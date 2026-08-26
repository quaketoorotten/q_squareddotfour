//======================================================================
// Author : Simon "Sock" OCallaghan
// Website: www.simonoc.com
//======================================================================
//#pragma warning disable Fxxx	// How to suppress compiler warnings

.entity activate;
.float classtype;
.string target2;
.float classgroup;


// Global fog system
float		fog_active;			// Global fog values are active
entity		fog_control;		// Global fog controller (unique to map)
.float		fog_density;		// Global fog density when map loads
.vector		fog_colour;			// Global fog colour when map loads
.string		fog_dpextra;		// Extra parameters for DP engine
.float		fog_currden;		// Current fog density
.float		fog_targden;		// Target fog density
.float		fog_diffden;		// Difference between current and target
.vector		fog_currcol;		// Current fog colour (RGB)
.vector		fog_targcol;		// Target fog colour (RBG)
.vector		fog_diffcol;		// Difference between current and target
.float		fog_difftime;		// Amount of time to fade fog (seconds)
.float		fog_steptime;		// Amount of steps to fade (20 per second)

.entity		attachment;			// 1st Entity attachment (additional model)
.float		bsporigin;			// All bmodel origins are 0,0,0 check this first
.entity		bmodel_act;	


string SOUND_EMPTY = "misc/null.wav";			
string SOUND_TALK = "misc/talk.wav";			// Activate/message sound

float STATE_SETUP = -1;		// Setup state (on/off functions)
float STATE_ON	= 1;		// Stupid idea to have on states as 0
float STATE_OFF	= 2;		// Impossible to test for 0 as 'not setup' is 0

float ENT_SPNSTATIC = 32;	// Will convert entity to static on spawn
float ENT_STARTOFF = 64;	// Global spawnflags setting
float ESTATE_BLOCK = 6;		// Blocked OFF+DISABLE
float ESTATE_LOWER = 7;		// ON+OFF+DISABLE
float ESTATE_ON = 1;		// Switch ON
float ESTATE_OFF = 2;		// Switch OFF
float ESTATE_DISABLE = 4;	// Disabled (blocks toggle)
float ESTATE_RESET = 8;		// Reset parameters
float ESTATE_AFRAME = 16;	// Changes Aframe only
float CT_TRIGFOG = 8330;
float CT_TRIGMULTI = 8010;	
float CT_TRIGONCE = 8000;	

// Entity state system
.float		estate_trigger;		// Entity state to be applied to target
.float		estate;				// Entity state (off,on and disable)
.void()		estate_on;			// Entity state ON  function
.void()		estate_off;			// Entity state OFF function
.void()		estate_disable;		// Entity state DISABLE function
.void()		estate_use;			// Entity state USE function
.void()		estate_fire;		// Entity state USE++ function
.void()		estate_reset;		// Entity state RESET function
.void()		estate_aframe;		// Entity state AFRAME function

.vector		bbmins;				// Saved bounding box size (minimum)
.vector		bbmaxs;				// Saved bounding box size (maximum)

float	ATTN_QUIET	= 3.99;
float CT_SOUNDEMITTER = 250;

float SOUND_PLAYONCE = 2;		// When triggered plays once
float SOUND_TRIGGER = 4;		// Wait for trigger and then stop
float CT_ESTATE = 340;			// Entity state modifier
float CG_TRIGGERS = 440;
float CT_MISCSHAKE = 6720;
float CG_MISCENT = 410;	

float FADEFOG_TIME = 0.05;
float DEF_FOGDEN = 0.1;	
vector DEF_FOGCOL = '0.1 0.1 0.1';	
float CT_TRIGSECRET = 8300;	

.string angletarget;

