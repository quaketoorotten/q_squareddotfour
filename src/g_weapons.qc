/*  Copyright (C) 1996-1997  Id Software, Inc.

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

    See file, 'COPYING', for details.
*/

// called by worldspawn
void() W_Precache =
{
    precache_sound("weapons/r_exp3.wav"); // new rocket explosion
    precache_sound("weapons/ric1.wav"); // ricochet (used in C code)
    precache_sound("weapons/ric2.wav"); // ricochet (used in C code)
    precache_sound("weapons/ric3.wav"); // ricochet (used in C code)
    precache_sound("weapons/spike2.wav"); // super spikes
    precache_sound("weapons/tink1.wav"); // spikes tink (used in C code)
    precache_sound("weapons/bounce.wav"); // grenade bounce
	precache_sound("monsters/bounce.wav");
	precache_sound ("weapons/grenade.wav");
	precache_sound ("weapons/sgun1.wav");

	precache_sound("weapons/lashit.wav");
	precache_sound("misc/lasfly.wav");
	precache_sound("weapons/plasmagun/flight_01.wav");

	precache_sound("weapons/rockfly.wav");

	precache_sound("weapons/pistol/pistol_shot_02a.wav");
	precache_sound("weapons/pistol/pistol_shot_03a.wav");
	precache_sound("weapons/pistol/pistol_shot_04a.wav");	

	precache_sound("sounds_q4/weapons/rocketlauncher/rocket_fire1.wav");
	precache_sound("sounds_q4/weapons/rocketlauncher/rocket_fire2.wav");
	precache_sound("sounds_q4/weapons/rocketlauncher/warhead1.wav");
	precache_sound("sounds_q4/weapons/rocketlauncher/warhead2.wav");
	precache_sound("sounds_q4/weapons/rocketlauncher/warhead3.wav");
	precache_sound("sounds_q4/weapons/rocketlauncher/servo.wav");

	precache_sound("sounds_q4/weapons/darkmatter/charge.wav");
	precache_sound("sounds_q4/weapons/darkmatter/fire.wav");

	precache_sound("weapons/machinegun/fire1e.wav");
	precache_sound("weapons/machinegun/fire2e.wav");
	precache_sound("weapons/machinegun/fire3e.wav");

	precache_sound("sounds_q4/weapons/hyperblaster/fire1.wav");
	precache_sound("sounds_q4/weapons/hyperblaster/fire2.wav");
	precache_sound("sounds_q4/weapons/hyperblaster/cell_out.wav");	
	precache_sound("sounds_q4/weapons/hyperblaster/cell_in.wav");
	precache_sound("sounds_q4/weapons/hyperblaster/spin_down.wav");	
	precache_sound("sounds_q4/weapons/hyperblaster/spin_up.wav");	
	precache_sound("sounds_q4/weapons/hyperblaster/close.wav");	

	precache_sound("sounds_q4/weapons/blaster/ready.wav");	
	precache_sound("sounds_q4/weapons/blaster/fire01.wav");
	precache_sound("sounds_q4/weapons/blaster/fire02.wav");

	precache_sound("sounds_q4/weapons/railgun/battery_in.wav");
	precache_sound("sounds_q4/weapons/railgun/charge_small.wav");
	precache_sound("sounds_q4/weapons/railgun/charge.wav");	

	precache_sound("sounds_q4/weapons/lightninggun/loop.wav");
	precache_sound("sounds_q4/weapons/lightninggun/fire.wav");
	precache_sound("sounds_q4/weapons/railgun/charge.wav");	
	precache_sound("sounds_q4/weapons/railgun/fire01.wav");	

	precache_sound("sounds_q4/weapons/railgun/fire02.wav");
	precache_sound("sounds_q4/weapons/railgun/fire03.wav");
	precache_sound("sounds_q4/weapons/railgun/readjust3.wav");	
	precache_sound("sounds_q4/weapons/railgun/battery_out.wav");	

	precache_sound("sounds_q4/weapons/nailgun/fire_01.wav");
	precache_sound("sounds_q4/weapons/nailgun/fire_02.wav");
	precache_sound("sounds_q4/weapons/nailgun/fire_03.wav");
	precache_sound("sounds_q4/weapons/nailgun/spin_up.wav");
	precache_sound("sounds_q4/weapons/nailgun/spin_down.wav");	
	precache_sound("sounds_q4/weapons/nailgun/spin_fast.wav");	

	precache_sound("sounds_q4/weapons/nailgun/handle.wav");
	precache_sound("sounds_q4/weapons/nailgun/clipout.wav");
	precache_sound("sounds_q4/weapons/nailgun/clipin.wav");	

	precache_sound("sounds_q4/weapons/shotgun/clip_in.wav");	
	precache_sound("sounds_q4/weapons/shotgun/clip_out.wav");	
	precache_sound("sounds_q4/weapons/shotgun/fire.wav");	
	precache_sound("sounds_q4/weapons/shotgun/pump1.wav");
	precache_sound("sounds_q4/weapons/shotgun/pump2.wav");

	precache_sound("sounds_q4/weapons/switch.wav");
	precache_sound("sounds_q4/weapons/grenade/clip_out.wav");
	precache_sound("sounds_q4/weapons/grenade/clip_in.wav");
	precache_sound("sounds_q4/weapons/grenade/fire.wav");

	precache_sound("sounds_q4/weapons/machinegun/bolt.wav");
	precache_sound("sounds_q4/weapons/machinegun/clipout.wav");
	precache_sound("sounds_q4/weapons/machinegun/clipin.wav");

	precache_sound("sounds_q4/weapons/machinegun/fire0.wav");
	precache_sound("sounds_q4/weapons/machinegun/fire1.wav");

	precache_sound("sounds_q4/weapons/blaster/light_off.wav");

	precache_sound("sounds_q4/weapons/machinegun/zoom_in.wav");
	precache_sound("sounds_q4/weapons/machinegun/zoom_out.wav");
};

void() AutofireMachineEnemyNoise =
{
	local float r = (random() );

	if(r >= 0.5)
		sound(self, CHAN_WEAPON, "sounds_q4/weapons/machinegun/fire0.wav", 1, ATTN_NORM);
	else	
		sound(self, CHAN_WEAPON, "sounds_q4/weapons/machinegun/fire1.wav", 1, ATTN_NORM);
}

void() RocketNoise =
{
	local float r = rint(random() * 2);

	if(r == 1)
		sound(self, CHAN_WEAPON, "sounds_q4/weapons/rocketlauncher/rocket_fire1.wav", 1, ATTN_NORM);
	else	
		sound(self, CHAN_WEAPON, "sounds_q4/weapons/rocketlauncher/rocket_fire2.wav", 1, ATTN_NORM);
}


float() crandom =
{
    return 2 * (random() - 0.5);
};

float() crand
{
	return (rand()&32767)* (2.0/32767) - 1;
};

float(entity viewer, entity targ) infront_notasself =
{
	local vector	vec;
	local float		dot;
	
	makevectors (viewer.angles);
	vec = normalize (targ.origin - viewer.origin);
	dot = vec * v_forward;
	
	if ( dot > 0.3)
	{
		return TRUE;
	}
	return FALSE;
};

