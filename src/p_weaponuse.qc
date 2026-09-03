/*
=====================================================================

player use weapons 

=====================================================================
*/

void()	player_passive;

//.entity pweaponmodel;
//entity gunpmodel;

weapon_info_ammo a_empty = {};
weapon_info_generic w_empty = {};
weapon_info_frames wf_empty = {};
weapon_info_frames2 wf2_empty = {};
weapon_info_func func_empty = {};
weapon_info_mag mag_empty = {0, 0};

// weapon_info_frames foobar = { last_active, idle_first, idle_last, swap_first, swap_last, 
//				reload_first, reload_last, frame_ins_ammo, reloadloop_1st, reload_loop_last, mag_size, capacity, fire_func, sound_func}

// seperated into chunks to remove lag between weapon switches
weapon_info_frames getweaponframes[14] =
{	
	wf_empty,
	wf_blaster,
	wf_machinegun,
	wf_shotgun,
	wf_hyperblaster,
	wf_grenadelauncher,
	wf_nailgun,
	wf_rocketlauncher,
	wf_railgun,
	wf_lightninggun,
	wf_dmg,
	wf_empty, // where are you oh  i figured
	wf_empty,
	wf_empty
};

weapon_info_frames2 getweaponframes2[14] =
{	
	wf2_empty,
	wf2_empty,
	wf2_machinegun,
	wf2_shotgun,
	wf2_hyperblaster,
	wf2_grenadelauncher,
	wf2_nailgun,
	wf2_rocketlauncher,
	wf2_railgun,
	wf2_empty,
	wf2_dmg,
	wf2_empty, // where are you oh  i figured
	wf2_empty,
	wf2_empty
};

weapon_info_generic getweaponinfo[14] =
{	
	w_empty,
	w_blaster,
	w_machinegun,
	w_shotgun,
	w_hyperblaster,
	w_grenadelauncher,
	w_nailgun,
	w_rocketlauncher,
	w_railgun,
	w_lightninggun,
	w_dmg,
	w_empty,
	w_empty,
	w_empty
};

weapon_info_ammo getweaponammo[14] =
{	
	a_empty,
	a_blaster,
	a_machinegun,
	a_shotgun,
	a_hyperblaster,
	a_grenadelauncher,
	a_nailgun,
	a_rocketlauncher,
	a_railgun,
	a_lightninggun,
	a_dmg,
	a_empty, 
	a_empty,
	a_empty
};

weapon_info_mag getweaponmag[14] =
{	
	mag_empty,
	mag_empty,
	mag_machinegun,
	mag_shotgun,
	mag_hyperblaster,
	mag_grenadelauncher,
	mag_nailgun,
	mag_rocketlauncher,
	mag_railgun,
	mag_empty,
	mag_dmg,
	mag_empty, 
	mag_empty,
	mag_empty
};

weapon_info_func getweaponfunc[14] =
{	
	func_empty,
	func_blaster,
	func_machinegun,
	func_shotgun,
	func_hyperblaster,
	func_grenadelauncher,
	func_nailgun,
	func_rocketlauncher,
	func_railgun,
	func_lightninggun,
	func_dmg,
	func_empty, 
	func_empty,
	func_empty
};

string scope_weapons[6] = // tells if this gun zooms or nah
{
	"", 
	"weapon_machinegun",
	"weapon_railgun",
	"weapon_nailgun",
	"weapon_rocketlauncher",
	"", 
};

string light_weapons[2] = // tells if this is a flashlight or not
{
	"weapon_blaster", 
	"weapon_machinegun",
};

float (string a) getweapon_alt =
{
	for(float i = 0; i < 5; i++)
	{
		if (a == scope_weapons[i])
		{	
			return TRUE;
			break;
		}
	}
	return FALSE;
}

float (string a) getweapon_light =
{
	for(float i = 0; i < 2; i++)
	{
		if (a == light_weapons[i])
		{	
			return TRUE;
			break;
		}
	}
	return FALSE;
}

