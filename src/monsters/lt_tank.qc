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

void() lt_tank_stand1 = [ 1, lt_tank_stand2 ] { ai_stand(); self.monster_frame = 0;};
void() lt_tank_stand2 = [ self.frame, lt_tank_stand2 ] 
{ 	
	self.monster_frame ++;
	if (self.monster_frame >= 104) 
	{	
		if (random() < 0.2)
			lt_tank_sfx_idle ();

		lt_tank_stand1 ();
		return;
	}
	ai_stand ();
};

void() lt_tank_walk1 = [ 2, lt_tank_walk2 ] 
{ ai_walk(3); self.monster_frame = 0; self.nextthink = time + 0.04167;};
void() lt_tank_walk2 = [ self.frame, lt_tank_walk2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 32) 
	{
		if (random() < 0.3)
			lt_tank_sfx_idle ();

		lt_tank_walk1 ();
		return;
	}


    ai_walk(3);

    self.nextthink = time + 0.04167;
};

void() lt_tank_run1 = [ 2, lt_tank_run2 ] 
{ ai_run(3); self.monster_frame = 0; self.nextthink = time + 0.04167;};
void() lt_tank_run2 = [ self.frame, lt_tank_run2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 32) 
	{
		if (random() < 0.3)
			lt_tank_sfx_idle ();
        
		lt_tank_run1 ();
		return;
	}

    if (random() <= 0.1)
        CheckForCharge (2 + 2*random());

    ai_run(3);

    self.nextthink = time + 0.04167;
};

void() lt_tank_charge1 = [ 3, lt_tank_charge2 ] 
{ ai_run(7); self.monster_frame = 0; self.nextthink = time + 0.04167;};
void() lt_tank_charge2 = [ self.frame, lt_tank_charge2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 18) 
	{
		if (random() < 0.2)
			lt_tank_sfx_rush ();
        
        CheckContinueCharge (1 + 2*random());
		lt_tank_charge1 ();
		return;
	}

    ai_run(7);

    self.nextthink = time + 0.04167;
};

void() lt_tank_checkcharge =
{
	if (self.aiflags & AI_CHARGE)
		lt_tank_charge1 ();
	else
		lt_tank_run1 ();
}

//==============================================================================

static void(entity target, string name) lt_tank_tag_entity =
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

static void() lt_tank_tag_think =
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
	
	self.think = lt_tank_tag_think;
	self.angles = self.owner.angles;
	self.nextthink = time;
}

static void(string stringg, float fr, float end, string name, string tag) lt_tank_tag = 
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
		lt_tank_tag_entity(e, name);

	e.netname = tag;
	e.think = lt_tank_tag_think;
	e.nextthink = time;

	if (tag == string_null)
		self.prelock_save = e;
}

// rocket
void() lt_tank_missilea1 = [ 8, lt_tank_missilea2 ] {
	self.flags |= FL_DODGED;
	self.monster_frame = 0;
	lt_tank_tag ("progs/monsters/lt_tank/missile_tag.md3", 8, 68, string_null, "muzzle");

	ai_face(); self.nextthink = time + 0.04;  
};
void() lt_tank_missilea2 = [ self.frame, lt_tank_missilea2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 30)
	{
		lt_tank_flash2 ();
		self.pos1 = self.enemy.origin;
	}

	if (self.monster_frame == 35)
		lt_tank_shoot_missile (800);

	if (self.monster_frame >= 68) 
	{   
        lt_tank_run1 ();
		self.flags &= ~FL_DODGED;
		return;
	}

	ai_face ();

	if (self.monster_frame < 11)
	    ai_charge (3);

	if (self.monster_frame > 11 && self.monster_frame < 19)
	    ai_charge (0.5);

	if (self.monster_frame > 36 && self.monster_frame < 39)
	    ai_charge (-3.5);

	if (self.monster_frame > 40 && self.monster_frame < 44)
	    ai_charge (1.5);

	if (self.monster_frame > 51)
	    ai_charge (1.5);
};

