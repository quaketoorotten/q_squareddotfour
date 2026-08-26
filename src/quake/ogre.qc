

void() monster_ogre =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	monster_gunner_cache ();	
	spawn_gunner ();
};

