float STAT_SHAKETIME = 36;
float STAT_SHAKEPOWER = 35;

float STAT_VIEWMODELPOS_X = 41;
float STAT_VIEWMODELPOS_Y = 42;
float STAT_VIEWMODELPOS_Z = 43;
float STAT_SFOV = 39;

float FOV_ZOOM = 70;

float STAT_MUZZLEFLASH = 44; 
float STAT_WEAPONID = 33;

static vector viewmodelpos;
static vector muzzle_org;

entity streak;

// minimum speed to bob and play run/walk animations at
static const float 	MIN_BOB_SPEED = 5.0;
static const float	LAND_DEFLECT_TIME = 0.15;
static const float	LAND_RETURN_TIME = 0.3;
static const float	STEPUP_TIME = 0.2;
static const float	MAX_STEP_CHANGE = 18;

static const float 	PITCH 	= 0;
static const float 	YAW 	= 1;
static const float 	ROLL 	= 2;

static const float 	M_PI = 3.14159265358979323846;

static const float 	pm_walkbob 	= 0.3;
static const float 	pm_runbob 		= 0.4;
static const float 	pm_runpitch 	= 0.002;
static const float 	pm_runroll 	= 0.005;
static const float 	pm_bobup 		= 0.005;
static const float 	pm_bobpitch 	= 0.002;
static const float 	pm_bobroll 	= 0.002;
static const float 	pm_stepsize 	= 16;

static const float	weaponOffsetTime = 0.4;
static const float	weaponOffsetScale = 0.0025;

static const float	weaponAngleOffsetAverages = 10;
static const float	weaponAngleOffsetScale = 0.25;
static const float	weaponAngleOffsetMax = 10;

//==============================================

typedef struct {
	float	_time;
	vector	dir;		// scaled larger for running
} loggedAccel_t;

static const float	NUM_LOGGED_VIEW_ANGLES = 64;		// for weapon turning angle offsets
static vector		loggedViewAngles[NUM_LOGGED_VIEW_ANGLES];	// [gameLocal.framenum&(LOGGED_VIEW_ANGLES-1)]
static const float	NUM_LOGGED_ACCELS = 16;			// for weapon turning angle offsets
loggedAccel_t		loggedAccel[NUM_LOGGED_ACCELS];	// [currentLoggedAccel & (NUM_LOGGED_ACCELS-1)]
static float		currentLoggedAccel;

//==============================================

typedef struct
{
	float 	bobFoot;
	float 	bobFrac;
	float 	bobfracsin;
	float 	bobCycle;
	float 	xyspeed;
	float 	landChange;
	float 	landTime;
	float	old_onground;
	float	onground;
	vector 	viewBobAngles;
	vector 	viewBob;
	vector 	punch;
} view_bob_t;

static view_bob_t 	view;

static vector 	old_client_origin;
static vector 	client_origin;
static vector 	view_origin;
static vector 	old_client_velocity;
static vector 	client_velocity;
static entity 	viewmodel;
static float 	framenum;
static float	stepUpTime;
static float	stepUpChange;

// fte for some reason seems to forget what the input globals
// are so inputs will be copied here

float		cur_buttons;
vector		cur_movevalues;
float		old_buttons;
vector		old_movevalues;
float		shakeinterval;

float() crandom =
{
    return 2 * (random() - 0.5);
};

vector getweaponang[14] =
{
	'0 0 0', // fist
	'0 0 0', // fist
	'0 0 0', // pistol
	'0 0 0', // shotgun
	'-1.6 2.5 6.2', // hyperblaster
	'9.7 4.6 -1.1', // grenade launcher
	'-3.1 -7.2 0.3', // nailgun
	'-5.7 -3.9 -1.2', // rocket launcher
	'0 0 0', // rocket launcher
	'0 0 0', // bfg 9000
	'0 0 0', // chainsaw
	'0 0 0', // super shotgun
	'0 0 0', // soul cube
	'0 0 0', // fist
};

//==============================================
//	idPlayer::CrashLand
//==============================================

