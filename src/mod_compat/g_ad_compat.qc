
// funcs ?

//======================================================================
// Trigger/use all entities that match the supplied targetname
// self is switched around so target use function works correctly
//
//----------------------------------------------------------------------
void(string target_strs, entity activator_ent) trigger_strs =
{
	local entity tself, tother, tactivator, ent_list;

	// Prevent this function from triggering everything by
	// checking if the target_str is empty (empty = world)
	if (target_strs != "") {
		// Store self/other for later
		tself = self;
		tother = other;
		tactivator = activator;
		if (activator_ent.flags & FL_CLIENT) activator = activator_ent;
	
		// Build initial list from world
		ent_list = find(world, targetname, target_strs);
		// Cycle through list
		while(ent_list) {
			// Setup self/other ready for trigger/use function
			self = ent_list;
			other = tself;
			if (self.use) {
				self.activate = activator_ent;		// Link activator
				self.use();							// Fire use function
			}
			// Find next trigger from intial list (not world)
			ent_list = find(ent_list, targetname, target_strs);
		}
		// Restore self/other from previous temp storage
		self = tself;
		other = tother;
		if (activator_ent.flags & FL_CLIENT) activator = tactivator;
	}
};

.float waitmin2;

//======================================================================
/*QUAKED ambient_custom_sound (0.5 0.1 0.8) (-16 -16 -8) (16 16 8) x PLAYONCE TRIGGER x x x STARTOFF x
Play a sound on a periodic basis
-------- KEYS --------
targetname : trigger entity (works with entity state system)
target  : targets to trigger each time sound is played
volume  : volume of sound (default 1, capped at 1)
noise   : primary sound (ambience/windgust1a.wav)
noise1  : stop sound (anbience/switch_6off.wav)
noise2  : random sound (ambience/windgust1b.wav)
wait    : random time between sounds (default 20, =-1 no random element)
delay   : minimum time between sounds (default 2)
waitmin : Starting time (waitmin + random() x waitmin, =-1 no delay)
waitmin2: 1 = Will not silence any playing sound if switching off
impulse : channel on which to play sound (0-7) (0 automatic is default)
speed   : attenuation -1=no attenuation, 1=normal (default), 2=idle, 3=static, 4=quiet
-------- SPAWNFLAGS --------
PLAYONCE : When triggered plays once
TRIGGER  : Constantly waits for trigger events (retrigger)
STARTOFF : Starts off and waits for trigger
-------- NOTES --------
Play a sound on a periodic basis
*/
//======================================================================
void() ambient_custom_stop =
{
	// Cannot block via entity state because there is an 'off sound'
	// Need to check against entity internal state for off state
	if (self.state == STATE_OFF) return;

	// Switch off sound emitter, clear next think
	self.state = STATE_OFF;
	self.think = SUB_Null;
	self.nextthink = time + 0.1;

	// Catch play once/disable setting separate
	if (self.estate & ESTATE_DISABLE) return;
	
	// Check for OFF sound, else play silence to clear sound
	if (self.noise1 != "") 
		sound (self, self.impulse, self.noise1, self.volume, self.speed);
	else {
		// If aflag is defined, do not cut off sound
		if (!self.waitmin2) sound (self, self.impulse, SOUND_EMPTY, self.volume, self.speed);
	}
};

//----------------------------------------------------------------------
void() ambient_custom_play =
{
	// Block everything except ON entity state
	if (self.estate & ESTATE_BLOCK) return;

	// Internal state used for switch off sound
	self.state = STATE_ON;
	
	// Check for random volume changes
	if (self.t_width > 0) {
		self.volume = self.t_width + (random() * self.t_length);
		if (self.volume > 1) self.volume = 1;
	}
	
	// Check for multiple random sounds
	if (self.noise2 != "" && random() < 0.5)
		sound (self, self.impulse, self.noise2, self.volume, self.speed);
	else sound (self, self.impulse, self.noise, self.volume, self.speed);
		
	// If any targets defined, trigger them
	if (self.target != "") trigger_strs(self.target, self);
	
	// Keep playing sound?
	// If sound is setup to play once, don't turn off sound before finished
	// Let the sound play out and switch off ambient sound entity
	if (self.spawnflags & SOUND_PLAYONCE) self.estate = ESTATE_DISABLE;
	else if (self.spawnflags & SOUND_TRIGGER) self.estate = ESTATE_OFF;
	else {
		// Check for any random time element
		if (self.wait == 0) self.nextthink = time + self.delay;
		else self.nextthink = time + self.delay + random()*self.wait;
		self.think = ambient_custom_play;
	}
};

