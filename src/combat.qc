
void() T_MissileTouch;
void() info_player_start;
void(entity targ, entity attacker) ClientObituary;

void() monster_death_use;

//============================================================================

/*
============
CanDamage

Returns true if the inflictor can directly damage the target.  Used for
explosions and melee attacks.
============
*/
float(entity targ, entity inflictor) CanDamage =
{
// bmodels need special checking because their origin is 0,0,0
	if (targ.movetype == MOVETYPE_PUSH)
	{
		traceline(inflictor.origin, 0.5 * (targ.absmin + targ.absmax), TRUE, self);
		if (trace_fraction == 1)
			return TRUE;
		if (trace_ent == targ)
			return TRUE;
		return FALSE;
	}
	
	traceline(inflictor.origin, targ.origin, TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '15 15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '-15 -15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '-15 15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '15 -15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;

	return FALSE;
};


/*
============
Killed
============
*/
void(entity targ, entity attacker) Killed =
{
	local entity oself;

	oself = self;
	self = targ;
	
// why the fuck wasn't this only for the player before
	if (self.health < -99 && (self.flags & FL_CLIENT))
		self.health = -99;		// don't let sbar look bad if a player

	if (self.movetype == MOVETYPE_PUSH || self.movetype == MOVETYPE_NONE)
	{	// doors, triggers, etc
		self.th_die ();
		self = oself;
		return;
	}
	
	if (attacker.flags & FL_MONSTER || self.classname == "explo_box")
		self.enemy = attacker;
	
// bump the monster counter
	if ((self.flags & FL_MONSTER) )
	{	
		
		if (self.goonmaster && self.goonmaster.goons > 0 && !(self.deadflag & DEAD_DEAD)) // if youre a goon, decrease goon master goon count
			self.goonmaster.goons = self.goonmaster.goons - 1;

		if(!(self.flags & FL_RESURRECTED) && !(self.deadflag & DEAD_DEAD))
		{
			killed_monsters = killed_monsters + 1;
			WriteByte (MSG_ALL, SVC_KILLEDMONSTER);
		}
	}
	
	if (!(self.deadflag) && (self.flags & FL_CLIENT))
		ClientObituary(self, attacker);
	self.touch = SUB_Null;
	
	if (!(self.deadflag & DEAD_DEAD) && (self.flags & FL_MONSTER))
		monster_death_use();
	
	if ((self.deadflag < DEAD_DYING) && (self.flags & FL_CLIENT))
	{	
		self.th_die ();
		self = oself;
		return;
	}

	if (!(self.flags & FL_CLIENT))
	{
		self.th_die ();
		self = oself;
	}
};


/*
============
Poison Entity

Poison damage...
============
*/

void() Poison_DoDmg =
{
	T_Damage (self.enemy, self, '0 0 0', self, 1, 0, DMGTYPE_TOX);
	self.think = Poison_DoDmg;
	self.nextthink = time + 0.3;

	if ((self.ltime < time) || (self.enemy.health <= 0))
	{
		remove(self);
		return;
	}
}

void(entity inflictor) Poison_ =
{	
	if (inflictor.classname == "poison")
		return;

	if (self.health <= 0)
		return;

	entity oself;
	local entity tox;
	tox = spawn();
	setorigin(tox, inflictor.origin);
	setsize(tox, VEC_ORIGIN, VEC_ORIGIN);

	tox.ltime = time + 3;
	tox.enemy = self;

	oself = self;
	self = tox;
	self.think = Poison_DoDmg;
	self.nextthink = time;
	self.classname = "poison";

	self = oself;
};

/*
============
Infight_checks

Buncha conditions for infighting
============
*/

float(entity attacker) Retaliate =
{	
	if (self.aiflags & AI_FLEE) // fleeing, dont change enemies
		return FALSE;

	if (self.aiflags & AI_AIMFLY) // aiming, dont change enemies
		return FALSE;

	if (attacker.enemy == self) 
		return TRUE;

	if (attacker.flags & FL_CLIENT)
		return TRUE;

	if (self.attack_state == AS_STRAIGHT) 
		return FALSE; // don't retaliate while running

	if (random() < 0.3) 
		return FALSE; // evil

	if (self.goonmaster == attacker) 
		return FALSE; 

	if (attacker.goonmaster == self) 
		return FALSE; 

	 return TRUE; 
};

/*
============
T_Damage

The damage is coming from inflictor, but get mad at attacker
This should be the only function that ever reduces health.
============
*/
void(entity targ, entity inflictor, vector inflictor_org, entity attacker, float damage, float kick, float MOD = 0) T_Damage =
{
	local	entity	oldself;
	local	float	save;
	local	float	take;

	if (!targ.takedamage)
		return;

	if (targ.classname == "gib")
	{
		if(kick)
		{
			local vector dir2 = targ.origin - inflictor_org;
			dir2 = normalize(dir2);
			
			targ.velocity = targ.velocity + dir2* (500.0 * kick / 50 );

			if(targ.flags & FL_ONGROUND)
				targ.velocity_z = targ.velocity_z + vlen(dir2 * (500.0 * kick / 100 ) );

			targ.flags = targ.flags - (targ.flags & FL_ONGROUND);
		}

		return;
	}	

// used by buttons and triggers to set activator for target firing
	damage_attacker = attacker;

// check for quad damage powerup on the attacker
	if (attacker.super_damage_finished > time)
	{
		damage = damage * 4;
		kick = kick * 4;
	}

// save damage based on the target's armor level
	
	save = ceil(targ.armortype*damage);

	if (MOD == DMGTYPE_TOX)
		save = 0;

	if (save >= targ.armorvalue)
	{
		save = targ.armorvalue;
		targ.armortype = 0;	// lost all armor
		targ.items = targ.items - (targ.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3));
	}
	
// check for godmode or invincibility
	if (targ.flags & FL_GODMODE)
		return;
	
	targ.armorvalue = targ.armorvalue - save;

	if(MOD == DMGTYPE_RAIL)
		save *= 0.3;

	take = ceil(damage-save);

// add to the damage total for clients, which will be sent as a single
// message at the end of the frame
// FIXME: remove after combining shotgun blasts?
	if (targ.flags & FL_CLIENT)
	{
		targ.dmg_take = targ.dmg_take + take;
		targ.dmg_save = targ.dmg_save + save;
		targ.dmg_inflictor = inflictor;
	}

	// figure momentum add
	if (targ.mass == 0)
		kick = 0;

	else if ((targ.movetype != MOVETYPE_PUSH) && (targ.movetype != MOVETYPE_NONE) && (targ.movetype != MOVETYPE_BOUNCE))
	{
		if(kick && (checkbottom(targ)) && !(targ.flags & FL_LEAP) )
		{		
			if((targ.flags & FL_MONSTER))
				inflictor_org[2] = targ.origin[2];				

			local vector dir = targ.origin - inflictor_org;
			dir = normalize(dir);

			if ((targ.flags & FL_CLIENT) && attacker == targ)
				targ.velocity = targ.velocity + dir* (1600.0 * kick / targ.mass );	
			else
				targ.velocity = targ.velocity + dir* (500.0 * kick / targ.mass );

			if((targ.flags & FL_MONSTER))
			{
				targ.flags = targ.flags - (targ.flags & FL_ONGROUND);
				targ.velocity_z = targ.velocity_z + vlen(dir* (250.0 * kick / targ.mass ) );
			}
		}
	}		

// team play damage avoidance
	if ( (teamplay == 1) && (targ.team > 0) && (targ.team == attacker.team) )
		return;
		
// do the damage
	if((targ.classname == attacker.classname) 
		&& (targ.flags & FL_MONSTER) && skill >= 1 && attacker != targ ) // enemies of same type don't damage eachother
		take = 0;

	if(targ == attacker.goonmaster && attacker.goonmaster != world) // no friendly fire between a goon master and its goons
		take = 0;

	if(targ.goonmaster == attacker && targ.goonmaster != world) 
		take = 0;

	if ((attacker.flags & FL_CLIENT) && targ.classname != "shield_bbox")
	{
		msg_entity = attacker;
		WriteByte (MSG_MULTICAST, SVC_CGAMEPACKET);
		WriteByte (MSG_MULTICAST, HITMARKER);
		multicast ('0 0 0', MULTICAST_ONE);
	}
	
	if(take > 0) 
	{			
		targ.health = targ.health - take;
			
		if (targ.health <= 0)
		{		
			Killed (targ, attacker);
			return;
		}
	}

// react to the damage
	oldself = self;
	self = targ;

	if (MOD == DMGTYPE_TOX)
		Poison_ (inflictor);

	if ( (self.flags & FL_MONSTER) && !(self.flags & FL_MEDIC) && Retaliate(attacker)
		&& ( (attacker.flags & FL_MONSTER) || (attacker.flags & FL_CLIENT) ) )
	{
		if (self != attacker && attacker != self.enemy 
			 && ((self.flags & (FL_FLY|FL_SWIM)) == (attacker.flags & (FL_FLY|FL_SWIM)))
			&& (!(self.enemy.flags & FL_MONSTER))) // dont infight while already INFIGHTINg
		{
			if ( (self.classname != attacker.classname) )
			{
				if ((self.enemy.flags & FL_CLIENT))
					self.oldenemy = self.enemy;

				self.enemy = attacker;
				FoundTarget (self);
			}
				
		}

	}

	if (self.th_pain && take > 0)
	{
		self.th_pain (attacker, take, MOD);
		// nightmare mode monsters don't make pain noises often	

		if (MOD != DMGTYPE_LTNG) // if isnt lightning damage take default 
		{
			if (skill >= 2 && (self.flags & FL_MONSTER))
				self.pain_finished = time + 3;
		}

		if (MOD == DMGTYPE_DMG)
			self.pain_finished = time + 0.1;
	}

	self = oldself;
};

