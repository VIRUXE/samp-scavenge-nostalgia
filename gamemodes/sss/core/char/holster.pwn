#include <YSI\y_hooks>

#define MAX_HOLSTER_ITEM_TYPES	(64)

enum E_HOLSTER_TYPE_DATA
{
ItemType:	hols_itemType,
			hols_boneId,
Float:		hols_offsetPosX,
Float:		hols_offsetPosY,
Float:		hols_offsetPosZ,
Float:		hols_offsetRotX,
Float:		hols_offsetRotY,
Float:		hols_offsetRotZ,
			hols_time,
			hols_animLib[32],
			hols_animName[32]
}


static
			hols_TypeData[MAX_HOLSTER_ITEM_TYPES][E_HOLSTER_TYPE_DATA],
			hols_Total,
			hols_ItemTypeHolsterDataID[ITM_MAX_TYPES] = {-1, ...},
			hols_Item[MAX_PLAYERS] = {INVALID_ITEM_ID, ...},
			hols_LastHolster[MAX_PLAYERS];


forward OnPlayerHolsterItem(playerid, itemid);
forward OnPlayerHolsteredItem(playerid, itemid);
forward OnPlayerUnHolsterItem(playerid, itemid);
forward OnPlayerUnHolsteredItem(playerid, itemid);

hook OnPlayerConnect(playerid) {
	hols_Item[playerid] = INVALID_ITEM_ID;
}

stock SetItemTypeHolsterable(ItemType:itemtype, boneid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, animtime, animlib[32], animname[32]) {
	if(!IsValidItemType(itemtype)) return -1;

	if(hols_Total >= MAX_HOLSTER_ITEM_TYPES) return -1;

	hols_TypeData[hols_Total][hols_itemType] = itemtype;
	hols_TypeData[hols_Total][hols_boneId] = boneid;
	hols_TypeData[hols_Total][hols_offsetPosX] = x;
	hols_TypeData[hols_Total][hols_offsetPosY] = y;
	hols_TypeData[hols_Total][hols_offsetPosZ] = z;
	hols_TypeData[hols_Total][hols_offsetRotX] = rx;
	hols_TypeData[hols_Total][hols_offsetRotY] = ry;
	hols_TypeData[hols_Total][hols_offsetRotZ] = rz;
	hols_TypeData[hols_Total][hols_time] = animtime;
	hols_TypeData[hols_Total][hols_animLib] = animlib;
	hols_TypeData[hols_Total][hols_animName] = animname;

	hols_ItemTypeHolsterDataID[itemtype] = hols_Total;

	return hols_Total++;
}

/*hook OnPlayerUpdate(playerid){
	new itemid = GetPlayerItem(playerid);
	
	if(itemid != INVALID_ITEM_ID && GetPlayerWeapon(playerid) > 0){
	    ResetPlayerWeapons(playerid);
	    return 1;
	}
	
	if(GetItemTypeWeapon(GetItemType(itemid)) != -1){
	    if(GetPlayerTotalAmmo(playerid) > 0 && GetPlayerWeapon(playerid) < 1){
	        if(CallLocalFunction("OnPlayerHolsterItem", "dd", playerid, itemid))
				return 1;
				
            SetPlayerHolsterItem(playerid, itemid);
            CallLocalFunction("OnPlayerHolsteredItem", "dd", playerid, itemid);
            return 1;
	    }
	}

	if(itemid == INVALID_ITEM_ID && GetPlayerWeapon(playerid) > 0){
	    if(!IsValidItem(hols_Item[playerid]))
			return 1;

        if(CallLocalFunction("OnPlayerUnHolsterItem", "dd", playerid, hols_Item[playerid]))
			return 1;
		
		CreateItemInWorld(hols_Item[playerid]);
		GiveWorldItemToPlayer(playerid, hols_Item[playerid]);

		CallLocalFunction("OnPlayerUnHolsteredItem", "dd", playerid, hols_Item[playerid]);

		RemovePlayerHolsterItem(playerid);
	}
	
	return 1;
}*/

