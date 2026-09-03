
void() InitBodyQue;


void() main =
{
	dprint ("main function\n");
	
// these are just commands the the prog compiler to copy these files

	precache_file ("progs.dat");
	precache_file ("gfx.wad");
	precache_file ("quake.rc");
	precache_file ("default.cfg");

	precache_file ("end1.bin");
	precache_file2 ("end2.bin");

	precache_file ("demo1.dem");
	precache_file ("demo2.dem");
	precache_file ("demo3.dem");

//
// these are all of the lumps from the cached.ls files
//
	precache_file ("gfx/palette.lmp");
	precache_file ("gfx/colormap.lmp");

	precache_file2 ("gfx/pop.lmp");

	precache_file ("gfx/complete.lmp");
	precache_file ("gfx/inter.lmp");

	precache_file ("gfx/ranking.lmp");
	precache_file ("gfx/vidmodes.lmp");
	precache_file ("gfx/finale.lmp");
	precache_file ("gfx/conback.lmp");
	precache_file ("gfx/qplaque.lmp");

	precache_file ("gfx/menudot1.lmp");
	precache_file ("gfx/menudot2.lmp");
	precache_file ("gfx/menudot3.lmp");
	precache_file ("gfx/menudot4.lmp");
	precache_file ("gfx/menudot5.lmp");
	precache_file ("gfx/menudot6.lmp");

	precache_file ("gfx/menuplyr.lmp");
	precache_file ("gfx/bigbox.lmp");
	precache_file ("gfx/dim_modm.lmp");
	precache_file ("gfx/dim_drct.lmp");
	precache_file ("gfx/dim_ipx.lmp");
	precache_file ("gfx/dim_tcp.lmp");
	precache_file ("gfx/dim_mult.lmp");
	precache_file ("gfx/mainmenu.lmp");
	
	precache_file ("gfx/box_tl.lmp");
	precache_file ("gfx/box_tm.lmp");
	precache_file ("gfx/box_tr.lmp");
	
	precache_file ("gfx/box_ml.lmp");
	precache_file ("gfx/box_mm.lmp");
	precache_file ("gfx/box_mm2.lmp");
	precache_file ("gfx/box_mr.lmp");
	
	precache_file ("gfx/box_bl.lmp");
	precache_file ("gfx/box_bm.lmp");
	precache_file ("gfx/box_br.lmp");
	
	precache_file ("gfx/sp_menu.lmp");
	precache_file ("gfx/ttl_sgl.lmp");
	precache_file ("gfx/ttl_main.lmp");
	precache_file ("gfx/ttl_cstm.lmp");
	
	precache_file ("gfx/mp_menu.lmp");
	
	precache_file ("gfx/netmen1.lmp");
	precache_file ("gfx/netmen2.lmp");
	precache_file ("gfx/netmen3.lmp");
	precache_file ("gfx/netmen4.lmp");
	precache_file ("gfx/netmen5.lmp");
	
	precache_file ("gfx/sell.lmp");
	
	precache_file ("gfx/help0.lmp");
	precache_file ("gfx/help1.lmp");
	precache_file ("gfx/help2.lmp");
	precache_file ("gfx/help3.lmp");
	precache_file ("gfx/help4.lmp");
	precache_file ("gfx/help5.lmp");

	precache_file ("gfx/pause.lmp");
	precache_file ("gfx/loading.lmp");

	precache_file ("gfx/p_option.lmp");
	precache_file ("gfx/p_load.lmp");
	precache_file ("gfx/p_save.lmp");
	precache_file ("gfx/p_multi.lmp");

// sounds loaded by C code
	precache_sound ("misc/menu1.wav");
	precache_sound ("misc/menu2.wav");
	precache_sound ("misc/menu3.wav");

	precache_sound ("ambience/water1.wav");
	precache_sound ("ambience/wind2.wav");

// shareware
	precache_file ("maps/start.bsp");

	precache_file ("maps/e1m1.bsp");
	precache_file ("maps/e1m2.bsp");
	precache_file ("maps/e1m3.bsp");
	precache_file ("maps/e1m4.bsp");
	precache_file ("maps/e1m5.bsp");
	precache_file ("maps/e1m6.bsp");
	precache_file ("maps/e1m7.bsp");
	precache_file ("maps/e1m8.bsp");

// registered
	precache_file2 ("gfx/pop.lmp");

	precache_file2 ("maps/e2m1.bsp");
	precache_file2 ("maps/e2m2.bsp");
	precache_file2 ("maps/e2m3.bsp");
	precache_file2 ("maps/e2m4.bsp");
	precache_file2 ("maps/e2m5.bsp");
	precache_file2 ("maps/e2m6.bsp");
	precache_file2 ("maps/e2m7.bsp");

	precache_file2 ("maps/e3m1.bsp");
	precache_file2 ("maps/e3m2.bsp");
	precache_file2 ("maps/e3m3.bsp");
	precache_file2 ("maps/e3m4.bsp");
	precache_file2 ("maps/e3m5.bsp");
	precache_file2 ("maps/e3m6.bsp");
	precache_file2 ("maps/e3m7.bsp");

	precache_file2 ("maps/e4m1.bsp");
	precache_file2 ("maps/e4m2.bsp");
	precache_file2 ("maps/e4m3.bsp");
	precache_file2 ("maps/e4m4.bsp");
	precache_file2 ("maps/e4m5.bsp");
	precache_file2 ("maps/e4m6.bsp");
	precache_file2 ("maps/e4m7.bsp");
	precache_file2 ("maps/e4m8.bsp");

	precache_file2 ("maps/end.bsp");

	precache_file2 ("maps/dm1.bsp");
	precache_file2 ("maps/dm2.bsp");
	precache_file2 ("maps/dm3.bsp");
	precache_file2 ("maps/dm4.bsp");
	precache_file2 ("maps/dm5.bsp");
	precache_file2 ("maps/dm6.bsp");
};


