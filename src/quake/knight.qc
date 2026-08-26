

void() monster_knight =
{	
	if (deathmatch)
	{
		remove(self);
		return;
	}
	monster_grunt_cache ();	
	monster_tactical_cache ();
	float r = rint(random() * 3);

	if (random() <= 0.2)
		spawn_grunt ();
	else
	{	
		if (r == 1)
			monster_tactical_mg ();
		else if (r == 2)
			monster_tactical_sg ();
		else if (r == 3)
			monster_tactical_hb ();
		else 
		{	
			if (world.model != "maps/e1m2.bsp" && world.model != "maps/e1m5.bsp" && world.model != "maps/e1m4.bsp")
			{
				monster_tactical_rg ();
			}
			else
			{
	
				if (random() <= 0.5)
					monster_tactical_sg ();
				else
					monster_tactical_hb ();
			}

		}
	}
};

