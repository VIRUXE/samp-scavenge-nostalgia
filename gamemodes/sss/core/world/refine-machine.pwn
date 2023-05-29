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


#define MAX_REFINE_MACHINE_ITEMS	(12)
#define MAX_REFINE_MACHINE_FUEL		(80.0)
#define REFINE_MACHINE_FUEL_USAGE	(3.5)


enum e_REFINE_MACHINE_DATA
{
			rm_containerid,
Float:		rm_fuel,
bool:		rm_cooking,
			rm_smoke,
			rm_cookTime,
			rm_startTime
}


static		rm_CurrentRefineMachine[MAX_PLAYERS] = {INVALID_ITEM_ID, ...};


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnPlayerConnect(playerid)
{
	

	rm_CurrentRefineMachine[playerid] = -1;
}


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


hook OnPlayerUseMachine(playerid, itemid, interactiontype)
{


	if(GetItemType(itemid) == item_RefineMachine)
	{

		_rm_PlayerUseRefineMachine(playerid, itemid, interactiontype);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_rm_PlayerUseRefineMachine(playerid, itemid, interactiontype) {
	new data[e_REFINE_MACHINE_DATA];

	GetItemArrayData(itemid, data);

	if(data[rm_cooking]) {
		ShowActionText(playerid, sprintf(ls(playerid, "item/machines/refinement/processing"), MsToString(data[rm_cookTime] - GetTickCountDifference(GetTickCount(), data[rm_startTime]), "%m minutes %s seconds")), 8000);
		return 0;
	}

	if(interactiontype == 0) {
		if(GetItemType(itemid) != item_Crowbar)
			DisplayContainerInventory(playerid, data[rm_containerid]);

		return 0;
	}

	rm_CurrentRefineMachine[playerid] = itemid;

	new ItemType:itemtype = GetItemType(GetPlayerItem(playerid));

	if(GetItemTypeLiquidContainerType(itemtype) != -1) {
		if(GetLiquidItemLiquidType(GetPlayerItem(playerid)) == liquid_Petrol) {
			StartHoldAction(playerid, floatround(MAX_REFINE_MACHINE_FUEL * 100), floatround(data[rm_fuel] * 100));
			return 0;
		}
	}

	Dialog_Show(playerid, RefineMachine, DIALOG_STYLE_MSGBOX, "Refining Machine", sprintf("Press 'Start' to activate the refining machine and convert scrap into refined metal.\n\n"C_GREEN"Fuel amount: "C_WHITE"%.1f", data[rm_fuel]), "Start", "Cancel");

	return 0;
}

Dialog:RefineMachine(playerid, response, listitem, inputtext[]) {
	if(response) {
		new result = _rm_StartCooking(rm_CurrentRefineMachine[playerid]);

		if(result == 0)
			ShowActionText(playerid, ls(playerid, "item/machines/refinement/no-items"), 5000);
		else if(result == -1)
			ShowActionText(playerid, ls(playerid, "item/machines/refinement/server-restart"), 6000);
		else if(result == -2)
			ShowActionText(playerid, sprintf(ls(playerid, "item/machines/refinement/not-enough-fuel"), REFINE_MACHINE_FUEL_USAGE), 6000);
		else
			ShowActionText(playerid, sprintf(ls(playerid, "item/machines/refinement/cook-time"), MsToString(result, "%m minutes %s seconds")), 6000);

		rm_CurrentRefineMachine[playerid] = -1;
	}
}

hook OnItemAddToContainer(containerid, itemid, playerid) {
	if(playerid != INVALID_PLAYER_ID) {
		new ItemType:itemtype = GetItemType(GetContainerMachineItem(containerid));

		if(itemtype == item_RefineMachine) {
			if(GetItemType(itemid) != item_ScrapMetal)
				return 1;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnHoldActionUpdate(playerid, progress) {
	if(rm_CurrentRefineMachine[playerid] != -1) {
		new itemid = GetPlayerItem(playerid);

		if(GetItemTypeLiquidContainerType(GetItemType(itemid)) != -1) {
			if(GetLiquidItemLiquidType(itemid) != liquid_Petrol) {
				StopHoldAction(playerid);
				rm_CurrentRefineMachine[playerid] = -1;
				return Y_HOOKS_BREAK_RETURN_1;
			}
		}

		new
			Float:fuel = GetLiquidItemLiquidAmount(itemid),
			Float:transfer;

		if(fuel <= 0.0) {
			StopHoldAction(playerid);
			rm_CurrentRefineMachine[playerid] = -1;
			HideActionText(playerid);
		} else {
			new Float:machinefuel = Float:GetItemArrayDataAtCell(rm_CurrentRefineMachine[playerid], rm_fuel);

			transfer = (fuel - 1.1 < 0.0) ? fuel : 1.1;
			SetLiquidItemLiquidAmount(itemid, fuel - transfer);
			SetItemArrayDataAtCell(rm_CurrentRefineMachine[playerid], _:(machinefuel + 1.1), rm_fuel);
			ShowActionText(playerid, ls(playerid, "item/machines/refinement/refueling"));
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_rm_StartCooking(itemid) {
	new data[e_REFINE_MACHINE_DATA];

	GetItemArrayData(itemid, data);

	new itemcount = GetContainerItemCount(data[rm_containerid]);

	if(itemcount == 0) return 0;

	// cook time = 90 seconds per item plus random 30 seconds
	new cooktime = (itemcount * 90) + random(30);

	// if there's not enough time left, don't allow a new cook to start.
	if(gServerUptime >= gServerMaxUptime - (cooktime * 1.5)) return -1;

	if(data[rm_fuel] < REFINE_MACHINE_FUEL_USAGE * itemcount) return -2;

	new Float:x, Float:y, Float:z;

	GetItemPos(itemid, x, y, z);

	cooktime *= 1000; // convert to ms

	data[rm_cooking] = true;
	DestroyDynamicObject(data[rm_smoke]);
	data[rm_smoke]     = CreateDynamicObject(18726, x, y, z - 1.0, 0.0, 0.0, 0.0);
	data[rm_cookTime]  = cooktime;
	data[rm_startTime] = GetTickCount();

	SetItemArrayData(itemid, data, _:e_REFINE_MACHINE_DATA);

	defer _rm_FinishCooking(itemid, cooktime);

	return cooktime;
}

timer _rm_FinishCooking[cooktime](itemid, cooktime) {
	#pragma unused cooktime

	new data[e_REFINE_MACHINE_DATA];

	GetItemArrayData(itemid, data);

	new
		subitemid,
		containerid = data[rm_containerid],
		itemcount;

	for(new i = GetContainerItemCount(containerid) - 1; i > -1; i--) {
		subitemid      = GetContainerSlotItem(containerid, i);
		data[rm_fuel] -= REFINE_MACHINE_FUEL_USAGE;

		DestroyItem(subitemid);
		itemcount++;
	}

	for(new i; i < itemcount; i++) {
		subitemid = CreateItem(item_RefinedMetal);
		AddItemToContainer(containerid, subitemid);
	}

	DestroyDynamicObject(data[rm_smoke]);
	data[rm_cooking] = false;
	data[rm_smoke]   = INVALID_OBJECT_ID;

	SetItemArrayData(itemid, data, _:e_REFINE_MACHINE_DATA);
}