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

void() tank_stand1 = [ 1, tank_stand2 ] { ai_stand(); self.monster_frame = 0;};
void() tank_stand2 = [ self.frame, tank_stand2 ] 
{ 	
	self.monster_frame ++;
	if (self.monster_frame >= 119) 
	{	
		if (random() < 0.2)
			tank_sfx_idle ();

		tank_stand1 ();
		return;
	}
	ai_stand ();
};

void() tank_walk1 = [ 2, tank_walk2 ] 
{ ai_walk(2); self.monster_frame = 0; self.nextthink = time + 0.04167;};
void() tank_walk2 = [ self.frame, tank_walk2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 21) 
	{
		if (random() < 0.3)
			tank_sfx_idle ();

		tank_walk1 ();
		return;
	}


    ai_walk(2);

    self.nextthink = time + 0.04167;
};

void() tank_run1 = [ 2, tank_run2 ] 
{ ai_run(2.5); self.monster_frame = 0; self.nextthink = time + 0.04167;};
void() tank_run2 = [ self.frame, tank_run2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 21) 
	{
		if (random() < 0.3)
			tank_sfx_idle ();

		tank_run1 ();
		return;
	}

    ai_run(2.5);

    self.nextthink = time + 0.04167;
};

void() tank_evadel1 = [ 6, tank_evadel2 ] 
{ 	//ai_face ();
	self.nextthink = time + 0.04167; self.monster_frame = 0;};
void() tank_evadel2 = [ self.frame, tank_evadel2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 25) 
	{	
		//self.attack_state = AS_STRAIGHT;
		self.flags &= ~FL_DODGED;
	//	despawn_shield ();
		tank_run1 ();
		return;
	}

   // ai_face ();
    if (self.monster_frame < 15)
        M_walkmove (self.ideal_yaw + 90, 5);
    else  if (self.monster_frame < 24)
        M_walkmove (self.ideal_yaw - 90, 1);

    if (self.monster_frame < 10)
        ai_move(-6);

    if (self.monster_frame > 15 && self.monster_frame < 24)
        ai_move(0.5);
	
	self.nextthink = time + 0.04167;
};

void() tank_evader1 = [ 5, tank_evader2 ] 
{ 	//ai_move(1.5);
   // ai_face ();
	 self.nextthink = time + 0.04167; self.monster_frame = 0;};
void() tank_evader2 = [ self.frame, tank_evader2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 21) 
	{	
		//self.attack_state = AS_STRAIGHT;
		self.flags &= ~FL_DODGED;
	//	despawn_shield ();
		tank_run1 ();
		return;
	}

   // ai_face ();
    if (self.monster_frame < 10)
        M_walkmove (self.ideal_yaw - 90, 5);
    else  if (self.monster_frame < 20)
        M_walkmove (self.ideal_yaw + 90, 1);

    if (self.monster_frame < 10)
        ai_move(-6);

    if (self.monster_frame > 15 && self.monster_frame < 20)
        ai_move(0.5);
	
	self.nextthink = time + 0.04167;
};


void() tank_evade =
{	
	makevectors(self.angles);
	tracebox (self.origin, self.mins, self.maxs, self.origin + v_right * 120, FALSE, self);
	float right = trace_fraction;

	tracebox (self.origin, self.mins, self.maxs, self.origin + v_right * -120, FALSE, self);
	float left = trace_fraction;

	if (left == 1 && right == 1)
	{
		if (random() <= 0.5)
			tank_evadel1 ();
		else 
			tank_evader1 ();
		return;
	}

	if (left == 1)
		tank_evadel1 ();
	else if (right == 1)
		tank_evader1 ();

	if (left < 1 || right < 1)
	{	
		self.flags &= ~FL_DODGED;
		tank_run1 ();
		return;
	}
	
	self.nextthink = time;
};

void() tank_strafel1 = [ 4, tank_strafel2 ] 
{ 	ai_face ();
	self.nextthink = time + 0.04167; self.monster_frame = 0;};
void() tank_strafel2 = [ self.frame, tank_strafel2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 39) 
	{	
		//self.attack_state = AS_STRAIGHT;
		self.flags &= ~FL_DODGED;
	//	despawn_shield ();
		tank_run1 ();
		return;
	}

    ai_face ();
    if (self.monster_frame > 6 && self.monster_frame < 32)
        M_walkmove (self.ideal_yaw + 90, 4);
	
	self.nextthink = time + 0.04167;
};