vector(entity bmodel_ent) bmodel_origin =
{
	local vector vdiff, vorigin;

	// Calculate the middle point of the mins/maxs size vectors
	// Changed /2 operation to *0.5 instead (ad1.7p2)
	vdiff_x = (bmodel_ent.maxs_x - bmodel_ent.mins_x) * 0.5;
	vdiff_y = (bmodel_ent.maxs_y - bmodel_ent.mins_y) * 0.5;
	vdiff_z = (bmodel_ent.maxs_z - bmodel_ent.mins_z) * 0.5;

	// The mins vector is an absolute value of where the Bmodel is located
	// Add mins vector to middle point to get true origin
	// When bmodel do move they also update their origin co-ordinates
	// So any additional movement needs to be added as well
	// This means that bmodels can be tracked by movement functions
	vorigin = bmodel_ent.origin + bmodel_ent.mins + vdiff;
	
	// Return origin
	return vorigin;
};

float(vector source, vector targ, float offset, float reverse, float dst_ang) viewangle =
{
	local float targ_dir, targ_ang;

	// Calculate vector angle between two points (source, target)
	if (reverse) targ_dir = vectoyaw(source - targ);
	else targ_dir = vectoyaw(targ - source);

	targ_ang = anglemod( (dst_ang - targ_dir) + offset );
	return targ_ang;
};

//----------------------------------------------------------------------
// Some entities have directional parameters (angles -> movedir)
// This function searches for an angletarget entity (useful for tracking)
// Always finds the first target key (will fail if multiple targets)
//----------------------------------------------------------------------
void(entity targ, float return_target) TargetMovedir =
{
	local entity angle_dest;
	local vector targ_origin, angle_dest_origin;
	
	// Exit if no angletarget defined
	if (targ.angletarget == "") return;
	
	// Find angle target entity
	angle_dest = find(world, targetname, targ.angletarget);
	if (angle_dest) {
		// Check for Bmodel origin for targ/angle_dest
		if (targ.bsporigin) targ_origin = bmodel_origin(targ);
		else targ_origin = targ.origin;
		if (angle_dest.bsporigin) angle_dest_origin = bmodel_origin(angle_dest);
		else angle_dest_origin = angle_dest.origin;
		
		// Calculate facing angle towards target
		self.movedir = normalize(angle_dest_origin - targ_origin);
		
		// Return variables for calling function (def=FALSE)
		if (return_target) {
			self.movetarget = angle_dest;	// Target entity
			self.dest1 = angle_dest_origin;	// Target origin
		}
	}
};


float BUFFER_STUFFCMD = 1;	// Long float print function (lftos)
float BUFFER_SPRINT = 2;	// Defined in subs.soc.qc
float BUFFER_DPRINT = 4;


//----------------------------------------------------------------------
// (Long Float TO String) Format and print a number to the console
// - str_player : needs to be a client for various buffer commands
// - buffer : BUFFER_STUFFCMD, BUFFER_SPRINT, BUFFER_DPRINT

//----------------------------------------------------------------------
// Returns power of 10
//----------------------------------------------------------------------
float(float pow_loop, float pow_bit) mathlib_powbit =
{
	local float pow_num, pow_counter;
	// Allow for starting range to be different
	pow_num = pow_bit;
	pow_counter = 1;
	if (pow_loop < 1) pow_loop = 1;
			
	while (pow_counter < pow_loop) {
		pow_num = pow_num * pow_bit;
		pow_counter = pow_counter + 1;
	}
	return pow_num;
}; 

