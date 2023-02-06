/*==============================================================================

# Southclaw's Interactivity Framework (SIF)

## Overview

SIF is a collection of high-level include scripts to make the
development of interactive features easy for the developer while
maintaining quality front-end gameplay for players.

## Description

An extension for SIF/Inventory that uses SA:MP dialog menus for player
interaction with their inventory items.

## Credits

- SA:MP Team: Amazing mod!
- SA:MP Community: Inspiration and support
- Incognito: Very useful streamer plugin
- Y_Less: YSI framework

==============================================================================*/


#if defined _SIF_INVENTORY_DIALOG_INCLUDED
	#endinput
#endif

#include <easyDialog>				// By Emmet_:				https://github.com/Awsomedude/easyDialog
#include <YSI\y_hooks>

#define _SIF_INVENTORY_DIALOG_INCLUDED


/*==============================================================================

	Constant Definitions, Function Declarations and Documentation

==============================================================================*/


// Functions


forward DisplayPlayerInventory(playerid);
/*
# Description:
-
*/

forward ClosePlayerInventory(playerid, call = false);
/*
# Description:
-
*/

forward GetPlayerSelectedInventorySlot(playerid);
/*
# Description:
-
*/

forward AddInventoryListItem(playerid, itemname[]);
/*
# Description:
-
*/

forward AddInventoryOption(playerid, option[]);
/*
# Description:
-
*/

forward GetInventoryListItems(playerid);
/*
# Description:
-
*/

forward GetInventoryOptions(playerid);
/*
# Description:
-
*/

forward GetInventoryListItemCount(playerid);
/*
# Description:
-
*/

forward GetInventoryOptionCount(playerid);
/*
# Description:
-
*/

forward IsPlayerViewingInventory(playerid);
/*
# Description:
-
*/


// Events


forward OnPlayerOpenInventory(playerid);
/*
# Called:
-
*/

forward OnPlayerCloseInventory(playerid);
/*
# Called:
-
*/

forward OnPlayerSelectExtraItem(playerid, item);
/*
# Called:
-
*/

forward OnPlayerRemoveFromInventory(playerid, slotid); // TODO
/*
# Called:
-
*/

forward OnPlayerRemovedFromInventory(playerid, slotid); // TODO
/*
# Called:
-
*/

forward OnPlayerViewInventoryOpt(playerid);
/*
# Called:
-
*/

forward OnPlayerSelectInventoryOpt(playerid, option);
/*
# Called:
-
*/


/*==============================================================================

	Setup

==============================================================================*/


static
			inv_ItemListTotal			[MAX_PLAYERS],
			inv_SelectedSlot			[MAX_PLAYERS],
			inv_ViewingInventory		[MAX_PLAYERS],
			inv_ExtraItemList			[MAX_PLAYERS][128],
			inv_ExtraItemCount			[MAX_PLAYERS],
			inv_OptionsList				[MAX_PLAYERS][128],
			inv_OptionsCount			[MAX_PLAYERS],
PlayerText:	inv_InventoryItem			[MAX_PLAYERS][INV_MAX_SLOTS],
PlayerText:	inv_InventoryName			[MAX_PLAYERS],
PlayerText:	inv_InventoryBox			[MAX_PLAYERS],
PlayerText:	inv_InventoryClose			[MAX_PLAYERS];


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	for(new i; i < MAX_PLAYERS; i++)
	{
		for(new j; j < INV_MAX_SLOTS; j++)
		{
			inv_SelectedSlot[i] = -1;
		}
	}
}

