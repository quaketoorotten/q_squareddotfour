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

void() soldier_stand1 = [ 1, soldier_stand2 ] { ai_stand(); self.monster_frame = 0;};
void() soldier_stand2 = [ self.frame, soldier_stand2 ] 
{ 	
	self.monster_frame ++;
	if (self.monster_frame >= 29) 
	{	
		if (random() < 0.2)
			soldier_sfx_idle ();
		soldier_stand1 ();
		return;
	}
	ai_stand ();
};

void() soldier_walk1 = [ 2, soldier_walk2 ] { ai_walk(4); self.monster_frame = 0;};
void() soldier_walk2 = [ self.frame, soldier_walk2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 23) 
	{   
        if (random() < 0.2)
			soldier_sfx_idle2 ();
		soldier_walk1 ();
		return;
	}

	ai_walk (4);
};

void() soldier_run1 = [ 3, soldier_run2 ] { ai_run(self.speed); self.monster_frame = 0;};
void() soldier_run2 = [ self.frame, soldier_run2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 20) 
	{
		if (random() < 0.3)
			soldier_sfx_idle2 ();

		soldier_run1 ();
		return;
	}

    ai_run (self.speed);
};

void() soldier_evadel1 = [ 4, soldier_evadel2 ] 
{ 	ai_face();  self.nextthink = time + 0.04; self.monster_frame = 0;};
void() soldier_evadel2 = [ self.frame, soldier_evadel2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 17) 
	{	
		//self.attack_state = AS_STRAIGHT;
		self.flags &= ~FL_DODGED;
	//	despawn_shield ();
		soldier_run1 ();
		return;
	}

    if (self.monster_frame > 2) {
    	ai_charge(4);
    	M_walkmove (self.ideal_yaw + 90, 6);
    }

	self.nextthink = time + 0.04;
};

void() soldier_evader1 = [ 5, soldier_evader2 ] 
{ 	ai_face(); self.nextthink = time + 0.0; self.monster_frame = 0;};
void() soldier_evader2 = [ self.frame, soldier_evader2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 16) 
	{	
		//self.attack_state = AS_STRAIGHT;
		self.flags &= ~FL_DODGED;
	//	despawn_shield ();
		soldier_run1 ();
		return;
	}

	if (self.monster_frame > 2) {
    	ai_charge(4);
    	M_walkmove (self.ideal_yaw - 90, 6);
    }
	self.nextthink = time + 0.04;
};

void() soldier_evadef1 = [ 17, soldier_evadef2 ] 
{ 	self.maxs[2] = 32;
	ai_face();  self.nextthink = time + 0.04; self.monster_frame = 0;};
void() soldier_evadef2 = [ self.frame, soldier_evadef2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 27) 
	{	
		//self.attack_state = AS_STRAIGHT;
		self.flags &= ~FL_DODGED;
		self.maxs[2] = 64;
		soldier_run1 ();
		return;
	}

    if (self.monster_frame > 1) {
    	ai_charge(6);
    }

	self.nextthink = time + 0.04;
};

void() soldier_evade =
{	
	makevectors(self.angles);
	tracebox (self.origin, self.mins, self.maxs, self.origin + v_right * 128, FALSE, self);
	float right = trace_fraction;

	tracebox (self.origin, self.mins, self.maxs, self.origin + v_right * -128, FALSE, self);
	float left = trace_fraction;

	tracebox (self.origin, self.mins, self.maxs, self.origin + v_forward * 128, FALSE, self);
	float forward = trace_fraction;

	float r = rint(random()*3);

    if (r == 0)
        r = 1;

	if (left == 1 && right == 1 && forward == 1)
	{   
     //   soldier_sfx_growl ();
		if (r == 1)
			soldier_evadel1 ();
		else if (r == 2)
			soldier_evader1 ();
        else
            soldier_evadef1 ();
		return;
	}

	if (left == 1)
		{soldier_evadel1 (); }
	else if (right == 1)
		{soldier_evader1 (); }
    else if (forward == 1)
		{soldier_evadef1 (); }

	if (left < 1 || right < 1  || forward < 1)
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

void() soldier_walkl1 = [ 6, soldier_walkl2 ] 
{ 	ai_face();  self.nextthink = time + 0.04; self.monster_frame = 0;};
void() soldier_walkl2 = [ self.frame, soldier_walkl2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 20) 
	{	
		self.attack_state = AS_STRAIGHT;
		self.strafe_time = 0;
		soldier_run1 ();
		return;
	}

    if (self.monster_frame > 2) {
        ai_face();
    	M_walkmove (self.ideal_yaw + 90, 4);
    }

	self.nextthink = time + 0.04;
};

void() soldier_walkr1 = [ 5, soldier_walkr2 ] 
{ 	ai_face(); self.nextthink = time + 0.0; self.monster_frame = 0;};
void() soldier_walkr2 = [ self.frame, soldier_walkr2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 14)
	{	
		self.attack_state = AS_STRAIGHT;
		self.strafe_time = 0;
		soldier_run1 ();
		return;
	}

	if (self.monster_frame > 2) {
    	ai_face();
    	M_walkmove (self.ideal_yaw - 90, 4);
    }
	self.nextthink = time + 0.04;
};

void() soldier_walkb1 = [ 8, soldier_walkb2 ] 
{ 	ai_face(); self.nextthink = time + 0.0; self.monster_frame = 0;};
void() soldier_walkb2 = [ self.frame, soldier_walkb2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 23) 
	{	
		self.attack_state = AS_STRAIGHT;
		soldier_run1 ();
		return;
	}	

	if (self.monster_frame > 2) {
    	ai_charge(-4);
    }
	self.nextthink = time + 0.04;
};

