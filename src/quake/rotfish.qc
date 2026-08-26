
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
$cd /raid/quake/id1/models/fish
$origin 0 0 24
$base base
$skin skin

$frame attack1 attack2 attack3 attack4 attack5 attack6
$frame attack7 attack8 attack9 attack10 attack11 attack12 attack13
$frame attack14 attack15 attack16 attack17 attack18

$frame death1 death2 death3 death4 death5 death6 death7
$frame death8 death9 death10 death11 death12 death13 death14 death15
$frame death16 death17 death18 death19 death20 death21

$frame swim1 swim2 swim3 swim4 swim5 swim6 swim7 swim8
$frame swim9 swim10 swim11 swim12 swim13 swim14 swim15 swim16 swim17
$frame swim18

$frame pain1 pain2 pain3 pain4 pain5 pain6 pain7 pain8
$frame pain9

void() swimmonster_start;

void() rotf_stand1  = [ $swim1, rotf_stand2 ] { ai_stand(); };
void() rotf_stand2  = [ $swim2, rotf_stand3 ] { ai_stand(); };
void() rotf_stand3  = [ $swim3, rotf_stand4 ] { ai_stand(); };
void() rotf_stand4  = [ $swim4, rotf_stand5 ] { ai_stand(); };
void() rotf_stand5  = [ $swim5, rotf_stand6 ] { ai_stand(); };
void() rotf_stand6  = [ $swim6, rotf_stand7 ] { ai_stand(); };
void() rotf_stand7  = [ $swim7, rotf_stand8 ] { ai_stand(); };
void() rotf_stand8  = [ $swim8, rotf_stand9 ] { ai_stand(); };
void() rotf_stand9  = [ $swim9, rotf_stand10  ] { ai_stand(); };
void() rotf_stand10 = [ $swim10, rotf_stand11 ] { ai_stand(); };
void() rotf_stand11 = [ $swim11, rotf_stand12 ] { ai_stand(); };
void() rotf_stand12 = [ $swim12, rotf_stand13 ] { ai_stand(); };
void() rotf_stand13 = [ $swim13, rotf_stand14 ] { ai_stand(); };
void() rotf_stand14 = [ $swim14, rotf_stand15 ] { ai_stand(); };
void() rotf_stand15 = [ $swim15, rotf_stand16 ] { ai_stand(); };
void() rotf_stand16 = [ $swim16, rotf_stand17 ] { ai_stand(); };
void() rotf_stand17 = [ $swim17, rotf_stand18 ] { ai_stand(); };
void() rotf_stand18 = [ $swim18, rotf_stand1 ] { ai_stand(); };

void() rotf_walk1  = [ $swim1, rotf_walk2 ] { ai_walk(8); };
void() rotf_walk2  = [ $swim2, rotf_walk3 ] { ai_walk(8); };
void() rotf_walk3  = [ $swim3, rotf_walk4 ] { ai_walk(8); };
void() rotf_walk4  = [ $swim4, rotf_walk5 ] { ai_walk(8); };
void() rotf_walk5  = [ $swim5, rotf_walk6 ] { ai_walk(8); };
void() rotf_walk6  = [ $swim6, rotf_walk7 ] { ai_walk(8); };
void() rotf_walk7  = [ $swim7, rotf_walk8 ] { ai_walk(8); };
void() rotf_walk8  = [ $swim8, rotf_walk9 ] { ai_walk(8); };
void() rotf_walk9  = [ $swim9, rotf_walk10  ] { ai_walk(8); };
void() rotf_walk10 = [ $swim10, rotf_walk11 ] { ai_walk(8); };
void() rotf_walk11 = [ $swim11, rotf_walk12 ] { ai_walk(8); };
void() rotf_walk12 = [ $swim12, rotf_walk13 ] { ai_walk(8); };
void() rotf_walk13 = [ $swim13, rotf_walk14 ] { ai_walk(8); };
void() rotf_walk14 = [ $swim14, rotf_walk15 ] { ai_walk(8); };
void() rotf_walk15 = [ $swim15, rotf_walk16 ] { ai_walk(8); };
void() rotf_walk16 = [ $swim16, rotf_walk17 ] { ai_walk(8); };
void() rotf_walk17 = [ $swim17, rotf_walk18 ] { ai_walk(8); };
void() rotf_walk18 = [ $swim18, rotf_walk1 ] { ai_walk(8); };

void() rotf_run1  = [ $swim1, rotf_run2 ]
{
	ai_run(12);
	//	sound(self, CHAN_VOICE, "fish/idle.wav", 1, ATTN_NORM);
};
void() rotf_run2  = [ $swim3, rotf_run3 ] { ai_run(12); };
void() rotf_run3  = [ $swim5, rotf_run4 ] { ai_run(12); };
void() rotf_run4  = [ $swim7, rotf_run5 ] { ai_run(12); };
void() rotf_run5  = [ $swim9, rotf_run6 ] { ai_run(12); };
void() rotf_run6  = [ $swim11, rotf_run7 ] { ai_run(12); };
void() rotf_run7  = [ $swim13, rotf_run8 ] { ai_run(12); };
void() rotf_run8  = [ $swim15, rotf_run9 ] { ai_run(12); };
void() rotf_run9  = [ $swim17, rotf_run1 ] { ai_run(12); };

void() fish_melee =
{
	vector delta;
	float ldmg;

	if (!self.enemy)
		return; // removed before stroke

	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 60)
		return;

