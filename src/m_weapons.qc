

/*
==============================================================================

MULTI-DAMAGE

Collects multiple small damages into a single damage

==============================================================================
*/


void() tracer_touch = 
{
	if (other == self.owner)
		return;

	vector org = self.origin - normalize(self.velocity)*4;

	if (other.takedamage)
	{	
		T_Damage (other, self, self.origin, self.owner, self.dmg, self.dspeed);

		if (other.classname == "gib")
		{
			if (random() < 0.4) 
				SpawnBlood (other, org, self.velocity * 0.2, self.dspeed * 2.5);
		} 
		else
			SpawnBlood (other, org, self.velocity * 0.2, self.dspeed * 2.5);
		
		// pointparticles (particleeffectnum("TE_BLOOD2"), org);
	}
	else
	{	
		pointparticles (particleeffectnum("d3fx.te_spike"), self.origin - normalize(self.velocity)*4);
		SpawnImpact (org, self.velocity);
	}

	remove(self);
};

void(vector org, vector direction, float damage, float kick, float speed) TracerBullet = 
{ 

	local entity tracer = spawn();
	tracer.owner = self;
	tracer.movetype = MOVETYPE_FLY;
	tracer.solid = SOLID_BBOX;

	tracer.angles = vectoangles(direction);
	
	tracer.classname = "tracer";
	tracer.effects = tracer.effects | EF_ADDITIVE | EF_FULLBRIGHT | EF_NOSHADOW;
	tracer.think = SUB_Remove;
	tracer.nextthink = time + 6;
	tracer.touch = tracer_touch;
	tracer.alpha = 0.7;
	tracer.scale = 0.7;
	tracer.dmg = damage;
	
	tracer.velocity = direction * speed;
	tracer.dspeed = kick;

	setmodel (tracer, "progs/tracer.md3");  //Precache model in WORLD.QC
	setsize (tracer, '0 0 0', '0 0 0');
	setorigin (tracer, org);
};

void(float shotcount, vector start, vector dir, vector spread, float damage, float kick, float speed) monster_FireBullets =
{
    local vector direction;
    local vector src;

    makevectors(self.angles);
	
   // m_puff (start + v_forward * 10);
    src = start + v_forward * 10;
  //  src_z = self.absmin_z + self.size_z * 0.7;

    while (  shotcount --)
    {
        direction = dir + crandom() * spread_x * v_right + crandom() * spread_y * v_up;
		TracerBullet (src, direction, damage, kick, speed);

    }
};

//================================================================================================================================

float STOP_EPSILON   = 0.1;
vector ClipVelocity(vector in, vector normal, float overbounce)
{
    float dot = dotproduct(in, normal);
    vector out = in + (normal * (-2 * dot));
    out = out * (overbounce - 1.0);
    
    if (dotproduct(out, out) < STOP_EPSILON * STOP_EPSILON)
        out = '0 0 0';
    
    return out;
}

static float vlensquared(vector v) =
{
	return v[0]^2 + v[1]^2 + v[2]^2;
}

// quake 2 rerelease
float M_CalculatePitchToFire(vector targ, vector start,__inout vector aim_, float speed, float time_remaining, float mortar, float destroy_on_touch)
{
	float pitches[9] = { -80.0, -70.0, -60.0, -50.0, -40.0, -30.0, -20.0, -10.0, -5.0 };
    float best_pitch = 0.0;
	// idk a quakec version of this
    float best_dist = 999999999;
	
    float sim_time = 0.1;
   	vector fwd, up, r;
    vector pitched_aim = vectoangles_(aim_);
    float grav = cvar("sv_gravity");	

    for (float pitch = 0; pitch < 9; pitch++)
    {
        if (mortar && pitches[pitch] >= -30.0)
            break;

        pitched_aim[0] = pitches[pitch];
		
	  	AngleVectors(pitched_aim, fwd, r, up);

        vector vel = fwd * speed;
        vector org = start;

        float t = time_remaining;

        while (t > 0.0)
        {  
			vel += '0 0 -1' * grav * sim_time;

            vector end = org + (vel * sim_time);
			traceline(org, end, 0, self);

            org = trace_endpos;

            if (trace_fraction < 1)
            {
                if (pointcontents(org) == CONTENT_SKY)
                    break;

                org = org + trace_plane_normal;
                vel = ClipVelocity(vel, trace_plane_normal, 1.6);

                float dist = vlensquared(org - targ);

                if (trace_ent == self.enemy || (trace_ent.classname == "player") || 
				(trace_plane_normal[2] >= 0.7 && dist < (128 * 128) && dist < best_dist))
                {
                  	best_pitch = pitches[pitch];
			//  bprint(ftos(best_pitch), "\n");
                    best_dist = dist;
                }

				if (destroy_on_touch)
                    break;
            }

            t -= sim_time;
        }
    }

    if (best_dist > 0)
    {	
        pitched_aim[0] = best_pitch;
	  	AngleVectors(pitched_aim, fwd, r, up);
        aim_ = fwd;
	
        return TRUE;
    } 

    return FALSE;
};

void() m_GrenadeExplode =
{
	T_RadiusDamage (self, self.owner, self.dmg, self.dmg_rad + 40, world);
//	sound (self, CHAN_VOICE, "weapons/r_exp3.wav", 1, ATTN_NORM);

	rocketimpact  ();
	
	BecomeExplosion ();
};

