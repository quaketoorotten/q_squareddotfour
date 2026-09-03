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

void() slimy_transf_stand1 = [ 1, slimy_transf_stand2 ] { ai_stand(); self.monster_frame = 0;};
void() slimy_transf_stand2 = [ self.frame, slimy_transf_stand2 ] 
{ 	
	self.monster_frame ++;
	if (self.monster_frame >= 87) 
	{	
		if (random() < 0.2)
			slimy_transf_sfx_idle ();

		slimy_transf_stand1 ();
		return;
	}
	ai_stand ();
};

void() slimy_transf_walk1 = [ 2, slimy_transf_walk2 ] 
{ ai_walk(1); self.monster_frame = 0; self.nextthink = time + 0.04167;};
void() slimy_transf_walk2 = [ self.frame, slimy_transf_walk2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 66) 
	{
		if (random() < 0.3)
			slimy_transf_sfx_idle ();

		slimy_transf_walk1 ();
		return;
	}


    ai_walk(1);

    self.nextthink = time + 0.04167;
};

void() slimy_transf_run1 = [ 2, slimy_transf_run2 ] 
{ ai_run(1); self.monster_frame = 0; self.nextthink = time + 0.04167;};
void() slimy_transf_run2 = [ self.frame, slimy_transf_run2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 66) 
	{
		if (random() < 0.3)
			slimy_transf_sfx_idle ();
        
		slimy_transf_run1 ();
		return;
	}

    if (random() <= 0.1)
        CheckForCharge (1 + 2*random());

    ai_run(1);

    self.nextthink = time + 0.04167;
};

void() slimy_transf_charge1 = [ 3, slimy_transf_charge2 ] 
{ ai_run(3); self.monster_frame = 0; self.nextthink = time + 0.04167;};
void() slimy_transf_charge2 = [ self.frame, slimy_transf_charge2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 40) 
	{
		if (random() < 0.3)
			slimy_transf_sfx_idle ();
        
        CheckContinueCharge (1 + 2*random());
		slimy_transf_charge1 ();
		return;
	}

    ai_run(3);

    self.nextthink = time + 0.04167;
};

void() slimy_transf_checkcharge =
{
	if (self.aiflags & AI_CHARGE)
		slimy_transf_charge1 ();
	else
		slimy_transf_run1 ();
}

//==============================================================================

static void(entity target, string name) slimy_transf_tag_entity =
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

static void() slimy_transf_tag_think =
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
	
	self.think = slimy_transf_tag_think;
	self.angles = self.owner.angles;
	self.nextthink = time;
}

static void(string stringg, float fr, float end, string name, string tag) slimy_transf_tag = 
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
		slimy_transf_tag_entity(e, name);

	e.netname = tag;
	e.think = slimy_transf_tag_think;
	e.nextthink = time;

	if (tag == string_null)
		self.prelock_save = e;
}

// vomit
void() slimy_transf_missilea1 = [ 7, slimy_transf_missilea2 ] {
	//self.flags |= FL_DODGED;
	self.monster_frame = 0;
	slimy_transf_tag ("progs/monsters/slimy_transfer/puke1_tag.md3", 7, 64, string_null, "Empty");

	ai_face(); self.nextthink = time + 0.04167;  
};
void() slimy_transf_missilea2 = [ self.frame, slimy_transf_missilea2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04167;

	if (self.monster_frame > 13 && self.monster_frame < 40)
		zom_missile ();

    if (self.monster_frame == 13)
        slimy_transf_flash ();

	if (self.monster_frame >= 64) 
	{   
        slimy_transf_run1 ();
		//self.flags &= ~FL_DODGED;
		return;
	}

	ai_face ();
};

void() slimy_transf_missileb1 = [ 8, slimy_transf_missileb2 ] {
	//self.flags |= FL_DODGED;
	self.monster_frame = 0;
	slimy_transf_tag ("progs/monsters/slimy_transfer/puke2_tag.md3", 8, 55, string_null, "Empty");

	ai_face(); self.nextthink = time + 0.04167;  
};
void() slimy_transf_missileb2 = [ self.frame, slimy_transf_missileb2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04167;

    if (self.monster_frame == 18)
        slimy_transf_flash ();

	if (self.monster_frame > 18 && self.monster_frame < 40)
		zom_missile ();

	if (self.monster_frame >= 55) 
	{   
        slimy_transf_run1 ();
		//self.flags &= ~FL_DODGED;
		return;
	}

	ai_face ();
};