//	sound(self, CHAN_VOICE, "fish/bite.wav", 1, ATTN_NORM);
	ldmg = (random() + random()) * 3;
	T_Damage(self.enemy, self, self.origin, self, ldmg, 2);
};

void() rotf_attack1 = [ $attack1, rotf_attack2 ] { ai_charge(10); };
void() rotf_attack2 = [ $attack2, rotf_attack3 ] { ai_charge(10); };
void() rotf_attack3 = [ $attack3, rotf_attack4 ] { fish_melee(); };
void() rotf_attack4 = [ $attack4, rotf_attack5 ] { ai_charge(10); };
void() rotf_attack5 = [ $attack5, rotf_attack6 ] { ai_charge(10); };
void() rotf_attack6 = [ $attack6, rotf_attack7 ] { ai_charge(10); };
void() rotf_attack7 = [ $attack7, rotf_attack8 ] { ai_charge(10); };
void() rotf_attack8 = [ $attack8, rotf_attack9 ] { ai_charge(10); };
void() rotf_attack9 = [ $attack9, rotf_attack10 ] { fish_melee(); };
void() rotf_attack10 = [ $attack10, rotf_attack11 ] { ai_charge(10); };
void() rotf_attack11 = [ $attack11, rotf_attack12 ] { ai_charge(10); };
void() rotf_attack12 = [ $attack12, rotf_attack13 ] { ai_charge(10); };
void() rotf_attack13 = [ $attack13, rotf_attack14 ] { ai_charge(10); };
void() rotf_attack14 = [ $attack14, rotf_attack15 ] { ai_charge(10); };
void() rotf_attack15 = [ $attack15, rotf_attack16 ] { fish_melee(); };
void() rotf_attack16 = [ $attack16, rotf_attack17 ] { ai_charge(10); };
void() rotf_attack17 = [ $attack17, rotf_attack18 ] { ai_charge(10); };
void() rotf_attack18 = [ $attack18, rotf_run1 ] { ai_charge(10); };

void() rotf_death1 = [ $death1, rotf_death2 ]
{
	self.solid = SOLID_NOT; 
//	sound(self, CHAN_VOICE, "fish/death.wav", 1, ATTN_NORM);
};
void() rotf_death2 = [ $death2, rotf_death3 ] {};
void() rotf_death3 = [ $death3, rotf_death4 ] {};
void() rotf_death4 = [ $death4, rotf_death5 ] {};
void() rotf_death5 = [ $death5, rotf_death6 ] {};
void() rotf_death6 = [ $death6, rotf_death7 ] {};
void() rotf_death7 = [ $death7, rotf_death8 ] {};
void() rotf_death8 = [ $death8, rotf_death9 ] {};
void() rotf_death9 = [ $death9, rotf_death10 ] {};
void() rotf_death10 = [ $death10, rotf_death11 ] {};
void() rotf_death11 = [ $death11, rotf_death12 ] {};
void() rotf_death12 = [ $death12, rotf_death13 ] {};
void() rotf_death13 = [ $death13, rotf_death14 ] {};
void() rotf_death14 = [ $death14, rotf_death15 ] {};
void() rotf_death15 = [ $death15, rotf_death16 ] {};
void() rotf_death16 = [ $death16, rotf_death17 ] {};
void() rotf_death17 = [ $death17, rotf_death18 ] {};
void() rotf_death18 = [ $death18, rotf_death19 ] {};
void() rotf_death19 = [ $death19, rotf_death20 ] {};
void() rotf_death20 = [ $death20, rotf_death21 ] {};
void() rotf_death21 = [ $death21, rotf_death21 ] { };

void() rotf_pain1  = [ $pain1, rotf_pain2 ] {};
void() rotf_pain2  = [ $pain2, rotf_pain3 ] { ai_pain(6); };
void() rotf_pain3  = [ $pain3, rotf_pain4 ] { ai_pain(6); };
void() rotf_pain4  = [ $pain4, rotf_pain5 ] { ai_pain(6); };
void() rotf_pain5  = [ $pain5, rotf_pain6 ] { ai_pain(6); };
void() rotf_pain6  = [ $pain6, rotf_pain7 ] { ai_pain(6); };
void() rotf_pain7  = [ $pain7, rotf_pain8 ] { ai_pain(6); };
void() rotf_pain8  = [ $pain8, rotf_pain9 ] { ai_pain(6); };
void() rotf_pain9  = [ $pain9, rotf_run1 ] { ai_pain(6); };

void(entity attacker, float damage, float MOD) rotfish_pain =
{

// fish allways do pain frames
	rotf_pain1();
};



/*QUAKED monster_fish (1 0 0) (-16 -16 -24) (16 16 24) Ambush
*/
void() monster_fish =
{

	remove(self);
	return;
	
};

void() spawn_rotf =
{
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

//	setmodel(self, "progs/fish.mdl");

	setsize(self, '-16 -16 -24', '16 16 24');
	self.health = 25;

	self.th_stand = rotf_stand1;
	self.th_walk = rotf_walk1;
	self.th_run = rotf_run1;
	self.th_die = rotf_death1;
	self.th_pain = rotfish_pain;
	self.th_melee = rotf_attack1;
	self.th_spawn = spawn_rotf;	
//	self.th_sight = SightSound;
	self.deathtype ="thinks that this is a quake enemy";
	swimmonster_start();
};