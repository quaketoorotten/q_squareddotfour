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

void() tactical_stand1 = [ 1, tactical_stand2 ] { ai_stand(); self.monster_frame = 0;};
void() tactical_stand2 = [ self.frame, tactical_stand2 ] 
{ 	
	self.monster_frame ++;
	if (self.monster_frame >= 29) 
	{	
		if (random() < 0.2)
			tactical_sfx_idle ();
		tactical_stand1 ();
		return;
	}
	ai_stand ();
};

void() tactical_walk1 = [ 2, tactical_walk2 ] { ai_walk(3); self.monster_frame = 0;};
void() tactical_walk2 = [ self.frame, tactical_walk2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 51) 
	{   
        if (random() < 0.2)
			tactical_sfx_idle ();
		tactical_walk1 ();
		return;
	}

	ai_walk (3);
};

void() tactical_run1 = [ 7, tactical_run2 ] { ai_run(self.speed); self.monster_frame = 0;};
void() tactical_run2 = [ self.frame, tactical_run2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 16) 
	{
		if (random() < 0.3)
			tactical_sfx_idle ();

		tactical_run1 ();
		return;
	}

    ai_run (self.speed);
};


void() tactical_evade =
{	
	makevectors(self.angles);
	tracebox (self.origin, self.mins, self.maxs, self.origin + v_right * 128, FALSE, self);
	float right = trace_fraction;

	tracebox (self.origin, self.mins, self.maxs, self.origin + v_right * -128, FALSE, self);
	float left = trace_fraction;

	float r = random();

	if (left == 1 && right == 1)
	{   
     //   tactical_sfx_growl ();
		if (r >= 0.5)
			tactical_runl1 ();
		else 
			tactical_runr1 ();
        self.strafe_time = time + 0.5 + random();
		return;
	}

	if (left == 1)
		{tactical_runl1 (); self.strafe_time = time + 0.5 + random();}
	else if (right == 1)
		{tactical_runr1 (); self.strafe_time = time + 0.5 + random();}

	if (left < 1 || right < 1)
	{	
        if (self.flags & FL_DODGED)
		    self.flags &= ~FL_DODGED;
        else
            self.th_run ();
		return;
	}
	
	self.nextthink = time;
};

//============================================================================================

void() tactical_walkl1 = [ 3, tactical_walkl2 ] 
{ 	ai_face();  self.nextthink = time + 0.04; self.monster_frame = 0;};
void() tactical_walkl2 = [ self.frame, tactical_walkl2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 29) 
	{	
		self.attack_state = AS_STRAIGHT;
		self.strafe_time = 0;
		tactical_run1 ();
		return;
	}

    if (self.monster_frame > 0) {
        ai_face();
    	M_walkmove (self.ideal_yaw + 90, 4);
    }

	self.nextthink = time + 0.04;
};

void() tactical_walkr1 = [ 4, tactical_walkr2 ] 
{ 	ai_face(); self.nextthink = time + 0.0; self.monster_frame = 0;};
void() tactical_walkr2 = [ self.frame, tactical_walkr2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 30)
	{	
		self.attack_state = AS_STRAIGHT;
		self.strafe_time = 0;
		tactical_run1 ();
		return;
	}

	if (self.monster_frame > 0) {
    	ai_face();
    	M_walkmove (self.ideal_yaw - 90, 4);
    }
	self.nextthink = time + 0.04;
};

void() tactical_walk_strf =
{	
	makevectors(self.angles);
	tracebox (self.origin, self.mins, self.maxs, self.origin + v_right * 128, FALSE, self);
	float right = trace_fraction;

	tracebox (self.origin, self.mins, self.maxs, self.origin + v_right * -128, FALSE, self);
	float left = trace_fraction;

    float r = random();

	if (left == 1 && right == 1)
	{   
     //   tactical_sfx_growl ();
		if (r >= 0.5)
			tactical_walkl1 ();
		else
			tactical_walkr1 ();

		return;
	}

	if (left == 1)
		{tactical_walkl1 (); }
	else if (right == 1)
		{tactical_walkr1 (); }

	if (left < 1 || right < 1)
	{	
        self.th_run ();
		self.strafe_time = 0;
		return;
	}
	
	self.nextthink = time;
};

//==============================================================================

void() tactical_runl1 = [ 5, tactical_runl2 ] 
{ 	ai_face();  self.nextthink = time + 0.04; self.monster_frame = 0;};
void() tactical_runl2 = [ self.frame, tactical_runl2 ] 
{ 
	self.monster_frame ++;
	if (self.strafe_time < time)
	{	
		self.attack_state = AS_STRAIGHT;
		self.strafe_time = 0;
        self.flags &= ~FL_DODGED;
		tactical_run1 ();
		return;
	}

	if (self.monster_frame >= 14) 
	{
		tactical_runl1 ();
		return;
	}	

    if (self.monster_frame > 0) {
        ai_face();
    	M_walkmove (self.ideal_yaw + 90, self.speed);
    }

	self.nextthink = time + 0.04;
};