void() idPlayer_CrashLand =
{
	float		delta;
	float		dist;
	float		vel, acc;
	float		t;
	float		a, b, c, den;
	
	dist = client_origin_z - old_client_origin_z;
	vel = old_client_velocity_z;
	acc = -cvar("sv_gravity");
	
	a = acc / 2;
	b = vel;
	c = -dist;
	
	den =  b * b - 4 * a * c;
	if ( den < 0 ) {
		return;
	}
	t = (-b - sqrt( den ) ) / ( 2 * a );

	delta = vel + t * acc;
	delta = delta * delta * 0.0001;
	delta += 1.0;// cheat...
	
	if ( delta < 1 ) {
		return;
	}
	
	if ( delta > 75 ) {
		view.landChange = -32;
		view.landTime = time;
	} else if ( delta > 50 ) {
		view.landChange	= -24;
		view.landTime	= time;
	} else if ( delta > 30 ) {
		view.landChange	= -16;
		view.landTime	= time;
	} else if ( delta > 7 ) {
		view.landChange	= -8;
		view.landTime	= time;
	} else if ( delta > 3 ) {
		// just walk on
	}
};

//==============================================
//	idPlayer::HasSteppedUp
//==============================================

float() idPlayer_HasSteppedUp =
{
	// use the step move
	float	delta;

	if ( !view.onground ) {
		return FALSE;
	}

	if ( client_velocity_z > 0 ) {
		return FALSE;
	}

	delta = client_origin_z - old_client_origin_z;
	if ( delta > 2 ) {
		if ( delta < 7 ) {
			return 1;
		} else if ( delta < 11 ) {
			return 2;
		} else if ( delta < 15 ) {
			return 3;
		} else {
			return 4;
		}
	}
	return FALSE;
};

//==============================================
//	idPlayer::Think
//==============================================

void() idPlayer_Think =
{
	float 	idx;
	float	stepUp;

	framenum++;
	
	loggedViewAngles[ framenum & (NUM_LOGGED_VIEW_ANGLES-1) ] = input_angles;
	
	if ( !(view.old_onground) && (view.onground) ) {
		idPlayer_CrashLand();
	}
	
	stepUp = idPlayer_HasSteppedUp();
	
	if ( stepUp )
	{
		float	oldStep;
		int		delta;
		int		step;

		// check for stepping up before a previous step is completed
		delta = time - stepUpTime;
		if (delta < STEPUP_TIME) {
			oldStep = stepUpChange * (STEPUP_TIME - delta) / STEPUP_TIME;
		} else {
			oldStep = 0;
		}

		// add this amount
		step = 4 * stepUp;
		stepUpChange = oldStep + step;
		if ( stepUpChange > MAX_STEP_CHANGE ) {
			stepUpChange = MAX_STEP_CHANGE;
		}
		stepUpTime = time;
	}
	
	if ( cur_buttons & 2 ) {
		// bounce the view weapon
		idx = currentLoggedAccel&(NUM_LOGGED_ACCELS-1);
		currentLoggedAccel++;
		loggedAccel[idx]._time = time;
		//print(sprintf("Jump %.2f\n", time));
		loggedAccel[idx].dir[2] = 200;
		loggedAccel[idx].dir[0] = loggedAccel[idx].dir[1] = 0;
	}
	
	// log movement changes for weapon bobbing effects
	if ( cur_movevalues_x != old_movevalues_x ) {
		idx = currentLoggedAccel&(NUM_LOGGED_ACCELS-1);
		currentLoggedAccel++;
		loggedAccel[idx]._time = time;
		loggedAccel[idx].dir[0] = cur_movevalues_x - old_movevalues_x;
		loggedAccel[idx].dir[1] = loggedAccel[idx].dir[2] = 0;
	}

	if ( cur_movevalues_y != old_movevalues_y ) {
		idx = currentLoggedAccel&(NUM_LOGGED_ACCELS-1);
		currentLoggedAccel++;
		loggedAccel[idx]._time = time;
		loggedAccel[idx].dir[1] = cur_movevalues_y - old_movevalues_y;
		loggedAccel[idx].dir[0] = loggedAccel[idx].dir[2] = 0;
	}
};

//==============================================
//	idPlayer::GunTurningOffset
//
//	generate a rotational offset for the gun based on the view angle
//	history in loggedViewAngles
//==============================================

