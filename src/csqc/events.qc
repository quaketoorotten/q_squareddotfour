const float EVENT_MP_MFLASH	 	= 86; 
const float EVENT_TOGGLE_FLASH	 	= 87; 
const float EVENT_PICKUP	 	= 88; 
const float EVENT_HITMARKER	 	= 89; 
const float EVENT_THUNDER_ENDPOS 	= 90; 
const float EVENT_THUNDER_STARTPOS 	= 91; 
const float EVENT_RAILTRAIL		= 92; 
const float EVENT_THUNDER2		= 93; 
const float EVENT_RAILTRAIL2		= 94; 

float marker_time;
float grow_time;
float grow_wait_time;
float grow_cross;
float flash_activate;
float flash_active;

vector thunderbolt_endpoint1; // for players
const float 	M_PI = 3.14159265358979323846;
float sfov;

void(vector origin, vector end, string textname, float size, float flag = 1) Event_Draw_LightningBolt =
{	
	/*vector ang;
	
	if (!flag)
		ang = vectoangles(origin);
	else
		ang = vectoangles(end);
		
	makevectors(ang);*/

	makevectors(getviewprop(VF_CL_VIEWANGLES));
    
   	R_BeginPolygon(textname, DRAWFLAG_TWOSIDED);
	vector right = v_right, up = v_up;
//	vector forward = v_forward;

    // topright
    	R_PolygonVertex(origin + (up * size), [1, 0], [1, 1, 1], flag);

    // topleft
    	R_PolygonVertex(origin - (up * size), [0, 0], [1, 1, 1], flag);

    // botleft
    	R_PolygonVertex(end - (up * size), [0, 1], [1, 1, 1], flag);

    // botright
    	R_PolygonVertex(end + (up * size), [1, 1], [1, 1, 1], flag);

    	R_EndPolygon();
};

void(vector origin, vector end, string textname, float size, float flag = 1) Event_Draw_LightningBolt2 = 
{	
	makevectors(getviewprop(VF_CL_VIEWANGLES));
    
   	R_BeginPolygon(textname, DRAWFLAG_TWOSIDED);
	vector right = v_right, up = v_up;
//	vector forward = v_forward;

   // topright
    	R_PolygonVertex(origin + (right * size), [1, 0], [1, 1, 1], flag);

    // topleft
    	R_PolygonVertex(origin - (right * size), [0, 0], [1, 1, 1], flag);

    // botleft
    	R_PolygonVertex(end - (right * size), [0, 1], [1, 1, 1], flag);

    // botright
    	R_PolygonVertex(end + (right * size), [1, 1], [1, 1, 1], flag);

	R_EndPolygon();
};


.vector start;
.vector end;
.float die;

void() SUB_Remove = {remove(self);};


float() Event_thunder =
{	
	if (self.die < time)
	{	
		remove(self);
		return PREDRAW_AUTOADD;
	}
	Event_Draw_LightningBolt (self.start, self.end, "effects/weapons/lightning_bolt", 16);
	Event_Draw_LightningBolt2 (self.start, self.end, "effects/weapons/lightning_bolt", 16);

	//Event_Draw_LightningBolt (self.start + '0 0 8', self.end, "effects/weapons/lightning_bolt", 8);
	//Event_Draw_LightningBolt2 (self.start + '0 0 -8', self.end, "effects/weapons/lightning_bolt", 8);
	
	return PREDRAW_AUTOADD;
};

float() Event_thunder2 =
{	
	if (self.die < time)
	{	
		remove(self);
		return PREDRAW_AUTOADD;
	}
	Event_Draw_LightningBolt (self.start, self.end, "effects/weapons/darkmatterbolt", 4);
	Event_Draw_LightningBolt2 (self.start, self.end, "effects/weapons/darkmatterbolt", 4);

	//Event_Draw_LightningBolt (self.start + '0 0 8', self.end, "effects/weapons/lightning_bolt", 4);
	//Event_Draw_LightningBolt2 (self.start + '0 0 -8', self.end, "effects/weapons/lightning_bolt", 4);
	
	return PREDRAW_AUTOADD;
};


float() Event_railtrail =
{	
	if (self.scale <= 0)
	{	
		remove(self);
		return PREDRAW_AUTOADD;
	}
	
	if (self.scale == 8)
		trailparticles(particleeffectnum("TE_RAIL_SPIRAL"), self, self.start, self.end);

	self.scale -= 0.5;
	
	Event_Draw_LightningBolt (self.start, self.end, "effects/weapons/rail_trail", self.scale);
	Event_Draw_LightningBolt2 (self.start, self.end, "effects/weapons/rail_trail", self.scale);

	if (self.scale != 6)
		return PREDRAW_AUTOADD;
	
	float n = ceil(vlen(self.start - self.end) / 128);
	vector vec = normalize(self.end - self.start);
	vec = vectoangles(vec);

	makevectors(vec);
	vector f = v_forward;
	f[2] = -f[2];
	
	float num = 0;	
	
	for (float i = 0; i < n; i++)
	{	
		pointparticles(particleeffectnum("TE_RAIL_LEFTOVER"), self.start + f * num);
		num += 128;
	}

	return PREDRAW_AUTOADD;
};

