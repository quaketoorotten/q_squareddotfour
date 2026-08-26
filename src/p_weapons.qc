///============================

/* PLAYER WEAPONS SHIT!!!!

uhhhh

*/
///============================


//==============================================================================================

/*PLAYER WEAPON USE
*/
//==============================================================================================

void(string mdl, vector org, vector dir, vector vel) _casing =
{
	local entity casing;
	casing = spawn();

	setmodel(casing, mdl);
    setsize(casing, '0 0 0', '0 0 0');
    setorigin(casing, org);
	
	casing.movetype = MOVETYPE_BOUNCE;
   	casing.solid = SOLID_TRIGGER;

	//makevectors (self.v_angle);
	casing.velocity = vel;
	casing.angles = vectoangles(aim(self,10000));

	casing.nextthink =  time + 10 + random()*5;
	casing.think = SUB_Remove;
};

void(string mdl, vector org) _mag =
{
	local entity casing;
	casing = spawn();

	setmodel(casing, mdl);
    setsize(casing, '0 0 0', '0 0 0');
    setorigin(casing, org);
	
	casing.movetype = MOVETYPE_BOUNCE;
   	casing.solid = SOLID_TRIGGER;

	casing.velocity = '0 0 10';
	casing.scale = 0.8;	

	casing.nextthink =  time + 10 + random()*5;
	casing.think = SUB_Remove;
	casing.avelocity = '0 600 600';
};


float() AmmoLessCheck = 
{	
	return FALSE;
};

/*
================
W_FireShotgun
================
*/
float() ShotgunNoAmmo = 
{	
	if (self.savedammo_shells > 0)	
        return FALSE;

	if (self.ammo_shells > 0)
		return FALSE;

	return TRUE;
};

void() W_FireShotgun =
{
    local vector dir;
	local vector offset, start;

	local float dmg = 14, kick = 2;

	if (deathmatch)
	{
		dmg = 8; 
		kick = 4;
	}

	local float r = rint(random() * 4);	

	sound(self, CHAN_WEAPON, "sounds_q4/weapons/shotgun/fire.wav", 1, ATTN_NORM);

  	self.punchangle = setvector (-4, crandom() * 0.3, crandom() * 0.3);

	offset = setvector (0, 4, self.view_ofs[2] - 8);
	makevectors(self.v_angle);
	start = ProjectAim (self.origin, offset, v_forward, v_right);

    self.currentammo -= 1;
    dir = aim(self, 10000);
	
    FirePallets (SHOTGUN_PELLETS, start,  dir, SHOTGUN_HSPREAD, SHOTGUN_VSPREAD, dmg, kick, "d3fx.te_spike");

	if (self.powerups & IT_QUAD)
		sound(self, CHAN_FIVE, "items/damage3.wav", 1, ATTN_NORM);

   // FirePallets (SSHOTGUN_PELLETS / 2, start,  dir, SSHOTGUN_HSPREAD*1.3, SHOTGUN_VSPREAD, dmg, kick, TE_GUNSHOT);
};

/*
================
W_FireMachineGun
================
*/
float() MachineGunNoAmmo = 
{	
	if (self.savedammo_bullets > 0)	
          	return FALSE;

	if (self.ammo_bullets > 0)
		return FALSE;

	return TRUE;
};

void() W_FireMachineGun =
{
    local vector dir;
	local vector offset, start;

	local float dmg = 13, kick = 2;

	if (deathmatch)
	{
		dmg = 6; 
		kick = 0.5;
	}

   // AutofireMachineNoise ();

	local float r = (random() );

	if(r >= 0.5)
		sound(self, CHAN_WEAPON, "sounds_q4/weapons/machinegun/fire0.wav", 1, ATTN_NORM);
	else	
		sound(self, CHAN_WEAPON, "sounds_q4/weapons/machinegun/fire1.wav", 1, ATTN_NORM);

	self.punchangle = setvector (crandom() * 0.7, crandom() * 0.7, crandom() * 0.7);

	offset = self.view_ofs;
	if (!self.button4)
		offset = setvector (0, 4, self.view_ofs[2] - 8);

	makevectors(self.v_angle);
	start = ProjectAim (self.origin, offset, v_forward, v_right);

    self.currentammo -= 1;
    dir = aim(self, 10000);

	float mod;
	if (self.button4)
		mod = 0.5;
	else	
		mod = 1;

    FireBullet (start,  dir, MACHINEGUN_HSPREAD * mod, MACHINEGUN_VSPREAD * mod, dmg, kick, "d3fx.te_spike");

	if (self.powerups & IT_QUAD)
		sound(self, CHAN_FIVE, "items/damage3.wav", 1, ATTN_NORM);

//	offset = setvector (12, 0, self.view_ofs[1] + 18);
//	makevectors(self.v_angle);

//	_casing ("progs/shell.mdl", ProjectAim (self.origin, offset, v_forward, v_right), aim(self, 10000), self.velocity + v_right*-75 + v_up*(25 + random()*50));
};

/*
================
W_FireNailGun
================
*/
float() NailGunNoAmmo = 
{	
	if (self.savedammo_nails > 0)	
		return FALSE;

	if (self.ammo_nails > 0)
		return FALSE;

	return TRUE;
};

static void(vector start, vector dir, float hspread, float vspread, float damage, float kick) _fireNails =
{
    local vector direction;
    local vector src;
	float spd;

	float up = crandom() * vspread
		, right = crandom() * hspread;

	makevectors(self.v_angle);
	
    src = start + v_forward*16;
	src_z = self.absmin_z + self.size_z * 0.7;
 
	if (!self.locked_enemy || self.locked_enemy.health <= 0)
	{
		spd = 1000;
		direction = dir + right*v_right + up*v_up;
	}
	else
	{	
		direction = dir;
		spd = 700;
	}

	Strogg_nail (src, direction, damage, kick, spd); 
};

void() W_FireNailGun =
{	
    local vector dir;
	local vector offset, start;

	local float dmg = 25, kick = 8;

	if (self.currentammo < 1)
		return;

	if (deathmatch)
	{
		dmg = 4; 
		kick = 16;
	}

	self.punchangle = setvector (crandom() * 0.8, crandom() * 0.8, crandom() * 0.8);

	makevectors(self.v_angle);
	
	offset = self.view_ofs;
	if (!self.button4)
		offset = setvector (0, 6, self.view_ofs[2] - 4);

	start = ProjectAim (self.origin, offset, v_forward, v_right);

    self.currentammo -= 1;
    dir = aim(self, 10000);
	
	self.effects = self.effects | EF_MUZZLEFLASH;
	
	_fireNails (start, dir, CHAINGUN_HSPREAD, CHAINGUN_VSPREAD, dmg, kick);

	local float r = rint(random() * 2);

	if(r == 2)
		sound(self, CHAN_WEAPON, "sounds_q4/weapons/nailgun/fire_03.wav", 1, ATTN_NORM);
	else	if(r == 1)
		sound(self, CHAN_WEAPON, "sounds_q4/weapons/nailgun/fire_02.wav", 1, ATTN_NORM);
	else
		sound(self, CHAN_WEAPON, "sounds_q4/weapons/nailgun/fire_01.wav", 1, ATTN_NORM);

	if (self.powerups & IT_QUAD)
		sound(self, CHAN_FIVE, "items/damage3.wav", 1, ATTN_NORM);

	CheckDodge (start, aim(self,1000), 2000);
};

//=============================================================================

void() rocketimpact =
{
	pointparticles (particleeffectnum("TE_ROCKETIMPAC"), self.origin);
	pointparticles (particleeffectnum("TE_ROCKETIMPAC2"), self.origin);
}

