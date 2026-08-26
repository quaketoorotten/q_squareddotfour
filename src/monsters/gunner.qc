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

void() gunner_stand1 = [ 1, gunner_stand2 ] { ai_stand(); self.monster_frame = 0;};
void() gunner_stand2 = [ self.frame, gunner_stand2 ] 
{ 	
	self.monster_frame ++;
	if (self.monster_frame >= 102) 
	{	
		if (random() < 0.2)
			gunner_sfx_idle ();
		gunner_stand1 ();
		return;
	}
	ai_stand ();
};

void() gunner_walk1 = [ 2, gunner_walk2 ] { ai_walk(4); self.monster_frame = 0;};
void() gunner_walk2 = [ self.frame, gunner_walk2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 24) 
	{
		gunner_walk1 ();
		return;
	}

	ai_walk (4);
};

void() gunner_run1 = [ 2, gunner_run2 ] { ai_run(4); self.monster_frame = 0;};
void() gunner_run2 = [ self.frame, gunner_run2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 24) 
	{
		if (random() < 0.3)
			gunner_sfx_idle ();

		gunner_run1 ();
		return;
	}

    ai_run (4);
};

void() gunner_strafel1 = [ 3, gunner_strafel2 ] 
{ 	ai_face();
	M_walkmove (self.ideal_yaw + 90, 4); self.nextthink = time + 0.04; self.monster_frame = 0;};
void() gunner_strafel2 = [ self.frame, gunner_strafel2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 27) 
	{	
		//self.attack_state = AS_STRAIGHT;
		self.flags &= ~FL_DODGED;
	//	despawn_shield ();
		gunner_run1 ();
		return;
	}
	ai_face();
	M_walkmove (self.ideal_yaw + 90, 4);
   // ai_move(-1);
	
	self.nextthink = time + 0.04;
};

void() gunner_strafer1 = [ 4, gunner_strafer2 ] 
{ 	ai_face();
	M_walkmove (self.ideal_yaw -90, 4); self.nextthink = time + 0.0; self.monster_frame = 0;};
void() gunner_strafer2 = [ self.frame, gunner_strafer2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 23) 
	{	
		//self.attack_state = AS_STRAIGHT;
		self.flags &= ~FL_DODGED;
	//	despawn_shield ();
		gunner_run1 ();
		return;
	}

	//if (self.monster_frame < 33)
	ai_face();
	M_walkmove (self.ideal_yaw - 90, 4);
    ai_move(-1);
	
	self.nextthink = time + 0.04;
};


void() gunner_strafe =
{	
	makevectors(self.angles);
	tracebox (self.origin, self.mins, self.maxs, self.origin + v_right * 120, FALSE, self);
	float right = trace_fraction;

	tracebox (self.origin, self.mins, self.maxs, self.origin + v_right * -120, FALSE, self);
	float left = trace_fraction;

	if (left == 1 && right == 1)
	{
		if (random() <= 0.5)
			gunner_strafel1 ();
		else 
			gunner_strafer1 ();
		return;
	}

	if (left == 1)
		gunner_strafel1 ();
	else if (right == 1)
		gunner_strafer1 ();

	if (left < 1 || right < 1)
	{	
		self.flags &= ~FL_DODGED;
		gunner_run1 ();
		return;
	}
	
	self.nextthink = time;
};

//==============================================================================

static void(entity target, string name) gunner_tag_entity =
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

static void() gunner_tag_think =
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
	
	self.think = gunner_tag_think;
	self.angles = self.owner.angles;
	self.nextthink = time;
}

static void(string stringg, float fr, float end, string name, string tag) gunner_tag = 
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
		gunner_tag_entity(e, name);

	e.netname = tag;
	e.think = gunner_tag_think;
	e.nextthink = time;
}

// nailgun normal also short?
void() gunner_missilea1 = [ 7, gunner_missilea2 ] {
	self.monster_frame = 0;
	gunner_tag ("progs/monsters/gunner/attack_tag.md3", 7, 43, string_null, "tag_muzzle");
	//sound(self, CHAN_RELOAD, "sounds_q4/strogg/gunner/railgun_charge.wav", 1, ATTN_NORM);
	ai_face(); self.nextthink = time + 0.04; };
