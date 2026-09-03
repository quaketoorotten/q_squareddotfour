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

void() grunt_stand1 = [ 1, grunt_stand2 ] { ai_stand(); self.monster_frame = 0;};
void() grunt_stand2 = [ self.frame, grunt_stand2 ] 
{ 	
	self.monster_frame ++;
	if (self.monster_frame >= 61) 
	{	
		if (random() < 0.2)
			grunt_sfx_idle ();
		grunt_stand1 ();
		return;
	}
	ai_stand ();
};

void() grunt_walk1 = [ 2, grunt_walk2 ] { ai_walk(3); self.monster_frame = 0;};
void() grunt_walk2 = [ self.frame, grunt_walk2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 23) 
	{   
        if (random() < 0.2)
			grunt_sfx_idle2 ();
		grunt_walk1 ();
		return;
	}

	ai_walk (3);
};

void() grunt_run1 = [ 5, grunt_run2 ] { ai_run(self.speed); self.monster_frame = 0;};
void() grunt_run2 = [ self.frame, grunt_run2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 17) 
	{
		if (random() < 0.3)
			grunt_sfx_idle2 ();

		grunt_run1 ();
		return;
	}

    ai_run (self.speed);
};

void() grunt_strafel1 = [ 3, grunt_strafel2 ] 
{ 	ai_face();  self.nextthink = time + 0.04; self.monster_frame = 0;};
void() grunt_strafel2 = [ self.frame, grunt_strafel2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 13) 
	{	
		//self.attack_state = AS_STRAIGHT;
		self.flags &= ~FL_DODGED;
	//	despawn_shield ();
		grunt_run1 ();
		return;
	}

    if (self.monster_frame > 2) {
    	ai_charge(6);
    	M_walkmove (self.ideal_yaw + 90, 7);
    }

	self.nextthink = time + 0.04;
};

void() grunt_strafer1 = [ 4, grunt_strafer2 ] 
{ 	ai_face(); self.nextthink = time + 0.0; self.monster_frame = 0;};
void() grunt_strafer2 = [ self.frame, grunt_strafer2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 13) 
	{	
		//self.attack_state = AS_STRAIGHT;
		self.flags &= ~FL_DODGED;
	//	despawn_shield ();
		grunt_run1 ();
		return;
	}

	if (self.monster_frame > 2) {
    	ai_charge(6);
    	M_walkmove (self.ideal_yaw - 90, 7);
    }
	self.nextthink = time + 0.04;
};


void() grunt_strafe =
{	
	makevectors(self.angles);
	tracebox (self.origin, self.mins, self.maxs, self.origin + v_right * 128, FALSE, self);
	float right = trace_fraction;

	tracebox (self.origin, self.mins, self.maxs, self.origin + v_right * -128, FALSE, self);
	float left = trace_fraction;

	if (left == 1 && right == 1)
	{   
     //   grunt_sfx_growl ();
		if (random() <= 0.5)
			grunt_strafel1 ();
		else 
			grunt_strafer1 ();
		return;
	}

	if (left == 1)
		{grunt_strafel1 (); }
	else if (right == 1)
		{grunt_strafer1 (); }

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

static void(entity target, string name) grunt_tag_entity =
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

static void() grunt_tag_think =
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
	
	self.think = grunt_tag_think;
	self.angles = self.owner.angles;
	self.nextthink = time;
}

static void(string stringg, float fr, float end, string name, string tag) grunt_tag = 
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
		grunt_tag_entity(e, name);

	e.netname = tag;
	e.think = grunt_tag_think;
	e.nextthink = time;
}

// gatling
void() grunt_missilea1 = [ 18, grunt_missilea2 ] {
	self.monster_frame = 0;
	grunt_tag ("progs/monsters/grunt/fire_tag.md3", 18, 47, string_null, "Empty");
	//sound(self, CHAN_RELOAD, "sounds_q4/strogg/grunt/railgun_charge.wav", 1, ATTN_NORM);
	ai_face(); self.nextthink = time + 0.04; };
void() grunt_missilea2 = [ self.frame, grunt_missilea2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame < 40 && self.monster_frame > 11)
    	grunt_shoot();

    if (!visible(self.enemy)) 
	{	
		grunt_run1 ();
		return;
	}
	
	if (self.monster_frame >= 47) 
	{	
		grunt_strafe ();
		return;
	}

	if (self.monster_frame < 40)
		ai_face();
};

