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

static
bool:	wb_ConstructionSetWorkbench[MAX_CONSTRUCT_SET],
		wb_CurrentConstructSet[MAX_PLAYERS],
		wb_CurrentWorkbench[MAX_PLAYERS];


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnPlayerConnect(playerid)
{
	wb_CurrentConstructSet[playerid] = -1;
	wb_CurrentWorkbench[playerid] = -1;
}

hook OnPlayerDisconnect(playerid, reason)
{
	if(wb_CurrentWorkbench[playerid] != -1)
		_wb_StopWorking(playerid);
}


/*==============================================================================

	Core

==============================================================================*/


stock SetConstructionSetWorkbench(consset)
{
	wb_ConstructionSetWorkbench[consset] = true;
}

stock IsValidWorkbenchConstructionSet(consset)
{
	if(!IsValidConstructionSet(consset))
	{
		err("Tried to assign workbench properties to invalid construction set ID.");
		return 0;
	}

	return wb_ConstructionSetWorkbench[consset];
}

hook OnPlayerPickUpItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Workbench)
	{
	    foreach(new i : Player){
		    if(wb_CurrentWorkbench[i] == itemid)
		        _wb_StopWorking(i);
		}
	    DisplayContainerInventory(playerid, GetItemArrayDataAtCell(itemid, 0));
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Workbench)
	{
	    foreach(new i : Player){
		    if(wb_CurrentWorkbench[i] == itemid)
		        _wb_StopWorking(i);
		}
		DisplayContainerInventory(playerid, GetItemArrayDataAtCell(itemid, 0));
	}
}

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	if(GetItemType(withitemid) == item_Workbench)
	{
		new
			craftitems[MAX_CONSTRUCT_SET_ITEMS][e_selected_item_data],
			containerid,
			itemcount,
			craftset,
			consset;

		containerid = GetItemArrayDataAtCell(withitemid, 0);
		itemcount = GetContainerItemCount(containerid);

		if(!IsValidContainer(containerid))
		{
			err("Workbench (%d) has invalid container ID (%d)", withitemid, containerid);
			return Y_HOOKS_CONTINUE_RETURN_0;
		}

		dbg("gamemodes/sss/core/world/workbench.pwn", 1, "[OnPlayerUseItemWithItem] Workbench item %d container %d itemcount %d", withitemid, containerid, itemcount);

		for(new i; i < itemcount; i++)
		{
			craftitems[i][cft_selectedItemType] = GetItemType(GetContainerSlotItem(containerid, i));
			craftitems[i][cft_selectedItemID] = GetContainerSlotItem(containerid, i);
			dbg("gamemodes/sss/core/world/workbench.pwn", 3, "[OnPlayerUseItemWithItem] Workbench item: %d (%d) valid: %d", _:craftitems[i][cft_selectedItemType], craftitems[i][cft_selectedItemID], IsValidItem(craftitems[i][cft_selectedItemID]));
		}

		craftset = _cft_FindCraftset(craftitems, itemcount);
		consset = GetCraftSetConstructSet(craftset);

		if(IsValidConstructionSet(consset))
		{
			if(wb_ConstructionSetWorkbench[consset])
			{
				dbg("gamemodes/sss/core/world/workbench.pwn", 2, "[OnPlayerUseItemWithItem] Valid consset %d", consset);

				if(GetConstructionSetTool(consset) == GetItemType(itemid))
				{
					new uniqueid[ITM_MAX_NAME];
					GetItemTypeName(GetCraftSetResult(craftset), uniqueid);

					wb_CurrentConstructSet[playerid] = consset;
					_wb_StartWorking(playerid, withitemid, itemcount * 3600);

					return Y_HOOKS_CONTINUE_RETURN_0;
				}
			}
		}

		if(GetItemType(itemid) != item_Crowbar) {
		    foreach(new i : Player){
			    if(wb_CurrentWorkbench[i] == itemid)
			        _wb_StopWorking(i);
			}
			DisplayContainerInventory(playerid, containerid);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_wb_ClearWorkbench(itemid)
{
	new
		containerid,
		itemcount;

	containerid = GetItemArrayDataAtCell(itemid, 0);
	itemcount = GetContainerItemCount(containerid);

	for(; itemcount >= 0; itemcount--)
		DestroyItem(GetContainerSlotItem(containerid, itemcount));
}

_wb_StartWorking(playerid, itemid, buildtime)
{
	SetPlayerFacingAngle(playerid, GetPlayerAngleToButton(playerid, GetItemButtonID(itemid)));
	ApplyAnimation(playerid, "INT_SHOP", "SHOP_CASHIER", 4.0, 1, 0, 0, 0, 0, 1);
	StartHoldAction(playerid, buildtime);
	
	foreach(new i : Player){
	    if(wb_CurrentWorkbench[i] == itemid)
	        _wb_StopWorking(i);
	        
		if(GetPlayerCurrentContainer(i) == GetItemArrayDataAtCell(itemid, 0))
		    Dialog_Close(i);
	}
	
	wb_CurrentWorkbench[playerid] = itemid;
}

_wb_StopWorking(playerid)
{
	ClearAnimations(playerid);

	StopHoldAction(playerid);
	wb_CurrentWorkbench[playerid] = -1;
}

_wb_CreateResult(itemid, craftset)
{
	dbg("gamemodes/sss/core/world/workbench.pwn", 1, "[_wb_CreateResult] itemid %d craftset %d", itemid, craftset);

	new
		Float:x,
		Float:y,
		Float:z,
		Float:rz;

	GetItemPos(itemid, x, y, z);
	GetItemRot(itemid, rz, rz, rz);

	CreateItem(GetCraftSetResult(craftset), x, y, z + 0.95, 0.0, 0.0, rz - 95.0 + frandom(10.0));
	
	//printf("[CRAFT] %p craftou o item %d em %0.1f, %0.1f, %0.1\n", playerid, ItemType:GetCraftSetResult(craftset), Float:x, Float:y, Float:z);
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	dbg("global", CORE, "[OnPlayerKeyStateChange] in /gamemodes/sss/core/world/workbench.pwn");

	if(RELEASED(16))
	{
		if(wb_CurrentWorkbench[playerid] != -1)
		{
			dbg("gamemodes/sss/core/world/workbench.pwn", 1, "[OnPlayerKeyStateChange] stopping workbench build");
			_wb_StopWorking(playerid);
		}
	}

	return 1;
}

hook OnHoldActionFinish(playerid)
{
	dbg("global", CORE, "[OnHoldActionFinish] in /gamemodes/sss/core/world/workbench.pwn");

	if(wb_CurrentWorkbench[playerid] != -1)
	{
		dbg("gamemodes/sss/core/world/workbench.pwn", 1, "[OnHoldActionFinish] workbench build complete, workbenchid: %d, construction set: %d", wb_CurrentWorkbench[playerid], wb_CurrentConstructSet[playerid]);

		new
			craftset = GetConstructionSetCraftSet(wb_CurrentConstructSet[playerid]),
			uniqueid[ITM_MAX_NAME];

		GetItemTypeName(GetCraftSetResult(craftset), uniqueid);

		_wb_ClearWorkbench(wb_CurrentWorkbench[playerid]);
		_wb_CreateResult(wb_CurrentWorkbench[playerid], craftset);
		_wb_StopWorking(playerid);
		wb_CurrentWorkbench[playerid] = -1;
		wb_CurrentConstructSet[playerid] = -1;
	}
}

hook OnPlayerConstruct(playerid, consset)
{
	dbg("global", CORE, "[OnPlayerConstruct] in /gamemodes/sss/core/world/workbench.pwn");

	if(!IsValidConstructionSet(consset))
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(wb_ConstructionSetWorkbench[consset] == true)
	{
		dbg("gamemodes/sss/core/world/workbench.pwn", 2, "[OnPlayerConstruct] playerid %d consset %d attempted construction of workbench consset", playerid, consset);
		ShowActionText(playerid, GetLanguageString(playerid, "NEEDWORKBE", true), 5000);
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
