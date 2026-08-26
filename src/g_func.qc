
/*
==============================================================================

PLATS AND TRAINS

==============================================================================
*/

void() plat_center_touch;
void() plat_outside_touch;
void() plat_trigger_use;
void() plat_go_up;
void() plat_go_down;
void() plat_crush;
float PLAT_LOW_TRIGGER = 1;

void() plat_spawn_inside_trigger =
{
	local entity	trigger;
	local vector	tmin, tmax;

//
// middle trigger
//	
	trigger = spawn();
	trigger.touch = plat_center_touch;
	trigger.movetype = MOVETYPE_NONE;
	trigger.solid = SOLID_TRIGGER;
	trigger.enemy = self;
	
	tmin = self.mins + '25 25 0';
	tmax = self.maxs - '25 25 -8';
	tmin_z = tmax_z - (self.pos1_z - self.pos2_z + 8);
	if (self.spawnflags & PLAT_LOW_TRIGGER)
		tmax_z = tmin_z + 8;
	
	if (self.size_x <= 50)
	{
		tmin_x = (self.mins_x + self.maxs_x) / 2;
		tmax_x = tmin_x + 1;
	}
	if (self.size_y <= 50)
	{
		tmin_y = (self.mins_y + self.maxs_y) / 2;
		tmax_y = tmin_y + 1;
	}
	
	setsize (trigger, tmin, tmax);
};

void() plat_hit_top =
{
	sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	self.state = STATE_TOP;
	self.think = plat_go_down;
	self.nextthink = self.ltime + 3;
};

void() plat_hit_bottom =
{
	sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	self.state = STATE_BOTTOM;
};

void() plat_go_down =
{
	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	self.state = STATE_DOWN;
	SUB_CalcMove (self.pos2, self.speed, plat_hit_bottom);
};

void() plat_go_up =
{
	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	self.state = STATE_UP;
	SUB_CalcMove (self.pos1, self.speed, plat_hit_top);
};

void() plat_center_touch =
{	
	if (other.classname != "player")
		return;
		
	if (other.health <= 0)
		return;

	self = self.enemy;
	if (self.state == STATE_BOTTOM)
		plat_go_up ();
	else if (self.state == STATE_TOP)
		self.nextthink = self.ltime + 1;	// delay going down
};

void() plat_outside_touch =
{	
	if (other.classname != "player")
		return;

	if (other.health <= 0)
		return;
		
//dprint ("plat_outside_touch\n");
	self = self.enemy;
	if (self.state == STATE_TOP)
		plat_go_down ();
};

void() plat_trigger_use =
{
	if (self.think)
		return;		// allready activated
	plat_go_down();
};


void() plat_crush =
{
//dprint ("plat_crush\n");
	
	if (other.classname == "gib")
	{	
		pointparticles (particleeffectnum("TE_BLOODSPRAY"), other.origin);
		other.think = gib_Remove;
		other.nextthink = time;
		return;
	}

	if (other.health > 0)
		T_Damage (other, self, self.origin, self, 10, 0);
	else
		T_Damage (other, self, self.origin, self, 99999, 0);

	if (self.state == STATE_UP)
		plat_go_down ();
	else if (self.state == STATE_DOWN)
		plat_go_up ();
	else
		objerror ("plat_crush: bad self.state\n");
};

void() plat_use =
{
	self.use = SUB_Null;
	if (self.state != STATE_UP)
		objerror ("plat_use: not in up state");
	plat_go_down();
};


/*QUAKED func_plat (0 .5 .8) ? PLAT_LOW_TRIGGER
speed	default 150

Plats are always drawn in the extended position, so they will light correctly.

If the plat is the target of another trigger or button, it will start out disabled in the extended position until it is trigger, when it will lower and become a normal plat.

If the "height" key is set, that will determine the amount the plat moves, instead of being implicitly determined by the model's height.
Set "sounds" to one of the following:
1) base fast
2) chain slow
*/


void() func_plat =

{
//local entity t;

	if (!self.t_length)
		self.t_length = 80;
	if (!self.t_width)
		self.t_width = 10;

	if (self.sounds == 0)
		self.sounds = 2;
// FIX THIS TO LOAD A GENERIC PLAT SOUND

	if (self.sounds == 1)
	{
		precache_sound ("plats/plat1.wav");
		precache_sound ("plats/plat2.wav");
		self.noise = "plats/plat1.wav";
		self.noise1 = "plats/plat2.wav";
	}

	if (self.sounds == 2)
	{
		precache_sound ("plats/medplat1.wav");
		precache_sound ("plats/medplat2.wav");
		self.noise = "plats/medplat1.wav";
		self.noise1 = "plats/medplat2.wav";
	}


	self.mangle = self.angles;
	self.angles = '0 0 0';

	self.classname = "plat";
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	setorigin (self, self.origin);	
	setmodel (self, self.model);
	setsize (self, self.mins , self.maxs);

	self.blocked = plat_crush;
	if (!self.speed)
		self.speed = 150;

// pos1 is the top position, pos2 is the bottom
	self.pos1 = self.origin;
	self.pos2 = self.origin;
	if (self.height)
		self.pos2_z = self.origin_z - self.height;
	else
		self.pos2_z = self.origin_z - self.size_z + 8;

	self.use = plat_trigger_use;

	plat_spawn_inside_trigger ();	// the "start moving" trigger	

	if (self.targetname)
	{
		self.state = STATE_UP;
		self.use = plat_use;
	}
	else
	{
		setorigin (self, self.pos2);
		self.state = STATE_BOTTOM;
	}
};

//============================================================================

void() train_next;
void() func_train_find;

void() train_blocked =
{	
	if (other.classname == "gib")
	{	
		pointparticles (particleeffectnum("TE_BLOODSPRAY"), other.origin);
		other.think = gib_Remove;
		other.nextthink = time;
		return;
	}

	if (time < self.attack_finished)
		return;
	self.attack_finished = time + 0.5;

	if (other.health > 0)
		T_Damage (other, self,self.origin, self, self.dmg, 0);
	else
		T_Damage (other, self,self.origin, self, 999999, 0);
};
void() train_use =
{
	if (self.think != func_train_find)
		return;		// already activated
	train_next();
};

void() train_wait =
{
	if (self.wait)
	{
		self.nextthink = self.ltime + self.wait;
		sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	}
	else
		self.nextthink = self.ltime + 0.1;
	
	self.think = train_next;
};

void() train_next =
{
	local entity	targ;

	targ = find (world, targetname, self.target);
	self.target = targ.target;
	if (!self.target)
		objerror ("train_next: no next target");
	if (targ.wait)
		self.wait = targ.wait;
	else
		self.wait = 0;
	sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	SUB_CalcMove (targ.origin - self.mins, self.speed, train_wait);
};

void() func_train_find =

{
	local entity	targ;

	targ = find (world, targetname, self.target);
	self.target = targ.target;
	setorigin (self, targ.origin - self.mins);
	if (!self.targetname)
	{	// not triggered, so start immediately
		self.nextthink = self.ltime + 0.1;
		self.think = train_next;
	}
};

