
void() bubble_bob;

/*
==============================================================================

PLAYER

==============================================================================
*/

$cd id1/models/player_4
$origin 0 -6 24
$base base		
$skin skin

/*
==============================================================================
PLAYER
==============================================================================
*/

void() player_run;

/*void() player_firegun = 
{	
	if (self.dcnt > time)
		return;
	
	if (self.attack_state != AS_MISSILE && self.attack_state != AS_MELEE)
		self.frame = 46;

	if (self.frame >= 53)
	{
		self.attack_state = AS_MELEE;
		player_run_unforced ();
		return;
	}
	
	self.attack_state = AS_MISSILE;
	self.frame++;
	self.dcnt = time + 0.1;
};

void() player_firegunloop = 
{	
	if (self.attack_state == AS_MELEE)
		return;

	if (self.dcnt > time)
		return;

	if (self.attack_state != AS_MISSILE)
		self.frame = 46;

	if (self.frame >= 48)
	{
		self.frame = 46;
		return;
	}
	
	self.attack_state = AS_MISSILE;
	self.frame++;
	self.dcnt = time + 0.1;
};*/

void(float fr) player_run_unforced = 
{	
	self.baseframe = fr;
	if (self.velocity_x || self.velocity_y)
		self.frame = 2;
	else
		self.frame = 1;

	self.walkframe = 0;
}

void()	player_stand1 =[	self.frame,	player_stand1	]
{	
	self.attack_state = AS_STRAIGHT;

	if (self.button2 && self.attack_state != AS_MISSILE && self.count == 0)
	{	
	//	self.baseframe = 3;
		self.walkframe = 3;
		self.count = time + frameduration(player_slimy_transfer, 3);
	}

	if (self.count < time)
	{	
		self.baseframe = 1;
		self.walkframe = 1;
		self.count = 0;
	}

	if (self.velocity_x || self.velocity_y)
	{
		self.walkframe=0;
		player_run();
		return;
	}

	self.frame = self.walkframe;
	self.nextthink = time + 0.03;
};

void()	player_run =[	self.frame,	player_run	]
{
	self.baseframe = 1;
	self.attack_state = AS_STRAIGHT;
//	bprint(ftos(self.baseframe), "\n");
	if (self.button2 && self.attack_state != AS_MISSILE  && self.count == 0)
	{	
	//	self.baseframe = 3;
		self.walkframe = 3;
		self.count = time + frameduration(player_slimy_transfer, 3);
	}

	if (self.count < time)
	{	
		self.baseframe = 1;
		self.walkframe = 2;
		self.count = 0;
	}

	if (!self.velocity_x && !self.velocity_y)
	{
		self.walkframe=0;
		player_stand1();
		return;
	}

	self.frame = self.walkframe;
	self.nextthink = time + 0.03;
};

//============================================================================

void(float num_bubbles) DeathBubbles;


