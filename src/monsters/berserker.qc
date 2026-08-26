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

void() berserk_stand1 = [ 1, berserk_stand2 ] { ai_stand(); self.monster_frame = 0;};
void() berserk_stand2 = [ self.frame, berserk_stand2 ] 
{ 	
	self.monster_frame ++;
	if (self.monster_frame >= 186) 
	{	
		if (random() < 0.2)
			berserk_sfx_idle ();
		berserk_stand1 ();
		return;
	}
	ai_stand ();
};

void() berserk_walk1 = [ 3, berserk_walk2 ] { ai_walk(2); self.monster_frame = 0;};
void() berserk_walk2 = [ self.frame, berserk_walk2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 23) 
	{
		berserk_walk1 ();
		return;
	}
	ai_walk (2);
};

void() berserk_run1 = [ 2, berserk_run2 ] { ai_run(self.speed); self.monster_frame = 0;};
void() berserk_run2 = [ self.frame, berserk_run2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 17) 
	{
		if (random() < 0.3)
			berserk_sfx_idle ();

		berserk_run1 ();
		return;
	}
	ai_run (self.speed);
};

void() berserk_strafel1 = [ 20, berserk_strafel2 ] 
{ M_walkmove (self.ideal_yaw + 90, 0); self.nextthink = time + 0.04; self.monster_frame = 0;};
void() berserk_strafel2 = [ self.frame, berserk_strafel2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 20) 
	{	
		//self.attack_state = AS_STRAIGHT;
		self.flags &= ~FL_DODGED;
		berserk_run1 ();
		return;
	}

	if (self.monster_frame > 3 && self.monster_frame < 14)
		M_walkmove (self.ideal_yaw + 90, 8);
	
	self.nextthink = time + 0.04;
};

void() berserk_strafer1 = [ 21, berserk_strafer2 ] 
{ M_walkmove (self.ideal_yaw -90, 0); self.nextthink = time + 0.04; self.monster_frame = 0;};
void() berserk_strafer2 = [ self.frame, berserk_strafer2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 23) 
	{	
		//self.attack_state = AS_STRAIGHT;
		self.flags &= ~FL_DODGED;
		berserk_run1 ();
		return;
	}

	if (self.monster_frame < 16 && self.monster_frame > 2)
		M_walkmove (self.ideal_yaw -90, 8);
	
	self.nextthink = time + 0.04;
};

void() berserk_dodge =
{	
	makevectors(self.angles);
	tracebox (self.origin, self.mins, self.maxs, self.origin + v_right * 120, FALSE, self);
	float right = trace_fraction;
//	line(self.origin, trace_endpos);
	tracebox (self.origin, self.mins, self.maxs, self.origin + v_right * -120, FALSE, self);
	float left = trace_fraction;
//	line(self.origin, trace_endpos);
//	bprint("left: ", ftos(left)," ","right: ", ftos(right), "\n");

	if (left == 1 && right == 1)
	{
		if (random() <= 0.5)
			berserk_strafel1 ();
		else 
			berserk_strafer1 ();
		return;
	}

	if (left == 1)
		berserk_strafel1 ();
	else if (right == 1)
		berserk_strafer1 ();

	if (left < 1 || right < 1)
	{	
        if (self.flags & FL_DODGED)
		    self.flags &= ~FL_DODGED;
        else
            self.th_run ();
		return;
	}
	
	self.nextthink = time;
}

//==============================================================================

static void(entity target, string name) whoosh_entity =
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

static void() whoosh_think =
{	
	self.frame = self.owner.monster_frame;
	if (self.frame >= self.dspeed || self.owner.frame != self.ltime )
	{	
		remove(self.prelock_save);
		remove(self);
		return;
	}
	
	setorigin(self, self.owner.origin);
	self.angles = self.owner.angles;

	float tagindex = gettagindex (self, self.netname);
	vector taginf = gettaginfo(self, tagindex);
	//bprint(ftos(self.prelock_save.traileffectnum), "\n");

	self.prelock_save.origin = taginf;

	self.think = whoosh_think;
	self.angles = self.owner.angles;
	self.nextthink = time;
}

static void(string stringg, float fr, float end, string name, string tag) spike_woosh = 
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
	whoosh_entity(e, name);
	e.netname = tag;
	e.think = whoosh_think;
	e.nextthink = time + 0.04;
}

