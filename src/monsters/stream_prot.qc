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

void() strm_prot_stand1 = [ 1, strm_prot_stand2 ] { ai_stand(); self.monster_frame = 0;};
void() strm_prot_stand2 = [ self.frame, strm_prot_stand2 ] 
{ 	
	self.monster_frame ++;
	if (self.monster_frame >= 58) 
	{	
		if (random() < 0.2)
			strm_prot_sfx_idle ();

		strm_prot_stand1 ();
		return;
	}
	ai_stand ();
};

void() strm_prot_walk1 = [ 2, strm_prot_walk2 ] 
{ ai_walk(4); self.monster_frame = 0; self.nextthink = time + 0.04167;};
void() strm_prot_walk2 = [ self.frame, strm_prot_walk2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 45) 
	{
		if (random() < 0.3)
			strm_prot_sfx_idle ();

		strm_prot_walk1 ();
		return;
	}


    if (self.monster_frame != 34 && self.monster_frame != 35
    && self.monster_frame != 14 && self.monster_frame != 15 && self.monster_frame != 16)
	{	
		if (self.monster_frame == 36)
			ai_walk (1);
		else if (self.monster_frame == 17)
			ai_walk (1);
		else if (self.monster_frame > 34 && self.monster_frame < 36)
			ai_walk (6);
		else	
			ai_walk (5);

	}

    self.nextthink = time + 0.04167;
};

void() strm_prot_run1 = [ 2, strm_prot_run2 ] 
{ ai_run(4); self.monster_frame = 0; self.nextthink = time + 0.04167;};
void() strm_prot_run2 = [ self.frame, strm_prot_run2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 45) 
	{
		if (random() < 0.3)
			strm_prot_sfx_idle ();

		strm_prot_run1 ();
		return;
	}

    if (self.monster_frame != 34 && self.monster_frame != 35 && 
    self.monster_frame != 14 && self.monster_frame != 15 && self.monster_frame != 16)
	{	
		if (self.monster_frame == 36)
			ai_run (1);
		else if (self.monster_frame == 17)
			ai_run (1);
		else if (self.monster_frame > 34 && self.monster_frame < 36)
			ai_run (6);
		else	
			ai_run (5);
	}

    self.nextthink = time + 0.04167;
};

void() strm_prot_strafel1 = [ 3, strm_prot_strafel2 ] 
{ 	ai_face();
	M_walkmove (self.ideal_yaw + 90, 4); self.nextthink = time + 0.04; self.monster_frame = 0;};
void() strm_prot_strafel2 = [ self.frame, strm_prot_strafel2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 31) 
	{	
		//self.attack_state = AS_STRAIGHT;
		self.flags &= ~FL_DODGED;
	//	despawn_shield ();
		strm_prot_run1 ();
		return;
	}
	if (self.monster_frame < 20 && self.monster_frame > 1)
    {
    	ai_face();
    	M_walkmove (self.ideal_yaw + 90, 5);
    }

    if (self.monster_frame > 20)
    {
    	M_walkmove (self.ideal_yaw - 90, 1);
    }
	
	self.nextthink = time + 0.04;
};

void() strm_prot_strafer1 = [ 4, strm_prot_strafer2 ] 
{ 	ai_face();
	M_walkmove (self.ideal_yaw -90, 4); self.nextthink = time + 0.0; self.monster_frame = 0;};
void() strm_prot_strafer2 = [ self.frame, strm_prot_strafer2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 31) 
	{	
		//self.attack_state = AS_STRAIGHT;
		self.flags &= ~FL_DODGED;
	//	despawn_shield ();
		strm_prot_run1 ();
		return;
	}

	if (self.monster_frame < 20 && self.monster_frame > 1)
    {
    	ai_face();
    	M_walkmove (self.ideal_yaw - 90, 5);
    }

    if (self.monster_frame > 20)
    {
    	M_walkmove (self.ideal_yaw + 90, 1);
    }
	
	self.nextthink = time + 0.04;
};


