/*
==============================================================================

PLAYER TRAIL

==============================================================================

This is a circular list containing the a list of points of where
the player has been recently.  It is used by monsters for pursuit.

.origin		the spot
.owner		forward link
.aiment		backward link
*/


float		TRAIL_LENGTH	= 8;

entity 		trail[8];
float			trail_head;
float			trail_active;

//#define NEXT(n)		(((n) + 1) & (TRAIL_LENGTH - 1))
//#define PREV(n)		(((n) - 1) & (TRAIL_LENGTH - 1))

float(float n) prevtrail =
{
	local float res;
	res = (n - 1) & (TRAIL_LENGTH - 1);
	return res;
}

float(float n) nexttrail =
{
	local float res;
	res = (n + 1) & (TRAIL_LENGTH - 1);
	return res;
}

void() PlayerTrail_Init =
{
	local float		n;

	if (deathmatch /* FIXME || coop */)
		return;

	for (n = 0; n < TRAIL_LENGTH; n++)
	{
		trail[n] = spawn();
		trail[n].classname = "player_trail";
		//setmodel(trail[n], "progs/male/tris.mdl");
	}

	trail_head = 0;
	trail_active = TRUE;
}


void(vector spot) PlayerTrail_Add =
{
	local vector	temp;

	if (!trail_active)
		return;

	trail[trail_head].origin = spot;
	//bprint ("marker spawned at: ", vtos(trail[trail_head].origin), "\n");

	trail[trail_head].ltime = time;
	
	temp = spot - trail[prevtrail(trail_head)].origin;
	
	trail[trail_head].angles[1] = vectoyaw (temp);

	trail_head = nexttrail(trail_head);
}


void(vector spot) PlayerTrail_New =
{
	if (!trail_active)
		return;
	
	//bprint ("hi");
	PlayerTrail_Init ();
	PlayerTrail_Add (spot);
}


entity(entity caller) PlayerTrail_PickFirst =
{
	local float		marker;
	local float		n;

	if (!trail_active)
		return  world;

	for (marker = trail_head, n = TRAIL_LENGTH; n; n--)
	{
		if(trail[marker].ltime <= caller.trail_time)
			marker = nexttrail(marker);
		else
			break;
	}

	if (visible(trail[marker]))
	{
		return trail[marker];
	}

	if (visible(trail[prevtrail(marker)]))
	{
		return trail[prevtrail(marker)];
	}

	return trail[marker];
}

entity(entity caller) PlayerTrail_PickNext =
{
	local float		marker;
	local float		n;

	if (!trail_active)
		return world;

	for (marker = trail_head, n = TRAIL_LENGTH; n; n--)
	{
		if(trail[marker].ltime <= caller.trail_time)
			marker = nexttrail(marker);
		else
			break;
	}

	return trail[marker];
}

entity() PlayerTrail_LastSpot =
{
	return trail[prevtrail(trail_head)];
}