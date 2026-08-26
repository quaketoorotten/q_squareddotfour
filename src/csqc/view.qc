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


// minimum speed to bob and play run/walk animations at
static const float 	MIN_BOB_SPEED = 5.0;
static const float	LAND_DEFLECT_TIME = 0.15;
static const float	LAND_RETURN_TIME = 0.3;
static const float	STEPUP_TIME = 0.2;
static const float	MAX_STEP_CHANGE = 18;

static const float 	PITCH 	= 0;
static const float 	YAW 	= 1;
static const float 	ROLL 	= 2;


static const float 	pm_walkbob 		= 0.3;
static const float 	pm_runbob 		= 0.4; 
static const float 	pm_runpitch 	= 0.002;
static const float 	pm_runroll 		= 0.005;
static const float 	pm_bobup 		= 0.005;
static const float 	pm_bobpitch 	= 0.002;
static const float 	pm_bobroll 		= 0.002;
static const float 	pm_stepsize 	= 16;

static const float	weaponOffsetTime = 600;
static const float	weaponOffsetScale = 0.002;

static const float	weaponAngleOffsetAverages = 10;
static const float	weaponAngleOffsetScale = 0.15;
static const float	weaponAngleOffsetMax = 3;

float	IT_INVISIBILITY			= 1<<19;
float	IT_REGENERATION		= 1<<20;
float	IT_SUIT					= 1<<21;
float	IT_QUAD					= 1<<22;

entity viewmodel_shell;

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

vector	gravityDir;

float() crandom =
{
    return 2 * (random() - 0.5);
};

float Lerp( float v1, float v2, float l ) {
	
	float this;

	if ( l <= 0.0f ) {
		this = v1;
	} else if ( l >= 1.0f ) {
		this = v2;
	} else {
		this = v1 + l * ( v2 - v1 );
	}
	return this;
};

vector getweaponang[14] =
{
	'0 0 0', // fist
	'1 -5.7 1.6', // blaster
	'-0.7 -7.4 -4.9', // machinegun
	'3 -8.5 -2', // shotgun
	'-1.6 2.5 6.2', // hyperblaster
	'9.7 4.6 -1.1', // grenade launcher
	'-3.1 -7.2 0.3', // nailgun
	'-5.7 -3.9 -1.2', // rocket launcher
	'-3 -9.4 2.3', // railgun
	'7.4 8.5 9.8', // thunderbolt
	'-0.7 -0.3 -1.5', // dark matter
	'0 0 0',
	'0 0 0',
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
	vector	gunpos = viewmodelpos * 3.5;

	// as the player changes direction, the gun will take a small lag
	vector	gunOfs = idPlayer_GunAcceleratingOffset();
	viewmodel.origin = getviewprop(VF_ORIGIN) + ( gunpos + gunOfs ) - getviewprop(VF_ORIGIN);

	// what the fuck ? ^

	// on odd legs, invert some angles
	if ( view.bobCycle & 128 ) {
		scale = -view.xyspeed;
	} else {
		scale = view.xyspeed;
	}

	float id = getstatf(STAT_WEAPONID);
	vector ang = getweaponang[id];
	float mod = 1;

	if (ang == '-0.7 -0.3 -1.5')
		mod = 0.25;

	// gun angles from bobbing
	viewmodel.angles[ROLL]		= scale * view.bobfracsin * 0.005;
	viewmodel.angles[YAW]		= scale * view.bobfracsin * 0.01;
	viewmodel.angles[PITCH]		= view.xyspeed * view.bobfracsin * 0.005;
	viewmodel.origin_z		    += (view.xyspeed * view.bobfracsin * 0.0015 * -1)*mod;

	viewmodel.angles = ang;

	// gun angles from turning
	vector	turnOfs = idPlayer_GunTurningOffset();
	//turnOfs[PITCH] 	*= -1;
	
	viewmodel.angles = viewmodel.angles + turnOfs;
	makevectors(getviewprop(VF_CL_VIEWANGLES));	

// RAVEN BEGIN
// abahr: when looking down, really large deflections cause back of weapons to show
	float landChangeFrac = Lerp( 0.25f, 0.05f, v_forward * gravityDir);
// RAVEN ABAHR

	// drop the weapon when landing after a jump / fall
	delta = time - view.landTime;
	if ( delta < LAND_DEFLECT_TIME ) {
		viewmodel.origin_z += ( view.landChange*landChangeFrac * delta / LAND_DEFLECT_TIME );

		//print ("not landed","\n");
	} else if ( delta < LAND_DEFLECT_TIME + LAND_RETURN_TIME ) {
		viewmodel.origin_z += ( view.landChange*landChangeFrac * (LAND_DEFLECT_TIME + LAND_RETURN_TIME - delta) / LAND_RETURN_TIME );

	//	print ("landed","\n");

	}

	// speed sensitive idle drift
	scale = view.xyspeed * 0.5f + 40.0;
	fracsin = scale * sin( time ) * 0.01;
	viewmodel.angles[ROLL]	+= fracsin;
	viewmodel.angles[YAW]	+= fracsin;
	viewmodel.angles[PITCH]	+= fracsin;
}