void() T_MissileTouch =
{
    local float damg;

    if (other == self.owner)
    {
        return; // don't explode on owner
    }

    if (pointcontents(self.origin) == CONTENT_SKY)
    {
        remove(self);
        return;
    }

    damg = 150 + random()*50;
//	bprint(ftos(damg), "\n");
	
	rocketimpact  ();
	
	T_RadiusDamage(self, self.owner, 150, 180, other);
	
    self.origin = self.origin - 32* normalize(self.velocity);

    if (other.takedamage)
    {
        T_Damage(other, self, self.origin, self.owner, damg, 50);

		if (other.classname != "gib")
		{
			for(float i = 0; i<6;i++)
				SpawnBlood (other, self.origin, '0 0 0', 20);
		}
    }
	
	self.classname = "grenade";
    //sound(self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM)
    BecomeExplosion();
};


/*
================
W_FireRocket
================
*/

void() rocketThink = 
{	
	if (time > self.ltime)
		remove(self);

	makevectors(self.angles);
	particle (self.origin + normalize(v_forward * -20), '0 0 -24', 234, 2);
	self.think = rocketThink;
	self.nextthink = time + 0.01;
};



void() W_FireRocket =
{
    local entity missile;
	local vector offset, start;

    self.currentammo -= 1;
	self.savedammo_rockets = self.currentammo;

   	RocketNoise ();

    self.punchangle = setvector (crandom() * 1.2, crandom() * 1.2, crandom() * 1.2);

    missile = spawn();
    missile.owner = self;
    missile.movetype = MOVETYPE_FLY;
    missile.solid = SOLID_BBOX;
    missile.classname = "missile";
	missile.shake_interval = 0.5;
	missile.shake_time = 1;

    // set missile speed

//	offset = self.view_ofs;
//	if (!self.button4)
   		offset = setvector (0, 8, self.view_ofs[1] + 16);
	
	makevectors(self.v_angle);
	start = ProjectAim (self.origin, offset, v_forward, v_right);

    missile.velocity = aim(self, 1000);
    missile.velocity = missile.velocity * 900;
    missile.angles = vectoangles(missile.velocity);

    missile.touch = T_MissileTouch;
	missile.traileffectnum = particleeffectnum ("EF_ROCKETTRAIL");

    // set missile duration
    // missile.ltime = time + 5;
    missile.think = G_RocketFollowLaser;
    missile.nextthink = time;
	missile.dspeed = time;

    setmodel(missile, "progs/weapons/missile.md3");
	missile.scale = 1.3;
    setsize(missile, '0 0 0', '0 0 0');
    setorigin(missile, start );
	CheckDodge(start, aim(self, 10000), 1000);

	if (self.powerups & IT_QUAD)
		sound(self, CHAN_FIVE, "items/damage3.wav", 1, ATTN_NORM);

	// sound(missile, CHAN_BODY, "weapons/rockfly.wav", 1, ATTN_IDLE);
};

void() G_RocketFollowLaser = // quake life code, thx serecky, chu chu~
{
	entity ent = world;
	vector dir, mytarget;
	float dist, max, dot;

	vector myangles = self.angles;
	myangles_x = -myangles_x;

	makevectors(myangles);

	mytarget = v_forward;
	max = 4096;
	
	ent = find(ent, classname, "laser_spot");
		
	while (ent)
	{
		traceline(self.origin, ent.origin, 0, self);
		if (trace_fraction >= 0.90)
		{
			dir = ent.origin - self.origin;
			dist = vlen(dir);
			dir = normalize(dir);
			dot = dotproduct(v_forward, dir);
			if ((dot > 0) && (dist * (1 - dot) < max))
			{
				max = dist * (1 - dot);
				mytarget = dir;
			}
		}
		ent = ent.chain;
	}
	
	self.angles = vectoangles(mytarget);
	
	float speed = vlen(self.velocity);
	if ((time - self.dspeed) < 1.0)
	{
		self.velocity = self.velocity * 0.2 + mytarget * (speed * 0.8 + 400);
		if (self.waterlevel == 3)
		{
			if (vlen(self.velocity) > 300)
			{
				self.velocity = normalize(self.velocity) * 300;
			}
		}
		else
		{
			if (vlen(self.velocity) > 900)
			{
				self.velocity = normalize(self.velocity) * 900;
			}
		}
	}
	else
	{
		self.velocity = self.velocity * 0.2 + mytarget * speed * 0.798;
	}
	
	self.nextthink = time;
};

entity() G_CreateLaser =
{
	entity spot;
	spot = spawn();
	spot.classname = "laser_spot";
	spot.movetype = MOVETYPE_NONE;
	spot.movetype = SOLID_NOT;
	setmodel(spot, "progs/muzzleflash.spr");
	spot.scale = 0.01;
	setsize(spot, VEC_ORIGIN, VEC_ORIGIN);
	setorigin(spot, spot.origin);
	return spot;
}

void(entity spot, float next_revive) G_SuspendLaser =
{
	setmodel(spot, "");
	spot.think = G_LaserRevive;
	spot.nextthink = time + next_revive;
}

void() G_LaserRevive =
{
	setmodel(self, "progs/muzzleflash.spr");
	self.think = SUB_Null;
}

void() G_UpdateSpot =
{
	if (!self.locked_enemy || self.locked_enemy == world)
	{
		self.locked_enemy = G_CreateLaser();
	}
		
	makevectors(self.v_angle);
		
	vector src = self.origin + self.view_ofs;
	vector dir = v_forward;
		
	traceline(src, src + dir * 8192, 0, self);
	setorigin(self.locked_enemy, trace_endpos);
		
		//sprint(self, vtos(self.ent1.origin));
		//sprint(self, "\n");
}

//=============================================================================

void() GrenadeExplode =
{
    T_RadiusDamage(self, self.owner, 200, 250, world);
	
	rocketimpact  ();
	
	self.origin_z += 16;
    BecomeExplosionPlayer();
};

void() GrenadeTouch =
{	
	if (other.classname == "shield_bbox")
		return;
	
    if (other == self.owner)
    {
        return; // don't explode on owner
    }

    if (other.takedamage)
    {
        T_RadiusDamage(self, self.owner, 200, 250, other);
		T_Damage(other, self, self.origin, self.owner, 125, 200);
		rocketimpact  ();
	
		self.origin_z += 16;
   		BecomeExplosionPlayer();
        return;
    }

    sound(self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM); // bounce sound

    if (self.velocity == '0 0 0')
    {
        self.avelocity = '0 0 0';
    }

	local vector	normal_angles, end, plane;
	local float 	time_left = time;

	if (other.solid != SOLID_BSP)
		return;
	
	end = self.origin + time_left*self.velocity;
	traceline(self.origin, end, FALSE, self); // guessing how q2 returns *cplane_t plane

	if (trace_plane_normal)
	{	
		plane = trace_plane_normal;

		normal_angles = vectoangles (plane);
		makevectors (normal_angles);
		self.angles = vectoangles (v_right);
	}
};


/*
================
W_FireGrenade
================
*/
void() W_FireGrenade =
{
    local entity missile;
	local vector start, offset;

//    sound(self, CHAN_WEAPON, "weapons/grenlf1a.wav", 1, ATTN_NORM);

    self.punchangle_x = -2;

    missile = spawn();
    missile.owner = self;
    missile.movetype = MOVETYPE_BOUNCE;
    missile.solid = SOLID_BBOX;
    missile.classname = "grenade";	
	missile.shake_interval = 0.4;
	missile.scale = 1.5;
	missile.shake_time = 1;
	missile.traileffectnum = particleeffectnum ("EF_NADETRAIL");

    // set missile speed
    offset = setvector (0, 8, self.view_ofs[1] + 8);
	makevectors(self.v_angle);
	start = ProjectAim (self.origin, offset, v_forward, v_right);
	

	local vector dir = aim(self,10000);
	makevectors (dir);

	missile.velocity = dir * 600;
	missile.velocity += (200 + crandom() * 10)* v_up;
	missile.velocity += (crandom() * 10) * v_right; 

    missile.avelocity = '300 300 300';

    missile.angles = vectoangles(missile.velocity);

    missile.touch = GrenadeTouch;

    // set missile duration
    missile.nextthink = time + 2.5;
    missile.think = GrenadeExplode;
	//missile.dmg = 120;

    setmodel(missile, "progs/weapons/grenadelauncher/grenade.md3");
    setsize(missile, '0 0 0', '0 0 0');
    setorigin(missile, start);

	makevectors(self.v_angle);
	CheckDodge(start, v_forward, 600);

	if (self.powerups & IT_QUAD)
		sound(self, CHAN_FIVE, "items/damage3.wav", 1, ATTN_NORM);
};