/*QUAKED func_train (0 .5 .8) ?
Trains are moving platforms that players can ride.
The targets origin specifies the min point of the train at each corner.
The train spawns at the first target it is pointing at.
If the train is the target of a button or trigger, it will not begin moving until activated.
speed	default 100
dmg		default	2
sounds
1) ratchet metal

*/
void() func_train =
{	
	if (!self.speed)
		self.speed = 100;
	if (!self.target)
		objerror ("func_train without a target");
	if (!self.dmg)
		self.dmg = 2;

	if (self.sounds == 0)
	{
		self.noise = ("misc/null.wav");
		precache_sound ("misc/null.wav");
		self.noise1 = ("misc/null.wav");
		precache_sound ("misc/null.wav");
	}

	if (self.sounds == 1)
	{
		self.noise = ("plats/train2.wav");
		precache_sound ("plats/train2.wav");
		self.noise1 = ("plats/train1.wav");
		precache_sound ("plats/train1.wav");
	}

	self.cnt = 1;
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	self.blocked = train_blocked;
	self.use = train_use;
	self.classname = "train";

	setmodel (self, self.model);
	setsize (self, self.mins , self.maxs);
	setorigin (self, self.origin);

// start trains on the second frame, to make sure their targets have had
// a chance to spawn
	self.nextthink = self.ltime + 0.1;
	self.think = func_train_find;
};

/*
==============================================================================

DOORS

==============================================================================
*/

/*

Doors are similar to buttons, but can spawn a fat trigger field around them
to open without a touch, and they link together to form simultanious
double/quad doors.
 
Door.owner is the master door.  If there is only one door, it points to itself.
If multiple doors, all will point to a single one.

Door.enemy chains from the master door through all doors linked in the chain.

*/

float DOOR_START_OPEN = 1;
float DOOR_CRUSHER = 128;
float DOOR_DONT_LINK = 4;
float DOOR_GOLD_KEY = 8;
float DOOR_SILVER_KEY = 16;
float DOOR_TOGGLE = 32;
float DOOR_NOMONSTER = 64;

/*
=============================================================================

DOOR THINK FUNCTIONS

=============================================================================
*/

void() door_go_down;
void() door_go_up;

void() door_blocked =
{
	if (other.classname == "gib")
	{	
		pointparticles (particleeffectnum("TE_BLOODSPRAY"), other.origin);
		other.think = gib_Remove;
		other.nextthink = time;
		return;
	}
	
	if (other.health > 0)
		T_Damage (other, self,self.origin, self, self.dmg, 0);
	else
		T_Damage (other, self,self.origin, self, 99999, 0);

	if (self.spawnflags & DOOR_CRUSHER)
		return;		
	
	// if a door has a negative wait, it would never come back if blocked,
	// so let it just squash the object to death real fast
	if (self.wait >= 0)
	{
		if (self.state == STATE_DOWN)
			door_go_up ();
		else
			door_go_down ();
	}
};


void() door_hit_top =
{
	sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	self.state = STATE_TOP;

	if (self.spawnflags & DOOR_TOGGLE)
		return;		// don't come down automatically

	self.think = door_go_down;
	self.nextthink = self.ltime + self.wait;
};

void() door_hit_bottom =
{
	sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	self.state = STATE_BOTTOM;
};

void() door_go_down =
{
	sound (self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);

	if (self.max_health)
	{
		self.takedamage = DAMAGE_YES;
		self.health = self.max_health;
	}
	
	self.state = STATE_DOWN;
	SUB_CalcMove (self.pos1, self.speed, door_hit_bottom);
};

