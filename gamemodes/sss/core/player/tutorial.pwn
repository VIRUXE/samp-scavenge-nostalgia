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

#define MAX_TUTORIAL_ITEMS      (22)

static
PlayerText:	ClassButtonTutorial		[MAX_PLAYERS],
bool:		PlayerInTutorial		[MAX_PLAYERS],
			PlayerTutorialVehicle	[MAX_PLAYERS],
			PlayerTutorial_Item     [MAX_TUTORIAL_ITEMS][MAX_PLAYERS],
			PlayerTutorial_Pickup   [MAX_TUTORIAL_ITEMS][MAX_PLAYERS],
bool:		PlayerTutorial_VozInv   [MAX_PLAYERS],
bool:		PlayerTutorial_VozCnt   [MAX_PLAYERS];

hook OnPlayerConnect(playerid)
{
	ClassButtonTutorial[playerid]	=CreatePlayerTextDraw(playerid, 320.000000, 300.000000, ls(playerid, "TUTORPROMPT"));
	PlayerTextDrawAlignment			(playerid, ClassButtonTutorial[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, ClassButtonTutorial[playerid], 255);
	PlayerTextDrawFont				(playerid, ClassButtonTutorial[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, ClassButtonTutorial[playerid], 0.45, 3.000000);
	PlayerTextDrawColor				(playerid, ClassButtonTutorial[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, ClassButtonTutorial[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, ClassButtonTutorial[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, ClassButtonTutorial[playerid], 1);
	PlayerTextDrawUseBox			(playerid, ClassButtonTutorial[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, ClassButtonTutorial[playerid], 255);
	PlayerTextDrawTextSize			(playerid, ClassButtonTutorial[playerid], 34.000000, 155.000000);
	PlayerTextDrawSetSelectable		(playerid, ClassButtonTutorial[playerid], true);
	PlayerTextDrawHide(playerid, ClassButtonTutorial[playerid]);
}

hook OnPlayerSpawnChar(playerid)
{
	dbg("global", CORE, "[OnPlayerSpawnChar] in /gamemodes/sss/core/player/tutorial.pwn");

	PlayerTextDrawHide(playerid, ClassButtonTutorial[playerid]);
}

hook OnPlayerSpawnNewChar(playerid)
{
	PlayerTextDrawHide(playerid, ClassButtonTutorial[playerid]);
}

hook OnPlayerCreateChar(playerid)
{
	PlayerTextDrawShow(playerid, ClassButtonTutorial[playerid]);
}

EnterTutorial(playerid) {
	log("[TUTORIAL] Jogador %p (%d) entrou no tutorial.", playerid, playerid);

	new virtualworld = playerid + 1;

	// Um armazém vermelho em Las Venturas
	SetPlayerPos(playerid, 928.8049,2072.3174,10.8203);
	SetPlayerFacingAngle(playerid, 269.3244);
	SetPlayerVirtualWorld(playerid, virtualworld);

	// Define uma roupa aleatória
	new skin;
	switch(random(14))
	{
		case 0 : skin = skin_Civ0M;
		case 1 : skin = skin_Civ1M;
		case 2 : skin = skin_Civ2M;
		case 3 : skin = skin_Civ3M;
		case 4 : skin = skin_Civ4M;
		case 5 : skin = skin_MechM;
		case 6 : skin = skin_BikeM;
		case 7 : skin = skin_Civ0F;
		case 8 : skin = skin_Civ1F;
		case 9 : skin = skin_Civ2F;
		case 10: skin = skin_Civ3F;
		case 11: skin = skin_Civ4F;
		case 12: skin = skin_ArmyF;
		case 13: skin = skin_IndiF;
	}
	SetPlayerClothesID(playerid, skin);

	SetPlayerHP(playerid, 100.0);
	SetPlayerAP(playerid, 0.0);
	SetPlayerFP(playerid, 80.0);
	SetPlayerClothes(playerid, GetPlayerClothesID(playerid));
	SetPlayerGender(playerid, GetClothesGender(GetPlayerClothesID(playerid)));
	SetPlayerBleedRate(playerid, 0.0);

	SetPlayerAliveState(playerid, false);
	SetPlayerSpawnedState(playerid, false);

	FreezePlayer(playerid, gLoginFreezeTime * 1000);
	PrepareForSpawn(playerid);

	PlayerInTutorial[playerid] = true;
	
	PlayerTutorial_VozInv[playerid] = false;
	PlayerTutorial_VozCnt[playerid] = false;

	//	Vehicle
	PlayerTutorialVehicle[playerid] = CreateWorldVehicle(veht_Bobcat, 949.1641,2060.3074,10.8203, 272.1444, random(100), random(100), .world = virtualworld);
	SetVehicleHealth(PlayerTutorialVehicle[playerid], 321.9);
	SetVehicleFuel(PlayerTutorialVehicle[playerid], frandom(1.0));
	FillContainerWithLoot(GetVehicleContainer(PlayerTutorialVehicle[playerid]), 5, GetLootIndexFromName("world_civilian"));
	SetVehicleDamageData(PlayerTutorialVehicle[playerid],
		encode_panels(random(4), random(4), random(4), random(4), random(4), random(4), random(4)),
		encode_doors(random(5), random(5), random(5), random(5)),
		encode_lights(random(2), random(2), random(2), random(2)),
		encode_tires(0, 1, 1, 0)
	);

	//	Items
	PlayerTutorial_Item[0][playerid]    = CreateItem(item_CorPanel, 975.1069,2071.6677,9.8603, .rz = frandom(360.0), .world = virtualworld);
	// PlayerTutorial_Pickup[0][playerid]  = CreatePickup(1559, 8, 975.1069,2071.6677,9.8603, virtualworld);
	PlayerTutorial_Item[1][playerid]    = CreateItem(item_CorPanel, 973.7677,2075.0117,9.8603, .rz = frandom(360.0), .world = virtualworld);
	// PlayerTutorial_Pickup[1][playerid]  = CreatePickup(1559, 8, 973.7677,2075.0117,9.8603, virtualworld);
	PlayerTutorial_Item[2][playerid]    = CreateItem(item_CorPanel, 973.7151,2067.4258,9.8603, .rz = frandom(360.0), .world = virtualworld);
	// PlayerTutorial_Pickup[2][playerid]  = CreatePickup(1559, 8, 973.7151,2067.4258,9.8603, virtualworld);
	PlayerTutorial_Item[3][playerid]    = CreateItem(item_Wheel, 951.7727,2068.0540,9.8603, .rz = frandom(360.0), .world = virtualworld);
	// PlayerTutorial_Pickup[3][playerid]  = CreatePickup(1559, 8, 951.7727,2068.0540,9.8603, virtualworld);
	PlayerTutorial_Item[4][playerid]    = CreateItem(item_Wheel, 954.4612,2068.2312,9.8603, .rz = frandom(360.0), .world = virtualworld);
	// PlayerTutorial_Pickup[4][playerid]  = CreatePickup(1559, 8, 954.4612,2068.2312,9.8603, virtualworld);
	PlayerTutorial_Item[5][playerid]    = CreateItem(item_Wheel, 952.7346,2070.6902,9.8603, .rz = frandom(360.0), .world = virtualworld);
	// PlayerTutorial_Pickup[5][playerid]  = CreatePickup(1559, 8, 952.7346,2070.6902,9.8603, virtualworld);
	PlayerTutorial_Item[6][playerid]    = CreateItem(item_Wrench, 948.3666,2069.8452,9.8603, .rz = frandom(360.0), .world = virtualworld);
	// PlayerTutorial_Pickup[6][playerid]  = CreatePickup(1559, 8, 948.3666,2069.8452,9.8603, virtualworld);
	PlayerTutorial_Item[7][playerid]    = CreateItem(item_Screwdriver, 946.4836,2069.7207,9.8603, .rz = frandom(360.0), .world = virtualworld);
	// PlayerTutorial_Pickup[7][playerid]  = CreatePickup(1559, 8, 946.4836,2069.7207,9.8603, virtualworld);
	PlayerTutorial_Item[8][playerid]    = CreateItem(item_Hammer, 944.1250,2067.6262,9.8603, .rz = frandom(360.0), .world = virtualworld);
	// PlayerTutorial_Pickup[8][playerid]  = CreatePickup(1559, 8, 944.1250,2067.6262,9.8603, virtualworld);
	PlayerTutorial_Item[9][playerid]    = CreateItem(item_TentPack, 944.1473,2083.2739,9.8603, .rz = frandom(360.0), .world = virtualworld);
	// PlayerTutorial_Pickup[9][playerid]  = CreatePickup(1559, 8, 944.1473,2083.2739,9.8603, virtualworld);
	PlayerTutorial_Item[10][playerid]   = CreateItem(item_Hammer, 949.4579,2082.9829,9.8603, .rz = frandom(360.0), .world = virtualworld);
	// PlayerTutorial_Pickup[10][playerid] = CreatePickup(1559, 8, 949.4579,2082.9829,9.8603, virtualworld);
	PlayerTutorial_Item[11][playerid]   = CreateItem(item_Crowbar, 947.3903,2080.4143,9.8603, .rz = frandom(360.0), .world = virtualworld);
	// PlayerTutorial_Pickup[11][playerid] = CreatePickup(1559, 8, 947.3903,2080.4143,9.8603, virtualworld);
	PlayerTutorial_Item[12][playerid]   = CreateItem(item_Crowbar, 951.6076,2067.8994,9.8603, .rz = frandom(360.0), .world = virtualworld);
	// PlayerTutorial_Pickup[12][playerid] = CreatePickup(1559, 8, 951.6076,2067.8994,9.8603, virtualworld);
	PlayerTutorial_Item[13][playerid]   = CreateItem(item_Keypad, 971.9176,2069.2117,9.8603, .rz = frandom(360.0), .world = virtualworld);
	// PlayerTutorial_Pickup[13][playerid] = CreatePickup(1559, 8, 971.9176,2069.2117,9.8603, virtualworld);
	PlayerTutorial_Item[14][playerid]   = CreateItem(item_Motor, 971.4994,2072.1038,9.8603, .rz = frandom(360.0), .world = virtualworld);
	// PlayerTutorial_Pickup[14][playerid] = CreatePickup(1559, 8, 971.4994,2072.1038,9.8603, virtualworld);
	PlayerTutorial_Item[15][playerid]   = CreateItem(item_Rucksack, 931.9263,2081.7053,9.8603, .rz = frandom(360.0), .world = virtualworld);
	// PlayerTutorial_Pickup[15][playerid] = CreatePickup(1559, 8, 931.9263,2081.7053,9.8603, virtualworld);
	PlayerTutorial_Item[16][playerid]   = CreateItem(item_LargeBox, 927.8030,2058.6838,9.8603, .rz = frandom(360.0), .world = virtualworld);
	// PlayerTutorial_Pickup[16][playerid] = CreatePickup(1559, 8, 927.8030,2058.6838,9.8603, virtualworld);
	PlayerTutorial_Item[17][playerid]   = CreateItem(item_MediumBox, 929.4532,2058.3926,9.8603, .rz = frandom(360.0), .world = virtualworld);
	// PlayerTutorial_Pickup[17][playerid] = CreatePickup(1559, 8, 929.4532,2058.3926,9.8603, virtualworld);
	PlayerTutorial_Item[18][playerid]   = CreateItem(item_SmallBox, 932.5464,2058.3267,9.8603, .rz = frandom(360.0), .world = virtualworld);
	// PlayerTutorial_Pickup[18][playerid] = CreatePickup(1559, 8, 932.5464,2058.3267,9.8603, virtualworld);
	PlayerTutorial_Item[19][playerid]   = CreateItem(item_PumpShotgun, 959.1787,2082.9680,9.8603, .rz = frandom(360.0), .world = virtualworld);
	// PlayerTutorial_Pickup[19][playerid] = CreatePickup(1559, 8, 959.1787,2082.9680,9.8603, virtualworld);

	// Shotgun?
	PlayerTutorial_Item[20][playerid]   = CreateItem(item_AmmoBuck, 961.2108,2083.3938,9.8603, .rz = frandom(360.0), .world = virtualworld);
	SetItemWeaponItemMagAmmo(PlayerTutorial_Item[20][playerid], 12);
	// PlayerTutorial_Pickup[20][playerid] = CreatePickup(1559, 8, 961.2108,2083.3938,9.8603, virtualworld);
	
	// Galão de Gasolina
	PlayerTutorial_Item[21][playerid]   = CreateItem(item_GasCan, 938.4733,2063.2769,9.8603, .rz = frandom(360.0), .world = virtualworld);
	SetLiquidItemLiquidType(PlayerTutorial_Item[21][playerid], liquid_Petrol);
	SetLiquidItemLiquidAmount(PlayerTutorial_Item[21][playerid], 15);
	// PlayerTutorial_Pickup[21][playerid] = CreatePickup(1559, 8, 938.4733,2063.2769,9.8603, virtualworld);

	PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob", ls(playerid, "TUTORINTROD"), ls(playerid, "IDIOMAID")));

	for(new i = 0; i < 20; i++) SendClientMessage(playerid, GREEN, "");

	ChatMsg(playerid, WHITE, ""C_GREEN"> "C_WHITE" %s", ls(playerid, "TUTORINTROD"));
}

hook OnPlayerClickPlayerTD(playerid, PlayerText:playertextid)
{
	dbg("global", CORE, "[OnPlayerClickPlayerTD] in /gamemodes/sss/core/player/tutorial.pwn");

	dbg("gamemodes/sss/core/player/tutorial.pwn", 1, "[OnPlayerClickPlayerTD]");

	if(playertextid == ClassButtonTutorial[playerid])
	{
		EnterTutorial(playerid);

		// Esconde os textdraws de escolha
		PlayerTextDrawHide(playerid, ClassButtonMale[playerid]);
		PlayerTextDrawHide(playerid, ClassButtonFemale[playerid]);
		PlayerTextDrawHide(playerid, ClassButtonTutorial[playerid]);

		// Remove a tela preta
		SetPlayerBrightness(playerid, 255);
	}
}

hook OnVehicleSave(vehicleid)
{
	foreach(new i : Player)
		if(vehicleid == PlayerTutorialVehicle[i]) return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDeath(playerid)
{
	dbg("global", CORE, "[OnPlayerDeath] in /gamemodes/sss/core/player/tutorial.pwn");

	ExitTutorial(playerid);
}

hook OnPlayerDisconnect(playerid, reason)
{
	dbg("global", CORE, "[OnPlayerDisconnect] in /gamemodes/sss/core/player/tutorial.pwn");

	ExitTutorial(playerid);
}

ExitTutorial(playerid)
{
	if(!PlayerInTutorial[playerid]) return 0;

	log("[TUTORIAL] Jogador %p (%d) saiu do tutorial.", playerid, playerid);
		
	for(new i = INV_MAX_SLOTS - 1; i >= 0; i--) RemoveItemFromInventory(playerid, i);
	
	RemovePlayerBag(playerid);
	RemovePlayerHolsterItem(playerid);
	
	PlayerInTutorial[playerid] = false;
	SetPlayerSpawnedState(playerid, false);
	SetPlayerAliveState(playerid, false);
	SetPlayerVirtualWorld(playerid, 0);
	PlayerCreateNewCharacter(playerid);
	SetPlayerBrightness(playerid, 0);

	for(new i = 0; i < MAX_TUTORIAL_ITEMS; i++) DestroyItem(PlayerTutorial_Item[i][playerid]);
		
	DestroyWorldVehicle(PlayerTutorialVehicle[playerid], true);
	PlayerTutorialVehicle[playerid] = INVALID_VEHICLE_ID;

	PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob", GetLanguageString(playerid, "TUTORIEXIT", true), GetLanguageString(playerid, "IDIOMAID", true)));

	// ! Eu já fiz uma função chamada ClearChat. Agora não sei em que branch ficou essa merda. Vou ter que procurar.
	for(new i = 0; i < 20; i++) SendClientMessage(playerid, GREEN, "");

	return ChatMsg(playerid, WHITE, ""C_GREEN"> "C_WHITE" %s", ls(playerid, "TUTORIEXIT"));
}

hook OnPlayerWearBag(playerid, itemid)
{
	dbg("global", CORE, "[OnPlayerWearBag] in /gamemodes/sss/core/player/tutorial.pwn");

	if(PlayerInTutorial[playerid])
	{
		PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob", GetLanguageString(playerid, "TUTORACCBAG", true), GetLanguageString(playerid, "IDIOMAID", true)));
        	
  		for(new i = 0; i < 20; i++) SendClientMessage(playerid, GREEN, "");
		
		ChatMsg(playerid, WHITE, ""C_GREEN"> "C_WHITE" %s", ls(playerid, "TUTORACCBAG"));
	}

	return 0;
}

hook OnPlayerOpenInventory(playerid)
{
	dbg("global", CORE, "[OnPlayerOpenInventory] in /gamemodes/sss/core/player/tutorial.pwn");

	if(PlayerInTutorial[playerid])
	{
	    if(!PlayerTutorial_VozInv[playerid])
	    {
	    	PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob",
				GetLanguageString(playerid, "TUTORINTINV", true), GetLanguageString(playerid, "IDIOMAID", true)));

            PlayerTutorial_VozInv[playerid] = true;
		}

  		for(new i = 0; i < 20; i++) SendClientMessage(playerid, GREEN, "");
			
		ChatMsg(playerid, WHITE, ""C_GREEN"> "C_WHITE" %s", ls(playerid, "TUTORINTINV"));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenContainer(playerid, containerid)
{
	dbg("global", CORE, "[OnPlayerOpenContainer] in /gamemodes/sss/core/player/tutorial.pwn");

	if(PlayerInTutorial[playerid])
	{
		if(containerid == GetItemArrayDataAtCell(GetPlayerBagItem(playerid), 1))
		{
		    if(!PlayerTutorial_VozCnt[playerid])
		    {
  				PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob", ls(playerid, "TUTORINTBAG"), ls(playerid, "IDIOMAID")));

                PlayerTutorial_VozCnt[playerid] = true;
			}
			
  			for(new i = 0; i < 20; i++) SendClientMessage(playerid, GREEN, "");
			
			ChatMsg(playerid, WHITE, ""C_GREEN"> "C_WHITE" %s", ls(playerid, "TUTORINTBAG"));
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerViewCntOpt(playerid, containerid)
{
	dbg("global", CORE, "[OnPlayerViewCntOpt] in /gamemodes/sss/core/player/tutorial.pwn");

	if(PlayerInTutorial[playerid])
	{
		if(GetItemType(GetContainerSlotItem(containerid, GetPlayerContainerSlot(playerid))) == item_Wrench)
		{
  			PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob",
				GetLanguageString(playerid, "TUTORITMOPT", true), GetLanguageString(playerid, "IDIOMAID", true)));

  			for(new i = 0; i < 20; i++)
				SendClientMessage(playerid, GREEN, "");

			ChatMsg(playerid, WHITE, ""C_GREEN"> "C_WHITE" %s", ls(playerid, "TUTORITMOPT"));
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDroppedItem(playerid, itemid)
{
	dbg("global", CORE, "[OnPlayerDroppedItem] in /gamemodes/sss/core/player/tutorial.pwn");

	if(PlayerInTutorial[playerid])
	{
		PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob",
			GetLanguageString(playerid, "TUTORDROITM", true), GetLanguageString(playerid, "IDIOMAID", true)));

		for(new i = 0; i < 20; i++)
			SendClientMessage(playerid, GREEN, "");

		ChatMsg(playerid, WHITE, ""C_GREEN"> "C_WHITE" %s", ls(playerid, "TUTORDROITM"));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemAddedToInventory(playerid, itemid, slot)
{
	dbg("global", CORE, "[OnItemAddedToInventory] in /gamemodes/sss/core/player/tutorial.pwn");

	if(PlayerInTutorial[playerid])
	{
		PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob",
			GetLanguageString(playerid, "TUTORINVADD", true), GetLanguageString(playerid, "IDIOMAID", true)));

		for(new i = 0; i < 20; i++)
			SendClientMessage(playerid, GREEN, "");

		ChatMsg(playerid, WHITE, ""C_GREEN"> "C_WHITE" %s", ls(playerid, "TUTORINVADD"));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerViewInvOpt(playerid)
{
	dbg("global", CORE, "[OnPlayerViewInvOpt] in /gamemodes/sss/core/player/tutorial.pwn");

	if(PlayerInTutorial[playerid])
	{
		PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob",
			GetLanguageString(playerid, "TUTORITMOPT", true), GetLanguageString(playerid, "IDIOMAID", true)));

		for(new i = 0; i < 20; i++)
			SendClientMessage(playerid, GREEN, "");

		ChatMsg(playerid, WHITE, ""C_GREEN"> "C_WHITE" %s", ls(playerid, "TUTORITMOPT"));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemAddedToContainer(containerid, itemid, playerid)
{
	dbg("global", CORE, "[OnItemAddedToContainer] in /gamemodes/sss/core/player/tutorial.pwn");

	if(IsPlayerConnected(playerid))
	{
		if(PlayerInTutorial[playerid])
		{
			if(containerid == GetItemArrayDataAtCell(GetPlayerBagItem(playerid), 1))
			{
 				PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob",
					GetLanguageString(playerid, "TUTORADDBAG", true), GetLanguageString(playerid, "IDIOMAID", true)));

				for(new i = 0; i < 20; i++)
					SendClientMessage(playerid, GREEN, "");

				ChatMsg(playerid, WHITE, ""C_GREEN"> "C_WHITE" %s", ls(playerid, "TUTORADDBAG"));
			}
			else
			{
 				PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob",
					GetLanguageString(playerid, "TUTORADDCNT", true), GetLanguageString(playerid, "IDIOMAID", true)));

				for(new i = 0; i < 20; i++)
					SendClientMessage(playerid, GREEN, "");

				ChatMsg(playerid, WHITE, ""C_GREEN"> "C_WHITE" %s", ls(playerid, "TUTORADDCNT"));
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerHolsteredItem(playerid, itemid)
{
	dbg("global", CORE, "[OnPlayerHolsteredItem] in /gamemodes/sss/core/player/tutorial.pwn");

	if(PlayerInTutorial[playerid])
	{
		PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob",
			GetLanguageString(playerid, "TUTORITMHOL", true), GetLanguageString(playerid, "IDIOMAID", true)));

		for(new i = 0; i < 20; i++)
			SendClientMessage(playerid, GREEN, "");

		ChatMsg(playerid, WHITE, ""C_GREEN"> "C_WHITE" %s", ls(playerid, "TUTORITMHOL"));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	dbg("global", CORE, "[OnPlayerUseItemWithItem] in /gamemodes/sss/core/player/tutorial.pwn");

	if(PlayerInTutorial[playerid])
	{
		for(new i = 0; i < 20; i++)
			SendClientMessage(playerid, GREEN, "");

		ChatMsg(playerid, WHITE, ""C_GREEN"> "C_WHITE" %s", ls(playerid, "TUTORITMUSE"));
	}
}

hook OnItemTweakFinish(playerid, itemid)
{
	if(PlayerInTutorial[playerid])
	{
		PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob",
			ls(playerid, "TUTORIDEF"), ls(playerid, "IDIOMAID")));

		for(new i = 0; i < 20; i++)
			SendClientMessage(playerid, GREEN, "");

		ChatMsg(playerid, WHITE, ""C_GREEN"> "C_WHITE" %s", ls(playerid, "TUTORIDEF"));
	}
}

stock IsPlayerInTutorial(playerid)
{
	if(PlayerInTutorial[playerid]) return 1;

	return 0;
}

// Para os admins poderem sair do tutorial
CMD:exittutorial(playerid) {
	if(!IsPlayerAdmin(playerid)) return 0;

	ExitTutorial(playerid);

	return 1;
}