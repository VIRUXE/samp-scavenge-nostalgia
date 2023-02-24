/*==============================================================================


	Southclaw's Scavenge and Survive

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


#include <YSI\y_hooks>


#define ACCOUNTS_TABLE_PLAYER		"Player"
#define FIELD_PLAYER_NAME			"name"		// 00
#define FIELD_PLAYER_PASS			"pass"		// 01
#define FIELD_PLAYER_IPV4			"ipv4"		// 02
#define FIELD_PLAYER_LANGUAGE		"language"	// 02
#define FIELD_PLAYER_ALIVE			"alive"		// 03
#define FIELD_PLAYER_REGDATE		"regdate"	// 04
#define FIELD_PLAYER_LASTLOG		"lastlog"	// 05
#define FIELD_PLAYER_SPAWNTIME		"spawntime"	// 06
#define FIELD_PLAYER_TOTALSPAWNS	"spawns"	// 07
#define FIELD_PLAYER_WARNINGS		"warnings"	// 08
#define FIELD_PLAYER_GPCI			"gpci"		// 19
#define FIELD_PLAYER_ACTIVE			"active"	// 10

enum
{
	FIELD_ID_PLAYER_NAME,
	FIELD_ID_PLAYER_PASS,
	FIELD_ID_PLAYER_IPV4,
	FIELD_ID_PLAYER_LANGUAGE,
	FIELD_ID_PLAYER_ALIVE,
	FIELD_ID_PLAYER_REGDATE,
	FIELD_ID_PLAYER_LASTLOG,
	FIELD_ID_PLAYER_SPAWNTIME,
	FIELD_ID_PLAYER_TOTALSPAWNS,
	FIELD_ID_PLAYER_WARNINGS,
	FIELD_ID_PLAYER_GPCI,
	FIELD_ID_PLAYER_ACTIVE
}


static
				acc_LoginAttempts[MAX_PLAYERS],
				acc_IsNewPlayer[MAX_PLAYERS],
				acc_HasAccount[MAX_PLAYERS],
				acc_LoggedIn[MAX_PLAYERS],

// ACCOUNTS_TABLE_PLAYER
DBStatement:	stmt_AccountExists,
DBStatement:	stmt_AccountCreate,
DBStatement:	stmt_AccountLoad,
DBStatement:	stmt_AccountUpdate,

DBStatement:	stmt_AccountGetPassword,
DBStatement:	stmt_AccountSetPassword,

DBStatement:	stmt_AccountGetIpv4,
DBStatement:	stmt_AccountSetIpv4,

DBStatement:	stmt_AccountGetAliveState,
DBStatement:	stmt_AccountSetAliveState,

DBStatement:	stmt_AccountGetRegdate,
DBStatement:	stmt_AccountSetRegdate,

DBStatement:	stmt_AccountGetLastLog,
DBStatement:	stmt_AccountSetLastLog,

DBStatement:	stmt_AccountGetSpawnTime,
DBStatement:	stmt_AccountSetSpawnTime,

DBStatement:	stmt_AccountGetTotalSpawns,
DBStatement:	stmt_AccountSetTotalSpawns,

DBStatement:	stmt_AccountGetWarnings,
DBStatement:	stmt_AccountSetWarnings,

DBStatement:	stmt_AccountGetGpci,
DBStatement:	stmt_AccountSetGpci,

DBStatement:	stmt_AccountGetActiveState,
DBStatement:	stmt_AccountSetActiveState,

DBStatement:	stmt_AccountGetAliasData,
DBStatement:	stmt_AccountSetName;


forward OnPlayerLoadAccount(playerid);
forward OnPlayerRegister(playerid);
forward OnPlayerLogin(playerid);


hook OnGameModeInit()
{
	db_query(gAccounts, "CREATE TABLE IF NOT EXISTS "ACCOUNTS_TABLE_PLAYER" (\
		"FIELD_PLAYER_NAME" TEXT,\
		"FIELD_PLAYER_PASS" TEXT,\
		"FIELD_PLAYER_IPV4" INTEGER,\
		"FIELD_PLAYER_LANGUAGE" INTEGER,\
		"FIELD_PLAYER_ALIVE" INTEGER,\
		"FIELD_PLAYER_REGDATE" INTEGER,\
		"FIELD_PLAYER_LASTLOG" INTEGER,\
		"FIELD_PLAYER_SPAWNTIME" INTEGER,\
		"FIELD_PLAYER_TOTALSPAWNS" INTEGER,\
		"FIELD_PLAYER_WARNINGS" INTEGER,\
		"FIELD_PLAYER_GPCI" TEXT,\
		"FIELD_PLAYER_ACTIVE")");

	db_query(gAccounts, "CREATE INDEX IF NOT EXISTS "ACCOUNTS_TABLE_PLAYER"_index ON "ACCOUNTS_TABLE_PLAYER"("FIELD_PLAYER_NAME")");

	DatabaseTableCheck(gAccounts, ACCOUNTS_TABLE_PLAYER, 12);

	stmt_AccountExists			= db_prepare(gAccounts, "SELECT COUNT(*) FROM "ACCOUNTS_TABLE_PLAYER" WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");
	stmt_AccountCreate			= db_prepare(gAccounts, "INSERT INTO "ACCOUNTS_TABLE_PLAYER" VALUES(?,?,?,?,1,?,?,0,0,0,?,1)");
	stmt_AccountLoad			= db_prepare(gAccounts, "SELECT * FROM "ACCOUNTS_TABLE_PLAYER" WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");
	stmt_AccountUpdate			= db_prepare(gAccounts, "UPDATE "ACCOUNTS_TABLE_PLAYER" SET "FIELD_PLAYER_ALIVE"=?, "FIELD_PLAYER_WARNINGS"=? WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");

	stmt_AccountGetPassword		= db_prepare(gAccounts, "SELECT "FIELD_PLAYER_PASS" FROM "ACCOUNTS_TABLE_PLAYER" WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");
	stmt_AccountSetPassword		= db_prepare(gAccounts, "UPDATE "ACCOUNTS_TABLE_PLAYER" SET "FIELD_PLAYER_PASS"=? WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");

	stmt_AccountGetIpv4			= db_prepare(gAccounts, "SELECT "FIELD_PLAYER_IPV4" FROM "ACCOUNTS_TABLE_PLAYER" WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");
	stmt_AccountSetIpv4			= db_prepare(gAccounts, "UPDATE "ACCOUNTS_TABLE_PLAYER" SET "FIELD_PLAYER_IPV4"=? WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");

	stmt_AccountGetAliveState	= db_prepare(gAccounts, "SELECT "FIELD_PLAYER_ALIVE" FROM "ACCOUNTS_TABLE_PLAYER" WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");
	stmt_AccountSetAliveState	= db_prepare(gAccounts, "UPDATE "ACCOUNTS_TABLE_PLAYER" SET "FIELD_PLAYER_ALIVE"=? WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");

	stmt_AccountGetRegdate		= db_prepare(gAccounts, "SELECT "FIELD_PLAYER_REGDATE" FROM "ACCOUNTS_TABLE_PLAYER" WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");
	stmt_AccountSetRegdate		= db_prepare(gAccounts, "UPDATE "ACCOUNTS_TABLE_PLAYER" SET "FIELD_PLAYER_REGDATE"=? WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");

	stmt_AccountGetLastLog		= db_prepare(gAccounts, "SELECT "FIELD_PLAYER_LASTLOG" FROM "ACCOUNTS_TABLE_PLAYER" WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");
	stmt_AccountSetLastLog		= db_prepare(gAccounts, "UPDATE "ACCOUNTS_TABLE_PLAYER" SET "FIELD_PLAYER_LASTLOG"=? WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");

	stmt_AccountGetSpawnTime	= db_prepare(gAccounts, "SELECT "FIELD_PLAYER_SPAWNTIME" FROM "ACCOUNTS_TABLE_PLAYER" WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");
	stmt_AccountSetSpawnTime	= db_prepare(gAccounts, "UPDATE "ACCOUNTS_TABLE_PLAYER" SET "FIELD_PLAYER_SPAWNTIME"=? WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");

	stmt_AccountGetTotalSpawns	= db_prepare(gAccounts, "SELECT "FIELD_PLAYER_TOTALSPAWNS" FROM "ACCOUNTS_TABLE_PLAYER" WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");
	stmt_AccountSetTotalSpawns	= db_prepare(gAccounts, "UPDATE "ACCOUNTS_TABLE_PLAYER" SET "FIELD_PLAYER_TOTALSPAWNS"=? WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");

	stmt_AccountGetWarnings		= db_prepare(gAccounts, "SELECT "FIELD_PLAYER_WARNINGS" FROM "ACCOUNTS_TABLE_PLAYER" WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");
	stmt_AccountSetWarnings		= db_prepare(gAccounts, "UPDATE "ACCOUNTS_TABLE_PLAYER" SET "FIELD_PLAYER_WARNINGS"=? WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");

	stmt_AccountGetGpci			= db_prepare(gAccounts, "SELECT "FIELD_PLAYER_GPCI" FROM "ACCOUNTS_TABLE_PLAYER" WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");
	stmt_AccountSetGpci			= db_prepare(gAccounts, "UPDATE "ACCOUNTS_TABLE_PLAYER" SET "FIELD_PLAYER_GPCI"=? WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");

	stmt_AccountGetActiveState	= db_prepare(gAccounts, "SELECT "FIELD_PLAYER_ACTIVE" FROM "ACCOUNTS_TABLE_PLAYER" WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");
	stmt_AccountSetActiveState	= db_prepare(gAccounts, "UPDATE "ACCOUNTS_TABLE_PLAYER" SET "FIELD_PLAYER_ACTIVE"=? WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");

	stmt_AccountGetAliasData	= db_prepare(gAccounts, "SELECT "FIELD_PLAYER_IPV4", "FIELD_PLAYER_PASS", "FIELD_PLAYER_GPCI" FROM "ACCOUNTS_TABLE_PLAYER" WHERE "FIELD_PLAYER_NAME"=? AND "FIELD_PLAYER_ACTIVE" COLLATE NOCASE");

    stmt_AccountSetName			= db_prepare(gAccounts, "UPDATE "ACCOUNTS_TABLE_PLAYER" SET "FIELD_PLAYER_NAME"=? WHERE "FIELD_PLAYER_NAME"=? COLLATE NOCASE");

}

hook OnPlayerConnect(playerid)
{
	if(IsPlayerNPC(playerid)) return Y_HOOKS_CONTINUE_RETURN_0;

	dbg("global", CORE, "[OnPlayerConnect] in /gamemodes/sss/core/player/accounts.pwn");

	acc_LoginAttempts[playerid] = 0;
	acc_IsNewPlayer[playerid]   = false;
	acc_HasAccount[playerid]    = false;
	acc_LoggedIn[playerid]      = false;

	return Y_HOOKS_CONTINUE_RETURN_1;
}


/*==============================================================================

	Loads database data into memory and applies it to the player.

==============================================================================*/


