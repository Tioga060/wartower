//Tioga060

::PlyManager <- null;

function OnPostSpawn()
{
	DoIncludeScript("wartower/util.nut",null);	
	DoIncludeScript("wartower/parameters.nut",null);
	DoIncludeScript("wartower/player.nut",null);
	
	DoIncludeScript("IOUtil.nut",null);
	debugprint("=========================== NEW ROUND ================================");
	PlyManager = PlayerManager();
	foreach(val in soundDict){
		self.PrecacheScriptSound(val);
	}
	foreach(model in PLAYER_MODELS){
		self.PrecacheModel(model);
	}
	self.PrecacheModel(MODEL_DEFAULT);
}

class GameController
{
	spawn_crates_enabled = true;
	crate_spawner = null;
	crate_template = null;
	equip_spawner = null;
	equip_template = null;
	name_spawner = null;
	name_template = null;
	
	crate_locations = {};
	jail_locations = {};
	jail_counts = {};
	jail_opens = {};
	current_round = 0;
	current_cell = 0;
	current_cell_round = 1;
	
	game_state = GAME_STATES.ROUND_SETUP;
	game_latest_state_change = Time();
	latest_time_print = 0;
	latest_player_count = -1;
	state_just_changed = true;
	
	constructor(EntityGroup)
	{
		crate_spawner = EntityGroup[0];
		crate_template = EntityGroup[1];
		
		equip_spawner = EntityGroup[2];
		equip_template = EntityGroup[3];
		
		name_spawner = EntityGroup[4];
		name_template = EntityGroup[5];
	
		
		current_cell = 0;
		current_cell_round = 1;
		
		FindCrateSpawnCoordinates();
		FindCells();
		CreateWeaponSpawners();
		CreateTeamFilters();
		game_latest_state_change = Time();
		
	}
	
	function CreateWeaponSpawners(){
		local i = 0.0;
		foreach(weapon in INVENTORY_ITEMS){
			
			EntFireByHandle(equip_template, "RunScriptCode", "SetWeapon("+weapon.index+")", i, equip_template, equip_template);
			EntFireByHandle(equip_spawner, "RunScriptCode", "CallSpawnEquip()", i, equip_spawner, equip_spawner);
			
			i+= 0.01;
		}
	}
	
	function OpenJail(jail_number)
	{
		jail_opens[current_round][jail_number] = true;
		local cell = jail_locations[current_round][jail_number];
		EntFireByHandle(cell.ent, "Disable", "<none>", 0.0, cell.ent, cell.ent);
	}
	
	function SpawnEquip(){
		equip_spawner.SpawnEntityAtLocation(equip_spawner.GetOrigin(), Vector(0,0,0));
	}
	
	function CreateTeamFilters(){
		local delay = 0.0;
		for(local team = 0; team < MAX_TEAMS; team+=1){
			
			EntFireByHandle(name_template, "RunScriptCode", "SetTeam("+team.tostring()+")", delay*team, name_template, name_template);
			EntFireByHandle(name_spawner, "RunScriptCode", "CallSpawnFilterName()", delay*team, name_spawner, name_spawner);
		}
	}
	
	function SpawnFilterName(){
		name_spawner.SpawnEntityAtLocation(name_spawner.GetOrigin(), Vector(0,0,0));
	}
	
	function EnableJailOpeners(){
		for(local i = 0; i<NUM_ROUNDS; i++)
		{
			local flag = "Disable";
			if(i == current_round) flag = "Enable";
			DoEntFire(format("jailopener_floor%d", i), flag, "<none>", 0.0, name_spawner, name_spawner);
		}
	}
	
	
	function FindCrateSpawnCoordinates(){
		local i = 0;
		while(i<CRATE_SEARCH_MAX){
			local tofind = format("cratespawn%d",i);
			local bounding_box = Entities.FindByName(null, tofind);
			if(bounding_box == null) 
			{
				i+=1;
				continue;
			}
			local origin = bounding_box.GetOrigin();
			local crate = Crate(bounding_box.GetAngles());
			local bottom_left = origin + bounding_box.GetBoundingMins();
			local top_right = origin + bounding_box.GetBoundingMaxs();
			local xmin = bottom_left.x;
			local ymin = bottom_left.y;
			local xmax = top_right.x;
			local ymax = top_right.y;
			local level = crate.level;
			if(!(level in crate_locations)) crate_locations[level] <- [];
			crate_locations[level].append({
				x0=xmin
				x1=xmax
				y0=ymin
				y1=ymax
				z=bottom_left.z
				area=(xmax-xmin)*(ymax-ymin)
				parameters=crate
			});
			i+=1;
		}
	}
	
