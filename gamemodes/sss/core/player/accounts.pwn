#include <YSI\y_hooks>

static enum {
	NAME,
	PASS,
	IPV4,
	LANGUAGE,
	ALIVE,
	REGDATE,
	LASTLOG,
	SPAWNTIME,
	TOTALSPAWNS,
	WARNINGS,
	JOINSENTENCE,
	CLAN,
	VIP,
	KILLS,
	DEATHS,
	ALIVETIME,
	COINS,
	ACTIVE
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

DBStatement:	stmt_AccountGetActiveState,
DBStatement:	stmt_AccountSetActiveState,

DBStatement:	stmt_AccountGetAliasData,
DBStatement:	stmt_AccountSetName;

forward OnPlayerLoadAccount(playerid);
forward OnPlayerRegister(playerid);
forward OnPlayerLogin(playerid);

hook OnGameModeInit() {
	db_query(Database, "CREATE TABLE IF NOT EXISTS players (\
		name TEXT NOT NULL,\
		pass TEXT NOT NULL,\
		ipv4 INTEGER NOT NULL,\
		language INTEGER NOT NULL,\
		alive INTEGER NOT NULL,\
		regDate INTEGER NOT NULL,\
		lastLog INTEGER NOT NULL,\
		spawnTime INTEGER NOT NULL,\
		totalSpawns INTEGER NOT NULL,\
		warnings INTEGER NOT NULL,\
		joinSentence TEXT,\
		clan TEXT,\
		vip INTEGER,\
		kills INTEGER,\
		deaths INTEGER,\
		aliveTime INTEGER,\
		coins INTEGER,\
		active INTEGER NOT NULL)");

	db_query(Database, "CREATE INDEX IF NOT EXISTS player_index ON players(name)");

	stmt_AccountExists			= db_prepare(Database, "SELECT COUNT(*) FROM players WHERE name=? COLLATE NOCASE");

	stmt_AccountCreate			= db_prepare(Database, "INSERT INTO players VALUES(?,?,?,?,0,?,?,0,0,0,?,'',0,0,0,0,0,1)");
	stmt_AccountLoad			= db_prepare(Database, "SELECT * FROM players WHERE name=? COLLATE NOCASE");
	stmt_AccountUpdate			= db_prepare(Database, "UPDATE players SET alive=?, warnings=? WHERE name=? COLLATE NOCASE");

	stmt_AccountGetPassword		= db_prepare(Database, "SELECT pass FROM players WHERE name=? COLLATE NOCASE");
	stmt_AccountSetPassword		= db_prepare(Database, "UPDATE players SET pass=? WHERE name=? COLLATE NOCASE");

	stmt_AccountGetIpv4			= db_prepare(Database, "SELECT ipv4 FROM players WHERE name=? COLLATE NOCASE");
	stmt_AccountSetIpv4			= db_prepare(Database, "UPDATE players SET ipv4=? WHERE name=? COLLATE NOCASE");

	stmt_AccountGetAliveState	= db_prepare(Database, "SELECT alive FROM players WHERE name=? COLLATE NOCASE");
	stmt_AccountSetAliveState	= db_prepare(Database, "UPDATE players SET alive=? WHERE name=? COLLATE NOCASE");

	stmt_AccountGetRegdate		= db_prepare(Database, "SELECT regDate FROM players WHERE name=? COLLATE NOCASE");
	stmt_AccountSetRegdate		= db_prepare(Database, "UPDATE players SET regDate=? WHERE name=? COLLATE NOCASE");

	stmt_AccountGetLastLog		= db_prepare(Database, "SELECT lastLog FROM players WHERE name=? COLLATE NOCASE");
	stmt_AccountSetLastLog		= db_prepare(Database, "UPDATE players SET lastLog=? WHERE name=? COLLATE NOCASE");

	stmt_AccountGetSpawnTime	= db_prepare(Database, "SELECT spawnTime FROM players WHERE name=? COLLATE NOCASE");
	stmt_AccountSetSpawnTime	= db_prepare(Database, "UPDATE players SET spawnTime=? WHERE name=? COLLATE NOCASE");

	stmt_AccountGetTotalSpawns	= db_prepare(Database, "SELECT totalSpawns FROM players WHERE name=? COLLATE NOCASE");
	stmt_AccountSetTotalSpawns	= db_prepare(Database, "UPDATE players SET totalSpawns=? WHERE name=? COLLATE NOCASE");

	stmt_AccountGetWarnings		= db_prepare(Database, "SELECT warnings FROM players WHERE name=? COLLATE NOCASE");
	stmt_AccountSetWarnings		= db_prepare(Database, "UPDATE players SET warnings=? WHERE name=? COLLATE NOCASE");

	stmt_AccountGetActiveState	= db_prepare(Database, "SELECT active FROM players WHERE name=? COLLATE NOCASE");
	stmt_AccountSetActiveState	= db_prepare(Database, "UPDATE players SET active=? WHERE name=? COLLATE NOCASE");

	stmt_AccountGetAliasData	= db_prepare(Database, "SELECT ipv4, pass, FROM players WHERE name=? AND active COLLATE NOCASE");

    stmt_AccountSetName			= db_prepare(Database, "UPDATE players SET name=? WHERE name=? COLLATE NOCASE");
}

hook OnPlayerConnect(playerid) {
	if(IsPlayerNPC(playerid)) return Y_HOOKS_CONTINUE_RETURN_0;

	acc_LoginAttempts[playerid] = 0;
	acc_IsNewPlayer[playerid]   = false;
	acc_HasAccount[playerid]    = false;
	acc_LoggedIn[playerid]      = false;

	return Y_HOOKS_CONTINUE_RETURN_1;
}


//	Loads database data into memory and applies it to the player.
LoadAccount(playerid) {
    if(IsPlayerNPC(playerid)) return 0;

	if(CallLocalFunction("OnPlayerLoadAccount", "d", playerid)) return -1;

	new
		name[MAX_PLAYER_NAME],
		exists,
		password[MAX_PASSWORD_LEN],
		ipv4,
		language,
		bool:alive,
		regDate,
		lastLog,
		spawnTime,
		spawns,
		warnings,
		clan[16], // MAX_CLAN_NAME
		bool:vip,
		kills,
		deaths,
		aliveTime,
		coins,
		active;

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	stmt_bind_value(stmt_AccountExists, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_AccountExists, 0, DB::TYPE_INTEGER, exists);

	if(!stmt_execute(stmt_AccountExists)) {
		err("[ACCOUNTS] executing statement 'stmt_AccountExists'.");
		return -1;
	}

	if(!stmt_fetch_row(stmt_AccountExists)) {
		err("[ACCOUNTS] fetching statement result 'stmt_AccountExists'.");
		return -1;
	}

	if(!exists) {
		log("[ACCOUNTS] %p (%d) (conta n„o existe)", playerid, playerid);
		return 0;
	}

	stmt_bind_value(stmt_AccountLoad, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_AccountLoad, PASS, DB::TYPE_STRING, password, MAX_PASSWORD_LEN);
	stmt_bind_result_field(stmt_AccountLoad, IPV4, DB::TYPE_INTEGER, ipv4);
	stmt_bind_result_field(stmt_AccountLoad, LANGUAGE, DB::TYPE_INTEGER, language);
	stmt_bind_result_field(stmt_AccountLoad, ALIVE, DB::TYPE_INTEGER, alive);
	stmt_bind_result_field(stmt_AccountLoad, REGDATE, DB::TYPE_INTEGER, regDate);
	stmt_bind_result_field(stmt_AccountLoad, LASTLOG, DB::TYPE_INTEGER, lastLog);
	stmt_bind_result_field(stmt_AccountLoad, SPAWNTIME, DB::TYPE_INTEGER, spawnTime);
	stmt_bind_result_field(stmt_AccountLoad, TOTALSPAWNS, DB::TYPE_INTEGER, spawns);
	stmt_bind_result_field(stmt_AccountLoad, WARNINGS, DB::TYPE_INTEGER, warnings);
	stmt_bind_result_field(stmt_AccountLoad, CLAN, DB::TYPE_STRING, clan, sizeof(clan));
	stmt_bind_result_field(stmt_AccountLoad, VIP, DB::TYPE_INTEGER, vip);
	stmt_bind_result_field(stmt_AccountLoad, KILLS, DB::TYPE_INTEGER, kills);
	stmt_bind_result_field(stmt_AccountLoad, DEATHS, DB::TYPE_INTEGER, deaths);
	stmt_bind_result_field(stmt_AccountLoad, ALIVETIME, DB::TYPE_INTEGER, aliveTime);
	stmt_bind_result_field(stmt_AccountLoad, COINS, DB::TYPE_INTEGER, coins);
	stmt_bind_result_field(stmt_AccountLoad, ACTIVE, DB::TYPE_INTEGER, active);

	if(!stmt_execute(stmt_AccountLoad)) {
		err("[ACCOUNTS] executing statement 'stmt_AccountLoad'.");
		return -1;
	}

	if(!stmt_fetch_row(stmt_AccountLoad)) {
		err("[ACCOUNTS] fetching statement result 'stmt_AccountLoad'.");
		return -1;
	}

	if(!active) {
		log("[ACCOUNTS] %p (%d) tentou entrar. (conta inativa), ⁄ltimo Login: %T", playerid, lastLog);
		return 4;
	}

	new const bool:hasClan = !isempty(clan);

	SetPlayerLanguage(playerid, language);
	if(hasClan) SetPlayerClan(playerid, clan);
	SetPlayerAliveState(playerid, alive ? true : false);
	acc_IsNewPlayer[playerid] = false;
	acc_HasAccount[playerid]  = true;

	SetPlayerPassHash(playerid, password);
	SetPlayerRegTimestamp(playerid, regDate);
	SetPlayerLastLogin(playerid, lastLog);
	SetPlayerCreationTimestamp(playerid, spawnTime);
	SetPlayerTotalSpawns(playerid, spawns);
	SetPlayerWarnings(playerid, warnings);
	SetPlayerVip(playerid, vip);
	GiveScore(playerid, kills);
	SetHudComponentString(playerid, HUD_STATUS_KILLS_VALUE, ret_valstr(kills));
	SetPlayerDeathCount(playerid, deaths);
	SetPlayerAliveTime(playerid, aliveTime);
	SetPlayerCoins(playerid, coins, false);

	printf("[ACCOUNTS] %p (%d) carregou conta. (⁄ltimo Login: %T, Registrado em: %T, VIP: %s, Ultimo Respawn: %T, Clan: %s, Total de Spawns: %d, Total de Avisos: %d, Kills: %d, Total de Mortes: %d, Total de Tempo Vivo: %d, Coins: %d, Vivo?: %s)",
		playerid, playerid, lastLog, regDate, booltostr(vip), spawnTime, hasClan ? clan : "Nenhum", spawns, warnings, deaths, kills, aliveTime, coins, booltostr(alive));

	return 1;
}

CreateAccount(playerid, password[]) {
    if(IsPlayerNPC(playerid)) return 0;

	stmt_bind_value(stmt_AccountCreate, 0, DB::TYPE_STRING,		GetPlayerNameEx(playerid), MAX_PLAYER_NAME);
	stmt_bind_value(stmt_AccountCreate, 1, DB::TYPE_STRING,		password, MAX_PASSWORD_LEN);
	stmt_bind_value(stmt_AccountCreate, 2, DB::TYPE_INTEGER,	GetPlayerIpAsInt(playerid));
	stmt_bind_value(stmt_AccountCreate, 3, DB::TYPE_INTEGER,	GetPlayerLanguage(playerid));
	stmt_bind_value(stmt_AccountCreate, 4, DB::TYPE_INTEGER,	gettime()); // regDate
	stmt_bind_value(stmt_AccountCreate, 5, DB::TYPE_INTEGER,	gettime()); // lastLog

	if(!stmt_execute(stmt_AccountCreate)) {
		err("[ACCOUNTS] Error executing statement 'stmt_AccountCreate'.");
		KickPlayer(playerid, "N„o foi possÌvel criar sua conta. Por favor, contacte um administrador no Discord.", true);

		return 0;
	}
	
	SetPlayerAimShoutText(playerid, "Largue sua arma");
	
	CheckAdminLevel(playerid);

	if(GetPlayerAdminLevel(playerid) > 0) ChatMsg(playerid, BLUE, " >  Seu nÌvel de admin atual ù: %d", GetPlayerAdminLevel(playerid));

	acc_IsNewPlayer[playerid] = true;
	acc_HasAccount[playerid]  = true;
	acc_LoggedIn[playerid]    = true;
	SetPlayerToolTips(playerid, true);
	SetPlayerChatMode(playerid, 0);
	StopAudioStreamForPlayer(playerid);

	CallLocalFunction("OnPlayerRegister", "d", playerid);

	return 1;
}

DisplayRegisterPrompt(playerid) {
	Dialog_Show(playerid, RegisterPrompt, DIALOG_STYLE_PASSWORD, ls(playerid, "player/account/register/dialog-title"), sprintf(ls(playerid, "player/account/register/dialog-body"), playerid), ls(playerid, "common/register"), ls(playerid, "common/cancel"));

	return 1;
}

Dialog:RegisterPrompt(playerid, response, listitem, inputtext[]) {
	if(response) {
		if(!(6 <= strlen(inputtext) <= 32)) {
			ChatMsg(playerid, YELLOW, "player/account/register/invalid-password");
			DisplayRegisterPrompt(playerid);

			return 0;
		}

		new password[MAX_PASSWORD_LEN];

		WP_Hash(password, MAX_PASSWORD_LEN, inputtext);

		CreateAccount(playerid, password);

		log("[ACCOUNTS] %p registrou sua conta.", playerid);
	} else 
		KickPlayer(playerid, "Escolheu nao registrar");

	return 0;
}

DisplayLoginPrompt(playerid, badpass = 0) {
	Dialog_Show(playerid, LoginPrompt, DIALOG_STYLE_PASSWORD, ls(playerid, "player/account/login/dialog-title"), sprintf(ls(playerid, badpass ? "player/account/login/wrong-password" : "player/account/login/dialog-body"), badpass ? acc_LoginAttempts[playerid] : playerid), ls(playerid, "common/enter"), ls(playerid, "common/cancel"));

	return 1;
}

Dialog:LoginPrompt(playerid, response, listitem, inputtext[]) {
	if(response) {
		if(strlen(inputtext) < 4) {// Chave muito curta
			acc_LoginAttempts[playerid]++;

			if(acc_LoginAttempts[playerid] < 5) DisplayLoginPrompt(playerid, 1); else Kick(playerid);

			return 1;
		}

		new inputhash[MAX_PASSWORD_LEN], storedhash[MAX_PASSWORD_LEN];

		WP_Hash(inputhash, MAX_PASSWORD_LEN, inputtext);
		GetPlayerPassHash(playerid, storedhash);

		if(isequal(inputhash, storedhash)) {
			SetPlayerScreenFade(playerid, FADE_OUT, 255, 10, 1);
			ShowMotd(playerid);

			if(GetPlayerTotalSpawns(playerid))
				defer Login(playerid); // Chave correta
			else
				defer EnterTutorial(playerid);
		} else {
			acc_LoginAttempts[playerid]++;

			if(acc_LoginAttempts[playerid] < 5) DisplayLoginPrompt(playerid, 1); else Kick(playerid);

			return 1;
		}
	} else Kick(playerid);

	return 0;
}

//	Loads a player's account, updates some data and spawns them.
timer Login[SEC(2)](playerid) {
    if(IsPlayerNPC(playerid)) return 0;
	
	log("[ACCOUNTS] %p (%d) logou.", playerid, playerid);

	// TODO: move to a single query
	// Atualiza o IP no banco de dados
	stmt_bind_value(stmt_AccountSetIpv4, 0, DB::TYPE_INTEGER, GetPlayerIpAsInt(playerid));
	stmt_bind_value(stmt_AccountSetIpv4, 1, DB::TYPE_PLAYER_NAME, playerid);
	stmt_execute(stmt_AccountSetIpv4);

	// Atualiza o ⁄ltimo login no banco de dados
	stmt_bind_value(stmt_AccountSetLastLog, 0, DB::TYPE_INTEGER, gettime());
	stmt_bind_value(stmt_AccountSetLastLog, 1, DB::TYPE_PLAYER_NAME, playerid);
	stmt_execute(stmt_AccountSetLastLog);

	CheckAdminLevel(playerid);

	acc_LoggedIn[playerid]      = true;
	acc_LoginAttempts[playerid] = 0;

	if(IsPlayerAlive(playerid))
		SpawnCharacter(playerid);
	else {
		SetPlayerScreenFade(playerid, FADE_OUT, 255, 25);
		ShowCharacterCreationScreen(playerid);
	}

	StopAudioStreamForPlayer(playerid);

	TextDrawShowForPlayer(playerid, RestartCount);
	TextDrawShowForPlayer(playerid, ClockRestart);

	CallLocalFunction("OnPlayerLogin", "d", playerid);

	return 1;
}

// Chamado apÛs o jogador logar
public OnPlayerLogin(playerid) {
 	ChatMsg(playerid, BLUE, "");
	ChatMsg(playerid, BLUE, " >  Scavenge and Survive (Copyright (C) 2016 Barnaby \"Southclaws\" Keene)");
	ChatMsg(playerid, BLUE, "");

	if(GetPlayerAdminLevel(playerid)) {
		ChatMsg(playerid, BLUE, " >  Seu nÌvel de admin atual È: "C_WHITE"%s", GetAdminRankName(GetPlayerAdminLevel(playerid)));

		new reports = GetUnreadReports();
		if(reports) ChatMsg(playerid, YELLOW, " >  %d reports n„o lidos, use "C_BLUE"/reports "C_YELLOW"para ver.", reports);
	}

	new chatModeStr[24] = "Local";

	switch(GetPlayerChatMode(playerid)) {
		case 1: chatModeStr = "Global";
		case 2: chatModeStr = "Clan";
		case 3: chatModeStr = "Admin";
	}

	ChatMsg(playerid, GREY, " >  Modo de Chat atual: "C_WHITE"%s", chatModeStr);
	
	AnnouncePlayerJoined(playerid);


	// Mostrar o marcador para os admins que estiverem em duty
	foreach(new p : Player) {
		if(!IsPlayerOnAdminDuty(p)) continue;

		SetPlayerMarkerForPlayer(p, playerid, (GetPlayerColor(playerid) | 0x000000FF));
	}

	EnablePlayerCameraTarget(playerid, 1);

	return 1;
}

// Logs the player out, saving their data and deleting their items.
Logout(playerid, docombatlogcheck = 1) {
    if(IsPlayerNPC(playerid) || !acc_LoggedIn[playerid] || IsPlayerOnAdminDuty(playerid)) return 0;

	new Float:x, Float:y, Float:z, Float:r;

    GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	log("[ACCOUNTS] %p (%d) foi deslogado em %.1f, %.1f, %.1f (%.1f). Logado: %s Vivo: %s Knocked Out: %s", playerid, playerid, x, y, z, r, acc_LoggedIn[playerid] ? "true" : "false", IsPlayerAlive(playerid) ? "true" : "false", IsPlayerKnockedOut(playerid) ? "true" : "false");

	if(docombatlogcheck) {
		if(gServerMaxUptime - gServerUptime > 30) {
			new lastattacker, lastweapon;

			if(IsPlayerCombatLogging(playerid, lastattacker, lastweapon)) {
				log("[ACCOUNTS] Player '%p' combat logged!", playerid);
				ChatMsgAll(YELLOW, " >  %p Deslogou em combate e foi morto!", playerid);
                TakeScore(playerid, 1);
                SetPlayerDeathCount(playerid, GetPlayerDeathCount(playerid) + 1);
				_OnDeath(playerid, lastattacker);
				SetPlayerAliveState(playerid, false);
			}
		}
	}

	new itemid, ItemType:itemtype;

	itemid   = GetPlayerItem(playerid);
	itemtype = GetItemType(itemid);

	if(IsItemTypeSafebox(itemtype)) {
		if(!IsContainerEmpty(GetItemExtraData(itemid))) {
			CreateItemInWorld(itemid, x + floatsin(-r, degrees), y + floatcos(-r, degrees), z - FLOOR_OFFSET);
			itemid   = INVALID_ITEM_ID;
			itemtype = INVALID_ITEM_TYPE;
		}
	}

	if(IsItemTypeBag(itemtype)) {
		if(!IsContainerEmpty(GetItemArrayDataAtCell(itemid, 1))) {
			itemid   = INVALID_ITEM_ID;
			itemtype = INVALID_ITEM_TYPE;

			if(IsValidItem(GetPlayerBagItem(playerid)))
				CreateItemInWorld(itemid, x + floatsin(-r, degrees), y + floatcos(-r, degrees), z - FLOOR_OFFSET);
			else
				GivePlayerBag(playerid, itemid);
		}
	}

	SavePlayerData(playerid);

	if(IsPlayerAlive(playerid)) {
		DestroyItem(itemid);
		DestroyItem(GetPlayerHolsterItem(playerid));
		DestroyPlayerBag(playerid);
		RemovePlayerHolsterItem(playerid);
		RemovePlayerWeapon(playerid);

		for(new i; i < INV_MAX_SLOTS; i++) DestroyItem(GetInventorySlotItem(playerid, 0));

		if(IsValidItem(GetPlayerHatItem(playerid))) RemovePlayerHatItem(playerid);

		if(IsValidItem(GetPlayerMaskItem(playerid))) RemovePlayerMaskItem(playerid);

		if(IsPlayerInAnyVehicle(playerid)) {
			new
				vehicleid = GetPlayerLastVehicle(playerid),
				Float:health;

			GetVehicleHealth(vehicleid, health);

			if(IsVehicleUpsideDown(vehicleid) || health < 300.0)
				DestroyVehicle(vehicleid);
			else
				if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) SetVehicleExternalLock(vehicleid, E_LOCK_STATE_OPEN);

			SaveVehicle(vehicleid);
		}
	}