void() strm_prot_strafe =
{	
	if ((self.flags & FL_DODGED) && (random() <= 0.3))
	{	
		self.flags &= ~FL_DODGED;
		strm_prot_run1 ();
		return;
	}

	makevectors(self.angles);
	tracebox (self.origin, self.mins, self.maxs, self.origin + v_right * 120, FALSE, self);
	float right = trace_fraction;

	tracebox (self.origin, self.mins, self.maxs, self.origin + v_right * -120, FALSE, self);
	float left = trace_fraction;

	if (left == 1 && right == 1)
	{
		if (random() <= 0.5)
			strm_prot_strafel1 ();
		else 
			strm_prot_strafer1 ();
		return;
	}

	if (left == 1)
		strm_prot_strafel1 ();
	else if (right == 1)
		strm_prot_strafer1 ();

	if (left < 1 || right < 1)
	{	
		self.flags &= ~FL_DODGED;
		strm_prot_run1 ();
		return;
	}
	
	self.nextthink = time;
};

//==============================================================================

static void(entity target, string name) strm_prot_tag_entity =
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

static void() strm_prot_tag_think =
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
	
	self.think = strm_prot_tag_think;
	self.angles = self.owner.angles;
	self.nextthink = time;
}

static void(string stringg, float fr, float end, string name, string tag) strm_prot_tag = 
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
		strm_prot_tag_entity(e, name);

	e.netname = tag;
	e.think = strm_prot_tag_think;
	e.nextthink = time;

	if (tag == string_null)
		self.prelock_save = e;
}

// missile barrage
void() strm_prot_missilea1 = [ 8, strm_prot_missilea2 ] {
	self.flags |= FL_DODGED;
	self.monster_frame = 0;
	strm_prot_tag ("progs/monsters/stream_protector/missile_tag.md3", 8, 79, string_null, string_null);

	ai_face(); self.nextthink = time + 0.04;  
};
void() strm_prot_missilea2 = [ self.frame, strm_prot_missilea2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 31)
	{
		local entity e = spawn();
		setorigin (e, self.enemy.origin);
		e.view_ofs = '0 0 0';
		e.think = SUB_Remove;
		e.nextthink = time + 6;
		self.oldenemy = self.enemy;
		e.health = 999999;
		e.classname = "aim_target";
		self.enemy = e;
		self.aiflags |= AI_AIMFLY;
	}

	if (self.monster_frame == 32)
		strm_prot_shoot_missile("muzzle1", 100, 950);
	if (self.monster_frame == 38)
		strm_prot_shoot_missile("muzzle2", -100, 950);
	if (self.monster_frame == 45)
		strm_prot_shoot_missile("muzzle3", 150, 1050);
	if (self.monster_frame == 52)
		strm_prot_shoot_missile("muzzle4", -150, 1050);

	if (self.monster_frame >= 79) 
	{   
		self.enemy = self.oldenemy;
		self.oldenemy = world;
        strm_prot_strafe ();
		self.flags &= ~FL_DODGED;
		self.aiflags &= ~AI_AIMFLY;
		return;
	}

	if (self.monster_frame < 32)
	    ai_face ();

	if (self.monster_frame > 31 && self.monster_frame < 62)
	    ai_face ();
};

// chaingun barrage
void() strm_prot_missileb1 = [ 7, strm_prot_missileb2 ] {

	self.monster_frame = 0;
	strm_prot_tag ("progs/monsters/stream_protector/cg_tag.md3", 7, 56, string_null, string_null);

	ai_face(); self.nextthink = time + 0.04;  
};
void() strm_prot_missileb2 = [ self.frame, strm_prot_missileb2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame > 25 && self.monster_frame < 49)
	{	
		if (self.monster_frame % 2)
		{
			strm_prot_shoot_bullets("muzzle1");
			strm_prot_shoot_bullets("muzzle2");
		}
	}

	if (self.monster_frame >= 56) 
	{   
		if (random() <= 0.5)
        	strm_prot_strafe ();
		else
			strm_prot_run1 ();

		return;
	}

	if (self.monster_frame < 52)
	    ai_face ();
};

// blaster
void() strm_prot_missilec1_0 = [ 9, strm_prot_missilec2_0 ] {
	ai_face(); self.nextthink = time + 0.04; self.monster_frame = 0; };
void() strm_prot_missilec2_0 = [ self.frame, strm_prot_missilec2_0 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	
	if (self.monster_frame >= 14) 
	{   
        strm_prot_missilec1_1 ();
        self.count = 0;
		return;
	}

	ai_face();
};

