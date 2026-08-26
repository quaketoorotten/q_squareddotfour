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

void() gladiator_stand1 = [ 1, gladiator_stand2 ] { ai_stand(); self.monster_frame = 0;};
void() gladiator_stand2 = [ self.frame, gladiator_stand2 ] 
{ 	
	self.monster_frame ++;
	if (self.monster_frame >= 96) 
	{	
		if (random() < 0.2)
			gladiator_sfx_idle ();
		gladiator_stand1 ();
		return;
	}
	ai_stand ();
};

void() gladiator_walk1 = [ 4, gladiator_walk2 ] { ai_walk(0); self.monster_frame = 0;};
void() gladiator_walk2 = [ self.frame, gladiator_walk2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 22) 
	{
		gladiator_walk1 ();
		return;
	}

    if (self.monster_frame == 11 || self.monster_frame == 1)
    	ai_walk (1.5);

    else if (self.monster_frame == 22 || self.monster_frame == 10)
        ai_walk(0);
    
    else
        ai_walk (3);
};

void() gladiator_run1 = [ 4, gladiator_run2 ] { ai_run(0); self.monster_frame = 0;};
void() gladiator_run2 = [ self.frame, gladiator_run2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 33) 
	{
		if (random() < 0.3)
			gladiator_sfx_idle ();

		gladiator_run1 ();
		return;
	}

    if (self.monster_frame == 11 || self.monster_frame == 1)
    	ai_run (1.5);

    else if (self.monster_frame == 22 || self.monster_frame == 10)
        ai_run(0);
    
    else
        ai_run (3);
};

void() gladiator_strafel1 = [ 24, gladiator_strafel2 ] 
{ 	if (self.flags & FL_DODGED)
		ai_face ();
	M_walkmove (self.ideal_yaw + 90, 0); self.nextthink = time + 0.04; self.monster_frame = 0;};
void() gladiator_strafel2 = [ self.frame, gladiator_strafel2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 32) 
	{	
		//self.attack_state = AS_STRAIGHT;
		self.flags &= ~FL_DODGED;
	//	despawn_shield ();
		gladiator_shield2_1 ();
		return;
	}

	if (self.flags & FL_DODGED)
		ai_face ();
	M_walkmove (self.ideal_yaw + 90, 3);
	
	self.nextthink = time + 0.04;
};

void() gladiator_strafer1 = [ 25, gladiator_strafer2 ] 
{ if (self.flags & FL_DODGED)
		ai_face ();
	M_walkmove (self.ideal_yaw -90, 0); self.nextthink = time + 0.04; self.monster_frame = 0;};
void() gladiator_strafer2 = [ self.frame, gladiator_strafer2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 32) 
	{	
		//self.attack_state = AS_STRAIGHT;
		self.flags &= ~FL_DODGED;
	//	despawn_shield ();
		gladiator_shield2_1 ();
		return;
	}

	//if (self.monster_frame < 33)
	if (self.flags & FL_DODGED)
		ai_face ();
	M_walkmove (self.ideal_yaw - 90, 3);
	
	self.nextthink = time + 0.04;
};

// shield up
void() gladiator_shield1_0 = [ 18, gladiator_shield2_0 ] {
spawn_shield();	ai_face(); self.nextthink = time + 0.04; self.monster_frame = 0; };
void() gladiator_shield2_0 = [ self.frame, gladiator_shield2_0 ] 
{   
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	
	if (self.monster_frame >= 9) 
	{   
     //  spawn_shield();
        gladiator_dodge ();
		return;
	}

	ai_face();
};

// shield hold
void() gladiator_shield1_1 = [ 19, gladiator_shield2_1 ] {
	ai_face(); self.nextthink = time + 0.04; self.monster_frame = 0; };
void() gladiator_shield2_1 = [ self.frame, gladiator_shield2_1 ] 
{   
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	
	if (self.monster_frame >= 40) 
	{   
       // spawn_shield();
        gladiator_shield1_2 ();
		return;
	}

	ai_face();
};