LoadAccount(playerid)
{
    if(IsPlayerNPC(playerid)) return 0;

	if(CallLocalFunction("OnPlayerLoadAccount", "d", playerid)) return -1;

	new
		name[MAX_PLAYER_NAME],
		exists,
		password[MAX_PASSWORD_LEN],
		ipv4,
		language,
		bool:alive,
		regdate,
		lastlog,
		spawntime,
		spawns,
		warnings,
		active;

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	stmt_bind_value(stmt_AccountExists, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_AccountExists, 0, DB::TYPE_INTEGER, exists);

	if(!stmt_execute(stmt_AccountExists))
	{
		err("[ACCOUNT] executing statement 'stmt_AccountExists'.");
		return -1;
	}

	if(!stmt_fetch_row(stmt_AccountExists))
	{
		err("[ACCOUNT] fetching statement result 'stmt_AccountExists'.");
		return -1;
	}

	if(exists == 0)
	{
		log("[ACCOUNT] %p (%d) (conta não existe)", playerid, playerid);
		return 0;
	}

	stmt_bind_value(stmt_AccountLoad, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_PASS, DB::TYPE_STRING, password, MAX_PASSWORD_LEN);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_IPV4, DB::TYPE_INTEGER, ipv4);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_LANGUAGE, DB::TYPE_INTEGER, language);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_ALIVE, DB::TYPE_INTEGER, alive);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_REGDATE, DB::TYPE_INTEGER, regdate);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_LASTLOG, DB::TYPE_INTEGER, lastlog);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_SPAWNTIME, DB::TYPE_INTEGER, spawntime);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_TOTALSPAWNS, DB::TYPE_INTEGER, spawns);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_WARNINGS, DB::TYPE_INTEGER, warnings);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_ACTIVE, DB::TYPE_INTEGER, active);

	if(!stmt_execute(stmt_AccountLoad))
	{
		err("[ACCOUNT] executing statement 'stmt_AccountLoad'.");
		return -1;
	}

	if(!stmt_fetch_row(stmt_AccountLoad))
	{
		err("[ACCOUNT] fetching statement result 'stmt_AccountLoad'.");
		return -1;
	}

	if(!active)
	{
		log("[ACCOUNT] %p (%d) (conta inativa) Vivo?: %s, Último Login: %T", playerid, alive ? "Sim" : "Nao", lastlog);
		return 4;
	}

	SetPlayerLanguage(playerid, language);

	SetPlayerAliveState(playerid, alive);
	acc_IsNewPlayer[playerid] = false;
	acc_HasAccount[playerid] = true;

	SetPlayerPassHash(playerid, password);
	SetPlayerRegTimestamp(playerid, regdate);
	SetPlayerLastLogin(playerid, lastlog);
	SetPlayerCreationTimestamp(playerid, spawntime);
	SetPlayerTotalSpawns(playerid, spawns);
	SetPlayerWarnings(playerid, warnings);