vector() idPlayer_GunTurningOffset =
{
	vector		a;
	
	a = '0 0 0';

	if ( framenum < NUM_LOGGED_VIEW_ANGLES ) {
		return a;
	}

	vector 		current = loggedViewAngles[ framenum & (NUM_LOGGED_VIEW_ANGLES-1) ];
	vector		av;

	av = current;

	// calcualte this so the wrap arounds work properly
	for ( float j = 1 ; j < weaponAngleOffsetAverages ; j++ ) {
		vector a2 = loggedViewAngles[ ( framenum - j ) & (NUM_LOGGED_VIEW_ANGLES-1) ];

		vector delta = a2 - current;

		if ( delta_y > 180 ) {
			delta_y -= 360;
		} else if ( delta_y < -180 ) {
			delta_y += 360;
		}

		av += delta * ( 1.0 / weaponAngleOffsetAverages );
	}

	a = ( av - current ) * weaponAngleOffsetScale;

	// this caused an array error when inside a for loop
	// so this will have to suffice

	if ( a_x < -weaponAngleOffsetMax ) {
		a_x = -weaponAngleOffsetMax;
	} else if ( a_x > weaponAngleOffsetMax ) {
		a_x = weaponAngleOffsetMax;
	}
	
	if ( a_y < -weaponAngleOffsetMax ) {
		a_y = -weaponAngleOffsetMax;
	} else if ( a_y > weaponAngleOffsetMax ) {
		a_y = weaponAngleOffsetMax;
	}
	
	if ( a_z < -weaponAngleOffsetMax ) {
		a_z = -weaponAngleOffsetMax;
	} else if ( a_z > weaponAngleOffsetMax ) {
		a_z = weaponAngleOffsetMax;
	}
	
	return a;
};

//==============================================
//	idPlayer::GunAcceleratingOffset
//
//	generate a positional offset for the gun based on the movement
//	history in loggedAccelerations
//==============================================

vector() idPlayer_GunAcceleratingOffset =
{
	vector ofs = '0 0 0';
	
	float stop = currentLoggedAccel - NUM_LOGGED_ACCELS;
	if ( stop < 0 ) {
		stop = 0;
	}
	
	for ( float i = currentLoggedAccel-1 ; i > stop ; i-- ) {
		loggedAccel_t acc = loggedAccel[i&(NUM_LOGGED_ACCELS-1)];

		float	f;
		float	t = time - acc._time;
		
		if ( t >= weaponOffsetTime ) {
			break;	// remainder are too old to care about
		}

		f = t / weaponOffsetTime;
		f = ( cos( f * 2.0 * M_PI ) - 1.0 ) * 0.5;
		
		ofs = ofs + acc.dir * (f * weaponOffsetScale);
	}

	return ofs;
};

//==============================================
//	idPlayer::CalculateViewWeaponPos
//
//	Calculate the bobbing position of the view weapon
//==============================================

void() idPlayer_CalculateViewWeaponPos =
{
	float		scale;
	float		fracsin;
	float		delta;
	
	// these cvars are just for hand tweaking before moving a value to the weapon def
	vector	gunpos = '0 0 0';
	
	viewmodel.origin = viewmodelpos * 3.5;  // wait what

	// as the player changes direction, the gun will take a small lag
	vector	gunOfs = idPlayer_GunAcceleratingOffset();
	viewmodel.origin += getviewprop(VF_ORIGIN) + (gunpos + gunOfs) - getviewprop(VF_ORIGIN);

	// what the fuck ? ^

	// on odd legs, invert some angles
	if ( view.bobCycle & 128 ) {
		scale = -view.xyspeed;
	} else {
		scale = view.xyspeed;
	}

	// gun angles from bobbing
	viewmodel.angles[ROLL]		= scale * view.bobfracsin * 0.005;
	viewmodel.angles[YAW]		= scale * view.bobfracsin * 0.005;
	viewmodel.angles[PITCH]		= view.xyspeed * view.bobfracsin * 0.005 * -1;
	viewmodel.origin_z		+= view.xyspeed * view.bobfracsin * 0.003 * -1;
	
	float id = getstatf(STAT_WEAPONID);
	vector ang = getweaponang[id];
	viewmodel.angles += ang;

	// gun angles from turning
	vector	turnOfs = idPlayer_GunTurningOffset();
	turnOfs[PITCH] 	*= -1;
	
	viewmodel.angles = viewmodel.angles + turnOfs;

	// drop the weapon when landing after a jump / fall
	delta = time - view.landTime;
	if ( delta < LAND_DEFLECT_TIME ) {
		viewmodel.origin_z += ( view.landChange*0.25 * delta / LAND_DEFLECT_TIME );

		//print ("not landed","\n");
	} else if ( delta < LAND_DEFLECT_TIME + LAND_RETURN_TIME ) {
		viewmodel.origin_z += ( view.landChange*0.25 * (LAND_DEFLECT_TIME + LAND_RETURN_TIME - delta) / LAND_RETURN_TIME );

	//	print ("landed","\n");

	}

	// speed sensitive idle drift
	scale = view.xyspeed + 40.0;
	fracsin = scale * sin( time ) * 0.01;
	viewmodel.angles[ROLL]	+= fracsin;
	viewmodel.angles[YAW]	+= fracsin;
	viewmodel.angles[PITCH]	+= -fracsin;
}

