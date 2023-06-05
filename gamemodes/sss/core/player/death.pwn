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
		aliveTime[MAX_PLAYERS];

hook OnPlayerConnect(playerid) {
	death_Dying[playerid]           = false;
	death_LastKilledBy[playerid][0] = EOS;
	death_LastKilledById[playerid]  = INVALID_PLAYER_ID;
	death_Count[playerid]           = 0;
	aliveTime[playerid]             = 0;
	death_Spree[playerid]           = 0;
}

hook OnPlayerLogin(playerid) {
	new const minutesAlive = aliveTime[playerid] / 60;
	if(minutesAlive) GiveScore(playerid, minutesAlive);
}

public OnPlayerDeath(playerid, killerid, reason) {
	if(IsPlayerNPC(playerid)) return -1; // Don't care about NPCs dieing

	if(IsPlayerConnected(killerid) && !IsPlayerSpawned(killerid)) return -1;

    if(GetTickCountDifference(GetTickCount(), death_LastDeath[playerid]) < SEC(1)) return -1; // ? Ignorar se morreu a menos de 1 segundo? Impossivel?

	death_Count[playerid]++;

	SetPlayerScreenFade(playerid, FADE_OUT, 255);
	death_LastDeath[playerid] = GetTickCount();

	if(killerid == INVALID_PLAYER_ID) {
		killerid = GetLastHitById(playerid);

		if(!IsPlayerConnected(killerid)) killerid = INVALID_PLAYER_ID;
	}

	_OnDeath(playerid, killerid);

	return 1;
}

ptask UpdatePlayerAliveTime[SEC(1)](playerid) {
	if(
		!IsPlayerSpawned(playerid) ||
		!IsPlayerAlive(playerid) ||
		IsPlayerUnfocused(playerid) ||
		IsPlayerOnAdminDuty(playerid) ||
		IsPlayerInTutorial(playerid)
	) return;

	aliveTime[playerid]++;

	db_query(Database, sprintf("UPDATE players SET aliveTime = aliveTime + 1 WHERE name = '%s';", GetPlayerNameEx(playerid)));

	if(aliveTime[playerid] % 60 == 0) GiveScore(playerid, 1);
}