// thunder shoot
void() berserk_missilea1 = [ 4, berserk_missilea2 ] {
	self.monster_frame = 0;
	spike_woosh("progs/monsters/berserker/attack_fire_tag.md3", 4, 16, "TE_LTNG_CLUB", "tag_point"); 
	ai_face(); self.nextthink = time + 0.04; };
void() berserk_missilea2 = [ self.frame, berserk_missilea2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame > 8 && self.monster_frame < 14)
		berserk_shock ();
	
	if (self.monster_frame >= 26) 
	{
		berserk_run1 ();
		return;
	}

	if (self.monster_frame < 8)
		ai_face ();
};

// heavy run fling
void() berserk_missileb1 = [ 14, berserk_missileb2 ] 
{	self.monster_frame = 0;
	spike_woosh("progs/monsters/berserker/leap_attack_tag.md3", 14, 19, "TE_WHOOSH", "tag_point"); 
	ai_charge(9); self.nextthink = time + 0.04; };
void() berserk_missileb2 = [ self.frame, berserk_missileb2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 18)
		berserk_Melee (90, 20, TRUE);
	
	if (self.monster_frame >= 26) 
	{
		berserk_run1 ();
		return;
	}

	if (self.monster_frame < 22)
		ai_charge (8);
	if (self.monster_frame > 22 && self.monster_frame < 29)
		ai_charge (4);
};

// light club slam
void() berserk_atta1 = [ 5, berserk_atta2 ] 
{	self.monster_frame = 0;
	spike_woosh("progs/monsters/berserker/attack01_tag2.md3", 5, 26, "TE_LTNG_CLUB", "tag_chain"); 
ai_face(); self.nextthink = time + 0.04;  };
void() berserk_atta2 = [ self.frame, berserk_atta2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 16)
		berserk_Melee (10, 16, TRUE);
	
	if (self.monster_frame >= 26) 
	{
		berserk_run1 ();
		return;
	}

	if (self.monster_frame < 15)
		ai_charge (4);

	else if (self.monster_frame > 15 && self.frame < 21)
		ai_charge (1.5);

	else if (self.monster_frame > 21)
		ai_charge (-3);
};

// light jab
void() berserk_attb1 = [ 6, berserk_attb2 ] 
{spike_woosh("progs/monsters/berserker/attack02_tag.md3", 6, 14, "TE_WHOOSH", "tag_point"); 
ai_face(); self.nextthink = time + 0.04; self.monster_frame = 0; };
void() berserk_attb2 = [ self.frame, berserk_attb2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 9)
		berserk_Melee (5, 14, FALSE);
	
	if (self.monster_frame >= 19) 
	{
		if (random() <= 0.6)
			berserk_run1 ();
		else
			berserk_dodge ();
		return;
	}
	ai_face ();
};

// light club swing
void() berserk_attc1 = [ 7, berserk_attc2 ] 
{	self.monster_frame = 0;
	spike_woosh("progs/monsters/berserker/attack03_tag2.md3", 7, 32, "TE_LTNG_CLUB", "tag_chain"); 
	ai_face(); self.nextthink = time + 0.04; };
void() berserk_attc2 = [ self.frame, berserk_attc2 ] 
{ 	
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 13)
		berserk_Melee (20, 16, TRUE);
	
	if (self.monster_frame >= 32) 
	{
		if (random() <= 0.6)
			berserk_run1 ();
		else
			berserk_dodge ();
		return;
	}

	if (self.monster_frame < 19)
		ai_charge (6);

	if (self.monster_frame > 19 && self.monster_frame < 27) 
		ai_charge (-3);
};

// ground shock start
void() berserk_attd1_0 = [ 8, berserk_attd2_0 ] 
{	self.monster_frame = 0;
	spike_woosh("progs/monsters/berserker/attack05_tag.md3", 8, 21, "TE_LTNG_CLUB", "tag_point"); 
	sound(self, CHAN_WEAPON, "sounds_q4/strogg/berserker/charge.wav", 1, ATTN_NORM);
	ai_face(); self.nextthink = time + 0.04; };
void() berserk_attd2_0 = [ self.frame, berserk_attd2_0 ] 
{ 	
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame > 21)
		berserk_shockwave ();
	
	if (self.monster_frame >= 21) 
	{
		berserk_attd1_1 ();
		return;
	}
};

