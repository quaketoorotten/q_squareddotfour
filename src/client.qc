
//float	modelindex_eyes, modelindex_player;

/*
=============================================================================

				LEVEL CHANGING / INTERMISSION

=============================================================================
*/

float	intermission_running;
float	intermission_exittime;

/*QUAKED info_intermission (1 0.5 0.5) (-16 -16 -16) (16 16 16)
This is the camera point for the intermission.
Use mangle instead of angle, so you can set pitch or roll as well as yaw.  'pitch roll yaw'
*/
void() info_intermission =
{
};

// shithead

// boundary check function
// take a float value and return:

// < 0 - return 0
// 0 - MAX - return integer value, always rounding down
// > MAX - return MAX
// where MAX is the max bit value, 255 is used with standard encoder below

float(float f, float MAX) f_bound =
{
	if (MAX > 16777215) 
		MAX = 16777215;

	if (f > MAX)
		f = MAX;
	else if (f < 0)
		f = 0;
	f = floor(f);
	return f;
};

// parm* value encoding and decoding
// maximize storage of data in parm* values
// most ammo data has a maximum of 200, armor is 200, health is 100, etc.
// this can be encoded into 8 bits -
// the original code uses 1 parm* per data point - a serious waste of bits
// each parm* variable has 24 bits - 3 * 8 bit values

// encode 3 values according to formulas with all values bounded 0 - 255
// values are set into float value 0 - 16777215

// where
// s1 - into high 8 bits
// s2 - into middle 8 bits
// s3 - into low 8 bits

float(float s1, float s2, float s3) encode =
{
	local float f;
	f = f_bound(s1, 255) * 65536 + f_bound(s2, 255) * 256 + f_bound(s3, 255);
	return f;
};

// generic encode

// s1 is value
// bits are max value - 1, 3, 7, 15, 31...255...65535...{n} - a series of 1 bits
// pos is the position in the parm* variable
// - position will be the next bit value above the previous bits
// - i.e. for 3 value bits at position 1, the next position is 4
// - for 7 value bits at position 4, the next position is 32
// binary math equivalent:
// - 00000011 - 3 value at 1
// - 00011100 - 7 value at 4
// - 11100000 - 7 value at 32

// you could encode any values in any position with this function
// it is included here as an example if you have values smaller or larger than 255 to encode
// such as the painkeep carry items with a limit of 3 on most inventory

float(float s1, float bits, float pos) g_encode =
{
	local float f;
	f = f_bound(s1, bits) * pos;
	return f;
};

// recover an 8 bit value (0 - 255) from parm encoding

// parmval - passed value of parm* variable

// where which is
// 1 - return high 8 bits
// 2 - return middle 8 bits
// 3 - return low 8 bits
// any other value - return low 8 bits

// use these handy codes to avoid confusion
float HI8 = 1; // s1 value of encode() call
float MID8 = 2; // s2 value of encode() call
float LOW8 = 3; // s3 value of encode() call

float(float parmval, float which) decode =
{
	local float f;

	if (which == 1)
		f = (parmval / 65536) & 255;
	else if (which == 2)
		f = (parmval / 256) & 255;
	else
		f = parmval & 255;
	return f;
};

// generic decode - extract data from generic encode above

// parmval is the parm* variable data
// bits are max value - 1, 3, 7, 15, 31...255...65535...{n} - a series of 1 bits
// pos is the position in the parm* variable

// this uses the same bits & pos to extract any generic encoded data
// see notes under g_encode for more details

float(float parmval, float bits, float pos) g_decode =
{
local float f;

	f = (parmval / pos) & bits;
	return f;
};

// replacement code for client.qc encode / decode functions
// these functions are called on map exit / map load to save player data in between levels
// all other data is zeroed!

// *** NOTE: care must be taken to encode and decode data from the same position in the parm* variables this way
// a simple notation error in encoding or decoding will corrupt data !

// the original code used 9 parms - leaving 7 for mods
// this code uses 4 parms for the original 9 and leaves one 8 bit slot in parm4 and 12 more parms free

void() SetChangeParms =
{
	if (self.health <= 0)
	{
		SetNewParms ();
		return;
	}

// remove items
	self.items = self.items - (self.items & 
	(IT_KEY1 | IT_KEY2) );
	
	self.powerups = self.powerups - (self.powerups & 
	(IT_INVISIBILITY | IT_SUIT | IT_QUAD) );

// cap super health
	if (self.health > 100)
		self.health = 100;
	if (self.health < 50)
		self.health = 50;
	parm1 = self.items;
	parm2 = self.health;
	parm3 = self.armorvalue;
	parm4 = self.ammo_bullets;
	parm5 = self.ammo_nails;
	parm6 = self.ammo_rockets;
	parm7 = self.ammo_cells;

	parm8 = self.weaponid;

	parm9 = self.armortype * 100;
	parm10 = self.armorbit;
	parm11 = encode(self.savedammo_shells, self.savedammo_dmc, self.savedammo_nails);
	parm12 = encode(self.savedammo_bullets, self.savedammo_rockets, self.savedammo_cells);
	parm13 = encode(self.savedammo_slugs, self.savedammo_grenades, self.ammo_dmc);
	parm14 = self.ammo_shells;
	parm15 = self.ammo_coils;
	parm16 = self.ammo_grenades;
	parm17 = self.ammo_slugs;
};

void() SetRespawnParms =
{	
	self.items = self.items - (self.items & 
	(IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3) );

	self.powerups = self.powerups - (self.powerups & 
	(IT_INVISIBILITY | IT_SUIT | IT_QUAD) );

// cap super health

	parm1 = self.items;
	parm2 = 100;
	parm3 = 0;
	parm4 = self.ammo_bullets;
	parm5 = self.ammo_nails;
	parm6 = self.ammo_rockets;
	parm7 = self.ammo_cells;

	parm8 = self.weaponid;

	parm9 = 0;
	parm10 = 0;
	parm11 = encode(self.savedammo_shells, self.savedammo_dmc, self.savedammo_nails);
	parm12 = encode(self.savedammo_bullets, self.savedammo_rockets, self.savedammo_cells);
	parm13 = encode(self.savedammo_slugs, self.savedammo_grenades, self.ammo_dmc);
	parm14 = self.ammo_shells;
	parm15 = self.ammo_coils;
	parm16 = self.ammo_grenades;
	parm17 = self.ammo_slugs;
};