void() tactical_runr1 = [ 6, tactical_runr2 ] 
{ 	ai_face(); self.nextthink = time + 0.0; self.monster_frame = 0;};
void() tactical_runr2 = [ self.frame, tactical_runr2 ] 
{ 
	self.monster_frame ++;
	if (self.strafe_time < time)
	{	
		self.attack_state = AS_STRAIGHT;
		self.flags &= ~FL_DODGED;
		self.strafe_time = 0;
		tactical_run1 ();
		return;
	}

	if (self.monster_frame >= 16) 
	{
		tactical_runr1 ();
		return;
	}	

	if (self.monster_frame > 0) {
    	ai_face();
    	M_walkmove (self.ideal_yaw - 90, self.speed);
    }
	self.nextthink = time + 0.04;
};

void() tactical_runb1 = [ 8, tactical_runb2 ] 
{ 	ai_face(); self.nextthink = time + 0.0; self.monster_frame = 0;};
void() tactical_runb2 = [ self.frame, tactical_runb2 ] 
{ 
	self.monster_frame ++;
	if (self.strafe_time < time) 
	{	
		self.attack_state = AS_STRAIGHT;
		self.flags &= ~FL_DODGED;
		self.strafe_time = 0;
		tactical_run1 ();
		return;
	}

	if (self.monster_frame >= 29) 
	{
		tactical_runb1 ();
		return;
	}	

	if (self.monster_frame > 0) {
    	ai_charge(-self.speed);
    }
	self.nextthink = time + 0.04;
};

void() tactical_run_strf =
{	
	makevectors(self.angles);
	tracebox (self.origin, self.mins, self.maxs, self.origin + v_right * 128, FALSE, self);
	float right = trace_fraction;

	tracebox (self.origin, self.mins, self.maxs, self.origin + v_right * -128, FALSE, self);
	float left = trace_fraction;

    tracebox (self.origin, self.mins, self.maxs, self.origin + v_forward * -128, FALSE, self);
    float back = trace_fraction;

    float r = rint(random()*3);

    if (r == 0)
        r = 1;

	if (left == 1 && right == 1 && back == 1)
	{   
     //   tactical_sfx_growl ();
		if (r == 1)
			tactical_runl1 ();
		else if (r == 2)
			tactical_runr1 ();
        else
            tactical_runb1 ();
		return;
	}

	if (left == 1)
		{tactical_runl1 (); }
	else if (right == 1)
		{tactical_runr1 (); }
    else if (back == 1)
		{tactical_runb1 (); }

	if (left < 1 || right < 1  || back < 1)
	{	
        self.th_run ();
		self.strafe_time = 0;
		return;
	}
	
	self.nextthink = time;
};

//==============================================================================

static void(entity target, string name) tactical_tag_entity =
{
	float tagindex = gettagindex (target, self.netname);
	vector taginf = gettaginfo(target, tagindex);

	entity e ;
	e = spawn();
	e.origin = taginf;
	setmodel(e, "progs/muzzleflash.spr");
	setsize(e, VEC_ORIGIN, VEC_ORIGIN);
	//setattachment (e, target, "tag_point");

	e.traileffectnum = particleeffectnum(name);
	e.owner = target;
	target.prelock_save = e;
};

static void() tactical_tag_think =
{	
	self.frame = self.owner.monster_frame;
	if (self.frame >= self.dspeed || self.owner.frame != self.ltime )
	{	
		if (self.prelock_save)
			remove(self.prelock_save);

		remove(self);
		return;
	}

	setorigin(self, self.owner.origin);
	self.angles = self.owner.angles;

	float tagindex = gettagindex (self, self.netname);
	vector taginf = gettaginfo(self, tagindex);

	float tagindex2 = gettagindex (self, self.netname2);
	vector taginf2 = gettaginfo(self, tagindex2);
	//bprint(ftos(self.prelock_save.traileffectnum), "\n");

	if (self.prelock_save)
	{
		self.prelock_save.origin = taginf;
	//	self.locked_enemy.origin = taginf2;
	//	bprint(vtos(taginf), "\n");
	}
		
	else
		self.owner.pos2 = taginf;
	
	self.think = tactical_tag_think;
	self.angles = self.owner.angles;
	self.nextthink = time;
}