void() tank_strafer1 = [ 3, tank_strafer2 ] 
{ 	//ai_move(1.5);
    ai_face ();
	self.nextthink = time + 0.04167; self.monster_frame = 0;};
void() tank_strafer2 = [ self.frame, tank_strafer2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 39) 
	{	
		//self.attack_state = AS_STRAIGHT;
		self.flags &= ~FL_DODGED;
	//	despawn_shield ();
		tank_run1 ();
		return;
	}

    ai_face ();
    if (self.monster_frame > 6 && self.monster_frame < 32)
        M_walkmove (self.ideal_yaw - 90, 4);
	
	self.nextthink = time + 0.04167;
};


void() tank_strafe =
{	
	makevectors(self.angles);
	tracebox (self.origin, self.mins, self.maxs, self.origin + v_right * 120, FALSE, self);
	float right = trace_fraction;

	tracebox (self.origin, self.mins, self.maxs, self.origin + v_right * -120, FALSE, self);
	float left = trace_fraction;

	if (left == 1 && right == 1)
	{
		if (random() <= 0.5)
			tank_strafel1 ();
		else 
			tank_strafer1 ();
		return;
	}

	if (left == 1)
		tank_strafel1 ();
	else if (right == 1)
		tank_strafer1 ();

	if (left < 1 || right < 1)
	{	
		self.flags &= ~FL_DODGED;
		tank_run1 ();
		return;
	}
	
	self.nextthink = time;
};

//==============================================================================

static void(entity target, string name) tank_tag_entity =
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

static void() tank_tag_think =
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
	
	self.think = tank_tag_think;
	self.angles = self.owner.angles;
	self.nextthink = time;
}

static void(string stringg, float fr, float end, string name, string tag) tank_tag = 
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
		tank_tag_entity(e, name);

	e.netname = tag;
	e.think = tank_tag_think;
	e.nextthink = time;

	if (tag == string_null)
		self.prelock_save = e;
}

// missile barrage
void() tank_missilea1 = [ 12, tank_missilea2 ] {
	self.flags |= FL_DODGED;
	self.monster_frame = 0;
    sound(self, CHAN_BODY, "sounds_q4/strogg/tank/tank_prepfire.wav", 1, ATTN_NORM);
	tank_tag ("progs/monsters/tank/rocket_tag.md3", 12, 999, string_null, string_null);

	ai_face(); self.nextthink = time + 0.04167;  
};
void() tank_missilea2 = [ self.frame, tank_missilea2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04167;

	if (self.monster_frame == 18)
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

	if (self.monster_frame == 20)
		tank_shoot_missile("tube1", 100, 950);
	if (self.monster_frame == 27)
		tank_shoot_missile("tube2", -100, 950);
	if (self.monster_frame == 35)
		tank_shoot_missile("tube3", 150, 1050);
	if (self.monster_frame == 41)
		tank_shoot_missile("tube4", -150, 1050);
    if (self.monster_frame == 60)
    {
        self.enemy = self.oldenemy;
		self.oldenemy = world;
        self.aiflags &= ~AI_AIMFLY;
    }
	if (self.monster_frame >= 69) 
	{   
        tank_evade ();
		self.flags &= ~FL_DODGED;
		return;
	}


	//if (self.monster_frame < 50)
	    ai_face ();
};