// jump
void() grunt_missileb1 = [ 13, grunt_missileb2 ] {
	self.monster_frame = 0;
//	grunt_tag ("progs/monsters/grunt/range_attack02_tag.md3", 7, 40, string_null, "tag_muzzle");
//	sound(self, CHAN_RELOAD, "sounds_q4/strogg/grunt/railgun_charge.wav", 1, ATTN_NORM);
	ai_charge(4); self.nextthink = time + 0.04; };
void() grunt_missileb2 = [ self.frame, grunt_missileb2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

//	if (self.monster_frame == 10 || self.monster_frame == 20 || self.monster_frame == 30)
//		grunt_shoot (600 + (random() + random() + random()*80));
	
	if (self.monster_frame >= 14) 
	{   
		grunt_jump1 ();	
		return;
	}

//	if (self.monster_frame < 10)
	ai_charge(4);
};

void() grunt_jump1 = [ self.frame, grunt_jump2 ] 
{ 
	ai_face();
	self.nextthink = time + 0.04;
	self.touch = grunt_JumpTouch;
	makevectors(self.angles);
	self.origin_z = self.origin_z + 1;
	self.velocity = v_forward * 600 + '0 0 250';
	if (self.flags & FL_ONGROUND)
		self.flags = self.flags - FL_ONGROUND;
	
	self.flags |= FL_LEAP;
    self.monster_frame ++;
};
void() grunt_jump2 = [ self.frame, grunt_jump2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 36)
		self.flags &= ~FL_LEAP;
	
	if (self.monster_frame >= 56) 
	{
		grunt_run1 ();
		return;
	}

    if (self.monster_frame > 36 && self.monster_frame < 45)
        ai_move (2);
    if (self.monster_frame > 45 && self.monster_frame < 53)
        ai_move (-3);
//	ai_face ();
};

//==============================================================================

void() grunt_meleea1 = [ 8, grunt_meleea2 ] {
	self.monster_frame = 0;
	grunt_tag ("progs/monsters/grunt/melee01_tag.md3", 8, 15, "TE_WHOOSH", "tag_whoosh");
	ai_face(); self.nextthink = time + 0.04;  };
void() grunt_meleea2 = [ self.frame, grunt_meleea2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 13)
		grunt_Melee();

	if (self.monster_frame >= 24) 
	{   
        grunt_strafe ();
		return;
	}

    if (self.monster_frame > 1 && self.monster_frame < 16)
		ai_charge (5);

	if (self.monster_frame > 16)
		ai_charge (3);
};

void() grunt_meleeb1 = [ 9, grunt_meleeb2 ] {
	self.monster_frame = 0;
    grunt_tag ("progs/monsters/grunt/melee02_tag.md3", 9, 16, "TE_WHOOSH", "tag_whoosh");
	ai_face(); self.nextthink = time + 0.04;  };
void() grunt_meleeb2 = [ self.frame, grunt_meleeb2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 12)
		grunt_Melee(18);

	if (self.monster_frame >= 20) 
	{   
        grunt_strafe ();
		return;
	}

    if (self.monster_frame > 2 && self.monster_frame < 14)
		ai_charge (5);

	if (self.monster_frame > 14)
		ai_charge (3);
};

void() grunt_meleec1 = [ 10, grunt_meleec2 ] {
	self.monster_frame = 0;
	grunt_tag ("progs/monsters/grunt/melee03_tag.md3", 10, 15, "TE_WHOOSH", "tag_whoosh");
	ai_face(); self.nextthink = time + 0.04;  };
void() grunt_meleec2 = [ self.frame, grunt_meleec2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 12)
		grunt_Melee(16);

	if (self.monster_frame >= 20) 
	{   
        grunt_strafe ();
		return;
	}

    if (self.monster_frame > 1 && self.monster_frame < 20)
		ai_charge (5);
};

void() grunt_meleed1 = [ 11, grunt_meleed2 ] {
	self.monster_frame = 0;
	grunt_tag ("progs/monsters/grunt/melee04_tag.md3", 11, 18, "TE_WHOOSH", "tag_whoosh");
	ai_face(); self.nextthink = time + 0.04;  };
