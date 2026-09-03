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

void() hovertank_stand1 = [ 1, hovertank_stand2 ] { ai_stand(); self.monster_frame = 0;};
void() hovertank_stand2 = [ self.frame, hovertank_stand2 ] 
{ 	
	self.monster_frame ++;
	if (self.monster_frame >= 52) 
	{	
        if (random() < 0.2)
	    	hovertank_sfx_idle ();
		hovertank_sfx_idle2 ();
		hovertank_stand1 ();
		return;
	}
	ai_stand ();
};

void() hovertank_walk1 = [ 1, hovertank_walk2 ] { ai_walk(3); self.monster_frame = 0;};
void() hovertank_walk2 = [ self.frame, hovertank_walk2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 52) 
	{
        if (random() < 0.2)
	    	hovertank_sfx_idle ();
	    hovertank_sfx_idle2 ();
		hovertank_walk1 ();
		return;
	}
	ai_walk (3);
};

void() hovertank_run1 = [ 1, hovertank_run2 ] { ai_run(self.speed); self.monster_frame = 0;};
void() hovertank_run2 = [ self.frame, hovertank_run2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 52) 
	{
      if (random() < 0.2)
	    	hovertank_sfx_idle ();
		
	    hovertank_sfx_idle2 ();
		hovertank_run1 ();
		return;
	}
	ai_run (self.speed);
};

//==============================================================================

void() hovertank_strafel1 = [ 7, hovertank_strafel2 ] 
{ 	ai_flybob_face();  self.nextthink = time + 0.04; self.monster_frame = 0;};
void() hovertank_strafel2 = [ self.frame, hovertank_strafel2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 25) 
	{	
		//self.attack_state = AS_STRAIGHT;
		self.flags &= ~FL_DODGED;
	//	despawn_shield ();
		hovertank_run1 ();
		sound(self, CHAN_VOICE, "sounds_q4/strogg/hovertank/strafe.wav", 1, ATTN_NORM);
		return;
	}

    M_walkmove (self.ideal_yaw + 90, 6);

	self.nextthink = time + 0.04;
};

void() hovertank_strafer1 = [ 6, hovertank_strafer2 ] 
{ 	ai_flybob_face(); self.nextthink = time + 0.0; self.monster_frame = 0;};
void() hovertank_strafer2 = [ self.frame, hovertank_strafer2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 22) 
	{	
		//self.attack_state = AS_STRAIGHT;
		self.flags &= ~FL_DODGED;
	//	despawn_shield ();
		hovertank_run1 ();
		sound(self, CHAN_VOICE, "sounds_q4/strogg/hovertank/strafe.wav", 1, ATTN_NORM);
		return;
	}

    M_walkmove (self.ideal_yaw - 90, 6);
    
	self.nextthink = time + 0.04;
};


void() hovertank_strafe =
{	
	makevectors(self.angles);
	tracebox (self.origin, self.mins, self.maxs, self.origin + v_right * 128, FALSE, self);
	float right = trace_fraction;

	tracebox (self.origin, self.mins, self.maxs, self.origin + v_right * -128, FALSE, self);
	float left = trace_fraction;

	if (left == 1 && right == 1)
	{   
     //   hovertank_sfx_growl ();
		if (random() <= 0.5)
			hovertank_strafel1 ();
		else 
			hovertank_strafer1 ();

		hovertank_sfx_idle2 ();
		return;
	}

	if (left == 1)
		{hovertank_strafel1 (); hovertank_sfx_idle2 ();}
	else if (right == 1)
		{hovertank_strafer1 (); hovertank_sfx_idle2 ();}

	if (left < 1 || right < 1)
	{	
		self.aiflags &= ~AI_AIMFLY;
        if (self.flags & FL_DODGED)
		    self.flags &= ~FL_DODGED;
        else
            self.th_run ();
		return;
	}
	
	self.nextthink = time;
};

//==============================================================================

// homing missile
void() hovertank_missilea1_0 = [ 3, hovertank_missilea2_0 ] 
{	  
	//self.flags |= FL_DODGED;
    self.aiflags |= AI_AIMFLY;
    self.monster_frame = 0; self.count =0;
    ai_flybob_face(); self.nextthink = time + 0.04;  };