_OnDeath(playerid, killerid) {
	if(!IsPlayerAlive(playerid) || IsPlayerOnAdminDuty(playerid)) return 0;
	
	new
		deathReason = GetLastHitByWeapon(playerid),
		deathReasonString[256];

	db_query(Database, sprintf("UPDATE players SET aliveTime = 0 WHERE name = '%s';", GetPlayerNameEx(playerid)));

	aliveTime[playerid] = 0;
	death_Dying[playerid] = true;
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

	KillPlayer(playerid, killerid, deathReason);

	if(IsPlayerConnected(killerid)) {
		log("[KILL] %p killed %p with %d at %f, %f, %f (%f)", killerid, playerid, deathReason, death_PosX[playerid], death_PosY[playerid], death_PosZ[playerid], death_RotZ[playerid]);
	
		GiveScore(killerid, IsPlayerVip(killerid) ? 2 : 1);

		db_query(Database, sprintf("UPDATE players SET kills = kills + CASE WHEN vip = 1 THEN 2 ELSE 1 END WHERE name = '%s';", GetPlayerNameEx(killerid)));
		
		death_Spree[killerid]++;
		death_Spree[playerid] = 0;
		
		foreach(new i : Player) ChatMsg(i, RED, "player/chatkill", killerid, playerid);
		
		GetPlayerName(killerid, death_LastKilledBy[playerid], MAX_PLAYER_NAME);
		death_LastKilledById[playerid] = killerid;
        SetLastHitById(playerid, INVALID_PLAYER_ID);

		switch(deathReason) {
			case 0..3, 5..7, 10..15: 	deathReasonString = "Espancado at� a morte.";
			case 4: 					deathReasonString = "Sofreu pequenos cortes no tronco, possivelmente de uma faca.";
			case 8: 					deathReasonString = "Grandes lacera��es cobrem o tronco e a cabe�a, parece uma espada finamente afiada.";
			case 9: 					deathReasonString = "H� peda�os em todos os lugares, provavelmente sofreu com uma serra el�trica.";
			case 16, 39, 35, 36, 255: 	deathReasonString = "Sofreu uma concuss�o maci�a devido a uma explos�o.";
			case 18, 37: 				deathReasonString = "Todo o corpo est� carbonizado e queimado.";
			case 22..34, 38: 			deathReasonString = "Morreu de perda de sangue causada pelo que parece balas.";
			case 41, 42: 				deathReasonString = "Esse corpo foi pulverizado e sufocado por uma subst�ncia de alta press�o.";
			case 44, 45: 				deathReasonString = "De alguma forma, eles foram mortos por �culos.";
			case 43: 					deathReasonString = "De alguma forma, eles foram mortos por uma c�mera.";
			default: 					deathReasonString = "Sangrou at� a morte";
		}
	} else {
		log("[DEATH] %p died because of %d at %f, %f, %f (%f)", playerid, deathReason, death_PosX[playerid], death_PosY[playerid], death_PosZ[playerid], death_RotZ[playerid]);

		death_LastKilledBy[playerid][0] = EOS;
		death_LastKilledById[playerid]  = INVALID_PLAYER_ID;

		switch(deathReason) {
			case 53: 	deathReasonString = "Se afogou";
			case 54: 	deathReasonString = "A maioria dos ossos est�o quebrados, parece que eles ca�ram de uma grande altura.";
			case 255: 	deathReasonString = "Sofreu uma concuss�o maci�a devido a uma explos�o.";
			default: 	deathReasonString = "Raz�o da morte desconhecida.";
		}
	}

	CreateGravestone(playerid, deathReasonString, death_PosX[playerid], death_PosY[playerid], death_PosZ[playerid] - FLOOR_OFFSET, death_RotZ[playerid]);

    SavePlayerData(playerid);

	SetPlayerDeathCount(playerid, GetPlayerDeathCount(playerid) + 1);
	db_query(Database, sprintf("UPDATE players SET deaths = deaths + 1 WHERE name = '%s';", GetPlayerNameEx(playerid)));

	return 1;
}

