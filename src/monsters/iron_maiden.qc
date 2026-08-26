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

void() maiden_stand1 = [ 1, maiden_stand2 ] { ai_stand(); self.monster_frame = 0;};
void() maiden_stand2 = [ self.frame, maiden_stand2 ] 
{ 	
	self.monster_frame ++;
	if (self.monster_frame >= 61) 
	{	
		if (random() < 0.2)
			maiden_sfx_idle ();
		maiden_stand1 ();
		return;
	}
	ai_stand ();
};

void() maiden_walk1 = [ 2, maiden_walk2 ] { ai_walk(3); self.monster_frame = 0;};
void() maiden_walk2 = [ self.frame, maiden_walk2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 28) 
	{
		maiden_walk1 ();
		return;
	}

	ai_walk (3);
};

void() maiden_run1 = [ 2, maiden_run2 ] { ai_run(5); self.monster_frame = 0;};
void() maiden_run2 = [ self.frame, maiden_run2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 33) 
	{
		if (random() < 0.3)
			maiden_sfx_idle ();

		maiden_run1 ();
		return;
	}

    ai_run (5);
};

void() maiden_strafel1 = [ 4, maiden_strafel2 ] 
{ 	ai_flybob_face();
	M_walkmove (self.ideal_yaw + 90, 3); self.nextthink = time + 0.04; self.monster_frame = 0;};
void() maiden_strafel2 = [ self.frame, maiden_strafel2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 28) 
	{	
		//self.attack_state = AS_STRAIGHT;
		//self.flags &= ~FL_DODGED;
	//	despawn_shield ();
		maiden_run1 ();
		return;
	}
	ai_flybob_face();
	M_walkmove (self.ideal_yaw + 90, 3);
	
	self.nextthink = time + 0.04;
};

void() maiden_strafer1 = [ 5, maiden_strafer2 ] 
{ 	ai_flybob_face();
	M_walkmove (self.ideal_yaw -90, 3); self.nextthink = time + 0.0; self.monster_frame = 0;};
void() maiden_strafer2 = [ self.frame, maiden_strafer2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 28) 
	{	
		//self.attack_state = AS_STRAIGHT;
		//self.flags &= ~FL_DODGED;
	//	despawn_shield ();
		maiden_run1 ();
		return;
	}

	//if (self.monster_frame < 33)
	ai_flybob_face();
	M_walkmove (self.ideal_yaw - 90, 3);
	
	self.nextthink = time + 0.04;
};


void() maiden_strafe =
{	
	makevectors(self.angles);
	tracebox (self.origin, self.mins, self.maxs, self.origin + v_right * 120, FALSE, self);
	float right = trace_fraction;

	tracebox (self.origin, self.mins, self.maxs, self.origin + v_right * -120, FALSE, self);
	float left = trace_fraction;

	if (left == 1 && right == 1)
	{
		if (random() <= 0.5)
			maiden_strafel1 ();
		else 
			maiden_strafer1 ();
		return;
	}

	if (left == 1)
		maiden_strafel1 ();
	else if (right == 1)
		maiden_strafer1 ();

	if (left < 1 || right < 1)
	{	
		maiden_run1 ();
		return;
	}
	
	self.nextthink = time;
};

// ==============================================================================

void() maiden_evadel1 = [ 17, maiden_evadel2 ] 
{ 
	M_walkmove (self.ideal_yaw + 90, 9); self.nextthink = time + 0.04; self.monster_frame = 0;};
void() maiden_evadel2 = [ self.frame, maiden_evadel2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 17) 
	{	
		//self.attack_state = AS_STRAIGHT;
		self.flags &= ~FL_DODGED;
	//	despawn_shield ();
		maiden_run1 ();
		return;
	}

	M_walkmove (self.ideal_yaw + 90, 9);
	
	self.nextthink = time + 0.04;
};

void() maiden_evader1 = [ 18, maiden_evader2 ] 
{ 	
	M_walkmove (self.ideal_yaw -90, 9); self.nextthink = time + 0.04; self.monster_frame = 0;};
void() maiden_evader2 = [ self.frame, maiden_evader2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 12) 
	{	
		//self.attack_state = AS_STRAIGHT;
		self.flags &= ~FL_DODGED;
	//	despawn_shield ();
		maiden_run1 ();
		return;
	}

	//if (self.monster_frame < 33)
	
	M_walkmove (self.ideal_yaw - 90, 9);
	
	self.nextthink = time + 0.04;
};

