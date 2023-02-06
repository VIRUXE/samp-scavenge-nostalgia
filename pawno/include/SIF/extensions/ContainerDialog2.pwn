/*==============================================================================

# Southclaw's Interactivity Framework (SIF)

## Overview

SIF is a collection of high-level include scripts to make the
development of interactive features easy for the developer while
maintaining quality front-end gameplay for players.

## Description

An extension script for SIF/Container that adds SA:MP dialogs for player
interaction with containers. Also allows containers and inventories to
work together.

## Hooks

- OnPlayerConnect: Zero initialised array cells.
- OnPlayerViewInvOpt: Insert an option to move inventory item to container.
- OnPlayerSelectInvOpt: To trigger moving an item from inventory to container.
- OnPlayerOpenInventory: Insert a link to the container inventory.
- OnPlayerSelectExtraItem: To open the container inventory from inventory.

## Credits

- SA:MP Team: Amazing mod!
- SA:MP Community: Inspiration and support
- Incognito: Very useful streamer plugin
- Y_Less: YSI framework

==============================================================================*/


#if defined _SIF_CONTAINER_DIALOG_INCLUDED
	#endinput
#endif

#include <YSI\y_hooks>
#include <easyDialog>				// By Emmet_:				https://github.com/Awsomedude/easyDialog

#define _SIF_CONTAINER_DIALOG_INCLUDED


/*==============================================================================

	Constant Definitions, Function Declarations and Documentation

==============================================================================*/


forward DisplayContainerInventory(playerid, containerid);
/*
# Description:
-
*/

forward ClosePlayerContainer(playerid, call = false);
/*
# Description:
-
*/

forward GetPlayerCurrentContainer(playerid);
/*
# Description:
-
*/

forward GetPlayerContainerSlot(playerid);
/*
# Description:
-
*/

forward AddContainerOption(playerid, option[]);
/*
# Description:
-
*/


// Events


forward OnPlayerOpenContainer(playerid, containerid);
/*
# Description:
-
*/

forward OnPlayerCloseContainer(playerid, containerid);
/*
# Description:
-
*/

forward OnPlayerViewContainerOpt(playerid, containerid);
/*
# Description:
-
*/

forward OnPlayerSelectContainerOpt(playerid, containerid, option);
/*
# Description:
-
*/

forward OnMoveItemToContainer(playerid, itemid, containerid);
/*
# Description:
-
*/

forward OnMoveItemToInventory(playerid, itemid, containerid);
/*
# Description:
-
*/


/*==============================================================================

	Setup

==============================================================================*/


static
			cnt_ItemListTotal			[MAX_PLAYERS],
			cnt_CurrentContainer		[MAX_PLAYERS],
			cnt_SelectedSlot			[MAX_PLAYERS],
			cnt_InventoryString			[MAX_PLAYERS][CNT_MAX_SLOTS * (ITM_MAX_NAME + ITM_MAX_TEXT + 1)],
			cnt_OptionsList				[MAX_PLAYERS][128],
			cnt_OptionsCount			[MAX_PLAYERS],
			cnt_InventoryContainerItem	[MAX_PLAYERS],
			cnt_InventoryOptionID		[MAX_PLAYERS],