//----------------------------------------------------------------------
void() ambient_custom_use =
{
	// Deal with STARTOFF functionality first
	if (self.spawnflags & ENT_STARTOFF) {
		// Remove spawnflag and switch ON entity
		self.spawnflags = self.spawnflags - ENT_STARTOFF;
		self.estate_on();
	}
	else {
		// Always allow trigger sounds to keep firing
		if (self.spawnflags & SOUND_TRIGGER) self.estate_on();
		else {			
			// Block USE functionality if state wrong
			if (self.estate & ESTATE_BLOCK) return;

			// Toggle state of ambient sound to start/stop
			if (self.state == STATE_OFF) self.estate_on();
			else self.estate_off();
		}
	}
};

//----------------------------------------------------------------------
void() ambient_custom_on =
{
	self.estate = ESTATE_ON;
	ambient_custom_play();
};

//----------------------------------------------------------------------
void() ambient_custom_off =
{
	ambient_custom_stop();
	self.estate = ESTATE_OFF;
};

//----------------------------------------------------------------------
void() ambient_custom_disable =
{
	self.state = STATE_OFF;
	sound (self, self.impulse, SOUND_EMPTY, self.volume, self.speed);
};

//----------------------------------------------------------------------
void() ambient_custom_sound =
{
	precache_sound (self.noise);
	
	// Is there an OFF sound defined (used for toggle sounds)
	if (self.noise1 != "") precache_sound (self.noise1);
	// Is there any random alternative sounds
	if (self.noise2 != "") precache_sound (self.noise2);
	
	self.classtype = CT_SOUNDEMITTER;
	self.state = STATE_OFF;
	
	// Check volume range is correct
	if (self.volume <= 0 || self.volume > 1) self.volume = 1;
	
	// Setup defaults for sound waits (-1=no random element)
	if (self.wait == 0) self.wait = 20;
	if (self.wait < 0) self.wait = 0;
	
	if (self.delay <= 0) self.delay = 2;
	if (self.waitmin == 0) self.waitmin = 4;
	if (self.impulse <= 0) self.impulse = 1;

	// attenuation -1=no attenuation, 1=normal (default), 2=idle, 3=static, 4=quiet	
	if (self.speed < 0) self.speed = ATTN_NONE;
	else if (self.speed == 2) self.speed = ATTN_IDLE;
	else if (self.speed == 3) self.speed = ATTN_STATIC;
	else if (self.speed == 4) self.speed = ATTN_QUIET;
	else self.speed = ATTN_NORM;
		
	// Setup Entity State functionality
	if (self.targetname != "") self.use = entity_state_use;
	self.estate_on = ambient_custom_on;
	self.estate_off = ambient_custom_off;
	self.estate_use = ambient_custom_use;
	self.estate_disable = ambient_custom_disable;
	
	if (self.spawnflags & ENT_STARTOFF) self.estate_off();
	else if (self.spawnflags & SOUND_TRIGGER) self.estate_off();
	else {
		if (self.waitmin > 0) {
			self.nextthink = time + self.waitmin + random()*self.waitmin;
			self.think = self.estate_on;
		}
		else self.estate_on();
	}
};

//======================================================

float(float fogrange) fog_check_range =
{
	if (fogrange < 0.01) return 0.01;
	if (fogrange > 1) return 1;
	return fabs(fogrange);
};

void() trigger_fog_fire =
{
	// This is after bmodel _use, _killed and _touch, so any reference
	// to the trigger activator has to go through 'bmodel_act'
	if (self.estate & ESTATE_BLOCK) return;
	if (self.attack_finished > time) return;
	// AD 1.8 removed SVR_NOFOGCMDS (winquake idea)
	
	// Print dev message if worldspawn not setup correctly
	// First fog blend will be weird otherwise
	if (!fog_active) {
		if (self.pain_finished < time) {
			dprint("\b[FOG]\b Missing density + colour on worldspawn!\n");
			dprint("\b[FOG]\b First fog blend requires worldspawn setup\n");
		}
		self.pain_finished = time + 1;
	}	
	
	// Crazy test option, random fog!
	if (self.lefty > 0) {
		// Extra test mode (-2) for fog density 1-10
		if (self.lefty == 2) self.fog_density = random()*10;
		// Default test mode (-1) for fog density 0-1
		else self.fog_density = random();
		self.fog_colour_x = random();
		self.fog_colour_y = random();
		self.fog_colour_z = random();
		self.speed = 1 + random()*4;
		// Show values on console
	}
	
	// Update global fog controller
	fade_fog(self.fog_density, self.fog_colour, self.speed);
	SUB_UseTargets();
	
	// Is the trigger repeatable?
	if (self.wait > 0) {
		if (self.wait < self.speed) self.wait = self.speed + 0.1;
		self.attack_finished = time + self.wait;
		self.nextthink = self.attack_finished;
		self.think = self.estate_on;
	}
	// block trigger and turn off (trigger_once)
	else {
		self.attack_finished = 99999;
		self.estate_off();
	}
};

