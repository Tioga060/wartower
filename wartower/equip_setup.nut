//Tioga060

//This sets the player tracker equipment to be named after the player just before it spawns so that multiple playertrackers dont parent to the same player
Weapon <- null;


function OnPostSpawn()
{
	DoIncludeScript("wartower/util.nut",null);
	DoIncludeScript("wartower/parameters.nut",null);
}

function SetWeapon(value)
{
	Weapon = INVENTORY_ITEMS[value];
}

function PreSpawnInstance( entityClass, entityName )
{
	local keyvalues =
	{ 
		targetname = Weapon.weapon_ent_name + "_equip"
	}
	keyvalues[Weapon.weapon_ent_name] <- 1;
	return keyvalues;
}