//	if(GetPlayerIpAsInt(playerid) == ipv4)
//	{
//		log("[ACCOUNT] %p (account exists, auto login)", playerid);
//		return 2;
//	}

	log("[ACCOUNT] %p (%d) (conta existe. pedindo login) Vivo?: %s, Último Login: %T", playerid, playerid, alive ? "Sim" : "Nao", lastlog);

	return 1;
}


/*==============================================================================

	Creates a new account for a player with the specified password hash.

==============================================================================*/


CreateAccount(playerid, password[])
{
    if(IsPlayerNPC(playerid)) return 0;

	TogglePlayerSpectating(playerid, false);

	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	
	new serial[MAX_GPCI_LEN];
	gpci(playerid, serial, MAX_GPCI_LEN);

	stmt_bind_value(stmt_AccountCreate, 0, DB::TYPE_STRING,		name, MAX_PLAYER_NAME);
	stmt_bind_value(stmt_AccountCreate, 1, DB::TYPE_STRING,		password, MAX_PASSWORD_LEN);
	stmt_bind_value(stmt_AccountCreate, 2, DB::TYPE_INTEGER,	GetPlayerIpAsInt(playerid));
	stmt_bind_value(stmt_AccountCreate, 3, DB::TYPE_INTEGER,	GetPlayerLanguage(playerid));
	stmt_bind_value(stmt_AccountCreate, 4, DB::TYPE_INTEGER,	gettime());
	stmt_bind_value(stmt_AccountCreate, 5, DB::TYPE_INTEGER,	gettime());
	stmt_bind_value(stmt_AccountCreate, 6, DB::TYPE_STRING,		serial, MAX_GPCI_LEN);

	if(!stmt_execute(stmt_AccountCreate))
	{
		err("[CreateAccount] executing statement 'stmt_AccountCreate'.");
		KickPlayer(playerid, "Não foi possível criar sua conta. Por favor, contacte um administrador no Discord.");
		return 0;
	}
	
	//SetPlayerAimShoutText(playerid, "Largue sua arma");
	
	CheckAdminLevel(playerid);

	if(GetPlayerAdminLevel(playerid) > 0) ChatMsg(playerid, BLUE, " >  Seu nível de admin atual é: %d", GetPlayerAdminLevel(playerid));

	acc_IsNewPlayer[playerid] = true;
	acc_HasAccount[playerid]  = true;
	acc_LoggedIn[playerid]    = true;
	SetPlayerToolTips(playerid, true);
	SetPlayerChatMode(playerid, 0);
	SetPlayerScore(playerid, 0);
	StopAudioStreamForPlayer(playerid);

	log("[ACCOUNTS] %p (%d) registrou.", playerid, playerid);
	
	CallLocalFunction("OnPlayerRegister", "d", playerid);

	return 1;
}