hook OnPlayerConnect(playerid)
{
	if(!IsPlayerNPC(playerid))
	{
		for(new j; j < INV_MAX_SLOTS; j++)
		{
			inv_InventoryItem[playerid][j] = CreatePlayerTextDraw(playerid, 180 + (35 * j), 150, "_");
			PlayerTextDrawBackgroundColor(playerid, inv_InventoryItem[playerid][j], 0x00000044);
			PlayerTextDrawFont(playerid, inv_InventoryItem[playerid][j], TEXT_DRAW_FONT_MODEL_PREVIEW);
			PlayerTextDrawColor(playerid, inv_InventoryItem[playerid][j], -1);
			PlayerTextDrawTextSize(playerid, inv_InventoryItem[playerid][j], 34.000000, 31.000000);
			PlayerTextDrawSetPreviewModel(playerid, inv_InventoryItem[playerid][j], 18631);
			PlayerTextDrawSetPreviewRot(playerid, inv_InventoryItem[playerid][j], -45.0, 0.0, -45.0, 1.0);
			PlayerTextDrawSetSelectable(playerid, inv_InventoryItem[playerid][j], 1);
		}
		
		inv_InventoryName[playerid] = CreatePlayerTextDraw(playerid, 172.705871, 131.250030, "Inventario (8/8)");
		PlayerTextDrawLetterSize(playerid, inv_InventoryName[playerid], 0.447647, 1.629166);
		PlayerTextDrawAlignment(playerid, inv_InventoryName[playerid], 1);
		PlayerTextDrawColor(playerid, inv_InventoryName[playerid], 0xDEB887FF);
		PlayerTextDrawSetShadow(playerid, inv_InventoryName[playerid], 0);
		PlayerTextDrawSetOutline(playerid, inv_InventoryName[playerid], 0);
		PlayerTextDrawBackgroundColor(playerid, inv_InventoryName[playerid], 51);
		PlayerTextDrawFont(playerid, inv_InventoryName[playerid], 1);
		PlayerTextDrawSetProportional(playerid, inv_InventoryName[playerid], 1);

		inv_InventoryBox[playerid] = CreatePlayerTextDraw(playerid, 472.588256, 130.416687, "usebox");
		PlayerTextDrawLetterSize(playerid, inv_InventoryBox[playerid], 0.000000, 7.137038);
		PlayerTextDrawTextSize(playerid, inv_InventoryBox[playerid], 167.411743, 0.000000);
		PlayerTextDrawAlignment(playerid, inv_InventoryBox[playerid], 1);
		PlayerTextDrawColor(playerid, inv_InventoryBox[playerid], 0);
		PlayerTextDrawUseBox(playerid, inv_InventoryBox[playerid], true);
		PlayerTextDrawBoxColor(playerid, inv_InventoryBox[playerid], 50);
		PlayerTextDrawSetShadow(playerid, inv_InventoryBox[playerid], 0);
		PlayerTextDrawSetOutline(playerid, inv_InventoryBox[playerid], 0);
		PlayerTextDrawFont(playerid, inv_InventoryBox[playerid], 0);
		
        inv_InventoryClose[playerid] = CreatePlayerTextDraw(playerid, 463.058898, 118.416694, "X");
		PlayerTextDrawLetterSize(playerid, inv_InventoryClose[playerid], 0.559176, 2.119166);
		PlayerTextDrawAlignment(playerid, inv_InventoryClose[playerid], 1);
		PlayerTextDrawColor(playerid, inv_InventoryClose[playerid], -558331905);
		PlayerTextDrawSetShadow(playerid, inv_InventoryClose[playerid], 0);
		PlayerTextDrawSetOutline(playerid, inv_InventoryClose[playerid], 1);
		PlayerTextDrawBackgroundColor(playerid, inv_InventoryClose[playerid], 51);
		PlayerTextDrawFont(playerid, inv_InventoryClose[playerid], 1);
		PlayerTextDrawSetProportional(playerid, inv_InventoryClose[playerid], 1);
		PlayerTextDrawSetSelectable(playerid, inv_InventoryClose[playerid], 1);
	}
}


hook OnPlayerDisconnect(playerid, reason)
{
	if(!IsPlayerNPC(playerid))
	{
		for(new j; j < INV_MAX_SLOTS; j++)
		{
			PlayerTextDrawDestroy(playerid, inv_InventoryItem[playerid][j]);
		}
		
		PlayerTextDrawDestroy(playerid, inv_InventoryName[playerid]);
		PlayerTextDrawDestroy(playerid, inv_InventoryBox[playerid]);
		PlayerTextDrawDestroy(playerid, inv_InventoryClose[playerid]);
	}
}
/*==============================================================================

	Core Functions

==============================================================================*/