/*void(string weapon) player_get_gunmodel =
{
	if (!self.pweaponmodel)
	{
		gunpmodel = spawn();
		gunpmodel.owner = self;
		self.pweaponmodel = gunpmodel;
		self.pweaponmodel.exteriormodeltoclient = gunpmodel.owner;
	}

	setmodel(self.pweaponmodel, weapon);
	setorigin(self.pweaponmodel, self.origin);
	self.pweaponmodel.solid = SOLID_NOT;
	setsize (self.pweaponmodel, VEC_ORIGIN, VEC_ORIGIN);
};*/

float getweaponbit (float id) {
	id = id - 1;

	return 1<<id;
}

void(float item) W_SetCurrentAmmo =
{	
	float id = self.weaponid;
	float old = self.oldweaponid;

	weapon_info_generic wep = getweaponinfo[id];
	weapon_info_ammo currammo = getweaponammo[id];

	if (id == old || item == TRUE)
	{	
		currammo.assign_currentammo();	
		return;
	}
	
  	self.weapon = getweaponbit(id);
	self.weaponmodel = wep.vmodel;
	self.weaponmodelpos = wep.offs;
	self.weaponname = wep.name;

	currammo.assign_currentammo();
	
	self.newweaponid = 0;
	self.weaponframe = 0;
	self.spawnmuzzleflash = 0;
	self.weaponstate = WEAPON_ACTIVATE;
	
	string modelstr = strcat ("progs/player/", self.pmodel_name, "/player", ftos(self.weaponid), ".md5.info");
	self.modelindex = getmodelindex(modelstr);

	float alt = getweapon_light(self.weaponname);

	if (!alt)
	{	
		if (self.flash_active == 1)
		{
			self.flash_active = 2;
			activate_flashlight ();
		}	
		return;
	}

	if (self.flash_active == 2)
	{	
	//	bprint("???", "\n");
		self.flash_active = 1;
		activate_flashlight ();
	}	
};

float() W_CheckNoAmmo =
{	
	float id = self.weaponid;
	float ammo_type = 0;
	weapon_info_generic wep = getweaponinfo [id];
	weapon_info_ammo wep_ammo = getweaponammo [id];	
	
    if (!wep_ammo.get_ammo() && !wep.condition())
    {
        return FALSE; // weapon doesn't need ammo
    }

    if (self.currentammo > 0)
    {
        return FALSE; // has at least one ammo
    }

	if (wep_ammo.get_ammo() > 0 && self.currentammo < 1 && cvar("g_autoreload") == 1)
	{		
		self.currentammo = 0;
		self.weaponstate = WEAPON_RELOAD;
		return TRUE; // just reload the gun
	}

/*	if (wep_ammo.get_ammo() <= 0)
	{
   	 	self.newweaponid = W_BestWeapon();
   	 	self.oldweaponid = self.weaponid;
   	 	self.weaponstate = WEAPON_DEACTIVATE;
	}*/

    // drop the weapon down
    return TRUE;
};

/*
============
W_ChangeWeapon
============
*/
void() W_ChangeWeapon =
{	
	if (self.weaponstate == WEAPON_FLASHUSE)
		return;

    local float it, am, fl;

    float id = self.impulse;

    weapon_info_generic wepinfo = getweaponinfo[id];

    it = self.items;
    am = wepinfo.condition();
    fl = getweaponbit(id);
	
    self.impulse = 0;

    if (!(self.items & fl))
    {
        // don't have the weapon or the ammo
        sprint(self, "no weapon.\n");
        return;
    }

    if (am)
    {
        // don't have the ammo
        sprint(self, "not enough ammo.\n");
        return;
    }

    //
    // set weapon, set ammo
    //

	if (self.weaponid == id)
		return;

	player_passive ();

    self.newweaponid = id;
	self.oldweaponid = self.weaponid;
	self.weaponstate = WEAPON_DEACTIVATE;
};

