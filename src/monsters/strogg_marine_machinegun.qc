void() monster_soldier_machinegun =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	monster_soldier_cache ();	
	spawn_soldier_machinegun ();
};

void() spawn_soldier_machinegun =
{
	spawn_soldier_blaster ();
	setmodel(self, "progs/monsters/strogg_marine/strogg_marine3.md5.info");
	setsize(self, '-16 -16 0', '16 16 64');

	self.th_spawn = spawn_soldier_machinegun;
	self.weapontype = 3;
};

void() monster_soldier_ss =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	monster_soldier_cache ();	
	spawn_soldier_machinegun ();
};
