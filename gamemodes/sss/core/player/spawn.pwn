#include <YSI\y_hooks>

enum e_item_object
{
	ItemType:e_itmobj_type,
	e_itmobj_exdata
}


static
// properties given to players on spawn
Float:		spawn_Blood,
Float:		spawn_Food,
Float:		spawn_Bleed,


// properties given to vip on spawn
Float:		spawn_VipBlood,
Float:		spawn_VipFood,
Float:		spawn_VipBleed;

static
bool:		spawn_State[MAX_PLAYERS] = {false, ...},
Float:		spawn_PosX[MAX_PLAYERS],
Float:		spawn_PosY[MAX_PLAYERS],
Float:		spawn_PosZ[MAX_PLAYERS],
Float:		spawn_RotZ[MAX_PLAYERS];

new
PlayerText:	ClassButtonMale[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:	ClassButtonFemale[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...};

forward OnPlayerEnterCharacterCreation(playerid);
forward OnPlayerSpawnCharacter(playerid);
forward OnPlayerSpawnNewChar(playerid);


hook OnGameModeInit()
{
	new Node:spawn, Node:node;

	log("[SPAWN] Carregando configurações de spawn...");

	JSON_GetObject(Settings, "player", node);
	JSON_GetObject(node, "spawn", spawn);

	JSON_GetObject(spawn, "bleed", node);
	JSON_GetFloat(node, "normal", spawn_Bleed);
	JSON_GetFloat(node, "vip", spawn_VipBleed);

	JSON_GetObject(spawn, "blood", node);
	JSON_GetFloat(node, "normal", spawn_Blood);
	JSON_GetFloat(node, "vip", spawn_VipBlood);

	JSON_GetObject(spawn, "food", node);
	JSON_GetFloat(node, "normal", spawn_Food);
	JSON_GetFloat(node, "vip", spawn_VipFood);

	log("[SPAWN][SETTINGS] Taxa de Sangramento: %.2f (vip: %.2f)", spawn_Bleed, spawn_VipBleed);
	log("[SPAWN][SETTINGS] Quantidade de Sangue: %.2f (vip: %.2f)", spawn_Blood, spawn_VipBlood);
	log("[SPAWN][SETTINGS] Taxa de Fome: %.2f (vip: %f)", spawn_Food, spawn_VipFood);
}

hook OnPlayerConnect(playerid)
{
	dbg("global", CORE, "[OnPlayerConnect] in /gamemodes/sss/core/player/spawn.pwn");

	spawn_State[playerid] = false;

	ClassButtonMale[playerid]		=CreatePlayerTextDraw(playerid, 250.000000, 200.000000, "~n~Male~n~~n~");
	PlayerTextDrawAlignment			(playerid, ClassButtonMale[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, ClassButtonMale[playerid], 255);
	PlayerTextDrawFont				(playerid, ClassButtonMale[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, ClassButtonMale[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, ClassButtonMale[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, ClassButtonMale[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, ClassButtonMale[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, ClassButtonMale[playerid], 1);
	PlayerTextDrawUseBox			(playerid, ClassButtonMale[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, ClassButtonMale[playerid], 255);
	PlayerTextDrawTextSize			(playerid, ClassButtonMale[playerid], 44.000000, 100.000000);
	PlayerTextDrawSetSelectable		(playerid, ClassButtonMale[playerid], true);

	ClassButtonFemale[playerid]		=CreatePlayerTextDraw(playerid, 390.000000, 200.000000, "~n~Female~n~~n~");
	PlayerTextDrawAlignment			(playerid, ClassButtonFemale[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, ClassButtonFemale[playerid], 255);
	PlayerTextDrawFont				(playerid, ClassButtonFemale[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, ClassButtonFemale[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, ClassButtonFemale[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, ClassButtonFemale[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, ClassButtonFemale[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, ClassButtonFemale[playerid], 1);
	PlayerTextDrawUseBox			(playerid, ClassButtonFemale[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, ClassButtonFemale[playerid], 255);
	PlayerTextDrawTextSize			(playerid, ClassButtonFemale[playerid], 44.000000, 100.000000);
	PlayerTextDrawSetSelectable		(playerid, ClassButtonFemale[playerid], true);
}

stock PlayerMapCheck(playerid)
{
	new bool:player_hasMap[MAX_PLAYERS] = false;

	for(new i; i < INV_MAX_SLOTS; i++)
    {
        new ItemType:itemtype = GetItemType(GetInventorySlotItem(playerid, i));

        if(itemtype == item_Map) player_hasMap[playerid] = true;
    }

    return player_hasMap[playerid];
}

PrepareForSpawn(playerid)
{
	printf("PrepareForSpawn(%d)", playerid);

	ToggleHud(playerid, true);

	if(IsPlayerInTutorial(playerid)) SetPlayerVirtualWorld(playerid, 0);

	if(!PlayerMapCheck(playerid))
		GangZoneShowForPlayer(playerid, MiniMapOverlay, 0x000000FF);
	else 
	{
		ShowSupplyIconSpawn(playerid);
		WCIconSpawn(playerid);
		ToggleHudComponent(playerid, HUD_COMPONENT_RADAR, false);
	}
	
	new hour, minute;
	gettime(hour, minute);

	SetPlayerTime(playerid, hour, minute);
	SetPlayerWeather(playerid, GetSettingInt("world/weather")); 

	SetPlayerSpawnedState(playerid, true);
	SetCameraBehindPlayer(playerid);
	SetAllWeaponSkills(playerid, 500);

	CancelSelectTextDraw(playerid);
}

SpawnCharacter(playerid)
{
	if(IsPlayerSpawned(playerid)) return 1;
	if(!LoadPlayerChar(playerid)) return 2;

	new Float:x, Float:y, Float:z, Float:r;

	GetPlayerSpawnPos(playerid, x, y, z);
	GetPlayerSpawnRot(playerid, r);

	Streamer_UpdateEx(playerid, x, y, z, 0, 0);
	SetPlayerPos(playerid, x, y, z);
	SetPlayerFacingAngle(playerid, r);

	SetPlayerGender(playerid, GetClothesGender(GetPlayerClothes(playerid)));

	if(GetPlayerWarnings(playerid) > 0)
	{
		if(GetPlayerWarnings(playerid) >= 5) SetPlayerWarnings(playerid, 0);

		ChatMsg(playerid, YELLOW, "WARNCOUNTER", GetPlayerWarnings(playerid));
	}

	// Congelar se não for admin nível 6
	if(GetPlayerAdminLevel(playerid) != 6)
		defer UnfreezePlayer_delay(playerid, SEC(gLoginFreezeTime), 0);
	else
		UnfreezePlayer(playerid);

	PrepareForSpawn(playerid);

	if(GetPlayerStance(playerid) == 1)
		ApplyAnimation(playerid, "SUNBATHE", "PARKSIT_M_OUT", 4.0, 0, 0, 0, 0, 0);
	else if(GetPlayerStance(playerid) == 2)
		ApplyAnimation(playerid, "SUNBATHE", "PARKSIT_M_OUT", 4.0, 0, 0, 0, 0, 0);
	else if(GetPlayerStance(playerid) == 3)
		ApplyAnimation(playerid, "ROB_BANK", "SHP_HandsUp_Scr", 4.0, 0, 1, 1, 1, 0);

	log("[SPAWN] %p (%d) spawnou personagem existente em %.1f, %.1f, %.1f (%.1f)", playerid, playerid, x, y, z, r);
	
 	ChatMsg(playerid, BLUE, "");
	ChatMsg(playerid, BLUE, " >  Scavenge and Survive (Copyright (C) 2016 Barnaby \"Southclaws\" Keene)");
	ChatMsg(playerid, BLUE, "");
	
	CallLocalFunction("OnPlayerSpawnCharacter", "d", playerid);

	return 0;
}

ShowCharacterCreationScreen(playerid)
{
	log("[CHARACTER] %p (%d) vai criar um novo personagem.", playerid, playerid);

	SetPlayerPos(playerid, DEFAULT_POS_X + 5, DEFAULT_POS_Y, DEFAULT_POS_Z);
	SetPlayerFacingAngle(playerid, 0.0);
	SetPlayerInterior(playerid, 0);

	SetPlayerCameraLookAt(playerid, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z);
	SetPlayerCameraPos(playerid, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z - 1.0);
	Streamer_UpdateEx(playerid, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z);

	SetPlayerScreenFade(playerid, 0);
	TogglePlayerControllable(playerid, false);

	if(IsPlayerLoggedIn(playerid))
	{
		PlayerTextDrawSetString(playerid, ClassButtonMale[playerid], sprintf("~n~%s~n~~n~", ls(playerid, "player/gender/male")));
		PlayerTextDrawSetString(playerid, ClassButtonFemale[playerid], sprintf("~n~%s~n~~n~", ls(playerid, "player/gender/female")));
		PlayerTextDrawShow(playerid, ClassButtonMale[playerid]);
		PlayerTextDrawShow(playerid, ClassButtonFemale[playerid]);
	}
	SelectTextDraw(playerid, 0xFFFFFF88);

	CallLocalFunction("OnPlayerEnterCharacterCreation", "d", playerid);
}

hook OnPlayerClickPlayerTD(playerid, PlayerText:playertextid)
{
	dbg("global", CORE, "[OnPlayerClickPlayerTD] in /gamemodes/sss/core/player/spawn.pwn");

	if(playertextid == ClassButtonMale[playerid])
		CreateNewCharacter(playerid, GENDER_MALE);
	else if(playertextid == ClassButtonFemale[playerid])
		CreateNewCharacter(playerid, GENDER_FEMALE);
}

CreateNewCharacter(playerid, gender)
{
	if(IsPlayerSpawned(playerid)) return 0;

	PlayerTextDrawHide(playerid, ClassButtonMale[playerid]);
	PlayerTextDrawHide(playerid, ClassButtonFemale[playerid]);

	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	SetPlayerTotalSpawns(playerid, GetPlayerTotalSpawns(playerid) + 1);

	SetAccountLastSpawnTimestamp(name, gettime());
	SetAccountTotalSpawns(name, GetPlayerTotalSpawns(playerid));

	new Float:x, Float:y, Float:z, Float:r;

	GenerateSpawnPoint(playerid, x, y, z, r);
	Streamer_UpdateEx(playerid, x, y, z, 0, 0);
	SetPlayerPos(playerid, x, y, z);
	SetPlayerFacingAngle(playerid, r);
	SetPlayerInterior(playerid, 0);

	new skin;
	if(gender == GENDER_MALE)
	{
		switch(random(6))
		{
			case 0: skin = skin_Civ0M;
			case 1: skin = skin_Civ1M;
			case 2: skin = skin_Civ2M;
			case 3: skin = skin_Civ3M;
			case 4: skin = skin_Civ4M;
			case 5: skin = skin_MechM;
			case 6: skin = skin_BikeM;
		}
	}
	else
	{
		switch(random(6))
		{
			case 0: skin = skin_Civ0F;
			case 1: skin = skin_Civ1F;
			case 2: skin = skin_Civ2F;
			case 3: skin = skin_Civ3F;
			case 4: skin = skin_Civ4F;
			case 5: skin = skin_ArmyF;
			case 6: skin = skin_IndiF;
		}
	}
	SetPlayerClothesID(playerid, skin);

	SetPlayerHP(playerid, 		 IsPlayerVip(playerid) ? spawn_VipBlood : spawn_Blood);
	SetPlayerFP(playerid, 		 IsPlayerVip(playerid) ? spawn_VipFood  : spawn_Food);
	SetPlayerBleedRate(playerid, IsPlayerVip(playerid) ? spawn_VipBleed : spawn_Bleed);

	SetPlayerAP(playerid, 0.0);
	SetPlayerClothes(playerid, GetPlayerClothesID(playerid));
	SetPlayerGender(playerid, gender);

//	GiveWorldItemToPlayer(playerid, CreateItem(item_Wrench));

	SetPlayerAliveState(playerid, true);

	// Congelar se não for admin nível 6
	if(GetPlayerAdminLevel(playerid) != 6)
		defer UnfreezePlayer_delay(playerid, SEC(gLoginFreezeTime), 0);
	else
		UnfreezePlayer(playerid);
    
	PrepareForSpawn(playerid);

	SetPlayerScreenFade(playerid, 255);

	log("[SPAWN] %p (%d) criou um novo personagem em %.2f, %.2f, %.2f (%.2f)", playerid, playerid, x, y, z, r);
    
	CallLocalFunction("OnPlayerSpawnNewChar", "d", playerid);

	return 1;
}

// ? Que merda é essa?
timer CheckBug[SEC(3)](playerid) {
	if(GetInventoryFreeSlots(playerid) != INV_MAX_SLOTS) defer DestroyPlayerInventoryItems(playerid);
	
	if(GetPlayerItem(playerid) != INVALID_ITEM_ID) DestroyItem(GetPlayerItem(playerid));
		
	if(GetPlayerBagItem(playerid) != INVALID_ITEM_ID) DestroyPlayerBag(playerid);

	if(GetPlayerHolsterItem(playerid) != INVALID_ITEM_ID) DestroyItem(GetPlayerHolsterItem(playerid));
}

/*==============================================================================

	Interface

==============================================================================*/
	
// spawn_State
stock IsPlayerSpawned(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;

	return spawn_State[playerid];
}

stock SetPlayerSpawnedState(playerid, bool:st)
{
	if(!IsPlayerConnected(playerid)) return 0;

	spawn_State[playerid] = st;

	return 1;
}

stock GetPlayerSpawnPos(playerid, &Float:x, &Float:y, &Float:z)
{
	if(!IsPlayerConnected(playerid)) return 0;

	x = spawn_PosX[playerid];
	y = spawn_PosY[playerid];
	z = spawn_PosZ[playerid];

	return 1;
}

stock SetPlayerSpawnPos(playerid, Float:x, Float:y, Float:z)
{
	if(!IsPlayerConnected(playerid)) return 0;

	spawn_PosX[playerid] = x;
	spawn_PosY[playerid] = y;
	spawn_PosZ[playerid] = z;

	return 1;
}

// spawn_RotZ
stock GetPlayerSpawnRot(playerid, &Float:r)
{
	if(!IsPlayerConnected(playerid)) return 0;

	r = spawn_RotZ[playerid];

	return 1;
}

stock SetPlayerSpawnRot(playerid, Float:r)
{
	if(!IsPlayerConnected(playerid)) return 0;

	spawn_RotZ[playerid] = r;

	return 1;
}

IsAtDefaultPos(Float:x, Float:y, Float:z)
{
	if(Distance(x, y, z, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z) < 10.0) return 1;

	return 0;
}

IsAtConnectionPos(Float:x, Float:y, Float:z)
{
	if(1133.05 < x < 1133.059999 && -2038.40 < y < -2038.409999 && 69.09 < z < 69.099999) return 1;

	return 0;
}