void() soldier_walk_strf =
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
     //   soldier_sfx_growl ();
		if (r == 1)
			soldier_walkl1 ();
		else if (r == 2)
			soldier_walkr1 ();
        else
            soldier_walkb1 ();
		return;
	}

	if (left == 1)
		{soldier_walkl1 (); }
	else if (right == 1)
		{soldier_walkr1 (); }
    else if (back == 1)
		{soldier_walkb1 (); }

	if (left < 1 || right < 1  || back < 1)
	{	
        self.th_run ();
		self.strafe_time = 0;
		return;
	}
	
	self.nextthink = time;
};

//==============================================================================

void() soldier_runl1 = [ 9, soldier_runl2 ] 
{ 	ai_face();  self.nextthink = time + 0.04; self.monster_frame = 0;};
void() soldier_runl2 = [ self.frame, soldier_runl2 ] 
{ 
	self.monster_frame ++;
	if (self.strafe_time < time)
	{	
		self.attack_state = AS_STRAIGHT;
		self.strafe_time = 0;
		soldier_run1 ();
		return;
	}

	if (self.monster_frame >= 16) 
	{
		soldier_runl1 ();
		return;
	}	

    if (self.monster_frame > 0) {
        ai_face();
    	M_walkmove (self.ideal_yaw + 90, self.speed);
    }

	self.nextthink = time + 0.04;
};

void() soldier_runr1 = [ 10, soldier_runr2 ] 
{ 	ai_face(); self.nextthink = time + 0.0; self.monster_frame = 0;};
void() soldier_runr2 = [ self.frame, soldier_runr2 ] 
{ 
	self.monster_frame ++;
	if (self.strafe_time < time)
	{	
		self.attack_state = AS_STRAIGHT;
		self.flags &= ~FL_DODGED;
		self.strafe_time = 0;
		soldier_run1 ();
		return;
	}

	if (self.monster_frame >= 16) 
	{
		soldier_runr1 ();
		return;
	}	

	if (self.monster_frame > 0) {
    	ai_face();
    	M_walkmove (self.ideal_yaw - 90, self.speed);
    }
	self.nextthink = time + 0.04;
};

void() soldier_runb1 = [ 11, soldier_runb2 ] 
{ 	ai_face(); self.nextthink = time + 0.0; self.monster_frame = 0;};
void() soldier_runb2 = [ self.frame, soldier_runb2 ] 
{ 
	self.monster_frame ++;
	if (self.strafe_time < time) 
	{	
		self.attack_state = AS_STRAIGHT;
		self.flags &= ~FL_DODGED;
		self.strafe_time = 0;
		soldier_run1 ();
		return;
	}

	if (self.monster_frame >= 23) 
	{
		soldier_runb1 ();
		return;
	}	

	if (self.monster_frame > 0) {
    	ai_charge(-self.speed);
    }
	self.nextthink = time + 0.04;
};

void() soldier_run_strf =
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
     //   soldier_sfx_growl ();
		if (r == 1)
			soldier_runl1 ();
		else if (r == 2)
			soldier_runr1 ();
        else
            soldier_runb1 ();
		return;
	}

	if (left == 1)
		{soldier_runl1 (); }
	else if (right == 1)
		{soldier_runr1 (); }
    else if (back == 1)
		{soldier_runb1 (); }

	if (left < 1 || right < 1  || back < 1)
	{	
        self.th_run ();
		self.strafe_time = 0;
		return;
	}
	
	self.nextthink = time;
};

//==============================================================================

static void(entity target, string name) soldier_tag_entity =
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

static void() soldier_tag_think =
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
	
	self.think = soldier_tag_think;
	self.angles = self.owner.angles;
	self.nextthink = time;
}

static void(string stringg, float fr, float end, string name, string tag) soldier_tag = 
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
		soldier_tag_entity(e, name);

	e.netname = tag;
	e.think = soldier_tag_think;
	e.nextthink = time;
}

//==============================================================================

void() soldier_missilea1_0 = [ 19, soldier_missilea2_0 ] {

	if (self.weapontype == 3)
		sound(self, CHAN_RELOAD, "sounds_q4/strogg/stroggmarine/ready_mgun.wav", 1, ATTN_NORM);
	else
		sound(self, CHAN_RELOAD, "sounds_q4/strogg/stroggmarine/ready_blaster.wav", 1, ATTN_NORM);

	ai_face(); self.nextthink = time + 0.04; self.monster_frame = 0; };
void() soldier_missilea2_0 = [ self.frame, soldier_missilea2_0 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	
	if (self.monster_frame >= 14) 
	{   
        soldier_missilea1_1 ();
        self.count = 0;
		return;
	}

	ai_face();
};

void() soldier_missilea1_1 = [ 20, soldier_missilea2_1 ] {

	soldier_tag ("progs/monsters/strogg_marine/fire01_tag.md3", 20, 999, string_null, "Empty.001");
	ai_face(); self.nextthink = time + 0.04; self.monster_frame = 0; };
void() soldier_missilea2_1 = [ self.frame, soldier_missilea2_1 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

    if (self.monster_frame == 2)
    {
        soldier_shoot ();
	//	gla_fireblaster (24);
        self.count ++;
    }

	if (self.weapontype == 3 && self.monster_frame == 4)
		soldier_shoot ();

    if (self.monster_frame >= 4)
        self.monster_frame = 0;

	if (!visible(self.enemy)) 
	{   
        self.count = 0;
		if (random() <= 0.4)
			soldier_walk_strf ();
		else
			soldier_missilea1_2 ();

		return;
	}
	
	if (self.count >= 8) 
	{   
		if (random() <= 0.4)
			soldier_walk_strf ();
		else
			soldier_missilea1_2 ();
		return;
	}

	ai_face();
};