/*
============
T_RadiusDamage
============
*/

static void(entity tell, vector o, vector vel, float p) spawnbloodspray =
{	
	for(float i = 0; i<4;i++)
		SpawnBlood (tell, o, vel * 0.25, p);
//	bprint("how");

}

void(entity inflictor, entity attacker, float damage, float damage_rad, entity ignore, float MOD = 1) T_RadiusDamage =
{
	local	float 	points;
	local	entity	head;
	local	vector	org;
	
	for (head = findradius(inflictor.origin, damage_rad); head; head = head.chain)
	{	
		if(head == ignore)
			continue;
    	if(!head.takedamage)
            continue;
        if(!CanDamage(head, inflictor))
            continue;
		if (head.classname == attacker.classname && (attacker.flags & FL_MONSTER) )
			continue;
		
		org = head.origin + (head.mins + head.maxs)*0.5;
		points = 0.5*vlen (inflictor.origin - org);
		if (points < 0)
			points = 0;
		points = damage - points;
		if (head == attacker)
			points = points * 0.5;

		if (points < 0)
			continue;

		if (attacker.classname == "monster_hovertank")						
			T_Damage (head, inflictor, inflictor.origin, attacker, points, points*0.8, MOD);
		else if (inflictor.classname == "plasma")
			T_Damage (head, inflictor, inflictor.origin, attacker, points, 30, DMGTYPE_NORM); // lol
		else if (inflictor.classname == "blackhole")
			T_Damage (head, inflictor, inflictor.origin, attacker, points, 250, MOD);
		else 
			T_Damage (head, inflictor, inflictor.origin, attacker, points, points*0.4, MOD);
		
		if (head.classname != "func_explosive" && head.classname != "explo_box")
			spawnbloodspray  (head, org, (inflictor.origin - org), points);

	}	
};