void() m_GrenadeTouch =
{	
	if (other.classname == "shield_bbox")
		return;
	if (other == self.owner)
		return;		// don't explode on owner
	if (other.takedamage)
	{
		m_GrenadeExplode();
		return;
	}
	sound (self, CHAN_VOICE, "weapons/bounce.wav", 1, ATTN_NORM);	// bounce sound
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

void(vector org, vector dir, float damage, float timer, float right_adjust, float up_adjust, float speed) monster_FireGravityBall=
{
	local	entity missile;
	float grav = cvar("sv_gravity");
	
	//self.effects = self.effects | EF_MUZZLEFLASH;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;

	if (damage > 65)
		missile.classname = "missile";
	else
		missile.classname = "grenade";
		
// set missile speed	

	makevectors (dir);
	missile.velocity = dir * speed;

	if (up_adjust)
	{
		float gravityAdjustment = grav / 800;
		missile.velocity += v_up * up_adjust * gravityAdjustment ;
	}

	if (right_adjust)
		missile.velocity += v_right * right_adjust;

	missile.dmg = damage;
	missile.dmg_rad = damage;
	missile.aiflags |= IS_PROJECTILE;

	missile.avelocity = '300 300 300';

	missile.angles = vectoangles(missile.velocity);
	
	missile.touch = m_GrenadeTouch;

// set missile duration
	missile.nextthink = time + timer;
	missile.ltime = timer;
	missile.think = m_GrenadeExplode;

	setmodel(missile, "progs/weapons/grenadelauncher/grenade.md3");
	missile.traileffectnum = particleeffectnum ("EF_NADETRAIL2");

	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, org);
};

static vector vectoangles_ (vector vec)
{
	float forward;
	float yaw, pitch;

	if (vec[1] == 0 && vec[0] == 0)
	{
		if (vec[2] > 0)
			return '-90 0 0';
		else
			return  '-270 0 0';
	}

	// PMM - fixed to correct for pitch of 0
	if (vec[0])
		yaw = (atan2(vec[1], vec[0]) * (180 / M_PI));
	else if (vec[1] > 0)
		yaw = 90;
	else
		yaw = 270;

	if (yaw < 0)
		yaw += 360;

	forward = sqrt(vec[0] * vec[0] + vec[1] * vec[1]);
	pitch = (atan2(vec[2], forward) * (180 / M_PI));

	if (pitch < 0)
		pitch += 360;

	vec_x = -pitch;
	vec_y = yaw;
	vec_z = 0;
	
	return vec;
};

/*
=================
fire_hit

Used for all impact (hit/punch/slash) attacks
=================
*/
float fire_hit (vector aim, float damage, float kick)
{
	vector		forward, right, up;
	vector		point;
	float		range;
	vector		dir;
	vector 		v;

	//see if enemy is in range
	dir = self.enemy.origin - self.origin;
	range = vlen(dir);
	if (range > aim[0])
		return FALSE;

	if (aim[1] > self.mins[0] && aim[1] < self.maxs[0])
	{
		// the hit is straight on so back the range up to the edge of their bbox
		range -= self.enemy.maxs[0];
	}
	else
	{
		// this is a side hit so adjust the "right" value out to the edge of their bbox
		if (aim[1] < 0)
			aim[1] = self.enemy.mins[0];
		else
			aim[1] = self.enemy.maxs[0];
	}

	point = self.origin + range*normalize(dir);

	traceline (self.origin, point, FALSE, self);
	if (trace_fraction < 1)
	{
		if (!trace_ent.takedamage)
			return FALSE;
		// if it will hit any client/monster then hit the one we wanted to hit
		if ((trace_ent.flags & FL_MONSTER) || (trace_ent.flags & FL_CLIENT))
			trace_ent = self->enemy;
	}

	AngleVectors(self.angles, forward, right, up);
	point = self.origin + range*forward;
	point += aim[1]*right;
	point += aim[2]*up;
//	dir = point = self.enemy.origin;

	// do the damage
	T_Damage (trace_ent, self, point, self, damage, kick);

	if (!(trace_ent.flags & FL_MONSTER) && !(trace_ent.flags & FL_CLIENT))
		return FALSE;

	vector	size = (self.enemy.maxs - self.enemy.mins) * 0.5;
	v = self.enemy.absmin + 0.5*size;
	v = v - point;
	v = normalize(v);

	self.enemy.velocity += kick*v;
	if (self.enemy.velocity[2] > 0)
		self.enemy.flags &= ~FL_ONGROUND;
	
	SpawnBlood (trace_ent, trace_endpos, '0 0 0', damage);
	return TRUE;
};

void() meat_hit =
{
	local float r = rint(random() * 2);	

	if (r == 2)
		    sound(self, CHAN_WEAPON, "monsters/imp/melee/hit_03.wav", 1, ATTN_NORM);
	else if (r == 1)
		    sound(self, CHAN_WEAPON, "monsters/imp/melee/hit_01.wav", 1, ATTN_NORM);
	else
		    sound(self, CHAN_WEAPON, "monsters/imp/melee/hit_04.wav", 1, ATTN_NORM);
};

void() meat_miss =
{
	local float r = rint(random() * 2);	

	if (r == 2)
		    sound(self, CHAN_WEAPON, "monsters/imp/melee/miss_01.wav", 1, ATTN_NORM);
	else if (r == 1)
		    sound(self, CHAN_WEAPON, "monsters/imp/melee/miss_02.wav", 1, ATTN_NORM);
	else
		    sound(self, CHAN_WEAPON, "monsters/imp/melee/miss_03.wav", 1, ATTN_NORM);
};
