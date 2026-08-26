
/*QUAKED monster_dog (1 0 0) (-32 -32 -24) (32 32 40) Ambush

*/

void() monster_dog =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	monster_grunt_cache ();	
	spawn_grunt ();
//	self.weapontype = 1;
	self.max_health = 150;
	self.health = self.max_health;
};

