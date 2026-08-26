
/*QUAKED info_null (0 0.5 0) (-4 -4 -4) (4 4 4)
Used as a positional target for spotlights, etc.
*/
void() info_null =
{
	remove(self);
};

/*QUAKED info_notnull (0 0.5 0) (-4 -4 -4) (4 4 4)
Used as a positional target for lightning.
*/
void() info_notnull =
{
};

//============================================================================

float START_OFF = 1;

void() light_use =
{
	if (self.spawnflags & START_OFF)
	{
		lightstyle(self.style, "m");
		self.spawnflags = self.spawnflags - START_OFF;
	}
	else
	{
		lightstyle(self.style, "a");
		self.spawnflags = self.spawnflags + START_OFF;
	}
};

/*QUAKED light (0 1 0) (-8 -8 -8) (8 8 8) START_OFF
Non-displayed light.
Default light value is 300
Default style is 0
If targeted, it will toggle between on or off.
*/
void() light =
{
	if (!self.targetname)
	{	// inert light
		remove(self);
		return;
	}
	
	if (self.style >= 32)
	{
		self.use = light_use;
		if (self.spawnflags & START_OFF)
			lightstyle(self.style, "a");
		else
			lightstyle(self.style, "m");
	}
};

/*QUAKED light_fluoro (0 1 0) (-8 -8 -8) (8 8 8) START_OFF
Non-displayed light.
Default light value is 300
Default style is 0
If targeted, it will toggle between on or off.
Makes steady fluorescent humming sound
*/
void() light_fluoro =
{
	if (self.style >= 32)
	{
		self.use = light_use;
		if (self.spawnflags & START_OFF)
			lightstyle(self.style, "a");
		else
			lightstyle(self.style, "m");
	}
	
	precache_sound ("ambience/fl_hum1.wav");
	ambientsound (self.origin, "ambience/fl_hum1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED light_fluorospark (0 1 0) (-8 -8 -8) (8 8 8)
Non-displayed light.
Default light value is 300
Default style is 10
Makes sparking, broken fluorescent sound
*/
void() light_fluorospark =
{
	if (!self.style)
		self.style = 10;

	precache_sound ("ambience/buzz1.wav");
	ambientsound (self.origin, "ambience/buzz1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED light_globe (0 1 0) (-8 -8 -8) (8 8 8)
Sphere globe light.
Default light value is 300
Default style is 0
*/
void() light_globe =
{
	precache_model ("progs/s_light.spr");
	setmodel (self, "progs/s_light.spr");
	makestatic (self);
};

void() FireAmbient =
{
	precache_sound ("ambience/fire1.wav");
// attenuate fast
	ambientsound (self.origin, "ambience/fire1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED light_torch_small_walltorch (0 .5 0) (-10 -10 -20) (10 10 20)
Short wall torch
Default light value is 200
Default style is 0
*/
void() light_torch_small_walltorch =
{
	precache_model ("progs/flame.mdl");
	setmodel (self, "progs/flame.mdl");
	FireAmbient ();
	makestatic (self);
};

/*QUAKED light_flame_large_yellow (0 1 0) (-10 -10 -12) (12 12 18)
Large yellow flame ball
*/
void() light_flame_large_yellow =
{
	precache_model ("progs/flame2.mdl");
	setmodel (self, "progs/flame2.mdl");
	self.frame = 1;
	FireAmbient ();
	makestatic (self);
};

/*QUAKED light_flame_small_yellow (0 1 0) (-8 -8 -8) (8 8 8) START_OFF
Small yellow flame ball
*/
void() light_flame_small_yellow =
{
	precache_model ("progs/flame2.mdl");
	setmodel (self, "progs/flame2.mdl");
	FireAmbient ();
	makestatic (self);
};

/*QUAKED light_flame_small_white (0 1 0) (-10 -10 -40) (10 10 40) START_OFF
Small white flame ball
*/
void() light_flame_small_white =
{
	precache_model ("progs/flame2.mdl");
	setmodel (self, "progs/flame2.mdl");
	FireAmbient ();
	makestatic (self);
};

//============================================================================


/*QUAKED misc_fireball (0 .5 .8) (-8 -8 -8) (8 8 8)
Lava Balls
*/

void() fire_fly;
void() fire_touch;
void() misc_fireball =
{
	self.classname = "fireball";
	self.nextthink = time + (random() * 5);
	self.think = fire_fly;
	if (!self.speed)
		self.speed = 1000;
};

void() fire_fly =
{
local entity	fireball;

	fireball = spawn();
	fireball.solid = SOLID_TRIGGER;
	fireball.movetype = MOVETYPE_TOSS;
	fireball.velocity = '0 0 1000';
	fireball.velocity_x = (random() * 100) - 50;
	fireball.velocity_y = (random() * 100) - 50;
	fireball.velocity_z = self.speed + (random() * 200);
	fireball.classname = "fireball";
	setmodel (fireball, "progs/muzzleflash.spr");

	setsize (fireball, '0 0 0', '0 0 0');
	setorigin (fireball, self.origin);
	fireball.nextthink = time + 0.1;
	fireball.think = fire_addparticles;
	fireball.touch = fire_touch;
	
	self.nextthink = time + (random() * 5) + 3;
	self.think = fire_fly;
};

void() fire_addparticles = 
{
	self.emiteffectnum = particleeffectnum ("TE_IMP_FIREBALL");
	self.traileffectnum = particleeffectnum ("EF_NADETRAIL");

	self.nextthink = time + 5;
	self.think = SUB_Remove;
}

void() fire_touch =
{
	T_Damage (other, self, self.origin, self, 20, 0);
	self.emiteffectnum = 0;
	self.traileffectnum = 0;
	remove(self);
};

//============================================================================

/*QUAKED misc_explobox (0 .5 .8) (0 0 0) (32 32 64)
TESTING THING
*/

void(string gibname, float vel, vector org) ThrowDebri;
vector(float dm) VelocityForDamage;

void() barrel_explode =
{
	local vector chunkorigin, size;
	local float spd;
		
	size = (self.maxs - self.mins) * 0.5;
	//org = size + self.absmin;
	//self.origin = size;
	
	spd = 1.5 * self.dmg / 200;
	for(float i = 0; i < 2; i++)
	{
		chunkorigin = self.origin + crandom() * size;
		ThrowDebri ("progs/debris1.mdl", spd, chunkorigin);
	}

	ThrowDebri ("progs/barrel2c.mdl", spd * 2000, self.origin + '0 0 48');
	
	// bottom corners
	spd = 1.75 * self.dmg / 200;
	chunkorigin= self.origin;
	ThrowDebri ("progs/debris3.mdl", spd, chunkorigin);
	chunkorigin= self.origin;
	chunkorigin[0] += size[0];
	ThrowDebri ("progs/debris3.mdl", spd, chunkorigin);
	chunkorigin= self.origin;
	chunkorigin[1] += size[1];
	ThrowDebri ("progs/debris3.mdl", spd, chunkorigin);
	chunkorigin= self.origin;
	chunkorigin[0] += size[0];
	chunkorigin[1] += size[1];
	ThrowDebri ("progs/debris3.mdl", spd, chunkorigin);

	// a bunch of little chunks
	spd = 2 * self.dmg / 200;

	for(float i = 0; i < 8; i++)
	{
		chunkorigin = self.origin + crandom() * size;
		ThrowDebri ("progs/debris2.mdl", spd, chunkorigin);
	}
	
	self.flags |= FL_ONGROUND;
	self.emiteffectnum = 0;
	BecomeExplosion ();
	self.origin_z -= 16;
	explosion_wave (self.origin);
	T_RadiusDamage (self, self, self.dmg, self.dmg, world);	
	
	rocketimpact  ();
	
};

void()	barrel_anim2 = [0, barrel_anim3   ] {self.velocity = '0 0 0'; self.nextthink = time + 0.5;};
void()	barrel_anim3 = [0, barrel_explode ] {};

void() barrel_die = 
{
	// check for gib
	if (self.health < -40)
	{
		barrel_explode();
		return;
	}

	self.movetype = MOVETYPE_WALK;
	self.velocity = normalize(self.origin - self.enemy.origin) * 200;
	self.emiteffectnum = (particleeffectnum("TE_ARCHVILEFLAME"));
	self.think = barrel_anim2;
	self.nextthink = time + 0.5;
	self.th_die = SUB_Null;
};

void() barrel_touch =
{
	local vector end;

	if(!(other.flags & FL_ONGROUND) && (other.classname != "player") && (other.health <= 0))
		return;

	end = self.origin + '0 0 64';
	tracebox(self.origin, self.mins, self.maxs, end, FALSE, self); // guessing how q2 returns *cplane_t plane
	
	if (trace_ent == other)
	{	
		other.flags |= FL_ONGROUND;
		return;
	}

	local float ratio;
	local vector v;
	
	ratio = other.mass / self.mass;
	v = ((self.maxs - self.mins) * 0.5 + self.absmin) - ((other.maxs - other.mins) * 0.5 + other.absmin);
	
	M_walkmove (vectoyaw(v), 25 * ratio * 0.1);
};

/*QUAKED misc_explobox (0 .5 .8) (0 0 0) (32 32 64)
TESTING THING
*/

void() misc_explobox =
{
	local float	oldz;
	
	if(!self.mdl) 
		self.mdl = "progs/barrels.mdl";

	self.classname = "explo_box";
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_STEP;
	precache_model (self.mdl);
	setmodel (self, self.mdl);
	setsize (self, '-16 -16 0', '16 16 32');
   	setorigin (self, self.origin + '16 16 0');
	self.scale = 0.8;

	if (!self.mass)
		self.mass = 400;
	if (!self.health)
		self.health = 10;
	if (!self.dmg)
		self.dmg = 165;

	self.max_health = self.health;
	self.th_die = barrel_die;
	self.touch = barrel_touch;

	self.takedamage = DAMAGE_YES;
	self.netname = "$qc_exploding_barrel";

	self.origin_z = self.origin_z + 2;
	oldz = self.origin_z;
	droptofloor();

	if (oldz - self.origin_z > 250)
	{
		dprint ("explobox fell out of level at ");
		dprint (vtos(self.origin));
		dprint ("\n");
		remove(self);
	}
};

/*QUAKED misc_explobox2 (0 .5 .8) (0 0 0) (32 32 64)
Smaller exploding box, REGISTERED ONLY
*/

void() misc_explobox2 =
{	
	self.mdl = "progs/barrels.mdl";
	misc_explobox();
};

//============================================================================

float SPAWNFLAG_SUPERSPIKE	= 1;
float SPAWNFLAG_LASER = 2;

void() spikeshooter_use =
{
	if (self.spawnflags & SPAWNFLAG_LASER)
	{
		sound (self, CHAN_VOICE, "enforcer/enfire.wav", 1, ATTN_NORM);
		LaunchLaser (self.origin, self.movedir, 0 ,0);
	}
	else
	{
		sound (self, CHAN_VOICE, "weapons/spike2.wav", 1, ATTN_NORM);
		launch_spike (self.origin, self.movedir);
		newmis.velocity = self.movedir * 500;
		if (self.spawnflags & SPAWNFLAG_SUPERSPIKE)
			newmis.touch = superspike_touch;
	}
};

void() shooter_think =
{
	spikeshooter_use ();
	self.nextthink = time + self.wait;
	newmis.velocity = self.movedir * 500;
};


/*QUAKED trap_spikeshooter (0 .5 .8) (-8 -8 -8) (8 8 8) superspike laser
When triggered, fires a spike in the direction set in QuakeEd.
Laser is only for REGISTERED.
*/

void() trap_spikeshooter =
{
	SetMovedir ();
	self.use = spikeshooter_use;
	if (self.spawnflags & SPAWNFLAG_LASER)
	{
		precache_model2 ("progs/laser.mdl");
		self.deathtype = "plasma";
		precache_sound2 ("enforcer/enfire.wav");
		precache_sound2 ("enforcer/enfstop.wav");
	}
	else
	{
		self.deathtype = "spike";
		precache_sound ("weapons/spike2.wav");
	}
};


/*QUAKED trap_shooter (0 .5 .8) (-8 -8 -8) (8 8 8) superspike laser
Continuously fires spikes.
"wait" time between spike (1.0 default)
"nextthink" delay before firing first spike, so multiple shooters can be stagered.
*/
void() trap_shooter =
{
	trap_spikeshooter ();
	
	if (self.wait == 0)
		self.wait = 1;
	self.nextthink = self.nextthink + self.wait + self.ltime;
	self.think = shooter_think;
};

//===============================================================================

/*QUAKED misc_teleporttrain (0 .5 .8) (-8 -8 -8) (8 8 8)
This is used for the final bos
*/
void() misc_teleporttrain =
{	
	if (!self.speed)
		self.speed = 100;
	if (!self.target)
		objerror ("func_train without a target");

	self.cnt = 1;
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_PUSH;
	self.blocked = train_blocked;
	self.use = train_use;
	self.avelocity = '100 200 300';

	self.noise = ("misc/null.wav");
	precache_sound ("misc/null.wav");
	self.noise1 = ("misc/null.wav");
	precache_sound ("misc/null.wav");

	precache_model2 ("progs/teleport.mdl");
	setmodel (self, "progs/teleport.mdl");
	setsize (self, self.mins , self.maxs);
	setorigin (self, self.origin);

// start trains on the second frame, to make sure their targets have had
// a chance to spawn
	self.nextthink = self.ltime + 0.1;
	self.think = func_train_find;
};


//===============================================================================

void() make_bubbles;
void() bubble_remove;
void() bubble_bob;

/*QUAKED air_bubbles (0 .5 .8) (-8 -8 -8) (8 8 8)

testing air bubbles
*/

void() air_bubbles =

{
	if (deathmatch)
	{
		remove (self);
		return;
	}
	precache_model ("progs/s_bubble.spr");
	self.nextthink = time + 1;
	self.think = make_bubbles;
};

void() make_bubbles =
{
local entity	bubble;

	bubble = spawn();
	setmodel (bubble, "progs/s_bubble.spr");
	setorigin (bubble, self.origin);
	bubble.movetype = MOVETYPE_NOCLIP;
	bubble.solid = SOLID_NOT;
	bubble.velocity = '0 0 15';
	bubble.nextthink = time + 0.5;
	bubble.think = bubble_bob;
	bubble.touch = bubble_remove;
	bubble.classname = "bubble";
	bubble.frame = 0;
	bubble.cnt = 0;
	setsize (bubble, '-8 -8 -8', '8 8 8');
	self.nextthink = time + random() + 0.5;
	self.think = make_bubbles;
};

void() bubble_split =
{
local entity	bubble;
	bubble = spawn();
	setmodel (bubble, "progs/s_bubble.spr");
	setorigin (bubble, self.origin);
	bubble.movetype = MOVETYPE_NOCLIP;
	bubble.solid = SOLID_NOT;
	bubble.velocity = self.velocity;
	bubble.nextthink = time + 0.5;
	bubble.think = bubble_bob;
	bubble.touch = bubble_remove;
	bubble.classname = "bubble";
	bubble.frame = 1;
	bubble.cnt = 10;
	setsize (bubble, '-8 -8 -8', '8 8 8');
	self.frame = 1;
	self.cnt = 10;
	if (self.waterlevel != 3)
		remove (self);
};

void() bubble_remove =
{
	if (other.classname == self.classname)
	{
//		dprint ("bump");
		return;
	}
	remove(self);
};

void() bubble_bob =
{
local float		rnd1, rnd2, rnd3;

	self.cnt = self.cnt + 1;
	if (self.cnt == 4)
		bubble_split();
	if (self.cnt == 20)
		remove(self);

	rnd1 = self.velocity_x + (-10 + (random() * 20));
	rnd2 = self.velocity_y + (-10 + (random() * 20));
	rnd3 = self.velocity_z + 10 + random() * 10;

	if (rnd1 > 10)
		rnd1 = 5;
	if (rnd1 < -10)
		rnd1 = -5;
		
	if (rnd2 > 10)
		rnd2 = 5;
	if (rnd2 < -10)
		rnd2 = -5;
		
	if (rnd3 < 10)
		rnd3 = 15;
	if (rnd3 > 30)
		rnd3 = 25;
	
	self.velocity_x = rnd1;
	self.velocity_y = rnd2;
	self.velocity_z = rnd3;
		
	self.nextthink = time + 0.5;
	self.think = bubble_bob;
};

/*~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>
~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~<~>~*/

/*QUAKED viewthing (0 .5 .8) (-8 -8 -8) (8 8 8)

Just for the debugging level.  Don't use
*/

void() viewthing =

{
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	precache_model ("progs/player.mdl");
	setmodel (self, "progs/player.mdl");
};

//============================================================================
/*QUAKED ambient_suck_wind (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_suck_wind =
{
	precache_sound ("ambience/suck1.wav");
	ambientsound (self.origin, "ambience/suck1.wav", 1, ATTN_STATIC);
};

/*QUAKED ambient_drone (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_drone =
{
	precache_sound ("ambience/drone6.wav");
	ambientsound (self.origin, "ambience/drone6.wav", 0.5, ATTN_STATIC);
};

/*QUAKED ambient_flouro_buzz (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_flouro_buzz =
{
	precache_sound ("ambience/buzz1.wav");
	ambientsound (self.origin, "ambience/buzz1.wav", 1, ATTN_STATIC);
};
/*QUAKED ambient_drip (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_drip =
{
	precache_sound ("ambience/drip1.wav");
	ambientsound (self.origin, "ambience/drip1.wav", 0.5, ATTN_STATIC);
};
/*QUAKED ambient_comp_hum (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_comp_hum =
{
	precache_sound ("ambience/comp1.wav");
	ambientsound (self.origin, "ambience/comp1.wav", 1, ATTN_STATIC);
};
/*QUAKED ambient_thunder (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_thunder =
{
	precache_sound ("ambience/thunder1.wav");
	ambientsound (self.origin, "ambience/thunder1.wav", 0.5, ATTN_STATIC);
};
/*QUAKED ambient_light_buzz (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_light_buzz =
{
	precache_sound ("ambience/fl_hum1.wav");
	ambientsound (self.origin, "ambience/fl_hum1.wav", 0.5, ATTN_STATIC);
};
/*QUAKED ambient_swamp1 (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_swamp1 =
{
	precache_sound ("ambience/swamp1.wav");
	ambientsound (self.origin, "ambience/swamp1.wav", 0.5, ATTN_STATIC);
};
/*QUAKED ambient_swamp2 (0.3 0.1 0.6) (-10 -10 -8) (10 10 8)
*/
void() ambient_swamp2 =
{
	precache_sound ("ambience/swamp2.wav");
	ambientsound (self.origin, "ambience/swamp2.wav", 0.5, ATTN_STATIC);
};

//============================================================================

void() noise_think =
{
	self.nextthink = time + 0.5;
	sound (self, 1, "enforcer/enfire.wav", 1, ATTN_NORM);
	sound (self, 2, "enforcer/enfstop.wav", 1, ATTN_NORM);
	sound (self, 3, "enforcer/sight1.wav", 1, ATTN_NORM);
	sound (self, 4, "enforcer/sight2.wav", 1, ATTN_NORM);
	sound (self, 5, "enforcer/sight3.wav", 1, ATTN_NORM);
	sound (self, 6, "enforcer/sight4.wav", 1, ATTN_NORM);
	sound (self, 7, "enforcer/pain1.wav", 1, ATTN_NORM);
};

/*QUAKED misc_noisemaker (1 0.5 0) (-10 -10 -10) (10 10 10)

For optimzation testing, starts a lot of sounds.
*/

void() misc_noisemaker =

{
	precache_sound2 ("enforcer/enfire.wav");
	precache_sound2 ("enforcer/enfstop.wav");
	precache_sound2 ("enforcer/sight1.wav");
	precache_sound2 ("enforcer/sight2.wav");
	precache_sound2 ("enforcer/sight3.wav");
	precache_sound2 ("enforcer/sight4.wav");
	precache_sound2 ("enforcer/pain1.wav");
	precache_sound2 ("enforcer/pain2.wav");
	precache_sound2 ("enforcer/death1.wav");
	precache_sound2 ("enforcer/idle1.wav");

	self.nextthink = time + 0.1 + random();
	self.think = noise_think;
};

//============================================================================

/*
=================
gibs
=================
*/

void() gib_kicker_touch = 
{
	if(!other.takedamage || other.classname == "gib")
		return;
		
	entity oself;
	if (other.flags & FL_MONSTER)
	{	
		oself = self;
		self = self.owner;

		self.velocity = normalize(other.angles) * 150;
		self.velocity_z = 40*crandom()*8;

		self.flags = self.flags - ( self.flags & FL_ONGROUND );

		self = oself;
		return;
	}

	if(vlen(other.velocity) < 50)
		return;

	traceline (self.origin, self.origin + normalize(other.velocity), FALSE, self);

	if (trace_startsolid)
		return;
	
	oself = self;
	self = self.owner;

	self.flags = self.flags - ( self.flags & FL_ONGROUND );
	self.velocity = normalize(other.velocity) * 150;
	self.velocity_z = 40*crandom()*8;

	self = oself;
};

void(entity own) gib_kicker_bbox =
{
	entity bbox = spawn();
	setorigin (bbox, own.origin);
	own.nextbumper = bbox;
	bbox.owner = own;
	bbox.touch = gib_kicker_touch;
	setsize(bbox, '-8 -8 -8', '8 8 8');
	bbox.solid = SOLID_TRIGGER;
	bbox.movetype = MOVETYPE_FLY;
};

void() gib_touch =
{	
	if(other.solid != SOLID_BSP)
		return;

	if(self.enemy == self)
	{	
		if (random() < 0.4)
			_splatter (); 
		pointparticles (particleeffectnum("EF_GIBSPRAY"), self.origin);
		self.enemy = world;
		return;
	}
};

void() gib_Remove =
{	
	remove(self.nextbumper);
	pointparticles (particleeffectnum("EF_GIBSPRAY"), self.origin);
	remove(self);
};

float(entity ent) gib_checkbott =
{	
	trace_t tr;
	gi_trace (tr, self.origin, VEC_ORIGIN, VEC_ORIGIN, self.origin + '0 0 -8', ent, TRUE);

	if (tr.fraction < 1)
		return TRUE;

	return FALSE;
}

void() gib_think = 
{	
	self.think = gib_think;
	self.nextthink = time;

	if (time > self.ltime)
	{	
		if (self.classname == "gib")
			gib_Remove ();
		else
			remove(self);

		return;
	}

	if (self.nextbumper)
		self.nextbumper.origin = self.origin;
	
	if (!(self.flags & FL_ONGROUND) && !self.enemy)
	{
	//	bprint("not on ground", "\n");
		physics_enable (self, TRUE);
		self.enemy = self;
	}

	float res = gib_checkbott(self);

	if (res == FALSE)
		self.flags &= ~FL_ONGROUND;
	else
	{	
		self.flags |= FL_ONGROUND;
	//	bprint("on ground", "\n"); // it'll auto disable itself
	}
};

void(string gibname, float dmg) ThrowGib =
{	
	local vector size = (self.maxs - self.mins) * 0.5;
	local	vector org = size + self.absmin;
	local vector chunkorg;
	
	chunkorg_x = org_x + crandom() * size_x;
	chunkorg_y = org_y + crandom() * size_y;
	chunkorg_z = org_z + crandom() * size_z;
	
	local	entity new;
	new = spawn();
	setorigin(new, chunkorg);
	setmodel (new, gibname);
	setsize (new , '-2 -2 -2', '2 2 2');

	new.movetype = MOVETYPE_PHYSICS;

	new.classname = "gib";
	new.takedamage = DAMAGE_YES;

	new.scale = 1.3;

	new.traileffectnum = particleeffectnum("EF_GIBSPRAY");
	new.solid = SOLID_CORPSE;

	new.velocity = self.velocity + VelocityForDamage(dmg)*0.25;
	new.velocity = ClipGibVelocity(new.velocity);

	new.touch = gib_touch;
	new.think = gib_think;
	new.ltime = time + 10 + random()*10;
	new.nextthink = time + 0.1;
	new.frame = 0;
	new.flags = 0;

	new.mass = 5;
	new.friction = 1;
	new.bouncefactor = 0.3;
	new.bouncestop = 0.2;

	gib_kicker_bbox (new);
	physics_enable(self, TRUE);
};

void(string gibname, float dmg) ThrowHead2 =
{	
	// local vector size = (self.maxs - self.mins) * 0.5;
	local	entity new;
	new = spawn();
	setorigin(new, self.origin);
	new.origin_z = self.absmax_z;
	new.scale = 1.7;
	
	setmodel (new , gibname);
	setsize (new , '-2 -2 -2', '2 2 2');
	
	new.movetype = MOVETYPE_PHYSICS;
	new.traileffectnum = particleeffectnum("EF_GIBSPRAY");

	new.solid = SOLID_CORPSE;

	new.classname = "gib";
	new.takedamage = DAMAGE_YES;

	new.touch = gib_touch;
	new.velocity = self.velocity + VelocityForDamage(dmg)*0.25;
	new.velocity = ClipGibVelocity(new.velocity);

	new.touch = gib_touch;
	new.think = gib_think;
	new.ltime = time + 10 + random()*10;
	new.nextthink = time + 0.1;
	new.frame = 0;
	new.flags = 0;

	new.mass = 5;
	new.friction = 1;
	new.bouncefactor = 0.3;
	new.bouncestop = 0.2;

	gib_kicker_bbox(new);
	physics_enable(self, TRUE);
};

void(string gibname, float vel, vector org) ThrowDebri =
{
	local	entity new;
	new = spawn();
	new.origin = org;

	setmodel (new, gibname);
	setsize (new, '-2 -2 -2', '2 2 2');

	if (gibname == "progs/barrel2c.mdl")
		new.scale = 0.6;
	
	new.velocity = self.velocity + VelocityForDamage(vel);
	new.velocity = ClipGibVelocity(new.velocity);
	
	new.movetype = MOVETYPE_PHYSICS;
	new.solid = SOLID_CORPSE;
	//new.hitcontentsmaski &= ~CONTENTBIT_SOLID;

	new.think = gib_think;
	new.nextthink = time + 0.1;
	new.ltime = time + 5 + random()*5;
	new.frame = 0;
	new.flags = 0;

	new.mass = 5;
	new.friction = 1;
	new.bouncefactor = 0.5;
	new.bouncestop = 0.1;

	physics_enable(self, TRUE);
};

void(float dm) MonsterGib =
{	
	sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);

	for(float i = 0; i < 2; i++)
		ThrowGib ("progs/pork1.mdl", dm);

	for(float i = 0; i < 2; i++)
		ThrowGib ("progs/pork2.mdl", dm);

	for(float i = 0; i < 2; i++)
		ThrowGib ("progs/pork3.mdl", dm);

	for(float i = 0; i < 2; i++)
		ThrowGib ("progs/pork4.mdl", dm);

	for(float i = 0; i < 2; i++)
		ThrowGib ("progs/pork5.mdl", dm);

	ThrowHead2 ("progs/brain.mdl", dm);
	pointparticles (particleeffectnum("TE_GORESPRAY"), self.origin + '0 0 24', '0 0 0', 4);
	SpawnBloodSplat (self.origin + '0 0 24', '0 0 -20', 0);
}

void() deadsoldier_gib =
{	
	if (self.health > -80)
		return;
	
	sound (self, CHAN_BODY, "player/udeath.wav", 1, ATTN_NORM);

	MonsterGib (self.dmg);

};

void(entity attacker, float damage, float MOD) deadsoldier_getdmg = 
{
	damage = self.dmg;
};

void() misc_deadsoldier =
{
	precache_model ("progs/dude.mdl");

	setmodel (self, "progs/dude.mdl");

	setsize (self, '-16 -16 0', '16 16 16');
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_CORPSE;
	self.takedamage = DAMAGE_YES;
	
	self.cnt = self.cnt;
	self.th_die = deadsoldier_gib;
	self.flags |= FL_MONSTER;

	switch(self.cnt)
      {
   		case 1:
    			self.frame = 1;
     			break;
   		case 2:
     			self.frame = 2;	
			break;
		case 3:
     			self.frame = 3;	
			break;
		case 4:
     			self.frame = 4;	
			break;
		case 5:
     			self.frame = 5;
			break;
   		default:
     			self.frame = 0;
     			break;
   	} 
};

void() misc_corpse =
{	
	precache_model ("progs/corpse1.md3");
	setmodel (self, "progs/corpse1.md3");
	setsize(self, VEC_ORIGIN, VEC_ORIGIN);
	self.movetype = MOVETYPE_NONE;
	
	self.scale = 0.74;
	makestatic(self);
};

void() misc_evilmeat1 =
{	
	precache_model ("progs/evilmeat.md3");
	setmodel (self, "progs/evilmeat.md3");
	setsize(self, VEC_ORIGIN, VEC_ORIGIN);
	self.movetype = MOVETYPE_NONE;

	self.scale = 0.6;
	makestatic(self);
};

void() misc_evilmeat2 =
{	
	precache_model ("progs/evilmeat2.md3");
	setmodel (self, "progs/evilmeat2.md3");
	setsize(self, VEC_ORIGIN, VEC_ORIGIN);
	self.movetype = MOVETYPE_NONE;

	self.scale = 0.5;
	makestatic(self);
};

void() cagedcorpse_think =
{
	self.frame ++;		
	if (self.frame >= 79)
		self.frame = 0;

	self.think = cagedcorpse_think;
	self.nextthink = time + 0.035;
};

void() misc_cagedcorpse =
{	
	precache_model ("progs/caged_meat.md3");
	setmodel (self, "progs/caged_meat.md3");
	setsize(self, VEC_ORIGIN, VEC_ORIGIN);
	self.movetype = MOVETYPE_NONE;
	
	self.think = cagedcorpse_think;
	self.nextthink = time + 0.03 + random()*2;
	self.scale = 0.8;
};

void() misc_pile1 =
{	
	precache_model ("progs/piles_b.md3");
	setmodel (self, "progs/piles_b.md3");
	setsize(self, VEC_ORIGIN, VEC_ORIGIN);
	self.movetype = MOVETYPE_NONE;
	
	self.scale = 0.72;
	makestatic(self);
};

void() misc_pile2 =
{	
	precache_model ("progs/piles_c.md3");
	setmodel (self, "progs/piles_c.md3");
	setsize(self, VEC_ORIGIN, VEC_ORIGIN);
	self.movetype = MOVETYPE_NONE;
	
	self.scale = 0.72;
	makestatic(self);
};

static void() torch_burn =
{
	pointparticles (particleeffectnum("TE_TORCH"), self.origin);
	self.think = torch_burn;
	self.nextthink = time + 0.1;
}

static void() spawn_fire = 
{	
	entity e;
	e = spawn();
	makevectors(self.angles);
	setorigin(e, self.origin + '0 0 24');
	e.think = torch_burn;
	e.nextthink = time + 0.1;
}

void() misc_torsotorch =
{	
	spawn_fire();

	precache_model ("progs/torso.mdl");
	setmodel (self, "progs/torso.mdl");
	setsize(self, VEC_ORIGIN, VEC_ORIGIN);
	self.movetype = MOVETYPE_NONE;
	FireAmbient ();
	self.scale = 0.72;
	lightstyle(self.style, "m");
	//makestatic(self);
};

void() misc_dummy =
{	
	precache_model ("progs/evilmeat2.md3");
	setmodel (self, "progs/evilmeat2.md3");
	setsize(self, '-16 -16 -24', '16 16 32');
	self.movetype = MOVETYPE_FLY;
	self.health = 999999;
	self.takedamage = DAMAGE_YES;
//	self.flags |= FL_MONSTER;
	self.solid = SOLID_BBOX;

	self.scale = 0.5;
};