// shield down
void() gladiator_shield1_2 = [ 20, gladiator_shield2_2 ] {
	ai_face(); self.nextthink = time + 0.04; self.monster_frame = 0; };
void() gladiator_shield2_2 = [ self.frame, gladiator_shield2_2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	
	if (self.monster_frame >= 10) 
	{   
		self.flags &= ~FL_DODGED;
        despawn_shield();
        gladiator_run1();
		return;
	}

	ai_face();
};

void() gladiator_dodge =
{	
	makevectors(self.angles);
	tracebox (self.origin, self.mins, self.maxs, self.origin + v_right * 312, FALSE, self);
	float right = trace_fraction;

	tracebox (self.origin, self.mins, self.maxs, self.origin + v_right * -312, FALSE, self);
	float left = trace_fraction;

	if (left == 1 && right == 1)
	{
		if (random() <= 0.5)
			gladiator_strafel1 ();
		else 
			gladiator_strafer1 ();
		return;
	}

	if (left == 1)
		gladiator_strafel1 ();
	else if (right == 1)
		gladiator_strafer1 ();

	if (left < 1 || right < 1)
	{	
		if (self.flags & FL_DODGED)
			gladiator_shield1_1 (); // stand still
		else
			gladiator_run1 ();
		return;
	}
	
	self.nextthink = time;
};

void() gladiator_block =
{	
//	bprint("??", "\n");
	if (random() <= 0.3 && skill > 1)
	{	
		if (self.shield == world) // no shield
			gladiator_missiled1_00 ();
		else
			gladiator_missiled1_0 ();

		return;
	}
		
	else
		gladiator_shield1_0 ();
};

//======================================================================

void() shield_follow =
{
    self.think = shield_follow;
    self.nextthink = time;

    vector f, r, u;
    AngleVectors(self.owner.angles, f, r, u);

	//self.shield.solid = SOLID_NOT;
    self.shield.origin = self.owner.origin + u * 32 + f * 32 + r * 6;
	setorigin(self.shield, self.shield.origin);
	self.shield.hitcontentsmaski = CONTENTBIT_CORPSE;
	//self.shield.solid = SOLID_BBOX;
   // self.shield.angles = self.owner.angles;

    self.origin = self.owner.origin;
    self.angles = self.owner.angles;
    self.frame = self.owner.frame;
};

void() spawn_shield = 
{	
    local entity sd ;
    sd = spawn();
    sd.origin = self.origin;
    setmodel(sd, "progs/monsters/gladiator/gla_shield_mesh.md5.info");
    setsize(sd, VEC_ORIGIN, VEC_ORIGIN);
    sd.think = shield_follow;
    sd.nextthink = time;
    sd.owner = self;
    sd.scale = self.scale;
    sd.frame = self.frame;
    self.shield = sd;
	sd.classname = "shield";

    spawn_shield_bbox(sd);
//	bprint("shieled", "\n");
	sound(self, CHAN_RELOAD, "sounds_q4/strogg/gladiator/shield_up.wav", 1, ATTN_NORM);
};

void(entity attacker, float dmg, float MOD) bbox_pain =
{	
    self.health = 999999;

	if (self.pain_finished > time)
		return;

	sound(self, CHAN_RELOAD, "sounds_q4/strogg/gladiator/shield_hit.wav", 1, ATTN_NORM);
	self.pain_finished = time + 1;
};

void(entity own) spawn_shield_bbox =
{
    local entity it;
    it = spawn();
    it.owner = own.owner;
    own.shield = it; // shield with a shield?
    setorigin(it, it.owner.origin);
  //  setmodel (it, "progs/soldier.mdl");
    setsize(it, '-26 -26 -32', '26 26 64');
  	it.classname = "shield_bbox";
    
    it.solid = SOLID_BSP;
    it.takedamage = DAMAGE_YES;
//	it.hitcontentsmaski = CONTENTBIT_CORPSE;
	it.touch = SHIELD_DAMAGE;
	it.th_pain = bbox_pain;
	it.health = 999999;

    it.movetype = MOVETYPE_FLY;
};