void() door_go_up =
{
	if (self.state == STATE_UP)
		return;		// allready going up

	if (self.state == STATE_TOP)
	{	// reset top wait time
		self.nextthink = self.ltime + self.wait;
		return;
	}
	
	sound (self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
	self.state = STATE_UP;
	SUB_CalcMove (self.pos2, self.speed, door_hit_top);

	SUB_UseTargets();
};


/*
=============================================================================

ACTIVATION FUNCTIONS

=============================================================================
*/

void() door_fire =
{
	local entity 	oself;
	local entity	starte;

	if (self.owner != self)
		objerror ("door_fire: self.owner != self");

	// play use key sound
	if (self.items)
		sound (self, CHAN_ITEM, self.noise4, 1, ATTN_NORM); // door unlock sound bugfix

	self.message = string_null;		// no more message
	oself = self;

	if (self.spawnflags & DOOR_TOGGLE)
	{
		if (self.state == STATE_UP || self.state == STATE_TOP)
		{
			starte = self;
			do
			{
				door_go_down ();
				self = self.enemy;
			} while ( (self != starte) && (self != world) );
	
			self = oself;
			return;
		}
	}
	
	// trigger all paired doors
	starte = self;
	do
	{
		door_go_up ();
		self = self.enemy;
	} while ( (self != starte) && (self != world) );

	self = oself;
};


void() door_use =
{
	local entity oself;

	self.message = string_null;			// door message are for touch only
	self.owner.message = string_null;	
	self.enemy.message = string_null;
	oself = self;
	self = self.owner;
	door_fire ();
	self = oself;
};


void() door_trigger_touch =
{
	if (other.health <= 0)
		return;
	
	if (!(other.flags & FL_MONSTER) && !(other.flags & FL_CLIENT))
		return;

	if ((self.spawnflags & DOOR_NOMONSTER) && (other.flags & FL_MONSTER))
		return;
	
	if (time < self.attack_finished)
		return;

	self.attack_finished = time + 1;

	activator = other;

	self = self.owner;
	door_use ();
};


void() door_killed =
{
	local entity oself;
	
	oself = self;
	self = self.owner;
	self.health = self.max_health;
	self.takedamage = DAMAGE_NO;	// wil be reset upon return
	door_use ();
	self = oself;
};


/*
================
door_touch

Prints messages and opens key doors
================
*/
void() door_touch =
{
	if (other.classname != "player")
		return;

	if (self.owner.attack_finished > time)
		return;

	self.owner.attack_finished = time + 2;

	if (self.owner.message != string_null)
	{
		centerprint (other, self.owner.message);
		sound (other, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);
	}
	
	// key door stuff
	if (!self.items)
		return;

	// FIXME: blink key on player's status bar
	if ((self.items & other.items) != self.items)
	{
		if (self.owner.items == IT_KEY1)
		{
			if (world.worldtype == 2)
			{
				centerprint(other, "You need the silver keycard");
				sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
			}
			else if (world.worldtype == 1)
			{
				centerprint(other, "You need the silver runekey");
				sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
			}
			else if (world.worldtype == 0)
			{
				centerprint(other, "You need the silver key");
				sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
			}
		}
		else
		{
			if (world.worldtype == 2)
			{
				centerprint(other, "You need the gold keycard");
				sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
			}
			else if (world.worldtype == 1)
			{
				centerprint(other, "You need the gold runekey");
				sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
			}
			else if (world.worldtype == 0)
			{
				centerprint(other, "You need the gold key");
				sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
			}
		}
		return;
	}

	other.items = other.items - self.items;
	self.touch = SUB_Null;

	if (self.enemy)
		self.enemy.touch = SUB_Null;	// get paired door

	door_use ();
};

/*
=============================================================================

SPAWNING FUNCTIONS

=============================================================================
*/


entity(vector fmins, vector fmaxs) spawn_field =
{
	local entity	trigger;
	local	vector	t1, t2;

	trigger = spawn();
	trigger.movetype = MOVETYPE_NONE;
	trigger.solid = SOLID_TRIGGER;
	trigger.owner = self;
	trigger.touch = door_trigger_touch;

	t1 = fmins;
	t2 = fmaxs;
	setsize (trigger, t1 - '60 60 8', t2 + '60 60 8');
	return (trigger);
};


float (entity e1, entity e2) EntitiesTouching =
{
	if (e1.mins_x > e2.maxs_x)
		return FALSE;

	if (e1.mins_y > e2.maxs_y)
		return FALSE;

	if (e1.mins_z > e2.maxs_z)
		return FALSE;

	if (e1.maxs_x < e2.mins_x)
		return FALSE;

	if (e1.maxs_y < e2.mins_y)
		return FALSE;

	if (e1.maxs_z < e2.mins_z)
		return FALSE;

	return TRUE;
};


/*
=============
LinkDoors


=============
*/
void() LinkDoors =
{
	local entity	t, starte;
	local vector	cmins, cmaxs;

	if (self.enemy)
		return;		// already linked by another door

	if (self.spawnflags & 4)
	{
		self.owner = self.enemy = self;
		return;		// don't want to link this door
	}

	cmins = self.mins;
	cmaxs = self.maxs;
	
	starte = self;
	t = self;
	
	do
	{
		self.owner = starte;			// master door

		if (self.health)
			starte.health = self.health;

		if (self.targetname != string_null)
			starte.targetname = self.targetname;

		if (self.message != string_null)
			starte.message = self.message;

		t = find (t, classname, self.classname);	
		if (!t)
		{
			self.enemy = starte;		// make the chain a loop

			// shootable, fired, or key doors just needed the owner/enemy links,
			// they don't spawn a field
			self = self.owner;

			if (self.health)
				return;
	
			if (self.targetname != string_null)
				return;
	
			if (self.items)
				return;

			self.owner.trigger_field = spawn_field(cmins, cmaxs);

			return;
		}

		if (EntitiesTouching(self,t))
		{
			if (t.enemy)
				objerror ("cross connected doors");
			
			self.enemy = t;
			self = t;

			if (t.mins_x < cmins_x)
				cmins_x = t.mins_x;

			if (t.mins_y < cmins_y)
				cmins_y = t.mins_y;

			if (t.mins_z < cmins_z)
				cmins_z = t.mins_z;

			if (t.maxs_x > cmaxs_x)
				cmaxs_x = t.maxs_x;

			if (t.maxs_y > cmaxs_y)
				cmaxs_y = t.maxs_y;

			if (t.maxs_z > cmaxs_z)
				cmaxs_z = t.maxs_z;
		}
	} while (1 );

};


/*QUAKED func_door (0 .5 .8) ? START_OPEN x DOOR_DONT_LINK GOLD_KEY SILVER_KEY TOGGLE
if two doors touch, they are assumed to be connected and operate as a unit.

TOGGLE causes the door to wait in both the start and end states for a trigger event.

START_OPEN causes the door to move to its destination when spawned, and operate in reverse.  It is used to temporarily or permanently close off an area when triggered (not usefull for touch or takedamage doors).

Key doors are allways wait -1.

"message"	is printed when the door is touched if it is a trigger door and it hasn't been fired yet
"angle"		determines the opening direction
"targetname" if set, no touch field will be spawned and a remote button or trigger field activates the door.
"health"	if set, door must be shot open
"speed"		movement speed (100 default)
"wait"		wait before returning (3 default, -1 = never return)
"lip"		lip remaining at end of move (8 default)
"dmg"		damage to inflict when blocked (2 default)
"sounds"
0)	no sound
1)	stone
2)	base
3)	stone chain
4)	screechy metal
*/

void() func_door =
{
	if (world.worldtype == 0)
	{
		precache_sound ("doors/medtry.wav");
		precache_sound ("doors/meduse.wav");
		self.noise3 = "doors/medtry.wav";
		self.noise4 = "doors/meduse.wav";
	}
	else if (world.worldtype == 1)
	{
		precache_sound ("doors/runetry.wav");
		precache_sound ("doors/runeuse.wav");
		self.noise3 = "doors/runetry.wav";
		self.noise4 = "doors/runeuse.wav";
	}
	else if (world.worldtype == 2)
	{
		precache_sound ("doors/basetry.wav");
		precache_sound ("doors/baseuse.wav");
		self.noise3 = "doors/basetry.wav";
		self.noise4 = "doors/baseuse.wav";
	}
	else
	{
		dprint ("no worldtype set!\n");
	}

	if (self.sounds == 0)
	{
		precache_sound ("misc/null.wav");
		precache_sound ("misc/null.wav");
		self.noise1 = "misc/null.wav";
		self.noise2 = "misc/null.wav";
	}

	if (self.sounds == 1)
	{
		precache_sound ("doors/drclos4.wav");
		precache_sound ("doors/doormv1.wav");
		self.noise1 = "doors/drclos4.wav";
		self.noise2 = "doors/doormv1.wav";
	}

	if (self.sounds == 2)
	{
		precache_sound ("doors/hydro1.wav");
		precache_sound ("doors/hydro2.wav");
		self.noise2 = "doors/hydro1.wav";
		self.noise1 = "doors/hydro2.wav";
	}

	if (self.sounds == 3)
	{
		precache_sound ("doors/stndr1.wav");
		precache_sound ("doors/stndr2.wav");
		self.noise2 = "doors/stndr1.wav";
		self.noise1 = "doors/stndr2.wav";
	}

	if (self.sounds == 4)
	{
		precache_sound ("doors/ddoor1.wav");
		precache_sound ("doors/ddoor2.wav");
		self.noise1 = "doors/ddoor2.wav";
		self.noise2 = "doors/ddoor1.wav";
	}

	SetMovedir ();

	self.max_health = self.health;
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	setorigin (self, self.origin);	
	setmodel (self, self.model);
	self.classname = "func_door";

	self.blocked = door_blocked;
	self.use = door_use;
	
	if (self.spawnflags & DOOR_SILVER_KEY)
		self.items = IT_KEY1;

	if (self.spawnflags & DOOR_GOLD_KEY)
		self.items = IT_KEY2;

	if ((self.spawnflags & DOOR_CRUSHER) && self.items)
		objerror ("why would you give a crusher keys?");

	if ((self.spawnflags & DOOR_CRUSHER) && (self.wait < 0))
		objerror ("y'know crusher doors ignore -1 wait");
	
	if (!self.speed)
		self.speed = 100;

	if (!self.wait)
		self.wait = 3;

	if (!self.lip)
		self.lip = 8;

	if (!self.dmg)
		self.dmg = 2;

	self.pos1 = self.origin;
	vector movedir_fabs = { fabs(self.movedir[0]), fabs(self.movedir[1]), fabs(self.movedir[2]) };
	self.pos2 = self.pos1 + ((movedir_fabs * self.size) - self.lip) * self.movedir;

	// DOOR_START_OPEN is to allow an entity to be lighted in the closed position
	// but spawn in the open position
	if (self.spawnflags & DOOR_START_OPEN)
	{
		setorigin (self, self.pos2);
		self.pos2 = self.pos1;
		self.pos1 = self.origin;
	}

	self.state = STATE_BOTTOM;

	if (self.health)
	{
		self.takedamage = DAMAGE_YES;
		self.th_die = door_killed;
	}
	
	if (self.items)
		self.wait = -1;
		
	self.touch = door_touch;

	// LinkDoors can't be done until all of the doors have been spawned, so
	// the sizes can be detected properly.
	self.think = LinkDoors;
	self.nextthink = self.ltime + 0.1;
};

/*
=============================================================================

SECRET DOORS

=============================================================================
*/

void() fd_secret_move1;
void() fd_secret_move2;
void() fd_secret_move3;
void() fd_secret_move4;
void() fd_secret_move5;
void() fd_secret_move6;
void() fd_secret_done;

float SECRET_OPEN_ONCE = 1;		// stays open
float SECRET_1ST_LEFT = 2;		// 1st move is left of arrow
float SECRET_1ST_DOWN = 4;		// 1st move is down from arrow
float SECRET_NO_SHOOT = 8;		// only opened by trigger
float SECRET_YES_SHOOT = 16;	// shootable even if targeted


void (entity attacker, float damage, float MOD) fd_secret_use =
{
	local float temp;
	
	self.health = 10000;

	// exit if still moving around...
	if (self.origin != self.oldorigin)
		return;
	
	self.message = string_null;		// no more message

	SUB_UseTargets();				// fire all targets / killtargets
	
	if (!(self.spawnflags & SECRET_NO_SHOOT))
	{
		self.th_pain = __NULL__;
		self.takedamage = DAMAGE_NO;
	}
	self.velocity = '0 0 0';

	// Make a sound, wait a little...
	
	sound(self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	self.nextthink = self.ltime + 0.1;

	temp = 1 - (self.spawnflags & SECRET_1ST_LEFT);	// 1 or -1
	makevectors(self.mangle);
	
	if (!self.t_width)
	{
		if (self.spawnflags & SECRET_1ST_DOWN)
			self. t_width = fabs(v_up * self.size);
		else
			self. t_width = fabs(v_right * self.size);
	}
		
	if (!self.t_length)
		self. t_length = fabs(v_forward * self.size);

	if (self.spawnflags & SECRET_1ST_DOWN)
		self.dest1 = self.origin - v_up * self.t_width;
	else
		self.dest1 = self.origin + v_right * (self.t_width * temp);
		
	self.dest2 = self.dest1 + v_forward * self.t_length;
	SUB_CalcMove(self.dest1, self.speed, fd_secret_move1);
	sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
};

void () fd_secret_use2=
{
	local float temp;
	
	self.health = 10000;

	// exit if still moving around...
	if (self.origin != self.oldorigin)
		return;
	
	self.message = string_null;		// no more message

	SUB_UseTargets();				// fire all targets / killtargets
	
	if (!(self.spawnflags & SECRET_NO_SHOOT))
	{
		self.th_pain = __NULL__;
		self.takedamage = DAMAGE_NO;
	}
	self.velocity = '0 0 0';

	// Make a sound, wait a little...
	
	sound(self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	self.nextthink = self.ltime + 0.1;

	temp = 1 - (self.spawnflags & SECRET_1ST_LEFT);	// 1 or -1
	makevectors(self.mangle);
	
	if (!self.t_width)
	{
		if (self.spawnflags & SECRET_1ST_DOWN)
			self. t_width = fabs(v_up * self.size);
		else
			self. t_width = fabs(v_right * self.size);
	}
		
	if (!self.t_length)
		self. t_length = fabs(v_forward * self.size);

	if (self.spawnflags & SECRET_1ST_DOWN)
		self.dest1 = self.origin - v_up * self.t_width;
	else
		self.dest1 = self.origin + v_right * (self.t_width * temp);
		
	self.dest2 = self.dest1 + v_forward * self.t_length;
	SUB_CalcMove(self.dest1, self.speed, fd_secret_move1);
	sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
};

// Wait after first movement...
void () fd_secret_move1 = 
{
	self.nextthink = self.ltime + 1.0;
	self.think = fd_secret_move2;
	sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
};

// Start moving sideways w/sound...
void () fd_secret_move2 =
{
	sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
	SUB_CalcMove(self.dest2, self.speed, fd_secret_move3);
};

// Wait here until time to go back...
void () fd_secret_move3 =
{
	sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
	if (!(self.spawnflags & SECRET_OPEN_ONCE))
	{
		self.nextthink = self.ltime + self.wait;
		self.think = fd_secret_move4;
	}
};

// Move backward...
void () fd_secret_move4 =
{
	sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
	SUB_CalcMove(self.dest1, self.speed, fd_secret_move5);		
};

// Wait 1 second...
void () fd_secret_move5 = 
{
	self.nextthink = self.ltime + 1.0;
	self.think = fd_secret_move6;
	sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
};

void () fd_secret_move6 =
{
	sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
	SUB_CalcMove(self.oldorigin, self.speed, fd_secret_done);
};

void () fd_secret_done =
{
	if (!self.targetname || self.spawnflags&SECRET_YES_SHOOT)
	{
		self.health = 10000;
		self.takedamage = DAMAGE_YES;
		self.th_pain = fd_secret_use;	
	}
	sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
};

void () secret_blocked =
{
	if (time < self.attack_finished)
		return;
	self.attack_finished = time + 0.5;
	T_Damage (other, self,self.origin, self, self.dmg, 0);
};

/*
================
secret_touch

Prints messages
================
*/
void() secret_touch =
{
	if (other.classname != "player")
		return;
	if (self.attack_finished > time)
		return;

	self.attack_finished = time + 2;
	
	if (self.message)
	{
		centerprint (other, self.message);
		sound (other, CHAN_BODY, "misc/talk.wav", 1, ATTN_NORM);
	}
};


/*QUAKED func_door_secret (0 .5 .8) ? open_once 1st_left 1st_down no_shoot always_shoot
Basic secret door. Slides back, then to the side. Angle determines direction.
wait  = # of seconds before coming back
1st_left = 1st move is left of arrow
1st_down = 1st move is down from arrow
always_shoot = even if targeted, keep shootable
t_width = override WIDTH to move back (or height if going down)
t_length = override LENGTH to move sideways
"dmg"		damage to inflict when blocked (2 default)

If a secret door has a targetname, it will only be opened by it's botton or trigger, not by damage.
"sounds"
1) medieval
2) metal
3) base
*/

void () func_door_secret =
{
	if (self.sounds == 0)
		self.sounds = 3;
	if (self.sounds == 1)
	{
		precache_sound ("doors/latch2.wav");
		precache_sound ("doors/winch2.wav");
		precache_sound ("doors/drclos4.wav");
		self.noise1 = "doors/latch2.wav";
		self.noise2 = "doors/winch2.wav";
		self.noise3 = "doors/drclos4.wav";
	}
	if (self.sounds == 2)
	{
		precache_sound ("doors/airdoor1.wav");
		precache_sound ("doors/airdoor2.wav");
		self.noise2 = "doors/airdoor1.wav";
		self.noise1 = "doors/airdoor2.wav";
		self.noise3 = "doors/airdoor2.wav";
	}
	if (self.sounds == 3)
	{
		precache_sound ("doors/basesec1.wav");
		precache_sound ("doors/basesec2.wav");
		self.noise2 = "doors/basesec1.wav";
		self.noise1 = "doors/basesec2.wav";
		self.noise3 = "doors/basesec2.wav";
	}

	if (!self.dmg)
		self.dmg = 2;
		
	// Magic formula...
	self.mangle = self.angles;
	self.angles = '0 0 0';
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	self.classname = "door";
	setmodel (self, self.model);
	setorigin (self, self.origin);	
	
	self.touch = secret_touch;
	self.blocked = secret_blocked;
	self.speed = 50;
	self.use = fd_secret_use2;
	if ( !self.targetname || self.spawnflags&SECRET_YES_SHOOT)
	{
		self.health = 10000;
		self.takedamage = DAMAGE_YES;
		self.th_pain = fd_secret_use;
		self.th_die = fd_secret_use2;
	}
	self.oldorigin = self.origin;
	if (!self.wait)
		self.wait = 5;		// 5 seconds before closing
};


/*
==============================================================================

BUTTONS

==============================================================================
*/

// button and multiple button

void() button_wait;
void() button_return;

void() button_wait =
{
	self.state = STATE_TOP;
	self.nextthink = self.ltime + self.wait;
	self.think = button_return;
	activator = self.enemy;
	SUB_UseTargets();
	self.frame = 1;			// use alternate textures
};

void() button_done =
{
	self.state = STATE_BOTTOM;
};

void() button_return =
{
	self.state = STATE_DOWN;
	SUB_CalcMove (self.pos1, self.speed, button_done);
	self.frame = 0;			// use normal textures
	if (self.health)
		self.takedamage = DAMAGE_YES;	// can be shot again
};


void() button_blocked =
{	// do nothing, just don't ome all the way back out
};


void() button_fire =
{
	if (self.state == STATE_UP || self.state == STATE_TOP)
		return;

	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);

	self.state = STATE_UP;
	SUB_CalcMove (self.pos2, self.speed, button_wait);
};


void() button_use =
{
	self.enemy = activator;
	button_fire ();
};

void() button_touch =
{
	if (other.classname != "player")
		return;
	self.enemy = other;
	button_fire ();
};

void() button_killed =
{
	self.enemy = damage_attacker;
	self.health = self.max_health;
	self.takedamage = DAMAGE_NO;	// wil be reset upon return
	button_fire ();
};


/*QUAKED func_button (0 .5 .8) ?
When a button is touched, it moves some distance in the direction of it's angle, triggers all of it's targets, waits some time, then returns to it's original position where it can be triggered again.

"angle"		determines the opening direction
"target"	all entities with a matching targetname will be used
"speed"		override the default 40 speed
"wait"		override the default 1 second wait (-1 = never return)
"lip"		override the default 4 pixel lip remaining at end of move
"health"	if set, the button must be killed instead of touched
"sounds"
0) steam metal
1) wooden clunk
2) metallic click
3) in-out
*/
void() func_button =
{
//local float		gtemp, ftemp;

	if (self.sounds == 0)
	{
		precache_sound ("buttons/airbut1.wav");
		self.noise = "buttons/airbut1.wav";
	}
	if (self.sounds == 1)
	{
		precache_sound ("buttons/switch21.wav");
		self.noise = "buttons/switch21.wav";
	}
	if (self.sounds == 2)
	{
		precache_sound ("buttons/switch02.wav");
		self.noise = "buttons/switch02.wav";
	}
	if (self.sounds == 3)
	{
		precache_sound ("buttons/switch04.wav");
		self.noise = "buttons/switch04.wav";
	}
	
	SetMovedir ();

	self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	setmodel (self, self.model);

	self.blocked = button_blocked;
	self.use = button_use;

	if (self.health)
	{
		self.max_health = self.health;
		self.th_die = button_killed;
		self.takedamage = DAMAGE_YES;
	}
	else
		self.touch = button_touch;

	if (!self.speed)
		self.speed = 40;
	if (!self.wait)
		self.wait = 1;
	if (!self.lip)
		self.lip = 4;

	self.state = STATE_BOTTOM;

	self.pos1 = self.origin;
	self.pos2 = self.pos1 + self.movedir*(fabs(self.movedir*self.size) - self.lip);
};

/*
==============================================================================

ROTATING BMODELS

==============================================================================
*/

/* Rotate QuickC program
   By Jim Dose'  10/17/96
*/

float STATE_ACTIVE      = 0;
float STATE_INACTIVE    = 1;
float STATE_SPEEDINGUP  = 2;
float STATE_SLOWINGDOWN = 3;

float STATE_CLOSED   = 4;
float STATE_OPEN     = 5;
float STATE_OPENING  = 6;
float STATE_CLOSING  = 7;

float STATE_WAIT = 0;
float STATE_MOVE = 1;
float STATE_STOP = 2;
float STATE_FIND = 3;
float STATE_NEXT = 4;

float OBJECT_ROTATE = 0;
float OBJECT_MOVEWALL  = 1;
float OBJECT_SETORIGIN = 2;

float TOGGLE   = 1;
float START_ON = 2;

float ROTATION = 1;
float ANGLES   = 2;
float STOP     = 4;
float NO_ROTATE = 8;
float DAMAGE   = 16;
float MOVETIME = 32;
float SET_DAMAGE = 64;

float VISIBLE = 1;
float TOUCH = 2;
float NONBLOCKING = 4;

float STAYOPEN = 1;

.vector neworigin;
.vector rotate;
.float  endtime;
.float  rotate_type;
.string path;
.string group;
.string event;

void() info_rotate =
{	
// remove self after a little while, to make sure that entities that
// have targeted it have had a chance to spawn
	self.nextthink = time + 2;
	self.think = SUB_Remove;
}

void() RotateTargets =
{
	local entity ent;
	local vector vx;
	local vector vy;
	local vector vz;
	local vector org;

	makevectors (self.angles);

	ent = find(world, targetname, self.target);
	while (ent)
	{
		if ( ent.rotate_type == OBJECT_SETORIGIN )
		{
			org = ent.oldorigin;
			vx = ( v_forward * org_x );
			vy = ( v_right   * org_y );
			vy = vy * -1;
			vz = ( v_up      * org_z );
			ent.neworigin = vx + vy + vz;
			setorigin( ent, ent.neworigin + self.origin );
		}
		else if ( ent.rotate_type == OBJECT_ROTATE )
		{
			ent.angles = self.angles;
			org = ent.oldorigin;
			vx = ( v_forward * org_x );
			vy = ( v_right   * org_y );
			vy = vy * -1;
			vz = ( v_up      * org_z );
			ent.neworigin = vx + vy + vz;
			setorigin( ent, ent.neworigin + self.origin );
		}
		else
		{
			org = ent.oldorigin;
			vx = ( v_forward * org_x );
			vy = ( v_right   * org_y );
			vy = vy * -1;
			vz = ( v_up      * org_z );
			ent.neworigin = vx + vy + vz;
			ent.neworigin = self.origin - self.oldorigin + (ent.neworigin - ent.oldorigin);
			ent.velocity = (ent.neworigin-ent.origin)*25;
		}
		ent = find( ent, targetname, self.target);
	}
}

void() RotateTargetsFinal =
{
	entity ent = find(world, targetname, self.target);
	while (ent)
	{
		ent.velocity = '0 0 0';
		if ( ent.rotate_type == OBJECT_ROTATE )
			ent.angles = self.angles;

		ent = find( ent, targetname, self.target);
	}
}

void() SetTargetOrigin =
{
	entity ent = find(world, targetname, self.target);
	while (ent)
	{
		if (ent.rotate_type == OBJECT_MOVEWALL)
			setorigin( ent, self.origin - self.oldorigin + (ent.neworigin - ent.oldorigin) );
		else
			setorigin( ent, ent.neworigin + self.origin );

		ent = find( ent, targetname, self.target);
	}
}

void() LinkRotateTargets =
{
	vector tempvec;

	self.oldorigin = self.origin;

	entity ent = find( world, targetname, self.target);
	while (ent)
	{
		if (ent.classname == "rotate_object")
		{
			ent.rotate_type = OBJECT_ROTATE;
			ent.oldorigin = ent.origin - self.oldorigin;
			ent.neworigin = ent.origin - self.oldorigin;
			ent.owner = self;
		}
		else if (ent.classname == "func_movewall")
		{
			ent.rotate_type = OBJECT_MOVEWALL;
			tempvec = (ent.absmin + ent.absmax) * 0.5;
			ent.oldorigin = tempvec - self.oldorigin;
			ent.neworigin = ent.oldorigin;
			ent.owner = self;
		}
		else
		{
			ent.rotate_type = OBJECT_SETORIGIN;
			ent.oldorigin = ent.origin - self.oldorigin;
			ent.neworigin = ent.origin - self.oldorigin;
		}
		ent = find(ent, targetname, self.target);
	}
}

void(float amount) SetDamageOnTargets =
{
	entity ent = find(world, targetname, self.target);
	while (ent)
	{
		if (ent.classname == "trigger_hurt")
			hurt_setdamage(ent, amount);
		else if (ent.classname == "func_movewall")
			ent.dmg = amount;

		ent = find(ent, targetname, self.target);
	}
}


//************************************************
//
// Moving clip walls
//
//************************************************


void() movewall_touch =
{
	if (time < self.owner.attack_finished)
		return;

	if (self.dmg)
	{
		T_Damage(other, self, self.origin, self.owner, self.dmg, 0);
		self.owner.attack_finished = time + 0.5;
	}
	else if (self.owner.dmg)
	{
		T_Damage(other, self, self.origin, self.owner, self.owner.dmg, 0);
		self.owner.attack_finished = time + 0.5;
	}
}

void() movewall_blocked =
{
	local entity temp;

	if (time < self.owner.attack_finished)
		return;

	self.owner.attack_finished = time + 0.5;

	if (self.owner.classname == "func_rotate_door")
	{
		temp = self;
		self = self.owner;
		rotate_door_group_reversedirection();
		self = temp;
	}

	if (self.dmg)
	{
		T_Damage(other, self, self.origin, self.owner, self.dmg, 0);
		self.owner.attack_finished = time + 0.5;
	}
	else if (self.owner.dmg)
	{
		T_Damage(other, self, self.origin, self.owner, self.owner.dmg, 0);
		self.owner.attack_finished = time + 0.5;
	}
}

void() movewall_think =
{
	self.ltime = time;
	self.nextthink = time + 0.01;
}

/*QUAKED func_movewall (0 .5 .8) ? ROTATE_VISIBLE ROTATE_TOUCH ROTATE_NONBLOCKING
Used to emulate collision on rotating objects.

VISIBLE causes brush to be displayed.

TOUCH specifies whether to cause damage when touched by player.

NONBLOCKING makes the brush non-solid.  This is useless if ROTATE_VISIBLE is set.

"dmg" specifies the damage to cause when touched or blocked.
*/
void() func_movewall =
{	
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;

	if (self.spawnflags & NONBLOCKING)
		self.solid = SOLID_NOT;
	else
	{
		self.solid = SOLID_BSP;
		self.blocked = movewall_blocked;
	}

	if (self.spawnflags & TOUCH)
		self.touch = movewall_touch;

	setmodel(self,self.model);

	if (!(self.spawnflags & VISIBLE))
		self.model = string_null;

	self.think = movewall_think;
	self.nextthink = time + 0.01;
	self.ltime = time;
}

/*QUAKED rotate_object (0 .5 .8) ?
This defines an object to be rotated.  Used as the target of func_rotate_door.
*/
void() rotate_object =
{	
	self.classname = "rotate_object";
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_NONE;
	setmodel (self,self.model);
	setsize(self, self.mins, self.maxs);
	self.think = SUB_Null;
};

//************************************************
//
// Rotating doors
//
//************************************************

void() rotate_door_think2 =
{
	float t = time - self.ltime;
	self.ltime = time;

	// change to alternate textures
	self.frame = 1 - self.frame;

	self.angles = self.dest;

	if (self.state == STATE_OPENING)
		self.state = STATE_OPEN;
	else
	{
		if (self.spawnflags & STAYOPEN)
		{
			rotate_door_group_reversedirection();
			return;
		}

		self.state = STATE_CLOSED;
	}

	if (self.sounds) sound(self, CHAN_VOICE, self.noise3, 1, ATTN_NORM);
	self.think = SUB_Null;

	RotateTargetsFinal();
}

void() rotate_door_think =
{
	float t = time - self.ltime;
	self.ltime = time;

	if (time < self.endtime)
	{
		self.angles = self.angles + ( self.rotate * t );
		RotateTargets();
	}
	else
	{
		self.angles = self.dest;
		RotateTargets();
		self.think = rotate_door_think2;
	}

	self.nextthink = time + 0.01;
}

void() rotate_door_reversedirection =
{
	vector start;

	// change to alternate textures
	self.frame = 1 - self.frame;

	if (self.state == STATE_CLOSING )
	{
		start = self.dest1;
		self.dest = self.dest2;
		self.state = STATE_OPENING;
	}
	else
	{
		start = self.dest2;
		self.dest = self.dest1;
		self.state = STATE_CLOSING;
	}

	if (self.sounds) sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);

	self.rotate = ( self.dest - start ) * ( 1 / self.speed );
	self.think = rotate_door_think;
	self.nextthink = time + 0.02;
	self.endtime = time + self.speed - ( self.endtime - time );
	self.ltime = time;
}

void() rotate_door_group_reversedirection =
{
	local string name;

	// tell all associated rotaters to reverse direction
	if (self.group)
	{
		name = self.group;
		self = find(world, group, name);
		while (self)
		{
			rotate_door_reversedirection();
			self = find(self, group, name);
		}
	}
	else
	{
		rotate_door_reversedirection();
	}
};

void() rotate_door_use =
{
//   local entity t;
	local vector start;

	if (self.state != STATE_OPEN && self.state != STATE_CLOSED)
		return;

	if (!self.cnt)
	{
		self.cnt = 1;
		LinkRotateTargets();
	}

	// change to alternate textures
	self.frame = 1 - self.frame;

	if (self.state == STATE_CLOSED)
	{
		start = self.dest1;
		self.dest = self.dest2;
		self.state = STATE_OPENING;
	}
	else
	{
		start = self.dest2;
		self.dest = self.dest1;
		self.state = STATE_CLOSING;
	}

	if (self.sounds)
		sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);

	self.rotate = ( self.dest - start ) * ( 1 / self.speed );
	self.think = rotate_door_think;
	self.nextthink = time + 0.01;
	self.endtime = time + self.speed;
	self.ltime = time;
}


