

/*QUAKED monster_enforcer (1 0 0) (-16 -16 -24) (16 16 40) Ambush

*/
void() monster_enforcer =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	monster_soldier_cache ();	

	if (random() >= 0.7)
		spawn_soldier_blaster ();
	else
		spawn_soldier_machinegun();
};

