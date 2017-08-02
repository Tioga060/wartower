//Tioga060

//This sets the player tracker equipment to be named after the player just before it spawns so that multiple playertrackers dont parent to the same player
Team <- null;


function OnPostSpawn()
{
	DoIncludeScript("wartower/util.nut",null);
	DoIncludeScript("wartower/parameters.nut",null);
}

function SetTeam(value)
{
	Team = value;
}

function PreSpawnInstance( entityClass, entityName )
{
	local keyvalues =
	{ 
		targetname = format("filter_team%d", Team)
		filtername = format("onteam%d", Team)
	}
	return keyvalues;
}