void (vector src, vector dir, float speed) CheckDodge = // deimos code rip
{
	local float dist;
	local entity targ, oself;

	if(skill <= 1)
		if(random() > 0.6)
			return;

	if(skill >= 2)
		if(random() > 0.9)
			return;

	traceline (src, src + dir*8192, FALSE, self);
	
	if (!trace_ent)
		return;
	
	targ = trace_ent;
	
	if( (targ.flags & FL_MONSTER) && (targ.health > 0) && infront_notasself(targ, self) )
	{	
		if(targ.flags & FL_MEDIC)
			return;

		if(targ.flags & FL_DODGED)
			return;
	
		if(targ.dodge_finished > time)
			return;	
		
		if(!targ.th_dodge)
			return;

		if(targ.attack_state == AS_SLIDING)
			return;
				
		dist = vlen(trace_endpos - src);

		targ.enemy = self;
		targ.flags = targ.flags | FL_DODGED;

		oself = self;
		self = targ;

		self.th_dodge (); 
	//	bprint("dodge???", "\n");
		if(skill == 0)
			self.dodge_finished = time + 3 + random()*2;
		if(skill == 1)
			self.dodge_finished = time + 2 + random()*2;
		if(skill >= 2)
			self.dodge_finished = time + 1 + random()*2;
			
		self = oself;	
	}
};

void (vector src, vector dir) CheckDodge2 = // deimos code rip
{
//	local float dist;
	local entity targ, oself;

	traceline (src, src + dir*2048, 2, self);
	
	if (!trace_ent)
		return;

	if (!(trace_ent.flags & FL_TACTICAL))
		return;
	
	targ = trace_ent;
	
	if( (targ.flags & FL_MONSTER) && (targ.health > 0) && infront_notasself(targ, self) )
	{	
		if(targ.dodge_finished > time)
			return;	
		
		if(!targ.th_dodge)
			return;

		if(targ.attack_state == AS_SLIDING)
			return;

		targ.enemy = self;
		targ.flags = targ.flags | FL_DODGED;

		oself = self;
		self = targ;

		self.th_dodge (); 
		self.dodge_finished = time + 0.8 + random()*2;
			
		self = oself;	
		return;
	}
	return;
};

//============================================================================

vector() wall_velocity =
{
    local vector vel;

    vel = normalize(self.velocity);
    vel = normalize(vel + v_up * (random() - 0.5) + v_right * (random() - 0.5));
    vel = vel + 2 * trace_plane_normal;
    vel = vel * 200;

    return vel;
};

void() _splatter =
{	
	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

	if (other.solid != SOLID_BSP)
		return;
	
	float r = rint(rand() % 3);

	if (r == 3)
		pointparticles (particleeffectnum("TE_BLOODSPLAT4"), self.origin);
	else if (r == 2)
		pointparticles (particleeffectnum("TE_BLOODSPLAT3"), self.origin);
	else if (r == 1)
		pointparticles (particleeffectnum("TE_BLOODSPLAT2"), self.origin);
	else
		pointparticles (particleeffectnum("TE_BLOODSPLAT1"), self.origin);

	if(self.classname == "gib")
		return;

	remove(self);
}

void(vector org, vector vel, float dmg) SpawnBloodSplat =
{	
    local entity missile;

    missile = spawn();
    missile.owner = self;
    missile.movetype = MOVETYPE_TOSS;
    missile.solid = SOLID_TRIGGER;

    makevectors(self.angles);

    missile.velocity = vel + v_forward *500;
    missile.velocity_z = -300 * random();

    missile.think = SUB_Remove;
    missile.nextthink = time + 0.7;

    // set missile duration

    setmodel(missile, "progs/muzzleflash.spr");
	missile.traileffectnum = particleeffectnum("EF_GIBSPRAY");

    setsize(missile, '0 0 0', '0 0 0');
    setorigin(missile, org);
    missile.touch = _splatter;
};

/*
================
SpawnBlood
================
*/
void(entity teller, vector org, vector vel, float damage) SpawnBlood =
{	
	if (teller.classname == "shield_bbox")
	{
		pointparticles (particleeffectnum("TE_BOLT_IMPACT_RED"), org);
		return;
	}

	if (teller.aiflags & IS_PROJECTILE)
		return;

	//te_bloodshower (org, vel, 100, damage);
    pointparticles (particleeffectnum("TE_BLOODSPRAY"), org);

	if (random() <= 0.05)
		return;
	
	SpawnBloodSplat (org, vel, damage);
};


/*
================
FireLead 
================
*/

void() _impact =
{	
	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
	if (other.solid != SOLID_BSP)
		return;

	pointparticles (particleeffectnum("TE_LEADIMPACT"), self.origin);

	remove(self);
}

void(vector org, vector dir) SpawnImpact =
{
    local entity missile;

    missile = spawn();
    missile.owner = self;
    missile.movetype = MOVETYPE_FLY;
    missile.solid = SOLID_TRIGGER;

    //makevectors(self.angles);

	missile.velocity = normalize(dir) * 1000;

    // set missile duration

    setmodel(missile, "progs/muzzleflash.spr");

    setsize(missile, '0 0 0', '0 0 0');
    setorigin(missile, org);
     missile.touch = _impact;
};

void(vector start, vector dir, float hspread, float vspread, float damage, float kick, string te) FireLead =
{
	local	vector end;
	local	vector	src;
	local float		up = crandom() * vspread
			    , right = crandom() * hspread;
	
	makevectors(self.v_angle);

	src = start + v_forward*10;
	src_z = self.absmin_z + self.size_z * 0.7;
	
	end= src + (8192 * dir);
	end= end + right*v_right + up*v_up;

	traceline (src, end, FALSE, self);

	if (trace_fraction != 1.0)
	{
		local	vector	vel, org;
		
		vel = normalize(dir + v_up*crandom() + v_right*crandom());
		vel = vel + 2*trace_plane_normal;
		vel = vel * -200;

		org = trace_endpos - dir*4;
		
		if (trace_ent.takedamage)
		{	
			T_Damage (trace_ent, self, trace_endpos, self, damage, kick);

			if (trace_ent.classname == "gib")
			{
				if (random() < 0.4)
					SpawnBlood (trace_ent, org, vel * 0.2, kick * 2.5);
			}
			else 
			{
				if (random() <= 0.7)
					SpawnBlood (trace_ent, org, vel * 0.2, kick * 2.5);
			}
				
			// pointparticles (particleeffectnum("TE_BLOOD2"), org);
		}
		else
		{	
			pointparticles (particleeffectnum(te), org);
			SpawnImpact (org, dir);
		}
	}

};


void(float shotcount, vector start, vector dir, float hspread, float vspread, float dmg, float kick, string te) FirePallets =
{
	for(float i = 0; i < shotcount; i++)
		FireLead (start, dir, hspread, vspread, dmg, kick, te);
};

void(vector start, vector dir, float hspread, float vspread, float dmg, float kick, string te) FireBullet =
{	
	FireLead (start, dir, hspread, vspread, dmg, kick, te);
};


