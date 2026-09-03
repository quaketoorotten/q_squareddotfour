
void() SUB_Null = {};

void() SUB_Remove = {remove(self);};


/*
QuakeEd only writes a single float for angles (bad idea), so up and down are
just constant angles.
*/
void() SetMovedir =
{
	if (self.angles == '0 -1 0')
		self.movedir = '0 0 1';
	else if (self.angles == '0 -2 0')
		self.movedir = '0 0 -1';
	else
	{
		makevectors (self.angles);
		self.movedir = v_forward;
	}
	
	self.angles = '0 0 0';
};

/*
================
InitTrigger
================
*/
void() InitTrigger =
{
// trigger angles are used for one-way touches.  An angle of 0 is assumed
// to mean no restrictions, so use a yaw of 360 instead.
	if (self.angles != '0 0 0')
		SetMovedir ();
	self.solid = SOLID_TRIGGER;
	setmodel (self, self.model);	// set size and link into world
	self.movetype = MOVETYPE_NONE;
	self.modelindex = 0;
	self.model = "";
};

/*
=============
SUB_CalcMove

calculate self.velocity and self.nextthink to reach dest from
self.origin traveling at speed
===============
*/
void(entity ent, vector tdest, float tspeed, void() func) SUB_CalcMoveEnt =
{
local entity	stemp;
	stemp = self;
	self = ent;

	SUB_CalcMove (tdest, tspeed, func);
	self = stemp;
};

void(vector tdest, float tspeed, void() func) SUB_CalcMove =
{
local vector	vdestdelta;
local float		len, traveltime;

	if (!tspeed)
		objerror("No speed is defined!");

	self.think1 = func;
	self.finaldest = tdest;
	self.think = SUB_CalcMoveDone;

	if (tdest == self.origin)
	{
		self.velocity = '0 0 0';
		self.nextthink = self.ltime + 0.1;
		return;
	}
		
// set destdelta to the vector needed to move
	vdestdelta = tdest - self.origin;
	
// calculate length of vector
	len = vlen (vdestdelta);
	
// divide by speed to get time to reach dest
	traveltime = len / tspeed;

	if (traveltime < 0.1)
	{
		self.velocity = '0 0 0';
		self.nextthink = self.ltime + 0.1;
		return;
	}
	
// set nextthink to trigger a think when dest is reached
	self.nextthink = self.ltime + traveltime;

// scale the destdelta vector by the time spent traveling to get velocity
	self.velocity = vdestdelta * (1/traveltime);	// qcc won't take vec/float	
};

/*
============
After moving, set origin to exact final destination
============
*/
void()  SUB_CalcMoveDone =
{
	setorigin(self, self.finaldest);
	self.velocity = '0 0 0';
	self.nextthink = -1;
	if (self.think1)
		self.think1();
};


/*
=============
SUB_CalcAngleMove

calculate self.avelocity and self.nextthink to reach destangle from
self.angles rotating 

The calling function should make sure self.think is valid
===============
*/
void(entity ent, vector destangle, float tspeed, void() func) SUB_CalcAngleMoveEnt =
{
local entity		stemp;
	stemp = self;
	self = ent;
	SUB_CalcAngleMove (destangle, tspeed, func);
	self = stemp;
};

void(vector destangle, float tspeed, void() func) SUB_CalcAngleMove =
{
local vector	destdelta;
local float		len, traveltime;

	if (!tspeed)
		objerror("No speed is defined!");
		
// set destdelta to the vector needed to move
	destdelta = destangle - self.angles;
	
// calculate length of vector
	len = vlen (destdelta);
	
// divide by speed to get time to reach dest
	traveltime = len / tspeed;

// set nextthink to trigger a think when dest is reached
	self.nextthink = self.ltime + traveltime;

// scale the destdelta vector by the time spent traveling to get velocity
	self.avelocity = destdelta * (1 / traveltime);
	
	self.think1 = func;
	self.finalangle = destangle;
	self.think = SUB_CalcAngleMoveDone;
};

/*
============
After rotating, set angle to exact final angle
============
*/
void() SUB_CalcAngleMoveDone =
{
	self.angles = self.finalangle;
	self.avelocity = '0 0 0';
	self.nextthink = -1;
	if (self.think1)
		self.think1();
};

//=========================
//
// SUB_NormalizeAngles
//
//=========================

