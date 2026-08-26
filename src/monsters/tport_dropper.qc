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

void() teldrop_stand1 = [ 1, teldrop_stand2 ] { ai_stand(); self.monster_frame = 0;};
void() teldrop_stand2 = [ self.frame, teldrop_stand2 ] 
{ 	
	self.monster_frame ++;
	if (self.monster_frame >= 122) 
	{	
		if (random() < 0.2)
			teldrop_sfx_idle ();
		teldrop_stand1 ();
		return;
	}
	ai_stand ();
};

void() teldrop_walk1 = [ 2, teldrop_walk2 ] { ai_walk(3); self.monster_frame = 0;};
void() teldrop_walk2 = [ self.frame, teldrop_walk2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 23) 
	{   
        if (random() < 0.2)
			teldrop_sfx_idle ();
		teldrop_walk1 ();
		return;
	}

	ai_walk (3);
};

void() teldrop_run1 = [ 3, teldrop_run2 ] { ai_run(self.speed); self.monster_frame = 0;};
void() teldrop_run2 = [ self.frame, teldrop_run2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 17) 
	{
		if (random() < 0.3)
			teldrop_sfx_idle();

		teldrop_run1 ();
		return;
	}

    ai_run (self.speed);
};

void() teldrop_strafel1 = [ 4, teldrop_strafel2 ] 
{ 	ai_face();  self.nextthink = time + 0.04; self.monster_frame = 0;};
void() teldrop_strafel2 = [ self.frame, teldrop_strafel2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 32) 
	{	
		//self.attack_state = AS_STRAIGHT;
		self.flags &= ~FL_DODGED;
	//	despawn_shield ();
		teldrop_run1 ();
		return;
	}

    if (self.monster_frame > 2 && self.monster_frame < 16) {
    //	ai_charge(6);
    	M_walkmove (self.ideal_yaw + 90, 6);
    }

    if (self.monster_frame > 16 && self.monster_frame < 32) {
    //	ai_charge(6);
    	M_walkmove (self.ideal_yaw - 90, 1.5);
    }

	self.nextthink = time + 0.04;
};

void() teldrop_strafer1 = [ 5, teldrop_strafer2 ] 
{ 	ai_face(); self.nextthink = time + 0.0; self.monster_frame = 0;};
void() teldrop_strafer2 = [ self.frame, teldrop_strafer2 ] 
{ 
	self.monster_frame ++;
	if (self.monster_frame >= 32) 
	{	
		//self.attack_state = AS_STRAIGHT;
		self.flags &= ~FL_DODGED;
	//	despawn_shield ();
		teldrop_run1 ();
		return;
	}

    if (self.monster_frame > 2 && self.monster_frame < 19) {
    //	ai_charge(6);
    	M_walkmove (self.ideal_yaw - 90, 6);
    }

    if (self.monster_frame > 19 && self.monster_frame < 32) {
    //	ai_charge(6);
    	M_walkmove (self.ideal_yaw + 90, 1.5);
    }

	self.nextthink = time + 0.04;
};


