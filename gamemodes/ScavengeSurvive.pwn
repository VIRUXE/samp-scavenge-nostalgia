/*==============================================================================


	Southclaw's Scavenge and Survive

		Big thanks to Onfire559/Adam for the initial concept and developing
		the idea a lot long ago with some very productive discussions!
		Recently influenced by Minecraft and DayZ, credits to the creators of
		those games and their fundamental mechanics and concepts.

		Copyright (C) 2016 Barnaby "Southclaw" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/

#include <a_samp>

/*==============================================================================

	Library Predefinitions

==============================================================================*/

#define BUILD_MINIMAL // Constroi o servidor com menos recursos. Para que o carregamento seja mais rapido.

native IsValidVehicle(vehicleid);
native gpci(playerid, serial[], len);
native SendClientCheck(playerid, actionid, memaddr, memOffset, bytesCount);
native WP_Hash(buffer[], len, const str[]); // By Y_Less:
forward Float:zip_absoluteangle(Float:angle);
forward Float:zip_GetDistancePointLine(Float:line_x,Float:line_y,Float:line_z,Float:vector_x,Float:vector_y,Float:vector_z,Float:point_x,Float:point_y,Float:point_z);
forward Float:zip_GetAngleToPoint(Float:fPointX, Float:fPointY, Float:fDestX, Float:fDestY);
forward Float:GetVehicleFuel(vehicleid);
forward Float:GetPlayerHP(playerid);
forward Float:GetPlayerAP(playerid);
forward Float:GetPlayerFP(playerid);
forward Float:GetPlayerTotalVelocity(playerid);
forward ItemType:GetItemWeaponItemAmmoItem(itemid);
forward Float:GetPlayerBleedRate(playerid);
forward GetPlayerBedPos(playerid, &Float:x, &Float:y, &Float:z);

#define _DEBUG							0 // YSI
#define DB_DEBUG						false // SQLitei
#define DB_MAX_STATEMENTS				(128) // SQLitei
#define DB_DEBUG_BACKTRACE_NOTICE		(true) // SQLitei
#define DB_DEBUG_BACKTRACE_WARNING		(true) // SQLitei
#define DB_DEBUG_BACKTRACE_ERROR		(true) // SQLitei
#define ITER_NONE						(cellmin) // Temporary fix for https://github.com/Misiur/YSI-Includes/issues/109
#define STRLIB_RETURN_SIZE				(256) // 256 strlib
#define MODIO_DEBUG						(0) // modio
#define MODIO_FILE_STRUCTURE_VERSION	(20) // modio
#define MODIO_SCRIPT_EXIT_FIX			(1) // modio
#define BTN_TELEPORT_FREEZE_TIME		(3000) // SIF/Button
#define INV_MAX_SLOTS					(8) // SIF/Inventory
#define ITM_ARR_ARRAY_SIZE_PROTECT		(false) // SIF/extensions/ItemArrayData
#define ITM_MAX_TYPES					(ItemType:324) // SIF/Item
#define ITM_MAX_NAME					(28) // SIF/Item
#define ITM_MAX_TEXT					(81) // SIF/Item
#define ITM_DROP_ON_DEATH				(false) // SIF/Item
#define MAX_SKINS                       (312)

#if defined BUILD_MINIMAL

	#define BTN_MAX							(4096) // SIF/Button
	#define ITM_MAX							(4096) // SIF/Item
	#define CNT_MAX_SLOTS					(10)
	#define MAX_MODIO_STACK_SIZE			(1024)
	#define MAX_MODIO_SESSION				(2)

#else

	#define BTN_MAX							(32768) // SIF/Button
	#define ITM_MAX							(32768) // SIF/Item
	#define CNT_MAX_SLOTS					(80)
	#define MAX_MODIO_SESSION				(2048) // modio

#endif

#define ls(%0,%1) GetLanguageString(GetPlayerLanguage(%0), %1)

/*==============================================================================

	Guaranteed first call

	OnGameModeInit_Setup is called before ANYTHING else, the purpose of this is
	to prepare various internal and external systems that may need to be ready
	for other modules to use their functionality. This function isn't hooked.

	OnScriptInit (from YSI) is then called through modules which is used to
	prepare dependencies such as databases, folders and register debuggers.

	OnGameModeInit is then finally called throughout modules and starts inside
	the "Server/Init.pwn" module (very important) so itemtypes and other object
	types can be defined. This callback is used throughout other scripts as a
	means for declaring entities with relevant data.

==============================================================================*/

new gServerLoadTime_Start, gServerLoadTime;

