

void() monster_shambler =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	
	monster_gladiator_cache ();	
	monster_lt_tank_cache ();

	if (world.model != "maps/e1m3.bsp")
	{	
		if (random() <= 0.35)
			spawn_light_tank ();
		else
			spawn_gladiator ();
	}
	else
		spawn_gladiator ();
};