void() hovertank_missilea2_0 = [ self.frame, hovertank_missilea2_0 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	hovertank_sfx_idle2 ();

	if (self.monster_frame == 24)
		sound(self, CHAN_WEAPON, "sounds_q4/strogg/hovertank/rocket_stow.wav", 1, ATTN_NORM);

	if (self.monster_frame >= 36) 
	{	   
   //     bprint("aiming", "\n");
		hovertank_missilea1_1a ();
		return;
	}

    ai_flybob_face ();
};

void() hovertank_missilea1_1a = [ 2, hovertank_missilea2_1a ] 
{	self.monster_frame = 0; 
    ai_run(3); self.nextthink = time + 0.04;  };
void() hovertank_missilea2_1a = [ self.frame, hovertank_missilea2_1a ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
    self.count += 0.5;
	
	hovertank_sfx_idle2 ();

    if ((self.count >= 39))
    {   
        self.aiflags &= ~AI_AIMFLY;
        hovertank_missilea1_2 ();
        return;
    }

	if ((self.monster_frame >= 39))
	{	
		hovertank_missilea1_1a ();
		return;
	}

    ai_run (3);
};

void() hovertank_missilea1_1b = [ 5, hovertank_missilea2_1b ] 
{	self.monster_frame = 0; 
    self.aiflags &= ~AI_AIMFLY;

	sound(self, CHAN_WEAPON, "sounds_q4/strogg/hovertank/rocket_ready.wav", 1, ATTN_NORM);
	hovertank_tag ("progs/monsters/heavyhovertank/big_guntag.md3", 5, 58, string_null, "Empty");
    ai_flybob_face (); self.nextthink = time + 0.02;  };
void() hovertank_missilea2_1b = [ self.frame, hovertank_missilea2_1b ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.02;

    if (self.monster_frame == 57)
    {   
    //    self.pos2 = self.origin + '0 0 64';
        hovertank_shoot ();
        
    }

	hovertank_sfx_idle2 ();

    if (self.monster_frame == 40)
    {
        hovertank_flash2 ();
        
    }

	if ((self.monster_frame >= 101))
	{	
		hovertank_missilea1_2 ();
		return;
	}

    if (self.monster_frame < 60)
        ai_flybob_face ();
    if (self.monster_frame > 60 && self.monster_frame < 95)
        ai_move(-4);
};

void() hovertank_missilea1_2 = [ 4, hovertank_missilea2_2 ] 
{	self.monster_frame = 0; self.count =0;
ai_flybob_face(); self.nextthink = time + 0.04;  };
void() hovertank_missilea2_2 = [ self.frame, hovertank_missilea2_2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	hovertank_sfx_idle2 ();

	if (self.monster_frame >= 36) 
	{	
       // self.aiflags |= AI_AIMFLY;
		hovertank_run1 ();
		return;
	}

    ai_flybob_face ();
};

void() hovertank_missileb1_0 = [ self.frame, hovertank_missileb2_0 ] 
{	
	self.flags |= FL_DODGED;   
    self.monster_frame = 0; self.count = 0;
    ai_flybob_face(); self.nextthink = time + 0.04;  };
void() hovertank_missileb2_0 = [ self.frame, hovertank_missileb2_0 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	hovertank_sfx_idle2 ();

	if (self.monster_frame >= 23) 
	{	   
   //     bprint("aiming", "\n");
		self.frame ++;
		hovertank_missileb1_1 ();
		return;
	}

    ai_flybob_face ();
};

void() hovertank_missileb1_1 = [ self.frame, hovertank_missileb2_1 ] 
{	   
    self.monster_frame = 0; self.count = 0;

	string mdl;
	if (self.frame == 9)
		mdl = "progs/monsters/heavyhovertank/mgun1_tag.md3";
	else
		mdl = "progs/monsters/heavyhovertank/mgun2_tag.md3";

	hovertank_tag (mdl, self.frame, 999, string_null, "Empty");
	
    ai_flybob_face(); self.nextthink = time + 0.04;  };