void() strm_prot_missilec1_1 = [ 10, strm_prot_missilec2_1 ] {

	strm_prot_tag ("progs/monsters/stream_protector/plasma_tag.md3", 10, 999, string_null, "muzzle1");
	ai_face(); self.nextthink = time + 0.02; self.monster_frame = 0; };
void() strm_prot_missilec2_1 = [ self.frame, strm_prot_missilec2_1 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.02;

    if (self.monster_frame == 1)
    {
        strm_prot_shoot_lasers ();
	//	gla_fireblaster (24);
        self.count ++;
    }

    if (self.monster_frame >= 7)
        self.monster_frame = 0;

	if (!visible(self.enemy)) 
	{   
        self.count = 0;
		if (random() <= 0.4)
			strm_prot_strafe ();
		else
			strm_prot_missilec1_2 ();

		return;
	}
	
	if (self.count >= 12) 
	{   
		if (random() <= 0.4)
			strm_prot_strafe ();
		else
			strm_prot_missilec1_2 ();
		return;
	}

	ai_face();
};

void() strm_prot_missilec1_2 = [ 11, strm_prot_missilec2_2 ] {

	ai_face(); self.nextthink = time + 0.04; self.monster_frame = 0; };
void() strm_prot_missilec2_2 = [ self.frame, strm_prot_missilec2_2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame >= 19) 
	{   
        self.count = 0;
		strm_prot_run1 ();
		return;
	}

	ai_face();
};

// flamethrower
void() strm_prot_missiled1_0 = [ 12, strm_prot_missiled2_0 ] {
	ai_face(); self.nextthink = time + 0.04; self.monster_frame = 0; };
void() strm_prot_missiled2_0 = [ self.frame, strm_prot_missiled2_0 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	
	if (self.monster_frame >= 19) 
	{   
		sound(self, CHAN_WEAPON, "sounds_q4/strogg/lt_tank/flame_start.wav", 1, ATTN_NORM);
		self.t_width = time + 0.2;
        strm_prot_missiled1_1 ();
        self.count = 0;
		return;
	}

	ai_face();
};

void() strm_prot_missiled1_1 = [ 13, strm_prot_missiled2_1 ] {

	strm_prot_tag ("progs/monsters/stream_protector/flame_tag.md3", 13, 999, string_null, "muzzle1");
	ai_face(); self.nextthink = time + 0.04; self.monster_frame = 0; };
void() strm_prot_missiled2_1 = [ self.frame, strm_prot_missiled2_1 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

    strm_prot_shoot_flame ();
	//	gla_fireblaster (24);
    //    self.count ++;

	if (!visible(self.enemy)) 
	{   
		sound(self, CHAN_WEAPON, "misc/null.wav", 1, ATTN_NORM);
        self.count = 0;
		if (random() <= 0.4)
			strm_prot_strafe ();
		else
			strm_prot_missiled1_2 ();

		return;
	}
	
	if (self.monster_frame >= 38) 
	{   
		sound(self, CHAN_WEAPON, "misc/null.wav", 1, ATTN_NORM);
		if (random() <= 0.4)
			strm_prot_strafe ();
		else
			strm_prot_missiled1_2 ();
		return;
	}

	ai_face();
};

void() strm_prot_missiled1_2 = [ 14, strm_prot_missiled2_2 ] {

	ai_face(); self.nextthink = time + 0.04; self.monster_frame = 0; };
void() strm_prot_missiled2_2 = [ self.frame, strm_prot_missiled2_2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame >= 17) 
	{   
        self.count = 0;
		strm_prot_run1 ();
		return;
	}

	ai_face();
};

//==============================================================================

void() strm_prot_meleea1 = [ 5, strm_prot_meleea2 ] {
	self.monster_frame = 0;
	strm_prot_tag ("progs/monsters/stream_protector/melee_tag.md3", 5, 22, "TE_WHOOSH", "muzzle1");
	ai_face(); self.nextthink = time + 0.04;  };
void() strm_prot_meleea2 = [ self.frame, strm_prot_meleea2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 17)
		strm_prot_Melee(60);

	if (self.monster_frame >= 54) 
	{   
        strm_prot_strafe ();
		return;
	}

	if (self.monster_frame < 20)
	    ai_face ();
};