// ground shock idle
void() berserk_attd1_1 = [ 9, berserk_attd2_1 ] 
{ 	sound(self, CHAN_WEAPON, "sounds_q4/strogg/berserker/charge_release.wav", 1, ATTN_NORM);
	self.nextthink = time + 0.02; self.monster_frame = 0; };
void() berserk_attd2_1 = [ self.frame, berserk_attd2_1 ] 
{ 	
	self.monster_frame ++;
	self.nextthink = time + 0.02;

	if (vlen(self.enemy.origin - self.origin) >= 140)
	{
		berserk_attd1_2 ();
		return;
	}

	berserk_shockwave ();
	
	if (self.monster_frame >= 10) 
	{
		berserk_attd1_2 ();
		return;
	}
};

// ground shock end
void() berserk_attd1_2 = [ 10, berserk_attd2_2 ] { self.nextthink = time + 0.04; self.monster_frame = 0; };
void() berserk_attd2_2 = [ self.frame, berserk_attd2_2 ] 
{ 	
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame < 26)
		berserk_shockwave ();
	
	if (self.monster_frame >= 31) 
	{
		berserk_run1 ();
		return;
	}
};

// heavy combo
void() berserk_atte1 = [ 11, berserk_atte2 ] 
{	self.monster_frame = 0;
	spike_woosh("progs/monsters/berserker/attack06_tag.md3", 11, 13, "TE_WHOOSH", "tag_point"); 
	ai_face(); self.nextthink = time + 0.04; };
void() berserk_atte2 = [ self.frame, berserk_atte2 ] 
{ 	
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 4)
		spike_woosh("progs/monsters/berserker/attack06_tag2.md3", 11, 37, "TE_LTNG_CLUB", "tag_chain"); 

	if (self.monster_frame == 13)
		berserk_Melee (20, 15, FALSE);

	if (self.monster_frame == 19)
		berserk_Melee (60, 18, TRUE);
	
	if (self.monster_frame >= 37) 
	{
		if (random() <= 0.3)
			berserk_run1 ();
		else
			berserk_dodge (); 
		return;
	}

	if (self.monster_frame < 19)
		ai_charge (6.5);

	if (self.monster_frame > 28 && self.monster_frame < 35)
		ai_charge (3);

	if (self.monster_frame > 19 && self.monster_frame < 28) 
		ai_charge (-2);
};

// heavy swing 
void() berserk_attf1 = [ 12, berserk_attf2 ] 
{	self.monster_frame = 0;
	spike_woosh("progs/monsters/berserker/attack09_tag2.md3", 12, 26, "TE_LTNG_CLUB", "tag_chain"); 
	ai_face(); self.nextthink = time + 0.04; };
void() berserk_attf2 = [ self.frame, berserk_attf2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 9)
		berserk_Melee (60, 23, TRUE);
	
	if (self.monster_frame >= 26) 
	{
		berserk_dodge ();
		return;
	}
	ai_face ();
};

// light fling
void() berserk_attg1 = [ 13, berserk_attg2 ] 
{	self.monster_frame = 0;
	spike_woosh("progs/monsters/berserker/attack10_tag2.md3", 13, 26, "TE_LTNG_CLUB", "tag_chain"); 
	ai_face(); self.nextthink = time + 0.04; };
void() berserk_attg2 = [ self.frame, berserk_attg2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 11)
		berserk_Melee (80, 25, TRUE);
	
	if (self.monster_frame >= 26) 
	{	
		if (random() <= 0.5)
			berserk_run1 ();
		else
			berserk_dodge ();
		return;
	}
	ai_face ();
};

//==============================================================================

void() berserk_MeleeAttack =
{
	berserk_sfx_melee ();
	float num = 0;
	float r = rint (random() * 3);
	if (self.pissed > 0.3) // do heavy attacks
	{		
		if (r == 1)
			berserk_atte1();
		else if (r == 2)
			berserk_attf1();
		else 
			berserk_attg1();

		return;
	}

//	float r = rint (random() * 3);

	if (r == 1)
		berserk_atta1();
	else if (r == 2)
		berserk_attb1();
	else 
		berserk_attc1();
};