void(entity caller, float power, float timer) GroundShake = 
{	
	if (!power || !timer)
		return;
	
	entity e;
	
	e = findradius(self.origin, 1024);
	
	while (e) 
	{	
		if (e.classname == "player")
		{
		//	bprint("bawhhh","\n");
			if (!e.shake_time)
			{
				e.shake_time = time + timer;
				e.shake_interval = power;
			}
		}

		e = e.chain;
	}
}

/*
============
T_RadiusPoison
============
*/

void(entity inflictor, entity attacker, float damage, float damage_rad, entity ignore) T_RadiusPoison =
{
	local	float 	points;
	local	entity	head;
	local	vector	org;
	
	for (head = findradius(inflictor.origin, damage_rad); head; head = head.chain)
	{	
		if(head == ignore)
			continue;
    	if(!head.takedamage)
            continue;
        if(!CanDamage(head, inflictor))
            continue;
		if (head.classname == attacker.classname && (attacker.flags & FL_MONSTER) )
			continue;

		org = head.origin + (head.mins + head.maxs)*0.5;
		points = 0.5*vlen (inflictor.origin - org);
		if (points < 0)
			points = 0;
		points = damage - points;
		if (head == attacker)
			points = points * 0.5;

		T_Damage (head, inflictor, inflictor.origin, attacker, points, 0, DMGTYPE_TOX);
	}	
};