void() PainSound =
{
local float		rs;

	if (self.health < 0)
		return;

	if (damage_attacker.classname == "teledeath")
	{
		sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	}

// water pain sounds
	if (self.watertype == CONTENT_WATER && self.waterlevel == 3)
	{
		DeathBubbles(1);
		if (random() > 0.5)
			sound (self, CHAN_VOICE, "player/drown1.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_VOICE, "player/drown2.wav", 1, ATTN_NORM);
		return;
	}

// slime pain sounds
	if (self.watertype == CONTENT_SLIME)
	{
// FIX ME	put in some steam here
		if (random() > 0.5)
			sound (self, CHAN_VOICE, "player/lburn1.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_VOICE, "player/lburn2.wav", 1, ATTN_NORM);

		self.pain_finished = time + 0.2;
		return;
	}

	if (self.watertype == CONTENT_LAVA)
	{
		if (random() > 0.5)
			sound (self, CHAN_VOICE, "player/lburn1.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_VOICE, "player/lburn2.wav", 1, ATTN_NORM);

		self.pain_finished = time + 0.2;
		return;
	}

	if (self.pain_finished > time)
	{
		self.axhitme = 0;
		return;
	}
	self.pain_finished = time + 0.22;

	rs = rint((random() * 5) + 1);

	self.noise = "";
	if (rs == 1)
		self.noise = "player/pain1.wav";
	else if (rs == 2)
		self.noise = "player/pain2.wav";
	else if (rs == 3)
		self.noise = "player/pain3.wav";
	else if (rs == 4)
		self.noise = "player/pain4.wav";
	else if (rs == 5)
		self.noise = "player/pain5.wav";
	else
		self.noise = "player/pain6.wav";

	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	return;
};

void()	player_pain1 =	[	53,	player_pain2	] {};
void()	player_pain2 =	[	54,	player_pain3	] {};
void()	player_pain3 =	[	55,	player_pain4	] {};
void()	player_pain4 =	[	56,	player_pain5	] {};
void()	player_pain5 =	[	57,	player_run 		] {};

void()	player_axpain1 =	[	58,	player_axpain2	] {};
void()	player_axpain2 =	[	59,	player_axpain3	] {};
void()	player_axpain3 =	[	60,	player_axpain4	] {};
void()	player_axpain4 =	[	61,	player_run		] {};

void()	player_painb1 =	[	62,	player_pain2	] {};
void()	player_painb2 =	[	63,	player_pain3	] {};
void()	player_painb3 =	[	64,	player_pain4	] {};
void()	player_painb4 =	[	65,	player_run		] {};

void()	player_deactivate1 =	[	62,	player_deactivate2] {};
void()	player_deactivate2 =	[	63,	player_deactivate3] {};
void()	player_deactivate3 =	[	64,	player_deactivate4] {};
void()	player_deactivate4 =	[	65,	player_run		] {};

void(entity attacker, float damage, float MOD) player_pain =
{	
	if (self.invisible_finished > time)
		return;		// eyes don't have pain frames
		
	local float n;
	
	n = floor((random()*10) % 2);
	
	PainSound();

	if (self.weaponstate == WEAPON_ACTIVATE 
		|| self.weaponstate == WEAPON_DEACTIVATE 
		|| self.weaponstate == WEAPON_USED || self.weaponstate == WEAPON_FLASHUSE)
		return;

	if (n == 0)
		player_axpain1 ();
	else if (n == 2)
		player_pain1 ();
	else
		player_painb1 ();
};

void() DeathBubblesSpawn =
{
local entity	bubble;
	if (self.owner.waterlevel != 3)
		return;
	bubble = spawn();
	setmodel (bubble, "progs/s_bubble.spr");
	setorigin (bubble, self.owner.origin + '0 0 24');
	bubble.movetype = MOVETYPE_NOCLIP;
	bubble.solid = SOLID_NOT;
	bubble.velocity = '0 0 15';
	bubble.nextthink = time + 0.5;
	bubble.think = bubble_bob;
	bubble.classname = "bubble";
	bubble.frame = 0;
	bubble.cnt = 0;
	setsize (bubble, '-8 -8 -8', '8 8 8');
	self.nextthink = time + 0.1;
	self.think = DeathBubblesSpawn;
	self.air_finished = self.air_finished + 1;
	if (self.air_finished >= self.bubble_count)
		remove(self);
};

void(float num_bubbles) DeathBubbles =
{
local entity	bubble_spawner;
	
	bubble_spawner = spawn();
	setorigin (bubble_spawner, self.origin);
	bubble_spawner.movetype = MOVETYPE_NONE;
	bubble_spawner.solid = SOLID_NOT;
	bubble_spawner.nextthink = time + 0.1;
	bubble_spawner.think = DeathBubblesSpawn;
	bubble_spawner.air_finished = 0;
	bubble_spawner.owner = self;
	bubble_spawner.bubble_count = num_bubbles;
	return;
};


void() DeathSound =
{
local float		rs;

	// water death sounds
	if (self.waterlevel == 3)
	{
		DeathBubbles(20);
		sound (self, CHAN_VOICE, "player/h2odeath.wav", 1, ATTN_NONE);
		return;
	}
	
	rs = rint ((random() * 4) + 1);
	if (rs == 1)
		self.noise = "player/death1.wav";
	if (rs == 2)
		self.noise = "player/death2.wav";
	if (rs == 3)
		self.noise = "player/death3.wav";
	if (rs == 4)
		self.noise = "player/death4.wav";
	if (rs == 5)
		self.noise = "player/death5.wav";

	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NONE);
	return;
};


void() PlayerDead =
{
	self.nextthink = -1;
// allow respawn after a certain time
	self.deadflag = DEAD_DEAD;
};

vector(float dm) VelocityForDamage =
{
	local  vector v;

	v_x = 100 * crandom();
	v_y = 100 * crandom();
	v_z = 200 + 100 * random();

	if (dm < 50)
	{
		v = v * 0.7;
	}
		v = v * 1.2;

	return v;
};

vector (vector vel) ClipGibVelocity =
{
	if (vel_x < -300)
		vel_x = -300;
	else if (vel_x > 300)
		vel_x = 300;
	if (vel_y < -300)
		vel_y = -300;
	else if (vel_y > 300)
		vel_y = 300;
	if (vel_z < 200)
        	vel_z = 200;    // always some upwards
    	else if (vel_z > 500)
        	vel_z = 500;

	return vel;
};

void(string gibname, float dm) ThrowHeadPlayer =
{
	setmodel (self, gibname);
	self.frame = 0;
	self.nextthink = -1;
	self.movetype = MOVETYPE_BOUNCE;
	self.takedamage = DAMAGE_NO;
	self.solid = SOLID_NOT;
	self.view_ofs = '0 0 8';
	setsize (self, '-16 -16 0', '16 16 56');
	self.velocity = self.velocity + VelocityForDamage (dm);
	self.velocity = ClipGibVelocity(self.velocity);
	self.origin_z = self.origin_z - 24;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	self.avelocity = crandom() * '0 600 0';
};

void() GibPlayer =
{	
	self.deadflag = DEAD_DEAD;
	ThrowHeadPlayer ("progs/h_player.mdl", self.health);
	ThrowGib ("progs/gib1.mdl", self.health);
	ThrowGib ("progs/gib2.mdl", self.health);
	ThrowGib ("progs/gib3.mdl", self.health);

	if (damage_attacker.classname == "teledeath")
	{
		sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	}

	if (damage_attacker.classname == "teledeath2")
	{
		sound (self, CHAN_VOICE, "player/teledth1.wav", 1, ATTN_NONE);
		return;
	}
		
	if (random() < 0.5)
		sound (self, CHAN_VOICE, "player/gib.wav", 1, ATTN_NONE);
	else
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NONE);
};

void() PlayerDie =
{
	local	float	i;

	player_run ();
	self.items = self.items - (self.items & IT_INVISIBILITY);
	self.invisible_finished = 0;	// don't die as eyes
	self.invincible_finished = 0;
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	self.oldweaponid = self.weaponid;
	self.weaponstate = WEAPON_DOWN;
	self.modelindex = modelindex_player;	// don't use eyes
	self.spawnmuzzleflash = 0;
	self.pos1 = 0;
	
//	if (self.pweaponmodel.model)
//		self.pweaponmodel.model = "";

	if (deathmatch || coop)
		DropBackpack();
	
	sound(self, CHAN_RELOAD, "misc/null.wav", 1, ATTN_NORM);
	sound(self, CHAN_WEAPON, "misc/null.wav", 1, ATTN_NORM);
//	self.weaponmodel="";
	self.view_ofs = '0 0 -8';
	self.deadflag = DEAD_DYING;
	self.solid = SOLID_NOT;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	self.movetype = MOVETYPE_TOSS;
	self.oldfov = 0;
	self.fov = 0;
	if (self.velocity_z < 10)
		self.velocity_z = self.velocity_z + random()*300;

	if (self.health < -40)
	{	
		//self.weaponstate = WEAPON_DOWN;
		GibPlayer ();
		return;
	}

	DeathSound();
	
	self.angles_x = 0;
	self.angles_z = 0;
	
	i = cvar("temp1");
	if (!i)
		i = 1 + floor(random()*3);
	
	if (i == 1)
		player_diea1();
	else if (i == 2)
		player_dieb1();
	else 
		player_diec1();

};

void() set_suicide_frame =
{	// used by klill command and diconnect command
	if (self.model != "progs/player.mdl")
		return;	// allready gibbed
	self.frame = 197;
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_TOSS;
	self.deadflag = DEAD_DEAD;
	self.nextthink = -1;
};


void()	player_diea1	=	[	178,	player_diea2	] {};
void()	player_diea2	=	[	179,	player_diea3	] {};
void()	player_diea3	=	[	180,	player_diea4	] {};
void()	player_diea4	=	[	181,	player_diea5	] {};
void()	player_diea5	=	[	182,	player_diea6	] {};
void()	player_diea6	=	[	183,	player_diea6	] {PlayerDead();};

void()	player_dieb1	=	[	184,	player_dieb2	] {};
void()	player_dieb2	=	[	185,	player_dieb3	] {};
void()	player_dieb3	=	[	186,	player_dieb4	] {};
void()	player_dieb4	=	[	187,	player_dieb5	] {};
void()	player_dieb5	=	[	188,	player_dieb6	] {};
void()	player_dieb6	=	[	189,	player_dieb6	] {PlayerDead();};

void()	player_diec1	=	[	190,	player_diec2	] {};
void()	player_diec2	=	[	191,	player_diec3	] {};
void()	player_diec3	=	[	192,	player_diec4	] {};
void()	player_diec4	=	[	193,	player_diec5	] {};
void()	player_diec5	=	[	194,	player_diec6	] {};
void()	player_diec6	=	[	195,	player_diec7	] {};
void()	player_diec7	=	[	196,	player_diec8	] {};
void()	player_diec8	=	[	197,	player_diec8	] {PlayerDead();};