void(entity str_player, float str_num, float topbit, float botbit, float buffer) lftos =
{
	local float str_counter, str_pow, str_result, str_remain, str_first;
	
	str_counter = topbit;		// Upper number length
	str_pow = mathlib_powbit(topbit,10);// Setup initial base 10 power for checking
	str_remain = FALSE;			// Decimal point been done yet
	str_first = FALSE;			// First non-zero digit printed

	// Deal with negative state first
	if (str_num < 0) {
		if (buffer & BUFFER_STUFFCMD) stuffcmd(str_player, "-");
		else if (buffer & BUFFER_SPRINT) sprint(str_player, "-");
		else if (buffer & BUFFER_DPRINT) dprint("-");
	}
	// Get rid of negative state
	str_num = fabs(str_num);
	
	// If number larger than fixed length?
	if (str_num > str_pow)
		str_num = str_num - (floor(str_num / str_pow) * str_pow);
		// New system, not used for this function
		// str_num = mathlib_truncate(str_num, topbit, botbit);

	// Loop through upper part of number
	while(str_counter > 0) {
		// Move down one pow digit
		str_pow = str_pow / 10;

		// Divide number by pow to get divider
		// Floor can produce rounding errors (fix it with 0.01)
		str_result = floor((str_num / str_pow)+0.01);
		// New system, not used for this function
		// str_result = mathlib_divisible(str_num, str_pow);
		
		// Result must be 0-9 digits
		if (str_result > 9) str_result = 9;
		if (str_result < 1) str_result = 0;
		
		// Fill front of number with spaces
		if (str_counter > 1 && str_result == 0 && str_first == FALSE) {
			// Print space to buffer type
			if (buffer & BUFFER_STUFFCMD) stuffcmd(str_player, " ");
			else if (buffer & BUFFER_SPRINT) sprint(str_player, " ");
			else if (buffer & BUFFER_DPRINT) dprint(" ");
		}
		// Display a number
		else if (str_result > 0 || str_first) {
			str_first = TRUE;
			// Print digit to buffer type
			if (buffer & BUFFER_STUFFCMD) stuffcmd(str_player, ftos(str_result));
			else if (buffer & BUFFER_SPRINT) sprint(str_player, ftos(str_result));
			else if (buffer & BUFFER_DPRINT) dprint(ftos(str_result));
		}
		
		// remove top part of number, decrease str length counter
		str_num = str_num - (str_result * str_pow);
		str_counter = str_counter - 1;
	}
	
	// Any decimal place?
	if (botbit <= 0) {
		// Check for zero value
		if (!str_first) {
			if (buffer & BUFFER_STUFFCMD) stuffcmd(str_player, "0");
			else if (buffer & BUFFER_SPRINT) sprint(str_player, "0");
			else if (buffer & BUFFER_DPRINT) dprint("0");
		}
		return;
	}
	
	// Is there any remainder?
	if (str_counter < 1) {
		// Print decimal point to buffer type
		if (!str_first) {
			str_first = TRUE;
			if (buffer & BUFFER_STUFFCMD) stuffcmd(str_player, "0.");
			else if (buffer & BUFFER_SPRINT) sprint(str_player, "0.");
			else if (buffer & BUFFER_DPRINT) dprint("0.");
		}
		else {
			if (buffer & BUFFER_STUFFCMD) stuffcmd(str_player, ".");
			else if (buffer & BUFFER_SPRINT) sprint(str_player, ".");
			else if (buffer & BUFFER_DPRINT) dprint(".");
		}
		if (botbit <1) botbit=1;
		str_counter = botbit;
		while (botbit > 0) { 
			str_num = str_num * 10; 
			botbit = botbit -1;
		}
		str_pow = mathlib_powbit(str_counter,10);
	}

	// Loop through lower part of number
	while(str_counter > 0) {
		// Move down one pow digit
		str_pow = str_pow / 10;

		// Divide number by pow to get divider
		// Floor can produce rounding errors (fix it with 0.01)
		str_result = floor((str_num / str_pow)+0.01);
		// New system, not used for this function
		// str_result = mathlib_divisible(str_num, str_pow);

		// Result must be 0-9 digits
		if (str_result > 9) str_result = 9;
		if (str_result < 1) str_result = 0;

		if (str_result > 0 || str_first) {
			str_first = TRUE;
			// Print digit to buffer type
			if (buffer & BUFFER_STUFFCMD) stuffcmd(str_player, ftos(str_result));
			else if (buffer & BUFFER_SPRINT) sprint(str_player, ftos(str_result));
			else if (buffer & BUFFER_DPRINT) dprint(ftos(str_result));
		}
		
		// remove top part of number, decrease str length counter
		str_num = str_num - (str_result * str_pow);
		str_counter = str_counter - 1;
	}
};