void() maiden_evade =
{	
	makevectors(self.angles);
	tracebox (self.origin, self.mins, self.maxs, self.origin + v_right * 120, FALSE, self);
	float right = trace_fraction;

	tracebox (self.origin, self.mins, self.maxs, self.origin + v_right * -120, FALSE, self);
	float left = trace_fraction;

	if (left == 1 && right == 1)
	{	
		if (random() <= 0.5)
			maiden_evadel1 ();
		else 
			maiden_evader1 ();
		return;
	}

	if (left == 1)
		maiden_evadel1 ();
	else if (right == 1)
		maiden_evader1 ();

	if (left < 1 || right < 1)
	{	
		self.flags &= ~FL_DODGED;
		return;
	}
	
	self.nextthink = time;
};

//==============================================================================

static void(entity target, string name) maid_tag_entity =
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

static void() maid_tag_think =
{	
	self.frame = self.owner.monster_frame;
	if (self.frame >= self.dspeed || self.owner.frame != self.ltime )
	{	
		if (self.prelock_save)
			remove(self.prelock_save);

		remove(self);
		return;
	}

	setorigin(self, self.owner.origin + '0 0 -12');
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
	
	self.think = maid_tag_think;
	self.angles = self.owner.angles;
	self.nextthink = time;
}

static void(string stringg, float fr, float end, string name, string tag) maid_tag = 
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
		maid_tag_entity(e, name);

	e.netname = tag;
	e.think = maid_tag_think;
	e.nextthink = time;
}

// missle singular
void() maiden_missilea1 = [ 6, maiden_missilea2 ] {
	self.monster_frame = 0;
	maid_tag ("progs/monsters/iron_maiden/range_attack_tag.md3", 6, 33, string_null, "tag_muzzle");
	//sound(self, CHAN_RELOAD, "sounds_q4/strogg/iron_maiden/railgun_charge.wav", 1, ATTN_NORM);
	ai_flybob_face(); self.nextthink = time + 0.04; };
void() maiden_missilea2 = [ self.frame, maiden_missilea2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 12)
		maid_flash ();

	if (self.monster_frame == 12)
		maid_shoot_home ();
	
	if (self.monster_frame >= 33) 
	{	
		maiden_strafe ();
		return;
	}

	if (self.monster_frame < 12)
		ai_flybob_face();

	if (self.monster_frame > 12 && self.monster_frame < 20)
		ai_move (-3);
	if (self.monster_frame > 20)
		ai_move (2);
};

// missiles plural
void() maiden_missileb1 = [ 7, maiden_missileb2 ] {
	self.monster_frame = 0;
	maid_tag ("progs/monsters/iron_maiden/range_attack02_tag.md3", 7, 40, string_null, "tag_muzzle");
//	sound(self, CHAN_RELOAD, "sounds_q4/strogg/iron_maiden/railgun_charge.wav", 1, ATTN_NORM);
	ai_flybob_face(); self.nextthink = time + 0.04; };
void() maiden_missileb2 = [ self.frame, maiden_missileb2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 10 || self.monster_frame == 20 || self.monster_frame == 30)
		maid_flash ();

	if (self.monster_frame == 10 || self.monster_frame == 20 || self.monster_frame == 30)
		maid_shoot (400);
	
	if (self.monster_frame >= 40) 
	{   
		maiden_strafe ();	
		return;
	}

//	if (self.monster_frame < 10)
	ai_flybob_face ();

	if (self.monster_frame > 10 && self.monster_frame < 16)
		ai_charge (-3);

	if (self.monster_frame > 20 && self.monster_frame < 26)
		ai_charge (-3);

	if (self.monster_frame > 30 && self.monster_frame < 36)
		ai_charge (-3);
};


//==============================================================================

void() maiden_meleea1 = [ 8, maiden_meleea2 ] {
	self.monster_frame = 0;
	maid_tag ("progs/monsters/iron_maiden/melee_attack_tag.md3", 8, 15, "TE_WHOOSH", "Empty");
	ai_flybob_face(); self.nextthink = time + 0.04;  };
void() maiden_meleea2 = [ self.frame, maiden_meleea2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 11)
		maid_Melee();

	if (self.monster_frame >= 21) 
	{   
        maiden_strafe ();
		return;
	}

	if (self.monster_frame < 11)
		ai_charge (2);
};

void() maiden_meleeb1 = [ 9, maiden_meleeb2 ] {
	self.monster_frame = 0;
	maid_tag ("progs/monsters/iron_maiden/melee_attack02_tag.md3", 9, 15, "TE_WHOOSH", "Empty");
	ai_flybob_face(); self.nextthink = time + 0.04; };
