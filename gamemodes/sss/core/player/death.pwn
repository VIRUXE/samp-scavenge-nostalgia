#include <YSI\y_hooks>

static
Text:	DeathText = Text:INVALID_TEXT_DRAW,
Text:	DeathButton = Text:INVALID_TEXT_DRAW,
bool:	death_Dying[MAX_PLAYERS],
		death_LastDeath[MAX_PLAYERS],
Float:	death_PosX[MAX_PLAYERS],
Float:	death_PosY[MAX_PLAYERS],
Float:	death_PosZ[MAX_PLAYERS],
Float:	death_RotZ[MAX_PLAYERS],
		death_LastKilledBy[MAX_PLAYERS][MAX_PLAYER_NAME],
		death_LastKilledById[MAX_PLAYERS],
		death_Count[MAX_PLAYERS],
        death_Spree[MAX_PLAYERS],
		death_Kills[MAX_PLAYERS],
		aliveTime[MAX_PLAYERS];

hook OnPlayerConnect(playerid) {
	death_Dying[playerid]           = false;
	death_LastKilledBy[playerid][0] = EOS;
	death_LastKilledById[playerid]  = INVALID_PLAYER_ID;
	death_Count[playerid]           = 0;
	death_Spree[playerid]           = 0;
	death_Kills[playerid]           = 0;
	aliveTime[playerid]             = 0;
}

hook OnPlayerLogin(playerid) {
	new const minutesAlive = aliveTime[playerid] / 60;
	if(minutesAlive) GiveScore(playerid, minutesAlive);
}

public OnPlayerDeath(playerid, killerid, reason) {
	if(IsPlayerNPC(playerid)) return -1; // Don't care about NPCs dieing

	if(IsPlayerConnected(killerid) && !IsPlayerSpawned(killerid)) return -1;

    if(GetTickCountDifference(GetTickCount(), death_LastDeath[playerid]) < SEC(1)) return -1; // ? Ignorar se morreu a menos de 1 segundo? Impossivel?

	SetPlayerScreenFade(playerid, FADE_OUT, 255);

	if(killerid == INVALID_PLAYER_ID) {
		killerid = GetLastHitById(playerid);

		if(!IsPlayerConnected(killerid)) killerid = INVALID_PLAYER_ID;
	}

	_OnDeath(playerid, killerid);

	return 1;
}

ptask UpdatePlayerAliveTime[SEC(1)](playerid) {
	if(
		!IsPlayerLoggedIn(playerid) ||
		!IsPlayerSpawned(playerid) ||
		!IsPlayerAlive(playerid) ||
		IsPlayerUnfocused(playerid) ||
		IsPlayerOnAdminDuty(playerid) ||
		IsPlayerInTutorial(playerid)
	) return;

	aliveTime[playerid]++;

	// TODO: Ingles
	new const hoursAlive = aliveTime[playerid] / 3600;

	if(aliveTime[playerid] % 3600 == 0) ChatMsgAll(GOLD, "[Score] %P "C_GOLD"completou agora %s hora vivo! (Total: %d hora%s)", playerid, hoursAlive > 1 ? "mais uma" : "uma", hoursAlive, hoursAlive > 1 ? "s" : ""); 

	if((aliveTime[playerid] / 60) % 1000 == 0) {
		AddPlayerCoins(playerid, 1000);

		ChatMsgAll(GREEN, " > Parabéns a %P"C_GREEN"! Ele completou agora 1000 de Score e ganhou 1000 MOEDAS!", playerid);
	}

	db_query(Database, sprintf("UPDATE players SET aliveTime = aliveTime + 1 WHERE name = '%s';", GetPlayerNameEx(playerid)));

	if(aliveTime[playerid] % 60 == 0) GiveScore(playerid, 1);
}