void() SetNewParms =
{
	parm1 = IT_WEP_TWO | IT_WEP_ONE;
	parm2 = 100;
	parm3 = 0;
	parm4 = 80;
	parm5 = 0;
	parm6 = 0;
	parm7 = 0;
	parm8 = 1;
	parm9 = 0;
	parm10 = 0;
	parm11 = encode(0, 0, 0);
	parm12 = encode(80, 0, 0);
	parm13 = encode(0, 0, 0);
	parm14 = 0;
	parm15 = 0;
	parm16 = 0;
	parm17 = 0;
};

void() DecodeLevelParms =
{
	if (serverflags)
	{
		if (world.model == "maps/start.bsp")
			SetNewParms ();		// take away all stuff on starting new episode
	}
	
	self.items = parm1;
	self.health = parm2;
	self.armorvalue = parm3;
	self.ammo_bullets = parm4;
	self.ammo_nails = parm5;
	self.ammo_rockets = parm6;
	self.ammo_cells = parm7;
	self.weaponid = parm8;
	self.armortype = parm9 * 0.01;
	self.armorbit = parm10;

	self.savedammo_shells = decode(parm11, HI8);
	self.savedammo_dmc = decode(parm11, MID8);
	self.savedammo_nails = decode(parm11, LOW8);

	self.savedammo_bullets = decode(parm12, HI8);
	self.savedammo_rockets = decode(parm12, MID8);
	self.savedammo_cells = decode(parm12, LOW8);

	self.savedammo_slugs = decode(parm13, HI8);
	self.savedammo_grenades = decode(parm13, MID8);
	self.ammo_dmc = decode(parm13, LOW8);

	self.ammo_shells = parm14;
	self.ammo_coils = parm15;
	self.ammo_grenades = parm16;
	self.ammo_slugs = parm17;

};

/*
============
FindIntermission

Returns the entity to view from
============
*/
entity() FindIntermission =
{
	local	entity spot;
	local	float cyc;

// look for info_intermission first
	spot = find (world, classname, "info_intermission");
	if (spot)
	{	// pick a random one
		cyc = random() * 4;
		while (cyc > 1)
		{
			spot = find (spot, classname, "info_intermission");
			if (!spot)
				spot = find (spot, classname, "info_intermission");
			cyc = cyc - 1;
		}
		return spot;
	}

// then look for the start position
	spot = find (world, classname, "info_player_start");
	if (spot)
		return spot;
	
// testinfo_player_start is only found in regioned levels
	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;
	
	objerror ("FindIntermission: no spot");
	return world;
};


string nextmap;
void() GotoNextMap =
{
	if (cvar("samelevel"))	// if samelevel is set, stay on same level
		changelevel (mapname);
	else
		changelevel (nextmap);
};


void() ExitIntermission =
{
// skip any text in deathmatch
	if (deathmatch)
	{
		GotoNextMap ();
		return;
	}
	
	intermission_exittime = time + 1;
	intermission_running = intermission_running + 1;

//
// run some text if at the end of an episode
//
	if (intermission_running == 2)
	{
		if (world.model == "maps/e1m7.bsp")
		{
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 2);
			WriteByte (MSG_ALL, 3);
			if (!cvar("registered"))
			{
				WriteByte (MSG_ALL, SVC_FINALE);
				WriteString (MSG_ALL, "As the corpse of the monstrous entity\nChthon sinks back into the lava whence\nit rose, you grip the Rune of Earth\nMagic tightly. Now that you have\nconquered the Dimension of the Doomed,\nrealm of Earth Magic, you are ready to\ncomplete your task in the other three\nhaunted lands of Quake. Or are you? If\nyou don't register Quake, you'll never\nknow what awaits you in the Realm of\nBlack Magic, the Netherworld, and the\nElder World!");
			}
			else
			{
				WriteByte (MSG_ALL, SVC_FINALE);
				WriteString (MSG_ALL, "As the corpse of the monstrous entity\nChthon sinks back into the lava whence\nit rose, you grip the Rune of Earth\nMagic tightly. Now that you have\nconquered the Dimension of the Doomed,\nrealm of Earth Magic, you are ready to\ncomplete your task. A Rune of magic\npower lies at the end of each haunted\nland of Quake. Go forth, seek the\ntotality of the four Runes!");
			}
			return;
		}
		else if (world.model == "maps/e2m6.bsp")
		{
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 2);
			WriteByte (MSG_ALL, 3);

			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "The Rune of Black Magic throbs evilly in\nyour hand and whispers dark thoughts\ninto your brain. You learn the inmost\nlore of the Hell-Mother; Shub-Niggurath!\nYou now know that she is behind all the\nterrible plotting which has led to so\nmuch death and horror. But she is not\ninviolate! Armed with this Rune, you\nrealize that once all four Runes are\ncombined, the gate to Shub-Niggurath's\nPit will open, and you can face the\nWitch-Goddess herself in her frightful\notherworld cathedral.");
			return;
		}
		else if (world.model == "maps/e3m6.bsp")
		{
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 2);
			WriteByte (MSG_ALL, 3);

			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "The charred viscera of diabolic horrors\nbubble viscously as you seize the Rune\nof Hell Magic. Its heat scorches your\nhand, and its terrible secrets blight\nyour mind. Gathering the shreds of your\ncourage, you shake the devil's shackles\nfrom your soul, and become ever more\nhard and determined to destroy the\nhideous creatures whose mere existence\nthreatens the souls and psyches of all\nthe population of Earth.");
			return;
		}
		else if (world.model == "maps/e4m7.bsp")
		{
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 2);
			WriteByte (MSG_ALL, 3);

			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "Despite the awful might of the Elder\nWorld, you have achieved the Rune of\nElder Magic, capstone of all types of\narcane wisdom. Beyond good and evil,\nbeyond life and death, the Rune\npulsates, heavy with import. Patient and\npotent, the Elder Being Shub-Niggurath\nweaves her dire plans to clear off all\nlife from the Earth, and bring her own\nfoul offspring to our world! For all the\ndwellers in these nightmare dimensions\nare her descendants! Once all Runes of\nmagic power are united, the energy\nbehind them will blast open the Gateway\nto Shub-Niggurath, and you can travel\nthere to foil the Hell-Mother's plots\nin person.");
			return;
		}