// chaingun barrage
void() tank_missileb1 = [ 10, tank_missileb2 ] {

    sound(self, CHAN_BODY, "sounds_q4/strogg/tank/tank_prepfire.wav", 1, ATTN_NORM);
    self.flags |= FL_DODGED;    
	self.monster_frame = 0;
	tank_tag ("progs/monsters/tank/cg_tag.md3", 10, 81, string_null, string_null);

	ai_face(); self.nextthink = time + 0.04167;  
};
void() tank_missileb2 = [ self.frame, tank_missileb2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04167;

    if (self.monster_frame == 30)
        sound(self, CHAN_WEAPON, "sounds_q4/strogg/tank/tank_nailgunfireseq.wav", 1, ATTN_NORM);

    if (self.monster_frame == 49 || self.monster_frame == 51
    || self.monster_frame == 53 || self.monster_frame == 55)
	{
		tank_shoot_bullets("muzzle2");
		//tank_shoot_bullets("muzzle2");
    }

    if (self.monster_frame == 43 || self.monster_frame == 45 || self.monster_frame == 47)
	{
		tank_shoot_bullets("muzzle3");
		//tank_shoot_bullets("muzzle2");
    }
	
	if (self.monster_frame == 52)
	{
		tank_shoot_bullets("muzzle4");
		//tank_shoot_bullets("muzzle2");
    }

    if (self.monster_frame == 48 || self.monster_frame == 50 || self.monster_frame == 56
    || self.monster_frame == 54)
	{
		tank_shoot_bullets("muzzle5");
		//tank_shoot_bullets("muzzle2");
    }

    if (self.monster_frame == 42 || self.monster_frame == 44 || self.monster_frame == 46)
	{
		tank_shoot_bullets("muzzle6");
		//tank_shoot_bullets("muzzle2");
    }

	if (self.monster_frame >= 81) 
	{   
		//if (random() <= 0.8)
        tank_strafe ();
        self.flags &= ~FL_DODGED;
		return;
	}

//	if (self.monster_frame < 52)
	    ai_face ();
};

// blaster
void() tank_missilec1 = [ 11, tank_missilec2 ] {
    tank_tag ("progs/monsters/tank/gunjoint_tag.md3", 11, 89, string_null, "gunjoint");
    sound(self, CHAN_RELOAD, "sounds_q4/strogg/tank/tank_railpowerup.wav", 1, ATTN_NORM);
    sound(self, CHAN_BODY, "sounds_q4/strogg/tank/tank_prepfire.wav", 1, ATTN_NORM);
	ai_face(); self.nextthink = time + 0.04167; self.monster_frame = 0; 
	self.flags |= FL_DODGED;    
};
void() tank_missilec2 = [ self.frame, tank_missilec2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04167;
	
 //   if (self.monster_frame == 30)
 //       sound(self, CHAN_WEAPON, "sounds_q4/strogg/tank/tank_nailgunfireseq.wav", 1, ATTN_NORM);


    if (self.monster_frame == 33 || self.monster_frame == 38 || self.monster_frame == 44
    || self.monster_frame == 49 || self.monster_frame == 47 || self.monster_frame == 52 || self.monster_frame == 55)
	{
		tank_shoot_lasers();
		//tank_shoot_bullets("muzzle2");
    }
	
	if (self.monster_frame >= 89) 
	{   
        tank_strafe ();
		self.flags &= ~FL_DODGED;
        self.count = 0;
		return;
	}

	ai_face();
};



//==============================================================================

void() tank_meleea1 = [ 7, tank_meleea2 ] {
	self.monster_frame = 0;
	tank_tag ("progs/monsters/tank/chop_tag.md3", 7, 22, "TE_WHOOSH", "Empty");
	ai_face(); self.nextthink = time + 0.04167;  };
void() tank_meleea2 = [ self.frame, tank_meleea2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04167;

	if (self.monster_frame == 17)
		tank_Melee(20);

	if (self.monster_frame >= 48) 
	{   
        tank_strafe ();
		return;
	}

	if (self.monster_frame < 20)
	    ai_face ();
};

void() tank_meleeb1 = [ 8, tank_meleeb2 ] {
	self.monster_frame = 0;
    tank_tag ("progs/monsters/tank/swipe_tag.md3", 8, 22, "TE_WHOOSH", "Empty");
	ai_face(); self.nextthink = time + 0.04167; };
void() tank_meleeb2 = [ self.frame, tank_meleeb2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04167;

	if (self.monster_frame == 14)
		tank_Melee(40);

	if (self.monster_frame >= 39)  
	{   
        tank_strafe ();
		return;
	}

	if (self.monster_frame < 20)
	    ai_face ();
};

// ts sparta
void() tank_meleec1 = [ 9, tank_meleec2 ] {
	self.monster_frame = 0;
   // tank_tag ("progs/monsters/tank/swipe_tag.md3", 8, 22, "TE_WHOOSH", "Empty");
	ai_face(); self.nextthink = time + 0.04; };