void() gunner_missilea2 = [ self.frame, gunner_missilea2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	//if (self.monster_frame == 12)
	//	gunner_flash ();

	if (self.monster_frame == 5)
		sound(self, CHAN_RELOAD, "sounds_q4/strogg/gunner/ready_weapon.wav", 1, ATTN_NORM);

	if (self.monster_frame == 11 || self.monster_frame == 14 || self.monster_frame == 17 || self.monster_frame == 20
		|| self.monster_frame == 23 || self.monster_frame == 26 || self.monster_frame == 29)
		gunner_shoot (FALSE);
	
	if (self.monster_frame >= 43) 
	{	
		if (SUB_CheckinRange(90, self, self.enemy))
		{
			self.th_melee ();
			return;
		}
		
		gunner_strafe ();
		return;
	}

	if (self.monster_frame < 11)
		ai_charge(3);

    if (self.monster_frame > 11 && self.monster_frame < 34)
		ai_face();

	if (self.monster_frame > 34 && self.monster_frame < 43)
		ai_move (1);
};

// grenade
void() gunner_missileb1 = [ 8, gunner_missileb2 ] {
	self.monster_frame = 0;
	gunner_tag ("progs/monsters/gunner/grenade_tag.md3", 8, 61, string_null, "tag_muzzle");
//	sound(self, CHAN_RELOAD, "sounds_q4/strogg/gunner/railgun_charge.wav", 1, ATTN_NORM);
	ai_face(); self.nextthink = time + 0.03; };
void() gunner_missileb2 = [ self.frame, gunner_missileb2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.03;

	//if (self.monster_frame == 10 || self.monster_frame == 20 || self.monster_frame == 30)
	//	gunner_flash ();

	if (self.monster_frame == 13)
		sound(self, CHAN_RELOAD, "sounds_q4/strogg/gunner/gren_prepare.wav", 1, ATTN_NORM);

	if (self.monster_frame == 30)
		gunner_flash2();

	if (self.monster_frame == 39)
		gunner_shoot (TRUE);
	
	if (self.monster_frame >= 61) 
	{   
		if (SUB_CheckinRange(90, self, self.enemy))
		{
			self.th_melee ();
			return;
		}

		gunner_strafe ();	
		return;
	}

	if (self.monster_frame < 45)
    	ai_face ();
};

// nailgun strafe
void() gunner_shoot_strafel1 = [ 5, gunner_shoot_strafel2 ] 
{ 	ai_face();
	gunner_tag ("progs/monsters/gunner/side_left_tag.md3", 5, 59, string_null, "tag_muzzle");
    self.nextthink = time + 0.04; self.monster_frame = 0;};
void() gunner_shoot_strafel2 = [ self.frame, gunner_shoot_strafel2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 59) 
	{	
		//self.attack_state = AS_STRAIGHT;
		//self.flags &= ~FL_DODGED;
	//	despawn_shield ();
		gunner_run1 ();
		return;
	}
	
	if (self.monster_frame == 25)
		sound(self, CHAN_RELOAD, "sounds_q4/strogg/gunner/ready_weapon.wav", 1, ATTN_NORM);

    if (self.monster_frame < 10)
	{
        ai_move(2);
        
    }

	if (self.monster_frame == 31 || self.monster_frame == 36 || self.monster_frame == 40)
		gunner_shoot (FALSE);

    if (self.monster_frame < 25)
	{
        ai_face();
        M_walkmove (self.ideal_yaw + 90, 4);
    }

    if (self.monster_frame > 25 && self.monster_frame < 30)
	{
        ai_face();
        M_walkmove (self.ideal_yaw + 90, 1);
    }

    if (self.monster_frame > 30 && self.monster_frame < 48)
	{
        ai_face();
    //    M_walkmove (self.ideal_yaw + 90, 1);
    }

    if (self.monster_frame > 48)
	{	
		if (SUB_CheckinRange(90, self, self.enemy))
		{
			self.th_melee ();
			return;
		}

        ai_face();
        M_walkmove (self.ideal_yaw - 90, 0.5);
    }
	
	self.nextthink = time + 0.04;
};