//==============================================
//	idPlayer_BobCycle
//==============================================

float noclip;

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

	vector vel = client_velocity - ( client_velocity * gravityDir ) * gravityDir;

	if ( noclip ) {
		vel = '0 0 0';
	}
	
	view.xyspeed = sqrt(vel[0]*vel[0] + vel[1]*vel[1]);

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
		view.bobCycle = (int)( old + bobmove * (frametime * 1000) ) & 255; //gameLocal.msec -> frametime 0.0159
		view.bobFoot = ( view.bobCycle & 128 ) >> 7;
		view.bobfracsin = fabs( sin( ( view.bobCycle & 127 ) / 127.0 * M_PI ) );
	}

	// calculate angles for view bobbing
	view.viewBobAngles = view_angles;

	// no view bob at all in MP while zoomed in
	if( deathmatch && sfov == FOV_ZOOM ) {
		view.bobCycle = 0;
		view.bobFoot = 0;
		view.bobfracsin = 0;	
		return;
	}

	// add angles based on velocity
	delta = client_velocity * v_forward;
	view.viewBobAngles[PITCH] += delta * pm_runpitch;
	
	delta = client_velocity * v_right;
	view.viewBobAngles[ROLL] -= delta * pm_runroll;

	// add angles based on bob
	// make sure the bob is visible even at low speeds
	speed = view.xyspeed > 200 ? view.xyspeed : 200;
	
	// make sure bob isnt too vomiting
	speed = view.xyspeed < 230 ? view.xyspeed : 230;

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
		view_origin += gravityDir * (stepUpChange * ( STEPUP_TIME - deltaTime ) / STEPUP_TIME) ;
		//print(sprintf("%.2f\n", ( stepUpChange * ( STEPUP_TIME - deltaTime ) / STEPUP_TIME )));
	}
	
	// add bob height after any movement smoothing
	bob = view.bobfracsin * view.xyspeed * pm_bobup;
	if ( bob > 6 ) {
		bob = 6;
	}

	view.viewBob += bob * gravityDir;

	// add fall height
	delta = time - view.landTime;
	if ( delta < LAND_DEFLECT_TIME ) {
		f = delta / LAND_DEFLECT_TIME;
		view.viewBob -= gravityDir * ( view.landChange * f );
	} else if ( delta < LAND_DEFLECT_TIME + LAND_RETURN_TIME ) {
		delta -= LAND_DEFLECT_TIME;
		f = 1.0 - ( delta / LAND_RETURN_TIME );
		view.viewBob -= gravityDir * ( view.landChange * f );
	}

};

//==============================================
//	V_GunModel
//==============================================

float	IT_INVISIBILITY			= 1<<19;
float	IT_CHAINGUN				= 1<<4;
.vector glowmod;