void() tank_meleec2 = [ self.frame, tank_meleec2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04167;

	if (self.monster_frame == 9)
		tank_Melee(80);

	if (self.monster_frame >= 29)  
	{   
        tank_strafe ();
		return;
	}

	if (self.monster_frame < 24)
	    ai_charge (3);
    else
        ai_charge (1);
};

//==============================================================================

void() tank_MeleeAttack =
{	
	if (random() <= 0.3)
	{
		tank_MissileAttack ();
		return;
	}

	tank_sfx_growl ();
    sound(self, CHAN_VOICE, "sounds_q4/strogg/tank/tank_melee1.wav", 1, ATTN_NORM);

    float r = rint(random()*2);
	if (r == 1)
        tank_meleea1 ();
    else if (r == 2)
        tank_meleeb1 ();
	else
        tank_meleec1 ();
};

void() tank_MissileAttack =
{   
    if (vlen(self.enemy.origin - self.origin) <= 110)
    {
        tank_MeleeAttack ();
        return;
    }   
    
	tank_sfx_sight ();

    float r = rint(random()*2);
	if (r == 1)
    {	
		if (vlen(self.enemy.origin - self.origin) >= 300)
			tank_missilea1 ();
		else
		{
			if (random() <= 0.5)
				tank_missileb1 ();
			else
				tank_missilec1 ();
		}
		return;
	}
    else if (r == 2)
        tank_missileb1 ();
	else
        tank_missilec1 ();
};

//==============================================================================