void() hovertank_missileb2_1 = [ self.frame, hovertank_missileb2_1 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	hovertank_sfx_idle2 ();

	if (self.monster_frame == 1)
	{
		hovertank_shoot2 ();
		self.count ++;
	}	

    if (self.monster_frame >= 3)
        self.monster_frame = 0;

	if (!visible(self.enemy)) 
	{   
        self.count = 0;
		if (random() <= 0.4)
			hovertank_strafe ();
		else
		{
			self.frame ++; 
			hovertank_missileb1_2 ();
		}
		self.flags &= ~FL_DODGED;
		return;
	}
	
	if (self.count >= 10) 
	{   
		self.frame ++;
		hovertank_missileb1_2 ();
		self.flags &= ~FL_DODGED;
		return;
	}

    ai_flybob_face ();
};

void() hovertank_missileb1_2 = [ self.frame, hovertank_missileb2_2 ] 
{	   
    self.monster_frame = 0; self.count = 0;
    ai_flybob_face(); self.nextthink = time + 0.04;  };
void() hovertank_missileb2_2 = [ self.frame, hovertank_missileb2_2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	hovertank_sfx_idle2 ();

	if (self.monster_frame >= 23) 
	{	   
   //     bprint("aiming", "\n");
	//	self.frame ++;
		if (random() <= 0.4)
			hovertank_strafe ();
		else
			hovertank_run1 ();
		return;
	}

    ai_flybob_face ();
};

//==================================================================================

static void(entity target, string name) hovertank_tag_entity =
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

static void() hovertank_tag_think =
{	
	self.frame = self.owner.monster_frame;
	if (self.frame >= self.dspeed || self.owner.frame != self.ltime )
	{	
		if (self.prelock_save)
			remove(self.prelock_save);

		remove(self);
		return;
	}

	setorigin(self, self.owner.origin );
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
	
	self.think = hovertank_tag_think;
	self.angles = self.owner.angles;
	self.nextthink = time;
}

static void(string stringg, float fr, float end, string name, string tag) hovertank_tag = 
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
		hovertank_tag_entity(e, name);

	e.netname = tag;
	e.think = hovertank_tag_think;
	e.nextthink = time;
	self.prelock_save = e;
}

void() hovertank_meleea1 = [ 17, hovertank_meleea2 ] 
{	self.monster_frame = 0; self.count =0;
	hovertank_tag ("progs/monsters/heavyhovertank/melee_tag.md3", 17, 20, "TE_WHOOSH", "Empty");
ai_flybob_face(); self.nextthink = time + 0.04;  };
void() hovertank_meleea2 = [ self.frame, hovertank_meleea2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 20) 
	{
		hovertank_Melee ();
	}
	
	if (self.monster_frame >= 36) 
	{	
		hovertank_strafe ();
		return;
	}
	ai_flybob_face ();
};

void() hovertank_meleeb1 = [ 18, hovertank_meleeb2 ] 
{	self.monster_frame = 0; self.count =0;
	hovertank_tag ("progs/monsters/heavyhovertank/melee2_tag.md3", 18, 26, "TE_WHOOSH", "Empty");
ai_flybob_face(); self.nextthink = time + 0.04;  };
void() hovertank_meleeb2 = [ self.frame, hovertank_meleeb2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 17) 
	{
		hovertank_Melee ();
	}
	
	if (self.monster_frame >= 39) 
	{	
		hovertank_strafe ();
		return;
	}   
	ai_flybob_face ();
};

//==============================================================================
void() hovertank_MeleeAttack = 
{	
	self.aiflags &= ~AI_AIMFLY;
	if (random() <= 0.5)
		hovertank_meleea1 ();
	else
		hovertank_meleeb1 ();
}


void() hovertank_MissileAttack =
{
	//heavyhovertank_sfx_attack ();

    if (self.aiflags & AI_AIMFLY)
    {
        hovertank_missilea1_1b ();
        return;
    }

	if (random() <= 0.4)
		hovertank_missilea1_0 ();
	else
	{
		if (random() <= 0.5)
			self.frame = 8;
		else
			self.frame = 11;

		hovertank_missileb1_0 ();
	}
};

//==============================================================================