/*
============
CycleWeaponCommand

Go to the next weapon with ammo
============
*/
.float nextweapon;

void() CycleWeaponCommand =
{	
	if (self.weaponstate == WEAPON_FLASHUSE)
		return;

    local float it, am;

    it = self.items;
    self.impulse = 0;
	
	float id = self.weaponid;
	weapon_info_generic nextweapon = getweaponinfo[id];
	float nextweapon_bit = getweaponbit(id);	

    while(1)
    {		
	  	id++; 
	  	if (id >= (MAX_WEAPONS + 1)) // reset
			id = 1; 
		//bprint (ftos(id), "\n");

	  	nextweapon = getweaponinfo[id];
	  	am = nextweapon.condition();  
		nextweapon_bit = getweaponbit(id);	

        if ((it & nextweapon_bit) && !am)
            break;
    }
	
	if (id == self.weaponid) // ended up on same gun
		return;

	player_passive ();

	self.newweaponid = id;	
	self.weaponstate = WEAPON_DEACTIVATE;
	self.oldweaponid = self.weaponid;
};

/*
============
CycleWeaponReverseCommand

Go to the prev weapon with ammo
============
*/
void() CycleWeaponReverseCommand =
{	
	if (self.weaponstate == WEAPON_FLASHUSE)
		return;

    local float it, am;

    it = self.items;
    self.impulse = 0;
	
	float id = self.weaponid;
	weapon_info_generic nextweapon = getweaponinfo[id];
	float nextweapon_bit = getweaponbit(id);	

    while(1)
    {		  
	  	id--;	  
	  	if (id <= 0) // reset
			id = MAX_WEAPONS; 
	  
        	//bprint (ftos(id), "\n");
	  	nextweapon = getweaponinfo[id];
	  	am = nextweapon.condition();  
		nextweapon_bit = getweaponbit(id);	

        if ((it & nextweapon_bit) && !am)
        	break;
    }

	if (id == self.weaponid) // ended up on same gun
		return;

	player_passive ();

    self.newweaponid = id;	
	self.weaponstate = WEAPON_DEACTIVATE;
	self.oldweaponid = self.weaponid;

};

//============================================

/*
============
W_WeaponFrame

Called every frame so impulse events can be handled as well as possible
============
*/
.float grabber_thinker;

float(float ammo) bfgcheckammo = 
{	
	if (29 < ammo && ammo < 60)
		return 30;
	if (59 < ammo && ammo < 90)
		return 60;
	if (89 < ammo && ammo < 120)
		return 90;
	if (ammo > 119)
		return 120;
	
	return 0;
}

static float FIRST = 0; static float LAST  = 1;

void() W_WeaponDead =
{	
	if (!self.weaponmodel)
		return;
	
	if (self.dspeed > time)
		return;

	float	id = self.weaponid;
	weapon_info_frames wepname = getweaponframes[id];

	if (self.weaponframe == wepname.swap_frames[LAST])
	{
		self.weaponmodel = "";
		return;
	}

	if (self.weaponstate == WEAPON_DOWN)
	{	
		if (self.weaponframe < wepname.swap_frames[FIRST])
			self.weaponframe = wepname.swap_frames[FIRST];
		
		self.attack_finished = TRUE;
		
		self.weaponframe ++;
		self.dspeed = time + 0.03;
		return;
	}
};