stock SetPlayerHolsterItem(playerid, itemid) {
	if(!IsPlayerConnected(playerid)) return 0;

	if(!IsValidItem(itemid)) return 0;

	new ItemType:itemtype = GetItemType(itemid);

	if(hols_ItemTypeHolsterDataID[itemtype] == -1) return 0;

	if(GetPlayerItem(playerid) == itemid) RemoveCurrentItem(playerid);

	RemoveItemFromWorld(itemid);
	RemoveCurrentItem(GetItemHolder(itemid));

	SetPlayerAttachedObject(playerid, ATTACHSLOT_HOLSTER, GetItemTypeModel(GetItemType(itemid)),
		hols_TypeData[hols_ItemTypeHolsterDataID[itemtype]][hols_boneId],
		hols_TypeData[hols_ItemTypeHolsterDataID[itemtype]][hols_offsetPosX],
		hols_TypeData[hols_ItemTypeHolsterDataID[itemtype]][hols_offsetPosY],
		hols_TypeData[hols_ItemTypeHolsterDataID[itemtype]][hols_offsetPosZ],
		hols_TypeData[hols_ItemTypeHolsterDataID[itemtype]][hols_offsetRotX],
		hols_TypeData[hols_ItemTypeHolsterDataID[itemtype]][hols_offsetRotY],
		hols_TypeData[hols_ItemTypeHolsterDataID[itemtype]][hols_offsetRotZ],
		1.0, 1.0, 1.0);

	hols_Item[playerid] = itemid;

	return 1;
}

stock RemovePlayerHolsterItem(playerid) {
	if(!IsPlayerConnected(playerid)) return 0;

	RemovePlayerAttachedObject(playerid, ATTACHSLOT_HOLSTER);
	hols_Item[playerid] = INVALID_ITEM_ID;

	return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	if((newkeys & KEY_YES)) {
		if(_HolsterChecks(playerid)) {
			new Float:z;

			GetPlayerVelocity(playerid, z, z, z);

			if(!(-0.01 < z < 0.01)) return 1;

			if(IsValidItem(GetPlayerItem(playerid))) _HolsterItem(playerid); else _UnholsterItem(playerid);

			return 1;
		}
	}

	return 1;
}

