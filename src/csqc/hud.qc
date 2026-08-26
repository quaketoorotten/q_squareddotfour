//	This file implements NQ, QW, and N64-style huds in csqc. Its meant to be complete, while not otherwise being that different.
//	The hud layout+items used are specific to vanilla Quake. For the mission packs, you should use the appropriate alternative huds.
//	
//	The entry points are at the bottom of the file.
//	You can just add this file (and fteextensions.qc or qsextensions.qc) into any mod and then just adapt it as desired.
//
//	Note that it doesn't understand viewsizes all that well, but no worse than eg scr_sbaralpha<1 in QS (its default). (this keeps the api spec simpler.)
//	the 'simple csqc' api means that this file (and api defs) is all you need for a hud, and can be directly embedded into a regular nq progs.dat, if needed.
//
//	I have made attempts to avoid copying the engine code, however I will not be held liable if there's any GPL contagion.
//	There is otherwise no license for the code in this file.


/*autocvars:
	cl_sbar: alternative layouts (sorry for this complication, but mneh).
		0: QuakeWorld style hud
		1: Vanilla style hud
		2: n64-style hud
		3: n64-style with meshes instead of models, where supported.
	cl_hudswap: QW/n64 ammo+weapons are on the
		0: right
		1: left
	scr_sbaralpha: opacity of backgroundy elements
*/

float sweaponid;

float ammo_type;
string sweaponname;

float STAT_MARKERTIME = 34;
float STAT_AMMOTYPE = 40;

float STAT_GRENADES				= 49;
float STAT_BULLETS				= 48;
float STAT_COILS				= 50;
float STAT_SLUGS				= 51;
float STAT_DMC					= 52;

float STAT_SAVED_BULLETS			= 57;
float STAT_SAVED_SHELLS				= 58;
float STAT_SAVED_CELLS				= 59;
float STAT_SAVED_GRENADES			= 60;
float STAT_SAVED_NAILS				= 61;
float STAT_SAVED_ROCKETS			= 62;
float STAT_SAVED_SLUGS				= 63;
float STAT_SAVED_DMC				= 64;

// items. FIXME: you should share these with your ssqc...

float IT_WEP_ONE 				= 1<<0;
float IT_WEP_TWO				= 1<<1;
float IT_WEP_THREE 			= 1<<2;
float IT_WEP_FOUR 			= 1<<3;
float IT_WEP_FIVE 			= 1<<4;
float IT_WEP_SIX	 			= 1<<5;
float IT_WEP_SEVEN 			= 1<<6;
float IT_WEP_EIGHT 			= 1<<7;
float IT_WEP_NINE				= 1<<8;
float IT_WEP_TEN				= 1<<9;

float	IT_ARMOR1				= 1<<13;
float	IT_ARMOR2				= 1<<14;
float	IT_ARMOR3				= 1<<15;
//float	IT_SUPERHEALTH			= 1<<16;

float	IT_KEY1					= 1<<17;
float	IT_KEY2					= 1<<18;
float	IT_INVISIBILITY			= 1<<19;
float	IT_REGENERATION		= 1<<20;
float	IT_SUIT					= 1<<21;
float	IT_QUAD					= 1<<22;

float IT2_RUNE1					= 1<<5;
float IT2_RUNE2					= 1<<6;
float IT2_RUNE3					= 1<<7;
float IT2_RUNE4					= 1<<8;


//wad image names in array form, for easier access.
static string number[10] = {
	"gfx/num_0",
	"gfx/num_1",
	"gfx/num_2",
	"gfx/num_3",
	"gfx/num_4",
	"gfx/num_5",
	"gfx/num_6",
	"gfx/num_7",
	"gfx/num_8",
	"gfx/num_9"
};

static string ammotypes[4] = {
	"gfx/stat4_0",
	"gfx/stat4_1",
	"gfx/stat4_2",
	"gfx/stat4_3"
};

static string anumber[10] = {
	"gfx/nums/font_0.tga",
	"gfx/nums/font_1.tga",
	"gfx/nums/font_2.tga",
	"gfx/nums/font_3.tga",
	"gfx/nums/font_4.tga",
	"gfx/nums/font_5.tga",
	"gfx/nums/font_6.tga",
	"gfx/nums/font_7.tga",
	"gfx/nums/font_8.tga",
	"gfx/nums/font_9.tga"
};
static string weaponicons[10] = {
	"gfx/hud/icons/item_blaster.tga",
	"gfx/hud/icons/item_machinegun.tga",
	"gfx/hud/icons/item_shotgun.tga",
	"gfx/hud/icons/item_hyperblaster.tga",
	"gfx/hud/icons/item_grenade.tga",
	"gfx/hud/icons/item_nailgun.tga",
	"gfx/hud/icons/item_rocket.tga",
	"gfx/hud/icons/item_railgun.tga",
	"gfx/hud/icons/item_lightning.tga",
	"gfx/hud/icons/item_darkmatter.tga"
};
static string weaponguns[10] = {
	"gfx/hud/icons/gun_blaster.tga",
	"gfx/hud/icons/gun_machinegun.tga",
	"gfx/hud/icons/gun_shotgun.tga",
	"gfx/hud/icons/gun_hyperblaster.tga",
	"gfx/hud/icons/gun_grenadelauncher.tga",
	"gfx/hud/icons/gun_nailgun.tga",
	"gfx/hud/icons/gun_rocketlauncher.tga",
	"gfx/hud/icons/gun_railgun.tga",
	"gfx/hud/icons/gun_lightninggun.tga",
	"gfx/hud/icons/gun_darkmatter.tga"
};