void() W_WeaponThink = 
{	
	if (!self.weaponid)
		return;
	
	if (self.dspeed > time)
		return;

	if (!self.weaponmodel)
		return;

	float	id = self.weaponid;
	weapon_info_frames wepname = getweaponframes[id];
	weapon_info_mag wepmag = getweaponmag[id];
	weapon_info_func weapon_func;

	//change_end = change_end + 1;
	local float ammo_type, cap = 0;

	if (self.weaponstate == WEAPON_ACTIVATE)
	{	
		weapon_func = getweaponfunc[id];
		weapon_func.weaponsound ();
		self.weaponframe ++;
		self.attack_finished = TRUE;

		if (self.weaponframe == wepname.last_activation)
		{	
			self.weaponstate = WEAPON_IDLE;

			if (wepname.idle_empty_frames)
			{	
				float condition2 = 0;
				weapon_info_ammo wepinfo3 = getweaponammo[id];
				ammo_type = wepinfo3.get_ammo();
				if (wepname.idle_empty_frames[2] == 1)
					condition2 = ammo_type;
				else
					condition2 = self.currentammo;	
			}
			if (wepname.idle_empty_frames[FIRST] && condition2 == 0)
				self.weaponframe = wepname.idle_empty_frames[FIRST];
			else
				self.weaponframe = wepname.idle_frames[FIRST];

			self.attack_finished = FALSE;
			self.dspeed = 0;
			return;
		}
		
		self.dspeed = time + 0.03;
		return;
	}
	
	// WEAPON_SPIN_OUT_OF_AMMO removed
	
	if (self.weaponstate == WEAPON_DEACTIVATE)
	{	
		if (self.weaponframe < wepname.swap_frames[FIRST])
			self.weaponframe = wepname.swap_frames[FIRST];
		
		self.weaponframe ++;
		self.attack_finished = FALSE;
				
		if (self.weaponframe == wepname.swap_frames[LAST])
		{	
			self.attack_finished = FALSE;
			self.weaponid = self.newweaponid;	
			
			self.weaponstate = WEAPON_IDLE;
			W_SetCurrentAmmo(FALSE);
			self.dspeed = 0;
			return;
		}
		
	//	player_deactivate1();
		self.dspeed = time + 0.03;
		return;
	}

	if (self.weaponstate == WEAPON_USED)
	{
		return;
	}	

	if (self.weaponstate == WEAPON_FLASHUSE)
	{
		return;
	}	

	if (W_WeaponUse())
	{
		W_Attack();
		return;
	}
	
	if (self.weaponstate == WEAPON_RELOAD)
	{	
		weapon_info_frames2 weprel = getweaponframes2[id];
		weapon_info_ammo wepinfo = getweaponammo[id];
		ammo_type = wepinfo.get_ammo();

		float ammo_load = wepmag.mag_size;
		cap = wepmag.capacity;
		float truecap = cap;

		if (id == 9) // bfg exclusive
		{	
			cap = bfgcheckammo(ammo_type);
			ammo_load = bfgcheckammo(ammo_type);
		}
		
		float end_frame = weprel.reload_frames[LAST];

		if (end_frame < weprel.reloadloop_frames[FIRST])
			end_frame = weprel.reloadloop_frames[LAST];

		if (self.weaponframe >= weprel.reloadidk_frames[FIRST] && weprel.reloadidk_frames[FIRST] != 0) 
			end_frame = weprel.reloadidk_frames[LAST];
		
		if ((self.currentammo >= cap || ammo_type < 1) && self.weaponframe >= end_frame && self.currentammo > 0)
		{	
			self.weaponstate = WEAPON_IDLE;
			self.weaponframe = wepname.idle_frames[FIRST];
			return;		
		}

		if (self.weaponframe < weprel.reload_frames[FIRST] && (self.weaponframe >= wepname.idle_frames[FIRST] || self.weaponframe <= wepname.idle_frames[LAST]))
			self.weaponframe = weprel.reload_frames[FIRST];

		if (self.currentammo <= cap && 
				( (self.weaponframe == weprel.reload_frames[2]) || (self.weaponframe == weprel.reloadloop_frames[2]) ) )
		{		
			if (ammo_type <= ammo_load && cap >= ammo_load)
				ammo_load = ammo_type;
			
			self.currentammo = self.currentammo + ammo_load;
			ammo_type -= ammo_load;

			if (self.currentammo > truecap)
			{	
				ammo_type += self.currentammo - cap;
				self.currentammo = self.currentammo - (self.currentammo - cap);
			}

			wepinfo.save_ammo (ammo_type);
		}

		if (self.currentammo < cap && ammo_type > 0 && self.weaponframe > weprel.reloadloop_frames[LAST] - 1 && id != 9)
			self.weaponframe = weprel.reloadloop_frames[FIRST];

		if (weprel.reloadidk_frames[FIRST] && (self.currentammo == cap || ammo_type <= 0)
				&& self.weaponframe == weprel.reload_frames[LAST])
		{
			self.weaponframe = weprel.reloadidk_frames[FIRST];
			//bprint(ftos(ammo_type), "? \n");
		}
			
			
		weapon_func = getweaponfunc[id];
		weapon_func.weaponsound ();
		self.weaponframe ++;

		if ( self.weaponframe < weprel.reloadloop_frames[LAST])
			self.attack_finished = TRUE;
		else
			self.attack_finished = FALSE;
		
		if (self.weaponname == "weapon_dmg")
			self.dspeed = time + 0.042; // wtf
		else
			self.dspeed = time + 0.03; // wtf
		return;
	}
	
	/*if (wepmag.capacity != 0)
	{	
		weapon_info_ammo wepinfo2 = getweaponammo[id];
		ammo_type = wepinfo2.get_ammo();
		if (self.currentammo < 1 && ammo_type <= 0)
		{	
			self.weaponstate = WEAPON_DEACTIVATE;
			self.newweaponid = W_BestWeapon();
			self.attack_finished = TRUE;
			player_passive ();
			return;
		}
	}*/
	
	self.weaponframe ++;
	self.dspeed = time + 0.04;
	
	self.weaponstate = WEAPON_IDLE;
	self.attack_finished = FALSE;
	
	if (wepname.idle_empty_frames[FIRST])
	{	
		if (self.weaponframe >= wepname.idle_empty_frames[FIRST] && self.currentammo > 0)
			self.weaponframe = wepname.idle_frames[FIRST];

		if (self.weaponframe == wepname.idle_empty_frames[LAST])
			self.weaponframe = wepname.idle_empty_frames[FIRST];

		float condition = 0;
		weapon_info_ammo wepinfo2 = getweaponammo[id];
		ammo_type = wepinfo2.get_ammo();
		if (wepname.idle_empty_frames[2] == 1)
			condition = ammo_type;
		else
			condition = self.currentammo;	

		if (wepname.idle_empty_frames[FIRST] && condition == 0)
			self.weaponframe = wepname.idle_empty_frames[FIRST];
	}

	if (self.weaponframe == wepname.idle_frames[LAST])
		self.weaponframe = wepname.idle_frames[FIRST];

	ImpulseCommands();
};