// RITUAL

	// RITUAL - Added two messages for map6 intermission exit
		else if (world.model == "maps/ze1m6.bsp")
		{
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 2);
			WriteByte (MSG_ALL, 3);

			// Does the player have FOUR runes?
			if ( (serverflags&15) == 15) {
/*
1234567890123456789012345678901234567890
You have fought your way through sunken\n
castles and crumbling sanctuaries filled\n
with wretched beings to finally collect\n
all the artifacts.\n
\n
The four ancient runes are now yours,\n
each pulsating with energy that is\n
warping the edges of your mind.\n
Feeding you with incomprehensible\n
images of prehuman places scattered\n
across hellish landscapes.\n
\n
Racing back towards the Black Reef\n
Island you sense that the shrouded\n
shores will not promise you answers.\n
However something stirs and has risen,\n
the final horror has returned!\n
*/
				// player got ---- FOUR ---- runes
				WriteByte (MSG_ALL, SVC_FINALE);
				WriteString (MSG_ALL, "You have fought your way through sunken\ncastles and crumbling sanctuaries filled\nwith wretched beings to finally collect\nall the artifacts.\n\nThe four ancient runes are now yours,\neach pulsating with energy that is\nwarping the edges of your mind.\nFeeding you with incomprehensible\nimages of prehuman places scattered\nacross hellish landscapes.\n\nRacing back towards the Black Reef\nIsland you sense that the shrouded\nshores will not promise you answers.\nHowever something stirs and has risen,\nthe final horror has returned!\n");
			}
			// Player has LESS than FOUR runes!
			else {
/*
//1234567890123456789012345678901234567890
You step through the portal leaving\n
behind a world teetering on the brink\n
of its own grotesque annihilation.\n
\n
A realm steeped in barbarism,\n
hideous bile-spewing cultists,\n
shapeless necromantic priests and\n
unspeakable abominations!\n
\n
As the swirling ether closes behind you\n
a chilling uncertainty gnaws at your\n
sanity. The fiery rune in your hand\n
is pulsating with an unnatural heat\n
and yet it does not feel complete.\n
\n
Was this the ultimate aim of the\n
\bRitual project\b, or the beginning\n
of a far darker revelation!?!\n
You may have escaped (for now) but\n
in the shadows beyond, ancient eyes\n
are still watching... and waiting!\n
*/
				// player got ---- ONE TWO THREE ---- runes
				WriteByte (MSG_ALL, SVC_FINALE);
				WriteString (MSG_ALL, "You step through the portal leaving\nbehind a world teetering on the brink\nof its own grotesque annihilation.\n\nA realm steeped in barbarism,\nhideous bile-spewing cultists,\nshapeless necromantic priests and\nunspeakable abominations!\n\nAs the swirling ether closes behind you\na chilling uncertainty gnaws at your\nsanity. The fiery rune in your hand\nis pulsating with an unnatural heat\nand yet it does not feel complete.\n\nWas this the ultimate aim of the\n\bRitual project\b, or the beginning\nof a far darker revelation!?!\nYou may have escaped (for now) but\nin the shadows beyond, ancient eyes\nare still watching... and waiting!\n");
			}
			return;
		}
// ritual
		GotoNextMap();
	}
	
	if (intermission_running == 3)
	{
		if (!cvar("registered"))
		{	// shareware episode has been completed, go to sell screen
			WriteByte (MSG_ALL, SVC_SELLSCREEN);
			return;
		}
		
		if ( (serverflags&15) == 15)
		{
			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "Now, you have all four Runes. You sense\ntremendous invisible forces moving to\nunseal ancient barriers. Shub-Niggurath\nhad hoped to use the Runes Herself to\nclear off the Earth, but now instead,\nyou will use them to enter her home and\nconfront her as an avatar of avenging\nEarth-life. If you defeat her, you will\nbe remembered forever as the savior of\nthe planet. If she conquers, it will be\nas if you had never been born.");
			return;
		}
		
	}

	GotoNextMap();
};

/*
============
IntermissionThink

When the player presses attack or jump, change to the next level
============
*/
void() IntermissionThink =
{
	if (time < intermission_exittime)
		return;

	if (!self.button0 && !self.button1 && !self.button2)
		return;
	
	ExitIntermission ();
};

void() execute_changelevel =
{
	local entity	pos;

	intermission_running = 1;
	
// enforce a wait time before allowing changelevel
	if (deathmatch)
		intermission_exittime = time + 5;
	else
		intermission_exittime = time + 2;

	WriteByte (MSG_ALL, SVC_CDTRACK);
	WriteByte (MSG_ALL, 3);
	WriteByte (MSG_ALL, 3);
	
	pos = FindIntermission ();

	other = find (world, classname, "player");
	while (other != world)
	{
		other.view_ofs = '0 0 0';
		other.angles = other.v_angle = pos.mangle;
		other.fixangle = TRUE;		// turn this way immediately
		other.nextthink = time + 0.5;
		other.takedamage = DAMAGE_NO;
		other.solid = SOLID_NOT;
		other.movetype = MOVETYPE_NONE;
		other.modelindex = 0;
		other.powerups = other.powerups - (other.powerups & (IT_INVISIBILITY | IT_SUIT | IT_QUAD) );

		other.invisible_finished = 0;	
		other.invincible_finished = 0;
		other.super_damage_finished = 0;
		other.radsuit_finished = 0;

		sound(other, CHAN_FIVE, "misc/null.wav", 1, ATTN_NORM);
		setorigin (other, pos.origin);
		other = find (other, classname, "player");
	}	

	WriteByte (MSG_ALL, SVC_INTERMISSION);
};