PlayerText:	cnt_InventoryItem			[MAX_PLAYERS][CNT_MAX_SLOTS],
PlayerText:	cnt_InventoryName			[MAX_PLAYERS],
PlayerText:	cnt_InventoryBox			[MAX_PLAYERS],
PlayerText:	cnt_InventoryClose			[MAX_PLAYERS];


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnPlayerConnect(playerid)
{
	new Float:x, Float:y;
	
    for(new j; j < CNT_MAX_SLOTS; j++)
	{
	    if(j < 8) {
	        x = 180 + (35 * j);
	        y = 150;
		}
		else if(j < 16){
		    x = 180 + (35 * (j - 8));
	        y = 150 + 32;
		}
		else if(j < 24){
		    x = 180 + (35 * (j - 16));
	        y = 150 + (32 * 2);
		}
		else if(j < 32){
		    x = 180 + (35 * (j - 24));
	        y = 150 + (32 * 3);
		}
		else if(j < 40){
		    x = 180 + (35 * (j - 32));
	        y = 150 + (32 * 4);
		}
		else if(j < 48){
		    x = 180 + (35 * (j - 40));
	        y = 150 + (32 * 5);
		}
		else if(j < 56){
		    x = 180 + (35 * (j - 48));
	        y = 150 + (32 * 6);
		}
		else if(j < 64){
		    x = 180 + (35 * (j - 56));
	        y = 150 + (32 * 7);
		}
		else if(j < 72){
		    x = 180 + (35 * (j - 64));
	        y = 150 + (32 * 8);
		}
		else if(j < 80){
		    x = 180 + (35 * (j - 72));
	        y = 150 + (32 * 9);
		}
		
		cnt_InventoryItem[playerid][j] = CreatePlayerTextDraw(playerid, x, y, "_");
		PlayerTextDrawBackgroundColor(playerid, cnt_InventoryItem[playerid][j], 0x00000044);
		PlayerTextDrawFont(playerid, cnt_InventoryItem[playerid][j], TEXT_DRAW_FONT_MODEL_PREVIEW);
		PlayerTextDrawColor(playerid, cnt_InventoryItem[playerid][j], -1);
		PlayerTextDrawTextSize(playerid, cnt_InventoryItem[playerid][j], 34.000000, 31.000000);
		PlayerTextDrawSetPreviewModel(playerid, cnt_InventoryItem[playerid][j], 18631);
		PlayerTextDrawSetPreviewRot(playerid, cnt_InventoryItem[playerid][j], -45.0, 0.0, -45.0, 1.0);
		PlayerTextDrawSetSelectable(playerid, cnt_InventoryItem[playerid][j], 1);
	}
		
    cnt_InventoryName[playerid] = CreatePlayerTextDraw(playerid, 172.705871, 131.250030, "Container");
	PlayerTextDrawLetterSize(playerid, cnt_InventoryName[playerid], 0.447647, 1.629166);
	PlayerTextDrawAlignment(playerid, cnt_InventoryName[playerid], 1);
	PlayerTextDrawColor(playerid, cnt_InventoryName[playerid], -1);
	PlayerTextDrawSetShadow(playerid, cnt_InventoryName[playerid], 0);
	PlayerTextDrawSetOutline(playerid, cnt_InventoryName[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, cnt_InventoryName[playerid], 51);
	PlayerTextDrawFont(playerid, cnt_InventoryName[playerid], 1);
	PlayerTextDrawSetProportional(playerid, cnt_InventoryName[playerid], 1);

	cnt_InventoryBox[playerid] = CreatePlayerTextDraw(playerid, 472.588256, 130.416687, "usebox");
	PlayerTextDrawLetterSize(playerid, cnt_InventoryBox[playerid], 0.000000, 7.137038);
	PlayerTextDrawTextSize(playerid, cnt_InventoryBox[playerid], 167.411743, 0.000000);
	PlayerTextDrawAlignment(playerid, cnt_InventoryBox[playerid], 1);
	PlayerTextDrawColor(playerid, cnt_InventoryBox[playerid], 0);
	PlayerTextDrawUseBox(playerid, cnt_InventoryBox[playerid], true);
	PlayerTextDrawBoxColor(playerid, cnt_InventoryBox[playerid], 50);
	PlayerTextDrawSetShadow(playerid, cnt_InventoryBox[playerid], 0);
	PlayerTextDrawSetOutline(playerid, cnt_InventoryBox[playerid], 0);
	PlayerTextDrawFont(playerid, cnt_InventoryBox[playerid], 0);
		
	cnt_InventoryClose[playerid] = CreatePlayerTextDraw(playerid, 463.058898, 118.416694, "X");
	PlayerTextDrawLetterSize(playerid, cnt_InventoryClose[playerid], 0.559176, 2.119166);
	PlayerTextDrawAlignment(playerid, cnt_InventoryClose[playerid], 1);
	PlayerTextDrawColor(playerid, cnt_InventoryClose[playerid], -558331905);
	PlayerTextDrawSetShadow(playerid, cnt_InventoryClose[playerid], 0);
	PlayerTextDrawSetOutline(playerid, cnt_InventoryClose[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, cnt_InventoryClose[playerid], 51);
	PlayerTextDrawFont(playerid, cnt_InventoryClose[playerid], 1);
	PlayerTextDrawSetProportional(playerid, cnt_InventoryClose[playerid], 1);
	PlayerTextDrawSetSelectable(playerid, cnt_InventoryClose[playerid], 1);

	if(!IsPlayerNPC(playerid))
		cnt_CurrentContainer[playerid] = INVALID_CONTAINER_ID;
}


hook OnPlayerDisconnect(playerid, reason)
{
	if(!IsPlayerNPC(playerid))
	{
		for(new j; j < CNT_MAX_SLOTS; j++)
		{
			PlayerTextDrawDestroy(playerid, cnt_InventoryItem[playerid][j]);
		}

		PlayerTextDrawDestroy(playerid, cnt_InventoryName[playerid]);
		PlayerTextDrawDestroy(playerid, cnt_InventoryBox[playerid]);
		PlayerTextDrawDestroy(playerid, cnt_InventoryClose[playerid]);
	}
}

/*==============================================================================

	Core Functions

==============================================================================*/


stock DisplayContainerInventory(playerid, containerid)
{
	if(!IsValidContainer(containerid))
		return 0;
    
    for(new j; j < CNT_MAX_SLOTS; j++)
		PlayerTextDrawHide(playerid, cnt_InventoryItem[playerid][j]);
		
	new
	    itemid,
	    containername[CNT_MAX_NAME];

	cnt_InventoryString[playerid][0] = EOS;
	cnt_ItemListTotal[playerid] = 0;

	for(new i; i < GetContainerSize(containerid); i++)
	{
		itemid = GetContainerSlotItem(containerid, i);

		if(IsValidItem(itemid)){
			PlayerTextDrawSetPreviewModel(playerid, cnt_InventoryItem[playerid][i], GetItemTypeModel(GetItemType(itemid)) );
			PlayerTextDrawShow(playerid, cnt_InventoryItem[playerid][i]);
		}
		else break;

		cnt_ItemListTotal[playerid]++;
	}

	if(cnt_ItemListTotal[playerid] < 8)
    	PlayerTextDrawLetterSize(playerid, cnt_InventoryBox[playerid], 0.000000, 7.137038);
	else if(cnt_ItemListTotal[playerid] < 16)
	    PlayerTextDrawLetterSize(playerid, cnt_InventoryBox[playerid], 0.000000, 2 * 7.137038);
    else if(cnt_ItemListTotal[playerid] < 24)
	    PlayerTextDrawLetterSize(playerid, cnt_InventoryBox[playerid], 0.000000, 3 * 7.137038);
 	else if(cnt_ItemListTotal[playerid] < 24)
	   	PlayerTextDrawLetterSize(playerid, cnt_InventoryBox[playerid], 0.000000, 4 * 7.137038);
 	else if(cnt_ItemListTotal[playerid] < 40)
	   	PlayerTextDrawLetterSize(playerid, cnt_InventoryBox[playerid], 0.000000, 5 * 7.137038);
 	else if(cnt_ItemListTotal[playerid] < 48)
	   	PlayerTextDrawLetterSize(playerid, cnt_InventoryBox[playerid], 0.000000, 6 * 7.137038);
	else if(cnt_ItemListTotal[playerid] < 56)
	   	PlayerTextDrawLetterSize(playerid, cnt_InventoryBox[playerid], 0.000000, 7 * 7.137038);
	else if(cnt_ItemListTotal[playerid] < 64)
	   	PlayerTextDrawLetterSize(playerid, cnt_InventoryBox[playerid], 0.000000, 8 * 7.137038);
	else if(cnt_ItemListTotal[playerid] < 72)
	   	PlayerTextDrawLetterSize(playerid, cnt_InventoryBox[playerid], 0.000000, 9 * 7.137038);
	else if(cnt_ItemListTotal[playerid] < 80)
	   	PlayerTextDrawLetterSize(playerid, cnt_InventoryBox[playerid], 0.000000, 10 * 7.137038);

	for(new i; i < GetContainerFreeSlots(containerid); i++)
		cnt_ItemListTotal[playerid]++;

    if(GetContainerFreeSlots(playerid) == CNT_MAX_SLOTS){
	    PlayerTextDrawSetPreviewModel(playerid, cnt_InventoryItem[playerid][0], 18631);
		PlayerTextDrawShow(playerid, cnt_InventoryItem[playerid][0]);
	}

	cnt_CurrentContainer[playerid] = containerid;

	if(CallLocalFunction("OnPlayerOpenContainer", "dd", playerid, containerid))
		return 0;

    GetContainerName(containerid, containername);
    
    PlayerTextDrawSetString(playerid, cnt_InventoryName[playerid],
    	sprintf("%s (%d/%d)", containername, GetContainerSize(containerid) - GetContainerFreeSlots(containerid), GetContainerSize(containerid)));

    PlayerTextDrawShow(playerid, cnt_InventoryName[playerid]);
	PlayerTextDrawShow(playerid, cnt_InventoryBox[playerid]);
	PlayerTextDrawShow(playerid, cnt_InventoryClose[playerid]);
	return 1;
}

hook OnPlayerClickPlayerTD(playerid, PlayerText:playertextid)
{
    for(new j; j < CNT_MAX_SLOTS; j++)
    	if(playertextid == cnt_InventoryItem[playerid][j])
    	    PlayerContainerSelect(playerid, j), PlayerPlaySound(playerid,1184,0.0,0.0,0.0);

	if(playertextid == cnt_InventoryClose[playerid])
	    ClosePlayerContainer(playerid, true);
	    
	return 1;
}


PlayerContainerSelect(playerid, listitem)
{
	if(!IsValidContainer(cnt_CurrentContainer[playerid]))
		return 0;

	printf("listitem %d total %d itemcount %d freeslots %d", listitem, cnt_ItemListTotal[playerid], GetContainerItemCount(cnt_CurrentContainer[playerid]), GetContainerFreeSlots(cnt_CurrentContainer[playerid]));

	if(listitem >= cnt_ItemListTotal[playerid])
	{
		DisplayPlayerInventory(playerid);
	}
	else
	{
		if(!(0 <= listitem < CNT_MAX_SLOTS))
		{
			printf("ERROR: Invalid listitem value: %d", listitem);
			return 0;
		}

		if(!IsValidItem(cnt_Items[cnt_CurrentContainer[playerid]][listitem]))
		{
			DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
		}
		else
		{
			cnt_SelectedSlot[playerid] = listitem;
			DisplayContainerOptions(playerid, listitem);
		}
	}

	return 1;
}

stock ClosePlayerContainer(playerid, call = false)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(cnt_CurrentContainer[playerid] == INVALID_CONTAINER_ID)
		return 0;

	if(call)
	{
		if(CallLocalFunction("OnPlayerCloseContainer", "dd", playerid, cnt_CurrentContainer[playerid]))
		{
			DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
			return 1;
		}
	}

    for(new j; j < CNT_MAX_SLOTS; j++)
		PlayerTextDrawHide(playerid, cnt_InventoryItem[playerid][j]);
		
    PlayerTextDrawHide(playerid, cnt_InventoryName[playerid]);
	PlayerTextDrawHide(playerid, cnt_InventoryBox[playerid]);
	PlayerTextDrawHide(playerid, cnt_InventoryClose[playerid]);
	
	cnt_CurrentContainer[playerid] = INVALID_CONTAINER_ID;

	return 1;
}

stock GetPlayerCurrentContainer(playerid)
{
	if(!IsPlayerConnected(playerid))
		return INVALID_CONTAINER_ID;

	return cnt_CurrentContainer[playerid];
}

stock GetPlayerContainerSlot(playerid)
{
	if(!IsPlayerConnected(playerid))
		return -1;

	return cnt_SelectedSlot[playerid];
}

stock AddContainerOption(playerid, option[])
{
	if(strlen(cnt_OptionsList[playerid]) + strlen(option) > sizeof(cnt_OptionsList[]))
		return 0;

	strcat(cnt_OptionsList[playerid], option);
	strcat(cnt_OptionsList[playerid], "\n");

	return cnt_OptionsCount[playerid]++;
}


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


DisplayContainerOptions(playerid, slotid)
{
	new
		tmp[ITM_MAX_NAME + ITM_MAX_TEXT];

	GetItemName(cnt_Items[cnt_CurrentContainer[playerid]][slotid], tmp);

	cnt_OptionsList[playerid] = "Equipar\nMover para invent�rio >\n";
	cnt_OptionsCount[playerid] = 0;

	CallLocalFunction("OnPlayerViewContainerOpt", "dd", playerid, cnt_CurrentContainer[playerid]);

	Dialog_Show(playerid, SIF_ContainerOptions, DIALOG_STYLE_LIST, tmp, cnt_OptionsList[playerid], "Op��es", "Voltar");

	return 1;
}

Dialog:SIF_ContainerOptions(playerid, response, listitem, inputtext[])
{
	if(!response)
	{
		DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
		return 1;
	}

	switch(listitem)
	{
		case 0:
		{
			if(GetPlayerItem(playerid) == INVALID_ITEM_ID)
			{
				new id = cnt_Items[cnt_CurrentContainer[playerid]][cnt_SelectedSlot[playerid]];

				RemoveItemFromContainer(cnt_CurrentContainer[playerid], cnt_SelectedSlot[playerid], playerid);
				GiveWorldItemToPlayer(playerid, id);
				DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
			}
			else
			{
				ShowActionText(playerid, "Voce est� segurando um item.", 3000, 200);
				DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
			}
		}
		case 1:
		{
			new itemid = cnt_Items[cnt_CurrentContainer[playerid]][cnt_SelectedSlot[playerid]];

			if(!IsValidItem(itemid))
			{
				DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
				return 0;
			}

			if(CallLocalFunction("OnMoveItemToInventory", "ddd", playerid, itemid, cnt_CurrentContainer[playerid]))
				return 0;

			new required = AddItemToInventory(playerid, itemid);

			if(required > 0)
			{
				new str[32];
				format(str, sizeof(str), "Extra %d slots required", required);
				ShowActionText(playerid, str, 3000, 150);
			}
			else if(required == 0)
			{
				RemoveItemFromContainer(cnt_CurrentContainer[playerid], GetItemContainerSlot(itemid), playerid);
			}

			DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);

			return 1;
		}
		default:
		{
			CallLocalFunction("OnPlayerSelectContainerOpt", "ddd", playerid, cnt_CurrentContainer[playerid], listitem - 2);
		}
	}

	return 1;
}