void() viewmodel_do_gui = 
{	
	float ammo = getstatf(STAT_AMMO);
	float extra = 0;

	string wepname = getstats(47);

	if (flash_active)
		extra = getstatf(STAT_WEAPONID); // evil

	if (ammo == 0 && ((wepname == "weapon_railgun") || (wepname == "weapon_hyperblaster") 
		|| (wepname == "weapon_shotgun") || (wepname == "weapon_machinegun")))
		viewmodel.skin = 1 + extra;
	else
		viewmodel.skin = 0 + extra;
	
	if (wepname == "weapon_rocketlauncher")
	{	
		if (ammo == 0)
			viewmodel.skin = 3;
		else if (ammo == 1)
			viewmodel.skin = 2;
		else if (ammo == 2)
			viewmodel.skin = 1;
		else
			viewmodel.skin = 0;
	}
};

void() V_GunModel =
{
	if ( viewmodel ) {

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
			viewmodel.frame2time += frametime; // 0.0159
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
	
		viewmodel_do_gui();
				
		addentity(viewmodel);
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

static void(vector origin, string textname, float size, float alpha) Draw_LightningBolt =
{	
	makevectors(getviewprop(VF_CL_VIEWANGLES));
    
   	R_BeginPolygon(textname, DRAWFLAG_TWOSIDED);
	vector right = v_right, up = v_up;
	vector forward = v_forward;

	vector end = thunderbolt_endpoint1;

    // topright
    	R_PolygonVertex(origin + (up * size), [1, 0], [1, 1, 1], alpha);

    // topleft
    	R_PolygonVertex(origin - (up * size), [0, 0], [1, 1, 1], alpha);

    // botleft
    	R_PolygonVertex(end - (up * size), [0, 1], [1, 1, 1], alpha);

    // botright
    	R_PolygonVertex(end + (up * size), [1, 1], [1, 1, 1], alpha);


    	R_EndPolygon();
};

static void(vector origin, string textname, float size, float alpha) Draw_LightningBolt2 = 
{	
	makevectors(getviewprop(VF_CL_VIEWANGLES));
    
   	R_BeginPolygon(textname, DRAWFLAG_TWOSIDED);
	vector right = v_right, up = v_up;
	vector forward = v_forward;

	vector end = thunderbolt_endpoint1;

	R_BeginPolygon(textname, DRAWFLAG_TWOSIDED);

   // topright
    	R_PolygonVertex(origin + (right * size), [1, 0], [1, 1, 1], alpha);

    // topleft
    	R_PolygonVertex(origin - (right * size), [0, 0], [1, 1, 1], alpha);

    // botleft
    	R_PolygonVertex(end - (right * size), [0, 1], [1, 1, 1], alpha);

    // botright
    	R_PolygonVertex(end + (right * size), [1, 1], [1, 1, 1], alpha);

	R_EndPolygon();
};

float (string wepname) getmuzzleflashsize =
{
	if (wepname == "weapon_grenadelauncher")
		return 14;

	if (wepname == "weapon_rocketlauncher")
		return 20;

	if (wepname == "weapon_railgun")
		return 10;

	if (wepname == "weapon_nailgun")
		return rint(9 + random()*14);

	if (wepname == "weapon_machinegun")
		return rint(9 + random()*14);

	if (wepname == "weapon_hyperblaster")
		return rint(6 + random()*14);

	return rint(5 + random()*14);
};

string(string wepname) getmuzzleflashtext = 
{	
	if (wepname == "weapon_grenadelauncher")
		return "effects/weapons/shotgun_mflash";

	if (wepname == "weapon_shotgun")
		return "effects/weapons/shotgun_mflash";

	if (wepname == "weapon_rocketlauncher")
		return "effects/weapons/shotgun_mflash";

	if (wepname == "weapon_hyperblaster")
		return "effects/weapons/blaster_mflash";

	if (wepname == "weapon_blaster")
		return "effects/weapons/blaster_mflash";

	if (wepname == "weapon_railgun")
		return "effects/weapons/rail_mflash";
	
	return "effects/weapons/mgun_muzzleflash";
};

vector flashlight_org;

void () V_FlashOrg = 
{	
	if (!flash_active)
		return;
	
	vector taginf = gettaginfo (viewmodel, gettagindex(viewmodel, "tag_flash"));
	makevectors(getviewprop(VF_CL_VIEWANGLES));
	flashlight_org = v_right * -taginf_y + v_up * taginf_z + view_origin;
			
	float delta = time - view.landTime;	
	if ( delta < LAND_DEFLECT_TIME ) 
		flashlight_org[2] -= ( view.landChange*-0.8 * delta / LAND_DEFLECT_TIME );

	else if ( delta < LAND_DEFLECT_TIME + LAND_RETURN_TIME )
		flashlight_org[2] -= ( view.landChange*-1 * (LAND_DEFLECT_TIME + LAND_RETURN_TIME - delta) / LAND_RETURN_TIME ); 
};

void () V_Muzzleflash = 
{	
	if (getstatf(STAT_SFOV) == FOV_ZOOM)
		return;
	
	float draw_muzzleflash = getstatf(STAT_MUZZLEFLASH);
	if (!draw_muzzleflash)
	{
		//setmodel( streak, "" );
		return;
	}

	vector taginf = gettaginfo (viewmodel, gettagindex(viewmodel, "tag_muzzle"));
	makevectors(getviewprop(VF_CL_VIEWANGLES));
	muzzle_org = v_right * -taginf_y + v_up * taginf_z + v_forward * taginf_x + view_origin;
			
	float delta = time - view.landTime;	
	if ( delta < LAND_DEFLECT_TIME ) 
		muzzle_org[2] -= ( view.landChange*-0.8 * delta / LAND_DEFLECT_TIME );

	else if ( delta < LAND_DEFLECT_TIME + LAND_RETURN_TIME )
		muzzle_org[2] -= ( view.landChange*-1 * (LAND_DEFLECT_TIME + LAND_RETURN_TIME - delta) / LAND_RETURN_TIME ); 

	string wepname = getstats(47);
	
	if (draw_muzzleflash == 2 )
	{	
		pointparticles (particleeffectnum("TE_EXHAUST"), muzzle_org, '0 0 0', 1);
		//setmodel( streak, "" );
	}
	else if (draw_muzzleflash == 1 )
		Draw_Pane (muzzle_org, getmuzzleflashtext(wepname), getmuzzleflashsize(wepname), 1);
	
	else if (draw_muzzleflash == 3 )
	{
		//Draw_LightningBolt (muzzle_org, "effects/weapons/lightning_bolt", 8, 1);
		Draw_LightningBolt (muzzle_org, "effects/weapons/lightning_bolt", 16, 1);
		Draw_LightningBolt2 (muzzle_org, "effects/weapons/lightning_bolt", 16, 1);

		Draw_LightningBolt (muzzle_org + '0 0 -3.6', "effects/weapons/lightning_bolt", 8, 1);
		Draw_LightningBolt (muzzle_org + '0 0 3.6', "effects/weapons/lightning_bolt", 8, 1);

		Draw_LightningBolt2 (muzzle_org + '-3.6 0 0', "effects/weapons/lightning_bolt2", 8, 1);
		Draw_LightningBolt2 (muzzle_org + '3.6 0 0', "effects/weapons/lightning_bolt2", 8, 1);
		
		Draw_Pane (muzzle_org, "effects/weapons/blaster_mflash", rint(10 + random()*14), 1);
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


float		tlit_screen;

vector flashlight_color = '1.5 1.5 1.5';
float flashlight_intensity = 1;

void flashlight_think ()
{
//	entity eflash = self;
	entity plyr = edict_num(player_localentnum);

	if (tlit_screen || intermission > 0) {
		remove (self); // Dead or intermission or cut-scene
		return;
	}

	vector plyr_v_angle = getviewprop (VF_CL_VIEWANGLES);

	makevectors (getviewprop (VF_CL_VIEWANGLES));

	vector src = flashlight_org;
	vector dst = src + v_forward * 1024;
	traceline (src, dst, 2, plyr);

	float distance = vlen (trace_endpos - src);
	float truedist = distance;
	float luminance_base = 500;

	//if (distance > 200)
	//	luminance_base = 700;

	if (distance > luminance_base)
		distance = luminance_base;

	if (truedist < 120)
		truedist = 120;
	
	float luminance_factor = luminance_base - sqrt(truedist);

	if (luminance_factor < 20)
		luminance_factor = 20;

	self.origin = src;	
	self.origin += v_forward * sqrt(truedist) * (sqrt(truedist) / 3);

	self.light_lev	= luminance_factor;
	float dist_intensity = sqrt(truedist);

//	print(ftos(dist_intensity),"\n");

	if (dist_intensity < 2)
		dist_intensity = 2;

	self.color = flashlight_color * ((dist_intensity / 10));

	self.angles_x = (plyr_v_angle_x - 180);
	self.angles_y = plyr_v_angle_y;
	self.angles_z = plyr_v_angle_z;

	//self.think		= flashlight_think;
	//self.nextthink = time;
};

float FlashLight_Draw ()
{	
	self.think	();
	// Baker:  Sheesh ...
	// FTE: Cubemap orientation will be read from v_forward/v_right/v_up.
	//#305 void(vector org, float radius, vector lightcolours[, float style, string cubemapname, float pflags]) adddynamiclight (EXT_CSQC)
	float lightindex = dynamiclight_add (
		self.origin, 
		self.light_lev, 
		self.color, 
		-1, 
		"effects/flashlight5", 
		128 // And corona not specified. Baker July 4 2025
	); 

	dynamiclight_set (lightindex, LFIELD_ANGLES, self.angles);

	return PREDRAW_AUTOADD;
};

entity my_flashlight;

void flashlight_on()
{
	//entity plyr = edict_num (player_localentnum);
	entity oself;
	entity myflash		= spawn();

	myflash.origin		= flashlight_org;

	myflash.classname	= "flashlight";
	myflash.think		= flashlight_think;
	myflash.nextthink   = time;
	// myflash.drawmask	= MASK_NORMAL_4; // Baker: This means draw the entity.
	// And we ARE NOT drawing it!
	myflash.color		= flashlight_color;
	myflash.predraw		= FlashLight_Draw;
	myflash.drawmask	= MASK_ENGINE;

	oself = self;
	self = myflash;
	flashlight_think ();
	self = oself;

	my_flashlight = myflash;
};

void flashlight_toggle ()
{
	//precache_sound ("weapons/flashlight_click.ogg");

	//vector org = getviewprop(VF_ORIGIN);
	//pointsound (org, "weapons/flashlight_click.ogg", 1, ATTN_NORM_1);

	if (!my_flashlight) {
		//zpr ("Turning flashlight on");
		flashlight_on ();
		return;
	}

	//zpr ("Turning flashlight off");

	// Turn off
	for (entity flashlight = findchain(classname, "flashlight"); flashlight; flashlight = flashlight.chain) {		
		my_flashlight = __NULL__;
		remove (flashlight);
		flash_active = FALSE;
	} // for
};

//==============================================
//	V_CalcRefDef
//==============================================

static vector 		last_viewangles;
static float 		fix_angles;
float spowerups;


void() V_CalcRefDef =
{
	if (intermission) 
	{	
		if (!fix_angles)		
			fix_angles = TRUE;
		
		last_viewangles = view_angles;
		setviewprop(VF_AFOV, cvar("fov"));
		setproperty(VF_CL_VIEWANGLES, last_viewangles);
		setproperty(VF_ANGLES, last_viewangles);
		addentities(MASK_ENGINE);
		renderscene();
		return;
	}
	
	sfov = getstatf(STAT_SFOV);
	last_viewangles = view_angles;
	fix_angles = FALSE;
	
	old_client_origin = client_origin;
	client_origin = getentity(player_localentnum, GE_ORIGIN);
	
	view_origin = client_origin;
	view_origin_z += getstatf(STAT_VIEWHEIGHT);
	gravityDir = ( getentity(player_localentnum, GE_GRAVITYDIR) );

	gravityDir[0] = -gravityDir[0];
	gravityDir[1] = -gravityDir[1];
	gravityDir[2] = -gravityDir[2];

	if (getstatf(56) == 1 && !flash_active)
	{	
		//print ("???" ,"\n");
		flash_active = TRUE;
		flash_activate = TRUE;
	}	

	if (flash_activate)
	{	
		flashlight_toggle ();
		flash_activate = FALSE;
	}

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

	if (sfov > 0) // incase fov change is needed
		setviewprop(VF_AFOV, sfov);
	
	Pre_Lockedon_Marker ();
	Lockedon_Marker ();

	//flashlight_toggle ();

	
	if (cvar("r_drawviewmodel") == 0)
		setmodel( viewmodel, "" );
	else	
		V_GunModel();
	
	idPlayer_Think();
	
	idPlayer_BobCycle();

	idPlayer_CalculateViewWeaponPos();

	V_Muzzleflash ();
	V_FlashOrg ();

	spowerups = getstatbits(37, 0, 23);
	if (spowerups & IT_INVISIBILITY) // check invis powerup
	{	
		viewmodel.alpha = 0.2;
	}
	else
	{	
		viewmodel.alpha = 1;
	}
	
	//========================================================
	
	if (cvar("chase_active") == 1)
	{	
		makevectors(getviewprop(VF_CL_VIEWANGLES));
		setproperty(VF_ORIGIN, view_origin + v_forward * -64 + v_up * 24);
	}
	else
		setproperty(VF_ORIGIN, view_origin + view.viewBob);

	// let engine handle tilting the screen if we're dead.
	
	if (tlit_screen)
		return;
	
	setproperty(VF_ANGLES, view.viewBobAngles + view.punch);
};

void() V_Init =
{	
	viewmodel = spawn();
	
	viewmodel.renderflags = RF_VIEWMODEL|RF_DEPTHHACK;
	setmodel( viewmodel, "" );
	setorigin( viewmodel, '0 0 0');
	viewmodel.angles = '0 0 0';
	viewmodel.alpha = 1;
	viewmodel.colormod = '0 0 0';

	viewmodel_shell = spawn();
	
	viewmodel_shell.renderflags = RF_VIEWMODEL|RF_DEPTHHACK;
	setmodel( viewmodel_shell, "" );
	setorigin( viewmodel_shell, '0 0 0');
	viewmodel_shell.angles = '0 0 0';
	viewmodel_shell.alpha = 1;
	viewmodel_shell.colormod = '0 0 0';
	
	currentLoggedAccel = 0;
	framenum = 0;
	
	stepUpTime = 0.0;
	stepUpChange = 0.0;

	flashlight_org = '0 0 0';
	
	shaderforname ("effects/weapons/rail_mflash");
	shaderforname ("effects/weapons/darkmatterbolt");
	shaderforname ("effects/weapons/rail_trail");
	shaderforname ("effects/weapons/rail_trail_2");
	shaderforname ("effects/weapons/mgun_muzzleflash");
	shaderforname ("effects/weapons/shotgun_mflash");
	shaderforname ("effects/weapons/blaster_mflash");
	shaderforname ("effects/weapons/lightning_bolt");
	shaderforname ("effects/weapons/lightning_bolt2");
	shaderforname ("gfx/recticals/nailgun_scope_target");
	shaderforname ("gfx/recticals/nailgun_scope_target_NAN");
	shaderforname ("effects/weapons/guide");
	shaderforname ("effects/round");
	shaderforname ("gfx/hud/ekg2");
	shaderforname ("gfx/hud/ekg2_low");
};

