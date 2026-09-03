
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

void() player_passive;


float AS_RESTING = 0;
float AS_JUMPING = 1;
float AS_FIRING  = 2;
float AS_FALLING = 3;
float AS_LANDING = 4;
float AS_DEAD = 5;

void() player_Animate = 
{	
//	self.animation_state = AS_FIRING;

	if (self.animinfo.state == AS_DEAD)
		return;

	if (self.health <= 0)
		self.animinfo.state = AS_DEAD;

	if (self.animinfo.state == AS_LANDING)
	{
		if (self.animinfo.land_time < time)
			self.animinfo.state = AS_RESTING;
		else
		{
			self.frame = 5;
			return;
		}
	}

	if (self.animinfo.cooldown > time)
		return;

	self.animinfo.cooldown = time + 0.1;

	if (self.animinfo.state == AS_LANDING)
	{
		if (self.animinfo.land_time < time)
			self.animinfo.state = AS_RESTING;
		else
		{
			self.frame = 5;
			return;
		}
	}

	if (self.animinfo.state == AS_JUMPING)
	{
		if (self.animinfo.jump_time < time)
		{	
			if (self.flags & FL_ONGROUND)
			{
				self.animinfo.cooldown = 0;
				self.animinfo.state = AS_LANDING;
			}	

			else if (self.velocity_z < -200)
			{
				self.animinfo.cooldown = 0;
				self.animinfo.state = AS_FALLING;
			}	

			else
				self.animinfo.state = AS_RESTING;
		}
			
		else
		{
			self.frame = 3;
			return;
		}
	}

	if (self.animinfo.state == AS_FALLING)
	{	
		if ((self.flags & FL_ONGROUND))
		{	
			self.animinfo.cooldown = 0;
			self.animinfo.state = AS_LANDING;
			self.frame = 5;
			self.animinfo.land_time = time + 0.3;
		}	
		else
			self.frame = 4;

		return;
	}

	if (self.velocity_z < -200)
	{	
		self.animinfo.state = AS_FALLING;
		self.frame = 4;
		return;
	}

	if (self.velocity_z > 100)
	{	
		self.animinfo.state = AS_JUMPING;
		self.frame = 3;
		self.animinfo.jump_time = time + 0.3;
		return;
	}

	//self.baseframe = fr;

	if (self.velocity_z == 0)
	{
		if (fabs(self.velocity_x) > 20 || fabs(self.velocity_y) > 20)
			self.frame = 2;
		else
			self.frame = 1;
	}


	self.animinfo.state = AS_RESTING;
	//self.walkframe = 0;
}

void()	player_passive =[	self.frame,	player_passive	] {	self.spawnmuzzleflash = 0;};

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

//void()	player_deactivate1 = [	62,	player_passive] {};

void(entity attacker, float damage, float MOD) player_pain =
{			
	local float n;
	
	n = floor((random()*10) % 2);
	
	PainSound();
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
	self.frame = 1;
	self.nextthink = -1;
	self.movetype = MOVETYPE_BOUNCE;
	self.takedamage = DAMAGE_NO;
	self.solid = SOLID_NOT;
	self.view_ofs = '0 0 8';
	setsize (self, '-16 -16 0', '16 16 56');
	self.velocity = self.velocity + VelocityForDamage (dm);
	self.velocity = ClipGibVelocity(self.velocity);
	self.origin_z = self.origin_z + 24;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	self.avelocity = crandom() * '0 600 0';
};