void() gunner_shoot_strafer1 = [ 6, gunner_shoot_strafer2 ] 
{ 	ai_face();
	gunner_tag ("progs/monsters/gunner/side_right_tag.md3", 6, 55, string_null, "tag_muzzle");
    self.nextthink = time + 0.0; self.monster_frame = 0;};
void() gunner_shoot_strafer2 = [ self.frame, gunner_shoot_strafer2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 55) 
	{	
		//self.attack_state = AS_STRAIGHT;
		//self.flags &= ~FL_DODGED;
	//	despawn_shield ();
		gunner_run1 ();
		return;
	}

	if (self.monster_frame == 17)
		sound(self, CHAN_RELOAD, "sounds_q4/strogg/gunner/ready_weapon.wav", 1, ATTN_NORM);

	if (self.monster_frame == 30 || self.monster_frame == 22 || self.monster_frame == 25)
		gunner_shoot (FALSE);
    
    if (self.monster_frame < 17)
	{
        ai_face();
        M_walkmove (self.ideal_yaw - 90, 4);
        ai_move(-2);
    }

    if (self.monster_frame > 17 && self.monster_frame < 23)
	{
        ai_face();
        M_walkmove (self.ideal_yaw - 90, 1);
    }

    if (self.monster_frame > 24 && self.monster_frame < 30)
	{
        ai_face();
        M_walkmove (self.ideal_yaw + 90, 1);
    }

	if (self.monster_frame > 29 && self.monster_frame < 45)
	{	
		if (SUB_CheckinRange(90, self, self.enemy))
		{
			self.th_melee ();
			return;
		}
        ai_face();
    }

    if (self.monster_frame > 45 && self.monster_frame < 48)
	{
        ai_face();
        M_walkmove (self.ideal_yaw + 90, 0.2);
    }
	
	self.nextthink = time + 0.04;
};

void() gunner_shoot_strafe =
{	
	makevectors(self.angles);
	tracebox (self.origin, self.mins, self.maxs, self.origin + v_right * 120, FALSE, self);
	float right = trace_fraction;

	tracebox (self.origin, self.mins, self.maxs, self.origin + v_right * -120, FALSE, self);
	float left = trace_fraction;

	if (left == 1 && right == 1)
	{
		if (random() <= 0.5)
			gunner_shoot_strafel1 ();
		else 
			gunner_shoot_strafer1 ();
		return;
	}

	if (left == 1)
		gunner_shoot_strafel1 ();
	else if (right == 1)
		gunner_shoot_strafer1 ();

	if (left < 1 || right < 1)
	{	
		if (random() <= 0.6)
	    	gunner_missileb1();
	    else 
	    	gunner_missilea1();
		return;
	}
	
	self.nextthink = time;
};

// short nailgun fire
void() gunner_nail_s1_0 = [ 12, gunner_nail_s2_0 ] {
	ai_face(); self.nextthink = time + 0.04; self.monster_frame = 0; };
void() gunner_nail_s2_0 = [ self.frame, gunner_nail_s2_0 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	
	if (self.monster_frame >= 11) 
	{   
        gunner_nail_s1_1 ();
        self.count = 0;
		return;
	}

	ai_face();
};

void() gunner_nail_s1_1 = [ 13, gunner_nail_s2_1 ] {
	sound(self, CHAN_RELOAD, "sounds_q4/strogg/gunner/ready_weapon.wav", 1, ATTN_NORM);
	gunner_tag ("progs/monsters/gunner/short_nail_tag.md3", 13, 999, string_null, "tag_muzzle");
	ai_face(); self.nextthink = time + 0.04; self.monster_frame = 0; };