//----------------------------------------------------------------------
void() trigger_fog_waitforcontrol =
{
	if (fog_control && fog_active) {
		// Setup Entity State functionality
		self.estate_fire = trigger_fog_fire;
		trigger_bmodel_setup();
	}
	else {
		self.think = trigger_fog_waitforcontrol;
		self.nextthink = time + 0.1 + random();
	}
};

//----------------------------------------------------------------------

//======================================================================
// Check for bmodel errors, model key empty (can crash engine)
//----------------------------------------------------------------------
float() check_bmodel_keys =
{
	if (self.model == "") {
		// this error can be fatal for most engines, show warning
		dprint ("\b[BMODEL]\b "); dprint (self.classname);
		dprint (" ("); dprint (self.targetname);
		dprint (") missing MODEL key!\n");
		
	//	self.classtype = CT_DEVMARKER;		// Useless entity
		self.movetype = MOVETYPE_NONE;		// Stationary
		self.solid = SOLID_NOT;				// no world interaction
		
		// If developer active show yellow diamond
	//	if (developer > 0) setmodel(self, MODEL_BROKEN);
		setmodel(self,"");
		
		// Make sure no world interaction
		setsize (self, VEC_ORIGIN, VEC_ORIGIN);
		
		// Randomly place debug diamond above 0,0,0
		self.pos1 = '0 0 0';
		self.pos1_z = random()*64;
		setorigin(self, self.pos1);
		
		// Do nothing with this entity
		return TRUE;
	}
	else return FALSE;
};

//----------------------------------------------------------------------
float() check_bmodel_notouch =
{
	// Cannot have a no touch AND no targetname setup!!!
	if (self.spawnflags & TRIG_NOTOUCH && self.targetname == "" && self.health < 1) {
		dprint("\b[TRIGGER]\b NO touch + NO targetname!\n");
		setmodel (self, self.model);
		self.oldorigin = bmodel_origin(self);
		return TRUE;
	}
	else return FALSE;
	
};

void() trigger_fog =
{
	if (check_bmodel_keys()) return;	// Check for bmodel errors
	if (check_bmodel_notouch()) return;	// NO touch + NO targetname!
	
	self.classtype = CT_TRIGFOG;
	self.classgroup = CG_TRIGGERS;
	InitTrigger ();

	// A fade time < minimum fade time = instant change
	if (self.speed == 0) self.speed = 2;
	if (self.speed < FADEFOG_TIME) self.speed = FADEFOG_TIME;
	if (self.wait == 0) self.wait = 2;
	self.attack_finished = 0;
	
	// Cannot have trigger touched by monsters
	self.spawnflags = self.spawnflags - (self.spawnflags & TRIG_MONSTERS);

	// Check for debug test mode (random density/colour)
	if (self.fog_density == -10) self.lefty = 1;		// Density 0-1
	else if (self.fog_density == -20) self.lefty = 2;	// Density 0-10
	else self.lefty = 0;
	
	// Default density/colour
	if (self.fog_density < 0) self.fog_density = 0;
	else if (self.fog_density == 0) self.fog_density = DEF_FOGDEN;
	// Check for fog colour 0,0,0 (black) option
	if (self.fog_colour_x < 0 || self.fog_colour_y < 0 || self.fog_colour_z < 0)
		self.fog_colour = '0 0 0';
	// Default colour (0.1 0.1 0.1)
	else if (CheckZeroVector(self.fog_colour)) self.fog_colour = DEF_FOGCOL;

	trigger_fog_waitforcontrol();
};


