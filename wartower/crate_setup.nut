//Tioga060

//This sets the player tracker equipment to be named after the player just before it spawns so that multiple playertrackers dont parent to the same player
LatestRoll <- null;
QueueDeletions <- false;
LatestLevel <- 0;

function RollCrate()
{
	local crate = Crate(self.GetAngles());
	if(crate.level != LatestLevel)
	{
		QueueDeletions  = true;
	}
	LatestLevel = crate.level;
	local possible_weapons = ROUND_WEAPON_LIST[crate.level][crate.crate_type];
	LatestRoll = possible_weapons[RandIntBetween(0,possible_weapons.len()-1)];
}


function OnPostSpawn()
{
	DoIncludeScript("wartower/util.nut",null);
	DoIncludeScript("wartower/parameters.nut",null);	
	RollCrate();
}

function DeleteOldCrates(name)
{
	local andIndex = name.find("&");
	local startKill = name.slice(andIndex+1).tointeger()-1;
	while(true)
	{
		local toKill = "crate_weapon&" + format("%04u",startKill);
		local killMe = Entities.FindByName(null, toKill);
		if(killMe == null) return true;
		killMe.Destroy();
		startKill-=1;
	}
}

function PreSpawnInstance( entityClass, entityName )
{
	
	if(entityName == "crate_pedestal") RollCrate();
	local contains = LatestRoll;
	if(entityName == "crate_weapon_model")
	{
		
		local keyvalues =
		{ 
			model = INVENTORY_ITEMS[contains].model
		}
		return keyvalues;
	}
	if(QueueDeletions && entityClass == "trigger_multiple")
	{
		if(CLEANUP_OLD_CRATES)
		{
			DeleteOldCrates(entityName);
		}
		QueueDeletions = false;
	}
	
	if(entityClass == "trigger_multiple"){
		local keyvalues =
		{ 
			health = contains
		}
		return keyvalues;
	}
}