// regular ow
void() tank_paina1 = [ 13, tank_paina2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() tank_paina2 = [ self.frame, tank_paina2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint("????", "\n");
	if (self.monster_frame >= 19) 
	{
		tank_run1 ();
		return;
	}
};

void() tank_painb1 = [ 14, tank_painb2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() tank_painb2 = [ self.frame, tank_painb2 ] 
{   
    //bprint(ftos(self.frame), "\n");
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint(">>>>>>>>>>?????", "\n");
	if (self.monster_frame >= 19) 
	{
		tank_run1 ();
		return;
	}
};

void(entity attacker, float damage, float MOD) tank_pain =
{
//	if (self.touch == tank_JumpTouch)
//		return;
//	bprint(ftos(MOD), "\n");
	if (self.flags & FL_DODGED)
	{	
		return;
	}

	if (self.pain_finished > time)
		return;

	self.pain_finished = time + 6;

	if (random()*500 > damage)
		return; // didn't flinch

    if (random() <= 0.5)
        tank_paina1 ();
    else
        tank_painb1 ();

    tank_sfx_pain (); // sfx
};

void() tank_die =
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

	tank_sfx_death ();

	local vector tmpangle;
	local float tempskin;
	tmpangle = self.angles;
	tempskin = self.skin;
	

	self.think = tank_diea1;

	self.monster_frame = 0;

	self.deadflag = DEAD_DEAD;
	self.solid = SOLID_CORPSE;
//	self.movetype = MOVETYPE_STEP;
	self.nextthink = time + 0.04;

	self.angles = tmpangle;
	//self.skin = tempskin;
};

void() tank_diea1 = [ 15 , tank_diea2 ] { self.nextthink = time + 0.04; self.monster_frame = 0;};
void() tank_diea2 = [ self.frame , tank_diea2 ] 
{ 	
	//self.frame |= 0x8000;
	self.nextthink = time + 0.04;

	if (self.monster_frame > 60 && self.monster_frame < 66)
		ai_move(-6);

	if (self.monster_frame == 65)
		sound(self, CHAN_BODY, "sounds_q4/strogg/tank/tnkdeth2.wav", 1, ATTN_NORM);

	self.monster_frame ++;
	if (self.monster_frame == 85)
	{
		self.maxs_z = 12;
		self.nextthink = -1;
		self.think = tank_fade1;
		self.nextthink = time + 3.5;
		self.cnt = 1;
		return;
	}
};

void() tank_fade1 = [ self.frame, tank_gib2 ] 
{	
	if (self.cnt == 1)
		self.frame = 0;
	else
		self.frame = 1;
	
	setmodel(self, "progs/monsters/tank/tank_death.iqm");
	setsize(self, '-16 -16 0', '16 16 12');
	//self.scale = 1;
	self.skin = 1; 
	self.alpha = 1; 
	self.glowmod = '0.5 0.5 0.5'; 
	self.nextthink = time + 0.02;
};

void() tank_gib1 = [ self.frame, tank_gib2 ] 
{MonsterGib (self.health); self.skin = 1; self.alpha = 1; self.nextthink = time + 0.02;};

void() tank_gib2 = [ self.frame, tank_gib2 ] 
{ 	
	self.nextthink = time + 0.02;
	self.alpha -= 0.02;
	if (self.alpha <= 0)
	{
		remove(self);
		return;
	}
};

static void() tank_sfx_pain =
{
	local float r = rint(random());	

	sound(self, CHAN_VOICE, "sounds_q4/strogg/tank/tnkpain2.wav", 1, ATTN_NORM);
};

static string tank_growl_list[2] = 
{
	"sounds_q4/strogg/tank/tank_servo.wav",
	"sounds_q4/strogg/tank/tank_servo2.wav",
};	

static void() tank_sfx_growl =
{
	local float r = rint(random());	

	sound(self, CHAN_BODY, tank_growl_list[r], 1, ATTN_NORM);
};

static void() tank_sfx_death =
{
//	local float r = rint(random() * 4);	

	sound(self, CHAN_VOICE, "sounds_q4/strogg/tank/death.wav", 1, ATTN_NORM);
};

static void() tank_sfx_idle =
{
	sound(self, CHAN_VOICE, "sounds_q4/strogg/tank/tnkidle1.wav", 1, ATTN_IDLE);
};

static void() tank_sfx_sight =
{   
	//local float r = rint(random() * 13);	

	sound(self, CHAN_VOICE, "sounds_q4/strogg/tank/sight1.wav", 1, ATTN_NORM);
};

/*QUAKED monster_demon (1 0 0) (-32 -32 -24) (32 32 64) Ambush

*/
void() monster_tank_cache =
{
	precache_model("progs/monsters/tank/tank.md5.info");

	precache_model("progs/monsters/tank/tank_death.iqm");
    precache_model("progs/monsters/tank/rocket_tag.md3");
    precache_model("progs/monsters/tank/cg_tag.md3");
    precache_model("progs/monsters/tank/gunjoint_tag.md3");
    precache_model("progs/monsters/tank/chop_tag.md3");
    precache_model("progs/monsters/tank/swipe_tag.md3");

    precache_sound("ounds_q4/strogg/tank/tnkidle1.wav");
    precache_sound("sounds_q4/strogg/tank/tnkdeth2.wav");
	precache_sound("sounds_q4/strogg/tank/death.wav");
	precache_sound("sounds_q4/strogg/tank/tnkdeth2.wav");
    precache_sound ("sounds_q4/strogg/tank/sight1.wav");
    precache_sound("sounds_q4/strogg/tank/tank_servo.wav");
    precache_sound("sounds_q4/strogg/tank/tank_servo2.wav");
    precache_sound("sounds_q4/strogg/tank/tnkidle1.wav");

    precache_sound("sounds_q4/strogg/tank/tnkpain2.wav");
    precache_sound("sounds_q4/strogg/tank/tank_nailgunfire.wav");
    precache_sound("sounds_q4/strogg/tank/tank_nailgunfireseq.wav");

    precache_sound("sounds_q4/strogg/tank/tank_melee1.wav");
    precache_sound("sounds_q4/strogg/tank/tank_missileloop.wav");
    precache_sound("sounds_q4/strogg/tank/tank_missilefire.wav");

    precache_sound("sounds_q4/strogg/tank/tank_prepfire.wav");
    precache_sound("sounds_q4/strogg/tank/tank_railpowerup.wav");

	precache_sound("sounds_q4/strogg/gladiator/rapidfire_01.wav");
	precache_sound("sounds_q4/strogg/gladiator/rapidfire_02.wav");
//	spawn_demon ();
};

void() monster_tank =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	monster_tank_cache ();	
	spawn_tank ();
};