void() berserk_MissileAttack =
{
	float r =  rint(random());

	if (vlen(self.origin - self.enemy.origin) <= 240)
	if (self.pissed > 0.4 && random() <= self.pissed)
	{	
		if (random() <= 0.5)
			sound(self, CHAN_VOICE, "sounds_q4/strogg/berserker/rush2.wav", 1, ATTN_NORM);
		else
			sound(self, CHAN_VOICE, "sounds_q4/strogg/berserker/rush1.wav", 1, ATTN_NORM);

		berserk_missileb1();
		return;
	}

	if (vlen(self.origin - self.enemy.origin) >= 180)
		return;

	if (self.pissed > 0.4 && random() <= self.pissed + 0.2)
	{	
		berserk_sfx_melee ();
		berserk_missilea1();
		return;
	}

	if (r >= 0.5)
	{
		berserk_sfx_melee ();
		berserk_missilea1();
	}
		
	else 
	{
		if (self.pissed > 0.1 && random() >= 0.6)
		{
			if (random() <= 0.5)
				sound(self, CHAN_VOICE, "sounds_q4/strogg/berserker/rush2.wav", 1, ATTN_NORM);
			else
				sound(self, CHAN_VOICE, "sounds_q4/strogg/berserker/rush1.wav", 1, ATTN_NORM);

			berserk_missileb1();
		}
			
		else if (vlen(self.origin - self.enemy.origin) <= 150)
		{
			berserk_sfx_melee ();
			berserk_attd1_0();
		}
		
	}
		
	
};

//==============================================================================