static void(string stringg, float fr, float end, string name, string tag) tactical_tag = 
{	
//	bprint("???", "\n");
	local entity e;
	e= spawn();
	setmodel(e, stringg);
	setsize(e, self.mins, self.maxs);
	e.solid = SOLID_NOT;
	setorigin(e, self.origin);
	e.frame = self.monster_frame;
	e.scale = self.scale;
	e.owner = self;
	e.ltime = fr;
	e.dspeed = end;

	if (name != string_null)
		tactical_tag_entity(e, name);

	e.netname = tag;
	e.think = tactical_tag_think;
	e.nextthink = time;

	if (tag == string_null)
		self.prelock_save = e;
}

//==============================================================================

void() tactical_missilea1 = [ 20, tactical_missilea2 ] {
	self.monster_frame = 0;
	self.count = 0;
	tactical_tag ("progs/monsters/tactical/muzzleflash_tags_std.md3", 20, 999, string_null, string_null);
	ai_face(); self.nextthink = time + 0.02;  };
void() tactical_missilea2 = [ self.frame, tactical_missilea2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.02;

	if (self.monster_frame == 1 && self.pissed > 0)
	{
		tactical_shoot("MG_muzzle");
		self.count ++;
		self.pissed --;
	}

	if (self.monster_frame >= 6) 
	{   
        self.monster_frame = 0;
	}

	if (self.count >= self.weapontype || self.pissed <= 0) 
	{   
        tactical_evade ();
		return;
	}

	ai_face ();
};

void() tactical_missileb1 = [ 14, tactical_missileb2 ] {
	self.monster_frame = 0;
	self.count = 0;
	tactical_tag ("progs/monsters/tactical/muzzleflash_tags_std.md3", 14, 999, string_null, string_null);
	ai_face(); self.nextthink = time + 0.04;  };
void() tactical_missileb2 = [ self.frame, tactical_missileb2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 1 && self.pissed > 0)
	{
		tactical_shoot("MG_muzzle");
		self.count ++;
		self.pissed --;
	}

	if (self.monster_frame >= 6) 
	{   
        self.monster_frame = 0;
	}

	if (self.count >= self.weapontype || self.pissed <= 0) 
	{   
        tactical_run1 ();
		return;
	}

	ai_face ();
};

void() tactical_aim1 = [ 1, tactical_aim2 ] {
	self.monster_frame = 0;
	self.count = 0;
	self.pos1 = self.enemy.origin;
//	tactical_tag ("progs/monsters/tactical/muzzleflash_tags_std.md3", 14, 999, string_null, string_null);
	ai_face(); self.nextthink = time + 0.02;  };
void() tactical_aim2 = [ self.frame, tactical_aim2 ] 
{ 
	
	self.monster_frame ++;
	self.nextthink = time + 0.02;

	if (visible(self.enemy) && self.monster_frame == 20)
	{	
		self.pos1 = self.enemy.origin;
	}

	if (self.monster_frame >= 29) 
	{   
        tactical_sfx_growl ();
        tactical_missileb1 ();
		return;
	}

	ai_face ();
};

void() tactical_reloada1 = [ 15, tactical_reloada2 ] {
	self.monster_frame = 0;
	self.count = 0;
//	tactical_tag ("progs/monsters/tactical/muzzleflash_tags_std.md3", 14, 999, string_null, string_null);
	ai_face(); self.nextthink = time + 0.04;  };
void() tactical_reloada2 = [ self.frame, tactical_reloada2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 20)
	{
		tactical_sfx_reload (2);
	}

	if (self.monster_frame == 39)
	{
		tactical_sfx_reload (1);
	}

	if (self.monster_frame >= 65) 
	{   
		self.pissed = self.ammotype;
        tactical_evade ();
		return;
	}
};


//==============================================================================

void() tactical_meleea1 = [ 12, tactical_meleea2 ] {
	self.monster_frame = 0;
	//tactical_tag ("progs/monsters/tactical/melee1_tag.md3", 28, 16, "TE_WHOOSH", "Empty");
	ai_face(); self.nextthink = time + 0.02;  };
void() tactical_meleea2 = [ self.frame, tactical_meleea2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.02;

	if (self.monster_frame == 37)
		tactical_Melee(0);

	if (self.monster_frame >= 74) 
	{   
        tactical_evade ();
		return;
	}

	if (self.monster_frame < 20)
		ai_charge (0.5);

    if (self.monster_frame > 20 &&self.monster_frame < 54)
		ai_charge (3);

	if (self.monster_frame > 54)
		ai_charge (-0.5);
};

void() tactical_meleeb1 = [ 13, tactical_meleeb2 ] {
	self.monster_frame = 0;
  	//tactical_tag ("progs/monsters/tactical/melee2_tag.md3", 29, 14, "TE_WHOOSH", "Empty");
	ai_face(); self.nextthink = time + 0.027;  };
void() tactical_meleeb2 = [ self.frame, tactical_meleeb2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.027;

	if (self.monster_frame == 14)
		tactical_Melee(0);

	if (self.monster_frame >= 46) 
	{   
        tactical_walk_strf ();
		return;
	}

    if (self.monster_frame < 38)
		ai_charge (2.5);

	if (self.monster_frame > 38)
		ai_charge (-0.5);
};