// flamethrower
void() lt_tank_missileb1 = [ 9, lt_tank_missileb2 ] {
    self.flags |= FL_DODGED;
	self.monster_frame = 0;
	lt_tank_tag ("progs/monsters/lt_tank/flamethrower_tag.md3", 9, 71, string_null, "muzzle");
	
	ai_face(); self.nextthink = time + 0.04;  
};
void() lt_tank_missileb2 = [ self.frame, lt_tank_missileb2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 14)
	{
		sound(self, CHAN_WEAPON, "sounds_q4/strogg/lt_tank/flame_start.wav", 1, ATTN_NORM);
		self.t_width = time + 0.2;
	}

    if (self.monster_frame > 17 && self.monster_frame < 60)
        lt_tank_shoot_flame ();

	if (self.monster_frame == 60)
		sound(self, CHAN_WEAPON, "misc/null.wav", 1, ATTN_NORM);

	if (self.monster_frame >= 71) 
	{   
		lt_tank_checkcharge ();
        self.flags &= ~FL_DODGED;
		return;
	}

	if (self.monster_frame < 63)
	    ai_face ();
};

// rocket walk
void() lt_tank_missilec1 = [ 15, lt_tank_missilec2 ] {
	self.flags |= FL_DODGED;
	self.monster_frame = 0;
	lt_tank_tag ("progs/monsters/lt_tank/missile2_tag.md3", 15, 64, string_null, "muzzle");

	ai_face(); self.nextthink = time + 0.04167;  
};
void() lt_tank_missilec2 = [ self.frame, lt_tank_missilec2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04167;

	if (self.monster_frame == 13 || self.monster_frame == 31)
		lt_tank_shoot_missile (500);

	if (self.monster_frame >= 48) 
	{   
        lt_tank_run1 ();
		self.flags &= ~FL_DODGED;
		return;
	}

	ai_face ();
};


//==============================================================================

void() lt_tank_meleea1 = [ 5, lt_tank_meleea2 ] {
	self.monster_frame = 0;
	lt_tank_tag ("progs/monsters/lt_tank/melee1_tag.md3", 5, 22, "TE_WHOOSH", "mace");
	ai_face(); self.nextthink = time + 0.04;  };
void() lt_tank_meleea2 = [ self.frame, lt_tank_meleea2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 17)
		lt_tank_Melee(60);

	if (self.monster_frame >= 49) 
	{   
        lt_tank_checkcharge ();
		return;
	}

	if (self.monster_frame < 4)
	    ai_charge (0.5);

	if (self.monster_frame > 4 && self.monster_frame < 22)
	    ai_charge (3.5);

	if (self.monster_frame > 2 && self.monster_frame < 32)
	    ai_charge (1.3);

	if (self.monster_frame > 32 && self.monster_frame < 44)
	    ai_charge (-0.5);
};

void() lt_tank_meleeb1 = [ 6, lt_tank_meleeb2 ] {
	self.monster_frame = 0;
	lt_tank_tag ("progs/monsters/lt_tank/melee2_tag.md3", 6, 22, "TE_WHOOSH", "mace");
	ai_face(); self.nextthink = time + 0.04; };
void() lt_tank_meleeb2 = [ self.frame, lt_tank_meleeb2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 15)
		lt_tank_Melee(60);

	if (self.monster_frame >= 44)  
	{   
        lt_tank_checkcharge ();
		return;
	}

	if (self.monster_frame < 10)
	    ai_charge (0.2);

	if (self.monster_frame > 12 && self.monster_frame < 37)
	    ai_charge (3.5);

	if (self.monster_frame > 37 && self.monster_frame < 40)
	    ai_charge (-0.5);
};

void() lt_tank_meleec1 = [ 7, lt_tank_meleec2 ] {
	self.monster_frame = 0;
	lt_tank_tag ("progs/monsters/lt_tank/melee3_tag.md3", 7, 22, "TE_WHOOSH", "mace");
	ai_face(); self.nextthink = time + 0.04; };
void() lt_tank_meleec2 = [ self.frame, lt_tank_meleec2 ] 
{ 	
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 16)
		lt_tank_Melee(60);

	if (self.monster_frame >= 44)  
	{   
        lt_tank_checkcharge ();
		return;
	}

	ai_face ();
};

void() lt_tank_meleed1 = [ 4, lt_tank_meleed2 ] {
	self.monster_frame = 0;
	lt_tank_tag ("progs/monsters/lt_tank/uppercut_tag.md3", 4, 22, "TE_WHOOSH", "mace");
	ai_face(); self.nextthink = time + 0.04; };
void() lt_tank_meleed2 = [ self.frame, lt_tank_meleed2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 13)
		lt_tank_Melee(70);

	if (self.monster_frame >= 34)  
	{   
        lt_tank_checkcharge ();
		return;
	}


	if (self.monster_frame < 16)
	    ai_charge (7);

	if (self.monster_frame > 16 && self.monster_frame < 34)
	    ai_charge (2.5);
};

