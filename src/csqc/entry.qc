// CSQC entry points all conveniently in one file

float skip_intermission;
float intermission_exittime;



void(vector virtsize, float showscores) CSQC_DrawScores =
{	
	//print(ftos(cur_buttons ), "\n");

	if (intermission || showscores || getstatf(STAT_HEALTH) <= 0)
	{	
		if (intermission)
		{
			if (!intermission_exittime)
			{
				if (deathmatch)
					intermission_exittime = time + 5;
				else
					intermission_exittime = time + 2;
			}
			
			if ((intermission_exittime < time) && (cur_buttons  & 1))
				skip_intermission = TRUE;
		}

		if (deathmatch)
			return Hud_DeathmatchScoreboard('0 0 0', virtsize);
		else if (intermission && !skip_intermission)
			Hud_Intermission('0 0 0', virtsize);
	}
	//print(ftos(intermission_time), "\n");
};

float(float save, float take, vector dir) CSQC_Parse_Damage =
{
	if (numclientseats <= 1)
		painfinishtime = time + 0.2;
	return FALSE;	//let the engine handle any red tints etc
};

void(vector virtsize, float showscores) CSQC_DrawHud =
{
	Hud_Draw(virtsize, showscores);
};

float draw_scoreboard;

void(float vwidth, float vheight, float notmenu) CSQC_UpdateView =
{
	clearscene();

	V_CalcRefDef();
	//Event_thunder ();	

	addentities(MASK_ENGINE);
	renderscene();
	
	local vector ssize;
	ssize_x = vwidth; ssize_y = vheight; ssize_z = 0;
	
	CSQC_DrawScores (ssize, draw_scoreboard);
	
	if (intermission)
		return;

	CSQC_DrawHud (ssize, draw_scoreboard);
	
};

float(string str) CSQC_ConsoleCommand =
{
	tokenize( str );
	switch ( argv(0) ) 
	{
		case "+showscores":
		{
			draw_scoreboard = TRUE;
			return TRUE;
			break;
		}
		case "-showscores":
		{
			draw_scoreboard = FALSE;
			return TRUE;
			break;
		}	
		case "noclip":
		{	
			if (noclip == FALSE)
				noclip = TRUE;
			else
				noclip = FALSE;
			return FALSE;
			break;
		}			
		default:
		{
			return FALSE;
			break;
		}
	}
    return TRUE;
};

void(float apilevel, string enginename, float engineversion) CSQC_Init =
{	
	particleeffectnum ("d3fx.cfg");
	precache_model ( "gfx/recticals/nailgun_scope_target.spr32");
	particleeffectnum ("TE_EXHAUST");
	particleeffectnum ("TE_GUIDE");
	particleeffectnum ("TE_RAIL_LEFTOVER");
	particleeffectnum ("TE_RAIL_SPIRAL");
	particleeffectnum ("TE_RAIL_LEFTOVER_2");
	particleeffectnum ("TE_RAIL_SPIRAL_2");
	precache_model ("progs/s_explod.spr");

	Hud_Init();
	V_Init();
	
	tlit_screen = 0;
	skip_intermission = 0;
	intermission_exittime = 0;
	noclip = FALSE;
	flash_activate = FALSE;
	flash_active = FALSE;
};

void() CSQC_Input_Frame =
{
	getinputstate(clientcommandframe - 1);
	old_movevalues = input_movevalues;
	old_buttons = input_buttons;
	
	getinputstate(clientcommandframe);
	
	cur_movevalues = input_movevalues;
	cur_buttons = input_buttons;
}