void() SHIELD_DAMAGE = 
{	
	if (other == self.owner)
		return;

	if (!other.takedamage)
		return;

	self.owner.think = self.owner.th_melee;
	self.owner.nextthink = time;
}

void() despawn_shield = 
{   
	if (!self.shield)
		return;
	
	sound(self, CHAN_RELOAD, "sounds_q4/strogg/gladiator/shield_down.wav", 1, ATTN_NORM);

    entity oself = self;
    self = self.shield;

    remove(self.shield);

    self = oself;
    remove(self.shield);
	self.shield = world;
};

//==============================================================================

static void(entity target, string name) glad_tag_entity =
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

static void() glad_tag_think =
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
	}
		
	else
		self.owner.pos2 = taginf;

	self.think = glad_tag_think;
	self.angles = self.owner.angles;
	self.nextthink = time;
}

static void(string stringg, float fr, float end, string name, string tag) glad_tag = 
{
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
		glad_tag_entity(e, name);

	e.netname = tag;
	e.think = glad_tag_think;
	e.nextthink = time;
}

// railgun shoot light
void() gladiator_missilea1 = [ 6, gladiator_missilea2 ] {
	self.monster_frame = 0;
	glad_tag ("progs/monsters/gladiator/railgun2_tag.md3", 6, 40, string_null, "tag_muzzle");
	sound(self, CHAN_RELOAD, "sounds_q4/strogg/gladiator/railgun_charge.wav", 1, ATTN_NORM);
	ai_face(); self.nextthink = time + 0.04; };
void() gladiator_missilea2 = [ self.frame, gladiator_missilea2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

    if (self.monster_frame < 37)
	{
		self.pos1 = self.enemy.origin + '0 0 22';
	//	gla_flash2 ();
	}

	if (self.monster_frame == 30)
		gla_flash ();

	if (self.monster_frame == 38)
		gla_shoot (36 + random()*12);
	
	if (self.monster_frame >= 59) 
	{	
		gladiator_dodge ();
		return;
	}

	if (self.monster_frame < 20)
		ai_charge (2);

    if (self.monster_frame >= 20 && self.monster_frame <= 37)
        ai_face ();

    if (self.monster_frame > 37 && self.monster_frame < 44)
	{
        ai_move (-3);
    }	

     if (self.monster_frame > 44 && self.monster_frame < 57)
    {   
        ai_move (0.5);
        
    }
		
};

// railgun shoot heavy
void() gladiator_missileb1 = [ 5, gladiator_missileb2 ] {
	self.monster_frame = 0;
	glad_tag ("progs/monsters/gladiator/railgun1_tag.md3", 5, 27, string_null, "tag_muzzle");
	sound(self, CHAN_RELOAD, "sounds_q4/strogg/gladiator/railgun_charge.wav", 1, ATTN_NORM);
	ai_face(); self.nextthink = time + 0.04;  };
void() gladiator_missileb2 = [ self.frame, gladiator_missileb2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

    if (self.monster_frame < 24)
	{
		self.pos1 = self.enemy.origin + '0 0 22';
		//gla_flash2 ();
	}
	
	if (self.monster_frame == 20)
		gla_flash ();

	if (self.monster_frame == 25)
		gla_shoot (50 + random()*12);
	
	if (self.monster_frame >= 59) 
	{   
		if (random() <= 0.5)
		{
			self.flags |= FL_DODGED;
			self.th_dodge ();

			return;
		}
		else
			gladiator_dodge ();
				
		return;
	}

	if (self.monster_frame < 20)
    {   
        ai_charge (3);
        M_walkmove (self.ideal_yaw - 90, 1);
    }

    if (self.monster_frame >= 20 && self.monster_frame <= 25)
        ai_face ();

    if (self.monster_frame > 25 && self.monster_frame < 41)
	{
        ai_move (-2);
        M_walkmove (self.ideal_yaw + 90, 0.6);
    }	

     if (self.monster_frame > 41 && self.monster_frame < 53)
    {   
        ai_move (0.5);
        
    }
};

