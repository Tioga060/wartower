//Tioga060

//The player class, contains all things the engine needs to know about the player, and some things it does not need to know (yet)
class Player
{
	Ent = 				null;		//The actual player entity in the game
	Name = 				"none";
	Team = 				null;
	Health = 			100;
	PrevHealth = 		100;
	Alive = 			true;
	UniqueHandle = 		null;		//The unique string that identifies this player and his entities generated at the start
	StillInPlay = 		false;
	Jail =				-1;
	JailRound = 		-1;
	Inventory = 		[];
	Events = {};
	
	//Initializes the player
	constructor(ply)
	{
		Ent = ply;
		Name = ply.GetName();
		StillInPlay = 		false;
		EntFireByHandle(Ent, "SetDamageFilter", "dmg_invuln", 0.0, Ent, Ent);
		Inventory = 		[];
		Jail =				-1;
		JailRound = 		-1;
		Events.OnHurt <- function(ply){};
		Events.OnDisconnect <- function(ply){
				PlyManager.RemovePlayer(ply);
				
		};
		Events.OnKilled <- function(ply){
				if(ply.StillInPlay) ply.StillInPlay = false;
				ply.Inventory = [];
				ply.AssignTeam(-1);
				
		};
		Events.OnRespawn <- function(ply){

		};
	}
	
	//Updates the player's health, does housekpeeing, calls events
	function Update()
	{
		PrevHealth = Health;
		UpdateEvents();
		Health = Ent.GetHealth();
		
	}
	
	function AssignTeam(team_number)
	{
		Team = team_number;
		if(team_number == -1)
		{
			if(StillInPlay) StillInPlay = false;
			EntFireByHandle(Ent, "AddOutput", "targetname none", 0.0, Ent, Ent);
			EntFireByHandle(Ent, "SetDamageFilter", "", 0.0, Ent, Ent);
			Ent.SetModel(MODEL_DEFAULT);
		}
		else
		{
			StillInPlay = true;
			Jail =				-1;
			JailRound = 		-1;
			EntFireByHandle(Ent, "AddOutput", "targetname onteam"+team_number.tostring(), 0.0, Ent, Ent);
			EntFireByHandle(Ent, "SetDamageFilter", "filter_team"+team_number.tostring(), 0.0, Ent, Ent);
			if(Ent.IsValid()) Ent.SetModel(PLAYER_MODELS[team_number]);
			
			//pass team inventory from player, then grant it
		}
	}
	
	function ArrayFindFixInventory(ar, val){
		for(local a = 0;a<(ar.len());a+=1)
		{
			if(val.type == ar[a].type){
				return a;
			}
		}
		return -1;
	}
	
	function AddToInventory(index)
	{
		local new_item = INVENTORY_ITEMS[index];
		foreach(value in this.Inventory)
		{
			if(new_item.index == value.index) return;
		}
		local to_delete = ArrayFindFixInventory(Inventory, new_item);
		if(to_delete != -1) Inventory.remove(to_delete);
		Inventory.append(new_item);
		GrantInventory();
	}
	
	function DebugPrintInventory(){
		debugprint("========================");
		debugprint(Name);
		foreach(item in Inventory)
		{
			debugprint(item.weapon_ent_name)
		}
	}
	
	function GrantInventory()
	{
		DoEntFire("common_equip", "use", "<none>", 0.0, Ent,Ent)
		foreach(item in Inventory)
		{	
			DoEntFire(item.weapon_ent_name+"_equip", "use", "<none>", 0.0, Ent,Ent)
		}
	}


	function UpdateEvents()
	{
		/*if(Health < PrevHealth && Alive)
		{
			Events.OnHurt(this);
		}*/
		if(!Ent.IsValid())
		{
			Events.OnDisconnect(this);
			return;
		}
		if(Health == 0 && Alive)
		{
			Alive = false;
			Events.OnKilled(this);
		}
		if(Health > 0 && !(Alive)){
			Alive = true;
			Events.OnRespawn(this);
		}
	}
}

