

void() monster_wizard =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}


	monster_sentry_cache ();
	monster_scientist_cache ();	

	if (random() <= 0.4)
		spawn_scientist ();
	else
		spawn_sentry();
};