//==============================================================================

void() tactical_MeleeAttack =
{	
	tactical_sfx_growl ();

	//if(random() <= 0.5)
	//	tactical_meleea1 ();
	//else
		tactical_meleeb1 ();

};

void() tactical_MissileAttack =
{   
	if (random() <= 0.4)
	{
		if (self.pissed < self.weapontype)
		{
			tactical_reload ();
			return;
		}
	}

	tactical_sfx_chatter ();

	if (self.weaponname == "weapon_railgun")
	{
		tactical_aim1 ();
		return;
	}

	if (self.weaponname == "weapon_shotgun")
		tactical_missileb1 ();
	else
		tactical_missilea1 ();
};

void() tactical_reload =
{   
	tactical_reloada1 ();
};

//==============================================================================

// regular ow
void() tactical_paina1 = [ 16, tactical_paina2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() tactical_paina2 = [ self.frame, tactical_paina2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint("????", "\n");
	if (self.monster_frame >= 17) 
	{
		tactical_run1 ();
		return;
	}
};

void() tactical_painb1 = [ 17, tactical_painb2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() tactical_painb2 = [ self.frame, tactical_painb2 ] 
{   
    //bprint(ftos(self.frame), "\n");
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint(">>>>>>>>>>?????", "\n");
	if (self.monster_frame >= 33) 
	{
		tactical_run1 ();
		return;
	}
};

// concussion
void() tactical_painc1 = [ 18, tactical_painc2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() tactical_painc2 = [ self.frame, tactical_painc2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	// bprint("????", "\n");
	if (self.monster_frame >= 35) 
	{   
		tactical_run1 ();
		return;
	}
};

void(entity attacker, float damage, float MOD) tactical_pain =
{
	if (self.attack_state == AS_SLIDING)
	{
		return;
	}

	if (self.flags & FL_DODGED)
	{	
		return;
	}

	if (self.pain_finished > time)
		return;

	self.pain_finished = time + 2;
	tactical_sfx_pain (); // sfx

	if (DMGTYPE_LTNG == MOD)
	{
	     tactical_paina1 ();
		
		if (skill < 2)
			self.pain_finished = time + 0.5;
		else
			self.pain_finished = time + 1.5;
		return;
	}

	if (MOD == DMGTYPE_RAIL)
	{   
         if (random() <= 0.5)
            tactical_painc1 ();
        else
            tactical_painb1 ();

		self.pain_finished = time + 2.5;
		return;
	}

	if (random()*120 > damage)
		return; // didn't flinch

	if (damage > 80 || MOD == DMGTYPE_EXP)
	{   
         if (random() <= 0.5)
            tactical_painc1 ();
        else
            tactical_painb1 ();
		return;
	}
    
    tactical_paina1 ();
};

void() tactical_die =
{	
	////setmodel(self, "progs/monsters/tactical_transfer/tactical_mesh_death.iqm");
	//setsize(self, '-32 -32 0', '32 32 64');
	//self.angles = '-90 0 0';
	if (self.health < -60)
	{	
		self.deadflag = DEAD_DEAD;
		self.solid = SOLID_NOT;
		MonsterGib (self.health); 
		remove(self);
		return;
	}
	
	if((self.deadflag & DEAD_DEAD))
		return;

	tactical_sfx_death ();

	local vector tmpangle;
	local float tempskin;
	tmpangle = self.angles;
	tempskin = self.skin;
	
	if (random() <= 0.3)
		self.think = tactical_die1;
	else
		self.think = tactical_dieb1;

	self.deadflag = DEAD_DEAD;
	self.solid = SOLID_CORPSE;
//	self.movetype = MOVETYPE_STEP;
	self.nextthink = time + 0.04;

	self.angles = tmpangle;
	//self.skin = tempskin;
};

void() tactical_die1 = [ 21 , tactical_die2 ] { self.nextthink = time + 0.04; self.monster_frame = 0;};
void() tactical_die2 = [ self.frame , tactical_die2 ] 
{ 	
	//self.frame |= 0x8000;
	self.nextthink = time + 0.04;
	self.monster_frame ++;

	if (self.monster_frame == 76)
	{
		self.maxs_z = 12;
		self.nextthink = -1;
		self.think = tactical_fade1;
		self.nextthink = time + 3.5;
		self.cnt = 1;
		return;
	}
};

void() tactical_dieb1 = [ 22 , tactical_dieb2 ] { self.nextthink = time + 0.04; self.monster_frame = 0;};
void() tactical_dieb2 = [ self.frame , tactical_dieb2 ] 
{ 	
	//self.frame |= 0x8000;
	self.nextthink = time + 0.04;

	if (self.monster_frame < 9)
		ai_move (-4);
	
	self.monster_frame ++;
	if (self.monster_frame == 28)
	{
		self.maxs_z = 12;
		self.nextthink = -1;
		self.think = tactical_fade1;
		self.nextthink = time + 3.5;
		return;
	}
};

void() tactical_fade1 = [ self.frame, tactical_gib2 ] 
{	
	if (self.cnt == 1)
		self.frame = 0;
	else
		self.frame = 1;
	
	setmodel(self, "progs/monsters/tactical/tactical_death.iqm");
	setsize(self, '-16 -16 0', '16 16 12');

//	self.skin = 1; 
	self.alpha = 1; 
	self.glowmod = '0.5 0.5 0.5'; 
	self.nextthink = time + 0.02;
};

void() tactical_gib1 = [ self.frame, tactical_gib2 ] 
{MonsterGib (self.health); self.skin = 1; self.alpha = 1; self.nextthink = time + 0.02;};

void() tactical_gib2 = [ self.frame, tactical_gib2 ] 
{ 	
	self.nextthink = time + 0.02;
	self.alpha -= 0.02;
	if (self.alpha <= 0)
	{
		remove(self);
		return;
	}
};

static string clip_list[4] = 
{
	"sounds_q4/strogg/tactical_transfer/mgun_clipin.wav",
	"sounds_q4/strogg/tactical_transfer/mgun_clipout.wav",
	"sounds_q4/strogg/tactical_transfer/shotgun_clipin.wav",
	"sounds_q4/strogg/tactical_transfer/shotgun_clipout.wav",
};	

static void(float i) tactical_sfx_reload =
{	
	if (self.weaponname == "weapon_shotgun")
		i = i + 2;

	sound(self, CHAN_RELOAD, clip_list[i - 1], 1, ATTN_NORM);
};

static string growl_list[4] = 
{
	"sounds_q4/strogg/tactical_transfer/growl1.wav",
	"sounds_q4/strogg/tactical_transfer/growl2.wav",
	"sounds_q4/strogg/tactical_transfer/growl3.wav",
	"sounds_q4/strogg/tactical_transfer/growl4.wav",
};	

static void() tactical_sfx_growl =
{
	local float r = rint(random() * 3);	

	sound(self, CHAN_VOICE, growl_list[r], 1, ATTN_NORM);
};

static string death_list[3] = 
{
	"sounds_q4/strogg/tactical_transfer/die2.wav",
	"sounds_q4/strogg/tactical_transfer/die3.wav",
	"sounds_q4/strogg/tactical_transfer/die1.wav",
};	

static void() tactical_sfx_death =
{
	local float r = rint(random() * 2);	

	sound(self, CHAN_VOICE, death_list[r], 1, ATTN_NORM);
};

static void() tactical_sfx_idle =
{
	local float r = rint(random() * 14);	

	sound(self, CHAN_VOICE, chat_list[r], 1, ATTN_IDLE);
};

static string chat_list[15] = 
{
	"sounds_q4/strogg/tactical_transfer/chatter3.wav",
	"sounds_q4/strogg/tactical_transfer/chatter4.wav",
	"sounds_q4/strogg/tactical_transfer/chatter5.wav",
	"sounds_q4/strogg/tactical_transfer/chatter6.wav",
	"sounds_q4/strogg/tactical_transfer/chatter7.wav",
	"sounds_q4/strogg/tactical_transfer/chatter8.wav",
	"sounds_q4/strogg/tactical_transfer/chatter9.wav",
	"sounds_q4/strogg/tactical_transfer/chatter10.wav",
	"sounds_q4/strogg/tactical_transfer/chatter11.wav",
	"sounds_q4/strogg/tactical_transfer/chatter12.wav",
	"sounds_q4/strogg/tactical_transfer/chatter13.wav",
	"sounds_q4/strogg/tactical_transfer/chatter14.wav",
	"sounds_q4/strogg/tactical_transfer/chatter15.wav",
	"sounds_q4/strogg/tactical_transfer/chatter2.wav",
	"sounds_q4/strogg/tactical_transfer/chatter1.wav",
};	

static void() tactical_sfx_chatter =
{
	local float r = rint(random() * 14);	

	sound(self, CHAN_VOICE, chat_list[r], 1, ATTN_NORM);
};

static string pain_list[5] = 
{
	"sounds_q4/strogg/tactical_transfer/pain1.wav",
	"sounds_q4/strogg/tactical_transfer/pain2.wav",
	"sounds_q4/strogg/tactical_transfer/pain3.wav",
	"sounds_q4/strogg/tactical_transfer/pain4.wav",
	"sounds_q4/strogg/tactical_transfer/pain5.wav",
};	

static void() tactical_sfx_pain =
{
	local float r = rint(random() * 4);	

	sound(self, CHAN_VOICE, pain_list[r], 1, ATTN_NORM);
};

static string sight_list[13] = 
{
	"sounds_q4/strogg/tactical_transfer/sight3.wav",
	"sounds_q4/strogg/tactical_transfer/sight4.wav",
	"sounds_q4/strogg/tactical_transfer/sight5.wav",
	"sounds_q4/strogg/tactical_transfer/sight6.wav",
	"sounds_q4/strogg/tactical_transfer/sight7.wav",
	"sounds_q4/strogg/tactical_transfer/sight8.wav",
	"sounds_q4/strogg/tactical_transfer/sight9.wav",
	"sounds_q4/strogg/tactical_transfer/sight10.wav",
	"sounds_q4/strogg/tactical_transfer/sight11.wav",
	"sounds_q4/strogg/tactical_transfer/sight12.wav",
	"sounds_q4/strogg/tactical_transfer/sight13.wav",
	"sounds_q4/strogg/tactical_transfer/sight2.wav",
	"sounds_q4/strogg/tactical_transfer/sight1.wav",
};	

void() tactical_sfx_sight =
{   
	local float r = rint(random() * 12);	

	sound(self, CHAN_VOICE, sight_list[r], 1, ATTN_NORM);
};

/*QUAKED monster_demon (1 0 0) (-32 -32 -24) (32 32 64) Ambush

*/
void() monster_tactical_cache =
{
	precache_model("progs/monsters/tactical/tactical_transfer.md5.info");
	precache_model("progs/monsters/tactical/tactical_transfer_hb.md5.info");
	precache_model("progs/monsters/tactical/tactical_transfer_rg.md5.info");
	precache_model("progs/monsters/tactical/tactical_transfer_sg.md5.info");
	precache_model("progs/monsters/tactical/muzzleflash_tags_std.md3");
	precache_model("progs/monsters/tactical/tactical_death.iqm");

//    precache_model("progs/monsters/tactical_transfer/tactical_shield_mesh.md5.info");

	precache_sound("sounds_q4/strogg/tactical_transfer/sight3.wav");
    precache_sound("sounds_q4/strogg/tactical_transfer/sight4.wav");
	precache_sound("sounds_q4/strogg/tactical_transfer/sight5.wav");
	precache_sound("sounds_q4/strogg/tactical_transfer/sight6.wav");
	precache_sound("sounds_q4/strogg/tactical_transfer/sight7.wav");
    precache_sound("sounds_q4/strogg/tactical_transfer/sight8.wav");
	precache_sound("sounds_q4/strogg/tactical_transfer/sight9.wav");
	precache_sound("sounds_q4/strogg/tactical_transfer/sight10.wav");
    precache_sound("sounds_q4/strogg/tactical_transfer/sight11.wav");
	precache_sound("sounds_q4/strogg/tactical_transfer/sight12.wav");
	precache_sound("sounds_q4/strogg/tactical_transfer/sight13.wav");

 	precache_sound("sounds_q4/strogg/tactical_transfer/die2.wav");
	precache_sound("sounds_q4/strogg/tactical_transfer/die3.wav");	
	precache_sound("sounds_q4/strogg/tactical_transfer/die1.wav");	

	precache_sound("sounds_q4/strogg/tactical_transfer/pain1.wav");
	precache_sound("sounds_q4/strogg/tactical_transfer/pain2.wav");
	precache_sound("sounds_q4/strogg/tactical_transfer/pain3.wav");
    precache_sound("sounds_q4/strogg/tactical_transfer/pain4.wav");
    precache_sound("sounds_q4/strogg/tactical_transfer/pain5.wav");

	precache_sound("sounds_q4/strogg/tactical_transfer/growl1.wav");
	precache_sound("sounds_q4/strogg/tactical_transfer/growl2.wav");
	precache_sound("sounds_q4/strogg/tactical_transfer/growl3.wav");
    precache_sound("sounds_q4/strogg/tactical_transfer/growl4.wav");

	precache_sound("sounds_q4/strogg/tactical_transfer/shotgun_clipin.wav");
    precache_sound("sounds_q4/strogg/tactical_transfer/shotgun_clipout.wav");
	precache_sound("sounds_q4/strogg/tactical_transfer/shotgun_fire.wav");

	precache_sound("sounds_q4/strogg/tactical_transfer/m_gun1.wav");
	precache_sound("sounds_q4/strogg/tactical_transfer/m_gun2.wav");
	precache_sound("sounds_q4/strogg/tactical_transfer/mgun_clipin.wav");
    precache_sound("sounds_q4/strogg/tactical_transfer/mgun_clipout.wav");

	for (float i=0;i<13;i++)
		precache_sound(sight_list[i]);

	for (float i=0;i<15;i++)
		precache_sound(chat_list[i]);

	precache_sound("sounds_q4/strogg/stroggmarine/weapon_slap.wav");	
//	precache_sound("sounds_q4/monsters/tactical_transfer/slash.wav");	

//	spawn_demon ();
};

void() monster_tactical_mg =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	monster_tactical_cache ();	

	self.weaponname = "weapon_machinegun";
    self.pissed = 40; // clip
    self.ammotype = 40; // max clip
    self.weapontype = 12; // shot count per fire
	spawn_tactical ();
};

void() monster_tactical_hb =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	monster_tactical_cache ();	

	self.weaponname = "weapon_hyperblaster";
    self.pissed = 60; // clip
    self.ammotype = 60; // max clip
    self.weapontype = 8; // shot count per fire
	spawn_tactical ();
};

void() monster_tactical_sg =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	monster_tactical_cache ();	

	self.weaponname = "weapon_shotgun";
    self.pissed = 8; // clip
    self.ammotype = 8; // max clip
    self.weapontype = 1; // shot count per fire
	spawn_tactical ();
};