//----------------------------------------------------------------------
// Check vectors for zero content (extremely useful)
//----------------------------------------------------------------------
float(vector check_vec) CheckZeroVector =
{
	if (check_vec_x == 0 && check_vec_y == 0 && check_vec_z == 0)
		return TRUE;
	else return FALSE;
};

/*======================================================================
 visxray (variable options)
  Returns TRUE if there is no blocking, FALSE if something in the way
  Custom options for variable source/target offsets and monster blocking
  (nomonsters) TRUE = no block, FALSE = blocked
  self is excluded from any trace starting points
======================================================================*/
float(entity targ, vector s_offset, vector t_offset, float nomonsters) visxray =
{
	local vector spot1, spot2;

	// Bmodels don't have proper origins
	if (self.bsporigin) spot1 = bmodel_origin(self) + s_offset;
	else spot1 = self.origin + s_offset;

	spot2 = targ.origin + t_offset;
	traceline (spot1, spot2, nomonsters, self);	// custom options
	
	// Check for liquid surface block condition
//	if (check_liquidblock(spot1, spot2) == TRUE) return FALSE; cut

	// monster blocking changes which test to use
	if (nomonsters) {
		// Has the traceline gone from source>target without anything blocking?
		if (trace_fraction == 1) return TRUE;
		return FALSE;
	}
	else {
		// Is the entity hit by the traceline the targ destination?
		if (trace_ent == targ) return TRUE;
		return FALSE;
	}
};

//======================================================================
// Main fog functions
//======================================================================
void(entity client) change_fog  =
{
	if (!fog_control) return;
	
	// Update fog parameters to console buffer
	stuffcmd(client, "\n\n\nfog ");
	// Fog density can be in the range of 0-99
	lftos(client, fog_control.fog_currden, 2,3, BUFFER_STUFFCMD);

	// I use to have a direct fix for DP/FTE engines with fog density
	// being wrong, but it seems DP (latest build) is completely broken
	// with AD and it feels pointless to keep trying to fix engine visuals.
	// So this QC hack is now removed and the fog setup is as the mapper
	// intended with no QC modification.
	// if (ext_dpfog) lftos(client, fog_control.fog_currden+0.05, 1,3, BUFFER_STUFFCMD); 
	// else lftos(client, fog_control.fog_currden, 1,3, BUFFER_STUFFCMD);
	
	stuffcmd(client, " "); 
	lftos(client, fog_control.fog_currcol_x, 1,3, BUFFER_STUFFCMD); 
	stuffcmd(client, " "); 
	lftos(client, fog_control.fog_currcol_y, 1,3, BUFFER_STUFFCMD); 
	stuffcmd(client, " "); 
	lftos(client, fog_control.fog_currcol_z, 1,3, BUFFER_STUFFCMD); 
	
	stuffcmd(client, "\n");
};