_OnDeath(playerid, killerId) {
	if(!IsPlayerAlive(playerid) || IsPlayerOnAdminDuty(playerid)) return 0;
	
	new
		deathReason = GetLastHitByWeapon(playerid),
		deathReasonString[256];

	db_query(Database, sprintf("UPDATE players SET aliveTime = 0, kills = 0, deaths = deaths + 1 WHERE name = '%s';", GetPlayerNameEx(playerid)));

	death_LastDeath[playerid] = GetTickCount();
	death_Count[playerid]++;
	death_Spree[playerid] = 0;
	death_Kills[playerid] = 0;
	death_Dying[playerid] = true;
	aliveTime[playerid]   = 0;
	SetPlayerSpawnedState(playerid, false);
	SetPlayerAliveState(playerid, false);

	GetPlayerPos(playerid, death_PosX[playerid], death_PosY[playerid], death_PosZ[playerid]);
	
	GetPlayerFacingAngle(playerid, death_RotZ[playerid]);

	if(IsPlayerInAnyVehicle(playerid)) {
		RemovePlayerFromVehicle(playerid);

		// ? E mesmo necessario?
		TogglePlayerSpectating(playerid, true);
		TogglePlayerSpectating(playerid, false);
		death_PosZ[playerid] += 0.5;
	}

	ToggleHud(playerid, false);
	DropItems(playerid, death_PosX[playerid], death_PosY[playerid], death_PosZ[playerid], death_RotZ[playerid], true);
	RemovePlayerWeapon(playerid);
	RemoveAllDrugs(playerid);

	SetPlayerWeather(playerid, GetSettingInt("world/weather"));

	SpawnPlayer(playerid);

	KillPlayer(playerid, killerId, deathReason);

	SendDeathMessage(killerId, playerid, deathReason);

	ChatMsgAll(RED, " > Que merda %P"C_RED" acabou por morrer com {FFFFFF}%d"C_RED" de score!", playerid, GetPlayerScore(playerid));

	if(IsPlayerConnected(killerId)) {
		log("[KILL] %p killed %p with %d at %f, %f, %f (%f)", killerId, playerid, deathReason, death_PosX[playerid], death_PosY[playerid], death_PosZ[playerid], death_RotZ[playerid]);
	
		GiveScore(killerId, IsPlayerVip(killerId) ? 2 : 1);

		db_query(Database, sprintf("UPDATE players SET kills = kills + CASE WHEN vip = 1 THEN 2 ELSE 1 END WHERE name = '%s';", GetPlayerNameEx(killerId)));
		
		death_Kills[killerId]++;
		death_Spree[killerId]++;

		SetHudComponentString(playerid, HUD_STATUS_KILLS_VALUE, ret_valstr(death_Kills[killerId]));
		
		// foreach(new i : Player) ChatMsg(i, RED, "player/chatkill", killerId, playerid);
		
		GetPlayerName(killerId, death_LastKilledBy[playerid], MAX_PLAYER_NAME);
		death_LastKilledById[playerid] = killerId;
        SetLastHitById(playerid, INVALID_PLAYER_ID);

		switch(deathReason) {
			case 0..3, 5..7, 10..15: 	deathReasonString = "Espancado até a morte.";
			case 4: 					deathReasonString = "Sofreu pequenos cortes no tronco, possivelmente de uma faca.";
			case 8: 					deathReasonString = "Grandes lacerações cobrem o tronco e a cabeça, parece uma espada finamente afiada.";
			case 9: 					deathReasonString = "Há pedaços em todos os lugares, provavelmente sofreu com uma serra elétrica.";
			case 16, 39, 35, 36, 255: 	deathReasonString = "Sofreu uma concussão maciça devido a uma explosão.";
			case 18, 37: 				deathReasonString = "Todo o corpo está carbonizado e queimado.";
			case 22..34, 38: 			deathReasonString = "Morreu de perda de sangue causada pelo que parece balas.";
			case 41, 42: 				deathReasonString = "Esse corpo foi pulverizado e sufocado por uma substância de alta pressão.";
			case 44, 45: 				deathReasonString = "De alguma forma, eles foram mortos por óculos.";
			case 43: 					deathReasonString = "De alguma forma, eles foram mortos por uma câmera.";
			default: 					deathReasonString = "Sangrou até a morte";
		}
	} else {
		log("[DEATH] %p died because of %d at %f, %f, %f (%f)", playerid, deathReason, death_PosX[playerid], death_PosY[playerid], death_PosZ[playerid], death_RotZ[playerid]);

		death_LastKilledBy[playerid][0] = EOS;
		death_LastKilledById[playerid]  = INVALID_PLAYER_ID;

		switch(deathReason) {
			case 53: 	deathReasonString = "Se afogou";
			case 54: 	deathReasonString = "A maioria dos ossos estão quebrados, parece que eles caíram de uma grande altura.";
			case 255: 	deathReasonString = "Sofreu uma concussão maciça devido a uma explosão.";
			default: 	deathReasonString = "Razão da morte desconhecida.";
		}
	}

	CreateGravestone(playerid, deathReasonString, death_PosX[playerid], death_PosY[playerid], death_PosZ[playerid] - FLOOR_OFFSET, death_RotZ[playerid]);

    SavePlayerData(playerid);

	return 1;
}