stock DisplayPlayerInventory(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	new itemid;

	inv_ItemListTotal[playerid] = 0;

    for(new j; j < INV_MAX_SLOTS; j++)
		PlayerTextDrawHide(playerid, inv_InventoryItem[playerid][j]);
		
	for(new i; i < GetPlayerInventorySize(playerid); i++)
	{
		itemid = GetInventorySlotItem(playerid, i);

		if(IsValidItem(itemid)){
			PlayerTextDrawSetPreviewModel(playerid, inv_InventoryItem[playerid][i], GetItemTypeModel(GetItemType(itemid)) );
			PlayerTextDrawShow(playerid, inv_InventoryItem[playerid][i]);
		}
		else break;
			
		inv_ItemListTotal[playerid]++;
	}

	for(new i; i < GetInventoryFreeSlots(playerid); i++)
		inv_ItemListTotal[playerid]++;

	if(GetInventoryFreeSlots(playerid) == INV_MAX_SLOTS){
	    PlayerTextDrawSetPreviewModel(playerid, inv_InventoryItem[playerid][0], 18631);
		PlayerTextDrawShow(playerid, inv_InventoryItem[playerid][0]);
	}
	
	inv_ExtraItemList[playerid][0] = EOS;
	inv_ExtraItemCount[playerid] = 0;

	if(CallLocalFunction("OnPlayerOpenInventory", "d", playerid))
		return 0;

    PlayerTextDrawSetString(playerid, inv_InventoryName[playerid],
    	sprintf("Inventario (%d/%d)", GetPlayerInventorySize(playerid) - GetInventoryFreeSlots(playerid), GetPlayerInventorySize(playerid)));
    
    PlayerTextDrawShow(playerid, inv_InventoryName[playerid]);
	PlayerTextDrawShow(playerid, inv_InventoryBox[playerid]);
    PlayerTextDrawShow(playerid, inv_InventoryClose[playerid]);
    
	inv_ViewingInventory[playerid] = true;
	return 1;
}


hook OnPlayerClickPlayerTD(playerid, PlayerText:playertextid)
{
    for(new j; j < INV_MAX_SLOTS; j++)
    	if(playertextid == inv_InventoryItem[playerid][j])
    	    PlayerInventorySelect(playerid, j), PlayerPlaySound(playerid,1184,0.0,0.0,0.0);

    if(playertextid == inv_InventoryClose[playerid])
        ClosePlayerInventory(playerid, true);
        
	return 1;
}


PlayerInventorySelect(playerid, listitem)
{
	if(listitem >= inv_ItemListTotal[playerid])
	{
		CallLocalFunction("OnPlayerSelectExtraItem", "dd", playerid, listitem - inv_ItemListTotal[playerid]);
		inv_ViewingInventory[playerid] = false;
		return 1;
	}

	if(!IsValidItem(GetInventorySlotItem(playerid, listitem)))
	{
		DisplayPlayerInventory(playerid);
	}
	else
	{
		inv_SelectedSlot[playerid] = listitem;
		DisplayPlayerInventoryOptions(playerid, listitem);
	}

	return 1;
}

stock ClosePlayerInventory(playerid, call = false)
{
	if(!inv_ViewingInventory[playerid])
		return 0;

	if(call)
	{
		if(CallLocalFunction("OnPlayerCloseInventory", "d", playerid))
		{
			DisplayPlayerInventory(playerid);
			return 1;
		}
	}

	for(new j; j < INV_MAX_SLOTS; j++)
		PlayerTextDrawHide(playerid, inv_InventoryItem[playerid][j]);
		
    PlayerTextDrawHide(playerid, inv_InventoryName[playerid]);
	PlayerTextDrawHide(playerid, inv_InventoryBox[playerid]);
	PlayerTextDrawHide(playerid, inv_InventoryClose[playerid]);
	
    CancelSelectTextDraw(playerid);
    
	inv_ViewingInventory[playerid] = false;

	return 1;
}

stock GetPlayerSelectedInventorySlot(playerid)
{
	if(!IsPlayerConnected(playerid))
		return -1;

	return inv_SelectedSlot[playerid];
}