void() monster_tactical_rg =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	monster_tactical_cache ();	

	self.weaponname = "weapon_railgun";
    self.pissed = 2; // clip
    self.ammotype = 2; // max clip
    self.weapontype = 1; // shot count per fire
	spawn_tactical ();
};

void() spawn_tactical =
{
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	self.classname = "monster_tactical";

	if (self.weaponname == "weapon_machinegun")
		setmodel(self, "progs/monsters/tactical/tactical_transfer.md5.info");
	if (self.weaponname == "weapon_shotgun")
		setmodel(self, "progs/monsters/tactical/tactical_transfer_sg.md5.info");
	if (self.weaponname == "weapon_railgun")
		setmodel(self, "progs/monsters/tactical/tactical_transfer_rg.md5.info");
	if (self.weaponname == "weapon_hyperblaster")
		setmodel(self, "progs/monsters/tactical/tactical_transfer_hb.md5.info");

	setsize(self, '-16 -16 0', '16 16 56');

	self.health = 225;
	self.max_health = 225;
	self.mass = 300; 
	self.scale = 0.8;

	self.th_stand = tactical_stand1;
	self.th_walk = tactical_walk1;
	self.th_run = tactical_run1;
	self.th_die = tactical_die;
	self.th_melee = tactical_MeleeAttack; // one of two attacks
	self.th_missile = tactical_MissileAttack; // jump attack
	self.th_pain = tactical_pain;
	self.th_checkatck = TacticalCheckAttack;
	self.th_spawn = spawn_tactical;
	self.th_dodge = tactical_evade;
	self.th_sight = tactical_sfx_sight;
	//setcustomskin (self, "progs/monsters/tactical_transfer/soldier.skin")
	self.deathtype = "was outsmarted by a Tactical Strogg";
	self.count = 0;
    self.speed = 4;
	self.strafe_time = 0;

    self.flags |= FL_TACTICAL;

	walkmonster_start();
};