public OnGameModeInit()
{
	gServerLoadTime_Start = GetTickCount();

    UsePlayerPedAnims();
    DisableInteriorEnterExits();
    SetNameTagDrawDistance(0.0);
    ShowNameTags(0);
    
	print("[OnGameModeInit] Initialising 'Main'...");

	OnGameModeInit_Setup();


	#if defined main_OnGameModeInit
		return main_OnGameModeInit();
	#else
		return 1;
	#endif
}
#if defined _ALS_OnGameModeInit
	#undef OnGameModeInit
#else
	#define _ALS_OnGameModeInit
#endif
#define OnGameModeInit main_OnGameModeInit
#if defined main_OnGameModeInit
	forward main_OnGameModeInit();
#endif

/*==============================================================================

	Libraries and respective links to their release pages

==============================================================================*/
#include <crashdetect>				// By Zeex:					https://github.com/Zeex/samp-plugin-crashdetect
#include <sscanf2>					// By Y_Less:				https://github.com/maddinat0r/sscanf
#include <YSI\y_timers>             // By Y_Less:			    https://github.com/Misiur/YSI-Includes
#include <YSI\y_hooks>              // By Y_Less:				https://github.com/Misiur/YSI-Includes
#include <YSI\y_iterate>            // By Y_Less:				https://github.com/Misiur/YSI-Includes
#include <ColAndreas>               // By Pottus:               https://github.com/Pottus/ColAndreas
#include <streamer>					// By Incognito:			https://github.com/samp-incognito/samp-streamer-plugin
#include <sqlitei>					// By Slice, v0.9.7:		https://github.com/oscar-broman/sqlitei
#include <formatex>					// By Slice:				http://forum.sa-mp.com/showthread.php?t=313488
#include <strlib>					// By Slice:				https://github.com/oscar-broman/strlib
#include <md-sort>					// By Slice:				https://github.com/oscar-broman/md-sort
#include <CTime>					// By RyDeR:				https://github.com/Southclaws/samp-ctime
#include <easyDialog>				// By Emmet_:				https://github.com/Awsomedude/easyDialog
#include <progress2>				// By Toribio/Southclaw:	https://github.com/Southclaws/progress2
#include <FileManager>				// By JaTochNietDan, 1.5:	https://github.com/JaTochNietDan/SA-MP-FileManager
#include <SimpleINI>				// By Southclaw:   			https://github.com/Southclaws/SimpleINI
#include <modio>					// By Southclaw:			https://github.com/Southclaws/modio
#include <SIF>						// By Southclaw:			https://github.com/Southclaws/SIF
#include <WeaponData>				// By Southclaw:   			https://github.com/Southclaws/AdvancedWeaponData
#include <Line>						// By Southclaw:			https://github.com/Southclaws/Line
#include <Zipline>					// By Southclaw:			https://github.com/Southclaws/Zipline
#include <Ladder>					// By Southclaw:			https://github.com/Southclaws/Ladder
#include <Pawn.RakNet>              // By urShadow:             https://github.com/urShadow/Pawn.RakNet
#include <optud>             		// By BrunoBM16:          	https://github.com/Jelly23/OnPlayerTurnUpsideDown
#include <BustAim>             		// By YashasSamaga:         https://github.com/YashasSamaga/BustAim-AntiAimbfot
#include <attachment-fix>           // By BrunoBM16:            https://github.com/Jelly23/Proper-attachments-fix
#include <dini2>                    // By Gammix:               https://github.com/Agneese-Saini/SA-MP/blob/master/pawno/include/dini2.inc
#include <player_geolocation>       // By Twixxx:               https://forum.sa-mp.com/showthread.php?t=658087
#include <json>						// By Southclaw:			https://github.com/Southclaws/pawn-json/releases/tag/1.4.1
#include <requests>					// By Southclaw:			https://github.com/Southclaws/pawn-requests/releases/tag/0.10.0

/*==============================================================================

	Definitions

==============================================================================*/

// Limits
#define MAX_MOTD_LEN				(128)
#define MAX_WEBSITE_NAME			(64)
#define MAX_RULE					(24)
#define MAX_RULE_LEN				(128)
#define MAX_STAFF					(24)
#define MAX_STAFF_LEN				(24)
#define MAX_PLAYER_FILE				(MAX_PLAYER_NAME+16)
#define MAX_ADMIN					(48)
#define MAX_PASSWORD_LEN			(129)
#define MAX_GPCI_LEN				(41)
#define MAX_HOST_LEN				(256)


// Directories
#define DIRECTORY_SCRIPTFILES		"./scriptfiles/"
#define DIRECTORY_MAIN				"data/"

// Genders
#define GENDER_MALE					(0)
#define GENDER_FEMALE				(1)