stock AddInventoryListItem(playerid, itemname[])
{
	if(strlen(inv_ExtraItemList[playerid]) + strlen(itemname) > sizeof(inv_ExtraItemList[]))
		return 0;

	strcat(inv_ExtraItemList[playerid], itemname);
	strcat(inv_ExtraItemList[playerid], "\n");

	return inv_ExtraItemCount[playerid]++;
}

stock AddInventoryOption(playerid, option[])
{
	if(strlen(inv_OptionsList[playerid]) + strlen(option) > sizeof(inv_OptionsList[]))
		return 0;

	strcat(inv_OptionsList[playerid], option);
	strcat(inv_OptionsList[playerid], "\n");

	return inv_OptionsCount[playerid]++;
}

stock GetInventoryListItems(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return inv_ExtraItemList[playerid];
}

stock GetInventoryOptions(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return inv_OptionsList[playerid];
}

stock GetInventoryListItemCount(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return inv_ExtraItemCount[playerid];
}

stock GetInventoryOptionCount(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return inv_OptionsCount[playerid];
}

stock IsPlayerViewingInventory(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return inv_ViewingInventory[playerid];
}


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


DisplayPlayerInventoryOptions(playerid, slotid)
{
	new
		name[ITM_MAX_NAME + ITM_MAX_TEXT+ 10];

	GetItemName(GetInventorySlotItem(playerid, slotid), name);
	
	inv_OptionsList[playerid] = "Equipar\nUsar\nJogar Item\n";
	inv_OptionsCount[playerid] = 0;

	CallLocalFunction("OnPlayerViewInventoryOpt", "d", playerid);

	Dialog_Show(playerid, SIF_PlayerInvOptions, DIALOG_STYLE_LIST, name, inv_OptionsList[playerid], "Selecionar", "Voltar");

	return 1;
}

Dialog:SIF_PlayerInvOptions(playerid, response, listitem, inputtext[])
{
	if(!response)
	{
		DisplayPlayerInventory(playerid);
		return 1;
	}

	switch(listitem)
	{
		case 0:
		{
			if(GetPlayerItem(playerid) == INVALID_ITEM_ID)
			{
				new itemid = GetInventorySlotItem(playerid, inv_SelectedSlot[playerid]);

				RemoveItemFromInventory(playerid, inv_SelectedSlot[playerid]);
				GiveWorldItemToPlayer(playerid, itemid, 1);
				DisplayPlayerInventory(playerid);
			}
			else
			{
				ShowActionText(playerid, "Voc� j� est� segurando um item.", 3000, 200);
				DisplayPlayerInventory(playerid);
			}
		}
		case 1:
		{
			if(GetPlayerItem(playerid) == INVALID_ITEM_ID)
			{
				new itemid = GetInventorySlotItem(playerid, inv_SelectedSlot[playerid]);

				RemoveItemFromInventory(playerid, inv_SelectedSlot[playerid]);
				GiveWorldItemToPlayer(playerid, itemid, 1);

				PlayerUseItem(playerid);

				ClosePlayerInventory(playerid, true);
			}
			else
			{
				ShowActionText(playerid, "Voc� j� est� segurando um item.", 3000, 200);
				DisplayPlayerInventory(playerid);
			}
		}
		case 2:
		{
			new
				itemid = GetInventorySlotItem(playerid, inv_SelectedSlot[playerid]),
				Float:x,
				Float:y,
				Float:z,
				Float:r;

			RemoveItemFromInventory(playerid, inv_SelectedSlot[playerid]);
			
            DisplayPlayerInventory(playerid);
            
        	GetPlayerPos(playerid, x, y, z);
			GetPlayerFacingAngle(playerid, r);

			CreateItemInWorld(itemid,
				x + (0.5 * floatsin(-r, degrees)),
				y + (0.5 * floatcos(-r, degrees)),
				z - FLOOR_OFFSET,
				0.0, 0.0, r,
				0, GetPlayerInterior(playerid), 1);

			Streamer_Update(playerid);

			CallLocalFunction("OnPlayerDroppedItem", "dd", playerid, itemid);
		}
		default:
		{
			CallLocalFunction("OnPlayerSelectInventoryOpt", "dd", playerid, listitem - 3);
		}
	}

	return 1;
}