void() W_Attack =
{	
    self.show_hostile = time + 1; // wake monsters up
	
	float id = self.weaponid;
	weapon_info_func weapon_func = getweaponfunc[id];
	weapon_func.weaponfire ();
};

float () W_WeaponUse =
{		
	// WEAPON_SPIN_OUT_OF_AMMO removed

	if (self.weaponstate == WEAPON_ACTIVATE)
		return FALSE;

	if (self.weaponstate == WEAPON_DEACTIVATE)
		return FALSE;

	if (self.weaponstate == WEAPON_FLASHUSE)
		return FALSE;

	if (self.attack_finished)
		return FALSE;
	
	if (W_CheckNoAmmo ())
		return FALSE;

    // check for attack
    if (!self.button0)
		return FALSE;

	return TRUE;
};

void() W_WeaponReload = 
{	
	if (self.button4)
		return;
	if (!self.button3)
		return;
	if (self.weaponstate == WEAPON_USED)
		return;
	if (self.weaponstate == WEAPON_RELOAD)
		return;
	if (self.weaponstate == WEAPON_FLASHUSE)
		return;
	
	float id = self.weaponid;
	weapon_info_ammo wepinfo = getweaponammo[id];
	weapon_info_frames2 wepname = getweaponframes2[id];
	weapon_info_mag wepmag = getweaponmag[id];

	if (!wepname.reload_frames[FIRST])
		return;

	if (!wepmag.capacity)
		return;
	
	float ammo_type = wepinfo.get_ammo();
	float cap = wepmag.capacity;

	if (id == 9) // bfg exclusive
		cap = bfgcheckammo(ammo_type);
	
	if(ammo_type < 30 && id == 9)
		return;
	if(self.currentammo == 120 && id == 9)
		return;
	if(self.currentammo >= cap && id != 9)
		return;
	if(ammo_type <= 0)
		return;
	if(self.attack_state == AS_MISSILE)
		return;
	
	player_passive();	
	self.weaponstate = WEAPON_RELOAD;
	self.dspeed = 0;	
};

