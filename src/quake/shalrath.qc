

void() monster_shalrath =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	monster_hovertank_cache ();	
	monster_strm_prot_cache ();	
	monster_tank_cache ();

	if (random() >= 0.2)
	{
		if (random() <= 0.3)
		{	
			if (world.model != "maps/e2m6.bsp")
				spawn_tank ();
			else
				spawn_hovertank ();
		}
		else
			spawn_hovertank ();
	}
	else 
	{
		if (world.model != "maps/e2m6.bsp")
			spawn_stream_protector ();
		else
			spawn_hovertank ();
	}
	
};
