void() monster_soldier_shotgun =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	monster_soldier_cache ();	
	spawn_soldier_shotgun ();
};

void() spawn_soldier_shotgun =
{	
	spawn_soldier_blaster ();

	setmodel(self, "progs/monsters/strogg_marine/strogg_marine2.md5.info");

	setsize(self, '-16 -16 0', '16 16 64');
	self.th_spawn = spawn_soldier_shotgun;

    self.speed = 6.5;
	self.weapontype = 2;
};