void() maiden_meleeb2 = [ self.frame, maiden_meleeb2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 11)
		maid_Melee();

	if (self.monster_frame >= 25)  
	{   
        maiden_strafe();
		return;
	}

	if (self.monster_frame < 17)
		ai_charge (3);
};

void() maiden_banshee1 = [ 16, maiden_banshee2 ] {
	self.monster_frame = 0;
	maid_tag ("progs/monsters/iron_maiden/banshee_tag.md3", 16, 70, string_null, "tag_mouth");
	ai_flybob_face(); self.nextthink = time + 0.04;  };
void() maiden_banshee2 = [ self.frame, maiden_banshee2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 9)
	{
		maid_Melee2 ();
		maiden_sfx_scream ();
	}

	if (self.monster_frame > 10 && self.monster_frame < 62)
		maid_scream();

	if (self.monster_frame >= 70) 
	{   
        maiden_run1();
		return;
	}
	ai_charge (1);
};

//==============================================================================

void() maiden_MeleeAttack =
{	
	if (random() <= 0.3)
	{
		//maiden_missilec1_0();
		maiden_banshee1 ();

		return;
	}

	if(random() <= 0.5)
		maiden_meleea1 ();
	else
		maiden_meleeb1 ();
};

void() maiden_MissileAttack =
{   
    if (random() <= 0.6)
		maiden_missileb1();
	else 
		maiden_missilea1();

};

//==============================================================================