// blaster
void() gladiator_missilec1_0 = [ 8, gladiator_missilec2_0 ] {
	ai_face(); self.nextthink = time + 0.04; self.monster_frame = 0; };
void() gladiator_missilec2_0 = [ self.frame, gladiator_missilec2_0 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	
	if (self.monster_frame >= 8) 
	{   
        if (!visible(self.enemy))
		    gladiator_missilec1_2 ();
        else
            gladiator_missilec1_1 ();
        self.count = 0;
		return;
	}

	ai_face();
};

void() gladiator_missilec1_1 = [ 9, gladiator_missilec2_1 ] {
	ai_face(); self.nextthink = time + 0.02; self.monster_frame = 0; };
void() gladiator_missilec2_1 = [ self.frame, gladiator_missilec2_1 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.02;

    if (self.monster_frame == 2)
    {
        gla_fireblaster ();
	//	gla_fireblaster (24);
        self.count ++;
    }
        
    if (self.monster_frame >= 9)
        self.monster_frame = 0;
	
	if (self.count >= 8) 
	{   
		gladiator_missilec1_2 ();
		return;
	}

	ai_face();
};

void() gladiator_missilec1_2 = [ 10, gladiator_missilec2_2 ] {
	ai_face(); self.nextthink = time + 0.04; self.monster_frame = 0; };
void() gladiator_missilec2_2 = [ self.frame, gladiator_missilec2_2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	
	if (self.monster_frame >= 10) 
	{   
        self.count = 0;
        gladiator_dodge ();
		return;
	}

	ai_face();
};

//s hield fire
void() gladiator_missiled1_0 = [ 21, gladiator_missiled2_0 ] {
	ai_face(); self.nextthink = time + 0.04; self.monster_frame = 0; };
void() gladiator_missiled2_0 = [ self.frame, gladiator_missiled2_0 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	
	if (self.monster_frame >= 8) 
	{   
        if (!visible(self.enemy))
		    gladiator_missiled1_2 ();
        else
            gladiator_missiled1_1 ();
        self.count = 0;
		return;
	}

	ai_face();
};

void() gladiator_missiled1_1 = [ 22, gladiator_missiled2_1 ] {
	ai_face(); self.nextthink = time + 0.02; self.monster_frame = 0; };
void() gladiator_missiled2_1 = [ self.frame, gladiator_missiled2_1 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.02;

    if (self.monster_frame == 2)
    {
        gla_fireblaster ();
	//	gla_fireblaster (24);
        self.count ++;
    }
        
    if (self.monster_frame >= 9)
        self.monster_frame = 0;
	
	if (self.count >= 8) 
	{   
		if (random() <= 0.4)
			gladiator_dodge ();
		else
			gladiator_missiled1_2 ();
		return;
	}

	ai_face();
};

void() gladiator_missiled1_2 = [ 23, gladiator_missiled2_2 ] {

	ai_face(); self.nextthink = time + 0.04; self.monster_frame = 0; };
void() gladiator_missiled2_2 = [ self.frame, gladiator_missiled2_2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	
	if (self.monster_frame >= 10) 
	{   
        self.count = 0;
        gladiator_missiled1_01 ();
		return;
	}

	ai_face();
};

void() gladiator_missiled1_00 = [ 18, gladiator_missiled2_00 ] {
spawn_shield();	ai_face(); self.nextthink = time + 0.04; self.monster_frame = 0; };
void() gladiator_missiled2_00 = [ self.frame, gladiator_missiled2_00 ] 
{   
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	
	if (self.monster_frame >= 9) 
	{   
        
        gladiator_missiled1_0 ();
        self.count = 0;
		return;
	}

	ai_face();
};

void() gladiator_missiled1_01 = [ 20, gladiator_missiled2_01 ] {
	ai_face(); self.nextthink = time + 0.04; self.monster_frame = 0; };