//==============================================================================

void() lt_tank_MeleeAttack =
{	
	lt_tank_sfx_growl ();

	float r = rint(random() * 2);

	if (self.aiflags & AI_CHARGE)
	{
		if (random() <= 0.5)
			lt_tank_missileb1 ();
		else
			lt_tank_meleed1 ();
		return;
	}
	else
	{	
		if (r == 1)
			lt_tank_meleea1 ();
		else if (r == 2)
			lt_tank_meleeb1 ();
		else	
			lt_tank_meleec1 ();
		return;
	}
};

void() lt_tank_MissileAttack =
{   
	lt_tank_sfx_growl ();

    if ((vlen(self.enemy.origin - self.origin) <= 200))
	{   
        if (self.aiflags & AI_CHARGE)
		{
			if (vlen(self.enemy.origin - self.origin) >= 100)
				lt_tank_missileb1 ();
			else
				lt_tank_meleed1 ();
			return;
		}
        else if (random() <= 0.5)
        {
            lt_tank_missileb1 ();
            return;
        }
		
	}

	if ((self.aiflags & AI_CHARGE) && random() <= 0.5)
		return;

	if (random () <= 0.5)
		lt_tank_missilea1 ();
	else
		lt_tank_missilec1 ();	
};

//==============================================================================