//==============================================
//	idPlayer_BobCycle
//==============================================

void() idPlayer_BobCycle =
{
	float		bobmove;
	float		old;
	float		deltaTime;
	float		bob;
	float		delta;
	float		speed;
	float		f;

	makevectors(view_angles);
	view.xyspeed = sqrt(client_velocity[0]*client_velocity[0] + client_velocity[1]*client_velocity[1]);

	if ( !view.onground )  {
		// airborne
		view.bobCycle = 0;
		view.bobFoot = 0;
		view.bobfracsin = 0;
	} else if ( ( !cur_movevalues_x && !cur_movevalues_y ) || ( view.xyspeed <= MIN_BOB_SPEED ) ) {
		// start at beginning of cycle again
		view.bobCycle = 0;
		view.bobFoot = 0;
		view.bobfracsin = 0;
	} else {
		view.bobFrac = 1.0;
		
		// vary the bobbing based on the speed of the player
		bobmove = pm_walkbob * ( 1.0 - view.bobFrac ) + pm_runbob * view.bobFrac;

		// check for footstep / splash sounds
		old = view.bobCycle;
		view.bobCycle = (int)( old + bobmove * (0.0159 * 1000) ) & 255; //gameLocal.msec -> frametime
		view.bobFoot = ( view.bobCycle & 128 ) >> 7;
		view.bobfracsin = fabs( sin( ( view.bobCycle & 127 ) / 127.0 * M_PI ) );
	}

	// calculate angles for view bobbing
	view.viewBobAngles = view_angles;

	// add angles based on velocity
	delta = dotproduct (client_velocity, v_forward);
	view.viewBobAngles[PITCH] += delta * pm_runpitch;
	
	delta = dotproduct (client_velocity, v_right);
	view.viewBobAngles[ROLL] -= delta * pm_runroll;

	// add angles based on bob
	// make sure the bob is visible even at low speeds
	speed = view.xyspeed > 200 ? view.xyspeed : 200;

	delta = view.bobfracsin * pm_bobpitch * speed;

	view.viewBobAngles[PITCH] += delta;
	delta = view.bobfracsin * pm_bobroll * speed;

	if ( view.bobFoot & 1 ) {
		delta = -delta;
	}
	view.viewBobAngles[ROLL] += delta;

	// calculate position for view bobbing
	view.viewBob = '0 0 0';
	
	// if the player stepped up recently
	deltaTime = time - stepUpTime;
	if ( deltaTime < STEPUP_TIME ) {
		view_origin_z -= stepUpChange * ( STEPUP_TIME - deltaTime ) / STEPUP_TIME ;
		//print(sprintf("%.2f\n", ( stepUpChange * ( STEPUP_TIME - deltaTime ) / STEPUP_TIME )));
	}
	
	// add bob height after any movement smoothing
	bob = view.bobfracsin * view.xyspeed * pm_bobup;
	if ( bob > 6 ) {
		bob = 6;
	}
	view.viewBob[2] += bob;

	// add fall height
	delta = time - view.landTime;
	if ( delta < LAND_DEFLECT_TIME ) {
		f = delta / LAND_DEFLECT_TIME;
		view.viewBob[2] += ( view.landChange * f );
	} else if ( delta < LAND_DEFLECT_TIME + LAND_RETURN_TIME ) {
		delta -= LAND_DEFLECT_TIME;
		f = 1.0 - ( delta / LAND_RETURN_TIME );
		view.viewBob[2] += ( view.landChange * f );
	}

};