void() changelevel_touch =
{
	if (other.classname != "player")
		return;

	if ((cvar("noexit") == 1) || ((cvar("noexit") == 2) && (mapname != "start")))
	{
		T_Damage (other, self, self.origin, self, 50000, 0);
		return;
	}

	if (coop || deathmatch)
	{
		bprint (other.netname);
		bprint (" exited the level\n");
	}
	
	nextmap = self.map;

	SUB_UseTargets ();

	if ( (self.spawnflags & 1) && (deathmatch == 0) )
	{	// NO_INTERMISSION
		GotoNextMap();
		return;
	}
	
	self.touch = SUB_Null;

// we can't move people right now, because touch functions are called
// in the middle of C movement code, so set a think time to do it
	self.think = execute_changelevel;
	self.nextthink = time + 0.1;
};

/*QUAKED trigger_changelevel (0.5 0.5 0.5) ? NO_INTERMISSION
When the player touches this, he gets sent to the map listed in the "map" variable.  Unless the NO_INTERMISSION flag is set, the view will go to the info_intermission spot and display stats.
*/
void() trigger_changelevel =
{
	if (!self.map)
		objerror ("chagnelevel trigger doesn't have map");
	
	InitTrigger ();
	self.touch = changelevel_touch;
};


/*
=============================================================================

				PLAYER GAME EDGE FUNCTIONS

=============================================================================
*/

void() set_suicide_frame;

// called by ClientKill and DeadThink
void() respawn =
{
	if (coop)
	{
		// get the spawn parms as they were at level start
		SetRespawnParms ();
		// respawn		
		PutClientInServer ();
	}
	else if (deathmatch)
	{
		// set default spawn parms
		SetNewParms ();
		// respawn		
		PutClientInServer ();
	}
	else
	{	// restart the entire server
		localcmd ("restart\n");
	}
};


/*
============
ClientKill

Player entered the suicide command
============
*/
void() ClientKill =
{
	bprint (self.netname);
	bprint (" suicides\n");
	set_suicide_frame ();
	//self.modelindex = modelindex_player;
	self.frags = self.frags - 2;	// extra penalty
	respawn ();
};

float(vector v) CheckSpawnPoint =
{
	return FALSE;
};

/*
============
SelectSpawnPoint

Returns the entity to spawn at
============
*/
entity() SelectSpawnPoint =
{
	local	entity spot;
	local	entity thing;
	local	float  pcount;
	
// testinfo_player_start is only found in regioned levels
	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;
		
// choose a info_player_deathmatch point
	if (coop)
	{
		lastspawn = find(lastspawn, classname, "info_player_coop");
		if (lastspawn == world)
			lastspawn = find (lastspawn, classname, "info_player_start");
		if (lastspawn != world)
			return lastspawn;
	}
	else if (deathmatch)
	{
		spot = lastspawn;
		while (1)
		{
			spot = find(spot, classname, "info_player_deathmatch");
			if (spot != world)
			{
				if (spot == lastspawn)
					return lastspawn;
				pcount = 0;
				thing = findradius(spot.origin, 32);
				while(thing)
				{
					if (thing.classname == "player")
						pcount = pcount + 1;
					thing = thing.chain;
				}
				if (pcount == 0)
				{
					lastspawn = spot;
					return spot;
				}
			}
		}
	}

	if (serverflags)
	{	// return with a rune to start
		spot = find (world, classname, "info_player_start2");
		if (spot)
			return spot;
	}
	
	spot = find (world, classname, "info_player_start");
	if (!spot)
		error ("PutClientInServer: no info_player_start on level");
	
	//vector org;
	//org = spot.origin + '0 0 -24';

	//spot.origin = org;
	return spot;
};

/*
===========
PutClientInServer

called each time a player is spawned
============
*/
void() DecodeLevelParms;
void() PlayerDie;

.vector view_ofs_guns;
//float player_slimy_transfer;

typedef struct { 
	float state;
	float jump_time;
	float land_time;
	float cooldown;
} player_animation_info;

typedef struct { 
	float start;
	float end;
	float loop;
} _framelimit;

.player_animation_info animinfo;
.string pmodel_name;

void() PutClientInServer =
{
	local	entity spot;

	spot = SelectSpawnPoint ();

	self.classname = "player";
	self.health = 100;
	self.takedamage = DAMAGE_AIM;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	self.show_hostile = 0;
	self.max_health = 100;
	self.mass = 100;
	self.flags = FL_CLIENT;
	self.air_finished = time + 12;
	self.dmg = 2;   		// initial water damage
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	self.invisible_finished = 0;
	self.invincible_finished = 0;
	self.effects = 0;
	self.invicible_time = 0;
	self.hitmarker_time = 0;
	self.shake_interval = 0;
	self.shake_time = 0;
	self.spawnmuzzleflash = 0;
	self.dspeed = 0;
	self.firerate = 0;
	self.scale = 0.75;
	self.flash_active = 0;
	self.flash_reactive = 0;
	self.animinfo.land_time = 0;
	self.animinfo.jump_time = 0;
	self.animinfo.state = AS_RESTING;
	self.newweaponid = 0;
	self.oldweaponid = 0;
	self.armor_rottime = 0;

	DecodeLevelParms ();

	self.attack_finished = time;
	self.th_pain = player_pain;
	self.th_die = PlayerDie;
	self.oldfov = 0;
	self.fov = 0;
	self.healamount = 0;
	self.weaponstate = WEAPON_ACTIVATE;
	
	self.deadflag = DEAD_NO;
// paustime is set by teleporters to keep the player from moving a while
	self.pausetime = 0;

	self.origin = spot.origin + '0 0 -23';
	self.angles = spot.angles;
	self.fixangle = TRUE;		// turn this way immediately
	self.oldorigin = self.origin;
	self.pmodel_name = infokey(self, "cl_player_model");

	string modelstr = strcat ("progs/player/", self.pmodel_name, "/player", "1", ".md5.info");
	setmodel (self, modelstr);
	setsize(self, '-16 -16 0', '16 16 56');

	W_SetCurrentAmmo (FALSE);
	PlayerTrail_Init();

	//self.scale = 1;
	
	self.view_ofs = '0 0 46';
	self.view_ofs_guns = '0 0 24';

	player_passive ();
//	player_spawn_pmodel ();
	
	if (deathmatch || coop)
	{
		makevectors(self.angles);
		spawn_tfog (self.origin + v_forward*20);
	}

	spawn_tdeath (self.origin, self);
};