//----------------------------------------------------------------------
// Main fog controller loop
//----------------------------------------------------------------------
void() fog_controller_think =
{
	// Has there been a change detected?
	if (self.state == STATE_SETUP) {
		// If fog fade time too low, instantly switch
		if (self.fog_difftime <= FADEFOG_TIME) {
			self.state = STATE_OFF;
			self.fog_currden = self.fog_targden;
			self.fog_currcol = self.fog_targcol;
			change_fog(self.owner);
		}
		else {
			// Setup gradual fade of fog over time
			self.state = STATE_ON;
			// divide the fade time into segments (minimum 0.05)
			// Multiple the time by segments so diff is correct
			// Time segements less than 0.05 does not work v well
			self.fog_steptime = self.fog_difftime / FADEFOG_TIME;
			self.fog_difftime = self.fog_steptime * FADEFOG_TIME;
			
			// Work out fade directions for density/colour
			self.fog_diffden = self.fog_targden - self.fog_currden;
			self.fog_diffcol = self.fog_targcol - self.fog_currcol;

			// Debug info only
			/*----------------------------------------------------------------------
			dprint("Curr ("); 
			lftos(self.owner, self.fog_currden, 1,3, BUFFER_DPRINT); dprint(")(");
			lftos(self.owner, self.fog_currcol_x, 1,3, BUFFER_DPRINT); dprint(" ");
			lftos(self.owner, self.fog_currcol_y, 1,3, BUFFER_DPRINT); dprint(" ");
			lftos(self.owner, self.fog_currcol_z, 1,3, BUFFER_DPRINT); dprint(")\n");
			dprint("Targ ("); 
			lftos(self.owner, self.fog_targden, 1,3, BUFFER_DPRINT); dprint(")(");
			lftos(self.owner, self.fog_targcol_x, 1,3, BUFFER_DPRINT); dprint(" ");
			lftos(self.owner, self.fog_targcol_y, 1,3, BUFFER_DPRINT); dprint(" ");
			lftos(self.owner, self.fog_targcol_z, 1,3, BUFFER_DPRINT); dprint(")\n");
			dprint("Diff ("); 
			lftos(self.owner, self.fog_diffden, 1,3, BUFFER_DPRINT); dprint(")(");
			lftos(self.owner, self.fog_diffcol_x, 1,3, BUFFER_DPRINT); dprint(" ");
			lftos(self.owner, self.fog_diffcol_y, 1,3, BUFFER_DPRINT); dprint(" ");
			lftos(self.owner, self.fog_diffcol_z, 1,3, BUFFER_DPRINT); dprint(")\n");
			//----------------------------------------------------------------------*/

			// Work out step ammount to fade smoothly over time
			self.fog_diffden = self.fog_diffden / self.fog_steptime;
			self.fog_diffcol_x = self.fog_diffcol_x / self.fog_steptime;
			self.fog_diffcol_y = self.fog_diffcol_y / self.fog_steptime;
			self.fog_diffcol_z = self.fog_diffcol_z / self.fog_steptime;
		}
	}
	// Is the fog fade over? Finite amount of steps
	else if (self.fog_steptime < 0 && self.state != STATE_OFF) {
		self.state = STATE_OFF;
		self.fog_currden = self.fog_targden;
		self.fog_currcol = self.fog_targcol;

		// Density and colour should be capped at 1, but it seems
		// density can go much higher and is needed to make it solid
		// Removed the upper cap check - AD 1.7 Patch 2
		//self.fog_currden = fog_check_range(self.fog_currden);
		if (self.fog_currden < 0) self.fog_currden = 0;
		if (self.fog_currden > 99) self.fog_currden = 99;
		// Check density and colour values are within range
		self.fog_currcol_x = fog_check_range(self.fog_currcol_x);
		self.fog_currcol_y = fog_check_range(self.fog_currcol_y);
		self.fog_currcol_z = fog_check_range(self.fog_currcol_z);
		
		change_fog(self.owner);
	}
	// If the fade is active, keep adding steps
	else if (self.state == STATE_ON) {
		self.fog_steptime = self.fog_steptime - 1;
		self.fog_currden = self.fog_currden + self.fog_diffden;
		self.fog_currcol = self.fog_currcol + self.fog_diffcol;
		change_fog(self.owner);
	}

	// Keep on looping around using min time step
	self.think = fog_controller_think;
	self.nextthink = time + FADEFOG_TIME;
};

//----------------------------------------------------------------------
void(float gf_den, vector gf_col, float gf_time) fade_fog =
{
	// No controller active?
	if (!fog_control) return;

	// Fog density can be higher than 1, check larger range
	if (gf_den < 0) gf_den = 0;
	if (gf_den > 99) gf_den = 99;
	//gf_den = fog_check_range(gf_den);
	// Check colour values are within range
	gf_col_x = fog_check_range(gf_col_x);
	gf_col_y = fog_check_range(gf_col_y);
	gf_col_z = fog_check_range(gf_col_z);
		
	// Setup fog controller with new fog values
	fog_control.fog_targden = gf_den;
	fog_control.fog_targcol = gf_col;
	fog_control.fog_difftime = gf_time;

	// Force fog controller to calculate difference
	fog_control.state = STATE_SETUP;
};

float CT_CONTROL = 150;	

