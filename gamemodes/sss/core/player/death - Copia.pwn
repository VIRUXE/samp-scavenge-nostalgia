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
		PlayerMortes[MAX_PLAYERS],
		Spree[MAX_PLAYERS],
bool:	ChatKill[MAX_PLAYERS];

hook OnPlayerConnect(playerid)
{
	dbg("global", CORE, "[OnPlayerConnect] in /gamemodes/sss/core/player/death.pwn");

    death_Dying[playerid] = false;

	death_LastKilledBy[playerid][0] = EOS;
	death_LastKilledById[playerid] = INVALID_PLAYER_ID;
    ChatKill[playerid] = false;
	new namep[24];
	GetPlayerName(playerid, namep, 24);
    SetPlayerScore(playerid,  dini_Int("score.ini",namep));
    PlayerMortes[playerid] = dini_Int("mortes.ini",namep);
    Spree[playerid] = dini_Int("spree.ini",namep);
	if(GetPlayerScore(playerid) > 100){
	    SetPlayerColor(playerid, 0x001a4400);
	}
}


hook OnPlayerOpenInventory(playerid)
{
    if(!ChatKill[playerid])
		HideChatKill(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenContainer(playerid, containerid)
{
    if(!ChatKill[playerid])
		HideChatKill(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}



stock HideChatKill(playerid){
    SendDeathMessageToPlayer(playerid, -1, -1, 0);
    SendDeathMessageToPlayer(playerid, -1, -1, 0);
    SendDeathMessageToPlayer(playerid, -1, -1, 0);
    SendDeathMessageToPlayer(playerid, -1, -1, 0);
    SendDeathMessageToPlayer(playerid, -1, -1, 0);
	return 1;
}


CMD:chatkill(playerid){
    ChatKill[playerid] = !ChatKill[playerid];
    if(!ChatKill[playerid]){
        HideChatKill(playerid);
		ChatMsg(playerid, RED, " > Chat Kill desativado.");
    }
    else {
        HidePlayerKeyActionUI(playerid);
		ChatMsg(playerid, GREEN, " > Chat Kill ativado.");
	}
	return 1;
}

hook OnPlayerSave(playerid, filename[])
{
	modio_push(filename, _T<C,K,I,L>, 1, ChatKill[playerid]);
}

hook OnPlayerLoad(playerid, filename[])
{
	modio_read(filename, _T<C,K,I,L>, 1, ChatKill[playerid]);
}

IsPlayerChatKill(playerid){
	return ChatKill[playerid];
}

hook OnPlayerDisconnect(playerid, reason)
{
    death_Dying[playerid] = false;
    new namep[24];
	GetPlayerName(playerid, namep, 24);
    dini_IntSet("score.ini",namep, GetPlayerScore(playerid));
    dini_IntSet("mortes.ini",namep,PlayerMortes[playerid]);
    dini_IntSet("spree.ini",namep,Spree[playerid]);
}

stock ResetPlayerSpree(name[]){
    dini_IntSet("spree.ini",name,0);
    dini_IntSet("mortes.ini",name, dini_Int("mortes.ini",name) + 2);
	return 1;
}

stock GetPlayerMortes(playerid)
{
	return PlayerMortes[playerid];
}

stock GetPlayerSpree(playerid)
{
	return Spree[playerid];
}

public OnPlayerDeath(playerid, killerid, reason)
{
	if(IsPlayerConnected(killerid) && !IsPlayerSpawned(killerid))
	{
	    return -1;
	}

    if(GetTickCountDifference(GetTickCount(), death_LastDeath[playerid]) < 1000)
				return -1;

	if(!IsPlayerNPC(playerid))
	{
	    if(GetTickCountDifference(GetTickCount(), GetPlayerServerJoinTick(playerid)) > 6000)
  		{
			death_LastDeath[playerid] = GetTickCount();

	        if(!IsPlayerNPC(killerid))
				killerid = INVALID_PLAYER_ID;

			if(killerid == INVALID_PLAYER_ID)
			{
				killerid = GetLastHitById(playerid);

				if(!IsPlayerConnected(killerid))
					killerid = INVALID_PLAYER_ID;
			}

			_OnDeath(playerid, killerid);
		}

	}
	return 1;
}

_OnDeath(playerid, killerid)
{
	if(!IsPlayerAlive(playerid) || IsPlayerOnAdminDuty(playerid))
	{
		return 0;
	}

	new
		deathreason = GetLastHitByWeapon(playerid),
		deathreasonstring[256];

	death_Dying[playerid] = true;
	SetPlayerSpawnedState(playerid, false);
	SetPlayerAliveState(playerid, false);

	GetPlayerPos(playerid, death_PosX[playerid], death_PosY[playerid], death_PosZ[playerid]);
	GetPlayerFacingAngle(playerid, death_RotZ[playerid]);

	if(IsPlayerInAnyVehicle(playerid))
	{
		RemovePlayerFromVehicle(playerid);
		TogglePlayerSpectating(playerid, true);
		TogglePlayerSpectating(playerid, false);
		death_PosZ[playerid] += 0.5;
	}

	HideWatch(playerid);
	DropItems(playerid, death_PosX[playerid], death_PosY[playerid], death_PosZ[playerid], death_RotZ[playerid], true);
	RemovePlayerWeapon(playerid);
	RemoveAllDrugs(playerid);
	SpawnPlayer(playerid);
	foreach(new i : Player){
	    if(ChatKill[i])
 			SendDeathMessageToPlayer(i, killerid, playerid, GetPlayerWeapon(killerid));
 	}
 	
	KillPlayer(playerid, killerid, deathreason);

	if(IsPlayerConnected(killerid))
	{
		log("[KILL] %p killed %p with %d at %f, %f, %f (%f)", killerid, playerid, deathreason, death_PosX[playerid], death_PosY[playerid], death_PosZ[playerid], death_RotZ[playerid]);

        SetPlayerScore(killerid, GetPlayerScore(killerid) + 1);
        PlayerMortes[playerid] ++;
        
        //if(Spree[playerid] > 2)
            //ChatMsgAll(0xFA0505FF, "[SPREE]: {E8F21F}%p morreu mas levou {FA0505}%d{E8F21F} com ele!", playerid, Spree[playerid]);
            
        Spree[playerid] = 0;
        Spree[killerid] ++;

        /*switch(Spree[killerid])
		{
			case 2, 4, 6, 7, 9, 10, 12, 14, 16, 18, 20, 25:
			{
        		ChatMsgAll(0xFA0505FF, "[SPREE]: {E8F21F}%p já mandou {FA0505}%d{E8F21F} pra cova!", killerid, Spree[killerid]);
			}
		}*/

		GetPlayerName(killerid, death_LastKilledBy[playerid], MAX_PLAYER_NAME);
		death_LastKilledById[playerid] = killerid;
        SetLastHitById(playerid, INVALID_PLAYER_ID);
		switch(deathreason)
		{
			case 0..3, 5..7, 10..15:
				deathreasonstring = "Espancado até a morte.";

			case 4:
				deathreasonstring = "Sofreu pequenos cortes no tronco, possivelmente de uma faca.";

			case 8:
				deathreasonstring = "Grandes lacerações cobrem o tronco e a cabeça, parece uma espada finamente afiada.";

			case 9:
				deathreasonstring = "Há pedaços em todos os lugares, provavelmente sofreu com uma serra elétrica.";

			case 16, 39, 35, 36, 255:
				deathreasonstring = "Sofreu uma concussão maciça devido a uma explosão.";

			case 18, 37:
				deathreasonstring = "Todo o corpo está carbonizado e queimado.";

			case 22..34, 38:
				deathreasonstring = "Morreu de perda de sangue causada pelo que parece balas.";

			case 41, 42:
				deathreasonstring = "Esse corpo foi pulverizado e sufocado por uma substância de alta pressão.";

			case 44, 45:
				deathreasonstring = "De alguma forma, eles foram mortos por óculos.";

			case 43:
				deathreasonstring = "De alguma forma, eles foram mortos por uma câmera.";

			default:
				deathreasonstring = "Sangrou até a morte";
		}
	}
	else
	{
		log("[DEATH] %p died because of %d at %f, %f, %f (%f)", playerid, deathreason, death_PosX[playerid], death_PosY[playerid], death_PosZ[playerid], death_RotZ[playerid]);

		death_LastKilledBy[playerid][0] = EOS;
		death_LastKilledById[playerid] = INVALID_PLAYER_ID;

		switch(deathreason)
		{
			case 53:
				deathreasonstring = "Se afogou";

			case 54:
				deathreasonstring = "A maioria dos ossos estão quebrados, parece que eles caíram de uma grande altura.";

			case 255:
				deathreasonstring = "Sofreu uma concussão maciça devido a uma explosão.";

			default:
				deathreasonstring = "Razão da morte desconhecida.";
		}
	}

	CreateGravestone(playerid, deathreasonstring, death_PosX[playerid], death_PosY[playerid], death_PosZ[playerid] - FLOOR_OFFSET, death_RotZ[playerid]);

    SavePlayerData(playerid);
	return 1;
}

DropItems(playerid, Float:x, Float:y, Float:z, Float:r, bool:death)
{
	new
		itemid,
		interior = GetPlayerInterior(playerid),
		world = GetPlayerVirtualWorld(playerid);

	/*
		Held item
	*/

	itemid = GetPlayerItem(playerid);

	if(IsValidItem(itemid))
	{
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

	if(IsValidItem(itemid))
	{
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

	for(new i; i < INV_MAX_SLOTS; i++)
	{
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

	if(IsValidItem(itemid))
	{
		RemovePlayerBag(playerid);

		SetItemPos(itemid, x + floatsin(180.0, degrees), y + floatcos(180.0, degrees), z - FLOOR_OFFSET);
		SetItemRot(itemid, 0.0, 0.0, r, true);
		SetItemInterior(itemid, interior);
		SetItemWorld(itemid, world);
	}

	/*
		Head-wear item
	*/

	itemid = RemovePlayerHatItem(playerid);

	if(IsValidItem(itemid))
	{
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

	if(IsValidItem(itemid))
	{
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

	if(GetPlayerAP(playerid) > 0.0)
	{
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

	if(!death)
		return;

	/*
		Handcuffs
	*/

	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED)
	{
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

	SetItemExtraData(itemid, GetPlayerClothes(playerid));

	return;
}

hook OnPlayerSpawn(playerid)
{
	dbg("global", CORE, "[OnPlayerSpawn] in /gamemodes/sss/core/player/death.pwn");

	if(IsPlayerDead(playerid))
	{
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
		SetPlayerScreenFade(playerid, 200);
		TextDrawShowForPlayer(playerid, DeathText);
		TextDrawShowForPlayer(playerid, DeathButton);
	}
}

timer SetDeathCamera[500](playerid)
{
	if(!IsPlayerDead(playerid))
		return;

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

hook OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	dbg("global", CORE, "[OnPlayerClickTextDraw] in /gamemodes/sss/core/player/death.pwn");

	if(clickedid == DeathButton)
	{
		if(!IsPlayerDead(playerid))
			return 1;

		death_Dying[playerid] = false;
		TogglePlayerSpectating(playerid, false);
		CancelSelectTextDraw(playerid);
		TextDrawHideForPlayer(playerid, DeathText);
		TextDrawHideForPlayer(playerid, DeathButton);
		SpawnLoggedInPlayer(playerid);
	}

	return 1;
}

hook OnGameModeInit()
{
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

	DeathButton					=TextDrawCreate(320.000000, 323.000000, ">Jogar novamente<");
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


stock IsPlayerDead(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return death_Dying[playerid];
}

stock GetPlayerDeathPos(playerid, &Float:x, &Float:y, &Float:z)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	x = death_PosX[playerid];
	y = death_PosY[playerid];
	z = death_PosZ[playerid];

	return 1;
}

stock GetPlayerDeathRot(playerid, &Float:r)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	r = death_RotZ;

	return 1;
}

// death_LastKilledBy
stock GetLastKilledBy(playerid, name[MAX_PLAYER_NAME])
{
	if(!IsPlayerConnected(playerid))
		return 0;

	name = death_LastKilledBy[playerid];

	return 1;
}

// death_LastKilledById
stock GetLastKilledById(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return death_LastKilledById[playerid];
}