/*QUAKED func_rotate_door (0 .5 .8) (-8 -8 -8) (8 8 8) ROTATE_STAYOPEN
Creates a door that rotates between two positions around a point of
rotation each time it's triggered.

ROTATE_STAYOPEN tells the door to reopen after closing.  This prevents a trigger-
once door from closing again when it's blocked.

"dmg" specifies the damage to cause when blocked.  Defaults to 2.  Negative numbers indicate no damage.
"speed" specifies how the time it takes to rotate

"sounds"
1) medieval (default)
2) metal
3) base
4)	screechy metal
*/

void() func_door_rotating =
{	
	if (!self.target)
		objerror( "rotate_door without target." );

	self.dest1 = '0 0 0';
	self.dest2 = self.angles;
	self.angles = self.dest1;

	// default to 2 seconds
	if (!self.speed) self.speed = 2;

	self.cnt = 0;

	if (!self.dmg)
		self.dmg = 2;
	else if (self.dmg < 0 )
		self.dmg = 0;

	if (self.sounds == 1)
	{
		precache_sound ("doors/latch2.wav");
		precache_sound ("doors/winch2.wav");
		precache_sound ("doors/drclos4.wav");
		self.noise1 = "doors/latch2.wav";
		self.noise2 = "doors/winch2.wav";
		self.noise3 = "doors/drclos4.wav";
	}
	if (self.sounds == 2)
	{
		precache_sound ("doors/airdoor1.wav");
		precache_sound ("doors/airdoor2.wav");
		self.noise2 = "doors/airdoor1.wav";
		self.noise1 = "doors/airdoor2.wav";
		self.noise3 = "doors/airdoor2.wav";
	}
	if (self.sounds == 3)
	{
		precache_sound ("doors/basesec1.wav");
		precache_sound ("doors/basesec2.wav");
		self.noise2 = "doors/basesec1.wav";
		self.noise1 = "doors/basesec2.wav";
		self.noise3 = "doors/basesec2.wav";
	}

	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_NONE;
	setmodel (self, self.model);
	setorigin(self, self.origin );
	setsize(self, self.mins, self.maxs);
	self.state = STATE_CLOSED;
	self.use = rotate_door_use;
	self.think = SUB_Null;
};