entity	lastspawn;

//=======================
/*QUAKED worldspawn (0 0 0) ?
Only used for the world entity.
Set message to the level name.
Set sounds to the cd track to play.

World Types:
0: medieval
1: metal
2: base
*/
//=======================
void() worldspawn =
{
	lastspawn = world;
	InitBodyQue ();
	
//registercvar("g_autoswitch", "0");
	registercvar("g_autoreload", "0");

// custom map attributes
	if (self.model == "maps/e1m8.bsp")
		cvar_set ("sv_gravity", "100");
	else
		cvar_set ("sv_gravity", "800");

	//autocvar ("cl_autoreload", "0");
	//autocvar ("cl_autochange", "0");

	cvar_set ("r_lerpmodels", "1");
	cvar_set ("r_lerpmuzzlehack", "0");

	cvar_set ("physics_ode_contactsurfacelayer", "0.001");
	cvar_set ("physics_ode_world_damping_linear_treshold", "0.05");
	cvar_set ("physics_ode_world_damping_angular_treshold", "0.05");
	cvar_set ("physics_ode_world_damping_linear", "0.025");
	cvar_set ("physics_ode_world_damping_angular", "0.025");
	cvar_set ("physics_ode_autodisable_time", "0");
	cvar_set ("physics_ode_maxspeed", "1000");

	max_players = ftoi(cvar("sv_maxclients"));

// the area based ambient sounds MUST be the first precache_sounds

// player precaches	
	W_Precache ();			// get weapon precaches

// sounds used from C physics code
	precache_sound ("demon/dland2.wav");		// landing thud
	precache_sound ("misc/h2ohit1.wav");		// landing splash

// setup precaches allways needed
	precache_sound ("sounds_q4/mp/misc/item_respawn.wav");		// item respawn sound
	precache_sound ("player/plyrjmp8.wav");		// player jump
	precache_sound ("player/land.wav");			// player landing
	precache_sound ("player/land2.wav");		// player hurt landing
	precache_sound ("player/drown1.wav");		// drowning pain
	precache_sound ("player/drown2.wav");		// drowning pain
	precache_sound ("player/gasp1.wav");		// gasping for air
	precache_sound ("player/gasp2.wav");		// taking breath
	precache_sound ("player/h2odeath.wav");		// drowning death

	precache_sound ("misc/talk.wav");			// talk
	precache_sound ("player/teledth1.wav");		// telefrag
	precache_sound ("misc/r_tele1.wav");		// teleport sounds
	precache_sound ("misc/r_tele2.wav");
	precache_sound ("misc/r_tele3.wav");
	precache_sound ("misc/r_tele4.wav");
	precache_sound ("misc/r_tele5.wav");
	precache_sound ("sounds_q4/items/ammo/default.wav");	// ammo pick up
	precache_sound ("sounds_q4/mp/pickups/weapon.wav");		// weapon up
	precache_sound ("sounds_q4/mp/pickups/armor.wav");  	// armor up
	precache_sound ("weapons/lhit.wav");		//lightning
	precache_sound ("weapons/lstart.wav");		//lightning start
	precache_sound ("items/damage3.wav");
	precache_sound ("sounds_q4/mp/pickups/wearoff.wav");
	precache_sound ("sounds_q4/mp/pickups/quad_loop_02.wav");

	precache_sound ("misc/power.wav");			//lightning for boss

// player gib sounds
	precache_sound ("player/gib.wav");			// player gib sound
	precache_sound ("player/udeath.wav");		// player gib sound
	precache_sound ("player/tornoff2.wav");		// gib sound

// player pain sounds

	precache_sound ("player/pain1.wav");
	precache_sound ("player/pain2.wav");
	precache_sound ("player/pain3.wav");
	precache_sound ("player/pain4.wav");
	precache_sound ("player/pain5.wav");
	precache_sound ("player/pain6.wav");

// player death sounds
	precache_sound ("player/death1.wav");
	precache_sound ("player/death2.wav");
	precache_sound ("player/death3.wav");
	precache_sound ("player/death4.wav");
	precache_sound ("player/death5.wav");

// ax sounds	
	precache_sound ("weapons/ax1.wav");			// ax swoosh
	precache_sound ("player/axhit1.wav");		// ax hit meat
	precache_sound ("player/axhit2.wav");		// ax hit world

	precache_sound ("player/h2ojump.wav");		// player jumping into water
	precache_sound ("player/slimbrn2.wav");		// player enter slime
	precache_sound ("player/inh2o.wav");		// player enter water
	precache_sound ("player/inlava.wav");		// player enter lava
	precache_sound ("misc/outwater.wav");		// leaving water sound

	precache_sound ("player/lburn1.wav");		// lava burn
	precache_sound ("player/lburn2.wav");		// lava burn

	precache_sound ("misc/water1.wav");			// swimming
	precache_sound ("misc/water2.wav");			// swimming
	precache_sound ("misc/null.wav");	
	precache_sound ("misc/fhit3.wav");

	precache_sound("monsters/imp/melee/hit_01.wav");
	precache_sound("monsters/imp/melee/hit_03.wav");
	precache_sound("monsters/imp/melee/hit_04.wav");

	precache_sound("monsters/imp/melee/miss_01.wav");
	precache_sound("monsters/imp/melee/miss_02.wav");
	precache_sound("monsters/imp/melee/miss_03.wav");

//	precache_model ("progs/male/tris.mdl");
	precache_model ("progs/player.mdl");
	precache_model ("progs/eyes.mdl");

	precache_model ("progs/barrels.mdl");
	precache_model ("progs/barrel2c.mdl");
	
	precache_model ("progs/h_player.mdl");
	precache_model ("progs/gib1.mdl");
	precache_model ("progs/gib2.mdl");
	precache_model ("progs/gib3.mdl");
	precache_model ("progs/debris1.mdl");
	precache_model ("progs/debris2.mdl");
	precache_model ("progs/debris3.mdl");

	precache_model ("progs/pork1.mdl");
	precache_model ("progs/pork2.mdl");
	precache_model ("progs/pork3.mdl");
	precache_model ("progs/pork4.mdl");
	precache_model ("progs/pork5.mdl");
	precache_model ("progs/brain.mdl");

	precache_model ("progs/s_bubble.spr");	// drowning bubbles
//	precache_model ("progs/r_explode.mdl");	// explosion
	precache_model ("progs/s_explo2.spr");
	precache_model ("progs/muzzleflash.spr");	
	
	precache_model ("progs/weapons/blaster/view.md3");
	precache_model ("progs/weapons/machinegun/view.md3");
	precache_model ("progs/weapons/shotgun/view.md3");
	precache_model ("progs/weapons/grenadelauncher/view.md3");
	precache_model ("progs/weapons/hyperblaster/view.md3");
	precache_model ("progs/weapons/nailgun/view.md3");
	precache_model ("progs/weapons/rocketlauncher/view.md3");
	precache_model ("progs/weapons/railgun/view.md3");
	precache_model ("progs/weapons/lightning_gun/view.md3");
	precache_model ("progs/weapons/darkmatter/view.md3");
	precache_model ("progs/weapons/darkmatter/darkmatter.md3");

	precache_model ("progs/player/player.md5.info");

	string mdl1, mdl2, mdl3;
	string whole;

	for (float i = 1; i <= 10; i ++)
	{
		mdl1 = "progs/player/marine/";
		mdl2 = "player";
		mdl3 = ".md5.info";

		whole = strcat (mdl1, mdl2, ftos(i), mdl3);

		precache_model(whole);
	}

	for (float i = 1; i <= 10; i ++)
	{
		mdl1 = "progs/player/bright/";
		mdl2 = "player";
		mdl3 = ".md5.info";
		whole = strcat (mdl1, mdl2, ftos(i), mdl3);

		precache_model(whole);
	}

	for (float i = 1; i <= 10; i ++)
	{
		mdl1 = "progs/player/marine2/";
		mdl2 = "player";
		mdl3 = ".md5.info";
		whole = strcat (mdl1, mdl2, ftos(i), mdl3);

		precache_model(whole);
	}

	for (float i = 1; i <= 10; i ++)
	{
		mdl1 = "progs/player/medic/";
		mdl2 = "player";
		mdl3 = ".md5.info";
		whole = strcat (mdl1, mdl2, ftos(i), mdl3);

		precache_model(whole);
	}

	for (float i = 1; i <= 10; i ++)
	{
		mdl1 = "progs/player/tech/";
		mdl2 = "player";
		mdl3 = ".md5.info";
		whole = strcat (mdl1, mdl2, ftos(i), mdl3);

		precache_model(whole);
	}

	precache_model ("progs/bolt.mdl");		// for lightning gun
	precache_model ("progs/bolt2.mdl");		// for lightning gun
	precache_model ("progs/bolt3.mdl");		// for boss shock
	precache_model ("progs/lavaball.mdl");	// for testing
	
	precache_model ("progs/weapons/missile.md3");
	precache_model ("progs/weapons/grenadelauncher/grenade.md3");
	precache_model ("progs/weapons/darkmatter/explode.md3");

	precache_model ("progs/spike.mdl");
	precache_model ("progs/s_spike.mdl");
	precache_model ("progs/weapons/nailgun/nail_g.md3");

	precache_model ("progs/backpack.mdl");
	precache_model ("progs/explo_wave.md3");
	precache_model ("progs/zom_gib.mdl");
	precache_model ("progs/tracer.md3");

	precache_model("progs/monsters/glass_ball.md3");

	//precache_sound ("chell/laugh_03.wav");
	
	particleeffectnum("d3fx.cfg");
	particleeffectnum("TE_BFG_BIGEXPLOSION");
	particleeffectnum("TE_BFG_BIGEXPLOSION2");

	particleeffectnum("EF_BLASTER");
	particleeffectnum("EF_PLASMA");
	particleeffectnum("EF_PLASMA_2");
	particleeffectnum("EF_ROCKETTRAIL");
	particleeffectnum("EF_CACOTRAIL");
	particleeffectnum("EF_NADETRAIL");
	particleeffectnum("EF_NADETRAIL2");
	particleeffectnum("EF_REVTRAIL"); particleeffectnum("EF_REVTRAIL2");
	particleeffectnum("TE_EXPLOSION_DUST");
	particleeffectnum("TE_EXPLOSION_DUST2");
	particleeffectnum("TE_EXPLOSION_DUST3");
	particleeffectnum("TE_EXPLOSION_BLAST"); particleeffectnum("TE_EXPLOSION_BLAST2");
	particleeffectnum("TE_EXPLOSION_BLAST_SMALL");
	particleeffectnum("TE_SHOCK_DUST");

	particleeffectnum("TE_BLOODSPRAY");
	particleeffectnum("EF_GIBSPRAY");
	particleeffectnum("TE_EXPLOD");
	particleeffectnum("TE_BLOODSPLAT1"); particleeffectnum("TE_BLOODSPLAT3"); 
	particleeffectnum("TE_BLOODSPLAT2"); particleeffectnum("TE_BLOODSPLAT4");
	particleeffectnum("TE_BFGIMPACT");
	particleeffectnum("TE_BFGIMPACT2");
	particleeffectnum("TE_ROCKETIMPAC");
	particleeffectnum("TE_ROCKETIMPAC2");
	particleeffectnum("TE_PLASIMPACT");
	particleeffectnum("TE_PLASIMPACT2");
	particleeffectnum("TE_PLASIMPACT3");

	particleeffectnum("TE_PLASIMPACT_RED");
	particleeffectnum("TE_PLASIMPACT2_RED");
	particleeffectnum("TE_PLASIMPACT3_RED");

	particleeffectnum("TE_DARKMATTER");
	particleeffectnum("TE_DARKMATTER_EAT");
	particleeffectnum("TE_DMG_IMPLOSION");

	particleeffectnum("TE_LEADIMPACT");
	particleeffectnum("TE_MUZZLEFLASH2");
	particleeffectnum("EF_MUZZLEFLASH");
	particleeffectnum("EF_FLASHLIGHT");

	particleeffectnum("EF_BFGBALL");
	particleeffectnum("TE_DUST");
	
	particleeffectnum("TE_BFGBEAM");
	particleeffectnum("TE_RAILTRAIL");
	particleeffectnum("TE_SUMMON");
	particleeffectnum("TE_ARCHVILEFLAME"); particleeffectnum("TE_ARCHVILEFLAME_HAND"); 
	particleeffectnum("TE_ARCHVILEFLAME_HAND2"); 
	particleeffectnum("EF_ARCHVILEFLAME_LIGHT"); particleeffectnum("EF_ARCHVILEFLAME_HAND_LIGHT"); 
	particleeffectnum("TE_BURNT");	
	particleeffectnum("TE_IMP_FIREBALL");
	particleeffectnum("TE_HK_FIREBALL");
	particleeffectnum("TE_MANC_FIREBALL");
	particleeffectnum("TE_CACO_FIREBALL"); 	particleeffectnum("TE_CACO_FLAME");
	particleeffectnum("EF_CACO_FIREBALL");
	particleeffectnum("TE_BFGBALLSAC");
	particleeffectnum("TE_PLASMA");
	particleeffectnum("TE_PLASMA_2");
	particleeffectnum("TE_GORESPRAY");
	particleeffectnum("TE_BERSERK_FLAME");
	particleeffectnum("TE_MGEAHEALTH_FLAME");
	
	particleeffectnum("EF_EXPLODLIGHT2");
	particleeffectnum("EF_SUMMONLIGHT");
	particleeffectnum("TE_BFGLASER");
	particleeffectnum("TE_CYBIE_FIREBALL");
	particleeffectnum("EF_MANC_FIRETRAIL");
	particleeffectnum("EF_CYBIE_FIRETRAIL");
	particleeffectnum("EF_POWERUP_LIGHT");
	particleeffectnum("TE_TORCH");
	particleeffectnum("TE_STROGG_NAIL");
	particleeffectnum("TE_BOLT_IMPACT");
	particleeffectnum("TE_BOLT_IMPACT_RED");
	particleeffectnum("TE_WHOOSH");
	particleeffectnum("TE_LTNG_CLUB");
	particleeffectnum("explo_smokie");
	particleeffectnum("EF_POD");

	particleeffectnum("EF_GASTRAIL");
	particleeffectnum("EF_GASTRAIL2");
	particleeffectnum("TE_GASBURST");
	particleeffectnum("TE_GAS_LINGER");
	particleeffectnum("TE_GAS_SPOT");
	particleeffectnum("EF_NADETRAIL2");
	particleeffectnum("TE_FLASH");
	particleeffectnum("EF_HHMISSTRAIL2");
	particleeffectnum("TE_STROGG_BULLET");
	particleeffectnum("TE_FLAMETHROWER");
	particleeffectnum("TE_FLAMETHROWER1");
	particleeffectnum("TE_ONFIRE");
	item_precaches ();
	
	call_clientstats ();

//
// Setup light animation tables. 'a' is total darkness, 'z' is maxbright.
//

	// 0 normal
	lightstyle(0, "m");
	
	// 1 FLICKER (first variety)
	lightstyle(1, "mmnmmommommnonmmonqnmmo");
	
	// 2 SLOW STRONG PULSE
	lightstyle(2, "abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba");
	
	// 3 CANDLE (first variety)
	lightstyle(3, "mmmmmaaaaammmmmaaaaaabcdefgabcdefg");
	
	// 4 FAST STROBE
	lightstyle(4, "mamamamamama");
	
	// 5 GENTLE PULSE 1
	lightstyle(5,"jklmnopqrstuvwxyzyxwvutsrqponmlkj");
	
	// 6 FLICKER (second variety)
	lightstyle(6, "nmonqnmomnmomomno");
	
	// 7 CANDLE (second variety)
	lightstyle(7, "mmmaaaabcdefgmmmmaaaammmaamm");
	
	// 8 CANDLE (third variety)
	lightstyle(8, "mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa");
	
	// 9 SLOW STROBE (fourth variety)
	lightstyle(9, "aaaaaaaazzzzzzzz");
	
	// 10 FLUORESCENT FLICKER
	lightstyle(10, "mmamammmmammamamaaamammma");

	// 11 SLOW PULSE NOT FADE TO BLACK
	lightstyle(11, "abcdefghijklmnopqrrqponmlkjihgfedcba");
	
	// styles 32-62 are assigned by the light program for switchable lights

	// 63 testing
	lightstyle(63, "a");

	light_style_boundary();
};