// Files
#define ACCOUNT_DATABASE			DIRECTORY_MAIN"accounts.db"
#define WORLD_DATABASE				DIRECTORY_MAIN"world.db"


// Macros
#define CMD:%1(%2)					forward cmd_%1(%2);\
									public cmd_%1(%2)

#define ACMD:%1[%2](%3)				forward acmd_%1_%2(%3);\
									public acmd_%1_%2(%3)

#define SCMD:%1(%2)					forward scmd_%1(%2);\
									public scmd_%1(%2)

#define HOLDING(%0)					((newkeys & (%0)) == (%0))
#define RELEASED(%0)				(((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))
#define PRESSED(%0)					(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))


// Colours

#define LBLUE						0x1589FFFF
#define LORANGE						0xFF8A14FF

#define YELLOW						0xFFFF00FF
#define RED							0xE85454FF
#define GREEN						0x33AA33FF
#define BLUE						0x33CCFFFF
#define ORANGE						0xFFAA00FF
#define GREY						0xAFAFAFFF
#define PINK						0xFFC0CBFF
#define NAVY						0x000080FF
#define GOLD						0xB8860BFF
#define LGREEN						0x00FD4DFF
#define TEAL						0x008080FF
#define BROWN						0xA52A2AFF
#define AQUA						0xF0F8FFFF
#define BLACK						0x000000FF
#define WHITE						0xFFFFFFFF
#define CHAT_LOCAL					0xADABD1FF
#define CHAT_CLAN					0x00FF00FF


// Embedding Colours

#define CL_BLUE						"{1589FF}"
#define CL_ORANGE					"{FF8A14}"

#define C_YELLOW					"{FFFF00}"
#define C_RED						"{E85454}"
#define C_GREEN						"{33AA33}"
#define C_BLUE						"{33CCFF}"
#define C_ORANGE					"{FFAA00}"
#define C_GREY						"{AFAFAF}"
#define C_PINK						"{FFC0CB}"
#define C_NAVY						"{000080}"
#define C_GOLD						"{B8860B}"
#define C_LGREEN					"{00FD4D}"
#define C_TEAL						"{008080}"
#define C_BROWN						"{DEB887}"
#define C_AQUA						"{F0F8FF}"
#define C_BLACK						"{000000}"
#define C_WHITE						"{FFFFFF}"
#define C_SPECIAL					"{0025AA}"


// Body parts
#define BODY_PART_TORSO				(3)
#define BODY_PART_GROIN				(4)
#define BODY_PART_LEFT_ARM			(5)
#define BODY_PART_RIGHT_ARM			(6)
#define BODY_PART_LEFT_LEG			(7)
#define BODY_PART_RIGHT_LEG			(8)
#define BODY_PART_HEAD				(9)

// Key text
#define KEYTEXT_INTERACT			"~k~~VEHICLE_ENTER_EXIT~"
#define KEYTEXT_RELOAD				"~k~~PED_ANSWER_PHONE~"
#define KEYTEXT_PUT_AWAY			"~k~~CONVERSATION_YES~"
#define KEYTEXT_DROP_ITEM			"~k~~CONVERSATION_NO~"
#define KEYTEXT_INVENTORY			"~k~~GROUP_CONTROL_BWD~"
#define KEYTEXT_ENGINE				"~k~~CONVERSATION_YES~"
#define KEYTEXT_LIGHTS				"~k~~CONVERSATION_NO~"
#define KEYTEXT_DOORS				"~k~~TOGGLE_SUBMISSIONS~"

// Attachment slots
enum
{
	ATTACHSLOT_ITEM,		// 0 - Same as SIF/Item
	ATTACHSLOT_BAG,			// 1 - Bag on back
	ATTACHSLOT_HOLSTER,		// 2 - Item holstering
	ATTACHSLOT_HAT,			// 3 - Head-wear slot
	ATTACHSLOT_FACE,		// 4 - Face-wear slot
	ATTACHSLOT_BLOOD,		// 5 - Bleeding particle effect
	ATTACHSLOT_ARMOUR		// 6 - Armour model slot
}


/*==============================================================================

	Global values

==============================================================================*/


new
bool:	gServerInitialising = true,
		gServerInitialiseTick,
bool:	gServerRestarting = false,
		gServerMaxUptime,
		gServerUptime,
		gGlobalDebugLevel;

// DATABASES
new
DB:		gAccounts;

// GLOBAL SERVER SETTINGS (Todo: modularise)
new
		// player
		gMessageOfTheDay[MAX_MOTD_LEN],
		gWebsiteURL[MAX_WEBSITE_NAME],
		gRuleList[MAX_RULE][MAX_RULE_LEN],
		gStaffList[MAX_STAFF][MAX_STAFF_LEN],

		// server