void() soldier_missilea1_2 = [ 21, soldier_missilea2_2 ] {

	ai_face(); self.nextthink = time + 0.04; self.monster_frame = 0; };
void() soldier_missilea2_2 = [ self.frame, soldier_missilea2_2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	
	if (self.monster_frame >= 7) 
	{   
        self.count = 0;
		soldier_run1 ();
		return;
	}

	ai_face();
};

void() soldier_missileb1_0 = [ 22, soldier_missileb2_0 ] {

	if (self.weapontype == 3)
		sound(self, CHAN_RELOAD, "sounds_q4/strogg/stroggmarine/ready_mgun.wav", 1, ATTN_NORM);
	else
		sound(self, CHAN_RELOAD, "sounds_q4/strogg/stroggmarine/ready_blaster.wav", 1, ATTN_NORM);

	ai_face(); self.nextthink = time + 0.04; self.monster_frame = 0; };
void() soldier_missileb2_0 = [ self.frame, soldier_missileb2_0 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	
	if (self.monster_frame >= 9) 
	{   
        soldier_missileb1_1 ();
        self.count = 0;
		return;
	}

	ai_face();
};

void() soldier_missileb1_1 = [ 23, soldier_missileb2_1 ] {

	soldier_tag ("progs/monsters/strogg_marine/fire03_tag.md3", 23, 999, string_null, "Empty.001");
	ai_face(); self.nextthink = time + 0.04; self.monster_frame = 0; };
void() soldier_missileb2_1 = [ self.frame, soldier_missileb2_1 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

    if (self.monster_frame == 2)
    {
        soldier_shoot ();
	//	gla_fireblaster (24);
        self.count ++;
    }
        
    if (self.monster_frame >= 4)
        self.monster_frame = 0;

	if (self.weapontype == 3 && self.monster_frame == 4)
		soldier_shoot ();

	if (!visible(self.enemy)) 
	{   
        self.count = 0;
		if (random() <= 0.4)
			soldier_walk_strf ();
		else
			soldier_missilec1_2 ();

		return;
	}	
	
	if (self.count >= 8) 
	{   
		if (random() <= 0.4)
			soldier_walk_strf ();
		else
			soldier_missileb1_2 ();
		return;
	}

	ai_face();
};

void() soldier_missileb1_2 = [ 24, soldier_missileb2_2 ] {

	ai_face(); self.nextthink = time + 0.04; self.monster_frame = 0; };
void() soldier_missileb2_2 = [ self.frame, soldier_missileb2_2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	
	if (self.monster_frame >= 8) 
	{   
        self.count = 0;
		soldier_run1 ();
		return;
	}

	ai_face();
};

void() soldier_missilec1_0 = [ 25, soldier_missilec2_0 ] {

	if (self.weapontype == 3)
		sound(self, CHAN_RELOAD, "sounds_q4/strogg/stroggmarine/ready_mgun.wav", 1, ATTN_NORM);
	else
		sound(self, CHAN_RELOAD, "sounds_q4/strogg/stroggmarine/ready_blaster.wav", 1, ATTN_NORM);

	ai_face(); self.nextthink = time + 0.04; self.monster_frame = 0; };
void() soldier_missilec2_0 = [ self.frame, soldier_missilec2_0 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	
	if (self.monster_frame >= 7) 
	{   
        soldier_missilec1_1 ();
        self.count = 0;
		return;
	}

	ai_face();
};

void() soldier_missilec1_1 = [ 26, soldier_missilec2_1 ] {

	soldier_tag ("progs/monsters/strogg_marine/fire04_tag.md3", 26, 999, string_null, "Empty.001");
	ai_face(); self.nextthink = time + 0.04; self.monster_frame = 0; };
void() soldier_missilec2_1 = [ self.frame, soldier_missilec2_1 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

    if (self.monster_frame == 2)
    {
        soldier_shoot ();
	//	gla_fireblaster (24);
        self.count ++;
    }

	if (self.weapontype == 3 && self.monster_frame == 5)
		soldier_shoot ();

    if (self.monster_frame >= 5)
        self.monster_frame = 0;

	if (!visible(self.enemy)) 
	{   
        self.count = 0;
		if (random() <= 0.4)
			soldier_walk_strf ();
		else
			soldier_missilec1_2 ();

		return;
	}
	
	if (self.count >= 8) 
	{   
		if (random() <= 0.4)
			soldier_walk_strf ();
		else
			soldier_missilec1_2 ();
		return;
	}

	ai_face();
};

void() soldier_missilec1_2 = [ 27, soldier_missilec2_2 ] {

	ai_face(); self.nextthink = time + 0.04; self.monster_frame = 0; };
void() soldier_missilec2_2 = [ self.frame, soldier_missilec2_2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame >= 8) 
	{   
        self.count = 0;
		soldier_run1 ();
		return;
	}

	ai_face();
};

void() soldier_missile_shotgun1 = [ 18, soldier_missile_shotgun2 ] {
	soldier_tag ("progs/monsters/strogg_marine/shotgun_tag.md3", 18, 999, string_null, "Empty.001");
	ai_face(); self.nextthink = time + 0.04; self.monster_frame = 0; };
