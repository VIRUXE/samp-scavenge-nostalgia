#include <YSI\y_hooks>

#define MAX_CONSTRUCT_SET (48)
#define MAX_CONSTRUCT_SET_ITEMS (BTN_MAX_INRANGE)

enum E_CONSTRUCT_SET_DATA {
			cons_buildtime,
ItemType:	cons_tool,
			cons_craftset,
ItemType:	cons_removalTool,
			cons_removalTime,
bool:		cons_tweak
}


static
		cons_Data[MAX_CONSTRUCT_SET][E_CONSTRUCT_SET_DATA],
		cons_Total,
		cons_CraftsetConstructSet[CFT_MAX_CRAFT_SET] = {-1, ...},
		cons_Constructing[MAX_PLAYERS] = {-1, ...},
		cons_Deconstructing[MAX_PLAYERS] = {-1, ...},
		cons_DeconstructingItem[MAX_PLAYERS] = {INVALID_ITEM_ID, ...},
		cons_SelectedItems[MAX_PLAYERS][MAX_CONSTRUCT_SET_ITEMS][e_selected_item_data],
		cons_SelectedItemCount[MAX_PLAYERS];


forward OnPlayerConstruct(playerid, consset);
forward OnPlayerConstructed(playerid, consset, result);
forward OnPlayerDeconstructed(playerid, itemid, itemid2);

hook OnPlayerConnect(playerid) {
	for(new i; i < MAX_CONSTRUCT_SET_ITEMS; i++) {
		cons_SelectedItems[playerid][i][cft_selectedItemType] = INVALID_ITEM_TYPE;
		cons_SelectedItems[playerid][i][cft_selectedItemID]   = INVALID_ITEM_ID;
	}

	cons_SelectedItemCount[playerid] = 0;
	cons_Constructing[playerid]      = -1;
}

stock SetCraftSetConstructible(buildtime, ItemType:tool, craftset, ItemType:removal = INVALID_ITEM_TYPE, removaltime = 0, bool:tweak = true) {
	cons_Data[cons_Total][cons_buildtime]   = buildtime;
	cons_Data[cons_Total][cons_tool]        = tool;
	cons_Data[cons_Total][cons_craftset]    = craftset;
	cons_Data[cons_Total][cons_removalTool] = removal;
	cons_Data[cons_Total][cons_removalTime] = removaltime;
	cons_Data[cons_Total][cons_tweak]       = tweak;

	cons_CraftsetConstructSet[craftset] = cons_Total;

	return cons_Total++;
}

