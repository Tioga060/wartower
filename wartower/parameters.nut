//Tioga060

//GAME CONSTANTS
MAX_RANK <- 64;						//Maximum number of players
ROUND_START_TIME  <- 3;				//Time before opening the gate at the start of the round
NUM_ROUNDS <- 3;					//Total number of floors
TELEPORT_BETWEEN_FLOORS <- true;	//debug setting used to teleport players between floors or not

//Dev Settings
CLEANUP_OLD_CRATES <- false;		//debug flag used to clean up crates on floors that have already been finished
CRATE_WIDTH <- 20;					//Width of the crate, keeps crates within crate spawns
CRATE_SEARCH_MAX <- 2000;			//Number of cratespawners to search for

//Gameplay Parameters
MAX_TEAMS <- 8;								//Number of players to survive round 1
TEAMS_ALIVE_PER_FLOOR <- [MAX_TEAMS,2,1];	//Number of players to pass each floor
PLAYERS_PER_CELL <- [4,4,4,100];			//Players to put in each cell for each round, mapped as: [floor0,floor1,floor2, etc]
GAS_DELAYS <- [5.0,5.0,5.0,5.0];			//Time to delay before enabling the trigger_hurt, mapped as [floor0, floor1, floor2, etc]


//Loaders
soundDict <-
{
	bell="ambient\\de_overpass_trainbell.wav"
};

PLAYER_MODELS <- 
[
	"models/player/ctm_fbi.mdl",
	"models/player/tm_pirate.mdl",
	"models/player/tm_balkan_varianta.mdl",
	"models/player/tm_professional.mdl",
	"models/player/ctm_gign.mdl",
	"models/player/ctm_gsg9.mdl",
	"models/player/ctm_sas.mdl",
	"models/player/tm_anarchist.mdl",
	
	"models/player/tm_leet_varianta.mdl",
	
	
	"models/player/tm_separatist.mdl"
];

MODEL_DEFAULT <- "models/player/tm_phoenix.mdl";

enum GAME_STATES {
  ROUND_SETUP,
  IN_ROUND,
  FINISHED,
  DONE
}

enum INVENTORY_TYPE {
	PRIMARY,
	SECONDARY,
	SPELL,
	GRENADE,
	HP
}

enum CRATE_TYPE {
	POWER,
	TEAM,
	UTILITY,
	HP
}

//Inventory weapons
//Any added must have an index 1 greater than the previous
//The index for each should be the same as its position in the array
INVENTORY_ITEMS <- [
	{weapon_ent_name="weapon_ump45" 		weapon_name = "UMP" 			index=0		type=INVENTORY_TYPE.PRIMARY		duration=2		model="models/weapons/v_smg_ump45.mdl"},
	{weapon_ent_name="weapon_sawedoff" 		weapon_name = "Shotgun" 		index=1		type=INVENTORY_TYPE.PRIMARY		duration=2		model="models/weapons/v_shot_sawedoff.mdl"},
	{weapon_ent_name="weapon_revolver" 		weapon_name = "Revolver" 		index=2		type=INVENTORY_TYPE.SECONDARY	duration=1		model="models/weapons/v_pist_revolver.mdl"},
	{weapon_ent_name="weapon_ak47" 			weapon_name = "AK-47"	 		index=3		type=INVENTORY_TYPE.PRIMARY		duration=4		model="models/weapons/v_rif_ak47.mdl"},
	{weapon_ent_name="weapon_smokegrenade" 	weapon_name = "Smoke Grenade"	index=4		type=INVENTORY_TYPE.GRENADE		duration=1		model="models/weapons/v_eq_smokegrenade.mdl"},
	{weapon_ent_name="weapon_healthshot"	weapon_name = "Health Pack"		index=5		type=INVENTORY_TYPE.HP			duration=1		model="models/weapons/v_healthshot.mdl"},
	{weapon_ent_name="weapon_awp"			weapon_name = "AWP"				index=6		type=INVENTORY_TYPE.PRIMARY		duration=6		model="models/weapons/v_snip_awp.mdl"}
]

//Weapons for each round
ROUND_WEAPON_LIST <- [
	[	[0],				[1]									],	//Round 0 [[type 1 weapons list], [type2], [type3], [etc]]
	[	[2],				[3,5],						[4],					[6]],	//Round 1
	[	[1],				[3],						[6],	],	//Round 2
	[	[3],				[1]									]	//Round 3
]


/*List of changed CVARS:
mp_weapons_allow_map_placed 						0;
mp_display_kill_assists 							1;
mp_respawn_on_death_t 								1;
mp_respawn_on_death_ct 								1;
weapon_auto_cleanup_time 							0.001;
mp_death_drop_gun 									0;
sv_infinite_ammo 									1;
sv_airaccelerate 									150;
mp_solid_teammates 									0;
mp_respawnwavetime_ct 								1;
mp_respawnwavetime_t 								1;
mp_use_respawn_waves 								1;
mp_autoteambalance 										0;
mp_limitteams										 100;
sv_visiblemaxplayers 									64;
*/