DropItems(playerid, Float:x, Float:y, Float:z, Float:r, bool:death) {
	new
		itemId,
		interior = GetPlayerInterior(playerid),
		world    = GetPlayerVirtualWorld(playerid),
		Float:newX, Float:newY, Float:groundZ;

	// Held item
	itemId = GetPlayerItem(playerid);

	if(IsValidItem(itemId)) {
		newX = x + floatsin(345.0, degrees);
		newY = y + floatcos(345.0, degrees);

		CA_FindZ_For2DCoord(newX,newY, groundZ);

		CreateItemInWorld(itemId, newX, newY, groundZ, .rz = r, .world = world, .interior = interior);
	}

	// Holstered item
	itemId = GetPlayerHolsterItem(playerid); // ? Porque criar outro?

	if(IsValidItem(itemId)) {
		RemovePlayerHolsterItem(playerid);

		newX = x + floatsin(15.0, degrees);
		newY = y + floatcos(15.0, degrees);

		CA_FindZ_For2DCoord(newX,newY, groundZ);

		CreateItemInWorld(itemId, newX, newY, groundZ, .rz = r, .world = world, .interior = interior);
	}

	// Inventory
	for(new i; i < INV_MAX_SLOTS; i++) {
		itemId = GetInventorySlotItem(playerid, 0);

		if(!IsValidItem(itemId)) break;

		RemoveItemFromInventory(playerid, 0);

		newX = x + floatsin(45.0 + (90.0 * float(i)), degrees);
		newY = y + floatcos(45.0 + (90.0 * float(i)), degrees);

		CA_FindZ_For2DCoord(newX,newY, groundZ);

		CreateItemInWorld(itemId, newX, newY, groundZ, .rz = r, .world = world, .interior = interior);
	}

	// Bag item
	itemId = GetPlayerBagItem(playerid);

	if(IsValidItem(itemId)) {
		RemovePlayerBag(playerid);

		SetItemPos(itemId, x, y, z - FLOOR_OFFSET); // ? A mochila fica no centro?
		SetItemRot(itemId, 0.0, 0.0, r, true);
		SetItemInterior(itemId, interior);
		SetItemWorld(itemId, world);
	}

	// Head-wear item
	itemId = RemovePlayerHatItem(playerid);

	if(IsValidItem(itemId)) {
		newX = x + floatsin(270.0, degrees);
		newY = y + floatcos(270.0, degrees);

		CA_FindZ_For2DCoord(newX,newY, groundZ);

		CreateItemInWorld(itemId, newX, newY, groundZ, .rz = r, .world = world, .interior = interior);
	}

	// Face-wear item
	itemId = RemovePlayerMaskItem(playerid);

	if(IsValidItem(itemId)) {
		newX = x + floatsin(280.0, degrees);
		newY = y + floatcos(280.0, degrees);

		CA_FindZ_For2DCoord(newX,newY, groundZ);

		CreateItemInWorld(itemId, newX, newY, groundZ, .rz = r, .world = world, .interior = interior);
	}

	// Armour item
	if(GetPlayerAP(playerid) > 0.0) {
		newX = x + floatsin(80.0, degrees);
		newY = y + floatcos(80.0, degrees);

		CA_FindZ_For2DCoord(newX,newY, groundZ);

		itemId = CreateItemInWorld(RemovePlayerArmourItem(playerid), newX, newY, groundZ, .rz = r, .world = world, .interior = interior);

		SetPlayerAP(playerid, 0.0);
	}

	// Os itens seguintes apenas devem ser dropados na morte
	if(!death) return;

	// Handcuffs
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED) {
		newX = x + floatsin(135.0, degrees);
		newY = y + floatcos(135.0, degrees);

		CA_FindZ_For2DCoord(newX,newY, groundZ);

		CreateItem(item_HandCuffs, newX,newY, groundZ, .rz = r, .world = world, .interior = interior);

		SetPlayerCuffs(playerid, false);
	}

	// Roupas
	newX = x + floatsin(90.0, degrees);
	newY = y + floatcos(90.0, degrees);

	CA_FindZ_For2DCoord(newX,newY, groundZ);

	itemId = CreateItem(item_Clothes, newX,newY, groundZ, .rz = r, .world = world, .interior = interior);

	if(GetPlayerSkin(playerid) == 287) {
		SetPlayerClothesID(playerid, skin_Civ0M);
		SetPlayerClothes(playerid, GetPlayerClothesID(playerid));

		newX = x + floatsin(135.0, degrees);
		newY = y + floatcos(135.0, degrees);

		CA_FindZ_For2DCoord(newX,newY, groundZ);

		CreateItem(item_Camouflage, newX,newY, groundZ, .rz = r, .world = world, .interior = interior);
	}
		
	SetItemExtraData(itemId, GetPlayerClothes(playerid));

	return;
}