static string cross_list [10] =
{
	"gfx/crosshairs/crosshair_blaster.tga",
	"gfx/crosshairs/crosshair_machinegun.tga",
	"gfx/crosshairs/crosshair_shotgun.tga",
	"gfx/crosshairs/crosshair_blaster.tga",
	"gfx/crosshairs/crosshair_grenadelauncher.tga",
	"gfx/crosshairs/crosshair_nailgun.tga",
	"gfx/crosshairs/crosshair_rocketlauncher.tga",
	"gfx/crosshairs/crosshair_railgun.tga",
	"gfx/crosshairs/crosshair_lightninggun.tga",
	"gfx/crosshairs/crosshair_grenadelauncher.tga",
};

static string power_list [4] =
{
	"gfx/hud/icons/item_invis.tga",
	"gfx/hud/icons/item_regen.tga",
	"gfx/hud/icons/item_invis.tga",
	"gfx/hud/icons/item_quaddamage.tga"
};

static vector weaponcolors[10] = {
	[0,0.85,1],
	[1,1,0],
	[1,0.55,0],
	[0,0.45,1],
	[0.2,0.56,0.07],
	[0.6,0.8,0.8],
	[1,0.25,0],
	[0,1,0],
	[1,1,0.6],
	[0.77,0.2,1]
};

//copies of stats, for easier access
static float sitems;		//copy of .items
static float sitems2;		//copy of .items2 (or serverflags)
static float sweapon;		//copy of .weapon
static float shealth;		//copy of .health

float painfinishtime;//tracks when we took damage, for flinching.

static float marine_font;
//static float load_font;

//registers the various pics so they're ready as needed.
void() Hud_Init
{
	float i;
	precache_pic("gfx/crosshair", TRUE);
	precache_pic("gfx/crosshair1", TRUE);
	precache_pic("gfx/infotab_glass", TRUE);
	precache_pic("gfx/infotab_border", TRUE);
	precache_pic("gfx/sbar", TRUE);
	precache_pic("gfx/stat1", TRUE);
	precache_pic("gfx/stat2_a", TRUE);
	precache_pic("gfx/stat2_h", TRUE);
	precache_pic("gfx/stat2_h1", TRUE);
	precache_pic("gfx/stat3", TRUE);
	precache_pic("gfx/stat4", TRUE);
	precache_pic("gfx/stat4_0", TRUE);
	precache_pic("gfx/stat4_1", TRUE);
	precache_pic("gfx/stat4_2", TRUE);
	precache_pic("gfx/stat4_3", TRUE);
	precache_pic("gfx/ibar", TRUE);
	for (i = 0; i < 10; i++)
	{
		precache_pic(number[i], TRUE);
		precache_pic(anumber[i], 0);
		precache_pic(weaponicons[i], 0);
		precache_pic(weaponguns[i], 0);
		precache_pic(cross_list[i], 0);
	}
	
	for (i = 0; i < 4; i++)
		precache_pic(cross_list[i], 0);

	precache_pic("gfx/sb_armor1", TRUE);
	precache_pic("gfx/sb_armor2", TRUE);
	precache_pic("gfx/sb_armor3", TRUE);
	precache_pic("gfx/disc", TRUE);

	precache_pic("gfx/sb_shells", TRUE);
	precache_pic("gfx/sb_nails", TRUE);
	precache_pic("gfx/sb_rocket", TRUE);
	precache_pic("gfx/sb_cells", TRUE);

	precache_pic("gfx/sb_key1", TRUE);
	precache_pic("gfx/sb_key2", TRUE);
	precache_pic("gfx/sb_invis", TRUE);
	precache_pic("gfx/sb_invuln", TRUE);
	precache_pic("gfx/sb_suit", TRUE);
	precache_pic("gfx/sb_quad", TRUE);
	
	precache_pic("gfx/sb_sigil1", TRUE);
	precache_pic("gfx/sb_sigil2", TRUE);
	precache_pic("gfx/sb_sigil3", TRUE);
	precache_pic("gfx/sb_sigil4", TRUE);

	precache_pic("gfx/recticals/nailgun_scope.tga", 0);
	precache_pic("gfx/recticals/nailgun_scope_locked.tga", 0);
	precache_pic("gfx/recticals/railgun_scope.tga", 0);

	precache_pic("gfx/recticals/railgun_scope2.tga", 0);
	precache_pic("gfx/recticals/railgun_scope3.tga", 0);
	precache_pic("gfx/recticals/railgun_scope4.tga", 0);

	precache_pic("gfx/recticals/mgun_scope.tga", 0);

	precache_pic("gfx/hud/arbar.tga", 0);
	precache_pic("gfx/hud/backbar.tga", 0);
	precache_pic("gfx/hud/backbar_add.tga", 0);
	precache_pic("gfx/hud/valbar.tga", 0);
	precache_pic("gfx/hud/ekg.tga", 0);
	precache_pic("gfx/hud/icons/item_health.tga", 0);
	precache_pic("gfx/hud/icons/item_armor.tga", 0);

	precache_pic("gfx/hud/wsbar.tga", 0);
	precache_pic("gfx/hud/wsbarglow.tga", 0);

	//precache_pic("gfx/rectials/nailgun_scope", 0);
	//precache_pic("gfx/rectials/nailgun_scope_locked", 0);

	precache_pic("gfx/hud/powerup_bgbar", 0);

	marine_font = loadfont("", "gfx/bigchars", "16", -1, 0, 0);

	precache_pic ("gfx/hud/bg_darkgrad2.tga", 0);
	precache_pic ("gfx/hud/obj_btn3.tga", 0);

	precache_pic ("gfx/hud/obj_btn4.tga", 0);
	precache_pic ("gfx/hud/noammo.tga", 0);
};

