/*QUAKED target_explosion (1 0 0) (-8 -8 -8) (8 8 8)
Spawns an explosion temporary entity when used.

"delay"		wait this long before going off
"dmg"		how much radius damage should be done, defaults to 0
*/

void() target_explsoion_explode = 
{
	BecomeExplosion ();
	T_RadiusDamage (self, self.enemy, self.dmg, self.dmg + 40, world);
};

void() use_target_explosion = 
{
	self.enemy = activator;
	self.use = __NULL__;

	if (!self.delay)
	{
		target_explsoion_explode();
		return;
	}

	self.think = target_explsoion_explode;	
	self.nextthink = time + self.delay;
};

void() target_explosion = 
{
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_NONE;	// so it doesn't get pushed by anything
	self.solid = SOLID_NOT;
	self.takedamage = DAMAGE_NO;
		
	setmodel (self, self.model);
	self.classname = "explosion";	

  	self.model = "";
	self.solid = SOLID_NOT;
	self.use = use_target_explosion;
};

//==========================================================


/*QUAKED target_speaker (1 0 0) (-8 -8 -8) (8 8 8)
"noise"		wav file to play
"attenuation"
-1 = none, send to whole level
1 = normal fighting sounds
2 = idle sound level
3 = ambient sound level
"volume"	0.0 to 1.0

Normal sounds play each time the target is used.
*/

.float attenuation;
.float volume;
.float channel;

void() use_target_speaker =
{		
	sound (self, self.channel, self.noise, self.volume, self.attenuation);
	self.use = use_target_speaker_off;
	self.state = 1;
};

void() use_target_speaker_off =
{		
	sound (self, self.channel, "misc/null.wav", 0, self.attenuation);
	self.use = use_target_speaker;
	self.state = 0;
};

void() target_speaker =
{
	if (!self.noise)	
	{
		objerror ("speaker without noise");
		return;
	}

	precache_sound(self.noise);

	if (!self.volume)
		self.volume = 1;
	if (!self.channel)
		self.channel = CHAN_VOICE;
		
	if (!self.attenuation)
		self.attenuation = 1;
	else if (self.attenuation < 0)
		self.attenuation = 0;

	self.use = use_target_speaker;
	self.classname = "speaker";

	setorigin(self, self.origin);
};

void() activate_all_active_speakers =
{	
	local entity t;
	t = find(world, classname, "speaker");
	
	while (t) // thx bmfbr
	{
		if (t.spawnflags & 4 == 4) // wat
		{
			if (t.state == 1) 
			{
				t.nextthink = time + 0.2;
				t.think = use_target_speaker;
			}
		}

		t = find(t, classname, "speaker");
	}
};

//==========================================================

/*QUAKED target_earthquake (1 0 0) (-8 -8 -8) (8 8 8)
When triggered, this initiates a level-wide earthquake.
All players and monsters are affected.
"speed"		severity of the quake (default:200)
"count"		duration of the quake (default:5)
*/

void() target_earthquake_think =
{
	local entity	e;

	if (self.attack_finished < time)
	{
		sound (self, CHAN_AUTO, "world/quake.wav", 1.0, ATTN_NONE, 0);
		self.attack_finished = time + 0.5;
	}

	e = find(world, classname, "player");
	
	while (e) // thx bmfbr
	{
		if ((e.flags & FL_ONGROUND) == FL_ONGROUND) // wat
		{
			e.flags &= ~FL_ONGROUND;
			e.velocity[0] += crandom()* 150;
			e.velocity[1] += crandom()* 150;
			e.velocity[2] = self.speed * (100.0 / e.mass);
		}

		if (!e.shake_time)
		{
			e.shake_time = time + 0.1;
			e.shake_interval = self.shake_interval;
		}
		
		e = find(e, classname, "player");
	}

	if (time < self.ltime)
		self.nextthink = time + 0.1;
};

void() target_earthquake_use =
{
	self.ltime = time + self.count;
	self.nextthink = time + 0.1;
	self.enemy = activator;
	self.dspeed = 0;
};

void() target_earthquake =
{
	if (!self.targetname)
		objerror("untargetted earthquake");

	if (!self.count)
		self.count = 5;

	if (!self.speed)
		self.speed = 20;

	if (!self.shake_interval)
		self.shake_interval = 0.04;

	self.think = target_earthquake_think;
	self.use = target_earthquake_use;

	precache_sound ("world/quake.wav");
};

//==========================================================

/*QUAKED target_laser (0 .5 .8) (-8 -8 -8) (8 8 8) START_ON 
When triggered, fires a laser.  You can either set a target
or a direction.
*/

void() target_laser_think =
{
	local entity ignore;
	local vector start;
	local vector end;
	local vector point;

	if (self.enemy)
	{
		point = self.enemy.absmin + (self.enemy.maxs - self.enemy.mins)*0.5;
		self.movedir = point - self.origin;
		self.movedir = normalize(self.movedir);
	}

	ignore = self;
	start = self.origin;
	end = start + self.movedir*2048;
	while(1)
	{
		traceline (start, end, FALSE, ignore);

		if (!trace_ent)
			break;

		// hurt it if we can
		if ((trace_ent.takedamage))
			T_Damage (trace_ent, self, trace_endpos, self.oldenemy, self.dmg, 1);

		// if we hit something that's not a monster or player or is immune to lasers, we're done
		if (!(trace_ent.flags & FL_MONSTER) && (trace_ent.classname != "player"))
			break;

		ignore = trace_ent;
		start = trace_endpos;
	}

	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, THUNDER_2);

//	WriteEntity(MSG_BROADCAST, self);
	WriteCoord(MSG_BROADCAST, self.origin_x);
	WriteCoord(MSG_BROADCAST, self.origin_y);
	WriteCoord(MSG_BROADCAST, self.origin_z);
	WriteCoord(MSG_BROADCAST, end_x);
	WriteCoord(MSG_BROADCAST, end_y);
	WriteCoord(MSG_BROADCAST, end_z);

	self.oldorigin = trace_endpos;
	
	self.think = target_laser_think;
	self.nextthink = time + 0.1;
}

void() target_laser_on =
{
	if (!self.oldenemy)
		self.oldenemy = self;
	target_laser_think ();
}

void() target_laser_off =
{
	self.spawnflags &= ~1;
	self.nextthink = -1;
}

void() target_laser_use =
{
	self.oldenemy = activator;
	if (self.spawnflags & 1)
		target_laser_off ();
	else
		target_laser_on ();
}

void() target_laser_start =
{
	local entity ent;

	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;

	if (!self.enemy)
	{
		if (self.target)
		{
			ent = find(world, targetname, self.target);
			if (!ent)
				objerror ("laser found no target");
			self.enemy = ent;
		}
		else
		{
			SetMovedir ();
		}
	}
	self.use = target_laser_use;
	self.think = target_laser_think;
	self.nextthink = time + 0.1;

	if (!self.dmg)
		self.dmg = 1;

	setsize (self, '-8 -8 -8', '8 8 8');

	if (self.spawnflags & 1)
		target_laser_on ();
	else
		target_laser_off ();
}

void() target_lightning =
{
	// let everything else get spawned before we start firing
	self.think = target_laser_start;
	self.nextthink = time + 1;
}