hook OnPlayerUseItem(playerid, itemid) {
	new
		list[BTN_MAX_INRANGE] = {INVALID_BUTTON_ID, ...},
		size;

	size = GetPlayerNearbyItems(playerid, list);

	if(size > 1) {
		_ResetSelectedItems(playerid);

		for(new i; i < size; i++) {
		    if(IsItemTypeDefence(GetItemType(list[i])) && GetDefenceActive(list[i])) continue;
				
			cons_SelectedItems[playerid][i][cft_selectedItemType] = GetItemType(list[i]);
			cons_SelectedItems[playerid][i][cft_selectedItemID] = list[i];
			cons_SelectedItemCount[playerid]++;
		}

		new craftset = _cft_FindCraftset(cons_SelectedItems[playerid], size);

		if(IsValidCraftSet(craftset)) {
			if(cons_CraftsetConstructSet[craftset] != -1) {
				if(cons_Data[cons_CraftsetConstructSet[craftset]][cons_tool] == GetItemType(GetPlayerItem(playerid))) {
					if(!CallLocalFunction("OnPlayerConstruct", "dd", playerid, cons_CraftsetConstructSet[craftset])) {
						StartHoldAction(playerid, GetPlayerVipMulti(playerid, cons_Data[cons_CraftsetConstructSet[craftset]][cons_buildtime]));

						ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
						ShowActionText(playerid, ls(playerid, "item/craft/constructing"));

						cons_Constructing[playerid] = craftset;

						return Y_HOOKS_BREAK_RETURN_1;
					}
				}
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid) {
	new craftset = ItemTypeResultForCraftingSet(GetItemType(withitemid));

	// ! wtf
	if(IsValidCraftSet(craftset)) {
		if(cons_CraftsetConstructSet[craftset] != -1) {
			if(GetItemType(itemid) == cons_Data[cons_CraftsetConstructSet[craftset]][cons_removalTool])
				StartRemovingConstructedItem(playerid, withitemid, craftset);
		}
	}
}

StartRemovingConstructedItem(playerid, itemid, craftset) {
	new uniqueid[ITM_MAX_NAME];
	GetItemTypeName(GetCraftSetResult(craftset), uniqueid);
	
	StartHoldAction(playerid, GetPlayerVipMulti(playerid, cons_Data[cons_CraftsetConstructSet[craftset]][cons_removalTime]));	    

	ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
	ShowActionText(playerid, ls(playerid, "item/craft/deconstructing"));
	cons_Deconstructing[playerid]     = craftset;
	cons_DeconstructingItem[playerid] = itemid;
}

StopRemovingConstructedItem(playerid) {
	StopHoldAction(playerid);
	ClearAnimations(playerid);
	HideActionText(playerid);
	cons_Deconstructing[playerid]     = -1;
	cons_DeconstructingItem[playerid] = INVALID_ITEM_ID;
}

hook OnHoldActionUpdate(playerid, progress)  {
	if(cons_Constructing[playerid] != INVALID_ITEM_ID || cons_DeconstructingItem[playerid] != INVALID_ITEM_ID)  {
		if(GetPlayerTotalVelocity(playerid) > 1.0)  {
			_ResetSelectedItems(playerid);
			cons_Constructing[playerid] = INVALID_ITEM_ID;
			StopRemovingConstructedItem(playerid);
		}

		return Y_HOOKS_BREAK_RETURN_0;
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnHoldActionFinish(playerid) {
	if(cons_Constructing[playerid] != -1) {
		new
			Float:x, Float:y, Float:z,
			Float:tx, Float:ty, Float:tz,
			count,
			itemid,
			uniqueid[ITM_MAX_NAME];

		GetItemTypeName(GetCraftSetResult(cons_Constructing[playerid]), uniqueid);
		
		if(random(10) == 5){
			DestroyItem(GetPlayerItem(playerid));
			ShowActionText(playerid, "~r~Sua ferramenta quebrou.");
		}

		for( ; count < cons_SelectedItemCount[playerid] && cons_SelectedItems[playerid][count][cft_selectedItemID] != INVALID_ITEM_ID; count++) {
			GetItemPos(cons_SelectedItems[playerid][count][cft_selectedItemID], x, y, z);

			if(x * y * z != 0.0) {
				tx += x;
				ty += y;
				tz += z;
			}

			if(!GetCraftSetItemKeep(cons_Constructing[playerid], count)) DestroyItem(cons_SelectedItems[playerid][count][cft_selectedItemID]);
		}

		tx /= float(count);
		ty /= float(count);
		tz /= float(count);

		itemid = CreateItem(GetCraftSetResult(cons_Constructing[playerid]), tx, ty, tz, .world = GetPlayerVirtualWorld(playerid), .interior = GetPlayerInterior(playerid));

		if(cons_Data[cons_CraftsetConstructSet[cons_Constructing[playerid]]][cons_tweak]) TweakItem(playerid, itemid);

		CallLocalFunction("OnPlayerConstructed", "ddd", playerid, cons_CraftsetConstructSet[cons_Constructing[playerid]], itemid);

		ClearAnimations(playerid);
		HideActionText(playerid);

		_ResetSelectedItems(playerid);

		if(!cons_Data[cons_CraftsetConstructSet[cons_Constructing[playerid]]][cons_tweak]) cons_Constructing[playerid] = -1;
	} else if(cons_Deconstructing[playerid] != INVALID_ITEM_ID) {
		if(!CallLocalFunction("OnPlayerDeconstructed", "ddd", playerid, cons_DeconstructingItem[playerid], cons_Deconstructing[playerid])) {
			new
				Float:x, Float:y, Float:z,
				recipedata[CFT_MAX_CRAFT_SET_ITEMS][e_craft_item_data],
				recipeitems;

			GetItemPos(cons_DeconstructingItem[playerid], x, y, z);

			DestroyItem(cons_DeconstructingItem[playerid]);

			recipeitems = GetCraftSetIngredients(cons_Deconstructing[playerid], recipedata);

			for(new i; i < recipeitems; i++) {
				// items that were kept at the time of crafting are ignored
				// since they never originally left the player's posession.
				if(recipedata[i][cft_keepItem]) continue;

				CreateItem(recipedata[i][cft_itemType], x + frandom(0.6), y + frandom(0.6), z, 0.0, 0.0, frandom(360.0), GetItemWorld(cons_DeconstructingItem[playerid]), GetItemInterior(cons_DeconstructingItem[playerid]));
			}

			StopRemovingConstructedItem(playerid);
		}
	}
}

hook OnItemTweakFinish(playerid, itemid) {
	cons_Constructing[playerid] = -1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	if(RELEASED(16)) {
		if(cons_Constructing[playerid] != -1) {
			StopHoldAction(playerid);
			ClearAnimations(playerid);
			HideActionText(playerid);
			_ResetSelectedItems(playerid);

			cons_Constructing[playerid] = -1;
		} else if(cons_Deconstructing[playerid] != -1)
			StopRemovingConstructedItem(playerid);
	}
}

hook OnPlayerCraft(playerid, craftset) {
	if(cons_CraftsetConstructSet[craftset] != -1) return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_ResetSelectedItems(playerid) {
	for(new i; i < MAX_CONSTRUCT_SET_ITEMS; i++) {
		cons_SelectedItems[playerid][i][cft_selectedItemType] = INVALID_ITEM_TYPE;
		cons_SelectedItems[playerid][i][cft_selectedItemID] = INVALID_ITEM_ID;
	}

	cons_SelectedItemCount[playerid] = 0;
}

stock IsValidConstructionSet(consset) {
	if(!(0 <= consset < MAX_CONSTRUCT_SET)) return 0;

	return 1;
}

stock GetConstructionSetBuildTime(consset) {
	if(!(0 <= consset < MAX_CONSTRUCT_SET)) return -1;

	return cons_Data[consset][cons_buildtime];
}

forward ItemType:GetConstructionSetTool(consset);
stock ItemType:GetConstructionSetTool(consset) {
	if(!(0 <= consset < MAX_CONSTRUCT_SET)) return INVALID_ITEM_TYPE;

	return cons_Data[consset][cons_tool];
}

stock GetConstructionSetCraftSet(consset) {
	if(!(0 <= consset < MAX_CONSTRUCT_SET)) return -1;

	return cons_Data[consset][cons_craftset];
}

stock GetCraftSetConstructSet(craftset) {
	if(!IsValidCraftSet(craftset)) return -1;

	return cons_CraftsetConstructSet[craftset];
}

stock GetPlayerConstructing(playerid) return cons_Constructing[playerid];

stock GetPlayerConstructionItems(playerid, output[MAX_CONSTRUCT_SET_ITEMS][e_selected_item_data], &count) {
	for(new i; i < MAX_CONSTRUCT_SET_ITEMS && cons_SelectedItems[playerid][i][cft_selectedItemID] != -1; i++)
		output[i] = cons_SelectedItems[playerid][i];

	count = cons_SelectedItemCount[playerid];

	return 1;
}