/*
=============================================================================

				QUAKED FUNCTIONS

=============================================================================
*/


/*QUAKED info_player_start (1 0 0) (-16 -16 -24) (16 16 24)
The normal starting point for a level.
*/
void() info_player_start =
{
};


/*QUAKED info_player_start2 (1 0 0) (-16 -16 -24) (16 16 24)
Only used on start map for the return point from an episode.
*/
void() info_player_start2 =
{
};


/*
saved out by quaked in region mode
*/
void() testplayerstart =
{
};

/*QUAKED info_player_deathmatch (1 0 1) (-16 -16 -24) (16 16 24)
potential spawning position for deathmatch games
*/
void() info_player_deathmatch =
{
};

/*QUAKED info_player_coop (1 0 1) (-16 -16 -24) (16 16 24)
potential spawning position for coop games
*/
void() info_player_coop =
{
};

/*
===============================================================================

RULES

===============================================================================
*/

/*
go to the next level for deathmatch
only called if a time or frag limit has expired
*/
void() NextLevel =
{
	local entity o;

	if (mapname == "start")
	{
		if (!cvar("registered"))
		{
			mapname = "e1m1";
		}
		else if (!(serverflags & 1))
		{
			mapname = "e1m1";
			serverflags = serverflags | 1;
		}
		else if (!(serverflags & 2))
		{
			mapname = "e2m1";
			serverflags = serverflags | 2;
		}
		else if (!(serverflags & 4))
		{
			mapname = "e3m1";
			serverflags = serverflags | 4;
		}
		else if (!(serverflags & 8))
		{
			mapname = "e4m1";
			serverflags = serverflags - 7;
		}

		o = spawn();
		o.map = mapname;
	}
	else
	{
		// find a trigger changelevel
		o = find(world, classname, "trigger_changelevel");

		// go back to start if no trigger_changelevel
		if (!o)
		{
			mapname = "start";
			o = spawn();
			o.map = mapname;
		}
	}

	nextmap = o.map;
	gameover = TRUE;
	
	if (o.nextthink < time)
	{
		o.think = execute_changelevel;
		o.nextthink = time + 0.1;
	}
};

/*
============
CheckRules

Exit deathmatch games upon conditions
============
*/
void() CheckRules =
{
	local	float		timelimit;
	local	float		fraglimit;
	
	if (gameover)	// someone else quit the game already
		return;
		
	timelimit = cvar("timelimit") * 60;
	fraglimit = cvar("fraglimit");
	
	if (timelimit && time >= timelimit)
	{
		NextLevel ();
		return;
	}
	
	if (fraglimit && self.frags >= fraglimit)
	{
		NextLevel ();
		return;
	}	
};

//============================================================================

void() PlayerDeathThink =
{
//	local entity	old_self;
	local float		forward;

	if ((self.flags & FL_ONGROUND))
	{
		forward = vlen (self.velocity);
		forward = forward - 20;
		if (forward <= 0)
			self.velocity = '0 0 0';
		else	
			self.velocity = forward * normalize(self.velocity);
	}

// wait for all buttons released
	if (self.deadflag == DEAD_DEAD)
	{
		if (self.button2 || self.button1 || self.button0)
			return;
		self.deadflag = DEAD_RESPAWNABLE;
		return;
	}

// wait for any button down
	if (!self.button2 && !self.button1 && !self.button0)
		return;

	self.button0 = 0;
	self.button1 = 0;
	self.button2 = 0;
	self.button3 = 0;
	respawn();
};

void() PlayerJump =
{
//	local vector start, end;
	
	if (self.flags & FL_WATERJUMP)
		return;
	
	if (self.waterlevel >= 2)
	{
		if (self.watertype == CONTENT_WATER)
			self.velocity_z = 100;
		else if (self.watertype == CONTENT_SLIME)
			self.velocity_z = 80;
		else
			self.velocity_z = 50;

// play swiming sound
		if (self.swim_flag < time)
		{
			self.swim_flag = time + 1;
			if (random() < 0.5)
				sound (self, CHAN_BODY, "misc/water1.wav", 1, ATTN_NORM);
			else
				sound (self, CHAN_BODY, "misc/water2.wav", 1, ATTN_NORM);
		}

		return;
	}

	if (!(self.flags & FL_ONGROUND))
		return;

	if ( !(self.flags & FL_JUMPRELEASED) )
		return;		// don't pogo stick

	self.flags = self.flags - (self.flags & FL_JUMPRELEASED);

	self.flags = self.flags - FL_ONGROUND;	// don't stairwalk
	
	self.button2 = 0;
// player jumping sound
	sound (self, CHAN_BODY, "player/plyrjmp8.wav", 1, ATTN_NORM);
	self.velocity_z = self.velocity_z + 270;
};


/*
===========
WaterMove

============
*/
.float	dmgtime;