/*
==============================================================================

SIMPLE BMODELS

==============================================================================
*/

void() func_wall_use =
{	// change to alternate textures
	self.frame = 1 - self.frame;
};

/*QUAKED func_wall (0 .5 .8) ?
This is just a solid wall if not inhibitted
*/
void() func_wall =
{
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
	setmodel (self, self.model);
};


/*QUAKED func_illusionary (0 .5 .8) ?
A simple entity that looks solid but lets you walk through it.
*/
void() func_illusionary =

{
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	setmodel (self, self.model);
	makestatic (self);
};

/*QUAKED func_episodegate (0 .5 .8) ? E1 E2 E3 E4
This bmodel will appear if the episode has allready been completed, so players can't reenter it.
*/
void() func_episodegate =

{
	if (!(serverflags & self.spawnflags))
		return;			// can still enter episode

	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
	setmodel (self, self.model);
};

/*QUAKED func_bossgate (0 .5 .8) ?
This bmodel appears unless players have all of the episode sigils.
*/
float	ALL_RUNES = 1;

void() func_bossgate =
{	
	if (self.spawnflags == ALL_RUNES) { // ritual support
		if ( (serverflags & 15) < 15)
			return;	// Not got all runes yet
	}
	else if ( (serverflags & 15) == 15)
		return;		// all episodes completed
	
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
	setmodel (self, self.model);
};