DisplayRegisterPrompt(playerid)
{
	new str[250];
	format(str, 250, GetLanguageString(playerid, "ACCREGIBODY", true), playerid);

	log("[DisplayRegisterPrompt] %p is registering", playerid);
	Dialog_Show(playerid, RegisterPrompt, DIALOG_STYLE_PASSWORD, ls(playerid, "ACCREGITITL"), str, ""C_GREEN">", ""C_RED"X");

	return 1;
}

Dialog:RegisterPrompt(playerid, response, listitem, inputtext[])
{
	log("[RegisterPrompt] %p Response: %d", playerid, response);

	if(response)
	{
		if(!(6 <= strlen(inputtext) <= 32))
		{
			ChatMsgLang(playerid, YELLOW, "PASSWORDREQ");
			DisplayRegisterPrompt(playerid);
			return 0;
		}

		new buffer[MAX_PASSWORD_LEN];

		WP_Hash(buffer, MAX_PASSWORD_LEN, inputtext);

		log("[RegisterPrompt] CreateAccount %d", playerid);
		CreateAccount(playerid, buffer);
	}
	else Kick(playerid);

	return 0;
}

DisplayLoginPrompt(playerid, badpass = 0)
{
	new str[200];

	if(badpass)
		format(str, 200, ls(playerid, "ACCLOGWROPW"), acc_LoginAttempts[playerid]);
	else
		format(str, 200, GetLanguageString(playerid, "ACCLOGIBODY", true), playerid);

	log("[DisplayLoginPrompt] %p is logging in", playerid);

	Dialog_Show(playerid, LoginPrompt, DIALOG_STYLE_PASSWORD, ls(playerid, "ACCLOGITITL"), str, ""C_GREEN">", ""C_RED"X");

	return 1;
}

Dialog:LoginPrompt(playerid, response, listitem, inputtext[])
{
	log("[LoginPrompt] %p Response: %d", playerid, response);

	if(response)
	{
		if(strlen(inputtext) < 4) // Chave muito curta
		{
			acc_LoginAttempts[playerid]++;

			if(acc_LoginAttempts[playerid] < 5) DisplayLoginPrompt(playerid, 1); else Kick(playerid);

			return 1;
		}

		new
			inputhash[MAX_PASSWORD_LEN],
			storedhash[MAX_PASSWORD_LEN];

		WP_Hash(inputhash, MAX_PASSWORD_LEN, inputtext);
		GetPlayerPassHash(playerid, storedhash);

		if(!strcmp(inputhash, storedhash)) Login(playerid); // Chave correta
		else {
			acc_LoginAttempts[playerid]++;

			if(acc_LoginAttempts[playerid] < 5) DisplayLoginPrompt(playerid, 1); else Kick(playerid);

			return 1;
		}
	}
	else Kick(playerid);

	return 0;
}

/*==============================================================================

	Loads a player's account, updates some data and spawns them.

==============================================================================*/


