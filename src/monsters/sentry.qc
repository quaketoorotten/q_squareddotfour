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

DEMON

==============================================================================
*/

//============================================================================

void() sentry_stand1 = [ 1, sentry_stand2 ] { ai_stand(); self.monster_frame = 0;};
void() sentry_stand2 = [ self.frame, sentry_stand2 ] 
{ 	
	self.monster_frame ++;
	if (self.monster_frame >= 60) 
	{	
		sentry_sfx_idle ();
		sentry_stand1 ();
		return;
	}
	ai_stand ();
};

void() sentry_walk1 = [ 1, sentry_walk2 ] { ai_walk(3); self.monster_frame = 0;};
void() sentry_walk2 = [ self.frame, sentry_walk2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 60) 
	{
		sentry_sfx_idle ();
		sentry_walk1 ();
		return;
	}
	ai_walk (3);
};

void() sentry_run1 = [ 1, sentry_run2 ] { ai_run(self.speed); self.monster_frame = 0;};
void() sentry_run2 = [ self.frame, sentry_run2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 60) 
	{
		sentry_sfx_idle ();
		sentry_run1 ();
		return;
	}
	ai_run (self.speed);
};

//==============================================================================

// fire
void() sentry_missile1 = [ 2, sentry_missile2 ] 
{	self.monster_frame = 0; self.count =0;
ai_flybob_face(); self.nextthink = time + 0.04;  };
void() sentry_missile2 = [ self.frame, sentry_missile2 ] 
{ 	
	sentry_sfx_idle ();
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame >= 4) 
	{
		self.monster_frame = 0;
	}

	if (self.monster_frame == 1)
	{	
	//	bprint(ftos(self.monster_frame), "\n");
		self.count ++;
		sentry_shoot ('0 -16 50');
	}

	if (self.monster_frame == 2)
	{	
	//	self.count ++;
		sentry_shoot ('0 16 50');
	}
	
	if (self.count >= 16 || !visible(self.enemy)) 
	{	
		sentry_run1 ();
		return;
	}

    ai_flybob_face ();
};

void() sentry_missilea1 = [ 2, sentry_missilea2 ] 
{	self.monster_frame = 0; self.count =0;
ai_flybob_face(); self.nextthink = time + 0.04;  };
void() sentry_missilea2 = [ self.frame, sentry_missilea2 ] 
{ 	
	sentry_sfx_idle ();
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame >= 4) 
	{
		self.monster_frame = 0;
	}

	if (self.monster_frame == 1)
	{	
	//	bprint(ftos(self.monster_frame), "\n");
		self.count ++;
		sentry_shoot ('0 -16 50');
	}

	if (self.monster_frame == 2)
	{	
	//	self.count ++;
		sentry_shoot ('0 16 50');
	}
	
	if (self.count >= 8 || !visible(self.enemy)) 
	{	
		sentry_run1 ();
		return;
	}

    ai_flybob_face ();
	M_walkmove (self.ideal_yaw -90, 3);
};

void() sentry_missileb1 = [ 2, sentry_missileb2 ] 
{	self.monster_frame = 0; self.count =0;
ai_flybob_face(); self.nextthink = time + 0.04;  };
void() sentry_missileb2 = [ self.frame, sentry_missileb2 ] 
{ 	
	sentry_sfx_idle ();
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame >= 4) 
	{
		self.monster_frame = 0;
	}

	if (self.monster_frame == 1)
	{	
	//	bprint(ftos(self.monster_frame), "\n");
		self.count ++;
		sentry_shoot ('0 -16 50');
	}

	if (self.monster_frame == 2)
	{	
	//	self.count ++;
		sentry_shoot ('0 16 50');
	}
	
	if (self.count >= 8 || !visible(self.enemy)) 
	{	
		sentry_run1 ();
		return;
	}

    ai_flybob_face ();
	M_walkmove (self.ideal_yaw + 90, 3);
};

//==============================================================================

void() sentry_MissileAttack =
{
	sentry_sfx_sight ();

	float r = rint(random()*2);

	if (r == 2)
		sentry_missilea1();
	else if (r == 1)
		sentry_missileb1();
	else
 	   	sentry_missile1();
};

//==============================================================================

void() sentry_die =
{	
	sentry_sfx_death ();
    self.origin_z += 24;
	MonsterGib(-500);
    BecomeExplosion2 ();
};

void(entity attacker, float damage, float MOD) sentry_pain =
{
	if (self.pain_finished > time)
		return;
	
	self.pain_finished = time + 1;
	sentry_sfx_pain ();
};

static void() sentry_sfx_pain =
{
	local float r = rint(random() * 1);	

	if (r == 1)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/sentry/pain2.wav", 1, ATTN_NORM);
	else
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/sentry/pain1.wav", 1, ATTN_NORM);
};

static void() sentry_sfx_death =
{
	local float r = (random());	

	if (r <= 0.5)
		    sound(self, CHAN_BODY, "sounds_q4/strogg/sentry/die1.wav", 1, ATTN_NORM);
	else
		    sound(self, CHAN_BODY, "sounds_q4/strogg/sentry/die2.wav", 1, ATTN_NORM);
};

