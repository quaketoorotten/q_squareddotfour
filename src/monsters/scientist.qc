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

void() scientist_stand1 = [ 1, scientist_stand2 ] { ai_stand(); self.monster_frame = 0;};
void() scientist_stand2 = [ self.frame, scientist_stand2 ] 
{ 	
	self.monster_frame ++;
	if (self.monster_frame >= 149) 
	{	
        if (random() < 0.2)
	    	scientist_sfx_idle ();
		scientist_stand1 ();
		return;
	}
	ai_stand ();
};

void() scientist_walk1 = [ 2, scientist_walk2 ] { ai_walk(3); self.monster_frame = 0;};
void() scientist_walk2 = [ self.frame, scientist_walk2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 74) 
	{
        if (random() < 0.2)
	    	scientist_sfx_idle ();
		scientist_walk1 ();
		return;
	}
	ai_walk (3);
};

void() scientist_run1 = [ 3, scientist_run2 ] { ai_run(self.speed); self.monster_frame = 0;};
void() scientist_run2 = [ self.frame, scientist_run2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 74) 
	{
        if (random() < 0.2)
	    	scientist_sfx_idle ();
		scientist_run1 ();
		return;
	}
	ai_run (self.speed);
};

//==============================================================================

void() scientist_strafel1 = [ 3, scientist_strafel2 ] 
{ 	ai_flybob_face();  self.nextthink = time + 0.04; self.monster_frame = 0;};
void() scientist_strafel2 = [ self.frame, scientist_strafel2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 13) 
	{	
		//self.attack_state = AS_STRAIGHT;
		self.flags &= ~FL_DODGED;
	//	despawn_shield ();
		scientist_run1 ();
		return;
	}

    if (self.monster_frame > 1 && self.monster_frame < 12) {
    	M_walkmove (self.ideal_yaw + 90, 7);
    }

	self.nextthink = time + 0.04;
};

void() scientist_strafer1 = [ 4, scientist_strafer2 ] 
{ 	ai_flybob_face(); self.nextthink = time + 0.0; self.monster_frame = 0;};
void() scientist_strafer2 = [ self.frame, scientist_strafer2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 13) 
	{	
		//self.attack_state = AS_STRAIGHT;
		self.flags &= ~FL_DODGED;
	//	despawn_shield ();
		scientist_run1 ();
		return;
	}

	if (self.monster_frame > 1 && self.monster_frame < 12) {
    	M_walkmove (self.ideal_yaw - 90, 7);
    }
	self.nextthink = time + 0.04;
};


void() scientist_strafe =
{	
	makevectors(self.angles);
	tracebox (self.origin, self.mins, self.maxs, self.origin + v_right * 128, FALSE, self);
	float right = trace_fraction;

	tracebox (self.origin, self.mins, self.maxs, self.origin + v_right * -128, FALSE, self);
	float left = trace_fraction;

	if (left == 1 && right == 1)
	{   
     //   scientist_sfx_growl ();
		if (random() <= 0.5)
			scientist_strafel1 ();
		else 
			scientist_strafer1 ();
		return;
	}

	if (left == 1)
		{scientist_strafel1 (); }
	else if (right == 1)
		{scientist_strafer1 (); }

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

//==============================================================================

// fire
void() scientist_missilea1 = [ 10, scientist_missilea2 ] 
{	self.monster_frame = 0; self.count =0;

	scientist_tag ("progs/monsters/scientist/throw_object_tag.md3", 10, 9, string_null, "Empty");
//	scientist_tag ("progs/monsters/scientist/throw_object_tag.md3", 10, 12, "EF_GASTRAIL2", "Empty");
ai_flybob_face(); self.nextthink = time + 0.04;  };
void() scientist_missilea2 = [ self.frame, scientist_missilea2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 11)
	{	
		scientist_shoot ();
	}

	if (self.monster_frame == 6)
	{	
		scientist_flash ();
	}

	if (self.monster_frame >= 29) 
	{	
		scientist_strafe ();
		return;
	}

    ai_flybob_face ();
};