Login(playerid)
{
    if(IsPlayerNPC(playerid)) return 0;
	
	TogglePlayerSpectating(playerid, false);

	new serial[MAX_GPCI_LEN];
	gpci(playerid, serial, MAX_GPCI_LEN);
	
	log("[ACCOUNT] %p (%d) efetuou login. Vivo?: %s", playerid, playerid, IsPlayerAlive(playerid) ? "Sim" : "Não");

	// TODO: move to a single query
	stmt_bind_value(stmt_AccountSetIpv4, 0, DB::TYPE_INTEGER, GetPlayerIpAsInt(playerid));
	stmt_bind_value(stmt_AccountSetIpv4, 1, DB::TYPE_PLAYER_NAME, playerid);
	stmt_execute(stmt_AccountSetIpv4);

	stmt_bind_value(stmt_AccountSetGpci, 0, DB::TYPE_STRING, serial);
	stmt_bind_value(stmt_AccountSetGpci, 1, DB::TYPE_PLAYER_NAME, playerid);
	stmt_execute(stmt_AccountSetGpci);

	stmt_bind_value(stmt_AccountSetLastLog, 0, DB::TYPE_INTEGER, gettime());
	stmt_bind_value(stmt_AccountSetLastLog, 1, DB::TYPE_PLAYER_NAME, playerid);
	stmt_execute(stmt_AccountSetLastLog);

	CheckAdminLevel(playerid);

	if(GetPlayerAdminLevel(playerid) > 0)
	{
		new
			reports = GetUnreadReports(),
			issues  = GetBugReports();

		ChatMsg(playerid, BLUE, " >  Seu nível de admin atual é: %d", GetPlayerAdminLevel(playerid));

		if(reports > 0) ChatMsg(playerid, YELLOW, " >  %d reports não lidos, use "C_BLUE"/reports "C_YELLOW"para ver.", reports);
		if(issues > 0) ChatMsg(playerid, YELLOW, " >  %d bugs reportados, use "C_BLUE"/bugs "C_YELLOW"para ver.", issues);
	}

	acc_LoggedIn[playerid] = true;
	acc_LoginAttempts[playerid] = 0;

	SetPlayerBrightness(playerid, 255);
	SpawnLoggedInPlayer(playerid);
	StopAudioStreamForPlayer(playerid);

	TextDrawShowForPlayer(playerid, RestartCount);
	TextDrawShowForPlayer(playerid, ClockRestart);

	// Mostra na tela para os outros jogadores que o jogador entrou no servidor e qual o idioma escolhido. (Apenas depois de carregar a conta)
	// Mensagem personalizada para cada player no final do texto
	new lang_name[3];

	if(GetPlayerLanguage(playerid) == 0) lang_name = "EN"; else lang_name = "PT";
	
	// Mostra a entrada do jogador no chat para os outros jogadores
	new playerName[MAX_PLAYER_NAME], frase[MAX_FRASE_LEN];
	GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);
	format(frase, MAX_FRASE_LEN, "%s", dini_Get("Frases.ini", playerName));
	foreach(new i : Player) if(i != playerid) ChatMsgLang(i, WHITE, "PJOINSV", playerid, playerid, lang_name, frase);

	CallLocalFunction("OnPlayerLogin", "d", playerid);

	return 1;
}

/*==============================================================================

	Logs the player out, saving their data and deleting their items.

==============================================================================*/


Logout(playerid, docombatlogcheck = 1)
{
    if(IsPlayerNPC(playerid)) return 0;
		
	if(!acc_LoggedIn[playerid])
	{
		log("[LOGOUT] %p not logged in.", playerid);
		return 0;
	}

	new Float:x, Float:y, Float:z, Float:r;

    GetPlayerPos(playerid, x, y, z);
    
	GetPlayerFacingAngle(playerid, r);

	log("[LOGOUT] %p logged out at %.1f, %.1f, %.1f (%.1f) Logged In: %d Alive: %d Knocked Out: %d", playerid, x, y, z, r, acc_LoggedIn[playerid], IsPlayerAlive(playerid), IsPlayerKnockedOut(playerid));

	if(IsPlayerOnAdminDuty(playerid))
	{
		dbg("gamemodes/sss/core/player/accounts.pwn", 1, "[LOGOUT] ERROR: Player on admin duty, aborting save.");
		return 0;
	}

	if(docombatlogcheck)
	{
		if(gServerMaxUptime - gServerUptime > 30)
		{
			new
				lastattacker,
				lastweapon;

			if(IsPlayerCombatLogging(playerid, lastattacker, lastweapon))
			{
				log("[LOGOUT] Player '%p' combat logged!", playerid);
				ChatMsgAll(YELLOW, " >  %p Deslogou em combate e foi morto!", playerid);
                SetPlayerSpree(playerid, 0);
                SetPlayerScore(playerid, GetPlayerScore(playerid) - 1);
                SetPlayerDeathCount(playerid, GetPlayerDeathCount(playerid) + 1);
				_OnDeath(playerid, lastattacker);
				SetPlayerAliveState(playerid,  false);
			}
		}
	}

	new
		itemid,
		ItemType:itemtype;

	itemid = GetPlayerItem(playerid);
	itemtype = GetItemType(itemid);

	if(IsItemTypeSafebox(itemtype))
	{
		dbg("gamemodes/sss/core/player/accounts.pwn", 1, "[LOGOUT] Player is holding a box.");
		if(!IsContainerEmpty(GetItemExtraData(itemid)))
		{
			dbg("gamemodes/sss/core/player/accounts.pwn", 1, "[LOGOUT] Player is holding an unempty box, dropping in world.");
			CreateItemInWorld(itemid, x + floatsin(-r, degrees), y + floatcos(-r, degrees), z - FLOOR_OFFSET);
			itemid = INVALID_ITEM_ID;
			itemtype = INVALID_ITEM_TYPE;
		}
	}

	if(IsItemTypeBag(itemtype))
	{
		dbg("gamemodes/sss/core/player/accounts.pwn", 1, "[LOGOUT] Player is holding a bag.");
		if(!IsContainerEmpty(GetItemArrayDataAtCell(itemid, 1)))
		{
			if(IsValidItem(GetPlayerBagItem(playerid)))
			{
				dbg("gamemodes/sss/core/player/accounts.pwn", 1, "[LOGOUT] Player is holding an unempty bag and is wearing one, dropping in world.");
				CreateItemInWorld(itemid, x + floatsin(-r, degrees), y + floatcos(-r, degrees), z - FLOOR_OFFSET);
				itemid = INVALID_ITEM_ID;
				itemtype = INVALID_ITEM_TYPE;
			}
			else
			{
				dbg("gamemodes/sss/core/player/accounts.pwn", 1, "[LOGOUT] Player is holding an unempty bag but is not wearing one, calling GivePlayerBag.");
				GivePlayerBag(playerid, itemid);
				itemid = INVALID_ITEM_ID;
				itemtype = INVALID_ITEM_TYPE;
			}
		}
	}

	SavePlayerData(playerid);

	if(IsPlayerAlive(playerid))
	{
		DestroyItem(itemid);
		DestroyItem(GetPlayerHolsterItem(playerid));
		DestroyPlayerBag(playerid);
		RemovePlayerHolsterItem(playerid);
		RemovePlayerWeapon(playerid);

		for(new i; i < INV_MAX_SLOTS; i++) DestroyItem(GetInventorySlotItem(playerid, 0));

		if(IsValidItem(GetPlayerHatItem(playerid))) RemovePlayerHatItem(playerid);

		if(IsValidItem(GetPlayerMaskItem(playerid))) RemovePlayerMaskItem(playerid);

		if(IsPlayerInAnyVehicle(playerid))
		{
			new
				vehicleid = GetPlayerLastVehicle(playerid),
				Float:health;

			GetVehicleHealth(vehicleid, health);

			if(IsVehicleUpsideDown(vehicleid) || health < 300.0) DestroyVehicle(vehicleid);
			else
			{
				if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) SetVehicleExternalLock(vehicleid, E_LOCK_STATE_OPEN);
			}

			SaveVehicle(vehicleid);
		}
	}

	return 1;
}


