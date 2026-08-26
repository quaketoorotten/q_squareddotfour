
/* ALL LIGHTS SHOULD BE 0 1 0 IN COLOR ALL OTHER ITEMS SHOULD
BE .8 .3 .4 IN COLOR */


void() SUB_regen =
{
	self.model = self.mdl;		// restore original model
	self.solid = SOLID_TRIGGER;	// allow it to be touched again
	sound (self, CHAN_VOICE, "sounds_q4/mp/misc/item_respawn.wav", 1, ATTN_NORM);	// play respawn sound
	setorigin (self, self.origin);
};



/*QUAKED noclass (0 0 0) (-8 -8 -8) (8 8 8)
prints a warning message when spawned
*/
void() noclass =
{
	dprint ("noclass spawned at");
	dprint (vtos(self.origin));
	dprint ("\n");
	remove (self);
};

void() grow_client_crosshair =
{
	msg_entity = other;
	WriteByte (MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte (MSG_MULTICAST, PICKUP);
	multicast ('0 0 0', MULTICAST_ONE);
}

/*
============
PlaceItem

plants the object on the floor
============
*/
void() PlaceItem =
{
	local float	oldz;

	self.mdl = self.model;		// so it can be restored on respawn
	self.flags = FL_ITEM;		// make extra wide
	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_TOSS;	
	self.velocity = '0 0 0';
	self.origin_z = self.origin_z + 6;
	
	oldz = self.origin_z;

	if (self.classname == "dropped_item")
		return;
	
	if (!droptofloor())
	{
		dprint ("Bonus item fell out of level at ");
		dprint (vtos(self.origin));
		dprint ("\n");
		remove(self);
		return;
	}

	if (self.think1)
	{
		self.nextthink = time + 0.2;	
		self.think = self.think1;
	}
};

/*
============
StartItem

Sets the clipping size and plants the object on the floor
============
*/
void(entity it) StartItem =
{
	it.nextthink = time + 0.2;	// items start after other solids
	it.think = PlaceItem;
};


void(void() item) DropItem = 
{	
	local entity en;
	en = spawn();
	en.origin = self.origin + '0 0 24';
	//en.velocity = self.velocity;
	//setorigin(en, self.origin + '0 0 24');

	en.solid = SOLID_TRIGGER;
	
	en.think = item;
	en.classname = "dropped_item";
	en.nextthink = time;

	en.velocity = self.velocity;
	en.flags &= ~FL_ONGROUND;

	en.movetype = MOVETYPE_TOSS;
}

/*
=========================================================================

HEALTH BOX

=========================================================================
*/
//
// T_Heal: add health to an entity, limiting health to max_health
// "ignore" will ignore max_health limit
//
float (entity e, float healamount, float ignore) T_Heal =
{
	if (e.health <= 0)
		return 0;
	if ((!ignore) && (e.health >= e.max_health))
		return 0;
	healamount = ceil(healamount);

	e.health = e.health + healamount;
	if ((!ignore) && (e.health >= e.max_health))
		e.health = e.max_health;
		
	if (e.health > 200)
		e.health = 200;
	return 1;
};

/*QUAKED item_health (.3 .3 1) (0 0 0) (32 32 32) rotten megahealth
Health box. Normally gives 25 points.
Rotten box heals 5-10 points,
megahealth will add 100 health, then 
rot you down to your maximum health limit, 
one point per second.
*/

float	H_ROTTEN = 1;
float	H_MEGA = 2;
.float	healamount, healtype;
void() health_touch;
void() item_megahealth_rot;

void() item_precaches = 
{
//	precache_model("progs/b_bh10.md3");
//	precache_model("progs/megahealth.md3");
	precache_model("progs/items/health/health.md3");

	precache_sound("items/r_item1.wav");	
	precache_sound("items/r_item2.wav");
	precache_sound("items/health1.wav");

	precache_model ("progs/items/armor/armor.md3");

	precache_model ("progs/weapons/shotgun/world.md3");
	precache_model ("progs/weapons/hyperblaster/world.md3");
	precache_model ("progs/weapons/nailgun/world.md3");
	precache_model ("progs/weapons/grenadelauncher/world.md3");
	precache_model ("progs/weapons/rocketlauncher/world.md3");
	precache_model ("progs/weapons/railgun/world.md3");
	precache_model ("progs/weapons/lightning_gun/world.md3");
	precache_model ("progs/weapons/darkmatter/world.md3");
	precache_model ("progs/weapons/machinegun/world.md3");

	precache_model ("progs/items/ammo/ammo_box.md3");

	precache_model2 ("progs/b_s_key.mdl");
	precache_model ("progs/m_s_key.mdl");
	precache_model ("progs/w_s_key.mdl");
	precache_model ("progs/m_g_key.mdl");
	precache_model ("progs/w_g_key.mdl");
	precache_model2 ("progs/b_g_key.mdl");
	
	precache_sound ("misc/medkey.wav");
	precache_sound ("misc/runekey.wav");
	precache_sound2 ("misc/basekey.wav");

	precache_model ("progs/items/power_ups/regen.md3");
	precache_sound ("sounds_q4/mp/pickups/regen_acquire.wav");
	precache_sound ("items/protect.wav");
	precache_sound ("items/protect2.wav");
	precache_sound ("items/protect3.wav");

	precache_model ("progs/suit.md3");
	precache_sound ("items/suit.wav");
	precache_sound ("items/suit2.wav");

	precache_model ("progs/items/power_ups/invis.md3");
	precache_sound ("sounds_q4/mp/pickups/invis.wav");
	precache_sound ("items/inv3.wav");

	precache_model ("progs/items/power_ups/quad.md3");
	precache_sound ("sounds_q4/mp/pickups/quad_acquire.wav");
//	precache_sound ("items/3rd_person_berserk.wav");
	precache_sound ("items/damage3.wav");
	precache_sound ("items/damage2.wav");

	precache_sound ("sounds_q4/mp/pickups/l_health.wav");
	precache_sound ("sounds_q4/mp/pickups/m_health.wav");

	precache_sound ("sounds_q4/mp/pickups/regen.wav");

	precache_sound ("items/megasphere_pickup.wav");
}


void() item_health =
{	
	self.touch = health_touch;

	if (self.spawnflags & H_ROTTEN)
	{
		setmodel(self, "progs/items/health/health.md3");
		self.noise = "sounds_q4/mp/pickups/l_health.wav";
		self.healamount = 15;
		self.healtype = 0;
		self.scale = 1.2;
		setsize (self, '-16 -16 0', '16 16 56');
	}
	else
	if (self.spawnflags & H_MEGA)
	{
		setmodel(self, "progs/items/health/health.md3");
		self.noise = "items/megasphere_pickup.wav";
		self.healamount = 100;
		self.healtype = 2;
		self.skin = 2;
		self.scale = 1.5;
		self.traileffectnum = (particleeffectnum("EF_POWERUP_LIGHT"));
		setsize (self, '-16 -16 0', '16 16 56');
	}
	else
	{
		setmodel(self, "progs/items/health/health.md3");
		self.noise = "sounds_q4/mp/pickups/m_health.wav";
		self.healamount = 25;
		self.skin = 1;
		self.healtype = 1;
		self.scale = 1.2;
		setsize (self, '-16 -16 0', '16 16 56');
	}
	
	setorigin (self, self.origin + '16 16 0');
	self.modelflags |= MF_ROTATE;
	
	StartItem (self);
};


void() health_touch =
{
//	local	float amount;
	local	string	s;
	
	if (other.classname != "player")
		return;
	
	if (self.healtype == 2) // Megahealth?  Ignore max_health...
	{
		if (other.health >= 250)
			return;
		if (!T_Heal(other, self.healamount, 1))
			return;
	}
	else
	{
		if (!T_Heal(other, self.healamount, 0))
			return;
	}
	
	sprint(other, "You receive ");
	s = ftos(self.healamount);
	sprint(other, s);
	sprint(other, " health\n");
	
// health touch sound
	sound(other, CHAN_ITEM, self.noise, 1, ATTN_NORM);

	stuffcmd (other, "bf\n");
	
	self.model = string_null;
	self.solid = SOLID_NOT;
	self.emiteffectnum = 0;

	// Megahealth = rot down the player's super health
	if (self.healtype == 2)
	{
		self.nextthink = time + 5;
		self.think = item_megahealth_rot;
		other.megahealth_finished = 1;
		other.megahealth_time = time + 5;
	}
	else
	{
		if (deathmatch != 2)		// deathmatch 2 is the silly old rules
		{
			if (deathmatch)
				self.nextthink = time + 20;
			self.think = SUB_regen;
		}
	}
	
	grow_client_crosshair ();

	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};	

void() item_megahealth_rot =
{
	if (deathmatch == 1)	// deathmatch 2 is silly old rules
	{
		self.nextthink = time + 20;
		self.think = SUB_regen;
	}
	else
		self.nextthink = -1;
};

/*
===============================================================================

ARMOR

===============================================================================
*/
.float armorbit;

void() armor_touch = 
{
	local float value, bit, type;
	local float oldvalue, oldbit, oldtype;

	if (other.health <= 0)
		return;
	if (other.classname != "player")
		return;

	value = self.armorvalue;
	bit = self.armorbit;
	type = self.armortype;
	
	if (other.armorvalue > 0)
	{
		oldtype = other.armortype;
		oldvalue = other.armorvalue;
		oldbit = other.armorbit;
	}

	if (!oldtype)
		value = value;
	
	else if (type > oldtype)
	{	
		value = value + ((oldtype / self.armortype) * oldvalue);
		type = type;
	}
	else
	{
		value = oldvalue + ((type / oldtype) * value);
		type = oldtype;
	}
	
	if(oldbit > bit)
	{
		if(oldvalue > 0)
			bit = oldbit;
		else
			bit = bit;
	}

	if(other.armorvalue >= 200) return;
		
	other.armortype = type;
	other.armorvalue = floor(value);

	if (other.armorvalue > 200)
		other.armorvalue = 200;
	
	other.items = other.items - (other.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3)) + bit;
	other.armorbit = bit;

	self.solid = SOLID_NOT;
	self.model = string_null;
	if (deathmatch == 1)
		self.nextthink = time + 20;
	self.think = SUB_regen;

	sprint(other, "You got armor\n");
// armor touch sound
	sound(other, CHAN_ITEM, "sounds_q4/mp/pickups/armor.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	
	grow_client_crosshair ();

	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};

/*QUAKED item_armor1 (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() item_armor1 =
{
	self.touch = armor_touch;
	setmodel (self, "progs/items/armor/armor.md3");
	self.skin = 0;
	self.armortype = 0.3;
	self.armorvalue = 50;
	self.armorbit = IT_ARMOR1;
	self.modelflags |= MF_ROTATE;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem (self);
};

/*QUAKED item_armor2 (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() item_armor2 =
{
	self.touch = armor_touch;
	setmodel (self, "progs/items/armor/armor.md3");
	self.skin = 1;
	self.armortype = 0.6;
	self.armorvalue = 100;
	self.armorbit = IT_ARMOR2;
	self.modelflags |= MF_ROTATE;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem (self);
};

/*QUAKED item_armorInv (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() item_armorInv =
{
	self.touch = armor_touch;
	setmodel (self, "progs/items/armor/armor.md3");
	self.skin = 2;
	self.armortype = 0.9;
	self.armorvalue = 150;
	self.armorbit = IT_ARMOR3;
	self.modelflags |= MF_ROTATE;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem (self);
};

/*
===============================================================================

WEAPONS

===============================================================================
*/

void() bound_other_ammo =
{	
	if (other.ammo_shells > MAX_SHELLS)
		other.ammo_shells = MAX_SHELLS;
	if (other.ammo_nails > MAX_NAILS)
		other.ammo_nails = MAX_NAILS;
	if (other.ammo_rockets > MAX_ROCKETS)
		other.ammo_rockets = MAX_ROCKETS;		
	if (other.ammo_cells > MAX_CELLS)
		other.ammo_cells = MAX_CELLS;		
	if (other.ammo_coils > MAX_COILS)
		other.ammo_coils = MAX_COILS;	
	if (other.ammo_grenades > MAX_GRENADES)
		other.ammo_grenades = MAX_GRENADES;	
	if (other.ammo_bullets > MAX_BULLETS)
		other.ammo_bullets = MAX_BULLETS;	
	if (other.ammo_slugs > MAX_SLUGS)
		other.ammo_slugs = MAX_SLUGS;	

	if (other.savedammo_shells <= 0)
		other.savedammo_shells += self.savedammo_shells;
	if (other.savedammo_nails <= 0)
		other.savedammo_nails += self.savedammo_nails;
	if (other.savedammo_rockets <= 0) 
		other.savedammo_rockets += self.savedammo_rockets;	
	if (other.savedammo_cells <= 0) 
		other.savedammo_cells += self.savedammo_cells;	

//	if (other.savedammo_shells2 <= 0)
//		other.savedammo_shells2 += self.savedammo_shells2;
	if (other.savedammo_bullets <= 0)
		other.savedammo_bullets += self.savedammo_bullets;	
	if (other.savedammo_slugs <= 0)
		other.savedammo_slugs += self.savedammo_slugs;	
	if (other.savedammo_grenades <= 0)
		other.savedammo_grenades += self.savedammo_grenades;	
};

/*
=============
Deathmatch_Weapon

Deathmatch weapon change rules for picking up a weapon

.float		ammo_shells, ammo_nails, ammo_rockets, ammo_cells;
=============
*/

/*void(float oldid, float newid) Deathmatch_Weapon =
{
	local float or, nr;

	if (self.super_damage_finished)
		return;

// change self.weapon if desired
	or = RankForWeapon (oldid);
	nr = RankForWeapon (newid);
	if ( nr < or )
	{
		self.newweaponid = newid;
		self.weaponstate = WEAPON_DEACTIVATE;	
		player_run(); // get out of any fire states
	}
};*/

void(float old, float new, float newid) SinglePlayer_Weapon =
{
	if ((old & new)) // already have this weapon
		return;

	self.newweaponid = newid;
	self.weaponstate = WEAPON_DEACTIVATE;	
	player_run(); // get out of any fire states
};

/*
=============
weapon_touch
=============
*/
//float() W_BestWeapon;

void() weapon_touch =
{
	local	float	new, old;
	local	entity	stemp;
	local	float	leave;
	local float modifier = 1;

	if (!(other.flags & FL_CLIENT))
		return;

	weapon_info_generic gun = getweaponinfo[self.weaponid];
	new = getweaponbit(self.weaponid);	

// if the player was using his best weapon, change up to the new one if better		
	stemp = self;
	self = other;
	//best = W_BestWeapon();
	self = stemp;

	if (deathmatch == 2 || coop)
		leave = 1;
	else
		leave = 0;

	if (leave && (other.items & new))
		return;
	
	sprint (other, "You got ");

	if (other.items & new)
		sprint (other, self.netname2);
	else
		sprint (other, self.netname);

	sprint (other, "\n");
// weapon touch sound
	sound (other, CHAN_ITEM, "sounds_q4/mp/pickups/weapon.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

// change to the weapon
	old = other.items;
	other.items = other.items | new;
	
	if (old & new)
		modifier = 0.5;

	other.ammo_shells += self.ammo_shells * modifier;
	other.ammo_nails += self.ammo_nails * modifier;
	other.ammo_rockets += self.ammo_rockets * modifier;
	other.ammo_cells += self.ammo_cells * modifier;
	other.ammo_bullets += self.ammo_bullets * modifier;
	other.ammo_coils += self.ammo_coils * modifier;
	other.ammo_grenades += self.ammo_grenades * modifier;
	other.ammo_slugs += self.ammo_slugs * modifier;
	other.ammo_dmc += self.ammo_dmc * modifier;

	bound_other_ammo ();
	float newid = self.weaponid;
	
	grow_client_crosshair ();

	stemp = self;
	self = other;
	
	if (self.weapon != new && self.weaponid != newid)	
	{	
		//if (!deathmatch)
			SinglePlayer_Weapon (old, new, newid);
		//else
			//Deathmatch_Weapon (self.oldweaponid, newid);
	}

	self = stemp;

	if (leave)
		return;
	
// remove it in single player, or setup for respawning in deathmatch
	self.model = string_null;
	self.solid = SOLID_NOT;
	if (deathmatch == 1)
		self.nextthink = time + 30;
	self.think = SUB_regen;
	
	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};

float weapon_ranks[8] = // not real ranking, just linear progression
{
	3, // shotgun
	4, // hyperblaster
	5, // grenade launcher
	6, // nailgun
	7, // rocket launcher
	9, // lightning gun
	8, // railgun
	10, // dmg
};

/*QUAKED weapon_supershotgun (0 .5 .8) (-16 -16 0) (16 16 32)
*/

.string netname2;

void() weapon_supershotgun =
{	
	setmodel (self, "progs/weapons/shotgun/world.md3");
	self.netname = "the Shotgun";
	self.netname2 = "some Shells";
	self.touch = weapon_touch;
	self.modelflags = MF_ROTATE;
	self.ammo_shells = 10;
	self.weaponid = 3;
	self.savedammo_shells = 5;

	self.colormod = '1 0.50196 0';
	self.colormod *= 3;

	setsize (self, '-16 -16 0', '16 16 56');
	StartItem (self);
};


/*QUAKED weapon_nailgun (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_nailgun =
{
	setmodel (self, "progs/weapons/hyperblaster/world.md3");
	self.netname = "the Hyperblaster";
	self.netname2 = "some Cells";
	self.touch = weapon_touch;
	self.modelflags = MF_ROTATE;
	self.ammo_cells = 40;
	self.weaponid = 4;
	self.savedammo_cells = 40;

	self.colormod =  '0  0.45098  1';
	self.colormod *= 3;

	setsize (self, '-16 -16 0', '16 16 56');
	StartItem (self);
};

void() weapon_hyperblaster =
{
	setmodel (self, "progs/weapons/hyperblaster/world.md3");
	self.netname = "the Hyperblaster";
	self.netname2 = "some Cells";
	self.touch = weapon_touch;
	self.modelflags = MF_ROTATE;
	self.ammo_cells = 40;
	self.weaponid = 4;
	self.savedammo_cells = 40;

	self.colormod =  '0  0.45098  1';
	self.colormod *= 3;

	setsize (self, '-16 -16 0', '16 16 56');
	StartItem (self);
};

/*QUAKED weapon_supernailgun (0 .5 .8) (-16 -16 0) (16 16 32)
*/
void() w_ng_decide = 
{	
	if (!deathmatch && !coop)
	{	
		float bit = getweaponbit(self.weaponid);
		entity player = find(world, classname, "player");
		if (player.items & bit)
		{
			weapon_rocketlauncher();
			return;
		}

		if ((player.items & bit) && (player.items & 1<<7))
		{
			if (random() <= 0.5)
			{
				weapon_rocketlauncher();
				return;			
			}
		}
	}
}

void() weapon_supernailgun =
{	
	self.weaponid = 6;

	setmodel (self, "progs/weapons/nailgun/world.md3");
	self.netname = "the Nailgun";
	self.netname2 = "some Nails";
	self.touch = weapon_touch;
	self.modelflags = MF_ROTATE;
	self.ammo_nails = 25;

	self.savedammo_nails = 50;

	self.colormod = '0.6  0.8  0.8';
	self.colormod *= 3;
	self.think1 = w_ng_decide;

	setsize (self, '-16 -16 0', '16 16 56');
	StartItem (self);
};

void() weapon_nailgun2 =
{	
	self.weaponid = 6;

	setmodel (self, "progs/weapons/nailgun/world.md3");
	self.netname = "the Nailgun";
	self.netname2 = "some Nails";
	self.touch = weapon_touch;
	self.modelflags = MF_ROTATE;
	self.ammo_nails = 25;

	self.savedammo_nails = 50;

	self.colormod = '0.6  0.8  0.8';
	self.colormod *= 3;
	//self.think1 = w_ng_decide;

	setsize (self, '-16 -16 0', '16 16 56');
	StartItem (self);
};

/*QUAKED weapon_grenadelauncher (0 .5 .8) (-16 -16 0) (16 16 32)
*/
void() weapon_grenadelauncher =
{
	setmodel (self, "progs/weapons/grenadelauncher/world.md3");
	self.netname = "the Grenade Launcher";
	self.netname2 = "some Nades";
	self.touch = weapon_touch;
	self.modelflags = MF_ROTATE;
	self.ammo_grenades = 10;
	self.weaponid = 5;
	self.savedammo_grenades = 5;

	self.colormod = '0.2  0.56078  0.07059';
	self.colormod *= 3;

	setsize (self, '-16 -16 0', '16 16 56');
	StartItem (self);
};

/*QUAKED weapon_rocketlauncher (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() w_rl_decide = 
{
	if (!deathmatch && !coop)
	{	
		float bit = getweaponbit(self.weaponid);
		entity player = find(world, classname, "player");
		if (player.items & bit)
		{
			weapon_railgun();
			return;
		}

		if ((player.items & bit) && (player.items & 1<<8))
		{
			if (random() <= 0.5)
			{
				weapon_railgun();
				return;			
			}
		}
	}
};

void() weapon_rocketlauncher =
{	
	self.weaponid = 7;

	setmodel (self, "progs/weapons/rocketlauncher/world.md3");
	self.netname = "the Rocket Launcher";
	self.netname2 = "some Rockets";
	self.touch = weapon_touch;
	self.modelflags = MF_ROTATE;
	self.ammo_rockets = 7;
	self.savedammo_rockets = 3;

	self.colormod = '1 0 0';
	self.colormod *= 3;
	self.think1 = w_rl_decide;

	setsize (self, '-16 -16 0', '16 16 56');
	StartItem (self);
};

void() weapon_rocketlauncher2 =
{	
	self.weaponid = 7;

	setmodel (self, "progs/weapons/rocketlauncher/world.md3");
	self.netname = "the Rocket Launcher";
	self.netname2 = "some Rockets";
	self.touch = weapon_touch;
	self.modelflags = MF_ROTATE;
	self.ammo_rockets = 7;
	self.savedammo_rockets = 3;

	self.colormod = '1 0 0';
	self.colormod *= 3;
//	self.think1 = w_rl_decide;

	setsize (self, '-16 -16 0', '16 16 56');
	StartItem (self);
};

/*QUAKED weapon_lightning (0 .5 .8) (-16 -16 0) (16 16 32)
*/

void() weapon_railgun =
{	
	setmodel (self, "progs/weapons/railgun/world.md3");
	self.netname = "the Railgun";
	self.netname2 = "some Slugs";
	self.touch = weapon_touch;
	self.modelflags = MF_ROTATE;
	self.ammo_slugs = 12;
	self.weaponid = 8;
	self.savedammo_slugs = 3;

	self.colormod = '0 .98039 0';
	self.colormod *= 3;

	setsize (self, '-16 -16 0', '16 16 56');
	StartItem (self);
};

void() w_lg_decide = 
{
	if (!deathmatch && !coop)
	{	
		float bit = getweaponbit(self.weaponid);
		entity player = find(world, classname, "player");
		if (player.items & bit)
		{
			weapon_dmg();
			return;
		}

		if ((player.items & bit) && (player.items & 1<<10))
		{
			if (random() < 0.3)
			{
				weapon_dmg();
				return;			
			}
		}
	}

};

void() weapon_lightning =
{	
	self.weaponid = 9;

	setmodel (self, "progs/weapons/lightning_gun/world.md3");
	self.netname = "the Lightning Gun";
	self.netname2 = "some Coils";
	self.touch = weapon_touch;
	self.modelflags = MF_ROTATE;
	self.ammo_coils = 100;
	self.weaponid = 9;

	self.think1 = w_lg_decide;

	self.colormod = '1  1  0.72941';
	self.colormod *= 3;

//	self.savedammo_cells = 25;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem (self);
};

void() weapon_lightning2 =
{	
	self.weaponid = 9;

	setmodel (self, "progs/weapons/lightning_gun/world.md3");
	self.netname = "the Lightning Gun";
	self.netname2 = "some Coils";
	self.touch = weapon_touch;
	self.modelflags = MF_ROTATE;
	self.ammo_coils = 100;
	self.weaponid = 9;

	//self.think1 = w_lg_decide;

	self.colormod = '1  1  0.72941';
	self.colormod *= 3;

//	self.savedammo_cells = 25;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem (self);
};

void() weapon_dmg =
{
	setmodel (self, "progs/weapons/darkmatter/world.md3");
	self.netname = "the Disintergrator";
	self.netname2 = "a darkmatter core";
	self.modelflags = MF_ROTATE;
	self.touch = weapon_touch;
	self.ammo_dmc = 3;
	self.savedammo_dmc = 1;
	self.weaponid = 10;

	self.colormod = ' 0.76863  0  1';
	self.colormod *= 3;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem (self);
};


/*
===============================================================================

AMMO

===============================================================================
*/

float COMMON = 1;
float UNCOMMON = 2;
float RARE = 3;
float SCACRE = 4;

void() ammo_touch =
{
local entity	stemp;
	
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;
	
// if the player was using his best weapon, change up to the new one if better		
	stemp = self;
	self = other;
	//best = W_BestWeapon();
	self = stemp;

	if (self.ammo_bullets > 0)
	{
		if (other.ammo_bullets >= MAX_BULLETS)
			return;

		other.ammo_bullets += self.ammo_bullets;
	}

	if (self.ammo_shells > 0)
	{
		if (other.ammo_shells >= MAX_SHELLS)
			return;

		other.ammo_shells += self.ammo_shells;
	}

	if (self.ammo_cells > 0)
	{
		if (other.ammo_cells >= MAX_CELLS)
			return;

		other.ammo_cells += self.ammo_cells;
	}

	if (self.ammo_grenades > 0) 
	{
		if (other.ammo_grenades >= MAX_GRENADES)
			return;

		other.ammo_grenades += self.ammo_grenades;
	}

	if (self.ammo_nails > 0)
	{
		if (other.ammo_nails >= MAX_NAILS)
			return;

		other.ammo_nails += self.ammo_nails;
	}

	if (self.ammo_rockets > 0)
	{
		if (other.ammo_rockets >= MAX_ROCKETS)
			return;

		other.ammo_rockets += self.ammo_rockets;
	}

	if (self.ammo_slugs > 0)
	{
		if (other.ammo_slugs >= MAX_SLUGS)
			return;

		other.ammo_slugs += self.ammo_slugs;
	}

	if (self.ammo_coils > 0)
	{
		if (other.ammo_coils >= MAX_COILS)
			return;

		other.ammo_coils += self.ammo_coils;
	}

	
	if (self.ammo_dmc > 0)
	{
		if (other.ammo_dmc >= MAX_CORES)
			return;

		other.ammo_dmc += self.ammo_dmc;

	}

	bound_other_ammo ();

	if (other.weaponname == "weapon_lightninggun")
		other.currentammo = other.ammo_coils;
	
	sprint (other, "You got ");
	sprint (other, self.netname);
	sprint (other, "\n");
// ammo touch sound
	sound (other, CHAN_ITEM, "sounds_q4/items/ammo/default.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

	grow_client_crosshair ();

// remove it in single player, or setup for respawning in deathmatch
	self.model = string_null;
	self.solid = SOLID_NOT;
	if (deathmatch == 1)
		self.nextthink = time + 30;
	self.think = SUB_regen;

	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};




float WEAPON_BIG2 = 1;

/*QUAKED item_shells (0 .5 .8) (0 0 0) (32 32 32) big
*/

void(float f, string name) item_placeholder = 
{	
	local entity it;
	it = spawn();

	setmodel(it,"progs/items/ammo/ammo_box.md3");
	it.touch = ammo_touch;
	setorigin(it, self.origin);
	it.frame = f;

	setsize (it, '0 0 0', '32 32 56');

	if (name == "Bullets") {
		it.ammo_bullets = self.ammo_bullets; it.skin = 0; }

	if (name == "Shells") {
		it.ammo_shells = self.ammo_shells; it.skin = 1; }
	
	if (name == "Cells") {
		it.ammo_cells = self.ammo_cells; it.skin = 2; }

	if (name == "Nades") {
		it.ammo_grenades = self.ammo_grenades; it.skin = 3; }

	if (name == "Nails") {
		it.ammo_nails = self.ammo_nails; it.skin = 4; }

	if (name == "Rockets") {
		it.ammo_rockets = self.ammo_rockets; it.skin = 5; }

	if (name == "Slugs") {
		it.ammo_slugs = self.ammo_slugs; it.skin = 6; }

	if (name == "Coils") {
		it.ammo_coils = self.ammo_coils; it.skin = 7; }

	if (name == "Dark-matter Cores") {
		it.ammo_dmc = self.ammo_dmc; it.skin = 8; }

	it.netname = name;
	it.scale = 1.2;
	StartItem (it);
}

void() item_shells =
{
	if (self.spawnflags & WEAPON_BIG2)
	{
		//self.netname = "multiple shells and bullets";
		self.ammo_bullets = 100;
		self.ammo_shells = 20;
	}
	else
	{
		//self.netname = "some shells and bullets";
		self.ammo_bullets = 75;
		self.ammo_shells = 15;
	}
	
	item_placeholder (0, "Bullets");
	item_placeholder (1, "Shells"); 

	setmodel (self, "");
	setsize (self, '0 0 0', '32 32 56');

	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_TOSS;
	self.origin_z = self.origin_z + 6;
	droptofloor ();
};

/*QUAKED item_spikes (0 .5 .8) (0 0 0) (32 32 32) big
*/

void() item_spikes =
{
	if (self.spawnflags & WEAPON_BIG2)
	{
		//self.netname = "multiple cells, nades and coils";
		self.ammo_cells = 100;
		self.ammo_grenades = 10;
		self.ammo_coils = 60;
	}
	else
	{
		//self.netname = "some cells, nades and coils";
		self.ammo_cells = 50;
		self.ammo_grenades = 7;
		self.ammo_coils = 30;
	}
	
	item_placeholder ( 0, "Cells");
	item_placeholder ( 1, "Nades"); 
	item_placeholder ( 2, "Coils"); 

	setmodel (self, "");
	setsize (self, '0 0 0', '32 32 56');

	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_TOSS;
	self.origin_z = self.origin_z + 6;
	droptofloor ();
};

/*QUAKED item_rockets (0 .5 .8) (0 0 0) (32 32 32) big
*/

void() item_rockets =
{
	if (self.spawnflags & WEAPON_BIG2)
	{
		//self.netname = "multiple rockets, slugs and nails";
		self.ammo_rockets = 10;
		self.ammo_nails = 40;
		self.ammo_slugs = 10;
	}
	else
	{
		//self.netname = "some rockets, nails and slugs";
		self.ammo_rockets = 5;
		self.ammo_nails = 20;
		self.ammo_slugs = 5;
	}
	
	item_placeholder (0, "Nails");
	item_placeholder (1, "Rockets"); 
	item_placeholder (2, "Slugs"); 

	setmodel(self, "");
	setsize (self, '0 0 0', '32 32 56');

	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_TOSS;
	self.origin_z = self.origin_z + 6;
	droptofloor ();
};


/*QUAKED item_cells (0 .5 .8) (0 0 0) (32 32 32) big
*/

void() item_cells =
{
	if (self.spawnflags & WEAPON_BIG2)
	{
		//self.netname = "multiple rockets, slugs and nails";
		self.ammo_rockets = 5;
		self.ammo_nails = 20;
		self.ammo_dmc = 2;
	}
	else
	{
		//self.netname = "some rockets, nails and slugs";
		self.ammo_rockets = 2;
		self.ammo_nails = 20;
		self.ammo_dmc = 1;
	}
	
	item_placeholder (0, "Nails");
	item_placeholder (1, "Rockets"); 
	item_placeholder (2, "Dark-matter Cores"); 

	setmodel(self, "");
	setsize (self, '0 0 0', '32 32 56');

	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_TOSS;
	self.origin_z = self.origin_z + 6;
	droptofloor ();
};


/*
===============================================================================

KEYS

===============================================================================
*/

void() key_touch =
{
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;
	if (other.items & self.items)
		return;

	sprint (other, "You got the ");
	sprint (other, self.netname);
	sprint (other,"\n");

	sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	other.items = other.items | self.items;

	if (!coop)
	{	
		self.solid = SOLID_NOT;
		self.model = string_null;
	}

	grow_client_crosshair ();

	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};


void() key_setsounds =
{
	if (world.worldtype == 0)
	{
		self.noise = "misc/medkey.wav";
	}
	if (world.worldtype == 1)
	{
		self.noise = "misc/runekey.wav";
	}
	if (world.worldtype == 2)
	{
		self.noise = "misc/basekey.wav";
	}
};

/*QUAKED item_key1 (0 .5 .8) (-16 -16 -24) (16 16 32)
SILVER key
In order for keys to work
you MUST set your maps
worldtype to one of the
following:
0: medieval
1: metal
2: base
*/

void() item_key1 =
{
	if (world.worldtype == 0)
	{
		setmodel (self, "progs/w_s_key.mdl");
		self.netname = "silver key";
	}
	else if (world.worldtype == 1)
	{
		setmodel (self, "progs/m_s_key.mdl");
		self.netname = "silver runekey";
	}
	else if (world.worldtype == 2)
	{
		setmodel (self, "progs/b_s_key.mdl");
		self.netname = "silver keycard";
	}
	key_setsounds();
	self.touch = key_touch;
	self.items = IT_KEY1;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem (self);
};

/*QUAKED item_key2 (0 .5 .8) (-16 -16 -24) (16 16 32)
GOLD key
In order for keys to work
you MUST set your maps
worldtype to one of the
following:
0: medieval
1: metal
2: base
*/

void() item_key2 =
{
	if (world.worldtype == 0)
	{
		setmodel (self, "progs/w_g_key.mdl");
		self.netname = "gold key";
	}
	if (world.worldtype == 1)
	{
		setmodel (self, "progs/m_g_key.mdl");
		self.netname = "gold runekey";
	}
	if (world.worldtype == 2)
	{
		setmodel (self, "progs/b_g_key.mdl");
		self.netname = "gold keycard";
	}
	key_setsounds();
	self.touch = key_touch;
	self.items = IT_KEY2;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem (self);
};



/*
===============================================================================

END OF LEVEL RUNES

===============================================================================
*/

void() sigil_touch =
{

	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;

	centerprint (other, "You got the rune!");

	sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	self.solid = SOLID_NOT;
	self.model = string_null;
	serverflags = serverflags | (self.spawnflags & 15);
	self.classname = "";		// so rune doors won't find it
	
	grow_client_crosshair ();

	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};


/*QUAKED item_sigil (0 .5 .8) (-16 -16 -24) (16 16 32) E1 E2 E3 E4
End of level sigil, pick up to end episode and return to jrstart.
*/

void() item_sigil =
{
	if (!self.spawnflags)
		objerror ("no spawnflags");

	precache_sound ("misc/runekey.wav");
	self.noise = "misc/runekey.wav";

	if (self.spawnflags & 1)
	{
		precache_model ("progs/end1.mdl");
		setmodel (self, "progs/end1.mdl");
	}
	if (self.spawnflags & 2)
	{
		precache_model2 ("progs/end2.mdl");
		setmodel (self, "progs/end2.mdl");
	}
	if (self.spawnflags & 4)
	{
		precache_model2 ("progs/end3.mdl");
		setmodel (self, "progs/end3.mdl");
	}
	if (self.spawnflags & 8)
	{
		precache_model2 ("progs/end4.mdl");
		setmodel (self, "progs/end4.mdl");
	}
	
	self.touch = sigil_touch;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem (self);
};

/*
===============================================================================

POWERUPS

===============================================================================
*/

void() powerup_touch;


void() powerup_touch =
{
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;

	if (deathmatch)
	{
		self.mdl = self.model;
		
		if ((self.classname == "item_artifact_super_damage") ||
			(self.classname == "item_artifact_invisibility") || 
			(self.classname == "item_artifact_invulnerability"))
			self.nextthink = time + 60*5;
		else
			self.nextthink = time + 60;
		
		self.think = SUB_regen;
	}	

	other.powerups |= self.items;
		
	sprint (other, "You got the ");
	sprint (other, self.netname);
	sprint (other,"\n");

	sound (other, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	self.solid = SOLID_NOT;

	self.model = string_null;
	self.emiteffectnum = 0;

// do the apropriate action
	if (self.classname == "item_artifact_envirosuit")
	{
		other.rad_time = 1;
		other.radsuit_finished = time + 30;
	}

	if (self.classname == "item_artifact_regeneration")
	{
		other.invicible_time = 1;
		other.invincible_finished = time + 30;
	}

	if (self.classname == "item_artifact_invisibility")
	{		
		other.invisible_time = 1;
		other.invisible_finished = time + 30;
	}

	if (self.classname == "item_artifact_super_damage")
	{
		other.super_time = 1;
		other.super_damage_finished = time + 30;
	}	

	grow_client_crosshair ();

	activator = other;
	SUB_UseTargets();				// fire all targets / killtargets
};



/*QUAKED item_artifact_invulnerability (0 .5 .8) (-16 -16 -24) (16 16 32)
Player is invulnerable for 30 seconds
*/
void() item_artifact_invulnerability =
{
	item_artifact_regeneration ();
	self.classname = "item_artifact_regeneration";
};

void() item_artifact_regeneration =
{
	self.touch = powerup_touch;

	self.noise = "sounds_q4/mp/pickups/regen_acquire.wav";
	setmodel (self, "progs/items/power_ups/regen.md3");
	self.netname = "Regeneration";
	self.items = IT_REGENERATION;
	self.emiteffectnum = (particleeffectnum("EF_POWERUP_LIGHT"));
	setsize (self, '-16 -16 0', '16 16 64');
	self.modelflags |= MF_ROTATE;
	StartItem (self);
};


/*QUAKED item_artifact_envirosuit (0 .5 .8) (-16 -16 -24) (16 16 32)
Player takes no damage from water or slime for 30 seconds
*/
void() item_artifact_envirosuit =
{
	self.touch = powerup_touch;

	self.noise = "items/suit.wav";
	setmodel (self, "progs/suit.md3");
	self.netname = "Biosuit";
	self.items = IT_SUIT;
	self.modelflags |= MF_ROTATE;
	self.scale = 1.3;
	setsize (self, '-16 -16 -16', '16 16 48');

	self.emiteffectnum = (particleeffectnum("EF_POWERUP_LIGHT"));	
	StartItem (self);
};


/*QUAKED item_artifact_invisibility (0 .5 .8) (-16 -16 -24) (16 16 32)
Player is invisible for 30 seconds
*/
void() item_artifact_invisibility =
{
	self.touch = powerup_touch;

	self.noise = "sounds_q4/mp/pickups/invis.wav";
	setmodel (self, "progs/items/power_ups/invis.md3");
	self.netname = "Partial Invisibility";
	self.items = IT_INVISIBILITY;
	self.modelflags |= MF_ROTATE;

	self.emiteffectnum = (particleeffectnum("EF_POWERUP_LIGHT"));
	setsize (self, '-16 -16 0', '16 16 64');
	self.scale = 0.6;
	StartItem (self);
};


/*QUAKED item_artifact_super_damage (0 .5 .8) (-16 -16 -24) (16 16 32)
The next attack from the player will do 4x damage
*/
void() item_artifact_super_damage =
{
	self.touch = powerup_touch;

	self.noise = "sounds_q4/mp/pickups/quad_acquire.wav";
	setmodel (self, "progs/items/power_ups/quad.md3");
	self.netname = "Quad Damage";
	self.items = IT_QUAD;
	self.modelflags |= MF_ROTATE;

	self.emiteffectnum = (particleeffectnum("EF_POWERUP_LIGHT"));
	setsize (self, '-16 -16 0', '16 16 64');
	StartItem (self);
};

/*
===============================================================================

PLAYER BACKPACKS

===============================================================================
*/

void() BackpackTouch =
{
	local string	s;
	local	float	old, new;
	local		entity	stemp;
	local	float	acount;
	
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;

	acount = 0;
	sprint (other, "You get ");

	if (self.items)
		if ((other.items & self.items) == 0)
		{
			acount = 1;
			sprint (other, "the ");
			sprint (other, self.netname);
		}

// if the player was using his best weapon, change up to the new one if better		
	stemp = self;
	self = other;
//	best = W_BestWeapon();
	self = stemp;

// change weapons
	other.ammo_shells = other.ammo_shells + self.ammo_shells;
	other.ammo_nails = other.ammo_nails + self.ammo_nails;
	other.ammo_rockets = other.ammo_rockets + self.ammo_rockets;
	other.ammo_cells = other.ammo_cells + self.ammo_cells;

	new = self.items;
	if (!new)
		new = other.weapon;
	old = other.items;
	other.items = other.items | new;
	
	bound_other_ammo ();

	if (self.ammo_shells)
	{
		if (acount)
			sprint(other, ", ");
		acount = 1;
		s = ftos(self.ammo_shells);
		sprint (other, s);
		sprint (other, " shells");
	}
	if (self.ammo_nails)
	{
		if (acount)
			sprint(other, ", ");
		acount = 1;
		s = ftos(self.ammo_nails);
		sprint (other, s);
		sprint (other, " nails");
	}
	if (self.ammo_rockets)
	{
		if (acount)
			sprint(other, ", ");
		acount = 1;
		s = ftos(self.ammo_rockets);
		sprint (other, s);
		sprint (other, " rockets");
	}
	if (self.ammo_cells)
	{
		if (acount)
			sprint(other, ", ");
		acount = 1;
		s = ftos(self.ammo_cells);
		sprint (other, s);
		sprint (other, " cells");
	}
	
	sprint (other, "\n");
// backpack touch sound
	sound (other, CHAN_ITEM, "sounds_q4/items/ammo/default.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

	grow_client_crosshair ();

// remove the backpack, change self to the player
	remove(self);
	self = other;

	W_SetCurrentAmmo (TRUE);
};

/*
===============
DropBackpack
===============
*/
void() DropBackpack =
{
	local entity	item;

	if (!(self.ammo_shells + self.ammo_nails + self.ammo_rockets + self.ammo_cells))
		return;	// nothing in it

	item = spawn();
	item.origin = self.origin + '0 0 24';
	
	item.items = self.weapon;

	/*if (item.items == IT_AXE)
		item.netname = "Fists";
	else if (item.items == IT_SHOTGUN)
		item.netname = "Pistol";
	else if (item.items == IT_SUPER_SHOTGUN)
		item.netname = "Shotgun";
	else if (item.items == IT_NAILGUN)
		item.netname = "Machine Gun";
	else if (item.items == IT_SUPER_NAILGUN)
		item.netname = "ChainGun";
	else if (item.items == IT_GRENADE_LAUNCHER)
		item.netname = "Grenades";
	else if (item.items == IT_ROCKET_LAUNCHER)
		item.netname = "Rocket Launcher";
	else if (item.items == IT_LIGHTNING)
		item.netname = "Plasma Gun";
	else if (item.items == IT_BFG)
		item.netname = "B.F.G 9000";
	else if (item.items == IT_CHAINSAW)
		item.netname = "Chainsaw";
	else
		item.netname = "";*/

	item.ammo_shells = self.ammo_shells;
	item.ammo_nails = self.ammo_nails;
	item.ammo_rockets = self.ammo_rockets;
	item.ammo_cells = self.ammo_cells;

	item.velocity_z = 300;
	item.velocity_x = -100 + (random() * 200);
	item.velocity_y = -100 + (random() * 200);
	
	item.flags = FL_ITEM;
	item.solid = SOLID_TRIGGER;
	item.movetype = MOVETYPE_TOSS;
	setmodel (item, "progs/backpack.mdl");
	setsize (item, '-16 -16 0', '16 16 56');
	item.touch = BackpackTouch;
	
	item.nextthink = time + 120;	// remove after 2 minutes
	item.think = SUB_Remove;
};