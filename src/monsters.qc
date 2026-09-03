/* ALL MONSTERS SHOULD BE 1 0 0 IN COLOR */

// name =[framenum,	nexttime, nextthink] {code}
// expands to:
// name ()
// {
//		self.frame=framenum;
//		self.nextthink = time + nexttime;
//		self.think = nextthink
//		<code>
// };

.void() th_sight;

/*
================
monster_use

Using a monster makes it angry at the current activator
================
*/

float TRIGGER_SPAWN = 4;
float SPAWN_SLIENT = 8;
float SPAWN_ANGRY = 16;

void() monster_spawn =
{		
	self.spawnflags &= ~TRIGGER_SPAWN;
	if(!(self.spawnflags & SPAWN_SLIENT))
		spawn_tfog(self.origin);
	
	self.th_spawn();
	
	self.nextthink = time + 0.1;
	
	if (self.spawnflags & SPAWN_ANGRY)	
	{
		self.th_sight ();
		FoundTarget(self);
		self.flags |= FL_JUMPRELEASED; // foobar
	}

	SUB_KillBox(self);

	if (!M_walkmove(0, 0) && (self.flags & FL_ONGROUND))
		T_Damage (self, self, self.origin, self, 99999, 0);
};

void() monster_use =
{	
	if (self.enemy)
		return;
	if (self.health <= 0)
		return;

	if (self.spawnflags & TRIGGER_SPAWN)
	{	
		if (self.spawnflags & SPAWN_ANGRY)	
			self.enemy = activator;
		self.frame = 1; // first frame is always idle
		self.think = monster_spawn;
		if(self.delay > 0)
			self.nextthink = time + self.delay;
		else
			self.nextthink = time + 0.1;
		return;
	}
	
	if (activator.powerups & IT_INVISIBILITY)
		return;
	if (activator.flags & FL_NOTARGET)
		return;
	if (activator.classname != "player")
		return;
	
// delay reaction so if the monster is teleported, its sound is still
// heard
	self.enemy = activator;
	self.nextthink = time + 0.1;
	FoundTarget(self);
};

/*
================
monster_death_use

When a mosnter dies, it fires all of its targets with the current
enemy as activator.
================
*/
void() monster_death_use =
{
//	local entity 	ent, otemp, stemp;

// fall to ground
	if (self.flags & FL_FLY)
		self.flags = self.flags - FL_FLY;

	if (self.flags & FL_SWIM)
		self.flags = self.flags - FL_SWIM;
	
	if (self.itemname)
	{
		DropItem (self.itemname);
		self.itemname = __NULL__;
	}
			
	if (self.deathtarget)
	{
		self.noise4 = self.deathtarget;
		self.target = self.deathtarget;
		self.deathtarget = __NULL__;
	}

	if (!self.target)
		return;
	
	activator = self.enemy;
	SUB_UseTargets ();
};


//============================================================================

void() walkmonster_start_go =
{	
	droptofloor();

	traceline (self.origin + '0 0 24', self.origin + '0 0 -48', FALSE, self);
	if (!trace_allsolid || !trace_startsolid)
		self.origin_z = trace_endpos_z;

	setorigin(self, self.origin);
	
	self.origin_z = self.origin_z + 1;	// raise off floor a bit
	
	if (!M_walkmove(0,0))
	{
		dprint ("walkmonster in wall at: ");
		dprint (vtos(self.origin));
		dprint ("\n");
	}
	
	self.takedamage = DAMAGE_AIM;
	self.touch = __NULL__;

	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 20;

	self.view_ofs = [0 , 0, self.maxs[2] - 4];

	self.use = monster_use;
	
	self.flags = self.flags | FL_MONSTER;

	if (self.spawnflags & TRIGGER_SPAWN)
	{
		self.model = string_null;
		self.solid = SOLID_NOT;
		self.emiteffectnum = 0;
		return;
	}
	
	if (self.target)
	{
		self.goalentity = self.movetarget = find(world, targetname, self.target);
		self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
		if (!self.movetarget)
		{
			dprint ("Monster can't find target at ");
			dprint (vtos(self.origin));
			dprint ("\n");
		}
// this used to be an objerror
		if (self.movetarget.classname == "path_corner")
			self.th_walk ();
		else
			self.pausetime = 99999999;
			self.th_stand ();
	}
	else if((self.enemy || self.oldenemy))
	{
		//bprint ("hello", "\n");
		if(self.enemy.health > 0)
		{
			self.pausetime = 0;
			FoundTarget(self);
			self.nextthink = time;
			return;
		}
		else if(self.oldenemy.health > 0) // was resurrected
		{	
			self.enemy = self.oldenemy;
			self.pausetime = 0;
			FoundTarget(self);
			self.nextthink = time;
			return;
		}
		else 
		{
			self.pausetime = 99999999;
			self.th_stand ();
		}
	}
	else 
	{
		self.pausetime = 99999999;
		self.th_stand ();
	}

// spread think times so they don't all happen at same time
	self.nextthink = self.nextthink + random()*0.5;
};