//----------------------------------------------------------------------
// Setup the fog controller entity (called from client if defined)
//----------------------------------------------------------------------
void() setup_fog_controller =
{
	if (!fog_control) {
		// Start off with the fog controller disabled
		// if the worldspawn setup correctly then enable
		// the controller and allow fog changes
		fog_active = FALSE;
		
		fog_control = spawn();
		fog_control.owner = self;				// Link back to client
		fog_control.classtype = CT_CONTROL;
		fog_control.solid = SOLID_NOT;			// No world interaction
		fog_control.movetype = MOVETYPE_NONE;	// Static item, no movement
		setorigin(fog_control, '0 0 0');
		setsize(fog_control, VEC_ORIGIN, VEC_ORIGIN);
		
		if (world.fog_density <= 0) {
			fog_active = FALSE;						// out of sync
			fog_control.fog_currden = DEF_FOGDEN;	// Bad default
			fog_control.fog_targden = DEF_FOGDEN;	// Target
		}
		else {
			fog_active = TRUE;					// engine and QC insync
			fog_control.fog_currden = world.fog_density;
			fog_control.fog_targden = world.fog_density;
		}
		fog_control.fog_diffden = 0;			// Difference

		if (CheckZeroVector(world.fog_colour)) {
			fog_active = FALSE;						// out of sync
			fog_control.fog_currcol = DEF_FOGCOL;	// Bad Default
			fog_control.fog_targcol = DEF_FOGCOL;	// Target
		}
		else {
			fog_active = TRUE;					// engine and QC insync
			fog_control.fog_currcol = world.fog_colour;
			fog_control.fog_targcol = world.fog_colour;
		}
		fog_control.fog_diffcol = '0 0 0';		// Difference
		fog_control.fog_dpextra = world.fog_dpextra;

		// This is a horrible hack, it should not be here
		// This parameter should be in the map file worldspawn
		//if (world.model == "maps/ad_end.bsp") 
		//	fog_control.fog_dpextra = "1 0 2048 8192 32";
		
		fog_control.state = STATE_OFF;	// Not fading atm
		fog_control.fog_difftime = 0;	// fading fog time (seconds)
		fog_control.fog_steptime = 0;	// How many steps to fade

		// Setup think process to monitor for fog changes
		// If this entity already exists, then its thinking!
		fog_control.think = fog_controller_think;
		fog_control.nextthink = time + FADEFOG_TIME;
		
		if (fog_active) change_fog(self);
	}
};


void() misc_shake =
{	
	remove(self);
	// foobar
};

//======================================================================
/*QUAKED light_candle (0 1 0) (-4 -4 -16) (4 4 16) LIGHTOFF FLAMEOFF x SHADOWS x STATIC x x
{ model(":progs/misc_candle1.mdl"); }
Wide variety of Candles (from Rogue Software)
-------- KEYS --------
targetname : toggle state (use trigger ent for exact state)
angle      : 0=random angle, 1-360=specific
height     : size of candle 1=short, 2=medium, 3=regular, -1=random
t_width    : width of candle 1=regular, 2=fat, 3=thin, -1=random
lip        : Moves model down to ground plane (default = 16)
light      : sets brightness, 300 is default
_color     : Light color - R/G/B (def='1 1 1')
wait       : Fade distance multiplier (def=1)
delay      : Attenuation 0=Linear, 1=inverse, 2=Squared, 3=NoFalloff, 4=Minlight, 5=Good Ambient
mangle     : Spotlight direction
angle      : Spotlight cone angle (def=40)

_dirt      : Dirt map (override)
_dirtscale : Dirt scale (override)
_deviance  : Deviance
_samples   : No. of Deviance lights (def=16)
_surface   : Surface light texture name
_surface_offset : Surface light offset (def=2)
_softangle : Spotlight soft angle (def=0)
_anglescale: Light angle scale (def=0.5)
-------- SPAWNFLAGS --------
LIGHTOFF   : Starts off and waits for trigger
FLAMEOFF   : The candle is displayed off (no flame)
SHADOWS    : Turn on shadows in DP engine
STATIC     : Turn entity into static upon spawn (frame 0)
-------- NOTES --------
Wide variety of Candles (from Rogue Software)

======================================================================*/
float LIGHT_STARTOFF = 1;
float LIGHT_NOSOUND = 2;
float LIGHT_QUOTHNOSTAT = 2;
float LIGHT_NOSTATIC = 4;
float LIGHT_FLAMEOFF = 2;
float LIGHT_CANDLESHADOW = 8;
float LIGHT_SWITCHFADE = 16;
float LIGHT_NOEFFECTS = 128;

string light_style_str[64];

void() light_candle_on =
{
	self.estate = ESTATE_ON;
	self.frame = 1 + (self.t_width-1)*2;
	// Light style defined? (use array to get the latest)
	if (self.style > 0) lightstyle(self.style, light_style_str[self.style]);
};

//----------------------------------------------------------------------
void() light_candle_off =
{
	self.estate = ESTATE_OFF;
	self.frame = (self.t_width-1)*2;
	lightstyle(self.style, "a");
};