float() RocketLauncherNoAmmo = 
{	
	if (self.savedammo_rockets > 0)	
        return FALSE;
	if (self.ammo_rockets > 0)
		return FALSE;
		
	return TRUE;
};

float() GrenadeLauncherNoAmmo = 
{	
	if (self.savedammo_grenades > 0)	
        return FALSE;
	if (self.ammo_grenades > 0)
		return FALSE;

	return TRUE;
};
//=============================================================================

float() PlasmaNoAmmo = 
{	
	if (self.savedammo_cells > 0)	
        return FALSE;

	if (self.ammo_cells > 0)
		return FALSE;

	return TRUE;
};

/*
================
W_FireHyper
================
*/

void() W_FireHyper = 
{
	local vector dir, offset, start;

	offset = setvector(0, 8, self.view_ofs[1] + 12);

	makevectors(self.v_angle);
	start = ProjectAim (self.origin, offset, v_forward, v_right);
	
	self.effects = self.effects | EF_MUZZLEFLASH;

	self.punchangle = setvector (crandom() * 0.7, crandom() * 0.7, crandom() * 0.7);
	
	dir = aim(self,10000);

	if (self.weaponname != "weapon_blaster")
	{
		self.currentammo -= 1;
		self.savedammo_cells = self.currentammo;
	}


	//local float r = rint(random() * 2);
	
	if (self.weaponname == "weapon_blaster")
	{
		if (random() <= 0.5)
			sound(self, CHAN_WEAPON, "sounds_q4/weapons/blaster/fire01.wav", 1, ATTN_NORM);
		else
			sound(self, CHAN_WEAPON, "sounds_q4/weapons/blaster/fire02.wav", 1, ATTN_NORM);
	}
	else
	{
		if (random() <= 0.5)
			sound(self, CHAN_WEAPON, "sounds_q4/weapons/hyperblaster/fire1.wav", 1, ATTN_NORM);
		else
			sound(self, CHAN_WEAPON, "sounds_q4/weapons/hyperblaster/fire2.wav", 1, ATTN_NORM);
	}

	if (self.powerups & IT_QUAD)
		sound(self, CHAN_FIVE, "items/damage3.wav", 1, ATTN_NORM);

	makevectors(self.v_angle);
	LaunchLaser (start, dir, v_right * (crandom() * 15), v_up * (crandom() * 15));

//	if (self.flags & FL_CLIENT)

	if (self.weaponname == "weapon_blaster")
		CheckDodge(start, dir, 9999);
	else
		CheckDodge(start, dir, 500);
};

/*
================
W_FireDisint
================
*/

void() W_FireDisint = 
{
	local vector dir, offset, start;

	offset = setvector(24, 8, self.view_ofs[1] + 14);

	makevectors(self.v_angle);
	start = ProjectAim (self.origin, offset, v_forward, v_right);
	dir = aim(self,10000);

	self.punchangle = setvector (crandom() * 0.9, crandom() * 0.4, crandom() * 0.2);
	
	if (self.powerups & IT_QUAD)
		sound(self, CHAN_FIVE, "items/damage3.wav", 1, ATTN_NORM);

	launch_blackhole(dir, start, 45);
//	self.currentammo = self.ammo_cells = self.ammo_cells - 15;

//	if (self.flags & FL_CLIENT)
	//	CheckDodge(start, dir, 100);
};

float() LGNoAmmo = 
{	
	if (self.ammo_coils > 1)
		return FALSE;

	return TRUE;
};

/*
================
W_FireLightning
================
*/

void() W_FireLightning = 
{
	local vector dir, offset, start;
	local float cells;

	if (self.waterlevel > 1)
	{
		cells = self.ammo_cells;
		self.ammo_cells = 0;
		self.weaponstate = WEAPON_DEACTIVATE;

	//	self.weaponframe = ;
		T_RadiusDamage (self, self, 50*cells, 50*cells , world);
		W_SetCurrentAmmo (FALSE);
	//	sound (self, CHAN_WEAPON, "weapons/bfg__x1b.wav", 1, ATTN_NORM);
		return;
	}
	
	self.currentammo = self.ammo_coils = self.ammo_coils - 1;
	
	if (self.t_width < time)
	{	
		sound (self, CHAN_WEAPON, "sounds_q4/weapons/lightninggun/loop.wav", 1, ATTN_NORM);
		self.t_width = time + 1;

		if (self.powerups & IT_QUAD)
			sound(self, CHAN_FIVE, "items/damage3.wav", 1, ATTN_NORM);
	}
	
	makevectors(self.v_angle);
	offset = setvector(0, 8, self.view_ofs[1] + 12);
	start = ProjectAim (self.origin, offset, v_forward, v_right);
	dir = aim(self,10000);

	self.punchangle = setvector (crandom() * 0.2, crandom() * 0.2, crandom() * 0.2);
	
	self.effects = self.effects | EF_MUZZLEFLASH;
	fireLightning(start, dir, self, 11, 5, 600);
	
};

float() RailgunNoAmmo = 
{	
	if (self.ammo_slugs > 1)
		return FALSE;

	if (self.savedammo_slugs > 1)
		return FALSE;

	return TRUE;
};

/*
================
W_FireRail
================
*/

void() W_FireRail = 
{
	local vector dir, offset, start;

	offset = setvector(0, 6, self.view_ofs[1] + 16);

	makevectors(self.v_angle);
	start = ProjectAim (self.origin, offset, v_forward, v_right);
	
	self.effects = self.effects | EF_MUZZLEFLASH;

	self.punchangle = setvector (crandom() * 0.7, crandom() * 0.7, crandom() * 1.2);
	
	dir = aim(self,10000);

	self.currentammo -= 1;
//	self.savedammo_cells = self.currentammo;

	local float r = rint(random() * 2);
	
	if (r == 2)
		sound(self, CHAN_WEAPON, "sounds_q4/weapons/railgun/fire01.wav", 1, ATTN_NORM);
	else if (r == 1)
		sound(self, CHAN_WEAPON, "sounds_q4/weapons/railgun/fire02.wav", 1, ATTN_NORM);
	else
		sound(self, CHAN_WEAPON, "sounds_q4/weapons/railgun/fire03.wav", 1, ATTN_NORM);

	if (self.powerups & IT_QUAD)
		sound(self, CHAN_FIVE, "items/damage3.wav", 1, ATTN_NORM);
	
//	makevectors(self.v_angle);
	self.solid = SOLID_BBOX;
	fireRail (start, dir, self, self, 175, 50, 8192);
	self.solid = SOLID_SLIDEBOX;

//	vector end = start + dir * 8192;
};

/*
================
W_FireAxe
================
*/

void(void() sfx1, void() sfx2) W_FireAxe =
{
	local	vector	source;
	local	vector	org;
	local float		spew = 15;
	local float		dmg = 25, kick = 5, crit = FALSE;
	// string punchnoise = ;
	
	makevectors (self.v_angle);
	source = self.origin + '0 0 16';
	local vector vel, dir;
	float dist = 48;

	if (self.powerups & IT_QUAD)
		dist = 64;

	dir = source + v_forward*dist;
	traceline (source, dir, 0, self);

	if (trace_fraction == 1.0)
		return;
	
	org = trace_endpos;

	vel = normalize(dir + v_up*crandom() + v_right*crandom());
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;

	if (trace_ent.takedamage)
	{
		trace_ent.axhitme = 1;

		SpawnBlood (trace_ent, org, vel, kick);

		T_Damage (trace_ent, self, trace_endpos, self, dmg , kick);
		sfx1 ();
	}
	else
	{	// hit wall
		sfx2 ();
		//stuffcmd (self, "vibrate tactile/player/axhit2.bnvib");

	}
};