	function FindCells(){
		local level = 0;
		local i = 0;
		local hasbroken = false;
		while(true){
			i = 0;
			hasbroken = false;
			while(true){
				local cell = Entities.FindByName(null, format("floor%d_cell%d",level,i));
				if(cell == null) {hasbroken = true; break;}
				EntFireByHandle(cell, "Enable", "<none>", 0.0, cell, cell);
				if(!(level in jail_locations)) jail_locations[level] <- [];
				if(!(level in jail_counts)) jail_counts[level] <- [];
				if(!(level in jail_opens)) jail_opens[level] <- [];
				jail_locations[level].append({
					ent=cell
					origin=cell.GetOrigin()
				});
				jail_counts[level].append(0);
				jail_opens[level].append(false);
				i+=1;
			}
			if(hasbroken && i==0) {
				break;
			}
			level+=1;
		}
	}
	
	function SpawnCratesForFloor(level)
	{
		if(level < crate_locations.len())
		{
			for(local i = 0; i<crate_locations[level].len(); i++)
			{
				SpawnCrateRandom(level,i);
			}
		}
	}
	
	function SpawnCrateRandom(level, area){
		local crate = crate_locations[level][area];
		for(local a = 0; a<crate.parameters.number_to_spawn; a++)
		{
			local x = RandIntBetween(crate.x0+CRATE_WIDTH, crate.x1-CRATE_WIDTH);
			local y = RandIntBetween(crate.y0+CRATE_WIDTH, crate.y1-CRATE_WIDTH);
			local location = Vector(x,y,crate.z);
			crate_template.SetAngles(crate.parameters.level, crate.parameters.crate_type, crate.parameters.number_to_spawn);
			crate_spawner.SpawnEntityAtLocation(location,Vector(0,0,0));
		}
	}

	
	function ReassignJails(round)
	{
		PlyManager.RunFunctionOnAllPlayersWithArgs(round, function(player_entry, round){
			if(player_entry.JailRound == round) game_controller.AssignJail(player_entry);
		});
	}
	
	
	function FindOpenJail(round)
	{
		local baseoccupancies = {};
		for(local i = 0; i<jail_opens[round].len(); i+=1)
		{
			if(!jail_opens[round][i]) baseoccupancies[i] <- 0;
		}
		local occupancies = PlyManager.GetJailOccupanciesForRound(round, baseoccupancies);
		local todelete = [];
		foreach(key, value in occupancies)
		{
			if(value > PLAYERS_PER_CELL[round]) todelete.append(key);
		}
		foreach(deleteme in todelete)
		{
			occupancies.rawdelete(deleteme);
		}
		if(occupancies.len() <= 0) return -1;
		return MinIndex(occupancies);
	}
	
	function AssignJail(player_entry)
	{
		if(current_cell_round >= jail_locations.len()) {
			debugprint("ALL JAILS FULL!"); 
			return false;
		}
		local jail_to_fill = FindOpenJail(current_cell_round);
		if(jail_to_fill == -1)
		{
			current_cell_round += 1;
			AssignJail(player_entry);
			return false;
		}
		local jailto = jail_locations[current_cell_round][jail_to_fill];
		
		player_entry.Ent.SetOrigin(jailto.origin);
		player_entry.Jail = jail_to_fill;
		player_entry.JailRound = current_cell_round;
		EntFireByHandle(player_entry.Ent, "SetDamageFilter", "dmg_invuln", 0.0, player_entry.Ent, player_entry.Ent);
	}
	