static void(vector pos, float value, float threshhold) Hud_DrawLargeValue =
{
	float c;
	float len;
	string s;
	if (value < 0)
		value = 0;	//hrm
	if (value>999)
		value = 999;

	vector color;

	s = ftos(floor(value));
	len = strlen(s);

	pos_x += 14 * (3-len);
	
	if (value > threshhold)
		color = '1 1 1';
	else
		color = '1 0 0';
	
	vector dist = '14 0 0';
	float maxlen = len;
	float compress = 0;

	while(len>0)
	{	
		len--;
		c = str2chr(s, len);
		
		if (anumber[c-'0'] == "gfx/nums/font_1.tga") // number one
		{		
			if (len == 0 && maxlen == 3)
				pos_x += (3-len);
			if (len == 0 && maxlen == 2)
				pos_x += (3-len);
			if (len == 2 && maxlen == 3)
			{
				pos_x += (6-len);
				compress = 1;
			}
			if (len == 1 && maxlen == 3)
			{
				pos_x += (4-len);
				compress = 1;
			}
		}
		
		if (compress && len != 2)
		{		
			if (anumber[c-'0'] == "gfx/nums/font_1.tga")
			{	
				drawpic(pos+len * dist + [(-len), 0, 0]+'1 1 0', anumber[c-'0'], '20 20 0', '0 0 0' , 0.6, 0);
				drawpic(pos+len * dist + [(-len), 0, 0], anumber[c-'0'], '20 20 0', color , 1, 0);
			}
			else	
			{	
				drawpic(pos+len * dist + [(3-len), 0, 0]+'1 1 0', anumber[c-'0'], '20 20 0', '0 0 0' , 0.6, 0);
				drawpic(pos+len * dist + [(3-len), 0, 0], anumber[c-'0'], '20 20 0', color , 1, 0);
			}
		}		
		else
		{	
			drawpic(pos+len * dist+'1 1 0', anumber[c-'0'], '20 20 0', '0 0 0' , 0.6, 0);
			drawpic(pos+len * dist, anumber[c-'0'], '20 20 0', color , 1, 0);
		}
	}
	
};

static void(vector pos, float value, float threshhold) Hud_DrawLargeValue_small =
{
	float c;
	float len;
	string s;
	if (value < 0)
		value = 0;	//hrm
	if (value>999)
		value = 999;

	vector color;

	s = ftos(floor(value));
	len = strlen(s);

	pos_x += 9 * (3-len);
	
	if (value > threshhold)
		color = '1 1 1';
	else
		color = '1 0 0';

	float maxlen = len;
	
	vector dist = '9 0 0';
	float compress = 0;
	while(len>0)
	{
		len--;
		c = str2chr(s, len);

		if (anumber[c-'0'] == "gfx/nums/font_1.tga") // number one
		{		
			if (len == 0 && maxlen == 3)
				pos_x += (2-len);
			if (len == 0 && maxlen == 2)
				pos_x += (2-len);
			if (len == 2 && maxlen == 3)
			{
				pos_x += (4-len);
				compress = 1;
			}
			if (len == 1 && maxlen == 3)
			{
				pos_x += (2.5-len);
				compress = 1;
			}
		}
		
		if (compress && len != 2)
		{	
			drawpic(pos+len * dist + [(2-len), 0, 0]+'1 1 0', anumber[c-'0'], '13 13 0', '0 0 0' , 0.6, 0);
			drawpic(pos+len * dist + [(2-len), 0, 0], anumber[c-'0'], '13 13 0', color , 1, 0);
		}
		else
		{	
			drawpic(pos+len * '9 0 0'+'1 1 0', anumber[c-'0'], '13 13 0', '0 0 0' , 0.6, 0);
			drawpic(pos+len * '9 0 0', anumber[c-'0'], '13 13 0', color , 1, 0);
		}
	}
	
};

