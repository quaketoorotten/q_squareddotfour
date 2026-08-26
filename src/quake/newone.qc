/*==============================================================================
OLD ONE / Shub-Niggurath (ID software Version)

New special version for the RITUAL mod
+ new star/train entity as org is broken

==============================================================================*/
$frame idle1 idle2 idle3 idle4 idle5 idle6 idle7 idle8
$frame idle9 idle10 idle11 idle12 idle13 idle14 idle15 idle16
$frame idle17 idle18 idle19 idle20 idle21 idle22 idle23 idle24
$frame idle25 idle26 idle27 idle28 idle29 idle30 idle31 idle32
$frame idle33 idle34 idle35 idle36 idle37 idle38 idle39 idle40
$frame idle41 idle42 idle43 idle44 idle45 idle46

$frame shake1 shake2 shake3 shake4 shake5 shake6 shake7 shake8
$frame shake9 shake10 shake11 shake12 shake13 shake14 shake15
$frame shake16 shake17 shake18 shake19 shake20

//======================================================================
// Vector randomizer, used mostly for avelocity setups
//----------------------------------------------------------------------
vector(float base, float rndmix, float plusminus) vecrand =
{
	local vector vecmix;
	if (plusminus) {
		vecmix_x = base + crandom() * rndmix; 
		vecmix_y = base + crandom() * rndmix; 
		vecmix_z = base + crandom() * rndmix; 
	}
	else {
		vecmix_x = base + random() * rndmix; 
		vecmix_y = base + random() * rndmix; 
		vecmix_z = base + random() * rndmix; 
	}
	return vecmix;
};

//======================================================================
// New finale functions (so original still works)
void() shub_finale_1;
void() shub_finale_2;
void() shub_finale_3;
void() shub_finale_4;

//===========================================================================
void() idshub_idle1 =[ $idle1, idshub_idle2 ] {};
void() idshub_idle2 =[ $idle2, idshub_idle3 ] {};
void() idshub_idle3 =[ $idle3, idshub_idle4 ] {};
void() idshub_idle4 =[ $idle4, idshub_idle5 ] {};
void() idshub_idle5 =[ $idle5, idshub_idle6 ] {};
void() idshub_idle6 =[ $idle6, idshub_idle7 ] {};
void() idshub_idle7 =[ $idle7, idshub_idle8 ] {};
void() idshub_idle8 =[ $idle8, idshub_idle9 ] {};
void() idshub_idle9 =[ $idle9, idshub_idle10 ] {};
void() idshub_idle10 =[ $idle10, idshub_idle11 ] {};
void() idshub_idle11 =[ $idle11, idshub_idle12 ] {};
void() idshub_idle12 =[ $idle12, idshub_idle13 ] {};
void() idshub_idle13 =[ $idle13, idshub_idle14 ] {};
void() idshub_idle14 =[ $idle14, idshub_idle15 ] {};
void() idshub_idle15 =[ $idle15, idshub_idle16 ] {};
void() idshub_idle16 =[ $idle16, idshub_idle17 ] {};
void() idshub_idle17 =[ $idle17, idshub_idle18 ] {};
void() idshub_idle18 =[ $idle18, idshub_idle19 ] {};
void() idshub_idle19 =[ $idle19, idshub_idle20 ] {};
void() idshub_idle20 =[ $idle20, idshub_idle21 ] {};
void() idshub_idle21 =[ $idle21, idshub_idle22 ] {};
void() idshub_idle22 =[ $idle22, idshub_idle23 ] {};
void() idshub_idle23 =[ $idle23, idshub_idle24 ] {};
void() idshub_idle24 =[ $idle24, idshub_idle25 ] {};
void() idshub_idle25 =[ $idle25, idshub_idle26 ] {};
void() idshub_idle26 =[ $idle26, idshub_idle27 ] {};
void() idshub_idle27 =[ $idle27, idshub_idle28 ] {};
void() idshub_idle28 =[ $idle28, idshub_idle29 ] {};
void() idshub_idle29 =[ $idle29, idshub_idle30 ] {};
void() idshub_idle30 =[ $idle30, idshub_idle31 ] {};
void() idshub_idle31 =[ $idle31, idshub_idle32 ] {};
void() idshub_idle32 =[ $idle32, idshub_idle33 ] {};
void() idshub_idle33 =[ $idle33, idshub_idle34 ] {};
void() idshub_idle34 =[ $idle34, idshub_idle35 ] {};
void() idshub_idle35 =[ $idle35, idshub_idle36 ] {};
void() idshub_idle36 =[ $idle36, idshub_idle37 ] {};
void() idshub_idle37 =[ $idle37, idshub_idle38 ] {};
void() idshub_idle38 =[ $idle38, idshub_idle39 ] {};
void() idshub_idle39 =[ $idle39, idshub_idle40 ] {};
void() idshub_idle40 =[ $idle40, idshub_idle41 ] {};
void() idshub_idle41 =[ $idle41, idshub_idle42 ] {};
void() idshub_idle42 =[ $idle42, idshub_idle43 ] {};
void() idshub_idle43 =[ $idle43, idshub_idle44 ] {};
void() idshub_idle44 =[ $idle44, idshub_idle45 ] {};
void() idshub_idle45 =[ $idle45, idshub_idle46 ] {};
void() idshub_idle46 =[ $idle46, idshub_idle1 ] {};