// regular ow
void() maiden_paina1 = [ 12, maiden_paina2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() maiden_paina2 = [ self.frame, maiden_paina2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint("????", "\n");
	if (self.monster_frame >= 13) 
	{
		maiden_run1 ();
		return;
	}
};

void() maiden_painb1 = [ 13, maiden_painb2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() maiden_painb2 = [ self.frame, maiden_painb2 ] 
{   
    //bprint(ftos(self.frame), "\n");
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint(">>>>>>>>>>?????", "\n");
	if (self.monster_frame >= 17) 
	{
		maiden_run1 ();
		return;
	}
};

// concussion
void() maiden_painc1 = [ 14, maiden_painc2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() maiden_painc2 = [ self.frame, maiden_painc2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint("????", "\n");
	if (self.monster_frame >= 18) 
	{   
		maiden_run1 ();
		return;
	}
};

void() maiden_paind1 = [ 15, maiden_paind2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() maiden_paind2 = [ self.frame, maiden_paind2 ] 
{   
    //bprint(ftos(self.frame), "\n");
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint(">>>>>>>>>>?????", "\n");
	if (self.monster_frame >= 21) 
	{   
		maiden_run1 ();
		return;
	}
};

void(entity attacker, float damage, float MOD) maiden_pain =
{
//	if (self.touch == maiden_JumpTouch)
//		return;
//	bprint(ftos(MOD), "\n");
	if (self.flags & FL_DODGED)
	{	
		return;
	}

	if (self.pain_finished > time)
		return;
	
	if (DMGTYPE_LTNG == MOD)
	{
  	  if (random() <= 0.5)
	        maiden_paina1 ();
 	   else
  	      	maiden_painb1 ();
		
		if (skill < 2)
			self.pain_finished = time + 0.5;
		else
			self.pain_finished = time + 1.5;
		return;
	}

	self.pain_finished = time + 2;
//	maiden_sfx_pain (); // sfx

	if (MOD == DMGTYPE_RAIL)
	{   
         if (random() <= 0.5)
            maiden_painc1 ();
        else
            maiden_paind1 ();

		self.pain_finished = time + 2.5;
		return;
	}

	if (random()*200 > damage)
		return; // didn't flinch

	if (damage > 50 || MOD == DMGTYPE_EXP)
	{   
         if (random() <= 0.5)
            maiden_painc1 ();
        else
            maiden_paind1 ();
		return;
	}

    if (random() <= 0.5)
        maiden_paina1 ();
    else
        maiden_painb1 ();
};

void() maiden_die =
{	
	//self.angles = '-90 0 0';
	if (self.health < -120)
	{	
		self.deadflag = DEAD_DEAD;
		self.solid = SOLID_NOT;
		MonsterGib (self.health); 
		remove(self);
		return;
	}
	
	if((self.deadflag & DEAD_DEAD))
		return;

	maiden_sfx_death ();

	local vector tmpangle;
	local float tempskin;
	tmpangle = self.angles;
	tempskin = self.skin;
	

	if (random() <= 0.5)
		self.think = maiden_diea1;
	else
		self.think = maiden_dieb1;

	self.monster_frame = 0;

	self.deadflag = DEAD_DEAD;
	self.solid = SOLID_CORPSE;
//	self.movetype = MOVETYPE_STEP;
	self.nextthink = time + 0.04;

	self.angles = tmpangle;
	//self.skin = tempskin;
	self.nextthink2 = 0;
};

void() maiden_diea1 = [ 19 , maiden_diea1 ] 
{ 	
	if ((checkbottom(self) && self.monster_frame == 7) || (self.nextthink2 > 10))
	{	
		self.cnt = 1;
		self.think = maiden_diea2;
		self.nextthink = time + 0.04;
		return;
	}
	else
	{
		self.nextthink2 ++;
	}

	if (self.monster_frame < 7)
	{
		ai_move (-5);
		self.monster_frame++;
	}	
	self.dspeed += 1;
	self.nextthink = time + 0.04; 
};

void() maiden_diea2 = [ 20 , maiden_diea2 ] 
{ 	
	//self.frame |= 0x8000;
	self.nextthink = time + 0.04;
	self.monster_frame ++;
	if (self.monster_frame >= 46)
	{
		self.maxs_z = 12;
		self.nextthink = -1;
		self.think = maiden_fade1;
		self.nextthink = time + 3.5;
		return;
	}
};

void() maiden_dieb1 = [ 21 , maiden_dieb1 ] 
{ 	
	if ((checkbottom(self) && self.monster_frame == 9) || (self.nextthink2 > 10))
	{	
	//	self.cnt = 1;
		self.think = maiden_dieb2;
		self.nextthink = time + 0.04;
		return;
	}
	else
	{
		self.nextthink2 ++;
	}

	if (self.monster_frame < 9)
	{
		ai_move (-5);
		self.monster_frame++;
	}	
	self.dspeed += 1;
	self.nextthink = time + 0.04; 
};

void() maiden_dieb2 = [ 22 , maiden_dieb2 ] 
{ 	
	//self.frame |= 0x8000;
	self.nextthink = time + 0.04;
	self.monster_frame ++;
	if (self.monster_frame >= 36)
	{
		self.maxs_z = 12;
		self.nextthink = -1;
		self.think = maiden_fade1;
		self.nextthink = time + 3.5;
		return;
	}
};

void() maiden_fade1 = [ self.frame, maiden_gib2 ] 
{	
	if (self.cnt == 1)
		self.frame = 0;
	else
		self.frame = 1;
	
	
	setmodel(self, "progs/monsters/iron_maiden/iron_maiden_death.iqm");
	setsize(self, '-16 -16 0', '16 16 12');

	self.skin = 1; 
	self.alpha = 1; 
	self.glowmod = '0.5 0.5 0.5'; 
	self.nextthink = time + 0.02;
};

void() maiden_gib1 = [ self.frame, maiden_gib2 ] 
{MonsterGib (self.health); self.skin = 1; self.alpha = 1; self.nextthink = time + 0.02;};

void() maiden_gib2 = [ self.frame, maiden_gib2 ] 
{ 	
	self.nextthink = time + 0.02;
	self.alpha -= 0.02;
	if (self.alpha <= 0)
	{
		remove(self);
		return;
	}
};

static void() maiden_sfx_scream =
{
	 if (random() <= 0.5)
	    sound(self, CHAN_VOICE, "sounds_q4/strogg/iron_maiden/attack1.wav", 1, ATTN_NORM);
    else
        sound(self, CHAN_VOICE, "sounds_q4/strogg/iron_maiden/attack2.wav", 1, ATTN_NORM);
};


static void() maiden_sfx_death =
{
	 if (random() <= 0.5)
	    sound(self, CHAN_VOICE, "sounds_q4/strogg/iron_maiden/die1.wav", 1, ATTN_NORM);
    else
        sound(self, CHAN_VOICE, "sounds_q4/strogg/iron_maiden/die2.wav", 1, ATTN_NORM);
};

static void() maiden_sfx_idle =
{
	local float r = rint(random() * 2);	

	if (r == 2)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/iron_maiden/breath1.wav", 1, ATTN_IDLE);
	else if (r == 1)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/iron_maiden/breath2.wav", 1, ATTN_IDLE);
	else 
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/iron_maiden/breath3.wav", 1, ATTN_IDLE);
};

static void() maiden_sfx_sight =
{   
    if (random() <= 0.5)
	    sound(self, CHAN_VOICE, "sounds_q4/strogg/iron_maiden/alert1.wav", 1, 0.7);
    else
        sound(self, CHAN_VOICE, "sounds_q4/strogg/iron_maiden/alert2.wav", 1, 0.7);
};

/*QUAKED monster_demon (1 0 0) (-32 -32 -24) (32 32 64) Ambush

*/
void() monster_maiden_cache =
{
	precache_model("progs/monsters/iron_maiden/iron_maiden.md5.info");
	precache_model("progs/monsters/iron_maiden/iron_maiden_death.iqm");

	precache_model("progs/monsters/iron_maiden/range_attack_tag.md3");
	precache_model("progs/monsters/iron_maiden/range_attack02_tag.md3");
	precache_model("progs/monsters/iron_maiden/melee_attack_tag.md3");
	precache_model("progs/monsters/iron_maiden/melee_attack02_tag.md3");
	precache_model("progs/monsters/iron_maiden/banshee_tag.md3");
	

	precache_sound("sounds_q4/strogg/iron_maiden/alert1.wav");
    precache_sound("sounds_q4/strogg/iron_maiden/alert2.wav");
	precache_sound("sounds_q4/strogg/iron_maiden/breath1.wav");
	precache_sound("sounds_q4/strogg/iron_maiden/breath2.wav");
	precache_sound("sounds_q4/strogg/iron_maiden/breath3.wav");
	
	precache_sound("sounds_q4/strogg/iron_maiden/attack1.wav");
	precache_sound("sounds_q4/strogg/iron_maiden/attack2.wav");
	precache_sound("sounds_q4/strogg/iron_maiden/die1.wav");
	precache_sound("sounds_q4/strogg/iron_maiden/die2.wav");	


//	spawn_demon ();
};

void() monster_iron_maiden =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	monster_maiden_cache ();	
	spawn_iron_maiden ();
};

void() spawn_iron_maiden =
{
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel(self, "progs/monsters/iron_maiden/iron_maiden.md5.info");
	self.classname = "monster_iron_maiden";
	setsize(self, '-16 -16 0', '16 16 88');
	self.health = 450;
	self.max_health = 450;
	self.mass = 300;
	self.scale = 0.7;

	self.th_stand = maiden_stand1;
	self.th_walk = maiden_walk1;
	self.th_run = maiden_run1;
	self.th_die = maiden_die;
	self.th_melee = maiden_MeleeAttack; // one of two attacks
	self.th_missile = maiden_MissileAttack; // jump attack
	self.th_pain = maiden_pain;
	//self.th_checkatck = GladCheckAttack;
	self.th_spawn = spawn_iron_maiden;
	self.th_dodge = maiden_evade;
	self.th_sight = maiden_sfx_sight;
	//setcustomskin (self, "progs/monsters/iron_maiden/gladiator.skin")
	self.deathtype = "was exploded by an Iron Maiden";
	self.count = 0;
	self.pissed = 0;
//	self.emiteffectnum = particleeffectnum("_maid_dress");

	self.flybob_horz = 2;
	self.flybob_vert = 1;
	self.flybob_strength = 15;

	flymonster_start();
};


/*
==============================================================================

DEMON

==============================================================================
*/



void(float speed) maid_shoot = 
{   
	RocketNoise ();
	vector dir = normalize(self.enemy.origin - self.pos2 + self.enemy.view_ofs);
	launch_rocket (self.pos2, dir, speed, 30, 80, "EF_REVTRAIL");
};

void() maid_shoot_home = 
{
	RocketNoise ();
	vector dir = normalize(self.enemy.origin - self.pos2 + self.enemy.view_ofs);
	launch_rocket_home (self.pos2, dir, 400, 30, 80, 40, "EF_REVTRAIL2");
};

void() maid_scream = 
{   
	vector dir = normalize(self.enemy.origin - self.origin);
	pointparticles (particleeffectnum("TE_BANSHEE"), self.pos2, dir*2000, 1);

	vector aim = setvector (140, 0, 0);
	if (fire_hit(aim, 2, 0) && self.dspeed < time)
	{	
		if (self.enemy.flags & FL_CLIENT)
		{
			self.enemy.shake_interval = 1.8;
			self.enemy.shake_time = time + 0.8;
		}
		self.dspeed = time + 0.1;
	}
};

void() maid_Melee2 =
{

};

void() maid_Melee =
{
	float ldmg;

	ai_flybob_face();

	ldmg = 20 + random()*15;

	vector	aim;

	aim = setvector (100, 0, 0);
	if (fire_hit(aim, rint(ldmg), 10))
	{	
		meat_hit (); 
	}
	else
	{
	
		meat_miss (); 
	//	self.pissed += 0.3;
	}
};

void() maid_flash = 
{   
   
    vector org;

    org = self.pos2;

    pointparticles (particleeffectnum("TE_MUZZLEFLASH2"), org, '0 0 0');
	pointparticles (particleeffectnum("EF_MUZZLEFLASH2"), org, '0 0 0');
};



//===========================================================================