/*==============================================================================

	Updates the database and calls the binary save functions if required.

==============================================================================*/


SavePlayerData(playerid)
{
    if(IsPlayerNPC(playerid)) return 0;

	dbg("gamemodes/sss/core/player/accounts.pwn", 1, "[SavePlayerData] Saving '%p'", playerid);

	if(!acc_LoggedIn[playerid])
	{
		dbg("gamemodes/sss/core/player/accounts.pwn", 1, "[SavePlayerData] ERROR: Player isn't logged in");
		return 0;
	}

	if(IsPlayerOnAdminDuty(playerid))
	{
		dbg("gamemodes/sss/core/player/accounts.pwn", 1, "[SavePlayerData] ERROR: On admin duty");
		return 0;
	}

	new Float:x, Float:y, Float:z, Float:r;

 	GetPlayerPos(playerid, x, y, z);
        
	GetPlayerFacingAngle(playerid, r);

	if(IsAtConnectionPos(x, y, z))
	{
		dbg("gamemodes/sss/core/player/accounts.pwn", 1, "[SavePlayerData] ERROR: At connection pos");
		return 0;
	}

	//SaveBlockAreaCheck(x, y, z);

	// Coloca o jogador para cima se ele estiver dentro de um veículo
	if(IsPlayerInAnyVehicle(playerid)) x += 1.5;

	if(IsPlayerAlive(playerid))
	{
		dbg("gamemodes/sss/core/player/accounts.pwn", 2, "[SavePlayerData] Player is alive");
		if(IsAtDefaultPos(x, y, z))
		{
			dbg("gamemodes/sss/core/player/accounts.pwn", 2, "[SavePlayerData] ERROR: Player at default position");
			return 0;
		}

		if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
		{
			dbg("gamemodes/sss/core/player/accounts.pwn", 2, "[SavePlayerData] Player is spectating");
			if(!gServerRestarting)
			{
				dbg("gamemodes/sss/core/player/accounts.pwn", 2, "[SavePlayerData] Server is not restarting, aborting save");
				return 0;
			}
		}

		stmt_bind_value(stmt_AccountUpdate, 0, DB::TYPE_INTEGER, 1);
		stmt_bind_value(stmt_AccountUpdate, 1, DB::TYPE_INTEGER, GetPlayerWarnings(playerid));
		stmt_bind_value(stmt_AccountUpdate, 2, DB::TYPE_PLAYER_NAME, playerid);

		if(!stmt_execute(stmt_AccountUpdate)) err("Statement 'stmt_AccountUpdate' failed to execute.");

		dbg("gamemodes/sss/core/player/accounts.pwn", 2, "[SavePlayerData] Saving character data");
		SavePlayerChar(playerid);
	}
	else
	{
		dbg("gamemodes/sss/core/player/accounts.pwn", 2, "[SavePlayerData] Player is dead");
		stmt_bind_value(stmt_AccountUpdate, 0, DB::TYPE_INTEGER, 0);
		stmt_bind_value(stmt_AccountUpdate, 1, DB::TYPE_INTEGER, GetPlayerWarnings(playerid));
		stmt_bind_value(stmt_AccountUpdate, 2, DB::TYPE_PLAYER_NAME, playerid);

		if(!stmt_execute(stmt_AccountUpdate)) err("Statement 'stmt_AccountUpdate' failed to execute.");
	}

	return 1;
}


