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


/*==============================================================================

	Setup

==============================================================================*/


#define MAX_SCRAP_MACHINE_ITEMS		(12)
#define MAX_SCRAP_MACHINE_FUEL		(80.0)
#define SCRAP_MACHINE_FUEL_USAGE	(3.5)


enum e_SCRAP_MACHINE_DATA
{
			sm_containerid,
Float:		sm_fuel,
bool:		sm_cooking,
			sm_smoke,
			sm_cookTime,
			sm_startTime
}


static
			sm_ItemTypeScrapValue[ITM_MAX_TYPES],
			sm_CurrentScrapMachine[MAX_PLAYERS] = {INVALID_ITEM_ID, ...};


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnPlayerConnect(playerid)
{
	

	sm_CurrentScrapMachine[playerid] = -1;
}


/*==============================================================================

	Core Functions

==============================================================================*/


stock SetItemTypeScrapValue(ItemType:itemtype, value)
{
	if(!IsValidItemType(itemtype))
	{
		err("Tried to assign scrap value to invalid item type.");
		return;
	}

	sm_ItemTypeScrapValue[itemtype] = value;

	return;
}


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


hook OnPlayerUseMachine(playerid, itemid, interactiontype)
{


	if(GetItemType(itemid) == item_ScrapMachine)
	{

		_sm_PlayerUseScrapMachine(playerid, itemid, interactiontype);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_sm_PlayerUseScrapMachine(playerid, itemid, interactiontype)
{


	new data[e_SCRAP_MACHINE_DATA];

	GetItemArrayData(itemid, data);

	if(data[sm_cooking])
	{
		ShowActionText(playerid, sprintf(ls(playerid, "item/machines/refinement/processing"), MsToString(data[sm_cookTime] - GetTickCountDifference(GetTickCount(), data[sm_startTime]), "%m minutes %s seconds")), 8000);
		return 0;
	}

	if(interactiontype == 0)
	{
		if(GetItemType(itemid) != item_Crowbar)
			DisplayContainerInventory(playerid, GetItemArrayDataAtCell(itemid, 0));

		return 0;
	}

	sm_CurrentScrapMachine[playerid] = itemid;

	new
		ItemType:itemtype = GetItemType(GetPlayerItem(playerid));

	if(GetItemTypeLiquidContainerType(itemtype) != -1)
	{
		if(GetLiquidItemLiquidType(GetPlayerItem(playerid)) == liquid_Petrol)
		{
			StartHoldAction(playerid, floatround(MAX_SCRAP_MACHINE_FUEL * 100), floatround(Float:data[sm_fuel] * 100));
			return 0;
		}
	}

	Dialog_Show(playerid, ScrapMachine, DIALOG_STYLE_MSGBOX, "Scrap Machine", sprintf("Press 'Start' to activate the scrap machine and convert certain types of items into scrap.\nItems that cannot be turned into scrap metal will be destroyed.\n\n"C_GREEN"Fuel amount: "C_WHITE"%.1f", data[sm_fuel]), "Start", "Cancel");

	return 0;
}

Dialog:ScrapMachine(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new ret = _sm_StartCooking(sm_CurrentScrapMachine[playerid]);

		if(ret == 0)
			ShowActionText(playerid, ls(playerid, "item/machines/refinement/no-items"), 5000);

		else if(ret == -1)
			ShowActionText(playerid, ls(playerid, "item/machines/refinement/server-restart"), 6000);

		else if(ret == -2)
			ShowActionText(playerid, sprintf(ls(playerid, "item/machines/refinement/not-enough-fuel"), SCRAP_MACHINE_FUEL_USAGE), 6000);

		else
			ShowActionText(playerid, sprintf(ls(playerid, "item/machines/refinement/cook-time"), MsToString(ret, "%m minutes %s seconds")), 6000);

		sm_CurrentScrapMachine[playerid] = -1;
	}
}

hook OnHoldActionUpdate(playerid, progress)
{


	if(sm_CurrentScrapMachine[playerid] != -1)
	{


		new itemid = GetPlayerItem(playerid);

		if(GetItemTypeLiquidContainerType(GetItemType(itemid)) != -1)
		{
			if(GetLiquidItemLiquidType(itemid) != liquid_Petrol)
			{

				StopHoldAction(playerid);
				sm_CurrentScrapMachine[playerid] = -1;
				return Y_HOOKS_BREAK_RETURN_1;
			}
		}

		new
			Float:fuel = GetLiquidItemLiquidAmount(itemid),
			Float:transfer;

		if(fuel <= 0.0)
		{

			StopHoldAction(playerid);
			sm_CurrentScrapMachine[playerid] = -1;
			HideActionText(playerid);
		}
		else
		{
			new Float:machinefuel = Float:GetItemArrayDataAtCell(sm_CurrentScrapMachine[playerid], sm_fuel);


			transfer = (fuel - 1.1 < 0.0) ? fuel : 1.1;
			SetLiquidItemLiquidAmount(itemid, fuel - transfer);
			SetItemArrayDataAtCell(sm_CurrentScrapMachine[playerid], _:(machinefuel + 1.1), sm_fuel);
			ShowActionText(playerid, ls(playerid, "item/machines/refinement/refueling"));
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_sm_StartCooking(itemid)
{
	new data[e_SCRAP_MACHINE_DATA];

	GetItemArrayData(itemid, data);


	new itemcount = GetContainerItemCount(data[sm_containerid]);

	if(itemcount == 0)
		return 0;

	// cook time = 90 seconds per item plus random 30 seconds
	new cooktime = (itemcount * 90) + random(30);


	// if there's not enough time left, don't allow a new cook to start.
	if(gServerUptime >= gServerMaxUptime - (cooktime * 1.5))
		return -1;

	if(data[sm_fuel] < SCRAP_MACHINE_FUEL_USAGE * itemcount)
		return -2;

	new
		Float:x,
		Float:y,
		Float:z;

	GetItemPos(itemid, x, y, z);

	cooktime *= 1000; // convert to ms


	data[sm_cooking] = true;
	DestroyDynamicObject(data[sm_smoke]);
	data[sm_smoke] = CreateDynamicObject(18726, x, y, z - 1.0, 0.0, 0.0, 0.0);
	data[sm_cookTime] = cooktime;
	data[sm_startTime] = GetTickCount();

	SetItemArrayData(itemid, data, _:e_SCRAP_MACHINE_DATA);

	defer _sm_FinishCooking(itemid, cooktime);

	return cooktime;
}

timer _sm_FinishCooking[cooktime](itemid, cooktime)
{
#pragma unused cooktime

	new data[e_SCRAP_MACHINE_DATA];

	GetItemArrayData(itemid, data);

	new
		subitemid,
		containerid = data[sm_containerid],
		scrapcount;

	for(new i = GetContainerItemCount(containerid) - 1; i > -1; i--)
	{
		subitemid = GetContainerSlotItem(containerid, i);



		scrapcount += sm_ItemTypeScrapValue[GetItemType(subitemid)];
		data[sm_fuel] -= SCRAP_MACHINE_FUEL_USAGE;

		DestroyItem(subitemid);
	}

	scrapcount = scrapcount > MAX_SCRAP_MACHINE_ITEMS - 1 ? MAX_SCRAP_MACHINE_ITEMS - 1 : scrapcount;

	for(new i; i < scrapcount; i++)
	{
		subitemid = CreateItem(item_ScrapMetal);
		AddItemToContainer(containerid, subitemid);

	}

	DestroyDynamicObject(data[sm_smoke]);
	data[sm_cooking] = false;
	data[sm_smoke] = INVALID_OBJECT_ID;

	SetItemArrayData(itemid, data, _:e_SCRAP_MACHINE_DATA);
}