static string(float f, float chars, string lead) FormatFloat
{
	string s = ftos(f);
	if (f < 10 && chars >= 3)
		s = strcat(lead, lead, s);
	else if (f < 10 && chars == 2)
		s = strcat(lead, s);
	else if (f < 100 && chars >= 3)
		s = strcat(lead, s);
	return s;
};

void(vector pos, string str, vector color, float alp = 1) drawstring_q3 =
{
	drawstring(pos + '1 1 0', str, '8 8 0', '0 0 0', alp - 0.2, 0);
	drawstring(pos, str, '8 8 0', color, alp, 0);
};

static string skillnames [4] =
{
	"Easy",
	"Normal",
	"Hard",
	"Nightmare"
};


static void(vector pos) Hud_CoopScores_SBar =
{
	string s;
	float nsecs;
	float nmins;
	vector sbar = pos;
		
	drawpic(sbar, "gfx/hud/bg_darkgrad2.tga", '312 100 0', '0 0 0', 0.8, 0);
//	drawpic(sbar, "gfx/infotab_border", '150 105 0', '1 1 1',1, 0);
	
	drawpic(sbar + '48 83 0', "gfx/hud/obj_btn4.tga", '256 8 0', [0.690,0.803,0.419], 0.8, 0);
	drawpic(sbar + '48 10 0', "gfx/hud/obj_btn3.tga", '256 73 0', [0.690,0.803,0.419], 0.8, 0);
	
	drawfont = marine_font;
	s = strcat("Monsters:", FormatFloat(getstatf(STAT_KILLEDMONSTERS), 3, " "), "/", FormatFloat(getstatf(STAT_TOTALMONSTERS), 3, " "));
	drawstring_q3(sbar + '52 16', s, '1 1 1');
	s = strcat("Secrets :", FormatFloat(getstatf(STAT_FOUNDSECRETS), 3, " "), "/", FormatFloat(getstatf(STAT_TOTALSECRETS), 3, " "));
	drawstring_q3(sbar + '52 24', s, '1 1 1');

	nmins = floor(time/60);
	nsecs = floor(time - nmins*60);
	s = strcat("Time :", FormatFloat(nmins, 3, " "), ":", FormatFloat(nsecs, 2, "0"));
	drawstring_q3(sbar + '52 32', s, '1 1 1');
	
	drawstring_q3(sbar + '52 40',"Keys: ", '1 1 1');
	if (sitems & IT_KEY1)
		drawstring_q3(sbar + '52 40',"       Silver", '0.545 0.545 0.796');
	if (sitems & IT_KEY2)
	{	
		if (sitems & IT_KEY1)
			sbar_y += 8;
		drawstring_q3(sbar + '52 40',"       Gold", '1 0.95 0.1');
	}
	
	float skill = cvar("skill");
	s = strcat("Skill:", "  ");
	drawstring_q3(sbar + '52 48',s, '1 1 1'); 
	
	vector skill_color = '1 1 1';
	
	if (skill == 3)
		skill_color = '1 0 0';

	if (skill == 2)
		skill_color = '1 0.5 0';

	if (skill == 1)
		skill_color = '1 1 0';
	
	if (skill == 0)
		skill_color = '0.5 1 0';
	
	s = strcat("        ", skillnames[skill]);
	
	drawstring_q3(sbar + '52 48', s, skill_color);	

	drawfont = 0;
};

static void Hud_PicOrModel(vector topleft, string pic, string showmodel, float showskin, float speed)
{
	vector sz = '24 24';

	if (autocvar(cl_sbar, 1) >= 3)
	if (checkextension("DP_QC_RENDER_SCENE"))
	{
		//reset view props and wipe entity lists
		clearscene();

		//set up the various view details, set up the renderer to be a little larger than the intended size... it avoids harsh cuts.
		setviewprop(VF_MIN, topleft - sz);
		setviewprop(VF_SIZE, sz * 3);
		setviewprop(VF_DRAWENGINESBAR, FALSE);
		setviewprop(VF_DRAWCROSSHAIR, FALSE);
		setviewprop(VF_DRAWWORLD, FALSE);
		setviewprop(VF_AFOV, 30);	//a small fov reduces perspective distortions without making it look like its isometric.
		setviewprop(VF_ANGLES, '15 0 0');	//angle downwards slightly
		makevectors('15 0 0');
		setviewprop(VF_ORIGIN, v_forward*-256);	//and move the camera away so that we can position the model at the center without needing to worry about the tilt.

		//spawn a (reusable) entity for our scene
		static entity hudpicent;
		if (!hudpicent)
			hudpicent = spawn();
		precache_model(showmodel);
		setmodel(hudpicent, showmodel);
		hudpicent.angles_y = cltime*speed;
		hudpicent.skin = showskin;
		makevectors(hudpicent.angles);
		//make sure its centered
		vector org = (hudpicent.maxs+hudpicent.mins)*0.5;
		setorigin(hudpicent, - v_forward*org_x + v_right*org_y - v_up*org_z);
		//and now copy it into the scene
		addentity(hudpicent);

		//and ask the engine to actually draw that single-entity scene. Think of this as a drawpic call.
		renderscene();

		return;
	}

	//drawpic(topleft, pic, '24 24 0', '1 1 1', 1, 0);
};