/*QUAKED func_explosive (0 .5 .8) ? Trigger_Spawn 
Any brush that you want to explode or break apart.  If you want an
ex0plosion, set dmg and it will do a radius explosion of that amount
at the center of the bursh.

If targeted it will not be shootable.

health defaults to 100.

mass defaults to 75.  This determines how much debris is emitted when
it explodes.  You get one large chunk per 100 of mass (up to 8) and
one small chunk per 25 of mass (up to 16).  So 800 gives the most.
*/

void() breakable_explode = 
{
	explosive_die();
};

void() explosive_die =
{
	self.takedamage = DAMAGE_NO;
	self.classname = "explo_box";

	local vector size, chunkorigin, org;
	local float count;
	local entity en;

	if(!self.use)
		en = self.enemy;
	else 
		en = self;
		
	size = (self.maxs - self.mins) * 0.5;
	org = size + self.absmin;
	self.origin = org;
	
	SUB_UseTargets();
	if(self.dmg)
	{	
		BecomeExplosion();
		T_RadiusDamage (self, self, self.dmg, self.dmg + 40, world);
	}

	if(!self.mass && !self.dmg)
	{
		remove(self);
		return;
	}

	self.velocity = normalize(en.origin - self.origin)*150;
		
	if(self.mass >= 100)
	{
		count = self.mass / 100;
		if(count > 8)
		{
			count = 8;
			while(count--)
			{
				chunkorigin = self.origin + crandom() * size;
				ThrowDebri ("progs/debris1.mdl", 1, chunkorigin);
			}
		}
	}

	count = self.mass / 25;
	if (count > 16)
		count = 16;
	while(count--)
	{
		chunkorigin = self.origin + crandom() * size;
		ThrowDebri ("progs/debris2.mdl", 1, chunkorigin);
	}
	
	if(!self.dmg)
		remove(self);
};