void() strm_prot_meleeb1 = [ 6, strm_prot_meleeb2 ] {
	self.monster_frame = 0;
	ai_face(); self.nextthink = time + 0.04; };
void() strm_prot_meleeb2 = [ self.frame, strm_prot_meleeb2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 26 || self.monster_frame == 30)
		strm_prot_Melee(15);

	if (self.monster_frame >= 54)  
	{   
        strm_prot_strafe();
		return;
	}

	if (self.monster_frame < 35)
	    ai_face ();
};


//==============================================================================

void() strm_prot_MeleeAttack =
{	
	strm_prot_sfx_growl ();

	float r = rint(random()*2);
	if (r == 1)
		strm_prot_meleea1 ();
	else if (r == 2)
		strm_prot_meleeb1 ();
	else 
	{	
		if (random() <= 0.3)
			strm_prot_missiled1_0 ();
		else
		{
		if (random() <= 0.5)	
			strm_prot_meleea1 ();
		else
			strm_prot_meleeb1 ();
		}
	}
};

void() strm_prot_MissileAttack =
{   
	strm_prot_sfx_growl ();

	if ((vlen(self.enemy.origin - self.origin) <= 300) && random() <= 0.3)
	{
		strm_prot_missiled1_0 ();
		return;
	}

	float r = rint(random()*2);

	if (r == 1)
		strm_prot_missilea1 ();
	else if (r == 2)
		strm_prot_missileb1 ();
	else 
	{
		strm_prot_missilec1_0 ();
	}
		
};

//==============================================================================