// regular ow
void() hovertank_paina1 = [ 14, hovertank_paina2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() hovertank_paina2 = [ self.frame, hovertank_paina2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint("????", "\n");
	if (self.monster_frame >= 14) 
	{
		hovertank_run1 ();
		return;
	}
};

void() hovertank_painb1 = [ 15, hovertank_painb2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() hovertank_painb2 = [ self.frame, hovertank_painb2 ] 
{   
    //bprint(ftos(self.frame), "\n");
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint(">>>>>>>>>>?????", "\n");
	if (self.monster_frame >= 14) 
	{
		hovertank_run1 ();
		return;
	}
};

// concussion
void() hovertank_painc1 = [ 16, hovertank_painc2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() hovertank_painc2 = [ self.frame, hovertank_painc2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint("????", "\n");
	if (self.monster_frame >= 24) 
	{   
		hovertank_strafe ();
		return;
	}
};


void(entity attacker, float damage, float MOD) hovertank_pain =
{
//	if (self.touch == hovertank_JumpTouch)
//		return;
//	bprint(ftos(MOD), "\n");
	if (self.flags & FL_DODGED)
	{	
		return;
	}

	if (self.pain_finished > time)
		return;

	self.aiflags &= ~AI_AIMFLY;
	self.pain_finished = time + 2;
	hovertank_sfx_pain (); // sfx

    if (MOD == DMGTYPE_RAIL && random() >= 0.6)
	{   
        hovertank_painc1 ();

		self.pain_finished = time + 2.5;
		return;
	}

	if (random()*500 > damage)
		return; // didn't flinch

	if (damage > 100 || MOD == DMGTYPE_EXP)
	{   
        hovertank_painc1 ();
		return;
	}

    if (random() <= 0.5)
        hovertank_paina1 ();
    else
        hovertank_painb1 ();
};

//==============================================================================

void() hovertank_die =
{	
	if (self.health < -500)
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

	setsize(self, '-32 -32 16', '32 32 78');

	local vector tmpangle;
	local float tempskin;
	tmpangle = self.angles;
	tempskin = self.skin;

	float r = rint(random()*2);
	
	if (r == 1)
		self.think = hovertank_diea1;
	else if (r == 2)
		self.think = hovertank_dieb1;
	else
		self.think = hovertank_diec1;

	
	self.monster_frame = 0;

	hovertank_sfx_pain ();
	self.deadflag = DEAD_DEAD;
	self.solid = SOLID_CORPSE;
//	self.movetype = MOVETYPE_STEP;
	self.nextthink = time + 0.04;

	self.angles = tmpangle;
	self.nextthink2 = 0;
};

void() hovertank_diea1 = [ 19 , hovertank_diea1 ] 
{ 	
	if ((checkbottom(self) && self.monster_frame == 12) || (self.nextthink2 > 10))
	{	
	//	self.cnt = 1;
		self.think = hovertank_diea2;
		self.nextthink = time + 0.04;
		return;
	}
	else 
	{
		self.nextthink2 ++;
	}

	if (self.monster_frame < 12)
	{
		ai_move (-5);
		self.monster_frame++;
	}	

	self.dspeed += 1;
	self.nextthink = time + 0.04; 
};

void() hovertank_diea2 = [ 20 , hovertank_diea2 ] 
{ 	
	//self.frame |= 0x8000;
	self.nextthink = time + 0.04;
	self.monster_frame ++;
	if (self.monster_frame >= 13)
	{
		self.maxs_z = 32;
		self.nextthink = -1;
		self.think = hovertank_fade1;
		self.nextthink = time + 3.5;
		self.count = 0;
		return;
	}
};

void() hovertank_dieb1 = [ 21 , hovertank_dieb1 ] 
{ 	
	if ((checkbottom(self) && self.monster_frame == 5) || (self.nextthink2 > 10))
	{	
	//	self.cnt = 1;
		self.think = hovertank_dieb2;
		self.nextthink = time + 0.04;
		return;
	}
	else
	{
		self.nextthink2 ++;
	}

	if (self.monster_frame < 5)
	{
		ai_move (5);
		self.monster_frame++;
	}	

	self.dspeed += 1;
	self.nextthink = time + 0.04; 
};

void() hovertank_dieb2 = [ 22 , hovertank_dieb2 ] 
{ 	
	//self.frame |= 0x8000;
	self.nextthink = time + 0.04;
	self.monster_frame ++;
	if (self.monster_frame >= 11)
	{
		self.maxs_z = 32;
		self.nextthink = -1;
		self.think = hovertank_fade1;
		self.nextthink = time + 3.5;
		self.count = 1;
		return;
	}
};

void() hovertank_diec1 = [ 23 , hovertank_diec1 ] 
{ 	
	if ((checkbottom(self) && self.monster_frame == 7) || (self.nextthink2 > 10))
	{	
	//	self.cnt = 1;
		self.think = hovertank_diec2;
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

void() hovertank_diec2 = [ 24 , hovertank_diec2 ] 
{ 	
	//self.frame |= 0x8000;
	self.nextthink = time + 0.04;
	self.monster_frame ++;
	if (self.monster_frame >= 12)
	{
		self.maxs_z = 32;
		
		self.nextthink = -1;
		self.think = hovertank_fade1;
		self.nextthink = time + 3.5;
		self.count = 2;
		return;
	}
};

void() hovertank_fade1 = [ 0, hovertank_gib2 ] 
{	
	setmodel(self, "progs/monsters/heavyhovertank/hovertank_death.iqm");
	setsize(self, '-32 -32 16', '32 32 16');

	self.skin = 1; 
	self.alpha = 1; 
	self.frame = self.count;
	self.glowmod = '0.5 0.5 0.5'; 
	self.nextthink = time + 0.02;
};

void() hovertank_gib2 = [ self.frame, hovertank_gib2 ] 
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


static void() hovertank_sfx_idle2 =
{	
	if (self.t_width < time)
		sound(self, CHAN_BODY, "sounds_q4/strogg/hovertank/hover_loop.wav", 1, ATTN_IDLE);
	self.t_width = time + 0.4;
};


static void() hovertank_sfx_idle =
{	
	if (random() <= 0.5)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/hovertank/chatter1.wav", 1, ATTN_NORM);
    else 
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/hovertank/chatter2.wav", 1, ATTN_NORM);
};

static void() hovertank_sfx_pain =
{	

	if (random() <= 0.5)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/hovertank/pain1.wav", 1, ATTN_NORM);
    else 
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/hovertank/pain2.wav", 1, ATTN_NORM);
};

static void() hovertank_sfx_attack =
{	
	local float r = (random());	
	if (r <= 0.5)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/hovertank/chatter_combat1.wav", 1, ATTN_NORM);
	else 
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/hovertank/chatter_combat2.wav", 1, ATTN_NORM);
};

static void() hovertank_sfx_sight =
{
	sound(self, CHAN_VOICE, "sounds_q4/strogg/hovertank/alert.wav", 1, ATTN_NORM);
};

/*QUAKED monster_demon (1 0 0) (-32 -32 -24) (32 32 64) Ambush

*/
void() monster_hovertank_cache =
{
	precache_model("progs/monsters/heavyhovertank/mesh.md5.info");
	precache_model("progs/monsters/heavyhovertank/hovertank_death.iqm");
	precache_model("progs/monsters/heavyhovertank/big_guntag.md3");
	precache_model("progs/monsters/heavyhovertank/mgun1_tag.md3");
	precache_model("progs/monsters/heavyhovertank/mgun2_tag.md3");
	precache_model("progs/monsters/heavyhovertank/melee_tag.md3");
	precache_model("progs/monsters/heavyhovertank/melee2_tag.md3");

	precache_sound("sounds_q4/strogg/hovertank/alert.wav");
	precache_sound("sounds_q4/strogg/hovertank/chatter_combat1.wav");
	precache_sound("sounds_q4/strogg/hovertank/chatter_combat2.wav");

	precache_sound("sounds_q4/strogg/hovertank/chatter1.wav");
	precache_sound("sounds_q4/strogg/hovertank/chatter2.wav");

	precache_sound("sounds_q4/strogg/hovertank/rocket_ready.wav");
    precache_sound("sounds_q4/strogg/hovertank/rocket_stow.wav");
	precache_sound("sounds_q4/strogg/hovertank/hover_loop.wav");

	precache_sound("sounds_q4/strogg/hovertank/strafe.wav");
    precache_sound("sounds_q4/strogg/hovertank/pain1.wav");
	precache_sound("sounds_q4/strogg/hovertank/pain2.wav");

	precache_sound("sounds_q4/strogg/gladiator/rapidfire_01.wav");
	precache_sound("sounds_q4/strogg/gladiator/rapidfire_02.wav");

//	spawn_demon ();
};

void() monster_hovertank =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	monster_hovertank_cache ();	
	spawn_hovertank ();
};

void() spawn_hovertank =
{
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel(self, "progs/monsters/heavyhovertank/mesh.md5.info");
    self.classname = "monster_hovertank";
	setsize(self, '-32 -32 8', '32 32 78');

	if (world.model == "maps/e2m6.bsp")
	{
		self.health = 800;
		self.max_health = 800;
	}
	else
	{
		self.health = 1360;
		self.max_health = 1360;
	}

	self.mass = 600;
	self.scale = 0.6;

	self.th_stand = hovertank_stand1;
	self.th_walk = hovertank_walk1;
	self.th_run = hovertank_run1;
	self.th_die = hovertank_die;
	self.th_melee = hovertank_MeleeAttack; // one of two attacks
	self.th_missile = hovertank_MissileAttack; // jump attack
	self.th_pain = hovertank_pain;
//	self.th_checkatck = BerserkCheckAttack;
	self.th_spawn = spawn_hovertank;
	self.th_dodge = hovertank_strafe;
	self.th_sight = hovertank_sfx_sight;
	//setcustomskin (self, "progs/monsters/heavyhovertank/heavyhovertank.skin")
	self.deathtype = "was blasted by a Heavy Hover Tank";
	self.pissed = 0;
	self.speed = 5;
	self.count = 0;
	self.flybob_horz = 2;
	self.flybob_vert = 1;
	self.flybob_strength = 128;

	flymonster_start();
};

//===========================================================================

void() hovertank_shoot =
{	
	RocketNoise ();
	hovertank_flash ();
	vector dir = normalize(self.enemy.origin - self.pos2 + self.enemy.view_ofs);

	vector f, r, u;
	AngleVectors(self.angles, f, r, u);
	dir += r * crandom() * 0.06 + u * crandom() * 0.05;
	if (random() <= 0.5)
		launch_rocket_home (self.pos2, dir, 400, 70, 120, 300, "EF_HHMISSTRAIL2");
	else
		launch_rocket (self.pos2, dir, 1000, 70, 120, "EF_HHMISSTRAIL2");
}

void() hovertank_shoot2 =
{	
	pointparticles (particleeffectnum("TE_MUZZLEFLASH2"), self.pos2, '0 0 0');
	pointparticles (particleeffectnum("EF_MUZZLEFLASH2"), self.pos2, '0 0 0');

	vector dir = normalize(self.enemy.origin - self.pos2 + self.enemy.view_ofs);

	vector f, r, u;
	AngleVectors(self.angles, f, r, u);

	if (random() <= 0.5)
		sound(self, CHAN_WEAPON, "sounds_q4/strogg/gladiator/rapidfire_01.wav", 1, ATTN_NORM);
	else
		sound(self, CHAN_WEAPON, "sounds_q4/strogg/gladiator/rapidfire_02.wav", 1, ATTN_NORM);

	dir += r * crandom() * 0.06 + u * crandom() * 0.05;
	Strogg_Bullet (self.pos2, dir, 10, 20, 600);
	Strogg_Bullet (self.pos2, dir, 10, 20, 400);
}

void() hovertank_Melee =
{
	float ldmg;

	ai_flybob_face();

	ldmg = 30 + 15*(random() + random() + random());
	vector	aim;

	//heavyhovertank_sfx_swing ();

	aim = setvector (100, 0, 0);
	if (fire_hit(aim, rint(ldmg), 50))
	{	
		meat_hit ();
	}
    else
    {	
		meat_miss ();
	}
};

void() hovertank_flash = 
{   
   
    vector org;

    org = self.pos2;

    pointparticles (particleeffectnum("TE_BOLT_IMPACT"), org, '0 0 0', 8);
//	pointparticles (particleeffectnum("EF_MUZZLEFLASH2"), org, '0 0 0');
};

void() hovertank_flash2 = 
{   
	if (skill > 2)
		return;
	
    vector org;

    org = self.pos2;

    pointparticles (particleeffectnum("TE_BOLT_IMPACT_RED"), org, '0 0 0', 8);
//	pointparticles (particleeffectnum("EF_MUZZLEFLASH2"), org, '0 0 0');
};