	return 1;
}

// Updates the database and calls the binary save functions if required.
SavePlayerData(playerid) {
    if(IsPlayerNPC(playerid) || IsPlayerInTutorial(playerid) || !acc_LoggedIn[playerid] || IsPlayerOnAdminDuty(playerid) || (GetPlayerState(playerid) == PLAYER_STATE_SPECTATING && !gServerRestarting)) return 0;

	new Float:x, Float:y, Float:z, Float:r;

 	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	if(IsAtConnectionPos(x, y, z) || IsAtDefaultPos(x, y, z)) return 0;

	//SaveBlockAreaCheck(x, y, z);

	if(IsPlayerInAnyVehicle(playerid)) {
		if(CA_GetRoomHeight(x, y, z)) { // Se tiver algum teto por cima coloca para tras
			new const Float:amountBack = 2.0;

			x -= amountBack * floatsin(-r, degrees), y -= amountBack * floatcos(-r, degrees);
		} else {
			x += 1.5;
		}
	}

	SavePlayerChar(playerid);

	stmt_bind_value(stmt_AccountUpdate, 0, DB::TYPE_INTEGER, IsPlayerAlive(playerid) ? 1 : 0);
	stmt_bind_value(stmt_AccountUpdate, 1, DB::TYPE_INTEGER, GetPlayerWarnings(playerid));
	stmt_bind_value(stmt_AccountUpdate, 2, DB::TYPE_PLAYER_NAME, playerid);

	if(!stmt_execute(stmt_AccountUpdate)) err("Statement 'stmt_AccountUpdate' failed to execute.");

	return 1;
}