void() walkmonster_start =
{
// delay drop to floor to make sure all doors have been spawned
// spread think times so they don't all happen at same time
	self.nextthink = self.nextthink + random()*0.5;
	self.think = walkmonster_start_go;		
	self.brainspeed = 0;

	if((self.flags & FL_JUMPRELEASED))
	{
		self.flags &= ~FL_JUMPRELEASED;
		return;
	}

	if((self.flags & FL_RESURRECTED)) 
		return;
	
	total_monsters = total_monsters + 1;
};


void() flymonster_start_go =
{
	self.takedamage = DAMAGE_AIM;

	traceline (self.origin + '0 0 24', self.origin + '0 0 -48', FALSE, self);
	if (!trace_allsolid || !trace_startsolid)
		self.origin_z = trace_endpos_z;
	
	setorigin(self, self.origin);

	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 10;
	
	//if (self.mins_z == 0)
	self.view_ofs = [0 , 0, self.maxs[2] - 4];
	
	self.use = monster_use;

	self.flags = self.flags | FL_FLY;
	self.flags = self.flags | FL_MONSTER;

	if (!M_walkmove(0,0))
	{
		dprint ("flymonster in wall at: ");
		dprint (vtos(self.origin));
		dprint ("\n");
	}

	if (self.spawnflags & TRIGGER_SPAWN)
	{
		self.model = string_null;
		self.solid = SOLID_NOT;
		self.emiteffectnum = 0;
		return;
	}
	
	
	if (self.target)
	{
		self.goalentity = self.movetarget = find(world, targetname, self.target);
		if (!self.movetarget)
		{
			dprint ("Monster can't find target at ");
			dprint (vtos(self.origin));
			dprint ("\n");
		}
// this used to be an objerror
		if (self.movetarget.classname == "path_corner")
			self.th_walk ();
		else
			self.pausetime = 99999999;
			self.th_stand ();
	}
	 // was resurrected
	else if((self.enemy || self.oldenemy))
	{
		if(self.enemy.health > 0)
		{
			self.pausetime = 0;
			FoundTarget(self);
			self.nextthink = time;
			return;
		}
		else if(self.oldenemy.health > 0) // was resurrected
		{	
			self.enemy = self.oldenemy;
			self.pausetime = 0;
			FoundTarget(self);
			self.nextthink = time;
			return;
		}
		else 
		{
			self.pausetime = 99999999;
			self.th_stand ();
		}
	}
	else 
	{
		self.pausetime = 99999999;
		self.th_stand ();
	}

// spread think times so they don't all happen at same time
	self.nextthink = self.nextthink + random()*0.5;

};

void() flymonster_start =
{
// spread think times so they don't all happen at same time

	self.nextthink = self.nextthink + random()*0.5;
	self.think = flymonster_start_go;
//	self.fly_roll = 0;
//	self.fly_pitch = 0;
	self.brainspeed = 0;

	if((self.flags & FL_JUMPRELEASED))
	{
		self.flags &= ~FL_JUMPRELEASED;
		return;
	}

	if((self.flags & FL_RESURRECTED)) 
		return;

	total_monsters = total_monsters + 1;
};


void() swimmonster_start_go =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}

	self.takedamage = DAMAGE_AIM;

	self.ideal_yaw = self.angles * '0 1 0';
	if (!self.yaw_speed)
		self.yaw_speed = 10;
	self.view_ofs = '0 0 10';
	self.use = monster_use;
	
	self.flags = self.flags | FL_SWIM;
	self.flags = self.flags | FL_MONSTER;

	if (self.spawnflags & TRIGGER_SPAWN)
	{
		self.model = string_null;
		self.solid = SOLID_NOT;
		return;
	}
	
	
	if (self.target)
	{
		self.goalentity = self.movetarget = find(world, targetname, self.target);
		if (!self.movetarget)
		{
			dprint ("Monster can't find target at ");
			dprint (vtos(self.origin));
			dprint ("\n");
		}
// this used to be an objerror
		self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
		self.th_walk ();
	}
	else	if((self.enemy || self.oldenemy ))
	{
		if(self.enemy.health > 0)
		{
			self.pausetime = 0;
			FoundTarget(self);
			self.nextthink = time;
			return;
		}
		else if(self.oldenemy.health > 0) // was resurrected
		{	
			self.enemy = self.oldenemy;
			self.pausetime = 0;
			FoundTarget(self);
			self.nextthink = time;
			return;
		}
		else 
		{
			self.pausetime = 99999999;
			self.th_stand ();
		}
	}
	else 
	{
		self.pausetime = 99999999;
		self.th_stand ();
	}


// spread think times so they don't all happen at same time
	self.nextthink = self.nextthink + random()*0.5;
};

void() swimmonster_start =
{
// spread think times so they don't all happen at same time

	self.nextthink = self.nextthink + random()*0.5;
	self.think = swimmonster_start_go;
	self.brainspeed = 0;

	if((self.flags & FL_JUMPRELEASED))
	{
		self.flags &= ~FL_JUMPRELEASED;
		return;
	}

	if((self.flags & FL_RESURRECTED)) 
		return;

	total_monsters = total_monsters + 1;
};