//loat pulsetime;
vector healthoff = '140 0 0';
vector armoroff = '260 0 0';
float currenammo;

static float magsize [10] =
{
	-1,
	80,
	10,
	60,
	8,
	100,
	3,
	3,
	400,
	1,
};

static float magalert [10] =
{
	-1,
	20,
	3,
	15,
	2,
	25,
	1,
	1,
	100,
	0,
};

static string gunnames [10] =
{
	"Blaster",
	"Machinegun",
	"Shotgun",
	"Hyperblaster",
	"Grenade Launcher",
	"Nailgun",
	"Rocket Launcher",
	"Railgun",
	"Lightning Gun",
	"Disintergrator"
};

static float getweaponbit (float id) {
	id = id;

	return 1<<id;
};

float weaponicon_deltaalpha;
float weaponicon_deltaalpha2;

static void weapon_icon_icon (vector org, float icon, optional float noammo = 0)
{	
	//drawpic(org - [2, 2, 0], "gfx/hud/wsbar.tga", '20 20 0', '0 0 0', weaponicon_deltaalpha2, 0);	
	float newalpha = weaponicon_deltaalpha;
	if (noammo == 1)
	{	
		if (newalpha > 0)
			newalpha = newalpha - 0.4;

		drawpic(org, weaponicons[icon], [16, 16, 0], weaponcolors[icon],  newalpha);
	}
	else
		drawpic(org, weaponicons[icon], [16, 16, 0], weaponcolors[icon],  weaponicon_deltaalpha);

	if (sweapon == getweaponbit(icon))
		drawpic(org - [2, 2, 0], "gfx/hud/wsbarglow.tga", '20 20 0', '1 1 1', weaponicon_deltaalpha, 0);
	
	if (noammo == 1)
		drawpic(org - [2, 2, 0], "gfx/hud/noammo.tga", '20 20 0', '1 0 0', weaponicon_deltaalpha, 0);
};

typedef struct {
	float	invis_time;
	float regen_time;
	float suit_time;	
	float quad_time;
		
} timers;

static timers power_;

static float pow_times (float i)
{
	switch (i) 
	{
		case 1:
		{
			return power_.invis_time;
			break;
		}
		case 2:
		{
			return power_.regen_time;
			break;
		}	
		case 3:
		{
			return power_.suit_time;
			break;
		}
		case 4:
		{
			return power_.quad_time;
			break;
		}		
		default:
		{
			return FALSE;
			break;
		}
	}
}

static void power_icon_icon (vector org, float icon)
{	
	drawpic(org, "gfx/hud/powerup_bgbar.tga", '72 36 0', '0 0 0',1, 0);	
	drawpic(org + [18, 6, 0], power_list[icon - 19], [24, 24, 0], '1 1 1',  1, DRAWFLAG_ADD);

	Hud_DrawLargeValue (org + '24 8 0', pow_times(icon - 18) - time , 10);
};


float draw_weapons;
float draw_weapons_time;
float snewweaponid;
float draw_weaponsalpha_time;
vector cross_scale;
//vector cross_scale_delta;

static void Hud_DrawSBar_Powup (vector virtsize)
{	
	vector pos = [virtsize_x - 72, virtsize_y - 100];
	float power_count = 0;

	//if ((spowerups & getweaponbit(22) ))

	for(float i = 19; i < 23; i ++)
	{
		if (!(spowerups & getweaponbit(i) ))
			continue;
		
		power_count ++;
		power_icon_icon (pos - [0, power_count* 32 -32-(power_count - 1), 0], i);
	}	
};

static float getammostat[10] = 
{	
	-1,
	STAT_BULLETS,
	STAT_SHELLS,
	STAT_CELLS,
	STAT_GRENADES,
	STAT_NAILS,
	STAT_ROCKETS,
	STAT_SLUGS,
	STAT_COILS,
	STAT_DMC,
};

static float get_saved_ammostat[10] = 
{	
	-1,
	STAT_SAVED_BULLETS,
	STAT_SAVED_SHELLS,
	STAT_SAVED_CELLS,
	STAT_SAVED_GRENADES,
	STAT_SAVED_NAILS,
	STAT_SAVED_ROCKETS,
	STAT_SAVED_SLUGS,
	STAT_COILS,
	STAT_DMC,
};