void() gladiator_missiled2_01 = [ self.frame, gladiator_missiled2_01 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	
	if (self.monster_frame >= 10) 
	{   
        despawn_shield();
		self.flags &= ~FL_DODGED;
        gladiator_dodge();
		
		return;
	}

	ai_face();
};


//==============================================================================

void() gladiator_meleea1 = [ 26, gladiator_meleea2 ] {
	self.monster_frame = 0;
	glad_tag ("progs/monsters/gladiator/melee1_tag.md3", 26, 20, "TE_WHOOSH", "tag_point1");
	ai_face(); self.nextthink = time + 0.04; };
void() gladiator_meleea2 = [ self.frame, gladiator_meleea2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	
	if (self.monster_frame == 14)
		glad_tag ("progs/monsters/gladiator/melee1_tag.md3", 26, 26, "TE_WHOOSH", "tag_point2");

	if (self.monster_frame == 20 || self.monster_frame == 15)
		gla_Melee();

	if (self.monster_frame >= 40) 
	{   
        gladiator_run1();
		return;
	}

	if (self.monster_frame < 4)
		ai_charge (-2);

	if (self.monster_frame > 4 && self.monster_frame < 36)
		ai_charge (3);
};

void() gladiator_meleeb1 = [ 27, gladiator_meleeb2 ] {
	self.monster_frame = 0;
	glad_tag ("progs/monsters/gladiator/melee2_tag.md3", 27, 20, "TE_WHOOSH", "tag_point1");
	ai_face(); self.nextthink = time + 0.04; };
void() gladiator_meleeb2 = [ self.frame, gladiator_meleeb2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 14)
		gla_Melee();

	if (self.monster_frame >= 30) 
	{   
        gladiator_run1();
		return;
	}

	if (self.monster_frame > 3 && self.monster_frame < 22)
		ai_charge (3);

	if (self.monster_frame > 22)
		ai_move (-1);
};


//==============================================================================

void() gladiator_MeleeAttack =
{	
	if (self.shield)
		despawn_shield ();
	
	self.flags &= ~FL_DODGED;

	if (self.pissed > 0.3)
	{
		gladiator_missilec1_0();
		self.pissed = 0;
		return;
	}

	if(random() <= 0.5)
		gladiator_meleea1 ();
	else
		gladiator_meleeb1 ();
};

void() gladiator_MissileAttack =
{   
    float r = rint (random() * 3);
	
	gladiator_sfx_idle ();

	if (r == 1)
		gladiator_missilec1_0();
	else if (r == 2)
		gladiator_missileb1();
	else 
		gladiator_missilea1();

};

//==============================================================================

