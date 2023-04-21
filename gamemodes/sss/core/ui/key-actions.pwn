#include <YSI\y_hooks>


static
PlayerText:	KeyActions[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
			KeyActionsText[MAX_PLAYERS][512];


hook OnPlayerConnect(playerid)
{
	KeyActions[playerid]			=CreatePlayerTextDraw(playerid, 618.000000, 120.000000, "fixed it");
	PlayerTextDrawAlignment			(playerid, KeyActions[playerid], 3);
	PlayerTextDrawBackgroundColor	(playerid, KeyActions[playerid], 255);
	PlayerTextDrawFont				(playerid, KeyActions[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, KeyActions[playerid], 0.300000, 1.499999);
	PlayerTextDrawColor				(playerid, KeyActions[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, KeyActions[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, KeyActions[playerid], 1);
}


/*==============================================================================

	Core

==============================================================================*/

stock ShowPlayerKeyActionUI(playerid)
{
	PlayerTextDrawSetString(playerid, KeyActions[playerid], KeyActionsText[playerid]);
	PlayerTextDrawShow(playerid, KeyActions[playerid]);
}

stock HidePlayerKeyActionUI(playerid)
{
	if(!IsPlayerNPC(playerid))
		PlayerTextDrawHide(playerid, KeyActions[playerid]);
}

stock ClearPlayerKeyActionUI(playerid)
	KeyActionsText[playerid][0] = EOS;

stock AddToolTipText(playerid, key[], use[])
	strcat(KeyActionsText[playerid], sprintf("~y~%s ~w~%s~n~", key, use));

/*==============================================================================

	Internal

==============================================================================*/


// Enter/exit inventory
hook OnPlayerOpenInventory(playerid)
	HidePlayerKeyActionUI(playerid);

hook OnPlayerCloseInventory(playerid)
	_UpdateKeyActions(playerid);
	
hook OnPlayerOpenContainer(playerid, containerid)
	HidePlayerKeyActionUI(playerid);

hook OnPlayerCloseContainer(playerid, containerid)
	_UpdateKeyActions(playerid);

hook OnPlayerAddToInventory(playerid, itemid)
	_UpdateKeyActions(playerid);

hook OnItemRemovedFromInv(playerid, itemid, slot)
	_UpdateKeyActions(playerid);

hook OnItemRemovedFromPlayer(playerid, itemid)
	_UpdateKeyActions(playerid);

// Pickup/drop item
hook OnPlayerPickedUpItem(playerid, itemid)
	_UpdateKeyActions(playerid);

hook OnPlayerDroppedItem(playerid, itemid)
	_UpdateKeyActions(playerid);

hook OnPlayerGetItem(playerid, itemid)
	_UpdateKeyActions(playerid);

hook OnPlayerGiveItem(playerid, targetid, itemid)
	_UpdateKeyActions(playerid);

hook OnPlayerGivenItem(playerid, targetid, itemid)
	_UpdateKeyActions(playerid);

// Vehicles
hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
	_UpdateKeyActions(playerid);

hook OnPlayerExitVehicle(playerid, vehicleid)
	_UpdateKeyActions(playerid);

// Areas
hook OnPlayerEnterDynArea(playerid, areaid)
	_UpdateKeyActions(playerid);

hook OnPlayerLeaveDynArea(playerid, areaid)
	_UpdateKeyActions(playerid);

// State change
hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	_UpdateKeyActions(playerid);

	if(!IsPlayerToolTipsOn(playerid)) return 1;

	if(newstate != PLAYER_STATE_DRIVER) return 1;

	new vehicleid = GetPlayerVehicleID(playerid);

	if(!IsValidVehicle(vehicleid)) return 1;

	_ShowRepairTip(playerid, vehicleid);

	return 1;
}

_UpdateKeyActions(playerid)
{
    if(IsPlayerNPC(playerid)) return;

	if(
		!IsPlayerSpawned(playerid) || 
		IsPlayerViewingInventory(playerid) || 
		IsValidContainer(GetPlayerCurrentContainer(playerid)) || 
		IsPlayerKnockedOut(playerid) || 
		!IsPlayerHudOn(playerid)
	) {
		HidePlayerKeyActionUI(playerid);
		return;		
	}

	if(IsPlayerInAnyVehicle(playerid)) {
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
			ClearPlayerKeyActionUI(playerid);
			AddToolTipText(playerid, KEYTEXT_ENGINE, ls(playerid, "player/key-actions/vehicle/toggle_engine"));
			AddToolTipText(playerid, KEYTEXT_LIGHTS, ls(playerid, "player/key-actions/vehicle/toggle_lights"));
			AddToolTipText(playerid, KEYTEXT_DOORS, ls(playerid, "player/key-actions/vehicle/toggle_doors"));
			AddToolTipText(playerid, KEYTEXT_INVENTORY, ls(playerid, "player/key-actions/vehicle/toggle_horn"));
			ShowPlayerKeyActionUI(playerid);
			
			return;
		}
	}

	new
		itemid = GetPlayerItem(playerid),
		invehiclearea = GetPlayerVehicleArea(playerid),
		inplayerarea = -1;
	
	ClearPlayerKeyActionUI(playerid);

	if(invehiclearea != INVALID_VEHICLE_ID && !IsPlayerInAnyVehicle(playerid)) {
		if(IsPlayerAtVehicleTrunk(playerid, invehiclearea))
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/vehicle/open_trunk"));

		if(IsPlayerAtVehicleBonnet(playerid, invehiclearea))
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/vehicle/repair_engine"));
	}

	foreach(new i : Player) {
		if(IsPlayerInPlayerArea(playerid, i)) {
			inplayerarea = i;
			break;
		}
	}

	if(!IsValidItem(itemid)) {
		if(IsPlayerCuffed(inplayerarea)) {
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/player/apply_cuffs"));
			ShowPlayerKeyActionUI(playerid);
		}

		AddToolTipText(playerid, KEYTEXT_INVENTORY, ls(playerid, "player/key-actions/player/open_inventory"));			    

		if(IsValidItem(GetPlayerBagItem(playerid)))
			AddToolTipText(playerid, KEYTEXT_DROP_ITEM, ls(playerid, "player/key-actions/player/remove_bag"));

		if(IsValidItem(GetPlayerHolsterItem(playerid)))
			AddToolTipText(playerid, KEYTEXT_PUT_AWAY, ls(playerid, "player/key-actions/player/holster"));

		ShowPlayerKeyActionUI(playerid);

		return;
	}

	// Itens simples

	new ItemType:itemtype = GetItemType(itemid);

	if(itemtype == item_Sign)
		AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/player/set_sign"));
	else if(itemtype == item_Armour)
		AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/player/wear_vest"));
	else if(itemtype == item_Crowbar)
		AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/player/disassemble"));	
	else if(itemtype == item_Shield)
		AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/player/use_shield"));
	else if(itemtype == item_Clothes)
		AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/player/wear_clothes"));
	else if(itemtype == item_HerpDerp)
		AddToolTipText(playerid, KEYTEXT_INTERACT, "Herp-a-Derp");
	else if(itemtype == item_HandCuffs) {
		if(inplayerarea != -1)
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/player/appy_cuffs"));
	} else if(itemtype == item_Wheel)
		AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/vehicle/replace_tyre"));
	else if(itemtype == item_GasCan) {
		if(invehiclearea != INVALID_VEHICLE_ID  && !IsPlayerInAnyVehicle(playerid))
		{
			if(IsPlayerAtVehicleBonnet(playerid, invehiclearea))
				AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/vehicle/refuel"));
		}
		else
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/item/fill-petrolcan"));
	} else if(itemtype == item_Headlight) {
		if(invehiclearea != INVALID_VEHICLE_ID  && !IsPlayerInAnyVehicle(playerid))
			if(IsPlayerAtVehicleBonnet(playerid, invehiclearea))
				AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/vehicle/replace_light"));
	} else if(itemtype == item_Pills)
		AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/items/take_pills"));
	else if(itemtype == item_AutoInjec)
		AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, inplayerarea == -1 ? "player/key-actions/player/inject_me" : "player/key-actions/player/inject_player"));
	else if(itemtype == item_Medkit || itemtype == item_Bandage || itemtype == item_DoctorBag)
		AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, inplayerarea != -1 ? "player/key-actions/player/heal_player" : "player/key-actions/player/heal_me"));
	else if(itemtype == item_Wrench || itemtype == item_Screwdriver || itemtype == item_Hammer) {
		if(invehiclearea != INVALID_VEHICLE_ID  && !IsPlayerInAnyVehicle(playerid))
			if(IsPlayerAtVehicleBonnet(playerid, invehiclearea))
				AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/vehicle/repair-engine"));
	} else {
		if(IsItemTypeFood(itemtype))
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/player/eat"));
		else if(IsItemTypeBag(itemtype)) {
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/player/open_bag"));
			AddToolTipText(playerid, KEYTEXT_PUT_AWAY, ls(playerid, "player/key-actions/items/use"));
		} else if(GetHatFromItem(itemtype) != -1)
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/items/use-acessory"));
		else if(GetMaskFromItem(itemtype) != -1)
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/items/use-acessory"));
		else if(GetItemTypeExplosiveType(itemtype) != -1)
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/items/arm_explosive"));
		else if(GetItemTypeLiquidContainerType(itemtype) != -1 && itemtype != item_GasCan)
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/player/drink"));
	}
	
	if(GetItemTypeWeapon(itemtype) != -1) {
		ClearPlayerKeyActionUI(playerid);

		if(IsValidHolsterItem(itemtype)) {
			AddToolTipText(playerid, KEYTEXT_INVENTORY, ls(playerid, "player/key-actions/player/open_inventory"));
			AddToolTipText(playerid, KEYTEXT_PUT_AWAY, ls(playerid, "player/key-actions/player/holster"));
		}

		if(GetItemWeaponCalibre(GetItemTypeWeapon(itemtype)) != NO_CALIBRE) {
			if(GetItemTypeAmmoType(GetItemWeaponItemAmmoItem(itemid)) != -1 && GetItemWeaponItemMagAmmo(itemid) + GetItemWeaponItemReserve(itemid) != 0)
				AddToolTipText(playerid, KEYTEXT_DROP_ITEM, ls(playerid, "player/key-actions/item/dropreload-weapon"));
			else
				AddToolTipText(playerid, KEYTEXT_DROP_ITEM, ls(playerid, "player/key-actions/player/item_drop"));
		}
	} else {
		AddToolTipText(playerid, KEYTEXT_INVENTORY, ls(playerid, "player/key-actions/player/open_inventory"));
		AddToolTipText(playerid, KEYTEXT_DROP_ITEM, ls(playerid, "player/key-actions/player/item_drop"));
		    
		if(IsValidItem(GetPlayerHolsterItem(playerid)))
			AddToolTipText(playerid, KEYTEXT_PUT_AWAY, ls(playerid, "KA_CCOLDRE2"));
	}

	if(IsPlayerOnAdminDuty(playerid))
		AddToolTipText(playerid, KEYTEXT_INVENTORY, ls(playerid, "player/key-actions/player/open_inventory"));

    //AddToolTipText(playerid, "ALT", ls(playerid, "player/key-actions/player/open_map"));

	ShowPlayerKeyActionUI(playerid);
}

_ShowRepairTip(playerid, vehicleid)
{
	new Float:health;
	GetVehicleHealth(vehicleid, health);

	if(health <= VEHICLE_HEALTH_CHUNK_2)
		ShowHelpTip(playerid, ls(playerid, "tutorial/tip/vehicle-wrench"));
	else if(health <= VEHICLE_HEALTH_CHUNK_3)
		ShowHelpTip(playerid, ls(playerid, "tutorial/tip/vehicle-screwdriver"));
	else if(health <= VEHICLE_HEALTH_CHUNK_4)
		ShowHelpTip(playerid, ls(playerid, "tutorial/tip/vehicle-hammer"));
	else if(health <= VEHICLE_HEALTH_MAX)
		ShowHelpTip(playerid, ls(playerid, "tutorial/tip/vehicle-spanner"));
	
	return;
}