bool:   gCombatLogWindow,
		gLoginFreezeTime,
		gMaxTaboutTime,
		gPingLimit;

// INTERNAL
new
		gBigString[MAX_PLAYERS][4096],
		gTotalStaff;

new stock
		GLOBAL_DEBUG = -1;

// pawn-requestss
new RequestsClient:client;


/*==============================================================================

	Gamemode Scripts

==============================================================================*/


// API Pre
#tryinclude "sss/extensions/ext_pre.pwn"

// UTILITIES
#include "sss/utils/logging.pwn"
#include "sss/utils/math.pwn"
#include "sss/utils/misc.pwn"
#include "sss/utils/time.pwn"
#include "sss/utils/camera.pwn"
#include "sss/utils/message.pwn"
#include "sss/utils/vehicle.pwn"
#include "sss/utils/vehicle-data.pwn"
#include "sss/utils/vehicle-parts.pwn"
#include "sss/utils/zones.pwn"
#include "sss/utils/player.pwn"
#include "sss/utils/object.pwn"
#include "sss/utils/tickcountfix.pwn"
#include "sss/utils/string.pwn"
#include "sss/utils/dialog-pages.pwn"
#include "sss/utils/item.pwn"
#include "sss/utils/headoffsets.pwn"

// SERVER CORE
#include "sss/core/server/settings.pwn"
#include "sss/core/server/text-tags.pwn"
#include "sss/core/server/weather.pwn"
//#include "sss/core/server/save-block.pwn"
//#include "sss/core/server/info-message.pwn"
#include "sss/core/server/language.pwn"
#include "sss/core/server/anti-cheat.pwn"
//#include "sss/core/player/language.pwn"
#include "sss/core/player/frase.pwn"
#include "sss/core/player/ped.pwn"

/*
	PARENT SYSTEMS
	Modules that declare setup functions and constants used throughout.
*/

#include "sss/core/vehicle/vehicle-type.pwn"
//#include "sss/core/vehicle/carmour.pwn" ///////////////////////////
#include "sss/core/vehicle/lock.pwn"
#include "sss/core/vehicle/core.pwn"
#include "sss/core/player/core.pwn"
#include "sss/core/player/save-load.pwn"
#include "sss/core/admin/core.pwn"
#include "sss/core/char/holster.pwn"
#include "sss/core/weapon/ammunition.pwn"
#include "sss/core/weapon/core.pwn"
#include "sss/core/weapon/damage-core.pwn"
#include "sss/core/ui/hold-action.pwn"
#include "sss/core/item/liquid.pwn"
#include "sss/core/item/liquid-container.pwn"
//#include "sss/core/world/tree.pwn"
#include "sss/core/world/explosive.pwn"
#include "sss/core/world/craft-construct.pwn"
#include "sss/core/world/loot-loader.pwn"

/*
	MODULE INITIALISATION CALLS
	Calls module constructors to set up entity types.
*/

#include "sss/core/server/init.pwn"

/*
	CHILD SYSTEMS
	Modules that do not declare anything globally accessible besides interfaces.
*/

#include "sss/core/player/vip.pwn" // By Kolorado

// VEHICLE
#include "sss/core/vehicle/player-vehicle.pwn"
#include "sss/core/vehicle/loot-vehicle.pwn"
#include "sss/core/vehicle/interact.pwn"
#include "sss/core/vehicle/trunk.pwn"
#include "sss/core/vehicle/repair.pwn"
#include "sss/core/vehicle/lock-break.pwn"
#include "sss/core/vehicle/locksmith.pwn"
#include "sss/core/vehicle/anti-ninja.pwn"
#include "sss/core/vehicle/bike-collision.pwn"
#include "sss/core/vehicle/trailer.pwn"
#include "sss/core/vehicle/spawn.pwn"

// PLAYER INTERNAL SCRIPTS
#include "sss/core/player/accounts.pwn"
#include "sss/core/player/aliases.pwn"
#include "sss/core/player/ipv4-log.pwn"
#include "sss/core/player/gpci-log.pwn"
//#include "sss/core/player/gpci-whitelist.pwn"
#include "sss/core/player/brightness.pwn"
#include "sss/core/player/spawn.pwn"
#include "sss/core/player/PM.pwn"
#include "sss/core/player/death.pwn"
#include "sss/core/player/tutorial.pwn"
//#include "sss/core/player/welcome-message.pwn"
#include "sss/core/player/chat.pwn"
#include "sss/core/player/cmd-process.pwn"
#include "sss/core/player/commands.pwn"
#include "sss/core/player/afk-check.pwn"
#include "sss/core/player/alt-tab-check.pwn"
#include "sss/core/player/disallow-actions.pwn"
//#include "sss/core/player/whitelist.pwn"
#include "sss/core/player/recipes.pwn"