//==============================================
//	V_GunModel
//==============================================

float	IT_INVISIBILITY			= 1<<19;
float	IT_CHAINGUN				= 1<<4;
.vector glowmod;

void() V_GunModel =
{
	if ( viewmodel ) {

		float sfov = getstatf(STAT_SFOV);

		if (sfov == FOV_ZOOM)
		{
			viewmodel.modelindex = 0;	
			return;
		}

		float newframe, newmodel;
	
		newframe = getstatf(STAT_WEAPONFRAME);
		newmodel = getstatf(STAT_WEAPONMODELI);

		if (newmodel != viewmodel.modelindex) {	//changed entirly.
			viewmodel.modelindex = newmodel;
			viewmodel.frame2 = viewmodel.frame = newframe;
			viewmodel.frame2time = viewmodel.frame1time = viewmodel.lerptime = time;

		} else if (newframe != viewmodel.frame) {
			viewmodel.frame2 = viewmodel.frame;
			viewmodel.frame = newframe;
			viewmodel.frame2time = viewmodel.frame1time;
			viewmodel.frame1time = time;
			viewmodel.lerptime = viewmodel.frame1time - viewmodel.frame2time;
		}
		
		if ( viewmodel.lerptime < 0 ) {
			viewmodel.lerptime = 1.0;
		}
		
		if ( cvar("r_lerpmodels")) {
			viewmodel.lerpfrac = (viewmodel.frame1time - viewmodel.frame2time) / viewmodel.lerptime;
			viewmodel.frame2time += frametime;
		} else {
			viewmodel.lerpfrac = 0;
		}
		
		if (viewmodel.lerpfrac > 1.0) {
			viewmodel.lerpfrac = 1.0;
		}
		
		if (viewmodel.lerpfrac < 0.0) {
			viewmodel.lerpfrac = 0.0;
		}
		
		//print(sprintf("%f\n", view.bobfracsin));
		
		viewmodelpos_x = getstatf(STAT_VIEWMODELPOS_X);
		viewmodelpos_y = getstatf(STAT_VIEWMODELPOS_Y);
		viewmodelpos_z = getstatf(STAT_VIEWMODELPOS_Z);
		
		
		addentity(viewmodel);
		addentity(streak);
	}
};


void(vector origin, string textname, float size, float alpha) Draw_Pane =
{	
	makevectors(getviewprop(VF_CL_VIEWANGLES));
    
   	R_BeginPolygon(textname);
	vector right = v_right, up = v_up;

    // topright
    	R_PolygonVertex(origin + (right * size) + (up * size), [1, 0], [1, 1, 1], alpha);

    // topleft
    	R_PolygonVertex(origin - (right * size) + (up * size), [0, 0], [1, 1, 1], alpha);

    // botleft
    	R_PolygonVertex(origin - (right * size) - (up * size), [0, 1], [1, 1, 1], alpha);

    // botright
    	R_PolygonVertex(origin + (right * size) - (up * size), [1, 1], [1, 1, 1], alpha);

    	R_EndPolygon();
};

float () getmuzzleflashsize =
{
	if (getstats(47) == "weapon_grenadelauncher")
		return rint(12);

	if (getstats(47) == "weapon_rocketlauncher")
		return rint(16);

	if (getstats(47) == "weapon_nailgun")
		return rint(9 + random()*14);

	if (getstats(47) == "weapon_hyperblaster")
		return rint(6 + random()*14);

	return rint(5 + random()*14);
};

string() getmuzzleflashtext = 
{	
	if (getstats(47) == "weapon_grenadelauncher")
		return "effects/weapons/shotgun_mflash";

	if (getstats(47) == "weapon_rocketlauncher")
		return "effects/weapons/shotgun_mflash";

	if (getstats(47) == "weapon_hyperblaster")
		return "effects/weapons/blaster_mflash";
	
	return "effects/weapons/mgun_muzzleflash";
};