	function TeleportPlayers()
	{
		local latest_search = 0;
		local assignments = {};
		foreach(player_entry in PlyManager.Players)
		{
			if(player_entry.Ent.IsValid() && "Team" in player_entry && player_entry.Team != null && player_entry.Team != -1)
			{
				if(!(player_entry.Team in assignments)){
					assignments[player_entry.Team] <- latest_search;
					latest_search += 1;
				}
				local search = format("floor%d_destination%d", current_round, assignments[player_entry.Team])
				local destination = Entities.FindByName(null, search);
				local angles = destination.GetAngles();
				player_entry.Ent.SetOrigin(destination.GetOrigin());
				player_entry.Ent.SetAngles(angles.x, angles.y, angles.z);
				player_entry.Ent.SetVelocity(Vector(0,0,0));
				
			}
		}
	}
	
	function Process_Round_Start()
	{
		if(state_just_changed){
			state_just_changed = false;
			current_cell = 0;
		}
		
		local time_until_round_start = ROUND_START_TIME - (Time() - game_latest_state_change);
		
		if(time_until_round_start <= 0) {
			PlyManager.RunFunctionOnAllPlayers(function(player_entry){
				player_entry.StillInPlay = true;
				EntFireByHandle(player_entry.Ent, "SetDamageFilter", "<none>", 0.0, player_entry.Ent, player_entry.Ent);
			});
			crate_spawner.EmitSound(soundDict.bell);
			DoEntFire("start_door", "Open", "<none>", 0.0, crate_spawner, crate_spawner);
			state_just_changed = true;
			game_state = GAME_STATES.IN_ROUND;
			game_latest_state_change = Time();
		}
		if(time_until_round_start.tointeger() != latest_time_print)
		{
			ScriptPrintMessageChatAll(format("Round will begin in %d seconds", 1 + time_until_round_start));
			latest_time_print = time_until_round_start.tointeger();
		}

	}
	
	function Process_Floor0()
	{
		if(state_just_changed){
			debugprint("Starting round 0");
			SystemChatPrint(format(" Starting round %s%d",ChatColors.orange, current_round+1));
			current_cell_round = 1;
			current_cell = 0;
			SpawnCratesForFloor(current_round)
			EnableJailOpeners()
			state_just_changed = false;
			
		}
		local players_left = PlyManager.CountPlayersInPlay();
		if(latest_player_count != players_left)
		{
			SystemChatPrint(format(" %s%d%s/%s%d %splayers left",ChatColors.lightred, players_left, ChatColors.white, ChatColors.red, TEAMS_ALIVE_PER_FLOOR[current_round], ChatColors.white));
			latest_player_count = players_left;
		}
		if(players_left <= MAX_TEAMS)
		{
			//TODO round is over
			PlyManager.AssignTeams();
			DoEntFire(format("zone%d_exit", current_round), "Open", "<none>", 0.0, crate_spawner, crate_spawner);
			DoEntFire(format("zone%d_gas", current_round), "Enable", "<none>", GAS_DELAYS[current_round], crate_spawner, crate_spawner);
			if(!TELEPORT_BETWEEN_FLOORS)
			{
				ScriptPrintMessageChatAll(format("Releasing gas on floor %d in %d seconds", current_round+1, GAS_DELAYS[current_round].tointeger()));
			}
			//TODO: release gas
			ReassignJails(current_round);
			current_round += 1;
			
			state_just_changed = true;
			game_state = GAME_STATES.IN_ROUND;
			game_latest_state_change = Time();
			return false;
		}
	}
	