//#include "sss/core/player/claninventario.pwn" // By Kolorado
#include "sss/core/player/clan.pwn" // By Kolorado
#include "sss/core/player/ini.pwn" // By Kolorado
//#include "sss/core/player/interior.pwn" // By Kolorado
#include "sss/core/player/rank.pwn" // By Kolorado
#include "sss/core/player/animes.pwn" // By Kolorado
#include "sss/core/player/status.pwn" // By Kolorado
#include "sss/core/player/name-tags.pwn"
#include "sss/core/player/TextDraw.pwn"
#include "sss/core/player/TelaLogin.pwn"
#include "sss/core/player/Coins.pwn"
#include "sss/core/world/comerciante.pwn"

// CHARACTER SCRIPTS
#include "sss/core/char/food.pwn"
#include "sss/core/char/drugs.pwn"
#include "sss/core/char/clothes.pwn"
#include "sss/core/char/inventory.pwn"
#include "sss/core/char/animations.pwn"
#include "sss/core/char/knockout.pwn"
#include "sss/core/char/disarm.pwn"
#include "sss/core/char/overheat.pwn"
#include "sss/core/char/infection.pwn"
#include "sss/core/char/backpack.pwn"
#include "sss/core/char/handcuffs.pwn"
#include "sss/core/char/medical.pwn"
//#include "sss/core/char/aim-shout.pwn"
#include "sss/core/char/masks.pwn"
#include "sss/core/char/hats.pwn"
#include "sss/core/char/bleed.pwn"
//#include "sss/core/char/skills.pwn"
#include "sss/core/char/travel-stats.pwn"
//#include "sss/core/char/map.pwn" // By Kolor4dO
//#include "sss/core/char/trash.pwn" // By Kolor4dO

// WEAPON
#include "sss/core/weapon/loot.pwn"
#include "sss/core/weapon/interact.pwn"
#include "sss/core/weapon/damage-firearm.pwn"
#include "sss/core/weapon/damage-melee.pwn"
#include "sss/core/weapon/damage-vehicle.pwn"
#include "sss/core/weapon/damage-explosive.pwn"
#include "sss/core/weapon/damage-world.pwn"
#include "sss/core/weapon/animset.pwn"
#include "sss/core/weapon/misc.pwn"
#include "sss/core/weapon/anti-combat-log.pwn"
#include "sss/core/weapon/tracer.pwn"
#include "sss/core/weapon/hitmark.pwn"

// UI
#include "sss/core/ui/tool-tip.pwn"
#include "sss/core/ui/key-actions.pwn"
#include "sss/core/ui/keypad.pwn"
#include "sss/core/ui/body-preview.pwn"

// WORLD ENTITIES
#include "sss/core/world/fuel.pwn"
#include "sss/core/world/barbecue.pwn"
#include "sss/core/world/defences.pwn"
#include "sss/core/world/gravestone.pwn"
#include "sss/core/world/safebox.pwn"
#include "sss/core/world/tent.pwn"
#include "sss/core/world/campfire.pwn"
#include "sss/core/world/emp.pwn"
#include "sss/core/world/sign.pwn"
#include "sss/core/world/supply-crate.pwn"
#include "sss/core/world/weapons-cache.pwn"
#include "sss/core/world/loot.pwn"
#include "sss/core/world/workbench.pwn"
#include "sss/core/world/machine.pwn"
#include "sss/core/world/scrap-machine.pwn"
#include "sss/core/world/refine-machine.pwn"
//#include "sss/core/world/tree-loader.pwn"
#include "sss/core/world/plot-pole.pwn"
#include "sss/core/world/item-tweak.pwn"
#include "sss/core/world/furniture.pwn"

#include "sss/core/player/map.pwn"

// IO
#include "sss/core/world/item-io.pwn"
#include "sss/core/world/defences-io.pwn"
#include "sss/core/world/sign-io.pwn"
//#include "sss/core/world/craft-io.pwn"
#include "sss/core/world/safebox-io.pwn"
#include "sss/core/world/tent-io.pwn"