stock GetAccountData(name[], pass[], &ipv4, &alive, &regDate, &lastLog, &spawnTime, &totalSpawns, &warnings, &active) {
	stmt_bind_value(stmt_AccountLoad, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_AccountLoad, PASS, DB::TYPE_STRING, pass, MAX_PASSWORD_LEN);
	stmt_bind_result_field(stmt_AccountLoad, IPV4, DB::TYPE_INTEGER, ipv4);
	stmt_bind_result_field(stmt_AccountLoad, ALIVE, DB::TYPE_INTEGER, alive);
	stmt_bind_result_field(stmt_AccountLoad, REGDATE, DB::TYPE_INTEGER, regDate);
	stmt_bind_result_field(stmt_AccountLoad, LASTLOG, DB::TYPE_INTEGER, lastLog);
	stmt_bind_result_field(stmt_AccountLoad, SPAWNTIME, DB::TYPE_INTEGER, spawnTime);
	stmt_bind_result_field(stmt_AccountLoad, TOTALSPAWNS, DB::TYPE_INTEGER, totalSpawns);
	stmt_bind_result_field(stmt_AccountLoad, WARNINGS, DB::TYPE_INTEGER, warnings);
	stmt_bind_result_field(stmt_AccountLoad, ACTIVE, DB::TYPE_INTEGER, active);

	if(!stmt_execute(stmt_AccountLoad)) {
		err("[GetAccountData] executing statement 'stmt_AccountLoad'.");
		return 0;
	}

	stmt_fetch_row(stmt_AccountLoad);

	return 1;
}