//The array that holds all of the players and manipulates them
class PlayerManager
{
	Players = [];		//All of the players including target players
	
	constructor()
	{	
	}
	
	//create and add a player object out of a player ent
	function Add(ply)
	{
		local tply = Player(ply);
		
		Players.append(tply);
		if(game_controller.game_state != GAME_STATES.ROUND_SETUP) SendToJail(ply);
		return tply;
	}
	
	//Finds a player by their entity. I'm sure there's a better way to index and access these (maybe use their entity index in game?) but I'm an electrical engineer not a computer scientist, and this will never be bigger than 64 anyways
	function FindByHandle(handle)
	{
		foreach(ply in Players)
		{
			if(ply.Ent == handle)
			{
				return ply;
			}
		}
		return null;
	}
	
	//If a player is already registered it returns them, if not it returns false. Pretty much the same thing as findbyhandle
	function CheckPlayerRegistered(handle)
	{
		foreach(ply in Players)
		{
			if(ply.Ent == handle)
			{
				return ply;
			}
		}
		return false;
	}
	
	function RegisterOrGet(handle)
	{
		foreach(ply in Players)
		{
			if(ply.Ent == handle)
			{
				return ply;
			}
		}
		return Add(handle);
	}
	
	function CountPlayersInPlay()
	{
		local players_left = 0;
		foreach(ply in Players)
		{
			if(ply.StillInPlay) players_left += 1;
		}
		return players_left;
	}
	
	function CountTeamsInPlay()
	{
		local teams = {};
		local teams_left = 0;
		foreach(ply in Players)
		{
			local team = ply.Team;
			if(team != null && team != -1 && !(team in teams)){
				teams[team] <- true;
				teams_left += 1;
			}
		}
		
		return teams_left;
	}
	
	function AssignTeams()
	{
		local team = 0;
		foreach(ply in Players)
		{
			if(ply.StillInPlay){
				ply.AssignTeam(team);
				team+=1;
			}
		}
		
	}
	
	function RemovePlayer(ply)
	{
		local find = ArrayFindFix(Players,ply)
		if(find != -1) Players.remove(find);
	}	
	
	//Calls each player update function if they are still connected, and if not it kills all their ents and removes them from the lists. This does not kill passives as they are killed when the player disconnects as per the rules of parenting
	function Update()
	{
		foreach(ply in Players)
		{
			if((ply.Ent).IsValid()){
				ply.Update();
			}
			else{
				Players.remove(ArrayFindFix(Players,ply));
			}
		}
	}
	
	function RunFunctionOnAllPlayers(fun)
	{
		foreach(ply in Players)
		{
			fun(ply);
		}
	}
	
	function RunFunctionOnAllPlayersWithArgs(args, fun)
	{
		foreach(ply in Players)
		{
			fun(ply, args);
		}
	}
	
	function RunFunctionOnPlayer(handle, fun)
	{
		foreach(ply in Players)
		{
			if(ply.Ent == handle)
			{
				fun(ply);
			}
		}
	}
	
	function RunFunctionOnPlayerWithArgs(handle, args, fun)
	{
		foreach(ply in Players)
		{
			if(ply.Ent == handle)
			{
				fun(ply, args);
			}
		}
	}
	
	function GetJailOccupanciesForRound(round, baseoccupancies)
	{
		local occupancies = baseoccupancies;
		foreach(ply in Players)
		{
			if(ply.JailRound == round && ply.Jail != -1)
			{
				if(!(ply.Jail in occupancies)) occupancies[ply.Jail] <- 0;
				occupancies[ply.Jail] += 1;
			}
		}
		return occupancies;
	}

	//debug function used to print out the players 
	function ListPlayers(){
		printl("Player List: ");
		foreach(ply in Players)
		{
			printl(ply.Name);
		}
	}
}