//==============================================================================================

/*PLAYER WEAPON FIRES
*/
//==============================================================================================

/*
============
Fists
============
*/

void() W_WeaponFistNoise = 
{	
	if (self.weaponframe == 0)
		sound(self, CHAN_RELOAD, "sounds_q4/weapons/switch.wav", 1, ATTN_NORM);

	if (self.weaponframe == 4)
		sound(self, CHAN_WEAPON, "sounds_q4/weapons/blaster/ready.wav", 1, ATTN_NORM);
};

void() player_blasteridle = 
{	
	//self.baseframe = 1;
	player_run ();
	self.weaponframe = 40;
	self.weaponstate = WEAPON_IDLE;
	self.spawnmuzzleflash = 0;
	return;
};

void() player_blasterfire = 
{
	switch(self.weaponframe)
	{
		case 22:
		case 32:
		self.solid = SOLID_BBOX;
		W_FireHyper();
		self.spawnmuzzleflash = 1;
		self.solid = SOLID_SLIDEBOX;
		break;
		case 24:
		self.spawnmuzzleflash = 0;
		break;
		case 34:
		self.spawnmuzzleflash = 0;
		break;

		default:
		break;
	}

	return;
};

void() player_blaster2 = [self.frame, player_blaster2]
{	
//	self.frame++;

	//if (self.baseframe == 1)
	//	self.baseframe = 4;

	self.weaponstate = WEAPON_USED; 
	SUB_AnimateWeapon (31, 39, player_blasteridle , 0.03, player_blasterfire);
	player_run_unforced (1);
};
void() player_blaster1 = [self.frame, player_blaster1]
{	
    // if (self.baseframe == 1)
    //	self.baseframe = 4;

	self.weaponstate = WEAPON_USED; 
	SUB_AnimateWeapon (21, 30, player_blasteridle , 0.03, player_blasterfire);
	player_run_unforced (1);
};

void() player_blast = 
{	
	if (self.weaponstate == WEAPON_USED) 
		return;

	local float r = rint(random());
//	self.baseframe = 0;

	CheckDodge2 (self.origin + self.view_ofs, aim(self,10000));
//	self.baseframe = 4;
	switch(r)
	{
		case 1:
		player_blaster2 ();
		break;

		default:
		player_blaster1 ();
		break;
	}
};

void() player_blaster_light = [self.frame, player_blaster_light ]
{	
	self.weaponstate = WEAPON_FLASHUSE;

	if (self.weaponframe != 103 && self.weaponframe < 103)
		self.weaponframe = 103;	 

	if (self.weaponframe >= 124 )
	{	
		self.spawnmuzzleflash = 0;
		player_run ();
		self.weaponstate = WEAPON_IDLE;
		self.weaponframe = 40;
		return;
	}

	if (self.weaponframe == 118)
	{	
		sound(self, CHAN_RELOAD, "sounds_q4/weapons/blaster/light_off.wav", 1, ATTN_NORM);
		activate_flashlight ();

		if (!self.flash_active)
			self.flash_active = 1;
		else
			self.flash_active = 0;
    }

/*	if (self.weaponframe == 33)
	{	
		offset = setvector (24, 4, self.view_ofs[1] + 16);
		makevectors(self.v_angle);

		_casing ("progs/shell2.mdl", ProjectAim (self.origin, offset, v_forward, v_right), aim(self, 10000),self.velocity + v_right*-75 + v_up*(25 + random()*25));
	}*/

	self.weaponframe++;

	self.nextthink = time + 0.04;

//	self.baseframe = 5;
//	player_run_unforced ();
};

float() get_noammo = {return 0;};
void(float a) save_noammo = {return 0;};

weapon_info_frames wf_blaster = {20, '40 99 0', '100 102 0'};
weapon_info_generic w_blaster = { "progs/weapons/blaster/view.md3", "", AmmoLessCheck, "weapon_blaster", '0 0 0'};
weapon_info_ammo a_blaster = {SUB_Assign_NoAmmo, get_noammo ,save_noammo};
weapon_info_func func_blaster = {player_blast, W_WeaponFistNoise  };

/*
============
Pistol
============
*/

void() W_WeaponMachinegunNoise =
{	
	//local float r = rint(random() * 2);

	if (self.weaponframe == 0)
		sound(self, CHAN_RELOAD, "sounds_q4/weapons/switch.wav", 1, ATTN_NORM);

	if (self.weaponframe == 7 || self.weaponframe == 96)
		sound(self, CHAN_WEAPON, "sounds_q4/weapons/machinegun/bolt.wav", 1, ATTN_NORM);

	if (self.weaponframe == 76)
		sound(self, CHAN_RELOAD, "sounds_q4/weapons/machinegun/clipout.wav", 1, ATTN_NORM);

	if (self.weaponframe == 88)
		sound(self, CHAN_RELOAD, "sounds_q4/weapons/machinegun/clipin.wav", 1, ATTN_NORM);
};

void() player_machinegun = [self.frame, player_machinegun ]
{	
	self.weaponstate = WEAPON_USED;

	if (!self.button0 || self.currentammo < 1)
	{	
		self.spawnmuzzleflash = 0;
		if ((self.weaponframe <= 21))
		{	
			self.weaponframe ++; 
			self.nextthink = time + 0.04;
			return;
		}
		else
		{	
			self.spawnmuzzleflash = 0;
			self.weaponstate = WEAPON_IDLE;
		//	self.baseframe = 1;
			player_run ();
			self.weaponframe = 22;
			return;
		}
	}

	if (self.button0 && self.weaponframe > 21)
		self.weaponframe = 18;

	if (self.weaponframe != 18 && self.weaponframe > 21)
	{
		self.weaponframe = 18;
	//	self.baseframe = 5;
	}

	if (self.weaponframe == 18)
	{	
		CheckDodge2 (self.origin + self.view_ofs, aim(self,10000));
		self.solid = SOLID_BBOX;
     	W_FireMachineGun();
		self.spawnmuzzleflash = 1;
		sound(self, CHAN_RELOAD, "sounds_q4/weapons/machinegun/bolt.wav", 1, ATTN_NORM);
		self.savedammo_bullets = self.currentammo;
		self.effects = self.effects | EF_MUZZLEFLASH;
		self.solid = SOLID_SLIDEBOX;
    }
	else
		self.spawnmuzzleflash = 2;

	self.weaponframe++;

	if (!self.button0)
		self.nextthink = time + 0.04;
	else
		self.nextthink = time + 0.024;

//	self.baseframe = 5;
//	player_run_unforced ();
};

void() player_machinegun_light = [self.frame, player_machinegun_light ]
{	
	self.weaponstate = WEAPON_FLASHUSE;

	if (self.weaponframe != 112 && self.weaponframe < 112)
		self.weaponframe = 112;	 

	if (self.weaponframe >= 125 )
	{	
		self.spawnmuzzleflash = 0;
		player_run ();
		self.weaponstate = WEAPON_IDLE;
		self.weaponframe = 22;
		return;
	}

	if (self.weaponframe == 121)
	{	
		sound(self, CHAN_RELOAD, "sounds_q4/weapons/blaster/light_off.wav", 1, ATTN_NORM);
		activate_flashlight ();
		
		if (!self.flash_active)
			self.flash_active = 1;
		else
			self.flash_active = 0;
    }

/*	if (self.weaponframe == 33)
	{	
		offset = setvector (24, 4, self.view_ofs[1] + 16);
		makevectors(self.v_angle);

		_casing ("progs/shell2.mdl", ProjectAim (self.origin, offset, v_forward, v_right), aim(self, 10000),self.velocity + v_right*-75 + v_up*(25 + random()*25));
	}*/

	self.weaponframe++;

	self.nextthink = time + 0.04;

//	self.baseframe = 5;
//	player_run_unforced ();
};