// regular ow
void() lt_tank_paina1 = [ 10, lt_tank_paina2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() lt_tank_paina2 = [ self.frame, lt_tank_paina2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint("????", "\n");
	if (self.monster_frame >= 19) 
	{
		lt_tank_run1 ();
		return;
	}
};

void() lt_tank_painb1 = [ 11, lt_tank_painb2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() lt_tank_painb2 = [ self.frame, lt_tank_painb2 ] 
{   
    //bprint(ftos(self.frame), "\n");
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint(">>>>>>>>>>?????", "\n");
	if (self.monster_frame >= 15) 
	{
		lt_tank_run1 ();
		return;
	}
};

// concussion
void() lt_tank_painc1 = [ 12, lt_tank_painc2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() lt_tank_painc2 = [ self.frame, lt_tank_painc2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint("????", "\n");
	if (self.monster_frame >= 27) 
	{   
		lt_tank_run1 ();
		return;
	}

    if (self.monster_frame == 1)
        ai_move (-0.5);

    if (self.monster_frame > 1 && self.monster_frame < 8)
        ai_move (-1);

    if (self.monster_frame < 8)
        M_walkmove (self.ideal_yaw + 90, 2);

    if (self.monster_frame > 8 && self.monster_frame < 19)
        ai_move (-2);

    if (self.monster_frame > 19)
        ai_move (-1);
};

// knocked
void() lt_tank_paind1 = [ 13, lt_tank_paind2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() lt_tank_paind2 = [ self.frame, lt_tank_paind2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint("????", "\n");
	if (self.monster_frame >= 51) 
	{   
		lt_tank_run1 ();
		return;
	}

    if (self.monster_frame < 10)
        ai_move (-3);

    if (self.monster_frame > 10 && self.monster_frame < 13)
        ai_move (-0.5);

    if (self.monster_frame > 20 && self.monster_frame < 25)
        ai_move (-0.5);

    if (self.monster_frame > 25)
        ai_move (-1.5);
};

// charging pain
void() lt_tank_paine1 = [ 14, lt_tank_paine2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() lt_tank_paine2 = [ self.frame, lt_tank_paine2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint("????", "\n");
	if (self.monster_frame >= 18) 
	{   
		lt_tank_charge1 ();
		return;
	}

    if (self.monster_frame == 1)
        ai_move (-0.5);

    if (self.monster_frame < 7)
        ai_charge (5);

    if (self.monster_frame > 7)
        ai_charge (7);
};

void(entity attacker, float damage, float MOD) lt_tank_pain =
{
//	if (self.touch == lt_tank_JumpTouch)
//		return;
//	bprint(ftos(MOD), "\n");
	if (self.flags & FL_DODGED)
	{	
		return;
	}

	if (self.pain_finished > time)
		return;

	self.pain_finished = time + 2;
	lt_tank_sfx_pain (); // sfx

	if (self.aiflags & AI_CHARGE)
	{
		lt_tank_paine1 ();
		return;
	}

	if (DMGTYPE_LTNG == MOD && (random() >= 0.9))
	{
  	  	if (random() <= 0.5)
	        lt_tank_paina1 ();
 	   	else
  	      	lt_tank_painb1 ();
		
		if (skill < 2)
			self.pain_finished = time + 0.5;
		else
			self.pain_finished = time + 1.5;
		return;
	}

	if (MOD == DMGTYPE_RAIL && (random() >= 0.6))
	{   
	//	bprint("knocked", "\n");
        lt_tank_paind1 ();

		self.pain_finished = time + 2.5;
		return;
	}

	if (random()*400 > damage)
		return; // didn't flinch

	if (damage > 150 || MOD == DMGTYPE_EXP)
	{   
        lt_tank_painc1 ();
		return;
	}

    if (random() <= 0.5)
        lt_tank_paina1 ();
    else
        lt_tank_painb1 ();
};

void() lt_tank_die =
{	
	//self.angles = '-90 0 0';
	if (self.health < -200)
	{	
		self.deadflag = DEAD_DEAD;
		self.solid = SOLID_NOT;
		MonsterGib (self.health); 
		remove(self);
		return;
	}
	
	if((self.deadflag & DEAD_DEAD))
		return;

	lt_tank_sfx_death ();

	local vector tmpangle;
	local float tempskin;
	tmpangle = self.angles;
	tempskin = self.skin;
	

//	if (random() <= 0.5)
		self.think = lt_tank_diea1;


	self.monster_frame = 0;

	self.deadflag = DEAD_DEAD;
	self.solid = SOLID_CORPSE;
//	self.movetype = MOVETYPE_STEP;
	self.nextthink = time + 0.04;

	self.angles = tmpangle;
	//self.skin = tempskin;
};

void() lt_tank_diea1 = [ 16 , lt_tank_diea2 ] { self.nextthink = time + 0.04; self.monster_frame = 0;};
void() lt_tank_diea2 = [ self.frame , lt_tank_diea2 ] 
{ 	
	//self.frame |= 0x8000;
	self.nextthink = time + 0.04;

	if (self.monster_frame < 20)
		ai_move (-5);

	self.monster_frame ++;
	if (self.monster_frame == 32)
	{
		self.maxs_z = 12;
		self.nextthink = -1;
		self.think = lt_tank_fade1;
		self.nextthink = time + 3.5;
		self.cnt = 1;
		return;
	}
};

void() lt_tank_fade1 = [ self.frame, lt_tank_gib2 ] 
{	
	if (self.cnt == 1)
		self.frame = 0;
	else
		self.frame = 1;
	
	
	setmodel(self, "progs/monsters/lt_tank/mesh_death.iqm");
	setsize(self, '-16 -16 0', '16 16 12');
	self.scale = 1;
	self.alpha = 1; 
	self.glowmod = '0.5 0.5 0.5'; 
	self.nextthink = time + 0.02;
};

void() lt_tank_gib1 = [ self.frame, lt_tank_gib2 ] 
{MonsterGib (self.health); self.skin = 1; self.alpha = 1; self.nextthink = time + 0.02;};

void() lt_tank_gib2 = [ self.frame, lt_tank_gib2 ] 
{ 	
	self.nextthink = time + 0.02;
	self.alpha -= 0.02;
	if (self.alpha <= 0)
	{
		remove(self);
		return;
	}
};

static string lt_tank_pain_list[2] = 
{
	"sounds_q4/strogg/lt_tank/pain1.wav",
	"sounds_q4/strogg/lt_tank/pain2.wav",
};	

static void() lt_tank_sfx_pain =
{
	local float r = rint(random());	

	sound(self, CHAN_VOICE, lt_tank_pain_list[r], 1, ATTN_NORM);
};

static string lt_tank_growl_list[2] = 
{
	"sounds_q4/strogg/lt_tank/growl1.wav",
	"sounds_q4/strogg/lt_tank/growl2.wav",
};	

static void() lt_tank_sfx_growl =
{
	local float r = rint(random());	

	sound(self, CHAN_VOICE, lt_tank_growl_list[r], 1, ATTN_NORM);
};

static void() lt_tank_sfx_death =
{
//	local float r = rint(random() * 4);	

    if (random() <= 0.5)
	    sound(self, CHAN_VOICE, "sounds_q4/strogg/lt_tank/die1.wav", 1, ATTN_NORM);
    else
        sound(self, CHAN_VOICE, "sounds_q4/strogg/lt_tank/die2.wav", 1, ATTN_NORM);
};

static void() lt_tank_sfx_rush =
{
//	local float r = rint(random() * 4);	

    if (random() <= 0.5)
	    sound(self, CHAN_VOICE, "sounds_q4/strogg/lt_tank/rush1.wav", 1, ATTN_IDLE);
    else
        sound(self, CHAN_VOICE, "sounds_q4/strogg/lt_tank/rush2.wav", 1, ATTN_IDLE);
};

static string lt_tank_breath_list[3] = 
{
	"sounds_q4/strogg/lt_tank/breath1.wav",
	"sounds_q4/strogg/lt_tank/breath2.wav",
    "sounds_q4/strogg/lt_tank/breath3.wav",
};	

static void() lt_tank_sfx_idle =
{
	local float r = rint(random()*2);	

	sound(self, CHAN_VOICE, lt_tank_breath_list[r], 1, ATTN_IDLE);
};

static void() lt_tank_sfx_sight =
{   
	//local float r = rint(random() * 13);	

    if (random() <= 0.5)
	    sound(self, CHAN_VOICE, "sounds_q4/strogg/lt_tank/sight1.wav", 1, ATTN_NORM);
    else
        sound(self, CHAN_VOICE, "sounds_q4/strogg/lt_tank/sight2.wav", 1, ATTN_NORM);
};

static void() lt_tank_sfx_swing =
{   
	//local float r = rint(random() * 13);	

    if (random() <= 0.5)
	    sound(self, CHAN_WEAPON, "sounds_q4/strogg/lt_tank/mace_swing1.wav", 1, ATTN_NORM);
    else
        sound(self, CHAN_WEAPON, "sounds_q4/strogg/lt_tank/mace_swing2.wav", 1, ATTN_NORM);
};

/*QUAKED monster_demon (1 0 0) (-32 -32 -24) (32 32 64) Ambush

*/
void() monster_lt_tank_cache =
{
	precache_model("progs/monsters/lt_tank/mesh.md5.info");
	precache_model("progs/monsters/lt_tank/missile_tag.md3");
	precache_model("progs/monsters/lt_tank/missile2_tag.md3");
	precache_model("progs/monsters/lt_tank/flamethrower_tag.md3");
	precache_model("progs/monsters/lt_tank/melee1_tag.md3");
	precache_model("progs/monsters/lt_tank/melee2_tag.md3");
	precache_model("progs/monsters/lt_tank/melee3_tag.md3");
    precache_model("progs/monsters/lt_tank/uppercut_tag.md3");
	precache_model("progs/monsters/lt_tank/mesh_death.iqm");

	precache_sound("sounds_q4/strogg/gladiator/rapidfire_01.wav");
	precache_sound("sounds_q4/strogg/gladiator/rapidfire_02.wav");

	float i;

//	for (i = 0; i < 2; i++)
//	{
	precache_sound("sounds_q4/strogg/lt_tank/sight1.wav");
    precache_sound("sounds_q4/strogg/lt_tank/sight2.wav");
	precache_sound("sounds_q4/strogg/lt_tank/flame_loop.wav");
	precache_sound("sounds_q4/strogg/lt_tank/flame_start.wav");
//	}

	for (i = 0; i < 2; i++)
	{
//		precache_sound(lt_tank_death_list[i]);
		precache_sound(lt_tank_growl_list[i]);
        precache_sound(lt_tank_pain_list[i]);
       // precache_sound(lt_tank_breath_list[i]);
	}

	for (i = 0; i < 3; i++)
	{
        precache_sound(lt_tank_breath_list[i]);
	}

	precache_sound("sounds_q4/strogg/lt_tank/rush1.wav");
	precache_sound("sounds_q4/strogg/lt_tank/rush2.wav");
	precache_sound("sounds_q4/strogg/lt_tank/die1.wav");
    precache_sound("sounds_q4/strogg/lt_tank/die2.wav");

    precache_sound("sounds_q4/strogg/lt_tank/mace_swing1.wav");
    precache_sound("sounds_q4/strogg/lt_tank/mace_swing2.wav");

//	spawn_demon ();
};

void() monster_light_tank =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	monster_lt_tank_cache ();	
	spawn_light_tank ();
};

void() spawn_light_tank =
{
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel(self, "progs/monsters/lt_tank/mesh.md5.info");
	self.classname = "monster_light_tank";
	setsize(self, '-24 -24 0', '24 24 72');
	self.health = 1350;
	self.max_health = 1350;
	self.mass = 800;
	self.scale = 0.8;

	self.th_stand = lt_tank_stand1;
	self.th_walk = lt_tank_walk1;
	self.th_run = lt_tank_run1;
	self.th_die = lt_tank_die;
	self.th_melee = lt_tank_MeleeAttack; // one of two attacks
	self.th_missile = lt_tank_MissileAttack; // jump attack
	self.th_pain = lt_tank_pain;
	//self.th_checkatck = GladCheckAttack;
	self.th_spawn = spawn_light_tank;
	//self.th_dodge = lt_tank_run1;
	self.th_sight = lt_tank_sfx_sight;
	//setcustomskin (self, "progs/monsters/lt_tank/gladiator.skin")
	self.deathtype = "was wrecked by a Light Tank";
	self.count = 0;
	self.pissed = 0;
    self.th_char = lt_tank_charge1;
//	self.emiteffectnum = particleeffectnum("_lt_tank_dress");

	walkmonster_start();
};


/*
==============================================================================

DEMON

==============================================================================
*/

void(float speed) lt_tank_shoot_missile = 
{   
//	entity e;

//	vector forward, right, up;
//	AngleVectors(self.angles, forward, right, up);

	//float tagindex = gettagindex (self.prelock_save, cannon);
	vector org = self.pos2;
	//self.pos2 = org + forward*4 + up*-4;
	lt_tank_flash ();
	vector dir;

	RocketNoise ();

	if (self.pos1)
		 dir = normalize(self.pos1 - org + self.enemy.view_ofs);
	else
		 dir = normalize(self.enemy.origin - org + self.enemy.view_ofs);

	self.pos1 = '0 0 0';
//	dir = dir + right * horz + up * vert;
	dir = normalize(dir);

	launch_rocket (org, dir, speed, 80, 80, "EF_REVTRAIL");
};

void() lt_tank_shoot_flame = 
{   
//	entity e;
	vector org = self.pos2;

	//self.pos2 = org ;

	vector dir = normalize(self.enemy.origin - org + '0 0 -24');

	vector f, r, u;
	AngleVectors(self.angles, f, r, u);

	dir += r * crandom() * 0.08 + u * crandom() * 0.08;
//	LaunchLaser (org, dir, '0 0 0', '0 0 0');

	if (self.t_width < time)
	{
		sound(self, CHAN_WEAPON, "sounds_q4/strogg/lt_tank/flame_loop.wav", 1, ATTN_NORM);
		self.t_width = time + 0.2;
	}

	Launch_Flame (org, dir + r * crandom() * 0.08 + u * crandom() * 0.2, 5, 100, 0.4, "TE_FLAMETHROWER1");
	Launch_Flame (org + f * 24, dir, 8, 300, 0.4 + random(), "TE_FLAMETHROWER");
	Launch_Flame (org + f * 16, dir, 5, 300, 0.3 + random(), "TE_FLAMETHROWER");
};

void(float kick) lt_tank_Melee =
{
	float ldmg;

	ai_face();

	ldmg = 34 + 15*(random() + random() + random());

	vector	aim;

	aim = setvector (100, 0, 0);
	if (fire_hit(aim, rint(ldmg), kick))
	{	
		meat_hit (); 
	}
	else
	{
	
		if (random() <= 0.5)
			sound(self, CHAN_WEAPON, "sounds_q4/strogg/lt_tank/mace_swing1.wav", 1, ATTN_NORM);
		else
			sound(self, CHAN_WEAPON, "sounds_q4/strogg/lt_tank/mace_swing2.wav", 1, ATTN_NORM);
	//	self.pissed += 0.3;
	}
};

void() lt_tank_flash = 
{   
   
    vector org;

    org = self.pos2;

    pointparticles (particleeffectnum("TE_MUZZLEFLASH2"), org, '0 0 0');
	pointparticles (particleeffectnum("EF_MUZZLEFLASH2"), org, '0 0 0');
};

void() lt_tank_flash2 = 
{   
   
    vector org;

    org = self.pos2;

    pointparticles (particleeffectnum("TE_BOLT_IMPACT_RED"), org, '0 0 0', 4);
//	pointparticles (particleeffectnum("EF_MUZZLEFLASH2"), org, '0 0 0');
};



//===========================================================================