void() GibPlayer =
{	
	self.deadflag = DEAD_DEAD;
	ThrowHeadPlayer ("progs/brain.mdl", self.health);

	ThrowGib ("progs/pork1.mdl", self.health);

	for(float i = 0; i < 2; i++)
		ThrowGib ("progs/pork2.mdl", self.health);

	for(float i = 0; i < 2; i++)
		ThrowGib ("progs/pork3.mdl", self.health);

	for(float i = 0; i < 2; i++)
		ThrowGib ("progs/pork4.mdl", self.health);

	ThrowGib ("progs/pork5.mdl", self.health);

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

void() weapon_items [8] = // because im stupid and didnt name the items like their weaponnames
{
	weapon_supershotgun,
	weapon_hyperblaster,
	weapon_grenadelauncher,
	weapon_nailgun2,
	weapon_rocketlauncher2,
	weapon_railgun,
	weapon_lightning,
	weapon_dmg
};

void() PlayerDie =
{
	player_passive ();
	self.powerups = self.powerups - (self.powerups & (IT_INVISIBILITY | IT_SUIT | IT_QUAD) );

	self.invisible_finished = 0;	// don't die as eyes
	self.invincible_finished = 0;
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	
	self.oldweaponid = self.weaponid;
	self.weaponstate = WEAPON_DOWN;
	self.armor_rottime = 0;
	self.megahealth_finished = 0;
	self.animinfo.land_time = 0;
	self.animinfo.jump_time = 0;
	//self.items = 0;
	
	self.spawnmuzzleflash = 0;
	self.pos1 = 0;

	if (self.flash_active)
		activate_flashlight ();

	self.flash_active = 0;

	if (deathmatch || coop)
	{	
		if (self.oldweaponid > 2)
			DropItem (weapon_items[self.oldweaponid - 3]);
	}	
	
	sound(self, CHAN_RELOAD, "misc/null.wav", 1, ATTN_NORM);
	sound(self, CHAN_WEAPON, "misc/null.wav", 1, ATTN_NORM);

	self.view_ofs = '0 0 16';
	self.deadflag = DEAD_DYING;
	self.solid = SOLID_NOT;
	self.flags = self.flags - (self.flags & FL_ONGROUND);
	self.movetype = MOVETYPE_TOSS;
	self.oldfov = 0;
	self.fov = 0;
	self.alpha = 1;

	if (self.health < -30)
	{
		GibPlayer ();
		return;
	}

	if (self.velocity_z < 10)
		self.velocity_z = self.velocity_z + random()*300;
	else
		self.velocity_z = self.velocity_z + random()*50;

	DeathSound();
	
	self.angles_x = 0;
	self.angles_z = 0;

	vector dir = self.dmg_inflictor.origin - self.origin;
	dir = normalize(dir);

	if (self.dmg_inflictor.owner == self)
	{	
	//	bprint("???", "\n");
		if (random() <= 0.5)
		{
			player_diea1 ();
			self.velocity += dir * -200;
		}	
		else
		{
			player_diec1 ();
			self.velocity += dir * 200;
		}
		self.flags &= ~FL_ONGROUND;
		return;
	}

	if (infront (self.dmg_inflictor))
	{
		player_diea1 ();
		self.velocity += dir * -200;
		self.flags &= ~FL_ONGROUND;
	}	
	else
	{
		if (random() <= 0.5)
			player_dieb1 ();
		else
			player_diec1 ();
		self.velocity += dir * 200;
		self.flags &= ~FL_ONGROUND;
	}
};

void() set_suicide_frame =
{	// used by klill command and diconnect command
	if (self.model != "progs/player/player.md5.info")
		return;	// allready gibbed
	self.frame = 1;
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_TOSS;
	self.deadflag = DEAD_DEAD;
	self.nextthink = -1;

	PlayerDie ();
};


void()	player_diea1	=	[	6,			player_diea2	] {};
void()	player_diea2	=	[	self.frame,	player_diea3	] {};
void()	player_diea3	=	[	self.frame,	player_diea4	] {};
void()	player_diea4	=	[	self.frame,	player_diea5	] {};
void()	player_diea5	=	[	self.frame,	player_diea6	] {};
void()	player_diea6	=	[	self.frame,	player_diea6	] {PlayerDead();};

void()	player_dieb1	=	[	7,			player_dieb2	] {};
void()	player_dieb2	=	[	self.frame,	player_dieb3	] {};
void()	player_dieb3	=	[	self.frame,	player_dieb4	] {};
void()	player_dieb4	=	[	self.frame,	player_dieb5	] {};
void()	player_dieb5	=	[	self.frame,	player_dieb6	] {};
void()	player_dieb6	=	[	self.frame,	player_dieb6	] {PlayerDead();};

void()	player_diec1	=	[	8,			player_diec2	] {};
void()	player_diec2	=	[	self.frame,	player_diec3	] {};
void()	player_diec3	=	[	self.frame,	player_diec4	] {};
void()	player_diec4	=	[	self.frame,	player_diec5	] {};
void()	player_diec5	=	[	self.frame,	player_diec6	] {};
void()	player_diec6	=	[	self.frame,	player_diec7	] {};
void()	player_diec7	=	[	self.frame,	player_diec8	] {};
void()	player_diec8	=	[	self.frame,	player_diec8	] {PlayerDead();};