weapon_info_frames wf_machinegun = {17, '22 69 0', '109 111 0'}; // nice
weapon_info_generic w_machinegun = { "progs/weapons/machinegun/view.md3", "progs/male/w_shotgun.mdl", MachineGunNoAmmo, "weapon_machinegun", '-2.8 0.8 -0.6'};
weapon_info_ammo a_machinegun = {SUB_Assign_Saved_Bullets, get_bullets, save_bammo};
weapon_info_func func_machinegun = {player_machinegun,  W_WeaponMachinegunNoise };
weapon_info_frames2 wf2_machinegun = {'70 108 88', '70 108 0'};
weapon_info_mag mag_machinegun = {MG_AMMO_CAP, MG_AMMO_CAP};

/*
============
Shotgun
============
*/
void() W_WeaponShotgunNoise =
{	

//	local float r = rint(random() * 2);

	if (self.weaponframe == 0)
		sound(self, CHAN_RELOAD, "sounds_q4/weapons/switch.wav", 1, ATTN_NORM);

	if (self.weaponframe == 5 || self.weaponframe == 27 || self.weaponframe == 143)
	{
	//	if (random() <= 0.5)
			sound(self, CHAN_RELOAD, "sounds_q4/weapons/shotgun/pump1.wav", 1, ATTN_NORM);
	//	else 
	//		sound(self, CHAN_RELOAD, "sounds_q4/weapons/shotgun/pump2.wav", 1, ATTN_NORM);
	}

	if (self.weaponframe == 30 || self.weaponframe == 10 || self.weaponframe == 146)
	{
	//	if (random() <= 0.5)
	//		sound(self, CHAN_RELOAD, "sounds_q4/weapons/shotgun/pump1.wav", 1, ATTN_NORM);
	//	else 
			sound(self, CHAN_RELOAD, "sounds_q4/weapons/shotgun/pump2.wav", 1, ATTN_NORM);
	}


	if (self.weaponframe == 119)
	{
		sound(self, CHAN_RELOAD, "sounds_q4/weapons/shotgun/clip_out.wav", 1, ATTN_NORM);
	}

	if (self.weaponframe == 130)
	{
		
		sound(self, CHAN_RELOAD, "sounds_q4/weapons/shotgun/clip_in.wav", 1, ATTN_NORM);
	}
};

void() player_shotg = [self.frame, player_shotg]
{
	self.weaponstate = WEAPON_USED;
 
	if (self.weaponframe != 15 && self.weaponframe > 36)
		self.weaponframe = 15;	 

	if (self.weaponframe >= 36 )
	{	
		self.spawnmuzzleflash = 0;
		player_run ();
		self.weaponstate = WEAPON_IDLE;
		self.weaponframe = 37;
		return;
	}

	if (self.weaponframe == 15)
	{	
		CheckDodge2 (self.origin + self.view_ofs, aim(self,10000));
		self.solid = SOLID_BBOX;
     	W_FireShotgun();
		self.savedammo_shells = self.currentammo;
		self.spawnmuzzleflash = 1;
		self.effects = self.effects | EF_MUZZLEFLASH;
		self.solid = SOLID_SLIDEBOX;
    }

	if (self.weaponframe > 17)
		self.spawnmuzzleflash = 2;

	if (self.weaponframe > 30)
		self.spawnmuzzleflash = 0;

/*	if (self.weaponframe == 33)
	{	
		offset = setvector (24, 4, self.view_ofs[1] + 16);
		makevectors(self.v_angle);

		_casing ("progs/shell2.mdl", ProjectAim (self.origin, offset, v_forward, v_right), aim(self, 10000),self.velocity + v_right*-75 + v_up*(25 + random()*25));
	}*/

	self.weaponframe++;

	self.nextthink = time + 0.038;

	 W_WeaponShotgunNoise ();
};

weapon_info_frames wf_shotgun = {14, '37 107 0', '153 156 0'};
weapon_info_generic w_shotgun = {"progs/weapons/shotgun/view.md3", "progs/male/w_sshotgun.mdl", ShotgunNoAmmo, "weapon_shotgun", '-0.8 1.3 0.6'};
weapon_info_ammo a_shotgun = {SUB_Assign_Saved_Shells, getshells, save_sammo};
weapon_info_func func_shotgun = {player_shotg,  W_WeaponShotgunNoise};
weapon_info_frames2 wf2_shotgun = {'108 152 131', '108 152 0'};
weapon_info_mag mag_shotgun = {SG_AMMO_CAP, SG_AMMO_CAP};

/*
============
Hyperblaster
============
*/

void() W_WeapoHyperblasternNoise =
{
	if (self.weaponframe == 78)
		sound(self, CHAN_RELOAD, "sounds_q4/weapons/hyperblaster/cell_out.wav", 1, ATTN_NORM);
	
	if (self.weaponframe == 97)
		sound(self, CHAN_RELOAD, "sounds_q4/weapons/hyperblaster/cell_in.wav", 1, ATTN_NORM);

	if (self.weaponframe == 112)
		sound(self, CHAN_RELOAD, "sounds_q4/weapons/hyperblaster/close.wav", 1, ATTN_NORM);

	if (self.weaponframe == 0)
		sound(self, CHAN_RELOAD, "sounds_q4/weapons/switch.wav", 1, ATTN_NORM);
};

.float firerate;
.float animatereverse;

void() player_hyperb = [self.frame, player_hyperb]
{	
	self.weaponstate = WEAPON_USED;
	//float oldpos = -1.5;

	if (!self.button0 || self.currentammo < 1)
	{	
		self.spawnmuzzleflash = 0;
		//self.firerate = 0;
		if (self.animatereverse)
		{
			self.weaponframe = 9;
			self.animatereverse = FALSE;
		}

		if ((self.weaponframe <= 25))
		{	
			if (self.weaponmodelpos_x < -2.2)
				self.weaponmodelpos_x += 0.05;

			if (self.weaponmodelpos_z < 1)
				self.weaponmodelpos_z += 0.05;
			
			if (time > self.pissed)
			{	
				sound(self, CHAN_RELOAD, "sounds_q4/weapons/hyperblaster/spin_down.wav", 1, ATTN_NORM);
				self.pissed = time + 1;
			}
			
			self.weaponframe ++; 
			self.nextthink = time + 0.04;
			return;
		}
		else
		{	
			self.animatereverse = FALSE;
			self.weaponmodelpos_x = -2.2;
			self.weaponmodelpos_z = 1;
			self.weaponstate = WEAPON_IDLE;
			player_run ();
			self.weaponframe = 26;
			self.firerate = 0;
			self.pissed = 0;
			return;
		}
	}

	if (self.weaponframe != 9 && self.weaponframe > 25)
	{	
		self.weaponframe = 9;
		sound(self, CHAN_RELOAD, "sounds_q4/weapons/hyperblaster/spin_up.wav", 1, ATTN_NORM);
		self.pissed = 0;
		self.firerate = 0;
		CheckDodge2 (self.origin + self.view_ofs, aim(self,10000));
	}
	
	if (self.weaponframe > 24 && self.button0)
		self.weaponframe = 10;

	if (self.weaponframe >= 24)
		self.animatereverse = TRUE;
	
	//bprint(ftos(self.firerate), "\n");
	if (self.button0 && self.weaponframe > 9 && self.weaponframe < 25)
	{	
		if (time > self.firerate)
		{	
			self.spawnmuzzleflash = 1;
			W_FireHyper ();
			CheckDodge2 (self.origin + self.view_ofs, aim(self,10000));
			self.firerate = time + 0.054;
			self.weaponmodelpos_z -= 0.01;
			self.weaponmodelpos_x -= 0.01;
		}
		else
		{	
			self.weaponmodelpos_x += 0.02;
			self.weaponmodelpos_z += 0.02;
			self.spawnmuzzleflash = 2;
		}
			
	}

	if (self.weaponmodelpos_x > -2.6)
	{
		self.weaponmodelpos_x -= 0.05;

		if (self.weaponmodelpos_x < 0)
			self.weaponmodelpos_z -= 0.05;
	}

	self.weaponframe++;	
	self.nextthink = time + 0.04;
};