hook OnItemAddToInventory(playerid, itemid, slot) {
	// This is to stop holstered items from being added to the inventory too.
	// (They share the same key.)
	if(!IsValidContainer(GetPlayerCurrentContainer(playerid)) && !IsPlayerViewingInventory(playerid)) {
		if(IsValidHolsterItem(GetItemType(itemid)))
			return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_HolsterChecks(playerid) {
	// Player can't holster/unholster when:

	// In vehicle
	if(IsPlayerInAnyVehicle(playerid)) return 0;

	// Cuffed
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED) return 0;

	// Doing this animation (whatever it is)
	if(GetPlayerAnimationIndex(playerid) == 1381) return 0;

	// Within 1 second of previously holstering/unholstering
	if(GetTickCountDifference(GetTickCount(), hols_LastHolster[playerid]) < SEC(1)) return 0;

	// On duty
	if(IsPlayerOnAdminDuty(playerid)) return 0;

	// Knocked out
	if(IsPlayerKnockedOut(playerid)) return 0;

	// Interacting with a valid item
	if(IsValidItem(GetPlayerInteractingItem(playerid))) return 0;

	// Interacting with a container
	if(IsValidContainer(GetPlayerCurrentContainer(playerid))) return 0;

	// Viewing inventory screen
	if(IsPlayerViewingInventory(playerid)) return 0;

	return 1;
}

_HolsterItem(playerid) {
	new itemid, ItemType:itemtype;

	itemid = GetPlayerItem(playerid);
	itemtype = GetItemType(itemid);

	if(!IsValidItemType(itemtype)) return 0;

	if(hols_ItemTypeHolsterDataID[itemtype] == -1) return 0;

	if(CallLocalFunction("OnPlayerHolsterItem", "dd", playerid, itemid)) return 0;

	ApplyAnimation(playerid, hols_TypeData[hols_ItemTypeHolsterDataID[itemtype]][hols_animLib], hols_TypeData[hols_ItemTypeHolsterDataID[itemtype]][hols_animName], 1.7, 0, 0, 0, 0, hols_TypeData[hols_ItemTypeHolsterDataID[itemtype]][hols_time]);
	defer HolsterItemDelay(playerid, itemid, hols_TypeData[hols_ItemTypeHolsterDataID[itemtype]][hols_time]);
	hols_LastHolster[playerid] = GetTickCount();

	return 1;
}

timer HolsterItemDelay[time](playerid, itemid, time) {
	#pragma unused time

	if(!IsValidItem(itemid)) return 0;

	new currentitem = hols_Item[playerid];

	if(itemid == currentitem) {
		err("Player %p (%d) attempting to holster item (%d) that's already holstered!", playerid, playerid, itemid);
		RemoveCurrentItem(playerid);
		return 0;
	}

	SetPlayerHolsterItem(playerid, itemid);
	ClearAnimations(playerid);

	if(IsValidItem(currentitem)) {
		GiveWorldItemToPlayer(playerid, currentitem);
		
		ShowActionText(playerid, ls(playerid, "player/holster/change"), SEC(3));
		
		CallLocalFunction("OnPlayerUnHolsteredItem", "dd", playerid, currentitem);
	} else {
		ShowActionText(playerid, ls(playerid, "player/holster/put"), SEC(3));

		CallLocalFunction("OnPlayerHolsteredItem", "dd", playerid, itemid);
	}

	return 1;
}

_UnholsterItem(playerid) {
	new ItemType:itemtype = GetItemType(hols_Item[playerid]);

	if(!IsValidItemType(itemtype)) return 0;

	if(hols_ItemTypeHolsterDataID[itemtype] == -1) return 0;

	if(CallLocalFunction("OnPlayerUnHolsterItem", "dd", playerid, hols_Item[playerid])) return 0;

	ApplyAnimation(playerid, hols_TypeData[hols_ItemTypeHolsterDataID[itemtype]][hols_animLib], hols_TypeData[hols_ItemTypeHolsterDataID[itemtype]][hols_animName], 1.7, 0, 0, 0, 0, hols_TypeData[hols_ItemTypeHolsterDataID[itemtype]][hols_time]);
	defer UnholsterItemDelay(playerid, hols_TypeData[hols_ItemTypeHolsterDataID[itemtype]][hols_time]);
	hols_LastHolster[playerid] = GetTickCount();

	return 1;
}

timer UnholsterItemDelay[time](playerid, time) {
	#pragma unused time

	if(!IsValidItem(hols_Item[playerid])) return 0;

	CreateItemInWorld(hols_Item[playerid]);
	GiveWorldItemToPlayer(playerid, hols_Item[playerid]);

	ShowActionText(playerid, ls(playerid, "player/holster/equip"), SEC(3));
    	
	CallLocalFunction("OnPlayerUnHolsteredItem", "dd", playerid, hols_Item[playerid]);

	RemovePlayerHolsterItem(playerid);

	return 1;
}

hook OnPlayerPickUpItem(playerid, itemid) {
	if(GetTickCountDifference(GetTickCount(), hols_LastHolster[playerid]) < SEC(1)) return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerGiveItem(playerid, targetid, itemid) {
	if(GetTickCountDifference(GetTickCount(), hols_LastHolster[playerid]) < SEC(1)) return Y_HOOKS_BREAK_RETURN_1;

	if(GetTickCountDifference(GetTickCount(), hols_LastHolster[targetid]) < SEC(1)) return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenInventory(playerid) {
	if(GetTickCountDifference(GetTickCount(), hols_LastHolster[playerid]) < SEC(2)) return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenContainer(playerid, containerid) {
	if(GetTickCountDifference(GetTickCount(), hols_LastHolster[playerid]) < SEC(2)) return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

stock GetPlayerHolsterItem(playerid) {
	if(!IsPlayerConnected(playerid)) return 0;

	return hols_Item[playerid];
}

stock GetPlayerLastHolsterTick(playerid) {
	if(!IsPlayerConnected(playerid)) return 0;

	return hols_LastHolster[playerid];
}

stock IsValidHolsterItem(ItemType:itemtype) {
	if(!IsValidItemType(itemtype)) return 0;

	return (hols_ItemTypeHolsterDataID[itemtype] != -1);
}