// regular ow
void() strm_prot_paina1 = [ 15, strm_prot_paina2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() strm_prot_paina2 = [ self.frame, strm_prot_paina2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint("????", "\n");
	if (self.monster_frame >= 19) 
	{
		strm_prot_run1 ();
		return;
	}
};

void() strm_prot_painb1 = [ 16, strm_prot_painb2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() strm_prot_painb2 = [ self.frame, strm_prot_painb2 ] 
{   
    //bprint(ftos(self.frame), "\n");
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint(">>>>>>>>>>?????", "\n");
	if (self.monster_frame >= 19) 
	{
		strm_prot_run1 ();
		return;
	}
};

// concussion
void() strm_prot_painc1 = [ 17, strm_prot_painc2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() strm_prot_painc2 = [ self.frame, strm_prot_painc2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint("????", "\n");
	if (self.monster_frame >= 29) 
	{   
		strm_prot_run1 ();
		return;
	}
};

void(entity attacker, float damage, float MOD) strm_prot_pain =
{
//	if (self.touch == strm_prot_JumpTouch)
//		return;
//	bprint(ftos(MOD), "\n");
	if (self.flags & FL_DODGED)
	{	
		return;
	}

	if (self.pain_finished > time)
		return;

	self.pain_finished = time + 2;
	strm_prot_sfx_pain (); // sfx

	if (DMGTYPE_LTNG == MOD && (random() >= 0.9))
	{
  	  	if (random() <= 0.5)
	        strm_prot_paina1 ();
 	   	else
  	      	strm_prot_painb1 ();
		
		if (skill < 2)
			self.pain_finished = time + 0.5;
		else
			self.pain_finished = time + 1.5;
		return;
	}

	if (MOD == DMGTYPE_RAIL && random() >= 0.75)
	{   
	//	bprint("knocked", "\n");
        strm_prot_painc1 ();

		self.pain_finished = time + 2.5;
		return;
	}

	if (random()*500 > damage)
		return; // didn't flinch

	if (damage > 150 || MOD == DMGTYPE_EXP)
	{   
        strm_prot_painc1 ();
		return;
	}

    if (random() <= 0.5)
        strm_prot_paina1 ();
    else
        strm_prot_painb1 ();
};

void() strm_prot_die =
{	
	//self.angles = '-90 0 0';
	if (self.health < -600)
	{	
		self.deadflag = DEAD_DEAD;
		self.solid = SOLID_NOT;
		MonsterGib (self.health); 
		remove(self);
		return;
	}
	
	if((self.deadflag & DEAD_DEAD))
		return;

	strm_prot_sfx_death ();

	local vector tmpangle;
	local float tempskin;
	tmpangle = self.angles;
	tempskin = self.skin;
	

	if (random() <= 0.5)
		self.think = strm_prot_diea1;
	else
		self.think = strm_prot_dieb1;

	self.monster_frame = 0;

	self.deadflag = DEAD_DEAD;
	self.solid = SOLID_CORPSE;
//	self.movetype = MOVETYPE_STEP;
	self.nextthink = time + 0.04;

	self.angles = tmpangle;
	//self.skin = tempskin;
};

void() strm_prot_diea1 = [ 18 , strm_prot_diea2 ] { self.nextthink = time + 0.04; self.monster_frame = 0;};
void() strm_prot_diea2 = [ self.frame , strm_prot_diea2 ] 
{ 	
	//self.frame |= 0x8000;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 4)
		sound(self, CHAN_BODY, "sounds_q4/strogg/stream_protector/stream_fall.wav", 1, ATTN_NORM);

	self.monster_frame ++;
	if (self.monster_frame == 30)
	{
		self.maxs_z = 12;
		self.nextthink = -1;
		self.think = strm_prot_fade1;
		self.nextthink = time + 3.5;
		self.cnt = 1;
		return;
	}
};

void() strm_prot_dieb1 = [ 19 , strm_prot_dieb2 ] { self.nextthink = time + 0.04; self.monster_frame = 0;};
void() strm_prot_dieb2 = [ self.frame , strm_prot_dieb2 ] 
{ 	
	//self.frame |= 0x8000;
    
	self.nextthink = time + 0.04;

    if (self.monster_frame == 4)
		sound(self, CHAN_BODY, "sounds_q4/strogg/stream_protector/stream_fall.wav", 1, ATTN_NORM);

	self.monster_frame ++;
	if (self.monster_frame == 50)
	{
		self.maxs_z = 12;
		self.nextthink = -1;
		self.think = strm_prot_fade1;
		self.nextthink = time + 3.5;
	//	self.cnt = 1;
		return;
	}
};


void() strm_prot_fade1 = [ self.frame, strm_prot_gib2 ] 
{	
	if (self.cnt == 1)
		self.frame = 0;
	else
		self.frame = 1;
	
	
	setmodel(self, "progs/monsters/stream_protector/strm_prot_death.iqm");
	setsize(self, '-16 -16 0', '16 16 12');
	self.scale = 1;
	self.skin = 1; 
	self.alpha = 1; 
	self.glowmod = '0.5 0.5 0.5'; 
	self.nextthink = time + 0.02;
};

void() strm_prot_gib1 = [ self.frame, strm_prot_gib2 ] 
{MonsterGib (self.health); self.skin = 1; self.alpha = 1; self.nextthink = time + 0.02;};

void() strm_prot_gib2 = [ self.frame, strm_prot_gib2 ] 
{ 	
	self.nextthink = time + 0.02;
	self.alpha -= 0.02;
	if (self.alpha <= 0)
	{
		remove(self);
		return;
	}
};

static string strm_prot_pain_list[2] = 
{
	"sounds_q4/strogg/stream_protector/stream_pain1.wav",
	"sounds_q4/strogg/stream_protector/stream_pain2.wav",
};	

static void() strm_prot_sfx_pain =
{
	local float r = rint(random());	

	sound(self, CHAN_VOICE, strm_prot_pain_list[r], 1, ATTN_NORM);
};

static string strm_prot_growl_list[2] = 
{
	"sounds_q4/strogg/stream_protector/growl1.wav",
	"sounds_q4/strogg/stream_protector/stream_growl.wav",
};	

static void() strm_prot_sfx_growl =
{
	local float r = rint(random());	

	sound(self, CHAN_VOICE, strm_prot_growl_list[r], 1, ATTN_NORM);
};

static void() strm_prot_sfx_death =
{
//	local float r = rint(random() * 4);	

	sound(self, CHAN_VOICE, "sounds_q4/strogg/stream_protector/stream_death.wav", 1, ATTN_NORM);
};

static string strm_prot_breath_list[2] = 
{
	"sounds_q4/strogg/stream_protector/chatter1.wav",
	"sounds_q4/strogg/stream_protector/chatter2.wav",
};	

static void() strm_prot_sfx_idle =
{
	local float r = rint(random());	

	sound(self, CHAN_VOICE, strm_prot_breath_list[r], 1, ATTN_IDLE);
};

static void() strm_prot_sfx_sight =
{   
	//local float r = rint(random() * 13);	

	sound(self, CHAN_VOICE, "sounds_q4/strogg/stream_protector/stream_alert.wav", 1, ATTN_NORM);
};

/*QUAKED monster_demon (1 0 0) (-32 -32 -24) (32 32 64) Ambush

*/
void() monster_strm_prot_cache =
{
	precache_model("progs/monsters/stream_protector/stream_protector.md5.info");
	precache_model("progs/monsters/stream_protector/strm_prot_death.iqm");
	precache_model("progs/monsters/stream_protector/missile_tag.md3");
	precache_model("progs/monsters/stream_protector/cg_tag.md3");
	precache_model("progs/monsters/stream_protector/plasma_tag.md3");
	precache_model("progs/monsters/stream_protector/flame_tag.md3");
	precache_model("progs/monsters/stream_protector/melee_tag.md3");

	precache_sound("sounds_q4/strogg/gladiator/rapidfire_01.wav");
	precache_sound("sounds_q4/strogg/gladiator/rapidfire_02.wav");

	float i;

//	for (i = 0; i < 2; i++)
//	{
	precache_sound("sounds_q4/strogg/stream_protector/stream_alert.wav");
    precache_sound("sounds_q4/strogg/stream_protector/stream_fall.wav");
	precache_sound("sounds_q4/strogg/lt_tank/flame_loop.wav");
	precache_sound("sounds_q4/strogg/lt_tank/flame_start.wav");
//	}

	for (i = 0; i < 2; i++)
	{
//		precache_sound(strm_prot_death_list[i]);
		precache_sound(strm_prot_growl_list[i]);
        precache_sound(strm_prot_pain_list[i]);
        precache_sound(strm_prot_breath_list[i]);
	}

	precache_sound("sounds_q4/strogg/stream_protector/ready_weapon.wav");
	precache_sound("sounds_q4/strogg/stream_protector/swing1.wav");
	precache_sound("sounds_q4/strogg/stream_protector/swing2.wav");
    precache_sound("sounds_q4/strogg/stream_protector/stream_death.wav");

//	spawn_demon ();
};

void() monster_stream_protector =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	monster_strm_prot_cache ();	
	spawn_stream_protector ();
};

void() spawn_stream_protector =
{
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel(self, "progs/monsters/stream_protector/stream_protector.md5.info");
	self.classname = "monster_stream_protector";
	setsize(self, '-32 -32 0', '32 32 88');
	self.health = 1800;
	self.max_health = 1800;
	self.mass = 800;
	self.scale = 0.8;

	self.th_stand = strm_prot_stand1;
	self.th_walk = strm_prot_walk1;
	self.th_run = strm_prot_run1;
	self.th_die = strm_prot_die;
	self.th_melee = strm_prot_MeleeAttack; // one of two attacks
	self.th_missile = strm_prot_MissileAttack; // jump attack
	self.th_pain = strm_prot_pain;
	//self.th_checkatck = GladCheckAttack;
	self.th_spawn = spawn_stream_protector;
	self.th_dodge = strm_prot_strafe;
	self.th_sight = strm_prot_sfx_sight;
	//setcustomskin (self, "progs/monsters/stream_protector/gladiator.skin")
	self.deathtype = "was disposed by a Stream Protector";
	self.count = 0;
	self.pissed = 0;
//	self.emiteffectnum = particleeffectnum("_strm_prot_dress");

	walkmonster_start();
};


/*
==============================================================================

DEMON

==============================================================================
*/

void(string cannon, float horz, float vert) strm_prot_shoot_missile = 
{   
//	entity e;

	vector forward, right, up;
	AngleVectors(self.angles, forward, right, up);

	float tagindex = gettagindex (self.prelock_save, cannon);
	vector org = gettaginfo (self.prelock_save, tagindex);
	self.pos2 = org + forward*4 + up*-4;
	strm_prot_flash ();

	RocketNoise ();
	vector dir = normalize(self.enemy.origin - org + self.enemy.view_ofs);

	dir = dir + right * horz + up * vert;
	dir = normalize(dir);

	launch_rocket_home (org, dir, 800, 80, 80, 600, "EF_REVTRAIL");
};


void(string cannon) strm_prot_shoot_bullets = 
{   
//	entity e;
	vector f, r, u;
	AngleVectors(self.angles, f, r, u);

	float tagindex = gettagindex (self.prelock_save, cannon);
	vector org = gettaginfo (self.prelock_save, tagindex);
	self.pos2 = org + f*16;
	strm_prot_flash ();

	vector dir = normalize(self.enemy.origin - org + self.enemy.view_ofs);

	AutofireMachineEnemyNoise(); 

	dir += r * crandom() * 0.06 + u * crandom() * 0.05;
	Strogg_Bullet (org, dir, 10, 20, 600);
	//Strogg_Bullet (org, dir, 10, 20, 400);
};

void() strm_prot_shoot_lasers = 
{   
//	entity e;
	vector org = self.pos2;

	//self.pos2 = org ;

	vector dir = normalize(self.enemy.origin - org + self.enemy.view_ofs);

	vector f, r, u;
	AngleVectors(self.angles, f, r, u);

	dir += r * crandom() * 0.06 + u * crandom() * 0.05;
	LaunchLaser (org, dir, '0 0 0', '0 0 0', 25);

	if (random() <= 0.5)
		sound(self, CHAN_WEAPON, "sounds_q4/strogg/gladiator/rapidfire_01.wav", 1, ATTN_NORM);
	else
		sound(self, CHAN_WEAPON, "sounds_q4/strogg/gladiator/rapidfire_02.wav", 1, ATTN_NORM);

	
	pointparticles (particleeffectnum("TE_BOLT_IMPACT_RED"), org + f*16, '0 0 0', 1);
	pointparticles (particleeffectnum("EF_MUZZLEFLASH2"), org + f*16, '0 0 0');
};

void() strm_prot_shoot_flame = 
{   
//	entity e;
	vector org = self.pos2;

	//self.pos2 = org ;

	vector dir = normalize(self.enemy.origin - org + '0 0 4');

	vector f, r, u;
	AngleVectors(self.angles, f, r, u);

	dir += r * crandom() * 0.08 + u * crandom() * 0.2;
//	LaunchLaser (org, dir, '0 0 0', '0 0 0');

	if (self.t_width < time)
	{	
		//bprint("???");
		sound(self, CHAN_WEAPON, "sounds_q4/strogg/lt_tank/flame_loop.wav", 1, ATTN_NORM);
		self.t_width = time + 0.2;
	}

	Launch_Flame (org, dir + r * crandom() * 0.08 + u * crandom() * 0.2, 5, 100, 0.4, "TE_FLAMETHROWER1");
	Launch_Flame (org + f * 24, dir, 8, 300, 0.4 + random(), "TE_FLAMETHROWER");
	Launch_Flame (org + f * 16, dir, 5, 300, 0.3 + random(), "TE_FLAMETHROWER");
};

void(float kick) strm_prot_Melee =
{
	float ldmg;

	ai_face();

	ldmg = 30 + 15*(random() + random() + random());

	vector	aim;

	aim = setvector (120, 0, 0);
	if (fire_hit(aim, rint(ldmg), kick))
	{	
		meat_hit (); 
	}
	else
	{
	
		meat_miss (); 
	//	self.pissed += 0.3;
	}
};

void() strm_prot_flash = 
{   
   
    vector org;

    org = self.pos2;

    pointparticles (particleeffectnum("TE_MUZZLEFLASH2"), org, '0 0 0');
	pointparticles (particleeffectnum("EF_MUZZLEFLASH2"), org, '0 0 0');
};

void() strm_prot_flash2 = 
{   
	if (skill > 2)
		return;
	   
    vector org;

    org = self.pos2;

    pointparticles (particleeffectnum("TE_BOLT_IMPACT_RED"), org, '0 0 0', 4);
//	pointparticles (particleeffectnum("EF_MUZZLEFLASH2"), org, '0 0 0');
};



//===========================================================================