void () V_Muzzleflash = 
{	
	if (getstatf(STAT_SFOV) == FOV_ZOOM)
		return;

	if (getstatf(STAT_MUZZLEFLASH) == 0)
	{
		setmodel( streak, "" );
		return;
	}

	vector taginf = gettaginfo (viewmodel, gettagindex(viewmodel, "tag_muzzle"));
	makevectors(getviewprop(VF_CL_VIEWANGLES));
	muzzle_org = v_right * -taginf_y + v_up * taginf_z + v_forward * taginf_x + view_origin;
			
	float delta = time - view.landTime;	
	if ( delta < LAND_DEFLECT_TIME ) 
		muzzle_org_z -= ( view.landChange*-0.8 * delta / LAND_DEFLECT_TIME );

	else if ( delta < LAND_DEFLECT_TIME + LAND_RETURN_TIME )
		muzzle_org_z -= ( view.landChange*-1 * (LAND_DEFLECT_TIME + LAND_RETURN_TIME - delta) / LAND_RETURN_TIME ); 

	float deltaTime = time - stepUpTime;
	if ( deltaTime < STEPUP_TIME ) 
		muzzle_org_z -= stepUpChange * ( STEPUP_TIME - deltaTime ) / STEPUP_TIME;
	
	if (getstatf(STAT_MUZZLEFLASH) == 2 )
	{	
		pointparticles (particleeffectnum("TE_EXHAUST"), muzzle_org, '0 0 0', 1);
		setmodel( streak, "" );
	}
	else if (getstatf(STAT_MUZZLEFLASH) == 1 )
		Draw_Pane (muzzle_org, getmuzzleflashtext(), getmuzzleflashsize(), 1);
	
	if (getstatf(STAT_MUZZLEFLASH) == 2 )
		return;

	if (getstats(47) == "weapon_nailgun") // nailgun
	{	
		setmodel( streak, "progs/weapons/nailgun/nozzle_streak.md3" );
		streak.origin = viewmodel.origin;
		streak.angles = viewmodel.angles;
		streak.frame = viewmodel.frame;
	}
		
};

void() Lockedon_Marker =
{
	float enemy = getstatf(45);
	//print(ftos(enemy));	

	vector targ_org = getentity(enemy, GE_ORIGIN);
	vector targ_maxs = getentity(enemy, GE_MAXS);
	vector targ_mins = getentity(enemy, GE_MINS);
	vector org;

	if (getstats(47) == "weapon_rocketlauncher" && targ_org != '0 0 0') // draw guide
	{
		makevectors(getviewprop(VF_CL_VIEWANGLES));
		//org = targ_org + (targ_mins + targ_maxs)*0.5;
		pointparticles (particleeffectnum("TE_GUIDE"), targ_org + v_forward * -24, '0 0 0', 1);
	//	print ("hello");
		return;
	}
	
	//print(vtos(targ_org), "\n");
	if (targ_org == '0 0 0' || targ_maxs_z < 16)
		return;
	
	makevectors(getviewprop(VF_CL_VIEWANGLES));
	org = targ_org + (targ_mins + targ_maxs)*0.5;
	Draw_Pane (org + v_forward * -30, "gfx/recticals/nailgun_scope_target", 32, 1);
};

void() Pre_Lockedon_Marker =
{
	float enemy = getstatf(46);
	//print(ftos(enemy));	

	vector targ_org = getentity(enemy, GE_ORIGIN);
	vector targ_maxs = getentity(enemy, GE_MAXS);
	vector targ_mins = getentity(enemy, GE_MINS);

	//float targ_health = getentity(enemy, health);
	
	//print(vtos(targ_org), "\n");
	if (targ_org == '0 0 0' || targ_maxs_z < 16)
	{
		return;
	}
	
	makevectors(getviewprop(VF_CL_VIEWANGLES));
	vector org = targ_org + (targ_mins + targ_maxs)*0.5;
	Draw_Pane (org + v_forward * -30, "gfx/recticals/nailgun_scope_target_NAN", 32, 1);
};


//==============================================
//	V_CalcRefDef
//==============================================

static vector 		last_viewangles;
static float 		fix_angles;