// regular ow
void() gladiator_paina1 = [ 16, gladiator_paina2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() gladiator_paina2 = [ self.frame, gladiator_paina2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint("????", "\n");
	if (self.monster_frame >= 12) 
	{
		gladiator_run1 ();
		return;
	}
};

void() gladiator_painb1 = [ 17, gladiator_painb2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() gladiator_painb2 = [ self.frame, gladiator_painb2 ] 
{   
    //bprint(ftos(self.frame), "\n");
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint(">>>>>>>>>>?????", "\n");
	if (self.monster_frame >= 30) 
	{
		gladiator_run1 ();
		return;
	}
};

// shieled ow
void() gladiator_painc1 = [ 13, gladiator_painc2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() gladiator_painc2 = [ self.frame, gladiator_painc2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint("????", "\n");
	if (self.monster_frame >= 27) 
	{   
		gladiator_run1 ();
		return;
	}
};

void() gladiator_paind1 = [ 14, gladiator_paind2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() gladiator_paind2 = [ self.frame, gladiator_paind2 ] 
{   
    //bprint(ftos(self.frame), "\n");
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint(">>>>>>>>>>?????", "\n");
	if (self.monster_frame >= 27) 
	{   
		gladiator_run1 ();
		return;
	}
};

void(entity attacker, float damage, float MOD) gladiator_pain =
{
//	if (self.touch == gladiator_JumpTouch)
//		return;
//	bprint(ftos(MOD), "\n");
	if (self.flags & FL_DODGED)
	{	
		if (MOD != DMGTYPE_LTNG)
			return;
		
		if (random()*20 > damage)
			return; // didn't flinch

		if (self.shield)
	    {	
			gladiator_sfx_pain (); // sfx
			
    	    if (random() <= 0.5)
        	    gladiator_painc1 ();
        	else
            	gladiator_paind1 ();
			
			despawn_shield();
			self.pain_finished = time + 6;
			self.flags &= ~FL_DODGED;
        	return;
    	}
	}

	if (self.pain_finished > time)
		return;

	self.pain_finished = time + 3;
	gladiator_sfx_pain (); // sfx

	if (MOD == DMGTYPE_RAIL && random() >= 0.8)
	{   
        if (self.shield)
        {
            if (random() <= 0.5)
                gladiator_painc1 ();
            else
                gladiator_paind1 ();
            return;
        }

		gladiator_painb1();
		self.pain_finished = time + 3;
		return;
	}

	if (random()*600 > damage)
		return; // didn't flinch

	if (damage > 100 || MOD == DMGTYPE_EXP)
	{   
        if (self.shield)
        {
            if (random() <= 0.5)
                gladiator_painc1 ();
            else
                gladiator_paind1 ();
            return;
        }
            
        else
		    gladiator_painb1 ();
		return;
	}
	
    if (self.shield)
    {
        if (random() <= 0.5)
            gladiator_painc1 ();
        else
            gladiator_paind1 ();
        return;
    }


    gladiator_paina1 ();
};

void() gladiator_die =
{	
    if (self.shield)
        despawn_shield ();

	if (self.health < -300)
	{	
		self.deadflag = DEAD_DEAD;
		self.solid = SOLID_NOT;
		MonsterGib (self.health); 
		remove(self);
		return;
	}
	
	if((self.deadflag & DEAD_DEAD))
		return;

	gladiator_sfx_death ();

	local vector tmpangle;
	local float tempskin;
	tmpangle = self.angles;
	tempskin = self.skin;
	

	self.think = gladiator_die1;


	self.deadflag = DEAD_DEAD;
	self.solid = SOLID_CORPSE;
//	self.movetype = MOVETYPE_STEP;
	self.nextthink = time + 0.04;

	self.angles = tmpangle;
	//self.skin = tempskin;
};

void() gladiator_die1 = [ 28 , gladiator_die2 ] { self.nextthink = time + 0.04; self.monster_frame = 0;};
void() gladiator_die2 = [ self.frame , gladiator_die2 ] 
{ 	
	//self.frame |= 0x8000;
	self.nextthink = time + 0.04;

	if (self.monster_frame < 5)
		ai_move (-6.5);
	self.monster_frame ++;
	if (self.monster_frame == 40)
	{
		self.maxs_z = 12;
		self.nextthink = -1;
		self.think = gladiator_fade1;
		self.nextthink = time + 3.5;
		return;
	}
};

void() gladiator_fade1 = [ 0, gladiator_gib2 ] 
{	
	setmodel(self, "progs/monsters/gladiator/gla_mesh_death.iqm");
	setsize(self, '-32 -32 0', '32 32 12');

	self.skin = 1; 
	self.alpha = 1; 
	self.glowmod = '0.5 0.5 0.5'; 
	self.nextthink = time + 0.02;

};

void() gladiator_gib1 = [ self.frame, gladiator_gib2 ] 
{MonsterGib (self.health); self.skin = 1; self.alpha = 1; self.nextthink = time + 0.02;};

void() gladiator_gib2 = [ self.frame, gladiator_gib2 ] 
{ 	
	self.nextthink = time + 0.02;
	self.alpha -= 0.02;
	if (self.alpha <= 0)
	{
		remove(self);
		return;
	}
};

static void() gladiator_sfx_pain =
{
	sound(self, CHAN_VOICE, "sounds_q4/strogg/gladiator/pain.wav", 1, ATTN_NORM);
};

static void() gladiator_sfx_death =
{
	sound(self, CHAN_VOICE, "sounds_q4/strogg/gladiator/death.wav", 1, ATTN_NORM);
};

static void() gladiator_sfx_idle =
{
	local float r = rint(random() * 3);	

	if (r == 3)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/gladiator/breath01.wav", 1, ATTN_IDLE);
	else if (r == 2)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/gladiator/breath02.wav", 1, ATTN_IDLE);
	else if (r == 1)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/gladiator/breath03.wav", 1, ATTN_IDLE);
	else
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/gladiator/breath04.wav", 1, ATTN_IDLE);
};

static void() gladiator_sfx_sight =
{
	sound(self, CHAN_VOICE, "sounds_q4/strogg/gladiator/alert.wav", 1, 0.7);
};

/*QUAKED monster_demon (1 0 0) (-32 -32 -24) (32 32 64) Ambush

*/
void() monster_gladiator_cache =
{
	precache_model("progs/monsters/gladiator/gla_mesh.md5.info");
    precache_model("progs/monsters/gladiator/gla_shield_mesh.md5.info");

	precache_model("progs/monsters/gladiator/railgun1_tag.md3");
	precache_model("progs/monsters/gladiator/railgun2_tag.md3");
	precache_model("progs/monsters/gladiator/melee1_tag.md3");
	precache_model("progs/monsters/gladiator/melee2_tag.md3");
	precache_model("progs/monsters/gladiator/gla_mesh_death.iqm");
	

	precache_sound("sounds_q4/strogg/gladiator/alert.wav");
	precache_sound("sounds_q4/strogg/gladiator/breath04.wav");
	precache_sound("sounds_q4/strogg/gladiator/breath03.wav");
	precache_sound("sounds_q4/strogg/gladiator/breath02.wav");
	
	precache_sound("sounds_q4/strogg/gladiator/breath01.wav");
	precache_sound("sounds_q4/strogg/gladiator/death.wav");
	precache_sound("sounds_q4/strogg/gladiator/pain.wav");
	precache_sound("sounds_q4/strogg/gladiator/shield_hit.wav");	

	precache_sound("sounds_q4/strogg/gladiator/shield_up.wav");
	precache_sound("sounds_q4/strogg/gladiator/shield_down.wav");
	precache_sound("sounds_q4/strogg/gladiator/railgun_blast.wav");

	precache_sound("sounds_q4/strogg/gladiator/railgun_charge.wav");
	precache_sound("sounds_q4/strogg/gladiator/rapidfire_01.wav");
	precache_sound("sounds_q4/strogg/gladiator/rapidfire_02.wav");

//	spawn_demon ();
};

void() monster_gladiator =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	monster_gladiator_cache ();	
	spawn_gladiator ();
};

.entity shield;
void() spawn_gladiator =
{
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	self.classname = "monster_gladiator";
	setmodel(self, "progs/monsters/gladiator/gla_mesh.md5.info");

	setsize(self, '-32 -32 0', '32 32 88');
	self.health = 990;
	self.max_health = 990;
	self.mass = 2000;
	self.scale = 0.9;

	self.th_stand = gladiator_stand1;
	self.th_walk = gladiator_walk1;
	self.th_run = gladiator_run1;
	self.th_die = gladiator_die;
	self.th_melee = gladiator_MeleeAttack; // one of two attacks
	self.th_missile = gladiator_MissileAttack; // jump attack
	self.th_pain = gladiator_pain;
	self.th_checkatck = GladCheckAttack;
	self.th_spawn = spawn_gladiator;
	self.th_dodge = gladiator_block;
	self.th_sight = gladiator_sfx_sight;
	//setcustomskin (self, "progs/monsters/gladiator/gladiator.skin")
	self.deathtype = "was railed by a Gladiator";
	self.count = 0;
	self.pissed = 0;

	walkmonster_start();
};


/*
==============================================================================

DEMON

==============================================================================
*/

void(float dmg = 40) gla_shoot = 
{   
   
    vector org;

    org = self.pos2;

	self.pos1 = self.pos1 - self.enemy.velocity*0.1;
    vector dir = normalize(self.pos1 - org);
	
	makevectors(self.angles);
	org = org + v_forward * -32;

    fireRail (org, dir, self, self, dmg, 40, 2048);

	sound(self, CHAN_WEAPON, "sounds_q4/strogg/gladiator/railgun_blast.wav", 1, ATTN_NORM);
	pointparticles (particleeffectnum("EF_MUZZLEFLASH2"), org, '0 0 0');
};

void() gla_Melee =
{
	float ldmg;

	ai_face();

	ldmg = 20 + random()*20;

	vector	aim;

	aim = setvector (120, 0, 0);
	if (fire_hit(aim, rint(ldmg), 50))
	{	
		meat_hit (); 
	}
	else
	{
	
		meat_miss (); 
		self.pissed += 0.3;
	}
};

void() gla_flash2 = 
{   
   
    vector org;

    org = self.pos2;

    pointparticles (particleeffectnum("TE_BOLT_IMPACT_RED"), org, '0 0 0', 1);
};

void() gla_flash = 
{   
   
    vector org;

    org = self.pos2;

    pointparticles (particleeffectnum("TE_BOLT_IMPACT_RED"), org, '0 0 0', 4);
	pointparticles (particleeffectnum("EF_MUZZLEFLASH2"), org, '0 0 0');
};

void(float num = 0) gla_fireblaster = 
{   
   
    vector org;
    makevectors (self.angles);
	
// /	bprint(ftos(self.frame), "\n");
	if (self.frame == 22)
		org = self.origin + '0 0 56' + v_right * -26 + v_forward * (72 + num);
	else
    	org = self.origin + '0 0 56' + v_right * -26 + v_forward * (24 + num);

    vector dir = normalize(self.enemy.origin - org);

    LaunchLaser (org, dir, '0 0 0', '0 0 0');

	if (random() <= 0.5)
		sound(self, CHAN_WEAPON, "sounds_q4/strogg/gladiator/rapidfire_01.wav", 1, ATTN_NORM);
	else
		sound(self, CHAN_WEAPON, "sounds_q4/strogg/gladiator/rapidfire_02.wav", 1, ATTN_NORM);
	
	pointparticles (particleeffectnum("TE_BOLT_IMPACT_RED"), org, '0 0 0', 1);
	pointparticles (particleeffectnum("EF_MUZZLEFLASH2"), org, '0 0 0');
}


/*
============
ShamCheckAttack

The player is in view, so decide to move or launch an attack
Returns FALSE if movement should continue
============
*/
float() GladCheckAttack =
{
	local vector	spot1, spot2;	
	local entity	targ;
//	local float		chance;

	targ = self.enemy;
	makevectors(self.angles);
	vector offset = setvector (8, 25, 80);
	vector start = ProjectAim(self.origin, offset, v_forward, v_right);
	
// see if any entities are in the way of the shot
	spot1 = start;
	spot2 = targ.origin + targ.view_ofs;

	traceline (spot1, spot2, FALSE, self);

	if (trace_ent != targ)
		return FALSE;		// don't have a clear shot

	if (trace_inopen && trace_inwater)
		return FALSE;			// sight line crossed contents

	if (trace_ent != targ)
	{
		return FALSE;	// don't have a clear shot
	}

	if (enemy_range == RANGE_MELEE)
	{
		if (CanDamage (self.enemy, self))
		{
			self.attack_state = AS_MELEE;
			return TRUE;
		}
	}

	if (time < self.attack_finished)
		return FALSE;
	
	if (!enemy_vis)
		return FALSE;
		
// missile attack
	if (enemy_range == RANGE_FAR)
		return FALSE;
		
	self.attack_state = AS_MISSILE;
	SUB_AttackFinished (1 + 2*random());
	return TRUE;
};

//===========================================================================