void() grunt_meleed2 = [ self.frame, grunt_meleed2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 14)
		grunt_Melee(18);

	if (self.monster_frame >= 24) 
	{   
        grunt_strafe ();
		return;
	}

    ai_face ();
};

void() grunt_meleee1 = [ 12, grunt_meleee2 ] {
	self.monster_frame = 0;
	grunt_tag ("progs/monsters/grunt/melee05_tag.md3", 12, 15, "TE_WHOOSH", "tag_whoosh");
	ai_face(); self.nextthink = time + 0.04;  };
void() grunt_meleee2 = [ self.frame, grunt_meleee2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 12)
		grunt_Melee(18);

	if (self.monster_frame >= 20) 
	{   
        grunt_strafe ();
		return;
	}

    ai_face ();
};

void() grunt_meleef1 = [ 6, grunt_meleef2 ] {
	self.monster_frame = 0;
//	grunt_tag ("progs/monsters/grunt/melee_attack_tag.md3", 8, 15, "TE_WHOOSH", "Empty");
	ai_face(); self.nextthink = time + 0.04;  };
void() grunt_meleef2 = [ self.frame, grunt_meleef2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 14)
		grunt_Melee(30, 30);

	if (self.monster_frame >= 32) 
	{   
        grunt_run1 ();
		return;
	}

    ai_face ();
};

void() grunt_scream1 = [ 7, grunt_scream2 ] {
	self.monster_frame = 0;
//	grunt_tag ("progs/monsters/grunt/melee_attack_tag.md3", 8, 15, "TE_WHOOSH", "Empty");
	ai_face(); self.nextthink = time + 0.04;  };
void() grunt_scream2 = [ self.frame, grunt_scream2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 20)
		grunt_sfx_adren ();

	if (self.monster_frame >= 38) 
	{   
        self.speed = 8;
        grunt_run1 ();
		return;
	}

    ai_face ();
};

//==============================================================================

void() grunt_MeleeAttack =
{	
    float r = rint(random()*4);

    if (self.pissed > 1)
        self.pissed = 1;

    if (self.pissed > 0.3 && random() >= 0.4)
    {
        grunt_meleef1 ();
        grunt_sfx_rush ();
        return;
    }

    if (r == 1) {
        grunt_meleea1 (); grunt_sfx_rush(); }
    else if (r == 2) {
        grunt_meleeb1 (); grunt_sfx_rush(); }
    else if (r == 3) {
        grunt_meleec1 (); grunt_sfx_rush(); }
    else if (r == 4) {
        grunt_meleed1 (); grunt_sfx_rush(); }
    else {
        grunt_meleee1 (); grunt_sfx_rush(); }
};

void() grunt_MissileAttack =
{   
    if (self.pissed > 1)
        self.pissed = 1;

    if (self.speed > 7 && CheckGruntJump())
    {   
        sound(self, CHAN_VOICE, "sounds_q4/strogg/grunt/jump.wav", 1, ATTN_NORM);
        grunt_missileb1 ();        
        return;
    }

    if (self.speed < 8 && self.weapontype == 3)
    {   
        setmodel(self, "progs/monsters/grunt/grunt2.md5.info");
	    setsize(self, '-16 -16 0', '16 16 64');

        grunt_scream1 ();
        grunt_sfx_scream ();
        return;
    }
    
    if (self.pissed > 0.6 && self.speed < 8 && self.weapontype == 2)
    {   
        setmodel(self, "progs/monsters/grunt/grunt2.md5.info");
	    setsize(self, '-16 -16 0', '16 16 64');

        grunt_scream1 ();
        grunt_sfx_scream ();
        return;
    }

    if (random() > 0.7)
    {   
        grunt_sfx_growl ();
        grunt_missilea1 ();
        return;
    }

//    if (random() <= 0.7)
//		grunt_missileb1();
//	else 
//		grunt_missilea1();

};

//==============================================================================