/*==============================================================================

	Interface functions

==============================================================================*/


stock GetAccountData(name[], pass[], &ipv4, &alive, &regdate, &lastlog, &spawntime, &totalspawns, &warnings, gpci[], &active)
{
	stmt_bind_value(stmt_AccountLoad, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_PASS, DB::TYPE_STRING, pass, MAX_PASSWORD_LEN);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_IPV4, DB::TYPE_INTEGER, ipv4);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_ALIVE, DB::TYPE_INTEGER, alive);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_REGDATE, DB::TYPE_INTEGER, regdate);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_LASTLOG, DB::TYPE_INTEGER, lastlog);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_SPAWNTIME, DB::TYPE_INTEGER, spawntime);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_TOTALSPAWNS, DB::TYPE_INTEGER, totalspawns);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_WARNINGS, DB::TYPE_INTEGER, warnings);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_GPCI, DB::TYPE_STRING, gpci, MAX_GPCI_LEN);
	stmt_bind_result_field(stmt_AccountLoad, FIELD_ID_PLAYER_ACTIVE, DB::TYPE_INTEGER, active);

	if(!stmt_execute(stmt_AccountLoad))
	{
		err("[GetAccountData] executing statement 'stmt_AccountLoad'.");
		return 0;
	}

	stmt_fetch_row(stmt_AccountLoad);

	return 1;
}

// FIELD_ID_PLAYER_NAME
stock AccountExists(name[])
{
	new exists;

	stmt_bind_value(stmt_AccountExists, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_AccountExists, 0, DB::TYPE_INTEGER, exists);

	if(stmt_execute(stmt_AccountExists))
	{
		stmt_fetch_row(stmt_AccountExists);

		if(exists)
			return 1;
	}

	return 0;
}

stock SetAccountName(name[], name2[MAX_PLAYER_NAME])
{
	stmt_bind_value(stmt_AccountSetName, 0, DB::TYPE_STRING, name2, MAX_PLAYER_NAME);
	stmt_bind_value(stmt_AccountSetName, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetName);
}


// FIELD_ID_PLAYER_PASS
stock GetAccountPassword(name[], password[MAX_PASSWORD_LEN])
{
	stmt_bind_result_field(stmt_AccountGetPassword, 0, DB::TYPE_STRING, password, MAX_PASSWORD_LEN);
	stmt_bind_value(stmt_AccountGetPassword, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetPassword))
		return 0;

	stmt_fetch_row(stmt_AccountGetPassword);

	return 1;
}

stock SetAccountPassword(name[], password[MAX_PASSWORD_LEN])
{
	stmt_bind_value(stmt_AccountSetPassword, 0, DB::TYPE_STRING, password, MAX_PASSWORD_LEN);
	stmt_bind_value(stmt_AccountSetPassword, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetPassword);
}

// FIELD_ID_PLAYER_IPV4
stock GetAccountIP(name[], &ip)
{
	stmt_bind_result_field(stmt_AccountGetIpv4, 0, DB::TYPE_INTEGER, ip);
	stmt_bind_value(stmt_AccountGetIpv4, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetIpv4))
		return 0;

	stmt_fetch_row(stmt_AccountGetIpv4);

	return 1;
}

stock SetAccountIP(name[], ip)
{
	stmt_bind_value(stmt_AccountSetIpv4, 0, DB::TYPE_INTEGER, ip);
	stmt_bind_value(stmt_AccountSetIpv4, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetIpv4);
}

// FIELD_ID_PLAYER_ALIVE
stock GetAccountAliveState(name[], &alivestate)
{
	stmt_bind_result_field(stmt_AccountGetAliveState, 0, DB::TYPE_INTEGER, alivestate);
	stmt_bind_value(stmt_AccountGetAliveState, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetAliveState))
		return 0;

	stmt_fetch_row(stmt_AccountGetAliveState);

	return 1;
}

stock SetAccountAliveState(name[], alivestate)
{
	stmt_bind_value(stmt_AccountSetAliveState, 0, DB::TYPE_INTEGER, alivestate);
	stmt_bind_value(stmt_AccountSetAliveState, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetAliveState);
}

// FIELD_ID_PLAYER_REGDATE
stock GetAccountRegistrationDate(name[], &timestamp)
{
	stmt_bind_result_field(stmt_AccountGetRegdate, 0, DB::TYPE_INTEGER, timestamp);
	stmt_bind_value(stmt_AccountGetRegdate, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetRegdate))
		return 0;

	stmt_fetch_row(stmt_AccountGetRegdate);

	return 1;
}

stock SetAccountRegistrationDate(name[], timestamp)
{
	stmt_bind_value(stmt_AccountSetRegdate, 0, DB::TYPE_INTEGER, timestamp);
	stmt_bind_value(stmt_AccountSetRegdate, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetRegdate);
}