void() gunner_nail_s2_1 = [ self.frame, gunner_nail_s2_1 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

    if (self.monster_frame == 1)
    {
        gunner_shoot (FALSE);
	//	gla_fireblaster (24);
        self.count ++;
    }

    if (self.monster_frame >= 3)
        self.monster_frame = 0;

	if (!visible(self.enemy)) 
	{   
        self.count = 0;
		if (random() <= 0.4)
			gunner_strafe ();
		else
			gunner_nail_s1_2 ();

		return;
	}
	
	if (self.count >= 6) 
	{   
		if (SUB_CheckinRange(90, self, self.enemy))
		{
			self.th_melee ();
			return;
		}

		if (random() <= 0.4)
			gunner_strafe ();
		else
			gunner_nail_s1_2 ();
		return;
	}

	ai_face();
};

void() gunner_nail_s1_2 = [ 14, gunner_nail_s2_2 ] {
	ai_face(); self.nextthink = time + 0.04; self.monster_frame = 0; };
void() gunner_nail_s2_2 = [ self.frame, gunner_nail_s2_2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	
	if (self.monster_frame >= 8) 
	{   
		if (SUB_CheckinRange(90, self, self.enemy))
		{
			self.th_melee ();
			return;
		}

        self.count = 0;
		gunner_run1 ();
		return;
	}

	ai_face();
};

// long nailgun fire
void() gunner_nail_l1_0 = [ 9, gunner_nail_l2_0 ] {
	ai_face(); self.nextthink = time + 0.04; self.monster_frame = 0; };
void() gunner_nail_l2_0 = [ self.frame, gunner_nail_l2_0 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	
	if (self.monster_frame >= 12) 
	{   
        gunner_nail_l1_1 ();
        self.count = 0;
		return;
	}

	ai_face();
};

void() gunner_nail_l1_1 = [ 10, gunner_nail_l2_1 ] {
	sound(self, CHAN_RELOAD, "sounds_q4/strogg/gunner/ready_weapon.wav", 1, ATTN_NORM);
	gunner_tag ("progs/monsters/gunner/long_nail_tag.md3", 10, 999, string_null, "tag_muzzle");
	ai_face(); self.nextthink = time + 0.04; self.monster_frame = 0; };
void() gunner_nail_l2_1 = [ self.frame, gunner_nail_l2_1 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

    if (self.monster_frame == 1)
    {
        gunner_shoot (FALSE);
	//	gla_fireblaster (24);
        self.count ++;
    }

    if (self.monster_frame >= 3)
        self.monster_frame = 0;

	if (!visible(self.enemy)) 
	{   
        self.count = 0;
		if (random() <= 0.4)
			gunner_strafe ();
		else
			gunner_nail_s1_2 ();

		return;
	}
	
	if (self.count >= 12) 
	{   
		if (SUB_CheckinRange(90, self, self.enemy))
		{
			self.th_melee ();
			return;
		}

		if (random() <= 0.4)
			gunner_strafe ();
		else
			gunner_nail_s1_2 ();
		return;
	}

	ai_face();
};

void() gunner_nail_l1_2 = [ 11, gunner_nail_l2_2 ] {
	ai_face(); self.nextthink = time + 0.04; self.monster_frame = 0; };
void() gunner_nail_l2_2 = [ self.frame, gunner_nail_l2_2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	
	if (self.monster_frame >= 9) 
	{   
		if (SUB_CheckinRange(90, self, self.enemy))
		{
			self.th_melee ();
			return;
		}

        self.count = 0;
		gunner_run1 ();
		return;
	}

	ai_face();
};

//==============================================================================

void() gunner_meleea1 = [ 16, gunner_meleea2 ] {
	self.monster_frame = 0;
	gunner_tag ("progs/monsters/gunner/backhand_tag.md3", 16, 15, "TE_WHOOSH", "tag_muzzle");
	ai_face(); self.nextthink = time + 0.04;  };
void() gunner_meleea2 = [ self.frame, gunner_meleea2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 9)
		gunner_Melee();

	if (self.monster_frame >= 24) 
	{   
        gunner_strafe ();
		return;
	}

	if (self.monster_frame < 6)
		ai_charge (-2);

	if (self.monster_frame > 6 && self.monster_frame < 16)
		ai_charge (5);

	if (self.monster_frame > 16)
		ai_charge (1);
};

void() gunner_meleeb1 = [ 15, gunner_meleeb2 ] {
	self.monster_frame = 0;
	gunner_tag ("progs/monsters/gunner/punch_tag.md3", 15, 15, "TE_WHOOSH", "tag_muzzle");
	ai_face(); self.nextthink = time + 0.04; };