// regular ow
void() grunt_paina1 = [ 14, grunt_paina2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() grunt_paina2 = [ self.frame, grunt_paina2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint("????", "\n");
	if (self.monster_frame >= 11) 
	{
		grunt_run1 ();
		return;
	}
};

void() grunt_painb1 = [ 15, grunt_painb2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() grunt_painb2 = [ self.frame, grunt_painb2 ] 
{   
    //bprint(ftos(self.frame), "\n");
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint(">>>>>>>>>>?????", "\n");
	if (self.monster_frame >= 11) 
	{
		grunt_run1 ();
		return;
	}
};

// concussion
void() grunt_painc1 = [ 16, grunt_painc2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() grunt_painc2 = [ self.frame, grunt_painc2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

    if (self.monster_frame > 0 && self.monster_frame < 20)
        ai_move (-3);

    if (self.monster_frame > 20 && self.monster_frame < 25)
        ai_move(2);

	// bprint("????", "\n");
	if (self.monster_frame >= 29) 
	{   
		grunt_run1 ();
		return;
	}
};

void() grunt_paind1 = [ 17, grunt_paind2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() grunt_paind2 = [ self.frame, grunt_paind2 ] 
{   
    //bprint(ftos(self.frame), "\n");
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint(">>>>>>>>>>?????", "\n");

    if (self.monster_frame > 3 && self.monster_frame < 21)
        ai_move (-3);

    if (self.monster_frame > 21 && self.monster_frame < 29)
        ai_move(2);

	if (self.monster_frame >= 30) 
	{   
		grunt_run1 ();
		return;
	}
};

void(entity attacker, float damage, float MOD) grunt_pain =
{
	if (self.touch == grunt_JumpTouch)
		return;
//	bprint(ftos(MOD), "\n");
	if (self.flags & FL_DODGED)
	{	
		return;
	}

	if (self.flags & FL_LEAP)
	{	
		return;
	}
	

	if (self.pain_finished > time)
		return;

	self.pain_finished = time + 2;
	grunt_sfx_pain (); // sfx

	if (DMGTYPE_LTNG == MOD)
	{
  	  if (random() <= 0.5)
	        grunt_paina1 ();
 	   else
  	      	grunt_painb1 ();
		
		if (skill < 2)
			self.pain_finished = time + 0.5;
		else
			self.pain_finished = time + 1.5;
		return;
	}

	if (MOD == DMGTYPE_RAIL)
	{   
         if (random() <= 0.5)
            grunt_painc1 ();
        else
            grunt_paind1 ();

		self.pain_finished = time + 2.5;
		return;
	}

	if (random()*200 > damage)
		return; // didn't flinch

	if (damage > 50 || MOD == DMGTYPE_EXP)
	{   
         if (random() <= 0.5)
            grunt_painc1 ();
        else
            grunt_paind1 ();
		return;
	}

    if (random() <= 0.5)
        grunt_paina1 ();
    else
        grunt_painb1 ();
};

void() grunt_die =
{	
	////setmodel(self, "progs/monsters/grunt/grunt_mesh_death.iqm");
	//setsize(self, '-32 -32 0', '32 32 64');
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

	grunt_sfx_death ();

	local vector tmpangle;
	local float tempskin;
	tmpangle = self.angles;
	tempskin = self.skin;
	
	if (random() <= 0.5)
		self.think = grunt_die1;
	else
		self.think = grunt_dieb1;

	self.deadflag = DEAD_DEAD;
	self.solid = SOLID_CORPSE;
//	self.movetype = MOVETYPE_STEP;
	self.nextthink = time + 0.04;

	self.angles = tmpangle;
	//self.skin = tempskin;
};

void() grunt_die1 = [ 20 , grunt_die2 ] { self.nextthink = time + 0.04; self.monster_frame = 0;};
void() grunt_die2 = [ self.frame , grunt_die2 ] 
{ 	
	//self.frame |= 0x8000;
	self.nextthink = time + 0.04;

	if (self.monster_frame < 13)
		ai_move (-4.5);

	self.monster_frame ++;
	if (self.monster_frame == 25)
	{
		self.maxs_z = 12;
		self.nextthink = -1;
		self.think = grunt_fade1;
		self.nextthink = time + 3.5;
		self.cnt = 1;
		return;
	}
};

void() grunt_dieb1 = [ 21 , grunt_dieb2 ] { self.nextthink = time + 0.04; self.monster_frame = 0;};
void() grunt_dieb2 = [ self.frame , grunt_dieb2 ] 
{ 	
	//self.frame |= 0x8000;
	self.nextthink = time + 0.04;

	if (self.monster_frame < 16)
		ai_move (-4.5);
	
	self.monster_frame ++;
	if (self.monster_frame == 25)
	{
		self.maxs_z = 12;
		self.nextthink = -1;
		self.think = grunt_fade1;
		self.nextthink = time + 3.5;
		return;
	}
};


void() grunt_fade1 = [ self.frame, grunt_gib2 ] 
{
	if (self.cnt == 1)
		self.frame = 0;
	else
		self.frame = 1;
	
	setmodel(self, "progs/monsters/grunt/grunt_death.iqm");
	setsize(self, '-16 -16 0', '16 16 12');

//	self.skin = 1; 
	self.alpha = 1; 
	self.glowmod = '0.5 0.5 0.5'; 
	self.nextthink = time + 0.02;
}

void() grunt_gib1 = [ self.frame, grunt_gib2 ] 
{MonsterGib (self.health); self.skin = 1; self.alpha = 1; self.nextthink = time + 0.02;};

void() grunt_gib2 = [ self.frame, grunt_gib2 ] 
{ 	
	self.nextthink = time + 0.02;
	self.alpha -= 0.02;
	if (self.alpha <= 0)
	{
		remove(self);
		return;
	}
};

static void() grunt_sfx_scream =
{
	local float r = rint(random() * 2);	

	if (r == 2)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/grunt/anger1.wav", 1, ATTN_NORM);
	else if (r == 1)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/grunt/anger2.wav", 1, ATTN_NORM);
	else 
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/grunt/anger3.wav", 1, ATTN_NORM);
};


static void() grunt_sfx_death =
{
	 if (random() <= 0.5)
	    sound(self, CHAN_VOICE, "sounds_q4/strogg/grunt/die01.wav", 1, ATTN_NORM);
    else
        sound(self, CHAN_VOICE, "sounds_q4/strogg/grunt/die02.wav", 1, ATTN_NORM);
};

static void() grunt_sfx_idle =
{
	local float r = rint(random() * 3);	

	if (r == 3)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/grunt/breath01.wav", 1, ATTN_IDLE);
	else if (r == 2)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/grunt/breath02.wav", 1, ATTN_IDLE);
    else if (r == 1)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/grunt/breath03.wav", 1, ATTN_IDLE);
	else 
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/grunt/breath04.wav", 1, ATTN_IDLE);
};

static void() grunt_sfx_idle2 =
{
	local float r = rint(random() * 2);	

	if (r == 2)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/grunt/chatter_idle1.wav", 1, ATTN_IDLE);
	else if (r == 1)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/grunt/chatter_idle2.wav", 1, ATTN_IDLE);
    else 
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/grunt/chatter_idle3.wav", 1, ATTN_IDLE);
};

static void() grunt_sfx_rush =
{
    if (random() <= 0.5)
	    sound(self, CHAN_VOICE, "sounds_q4/strogg/grunt/rush1.wav", 1, ATTN_NORM);
    else
        sound(self, CHAN_VOICE, "sounds_q4/strogg/grunt/rush2.wav", 1, ATTN_NORM);
};

static void() grunt_sfx_growl =
{
    if (random() <= 0.5)
	    sound(self, CHAN_VOICE, "sounds_q4/strogg/grunt/growl01.wav", 1, ATTN_NORM);
    else
        sound(self, CHAN_VOICE, "sounds_q4/strogg/grunt/growl02.wav", 1, ATTN_NORM);
};

static void() grunt_sfx_adren =
{
    if (random() <= 0.5)
	    sound(self, CHAN_RELOAD, "sounds_q4/strogg/grunt/adren.wav", 1, ATTN_NORM);
    else
        sound(self, CHAN_RELOAD, "sounds_q4/strogg/grunt/adren2.wav", 1, ATTN_NORM);
};

static void() grunt_sfx_pain =
{
	local float r = rint(random() * 3);	

	if (r == 3)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/grunt/pain1.wav", 1, ATTN_NORM);
	else if (r == 2)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/grunt/pain2.wav", 1, ATTN_NORM);
    else if (r == 1)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/grunt/pain3.wav", 1, ATTN_NORM);
	else 
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/grunt/pain4.wav", 1, ATTN_NORM);
};

static void() grunt_sfx_sight =
{   
    if (random() <= 0.5)
	    sound(self, CHAN_VOICE, "sounds_q4/strogg/grunt/sight1.wav", 1, ATTN_NORM);
    else
        sound(self, CHAN_VOICE, "sounds_q4/strogg/grunt/sight2.wav", 1, ATTN_NORM);
};

/*QUAKED monster_demon (1 0 0) (-32 -32 -24) (32 32 64) Ambush

*/
void() monster_grunt_cache =
{
	precache_model("progs/monsters/grunt/grunt.md5.info");
    precache_model("progs/monsters/grunt/grunt2.md5.info");
    precache_model("progs/monsters/grunt/fire_tag.md3");
    precache_model("progs/monsters/grunt/grunt_death.iqm");

    precache_model("progs/monsters/grunt/melee01_tag.md3");
    precache_model("progs/monsters/grunt/melee02_tag.md3");
    precache_model("progs/monsters/grunt/melee03_tag.md3");
    precache_model("progs/monsters/grunt/melee04_tag.md3");
    precache_model("progs/monsters/grunt/melee05_tag.md3");
//    precache_model("progs/monsters/grunt/grunt_shield_mesh.md5.info");

	precache_sound("sounds_q4/strogg/grunt/sight1.wav");
    precache_sound("sounds_q4/strogg/grunt/sight2.wav");
	precache_sound("sounds_q4/strogg/grunt/breath01.wav");
	precache_sound("sounds_q4/strogg/grunt/breath02.wav");
	precache_sound("sounds_q4/strogg/grunt/breath03.wav");
    precache_sound("sounds_q4/strogg/grunt/breath04.wav");
	
	precache_sound("sounds_q4/strogg/grunt/growl01.wav");
	precache_sound("sounds_q4/strogg/grunt/growl02.wav");
    precache_sound("sounds_q4/strogg/grunt/jump.wav");

	precache_sound("sounds_q4/strogg/grunt/die01.wav");
	precache_sound("sounds_q4/strogg/grunt/die02.wav");	

	precache_sound("sounds_q4/strogg/grunt/pain1.wav");
	precache_sound("sounds_q4/strogg/grunt/pain2.wav");
	precache_sound("sounds_q4/strogg/grunt/pain3.wav");
    precache_sound("sounds_q4/strogg/grunt/pain4.wav");

    precache_sound("sounds_q4/strogg/grunt/anger1.wav");
    precache_sound("sounds_q4/strogg/grunt/anger2.wav");
    precache_sound("sounds_q4/strogg/grunt/anger3.wav");

    precache_sound("sounds_q4/strogg/grunt/chatter_idle1.wav");
    precache_sound("sounds_q4/strogg/grunt/chatter_idle2.wav");
    precache_sound("sounds_q4/strogg/grunt/chatter_idle3.wav");

    precache_sound("sounds_q4/strogg/grunt/rush1.wav");
    precache_sound("sounds_q4/strogg/grunt/rush2.wav");

    precache_sound("sounds_q4/strogg/grunt/adren.wav");
    precache_sound("sounds_q4/strogg/grunt/adren2.wav");

    precache_sound("sounds_q4/strogg/grunt/gatling01.wav");
    precache_sound("sounds_q4/strogg/grunt/gatling02.wav");
    precache_sound("sounds_q4/strogg/grunt/gatling03.wav");

//	spawn_demon ();
};

void() monster_grunt =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	monster_grunt_cache ();	
	spawn_grunt ();
};

void() monster_infantry =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	monster_grunt_cache ();	
	spawn_grunt ();
};

void() spawn_grunt =
{
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	self.classname = "monster_grunt";
	setmodel(self, "progs/monsters/grunt/grunt.md5.info");

	setsize(self, '-16 -16 0', '16 16 64');
	self.health = 300;
	self.max_health = 300;
	self.mass = 300;
	self.scale = 0.8;

	self.th_stand = grunt_stand1;
	self.th_walk = grunt_walk1;
	self.th_run = grunt_run1;
	self.th_die = grunt_die;
	self.th_melee = grunt_MeleeAttack; // one of two attacks
	self.th_missile = grunt_MissileAttack; // jump attack
	self.th_pain = grunt_pain;
	//self.th_checkatck = GladCheckAttack;
	self.th_spawn = spawn_grunt;
//	self.th_dodge = grunt_strafe;
	self.th_sight = grunt_sfx_sight;
	//setcustomskin (self, "progs/monsters/grunt/gladiator.skin")
	self.deathtype = "was mauled and clobbered by a Grunt";
	self.count = 0;
	self.pissed = 0;
    self.speed = 7;

    float r = rint(random()*3);
    self.weapontype = r;

    if (r == 0)
        self.weapontype = 1;

	if ((self.flags & FL_RESURRECTED))
		self.weapontype = 1;

	walkmonster_start();
};


/*
==============================================================================

DEMON

==============================================================================
*/



void() grunt_shoot = 
{   
	float r = rint(random()*2);

    if (self.dspeed > time)
        return;

    vector dir, org;
	entity en;

    if (r==2)
        sound(self, CHAN_WEAPON, "sounds_q4/strogg/grunt/gatling01.wav", 1, ATTN_NORM);
    else if (r==1)
        sound(self, CHAN_WEAPON, "sounds_q4/strogg/grunt/gatling02.wav", 1, ATTN_NORM);
    else
        sound(self, CHAN_WEAPON, "sounds_q4/strogg/grunt/gatling03.wav", 1, ATTN_NORM);

// fire somewhat behind the player, so a dodging player is harder to hit
	en = self.enemy;
	org = self.pos2;
	
	makevectors(self.angles);
	pointparticles (particleeffectnum("TE_MUZZLEFLASH2"), org + v_forward * 24, '0 0 0');
	pointparticles (particleeffectnum("EF_MUZZLEFLASH2"), org, '0 0 0');

	dir = en.origin - en.velocity*0.15  + '0 0 24';
	dir = normalize(dir - org);

	monster_FireBullets (1, org, dir, '0.05 0.05 0', 4, 2, 2000);
    self.dspeed = time + 0.1;
};

void(float base = 15, float kick = 10, float range = 100) grunt_Melee =
{
	float ldmg;

	ai_face();

	ldmg = base + 10*random();
	if (self.pissed > 0.4)
		ldmg *= (1 + self.pissed - 0.3);

	vector	aim;

	aim = setvector (100, 0, 0);
	if (fire_hit(aim, rint(ldmg), kick))
	{	
		meat_hit (); 

		if (self.pissed > 0)
			self.pissed -= 0.1;
	}
	else
	{
		meat_miss();

		if (!(self.flags & FL_RESURRECTED))
			self.pissed += 0.3; 
	}
};

void() grunt_flash = 
{   
   
    vector org;

    org = self.pos2;

    pointparticles (particleeffectnum("TE_MUZZLEFLASH2"), org, '0 0 0');
	pointparticles (particleeffectnum("EF_MUZZLEFLASH2"), org, '0 0 0');
};

static float() CheckGruntJump =
{
	vector dist;
	float d;

	vector org = self.origin + '0 0 24';
	vector enemy_org = self.enemy.origin + '0 0 24';

	if (org_z + self.mins_z > enemy_org_z + self.enemy.mins_z
	+ 0.75 * self.enemy.size_z)
		return FALSE;

	if (org_z + self.maxs_z < enemy_org_z + self.enemy.mins_z
	+ 0.25 * self.enemy.size_z)
		return FALSE;

	dist = self.enemy.origin - self.origin;
	dist_z = 0;
	
	d = vlen(dist);
	
	if (d < 100)
		return FALSE;
		
	if (d > 100)
	{
		if (random() < 0.6)
			return FALSE;
	}

	return TRUE;
};



void()	grunt_JumpTouch =
{
	local	float	ldmg;

	if (self.health <= 0)
		return;
	
	self.dmgtime = time + 0.6;
	if (other.takedamage && self.dmgtime > time && other == self.enemy)
	{
		if ( vlen(self.velocity) > 400 )
		{
			ldmg = 30 + 10*random();
			T_Damage (other, self, self.origin, self, ldmg, 50);	

			SpawnBlood (other, other.origin - normalize(self.velocity) * 16, '0 0 0', ldmg);
		}
	}

	if (!checkbottom(self))
	{
		/*if (self.flags & FL_ONGROUND)
		{	// jump randomly to not get hung up
//dprint ("popjump\n");
	self.touch = SUB_Null;
	self.think = demon1_jump1;
	self.nextthink = time + 0.1;

//			self.velocity_x = (random() - 0.5) * 600;
//			self.velocity_y = (random() - 0.5) * 600;
//			self.velocity_z = 200;
//			self.flags = self.flags - FL_ONGROUND;
		}*/
		return;	// not on ground yet
	}

	self.touch = SUB_Null;
	self.flags = self.flags - (self.flags & FL_LEAP);
};

//===========================================================================
