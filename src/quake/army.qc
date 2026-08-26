

/*QUAKED monster_army (1 0 0) (-16 -16 -24) (16 16 40) Ambush
*/
void() monster_army =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	monster_soldier_cache ();
	
	if (random() >= 0.6)
		spawn_soldier_blaster ();
	else
		spawn_soldier_shotgun();
};