/*
==============================================================================

EXPLOSIONS

==============================================================================
*/

void(vector org) explosion_wave = 
{
	local entity e;
	e = spawn();
	org_z += 8;
	setorigin(e, org);
	setmodel(e, "progs/explo_wave.md3");
	setsize(e, VEC_ORIGIN, VEC_ORIGIN);
	e.scale = 0.1;
	e.think = _increasesize;
	e.nextthink = time;
	e.effects |= EF_ADDITIVE;
	//e.effects |= EF_FULLBRIGHT;
	e.effects |= EF_NOSHADOW;
	e.alpha = 0.5;
	e.ltime = 3;
}

static void() _increasesize =
{	
	if (self.scale >= self.ltime)
	{
		remove(self);
		return;
	}
	self.scale += .1;
	self.think = _increasesize;
	self.nextthink = time + 0.01;
}

void()	s3_explode_	=	[self.frame,		s3_explode_] 
{
	
	if (self.frame == 4)
		self.emiteffectnum = (particleeffectnum("TE_EXPLOSION_DUST3"));
	
	if (self.frame > 13)
	{
		remove(self);
		return;
	}
	self.frame++;

	self.nextthink = time + 0.02;
};

void() BecomeExplosion2 =
{
	self.frame = 0;
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.touch = SUB_Null;

	self.solid = SOLID_NOT;
	setorigin(self, self.origin);
	self.nextthink = time;
	
	pointparticles (particleeffectnum("TE_EXPLOSION_BLAST_SMALL"), self.origin, self.origin, 2);
	pointparticles (particleeffectnum("TE_EXPLOD"), self.origin, self.origin, 1);
	self.angles = '0 0 0';

	GroundShake (self, self.shake_interval, self.shake_time);
	remove(self);
};

void()	s2_explode_	=	[self.frame,		s2_explode_] 
{
	if (self.frame == 4)
	{
		if (self.classname != "grenade")
			self.emiteffectnum = (particleeffectnum("TE_EXPLOSION_DUST"));
		else
			self.emiteffectnum = (particleeffectnum("TE_EXPLOSION_DUST2"));
	}
	
	if (self.frame > 13)
	{
		remove(self);
		return;
	}
	self.frame++;

	self.nextthink = time + 0.02;
};

void()	sp_explode_	=	[self.frame,		sp_explode_] 
{
	//self.owner.punchangle = setvector (crandom() * 0.6, crandom() * 0.6, crandom() * 0.6);
	if (self.frame == 4)
	{
		self.emiteffectnum = (particleeffectnum("TE_EXPLOSION_DUST"));
	}
	
	if (self.frame > 13)
	{
		remove(self);
		return;
	}
	self.frame++;

	self.nextthink = time + 0.02;
};

void() BecomeExplosionPlayer =
{
	self.frame = 0;
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.touch = SUB_Null;

	self.solid = SOLID_NOT;
	setorigin(self, self.origin);
	self.nextthink = time;
	
	self.angles = '0 0 0';

	setmodel (self, "progs/muzzleflash.spr");
	setsize(self, VEC_ORIGIN, VEC_ORIGIN);
	self.think = sp_explode_;
	self.scale = 0.001;
	
	pointparticles (particleeffectnum("TE_EXPLOSION_BLAST"), self.origin, self.origin, 2);
	pointparticles (particleeffectnum("TE_EXPLOD"), self.origin, self.origin, 1);
	//pointparticles (particleeffectnum("EF_EXPLODLIGHT"), self.origin);

	GroundShake (self, self.shake_interval, self.shake_time);
	//explosion_wave (self.origin);
};

void() BecomeExplosion =
{
	self.frame = 0;
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.touch = SUB_Null;

	self.solid = SOLID_NOT;
	setorigin(self, self.origin);
	self.nextthink = time;
	
	self.angles = '0 0 0';

	setmodel (self, "progs/muzzleflash.spr");
	setsize (self, VEC_ORIGIN, VEC_ORIGIN);
	self.think = s2_explode_;
	self.scale = 0.001;
	
	if(self.classname == "green")
		pointparticles (particleeffectnum("TE_EXPLOSION_BLAST2"), self.origin, self.origin, 2);
	else
		pointparticles (particleeffectnum("TE_EXPLOSION_BLAST"), self.origin, self.origin, 2);

	pointparticles (particleeffectnum("TE_EXPLOD"), self.origin, self.origin, 1);
	//pointparticles (particleeffectnum("EF_EXPLODLIGHT"), self.origin);

	GroundShake (self, self.shake_interval, self.shake_time);
//	bprint("wow");
};

/*
===============================================================================

LIGHTNING

===============================================================================
*/

/*
=================
LightningDamage
=================
*/

void() _impact2 =
{	
	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
	if (other.solid != SOLID_BSP)
		return;

	pointparticles (particleeffectnum("TE_PLASIMPACT"), self.origin);

	remove(self);
}

void(vector org, vector dir) SpawnImpact2 =
{
    local entity missile;

    missile = spawn();
    missile.owner = self;
    missile.movetype = MOVETYPE_FLY;
    missile.solid = SOLID_TRIGGER;

    //makevectors(self.angles);

	missile.velocity = normalize(dir) * 1000;

    // set missile duration

    setmodel(missile, "progs/muzzleflash.spr");

    setsize(missile, '0 0 0', '0 0 0');
    setorigin(missile, org);
     missile.touch = _impact2;
};

void(vector p1, vector p2, entity anchor, entity shooter, float dmg, float kick, float len) fireRail = // fuckin' dangerous ass function
{
	local vector end;
	local vector from;
	local entity ignore;
	float bool = 2;

	end = p1 + p2 * len;
	from = p1;
//	vector trailend;
	float mod = DMGTYPE_RAIL;

	ignore = shooter;
	
	string name = "TE_BOLT_IMPACT";
	if (self.flags & FL_MONSTER)
		name = "TE_BOLT_IMPACT_RED";

	traceline (from, end, TRUE, ignore);
		vector org2 = trace_endpos;

	while(ignore)
	{
		traceline (from, end, bool, ignore);

		if((trace_ent.flags & FL_MONSTER) || (trace_ent.flags & FL_CLIENT))
			ignore = trace_ent;
		else
			ignore = world;
		
		from = trace_endpos;

		if((trace_ent != self) && (trace_ent.takedamage))
		{	
			if (trace_ent == ignore)
			{	
				SpawnBlood (trace_ent, trace_ent.origin, '0 0 -100', kick * 2.5);
				pointparticles (particleeffectnum(name), trace_endpos + p2*-4, '0 0 0', 4);
			}

			T_Damage (trace_ent, shooter, trace_endpos, shooter, dmg, kick, mod);
		}
	}

	if (self.classname == "monster_puncturer")
		return;
	
	pointparticles (particleeffectnum(name), from + p2*-4, '0 0 0', 4);
	SpawnImpact2(from + p2*-16, p2);

	if (self.flags & FL_MONSTER)
	{
		WriteByte (MSG_MULTICAST, SVC_CGAMEPACKET); // visual for other clients
		WriteByte (MSG_MULTICAST, TE_RAILTRAIL2);
	}
	else
	{
		WriteByte (MSG_MULTICAST, SVC_CGAMEPACKET); // visual for other clients
		WriteByte (MSG_MULTICAST, TE_RAILTRAIL);
	}
	WriteCoord (MSG_MULTICAST, p1_x);
	WriteCoord (MSG_MULTICAST, p1_y);
	WriteCoord (MSG_MULTICAST, p1_z);

	WriteCoord (MSG_MULTICAST, org2_x);
	WriteCoord (MSG_MULTICAST, org2_y);
	WriteCoord (MSG_MULTICAST, org2_z);

	multicast('0 0 0', MULTICAST_ALL);
};