weapon_info_frames wf_hyperblaster = {8, '26 74 0', '114 117 0'};
weapon_info_generic w_hyperblaster = { "progs/weapons/hyperblaster/view.md3", "progs/male/w_hyperblaster.mdl", PlasmaNoAmmo, "weapon_hyperblaster", '-2.2 0 1'};
weapon_info_ammo a_hyperblaster = {SUB_Assign_Saved_Cells, getcells, save_c1ammo};
weapon_info_func func_hyperblaster = { player_hyperb,  W_WeapoHyperblasternNoise};
weapon_info_frames2 wf2_hyperblaster = {'75 113 109', '75 113 0'};
weapon_info_mag mag_hyperblaster = {HB_AMMO_CAP, HB_AMMO_CAP};

/*
============
Grenade Launcher
============
*/

void() W_WeaponGrenadelauncherNoise =
{	
	//local float r = rint(random() * 2);

	if (self.weaponframe == 0)
		sound(self, CHAN_RELOAD, "sounds_q4/weapons/switch.wav", 1, ATTN_NORM);

	if (self.weaponframe == 33)
		sound(self, CHAN_RELOAD, "sounds_q4/weapons/grenade/clip_out.wav", 1, ATTN_NORM);
	
	if (self.weaponframe == 56)
		sound(self, CHAN_RELOAD, "sounds_q4/weapons/grenade/clip_in.wav", 1, ATTN_NORM);
};

void() player_grenl_ammo = [self.frame, player_grenl_ammo ]
{	
	self.weaponstate = WEAPON_USED;

	if (self.weaponframe != 7 && self.weaponframe > 26)
	{
		CheckDodge2 (self.origin + self.view_ofs, aim(self,10000));
		self.weaponframe = 7;
	}
	if (self.weaponframe >= 26)
	{	
		self.spawnmuzzleflash = 0;
		self.weaponstate = WEAPON_IDLE;
		player_run ();
		self.weaponframe = 27;
		return;
	}

	if (self.weaponframe == 10)
		self.spawnmuzzleflash = 2;

	if (self.weaponframe == 15)
		self.spawnmuzzleflash = 0;

	if (self.weaponframe == 9)
	{	
		sound(self, CHAN_WEAPON, "sounds_q4/weapons/grenade/fire.wav", 1, ATTN_NORM);
     	W_FireGrenade();
		self.currentammo -= 1;
		self.savedammo_grenades = self.currentammo;
		self.effects = self.effects | EF_MUZZLEFLASH;
		self.spawnmuzzleflash = 1;
    }

	self.weaponframe++;
	self.nextthink = time + 0.04;
};

void() player_grenl_noammo = [self.frame, player_grenl_noammo ]
{	
	self.weaponstate = WEAPON_USED;
	//bprint(ftos(self.weaponframe), "\n");
	
	if (self.weaponframe != 86 && self.weaponframe < 87)
	{
		CheckDodge2 (self.origin + self.view_ofs, aim(self,10000));
		self.weaponframe = 86;
	}

	if (self.weaponframe >= 105)
	{		
		self.weaponstate = WEAPON_IDLE; 
		player_run ();
		self.weaponframe = 29;
		self.spawnmuzzleflash = 0;
		return;
	}

	if (self.weaponframe == 86)
		self.spawnmuzzleflash = 2;

	if (self.weaponframe == 90)
		self.spawnmuzzleflash = 0;

	if (self.weaponframe == 86)
	{	
		sound(self, CHAN_WEAPON, "sounds_q4/weapons/grenade/fire.wav", 1, ATTN_NORM);
     	W_FireGrenade();
		self.currentammo -= 1;
		self.savedammo_grenades = self.currentammo;
		self.effects = self.effects | EF_MUZZLEFLASH;
		self.spawnmuzzleflash = 1;
    }

	self.weaponframe++;
	self.nextthink = time + 0.04;
};

void() player_grenl = 
{
	if (self.currentammo == 1)
		player_grenl_noammo ();
	else
		player_grenl_ammo ();
}

weapon_info_frames wf_grenadelauncher = {6, '27 28 0', '79 85 0', '29 30 0'};
weapon_info_generic w_grenadelauncher = { "progs/weapons/grenadelauncher/view.md3", "progs/male/w_shotgun.mdl", GrenadeLauncherNoAmmo, "weapon_grenadelauncher", '-1.8 0.1 0'};
weapon_info_ammo a_grenadelauncher = {SUB_Assign_Saved_Grenades, get_grenades, save_gammo};
weapon_info_func func_grenadelauncher = {player_grenl,  W_WeaponGrenadelauncherNoise };
weapon_info_frames2 wf2_grenadelauncher = {'31 78 63', '32 77 0'};
weapon_info_mag mag_grenadelauncher = {GL_AMMO_CAP, GL_AMMO_CAP};


/*
============
Nailgun
============
*/

void() W_WeaponNailGunNoise =
{
	if (self.weaponframe == 9 || self.weaponframe == 206 || self.weaponframe == 228)
		sound(self, CHAN_WEAPON, "sounds_q4/weapons/nailgun/handle.wav", 1, ATTN_NORM);

	if (self.weaponframe == 123 || self.weaponframe == 167)
		sound(self, CHAN_RELOAD, "sounds_q4/weapons/nailgun/clipout.wav", 1, ATTN_NORM);

	if (self.weaponframe == 144 || self.weaponframe == 190)
		sound(self, CHAN_RELOAD, "sounds_q4/weapons/nailgun/clipin.wav", 1, ATTN_NORM);

	if (self.weaponframe == 0)
		sound(self, CHAN_RELOAD, "sounds_q4/weapons/switch.wav", 1, ATTN_NORM);
};

void() nailgun_lockon = 
{	
	if (!visible(self.prelock_save) && self.prelock_save)
	{
		self.locked_on = 0;
		self.prelock_save = world;
	}

	if (!self.prelock_save)
		return;
	
	if (!self.locked_on)
		self.locked_on = time + 0.2;

	if (self.locked_on > time)
		return;

	self.locked_enemy = self.prelock_save;
	self.prelock_save = world;
	self.locked_on = 0;
}

void() nailgun_locking =
{	
	if (!visible(self.locked_enemy) && self.locked_enemy)
		self.locked_enemy = world;

	vector start = self.origin + self.view_ofs;
	vector src = start + v_forward*10;
	
	vector end= src + (8192 * aim(self,1000));

	traceline (src, end, FALSE, self);

	if (trace_ent == self.locked_enemy)
		return;

	if (trace_ent == self.prelock_save)
		return;

	if (!(trace_ent.flags & FL_MONSTER))
		return;
	
	if (!trace_ent.takedamage)
		return;

	if (trace_ent.health <= 0)
		return;
	
	self.prelock_save = trace_ent;
}