	function Process_Floor()
	{
		if(state_just_changed){
			
			
			if(current_round >= NUM_ROUNDS){
				debugprint(" Game has finished!");
				game_state = GAME_STATES.FINISHED;
				state_just_changed = true;
				return;
			}
			debugprint(format("Starting round %d",current_round));
			SystemChatPrint(format(" Starting round %s%d",ChatColors.orange, current_round+1));
			if(TELEPORT_BETWEEN_FLOORS)
			{
				TeleportPlayers();
			}
			current_cell_round = max(current_round+1, current_cell_round);
			if(current_cell_round <= current_round+1) current_cell = 0;
			SpawnCratesForFloor(current_round)
			EnableJailOpeners()
			state_just_changed = false;

		}
		
		local players_left = PlyManager.CountTeamsInPlay();
		if(latest_player_count != players_left)
		{
			SystemChatPrint(format(" %s%d%s/%s%d %steams left",ChatColors.lightred, players_left, ChatColors.white, ChatColors.red, TEAMS_ALIVE_PER_FLOOR[current_round], ChatColors.white));
			latest_player_count = players_left;
		}
		
		if(players_left <= TEAMS_ALIVE_PER_FLOOR[current_round])
		{
			//TODO round is over
			state_just_changed = true;
			ReassignJails(current_round);
			DoEntFire(format("zone%d_exit", current_round), "Open", "<none>", 0.0, crate_spawner, crate_spawner);
			DoEntFire(format("zone%d_gas", current_round), "Enable", "<none>", GAS_DELAYS[current_round], crate_spawner, crate_spawner);
			if(!TELEPORT_BETWEEN_FLOORS)
			{
				ScriptPrintMessageChatAll(format("Releasing gas on floor %d in %d seconds", current_round+1, GAS_DELAYS[current_round].tointeger()));
			}
			current_round += 1;
			game_state = GAME_STATES.IN_ROUND;
			game_latest_state_change = Time();
			
			return false;
		}	
	}

	function Process_Game_End()
	{
		if(state_just_changed)
		{
			SystemChatPrint("Game has finished!");
			DoEntFire("round_ender","EndRound_TerroristsWin", "<none>", 0.0, crate_spawner, crate_spawner);
			state_just_changed = false;
		}
		
	}
	
	function Think(){
		if(game_state == GAME_STATES.ROUND_SETUP){
			Process_Round_Start();
		}
		else if(game_state == GAME_STATES.IN_ROUND)
		{
			if(current_round == 0) Process_Floor0();
			else Process_Floor();
		}
		else if(game_state ==GAME_STATES.FINISHED)
		{
			Process_Game_End();
		}
	}
}

::game_controller <- GameController(EntityGroup);
function Think()
{
	game_controller.Think();
	PlyManager.Update();
}

//=======================================================================//
//=========================Game State Functions==========================//
//=======================================================================//
::SetInZone <- function(ply, value)
{
	PlyManager.RunFunctionOnPlayerWithArgs(ply, value, function(player_entry, value){
		player_entry.InTeleportZone = value;
	});
}

::SendToJail <- function(ply)
{
	PlyManager.RunFunctionOnPlayer(ply, function(player_entry){
		if(!player_entry.StillInPlay)
		{
			game_controller.AssignJail(player_entry);
		}
	});

	
}

::OpenJail <- function(ply, jail_number){
	local player = PlyManager.FindByHandle(ply);
	local args = {
		team_number = player.Team
		jail_number = jail_number
	
	}
	
	PlyManager.RunFunctionOnAllPlayersWithArgs(args, function(player_entry, args)
	{
		if(player_entry.Jail == args.jail_number && player_entry.JailRound == game_controller.current_round)
			player_entry.AssignTeam(args.team_number);
	});
	game_controller.OpenJail(jail_number);
}

//=======================================================================//
//=========================Inventory Functions===========================//
//=======================================================================//
::AddToInventory <- function(index, ply)
{
	PlyManager.RunFunctionOnPlayerWithArgs(ply, index, function(player_entry, index)
	{
		player_entry.AddToInventory(index);
	});
}

::CallSpawnEquip <- function()
{
	game_controller.SpawnEquip();
}

::CallSpawnFilterName <- function()
{
	game_controller.SpawnFilterName();
}

//=======================================================================//
//========================Player Initialization==========================//
//=======================================================================//

::RegisterPlayer <- function(ply){
	PlyManager.RegisterOrGet(ply);
}