float() Event_railtrail_2 =
{	
	if (self.scale <= 0)
	{	
		remove(self);
		return PREDRAW_AUTOADD;
	}
	
	if (self.scale == 8)
		trailparticles(particleeffectnum("TE_RAIL_SPIRAL_2"), self, self.start, self.end);

	self.scale -= 0.5;
	
	Event_Draw_LightningBolt (self.start, self.end, "effects/weapons/rail_trail_2", self.scale);
	Event_Draw_LightningBolt2 (self.start, self.end, "effects/weapons/rail_trail_2", self.scale);

	if (self.scale != 6)
		return PREDRAW_AUTOADD;
	
	float n = ceil(vlen(self.start - self.end) / 128);
	vector vec = normalize(self.end - self.start);
	vec = vectoangles(vec);

	makevectors(vec);
	vector f = v_forward;
	f[2] = -f[2];
	
	float num = 0;	
	
	for (float i = 0; i < n; i++)
	{	
		pointparticles(particleeffectnum("TE_RAIL_LEFTOVER_2"), self.start + f * num);
		num += 128;
	}

	return PREDRAW_AUTOADD;
};

void(vector p1, vector p2, float() draw, float death, float size) spawn_thunderbolt_tempent =
{	
	//print ("???");
	local entity e;
	e = spawn ();
	e.start = p1;
	e.end = p2;
	e.predraw = draw;
	e.drawmask = MASK_ENGINE;
	e.scale = size;
	e.die = time + death;
};

float () mflash_partdraw = 
{
	if (self.die < time)
	{	
		remove(self);
		return PREDRAW_AUTOADD;
	}

	//pointparticles (particleeffectnum("TE_MUZZLEFLASH2"), self.origin , '0 0 0');
	pointparticles (particleeffectnum("EF_MUZZLEFLASH2"), self.origin , '0 0 0');

	return PREDRAW_AUTOADD;
}
 
void(vector p1) spawn_mflash_part =
{
	local entity e;
	e = spawn ();
	e.origin = p1;
	e.predraw = mflash_partdraw;
	e.drawmask = MASK_ENGINE;
	e.die = time + 0.03;	
}

//function is called whenever the client receives a SVC_CGAMEPACKET
noref void() CSQC_Parse_Event =
{
	float first = readbyte(); 
	vector pos1;
	vector pos2;
	float ent;

	if(first == EVENT_THUNDER_ENDPOS)
	{
		pos1_x = readcoord();
		pos1_y = readcoord();
		pos1_z = readcoord();

		thunderbolt_endpoint1 = pos1;

		//print("pos1 ", vtos(pos1), "\n");
	}	
	if(first == EVENT_THUNDER_STARTPOS)
	{
		pos1_x = readcoord();
		pos1_y = readcoord();
		pos1_z = readcoord();

		//print("pos1 ", vtos(pos1), "\n");

		pos2_x = readcoord();
		pos2_y = readcoord();
		pos2_z = readcoord();
		
		//print("pos2 ", vtos(pos2), "\n");

		ent = readentitynum();

		if (ent != player_localentnum)
			spawn_thunderbolt_tempent (pos1, pos2, Event_thunder, 0.06, 1);
	}
	if(first == EVENT_RAILTRAIL)
	{
		pos1_x = readcoord();
		pos1_y = readcoord();
		pos1_z = readcoord();

		//print("pos1 ", vtos(pos1), "\n");

		pos2_x = readcoord();
		pos2_y = readcoord();
		pos2_z = readcoord();
		
		//print("pos2 ", vtos(pos2), "\n");

		spawn_thunderbolt_tempent (pos1, pos2, Event_railtrail, 0, 8);
	}
	if(first == EVENT_THUNDER2)
	{
		pos1_x = readcoord();
		pos1_y = readcoord();
		pos1_z = readcoord();

		//print("pos1 ", vtos(pos1), "\n");

		pos2_x = readcoord();
		pos2_y = readcoord();
		pos2_z = readcoord();
		
		//print("pos2 ", vtos(pos2), "\n");

		spawn_thunderbolt_tempent (pos1, pos2, Event_thunder2, 0.2, 1);
	}
	if(first == EVENT_RAILTRAIL2)
	{
		pos1_x = readcoord();
		pos1_y = readcoord();
		pos1_z = readcoord();

		//print("pos1 ", vtos(pos1), "\n");

		pos2_x = readcoord();
		pos2_y = readcoord();
		pos2_z = readcoord();
		
		//print("pos2 ", vtos(pos2), "\n");

		spawn_thunderbolt_tempent (pos1, pos2, Event_railtrail_2, 0, 8);
	}
	if(first == EVENT_HITMARKER)
	{	
		grow_time = time + 0.15;
		marker_time = time + 0.15;
		grow_wait_time = time + 0.05;
		grow_cross = TRUE;
	}
	if(first == EVENT_PICKUP)
	{
		grow_time = time + 0.15;
		grow_wait_time = time + 0.05;
		grow_cross = TRUE;
	}
	if(first == EVENT_TOGGLE_FLASH)
	{
		flash_activate = TRUE;
		flash_active = TRUE;
	}
	if(first == EVENT_MP_MFLASH)
	{
		pos1_x = readcoord();
		pos1_y = readcoord();
		pos1_z = readcoord();

		ent = readentitynum();

		if (ent != player_localentnum)
			spawn_mflash_part (pos1);
	}
}

// tutorial grabbed