/*
==============================================================================

DEMON

==============================================================================
*/

float() TacticalCheckAttack =
{
	local vector	spot1, spot2;	
	local entity	targ;
	local float		chance;

	targ = self.enemy;
	
// see if any entities are in the way of the shot
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;

	traceline (spot1, spot2, FALSE, self);
	
	if (trace_ent != targ)
		return FALSE;		// don't have a clear shot
			
	if (trace_inopen && trace_inwater)
		return FALSE;			// sight line crossed contents

	if (enemy_range == RANGE_MELEE)
	{	
		if (rand() & 3)
		{
			tactical_walk_strf ();

			self.strafe_time = 0;
			self.attack_state = AS_SLIDING;
			return FALSE;
		}
		else
		{	
			if (random() >= 0.4)
				self.attack_state = AS_MELEE;
			else
				self.attack_state = AS_MISSILE;
		}
		return TRUE;
	}
	
// missile attack
	
	if (self.flags & FL_DODGED)
		return FALSE;
		
	if (time < self.attack_finished)
	{	
        if (self.pissed <= 0)
        {
	        tactical_reload ();
            return FALSE;
        }

		if (self.weaponname == "weapon_hyperblaster" || self.weaponname == "weapon_shotgun")
		{
			if (random() <= 0.6)
				return FALSE;
		}

		if ((vlen(spot1 - spot2) <= 200) && self.strafe_time < time)
		{	
			tactical_walk_strf ();

			self.strafe_time = 0;
			self.attack_state = AS_SLIDING;
			return FALSE;
		}

		if ((vlen(spot1 - spot2) <= 700) && self.strafe_time < time)
		{	
			tactical_run_strf ();

			self.strafe_time = time + (1 + random());
			self.attack_state = AS_SLIDING;
			return FALSE;
		}
		return FALSE;
	}
		
	if (enemy_range == RANGE_FAR)
		return FALSE;
	

	if (self.weaponname == "weapon_hyperblaster" || self.weaponname == "weapon_shotgun")
	{
		if (enemy_range == RANGE_MELEE)
			chance = 0.3;
		else if (enemy_range == RANGE_CLOSE)
			chance = 0.25;
		else if (enemy_range == RANGE_NEAR)
			chance = 0.1;
		else if (enemy_range == RANGE_MID)
			chance = 0.05;
		else
			return FALSE;
	}
	else
	{
		if (enemy_range == RANGE_MELEE)
			chance = 0.1;
		else if (enemy_range == RANGE_CLOSE)
			chance = 0.25;
		else if (enemy_range == RANGE_NEAR)
			chance = 0.3;
		else if (enemy_range == RANGE_MID)
			chance = 0.1;
		else
			return FALSE;
	}


	if (random () < chance)
	{
		self.attack_state = AS_MISSILE;

		if (self.weaponname == "weapon_railgun")
			SUB_AttackFinished (1.5 + 4*random());
		else
			SUB_AttackFinished (1 + 2*random());
		return TRUE;
	}

	return FALSE;
};