//==============================================================================

void() slimy_transf_meleea1 = [ 9, slimy_transf_meleea2 ] {
	self.monster_frame = 0;
	slimy_transf_tag ("progs/monsters/slimy_transfer/melee_tag.md3", 9, 22, "TE_WHOOSH", "Empty");
	ai_face(); self.nextthink = time + 0.04;  };
void() slimy_transf_meleea2 = [ self.frame, slimy_transf_meleea2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 20)
		slimy_transf_Melee(60);

	if (self.monster_frame >= 69) 
	{   
        slimy_transf_checkcharge ();
		return;
	}

    ai_face ();
};

//==============================================================================

void() slimy_transf_MeleeAttack =
{	
	if (vlen(self.enemy.origin - self.origin) >= 80)
	{
		slimy_transf_MissileAttack ();
		return;
	}

	slimy_transf_sfx_growl ();

	slimy_transf_meleea1 ();
};

void() slimy_transf_MissileAttack =
{   
	slimy_transf_sfx_vomit ();

	if (random () <= 0.5)
		slimy_transf_missilea1 ();
	else
		slimy_transf_missileb1 ();	
};

//==============================================================================

// regular ow
void() slimy_transf_paina1 = [ 4, slimy_transf_paina2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() slimy_transf_paina2 = [ self.frame, slimy_transf_paina2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint("????", "\n");
	if (self.monster_frame >= 12) 
	{
		slimy_transf_run1 ();
		return;
	}
};

void() slimy_transf_painb1 = [ 5, slimy_transf_painb2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() slimy_transf_painb2 = [ self.frame, slimy_transf_painb2 ] 
{   
    //bprint(ftos(self.frame), "\n");
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint(">>>>>>>>>>?????", "\n");
	if (self.monster_frame >= 12) 
	{
		slimy_transf_run1 ();
		return;
	}
};

// concussion
void() slimy_transf_painc1 = [ 6, slimy_transf_painc2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() slimy_transf_painc2 = [ self.frame, slimy_transf_painc2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint("????", "\n");
	if (self.monster_frame >= 69) 
	{   
		slimy_transf_run1 ();
		return;
	}
};

void(entity attacker, float damage, float MOD) slimy_transf_pain =
{
//	if (self.touch == slimy_transf_JumpTouch)
//		return;
//	bprint(ftos(MOD), "\n");
	if (self.flags & FL_DODGED)
	{	
		return;
	}

	if (self.pain_finished > time)
		return;

	self.pain_finished = time + 2;
	slimy_transf_sfx_pain (); // sfx

	if (DMGTYPE_LTNG == MOD && (random() >= 0.9))
	{
  	  	if (random() <= 0.5)
	        slimy_transf_paina1 ();
 	   	else
  	      	slimy_transf_painb1 ();
		
		if (skill < 2)
			self.pain_finished = time + 0.5;
		else
			self.pain_finished = time + 1.5;
		return;
	}

	if (MOD == DMGTYPE_RAIL)
	{   
	//	bprint("knocked", "\n");
        slimy_transf_painc1 ();

		self.pain_finished = time + 2.5;
		return;
	}

	if (random()*40 > damage)
		return; // didn't flinch

	if (damage > 150 || MOD == DMGTYPE_EXP)
	{   
        slimy_transf_painc1 ();
		return;
	}

    if (random() <= 0.5)
        slimy_transf_paina1 ();
    else
        slimy_transf_painb1 ();
};

void() slimy_transf_die =
{	
	//self.angles = '-90 0 0';
	if (self.health < -80)
	{	
		self.deadflag = DEAD_DEAD;
		self.solid = SOLID_NOT;
		MonsterGib (self.health); 
		remove(self);
		return;
	}
	
	if((self.deadflag & DEAD_DEAD))
		return;

	slimy_transf_sfx_death ();

	local vector tmpangle;
	local float tempskin;
	tmpangle = self.angles;
	tempskin = self.skin;
	

//	if (random() <= 0.5)
	self.think = slimy_transf_diea1;

	self.monster_frame = 0;

	self.deadflag = DEAD_DEAD;
	self.solid = SOLID_CORPSE;
//	self.movetype = MOVETYPE_STEP;
	self.nextthink = time + 0.04;

	self.angles = tmpangle;
	//self.skin = tempskin;
};

void() slimy_transf_diea1 = [ 10 , slimy_transf_diea2 ] { self.nextthink = time + 0.04; self.monster_frame = 0;};
void() slimy_transf_diea2 = [ self.frame , slimy_transf_diea2 ] 
{ 	
	//self.frame |= 0x8000;
	self.nextthink = time + 0.04;

	if (self.monster_frame < 15)
		ai_move (-5);

	self.monster_frame ++;
	if (self.monster_frame == 32)
	{
		self.maxs_z = 12;
		self.nextthink = -1;
		self.think = slimy_transf_fade1;
		self.nextthink = time + 3.5;
		return;
	}
};

void() slimy_transf_fade1 = [ self.frame, slimy_transf_gib2 ] 
{	
	
	setmodel(self, "progs/monsters/slimy_transfer/slimy_death.iqm");
	setsize(self, '-16 -16 0', '16 16 12');
	//self.scale = 1;
	self.alpha = 1; 
	self.glowmod = '0.5 0.5 0.5'; 
	self.nextthink = time + 0.02;
};

void() slimy_transf_gib1 = [ self.frame, slimy_transf_gib2 ] 
{MonsterGib (self.health); self.skin = 1; self.alpha = 1; self.nextthink = time + 0.02;};

void() slimy_transf_gib2 = [ self.frame, slimy_transf_gib2 ] 
{ 	
	self.nextthink = time + 0.02;
	self.alpha -= 0.02;
	if (self.alpha <= 0)
	{
		remove(self);
		return;
	}
};

static string slimy_transf_pain_list[3] = 
{
	"sounds_q4/strogg/failed_transfer/s_pain1.wav",
	"sounds_q4/strogg/failed_transfer/s_pain2.wav",
    "sounds_q4/strogg/failed_transfer/s_pain3.wav",
};	

static void() slimy_transf_sfx_pain =
{
	local float r = rint(random());	

	sound(self, CHAN_VOICE, slimy_transf_pain_list[r], 1, ATTN_NORM);
};

static string slimy_transf_growl_list[3] = 
{
	"sounds_q4/strogg/failed_transfer/s_growl1.wav",
	"sounds_q4/strogg/failed_transfer/s_growl2.wav",
    "sounds_q4/strogg/failed_transfer/s_growl3.wav",
};	

static void() slimy_transf_sfx_growl =
{
	local float r = rint(random()*2);	

	sound(self, CHAN_VOICE, slimy_transf_growl_list[r], 1, ATTN_NORM);
};

static string slimy_transf_death_list[3] = 
{
	"sounds_q4/strogg/failed_transfer/die1.wav",
	"sounds_q4/strogg/failed_transfer/die2.wav",
    "sounds_q4/strogg/failed_transfer/die3.wav",
};	

static void() slimy_transf_sfx_death =
{
	local float r = rint(random()*2);	

	sound(self, CHAN_VOICE, slimy_transf_death_list[r], 1, ATTN_NORM);
};

static string slimy_transf_vomit_list[3] = 
{
	"sounds_q4/strogg/failed_transfer/vomit1.wav",
	"sounds_q4/strogg/failed_transfer/vomit2.wav",
    "sounds_q4/strogg/failed_transfer/vomit3.wav",
};	

static void() slimy_transf_sfx_vomit =
{
	local float r = rint(random()*2);	

	sound(self, CHAN_VOICE, slimy_transf_vomit_list[r], 1, ATTN_NORM);
};

static string slimy_transf_breath_list[4] = 
{
	"sounds_q4/strogg/failed_transfer/s_chatter1.wav",
	"sounds_q4/strogg/failed_transfer/s_chatter2.wav",
    "sounds_q4/strogg/failed_transfer/s_chatter3.wav",
    "sounds_q4/strogg/failed_transfer/s_chatter4.wav",
};	

static void() slimy_transf_sfx_idle =
{
	local float r = rint(random()*3);	

	sound(self, CHAN_VOICE, slimy_transf_breath_list[r], 1, ATTN_IDLE);
};

static string slimy_transf_sight_list[3] = 
{
	"sounds_q4/strogg/failed_transfer/s_alert1.wav",
	"sounds_q4/strogg/failed_transfer/s_alert2.wav",
    "sounds_q4/strogg/failed_transfer/s_alert3.wav"
};	

static void() slimy_transf_sfx_sight =
{   
	local float r = rint(random()*2);	

	sound(self, CHAN_VOICE, slimy_transf_sight_list[r], 1, ATTN_NORM);
};

static string slimy_transf_vomit2_list[4] = 
{
	"sounds_q4/strogg/failed_transfer/vomit_liquid1.wav",
	"sounds_q4/strogg/failed_transfer/vomit_liquid2.wav",
};	

static void() slimy_transf_vomit2_idle =
{   
    if (self.t_width > time)
        return;

	local float r = rint(random());	

	sound(self, CHAN_WEAPON, slimy_transf_vomit2_list[r], 1, ATTN_NORM);
    self.t_width = time + 1;
};

/*QUAKED monster_demon (1 0 0) (-32 -32 -24) (32 32 64) Ambush

*/
void() monster_slimy_transf_cache =
{
	precache_model("progs/monsters/slimy_transfer/mesh.md5.info");
    precache_model("progs/monsters/slimy_transfer/puke1_tag.md3");
    precache_model("progs/monsters/slimy_transfer/puke2_tag.md3");
    precache_model("progs/monsters/slimy_transfer/melee_tag.md3");
	precache_model("progs/monsters/slimy_transfer/slimy_death.iqm");

    precache_sound("monsters/boney/acid_burn.wav");
    precache_sound("monsters/boney/acid_burn2.wav");

	float i;

	for (i = 0; i < 3; i++)
	{
		precache_sound(slimy_transf_death_list[i]);
		precache_sound(slimy_transf_growl_list[i]);
        precache_sound(slimy_transf_pain_list[i]);
        precache_sound(slimy_transf_sight_list[i]);
        precache_sound(slimy_transf_vomit_list[i]);
        precache_sound(slimy_transf_vomit2_list[i]);
	}

    for (i = 0; i < 4; i ++)
    {
        precache_sound(slimy_transf_breath_list[i]);
    }

//	spawn_demon ();
};

void() monster_slimy_transfer =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	monster_slimy_transf_cache ();	
	spawn_slimy_transfer ();
};

void() spawn_slimy_transfer =
{
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel(self, "progs/monsters/slimy_transfer/mesh.md5.info");
	self.classname = "monster_slimy_transfer";
	setsize(self, '-16 -16 0', '16 16 64');
	self.health = 88;
	self.max_health = 88;
	self.mass = 200;
	self.scale = 0.8;

	self.th_stand = slimy_transf_stand1;
	self.th_walk = slimy_transf_walk1;
	self.th_run = slimy_transf_run1;
	self.th_die = slimy_transf_die;
	self.th_melee = slimy_transf_MeleeAttack; // one of two attacks
	self.th_missile = slimy_transf_MissileAttack; // jump attack
	self.th_pain = slimy_transf_pain;
	//self.th_checkatck = GladCheckAttack;
	self.th_spawn = spawn_slimy_transfer;
	//self.th_dodge = slimy_transf_run1;
	self.th_sight = slimy_transf_sfx_sight;
	//setcustomskin (self, "progs/monsters/failed_transfer/gladiator.skin")
	self.deathtype = "joins the Zombies";
	self.count = 0;
	self.pissed = 0;
    self.th_char = slimy_transf_charge1;
//	self.emiteffectnum = particleeffectnum("_slimy_transf_dress");

	walkmonster_start();
};


/*
==============================================================================

DEMON

==============================================================================
*/

void(float kick) slimy_transf_Melee =
{
	float ldmg;

	ai_face();

	ldmg = 12;

	vector	aim;

	aim = setvector (80, 0, 0);
	if (fire_hit(aim, rint(ldmg), 2))
	{	
		meat_hit (); 
	}
	else
	{
		meat_miss ();
	//	self.pissed += 0.3;
	}
};

void() zom_missile =
{   
    if ((self.monster_frame & 2))
    {
        slimy_transf_vomit2_idle ();
        zombie_FireGrenade2 ();		
    }
  
	//zombie_FireGrenade2 ();
	//zombie_FireGrenade2 ();
	
	// MarksmanFireGrenade(20);
}

void() slimy_transf_flash = 
{   
   
    vector org;

    org = self.pos2;

    pointparticles (particleeffectnum("TE_FLASH"), org, '0 0 0', 8);
};



//===========================================================================