// ADMINISTRATION TOOLS
#include "sss/core/admin/report.pwn"
#include "sss/core/admin/report-cmds.pwn"
//#include "sss/core/admin/hack-trap.pwn"
#include "sss/core/admin/hack-detect.pwn"
#include "sss/core/admin/ban.pwn"
#include "sss/core/admin/ban-command.pwn"
#include "sss/core/admin/ban-list.pwn"
#include "sss/core/admin/spectate.pwn"
#include "sss/core/admin/level1.pwn"
#include "sss/core/admin/level2.pwn"
#include "sss/core/admin/level3.pwn"
#include "sss/core/admin/level4.pwn"
#include "sss/core/admin/level5.pwn"
#include "sss/core/admin/bug-report.pwn"
#include "sss/core/admin/mute.pwn"
#include "sss/core/admin/rcon.pwn"
#include "sss/core/admin/freeze.pwn"
#include "sss/core/admin/name-tags.pwn"
#include "sss/core/admin/player-list.pwn"

#include "sss/core/admin/detfield.pwn"
#include "sss/core/admin/detfield-cmds.pwn"
#include "sss/core/admin/detfield-draw.pwn"


// ITEMS
#include "sss/core/item/food.pwn"
#include "sss/core/item/firework.pwn"
#include "sss/core/item/shield.pwn"
#include "sss/core/item/handcuffs.pwn"
#include "sss/core/item/wheel.pwn"
#include "sss/core/item/camouflage.pwn"

// HATS
#include "sss/core/item/hats/HelmArmy.pwn"
#include "sss/core/item/hats/HelmMoto.pwn"
#include "sss/core/item/hats/TruckCap.pwn"
#include "sss/core/item/hats/BoaterHat.pwn"
#include "sss/core/item/hats/fire_hat2.pwn"
#include "sss/core/item/hats/BowlerHat.pwn"
#include "sss/core/item/hats/PoliceCap.pwn"
#include "sss/core/item/hats/TopHat.pwn"
#include "sss/core/item/hats/SwatHelmet.pwn"
#include "sss/core/item/hats/XmasHat.pwn"
#include "sss/core/item/hats/PizzaHat.pwn"
#include "sss/core/item/hats/WitchesHat.pwn"
#include "sss/core/item/hats/PoliceHelm.pwn"
#include "sss/core/item/hats/StrawHat.pwn"
#include "sss/core/item/hats/fire_hat1.pwn"
#include "sss/core/item/hats/headphones04.pwn"
#include "sss/core/item/hats/ArmyHelmet2.pwn"
/*#include "sss/core/item/hats/CowboyHat.pwn"
#include "sss/core/item/hats/CaptainsCap.pwn"
#include "sss/core/item/hats/CapBack5.pwn"
#include "sss/core/item/hats/CapBack4.pwn"
#include "sss/core/item/hats/CapBack3.pwn"
#include "sss/core/item/hats/CapBack2.pwn"
#include "sss/core/item/hats/CapBack1.pwn"*/


// MASKS
#include "sss/core/item/masks/GasMask.pwn"
#include "sss/core/item/masks/BandanaBlue.pwn"
#include "sss/core/item/masks/BandanaPattern.pwn"
#include "sss/core/item/masks/HockeyMask.pwn"
#include "sss/core/item/masks/MaskGreen.pwn"
#include "sss/core/item/masks/MaskRed.pwn"
#include "sss/core/item/masks/BandanaWhite.pwn"
#include "sss/core/item/masks/DiaboMask.pwn"
#include "sss/core/item/masks/BandanaGrey.pwn"
#include "sss/core/item/masks/CluckinBellHat1.pwn"
#include "sss/core/item/masks/Balaclava.pwn"
//#include "sss/core/item/masks/GimpMask1.pwn"
//#include "sss/core/item/masks/ZorroMask.pwn"
//#include "sss/core/item/masks/PussyMask.pwn"

#include "sss/core/item/headlight.pwn"
#include "sss/core/item/pills.pwn"
#include "sss/core/item/dice.pwn"
#include "sss/core/item/armour.pwn"
#include "sss/core/item/injector.pwn"
#include "sss/core/item/parachute.pwn"
#include "sss/core/item/molotov.pwn"
#include "sss/core/item/screwdriver.pwn"
#include "sss/core/item/torso.pwn"
#include "sss/core/item/herpderp.pwn"
#include "sss/core/item/stungun.pwn"
#include "sss/core/item/note.pwn"
#include "sss/core/item/seedbag.pwn"
#include "sss/core/item/plantpot.pwn"
#include "sss/core/item/heartshapedbox.pwn"
#include "sss/core/item/fishingrod.pwn"
#include "sss/core/item/chainsaw.pwn"
#include "sss/core/item/locator.pwn"
#include "sss/core/item/locker.pwn"
#include "sss/core/item/bed.pwn" // By Kolor4dO
#include "sss/core/item/supplydrop.pwn"


// BAGS