void() player_nail = [self.frame, player_nail]
{	
	self.weaponstate = WEAPON_USED;

	if (!self.button0 || (self.currentammo < 1))
	{	
		self.spawnmuzzleflash = 0;
		//self.firerate = 0;
		if (self.weaponmodelpos_x < -1.2)
		{
			self.weaponmodelpos_x += 0.04;

			if (self.weaponmodelpos_z < 0.6)
				self.weaponmodelpos_z += 0.05;
		}

		if (self.weaponframe < 64)
		{
			sound(self, CHAN_RELOAD, "sounds_q4/weapons/nailgun/spin_down.wav", 1, ATTN_NORM);
			self.weaponframe = 64;
		}	

		if ((self.weaponframe <= 77))
		{	
			self.weaponframe ++; 
			self.nextthink = time + 0.04;
			return;
		}
		else
		{	
			self.weaponmodelpos_x = -1.2;
			self.weaponmodelpos_z = 0.6;
			self.firerate = 0;
			sound(self, CHAN_RELOAD, "misc/null.wav", 1, ATTN_NORM);
			self.weaponstate = WEAPON_IDLE; 
			player_run ();
			self.weaponframe = 77;
			return;
		}
	}

	self.savedammo_nails = self.currentammo;
	
	if (self.weaponframe != 17 && self.weaponframe > 76 && self.button4)
	{
		self.weaponframe = 17;
		self.firerate = 0;
		sound(self, CHAN_RELOAD, "sounds_q4/weapons/nailgun/spin_up.wav", 1, ATTN_NORM);
		CheckDodge2 (self.origin + self.view_ofs, aim(self,10000));
	}

	if (self.weaponframe != 30 && self.weaponframe > 76 && !self.button4)
	{
		self.weaponframe = 30;
		self.firerate = 0;
		sound(self, CHAN_RELOAD, "sounds_q4/weapons/nailgun/spin_up.wav", 1, ATTN_NORM);
		CheckDodge2 (self.origin + self.view_ofs, aim(self,10000));
	}
		
	if (self.weaponmodelpos_x > -1.8 && self.weaponframe > 30)
	{
		self.weaponmodelpos_x -= 0.04;

		if (self.weaponmodelpos_z > 0.3)
			self.weaponmodelpos_z -= 0.05;
	}

//	bprint(ftos(self.weaponmodelpos_x), "\n");
	if (self.button0 && self.weaponframe > 30 && self.weaponframe < 64)
	{	
		if (time > self.firerate)
		{	
			self.spawnmuzzleflash = 1;
			W_FireNailGun ();
			CheckDodge2 (self.origin + self.view_ofs, aim(self,10000));
			self.firerate = time + 0.13;
		}
		else
			self.spawnmuzzleflash = 2;
	}
		
//	if (self.weaponframe == 17)
		

	if (self.weaponframe > 63 && self.button0 && self.weaponframe < 65) // full-auto
	{	
	//	sound(self, CHAN_RELOAD, "sounds_q4/weapons/nailgun/spin_fast.wav", 1, ATTN_NORM);
		self.weaponframe = 47;
	}

	self.weaponframe++;

	//if (self.weaponframe < 30 && self.button4)
	//	nailgun_lockon ();

	self.nextthink = time + 0.03;
};

weapon_info_frames wf_nailgun = {16, '77 115 0', '234 237 0'};
weapon_info_generic w_nailgun = { "progs/weapons/nailgun/view.md3", "progs/male/w_nailgun.mdl", NailGunNoAmmo, "weapon_nailgun", ' -1.2 0.8 0.6'};
weapon_info_ammo a_nailgun = {SUB_Assign_Saved_Nails, get_nails, save_nammo};
weapon_info_func func_nailgun = { player_nail, W_WeaponNailGunNoise};
weapon_info_frames2 wf2_nailgun = {'116 156 140', '157 216 199', '217 233 0'};
weapon_info_mag mag_nailgun = {NG_AMMO_LOAD, NG_AMMO_CAP};

/*
============
PLASMAgun
============
*/

void() W_WeaponRocketLaunNoise =
{	
	float r  = rint (random()*3);

	if (self.weaponframe == 0)
		sound(self, CHAN_RELOAD, "sounds_q4/weapons/switch.wav", 1, ATTN_NORM);

	if (self.weaponframe == 41 || self.weaponframe == 21)
	{
		if (r == 1)
			sound(self, CHAN_RELOAD, "sounds_q4/weapons/rocketlauncher/warhead1.wav", 1, ATTN_NORM);
		else if (r == 1)
			sound(self, CHAN_RELOAD, "sounds_q4/weapons/rocketlauncher/warhead2.wav", 1, ATTN_NORM);
		else
			sound(self, CHAN_RELOAD, "sounds_q4/weapons/rocketlauncher/warhead3.wav", 1, ATTN_NORM);
	}

	if (self.weaponframe == 31)
	{
		sound(self, CHAN_RELOAD, "sounds_q4/weapons/rocketlauncher/servo.wav", 1, ATTN_NORM);
	}
};


void() player_rl_ammo = [self.frame, player_rl_ammo ]
{	
	self.weaponstate = WEAPON_USED;
//	bprint(ftos(self.weaponframe), "\n");

	if (!self.button0 && self.weaponframe > 13)
	{	
		self.spawnmuzzleflash = 0;
		
		if (self.ammo_rockets > 0)
			self.weaponstate = WEAPON_RELOAD; 	
		else
			self.weaponstate = WEAPON_IDLE; 	

		player_run ();
		self.weaponframe = 51;
		return;

	}

	if (self.weaponframe == 10)
		self.spawnmuzzleflash = 2;

	if (self.weaponframe > 13 && self.button0 && self.currentammo == 0)
	{	
		self.spawnmuzzleflash = 0;
		self.weaponstate = WEAPON_RELOAD; 
		player_run ();
		self.weaponframe = 51;
		return;
	}

	if (self.weaponframe > 13 && self.button0 && self.currentammo > 0)
	{	
		self.weaponframe = 9;
		self.spawnmuzzleflash = 1;
	}

	if (self.weaponframe != 9 && self.weaponframe > 50)
		self.weaponframe = 9;

	if (self.weaponframe == 9)
	{	
		CheckDodge2 (self.origin + self.view_ofs, aim(self,10000));
		self.effects = self.effects | EF_MUZZLEFLASH;
		W_FireRocket();
	}
		
	self.weaponframe++;
	self.nextthink = time + 0.08;
};

void() player_rl_noammo = [self.frame, player_rl_noammo ]
{	
	self.weaponstate = WEAPON_USED;
	//bprint(ftos(self.weaponframe), "\n");

	if (!self.button0 && self.weaponframe > 67)
	{	
		self.spawnmuzzleflash = 0;
		self.weaponstate = WEAPON_IDLE; 
		player_run ();
		self.weaponframe = 53;
		return;
	}

	if (self.weaponframe == 64)
		self.spawnmuzzleflash = 2;

	if (self.weaponframe > 68 && self.button0 && self.currentammo > 0)
	{	
		self.weaponframe = 63;
		self.spawnmuzzleflash = 1;
	}

	if (self.weaponframe != 63 && self.weaponframe < 64)
		self.weaponframe = 63;

	if (self.weaponframe == 63)
	{	
		CheckDodge2 (self.origin + self.view_ofs, aim(self,10000));
		self.effects = self.effects | EF_MUZZLEFLASH;
		W_FireRocket();
	}

	self.weaponframe++;
	self.nextthink = time + 0.08;
};

void() player_rl = 
{
	if (self.ammo_rockets == 0)
		player_rl_noammo ();
	else
		player_rl_ammo ();
}


weapon_info_frames wf_rocketlauncher = {8, '51 52 0', '55 62 0', '53 54 1'};
weapon_info_generic w_rocketlauncher = { "progs/weapons/rocketlauncher/view.md3", "progs/male/w_hyperblaster.mdl", RocketLauncherNoAmmo, "weapon_rocketlauncher", '-0.8 0 0.8'};
weapon_info_ammo a_rocketlauncher = {SUB_Assign_Saved_Rockets, get_rockets, save_rammo};
weapon_info_func func_rocketlauncher = { player_rl, W_WeaponRocketLaunNoise};
weapon_info_frames2 wf2_rocketlauncher = {'14 33 22', '14 33 0'};
weapon_info_mag mag_rocketlauncher = {RL_AMMO_LOAD, RL_AMMO_CAP};