static void() fire =
{
	local float r = (random());	

	if (r <= 0.5)
		    sound(self, CHAN_WEAPON, "sounds_q4/strogg/sentry/fire1.wav", 1, ATTN_NORM);
	else
		    sound(self, CHAN_WEAPON, "sounds_q4/strogg/sentry/fire1.wav", 1, ATTN_NORM);
};

static void() sentry_sfx_idle =
{	
	if (self.t_width < time)
		sound(self, CHAN_BODY, "sounds_q4/strogg/sentry/sentry_hover.wav", 1, ATTN_IDLE);
	self.t_width = time + 0.1;
};

static void() sentry_sfx_sight =
{
	local float r = rint(random() * 7);	

	if (r == 7)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/sentry/voice_1.wav", 1, ATTN_NORM);
	else if (r == 6)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/sentry/voice_2.wav", 1, ATTN_NORM);
	else if (r == 5)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/sentry/voice_3.wav", 1, ATTN_NORM);
	else if (r == 4)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/sentry/voice_4.wav", 1, ATTN_NORM);
	else if (r == 3)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/sentry/voice_5.wav", 1, ATTN_NORM);
	else if (r == 2)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/sentry/voice_6.wav", 1, ATTN_NORM);
	else if (r == 1)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/sentry/voice_7.wav", 1, ATTN_NORM);
	else
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/sentry/voice_8.wav", 1, ATTN_NORM);
};

/*QUAKED monster_demon (1 0 0) (-32 -32 -24) (32 32 64) Ambush

*/
void() monster_sentry_cache =
{
	precache_model("progs/monsters/sentry/sentry.md5.info");

	precache_sound("sounds_q4/strogg/sentry/voice_1.wav");
	precache_sound("sounds_q4/strogg/sentry/voice_2.wav");
	precache_sound("sounds_q4/strogg/sentry/voice_3.wav");
	precache_sound("sounds_q4/strogg/sentry/voice_4.wav");
	precache_sound("sounds_q4/strogg/sentry/voice_5.wav");
	precache_sound("sounds_q4/strogg/sentry/voice_6.wav");
	precache_sound("sounds_q4/strogg/sentry/voice_7.wav");
	precache_sound("sounds_q4/strogg/sentry/voice_8.wav");

	precache_sound("sounds_q4/strogg/sentry/fire1.wav");
    precache_sound("sounds_q4/strogg/sentry/fire2.wav");

    precache_sound("sounds_q4/strogg/sentry/die1.wav");
    precache_sound("sounds_q4/strogg/sentry/die2.wav");

    precache_sound("sounds_q4/strogg/sentry/pain1.wav");
    precache_sound("sounds_q4/strogg/sentry/pain2.wav");

    precache_sound("sounds_q4/strogg/sentry/sentry_hover.wav");

//	spawn_demon ();
};

void() monster_sentry =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	monster_sentry_cache ();	
	spawn_sentry ();
};

void() spawn_sentry =
{
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel(self, "progs/monsters/sentry/sentry.md5.info");
	self.classname = "monster_sentry";
	setsize(self, '-16 -16 0', '16 16 64');
	self.health = 180;
	self.max_health = 180;
	self.mass = 300;
	self.scale = 0.7;

	self.th_stand = sentry_stand1;
	self.th_walk = sentry_walk1;
	self.th_run = sentry_run1;
	self.th_die = sentry_die;
	self.th_melee = sentry_MissileAttack; // one of two attacks
	self.th_missile = sentry_MissileAttack; // jump attack
	self.th_pain = sentry_pain;
//	self.th_checkatck = BerserkCheckAttack;
	self.th_spawn = spawn_sentry;
//	self.th_dodge = sentry_dodge;
	self.th_sight = sentry_sfx_sight;
	//setcustomskin (self, "progs/monsters/sentry/sentry.skin")
	self.deathtype = "was shot to death by a Sentry";
	self.pissed = 0;
	self.speed = 3;
	self.count = 0;

	self.flybob_horz = 0;
	self.flybob_vert = 3;
	self.flybob_strength = 25;

	flymonster_start();
};

//===========================================================================

void(vector off) sentry_shoot =
{
	vector dir, org;
	entity en;

	AutofireMachineEnemyNoise ();

// fire somewhat behind the player, so a dodging player is harder to hit
	en = self.enemy;

	makevectors(self.angles);
	org = ProjectAim(self.origin, off, v_forward, v_right);
	
	pointparticles (particleeffectnum("TE_MUZZLEFLASH2"), org + v_forward * 24, '0 0 0');
	pointparticles (particleeffectnum("EF_MUZZLEFLASH2"), org, '0 0 0');

	dir = en.origin - en.velocity*0.15;
	dir = normalize(dir - org);

	monster_FireBullets (1, org, dir, '0.05 0.05 0', 2, 2, 2000);
}

