
void() monster_demon1 =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	monster_teldrop_cache ();	
    monster_grunt_cache ();
	monster_berserker_cache ();	

	if (world.model != "maps/e1m3.bsp" && world.model != "maps/e1m2.bsp" && world.model != "maps/e1m4.bsp" && 
	world.model != "maps/e1m5.bsp" && world.model != "maps/e1m6.bsp")
	{	
		if (random() <= 0.2)
			spawn_teleport_dropper ();
		else
			spawn_berserker ();
	}
	else
		spawn_berserker ();
};