//----------------------------------------------------------------------
void() light_candle_setup =
{
	// Setup model and no world interaction
	setmodel (self, self.mdl);
	setsize (self, VEC_ORIGIN, VEC_ORIGIN);

	// Setting the angle key in the editor to UP/DOWN = random rotation	
	if (self.angles_y <= 0) self.angles_y = rint(random()*359);
	
	// Setup light
	if (self.spawnflags & LIGHT_FLAMEOFF) {
		self.estate = ESTATE_OFF;
		self.frame = (self.t_width-1)*2;
	}

	// Check for static option (default is now static if no target)
	if (self.spawnflags & ENT_SPNSTATIC) makestatic(self);
	else {
		// Custom estate on/off functions
		self.estate_on = light_candle_on;
		self.estate_off = light_candle_off;
		// Check for any custom light styles
		light_customstyle_start();
	}
};

void() light_customstyle_start =
{
	// Need to check style and remap values are within range FIRST
	// Will be serious crash because its an index for fixed size array
	if (self.style < 0 || self.style >= LIGHT_MAXLIGHTSTYLE) {
		dprint("\b[LIGHT]\b light style ("); dprint(ftos(self.style));
		dprint(") out of range!\n");
		remove(self);
		return;
	}
	else if (self.customstyle_remap < 0 || self.customstyle_remap >= LIGHT_MAXLIGHTSTYLE) {
		dprint("\b[LIGHT]\b remap style ("); dprint(ftos(self.customstyle_remap));
		dprint(") out of range!\n");
		remove(self);
		return;
	}

	// All custom lightstyle strings must happen FIRST, so that
	// the array is setup with all the correct strings for remaps
	// Needs slight delay to make sure array has defaults setup
	// No style key check so that style 0 (whole map) can be changed
	if (self.customstyle_string != "") {
		// string has priority over remap
		self.customstyle_remap = 0;
		self.think = light_customstyle_finish;
		self.nextthink = time + 0.1;
	}
	// Re-map lightstyles MUST happen after custom lightstyle strings
	// These lights will have problems being static because of timing
	// Static lights need to be converted early to work properly
	else if (self.customstyle_remap > 0 && self.style > 0) {
		// Will be redefined later
		self.customstyle_string = "";
		self.think = light_customstyle_finish;
		self.nextthink = time + 0.3;
	}
	// Finally switchable lights with styles defined by the compiler
	// These are not removeable or static because of interaction
	// Will need entity state setup and 'use' functionality
	else if (self.targetname != "") light_customstyle_finish();
	else {
		// DEFAULT = No world interaction because no targetname
		// Either remove light or make it static (model exists)
		// This should be happening at spawntime + 0.0
		if (self.classtype == CT_LIGHT) remove(self);
		else if (self.classtype == CT_LIGHTSTATIC) setup_light_static();
	}
};

void() setup_light_static =
{
	// Default = static, check for exception spawnflag
	if (self.spawnflags & LIGHT_NOSTATIC) return;
	// Setup any models that are defined
	if (self.mdl) setmodel (self, self.mdl);
	// Cannot have static entities and particle emitters!
//	if (self.part_emitter && self.part_static == FALSE) return;
	// Goodbye entity, no longer interactive with QC
	makestatic (self);
};

.float customstyle_remap;
.string customstyle_string;
//----------------------------------------------------------------------
void() light_customstyle_finish =
{
	// Check for style errors above compiler light boundary
	// Only for lights with style range issues + customstyles remap/string
	if (self.style >= mapstyle_start && self.targetname == "") {
		// The light entity is using a style number in the compiler
		// generated (they always have targetname) target light zone.
		// If this issue is left, weird things will start happening
		// to lightstyles, highlight error to mapper.
		dprint("\b[LIGHT]\b style ("); dprint(ftos(self.style));
		dprint(") cannot be used, error!\n");
		remove(self);
		return;
	}
	// Style has to be different to re-map
	if (self.customstyle_remap > 0 && self.customstyle_remap == self.style) {
		dprint("\b[LIGHT]\b remap and style are the same!\n");
		remove(self);
		return;
	}

	// Any re-map custom style lights defined?
	if (self.customstyle_remap > 0 && self.style > 0) {
		// Copy string from array
		self.customstyle_string = light_style_str[self.customstyle_remap];
		// Show debug info for custom lightstyle remaps
		dprint("\b[LIGHT]\b ("); dprint(self.classname);
		dprint(") style ("); dprint(ftos(self.style));
		dprint(") remap ("); dprint(ftos(self.customstyle_remap));
		dprint(")\n");
	}

	// Any custom style light string defined?
	// No style check, so that 0 (default, whole map) can be changed
	if (self.customstyle_string != "") {
		// Save the light style to the array
		light_style_str[self.style] = self.customstyle_string;
		// Define new light style to the engine
		lightstyle(self.style, self.customstyle_string);
		// Only show debug info for new custom lightstyles not remaps
		if (self.customstyle_remap == 0) {
			dprint("\b[LIGHT]\b ("); dprint(self.classname);
			dprint(") style ("); dprint(ftos(self.style));
			dprint(") string ("); dprint(self.customstyle_string);
			dprint(")\n");
		}
	}
	
	// Is this a switchable light?
	if (self.targetname != "") {
		// For reference later by other functions
		// self.classgroup = CG_LIGHTS;
		// Setup Entity State functionality
		self.use = entity_state_use;
	//	if (!self.estate_on) self.estate_on = light_on; later. . .
	//	if (!self.estate_off) self.estate_off = light_off;
		if (self.spawnflags & LIGHT_STARTOFF) self.estate_off();
		else self.estate_on();
	}
	else {
		// No more world interaction required (no targetname)
		// Either remove light or make it static (model exists)
		if (self.classtype == CT_LIGHT) remove(self);
		else if (self.classtype == CT_LIGHTSTATIC) setup_light_static();
	}
};