stock AccountExists(name[]) {
	new exists;

	stmt_bind_value(stmt_AccountExists, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_AccountExists, 0, DB::TYPE_INTEGER, exists);

	if(stmt_execute(stmt_AccountExists)) {
		stmt_fetch_row(stmt_AccountExists);

		if(exists) return 1;
	}

	return 0;
}

stock SetAccountName(name[], name2[MAX_PLAYER_NAME]) {
	stmt_bind_value(stmt_AccountSetName, 0, DB::TYPE_STRING, name2, MAX_PLAYER_NAME);
	stmt_bind_value(stmt_AccountSetName, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetName);
}


stock GetAccountPassword(name[], password[MAX_PASSWORD_LEN]) {
	stmt_bind_result_field(stmt_AccountGetPassword, 0, DB::TYPE_STRING, password, MAX_PASSWORD_LEN);
	stmt_bind_value(stmt_AccountGetPassword, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetPassword)) return 0;

	stmt_fetch_row(stmt_AccountGetPassword);

	return 1;
}

stock SetAccountPassword(name[], password[MAX_PASSWORD_LEN]) {
	stmt_bind_value(stmt_AccountSetPassword, 0, DB::TYPE_STRING, password, MAX_PASSWORD_LEN);
	stmt_bind_value(stmt_AccountSetPassword, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetPassword);
}