nosave float game_loaded; // alkaline

void() StartFrame =
{
    teamplay = cvar("teamplay");
    skill = cvar("skill");

	if(!game_loaded && framecount > 2)
	{	
		if(framecount != 3)
		{
			call_clientstats (); // stupid ass game
			activate_all_active_speakers();
		//	activate_all_active_flashlights();
		}

		game_loaded = 1;
	}
};

void() call_clientstats =
{
	clientstat(29, EV_FLOAT, velocity.x);
	clientstat(30, EV_FLOAT, velocity.y);
	clientstat(31, EV_FLOAT, velocity.z);
	clientstat(32, EV_FLOAT, flags);
	clientstat(33, EV_FLOAT, weaponid);
	clientstat(34, EV_FLOAT, invincible_finished);
	clientstat(35, EV_FLOAT, shake_interval);
	clientstat(36, EV_FLOAT, shake_time);
	clientstat(37, EV_FLOAT, powerups);
	clientstat(38, EV_FLOAT, super_damage_finished);
	clientstat(39, EV_FLOAT, fov);
	clientstat(40, EV_FLOAT, ammotype);
	clientstat(41, EV_FLOAT, weaponmodelpos.x);
	clientstat(42, EV_FLOAT, weaponmodelpos.y);
	clientstat(43, EV_FLOAT, weaponmodelpos.z);
	clientstat(44, EV_FLOAT, spawnmuzzleflash);
	clientstat(45, EV_ENTITY, locked_enemy);
	clientstat(46, EV_ENTITY, prelock_save);
	clientstat(47, EV_STRING, weaponname);
	clientstat(48, EV_FLOAT, ammo_bullets);
	clientstat(49, EV_FLOAT, ammo_grenades);
	clientstat(50, EV_FLOAT, ammo_coils);
	clientstat(51, EV_FLOAT, ammo_slugs);
	clientstat(52, EV_FLOAT, ammo_dmc);
	clientstat(53, EV_FLOAT, newweaponid);

	clientstat(54, EV_FLOAT, radsuit_finished);
	clientstat(55, EV_FLOAT, invisible_finished);
	clientstat(56, EV_FLOAT, flash_active);

	clientstat(57, EV_FLOAT, savedammo_bullets);
	clientstat(58, EV_FLOAT, savedammo_shells);
	clientstat(59, EV_FLOAT, savedammo_cells);
	clientstat(60, EV_FLOAT, savedammo_grenades);
	clientstat(61, EV_FLOAT, savedammo_nails);
	clientstat(62, EV_FLOAT, savedammo_rockets);
	clientstat(63, EV_FLOAT, savedammo_slugs);
	clientstat(64, EV_FLOAT, savedammo_dmc);
	clientstat(65, EV_FLOAT, oldweaponid);
}