void(vector p1, vector p2, entity shooter, float dmg, float kick, float len) fireLightning = 
{
	local vector end;
	local vector from;
	local entity ignore;

	end = p1 + p2 * len;
	from = p1;

	ignore = self;

	self.solid = SOLID_BBOX;

	traceline (from, end, 2, ignore);
	vector org = trace_endpos - p2*4;
	
	if((trace_ent != ignore) && (trace_ent.takedamage) && (trace_ent.classname != "gib"))
	{	
		SpawnBlood (trace_ent, org, '0 0 0', kick * 2.5);
		T_Damage (trace_ent, shooter, org, shooter, dmg, kick, DMGTYPE_LTNG);
		ignore = trace_ent;
	}

	self.solid = SOLID_SLIDEBOX;

	msg_entity = self;
	WriteByte (MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte (MSG_MULTICAST, THUNDER_ENDPOS);
	WriteCoord (MSG_MULTICAST, org_x);
	WriteCoord (MSG_MULTICAST, org_y);
	WriteCoord (MSG_MULTICAST, org_z);
	multicast ('0 0 0', MULTICAST_ONE);

	WriteByte (MSG_MULTICAST, SVC_CGAMEPACKET); // visual for other clients
	WriteByte (MSG_MULTICAST, THUNDER_STARTPOS);
	WriteCoord (MSG_MULTICAST, from_x);
	WriteCoord (MSG_MULTICAST, from_y);
	WriteCoord (MSG_MULTICAST, from_z);

	WriteCoord (MSG_MULTICAST, org_x);
	WriteCoord (MSG_MULTICAST, org_y);
	WriteCoord (MSG_MULTICAST, org_z);

	WriteEntity (MSG_MULTICAST, self);

	multicast('0 0 0', MULTICAST_ALL);

	pointparticles (particleeffectnum("TE_BOLT_IMPACT"), org);

	if (ignore == self)
		return;

	entity ent;
	vector point;
	//vector vec;

	for (ent= findradius(org, 200); ent; ent = ent.chain)
	{
		if(!ent.takedamage)
            continue;
        if(ent == self)
            continue;
		if(ent == ignore)
			continue;
		if(ent.classname == "gib")
			continue;
        if(!CanDamage(ent, ignore))
            continue;
		if(!(ent.flags & FL_MONSTER) && !(ent.flags & FL_CLIENT))
			continue;
		if(ent.solid == SOLID_CORPSE)
            continue;
		
		point = (ent.maxs - ent.mins) * 0.5 + ent.absmin;	

		pointparticles (particleeffectnum("TE_BOLT_IMPACT"), point);
	
		T_Damage (ent, self, point, self.owner, dmg, kick, DMGTYPE_LTNG);

		if (random() > 0.2)
			SpawnBlood (ent, point, '0 0 0', 0);

		//particle (point, '0 0 100', 73, self.dmg_lsr* 8);

		sound (self, CHAN_VOICE, "weapons/lhit.wav", 1, ATTN_NORM);

		//msg_entity = self;
		WriteByte (MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte (MSG_MULTICAST, THUNDER_STARTPOS);
		WriteCoord (MSG_MULTICAST, point_x);
		WriteCoord (MSG_MULTICAST, point_y);
		WriteCoord (MSG_MULTICAST, point_z);

		WriteCoord (MSG_MULTICAST, org_x);
		WriteCoord (MSG_MULTICAST, org_y);
		WriteCoord (MSG_MULTICAST, org_z);

		WriteEntity (MSG_MULTICAST, ent);

		multicast('0 0 0', MULTICAST_ALL);
	}
};

//=============================================


.float dmg_rad;
.float dmg_lsr;

float BLACKHOLE_TIMER = 1.5;

static void() _increasesize2 =
{	
	self.scale += 0.1;
//	bprint(ftos(self.scale),"\n");
	if (self.speed < time)
	{
		setmodel(self, "");
		remove(self);
		return;
	}

	self.think = _increasesize2;
	self.nextthink = time;
}

void() blackhole_explode = 
{	
//	bprint("wtf", "\n");
	entity e;
	e = spawn();

	setorigin(e, self.origin - normalize(self.velocity)*32);
	setmodel(e, "progs/weapons/darkmatter/explode.md3");
	setsize(e, VEC_ORIGIN, VEC_ORIGIN);

	e.scale = 1;
	e.alpha = 1;
	e.effects |= EF_FULLBRIGHT;
	//e.effects |= EF_ADDITIVE;
//	e.ltime = 60;
	e.speed = time + 1.2;

	e.think = _increasesize2;
	e.nextthink = time;

	pointparticles(particleeffectnum("TE_DMG_IMPLOSION"), self.origin - normalize(self.velocity)*32, '0 0 0', 3);
	GroundShake (self, 0.6, 0.8);
}

void() blackhole_eat =
{	
	local vector org;

	org = self.enemy.origin + (self.enemy.mins + self.enemy.maxs) * 0.5;
	self.origin = org;	

	if (self.enemy.health <= 0) // always gib enemy before disappearing
	{	
		blackhole_explode ();
	
		T_RadiusDamage (self, self.owner, 800, 1000, self.owner);
		
		T_Damage (self.enemy, self, self.origin, self.owner, 9999, 0);
		remove(self);
		return;
	}

	if ( ((time - self.ltime) > BLACKHOLE_TIMER) || !self.enemy)
	{	

		blackhole_explode ();
		T_RadiusDamage (self, self.owner, 400, 400, self.owner);
		remove(self);
		return;
	}
	
	if (self.enemy) {
		T_Damage (self.enemy, self, self.origin, self.owner, self.dmg_lsr, 0, DMGTYPE_DMG);	
		SpawnBlood (self.enemy, org, '0 0 0', 0);
	}

	self.think = blackhole_eat;
	self.nextthink = time + 0.1;
};

void() T_blackholetouch =
{ 
	self.effects = 0;
	vector vel = self.velocity;

	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	if (!other.takedamage)
	{	
		blackhole_explode ();
		T_RadiusDamage (self, self.owner, 180, 200, world);
		remove(self);
		return;
	}

	if (!(other.flags & FL_MONSTER) && !(other.flags & FL_CLIENT))
	{	
		blackhole_explode ();
		T_RadiusDamage (self, self.owner, 180, 200, world);
		remove(self);
		return;
	}

	self.emiteffectnum = particleeffectnum("TE_DARKMATTER_EAT");
	self.traileffectnum = 0;
//	self.scale = 4;
//	setmodel(self, "progs/muzzleflash.spr");
	self.think = blackhole_eat;
	self.nextthink = time + frametime;
	self.enemy = other;
	self.touch = __NULL__;
	self.ltime = time;
};

void() tbThink =
{      
	local	entity ent; local vector point, end, dir;
	float speed;
//	vector vel;

	if(time > self.dspeed)
		remove(self);

//	darkmatter_bolt ();
// literal copy of quake 2's code
	
	for (ent= findradius(self.origin, 128); ent; ent = ent.chain)
	{	
		if(!ent.takedamage)
            continue;

		if (ent.classname == "gib" && CanDamage(ent, self))
		{
			dir = normalize (ent.origin - self.origin);
		
			speed = 0.5*vlen (ent.origin - self.origin);

			speed = 400 - speed;

			if (vlen (ent.origin - self.origin) < 50)
				remove(ent);
			else
				ent.velocity = dir * -speed;
			
		//	physics_enable (ent, 1);
			
			if (ent.flags & FL_ONGROUND)
			{
				ent.origin_z += 16;
				ent.flags &= ~FL_ONGROUND;
			}
			continue;
		}

        if(ent== self.owner)
            continue;
        if(!CanDamage(ent, self))
            continue;
		if(!(ent.flags & FL_MONSTER) && !(ent.flags & FL_CLIENT))
			continue;
		
		point = (ent.maxs - ent.mins) * 0.5 + ent.absmin;	
		dir = normalize (point - self.origin);

		end = self.origin + dir*vlen(self.origin - point);	

		//traceline(self.origin, end, TRUE, self);
		
		T_Damage (ent, self, self.origin, self.owner, 15, 0);
		SpawnBlood (ent, point, '0 0 0', 0);

		if(!ent.mass)
            continue;
		if(ent.max_health > 300)
            continue;
		 if(!CanDamage(ent, self))
            continue;

		speed = 0.5*vlen (point - self.origin);
	
		speed = 500 - speed;
		speed = (100 * speed / ent.mass );

		if (vlen (point - self.origin) < 100) 
		{
			T_Damage (ent, self, self.origin, self.owner, ent.health, 0);
			ent.velocity = dir * -100;
		}
		else
			ent.velocity = dir * -speed;
		
		if (ent.flags & FL_ONGROUND)
		{
			ent.origin_z += 16;
			ent.flags &= ~FL_ONGROUND;
		}

	//	sound (self, CHAN_VOICE, "weapons/lhit.wav", 1, ATTN_NORM);

		/*WriteByte (MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte (MSG_MULTICAST, THUNDER_2);
		WriteCoord (MSG_MULTICAST, point_x);
		WriteCoord (MSG_MULTICAST, point_y);
		WriteCoord (MSG_MULTICAST, point_z);

		WriteCoord (MSG_MULTICAST, self.origin_x);
		WriteCoord (MSG_MULTICAST, self.origin_y);
		WriteCoord (MSG_MULTICAST, self.origin_z);*/

	//	WriteEntity (MSG_MULTICAST, ent);

		multicast('0 0 0', MULTICAST_ALL);
	}

	self.think = tbThink;
	self.nextthink = time + 0.1;
};

void(vector dir, vector org, float damage) launch_blackhole =
{	
	local entity missile;

	missile= spawn ();
	missile.angles = vectoangles(dir);
	missile.movetype = MOVETYPE_FLY;	
	missile.solid = SOLID_SLIDEBOX;

	missile.dmg_lsr = damage;
	
	missile.owner = self;
	missile.classname = "blackhole";
	missile.ltime = time + 3;
	missile.dspeed = time + 6;

	missile.touch = T_blackholetouch;
	
	missile.traileffectnum = particleeffectnum("TE_DARKMATTER");
	missile.nextthink = time + frametime;
	missile.think = tbThink;

	missile.velocity = dir * 400;
//	GroundShake (self, 0.6, 0.3);
		
	setmodel (missile, "progs/weapons/darkmatter/darkmatter.md3");
	missile.scale = 2.6;
	//missile.forceshader = shaderforname("effects/weapons/darkmatter_core");
	setsize (missile, VEC_ORIGIN, VEC_ORIGIN);
	
	setorigin (missile, org);
//	sound(missile, CHAN_BODY, "weapons/bfg__l1a.wav", 1, ATTN_STATIC);
	
};

//=============================================================================


void() spike_touch;
void() superspike_touch;

/*
===============
launch_spike

Used for both the player and the ogre
===============
*/

void()	_explode1	=	[0,		_explode2] {self.alpha = 0.8; };
void()	_explode2	=	[1,		_explode3] {self.alpha = 0.8; };
void()	_explode3	=	[2,		_explode4] {self.alpha = 0.6; };
void()	_explode4	=	[3,	     SUB_Remove] {self.alpha = 0.3; };

void(vector org, vector vel) TE_BLASTER = 
{		
	if (self.owner.classname != "player")
	{	
		pointparticles (particleeffectnum("TE_PLASIMPACT3_RED"), org,'0 0 0', 1);
		pointparticles (particleeffectnum("TE_PLASIMPACT2_RED"), org,'0 0 0', 1);
		pointparticles (particleeffectnum("TE_PLASIMPACT_RED"), org,'0 0 0', 1);
		return;
	}

	pointparticles (particleeffectnum("TE_PLASIMPACT3"), org,'0 0 0', 1);
	pointparticles (particleeffectnum("TE_PLASIMPACT2"), org,'0 0 0', 1);
	pointparticles (particleeffectnum("TE_PLASIMPACT"), org,'0 0 0', 1);
	//bprint("?", "\n");
	return;
};

.vector old_velocity;
void() Laser_Touch =
{
	local vector org;
	
	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
	if (self.bounce)
	{
		vector oldvel, spot1, spot2;

		oldvel = normalize(self.old_velocity);
   		spot1 = self.origin - (45*oldvel);
  	 	spot2 = self.origin + (45*oldvel);
  	 	traceline (spot1, spot2, FALSE, self);  // see through other monsters
 	 	self.origin = trace_endpos;
	
		org = self.origin;
	}

	self.classname = "plasma";
	if (other.takedamage)
	{	
		if (other.classname != "gib")
			SpawnBlood (other, org, self.velocity*0.2, self.dmg * 2.5);

		T_Damage (other, self, self.origin, self.owner, self.dmg, 2);
		T_RadiusDamage(self, self.owner, 15, 50, world);	
		remove(self);
	}
	else 
	{	
		org = self.origin;

	//	sound(self, CHAN_BODY, "weapons/lashit.wav", 1, ATTN_STATIC);
		TE_BLASTER (org - normalize(self.velocity) * 8, self.velocity);
		T_RadiusDamage(self, self.owner, 15, 50, world);	

		if (self.bounce != 0)
		{
			self.velocity = oldvel+(2*trace_plane_normal);
      		self.velocity = normalize(self.velocity);
     		self.velocity = self.speed * self.velocity;
      		self.old_velocity = self.velocity;
      		if (self.flags & FL_ONGROUND)
         		self.flags = self.flags - FL_ONGROUND;

			self.cnt ++;
		}
		else	
			remove(self);
	}
};

static void() _bounce_laser_think = 
{
	if (self.ltime < time)
	{
		self.think = SUB_Remove;
		self.nextthink = 0;
	}

	if (self.cnt >= 2)
	{
		self.think = SUB_Remove;
		self.nextthink = 0;
	}

	if (self.flags & FL_ONGROUND)
      self.flags = self.flags - FL_ONGROUND;

   	self.velocity = self.old_velocity;
   	self.angles = vectoangles(self.velocity);
   	self.nextthink = time;
}

static void() do_i_bounce =
{
	if (self.bounce)
	{
		self.nextthink = time;
		self.think = _bounce_laser_think;
		self.ltime = time + 6;
	}
	else
	{
		self.think = SUB_Remove;
		self.nextthink = time + 6;
	}
}

.float bounce;
void(vector org, vector vec, vector right, vector up, float damage = 0) LaunchLaser =
{
	vec = normalize(vec);
	local float spd;	
	local entity missile;

	missile = spawn();
	missile.owner = self;
	missile.movetype = MOVETYPE_FLY;
	missile.solid = SOLID_BBOX;

	if (damage > 0)
		missile.dmg = damage;
	else
		missile.dmg = 15;
	
	if (self.flags & FL_FLY)
		missile.dmg = 3;
	else if(self.classname == "player" && !deathmatch)
	{
		missile.bounce = TRUE;
		missile.speed = 1000;
		missile.cnt = 0;
		missile.dmg = 18;
	}
		
	else if(self.classname == "monster_gladiator")
	{
		missile.dmg = 25;
	}
	
	setmodel (missile, "progs/muzzleflash.spr");
	missile.effects = missile.effects | EF_ADDITIVE | EF_FULLBRIGHT;

		//	missile.scale = 1.4;
		//	missile.ltime = time + 5;
		//	missile.alpha = 0.99;
	missile.think = do_i_bounce;
	missile.nextthink = time;

	if (self.flags & FL_CLIENT)
	{
		missile.traileffectnum = particleeffectnum ("EF_PLASMA");
		missile.emiteffectnum = particleeffectnum ("TE_PLASMA");
	}
	else
	{
		missile.traileffectnum = particleeffectnum ("EF_PLASMA_2");
		missile.emiteffectnum = particleeffectnum ("TE_PLASMA_2");
	}
	
	setsize (missile, '0 0 0', '0 0 0');		

	setorigin (missile, org);
	
	if(self.classname == "monster_gladiator" || self.classname == "monster_tactical")
		spd = 800;
	else if((self.flags & FL_FLY))
		spd = 1000;
	else if (self.flags & FL_CLIENT)
		spd = 3000;
	else
		spd = 600;
	
	//makevectors(vec);
	missile.velocity = vec * spd + up + right;

	missile.angles = vectoangles(missile.velocity);
	missile.old_velocity = missile.velocity;
	missile.touch = Laser_Touch;

	if (self.classname != "player")
		sound(missile, CHAN_BODY, "misc/lasfly.wav", 1, ATTN_STATIC);
	else
		sound(missile, CHAN_BODY, "weapons/plasmagun/flight_01.wav", 1, ATTN_STATIC);
};

void(vector org, vector dir, float speed = 1000, float slidebox = 0) launch_spike =
{	
    newmis = spawn();
    newmis.owner = self;
    newmis.movetype = MOVETYPE_FLY;

	if(slidebox)
		newmis.solid = SOLID_SLIDEBOX;
	else
    	newmis.solid = SOLID_BBOX;

    newmis.angles = vectoangles(dir);

    newmis.touch = spike_touch;
    newmis.classname = "spike";
    newmis.think = SUB_Remove;
    newmis.nextthink = time + 6;
    setmodel(newmis, "progs/spike.mdl");
    setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
    setorigin(newmis, org);

    newmis.velocity = dir * speed;
};


void() W_FireSuperSpikes =
{
    local vector dir;

    sound(self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
    self.attack_finished = time + 0.2;
  //  self.currentammo = self.ammo_nails = self.ammo_nails - 2;
    dir = aim(self, 1000);
    launch_spike(self.origin + '0 0 16', dir);
    newmis.touch = superspike_touch;
    setmodel(newmis, "progs/s_spike.mdl");
    setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
    self.punchangle_x = -2;
	CheckDodge(newmis.origin, aim(self, 10000), 1000);
};


void(float ox) W_FireSpikes =
{
    local vector dir;

    makevectors(self.v_angle);

    sound(self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);
    self.attack_finished = time + 0.2;
  //  self.currentammo = self.ammo_nails = self.ammo_nails - 1;
    dir = aim(self, 1000);
    launch_spike (self.origin + '0 0 16' + v_right * ox, dir);

    self.punchangle_x = -2;

	CheckDodge(newmis.origin, aim(self, 10000), 1000);

};


void() spike_touch =
{
	local float dmg;
	
	if(self.owner.classname == "player")
		dmg = 10;
	else
		dmg = 8;
	
    if (other == self.owner)
    {
        return;
    }
    if (other.solid == SOLID_TRIGGER)
    {
        return; // trigger field, do nothing
    }

    if (pointcontents(self.origin) == CONTENT_SKY)
    {
        remove(self);
        return;
    }

    // hit something that bleeds
    if (other.takedamage)
    {
        SpawnBlood (other, self.origin, self.velocity*0.2, dmg);
        T_Damage(other, self, self.origin, self.owner, dmg, 3);
    } 
	else
    {

	pointparticles (particleeffectnum("d3fx.te_spike"), self.origin - normalize(self.velocity)*4);
		 

	//m_puff (self.origin);
    }
	remove(self);


};


void() superspike_touch =
{	
	local float dmg;
	
	if(self.owner.classname == "player")
		dmg = 20;
	else
		dmg = 16;

    if (other == self.owner)
    {
        return;
    }
    if (other.solid == SOLID_TRIGGER)
    {
        return; // trigger field, do nothing
    }

    if (pointcontents(self.origin) == CONTENT_SKY)
    {
        remove(self);
        return;
    }

    // hit something that bleeds
    if (other.takedamage)
    {
        SpawnBlood (other, self.origin, self.velocity*0.2, dmg);
        T_Damage(other, self, self.origin, self.owner, dmg, 3);
    } 
	else
    {
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
         WriteByte(MSG_BROADCAST, TE_SUPERSPIKE);
	WriteCoord(MSG_BROADCAST, self.origin_x);
        WriteCoord(MSG_BROADCAST, self.origin_y);
        WriteCoord(MSG_BROADCAST, self.origin_z);
		 

	//m_puff (self.origin);
    }
	 remove(self);
  
};

.vector rndAng;
void() Nail_Aim =
{	
	if (self.enemy.health <= 0)
	{
		self.think = SUB_Remove;
		self.nextthink = time + 6;
		return;
	}
		
	vector	dir, seekPos;
	vector  dirAng, nose;
	float frac;
	vector diff;
	float i = 0;

	nose = self.origin;
	seekPos = self.enemy.origin + (self.enemy.mins + self.enemy.maxs)*0.5;

	dir = seekPos - nose;

	dirAng = vectoangles(normalize(dir));
	dirAng [0] = -dirAng[0]; // im not sure why 

	if (( self.ltime < time ) )
	{
		self.rndAng[ 0 ] = 5 * crandom();
		self.rndAng[ 1 ] = 5 * crandom();
		self.rndAng[ 2 ] = 5 * crandom();
		self.ltime = time + 1.25;
	}

	// make it more accurate as it gets closer
	frac = vlen(dir) / 256;
	if ( frac > 1) 
		frac = 1;

	diff = dirAng - self.movedir + self.rndAng * frac;
	diff = Normalize180(diff);

	diff[0] = get_diff(diff[0]);
	diff[1] = get_diff(diff[1]);
	diff[2] = get_diff(diff[2]);

	self.movedir += diff;

	vector fwd;
	AngleVectors(self.movedir, fwd);

	self.velocity = fwd * 800;

	self.nextthink = time;
	self.think = Nail_Aim;	
};


static float (float diff) get_diff =
{
	if ( diff > 180 ) 
		diff = 180;
	else if ( diff < -180 ) 
		diff = -180;
	return diff;
}

void() stroggnail_touch = 
{
	if (other == self.owner)
		return;

	vector org = self.origin - normalize(self.velocity)*4;

	if (other.takedamage)
	{	
		T_Damage (other, self, self.origin, self.owner, self.dmg, self.dspeed);

		if (other.classname == "gib")
		{
			if (random() < 0.4) 
				SpawnBlood (other, org, self.velocity * 0.2, self.dspeed * 2.5);
		} 
		else
			SpawnBlood (other, org, self.velocity * 0.2, self.dspeed * 2.5);
		// pointparticles (particleeffectnum("TE_BLOOD2"), org);
	}
	else
	{	
		pointparticles (particleeffectnum("d3fx.te_spike"), self.origin - normalize(self.velocity)*4);
		SpawnImpact (org, self.velocity);
	}

	if (self.owner.classname == "player")
		T_RadiusDamage(self, self.owner, 25, 50, world);
	else
		T_RadiusDamage(self, self.owner, 15, 50, world);

	remove(self);
};

void(vector org, vector direction, float damage, float kick, float speed) Strogg_nail = 
{ 
	local entity tracer = spawn();
	tracer.owner = self;
	tracer.movetype = MOVETYPE_FLY;
	tracer.solid = SOLID_BBOX;

	tracer.angles = vectoangles(direction);
	
	tracer.classname = "tracer";
	tracer.effects = tracer.effects | EF_FULLBRIGHT | EF_NOSHADOW | EF_ADDITIVE;
	tracer.think = SUB_Remove;
	tracer.nextthink = time + 6;
	tracer.touch = stroggnail_touch;
	tracer.scale = 1.2;
	tracer.dmg = damage;

	if (self.locked_enemy != world)
	{	
		tracer.enemy = self.locked_enemy;
		//self.locked_enemy = __NULL__;
		tracer.nextthink = time + 0.2;
		tracer.think = Nail_Aim;
	}
	
	tracer.velocity = direction * speed;
	tracer.dspeed = kick;
	tracer.traileffectnum = particleeffectnum("TE_STROGG_NAIL");

	setmodel (tracer, "progs/weapons/nailgun/nail_g.md3");  
	setsize (tracer, '0 0 0', '0 0 0');
	setorigin (tracer, org);
};

//====================================================================================================

void() stroggBul_touch = 
{
	if (other == self.owner)
		return;

	vector org = self.origin - normalize(self.velocity)*4;

	if (other.takedamage)
	{	
		T_Damage (other, self, self.origin, self.owner, self.dmg, self.dspeed);

		if (other.classname == "gib")
		{
			if (random() < 0.4) 
				SpawnBlood (other, org, self.velocity * 0.2, self.dspeed * 2.5);
		} 
		else
			SpawnBlood (other, org, self.velocity * 0.2, self.dspeed * 2.5);
		// pointparticles (particleeffectnum("TE_BLOOD2"), org);
	}
	else
	{	
	//	pointparticles (particleeffectnum("d3fx.te_spike"), self.origin - normalize(self.velocity)*4);
		pointparticles (particleeffectnum("TE_PLASIMPACT3_RED"), org,'0 0 0', 1);
		pointparticles (particleeffectnum("TE_PLASIMPACT_RED"), org,'0 0 0', 1);
		pointparticles (particleeffectnum("d3fx.te_spike"), self.origin - normalize(self.velocity)*4);
	}

	remove(self);
};

void(vector org, vector direction, float damage, float kick, float speed) Strogg_Bullet = 
{ 

	local entity tracer = spawn();
	tracer.owner = self;
	tracer.movetype = MOVETYPE_FLY;
	tracer.solid = SOLID_BBOX;

	tracer.angles = vectoangles(direction);
	
	tracer.classname = "tracer";
//	tracer.effects = tracer.effects | EF_FULLBRIGHT | EF_NOSHADOW | EF_ADDITIVE;
	tracer.think = SUB_Remove;
	tracer.nextthink = time + 6;
	tracer.touch = stroggBul_touch;
	tracer.dmg = damage;
	
	tracer.velocity = direction * speed;
	tracer.dspeed = kick;
	tracer.emiteffectnum = particleeffectnum("TE_STROGG_BULLET");

	setmodel (tracer, "progs/muzzleflash.spr");  
	setsize (tracer, '0 0 0', '0 0 0');
	setorigin (tracer, org);
};

//====================================================================================================

void() rocket_touch =
{
//    local float damg;

    if (other == self.owner)
    {
        return; // don't explode on owner
    }

    if (pointcontents(self.origin) == CONTENT_SKY)
    {
        remove(self);
        return;
    }

	if (self.nextbumper)
		remove(self.nextbumper);

//	bprint(ftos(damg), "\n");
	
	rocketimpact  ();
	
	T_RadiusDamage(self, self.owner, self.dmg, self.dmg_rad, other);

	float kick = 50;
	if (self.owner.classname == "monster_hovertank")	
		kick = 120;
	
    self.origin = self.origin - 32* normalize(self.velocity);

    if (other.takedamage)
    {
        T_Damage(other, self, self.origin, self.owner, self.dmg, kick);

		if (other.classname != "gib")
		{
			for(float i = 0; i<6;i++)
				SpawnBlood (other, self.origin, '0 0 0', 20);
		}
    }

	//self.classname = "grenade";
    //sound(self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM)

	if (self.dmg >= 60)
    	BecomeExplosion();
	else
		BecomeExplosion2();
};

void(vector org, vector dir, float speed = 1000, float damage, float damage_rad, string part) launch_rocket =
{	
    newmis = spawn();
    newmis.owner = self;
    newmis.movetype = MOVETYPE_FLY;

    newmis.solid = SOLID_SLIDEBOX;

    newmis.angles = vectoangles(dir);

    newmis.touch = rocket_touch;
    newmis.classname = "missile";
    newmis.think = SUB_Remove;
    newmis.nextthink = time + 6;
    setmodel(newmis, "progs/weapons/missile.md3");
	newmis.scale = 1.3;
	newmis.traileffectnum = particleeffectnum (part);
    setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
    setorigin(newmis, org);
	newmis.shake_interval = 0.2;
	newmis.shake_time = 0.6;
	newmis.dmg = damage;
	newmis.dmg_rad = damage_rad;

    newmis.velocity = dir * speed;
};

void() rocket_homein =
{
	float len = vlen(self.enemy.origin - self.origin);
	if ((self.enemy.health <= 0) || ((len <= 100) && self.enemy.classname == "aim_target"))
	{
		self.think = SUB_Remove;
		self.nextthink = time + 6;
		return;
	}

	vector	dir, seekPos;
	vector  dirAng, nose;
	float frac;
	vector diff;
	float i = 0;

	nose = self.origin;
	seekPos = self.enemy.origin + self.enemy.view_ofs;

	dir = seekPos - nose;
	dirAng = vectoangles(normalize(dir));
	dirAng [0] = -dirAng[0]; // im not sure why 

	if ( self.ltime < time ) 
	{
		self.rndAng[ 0 ] = 15 * crandom();
		self.rndAng[ 1 ] = 15 * crandom();
		if (self.owner.classname != "monster_stream_protector" && self.owner.classname != "monster_tank")
			self.rndAng[ 2 ] = 15 * crandom();
		else
			self.rndAng[ 2 ] = 35;

		self.ltime = time + 1.25;
	}

	// make it more accurate as it gets closer
	frac = vlen(dir) / 256;
	if ( frac > 1) 
		frac = 1;

	diff = dirAng - self.angles + self.rndAng * frac;
	diff = Normalize180(diff);

	diff[0] = get_diff(diff[0]);
	diff[1] = get_diff(diff[1]);

	//if (self.owner.classname != "monster_stream_protector" && self.owner.classname != "monster_tank")
	diff[2] = get_diff(diff[2]);

	self.angles += diff;

	vector fwd;
	AngleVectors(self.angles, fwd);

	if (self.nextbumper)
		setorigin(self.nextbumper, self.origin);

	self.velocity = fwd * self.dspeed;

	self.nextthink = time + 0.1;
	self.think = rocket_homein;	
};

void(entity attacker, float damage, float MOD) rocket_bbox_pain = 
{	
	
}

void(entity own) rocket_bbox = 
{
	local entity e;
	e = spawn();
	setsize(e, '-10 -10 -10', '10 10 10');
	setorigin(e, own.origin);
	e.health = own.health;
	e.takedamage = DAMAGE_AIM;
	e.solid = SOLID_CORPSE;
	e.classname = "homing_missilebbox";
	e.movetype = MOVETYPE_FLY;
	e.th_die = rocket_bbox_die;
	e.owner = own;
	e.origin = own.origin;
	e.aiflags |= IS_PROJECTILE;
	//e.think = followmissile;
	//e.nextthink = time;
	//e.groundentity = own;
	own.nextbumper = e;
}

void() rocket_bbox_die =
{	
	self.th_die = SUB_Null;

	//if (!(self.owner.flags & FL_MONSTER))
	remove(self.owner);

	self.origin = self.origin - 32* normalize(self.velocity);
	
	BecomeExplosion2 ();
};

void(vector org, vector dir, float speed, float damage, float damage_rad, float hp, string part) launch_rocket_home =
{	
    newmis = spawn();
    newmis.owner = self;
    newmis.movetype = MOVETYPE_FLY;

    newmis.solid = SOLID_SLIDEBOX;

    newmis.angles = vectoangles(dir);

    newmis.touch = rocket_touch;
    newmis.classname = "missile_homing";
    newmis.think = rocket_homein;
    newmis.nextthink = time;
	newmis.health = hp;
    setmodel(newmis, "progs/weapons/missile.md3");
	newmis.scale = 1.3;
	newmis.traileffectnum = particleeffectnum (part);
    setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
    setorigin(newmis, org);

	newmis.shake_interval = damage_rad < 80 ? 0.2 : 0.6;
	newmis.shake_time = damage_rad < 80 ? 0.6 : 1.2;

	newmis.dmg = damage;
	newmis.dmg_rad = damage_rad;
	newmis.enemy = self.enemy;

	if (hp > 50)
		newmis.dspeed = 250;
	else
		newmis.dspeed = 280;

	if (self.classname == "monster_stream_protector" || self.classname == "monster_tank")
		newmis.dspeed = speed;

    newmis.velocity = dir * speed;
	rocket_bbox (newmis);
};

//=======================================================================================

void() Flame_Burn = 
{
	if (other == self.owner)
		return;

	vector org = self.origin - normalize(self.velocity)*4;

	if (other.takedamage)
	{	
		T_Damage (other, self, self.origin, self.owner, self.dmg, 15);

		if (other.classname == "gib")
		{
			if (random() < 0.4) 
				SpawnBlood (other, org, self.velocity * 0.2, 15 * 2.5);
		} 
		else
			SpawnBlood (other, org, self.velocity * 0.2, 15 * 2.5);
		// pointparticles (particleeffectnum("TE_BLOOD2"), org);
	}
	else
	{	
	//	pointparticles (particleeffectnum("d3fx.te_spike"), self.origin - normalize(self.velocity)*4);
		pointparticles (particleeffectnum("TE_ROCKETIMPAC"), org,'0 0 0', 1);
		pointparticles (particleeffectnum("TE_PLASIMPACT3_RED"), org,'0 0 0', 1);
	}

	remove(self);
};

void() Flame_think = 
{	
	if (self.ltime < time)
	{
		remove(self);
		return;

	}
	self.think = Flame_think;
	self.nextthink = time;

	self.velocity[2] += 0.4;
}

void(vector org, vector direction, float damage, float speed, float die ,string effect) Launch_Flame = 
{ 
//	float grav = cvar("sv_gravity");
	local entity tracer = spawn();
	tracer.owner = self;
	tracer.movetype = MOVETYPE_FLY;
	tracer.solid = SOLID_BBOX;

	tracer.angles = vectoangles(direction);
	
	tracer.classname = "fire";
//	tracer.effects = tracer.effects | EF_FULLBRIGHT | EF_NOSHADOW | EF_ADDITIVE;
	tracer.think = Flame_think;
	tracer.nextthink = time;
	tracer.ltime = time + die;
	tracer.touch = Flame_Burn;
	tracer.dmg = damage;
	
	makevectors (direction);
	tracer.velocity = direction * speed;
//	tracer.velocity_z = 10;
//	tracer.dspeed = kick;
	tracer.emiteffectnum = particleeffectnum(effect);

	setmodel (tracer, "progs/muzzleflash.spr");  
	setsize (tracer, '0 0 0', '0 0 0');
	setorigin (tracer, org);
};