vector ( vector ang ) SUB_NormalizeAngles =
   {
   while( ang_x > 360 )
      {
      ang_x = ang_x - 360;
      }
   while( ang_x < 0 )
      {
      ang_x = ang_x + 360;
      }

   while( ang_y > 360 )
      {
      ang_y = ang_y - 360;
      }
   while( ang_y < 0 )
      {
      ang_y = ang_y + 360;
      }

   while( ang_z > 360 )
      {
      ang_z = ang_z - 360;
      }
   while( ang_z < 0 )
      {
      ang_z = ang_z + 360;
      }

   return ang;
   };

//=============================================================================

void() DelayThink =
{
	activator = self.enemy;
	SUB_UseTargets ();
	remove(self);
};

/*
==============================
SUB_UseTargets

the global "activator" should be set to the entity that initiated the firing.

If self.delay is set, a DelayedUse entity will be created that will actually
do the SUB_UseTargets after that many seconds have passed.

Centerprints any self.message to the activator.

Removes all entities with a targetname that match self.killtarget,
and removes them, so some events can remove other triggers.

Search for (string)targetname in all entities that
match (string)self.target and call their .use function

==============================
*/
void() SUB_UseTargets =
{
	entity t, stemp, otemp, act;

//
// check for a delay
//
	if (self.delay)
	{
	// create a temp object to fire at a later time
		t = spawn();
		t.classname = "DelayedUse";
		t.nextthink = time + self.delay;
		t.think = DelayThink;
		t.enemy = activator;
		t.message = self.message;
		t.killtarget = self.killtarget;
		t.target = self.target;
		return;
	}


//
// print the message
//
	if (activator.classname == "player" && self.message != "")
	{
		centerprint(activator, self.message);
		if (!self.noise)
			sound(activator, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);
	}

//
// kill the killtagets
//
	if (self.killtarget)
	{
		t = world;
		do
		{
			t = find(t, targetname, self.killtarget);
			if (!t)
				return;
			remove(t);
		} while (1);
	}

//
// fire targets
//
	if (self.target)
	{
		act = activator;
		t = world;
		do
		{
			t = find(t, targetname, self.target);
			if (!t)
			{
				return;
			}
			stemp = self;
			otemp = other;
			self = t;
			other = stemp;
			if (self.use != SUB_Null)
			{
				if (self.use)
					self.use();
			}
			self = stemp;
			other = otemp;
			activator = act;
		} while (1);
	}


};
//============================================================

float(entity e) SUB_KillBox =
{	
	local float oldsolid = e.solid;

	e.solid = SOLID_BBOX;
	while(1)
	{
		tracebox (e.origin, e.mins, e.maxs, e.origin, FALSE, self);
		if(!trace_ent)
			break;
		
		if(trace_ent.deadflag)
			return FALSE;		

		T_Damage (trace_ent, e, e.origin, e, trace_ent.health + 10000, 0);
		
		if (trace_ent.solid)
			return FALSE;
	}
	
	e.solid = oldsolid;
	return TRUE;
};

void(float start, float end, void() thinker, float speed, void() extra_thinker) SUB_AnimateWeapon =
{		
	if (self.weaponframe != start && self.weaponframe > end + 1)
		self.weaponframe = start;

	if (self.weaponframe >= end)
	{
		self.think = thinker;
		self.nextthink = time + speed;
		return;
	}
	
	self.weaponframe++;
	// self.think = self.think2;
	self.nextthink = time + speed;

	extra_thinker();
};

void(float start, float end, void() thinker, float speed, void() extra_thinker) SUB_Animate =
{		
	if (self.frame >= end)
	{
		thinker ();
		extra_thinker();
		return;
	}
	
	self.frame++;
	self.nextthink = time + speed;

	extra_thinker();
};

		
void(float normal) SUB_AttackFinished =
{	
	self.cnt = 0;
	self.attack_finished = time + normal;
};

void(entity ent, float normal) SUB_AttackFinished_notself =
{	
	ent.cnt = 0;
	ent.attack_finished = time + normal;
};

float (entity targ) visible;

void (void() thinkst) SUB_CheckRefire =
{	
	if (skill < 2)
		return;
	if (self.cnt == 1)
		return;
	if (!visible (self.enemy))
		return;
	self.cnt = 1;
	self.think = thinkst;
};

float (float thinkst) SUB_CheckRefireFrame =
{	
	//if (skill < 2)
	//	return FALSE;
	if (self.cnt == 1)
		return FALSE;
	if (!visible (self.enemy))
		return FALSE;
	self.cnt = 1;
	self.frame = thinkst;
	return TRUE;
};