void() teldrop_strafe =
{	
	self.aiflags &= ~AI_FLEE;

	makevectors(self.angles);
	tracebox (self.origin, self.mins, self.maxs, self.origin + v_right * 128, FALSE, self);
	float right = trace_fraction;

	tracebox (self.origin, self.mins, self.maxs, self.origin + v_right * -128, FALSE, self);
	float left = trace_fraction;

	if (left == 1 && right == 1)
	{   
     //   teldrop_sfx_growl ();
		if (random() <= 0.5)
			teldrop_strafel1 ();
		else 
			teldrop_strafer1 ();
		return;
	}

	if (left == 1)
		{teldrop_strafel1 (); }
	else if (right == 1)
		{teldrop_strafer1 (); }

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

void() teldrop_hide1_0 = [ 13, teldrop_hide2_0 ] 
{ ai_face_oldenemy(); self.monster_frame = 0; self.nextthink = time + 0.04;};
void() teldrop_hide2_0 = [ self.frame, teldrop_hide2_0 ] 
{ 	
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	if (self.monster_frame >= 20) 
	{	
		teldrop_hide1_1 ();
		return;
	}
	ai_face_oldenemy ();
//	ai_hide ();
};

void() teldrop_hide1_1 = [ 12, teldrop_hide2_1 ] 
{ ai_hide(); self.monster_frame = 0; self.nextthink = time + 0.04;};
void() teldrop_hide2_1 = [ self.frame, teldrop_hide2_1 ] 
{ 	
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	if (self.monster_frame >= 77) 
	{	
		if (random() < 0.5)
			teldrop_sfx_idle();
		
		teldrop_hide1_1 ();
		return;
	}
	ai_hide ();
};

//==============================================================================

static void(entity target, string name) teldrop_tag_entity =
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

static void() teldrop_tag_think =
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

	if (self.netname != string_null)
	{
		float tagindex = gettagindex (self, self.netname);
		vector taginf = gettaginfo(self, tagindex);
	//bprint(ftos(self.prelock_save.traileffectnum), "\n");

		if (self.prelock_save)
		{
			self.prelock_save.origin = taginf;
	//	self.locked_enemy.origin = taginf2;
	//	bprint(vtos(taginf), "\n");
		}
		
		else
			self.owner.pos2 = taginf;
	}

	
	self.think = teldrop_tag_think;
	self.angles = self.owner.angles;
	self.nextthink = time;
}

static void(string stringg, float fr, float end, string name, string tag) teldrop_tag = 
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
		teldrop_tag_entity(e, name);

	e.netname = tag;
	e.think = teldrop_tag_think;
	e.nextthink = time;
	
	if (tag == string_null)
		self.prelock_save = e;
}

// gatling
void() teldrop_missilea1 = [ 11, teldrop_missilea2 ] {
	self.monster_frame = 0;
	teldrop_tag ("progs/monsters/teleport_dropper/cannon_tags.md3", 11, 37, string_null, string_null);
	//sound(self, CHAN_RELOAD, "sounds_q4/strogg/teleportdropper/railgun_charge.wav", 1, ATTN_NORM);
	ai_face(); self.nextthink = time + 0.04; };
void() teldrop_missilea2 = [ self.frame, teldrop_missilea2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 13)
    	teldrop_shoot(-1, "tag1");

	if (self.monster_frame == 17)
    	teldrop_shoot(1, "tag3");

	if (self.monster_frame == 24)
    	teldrop_shoot(1, "tag4");

	if (self.monster_frame == 29)
    	teldrop_shoot(-1, "tag2");

	if (self.monster_frame >= 37) 
	{	
		self.aiflags |= AI_FLEE;
		teldrop_run1 ();
		return;
	}
};

//==============================================================================

void() teldrop_meleea1 = [ 9, teldrop_meleea2 ] {
	self.monster_frame = 0;
	//teldrop_tag ("progs/monsters/teleport_dropper/melee01_tag.md3", 8, 15, "TE_WHOOSH", "tag_whoosh");
	ai_face(); self.nextthink = time + 0.04;  };
void() teldrop_meleea2 = [ self.frame, teldrop_meleea2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

	if (self.monster_frame == 16)
		teldrop_Melee();

	if (self.monster_frame >= 38) 
	{   
        teldrop_run1 ();
		return;
	}

    if (self.monster_frame < 9)
        ai_face();

    if (self.monster_frame > 9 && self.monster_frame < 18)
		ai_charge (20);

	if (self.monster_frame > 18 && self.monster_frame < 38)
		ai_move (-1.5);
};

//==============================================================================

void() teldrop_MeleeAttack =
{	
	teldrop_sfx_growl ();
    teldrop_meleea1 ();
};

void() teldrop_MissileAttack =
{   
//	bprint("goons: ",ftos(self.goons), "\n");
    if (self.goons < 2 )
	{
		teldrop_sfx_growl ();
		teldrop_missilea1 ();
		self.flags &= ~FL_MEDIC;
	}
        
};

//==============================================================================