void(string cannon) tactical_shoot = 
{   
	float r = rint(random()*2);

    vector dir, org;
	entity en;

	if (self.weaponname == "weapon_shotgun")
	{
		sound(self, CHAN_WEAPON, "sounds_q4/strogg/tactical_transfer/shotgun_fire.wav", 1, ATTN_NORM);
		cannon = "SG_muzzle";
	}
	if (self.weaponname == "weapon_machinegun")
	{
		if(random() >= 0.5)
			sound(self, CHAN_WEAPON, "sounds_q4/strogg/tactical_transfer/m_gun1.wav", 1, ATTN_NORM);
		else	
			sound(self, CHAN_WEAPON, "sounds_q4/strogg/tactical_transfer/m_gun2.wav", 1, ATTN_NORM);
		cannon = "MG_muzzle";
	}
	if (self.weaponname == "weapon_hyperblaster")
	{
		if (random() <= 0.5)
			sound(self, CHAN_WEAPON, "sounds_q4/weapons/hyperblaster/fire1.wav", 1, ATTN_NORM);
		else
			sound(self, CHAN_WEAPON, "sounds_q4/weapons/hyperblaster/fire2.wav", 1, ATTN_NORM);
		cannon = "HB_muzzle";
	}
    if (self.weaponname == "weapon_railgun")
    {
    	if (r == 2)
    		sound(self, CHAN_WEAPON, "sounds_q4/weapons/railgun/fire01.wav", 1, ATTN_NORM);
    	else if (r == 1)
    		sound(self, CHAN_WEAPON, "sounds_q4/weapons/railgun/fire02.wav", 1, ATTN_NORM);
    	else
	    	sound(self, CHAN_WEAPON, "sounds_q4/weapons/railgun/fire03.wav", 1, ATTN_NORM);
		cannon = "HB_muzzle";
    }

// fire somewhat behind the player, so a dodging player is harder to hit
	en = self.enemy;

//	makevectors(self.angles);
	float tagindex = gettagindex (self.prelock_save, cannon);
	org = gettaginfo (self.prelock_save, tagindex);
	
	pointparticles (particleeffectnum("TE_MUZZLEFLASH2"), org , '0 0 0');
	pointparticles (particleeffectnum("EF_MUZZLEFLASH2"), org , '0 0 0');

	dir = en.origin - en.velocity*0.15 + en.view_ofs;

	if (self.weaponname == "weapon_railgun")
		dir = self.pos1 + self.enemy.view_ofs;

	makevectors(self.angles);
	org = org + v_forward * -32 + v_up *-4;
	dir = normalize(dir - org);

	if (self.weaponname == "weapon_hyperblaster")
		LaunchLaser (org, dir, '0 0 0', '0 0 0');
	if (self.weaponname == "weapon_shotgun")
		monster_FireBullets (6, org, dir, '0.1 0.1 0', 5, 6, 7500);
	if (self.weaponname == "weapon_machinegun")
		monster_FireBullets (1, org, dir, '0.05 0.05 0', 3, 2, 2000);
	if (self.weaponname == "weapon_railgun")
		fireRail (org, dir, self, self, 30, 40, 2048);
};

void(float bool) tactical_Melee =
{
	float ldmg;

	ai_face();

	ldmg = 10 + 10*random();
	vector	aim;

	aim = setvector (100, 0, 0);
	if (fire_hit(aim, rint(ldmg), 10))
	{	
	//	if (bool == 1)
			sound(self, CHAN_WEAPON, "sounds_q4/strogg/stroggmarine/weapon_slap.wav", 1, ATTN_NORM);
	}
	else
	{
		meat_miss();

	}
};


//===========================================================================