void() soldier_missile_shotgun2 = [ self.frame, soldier_missile_shotgun2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 18)
    {
        soldier_shoot ();
	//	gla_fireblaster (24);
    //    self.count ++;
    }

	if (self.monster_frame == 28)
	{
		sound(self, CHAN_RELOAD, "sounds_q4/strogg/stroggmarine/ready_weapon.wav", 1, ATTN_NORM);
	}

	if (self.monster_frame == 10)
    {
        soldier_flash ();
	//	gla_fireblaster (24);
    //    self.count ++;
    }
	
	if (self.monster_frame >= 45) 
	{   
        self.count = 0;
		soldier_run1 ();
		return;
	}

	ai_face();
};

void() soldier_dive_shoot1 = [ 17, soldier_dive_shoot2 ] 
{ 	self.maxs[2] = 32;
	self.flags |= FL_DODGED;
	ai_face();  self.nextthink = time + 0.04; self.monster_frame = 0;};
void() soldier_dive_shoot2 = [ self.frame, soldier_dive_shoot2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 27) 
	{	
		//self.attack_state = AS_STRAIGHT;
		self.maxs[2] = 64;
		self.flags &= ~FL_DODGED;
		soldier_missile_shotgun1 ();
		return;
	}

    if (self.monster_frame > 1) {
    	ai_charge(6);
    }

	self.nextthink = time + 0.04;
};

//==============================================================================

void() soldier_meleea1 = [ 28, soldier_meleea2 ] {
	self.monster_frame = 0;
	soldier_tag ("progs/monsters/strogg_marine/melee1_tag.md3", 28, 16, "TE_WHOOSH", "Empty");
	ai_face(); self.nextthink = time + 0.04;  };
void() soldier_meleea2 = [ self.frame, soldier_meleea2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 11)
		soldier_Melee(0);

	if (self.monster_frame >= 26) 
	{   
        soldier_evade ();
		return;
	}

    if (self.monster_frame <= 11)
		ai_face ();
};

void() soldier_meleeb1 = [ 29, soldier_meleeb2 ] {
	self.monster_frame = 0;
  	soldier_tag ("progs/monsters/strogg_marine/melee2_tag.md3", 29, 14, "TE_WHOOSH", "Empty");
	ai_face(); self.nextthink = time + 0.04;  };
void() soldier_meleeb2 = [ self.frame, soldier_meleeb2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 8)
		soldier_Melee(0);

	if (self.monster_frame >= 21) 
	{   
        soldier_walk_strf ();
		return;
	}

    if (self.monster_frame > 0 && self.monster_frame < 14)
		ai_charge (5);

	if (self.monster_frame > 14)
		ai_charge (-2);
};

void() soldier_meleec1 = [ 30, soldier_meleec2 ] {
	self.monster_frame = 0;
	soldier_tag ("progs/monsters/strogg_marine/melee3_tag.md3", 30, 17, "TE_WHOOSH", "Empty");
	ai_face(); self.nextthink = time + 0.04;  };
void() soldier_meleec2 = [ self.frame, soldier_meleec2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 11)
		soldier_Melee(0);

	if (self.monster_frame >= 34) 
	{   
        soldier_run_strf ();
		return;
	}

    if (self.monster_frame < 17)
		ai_face ();
};

void() soldier_meleed1 = [ 31, soldier_meleed2 ] {
	self.monster_frame = 0;
	soldier_tag ("progs/monsters/strogg_marine/melee4_tag1.md3", 31, 18, "TE_WHOOSH", "Empty");
	ai_face(); self.nextthink = time + 0.04;  };
void() soldier_meleed2 = [ self.frame, soldier_meleed2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 23)
		soldier_Melee(1);

	if (self.monster_frame == 11)
		soldier_Melee(0);

	if (self.monster_frame == 18)
		soldier_tag ("progs/monsters/strogg_marine/melee4_tag2.md3", 31, 28, "TE_WHOOSH", "Empty");

	if (self.monster_frame >= 33) 
	{   
		if (random() <= 0.5)
	        soldier_evade ();
		else
			soldier_walk_strf ();
		return;
	}

	if (self.monster_frame > 4 && self.monster_frame < 15)
		ai_charge (5);

    if (self.monster_frame > 18 && self.monster_frame < 25)
		ai_charge (5);

	if (self.monster_frame < 4)
		ai_charge (-2);

	if (self.monster_frame > 25)
		ai_charge (-2);
};

//==============================================================================

void() soldier_MeleeAttack =
{	
	soldier_sfx_growl ();

	if (self.weapontype == 1)
	{
		if(random() <= 0.5)
			soldier_meleea1 ();
		else
			soldier_meleed1 ();
	}

	if (self.weapontype == 2)
	{
		if(random() <= 0.5)
			soldier_meleeb1 ();
		else
			soldier_meleea1 ();
	}

	if (self.weapontype == 3)
	{
		if(random() <= 0.5)
			soldier_meleec1 ();
		else
			soldier_meleed1 ();
	}	
};

void() soldier_MissileAttack =
{   
	soldier_sfx_cc ();

	if (self.weapontype == 1)
	{
		if(random() <= 0.5)
			soldier_missilec1_0 ();
		else
			soldier_missileb1_0 ();
	}

	if (self.weapontype == 2)
	{
		if(random() <= 0.5)
			soldier_dive_shoot1 ();
		else
			soldier_missile_shotgun1 ();
	}

	if (self.weapontype == 3)
	{
		if(random() <= 0.5)
			soldier_missilea1_0 ();
		else
			soldier_missilec1_0 ();
	}
};

//==============================================================================