//===========================================================================
void(float always_fire) shub_telesplash =
{
	if (always_fire > 0 || random() > 0.66)
	{
		// Make sure it does not happen more than 0.3s
		if (self.waitmin < time) {
			self.waitmin = time + 0.3;
			sound (self, CHAN_BODY, "misc/r_tele1.wav", 1, ATTN_NORM);

			// start a teleport splash inside shub
			self.view_ofs_x = crandom()*50;
			self.view_ofs_y = -100;
			self.view_ofs_z = random()*100;
			self.oldorigin = self.origin + self.view_ofs;
			WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
			WriteByte (MSG_BROADCAST, TE_TELEPORT);
			WriteCoord (MSG_BROADCAST, self.oldorigin_x);
			WriteCoord (MSG_BROADCAST, self.oldorigin_y);
			WriteCoord (MSG_BROADCAST, self.oldorigin_z);
		}
	}
};

//===========================================================================
void() idshub_pain1 = [ $shake1,  idshub_pain2 ] { 
	lightstyle(0, "m");
	sound (self, CHAN_VOICE, "boss2/death.wav", 1, ATTN_NORM);
};
void() idshub_pain2 = [ $shake2,  idshub_pain3 ] { lightstyle(0, "k");};
void() idshub_pain3 = [ $shake3,  idshub_pain4 ] { lightstyle(0, "k");shub_telesplash(0);};
void() idshub_pain4 = [ $shake4,  idshub_pain5 ] { lightstyle(0, "i");};
void() idshub_pain5 = [ $shake5,  idshub_pain6 ] { lightstyle(0, "g");shub_telesplash(0);};
void() idshub_pain6 = [ $shake6,  idshub_pain7 ] { lightstyle(0, "e");};
void() idshub_pain7 = [ $shake7,  idshub_pain8 ] { lightstyle(0, "c");shub_telesplash(0);};
void() idshub_pain8 = [ $shake8,  idshub_pain9 ] { lightstyle(0, "a");};
void() idshub_pain9 = [ $shake9,  idshub_pain10 ] {lightstyle(0, "c");shub_telesplash(0);};
void() idshub_pain10 =[ $shake10, idshub_pain11 ] {lightstyle(0, "e");};

void() idshub_pain11 =[ $shake11, idshub_pain12 ] {lightstyle(0, "g");shub_telesplash(0);};
void() idshub_pain12 =[ $shake12, idshub_pain13 ] {lightstyle(0, "i");};
void() idshub_pain13 =[ $shake13, idshub_pain14 ] {lightstyle(0, "k");shub_telesplash(0);};
void() idshub_pain14 =[ $shake14, idshub_pain15 ] {lightstyle(0, "m");};
void() idshub_pain15 =[ $shake15, idshub_pain16 ] {lightstyle(0, "m");
self.count = self.count + 1;
if (self.count < 3) self.think = idshub_pain1;
};
void() idshub_pain16 =[ $shake16, idshub_pain17 ] {lightstyle(0, "g");};
void() idshub_pain17 =[ $shake17, idshub_pain18 ] {lightstyle(0, "c");};
void() idshub_pain18 =[ $shake18, idshub_pain19 ] {lightstyle(0, "b");};
void() idshub_pain19 =[ $shake19, idshub_pain20 ] {lightstyle(0, "a");};
void() idshub_pain20 =[ $shake20, idshub_pain20 ] {shub_finale_4();};