static void Hud_DrawSBar(vector virtsize, float showscores)
{	
	float guns = 0;
	float gun_count = 0;
	vector pos, picsize, picsize_ekg;
	picsize_x = 104;
	picsize_y = 52;
	picsize_z = 0;

	picsize_ekg[0] = 94;
	picsize_ekg[1] = 47;
	picsize_ekg[2] = 0;

	Hud_DrawSBar_Powup (virtsize);

	if (draw_weapons_time < time && !showscores)		
	{
		draw_weapons = FALSE;
		draw_weapons_time = 0;
		draw_weaponsalpha_time = 0;
		weaponicon_deltaalpha = 0;
		weaponicon_deltaalpha2 = 0;
	}	
	
	if (snewweaponid != 0)
	{
		draw_weapons = TRUE;
		draw_weapons_time = time + 0.6;
		draw_weaponsalpha_time = time + 0.4;
		weaponicon_deltaalpha = 1;
		weaponicon_deltaalpha2 = 0.5;
	}	

	for(float i = 0; i < 10; i ++)
	{
		if (!(sitems & getweaponbit(i) ))
			continue;
		gun_count ++;
	}	
	
	vector weppos = [virtsize_x/2-32-(gun_count - 1)*12, virtsize_y-(picsize_y) - 38, 0];
	if (draw_weapons)
	{		
		if (draw_weaponsalpha_time < time && weaponicon_deltaalpha > 0)
			weaponicon_deltaalpha -= 0.04;

		if (draw_weaponsalpha_time < time && weaponicon_deltaalpha2 > 0)
			weaponicon_deltaalpha2 -= 0.04;

		for(float i = 0; i < 10; i ++)
		{
			if (!(sitems & getweaponbit(i) ))
				continue;
			
			float noammo = 0;
			float ammo_stat = getammostat[i];
			float savedammo_stat = get_saved_ammostat[i];

			float ammo_left = 0;
			float savedammo_left = 0;

			if (ammo_stat > 0)
			{
				ammo_left = getstatf(ammo_stat);
				savedammo_left = getstatf(savedammo_stat);
				
				if (ammo_left <= 0 && savedammo_left <= 0)
					noammo = 1;
			}

			guns ++;
			weapon_icon_icon (weppos + [(guns*24),0,0], i, noammo);
		}
		
		float id;
		if (snewweaponid != 0)
			id = snewweaponid - 1;
		else
			id = sweaponid - 1;
		
		drawfont = marine_font;
		vector wepname_pos = [virtsize_x/2 - strlen(gunnames[id])*4, virtsize_y-(picsize_y) - 14, 0];
		drawstring_q3(wepname_pos, gunnames[id], '1 1 1', weaponicon_deltaalpha);
		drawfont = 0;
	}

	//if (autocvar(cl_sbar, 1))
	
	pos = [14, virtsize_y-(picsize_y) - 4];
	drawpic(pos, "gfx/hud/backbar.tga", picsize, '0 0 0', 0.5, 0);
	
	vector pos2 = pos + '2 0 0';

	vector healthsize = [0, picsize_y, 0];
	vector armorsize = [0, picsize_y, 0];
	vector ammosize = [0, picsize_y, 0];

	float selfhealth = shealth;
	//float selfhealth2 = 0;
	float selfarmor = getstatf(STAT_ARMOR);
	
	vector health_icon_color = [0.658,0.639,0.376];

	if (shealth > 100)
	{
		selfhealth = 100;
	//	selfhealth2 = shealth - selfhealth;
		health_icon_color = [0,  0.50196,  1];
	}
	
	float hpp = selfhealth/100;

	drawpic(pos2 + healthoff, "gfx/hud/backbar.tga", picsize, '0 0 0', 0.5, 0);

	float helth = 0 + (picsize_x * hpp);
	float hploc = picsize_x - helth;
	healthsize_x = helth;
	
	vector color = [0.698,0.811,0.427];
	vector color_ekg = [0.0862,0.105,0.0549];
	
	if (hpp < 0.26)
	{
		color = [1,0.3,0];
		color_ekg = [0.3,0.05,0];
	}

	//drawpic(pos + healthoff, "gfx/hud/valbar.tga", picsize, color, 0.35, 0);

	hpp += 0.0429687;
	drawsubpic(pos2 + healthoff + [hploc, 0, 0], healthsize, "gfx/hud/valbar.tga", 
			[( 1.04296875 - hpp), 0, 0 ], [1 - ( 1.04296875 - hpp) ,1, 0 ], color, 0.35, 0);

	drawpic(pos2 + healthoff, "gfx/hud/valbar.tga", picsize, color, 0.2, 0);

	float pulse = 0.2 + fabs(sin(8 * time) * 0.4);

	if ((hpp - 0.0429687) < 0.26)	
		drawpic(pos2 + healthoff, "gfx/hud/backbar_add.tga", picsize, [1, 0, 0], pulse, DRAWFLAG_ADD);
	
	if (hpp < 0.26)
		drawpic(pos2 + healthoff + '4 0 0', "gfx/hud/ekg2_low", picsize_ekg, color_ekg, 1, DRAWFLAG_ADD);
	else
		drawpic(pos2 + healthoff + '4 0 0', "gfx/hud/ekg2", picsize_ekg, color_ekg, 1, DRAWFLAG_ADD);

	Hud_DrawLargeValue (pos2 + healthoff + '52 11 0', shealth, -1);
	
	if (power_.regen_time > time)
		health_icon_color = '1 0 0';

	drawpic(pos2 + healthoff + '84 32 0', "gfx/hud/icons/item_health.tga", [16, 16, 0], health_icon_color, 0.8);

	vector  color_armor;

	if (selfarmor > 0)
	{	
		if (selfarmor <= 0)
			color_armor = [1,0.3,0];
		else
			color_armor = [0.698,0.811,0.427];
			
		drawpic(pos2 + armoroff, "gfx/hud/backbar.tga", picsize, '0 0 0', 0.5, 0);
		
		float arp = (selfarmor/200);
		float armo = 0 + (picsize_x * arp);
		armorsize_x = armo;
		float arloc = picsize_x - armo;
		
		arp += 0.0429687;
		
		//drawpic(pos2 + armoroff, "gfx/hud/arbar.tga", armorsize, color_armor, 0.35, 0);

		drawsubpic(pos2 + armoroff + [arloc, 0, 0], armorsize, "gfx/hud/arbar.tga", 
			[( 1.04296875 - arp), 0, 0 ], [1 - ( 1.04296875 - arp) ,1, 0 ], color_armor , 0.35, 0);
		
		drawpic(pos2 + armoroff, "gfx/hud/arbar.tga", picsize, color_armor, 0.2, 0);
	
		//Hud_DrawNums( pos+[136, 24, 0], getstatf(STAT_ARMOR));
		Hud_DrawLargeValue (pos2 + armoroff + '52 11 0', getstatf(STAT_ARMOR), -1);
		
		vector armor_icon_color = [0.658,0.639,0.376];

		if (sitems & IT_ARMOR3)
			armor_icon_color = [0.980,0.168,0.0196];
		if (sitems & IT_ARMOR2)
			armor_icon_color = [1,1,0];
		
		drawpic(pos2 + armoroff + '84 32 0', "gfx/hud/icons/item_armor.tga", [16, 16, 0],armor_icon_color , 0.8);
	}

	//if (autocvar(cl_sbar, 1))
	//drawpic(pos, "gfx/stat3", '166 35 0', '1 1 1', autocvar(scr_sbaralpha, 0.75), 0);
	
	vector color_ammo = weaponcolors[sweaponid - 1];

	if (currenammo <= magalert[sweaponid - 1])
		color_ammo = [1,0.3,0];

	float currp;

	currp = currenammo/magsize[sweaponid - 1];
	
	
	if (sweaponid == 1)
		currp = 1;	

	float curr = 0 + (picsize_x * currp);
	float ammoloc = picsize_x - curr;
	ammosize_x = curr;
	
	currp += 0.04296875;
	drawsubpic(pos + [ammoloc, 0, 0], ammosize, "gfx/hud/valbar.tga", 
		[( 1.04296875 - currp), 0, 0 ], [1 - ( 1.04296875 - currp) ,1, 0 ], color_ammo, 0.35, 0);

	drawpic(pos, "gfx/hud/valbar.tga", picsize, color_ammo, 0.2, 0);

	vector offset_gun [10] =
	{
		'-24 1 0',
		'-24 1 0',
		'-5 1.5 0',
		'-10 1 0',
		'-10 1.5 0',
		'-20 0 0',
		'-12 1.6 0',
		'-12 1.6 0',
		'-15 1.5 0',
		'-12 1.6 0',
	};	

	if (sweaponid == 3)
		drawpic(pos + '0 11.5 0' + offset_gun[sweaponid - 1], weaponguns[sweaponid - 1], [94, 23, 0], color_ammo, 0.5);
	else
		drawpic(pos + '-1 11.5 0' + offset_gun[sweaponid - 1], weaponguns[sweaponid - 1], [104, 26, 0], color_ammo, 0.5);
	
	if (currenammo <= magalert[sweaponid - 1])
		drawpic(pos, "gfx/hud/backbar_add.tga", picsize, [1, 0, 0], pulse, DRAWFLAG_ADD);
	
	vector offset_ammo = '0 0 0';
	float ammo_val;

	if (ammo_type > 0)
	{	
		ammo_val = getstatf(ammo_type);

		if (ammo_val <= 99 && sweaponid != 9)
			offset_ammo = '9 0 0';

		if (sweaponid == 9)
		{	
			Hud_DrawLargeValue(pos + '52 11 0' + offset_ammo, ammo_val, -1);
		}
		else
		{
			Hud_DrawLargeValue_small (pos + '68 13 0', ammo_val, -1);
			Hud_DrawLargeValue( pos + '22 11 0' + offset_ammo, currenammo, -1);
		}
	}

	drawpic(pos + '84 32 0', weaponicons[sweaponid - 1], [16, 16, 0], weaponcolors[sweaponid - 1], 0.8);
	
	vector offset_cross = '0 0 0';
	vector cross_color = '1 1 1';
	vector cross_pos = [virtsize_x/2, virtsize_y/2, 0];
	
	if (cvar("crosshair"))
	{	
		if (grow_time < time)
		{
			grow_cross = FALSE;
			grow_time = 0;
			grow_wait_time = 0;
			cross_scale = '24 24 0';

			offset_cross[0] = cross_scale[0]/2;
			offset_cross[1] = cross_scale[1]/2;
		}		

		if (marker_time > time)	
			cross_color = '1 0 0';
		else
			marker_time = 0;
		
		if (grow_cross)
		{	
			//if (grow_wait_time < time
			

			if (grow_wait_time < time && cross_scale[0] > 24)
			{
				cross_scale[0] = Lerp(cross_scale[0] - 2, cross_scale[0] - 2, 1);
				cross_scale[1] = cross_scale[0];
		
				offset_cross[0] = cross_scale[0]/2;
				offset_cross[1] = cross_scale[1]/2;
			}
			else
			{
				cross_scale = '42 42 0';
				offset_cross[0] = cross_scale[0]/2;
				offset_cross[1] = cross_scale[1]/2;	
			}

		}

		drawpic(cross_pos - offset_cross, cross_list[sweaponid - 1], cross_scale, cross_color, 1, 0);
	}
};