void() gunner_meleeb2 = [ self.frame, gunner_meleeb2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 9)
		gunner_Melee();

	if (self.monster_frame >= 26)  
	{   
        gunner_strafe();
		return;
	}

	if (self.monster_frame < 10)
		ai_charge (-2);

	if (self.monster_frame > 10 && self.monster_frame < 16)
		ai_charge (5);

	if (self.monster_frame > 16)
		ai_move (3);
};


//==============================================================================

void() gunner_MeleeAttack =
{	
	gunner_sfx_growl ();

	if (random() <= 0.4)
	{	
		float r2 = rint(random() * 3);
		if (r2 == 0)
			r2 = 1;

		if(r2 == 1)
			gunner_nail_l1_0 ();
		else if (r2 == 2)
			gunner_nail_s1_0 ();
		else
			gunner_missilea1 ();
		return;
	}


	if (random() <= 0.5)	
		gunner_meleea1 ();
	else
		gunner_meleeb1 ();
};

void() gunner_MissileAttack =
{   
	gunner_sfx_growl ();

    float r = random();
	float r2 = rint(random() * 3);
	if (r2 == 0)
		r2 = 1;

    if (r >= 0.5)
	{
		if (random() <= 0.5)
	    	gunner_missileb1();
	    else 
	    {
			if(r2 == 1)
				gunner_nail_l1_0 ();
			else if (r2 == 2)
				gunner_nail_s1_0 ();
			else
				gunner_missilea1 ();
		}
	}
    else
        gunner_shoot_strafe ();
};

//==============================================================================

