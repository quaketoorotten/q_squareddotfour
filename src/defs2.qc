.float dcnt;
.void() th_dodge;
.void() th_spawn;
// .void() th_duckhold;
.float dspeed;
.float nextthink2;
.float brainspeed;

.string deathtarget;
.string combattarget;

.float dodge_finished;
.void() th_char;
.float() th_checkatck;
.void() itemname;
//.float color;
.float pissed;

.float savedammo_shells;
.float savedammo_bullets;
.float savedammo_nails;
.float savedammo_grenades;
.float savedammo_rockets;
.float savedammo_cells;
.float savedammo_slugs;
.float savedammo_dmc;

.float ammo_dmc;
.float ammo_coils;
.float ammo_slugs;
.float ammo_bullets;
.float ammo_grenades;

.float megahealth_finished;
.float megahealth_time;
.float artifact_healtime;
.float armor_rottime;
.float armor_rotfinished;
//.float armor_rotstart;

.float mass;
.float hitmarker_time;

float SHOTGUN_PELLETS = 10;
float SHOTGUN_HSPREAD = 800;
float SHOTGUN_VSPREAD = 400;

float CHAINGUN_HSPREAD = 0.025; // projectiles
float CHAINGUN_VSPREAD = 0.025;

float MACHINEGUN_HSPREAD = 250;
float MACHINEGUN_VSPREAD = 200;

float GRENADE_MINSPEED = 200;
float GRENADE_MAXSPEED = 900;
float GRENADE_TIMER = 4.0;
.float grenade_time;

float PSTL_AMMO_CAP = 16;
float SG_AMMO_CAP = 10;
float SG_AMMO_LOAD = 2;
float MG_AMMO_CAP = 80;
float NG_AMMO_LOAD = 50;
float NG_AMMO_CAP = 100;
float RL_AMMO_CAP = 3;
float RL_AMMO_LOAD = 1;
float HB_AMMO_CAP = 60;
float NO_AMMO = 0;
float RG_AMMO_CAP = 3;
float GL_AMMO_CAP = 8;

float MAX_SHELLS = 40;
float MAX_NAILS = 200;
float MAX_ROCKETS = 37;
float MAX_CELLS = 320;
float MAX_BULLETS = 220;
float MAX_GRENADES = 42;
float MAX_COILS = 400;
float MAX_SLUGS = 47;
float MAX_CORES = 14;

.float trail_time;

.float aiflags;
.vector last_sighting;
.vector saved_goal;
.float shake_interval;
.float shake_time;

float AI_LOST_SIGHT			= 1; 
float AI_PURSUE_NEXT		= 2;
float AI_PURSUE_TEMP		= 4;	
float AI_PURSUIT_LAST_SEEN	= 8;
float AI_COMBAT_POINT		= 16;
float AI_STAND_GROUND		= 32;
float AI_THIRD_EYE			= 64;
float IS_PROJECTILE			= 128; // used for projectile hitboxes
float AI_SCRIPTED_ACTION	= 256;
float AI_FLEE				= 512;
float AI_AIMFLY				= 1024;
float AI_CHARGE				= 2048;

float CHAN_FIVE = 5;
float CHAN_SIX = 6;
float CHAN_RELOAD = 7;

float IT_WEP_ONE 				= 1;
float IT_WEP_TWO				= 2;
float IT_WEP_THREE 				= 4;
float IT_WEP_FOUR 				= 8;
float IT_WEP_FIVE 				= 16;
float IT_WEP_SIX	 			= 32;
float IT_WEP_SEVEN 				= 64;
float IT_WEP_EIGHT 				= 128;
float IT_WEP_NINE				= 256;
float IT_WEP_TEN				= 512;

float IT_WEP_ELEVEN				= 1024;
float IT_WEP_TWELVE				= 2048;
float IT_WEP_THIRTEEN			= 4096;

float IT_SHELLS_				= 6;
float IT_NAILS_					= 7;
float IT_ROCKETS_				= 8;
float IT_CELLS_					= 9;
float IT_EMPTY					= -1;
float IT_GRENADES				= 49;
float IT_BULLETS				= 48;
float IT_COILS					= 50;
float IT_SLUGS					= 51;
float IT_DMC					= 52;

float FL_MEDIC				= 8192;
float FL_DODGED				= 16384;
float FL_RESURRECTED		= 32768;
float FL_LEAP				= 65536;
float FL_TACTICAL			= 131072;

float MAX_WEAPONS				= 10;

float TE_MP_MFLASH				= 86;
float PICKUP					= 88;
float HITMARKER					= 89;
float THUNDER_ENDPOS			= 90;
float THUNDER_STARTPOS			= 91;
float TE_RAILTRAIL 				= 92;
float THUNDER_2					= 93;
float TE_RAILTRAIL2				= 94;

.entity goonmaster;
.float goons;
.float maxgoons;
.float strafe_time;

const float M_PI = 3.14159265358979323846;	/* Mathematica Pi constant. */ // yo why tf ts so short lemme make it longer

/*void(float start_fire, float idle_start, float idle_end, float change_end, 
	optional float change_start, optional float reload_start, optional float reload_loop_start, reload_insert
	 optional float reload_end_start, optional float reload_end_end, optional float ammo_load, optional float max_ammo_load, optional float ammo_type) */

typedef struct { 
	float last_activation;
	vector idle_frames;
	vector swap_frames;
	vector idle_empty_frames;
} weapon_info_frames;

typedef struct { 
	vector reload_frames;
	vector reloadloop_frames;
	vector reloadidk_frames;
} weapon_info_frames2;

typedef struct { 
	float mag_size;
	float capacity;
} weapon_info_mag;

typedef struct { 
	string vmodel;
	string pmodel;
	float() condition;
	string name;
	vector offs;
} weapon_info_generic;

typedef struct { 
	void() assign_currentammo;
	float() get_ammo;
	void(float ammo_type) save_ammo;
} weapon_info_ammo;

typedef struct {
	void() weaponfire;
	void() weaponsound;
} weapon_info_func;

.float weaponstate;

int WEAPON_IDLE = 0;
int WEAPON_USED = 1;
int WEAPON_ACTIVATE = 2;
int WEAPON_DEACTIVATE = 3;
int WEAPON_RELOAD = 5;
int WEAPON_DOWN = 6;
int WEAPON_FLASHUSE = 7;

.float weapontype;

.float oldweaponid;
.float newweaponid;
.float weaponid;

.float powerups; // replace .items
.float fov;
.float oldfov;

.vector weaponmodelpos;
.float ammotype;
.string weaponname;

.float spawnmuzzleflash;		
.entity locked_enemy;
.float locked_on;
.entity prelock_save;

typedef struct { // what am i even doing
    float allsolid;
    float startsolid;
    float fraction;
    
    vector endpos;
    vector plane_normal;
    float plane_dist;
    entity _ent;

    float inopen;
    float inwater;
    
} trace_t;

.float monster_frame;
.float flybob_strength;
.float flybob_horz;
.float flybob_vert;

float DMGTYPE_NORM = 0;
float DMGTYPE_EXP = 1;
float DMGTYPE_LTNG = 2;
float DMGTYPE_RAIL = 3;
float DMGTYPE_DMG = 4;
float DMGTYPE_TOX = 5;

.int playerflags;
int max_players;
.int max_player_interaction;