DropItems(playerid, Float:x, Float:y, Float:z, Float:r, bool:death) {
	new
		itemid,
		interior = GetPlayerInterior(playerid),
		world    = GetPlayerVirtualWorld(playerid);

	/*
		Held item
	*/

	itemid = GetPlayerItem(playerid);

	if(IsValidItem(itemid)) {
		CreateItemInWorld(itemid,
			x + floatsin(345.0, degrees),
			y + floatcos(345.0, degrees),
			z - FLOOR_OFFSET,
			.rz = r,
			.world = world,
			.interior = interior);
	}

	/*
		Holstered item
	*/

	itemid = GetPlayerHolsterItem(playerid);

	if(IsValidItem(itemid)) {
		RemovePlayerHolsterItem(playerid);

		CreateItemInWorld(itemid,
			x + floatsin(15.0, degrees),
			y + floatcos(15.0, degrees),
			z - FLOOR_OFFSET,
			.rz = r,
			.world = world,
			.interior = interior);
	}

	/*
		Inventory
	*/

	for(new i; i < INV_MAX_SLOTS; i++) {
		itemid = GetInventorySlotItem(playerid, 0);

		if(!IsValidItem(itemid))
			break;

		RemoveItemFromInventory(playerid, 0);
		CreateItemInWorld(itemid,
			x + floatsin(45.0 + (90.0 * float(i)), degrees),
			y + floatcos(45.0 + (90.0 * float(i)), degrees),
			z - FLOOR_OFFSET,
			.rz = r,
			.world = world,
			.interior = interior);
	}

	/*
		Bag item
	*/

	itemid = GetPlayerBagItem(playerid);

	if(IsValidItem(itemid)) {
		RemovePlayerBag(playerid);

		SetItemPos(itemid, x, y, z - FLOOR_OFFSET);
		SetItemRot(itemid, 0.0, 0.0, r, true);
		SetItemInterior(itemid, interior);
		SetItemWorld(itemid, world);
	}

	/*
		Head-wear item
	*/

	itemid = RemovePlayerHatItem(playerid);

	if(IsValidItem(itemid)) {
		CreateItemInWorld(itemid,
			x + floatsin(270.0, degrees),
			y + floatcos(270.0, degrees),
			z - FLOOR_OFFSET,
			.rz = r,
			.world = world,
			.interior = interior);
	}

	/*
		Face-wear item
	*/

	itemid = RemovePlayerMaskItem(playerid);

	if(IsValidItem(itemid)) {
		CreateItemInWorld(itemid,
			x + floatsin(280.0, degrees),
			y + floatcos(280.0, degrees),
			z - FLOOR_OFFSET,
			.rz = r,
			.world = world,
			.interior = interior);
	}

	/*
		Armour item
	*/

	if(GetPlayerAP(playerid) > 0.0) {
		itemid = CreateItemInWorld(RemovePlayerArmourItem(playerid),
			x + floatsin(80.0, degrees),
			y + floatcos(80.0, degrees),
			z - FLOOR_OFFSET,
			.rz = r,
			.world = world,
			.interior = interior);

		SetPlayerAP(playerid, 0.0);
	}

	/*
		These items should only be dropped on death.
	*/

	if(!death) return;

	/*
		Handcuffs
	*/

	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED) {
		CreateItem(item_HandCuffs,
			x + floatsin(135.0, degrees),
			y + floatcos(135.0, degrees),
			z - FLOOR_OFFSET,
			.rz = r,
			.world = world,
			.interior = interior);

		SetPlayerCuffs(playerid, false);
	}

	/*
		Clothes item
	*/

	itemid = CreateItem(item_Clothes,
		x + floatsin(90.0, degrees),
		y + floatcos(90.0, degrees),
		z - FLOOR_OFFSET,
		.rz = r,
		.world = world,
		.interior = interior);

	if(GetPlayerSkin(playerid) == 287) {
		SetPlayerClothesID(playerid, skin_Civ0M);
		SetPlayerClothes(playerid, GetPlayerClothesID(playerid));

		CreateItem(item_Camouflage,
			x + floatsin(135.0, degrees),
			y + floatcos(135.0, degrees),
			z - FLOOR_OFFSET,
			.rz = r,
			.world = world,
			.interior = interior);
	}
		
	SetItemExtraData(itemid, GetPlayerClothes(playerid));

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
			printf("[DEATH] %p (%d) tentou se reviver, mas n�o est� morto.", playerid, playerid);
			return 1;
		}

		death_Dying[playerid] = false;
		TogglePlayerSpectating(playerid, false);

		// Esconde a tela actual
		CancelSelectTextDraw(playerid);
		TextDrawHideForPlayer(playerid, DeathText);
		TextDrawHideForPlayer(playerid, DeathButton);

		// Mostra a tela de selec��o de personagem
		SetPlayerScreenFade(playerid, FADE_OUT, 255, 25);
		defer ShowCharacterCreationScreen(playerid);
	}

	return 1;
}
/* 
	TODO: Essas textdraws podem simplesmente ser criadas na morte.
	Tem vezes que o jogador nem morre na sessao de jogo

	TODO: Introduzir internacionalizacao
*/
hook OnGameModeInit() {

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

stock GetPlayerAliveTime(playerid) return aliveTime[playerid];
	
stock SetPlayerAliveTime(playerid, time) aliveTime[playerid] = time;

stock GetPlayerDeathCount(playerid) return death_Count[playerid];

stock SetPlayerDeathCount(playerid, dead) death_Count[playerid] = dead;

stock GetPlayerSpree(playerid) return death_Spree[playerid];

stock SetPlayerSpree(playerid, spree) death_Spree[playerid] = spree;