float numclientseats;
float soldweapon;

void Hud_Draw(vector virtsize, float scoreboard)
{
	vector pos;
	float oitems = sitems;
	float oitems2 = sitems2;
	float ohealth = shealth;

	pos_x = (virtsize_x-320)/2;
	pos_y = virtsize_y;

	sitems = getstatbits(STAT_ITEMS, 0, 23);	//note that we could use getstati to read the items stat, but it'd degrade when then cast to a float, and QSS+DP don't support ints, so we have to use two floats. 
	sitems2 = getstatbits(STAT_ITEMS, 23, 9);
	
	if (!sweapon)
		soldweapon = getstatf(STAT_ACTIVEWEAPON);
	else
		soldweapon = sweapon;

	sweapon = getstatf(STAT_ACTIVEWEAPON);
	sweaponid = getstatf( STAT_WEAPONID);
	sweaponname = getstats(47);
	snewweaponid = getstatf(53);
	shealth = getstatf(STAT_HEALTH);
	//marker_time = getstatf(STAT_MARKERTIME);
	ammo_type = getstatf(STAT_AMMOTYPE);
	currenammo = getstatf(STAT_AMMO);
	//note that ssqc can provide custom stats, eg: clientstat(STAT_USER+n, EV_FLOAT, items3); can then be read by us with float items3 = getstatf(STAT_USER+n);
	
	power_.invis_time = getstatf(55);
	power_.suit_time = getstatf(54);
	power_.regen_time = getstatf(34);
	power_.quad_time = getstatf(38);

	if (shealth <= 0)
	{	
		tlit_screen = TRUE;
		return;
	}

	sfov = getstatf(STAT_SFOV);
	
	//print(sweaponname, "\n");
	if (sfov == FOV_ZOOM)
	{	
		if (sweaponname == "weapon_nailgun")
		{	
			vector targ_maxs = getentity(getstatf(45), GE_MAXS);
			if (targ_maxs_z > 16)
				drawpic('0 0 0', "gfx/recticals/nailgun_scope_locked.tga", virtsize , '1 1 1', 1, 0);
			else
				drawpic('0 0 0', "gfx/recticals/nailgun_scope.tga", virtsize , '1 1 1', 1, 0);
		}
		
		if (sweaponname == "weapon_railgun")
		{
			if (getstatf(STAT_AMMO) == 3)
				drawpic('0 0 0', "gfx/recticals/railgun_scope.tga", virtsize , '1 1 1', 1, 0);
			if (getstatf(STAT_AMMO) == 2)
				drawpic('0 0 0', "gfx/recticals/railgun_scope2.tga", virtsize , '1 1 1', 1, 0);
			if (getstatf(STAT_AMMO) == 1)
				drawpic('0 0 0', "gfx/recticals/railgun_scope3.tga", virtsize , '1 1 1', 1, 0);
			if (getstatf(STAT_AMMO) == 0)
				drawpic('0 0 0', "gfx/recticals/railgun_scope4.tga", virtsize , '1 1 1', 1, 0);
		}	

		if (sweaponname == "weapon_machinegun")
		{	
		
			drawpic('0 0 0', "gfx/recticals/mgun_scope.tga", virtsize , '1 1 1', 1, 0);
		}
	}

	//spowerups = getstatbits(37, 0, 23);
	if (spowerups & IT_QUAD)
		drawfill('0 0 0', virtsize, '0 0 1', 0.2);
	
	if (spowerups & IT_SUIT)
		drawfill('0 0 0', virtsize, '0 1 0', 0.2);

	if (autocvar(viewsize, 100) < 120)
	{
		if (scoreboard && !deathmatch)
		{	
			pos_x = -39;
			pos_y = pos_y / 2 - 50;
			Hud_CoopScores_SBar(pos);

		//	if (!draw_weapons)
		//	{
				// draw_weapons = TRUE;
				// draw_weapons_time = time + 0.3;
				// draw_weaponsalpha_time = time + 0.15;
				// weaponicon_deltaalpha = 1;
				// weaponicon_deltaalpha2 = 0.5;
		//	}
		}

		Hud_DrawSBar(virtsize, scoreboard);
		
		pos_x = virtsize_x - strlen(world.message)*8;
		pos_y = virtsize_y - 8;
		drawfont = marine_font;

		drawstring_q3 (pos, world.message, '1 1 1');
		
		drawfont = 0;
	}
};