//Tioga060

PlayersInside <- [];

Crate_Contains <- INVENTORY_ITEMS[self.GetHealth()];

function OnPostSpawn()
{
	DoIncludeScript("wartower/util.nut",null);
	DoIncludeScript("wartower/parameters.nut",null);	
}

function Think(){
	CheckPlayersInLongEnough();
}

function AddPlayerToList()
{
	local index = ArrayFindFixCrate(PlayersInside,activator);
	if (index != -1) PlayersInside.remove(index);
	PlayersInside.append(Player(activator,Crate_Contains));
}

function RemovePlayerFromList()
{
	local index = ArrayFindFixCrate(PlayersInside,activator);
	if (index != -1) PlayersInside.remove(index);
	//PlayersInside = [];
}

function ChangeContents()
{
	Crate_Contains = INVENTORY_ITEMS[self.GetHealth()];
	RoleCaller = Entities.FindByName(null,(Crate_Contains.weapon_ent_name));
}


function DisableSelf()
{
	EntFireByHandle(self, "Disable", "<none>", 0.0, self, self);
	EntFireByHandle(self.FirstMoveChild(), "Disable", "<none>", 0.0, self, self);
}

function DestroySelf()
{
	self.Destroy();
}

function EnableSelf()
{
	EntFireByHandle(self, "Enable", "<none>", 0.0, self, self);
	EntFireByHandle(self.FirstMoveChild(), "Enable", "<none>", 0.0, self, self);
}

class Player
{
	player_entity = null;
	time_entered = null;
	crate_contents = null;
	constructor(ent, cc){
		crate_contents = cc;
		player_entity = ent;
		time_entered = Time();
	} 
	
	function InLongEnough(){
		return (Time()-time_entered) >= crate_contents.duration; 
	}
	
	function PrintTimeLeft(){
		displayText(player_entity, crate_contents.weapon_name + "\n" + format("%.1f",max(0,(crate_contents.duration-(Time()-time_entered)))).tostring());
	}
}

function CheckPlayersInLongEnough()
{
	foreach(player in PlayersInside)
	{
		if(player.player_entity.IsValid()){
			player.PrintTimeLeft();
			if(player.InLongEnough()){
				DoEntFire(Crate_Contains.weapon_ent_name + "_equip", "use", "<none>", 0.0, player.player_entity, player.player_entity);
				EntFireByHandle(player.player_entity, "RunScriptCode", format("AddToInventory(%d, self)",Crate_Contains.index), 0.0, player.player_entity, player.player_entity);
				
				DestroySelf();
			}
		}
		else
		{
			local index = ArrayFindFixCrate(PlayersInside,player);
			if (index != -1) PlayersInside.remove(index);
		}
	}
}

function ArrayFindFixCrate(ar, val){
	
	for(local a = 0;a<(ar.len());a+=1)
	{
		if(val == ar[a].player_entity){
			return a;
		}
	}
	return -1;
}