// IPV4
stock GetAccountIP(name[], &ip) {
	stmt_bind_result_field(stmt_AccountGetIpv4, 0, DB::TYPE_INTEGER, ip);
	stmt_bind_value(stmt_AccountGetIpv4, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetIpv4)) return 0;

	stmt_fetch_row(stmt_AccountGetIpv4);

	return 1;
}

stock SetAccountIP(name[], ip) {
	stmt_bind_value(stmt_AccountSetIpv4, 0, DB::TYPE_INTEGER, ip);
	stmt_bind_value(stmt_AccountSetIpv4, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetIpv4);
}

// ALIVE
stock GetAccountAliveState(name[], &alivestate) {
	stmt_bind_result_field(stmt_AccountGetAliveState, 0, DB::TYPE_INTEGER, alivestate);
	stmt_bind_value(stmt_AccountGetAliveState, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetAliveState)) return 0;

	stmt_fetch_row(stmt_AccountGetAliveState);

	return 1;
}

stock SetAccountAliveState(name[], alivestate) {
	stmt_bind_value(stmt_AccountSetAliveState, 0, DB::TYPE_INTEGER, alivestate);
	stmt_bind_value(stmt_AccountSetAliveState, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetAliveState);
}

// REGDATE
stock GetAccountRegistrationDate(name[], &timestamp)
{
	stmt_bind_result_field(stmt_AccountGetRegdate, 0, DB::TYPE_INTEGER, timestamp);
	stmt_bind_value(stmt_AccountGetRegdate, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetRegdate)) return 0;

	stmt_fetch_row(stmt_AccountGetRegdate);

	return 1;
}