// regular ow
void() berserk_paina1 = [ 15, berserk_paina2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() berserk_paina2 = [ self.frame, berserk_paina2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	
	if (self.monster_frame >= 12) 
	{
		berserk_run1 ();
		return;
	}
};

void() berserk_painb1 = [ 16, berserk_painb2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() berserk_painb2 = [ self.frame, berserk_painb2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	
	if (self.monster_frame >= 12) 
	{
		berserk_run1 ();
		return;
	}
};

// knocked
void() berserk_painc1 = [ 19, berserk_painc2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() berserk_painc2 = [ self.frame, berserk_painc2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	
	if (self.monster_frame >= 44) 
	{
		berserk_run1 ();
		return;
	}

	if (self.monster_frame > 3 && self.monster_frame < 14)
		ai_move (-4);

	if (self.monster_frame > 14 && self.monster_frame < 40)
		ai_move (1);
};

// concusion
void() berserk_paind1 = [ 17, berserk_paind2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() berserk_paind2 = [ self.frame, berserk_paind2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	
	if (self.monster_frame >= 20) 
	{
		berserk_run1 ();
		return;
	}
};

void() berserk_paine1 = [ 18, berserk_paine2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() berserk_paine2 = [ self.frame, berserk_paine2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	
	if (self.monster_frame >= 16) 
	{
		berserk_run1 ();
		return;
	}
};

void(entity attacker, float damage, float MOD) berserk_pain =
{
//	if (self.touch == berserk_JumpTouch)
//		return;
//	bprint(ftos(MOD), "\n");
	if (self.flags & FL_DODGED)
		return;

	if (self.pain_finished > time)
		return;

	self.pain_finished = time + 1.5;
	berserk_sfx_pain (); // sfx

	if (DMGTYPE_LTNG == MOD)
	{
		if (random() >= 0.5)
			berserk_paina1 ();
		else
			berserk_painb1 ();
		
		if (skill < 2)
			self.pain_finished = time + 0.5;
		else
			self.pain_finished = time + 1.5;
		return;
	}

	if (MOD == DMGTYPE_RAIL && self.pissed < 0.8)
	{
		berserk_painc1();
		self.pain_finished = time + 3;
		return;
	}

	if (random()*200 > damage)
		return; // didn't flinch

	if (damage > 60 || MOD == DMGTYPE_EXP)
	{
		if (random() >= 0.5)
			berserk_paine1 ();
		else
			berserk_paind1 ();

		return;
	}
	
	if (random() >= 0.5)
		berserk_paina1 ();
	else
		berserk_painb1 ();
};

void() berserk_die =
{	
	
	//setsize(self, '-16 -16 0', '16 16 64');
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

	berserk_sfx_death ();

	local vector tmpangle;
	local float tempskin;
	tmpangle = self.angles;
	tempskin = self.skin;
	
	if (random () <= 0.5)
	{
		self.think = berserk_die1;
	//	setmodel(self, "progs/demondeath.md3");
	}
	else
	{
		self.think = berserk_dieb1;
	//	setmodel(self, "progs/demondeath2.md3");
	}

	self.deadflag = DEAD_DEAD;
	self.solid = SOLID_CORPSE;
//	self.movetype = MOVETYPE_STEP;
	self.nextthink = time + 0.04;

	self.angles = tmpangle;
	//self.skin = tempskin;
};

void() berserk_die1 = [ 22, berserk_die2 ] { self.nextthink = time + 0.04; self.monster_frame = 0;};
void() berserk_die2 = [ self.frame, berserk_die2 ] 
{ 	
	//self.frame |= 0x8000;
	self.nextthink = time + 0.04;
	if (self.monster_frame < 20)
		ai_move (-4.5);
	self.monster_frame ++;
	if (self.monster_frame == 31)
	{
		self.maxs_z = 12;
		self.cnt = 1;
		self.nextthink = -1;
		self.think = berserk_fade1;
		self.nextthink = time + 3.5;
		return;
	}
};

void() berserk_dieb1 = [ 23, berserk_dieb2 ] { self.nextthink = time + 0.04; self.monster_frame = 0;};
void() berserk_dieb2 = [ self.frame, berserk_dieb2 ] 
{ 	
	//self.frame |= 0x8000;
	self.nextthink = time + 0.04;

	if (self.monster_frame < 29)
		ai_move (-4.5);
	self.monster_frame ++;
	if (self.monster_frame == 31)
	{	
		self.maxs_z = 12;
		self.think = berserk_fade1;
		self.nextthink = time + 3.5;
		return;
	}
};

void() berserk_fade1 = [ self.frame, berserk_gib2 ] 
{
	if (self.cnt == 1)
		self.frame = 0;
	else
		self.frame = 1;
	
	setmodel(self, "progs/monsters/berserker/berserker_death.iqm");
	setsize(self, '-16 -16 0', '16 16 12');

	self.skin = 1; 
	self.alpha = 1; 
	self.glowmod = '0.5 0.5 0.5'; 
	self.nextthink = time + 0.02;

};

void() berserk_gib1 = [ self.frame, berserk_gib2 ] 
{MonsterGib (self.health); self.skin = 1; self.alpha = 1; self.nextthink = time + 0.02;};

void() berserk_gib2 = [ self.frame, berserk_gib2 ] 
{ 	
	self.nextthink = time + 0.02;
	self.alpha -= 0.02;
	if (self.alpha <= 0)
	{
		remove(self);
		return;
	}
};

static void() berserk_sfx_pain =
{
	local float r = rint(random() * 2);	

	if (r == 2)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/berserker/pain1.wav", 1, ATTN_NORM);
	else if (r == 1)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/berserker/pain2.wav", 1, ATTN_NORM);
	else
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/berserker/pain3.wav", 1, ATTN_NORM);
};

static void() berserk_sfx_melee =
{
	local float r = rint(random() * 3);	

	if (r == 3)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/berserker/watchit1.wav", 1, ATTN_NORM);
	else if (r == 2)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/berserker/watchit2.wav", 1, ATTN_NORM);
	else if (r == 1)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/berserker/growl1.wav", 1, ATTN_NORM);
	else
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/berserker/growl2.wav", 1, ATTN_NORM);
};

static void() berserk_sfx_death =
{
	local float r = (random());	

	if (r <= 0.5)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/berserker/die1.wav", 1, ATTN_NORM);
	else
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/berserker/die2.wav", 1, ATTN_NORM);
};

static void() club_miss =
{
	local float r = rint(random() * 2);	

	if (r == 2)
		    sound(self, CHAN_WEAPON, "sounds_q4/strogg/berserker/mace_swing_1.wav", 1, ATTN_IDLE);
	else if (r == 1)
		    sound(self, CHAN_WEAPON, "sounds_q4/strogg/berserker/mace_swing_2.wav", 1, ATTN_IDLE);
	else
		    sound(self, CHAN_WEAPON, "sounds_q4/strogg/berserker/mace_swing_3.wav", 1, ATTN_IDLE);
};

static void() pike_miss =
{
	local float r = rint(random() * 2);	

	if (r == 2)
		    sound(self, CHAN_WEAPON, "sounds_q4/strogg/berserker/blade_swing1.wav", 1, ATTN_IDLE);
	else if (r == 1)
		    sound(self, CHAN_WEAPON, "sounds_q4/strogg/berserker/blade_swing2.wav", 1, ATTN_IDLE);
	else
		    sound(self, CHAN_WEAPON, "sounds_q4/strogg/berserker/blade_swing3.wav", 1, ATTN_IDLE);
};

static void() club_hit =
{
	local float r = (random());	

	if (r <= 0.5)
		    sound(self, CHAN_WEAPON, "sounds_q4/strogg/berserker/mace_hit_1.wav", 1, ATTN_NORM);
	else
		    sound(self, CHAN_WEAPON, "sounds_q4/strogg/berserker/mace_hit_2.wav", 1, ATTN_NORM);
};

static void() berserk_sfx_idle =
{
	local float r = rint(random() * 3);	

	if (r == 2)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/berserker/breath01.wav", 1, ATTN_IDLE);
	else if (r == 1)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/berserker/breath02.wav", 1, ATTN_IDLE);
	else
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/berserker/breath03.wav", 1, ATTN_IDLE);
};

static void() berserk_sfx_sight =
{
	local float r = rint(random() * 2);	

	if (r == 2)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/berserker/sight1.wav", 1, 0.7);
	else if (r == 1)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/berserker/sight2.wav", 1, 0.7);
	else
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/berserker/sight3.wav", 1, 0.7);
};

/*QUAKED monster_demon (1 0 0) (-32 -32 -24) (32 32 64) Ambush

*/
void() monster_berserker_cache =
{
	precache_model("progs/monsters/berserker/berserker.md5.info");
	precache_model("progs/monsters/berserker/berserker_death.iqm");
	
	precache_model("progs/monsters/berserker/attack02_tag.md3");
	precache_model("progs/monsters/berserker/attack06_tag.md3");
	precache_model("progs/monsters/berserker/attack01_tag2.md3");
	precache_model("progs/monsters/berserker/attack06_tag2.md3");
	precache_model("progs/monsters/berserker/attack09_tag2.md3");
	precache_model("progs/monsters/berserker/attack03_tag2.md3");
	precache_model("progs/monsters/berserker/attack10_tag2.md3");
	precache_model("progs/monsters/berserker/attack_fire_tag.md3");
	precache_model("progs/monsters/berserker/attack05_tag.md3");
	precache_model("progs/monsters/berserker/leap_attack_tag.md3");

	precache_sound("sounds_q4/strogg/berserker/charge.wav");
	precache_sound("sounds_q4/strogg/berserker/charge_release.wav");
	precache_sound("sounds_q4/strogg/berserker/rush2.wav");
	precache_sound("sounds_q4/strogg/berserker/rush1.wav");
	
	precache_sound("sounds_q4/strogg/berserker/pain1.wav");
	precache_sound("sounds_q4/strogg/berserker/pain2.wav");
	precache_sound("sounds_q4/strogg/berserker/pain3.wav");

	precache_sound("sounds_q4/strogg/berserker/watchit1.wav");
	precache_sound("sounds_q4/strogg/berserker/watchit2.wav");

	precache_sound("sounds_q4/strogg/berserker/growl1.wav");
	precache_sound("sounds_q4/strogg/berserker/growl2.wav");

	precache_sound("sounds_q4/strogg/berserker/die1.wav");
	precache_sound("sounds_q4/strogg/berserker/die2.wav");
	precache_sound("sounds_q4/strogg/berserker/mace_swing_1.wav");
	precache_sound("sounds_q4/strogg/berserker/mace_swing_2.wav");
	precache_sound("sounds_q4/strogg/berserker/mace_swing_3.wav");

	precache_sound("sounds_q4/strogg/berserker/blade_swing1.wav");
	precache_sound("sounds_q4/strogg/berserker/blade_swing2.wav");
	precache_sound("sounds_q4/strogg/berserker/blade_swing3.wav");	

	precache_sound("sounds_q4/strogg/berserker/mace_hit_1.wav");
	precache_sound("sounds_q4/strogg/berserker/mace_hit_2.wav");

	precache_sound("sounds_q4/strogg/berserker/breath01.wav");
	precache_sound("sounds_q4/strogg/berserker/breath02.wav");
	precache_sound("sounds_q4/strogg/berserker/breath03.wav");

	precache_sound("sounds_q4/strogg/berserker/sight1.wav");
	precache_sound("sounds_q4/strogg/berserker/sight2.wav");
	precache_sound("sounds_q4/strogg/berserker/sight3.wav");

	precache_sound("sounds_q4/strogg/berserker/fire.wav");

//	spawn_demon ();
};

void() monster_berserker =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	monster_berserker_cache ();	
	spawn_berserker ();
};

void() spawn_berserker =
{
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	self.classname = "monster_berserker";
	setmodel(self, "progs/monsters/berserker/berserker.md5.info");

	setsize(self, '-16 -16 0', '16 16 64');
	self.health = 540;
	self.max_health = 540;
	self.mass = 300;
	self.scale = 0.85;

	self.th_stand = berserk_stand1;
	self.th_walk = berserk_walk1;
	self.th_run = berserk_run1;
	self.th_die = berserk_die;
	self.th_melee = berserk_MeleeAttack; // one of two attacks
	self.th_missile = berserk_MissileAttack; // jump attack
	self.th_pain = berserk_pain;
	self.th_checkatck = BerserkCheckAttack;
	self.th_spawn = spawn_berserker;
	self.th_dodge = berserk_dodge;
	self.th_sight = berserk_sfx_sight;
	//setcustomskin (self, "progs/monsters/berserker/berserker.skin")
	self.deathtype = "was pulverised by a Berserker";
	self.pissed = 0;
	self.speed = 9;

	walkmonster_start();
};


/*
==============================================================================

DEMON

==============================================================================
*/

/*
==============
CheckDemonMelee

Returns TRUE if a melee attack would hit right now
==============
*/

static float() BerserkCheckAttack =
{

	local vector	spot1, spot2;	
	local entity	targ;
	local float		chance;

	if (self.pissed > 1)
		self.pissed = 1;

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
		
		// don't always melee in easy mode
		if (skill == 0 && (rand()&3) )
			return FALSE;
		
		self.attack_state = AS_MELEE;

		return TRUE;
	}
	
// missile attack
	
	if (!self.th_missile)
		return FALSE;
	
	if (self.flags & FL_DODGED)
		return FALSE;
		
	if (time < self.attack_finished)
		return FALSE;
		
	if (enemy_range == RANGE_FAR)
		return FALSE;
		
	if (enemy_range == RANGE_MELEE)
		chance = 0.15;
	else if (enemy_range == RANGE_CLOSE && vlen(self.origin - self.enemy.origin) <= 180)
		chance = 0.2;
	else
		return FALSE;

	if (skill == 0)
		chance *= 0.5;
	if (skill >= 2)
		chance *= 1.5 + self.pissed;

	if (random () < chance)
	{	
		
		self.attack_state = AS_MISSILE;
		SUB_AttackFinished (1 + 2*random() - self.pissed);
		return TRUE;
	}

	return FALSE;
};


//===========================================================================

void(float kick, float base, float club) berserk_Melee =
{
	float ldmg;

	ai_face();

	ldmg = base + 10*random();
	if (self.pissed > 0.4)
		ldmg *= (1 + self.pissed);

	vector	aim;

	aim = setvector (100, 0, 0);
	if (fire_hit(aim, rint(ldmg), kick))
	{	
		if (club)
			club_hit (); 
		else
			meat_hit (); 

		if (self.pissed > 0)
			self.pissed -= 0.1;
	}
	else
	{
		if (club)
			club_miss (); 
		else
			pike_miss (); 

		self.pissed += 0.3; 
	}
};

static void(vector p1, vector p2, entity shooter, float dmg, float kick, float len) _fireLightning = 
{
	local vector end;
	local vector from;
	local entity ignore;

	end = p1 + p2 * len;
	from = p1;

	ignore = self;

	self.solid = SOLID_BBOX;
	tracebox (from, '-16 -16 -16', '16 16 16', end, FALSE, ignore);
	vector org = trace_endpos - p2*4;
	
	if((trace_ent != ignore) && (trace_ent.takedamage) && (trace_ent.classname != "gib") && !(trace_ent.flags & FL_MONSTER))
	{		
		SpawnBlood (trace_ent, org, '0 0 0', kick * 2.5);
		T_Damage (trace_ent, shooter, org, shooter, dmg, kick);
		ignore = trace_ent;
		pointparticles (particleeffectnum("TE_BOLT_IMPACT"), org);
	}
	if (trace_ent != shooter.enemy && skill > 2)
		shooter.pissed += 0.025;
	
	//bprint (ftos(self.pissed), "\n");
	self.solid = SOLID_SLIDEBOX;

	WriteByte (MSG_MULTICAST, SVC_CGAMEPACKET); // visual for other clients
	WriteByte (MSG_MULTICAST, THUNDER_STARTPOS);
	WriteCoord (MSG_MULTICAST, from_x);
	WriteCoord (MSG_MULTICAST, from_y);
	WriteCoord (MSG_MULTICAST, from_z);

	WriteCoord (MSG_MULTICAST, org_x);
	WriteCoord (MSG_MULTICAST, org_y);
	WriteCoord (MSG_MULTICAST, org_z);

	WriteEntity (MSG_MULTICAST, shooter);

	multicast('0 0 0', MULTICAST_ALL);
};

void() berserk_shock =
{
//	float ldmg;

//	vector dir = normalize(self.enemy.origin - self.origin - '0 0 32'); 
	sound(self, CHAN_WEAPON, "sounds_q4/strogg/berserker/fire.wav", 1, ATTN_NORM);
	makevectors(self.angles);
	_fireLightning (self.origin + '0 0 50' + v_right * 12 + v_forward * 32, v_forward, self, 6, 2, 120);

	sound (self, CHAN_BODY, "weapons/lhit.wav", 1, ATTN_NORM);
};

void() berserk_shockwave =
{
//	float ldmg;

//	vector dir = normalize(self.enemy.origin - self.origin - '0 0 32');
	makevectors(self.angles);
	_spawn_laser (self.origin + v_forward * 32 + v_right * 8 + '0 0 4');
	_spawn_laser (self.origin + v_forward * 32 + v_right * 8 + '0 0 4');

	local entity ent;
	vector point;

	for (ent= findradius(self.origin + v_forward * 32 + v_right * 8 + '0 0 4', 150); ent; ent = ent.chain)
	{
		if(!ent.takedamage)
            continue;
        if(ent == self)
            continue;
		if(ent.classname == "gib")
			continue;
        if(!CanDamage(ent, self))
            continue;
		if(ent != self.enemy)
			continue;
		if(ent.solid == SOLID_CORPSE)
            continue;
		if(!(ent.flags & FL_ONGROUND))
			continue;
		
		point = (ent.maxs - ent.mins) * 0.5 + ent.absmin;	

		pointparticles (particleeffectnum("TE_BOLT_IMPACT"), point);
	
		T_Damage (ent, self, point, self, 2, 10, DMGTYPE_LTNG);

		if (random() > 0.2)
			SpawnBlood (ent, point, '0 0 0', 0);

		//particle (point, '0 0 100', 73, self.dmg_lsr* 8);
	}

	sound (self, CHAN_BODY, "weapons/lhit.wav", 1, ATTN_NORM);
};

static vector _laser_pos(vector  p, float  dist) = // q2 rerelease
{
	float theta = random(16 * M_PI);
	float phi = acos(crandom());

	vector d;
	d[0] = sin(phi) * cos(theta);
	d[1] = sin(phi) * sin(theta);
	d[2] = 0;

	return p + (d * dist);
};

static void() _laser_update = // q2 rerelease
{
	if (time > self.ltime)
	{
		remove(self);
		return;
	}
	
	vector from = self.pos1;
	vector org = self.oldorigin;

	WriteByte (MSG_MULTICAST, SVC_CGAMEPACKET); // visual for other clients
	WriteByte (MSG_MULTICAST, THUNDER_STARTPOS);
	WriteCoord (MSG_MULTICAST, from_x);
	WriteCoord (MSG_MULTICAST, from_y);
	WriteCoord (MSG_MULTICAST, from_z);

	WriteCoord (MSG_MULTICAST, org_x);
	WriteCoord (MSG_MULTICAST, org_y);
	WriteCoord (MSG_MULTICAST, org_z);

	WriteEntity (MSG_MULTICAST, self);

	multicast('0 0 0', MULTICAST_ALL);

	self.origin = self.pos1;
	self.nextthink = time + 0.1;
	self.think = _laser_update;
};

static void(vector org) _spawn_laser = // q2 rerelease
{
	vector end = _laser_pos(org, 130);
	traceline(org, end, TRUE, self);

	entity laser = spawn();

	laser.think = _laser_update;
	laser.nextthink = time + 0.01;
	laser.ltime = time + 0.4;
	laser.oldorigin = trace_endpos;
	laser.pos1 = org;
	laser.owner = self;
	setorigin(laser, self.origin);
	pointparticles (particleeffectnum("TE_BOLT_IMPACT"), laser.oldorigin, '0 0 0', 3);
};