#include "sss/core/item/bags/item_Backpack.pwn"
#include "sss/core/item/bags/item_Daypack.pwn"
#include "sss/core/item/bags/item_HeartShapedBox.pwn"
#include "sss/core/item/bags/item_LargeBackpack.pwn"
#include "sss/core/item/bags/item_MediumBag.pwn"
#include "sss/core/item/bags/item_ParaBag.pwn"
#include "sss/core/item/bags/item_Rucksack.pwn"
#include "sss/core/item/bags/item_Satchel.pwn"

// POST-CODE

//#include "sss/core/server/auto-save.pwn"
#tryinclude "sss/extensions/ext_post.pwn"

#include "sss/world/world.pwn"


#if !defined GetMapName
	#error World script MUST have a "GetMapName" function!
#endif

#if !defined GenerateSpawnPoint
	#error World script MUST have a "GenerateSpawnPoint" function!
#endif

static
Text:RestartCount = Text:INVALID_TEXT_DRAW,
Text:RestartCount2 = Text:INVALID_TEXT_DRAW,

Text:ClockRestart = Text:INVALID_TEXT_DRAW,
Text:ClockRestart2 = Text:INVALID_TEXT_DRAW;

main()
{
	log("================================================================================");
	log("    Southclaw's Scavenge and Survive");
	log("        Copyright (C) 2016 Barnaby \"Southclaw\" Keene");
	log("        This program comes with ABSOLUTELY NO WARRANTY; This is free software,");
	log("        and you are welcome to redistribute it under certain conditions.");
	log("        Please see <http://www.gnu.org/copyleft/gpl.html> for details.");
	log("================================================================================");

	gServerInitialising = false;
	gServerInitialiseTick = GetTickCount();
}

/*
	This is called absolutely first before any other call.
*/
OnGameModeInit_Setup()
{
	log("[OnGameModeInit_Setup] Setting up...");

	Streamer_ToggleErrorCallback(true);

	if(!dir_exists(DIRECTORY_SCRIPTFILES))
	{
		log("ERROR: Directory '"DIRECTORY_SCRIPTFILES"' not found. Creating directory.");
		dir_create(DIRECTORY_SCRIPTFILES);
	}

	if(!dir_exists(DIRECTORY_SCRIPTFILES DIRECTORY_MAIN))
	{
		log("ERROR: Directory '"DIRECTORY_SCRIPTFILES DIRECTORY_MAIN"' not found. Creating directory.");
		dir_create(DIRECTORY_SCRIPTFILES DIRECTORY_MAIN);
	}

	gAccounts = db_open_persistent(ACCOUNT_DATABASE);

	LoadSettings();

	SendRconCommand(sprintf("mapname %s", GetMapName()));

	// * Estou preguiçoso hoje, então vou deixar assim mesmo. :D
	new Node:node;
	JSON_GetObject(Settings, "server", node);
	JSON_GetInt(node, "global-debug-level", gGlobalDebugLevel);
	log("[SETTINGS] Global debug level: %d", gGlobalDebugLevel);

	debug_set_level("global", gGlobalDebugLevel);
	
	RestartCount				=TextDrawCreate(18.400001, 433.100067, "Respawn em: ~r~~h~~h~00:00");
	TextDrawBackgroundColor		(RestartCount, 255);
	TextDrawFont				(RestartCount, 2);
	TextDrawLetterSize			(RestartCount, 0.180000, 1.199998);
	TextDrawColor				(RestartCount, -1);
	TextDrawSetOutline			(RestartCount, 1);
	TextDrawSetProportional		(RestartCount, 1);
	
	RestartCount2				=TextDrawCreate(18.400001, 433.100067, "Respawn em: ~y~00:00");
	TextDrawBackgroundColor		(RestartCount2, 255);
	TextDrawFont				(RestartCount2, 2);
	TextDrawLetterSize			(RestartCount2, 0.180000, 1.199998);
	TextDrawColor				(RestartCount2, -1);
	TextDrawSetOutline			(RestartCount2, 1);
	TextDrawSetProportional		(RestartCount2, 1);

	ClockRestart 				= TextDrawCreate(16.000000, 430.000000, "LD_GRAV:timer");
	TextDrawBackgroundColor		(ClockRestart, 255);
	TextDrawFont				(ClockRestart, 4);
	TextDrawLetterSize			(ClockRestart, 0.180000, 1.199998);
	TextDrawColor				(ClockRestart, 0xFF0000FF);
	TextDrawSetOutline			(ClockRestart, 1);
	TextDrawSetProportional		(ClockRestart, 1);
	TextDrawUseBox				(ClockRestart, 1);
	TextDrawBoxColor			(ClockRestart, 255);
	TextDrawTextSize			(ClockRestart, -13.000000, 15.000000);
	TextDrawSetSelectable		(ClockRestart, 0);

	ClockRestart2 				= TextDrawCreate(16.000000, 430.000000, "LD_GRAV:timer");
	TextDrawBackgroundColor		(ClockRestart2, 255);
	TextDrawFont				(ClockRestart2, 4);
	TextDrawLetterSize			(ClockRestart2, 0.180000, 1.199998);
	TextDrawColor				(ClockRestart2, -1);
	TextDrawSetOutline			(ClockRestart2, 1);
	TextDrawSetProportional		(ClockRestart2, 1);
	TextDrawUseBox				(ClockRestart2, 1);
	TextDrawBoxColor			(ClockRestart2, 255);
	TextDrawTextSize			(ClockRestart2, -13.000000, 15.000000);
	TextDrawSetSelectable		(ClockRestart2, 0);
}