stock SetAccountRegistrationDate(name[], timestamp) {
	stmt_bind_value(stmt_AccountSetRegdate, 0, DB::TYPE_INTEGER, timestamp);
	stmt_bind_value(stmt_AccountSetRegdate, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetRegdate);
}

// LASTLOG
stock GetAccountLastLogin(name[], &timestamp) {
	stmt_bind_result_field(stmt_AccountGetLastLog, 0, DB::TYPE_INTEGER, timestamp);
	stmt_bind_value(stmt_AccountGetLastLog, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetLastLog)) return 0;

	stmt_fetch_row(stmt_AccountGetLastLog);

	return 1;
}

stock SetAccountLastLogin(name[], timestamp) {
	stmt_bind_value(stmt_AccountSetLastLog, 0, DB::TYPE_INTEGER, timestamp);
	stmt_bind_value(stmt_AccountSetLastLog, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetLastLog);
}

// SPAWNTIME
stock GetAccountLastSpawnTimestamp(name[], &timestamp) {
	stmt_bind_result_field(stmt_AccountGetSpawnTime, 0, DB::TYPE_INTEGER, timestamp);
	stmt_bind_value(stmt_AccountGetSpawnTime, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetSpawnTime)) return 0;

	stmt_fetch_row(stmt_AccountGetSpawnTime);

	return 1;
}

