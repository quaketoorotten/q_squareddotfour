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
/*
==============================================================================

ZOMBIE

==============================================================================
*/

//=============================================================================

.float inpain;

/*
=============================================================================

ATTACKS

=============================================================================
*/

void() zombiedamagertouch =
{	
	if (!other.takedamage)
		return;
	if (other.classname != "player")
		return;
	if (other.classname == "gib")
		return;
	if (other.dmgtime > time)
		return;

	T_Damage (other, self, self.origin, self, self.dmg, 0);
	other.dmgtime = time + 0.3;
};

void(vector org) spawn_damagerzombie =
{
	local entity e;
	
	e = spawn();
	setorigin(e, org);
	//e.origin[2] += 4;

	setmodel (e, "progs/muzzleflash.spr");
	setsize (e, '-16 -16 -16', ' 16 16 16');
	e.solid = SOLID_TRIGGER;
	e.movetype = MOVETYPE_STEP;
	e.emiteffectnum = (particleeffectnum("TE_ZOMBIEFLESHSPLAT2"));
	e.touch = zombiedamagertouch ;
	e.deathtype = "acid";
	e.enemy = self.enemy;
	//e.owner = owner1;
	e.nextthink = time + 4;
	e.think = SUB_Remove;
	e.dmg = 8;
};

void() zombie_GrenadeTouch =
{
	if (other == self.owner)
		return; // don't explode on owner
	if (other.takedamage)
	{
		T_Damage(other, self, self.origin, self.owner, 2, 0 );
//		sound(self, CHAN_WEAPON, "zombie/z_hit.wav", 1, ATTN_NORM);
		remove(self);
		return;
	}
	if (random() <= 0.5)
		sound(self, CHAN_WEAPON, "monsters/boney/acid_burn.wav", 0.7, ATTN_NORM); // bounce sound
	else	
		sound(self, CHAN_WEAPON, "monsters/boney/acid_burn2.wav", 0.7, ATTN_NORM); // bounce sound

	self.velocity = '0 0 0';
	self.avelocity = '0 0 0';
	pointparticles (particleeffectnum("TE_ZOMBIEFLESHSPLAT"), self.origin - 16* normalize(self.velocity), '0 0 0', 2);

	if (pointcontents (self.origin) == CONTENT_WATER || pointcontents (self.origin) == CONTENT_SLIME || pointcontents (self.origin) == CONTENT_LAVA)
	{
		remove(self);
		return;
	}
	if (random() >= 0.4)
		spawn_damagerzombie (self.origin);
	
	remove(self);
};

/*
================
zombie_FireGrenade
================
*/

void () zombie_grenadeeffect =
{
	self.traileffectnum = particleeffectnum("EF_ZOMBIEFLESHSPRAY");
	self.nextthink = time + 6;
	self.think = SUB_Remove;
}

void(vector org, vector dir, float right_adjust, float up_adjust, float speed)  zombie_flesh =
{
	local	entity missile;
	float grav = cvar("sv_gravity");
	
	//self.effects = self.effects | EF_MUZZLEFLASH;

	missile = spawn ();
	missile.owner = self;
	missile.enemy = self.enemy;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
	missile.classname = "grenade";
		
// set missile speed	

	makevectors (dir);
	missile.velocity = dir * speed;

	if (up_adjust)
	{
		float gravityAdjustment = grav / 800;
		missile.velocity += v_up * up_adjust * gravityAdjustment ;
	}

	if (right_adjust)
		missile.velocity += v_right * right_adjust;

	//missile.dmg = damage;

	missile.avelocity = '300 300 300';

	missile.touch = zombie_GrenadeTouch;

// set missile duration
	missile.nextthink = time + 0.4;
	missile.think = zombie_grenadeeffect;

	setmodel(missile, "progs/muzzleflash.spr");
	setsize(missile, '0 0 0', '0 0 0');
	missile.traileffectnum = particleeffectnum("EF_ZOMBIEFLESHSPRAY2");

	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, org);
};

void() zombie_FireGrenade2 =
{
	entity en = self.enemy;
	vector org, dir, target;
	vector fwd, r, u;

//	sound(self, CHAN_WEAPON, "zombie/z_shot1.wav", 1, ATTN_NORM);

// calc org
	AngleVectors(self.angles, fwd, r, u);
	org = self.pos2;

	target = en.origin;
	dir = fwd;
//	local float dist = vlen(dir), pitch;

	zombie_flesh (org, dir,(crandom() * 50), 200 + (crandom() * 50), 300);
};






void() monster_zombie =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	
	monster_slimy_transf_cache ();

	if (self.spawnflags & SPAWN_CRUCIFIED)
	{
		self.movetype = MOVETYPE_NONE;
		zombie_cruc ();
	}
	else
		spawn_slimy_transfer ();
};

float	SPAWN_CRUCIFIED	= 1;

void() spawn_zombie =
{

};

void() zombie_cruc =
{

};