// FIELD_ID_PLAYER_LASTLOG
stock GetAccountLastLogin(name[], &timestamp)
{
	stmt_bind_result_field(stmt_AccountGetLastLog, 0, DB::TYPE_INTEGER, timestamp);
	stmt_bind_value(stmt_AccountGetLastLog, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetLastLog))
		return 0;

	stmt_fetch_row(stmt_AccountGetLastLog);

	return 1;
}

stock SetAccountLastLogin(name[], timestamp)
{
	stmt_bind_value(stmt_AccountSetLastLog, 0, DB::TYPE_INTEGER, timestamp);
	stmt_bind_value(stmt_AccountSetLastLog, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetLastLog);
}

// FIELD_ID_PLAYER_SPAWNTIME
stock GetAccountLastSpawnTimestamp(name[], &timestamp)
{
	stmt_bind_result_field(stmt_AccountGetSpawnTime, 0, DB::TYPE_INTEGER, timestamp);
	stmt_bind_value(stmt_AccountGetSpawnTime, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetSpawnTime))
		return 0;

	stmt_fetch_row(stmt_AccountGetSpawnTime);

	return 1;
}

stock SetAccountLastSpawnTimestamp(name[], timestamp)
{
	stmt_bind_value(stmt_AccountSetSpawnTime, 0, DB::TYPE_INTEGER, timestamp);
	stmt_bind_value(stmt_AccountSetSpawnTime, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetSpawnTime);
}

// FIELD_ID_PLAYER_TOTALSPAWNS
stock GetAccountTotalSpawns(name[], &spawns)
{
	stmt_bind_result_field(stmt_AccountGetTotalSpawns, 0, DB::TYPE_INTEGER, spawns);
	stmt_bind_value(stmt_AccountGetTotalSpawns, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetTotalSpawns))
		return 0;

	stmt_fetch_row(stmt_AccountGetTotalSpawns);

	return 1;
}

stock SetAccountTotalSpawns(name[], spawns)
{
	stmt_bind_value(stmt_AccountSetTotalSpawns, 0, DB::TYPE_INTEGER, spawns);
	stmt_bind_value(stmt_AccountSetTotalSpawns, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetTotalSpawns);
}

// FIELD_ID_PLAYER_WARNINGS
stock GetAccountWarnings(name[], &warnings)
{
	stmt_bind_result_field(stmt_AccountGetWarnings, 0, DB::TYPE_INTEGER, warnings);
	stmt_bind_value(stmt_AccountGetWarnings, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetWarnings))
		return 0;

	stmt_fetch_row(stmt_AccountGetWarnings);

	return 1;
}

stock SetAccountWarnings(name[], warnings)
{
	stmt_bind_value(stmt_AccountSetWarnings, 0, DB::TYPE_INTEGER, warnings);
	stmt_bind_value(stmt_AccountSetWarnings, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetWarnings);
}

// FIELD_ID_PLAYER_GPCI
stock GetAccountGPCI(name[], gpci[MAX_GPCI_LEN])
{
	stmt_bind_result_field(stmt_AccountGetGpci, 0, DB::TYPE_STRING, gpci, MAX_GPCI_LEN);
	stmt_bind_value(stmt_AccountGetGpci, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetGpci))
		return 0;

	stmt_fetch_row(stmt_AccountGetGpci);

	return 1;
}

stock SetAccountGPCI(name[], gpci[MAX_GPCI_LEN])
{
	stmt_bind_value(stmt_AccountSetGpci, 0, DB::TYPE_STRING, gpci, MAX_GPCI_LEN);
	stmt_bind_value(stmt_AccountSetGpci, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetGpci);
}

// FIELD_ID_PLAYER_ACTIVE
stock GetAccountActiveState(name[], &active)
{
	stmt_bind_result_field(stmt_AccountGetActiveState, 0, DB::TYPE_INTEGER, active);
	stmt_bind_value(stmt_AccountGetActiveState, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetActiveState))
		return 0;

	stmt_fetch_row(stmt_AccountGetActiveState);

	return 1;
}

stock SetAccountActiveState(name[], active)
{
	stmt_bind_value(stmt_AccountSetActiveState, 0, DB::TYPE_INTEGER, active);
	stmt_bind_value(stmt_AccountSetActiveState, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetActiveState);
}

// Pass, IP and gpci
stock GetAccountAliasData(name[], pass[129], &ip, gpci[MAX_GPCI_LEN])
{
	stmt_bind_value(stmt_AccountGetAliasData, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_AccountGetAliasData, 0, DB::TYPE_STRING, pass, MAX_PASSWORD_LEN);
	stmt_bind_result_field(stmt_AccountGetAliasData, 1, DB::TYPE_INTEGER, ip);
	stmt_bind_result_field(stmt_AccountGetAliasData, 2, DB::TYPE_STRING, gpci, MAX_GPCI_LEN);

	if(!stmt_execute(stmt_AccountGetAliasData))
		return 0;

	stmt_fetch_row(stmt_AccountGetAliasData);

	return 1;
}

// acc_IsNewPlayer
stock IsNewPlayer(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return acc_IsNewPlayer[playerid];
}

// acc_HasAccount
stock IsPlayerRegistered(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return acc_HasAccount[playerid];
}

// acc_LoggedIn
stock IsPlayerLoggedIn(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return acc_LoggedIn[playerid];
}