// regular ow
void() gunner_paina1 = [ 17, gunner_paina2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() gunner_paina2 = [ self.frame, gunner_paina2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint("????", "\n");
	if (self.monster_frame >= 11) 
	{
		gunner_run1 ();
		return;
	}
};

void() gunner_painb1 = [ 18, gunner_painb2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() gunner_painb2 = [ self.frame, gunner_painb2 ] 
{   
    //bprint(ftos(self.frame), "\n");
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint(">>>>>>>>>>?????", "\n");
	if (self.monster_frame >= 14) 
	{
		gunner_run1 ();
		return;
	}
};

// concussion
void() gunner_painc1 = [ 19, gunner_painc2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() gunner_painc2 = [ self.frame, gunner_painc2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint("????", "\n");
	if (self.monster_frame >= 14) 
	{   
		gunner_run1 ();
		return;
	}

	if (self.monster_frame < 7)
		ai_move (-3);

	if (self.monster_frame > 11)
		ai_move (1);
};

// knocked
void() gunner_paind1 = [ 20, gunner_paind2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() gunner_paind2 = [ self.frame, gunner_paind2 ] 
{   
	//bprint("knocked", "\n");
    //bprint(ftos(self.frame), "\n");
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint(">>>>>>>>>>?????", "\n");
	if (self.monster_frame >= 37) 
	{   
		gunner_run1 ();
		return;
	}
};

void(entity attacker, float damage, float MOD) gunner_pain =
{
//	if (self.touch == gunner_JumpTouch)
//		return;
//	bprint(ftos(MOD), "\n");
	if (self.flags & FL_DODGED)
	{	
		return;
	}

	if (self.pain_finished > time)
		return;

	self.pain_finished = time + 2;
	gunner_sfx_pain (); // sfx

	if (DMGTYPE_LTNG == MOD)
	{
  	  if (random() <= 0.5)
	        gunner_paina1 ();
 	   else
  	      	gunner_painb1 ();
		
		if (skill < 2)
			self.pain_finished = time + 0.5;
		else
			self.pain_finished = time + 1.5;
		return;
	}

	if (MOD == DMGTYPE_RAIL)
	{   
	//	bprint("knocked", "\n");
        gunner_paind1 ();

		self.pain_finished = time + 2.5;
		return;
	}

	if (random()*200 > damage)
		return; // didn't flinch

	if (damage > 50 || MOD == DMGTYPE_EXP)
	{   
        gunner_painc1 ();
		return;
	}

    if (random() <= 0.5)
        gunner_paina1 ();
    else
        gunner_painb1 ();
};

void() gunner_die =
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

	gunner_sfx_death ();

	local vector tmpangle;
	local float tempskin;
	tmpangle = self.angles;
	tempskin = self.skin;
	

	if (random() <= 0.7)
		self.think = gunner_diea1;
	else
		self.think = gunner_dieb1;

	self.monster_frame = 0;

	self.deadflag = DEAD_DEAD;
	self.solid = SOLID_CORPSE;
//	self.movetype = MOVETYPE_STEP;
	self.nextthink = time + 0.04;

	self.angles = tmpangle;
	//self.skin = tempskin;
};

void() gunner_diea1 = [ 21 , gunner_diea2 ] { self.nextthink = time + 0.04; self.monster_frame = 0;};
void() gunner_diea2 = [ self.frame , gunner_diea2 ] 
{ 	
	//self.frame |= 0x8000;
	self.nextthink = time + 0.04;

	if (self.monster_frame < 8)
		ai_move (-7.5);

	self.monster_frame ++;
	if (self.monster_frame == 30)
	{
		self.maxs_z = 12;
		self.nextthink = -1;
		self.think = gunner_fade1;
		self.nextthink = time + 3.5;
		self.cnt = 1;
		return;
	}
};

void() gunner_dieb1 = [ 22 , gunner_dieb2 ] { self.nextthink = time + 0.04; self.monster_frame = 0;};
void() gunner_dieb2 = [ self.frame , gunner_dieb2 ] 
{ 	
	//self.frame |= 0x8000;
	self.nextthink = time + 0.04;

	self.monster_frame ++;
	if (self.monster_frame == 50)
	{
		self.maxs_z = 12;
		self.nextthink = -1;
		self.think = gunner_fade1;
		self.nextthink = time + 3.5;
	//	self.cnt = 1;
		return;
	}
};


void() gunner_fade1 = [ self.frame, gunner_gib2 ] 
{	
	if (self.cnt == 1)
		self.frame = 0;
	else
		self.frame = 1;
	
	
	setmodel(self, "progs/monsters/gunner/gunner_death.iqm");
	setsize(self, '-16 -16 0', '16 16 12');

	self.skin = 1; 
	self.alpha = 1; 
	self.glowmod = '0.5 0.5 0.5'; 
	self.nextthink = time + 0.02;
};

void() gunner_gib1 = [ self.frame, gunner_gib2 ] 
{MonsterGib (self.health); self.skin = 1; self.alpha = 1; self.nextthink = time + 0.02;};

void() gunner_gib2 = [ self.frame, gunner_gib2 ] 
{ 	
	self.nextthink = time + 0.02;
	self.alpha -= 0.02;
	if (self.alpha <= 0)
	{
		remove(self);
		return;
	}
};

static string gunner_pain_list[6] = 
{
	"sounds_q4/strogg/gunner/pain1.wav",
	"sounds_q4/strogg/gunner/pain2.wav",
	"sounds_q4/strogg/gunner/pain3.wav",
	"sounds_q4/strogg/gunner/pain4.wav",
	"sounds_q4/strogg/gunner/pain5.wav",
	"sounds_q4/strogg/gunner/pain6.wav",
};	

static void() gunner_sfx_pain =
{
	local float r = rint(random() * 5);	

	sound(self, CHAN_VOICE, gunner_pain_list[r], 1, ATTN_NORM);
};

static string gunner_growl_list[5] = 
{
	"sounds_q4/strogg/gunner/growl1.wav",
	"sounds_q4/strogg/gunner/growl2.wav",
	"sounds_q4/strogg/gunner/growl3.wav",
	"sounds_q4/strogg/gunner/growl4.wav",
	"sounds_q4/strogg/gunner/growl5.wav",
};	

static void() gunner_sfx_growl =
{
	local float r = rint(random() * 4);	

	sound(self, CHAN_VOICE, gunner_growl_list[r], 1, ATTN_NORM);
};

static string gunner_death_list[5] = 
{
	"sounds_q4/strogg/gunner/die1.wav",
	"sounds_q4/strogg/gunner/die2.wav",
	"sounds_q4/strogg/gunner/die3.wav",
	"sounds_q4/strogg/gunner/die4.wav",
	"sounds_q4/strogg/gunner/die5.wav",
};	

static void() gunner_sfx_death =
{
	local float r = rint(random() * 4);	

	sound(self, CHAN_VOICE, gunner_death_list[r], 1, ATTN_NORM);
};

static string gunner_breath_list[4] = 
{
	"sounds_q4/strogg/gunner/breath01.wav",
	"sounds_q4/strogg/gunner/breath02.wav",
	"sounds_q4/strogg/gunner/breath03.wav",
	"sounds_q4/strogg/gunner/breath04.wav",
};	

static void() gunner_sfx_idle =
{
	local float r = rint(random() * 3);	

	sound(self, CHAN_VOICE, gunner_breath_list[r], 1, ATTN_IDLE);
};

static string gunner_sight_list[14] = 
{
	"sounds_q4/strogg/gunner/sight1.wav",
	"sounds_q4/strogg/gunner/sight2.wav",
	"sounds_q4/strogg/gunner/sight3.wav",
	"sounds_q4/strogg/gunner/sight4.wav",
	"sounds_q4/strogg/gunner/sight5.wav",
	"sounds_q4/strogg/gunner/sight6.wav",
	"sounds_q4/strogg/gunner/sight7.wav",
	"sounds_q4/strogg/gunner/sight8.wav",
	"sounds_q4/strogg/gunner/sight9.wav",
	"sounds_q4/strogg/gunner/sight10.wav",
	"sounds_q4/strogg/gunner/sight11.wav",
	"sounds_q4/strogg/gunner/sight12.wav",
	"sounds_q4/strogg/gunner/sight13.wav",
	"sounds_q4/strogg/gunner/sight14.wav",
};	

static void() gunner_sfx_sight =
{   
	local float r = rint(random() * 13);	

	sound(self, CHAN_VOICE, gunner_sight_list[r], 1, ATTN_NORM);
};

/*QUAKED monster_demon (1 0 0) (-32 -32 -24) (32 32 64) Ambush

*/
void() monster_gunner_cache =
{
	precache_model("progs/monsters/gunner/gunner.md5.info");
	precache_model("progs/monsters/gunner/gunner_death.iqm");

	precache_model("progs/monsters/gunner/grenade_tag.md3");
	precache_model("progs/monsters/gunner/attack_tag.md3");
	precache_model("progs/monsters/gunner/long_nail_tag.md3");
	precache_model("progs/monsters/gunner/short_nail_tag.md3");
	precache_model("progs/monsters/gunner/side_left_tag.md3");
	precache_model("progs/monsters/gunner/side_right_tag.md3");

	precache_model("progs/monsters/gunner/punch_tag.md3");
	precache_model("progs/monsters/gunner/backhand_tag.md3");

	float i;

	for (i = 0; i < 14; i++)
	{
		precache_sound(gunner_sight_list[i]);
	}

	for (i = 0; i < 5; i++)
	{
		precache_sound(gunner_death_list[i]);
		precache_sound(gunner_growl_list[i]);
	}

	for (i = 0; i < 4; i++)
	{
		precache_sound(gunner_breath_list[i]);
	}

	for (i = 0; i < 6; i++)
	{
		precache_sound(gunner_pain_list[i]);
	}

	precache_sound("sounds_q4/strogg/gunner/ready_weapon.wav");
	precache_sound("sounds_q4/strogg/gunner/gren_prepare.wav");
	precache_sound("sounds_q4/strogg/gunner/m_gun1.wav");
	precache_sound("sounds_q4/strogg/gunner/m_gun2.wav");
	precache_sound("sounds_q4/strogg/gunner/m_gun3.wav");
	precache_sound("sounds_q4/strogg/gunner/grenadelaunch.wav");
//	spawn_demon ();
};

void() monster_gunner =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	monster_gunner_cache ();	
	spawn_gunner ();
};

void() spawn_gunner =
{
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel(self, "progs/monsters/gunner/gunner.md5.info");
	self.classname = "monster_gunner";
	setsize(self, '-16 -16 0', '16 16 64');
	self.health = 360;
	self.max_health = 360;
	self.mass = 300;
	self.scale = 0.85;

	self.th_stand = gunner_stand1;
	self.th_walk = gunner_walk1;
	self.th_run = gunner_run1;
	self.th_die = gunner_die;
	self.th_melee = gunner_MeleeAttack; // one of two attacks
	self.th_missile = gunner_MissileAttack; // jump attack
	self.th_pain = gunner_pain;
	//self.th_checkatck = GladCheckAttack;
	self.th_spawn = spawn_gunner;
	self.th_dodge = gunner_strafe;
	self.th_sight = gunner_sfx_sight;
	//setcustomskin (self, "progs/monsters/gunner/gladiator.skin")
	self.deathtype = "was fractured by a Gunner";
	self.count = 0;
	self.pissed = 0;
//	self.emiteffectnum = particleeffectnum("_gunner_dress");

	walkmonster_start();
};


/*
==============================================================================

DEMON

==============================================================================
*/



void(float bool) gunner_shoot = 
{   
	vector dir = normalize(self.enemy.origin - self.pos2 + self.enemy.view_ofs);

	gunner_flash ();

	vector f, r, u;
	if (bool == FALSE)
	{	
		float rand = rint(random()*2);

		if (rand == 2)
			sound(self, CHAN_WEAPON, "sounds_q4/strogg/gunner/m_gun1.wav", 1, ATTN_NORM);
		else if (rand == 1)
			sound(self, CHAN_WEAPON, "sounds_q4/strogg/gunner/m_gun2.wav", 1, ATTN_NORM);
		else
			sound(self, CHAN_WEAPON, "sounds_q4/strogg/gunner/m_gun3.wav", 1, ATTN_NORM);
		
		AngleVectors(self.angles, f, r, u);
		Strogg_nail (self.pos2, dir + r * crandom() * 0.04 + u * crandom() * 0.02, 4, 20, 600);
		return;
	}


	AngleVectors(self.angles, f, r, u);
//	vector org = self.pos2;
	dir = normalize(self.enemy.origin - self.pos2 + self.enemy.view_ofs + self.enemy.velocity * 0.2);
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

	dir = f + r *-0.1;
	dir = dir + pitch * u;
//PGM	

	float ldmg = 60 + (random() + random() + random())*12;
	if (M_CalculatePitchToFire (self.enemy.origin, self.pos2, dir, 700, 2.5, 0, 0))
		monster_FireGravityBall (self.pos2, dir, ldmg, 2.5, (crandom() * 10), crandom() * 10, 700);
	else
		monster_FireGravityBall (self.pos2, dir, ldmg, 2.5, (crandom() * 10), 200 + (crandom() * 10), 700);
	
	sound(self, CHAN_WEAPON, "sounds_q4/strogg/gunner/grenadelaunch.wav", 1, ATTN_NORM);
//	launch_rocket (self.pos2, dir, speed, 30, 80, "EF_REVTRAIL");
};

void() gunner_Melee =
{
	float ldmg;

	ai_face();

	ldmg = 20 + random()*15;

	vector	aim;

	aim = setvector (100, 0, 0);
	if (fire_hit(aim, rint(ldmg), 25))
	{	
		meat_hit (); 
	}
	else
	{
	
		meat_miss (); 
	//	self.pissed += 0.3;
	}
};

void() gunner_flash = 
{   
   
    vector org;

    org = self.pos2;

    pointparticles (particleeffectnum("TE_MUZZLEFLASH2"), org, '0 0 0');
	pointparticles (particleeffectnum("EF_MUZZLEFLASH2"), org, '0 0 0');
};

void() gunner_flash2 = 
{   
   
    vector org;

    org = self.pos2;

    pointparticles (particleeffectnum("TE_BOLT_IMPACT_RED"), org, '0 0 0', 4);
//	pointparticles (particleeffectnum("EF_MUZZLEFLASH2"), org, '0 0 0');
};


//===========================================================================