// regular ow
void() teldrop_paina1 = [ 6, teldrop_paina2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() teldrop_paina2 = [ self.frame, teldrop_paina2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint("????", "\n");
	if (self.monster_frame >= 13) 
	{
		teldrop_run1 ();
		return;
	}
};

void() teldrop_painb1 = [ 7, teldrop_painb2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() teldrop_painb2 = [ self.frame, teldrop_painb2 ] 
{   
    //bprint(ftos(self.frame), "\n");
	self.monster_frame ++;
	self.nextthink = time + 0.04;
	// bprint(">>>>>>>>>>?????", "\n");
	if (self.monster_frame >= 13) 
	{
		teldrop_run1 ();
		return;
	}
};

// concussion
void() teldrop_painc1 = [ 8, teldrop_painc2 ] {self.monster_frame = 0; self.nextthink = time + 0.04;};
void() teldrop_painc2 = [ self.frame, teldrop_painc2 ] 
{ 
	self.monster_frame ++;
	self.nextthink = time + 0.04;

    if (self.monster_frame > 2 && self.monster_frame < 16)
        ai_move (1.5);

	// bprint("????", "\n");
	if (self.monster_frame >= 20) 
	{   
		teldrop_run1 ();
		return;
	}
};

void(entity attacker, float damage, float MOD) teldrop_pain =
{

//	bprint(ftos(MOD), "\n");
	if (self.flags & FL_DODGED)
	{	
		return;
	}

	if (self.flags & FL_MEDIC)
	{	
		self.flags &= ~FL_MEDIC;
		return;
	}

	if (self.pain_finished > time)
		return;
	
	if (self.aiflags & AI_FLEE)
	{	
		entity player = self.oldenemy;

		self.enemy = player;
		self.oldenemy = world;
		self.last_sighting = player.origin;
		self.goalentity = player;
		self.aiflags &= ~AI_FLEE;
		self.dcnt = FALSE;
		self.th_run ();
			
		self.aiflags &= ~AI_FLEE;
		return;
	}

	self.pain_finished = time + 2;
	teldrop_sfx_pain (); // sfx

	if (DMGTYPE_LTNG == MOD)
	{
  	  if (random() <= 0.5)
	        teldrop_paina1 ();
 	   else
  	      	teldrop_painb1 ();
		
		if (skill < 2)
			self.pain_finished = time + 0.5;
		else
			self.pain_finished = time + 1.5;
		return;
	}

	if (MOD == DMGTYPE_RAIL)
	{   
        teldrop_painc1 ();

		self.pain_finished = time + 2.5;
		return;
	}

	if (random()*200 > damage)
		return; // didn't flinch

	if (damage > 50 || MOD == DMGTYPE_EXP)
	{   
        teldrop_painc1 ();
		return;
	}

    if (random() <= 0.5)
        teldrop_paina1 ();
    else
        teldrop_painb1 ();
};

void() teldrop_die =
{	
	////setmodel(self, "progs/monsters/teleport_dropper/teldrop_mesh_death.iqm");
	//setsize(self, '-32 -32 0', '32 32 64');
//	self.angles = '-90 0 0';
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

	teldrop_sfx_death ();

	local vector tmpangle;
	local float tempskin;
	tmpangle = self.angles;
	tempskin = self.skin;
	

	self.think = teldrop_die1;


	self.deadflag = DEAD_DEAD;
	self.solid = SOLID_CORPSE;
//	self.movetype = MOVETYPE_STEP;
	self.nextthink = time + 0.04;

	self.angles = tmpangle;
	//self.skin = tempskin;
};

void() teldrop_die1 = [ 14 , teldrop_die2 ] { self.nextthink = time + 0.04; self.monster_frame = 0;};
void() teldrop_die2 = [ self.frame , teldrop_die2 ] 
{ 	
	//self.frame |= 0x8000;
	self.nextthink = time + 0.04;
	ai_move (-6.5);
	self.monster_frame ++;
	if (self.monster_frame == 40)
	{
		self.maxs_z = 12;
		self.nextthink = -1;
		self.think = teldrop_fade1;
		self.nextthink = time + 3.5;
		return;
	}
};

void() teldrop_fade1 = [ 0, teldrop_gib2 ] 
{	

	setmodel(self, "progs/monsters/teleport_dropper/teleport_dropper_death.iqm");
	setsize(self, '-24 -24 0', '24 24 12');

	self.skin = 0; 
	self.alpha = 1; 
	self.glowmod = '0.5 0.5 0.5'; 
	self.nextthink = time + 0.02;
};


void() teldrop_gib1 = [ self.frame, teldrop_gib2 ] 
{MonsterGib (self.health); self.skin = 1; self.alpha = 1; self.nextthink = time + 0.02;};

void() teldrop_gib2 = [ self.frame, teldrop_gib2 ] 
{ 	
	self.nextthink = time + 0.02;
	self.alpha -= 0.02;
	if (self.alpha <= 0)
	{
		remove(self);
		return;
	}
};

static void() teldrop_sfx_death =
{
	 if (random() <= 0.5)
	    sound(self, CHAN_VOICE, "sounds_q4/strogg/teleportdropper/death1.wav", 1, ATTN_NORM);
    else
        sound(self, CHAN_VOICE, "sounds_q4/strogg/teleportdropper/death2.wav", 1, ATTN_NORM);
};

static void() teldrop_sfx_idle =
{
	local float r = rint(random() * 2);	

	if (r == 1)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/teleportdropper/breath1.wav", 1, ATTN_IDLE);
	else if (r == 2)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/teleportdropper/breath2.wav", 1, ATTN_IDLE);
	else 
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/teleportdropper/breath3.wav", 1, ATTN_IDLE);
};

static void() teldrop_sfx_bite =
{
    if (random() <= 0.5)
	    sound(self, CHAN_VOICE, "sounds_q4/strogg/teleportdropper/bite1.wav", 1, ATTN_NORM);
    else
        sound(self, CHAN_VOICE, "sounds_q4/strogg/teleportdropper/bite2.wav", 1, ATTN_NORM);
};

static void() teldrop_sfx_growl =
{
	local float r = rint(random() * 3);	

	if (r == 3)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/teleportdropper/growl1.wav", 1, ATTN_NORM);
	else if (r == 2)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/teleportdropper/growl2.wav", 1, ATTN_NORM);
	else if (r == 1)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/teleportdropper/growl3.wav", 1, ATTN_NORM);
    else 
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/teleportdropper/growl4.wav", 1, ATTN_NORM);
};

static void() teldrop_sfx_pain =
{
	local float r = rint(random() * 2);	

	if (r == 2)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/teleportdropper/pain1.wav", 1, ATTN_NORM);
	else if (r == 1)
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/teleportdropper/pain2.wav", 1, ATTN_NORM);
    else 
		    sound(self, CHAN_VOICE, "sounds_q4/strogg/teleportdropper/pain3.wav", 1, ATTN_NORM);
};

static void() teldrop_sfx_sight =
{   
    if (random() <= 0.5)
	    sound(self, CHAN_VOICE, "sounds_q4/strogg/teleportdropper/alert1.wav", 1, ATTN_NORM);
    else
        sound(self, CHAN_VOICE, "sounds_q4/strogg/teleportdropper/alert2.wav", 1, ATTN_NORM);
};

/*QUAKED monster_demon (1 0 0) (-32 -32 -24) (32 32 64) Ambush

*/
void() monster_teldrop_cache =
{
	precache_model("progs/monsters/teleport_dropper/teleport_dropper.md5.info");
	precache_model("progs/monsters/teleport_dropper/teleport_dropper_death.iqm");
    precache_model("progs/monsters/teleport_dropper/cannon_tags.md3");

    precache_model("progs/monsters/teleport_dropper/pod.md3");
//    precache_model("progs/monsters/teleport_dropper/teldrop_shield_mesh.md5.info");

	precache_sound("sounds_q4/strogg/teleportdropper/alert1.wav");
    precache_sound("sounds_q4/strogg/teleportdropper/alert2.wav");
	precache_sound("sounds_q4/strogg/teleportdropper/breath1.wav");
	precache_sound("sounds_q4/strogg/teleportdropper/breath2.wav");
	precache_sound("sounds_q4/strogg/teleportdropper/breath3.wav");
	
	precache_sound("sounds_q4/strogg/teleportdropper/growl1.wav");
	precache_sound("sounds_q4/strogg/teleportdropper/growl2.wav");
	precache_sound("sounds_q4/strogg/teleportdropper/growl3.wav");
	precache_sound("sounds_q4/strogg/teleportdropper/growl4.wav");

	precache_sound("sounds_q4/strogg/teleportdropper/death1.wav");
	precache_sound("sounds_q4/strogg/teleportdropper/death2.wav");	

	precache_sound("sounds_q4/strogg/teleportdropper/pain1.wav");
	precache_sound("sounds_q4/strogg/teleportdropper/pain2.wav");
	precache_sound("sounds_q4/strogg/teleportdropper/pain3.wav");

    precache_sound("sounds_q4/strogg/teleportdropper/bite1.wav");
    precache_sound("sounds_q4/strogg/teleportdropper/bite2.wav");

//	spawn_demon ();
};

void() monster_teleport_dropper =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	monster_teldrop_cache ();	
    monster_grunt_cache ();
	spawn_teleport_dropper ();
};

.entity hide_spot;
void() spawn_hide_spot =
{
	local entity spot = spawn();
	setorigin(spot, self.origin);
	setsize(spot, '-8 -8 0', '8 8 16');

	self.hide_spot = spot;
	spot.health = 1;
};

void() spawn_teleport_dropper =
{
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	self.classname = "monster_teleport_dropper";

	setmodel(self, "progs/monsters/teleport_dropper/teleport_dropper.md5.info");

	setsize(self, '-24 -25 0', '24 24 56');
	self.health = 850;
	self.max_health = 850;
	self.mass = 300;
	self.scale = 0.7;

	self.th_stand = teldrop_stand1;
	self.th_walk = teldrop_walk1;
	self.th_run = teldrop_run1;
	self.th_die = teldrop_die;
	self.th_melee = teldrop_MeleeAttack; // one of two attacks
	self.th_missile = teldrop_MissileAttack; // jump attack
	self.th_pain = teldrop_pain;
	self.th_checkatck = Teldrop_CheckAttack;
	self.th_spawn = spawn_teleport_dropper;
	self.th_dodge = teldrop_strafe;
	self.th_sight = teldrop_sfx_sight;
	//setcustomskin (self, "progs/monsters/teleport_dropper/gladiator.skin")
	self.deathtype = "was annoyed by a Teleport Dropper";
	self.count = 0;
	self.pissed = 0;
    self.speed = 7;
    self.maxgoons = 4;
	self.dcnt = 0;
	self.hide_spot = world;

	walkmonster_start();
};


/*
==============================================================================

DEMON

==============================================================================
*/

static vector _pod_pos(vector  p, float  dist) = // q2 rerelease
{
	float theta = random(8 * M_PI);
	float phi = acos(crandom());

	vector d;
	d[0] = sin(phi) * cos(theta);
	d[1] = sin(phi) * sin(theta);
	d[2] = 0;

	return p + (d * dist);
};

void() pod_think = 
{	
	self.traileffectnum = 0;
    tracebox(self.origin, '-16 -16 0', '16 16 64', self.origin + '0 0 64', FALSE, self);
    if (trace_startsolid)
        {remove(self); self.goonmaster.goons --; return;}

    if (trace_allsolid)
        {remove(self); self.goonmaster.goons --; return;}

	if (trace_ent == self.goonmaster)
        {remove(self); self.goonmaster.goons --; return;}

    if (trace_fraction < 1)
    	{remove(self); self.goonmaster.goons --; return;}

    if (!checkbottom(self))
    	{remove(self); self.goonmaster.goons --; return;}
	
	self.mins = '-16 -16 0';
	self.maxs = '16 16 64';
	SUB_KillBox (self);
    self.origin[2] += 8;
    self.think = monster_grunt;
    self.nextthink = time;
	self.weapontype = 0;
	spawn_tfog (self.origin + '0 0 16');
};

void(float num, string cannon) teldrop_shoot = 
{   
    if (self.goons >= self.maxgoons )
        return;

//    bprint("wah", "\n");
	vector pos = _pod_pos(self.origin, 256);
    vector dir = normalize(pos - self.origin);

	if (num > 0)
	{
		if (dir[0] < 0)
			dir[0] *= -1;

		if (dir[1] < 0)
			dir[1] *= -1;
	}

	if (num < 0)
	{
		if (dir[0] > 0)
			dir[0] *= -1;

		if (dir[1] > 0)
			dir[1] *= -1;
	}

    local entity pod;
    pod = spawn();
    pod.solid = SOLID_BBOX;

	float tagindex = gettagindex (self.prelock_save, cannon);
	vector org = gettaginfo (self.prelock_save, tagindex);

    setorigin(pod, org);
	pointparticles (particleeffectnum("TE_MUZZLEFLASH2"), org, '0 0 0');

    setmodel (pod, "progs/monsters/teleport_dropper/pod.md3");
    setsize(pod, VEC_ORIGIN, VEC_ORIGIN);
    pod.movetype = MOVETYPE_TOSS;
    pod.scale = 1;
	pod.traileffectnum = particleeffectnum("EF_POD");
    
    makevectors(dir);
    pod.velocity = dir * 150;
    pod.velocity += v_up * 300;
    self.goons ++;
    pod.nextthink = time + 1;
    pod.think = pod_think;
    pod.goonmaster = self;
    pod.enemy = self.enemy;
	pod.flags |= FL_RESURRECTED;
};

void(float base = 20, float kick = 10, float range = 100) teldrop_Melee =
{
	float ldmg;

	ai_face();

	ldmg = base + 10*(random() + random());
	//if (self.pissed > 0.4)
	//	ldmg *= (1 + self.pissed - 0.3);

	vector	aim;

	aim = setvector (100, 0, 0);
	if (fire_hit(aim, rint(ldmg), kick))
	{	
		teldrop_sfx_bite (); 
	}
	else
	{
		meat_miss();

	//	self.pissed += 0.3; 
	}

	if (self.goons > 1)
		self.aiflags |= AI_FLEE;
};

void() teldrop_flash = 
{   
   
    vector org;

    org = self.pos2;

    pointparticles (particleeffectnum("TE_MUZZLEFLASH2"), org, '0 0 0');
	pointparticles (particleeffectnum("EF_MUZZLEFLASH2"), org, '0 0 0');
};

//===========================================================================

float() Teldrop_CheckAttack =
{
	local vector	spot1, spot2;	
	local entity	targ, player;
	local float		chance;

	targ = self.enemy;

	if (self.aiflags & AI_FLEE)
	{	
		player = self.oldenemy;

		if ((self.goons < 2) || (range(player) == RANGE_MELEE))
		{
			self.enemy = player;
			self.oldenemy = world;
			self.last_sighting = player.origin;
			self.goalentity = player;
			self.aiflags &= ~AI_FLEE;

			if (self.goons < 2)
				self.flags |= FL_MEDIC;

			self.dcnt = FALSE;
			self.th_run ();
			SUB_AttackFinished (1 + 5*random());
			return TRUE;
		}

		if (vlen(self.origin - targ.origin) <= 80 && self.dcnt == FALSE)
		{	
			teldrop_hide1_0 ();
			self.dcnt = TRUE;
			return TRUE;
		}

		return FALSE;
	}

	if (enemy_range == RANGE_MELEE)
	{	
		// see if any entities are in the way of the shot
		spot1 = self.origin + self.view_ofs;
		spot2 = targ.origin + targ.view_ofs;

		traceline (spot1, spot2, FALSE, self);
	
		if (trace_ent != targ)
			return FALSE;		// don't have a clear shot

		if (trace_inopen && trace_inwater)
			return FALSE;			// sight line crossed contents

		self.attack_state = AS_MELEE;

		return TRUE;
	}

// missile attack

	if (!self.hide_spot && (time > self.attack_finished - 0.6)) 
		spawn_hide_spot ();

	if (time < self.attack_finished)
		return FALSE;
		
	if (self.flags & FL_DODGED)
		return FALSE;
		
	if (enemy_range == RANGE_FAR)
		return FALSE;
		
	if (enemy_range == RANGE_MELEE)
		chance = 0.06;
	else if (enemy_range == RANGE_CLOSE)
		chance = 0.15;
	else if (enemy_range == RANGE_NEAR)
		chance = 0.2;
	else if (enemy_range == RANGE_MID)
		chance = 0.06;
	else
		return FALSE;

	if (skill == 0)
		chance *= 0.5;
	if (skill >= 2)
		chance *= 1.5;

	if (random () < chance)
	{
		self.attack_state = AS_MISSILE;
		SUB_AttackFinished (1 + 2*random());
		return TRUE;
	}

	return FALSE;
};