hook OnPlayerSpawn(playerid) {
	if(IsPlayerDead(playerid)) {
		TogglePlayerSpectating(playerid, true);
		TogglePlayerControllable(playerid, false);

		defer SetDeathCamera(playerid);

		SetPlayerCameraPos(playerid,
			death_PosX[playerid] - floatsin(-death_RotZ[playerid], degrees),
			death_PosY[playerid] - floatcos(-death_RotZ[playerid], degrees),
			death_PosZ[playerid]);

		SetPlayerCameraLookAt(playerid, death_PosX[playerid], death_PosY[playerid], death_PosZ[playerid]);

		SelectTextDraw(playerid, 0xFFFFFF88);
		SetPlayerHP(playerid, 1.0);

		TextDrawShowForPlayer(playerid, DeathText);
		TextDrawShowForPlayer(playerid, DeathButton);
	}
}

timer SetDeathCamera[500](playerid) {
	if(!IsPlayerDead(playerid)) return;

	InterpolateCameraPos(playerid,
		death_PosX[playerid] - floatsin(-death_RotZ[playerid], degrees),
		death_PosY[playerid] - floatcos(-death_RotZ[playerid], degrees),
		death_PosZ[playerid] + 1.0,
		death_PosX[playerid] - floatsin(-death_RotZ[playerid], degrees),
		death_PosY[playerid] - floatcos(-death_RotZ[playerid], degrees),
		death_PosZ[playerid] + 20.0,
		30000, CAMERA_MOVE);

	InterpolateCameraLookAt(playerid,
		death_PosX[playerid],
		death_PosY[playerid],
		death_PosZ[playerid],
		death_PosX[playerid],
		death_PosY[playerid],
		death_PosZ[playerid] + 1.0,
		30000, CAMERA_MOVE);

	return;
}