/*
==============================================================================

BODY QUE

==============================================================================
*/

entity	bodyque_head;

void() bodyque =
{	// just here so spawn functions don't complain after the world
	// creates bodyques
};

void() InitBodyQue =
{
	bodyque_head = spawn();
	bodyque_head.classname = "bodyque";
	bodyque_head.owner = spawn();
	bodyque_head.owner.classname = "bodyque";
	bodyque_head.owner.owner = spawn();
	bodyque_head.owner.owner.classname = "bodyque";
	bodyque_head.owner.owner.owner = spawn();
	bodyque_head.owner.owner.owner.classname = "bodyque";
	bodyque_head.owner.owner.owner.owner = bodyque_head;
};


// make a body que entry for the given ent so the ent can be
// respawned elsewhere
void(entity ent) CopyToBodyQue =
{
	bodyque_head.angles = ent.angles;
	bodyque_head.model = ent.model;
	bodyque_head.modelindex = ent.modelindex;
	bodyque_head.frame = ent.frame;
	bodyque_head.colormap = ent.colormap;
	bodyque_head.movetype = ent.movetype;
	bodyque_head.velocity = ent.velocity;
	bodyque_head.flags = 0;
	setorigin (bodyque_head, ent.origin);
	setsize (bodyque_head, ent.mins, ent.maxs);
	bodyque_head = bodyque_head.owner;
};