// wtf is inky cloud quake 4 ?
void() scientist_missileb1 = [ 11, scientist_missileb2 ] 
{	self.monster_frame = 0; self.count =0;
ai_flybob_face(); self.nextthink = time + 0.04;  };
void() scientist_missileb2 = [ self.frame, scientist_missileb2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 6) 
	{
		scientist_shoot ();
	}
	
	if (self.monster_frame >= 18) 
	{	
		scientist_run1 ();
		return;
	}

    ai_flybob_face ();
};

//==================================================================================

static void(entity target, string name) scientist_tag_entity =
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

static void() scientist_tag_think =
{	
	self.frame = self.owner.monster_frame;
	if (self.frame >= self.dspeed || self.owner.frame != self.ltime )
	{	
		if (self.prelock_save)
			remove(self.prelock_save);

		remove(self);
		return;
	}

	setorigin(self, self.owner.origin +'0 0 -8');
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
	
	self.think = scientist_tag_think;
	self.angles = self.owner.angles;
	self.nextthink = time;
}

static void(string stringg, float fr, float end, string name, string tag) scientist_tag = 
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
		scientist_tag_entity(e, name);

	e.netname = tag;
	e.think = scientist_tag_think;
	e.nextthink = time;
}

void() scientist_meleea1 = [ 6, scientist_meleea2 ] 
{	self.monster_frame = 0; self.count =0;
	scientist_tag ("progs/monsters/scientist/melee_tool_tag.md3", 6, 26, "TE_WHOOSH", "Empty");
ai_flybob_face(); self.nextthink = time + 0.04;  };
void() scientist_meleea2 = [ self.frame, scientist_meleea2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 9) 
	{
		scientist_Melee ();
	}

	if (self.monster_frame > 18 && self.monster_frame < 21)
        scientist_Saw ();
	
	if (self.monster_frame >= 34) 
	{	
		scientist_strafe ();
		return;
	}

    ai_charge (3);
};

void() scientist_meleeb1 = [ 7, scientist_meleeb2 ] 
{	self.monster_frame = 0; self.count =0;
	scientist_tag ("progs/monsters/scientist/melee_front_arms_tag_arm.md3", 7, 13, "TE_WHOOSH", "Empty");
ai_flybob_face(); self.nextthink = time + 0.04;  };
void() scientist_meleeb2 = [ self.frame, scientist_meleeb2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 8) 
	{
		scientist_Melee ();
	}

	if (self.monster_frame == 18)
		scientist_tag ("progs/monsters/scientist/melee_front_arms_tag_saw.md3", 7, 26, "TE_WHOOSH", "Empty");

    if (self.monster_frame > 19 && self.monster_frame < 23)
        scientist_Saw ();
	
	if (self.monster_frame >= 39) 
	{	
		scientist_strafe ();
		return;
	}

    ai_charge (3);
        
};

void() scientist_meleec1 = [ 8, scientist_meleec2 ] 
{	self.monster_frame = 0; self.count =0;
	scientist_tag ("progs/monsters/scientist/melee_lunge_syringe.md3", 8, 9, "TE_WHOOSH", "Empty");
ai_flybob_face(); self.nextthink = time + 0.04;  };
void() scientist_meleec2 = [ self.frame, scientist_meleec2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 7 || self.monster_frame == 15) 
	{
		scientist_Melee ();
	}

    if (self.monster_frame > 11 && self.monster_frame < 15)
        scientist_Saw ();

	if (self.monster_frame > 23 && self.monster_frame < 26)
        scientist_Saw ();

	if (self.monster_frame == 12)
		scientist_tag ("progs/monsters/scientist/knife_tag.md3", 8, 17, "TE_WHOOSH", "Empty");

	if (self.monster_frame == 7)
		scientist_tag ("progs/monsters/scientist/melee_lunge_saw.md3", 8, 26, "TE_WHOOSH", "Empty");
	
	if (self.monster_frame >= 35) 
	{	
		scientist_strafe ();
		return;
	}

    if (self.monster_frame != 8 && self.monster_frame != 7 && self.monster_frame != 20 && self.monster_frame != 21
        && self.monster_frame != 9 && self.monster_frame != 18 && self.monster_frame != 19 && self.monster_frame < 30)
        ai_charge (6);
    else
        ai_charge (1);
        
};