float CT_LIGHT = 200;			// Light entity
float CT_LIGHTSTATIC = 210;		// Static light entity

//----------------------------------------------------------------------
void() light_candle =
{
	// Cannot have randomly selected models for prechache
	// Quickload will re-run all spawn functions and try to select
	// a different candle model which is not precached
	precache_model ("progs/misc_candle1.mdl");
	precache_model ("progs/misc_candle2.mdl");
	precache_model ("progs/misc_candle3.mdl");

	// Check for size 1=small, 2=medium, 3=regular (def), -1=random
	if (self.height < 0) self.height = 1 + rint(random()*2);
	if (self.height == 1) self.mdl = "progs/misc_candle1.mdl";
	else if (self.height == 2) self.mdl = "progs/misc_candle2.mdl";
	else self.mdl = "progs/misc_candle3.mdl";
	
	// Check for width 1=regular (def), 2=fat, 3=thin, -1=random
	// The models are split up into three groups of off/on
	if (self.t_width < 0) self.t_width = 1 + rint(random()*2);
	else if (self.t_width == 0 || self.t_width > 3) self.t_width = 1;

	self.modelindex = 0;
	self.model = string_null;				// hide bmodel surface
	self.frame = 1 + (self.t_width-1)*2;	// Def = on state
	self.movetype = MOVETYPE_NONE;			// Create baseline
	self.solid = SOLID_NOT;
	self.nextthink = 0;

	// The model should not be setup flush to floor because it is a light
	// source and will look really odd, setup entity 16 units above floor
	// and the "lip" key will move it back down again
	if (!self.lip) self.lip = 16;
	self.origin_z = self.origin_z - self.lip;

	// Check for static entity option first
	if (self.spawnflags & ENT_SPNSTATIC) light_candle_setup();
	else {
		// Check for spawn delay on model (signon buffer issues)
		// Code left so light_candles can be switched on/off
		if (self.lighttarget != "" && !self.style) {
			self.targetname = self.lighttarget;
			// Use the entity state system for max compatibility
			self.estate = ESTATE_OFF;
			self.use = entity_state_use;
			self.estate_on = light_candle_setup;
		}
		else light_candle_setup();
	}
};

.string lighttarget;

// Protected default light styles
float LIGHT_IDSTYLE = 12;
float LIGHT_COMPILERSTYLE = 32;
float LIGHT_MAXLIGHTSTYLE = 64;
// Possible extended BSP2 standard ... who knows!
float LIGHT_BSP2LIGHTSTYLE = 256;
// The array is setup from world.qc before anything loads

.float compilerstyle_start;
float mapstyle_start;

//----------------------------------------------------------------------
// Allow the compile to change the starting point for target lights
//----------------------------------------------------------------------
void() light_style_boundary =
{
	// Check worldspawn key for starting point of target lights
	if (world.compilerstyle_start == 0) mapstyle_start = LIGHT_COMPILERSTYLE;
	else mapstyle_start = world.compilerstyle_start;
	// Make sure it does not overwrite default (0-11) ID styles
	if (mapstyle_start < LIGHT_IDSTYLE) mapstyle_start = LIGHT_IDSTYLE;
};