// regular ow
void() soldier_paina1 = [ 15, soldier_paina2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() soldier_paina2 = [ self.frame, soldier_paina2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint("????", "\n");
	if (self.monster_frame >= 14) 
	{
		soldier_run1 ();
		return;
	}
};

void() soldier_painb1 = [ 16, soldier_painb2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() soldier_painb2 = [ self.frame, soldier_painb2 ] 
{   
    //bprint(ftos(self.frame), "\n");
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint(">>>>>>>>>>?????", "\n");
	if (self.monster_frame >= 14) 
	{
		soldier_run1 ();
		return;
	}
};

// concussion
void() soldier_painc1 = [ 12, soldier_painc2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() soldier_painc2 = [ self.frame, soldier_painc2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

    if (self.monster_frame > 0 && self.monster_frame < 12)
        ai_move (-3);

    if (self.monster_frame > 12 && self.monster_frame < 16)
        ai_move(2);

	// bprint("????", "\n");
	if (self.monster_frame >= 16) 
	{   
		soldier_run1 ();
		return;
	}
};

// pain head
void() soldier_paind1 = [ 14, soldier_paind2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() soldier_paind2 = [ self.frame, soldier_paind2 ] 
{   
    //bprint(ftos(self.frame), "\n");
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint(">>>>>>>>>>?????", "\n");

	if (self.monster_frame >= 11) 
	{   
		soldier_run1 ();
		return;
	}
};

// pain gut
void() soldier_paine1 = [ 13, soldier_paine2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() soldier_paine2 = [ self.frame, soldier_paine2 ] 
{   
    //bprint(ftos(self.frame), "\n");
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint(">>>>>>>>>>?????", "\n");

	if (self.monster_frame >= 14) 
	{   
		soldier_run1 ();
		return;
	}
};

void(entity attacker, float damage, float MOD) soldier_pain =
{
	if (self.attack_state == AS_SLIDING)
	{
		self.attack_state = AS_STRAIGHT;
		self.strafe_time = 0;
		self.attack_finished = 0;
		self.th_run();
		return;
	}

	if (self.flags & FL_DODGED)
	{	
		return;
	}

	if (self.pain_finished > time)
		return;

	self.pain_finished = time + 2;
	soldier_sfx_pain (); // sfx

	if (DMGTYPE_LTNG == MOD)
	{
  	  if (random() <= 0.5)
	        soldier_paina1 ();
 	   else
  	      	soldier_painb1 ();
		
		if (skill < 2)
			self.pain_finished = time + 0.5;
		else
			self.pain_finished = time + 1.5;
		return;
	}

	if (MOD == DMGTYPE_RAIL)
	{   
         if (random() <= 0.5)
            soldier_painc1 ();
        else
            soldier_paine1 ();

		self.pain_finished = time + 2.5;
		return;
	}

	if (random()*80 > damage)
		return; // didn't flinch

	if (damage > 30 || MOD == DMGTYPE_EXP)
	{   
         if (random() <= 0.5)
            soldier_painc1 ();
        else
            soldier_paine1 ();
		return;
	}
    
    if (random() <= 0.5)
        soldier_paina1 ();
    else
        soldier_painb1 ();
};

void() soldier_die =
{	
	////setmodel(self, "progs/monsters/stroggmarine/soldier_mesh_death.iqm");
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

	soldier_sfx_death ();

	local vector tmpangle;
	local float tempskin;
	tmpangle = self.angles;
	tempskin = self.skin;
	
	if (random() <= 0.3)
		self.think = soldier_die1;
	else
		self.think = soldier_dieb1;

	self.deadflag = DEAD_DEAD;
	self.solid = SOLID_CORPSE;
//	self.movetype = MOVETYPE_STEP;
	self.nextthink = time + 0.04;

	self.angles = tmpangle;
	//self.skin = tempskin;
};

void() soldier_die1 = [ 32 , soldier_die2 ] { self.nextthink = time + 0.04; self.monster_frame = 0;};
void() soldier_die2 = [ self.frame , soldier_die2 ] 
{ 	
	//self.frame |= 0x8000;
	self.nextthink = time + 0.04;


	self.monster_frame ++;

	if (self.monster_frame < 7)
		ai_move (3);

	if (self.monster_frame > 17 && self.monster_frame < 22)
		ai_move (3);

	if (self.monster_frame > 35 && self.monster_frame < 45)
		ai_move (3);

	if (self.monster_frame == 67)
	{
		self.maxs_z = 12;
		self.nextthink = -1;
		self.think = soldier_fade1;
		self.nextthink = time + 3.5;
		self.cnt = 1;
		return;
	}
};

void() soldier_dieb1 = [ 33 , soldier_dieb2 ] { self.nextthink = time + 0.04; self.monster_frame = 0;};
void() soldier_dieb2 = [ self.frame , soldier_dieb2 ] 
{ 	
	//self.frame |= 0x8000;
	self.nextthink = time + 0.04;

	if (self.monster_frame < 18)
		ai_move (-4.5);
	
	self.monster_frame ++;
	if (self.monster_frame == 67)
	{
		self.maxs_z = 12;
		self.nextthink = -1;
		self.think = soldier_fade1;
		self.nextthink = time + 3.5;
		return;
	}
};

static string models[4] =
{
	"progs/monsters/strogg_marine/blasterdie.iqm",
	"progs/monsters/strogg_marine/blasterdie.iqm",
	"progs/monsters/strogg_marine/shotgundie.iqm",
	"progs/monsters/strogg_marine/machinegundie.iqm",
};

void() soldier_fade1 = [ self.frame, soldier_gib2 ] 
{	
	if (self.cnt == 1)
		self.frame = 0;
	else
		self.frame = 1;
	
	setmodel(self, models[self.weapontype]);
	setsize(self, '-16 -16 0', '16 16 12');

//	self.skin = 1; 
	self.alpha = 1; 
	self.glowmod = '0.5 0.5 0.5'; 
	self.nextthink = time + 0.02;
};

void() soldier_gib1 = [ self.frame, soldier_gib2 ] 
{MonsterGib (self.health); self.skin = 1; self.alpha = 1; self.nextthink = time + 0.02;};

void() soldier_gib2 = [ self.frame, soldier_gib2 ] 
{ 	
	self.nextthink = time + 0.02;
	self.alpha -= 0.02;
	if (self.alpha <= 0)
	{
		remove(self);
		return;
	}
};

static string growl_list[9] = 
{
	"sounds_q4/strogg/stroggmarine/growl1.wav",
	"sounds_q4/strogg/stroggmarine/growl2.wav",
	"sounds_q4/strogg/stroggmarine/growl3.wav",
	"sounds_q4/strogg/stroggmarine/growl4.wav",
	"sounds_q4/strogg/stroggmarine/growl5.wav",
	"sounds_q4/strogg/stroggmarine/growl6.wav",
	"sounds_q4/strogg/stroggmarine/growl7.wav",
	"sounds_q4/strogg/stroggmarine/growl8.wav",
	"sounds_q4/strogg/stroggmarine/growl1.wav",
};	

static void() soldier_sfx_growl =
{
	local float r = rint(random() * 8);	

	sound(self, CHAN_VOICE, growl_list[r], 1, ATTN_NORM);
};

static string death_list[6] = 
{
	"sounds_q4/strogg/stroggmarine/die2.wav",
	"sounds_q4/strogg/stroggmarine/die3.wav",
	"sounds_q4/strogg/stroggmarine/die4.wav",
	"sounds_q4/strogg/stroggmarine/die5.wav",
	"sounds_q4/strogg/stroggmarine/die6.wav",
	"sounds_q4/strogg/stroggmarine/die2.wav",
};	

static void() soldier_sfx_death =
{
	local float r = rint(random() * 5);	

	sound(self, CHAN_VOICE, death_list[r], 1, ATTN_NORM);
};

static void() soldier_sfx_idle =
{
	local float r = rint(random() * 4);	

	if (r == 4)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/stroggmarine/breath01.wav", 1, ATTN_IDLE);
	else if (r == 3)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/stroggmarine/breath02.wav", 1, ATTN_IDLE);
    else if (r == 2)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/stroggmarine/breath03.wav", 1, ATTN_IDLE);
	else 
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/stroggmarine/breath04.wav", 1, ATTN_IDLE);
};

static void() soldier_sfx_idle2 =
{
	local float r = rint(random() * 3);	

	if (r == 2)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/stroggmarine/chatter_idle1.wav", 1, ATTN_IDLE);
	else if (r == 1)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/stroggmarine/chatter_idle2.wav", 1, ATTN_IDLE);
    else 
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/stroggmarine/chatter_idle3.wav", 1, ATTN_IDLE);
};

static void() soldier_sfx_cc =
{
	local float r = rint(random() * 3);	

	if (r == 2)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/stroggmarine/chatter_combat1.wav", 1, ATTN_NORM);
	else if (r == 1)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/stroggmarine/chatter_combat2.wav", 1, ATTN_NORM);
    else 
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/stroggmarine/chatter_combat3.wav", 1, ATTN_NORM);
};

static string pain_list[7] = 
{
	"sounds_q4/strogg/stroggmarine/pain1.wav",
	"sounds_q4/strogg/stroggmarine/pain2.wav",
	"sounds_q4/strogg/stroggmarine/pain3.wav",
	"sounds_q4/strogg/stroggmarine/pain4.wav",
	"sounds_q4/strogg/stroggmarine/pain5.wav",
	"sounds_q4/strogg/stroggmarine/pain6.wav",
	"sounds_q4/strogg/stroggmarine/pain1.wav",
};	

static void() soldier_sfx_pain =
{
	local float r = rint(random() * 6);	

	sound(self, CHAN_VOICE, pain_list[r], 1, ATTN_NORM);
};

static string sight_list[13] = 
{
	"sounds_q4/strogg/stroggmarine/sight3.wav",
	"sounds_q4/strogg/stroggmarine/sight4.wav",
	"sounds_q4/strogg/stroggmarine/sight5.wav",
	"sounds_q4/strogg/stroggmarine/sight6.wav",
	"sounds_q4/strogg/stroggmarine/sight6.wav",
	"sounds_q4/strogg/stroggmarine/sight8.wav",
	"sounds_q4/strogg/stroggmarine/sight9.wav",
	"sounds_q4/strogg/stroggmarine/sight10.wav",
	"sounds_q4/strogg/stroggmarine/sight11.wav",
	"sounds_q4/strogg/stroggmarine/sight12.wav",
	"sounds_q4/strogg/stroggmarine/sight13.wav",
	"sounds_q4/strogg/stroggmarine/sight14.wav",
	"sounds_q4/strogg/stroggmarine/sight3.wav",
};	

void() soldier_sfx_sight =
{   
	local float r = rint(random() * 12);	

	sound(self, CHAN_VOICE, sight_list[r], 1, ATTN_NORM);
};

/*QUAKED monster_demon (1 0 0) (-32 -32 -24) (32 32 64) Ambush

*/
void() monster_soldier_cache =
{
	precache_model("progs/monsters/strogg_marine/strogg_marine.md5.info");
	precache_model("progs/monsters/strogg_marine/strogg_marine2.md5.info");
	precache_model("progs/monsters/strogg_marine/strogg_marine3.md5.info");

	precache_model("progs/monsters/strogg_marine/blasterdie.iqm");
	precache_model("progs/monsters/strogg_marine/shotgundie.iqm");
	precache_model("progs/monsters/strogg_marine/machinegundie.iqm");

    precache_model("progs/monsters/strogg_marine/fire01_tag.md3");
    precache_model("progs/monsters/strogg_marine/fire04_tag.md3");
    precache_model("progs/monsters/strogg_marine/fire03_tag.md3");
	precache_model("progs/monsters/strogg_marine/shotgun_tag.md3");

    precache_model("progs/monsters/strogg_marine/melee1_tag.md3");
    precache_model("progs/monsters/strogg_marine/melee2_tag.md3");
    precache_model("progs/monsters/strogg_marine/melee3_tag.md3");
	precache_model("progs/monsters/strogg_marine/melee4_tag1.md3");
	precache_model("progs/monsters/strogg_marine/melee4_tag2.md3");

//    precache_model("progs/monsters/stroggmarine/soldier_shield_mesh.md5.info");

	precache_sound("sounds_q4/strogg/stroggmarine/sight3.wav");
    precache_sound("sounds_q4/strogg/stroggmarine/sight4.wav");
	precache_sound("sounds_q4/strogg/stroggmarine/sight5.wav");
	precache_sound("sounds_q4/strogg/stroggmarine/sight6.wav");
	precache_sound("sounds_q4/strogg/stroggmarine/sight6.wav");
    precache_sound("sounds_q4/strogg/stroggmarine/sight8.wav");
	precache_sound("sounds_q4/strogg/stroggmarine/sight9.wav");
	precache_sound("sounds_q4/strogg/stroggmarine/sight10.wav");
    precache_sound("sounds_q4/strogg/stroggmarine/sight11.wav");
	precache_sound("sounds_q4/strogg/stroggmarine/sight12.wav");
	precache_sound("sounds_q4/strogg/stroggmarine/sight13.wav");
    precache_sound("sounds_q4/strogg/stroggmarine/sight14.wav");
	
	precache_sound("sounds_q4/strogg/stroggmarine/ready_mgun.wav");
	precache_sound("sounds_q4/strogg/stroggmarine/ready_blaster.wav");
    precache_sound("sounds_q4/strogg/stroggmarine/ready_weapon.wav");

	precache_sound("sounds_q4/strogg/stroggmarine/die2.wav");
	precache_sound("sounds_q4/strogg/stroggmarine/die3.wav");	
	precache_sound("sounds_q4/strogg/stroggmarine/die4.wav");	
	precache_sound("sounds_q4/strogg/stroggmarine/die5.wav");	
	precache_sound("sounds_q4/strogg/stroggmarine/die6.wav");	

	precache_sound("sounds_q4/strogg/stroggmarine/pain1.wav");
	precache_sound("sounds_q4/strogg/stroggmarine/pain2.wav");
	precache_sound("sounds_q4/strogg/stroggmarine/pain3.wav");
    precache_sound("sounds_q4/strogg/stroggmarine/pain4.wav");
    precache_sound("sounds_q4/strogg/stroggmarine/pain5.wav");
    precache_sound("sounds_q4/strogg/stroggmarine/pain6.wav");

	precache_sound("sounds_q4/strogg/stroggmarine/growl1.wav");
	precache_sound("sounds_q4/strogg/stroggmarine/growl2.wav");
	precache_sound("sounds_q4/strogg/stroggmarine/growl3.wav");
    precache_sound("sounds_q4/strogg/stroggmarine/growl4.wav");
    precache_sound("sounds_q4/strogg/stroggmarine/growl5.wav");
    precache_sound("sounds_q4/strogg/stroggmarine/growl6.wav");
    precache_sound("sounds_q4/strogg/stroggmarine/growl7.wav");
    precache_sound("sounds_q4/strogg/stroggmarine/growl8.wav");

    precache_sound("sounds_q4/strogg/stroggmarine/chatter_idle1.wav");
    precache_sound("sounds_q4/strogg/stroggmarine/chatter_idle2.wav");
    precache_sound("sounds_q4/strogg/stroggmarine/chatter_idle3.wav");

    precache_sound("sounds_q4/strogg/stroggmarine/chatter_combat1.wav");
    precache_sound("sounds_q4/strogg/stroggmarine/chatter_combat2.wav");
    precache_sound("sounds_q4/strogg/stroggmarine/chatter_combat3.wav");

	precache_sound("sounds_q4/strogg/stroggmarine/breath01.wav");	
	precache_sound("sounds_q4/strogg/stroggmarine/breath02.wav");	
	precache_sound("sounds_q4/strogg/stroggmarine/breath03.wav");	
	precache_sound("sounds_q4/strogg/stroggmarine/breath04.wav");	

	precache_sound("sounds_q4/strogg/stroggmarine/weapon_slap.wav");	
	precache_sound("sounds_q4/strogg/stroggmarine/slash.wav");	

	precache_sound("sounds_q4/strogg/stroggmarine/fire01.wav");	
	precache_sound("sounds_q4/strogg/stroggmarine/fire02.wav");	
//	spawn_demon ();
};

void() monster_soldier_blaster =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	monster_soldier_cache ();	
	spawn_soldier_blaster ();
};

void() monster_soldier_light =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	monster_soldier_cache ();	
	spawn_soldier_blaster ();
};

void() spawn_soldier_blaster =
{
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	self.classname = "monster_soldier";
	setmodel(self, "progs/monsters/strogg_marine/strogg_marine.md5.info");

	setsize(self, '-16 -16 0', '16 16 64');
	self.health = 136;
	self.max_health = 136;
	self.mass = 300; 
	self.scale = 0.8;

	self.th_stand = soldier_stand1;
	self.th_walk = soldier_walk1;
	self.th_run = soldier_run1;
	self.th_die = soldier_die;
	self.th_melee = soldier_MeleeAttack; // one of two attacks
	self.th_missile = soldier_MissileAttack; // jump attack
	self.th_pain = soldier_pain;
	self.th_checkatck = SoldierCheckAttack;
	self.th_spawn = spawn_soldier_blaster;
	self.th_dodge = soldier_evade;
	self.th_sight = soldier_sfx_sight;
	//setcustomskin (self, "progs/monsters/stroggmarine/soldier.skin")
	self.deathtype = "was killed by a Strogg Marine";
	self.count = 0;
	self.pissed = 0;
    self.speed = 6;
	self.strafe_time = 0;
	self.weapontype = 1;

	walkmonster_start();
};

/*
==============================================================================

DEMON

==============================================================================
*/

float() SoldierCheckAttack =
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
			self.attack_state = AS_MISSILE;
		else
			self.attack_state = AS_MELEE;
		return TRUE;
	}
	
// missile attack
	
	if (self.flags & FL_DODGED)
		return FALSE;
		
	if (time < self.attack_finished)
	{	
		if ((vlen(spot1 - spot2) <= 280) && self.strafe_time < time)
		{	
			soldier_walk_strf ();

			self.strafe_time = 0;
			self.attack_state = AS_SLIDING;
			return FALSE;
		}

		if ((vlen(spot1 - spot2) <= 700) && self.strafe_time < time)
		{	
			soldier_run_strf ();

			self.strafe_time = time + (1 + random());
			self.attack_state = AS_SLIDING;
			return FALSE;
		}
		return FALSE;
	}
		
	if (enemy_range == RANGE_FAR)
		return FALSE;
	
	if (self.weapontype == 2)
	{
		if (enemy_range == RANGE_MELEE)
			chance = 0.25;
		else if (enemy_range == RANGE_CLOSE)
			chance = 0.2;
		else if (enemy_range == RANGE_NEAR)
			chance = 0.15;
		else if (enemy_range == RANGE_MID)
			chance = 0.1;
		else
			return FALSE;
	}
	else
	{
		if (enemy_range == RANGE_MELEE)
			chance = 0.15;
		else if (enemy_range == RANGE_CLOSE)
			chance = 0.2;
		else if (enemy_range == RANGE_NEAR)
			chance = 0.2;
		else if (enemy_range == RANGE_MID)
			chance = 0.15;
		else
			return FALSE;
	}

	if (random () < chance)
	{
		self.attack_state = AS_MISSILE;
		SUB_AttackFinished (1 + 2*random());
		return TRUE;
	}

	return FALSE;
};

void() soldier_shoot = 
{   
	float r = rint(random()*3);

    if (self.dspeed > time)
        return;

    vector dir, org;
	entity en;

	if (self.weapontype == 2)
	{
		if (random() <= 0.5)
			sound(self, CHAN_WEAPON, "sounds_q4/strogg/stroggmarine/fire01.wav", 1, ATTN_NORM);
		else
			sound(self, CHAN_WEAPON, "sounds_q4/strogg/stroggmarine/fire02.wav", 1, ATTN_NORM);
	}
	if (self.weapontype == 3)
	{
		if(random() >= 0.5)
			sound(self, CHAN_WEAPON, "sounds_q4/weapons/machinegun/fire0.wav", 1, ATTN_NORM);
		else	
			sound(self, CHAN_WEAPON, "sounds_q4/weapons/machinegun/fire1.wav", 1, ATTN_NORM);
	}
	if (self.weapontype == 1)
	{
		if (random() <= 0.5)
			sound(self, CHAN_WEAPON, "sounds_q4/weapons/blaster/fire01.wav", 1, ATTN_NORM);
		else
			sound(self, CHAN_WEAPON, "sounds_q4/weapons/blaster/fire02.wav", 1, ATTN_NORM);
	}

// fire somewhat behind the player, so a dodging player is harder to hit
	en = self.enemy;

//	makevectors(self.angles);
	org = self.pos2;
	
	pointparticles (particleeffectnum("TE_MUZZLEFLASH2"), org , '0 0 0');
	pointparticles (particleeffectnum("EF_MUZZLEFLASH2"), org , '0 0 0');

	dir = en.origin - en.velocity*0.15  + '0 0 24';

	makevectors(self.angles);
	org = org + v_forward * -32;
	dir = normalize(dir - org);

	if (self.weapontype == 1)
		LaunchLaser (org, dir, v_right * crandom() * 35, v_up * crandom() * 20, 3);
	else if (self.weapontype == 3)
		monster_FireBullets (1, org, dir, '0.05 0.05 0', 2, 2, 1800);
	else
		monster_FireBullets (6, org, dir, '0.1 0.1 0', 5, 6, 7500);
};

void(float bool) soldier_Melee =
{
	float ldmg;

	ai_face();

	ldmg = 10 + 10*random();
	vector	aim;

	aim = setvector (100, 0, 0);
	if (fire_hit(aim, rint(ldmg), 10))
	{	
		if (bool == 1)
			sound(self, CHAN_WEAPON, "sounds_q4/strogg/stroggmarine/weapon_slap.wav", 1, ATTN_NORM);
		else
			sound(self, CHAN_WEAPON, "sounds_q4/strogg/stroggmarine/slash.wav", 1, ATTN_NORM);
	}
	else
	{
		meat_miss();

	}
};

void() soldier_flash = 
{   
	if (skill > 2)
		return;
	   
    vector org;

    org = self.pos2;

    pointparticles (particleeffectnum("TE_BOLT_IMPACT_RED"), org, '0 0 0', 4);
//	pointparticles (particleeffectnum("EF_MUZZLEFLASH2"), org, '0 0 0');
};

//===========================================================================