static float (float angle) normalize180_helper =
{
	angle -= floor( angle / 360) * 360;
	if ( angle > 180 ) {
		angle -= 360;
	}
	else if ( angle < -180 ) {
		angle += 360;
	}
	return angle;
}

vector(vector angle)  Normalize180 = 
{	
	angle[0] = normalize180_helper (angle[0]);
	angle[1] = normalize180_helper (angle[1]);
	angle[2] = normalize180_helper (angle[2]);

	return angle;
}

vector (vector a, vector b, vector forward, vector right) ProjectAim =
{
	local vector spit;
	spit = a + forward * b[0] + right * b[1];
	spit_z = spit_z + b[2];
	
	return spit;
};

vector (float x, float y, float z) setvector = 
{
	local vector v;
	v_x = x;
	v_y = y;
	v_z = z;
	return v;
};

float rand() =
{
	return random()*32767;
};

void(vector start, vector pos) line = 
{	
	if (cvar("developer") == 0)
		return;

		WriteByte (MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte (MSG_MULTICAST, THUNDER_STARTPOS);
		WriteCoord (MSG_MULTICAST, pos_x);
		WriteCoord (MSG_MULTICAST, pos_y);
		WriteCoord (MSG_MULTICAST, pos_z);

		WriteCoord (MSG_MULTICAST, start_x);
		WriteCoord (MSG_MULTICAST, start_y);
		WriteCoord (MSG_MULTICAST, start_z);

		WriteEntity (MSG_MULTICAST, self);

		multicast('0 0 0', MULTICAST_ALL);
};


// quake 2 slough
void(__inout trace_t trace, vector start, vector smins, vector smaxs, vector end, entity ignore, float nomonsters) gi_trace = 
{	
	if (smins != '0 0 0' || smaxs != '0 0 0')
		tracebox (start, smins, smaxs, end, nomonsters, ignore);
	else
		traceline (start, end, nomonsters, ignore);

	trace.allsolid = trace_allsolid;
	trace.startsolid = trace_startsolid;
	trace.fraction = trace_fraction;
	trace.endpos = trace_endpos;
	trace.plane_normal = trace_plane_normal;
	trace.plane_dist = trace_plane_dist;
	trace._ent = trace_ent;
	trace.inopen = trace_inopen;
	trace.inwater = trace_inwater;
};

//
// CheckSpawnPoint
//
// PMM - checks volume to make sure we can spawn a monster there (is it solid?)
//
// This is all fliers should need
float (vector Eorigin, vector Emins, vector Emaxs) CheckSpawnPointQ2 =
{
	if (!Emins || !Emaxs)
		return FALSE;
	
	trace_t trace;
	
	gi_trace (trace, Eorigin, Emins, Emaxs, Eorigin + '0 0 24', self, FALSE);

	if (trace.startsolid || trace.allsolid)
		return FALSE;

	if (trace._ent != world)
		return FALSE;

	return TRUE;
};

//
// CheckGroundSpawnPoint
//
// PMM - used for walking monsters
//  checks:
//		1)	is there a ground within the specified height of the origin?
//		2)	is the ground non-water?
//		3)	is the ground flat enough to walk on?
//
float (vector ent_origin, vector ent_mins, vector ent_maxs, float height, float gravity) CheckGroundSpawnPoint =
{
	if (!CheckSpawnPointQ2 (ent_origin, ent_mins, ent_maxs))
		return FALSE;

	vector stop = ent_origin;
	stop[2] = ent_origin[2] + ent_mins[2] - height;

//	bprint (ftos(stop[2]), "\n");

	trace_t tr;
	gi_trace (tr, ent_origin, ent_mins, ent_maxs, stop, self, FALSE);

	//bprint (vtos(tr.plane_normal), "\n");

	// it's not going to be all solid or start solid, since that's checked above
	if ((tr.fraction < 1))
	{
		// we found a non-water surface down there somewhere.  now we need to check to make sure it's not too sloped
		//
		// algorithm straight out of m_move.c:M_CheckBottom()
		//

		// first, do the midpoint trace
		vector mins = tr.endpos + ent_mins;
		vector maxs = tr.endpos + ent_maxs;

		// first, do the easy flat check
		vector start;

		if (gravity > 0)
			start[2] = maxs[2] + 1;
		else
			start[2] = mins[2] - 1;

		for (float x = 0; x <= 1; x++)
			for (float y = 0; y <= 1; y++)
			{
				start[0] = x ? maxs[0] : mins[0];
				start[1] = y ? maxs[1] : mins[1];
				if (pointcontents (start) != CONTENT_SOLID)
					goto realcheck;
			}

		// if it passed all four above checks, we're done
		return TRUE;

realcheck:
		// check it for real
		start[0] = stop[0] = (mins[0] + maxs[0])*0.5;
		start[1] = stop[1] = (mins[1] + maxs[1])*0.5;
		start[2] = mins[2];

		gi_trace (tr, ent_origin, VEC_ORIGIN, VEC_ORIGIN, stop, self, FALSE);

		if (tr.fraction == 1.0)
			return FALSE;

		float mid, bottom;

		if (gravity < 0)
		{
			start[2] = mins[2];
			stop[2] = start[2] - 18 - 18;
			mid = bottom = tr.endpos[2] + ent_mins[2];
		}
		else
		{
			start[2] = maxs[2];
			stop[2] = start[2] + 18 + 18;
			mid = bottom = tr.endpos[2] - ent_maxs[2];
		}

		for (float x = 0; x <= 1; x++)
			for (float y = 0; y <= 1; y++)
			{
				start[0] = stop[0] = x ? maxs[0] : mins[0];
				start[1] = stop[1] = y ? maxs[1] : mins[1];

			//	traceline (start, stop, 0, self);
				gi_trace (tr, start, VEC_ORIGIN, VEC_ORIGIN, stop, self, FALSE);
			// 	tr.fraction = trace_fraction;
			//	tr.endpos = trace_endpos; 

				if(gravity > 0)
				{
					if (tr.fraction != 1.0 && tr.endpos[2] < bottom)
						bottom = tr.endpos[2];
					if (tr.fraction == 1.0 || tr.endpos[2] - mid > 18)
						return FALSE;
				}
				else
				{
					if (tr.fraction != 1.0 && tr.endpos[2] > bottom)
						bottom = tr.endpos[2];
					if (tr.fraction == 1.0 || mid - tr.endpos[2] > 18)
						return FALSE;
				}
			}

		return TRUE; // we can land on it, it's ok
	}

	// otherwise, it's either water (bad) or not there (too far)
	// if we're here, it's bad below
	return FALSE;
};

entity CreateGroundMonster (vector org, vector ang, vector entMins, vector entMaxs, string name, void() name2, float height) =
{
//	trace_t		tr;

	if (org == '0 0 0')
		return world;

	// check the ground to make sure it's there, it's relatively flat, and it's not toxic
	if (!CheckGroundSpawnPoint(org, entMins, entMaxs, height, -1))
		return world;

	return CreateMonster (org, ang, name, name2);
};

entity CreateMonster(vector org, vector ang, string name, void() monster) =
{
	local entity newEnt;

	newEnt = spawn();

	newEnt.origin = org;
	newEnt.angles = ang;
	newEnt.classname = name;
	newEnt.flags |= FL_RESURRECTED;

	local entity oself = self;
	self = newEnt;
	monster();
	SUB_KillBox (self);
	self = oself;
	
	return newEnt;
};

// FindSpawnPoint
// PMM - this is used by the medic commander (possibly by the carrier) to find a good spawn point
// if the startpoint is bad, try above the startpoint for a bit

vector FindSpawnPoint (vector startpoint, vector Emins, vector Emaxs, vector spawnpoint, float maxMoveUp) =
{
	local float		height;
	local vector		top;

	trace_t tr;

	height = Emaxs[2] - Emins[2];

//	tr = gi.trace (startpoint, mins, maxs, startpoint, NULL, MASK_MONSTERSOLID|CONTENTS_PLAYERCLIP);
	gi_trace (tr, startpoint, Emins, Emaxs, startpoint, self, FALSE);

	if((tr.startsolid || tr.allsolid))
	{
		top = startpoint;
		top[2] += maxMoveUp;

		//tracebox(top, Emins, Emaxs, startpoint, FALSE, self);
		gi_trace (tr, top, Emins, Emaxs, startpoint, self, FALSE);

		if (tr.startsolid || tr.allsolid || tr._ent)
			return '0 0 0';
		else
		{
//			if ((g_showlogic) && (g_showlogic->value))
//				gi.dprintf ("FindSpawnPoint: %s -> %s\n", vtos (startpoint), vtos (tr.endpos));
			//spawnpoint = trace_endpos;
			return tr.endpos;
		}
	}
	else
	{
		//spawnpoint = startpoint;
		return tr.endpos;
	}
}

void AngleVectors (vector  angles, optional __inout vector forward, optional __inout vector right, optional __inout vector  up)
{
	float angle = angles[1] * (M_PI * 2 / 360);
	float sy = sin(angle);
	float cy = cos(angle);
	angle = angles[0] * (M_PI * 2 / 360);
	float sp = sin(angle);
	float cp = cos(angle);
	angle = angles[2] * (M_PI * 2 / 360);
	float sr = sin(angle);
	float cr = cos(angle);

	forward_x = cp * cy;
	forward_y = cp * sy;
	forward_z = -sp;

	right_x = (-1 * sr * sp * cy + -1 * cr * -sy);
	right_y = (-1 * sr * sp * sy + -1 * cr * cy);
	right_z = -1 * sr * cp;
	
	up_x = (cr * sp * cy + -sr * -sy);
	up_y = (cr * sp * sy + -sr * cy);
	up_z = cr * cp;
}

// weapon ammo stuff

void() SUB_Assign_NoAmmo 	  		= {	self.currentammo = 0; self.ammotype = IT_EMPTY;}
void() SUB_Assign_Saved_Shells	 	= {	self.currentammo = self.savedammo_shells; self.ammotype = IT_SHELLS;}
void() SUB_Assign_Saved_Bullets  	= {	self.currentammo = self.savedammo_bullets; self.ammotype = IT_BULLETS;}
void() SUB_Assign_Saved_Nails	  	= {	self.currentammo = self.savedammo_nails; self.ammotype = IT_NAILS;}
void() SUB_Assign_Saved_Grenades 	= {	self.currentammo = self.savedammo_grenades; self.ammotype = IT_GRENADES;}
void() SUB_Assign_Saved_Rockets 	= {	self.currentammo = self.savedammo_rockets; self.ammotype = IT_ROCKETS;}

void() SUB_Assign_Saved_Cells  		= {	self.currentammo = self.savedammo_cells; self.ammotype = IT_CELLS;}
void() SUB_Assign_Saved_Coils	  	= {	self.currentammo = self.ammo_coils; self.ammotype = IT_COILS;}

void() SUB_Assign_Saved_Slugs	  	= {	self.currentammo = self.savedammo_slugs; self.ammotype = IT_SLUGS;}
void() SUB_Assign_Saved_DMC 	  	= {	self.currentammo = self.savedammo_dmc; self.ammotype = IT_DMC;}


//========================================================================

//shells
float() getshells = {return self.ammo_shells;};

void(float a) save_sammo = 
{
	self.ammo_shells = a;
	self.savedammo_shells = self.currentammo;
};

//========================================================================
// nails
float() get_nails = {return self.ammo_nails;};
float() get_bullets = {return self.ammo_bullets;};

void(float a) save_bammo = 
{
	self.ammo_bullets = a;
	self.savedammo_bullets = self.currentammo;
};

void(float a) save_nammo = 
{
	self.ammo_nails = a;
	self.savedammo_nails = self.currentammo;
};
//========================================================================
// rockets
float() get_grenades = {return self.ammo_grenades;};
float() get_rockets = {return self.ammo_rockets;};

void(float a) save_gammo = 
{
	self.ammo_grenades = a;
	self.savedammo_grenades = self.currentammo;
};

void(float a) save_rammo = 
{
	self.ammo_rockets = a;
	self.savedammo_rockets = self.currentammo;
};

//========================================================================
// cells
float() getcells = {return self.ammo_cells;};
float() getcoils = {return self.ammo_coils;};

void(float a) save_c1ammo = 
{
	self.ammo_cells = a;
	self.savedammo_cells = self.currentammo;
};

void(float a) save_c2ammo = 
{
	self.ammo_coils = a;
	self.currentammo = self.ammo_coils;
	
};

float() get_slugs = {return self.ammo_slugs;};

void(float a) save_slugammo = 
{
	self.ammo_slugs = a;
	self.savedammo_slugs = self.currentammo;
	
};

//======================================================================
float() get_dmc = {return self.ammo_dmc;};
void(float a) save_dmcammo =
{
	self.ammo_dmc = a;
	self.savedammo_dmc = self.currentammo;	
};


float(float rad, entity checker, entity target) SUB_CheckinRange =
{	
	if (checker.aiflags & AI_SCRIPTED_ACTION)
		return FALSE;

	if (target.health <= 0)
		return FALSE;

	vector spot1 = checker.origin + checker.view_ofs;
	vector spot2 = target.origin + target.view_ofs;

	if (vlen(spot1 - spot2) <= rad)
		return TRUE;
	
	return FALSE;
};