hook OnPlayerViewInvOpt(playerid)
{
	if(cnt_CurrentContainer[playerid] != INVALID_CONTAINER_ID)
	{
		new str[8 + CNT_MAX_NAME];
		str = "Mover para ";
		strcat(str, cnt_Data[cnt_CurrentContainer[playerid]][cnt_name]);
		cnt_InventoryOptionID[playerid] = AddInventoryOption(playerid, str);
	}

	return 0;
}

hook OnPlayerSelectInvOpt(playerid, option)
{
	if(cnt_CurrentContainer[playerid] != INVALID_CONTAINER_ID)
	{
		if(option == cnt_InventoryOptionID[playerid])
		{
			new
				slot,
				itemid;

			slot = GetPlayerSelectedInventorySlot(playerid);
			itemid = GetInventorySlotItem(playerid, slot);

			if(IsValidItem(cnt_Items[cnt_CurrentContainer[playerid]][cnt_Data[cnt_CurrentContainer[playerid]][cnt_size]-1]) || !IsValidItem(itemid))
			{
				DisplayPlayerInventory(playerid);
				return 0;
			}

			new required = AddItemToContainer(cnt_CurrentContainer[playerid], itemid, playerid);

			if(required == 0)
			{
				if(CallLocalFunction("OnMoveItemToContainer", "ddd", playerid, itemid, cnt_CurrentContainer[playerid]))
					return 0;
			}

			DisplayPlayerInventory(playerid);

			return 1;
		}
	}

	return 0;
}


hook OnPlayerOpenInventory(playerid)
{
	if(IsValidContainer(cnt_CurrentContainer[playerid]))
	{
		new str[CNT_MAX_NAME + 2];
		strcat(str, cnt_Data[cnt_CurrentContainer[playerid]][cnt_name]);
		strcat(str, " >");
		cnt_InventoryContainerItem[playerid] = AddInventoryListItem(playerid, str);
	}

	return 0;
}


hook OnPlayerSelectExtraItem(playerid, item)
{
	if(IsValidContainer(cnt_CurrentContainer[playerid]))
	{
		if(item == cnt_InventoryContainerItem[playerid])
		{
			DisplayContainerInventory(playerid, cnt_CurrentContainer[playerid]);
		}
	}

	return 0;
}