void() scientist_meleed1 = [ 9, scientist_meleed2 ] 
{	self.monster_frame = 0; self.count =0;
	scientist_tag ("progs/monsters/scientist/melee_syringe_tag.md3", 9, 16, "TE_WHOOSH", "Empty");
ai_flybob_face(); self.nextthink = time + 0.04;  };
void() scientist_meleed2 = [ self.frame, scientist_meleed2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 8) 
	{
		scientist_Melee ();
	}
	
	if (self.monster_frame >= 29) 
	{	
		scientist_strafe ();
		return;
	}

    ai_charge (3);
        
};

//==============================================================================
void() scientist_MeleeAttack = 
{
    float r = rint(random()*3);
	scientist_sfx_attack ();

	if (r == 3)
		scientist_meleea1();
	else if (r == 2)
		scientist_meleeb1();
    else if (r == 1)
		scientist_meleec1();
	else
 	   	scientist_meleed1();
}


void() scientist_MissileAttack =
{
	//scientist_sfx_attack ();

	scientist_missilea1();
};

//==============================================================================


// regular ow
void() scientist_paina1 = [ 12, scientist_paina2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() scientist_paina2 = [ self.frame, scientist_paina2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint("????", "\n");
	if (self.monster_frame >= 11) 
	{
		scientist_run1 ();
		return;
	}
};

void() scientist_painb1 = [ 13, scientist_painb2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() scientist_painb2 = [ self.frame, scientist_painb2 ] 
{   
    //bprint(ftos(self.frame), "\n");
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint(">>>>>>>>>>?????", "\n");
	if (self.monster_frame >= 11) 
	{
		scientist_run1 ();
		return;
	}
};

// concussion
void() scientist_painc1 = [ 14, scientist_painc2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() scientist_painc2 = [ self.frame, scientist_painc2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint("????", "\n");
	if (self.monster_frame >= 22) 
	{   
		scientist_strafe ();
		return;
	}

	if (self.monster_frame < 6)
		ai_move (-3);

	if (self.monster_frame > 9)
		ai_move (3);

	if (self.monster_frame == 1)
		ai_move (2);
};


void(entity attacker, float damage, float MOD) scientist_pain =
{
//	if (self.touch == scientist_JumpTouch)
//		return;
//	bprint(ftos(MOD), "\n");
	if (self.flags & FL_DODGED)
	{	
		return;
	}

	if (self.pain_finished > time)
		return;

	self.pain_finished = time + 2;
	scientist_sfx_pain (); // sfx

	if (DMGTYPE_LTNG == MOD)
	{
  	  if (random() <= 0.5)
	        scientist_paina1 ();
 	   else
  	      	scientist_painb1 ();
		
		if (skill < 2)
			self.pain_finished = time + 0.5;
		else
			self.pain_finished = time + 1.5;
		return;
	}

	if (MOD == DMGTYPE_RAIL)
	{   
        scientist_painc1 ();
		self.pain_finished = time + 2.5;
		return;
	}

	if (random()*100 > damage)
		return; // didn't flinch

	if (damage > 50 || MOD == DMGTYPE_EXP)
	{   
        scientist_painc1 ();
		return;
	}

    if (random() <= 0.5)
        scientist_paina1 ();
    else
        scientist_painb1 ();
};

//==============================================================================

void() scientist_die =
{	
	if (self.health < -100)
	{	
		self.deadflag = DEAD_DEAD;
		self.solid = SOLID_NOT;
		MonsterGib (self.health); 
		remove(self);
		return;
	}
	
	if((self.deadflag & DEAD_DEAD))
		return;

	//_sfx_death ();

	setsize(self, '-16 -16 20', '16 16 64');

	local vector tmpangle;
	local float tempskin;
	tmpangle = self.angles;
	tempskin = self.skin;
	
	self.think = scientist_diea1;

	self.monster_frame = 0;

	scientist_sfx_pain ();
	self.deadflag = DEAD_DEAD;
	self.solid = SOLID_CORPSE;
//	self.movetype = MOVETYPE_STEP;
	self.nextthink = time + 0.04;

	self.angles = tmpangle;
	self.nextthink2 = 0;
};

void() scientist_diea1 = [ 15 , scientist_diea1 ] 
{ 	
	if ((checkbottom(self) && self.monster_frame == 5) || (self.nextthink2 > 10))
	{	
	//	self.cnt = 1;
		self.think = scientist_diea2;
		self.nextthink = time + 0.04;
		return;
	}
	else 
	{
		self.nextthink2 ++; // assume we're stuck 
	}
	
	if (self.monster_frame < 5)
	{
		ai_move (-5);
		self.monster_frame++;
	}	

	self.dspeed += 1;
	self.nextthink = time + 0.04; 
};

void() scientist_diea2 = [ 16 , scientist_diea2 ] 
{ 	
	//self.frame |= 0x8000;
	self.nextthink = time + 0.04;
	self.monster_frame ++;
	if (self.monster_frame >= 15)
	{
		self.maxs_z = 40;
		self.nextthink = -1;
		self.think = scientist_fade1;
		self.nextthink = time + 3.5;
		return;
	}
};

void() scientist_fade1 = [ 0, scientist_gib2 ] 
{	

	setmodel(self, "progs/monsters/scientist/scientist_death.iqm");
	setsize(self, '-16 -16 20', '16 16 40');

	self.skin = 1; 
	self.alpha = 1; 
	self.glowmod = '0.5 0.5 0.5'; 
	self.nextthink = time + 0.02;
};

void() scientist_gib2 = [ self.frame, scientist_gib2 ] 
{ 	
	self.nextthink = time + 0.02;
	self.alpha -= 0.02;
	if (self.alpha <= 0)
	{
		remove(self);
		return;
	}
};

//========================================================================================


static void() scientist_sfx_idle =
{
	sound(self, CHAN_VOICE, "sounds_q4/strogg/scientist/hover_loop.wav", 1, ATTN_IDLE);
};


static void() scientist_sfx_swing =
{	
	local float r = rint(random() * 3);	
	if (r == 2)
		    sound(self, CHAN_RELOAD, "sounds_q4/strogg/scientist/swing1.wav", 1, ATTN_NORM);
	else if (r == 1)
		    sound(self, CHAN_RELOAD, "sounds_q4/strogg/scientist/swing2.wav", 1, ATTN_NORM);
    else 
		    sound(self, CHAN_RELOAD, "sounds_q4/strogg/scientist/swing3.wav", 1, ATTN_NORM);
};

static void() scientist_sfx_pain =
{	
	local float r = rint(random() * 3);	
	if (r == 2)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/scientist/squish1.wav", 1, ATTN_NORM);
	else if (r == 1)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/scientist/squish2.wav", 1, ATTN_NORM);
    else 
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/scientist/squish3.wav", 1, ATTN_NORM);
};

static void() scientist_sfx_attack =
{	
	local float r = (random());	
	if (r <= 0.5)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/scientist/attack.wav", 1, ATTN_NORM);
	else 
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/scientist/attack2.wav", 1, ATTN_NORM);
};

static void() scientist_sfx_saw =
{	
	local float r = (random());	
	if (r <= 0.5)
		    sound(self, CHAN_RELOAD, "sounds_q4/strogg/scientist/saw1.wav", 1, ATTN_NORM);
	else 
		    sound(self, CHAN_RELOAD, "sounds_q4/strogg/scientist/saw2.wav", 1, ATTN_NORM);
};

static void() scientist_sfx_sight =
{
	local float r = rint(random() * 6);	

	if (r == 6)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/scientist/voice_1a.wav", 1, ATTN_NORM);
	else if (r == 5)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/scientist/voice_2a.wav", 1, ATTN_NORM);
	else if (r == 4)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/scientist/voice_3a.wav", 1, ATTN_NORM);
	else if (r == 3)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/scientist/voice_4a.wav", 1, ATTN_NORM);
	else if (r == 2)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/scientist/voice_5a.wav", 1, ATTN_NORM);
	else if (r == 1)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/scientist/voice_6a.wav", 1, ATTN_NORM);
	else 
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/scientist/voice_9a.wav", 1, ATTN_NORM);
};

/*QUAKED monster_demon (1 0 0) (-32 -32 -24) (32 32 64) Ambush

*/
void() monster_scientist_cache =
{
	precache_model("progs/monsters/scientist/scientist.md5.info");
	precache_model("progs/monsters/scientist/scientist_death.iqm");
	precache_model("progs/monsters/scientist/melee_syringe_tag.md3");
	precache_model("progs/monsters/scientist/melee_lunge_saw.md3");
	precache_model("progs/monsters/scientist/melee_lunge_syringe.md3");
	precache_model("progs/monsters/scientist/melee_tool_tag.md3");
	precache_model("progs/monsters/scientist/melee_front_arms_tag_arm.md3");
	precache_model("progs/monsters/scientist/melee_front_arms_tag_saw.md3");
	precache_model("progs/monsters/scientist/knife_tag.md3");
	precache_model("progs/monsters/scientist/throw_object_tag.md3");

	precache_sound("sounds_q4/strogg/scientist/voice_1a.wav");
	precache_sound("sounds_q4/strogg/scientist/voice_2a.wav");
	precache_sound("sounds_q4/strogg/scientist/voice_3a.wav");
	precache_sound("sounds_q4/strogg/scientist/voice_4a.wav");
	precache_sound("sounds_q4/strogg/scientist/voice_5a.wav");
	precache_sound("sounds_q4/strogg/scientist/voice_6a.wav");
	precache_sound("sounds_q4/strogg/scientist/voice_9a.wav");

	precache_sound("sounds_q4/strogg/scientist/swing1.wav");
    precache_sound("sounds_q4/strogg/scientist/swing2.wav");
	precache_sound("sounds_q4/strogg/scientist/swing3.wav");

	precache_sound("sounds_q4/strogg/scientist/squish1.wav");
    precache_sound("sounds_q4/strogg/scientist/squish2.wav");
	precache_sound("sounds_q4/strogg/scientist/squish3.wav");

    precache_sound("sounds_q4/strogg/scientist/chemical_burst1.wav");
    precache_sound("sounds_q4/strogg/scientist/chemical_burst2.wav");

    precache_sound("sounds_q4/strogg/scientist/attack.wav");
    precache_sound("sounds_q4/strogg/scientist/attack2.wav");

    precache_sound("sounds_q4/strogg/scientist/hover_loop.wav");

    precache_sound("sounds_q4/strogg/scientist/saw1.wav");
	precache_sound("sounds_q4/strogg/scientist/saw2.wav");

//	spawn_demon ();
};

void() monster_scientist =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	monster_scientist_cache ();	
	spawn_scientist ();
};

void() spawn_scientist =
{
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel(self, "progs/monsters/scientist/scientist.md5.info");
	self.classname = "monster_scientist";
	setsize(self, '-16 -16 24', '16 16 72');
	self.health = 270;
	self.max_health = 270;
	self.mass = 300;
	self.scale = 0.8;

	self.th_stand = scientist_stand1;
	self.th_walk = scientist_walk1;
	self.th_run = scientist_run1;
	self.th_die = scientist_die;
	self.th_melee = scientist_MeleeAttack; // one of two attacks
	self.th_missile = scientist_MissileAttack; // jump attack
	self.th_pain = scientist_pain;
//	self.th_checkatck = BerserkCheckAttack;
	self.th_spawn = spawn_scientist;
	self.th_dodge = scientist_strafe;
	self.th_sight = scientist_sfx_sight;
	//setcustomskin (self, "progs/monsters/scientist/scientist.skin")
	self.deathtype = "forgot to wear a gas mask facing a Scientist";
	self.pissed = 0;
	self.speed = 5;
	self.count = 0;

	self.flybob_horz = 0;
	self.flybob_vert = 12;
	self.flybob_strength = 3;

	flymonster_start();
};

//===========================================================================

void() scientist_shoot =
{
	vector dir, org;
	entity en;

//	AutofireMachineEnemyNoise ();

// fire somewhat behind the player, so a dodging player is harder to hit
	en = self.enemy;

	org = self.origin + '0 0 48';

	dir = en.origin - en.velocity*0.15 + '0 0 24';
	dir = normalize(dir - org);

	vector f, r, u;
	AngleVectors(self.angles, f, r, u);
//	vector org = self.pos2;
	float dist = vlen(dir);
	float pitch;

//PGM
	if((dist > 512) && (dir[2] < 64) && (dir[2] > -64))
	{
		dir[2] += (dist - 512);
	}

	dir = normalize (dir);
	pitch = dir[2];
	if(pitch > 0.4)
	{
		pitch = 0.4;
	}
	else if(pitch < -0.5)
		pitch = -0.5;

	dir = f;
	dir = dir + pitch * u;
//PGM	

//	float ldmg = 90 + (random() + random() + random())*12;
	if (M_CalculatePitchToFire (self.enemy.origin + '0 0 24', org, dir, 600, 0, TRUE, TRUE))
		gas (org, dir, (crandom() * 10), 80 + (crandom() * 10), 600);
	else
		gas (org, dir, (crandom() * 10), 200 + (crandom() * 10), 600);

}

void() scientist_Melee =
{
	float ldmg;

	ai_flybob_face();

	ldmg = 7 + 5*random();
	vector	aim;

	scientist_sfx_swing ();

	aim = setvector (100, 0, 0);
	if (fire_hit(aim, rint(ldmg), 5))
	{	
		meat_hit ();
	}
};

void() scientist_Saw =
{
	float ldmg;

	ai_flybob_face();

	ldmg = 2 + 10*random();
	vector	aim;

	if (self.pissed < time)
	{
		scientist_sfx_saw ();
		self.pissed = time + 0.1;
	}

	aim = setvector (100, 0, 0);
	if (fire_hit(aim, rint(ldmg), 0))
	{	
		meat_hit ();
	}
	else
	{
		meat_miss();

	}
};

static void() gas_GrenadeTouch =
{
	if (other == self.owner)
		return; // don't explode on owner
	
	if (other.takedamage && other.dmgtime < time)
	{	
		//T_RadiusDamage(self, self.owner, 30, 60, world);
		T_Damage (other, self, self.origin, self, 2, 0, DMGTYPE_NORM);
		other.dmgtime = time + 0.2;
		self.solid = SOLID_TRIGGER;
	}

	pointparticles (particleeffectnum("TE_GAS_SPOT"), self.origin);

	if (random() <= 0.5)
		sound(self, CHAN_WEAPON, "sounds_q4/strogg/scientist/chemical_burst1.wav", 1, ATTN_NORM); // bounce sound
	else	
		sound(self, CHAN_WEAPON, "sounds_q4/strogg/scientist/chemical_burst2.wav", 1, ATTN_NORM); // bounce sound

	T_RadiusPoison (self, self.owner, 25, 90, world);

	pointparticles (particleeffectnum("TE_GASBURST"), self.origin, '0 0 0', 1);
	

//	spawn_damagergas (self.origin);
	
	remove(self);
};


static void(vector org, vector dir, float right_adjust, float up_adjust, float speed) gas =
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

	missile.touch = gas_GrenadeTouch;

// set missile duration
	missile.nextthink = time + 6;
	missile.think = SUB_Remove;

	setmodel(missile, "progs/monsters/glass_ball.md3");
	setsize(missile, '0 0 0', '0 0 0');
	missile.traileffectnum = particleeffectnum("EF_GASTRAIL");
	
	setorigin (missile, org);
};

void() scientist_flash = 
{   
   
    vector org;

    org = self.pos2;

    pointparticles (particleeffectnum("TE_FLASH"), org, '0 0 0', 8);
//	pointparticles (particleeffectnum("EF_MUZZLEFLASH2"), org, '0 0 0');
};