void() WaterMove =
{
//dprint (ftos(self.waterlevel));
	if (self.movetype == MOVETYPE_NOCLIP)
		return;
	if (self.health < 0)
		return;

	if (self.waterlevel != 3)
	{
		if (self.air_finished < time)
			sound (self, CHAN_VOICE, "player/gasp2.wav", 1, ATTN_NORM);
		else if (self.air_finished < time + 9)
			sound (self, CHAN_VOICE, "player/gasp1.wav", 1, ATTN_NORM);
		self.air_finished = time + 12;
		self.dmg = 2;
	}
	else if (self.air_finished < time)
	{	// drown!
		if (self.pain_finished < time)
		{
			self.dmg = self.dmg + 2;
			if (self.dmg > 15)
				self.dmg = 10;
			T_Damage (self, world, '0 0 0', world, self.dmg, 0);
			self.pain_finished = time + 1;
		}
	}
	
	if (!self.waterlevel)
	{
		if (self.flags & FL_INWATER)
		{	
			// play leave water sound
			sound (self, CHAN_BODY, "misc/outwater.wav", 1, ATTN_NORM);
			self.flags = self.flags - FL_INWATER;
		}
		return;
	}

	if (self.watertype == CONTENT_LAVA)
	{	// do damage
		if (self.dmgtime < time)
		{
			if (self.radsuit_finished > time)
				self.dmgtime = time + 1;
			else
				self.dmgtime = time + 0.2;

			T_Damage (self, world, '0 0 0', world, 10*self.waterlevel, 0);
		}
	}
	else if (self.watertype == CONTENT_SLIME)
	{	// do damage
		if (self.dmgtime < time && self.radsuit_finished < time)
		{
			self.dmgtime = time + 1;
			T_Damage (self, world,'0 0 0', world, 4*self.waterlevel, 0);
		}
	}
	
	if ( !(self.flags & FL_INWATER) )
	{	

// player enter water sound

		if (self.watertype == CONTENT_LAVA)
			sound (self, CHAN_BODY, "player/inlava.wav", 1, ATTN_NORM);
		if (self.watertype == CONTENT_WATER)
			sound (self, CHAN_BODY, "player/inh2o.wav", 1, ATTN_NORM);
		if (self.watertype == CONTENT_SLIME)
			sound (self, CHAN_BODY, "player/slimbrn2.wav", 1, ATTN_NORM);

		self.flags = self.flags + FL_INWATER;
		self.dmgtime = 0;
	}
	
	if (! (self.flags & FL_WATERJUMP) )
		self.velocity = self.velocity - 0.8*self.waterlevel*frametime*self.velocity;
};

void() CheckWaterJump =
{
	local vector start, end;

// check for a jump-out-of-water
	makevectors (self.angles);
	start = self.origin;
	start_z = start_z + 8; 
	v_forward_z = 0;
	normalize(v_forward);
	end = start + v_forward*24;
	traceline (start, end, TRUE, self);
	if (trace_fraction < 1)
	{	// solid at waist
		start_z = start_z + self.maxs_z - 8;
		end = start + v_forward*24;
		self.movedir = trace_plane_normal * -50;
		traceline (start, end, TRUE, self);
		if (trace_fraction == 1)
		{	// open at eye level
			self.flags = self.flags | FL_WATERJUMP;
			self.velocity_z = 225;
			self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
			self.teleport_time = time + 2;	// safety net
			return;
		}
	}
};

/*
================
PlayerPreThink

Called every frame before physics are run
================
*/

void() PlayerPreThink =
{
//	local	float	mspeed, aspeed;
//	local	float	r;
	
	if (intermission_running)
	{	
		IntermissionThink ();	// otherwise a button could be missed between
		return;					// the think tics
	}

	if (self.view_ofs == '0 0 0')
		return;		// intermission or finale

	makevectors (self.v_angle);		// is this still used

	CheckRules ();
	WaterMove ();
	WeaponChange ();

	if (self.shake_time < time && self.shake_time != 0)
	{
		self.shake_time = 0;
		self.shake_interval = 0;
	}

	if (self.waterlevel == 2)
		CheckWaterJump ();

	if (self.deadflag >= DEAD_DEAD)
	{
		PlayerDeathThink ();
		return;
	}
	
	if (self.deadflag == DEAD_DYING)
		return;	// dying, so do nothing

	if (self.button2)
	{
		PlayerJump ();
	}
	else
		self.flags = self.flags | FL_JUMPRELEASED;
	
// teleporters can force a non-moving pause time	
	if (time < self.pausetime)
		self.velocity = '0 0 0';

	if (!deathmatch)
	{
		if (!visible (PlayerTrail_LastSpot() ) )
		{	
			//bprint("guh","\n");
			PlayerTrail_Add (self.oldorigin);
		}
	}
};
	
/*
================
CheckPowerups

Check for turning off powerups
================
*/

void() BerserkSpeedUp =
{	
	if (!self.movement) // no movement inputs
		return;

	// berserk runs faster
	float maxspeed = cvar("sv_maxspeed");
	float spd = maxspeed * 1.6;
	vector fwd, r;
	AngleVectors([0, self.v_angle[1], 0], fwd, r);
	vector wish = fwd * self.movement[0] + r * self.movement[1];
	wish = normalize(wish);

	self.velocity[0] = wish[0] * spd;
	self.velocity[1] = wish[1] * spd;
}

void() AdrenalineSpeedUp =
{	
	if (!self.movement) // no movement inputs
		return;

	// adrenaline runs faster
	float maxspeed = cvar("sv_maxspeed");
	float spd = maxspeed * 1.3;
	vector fwd, r;
	AngleVectors([0, self.v_angle[1], 0], fwd, r);
	vector wish = fwd * self.movement[0] + r * self.movement[1];
	wish = normalize(wish);

	self.velocity[0] = wish[0] * spd;
	self.velocity[1] = wish[1] * spd;
}

