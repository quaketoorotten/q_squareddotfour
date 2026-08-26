
void() monster_hell_knight =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	
	monster_maiden_cache ();

	monster_iron_maiden ();
};