hook OnPlayerClickTextDraw(playerid, Text:clickedid) {
	if(clickedid == DeathButton) { // Se quer se reviver
		if(!IsPlayerDead(playerid)) {
			printf("[DEATH] %p (%d) tentou se reviver, mas não está morto.", playerid, playerid);
			return 1;
		}

		death_Dying[playerid] = false;
		TogglePlayerSpectating(playerid, false);

		// Esconde a tela actual
		CancelSelectTextDraw(playerid);
		TextDrawHideForPlayer(playerid, DeathText);
		TextDrawHideForPlayer(playerid, DeathButton);

		// Mostra a tela de selecção de personagem
		SetPlayerScreenFade(playerid, FADE_OUT, 255, 25);
		defer ShowCharacterCreationScreen(playerid);
	}

	return 1;
}

hook OnGameModeInit() {
	// TODO: internacionalizacao
	DeathText					=TextDrawCreate(320.000000, 300.000000, "MORTO!");
	TextDrawAlignment			(DeathText, 2);
	TextDrawBackgroundColor		(DeathText, 255);
	TextDrawFont				(DeathText, 1);
	TextDrawLetterSize			(DeathText, 0.500000, 2.000000);
	TextDrawColor				(DeathText, -1);
	TextDrawSetOutline			(DeathText, 0);
	TextDrawSetProportional		(DeathText, 1);
	TextDrawSetShadow			(DeathText, 1);
	TextDrawUseBox				(DeathText, 1);
	TextDrawBoxColor			(DeathText, 85);
	TextDrawTextSize			(DeathText, 20.000000, 150.000000);

	DeathButton					=TextDrawCreate(320.000000, 323.000000, "> Jogar Novamente <");
	TextDrawAlignment			(DeathButton, 2);
	TextDrawBackgroundColor		(DeathButton, 255);
	TextDrawFont				(DeathButton, 1);
	TextDrawLetterSize			(DeathButton, 0.370000, 1.599999);
	TextDrawColor				(DeathButton, -1);
	TextDrawSetOutline			(DeathButton, 0);
	TextDrawSetProportional		(DeathButton, 1);
	TextDrawSetShadow			(DeathButton, 1);
	TextDrawUseBox				(DeathButton, 1);
	TextDrawBoxColor			(DeathButton, 85);
	TextDrawTextSize			(DeathButton, 20.000000, 150.000000);
	TextDrawSetSelectable		(DeathButton, true);
}

stock IsPlayerDead(playerid) {
	if(!IsPlayerConnected(playerid)) return 0;

	return death_Dying[playerid];
}

stock GetPlayerDeathPos(playerid, &Float:x, &Float:y, &Float:z) {
	if(!IsPlayerConnected(playerid)) return 0;

	x = death_PosX[playerid];
	y = death_PosY[playerid];
	z = death_PosZ[playerid];

	return 1;
}

stock GetPlayerDeathRot(playerid, &Float:r) {
	if(!IsPlayerConnected(playerid)) return 0;

	r = death_RotZ;

	return 1;
}

// death_LastKilledBy
stock GetLastKilledBy(playerid, name[MAX_PLAYER_NAME]) {
	if(!IsPlayerConnected(playerid)) return 0;

	name = death_LastKilledBy[playerid];

	return 1;
}

// death_LastKilledById
stock GetLastKilledById(playerid) {
	if(!IsPlayerConnected(playerid)) return 0;

	return death_LastKilledById[playerid];
}

GetPlayerKillCount(playerid) return death_Kills[playerid];

stock GetPlayerAliveTime(playerid) return aliveTime[playerid];
	
stock SetPlayerAliveTime(playerid, time) aliveTime[playerid] = time;

stock GetPlayerDeathCount(playerid) return death_Count[playerid];

stock SetPlayerDeathCount(playerid, dead) death_Count[playerid] = dead;

stock GetPlayerSpree(playerid) return death_Spree[playerid];

stock SetPlayerSpree(playerid, spree) death_Spree[playerid] = spree;