void() CheckPowerups =
{
	if (self.health <= 0)
		return;

// invisibility
	if (self.invisible_finished)
	{	
	//	self.flags |= FL_NOTARGET;
// sound and screen flash when items starts to run out
		if (self.invisible_sound < time)
		{
			sound (self, CHAN_AUTO, "items/inv3.wav", 0.5, ATTN_IDLE);
			self.invisible_sound = time + ((random() * 3) + 1);
		}

		if (self.invisible_finished < time + 3)
		{
			if (self.invisible_time == 1)
			{
				//sprint (self, "Partial Invisibility is fading\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "sounds_q4/mp/pickups/wearoff.wav", 1, ATTN_NORM);
				self.invisible_time = time + 1;
			}
			
			if (self.invisible_time < time)
			{	
				sound(self, CHAN_AUTO, "sounds_q4/mp/pickups/wearoff.wav", 1, ATTN_NORM);
				self.invisible_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.invisible_finished < time)
		{	// just stopped
			self.powerups &= ~IT_INVISIBILITY;
		//	self.flags &= ~FL_NOTARGET;
			self.invisible_finished = 0;
			self.invisible_time = 0;
			self.alpha = 1;
		}
		
	// use the eyes
	//	self.frame = 0;
		self.alpha = 0.3;
	}

// invincibility
	if (self.invincible_finished)
	{
// sound and screen flash when items starts to run out
		if (self.invincible_finished < time + 3)
		{
			if (self.invicible_time == 1)
			{
				//sprint (self, "Regeneration is almost burned out\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "sounds_q4/mp/pickups/wearoff.wav", 1, ATTN_NORM);
				self.invicible_time = time + 1;
			}
			
			if (self.invicible_time < time)
			{	
				sound(self, CHAN_AUTO, "sounds_q4/mp/pickups/wearoff.wav", 1, ATTN_NORM);
				self.invicible_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.artifact_healtime < time)
		{
			self.artifact_healtime = time + 1;

			if (self.health >= 100 && self.health < 200)
			{
				self.health += 5;
				sound(self, CHAN_AUTO, "sounds_q4/mp/pickups/regen.wav", 1, ATTN_NORM);
			}

			else if (self.health < 100)
			{
				self.health += 15;
				sound(self, CHAN_AUTO, "sounds_q4/mp/pickups/regen.wav", 1, ATTN_NORM);
			}
		}

		if (self.health > 200)
		{
		//	self.nextthink2 = 9999999;
			self.health = 200;
		}
		
		if (self.invincible_finished < time)
		{	// just stopped
			self.powerups &= ~IT_REGENERATION;
			self.invicible_time = 0;
			self.invincible_finished = 0;
			self.nextthink2 = 0;
			self.artifact_healtime = 0;
			self.megahealth_finished = TRUE;
			self.megahealth_time = time + 0.1;
		}
		if (self.invincible_finished > time)
			self.effects = self.effects | EF_RED;
		else
			self.effects = self.effects - (self.effects & EF_RED);
	}

// super damage
	if (self.super_damage_finished)
	{	
		if (self.super_damage_finished < time + 3)
		{
			if (self.super_time == 1)
			{	
				//sprint(self, "Quad Damage is wearing off\n");
				stuffcmd(self, "bf\n");
				sound(self, CHAN_AUTO, "sounds_q4/mp/pickups/wearoff.wav", 1, ATTN_NORM);
				self.super_time = time + 1;
			}

			if (self.super_time < time)
			{	
				sound(self, CHAN_AUTO, "sounds_q4/mp/pickups/wearoff.wav", 1, ATTN_NORM);
				self.super_time = time + 1;
				stuffcmd(self, "bf\n");
			}
		}

		if (self.nextthink2 < time)
		{	
			//bprint("???", "\n");
			sound(self, CHAN_FIVE, "sounds_q4/mp/pickups/quad_loop_02.wav", 1, ATTN_NORM);
			self.nextthink2 = time + 4;
		}

		if (self.super_damage_finished < time)
		{ // just stopped
			self.nextthink2 = 0;
			self.powerups &= ~IT_QUAD;
			self.super_damage_finished = 0;
			self.super_time = 0;
			sound(self, CHAN_FIVE, "misc/null.wav", 1, ATTN_NORM);
		}
		if (self.super_damage_finished > time)
			self.effects = self.effects | EF_BLUE;
		else
			self.effects = self.effects - (self.effects & EF_BLUE);
	}	

// suit	
	if (self.radsuit_finished)
	{	
		self.air_finished = time + 12;		// don't drown

// sound and screen flash when items starts to run out
		if (self.radsuit_finished < time + 3)
		{
			if (self.rad_time == 1)
			{
				//sprint (self, "Air supply in Biosuit expiring\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "sounds_q4/mp/pickups/wearoff.wav", 1, ATTN_NORM);
				self.rad_time = time + 1;
			}
			
			if (self.rad_time < time)
			{	
				sound(self, CHAN_AUTO, "sounds_q4/mp/pickups/wearoff.wav", 1, ATTN_NORM);
				self.rad_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.radsuit_finished < time)
		{	// just stopped
			self.powerups &= ~IT_SUIT;
		//	self.items &= ~IT_SUIT;
			self.rad_time = 0;
			self.radsuit_finished = 0;
		}
	}	

	if (self.megahealth_finished)
	{	
		if (self.health <= self.max_health)
		{	// just stopped
			self.megahealth_finished = 0;
			self.megahealth_time = 0;
		}

		if (self.megahealth_time < time && self.health > self.max_health && self.nextthink2 < time)
		{
			self.health = self.health - 1;
			self.nextthink2 = time + 1;
		}
	}
};

void() armorRot = 
{	
	if (self.armorvalue > 100)
	{	
		self.armor_rotfinished = 1;
	}

	if (self.armor_rotfinished)
	{
		if (self.armorvalue <= 100)
		{
			self.armorvalue = 100;
			self.armor_rotfinished = 0;
			self.armor_rottime = 0;
		}	

		if (self.armor_rottime < time && self.armorvalue > 100)
		{	
			self.armorvalue = self.armorvalue - 1;
			self.armor_rottime = time + 0.75;
		}	
	}
}

/*
================
PlayerPostThink

Called every frame after physics are run
================
*/
.void() weaponthink;

void() PlayerPostThink =
{
//	local	float	mspeed, aspeed;
//	local	float	r;

	if (fog_active) change_fog(self);
			else setup_fog_controller();

	if (self.view_ofs == '0 0 0')
	{
		self.velocity = '0 0 0';
		self.effects = 0;

		return;		// intermission or finale
	}

	if (self.deadflag >= DEAD_DYING)
	{	
		W_WeaponDead ();
		return;
	}

	player_Animate (); 

// check to see if player landed and play landing sound	
	if ((self.jump_flag < -300) && (self.flags & FL_ONGROUND) && (self.health > 0))
	{
		if (self.watertype == CONTENT_WATER)
			sound (self, CHAN_BODY, "player/h2ojump.wav", 1, ATTN_NORM);
		else if (self.jump_flag < -650)
		{
			T_Damage (self, world, '0 0 0', world, 5, 0); 
			sound (self, CHAN_VOICE, "player/land2.wav", 1, ATTN_NORM);
			self.deathtype = "falling";
		}
		else
			sound (self, CHAN_VOICE, "player/land.wav", 1, ATTN_NORM);
		
	//	Playerfall ();
		self.jump_flag = 0;
	}

	if (!(self.flags & FL_ONGROUND))
		self.jump_flag = self.velocity_z;

	CheckPowerups ();

	if (skill > 2 && !deathmatch)
		armorRot ();

	if (deathmatch)
		armorRot ();

	W_WeaponZoom ();
	W_WeaponFlashlight ();
	W_WeaponThink ();
	W_WeaponReload ();

//	if ((self.jump_flag < -300) && (self.flags & FL_ONGROUND) && (self.health > 0))
//		self.jump_flag = 0
};	


/*
===========
ClientConnect

called when a player connects to a server
============
*/
void() ClientConnect =
{
	bprint (self.netname);
	bprint (" entered the game\n");
	
// a client connecting during an intermission can cause problems
	if (intermission_running)
		ExitIntermission ();

	//max_players++;

	self.pmodel_name = infokey(self, "cl_player_model");

	int edictnum = num_for_edict(self) - 1;
	self.playerflags = 1<<edictnum;

	PlayerTrail_Init ();
};


/*
===========
ClientDisconnect

called when a player disconnects from a server
============
*/
void() ClientDisconnect =
{
	if (gameover)
		return;
	// if the level end trigger has been activated, just return
	// since they aren't *really* leaving

	// let everyone else know
	bprint (self.netname);
	bprint (" left the game with ");
	bprint (ftos(self.frags));
	bprint (" frags\n");
	sound (self, CHAN_BODY, "player/tornoff2.wav", 1, ATTN_NONE);
	set_suicide_frame ();
};

/*
===========
ClientObituary

called when a player dies
============
*/

string gundeath1 [10] =
{
	"got humiliated by",
	"was sniped by",
	"chewed on",
	"blasted into oblivion by",
	"ate",
	"was nailed into the wall by",
	"choked on",
	"was railed by",
	"accepts",
	"got sucked into"
};

string gundeath2 [10] =
{
	"'s shitty pistol",
	"'s rifle",
	"'s boomstick'",
	"'s hyperblaster",
	"'s delicious pineapple",
	"'s nailgun",
	"'s massive missile",
	"'s railgun",
	"'s shaft",
	"'s dark hole"
};

void(entity targ, entity attacker) ClientObituary =
{
	local	float rnum;
	local	string deathstring, deathstring2;
	//string deathmsg;
	rnum = random();

	if (targ.classname == "player")
	{
		if (attacker.classname == "teledeath")
		{
			bprint (targ.netname, " was telefragged by ", attacker.owner.netname, "\n");
			attacker.owner.frags = attacker.owner.frags + 1;
			return;
		}

		if (attacker.classname == "teledeath2")
		{
			bprint ("Satan's power deflects ", targ.netname, "'s telefrag", "\n");
			targ.frags = targ.frags - 1;
			return;
		}

		if (attacker.classname == "player")
		{
			if (targ == attacker)
			{
				// killed self
				attacker.frags = attacker.frags - 1;
				
				if (targ.weaponname == "weapon_lightningun" && targ.waterlevel > 1)
				{
					deathstring = " discharges into the water";
				//	return;
				}

				if (targ.weaponname == "weapon_grenadelauncher")
					deathstring = " tries to put the pin back in";
				else
					deathstring = " becomes bored with life";

				bprint (targ.netname , deathstring ,"\n");
				return;
			}
			else if ( (teamplay == 2) && (targ.team > 0)&&(targ.team == attacker.team) )
			{
				if (rnum < 0.25)
					deathstring = " mows down a teammate\n";
				else if (rnum < 0.50)
					deathstring = " checks his glasses\n";
				else if (rnum < 0.75)
					deathstring = " gets a frag for the other team\n";
				else
					deathstring = " loses another friend\n";

				bprint (attacker.netname , deathstring ,"\n");
				attacker.frags = attacker.frags - 1;
				return;
			}
			else
			{
				attacker.frags = attacker.frags + 1;

				float gunid = attacker.weaponid - 1;
				
				deathstring = gundeath1[gunid];
				deathstring2 = gundeath2[gunid];

				bprint (targ.netname, " ",deathstring, " ",attacker.netname, deathstring2, "\n" );
			}
			return;
		}
		else
		{
			targ.frags = targ.frags - 1;
			bprint (targ.netname);

			// killed by a montser?
			if (attacker.flags & FL_MONSTER)
			{
				bprint(" ", attacker.deathtype, "\n");
				return;
			}

			// tricks and traps
			if (attacker.classname == "explo_box")
			{
				bprint (" blew up\n");
				return;
			}
			if (attacker.solid == SOLID_BSP && attacker != world)
			{	
				bprint (" was squished\n");
				return;
			}
			if (attacker.deathtype == "spike")
			{
				bprint (" was spiked\n");
				return;
			}
			if (attacker.deathtype == "plasma")
			{
				bprint (" was fried\n");
				return;
			}
			if (attacker.deathtype == "fire")
			{
				bprint (" was engulfed in flames\n");
				return;
			}
			if (attacker.deathtype == "acid")
			{
				bprint (" was corroded\n");
				return;
			}

			if (attacker.classname == "fireball")
			{
				bprint (" ate a cheeseball\n");
				return;
			}
			if (attacker.classname == "trigger_changelevel")
			{
				bprint (" tried to leave\n");
				return;
			}

			// in-water deaths
			rnum = targ.watertype;
			if (rnum == -3)
			{
				if (random() < 0.5)
					bprint (" sleeps with the fishes\n");
				else
					bprint (" sucks it down\n");
				return;
			}
			else if (rnum == -4)
			{
				if (random() < 0.5)
					bprint (" gulped a load of slime\n");
				else
					bprint (" can't exist on slime alone\n");
				return;
			}
			else if (rnum == -5)
			{
				if (targ.health < -15)
				{
					bprint (" burst into flames\n");
					return;
				}
				if (random() < 0.5)
					bprint (" turned into hot slag\n");
				else
					bprint (" visits the Volcano God\n");
				return;
			}

			// fell to their death?
			if (targ.deathtype == "falling")
			{
				targ.deathtype = "";
				bprint (" fell to his death\n");
				return;
			}

			// hell if I know; he's just dead!!!
			bprint (" died mysteriously\n");
		}
	}
};