stock SetAccountLastSpawnTimestamp(name[], timestamp) {
	stmt_bind_value(stmt_AccountSetSpawnTime, 0, DB::TYPE_INTEGER, timestamp);
	stmt_bind_value(stmt_AccountSetSpawnTime, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetSpawnTime);
}

// TOTALSPAWNS
stock GetAccountTotalSpawns(name[], &spawns) {
	stmt_bind_result_field(stmt_AccountGetTotalSpawns, 0, DB::TYPE_INTEGER, spawns);
	stmt_bind_value(stmt_AccountGetTotalSpawns, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetTotalSpawns)) return 0;

	stmt_fetch_row(stmt_AccountGetTotalSpawns);

	return 1;
}

stock SetAccountTotalSpawns(name[], spawns) {
	stmt_bind_value(stmt_AccountSetTotalSpawns, 0, DB::TYPE_INTEGER, spawns);
	stmt_bind_value(stmt_AccountSetTotalSpawns, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetTotalSpawns);
}

// WARNINGS
stock GetAccountWarnings(name[], &warnings) {
	stmt_bind_result_field(stmt_AccountGetWarnings, 0, DB::TYPE_INTEGER, warnings);
	stmt_bind_value(stmt_AccountGetWarnings, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetWarnings)) return 0;

	stmt_fetch_row(stmt_AccountGetWarnings);

	return 1;
}