//============================================================================
// Final thrash, explosion and on screen text waffle
//============================================================================
void() shub_finale_1 =
{
	intermission_running = 1;						//End of the game!
	intermission_exittime = time + 100000;			// never allow exit

	// find the intermission spot
	self.owner = find (world, classname, "info_intermission");
	if (!self.owner) dprint("Cannot find info_intermission!\n");
		
	// Find misc teleport thing and remove it
	self.enemy = find (world, classname, "misc_teleporttrain_shub2");
	if (!self.enemy) dprint("Cannot find teleporttrain!\n");
	else remove (self.enemy);

	// prepare all clients for finale (set to blank)
	WriteByte (MSG_ALL, SVC_FINALE);
	WriteString (MSG_ALL, "");

	// Cycle through all players and move them to the intermission
	self.enemy = find (world, classname, "player");
	while (self.enemy != world) {
		self.enemy.view_ofs = '0 0 0';
		// Change players angles/v_angle to the interm camera
		self.enemy.angles = self.enemy.v_angle = self.owner.mangle;
		self.enemy.fixangle = TRUE;		// turn this way immediately
		// WTF is this?
		//self.enemy.map = self.map;
		self.enemy.nextthink = time + 0.5;
		// No more world interactions
		self.enemy.takedamage = DAMAGE_NO;
		self.enemy.solid = SOLID_NOT;
		self.enemy.movetype = MOVETYPE_NONE;
		self.enemy.modelindex = 0;
//		self.mdl = 	self.enemy.pweaponmodel.model;
		// Move to intermissions camera origin
		setorigin (self.enemy, self.owner.origin);
		// Anymore players?
		self.enemy = find (self.enemy, classname, "player");
	}	
	
	self.nextthink = time + 0.3;
	self.think = shub_finale_2;
};

//----------------------------------------------------------------------
// Randomnly spawn 10 teleporter sparkle effects
//----------------------------------------------------------------------
void() shub_finale_2 =
{
	// Start with a teleport splash inside shub
	shub_telesplash(1);
	
	self.nextthink = time + random()*0.5;
	self.think = shub_finale_3;
};

//----------------------------------------------------------------------
void() shub_finale_3 =
{
	// start shub thrashing wildly
	//sound (self, CHAN_VOICE, "boss2/death.wav", 1, ATTN_NORM);
	lightstyle(0, "abcdefghijklmlkjihgfedcb");	

	// Three loops of pain
	self.count = 0;
	// Start pain animation + tele splashes
	idshub_pain1();
};

//----------------------------------------------------------------------
// Called after thrash animation (last frame)
//----------------------------------------------------------------------
void() shub_finale_4 =
{	
	local	vector	oldo;
	local	float	x, y, z;
	local	float	r;
	local entity	n;
	
	// Play exploding sound
	sound (self, CHAN_VOICE, "boss2/pop2.wav", 1, ATTN_NORM);
	// Start with shub origin
	oldo = self.origin;

	// Generate a cube of gibs around shub
	z = 16;
	while (z <= 144)
	{
		x = -64;
		while (x <= 64)
		{
			y = -64;
			while (y <= 64)
			{
				self.origin_x = oldo_x + x;
				self.origin_y = oldo_y + y;
				self.origin_z = oldo_z + z;

				r = random();
				if (r < 0.3) ThrowGib ("progs/gib1.mdl", -500);
				else if (r < 0.6) ThrowGib ("progs/gib2.mdl", -500);
				else ThrowGib ("progs/gib3.mdl", -500);
				y = y + 32;
			}
			x = x + 32;
		}
		z = z + 96;
	}

	// start the blah blah blah
	WriteByte (MSG_ALL, SVC_FINALE);
	WriteString (MSG_ALL, "As you telefrag through the bowels\nof the Lord of the Woods gigantic body\nYou are drenched in mountains of blood!\n\nOnce the blood mist clears and your\nsenses return you feel a gaping dread\nas you realize this twisted realm\nis not bound by space and time but\na hungering void warping your being!\n\nYou hear the whispering voices of\nnightmarish horrors lurking closeby\nThey are watching, waiting and wondering\nwhat is your next move... Ranger!\n");

/*
1234567890123456789012345678901234567890
As you telefrag through the bowels\n
of the Lord of the Woods gigantic body\n
You are drenched in mountains of blood!\n
\n
Once the blood mist clears and your\n
senses return you feel a gaping dread\n
as you realize this twisted realm\n
is not bound by space and time but\n
a hungering void warping your being!\n
\n
You hear the whispering voices of\n
nightmarish horrors lurking closeby\n
They are watching, waiting and wondering\n
what is your next move... Ranger!\n
*/

	// setup a player model, TONS of hardcoded shite!
	n = spawn();
	setmodel (n, "progs/player.mdl");
	oldo = oldo - '32 264 0';
	setorigin (n, oldo);
	n.angles = '0 290 0';
	n.frame = 115;

	local entity gun;
	gun = spawn();
	setmodel (gun, self.mdl);
	setorigin (gun, oldo);
	gun.angles = '0 290 0';
	gun.frame = 115;
	
	// No more shub!
	remove (self);

	// Default end cd track
	WriteByte (MSG_ALL, SVC_CDTRACK);
	WriteByte (MSG_ALL, 3);
	WriteByte (MSG_ALL, 3);
	// Reset light styles
	lightstyle(0, "m");	

};

