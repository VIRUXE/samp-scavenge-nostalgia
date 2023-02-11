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

forward OnPlayerCreateChar(playerid);
forward OnPlayerSpawnChar(playerid);
forward OnPlayerSpawnNewChar(playerid);


hook OnGameModeInit()
{
	GetSettingFloat("spawn/blood", 100.0, spawn_Blood);
	GetSettingFloat("spawn/food", 80.0, spawn_Food);
	GetSettingFloat("spawn/bleed", 0.0, spawn_Bleed);

	GetSettingFloat("spawn/vipblood", 100.0, spawn_VipBlood);
	GetSettingFloat("spawn/vipfood", 100.0, spawn_VipFood);
	GetSettingFloat("spawn/vipbleed", 0.0, spawn_VipBleed);
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

SpawnLoggedInPlayer(playerid)
{
	if(IsPlayerAlive(playerid))
	{
		new ret = PlayerSpawnExistingCharacter(playerid);

		if(!ret)
		{
			SetPlayerBrightness(playerid, 255);
			return 1;
		}
	}

	PlayerCreateNewCharacter(playerid);
	SetPlayerBrightness(playerid, 255);

	return 0;
}

stock PlayerMapCheck(playerid)
{
	new bool:player_hasMap[MAX_PLAYERS] = false;
	new itemid;

	for(new i; i < INV_MAX_SLOTS; i++)
    {
        itemid = GetInventorySlotItem(playerid, i);
        new ItemType:itemtype = GetItemType(itemid);

        if(itemtype == item_Map) 
            player_hasMap[playerid] = true;
    }

    return player_hasMap[playerid];
}

PrepareForSpawn(playerid)
{
	LoadPlayerHUD(playerid);
	SetPlayerSpawnedState(playerid, true);
	SetCameraBehindPlayer(playerid);
	SetAllWeaponSkills(playerid, 500);

	if(!PlayerMapCheck(playerid))
	{
		GangZoneShowForPlayer(playerid, MiniMapOverlay, 0x000000FF);
	}
	else
	{
		ShowSupplyIconSpawn(playerid);
		WCIconSpawn(playerid);
		HideWatch(playerid);
	}

	CancelSelectTextDraw(playerid);
}

PlayerSpawnExistingCharacter(playerid)
{
	if(IsPlayerSpawned(playerid))
		return 1;

	if(!LoadPlayerChar(playerid))
		return 2;

	new
		Float:x,
		Float:y,
		Float:z,
		Float:r;

	GetPlayerSpawnPos(playerid, x, y, z);
	GetPlayerSpawnRot(playerid, r);

	Streamer_UpdateEx(playerid, x, y, z, 0, 0);
	SetPlayerPos(playerid, x, y, z);
	SetPlayerFacingAngle(playerid, r);

	SetPlayerGender(playerid, GetClothesGender(GetPlayerClothes(playerid)));

	if(GetPlayerWarnings(playerid) > 0)
	{
		if(GetPlayerWarnings(playerid) >= 5)
			SetPlayerWarnings(playerid, 0);

		ChatMsgLang(playerid, YELLOW, "WARNCOUNTER", GetPlayerWarnings(playerid));
	}

	//SetPlayerClothes(playerid, GetPlayerClothesID(playerid));
	
//	if(!IsPlayerVip(playerid))
	FreezePlayer(playerid, gLoginFreezeTime * 1000);
//	else
//	    UnfreezePlayer(playerid);
	    
	PrepareForSpawn(playerid);

	if(GetPlayerStance(playerid) == 1)
	{
		ApplyAnimation(playerid, "SUNBATHE", "PARKSIT_M_OUT", 4.0, 0, 0, 0, 0, 0);
	}
	else if(GetPlayerStance(playerid) == 2)
	{
		ApplyAnimation(playerid, "SUNBATHE", "PARKSIT_M_OUT", 4.0, 0, 0, 0, 0, 0);
	}
	else if(GetPlayerStance(playerid) == 3)
	{
		ApplyAnimation(playerid, "ROB_BANK", "SHP_HandsUp_Scr", 4.0, 0, 1, 1, 1, 0);
	}

	log("[SPAWN] %p spawned existing character at %.1f, %.1f, %.1f (%.1f)", playerid, x, y, z, r);
	
	CallLocalFunction("OnPlayerSpawnChar", "d", playerid);
	
 	ChatMsg(playerid, BLUE, "");
	ChatMsg(playerid, BLUE, " >  Scavenge and Survive (Copyright (C) 2016 Barnaby \"Southclaws\" Keene)");
	ChatMsg(playerid, BLUE, "");
	
	return 0;
}

PlayerCreateNewCharacter(playerid)
{
	log("[NEWCHAR] %p creating new character", playerid);

	SetPlayerPos(playerid, DEFAULT_POS_X + 5, DEFAULT_POS_Y, DEFAULT_POS_Z);
	SetPlayerFacingAngle(playerid, 0.0);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerInterior(playerid, 0);

	SetPlayerCameraLookAt(playerid, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z);
	SetPlayerCameraPos(playerid, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z - 1.0);
	Streamer_UpdateEx(playerid, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z);

	SetPlayerBrightness(playerid, 255);
	TogglePlayerControllable(playerid, false);

	if(IsPlayerLoggedIn(playerid) && GetPlayerTotalSpawns(playerid) > 0) // If they are logged in a have spawned before
	{
		PlayerTextDrawSetString(playerid, ClassButtonMale[playerid], sprintf("~n~%s~n~~n~", ls(playerid, "GENDER_M")));
		PlayerTextDrawSetString(playerid, ClassButtonFemale[playerid], sprintf("~n~%s~n~~n~", ls(playerid, "GENDER_F")));
		PlayerTextDrawShow(playerid, ClassButtonMale[playerid]);
		PlayerTextDrawShow(playerid, ClassButtonFemale[playerid]);
	}
	SelectTextDraw(playerid, 0xFFFFFF88);

	CallLocalFunction("OnPlayerCreateChar", "d", playerid);
}

hook OnPlayerClickPlayerTD(playerid, PlayerText:playertextid)
{
	dbg("global", CORE, "[OnPlayerClickPlayerTD] in /gamemodes/sss/core/player/spawn.pwn");

	if(playertextid == ClassButtonMale[playerid]) PlayerSpawnNewCharacter(playerid, GENDER_MALE);
	else if(playertextid == ClassButtonFemale[playerid]) PlayerSpawnNewCharacter(playerid, GENDER_FEMALE);
}

PlayerSpawnNewCharacter(playerid, gender)
{
	if(IsPlayerSpawned(playerid))
		return 0;

	new name[MAX_PLAYER_NAME];

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	SetPlayerTotalSpawns(playerid, GetPlayerTotalSpawns(playerid) + 1);

	SetAccountLastSpawnTimestamp(name, gettime());
	SetAccountTotalSpawns(name, GetPlayerTotalSpawns(playerid));

	new
		Float:x,
		Float:y,
		Float:z,
		Float:r;

	GenerateSpawnPoint(playerid, x, y, z, r);
	Streamer_UpdateEx(playerid, x, y, z, 0, 0);
	SetPlayerPos(playerid, x, y, z);
	SetPlayerFacingAngle(playerid, r);
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerInterior(playerid, 0);

	if(gender == GENDER_MALE)
	{
		switch(random(6))
		{
			case 0: SetPlayerClothesID(playerid, skin_Civ0M);
			case 1: SetPlayerClothesID(playerid, skin_Civ1M);
			case 2: SetPlayerClothesID(playerid, skin_Civ2M);
			case 3: SetPlayerClothesID(playerid, skin_Civ3M);
			case 4: SetPlayerClothesID(playerid, skin_Civ4M);
			case 5: SetPlayerClothesID(playerid, skin_MechM);
			case 6: SetPlayerClothesID(playerid, skin_BikeM);
		}
	}
	else
	{
		switch(random(6))
		{
			case 0: SetPlayerClothesID(playerid, skin_Civ0F);
			case 1: SetPlayerClothesID(playerid, skin_Civ1F);
			case 2: SetPlayerClothesID(playerid, skin_Civ2F);
			case 3: SetPlayerClothesID(playerid, skin_Civ3F);
			case 4: SetPlayerClothesID(playerid, skin_Civ4F);
			case 5: SetPlayerClothesID(playerid, skin_ArmyF);
			case 6: SetPlayerClothesID(playerid, skin_IndiF);
		}
	}

	if(PlayerVip[playerid])
	{
		SetPlayerHP(playerid, spawn_VipBlood);
		SetPlayerFP(playerid, spawn_VipFood);
		SetPlayerBleedRate(playerid, spawn_VipBleed);
	}
	else
	{
		SetPlayerHP(playerid, spawn_Blood);
		SetPlayerFP(playerid, spawn_Food);
		SetPlayerBleedRate(playerid, spawn_Bleed);
	}

	SetPlayerAP(playerid, 0.0);
	SetPlayerClothes(playerid, GetPlayerClothesID(playerid));
	SetPlayerGender(playerid, gender);

	SetPlayerAliveState(playerid, true);

//    if(!IsPlayerVip(playerid))
	FreezePlayer(playerid, gLoginFreezeTime * 1000);
//    else
//	    UnfreezePlayer(playerid);
	    
	PrepareForSpawn(playerid);

	PlayerTextDrawHide(playerid, ClassButtonMale[playerid]);
	PlayerTextDrawHide(playerid, ClassButtonFemale[playerid]);

	SetPlayerBrightness(playerid, 255);

	CallLocalFunction("OnPlayerSpawnNewChar", "d", playerid);
    
	log("[SPAWN] %p spawned new character at %.1f, %.1f, %.1f (%.1f)", playerid, x, y, z, r);

    //if(!IsPlayerVip(playerid))
		//defer CheckBug(playerid);
	return 1;
}


timer CheckBug[3000](playerid){
	if(GetInventoryFreeSlots(playerid) != INV_MAX_SLOTS)
	    defer DestroyPlayerInventoryItems(playerid);
	
	if(GetPlayerItem(playerid) != INVALID_ITEM_ID)
		DestroyItem(GetPlayerItem(playerid));
		
	if(GetPlayerBagItem(playerid) != INVALID_ITEM_ID)
    	DestroyPlayerBag(playerid);

	if(GetPlayerHolsterItem(playerid) != INVALID_ITEM_ID)
	    DestroyItem(GetPlayerHolsterItem(playerid));
}

/*==============================================================================

	Interface

==============================================================================*/
	
// spawn_State
stock IsPlayerSpawned(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return spawn_State[playerid];
}

stock SetPlayerSpawnedState(playerid, bool:st)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	spawn_State[playerid] = st;

	return 1;
}

// spawn_PosX
// spawn_PosY
// spawn_PosZ
stock GetPlayerSpawnPos(playerid, &Float:x, &Float:y, &Float:z)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	x = spawn_PosX[playerid];
	y = spawn_PosY[playerid];
	z = spawn_PosZ[playerid];

	return 1;
}

stock SetPlayerSpawnPos(playerid, Float:x, Float:y, Float:z)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	spawn_PosX[playerid] = x;
	spawn_PosY[playerid] = y;
	spawn_PosZ[playerid] = z;

	return 1;
}

// spawn_RotZ
stock GetPlayerSpawnRot(playerid, &Float:r)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	r = spawn_RotZ[playerid];

	return 1;
}

stock SetPlayerSpawnRot(playerid, Float:r)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	spawn_RotZ[playerid] = r;

	return 1;
}

IsAtDefaultPos(Float:x, Float:y, Float:z)
{
	if(Distance(x, y, z, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z) < 10.0)
		return 1;

	return 0;
}

IsAtConnectionPos(Float:x, Float:y, Float:z)
{
	if(1133.05 < x < 1133.059999 && -2038.40 < y < -2038.409999 && 69.09 < z < 69.099999)
		return 1;

	return 0;
}