stock SetAccountWarnings(name[], warnings) {
	stmt_bind_value(stmt_AccountSetWarnings, 0, DB::TYPE_INTEGER, warnings);
	stmt_bind_value(stmt_AccountSetWarnings, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetWarnings);
}

// ACTIVE
stock GetAccountActiveState(name[], &active) {
	stmt_bind_result_field(stmt_AccountGetActiveState, 0, DB::TYPE_INTEGER, active);
	stmt_bind_value(stmt_AccountGetActiveState, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AccountGetActiveState)) return 0;

	stmt_fetch_row(stmt_AccountGetActiveState);

	return 1;
}

stock SetAccountActiveState(name[], active) {
	stmt_bind_value(stmt_AccountSetActiveState, 0, DB::TYPE_INTEGER, active);
	stmt_bind_value(stmt_AccountSetActiveState, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_AccountSetActiveState);
}

// Pass, IP
stock GetAccountAliasData(name[], pass[129], &ip) {
	stmt_bind_value(stmt_AccountGetAliasData, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_AccountGetAliasData, 0, DB::TYPE_STRING, pass, MAX_PASSWORD_LEN);
	stmt_bind_result_field(stmt_AccountGetAliasData, 1, DB::TYPE_INTEGER, ip);

	if(!stmt_execute(stmt_AccountGetAliasData)) return 0;

	stmt_fetch_row(stmt_AccountGetAliasData);

	return 1;
}

stock IsNewPlayer(playerid) return !IsPlayerConnected(playerid) ? 0 : acc_IsNewPlayer[playerid];

stock IsPlayerRegistered(playerid) return !IsPlayerConnected(playerid) ? 0 : acc_HasAccount[playerid];

stock IsPlayerLoggedIn(playerid) return !IsPlayerConnected(playerid) ? 0 : acc_LoggedIn[playerid];