void() V_CalcRefDef =
{
	if (intermission) 
	{	
		if (!fix_angles)
		{
			last_viewangles = view_angles;
			fix_angles = TRUE;
		}
		
		setviewprop(VF_AFOV, cvar("fov"));
		setproperty(VF_CL_VIEWANGLES, last_viewangles);
		setproperty(VF_ANGLES, last_viewangles);
		addentities(MASK_ENGINE);
		renderscene();
		return;
	}
	
	last_viewangles = view_angles;
	fix_angles = FALSE;
	
	old_client_origin = client_origin;
	client_origin = getentity(player_localentnum, GE_ORIGIN);
	
	view_origin = client_origin;
	view_origin_z += getstatf(STAT_VIEWHEIGHT);
	
	//========================================================
	
	old_client_velocity = client_velocity;
	client_velocity = [getstatf(STAT_VELOCITY_X), getstatf(STAT_VELOCITY_Y), getstatf(STAT_VELOCITY_Z)];
	
	view.old_onground = view.onground;
	view.onground = getstatf(STAT_FLAGS) & FL_ONGROUND;
	
	if (getstatf(STAT_SHAKETIME) > time)
	{
		if (shakeinterval < time)
			shakeinterval = time + 0.02;

		else
		{
			float shake = getstatf(STAT_SHAKEPOWER);
			view.punch = [crandom() * shake, crandom() * shake, crandom() * shake];
		}
	}
	else
		view.punch = [getstatf(STAT_PUNCHANGLE_X), getstatf(STAT_PUNCHANGLE_Y), getstatf(STAT_PUNCHANGLE_Z)];
	
	float sfov = getstatf(STAT_SFOV);

	if (sfov > 0) // incase fov change is needed
		setviewprop(VF_AFOV, sfov);
	
	Pre_Lockedon_Marker ();
	Lockedon_Marker ();

	V_GunModel();
	
	idPlayer_Think();
	
	V_Muzzleflash ();
	
	idPlayer_BobCycle();

	idPlayer_CalculateViewWeaponPos();

	float spowerups = getstatbits(37, 0, 23);
	if (spowerups & IT_INVISIBILITY) // check invis powerup
	{	
		viewmodel.colormod = '2 4 1';
		viewmodel.alpha = 0.4;
	}
	else
	{	
		viewmodel.colormod = '0 0 0';
		viewmodel.alpha = 1;
	}
	
	//========================================================

	// let engine handle tilting the screen if we're dead.
	if ( getstatf(STAT_HEALTH) <= 0 ) {
		return;
	}
	
	setproperty(VF_ANGLES, view.viewBobAngles + view.punch);
	setproperty(VF_ORIGIN, view_origin + view.viewBob);
};

void() V_Init =
{	
	streak = spawn();
	streak.renderflags = RF_VIEWMODEL|RF_DEPTHHACK;
	setmodel( streak, "" );
	setorigin( streak, '0 0 0');
	streak.angles = '0 0 0';
	streak.alpha = 1;
	streak.colormod = '0 0 0';

	viewmodel = spawn();
	
	viewmodel.renderflags = RF_VIEWMODEL|RF_DEPTHHACK;
	setmodel( viewmodel, "" );
	setorigin( viewmodel, '0 0 0');
	viewmodel.angles = '0 0 0';
	viewmodel.alpha = 1;
	viewmodel.colormod = '0 0 0';
	
	currentLoggedAccel = 0;
	framenum = 0;
	
	stepUpTime = 0.0;
	stepUpChange = 0.0;

	Draw_Pane ('0 0 0', "effects/weapons/mgun_muzzleflash", rint(5 + random()*14), 1);
	Draw_Pane ('0 0 0', "effects/weapons/shotgun_mflash", rint(5 + random()*14), 1);
	Draw_Pane ('0 0 0', "effects/weapons/blaster_mflash", rint(5 + random()*14), 1);
	Draw_Pane ('0 0 0', "gfx/recticals/nailgun_scope_target", 32, 1);
	Draw_Pane ('0 0 0', "gfx/recticals/nailgun_scope_target_NAN", 32, 1);
	Draw_Pane ('0 0 0', "effects/weapons/guide", rint(5 + random()*14), 1);
};