public OnGameModeExit()
{
	log("[OnGameModeExit] Shutting down...");
	return 1;
}

public OnScriptExit()
{
	log("[OnScriptExit] Shutting down...");
	return 1;
}

forward SetRestart(seconds);
public SetRestart(seconds)
{
	log("Restarting server in: %ds", seconds);
	gServerUptime = gServerMaxUptime - seconds;
}

RestartGamemode()
{
	printf("\n[RestartGamemode] Initialising gamemode restart...\n");

	foreach(new i : Player) Kick(i);
	
    gServerRestarting = true;
	defer ServerGMX();
}

timer ServerGMX[10000](){
    SendRconCommand("gmx");
}

task RestartUpdate[1000]()
{
	if(gServerMaxUptime > 0)
	{
		if(gServerUptime >= gServerMaxUptime) RestartGamemode();

		new hours, minutes, seconds;

		minutes = (gServerMaxUptime - gServerUptime) / 60;
		seconds = (gServerMaxUptime - gServerUptime) % 60;
		hours   = minutes / 60;
		minutes = minutes % 60;
	
		new str[64];
		format(str, 64, "Respawn em: ~r~~h~~h~ %02d:%02d:%02d", hours, minutes, seconds);
		TextDrawSetString(RestartCount, str);
		
		new str2[64];
		format(str2, 64, "Respawn em: ~y~ %02d:%02d:%02d", hours, minutes, seconds);
		TextDrawSetString(RestartCount2, str2);

		foreach(new i : Player)
		{
			if(IsPlayerHudOn(i) && IsPlayerSpawned(i))
			{
				if(gServerUptime <= gServerMaxUptime - 600)
				{
					TextDrawHideForPlayer(i, RestartCount);
					TextDrawHideForPlayer(i, ClockRestart);

					TextDrawShowForPlayer(i, RestartCount2);
					TextDrawShowForPlayer(i, ClockRestart2);
				}
				
				if(gServerUptime > gServerMaxUptime - 600)
				{
					TextDrawHideForPlayer(i, RestartCount2);
					TextDrawHideForPlayer(i, ClockRestart2);

					TextDrawShowForPlayer(i, RestartCount);
					TextDrawShowForPlayer(i, ClockRestart);
				}
			}
			else
			{
				TextDrawHideForPlayer(i, RestartCount);
				TextDrawHideForPlayer(i, RestartCount2);

				TextDrawHideForPlayer(i, ClockRestart);
				TextDrawHideForPlayer(i, ClockRestart2);
			}
		}
	}
	
	// Avisa os jogadores pelo chat 1 minuto antes de reiniciar o servidor
	if(gServerUptime == gServerMaxUptime - 60) {
		foreach(new i : Player) {
			ChatMsg(i, RED, "");
			ChatMsgLang(i, RED, "RESPAWNWRNTXT");
			ChatMsg(i, RED, "");
		}
	}

	gServerUptime++;
}

DirectoryCheck(directory[])
{
	if(!dir_exists(directory))
	{
		err("Directory '%s' not found. Creating directory.", directory);
		dir_create(directory);
	}
}

DatabaseTableCheck(DB:database, tablename[], expectedcolumns)
{
	new
		query[96],
		DBResult:result,
		dbcolumns;

	format(query, sizeof(query), "pragma table_info(%s)", tablename);
	result = db_query(database, query);

	dbcolumns = db_num_rows(result);

	if(dbcolumns != expectedcolumns)
	{
		err("Table '%s' has %d columns, expected %d:", tablename, dbcolumns, expectedcolumns);
		err("Please verify table structure against column list in script.");

		// Put the server into a loop to stop it so the user can read the message.
		// It won't function correctly with bad databases anyway.
		for(;;){}
	}
}