void() spawn_tank =
{
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel(self, "progs/monsters/tank/tank.md5.info");
	self.classname = "monster_tank";
	setsize(self, '-32 -32 0', '32 32 88');
	self.health = 1440;
	self.max_health = 1440;
	self.mass = 2000;
	self.scale = 0.6;

	self.th_stand = tank_stand1;
	self.th_walk = tank_walk1;
	self.th_run = tank_run1;
	self.th_die = tank_die;
	self.th_melee = tank_MeleeAttack; // one of two attacks
	self.th_missile = tank_MissileAttack; // jump attack
	self.th_pain = tank_pain;
	//self.th_checkatck = GladCheckAttack;
	self.th_spawn = spawn_tank;
	self.th_dodge = tank_evade;
	self.th_sight = tank_sfx_sight;
	//setcustomskin (self, "progs/monsters/tank/gladiator.skin")
	self.deathtype = "was annihilated by a Tank";
	self.count = 0;
	self.pissed = 0;
//	self.emiteffectnum = particleeffectnum("_tank_dress");

	walkmonster_start();
};


/*
==============================================================================

DEMON

==============================================================================
*/

void(string cannon, float horz, float vert) tank_shoot_missile = 
{   
//	entity e;

	vector forward, right, up;
	AngleVectors(self.angles, forward, right, up);

	float tagindex = gettagindex (self.prelock_save, cannon);
	vector org = gettaginfo (self.prelock_save, tagindex);
	self.pos2 = org + forward*4 + up*-9;
	tank_flash ();

	//RocketNoise ();
	vector dir = normalize(self.enemy.origin - org + self.enemy.view_ofs);

	dir = dir + right * horz + up * vert;
	dir = normalize(dir);

    sound(self, CHAN_WEAPON, "sounds_q4/strogg/tank/tank_missilefire.wav", 1, ATTN_NORM);

	launch_rocket_home (self.pos2 + forward*12, dir, 800, 100, 100, 999, "EF_REVTRAIL2");
};


void(string cannon) tank_shoot_bullets = 
{   
//	entity e;
	vector f, r, u;
	AngleVectors(self.angles, f, r, u);

	float tagindex = gettagindex (self.prelock_save, cannon);
	vector org = gettaginfo (self.prelock_save, tagindex);
	self.pos2 = org + u*-9;
	tank_flash ();

	vector dir = normalize(self.enemy.origin - org + self.enemy.view_ofs);

	//AutofireMachineEnemyNoise(); 

	dir += r * crandom() * 0.06 + u * crandom() * 0.05;
	Strogg_Bullet (self.pos2 + f *8, dir, 15, 20, 600);
	Strogg_Bullet (self.pos2 + f *8, dir, 15, 20, 1000);
};

void() tank_shoot_lasers = 
{   
//	entity e;
	vector org = self.pos2;

	//self.pos2 = org ;

	vector dir = normalize(self.enemy.origin - org + self.enemy.view_ofs);

	vector f, r, u;
	AngleVectors(self.angles, f, r, u);

	dir += r * crandom() * 0.06 + u * crandom() * 0.05;
	LaunchLaser (org, dir, '0 0 0', '0 0 0', 35);

	if (random() <= 0.5)
		sound(self, CHAN_WEAPON, "sounds_q4/strogg/gladiator/rapidfire_01.wav", 1, ATTN_NORM);
	else
		sound(self, CHAN_WEAPON, "sounds_q4/strogg/gladiator/rapidfire_02.wav", 1, ATTN_NORM);

	
	pointparticles (particleeffectnum("TE_BOLT_IMPACT_RED"), org + f*16, '0 0 0', 1);
	pointparticles (particleeffectnum("EF_MUZZLEFLASH2"), org + f*16, '0 0 0');
};

void(float kick) tank_Melee =
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

void() tank_flash = 
{   
   
    vector org;

    org = self.pos2;

    pointparticles (particleeffectnum("TE_MUZZLEFLASH2"), org, '0 0 0');
	pointparticles (particleeffectnum("EF_MUZZLEFLASH2"), org, '0 0 0');
};

void() tank_flash2 = 
{   
 	if (skill > 2)
		return;
	  
    vector org;

    org = self.pos2;

    pointparticles (particleeffectnum("TE_BOLT_IMPACT_RED"), org, '0 0 0', 4);
//	pointparticles (particleeffectnum("EF_MUZZLEFLASH2"), org, '0 0 0');
};



//===========================================================================