void() W_WeaponZoom = 
{	
	if (!self.button4)
	{	
		if (self.fov == 70)
			sound(self, CHAN_AUTO, "sounds_q4/weapons/machinegun/zoom_out.wav", 1, ATTN_NORM);

		if (self.fov)
			self.fov += 5;

		if (self.fov > self.oldfov)
		{
			self.fov = 0;
			self.oldfov = 0;
		}
		
		if (self.prelock_save)
			self.prelock_save = world;

		if (self.locked_enemy)
		{	
			if (self.locked_enemy.classname == "laser_spot")
				remove(self.locked_enemy);
			self.locked_enemy = world;
		}

		return;
	}

	if (self.weaponstate == WEAPON_DEACTIVATE)
		return;

	if (self.weaponstate == WEAPON_RELOAD && self.weaponname != "weapon_rocketlauncher")
		return;

	if (self.weaponstate == WEAPON_FLASHUSE)
		return;
	
	float id = self.weaponid;
	float alt = getweapon_alt(self.weaponname);

	if (!alt)
		return;

	if (self.weaponname == "weapon_rocketlauncher")
	{
		G_UpdateSpot ();
	//	return;
	}

	if (!self.fov)
	{
		sound(self, CHAN_AUTO, "sounds_q4/weapons/machinegun/zoom_in.wav", 1, ATTN_NORM);
		self.fov = cvar("fov");
	}	

	if (!self.oldfov)
		self.oldfov = cvar("fov");

	if (self.fov != 70)
		self.fov -= 5;
	
	if (self.fov < 70)
		self.fov = 70;

	if (self.weaponname == "weapon_nailgun")
	{
		nailgun_lockon ();
		nailgun_locking ();
	}
};

void() flashlight_func_list [2] =
{	
	player_blaster_light,
	player_machinegun_light
};

.float flash_active;
.float flash_reactive;