/*
============
Rocket Laucnher
============
*/
void() W_WeaponRailgunNoise =
{	
	//local float r = rint(random() * 2);

	if (self.weaponframe == 0)
		sound(self, CHAN_RELOAD, "sounds_q4/weapons/switch.wav", 1, ATTN_NORM);

	if (self.weaponframe == 91)
		sound(self, CHAN_SIX, "sounds_q4/weapons/railgun/readjust3.wav", 1, ATTN_NORM);

	if (self.weaponframe == 90)
		sound(self, CHAN_RELOAD, "sounds_q4/weapons/railgun/battery_out.wav", 1, ATTN_NORM);

	if (self.weaponframe == 115)
		sound(self, CHAN_RELOAD, "sounds_q4/weapons/railgun/battery_in.wav", 1, ATTN_NORM);

	if (self.weaponframe == 7)
		sound(self, CHAN_SIX, "sounds_q4/weapons/railgun/charge_small.wav", 1, ATTN_NORM); 

	if (self.weaponframe == 121)
		sound(self, CHAN_SIX, "sounds_q4/weapons/railgun/charge_small.wav", 1, ATTN_NORM); 
};

void() player_rail = [self.frame, player_rail]
{	
	self.weaponstate = WEAPON_USED;
	
	if (self.weaponframe != 12 && self.weaponframe > 42)	
	{
		CheckDodge2 (self.origin + self.view_ofs, aim(self,10000));
		self.weaponframe = 12;
	}	
	
	if (self.weaponframe >= 42)
	{	
		self.spawnmuzzleflash = 0;
		self.weaponstate = WEAPON_IDLE;
		self.weaponframe = 43;
		player_run();
		return;
	}

	if (self.weaponframe == 35)
		sound(self, CHAN_RELOAD, "sounds_q4/weapons/railgun/readjust3.wav", 1, ATTN_NORM);
	
	if (self.weaponframe == 15)
	{
		sound(self, CHAN_SIX, "sounds_q4/weapons/railgun/charge.wav", 1, ATTN_NORM); 
		self.spawnmuzzleflash = 0;
	}
		

	if (self.weaponframe == 13)
	{	
		self.effects = self.effects | EF_MUZZLEFLASH;
		W_FireRail();
		self.spawnmuzzleflash = 1;
		self.savedammo_slugs = self.currentammo;
	}	

	self.weaponframe++;
	self.nextthink = time + 0.04;
};

weapon_info_frames wf_railgun = {12, '42 81 0', '127 132 0'};
weapon_info_generic w_railgun = { "progs/weapons/railgun/view.md3", "progs/male/w_rlauncher.mdl", RailgunNoAmmo, "weapon_railgun", '-0.6 1.7 0.9'};
weapon_info_ammo a_railgun = {SUB_Assign_Saved_Slugs, get_slugs, save_slugammo};
weapon_info_func func_railgun = {player_rail, W_WeaponRailgunNoise};
weapon_info_frames2 wf2_railgun = {'82 126 115', '82 126 0'};
weapon_info_mag mag_railgun = {RG_AMMO_CAP, RG_AMMO_CAP};

/*
============
thunderbolt
============
*/

void() W_WeaponLightiningNoise =
{	
	//local float r = rint(random() * 2);

	if (self.weaponframe == 0)
		sound(self, CHAN_RELOAD, "sounds_q4/weapons/switch.wav", 1, ATTN_NORM);
};

void() player_lightninggun = [self.frame, player_lightninggun]
{	
	local float level = 30;

	self.weaponstate = WEAPON_USED;

	if (self.weaponframe != 8 && self.weaponframe > 21)
		self.weaponframe = 8;
	
	if (!self.button0 || self.currentammo <= 0)
	{	
		sound (self, CHAN_WEAPON, "misc/null.wav", 1, ATTN_NORM);
		if (self.weaponmodelpos_x < 0)
			self.weaponmodelpos_x += 0.1;

		self.weaponmodelpos_z = 0.8;
		self.t_width = 0;

		self.spawnmuzzleflash = 0;
		if (self.weaponframe < 17)
			self.weaponframe = 17;
		
		self.weaponframe++;
		self.nextthink = time + 0.04;
		
		if (self.weaponframe >= 22)
		{
			self.weaponstate = WEAPON_IDLE;
			self.weaponframe = 22;
			self.weaponmodelpos_x = 0;
			player_run ();
			return;
		}
	}

	if (!self.t_width && self.weaponframe > 11)
	{
		sound (self, CHAN_WEAPON, "sounds_q4/weapons/lightninggun/fire.wav", 1, ATTN_NORM);
		self.t_width = time + 0.5;
	}
		

	if (self.button0 && self.weaponframe >= 16 && self.currentammo > 0)
	{
		self.weaponframe = 13;
		
	}
	

	if (self.weaponframe >= 13 && self.weaponframe <= 16)
	{	
		W_FireLightning();
		self.spawnmuzzleflash = 3;

		if (self.weaponmodelpos_x > -0.6)
			self.weaponmodelpos_x -= 0.05;
		else
			self.weaponmodelpos_x += 0.05;

		if (self.weaponmodelpos_z >= 0.8)
			self.weaponmodelpos_z -= 0.05;
		else
			self.weaponmodelpos_z += 0.05;
	}

	self.weaponframe++;
	self.nextthink = time + 0.04;
};

weapon_info_frames wf_lightninggun = {7, '22 23 0', '24 30 0'};
weapon_info_generic w_lightninggun = { "progs/weapons/lightning_gun/view.md3", "progs/male/w_lightninggun.mdl", LGNoAmmo, "weapon_lightninggun", '0 -1.4 0.8'};
weapon_info_ammo a_lightninggun = {SUB_Assign_Saved_Coils, getcoils, save_c2ammo};
weapon_info_func func_lightninggun = {player_lightninggun, W_WeaponLightiningNoise};

/*
============
Dark matter gun
============
*/


void() W_WeaponDMGNoise =
{
	if (self.weaponframe == 0)
		sound(self, CHAN_RELOAD, "sounds_q4/weapons/switch.wav", 1, ATTN_NORM);

	if (self.weaponframe == 155)
		sound(self, CHAN_WEAPON, "sounds_q4/weapons/darkmatter/charge.wav", 1, ATTN_NORM);
};

void() player_dmg = [self.frame, player_dmg]
{	
	self.weaponstate = WEAPON_USED;
	
	if (self.weaponframe != 8 && self.weaponframe > 44)
	{
		self.weaponframe = 8; self.currentammo -= 1;
		self.savedammo_dmc = self.currentammo;
	}
	
	if (self.weaponframe >= 43)
	{
		self.weaponstate = WEAPON_RELOAD;
		self.weaponframe = 93;
		player_run ();
	}

	if (self.weaponframe == 9)
	{	
		self.effects = self.effects | EF_MUZZLEFLASH;
		W_FireDisint ();	
		sound(self, CHAN_WEAPON, "sounds_q4/weapons/darkmatter/fire.wav", 1, ATTN_NORM);
	}
	
	self.weaponframe++;
	self.nextthink = time + 0.04;
};

float() DMCnoammo =
{
	if (self.savedammo_dmc > 0)
		return FALSE;

	if (self.ammo_dmc > 0)
		return FALSE;

	return TRUE;
}

weapon_info_frames wf_dmg = {7, '44 92 0', '215 220 0', '93 154 0'};
weapon_info_generic w_dmg = { "progs/weapons/darkmatter/view.md3", "progs/male/w_railgun.mdl", DMCnoammo, "weapon_dmg", '0.2 0 -0.4'};
weapon_info_func func_dmg = {player_dmg, W_WeaponDMGNoise};
weapon_info_ammo a_dmg = {SUB_Assign_Saved_DMC, get_dmc, save_dmcammo};
weapon_info_frames2 wf2_dmg = {'155 214 213', '155 214 0'};
weapon_info_mag mag_dmg = {1, 1};

//=============================================