void(entity attacker, float dmg, float MOD) explosive_pain =
{
	self.enemy = attacker;
};

void() explosive_spawn =
{
	self.model = self.oldmodel;
	self.solid = SOLID_BSP;
	setorigin(self, self.origin);
	self.use = __NULL__;
	SUB_KillBox (self);
};

.string oldmodel;

void() func_explosive =
{
	self.classname = "func_explosive";
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
	self.takedamage = DAMAGE_NO;
	self.th_pain = explosive_pain;
		
	setmodel (self, self.model);
	
	if((self.spawnflags & 1))
	{
		self.oldmodel = self.model;
  		self.model = "";
		self.solid = SOLID_NOT;
		self.use = explosive_spawn;
	}
	else
	{
		self.solid = SOLID_BSP;
		if (self.targetname)
			self.use = explosive_die;
	}
		
	if(self.use != explosive_die)
	{
		if(!self.health)
			self.health = 100;
		if(!self.mass)
			self.mass = 75;
		self.takedamage = DAMAGE_YES;
		self.th_die = explosive_die;
	}

	setorigin (self, self.origin);
};

void() func_breakable =
{
	self.classname = "func_explosive";
	func_explosive ();
};

/*QUAKED func_object (0 .5 .8) ? TRIGGER_SPAWN 
This is solid bmodel that will fall if it's support it removed.
*/