void() activate_flashlight = 
{
	msg_entity = self;
	WriteByte (MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte (MSG_MULTICAST, 87);
	multicast ('0 0 0', MULTICAST_ONE);
}

void() W_WeaponFlashlight = 
{	
	float alt = getweapon_light(self.weaponname);

	if (!alt)
	{	
		return;
	}

	if (self.weaponstate == WEAPON_ACTIVATE)
		return;

	if (self.weaponstate == WEAPON_DEACTIVATE)
		return;

	if (self.weaponstate == WEAPON_RELOAD)
		return;

	if (self.weaponstate == WEAPON_FLASHUSE)
		return;

	if (self.attack_finished)
		return;

	if (!self.button5)
		return;

	flashlight_func_list[self.weaponid - 1] ();
}

/*
============
CheatCommand
============
*/
void() CheatCommand =
{
    if (deathmatch || coop)
    {
        return;
    }
	
    self.ammo_rockets = MAX_ROCKETS;
    self.ammo_nails = MAX_NAILS;
    self.ammo_shells = MAX_SHELLS;
	self.ammo_bullets = MAX_BULLETS;
	self.ammo_coils = MAX_COILS;
	self.ammo_grenades = MAX_GRENADES;
	self.ammo_slugs = MAX_SLUGS;
	self.ammo_dmc = MAX_CORES;
   
	for (float i = 0; i < MAX_WEAPONS; i++)
	{
		self.items |= 1<<i;
	}

    self.ammo_cells = MAX_CELLS;

    self.impulse = 0;

    self.savedammo_bullets = MG_AMMO_CAP;
    self.savedammo_nails = NG_AMMO_CAP;

    self.savedammo_shells = SG_AMMO_CAP;
//    self.savedammo_shells2 = PSTL_AMMO_CAP;
	self.savedammo_cells = HB_AMMO_CAP;
	self.savedammo_grenades = GL_AMMO_CAP;
	self.savedammo_rockets = RL_AMMO_CAP;
	self.savedammo_slugs = RG_AMMO_CAP;
	self.savedammo_dmc = 1;

    W_SetCurrentAmmo(TRUE);
};


void() _lightning_debug =
{
    if (deathmatch || coop)
    {
        return;
    }
	
	self.ammo_coils = 221;

    W_SetCurrentAmmo(TRUE);
};

/*
============
ServerflagsCommand

Just for development
============
*/
void() ServerflagsCommand =
{
    serverflags = serverflags * 2 + 1;
};


void() QuadCheat =
{
    if (deathmatch || coop)
    {
        return;
    }

	self.powerups &= ~IT_QUAD;
    self.super_time = time;
    self.super_damage_finished = time + 30;
    self.powerups |= IT_QUAD;

    dprint("quad cheat\n");
};

void() SuitCheat =
{
    if (deathmatch || coop)
    {
        return;
    }

	self.powerups &= ~IT_SUIT;
    self.rad_time = 1;
    self.radsuit_finished = time + 30;
    self.powerups |= IT_SUIT;
    dprint("suit cheat\n");
};

void() InvisCheat =
{
    if (deathmatch || coop)
    {
        return;
    }

	self.powerups &= ~IT_INVISIBILITY;
    self.invisible_time = 1;
    self.invisible_finished = time + 30;
    self.powerups |= IT_INVISIBILITY;
    dprint("invis cheat\n");
};

void() PentaCheat =
{
    if (deathmatch || coop)
    {
        return;
    }

	self.powerups &= ~IT_REGENERATION;
    self.invicible_time = 1;
    self.invincible_finished = time + 30;
    self.powerups |= IT_REGENERATION;
    dprint("artifact cheat\n");
};

void() AllPower =
{
    if (deathmatch || coop)
    {
        return;
    }

	self.powerups = 0;
    PentaCheat ();
	InvisCheat ();
	SuitCheat ();
	QuadCheat ();
};

void() KeyCheat =
{
    if (deathmatch || coop)
    {
        return;
    }

    self.items = self.items | IT_KEY1  | IT_KEY2;
};

/*
============
ImpulseCommands

============
*/
void() ImpulseCommands =
{	
	switch(self.impulse)
	{	
		case 29:
			CheatCommand();
			break;
		case 122:
			_lightning_debug();
			break;
		case 32:
			ServerflagsCommand();
			break;
		case 121:
			KeyCheat();
			break;
		case 251:
			SuitCheat ();
			break;
		case 252:
			PentaCheat ();
			break;
		case 253:
			InvisCheat ();
			break;
		case 254:
			QuadCheat ();
			break;
		case 255:
			AllPower ();
			break;
		default:
			return;	
	}	
		
	self.impulse = 0;
};

void() WeaponChange =
{	
	switch(self.impulse)
	{
		case 1:
		case 2:
		case 3:
		case 4:
		case 5:
		case 6:
		case 7:
		case 8:
		case 9:
		case 10:
			W_ChangeWeapon();
			break;
		case 30:
			CycleWeaponCommand();
			break;
		case 31:
			CycleWeaponReverseCommand ();
			break;
	//	case 67:
	//		WeaponReload ();
	//		break;
		default:
			return;	
	}		
	
	self.impulse = 0;
};