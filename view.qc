float STAT_SHAKETIME = 36;
float STAT_SHAKEPOWER = 35;

float STAT_VIEWMODELPOS_X = 41;
float STAT_VIEWMODELPOS_Y = 42;
float STAT_VIEWMODELPOS_Z = 43;

float STAT_VIEWMODEL_MOD = 44;

static vector viewmodelpos;

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
	
	if ( (cur_buttons & 2) && !(view.old_onground)) {
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
	float viewmodel_modifier = getstatf(STAT_VIEWMODEL_MOD);
	
	if (viewmodel_modifier == 0)
		viewmodel_modifier = 1;

	// as the player changes direction, the gun will take a small lag
	vector	gunOfs = idPlayer_GunAcceleratingOffset();
	viewmodel.origin = getviewprop(VF_ORIGIN) + (gunpos + gunOfs) * viewmodel_modifier + viewmodelpos - getviewprop(VF_ORIGIN);

	// on odd legs, invert some angles
	if ( view.bobCycle & 128 ) {
		scale = -view.xyspeed;
	} else {
		scale = view.xyspeed;
	}

	// gun angles from bobbing
	viewmodel.angles[ROLL]		= scale * view.bobfracsin * 0.005;
	viewmodel.angles[YAW]		= scale * view.bobfracsin * 0.01;
	viewmodel.angles[PITCH]		= view.xyspeed * view.bobfracsin * 0.005 * -1;

	// gun angles from turning
	vector	turnOfs = idPlayer_GunTurningOffset();
	turnOfs[PITCH] 	*= -1;
	
	viewmodel.angles = viewmodel.angles + turnOfs;

	// drop the weapon when landing after a jump / fall
	delta = time - view.landTime;
	if ( delta < LAND_DEFLECT_TIME ) {
		viewmodel.origin_z += ( view.landChange*0.25 * delta / LAND_DEFLECT_TIME );
	} else if ( delta < LAND_DEFLECT_TIME + LAND_RETURN_TIME ) {
		viewmodel.origin_z += ( view.landChange*0.25 * (LAND_DEFLECT_TIME + LAND_RETURN_TIME - delta) / LAND_RETURN_TIME );
	}

	// speed sensitive idle drift
	scale = view.xyspeed + 40.0;
	fracsin = scale * sin( time ) * 0.01;
	viewmodel.angles[ROLL]	+= fracsin;
	viewmodel.angles[YAW]	+= fracsin;
	viewmodel.angles[PITCH]	+= -fracsin;

	viewmodel.angles *= viewmodel_modifier;
};

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


void() V_GunModel =
{
	if ( viewmodel ) {
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
			viewmodel.lerptime = 0.0159;
		}
		
		if ( cvar("r_lerpmodels")) {
			viewmodel.lerpfrac = (viewmodel.frame1time - viewmodel.frame2time) / viewmodel.lerptime;
			viewmodel.frame2time += 0.0159;
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
	}
};

//==============================================
//	V_CalcRefDef
//==============================================

static vector 		last_viewangles;
static float 		fix_angles;
float STAT_SFOV = 39;

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

	V_GunModel();
	
	idPlayer_Think();
	
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
};