//============================================================================
void (entity attacker, float damage, float MOD) idshub_pain =
{
	self.health = self.max_health;		// reset health	
};

//----------------------------------------------------------------------
void() idshub_die =
{
	self.deadflag = DEAD_DEAD;	// dead is dead
	self.effects = 0;			// Remove effects on death
	shub_finale_1();
};

/*============================================================================
 QUAKED monster_newone (1 0 0) (-16 -16 -24) (16 16 32)
============================================================================*/
void() monster_newone =
{
	self.mdl = "progs/oldone.mdl";
	precache_model (self.mdl);

	// idle/sight not used
	precache_sound ("boss2/idle.wav");
	precache_sound ("boss2/sight.wav");
	
	// No default pain sound
	// finale_3/finale_4 stages
	precache_sound ("boss2/death.wav");
	precache_sound ("boss2/pop2.wav");
	
	self.health = self.max_health = 40000;	// kill ONLY by telefrag
	self.velocity = '0 0 0';		// Make sure stationary
	
	self.th_stand = self.th_walk = self.th_run = idshub_idle1;
	self.th_pain = idshub_pain;
	self.th_die = idshub_die;
	
	// Manually add monster count
	total_monsters = total_monsters + 1;

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	setmodel(self, self.mdl);
	setsize (self, '-160 -128 -24', '160 128 256');
	self.takedamage = DAMAGE_YES;
	shub = self;

	self.think = idshub_idle1;
	self.nextthink = time + 0.1;	
};

//======================================================================
/*QUAKED shub_teleporttrain (0 0.5 0.8) (-8 -8 -8) (8 8 8) x
This is used for the final boss ONLY
Flying ball needed to teleport kill Shub-Niggurath
-------- KEYS --------
-------- SPAWNFLAGS --------
-------- NOTES --------
This is used for the final boss ONLY
Flying ball needed to teleport kill Shub-Niggurath
Originallu used bmodel train functions, setup to work like
the shalrath homing missile

======================================================================*/
void() shub_teleporttrain_next;
void() shub_teleporttrain_target =
{
	local vector dir;

	if (self.target != "") {
		// Find next target entity
		self.enemy = find (world, targetname, self.target);
		if (self.enemy) {
			// Work out distance and angle to turn towards
			dir = normalize(self.enemy.origin - self.origin);
			self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
			self.velocity = dir * self.speed;
	
			// Shift target to next target in the entity chain
			self.target = self.enemy.target;
			self.nextthink = time + 0.1;
			self.think = shub_teleporttrain_next;
			return;
		}
	}
	// No target or entity to follow, full stop
	self.velocity = '0 0 0';
	self.enemy = world;
};

//----------------------------------------------------------------------
void() shub_teleporttrain_next =
{
	local vector dir;
	if (!self.enemy) return;

	// Work out how close to the next target (self.enemy)		
	self.t_length = vlen(self.enemy.origin - self.origin);
	if (self.t_length < self.t_width) shub_teleporttrain_target();
	else {
		// Keep turning towards corner
		dir = normalize(self.enemy.origin - self.origin);
		self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
		self.velocity = dir * self.speed;
	
		// Keep checking
		self.nextthink = time + 0.1;
		self.think = shub_teleporttrain_next;
	}		
};

//----------------------------------------------------------------------
void() misc_teleporttrain_shub2 =
{	
	self.mdl = "progs/teleport.mdl";
	precache_model (self.mdl);

	self.solid = SOLID_TRIGGER;
	// Push movetype cannot rotate, fly can
	// Push also does weird shit with projectiles
	//	self.movetype = MOVETYPE_PUSH;
	self.movetype = MOVETYPE_FLY;
	self.use = shub_teleporttrain_target;
	self.avelocity = vecrand(50,250,FALSE);

	setmodel (self, self.mdl);
	setsize (self, VEC_ORIGIN , VEC_ORIGIN);

	if (!self.speed) self.speed = 100;
	if (!self.t_width) self.t_width = 32;
};