void() func_object_touch = // help?
{	
	local vector end, plane;
	local float time_left = time;

	end = self.origin + time_left*self.velocity;
	tracebox(self.origin, self.mins, self.maxs, end, FALSE, self); // guessing how q2 returns *cplane_t plane
	plane = trace_plane_normal;
	
	if (!plane)
		return;
	if (plane_z < 1.0)
		return;
	
	if (!other.takedamage && other.solid == SOLID_BSP) // touched ground
	{	
		self.movetype = MOVETYPE_PUSH;
		self.flags |= FL_ONGROUND;
		setmodel(self,self.model);
		setorigin(self, self.origin);
		self.velocity = '0 0 0';
		self.nextthink = -1;
		return;
	}

	if (other.takedamage == DAMAGE_NO)
		return;

	T_Damage (other, self, self.origin, self, other.health + 99999, 0); // no survivors even bosses
	other.origin_z += 24; // avoid falling out
};

void() func_object_think =
{	
	dprint("i am falling");

	self.flags &= ~FL_ONGROUND;

	self.think = func_object_think;
	self.nextthink = time + frametime;
};

void() func_object_release
{
	self.movetype = MOVETYPE_TOSS;
	self.touch = func_object_touch;
	self.think = func_object_think;
	self.nextthink = time + 0.8 * frametime;
};

void() func_object_use
{
	self.solid = SOLID_BSP;
	self.model = self.oldmodel;
	setorigin(self, self.origin);

	self.use = __NULL__;
	SUB_KillBox (self);
	func_object_release ();
};

void() func_object =
{
	setmodel(self,self.model);
	
	self.maxs += '1 1 1';
	self.mins += '-1 -1 -1';
	
	if (self->spawnflags == 0)
	{
		self.solid = SOLID_BSP;
		self.movetype = MOVETYPE_PUSH;
		self.think = func_object_release;
		self.nextthink = time + 2 * frametime;
	}
	else
	{
		self.solid = SOLID_NOT;
		self.movetype = MOVETYPE_PUSH;
		self.use = func_object_use;
		self.oldmodel = self.model;
		self.model = "";
	}

	setorigin(self, self.origin);
};

void() use_killbox =
{
	SUB_KillBox (self);
};

void() func_killbox = 
{
	setmodel (self, self.model);
	self.use = use_killbox;
	self.model = "";
};

//=============================================================================

/*QUAKED func_timer (0.3 0.1 0.6) (-8 -8 -8) (8 8 8) START_ON
"wait"			base time between triggering all targets, default is 1
"random"(count)		wait variance, default is 0

so, the basic time between firing is a random time between
(wait - random) and (wait + random)

"delay"			delay before first firing when turned on, default is 0

"pausetime"		additional delay used only the very first time
				and only if spawned with START_ON

These can used but not touched.
*/
void() func_timer_think 
{
	SUB_UseTargets();
	self.nextthink = time + self.wait + crandom() * self.count;
};

void() func_timer_use 
{
	self.enemy = activator;

	// if on, turn it off
	if (self.nextthink)
	{
		self.nextthink = 0;
		return;
	}

	// turn it on
	if (self.delay)
		self.nextthink = time + self.delay;
	else
		func_timer_think ();
};

void() func_timer 
{
	if (!self.wait)
		self.wait = 1.0;

	self.use = func_timer_use;
	self.think = func_timer_think;

	if (self.count >= self.wait)
	{
		self.count = self.wait - 0.1;
		dprint("func_timer at", vtos(self.origin), "has random >= wait\n");
	}

	if (self.spawnflags & 1) // started active
	{
		self.nextthink = time + 1.0 + self.pausetime + self.delay + self.wait + crandom() * self.count;
		self.enemy = self;
	}
	
	setmodel(self, self.model);
	self.model = "";
};

/*QUAKED func_rotating (0 .5 .8) ? START_ON REVERSE X_AXIS Y_AXIS TOUCH_PAIN STOP ANIMATED ANIMATED_FAST
You need to have an origin brush as part of this entity.  The center of that brush will be
the point around which it is rotated. It will rotate around the Z axis by default.  You can
check either the X_AXIS or Y_AXIS box to change that.

"speed" determines how fast it moves; default value is 100.
"dmg"	damage to inflict when blocked (2 default)

REVERSE will cause the it to rotate in the opposite direction.
STOP mean it will stop moving instead of pushing entities
*/

void() rotating_blocked =
{
	T_Damage (other, self, other.origin, self, self.dmg, 1, 0);
};

void() rotating_touch =
{
	if (self.avelocity[0] || self.avelocity[1] || self.avelocity[2])
		T_Damage (other, self, other.origin, self, self.dmg, 1, 0);
};

void() rotating_use =
{
	if (self.avelocity != '0 0 0')
	{
		//self->s.sound = 0;
		self.avelocity = '0 0 0';
		self.touch = SUB_Null;
	}
	else
	{
		//self->s.sound = self->moveinfo.sound_middle;
		//VectorScale (self->movedir, self->speed, self->avelocity);
		self.avelocity = self.movedir * self.speed;
		self.think = rotating_think;
		self.nextthink = time + 0.1;
		if (self.spawnflags & 16)
			self.touch = rotating_touch;
	}
};

void() rotating_think = 
{
	self.think = rotating_think;
	self.nextthink = time + 0.1;

	self.avelocity = self.avelocity;
}

void() func_rotating =
{
	self.solid = SOLID_BSP;
	//if (ent->spawnflags & 32)
	//	ent->movetype = MOVETYPE_STOP;
	//else
	self.movetype = MOVETYPE_PUSH;

	// set the axis of rotation
	//VectorClear(ent->movedir);
	self.movedir = '0 0 0';
	if (self.spawnflags & 4)
		self.movedir[2] = 1.0;
	else if (self.spawnflags & 8)
		self.movedir[0] = 1.0;
	else // Z_AXIS
		self.movedir[1] = 1.0;

	// check for reverse rotation
	if (self.spawnflags & 2)
	{
		self.movedir[0] = -self.movedir[0];
		self.movedir[1] = -self.movedir[1];
		self.movedir[2] = -self.movedir[2];
	}	

	if (!self.speed)
		self.speed = 100;
	if (!self.dmg)
		self.dmg = 2;

//	ent->moveinfo.sound_middle = "doors/hydro1.wav";

	self.use = rotating_use;
	if (self.dmg)
		self.blocked = rotating_blocked;

	if (self.spawnflags & 1)
		self.use();

	setmodel (self, self.model);
	setorigin(self, self.origin);
}
