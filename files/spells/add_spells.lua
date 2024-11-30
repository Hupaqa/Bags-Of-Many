if DebugGetIsDevBuild() then --ensures spells won't exist in regular play in any capacity.



--binders
table.insert( actions,
{

	id          = "BAGSOFMANY_SPAWN_SMALLBINDER",
	name 		= "spawn small spell binder",
	description = "DEVELOPER SPELL",
	sprite 		= "mods/bags_of_many/files/spells/SPAWN_SMALLBINDER.png",
	type 		= ACTION_TYPE_OTHER,
	spawn_level                       = "", --this shouldn't ever spawn naturally.
	spawn_probability                 = "",
	price = 0,
	mana = 0,
	action 		= function()
		c.fire_rate_wait = c.fire_rate_wait + 120
		if reflecting then return end
		add_projectile("mods/bags_of_many/files/spells/SPAWN_SMALLBINDER.xml")
		
	end,
} )
table.insert( actions,
{

	id          = "BAGSOFMANY_SPAWN_MEDIUMBINDER",
	name 		= "spawn medium spell binder",
	description = "DEVELOPER SPELL",
	sprite 		= "mods/bags_of_many/files/spells/SPAWN_MEDIUMBINDER.png",
	type 		= ACTION_TYPE_OTHER,
	spawn_level                       = "",
	spawn_probability                 = "",
	price = 0,
	mana = 0,
	action 		= function()
		c.fire_rate_wait = c.fire_rate_wait + 120
		if reflecting then return end
		add_projectile("mods/bags_of_many/files/spells/SPAWN_MEDIUMBINDER.xml")
		
	end,
} )
table.insert( actions,
{

	id          = "BAGSOFMANY_SPAWN_BIGBINDER",
	name 		= "spawn big spell binder",
	description = "DEVELOPER SPELL",
	sprite 		= "mods/bags_of_many/files/spells/SPAWN_BIGBINDER.png",
	type 		= ACTION_TYPE_OTHER,
	spawn_level                       = "",
	spawn_probability                 = "",
	price = 0,
	mana = 0,
	action 		= function()
		c.fire_rate_wait = c.fire_rate_wait + 120
		if reflecting then return end
		add_projectile("mods/bags_of_many/files/spells/SPAWN_BIGBINDER.xml")
		
	end,
} )

--pouches
table.insert( actions,
{

	id          = "BAGSOFMANY_SPAWN_SMALLPOUCH",
	name 		= "spawn small potion pouch",
	description = "DEVELOPER SPELL",
	sprite 		= "mods/bags_of_many/files/spells/SPAWN_SMALLPOUCH.png",
	type 		= ACTION_TYPE_OTHER,
	spawn_level                       = "",
	spawn_probability                 = "",
	price = 0,
	mana = 0,
	action 		= function()
		c.fire_rate_wait = c.fire_rate_wait + 120
		if reflecting then return end
		add_projectile("mods/bags_of_many/files/spells/SPAWN_SMALLPOUCH.xml")
		
	end,
} )
table.insert( actions,
{

	id          = "BAGSOFMANY_SPAWN_MEDIUMPOUCH",
	name 		= "spawn medium potion pouch",
	description = "DEVELOPER SPELL",
	sprite 		= "mods/bags_of_many/files/spells/SPAWN_MEDIUMPOUCH.png",
	type 		= ACTION_TYPE_OTHER,
	spawn_level                       = "",
	spawn_probability                 = "",
	price = 0,
	mana = 0,
	action 		= function()
		c.fire_rate_wait = c.fire_rate_wait + 120
		if reflecting then return end
		add_projectile("mods/bags_of_many/files/spells/SPAWN_MEDIUMPOUCH.xml")
		
	end,
} )
table.insert( actions,
{

	id          = "BAGSOFMANY_SPAWN_BIGPOUCH",
	name 		= "spawn big potion pouch",
	description = "DEVELOPER SPELL",
	sprite 		= "mods/bags_of_many/files/spells/SPAWN_BIGPOUCH.png",
	type 		= ACTION_TYPE_OTHER,
	spawn_level                       = "",
	spawn_probability                 = "",
	price = 0,
	mana = 0,
	action 		= function()
		c.fire_rate_wait = c.fire_rate_wait + 120
		if reflecting then return end
		add_projectile("mods/bags_of_many/files/spells/SPAWN_BIGPOUCH.xml")
		
	end,
} )


--universals
table.insert( actions,
{

	id          = "BAGSOFMANY_SPAWN_SMALLUNIVERSAL",
	name 		= "spawn small universal bag",
	description = "DEVELOPER SPELL",
	sprite 		= "mods/bags_of_many/files/spells/SPAWN_SMALLUNIVERSAL.png",
	type 		= ACTION_TYPE_OTHER,
	spawn_level                       = "",
	spawn_probability                 = "",
	price = 0,
	mana = 0,
	action 		= function()
		c.fire_rate_wait = c.fire_rate_wait + 120
		if reflecting then return end
		add_projectile("mods/bags_of_many/files/spells/SPAWN_SMALLUNIVERSAL.xml")
		
	end,
} )
table.insert( actions,
{

	id          = "BAGSOFMANY_SPAWN_MEDIUMUNIVERSAL",
	name 		= "spawn medium universal bag",
	description = "DEVELOPER SPELL",
	sprite 		= "mods/bags_of_many/files/spells/SPAWN_MEDIUMUNIVERSAL.png",
	type 		= ACTION_TYPE_OTHER,
	spawn_level                       = "",
	spawn_probability                 = "",
	price = 0,
	mana = 0,
	action 		= function()
		c.fire_rate_wait = c.fire_rate_wait + 120
		if reflecting then return end
		add_projectile("mods/bags_of_many/files/spells/SPAWN_MEDIUMUNIVERSAL.xml")
		
	end,
} )
table.insert( actions,
{

	id          = "BAGSOFMANY_SPAWN_BIGUNIVERSAL",
	name 		= "spawn big universal bag",
	description = "DEVELOPER SPELL",
	sprite 		= "mods/bags_of_many/files/spells/SPAWN_BIGUNIVERSAL.png",
	type 		= ACTION_TYPE_OTHER,
	spawn_level                       = "",
	spawn_probability                 = "",
	price = 0,
	mana = 0,
	action 		= function()
		c.fire_rate_wait = c.fire_rate_wait + 120
		if reflecting then return end
		add_projectile("mods/bags_of_many/files/spells/SPAWN_BIGUNIVERSAL.xml")
		
	end,
} )





end 