#include <YSI\y_hooks>

static
PlayerText:	KeyActions[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
			KeyActionsText[MAX_PLAYERS][512];

hook OnPlayerConnect(playerid) {
	KeyActions[playerid]			=CreatePlayerTextDraw(playerid, 618.000000, 120.000000, "Yes");
	PlayerTextDrawAlignment			(playerid, KeyActions[playerid], 3);
	PlayerTextDrawBackgroundColor	(playerid, KeyActions[playerid], 255);
	PlayerTextDrawFont				(playerid, KeyActions[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, KeyActions[playerid], 0.300000, 1.499999);
	PlayerTextDrawColor				(playerid, KeyActions[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, KeyActions[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, KeyActions[playerid], 1);
}

stock ShowPlayerKeyActionUI(playerid) {
	PlayerTextDrawSetString(playerid, KeyActions[playerid], KeyActionsText[playerid]);
	PlayerTextDrawShow(playerid, KeyActions[playerid]);
}

stock HidePlayerKeyActionUI(playerid) {
	if(!IsPlayerNPC(playerid)) PlayerTextDrawHide(playerid, KeyActions[playerid]);
}

stock ClearPlayerKeyActionUI(playerid) KeyActionsText[playerid][0] = EOS;

stock AddToolTipText(playerid, key[], use[]) strcat(KeyActionsText[playerid], sprintf("~y~%s ~w~%s~n~", key, use));

// Enter/exit inventory
hook OnPlayerOpenInventory(playerid) HidePlayerKeyActionUI(playerid);

hook OnPlayerCloseInventory(playerid) _UpdateKeyActions(playerid);
	
hook OnPlayerOpenContainer(playerid, containerid) HidePlayerKeyActionUI(playerid);

hook OnPlayerCloseContainer(playerid, containerid) _UpdateKeyActions(playerid);

hook OnPlayerAddToInventory(playerid, itemId) _UpdateKeyActions(playerid);

hook OnItemRemovedFromInv(playerid, itemId, slot) _UpdateKeyActions(playerid);

hook OnItemRemovedFromPlayer(playerid, itemId) _UpdateKeyActions(playerid);

// Pickup/drop item
hook OnPlayerPickedUpItem(playerid, itemId) _UpdateKeyActions(playerid);

hook OnPlayerDroppedItem(playerid, itemId) _UpdateKeyActions(playerid);

hook OnPlayerGetItem(playerid, itemId) _UpdateKeyActions(playerid);

hook OnPlayerGiveItem(playerid, targetid, itemId) _UpdateKeyActions(playerid);

hook OnPlayerGivenItem(playerid, targetid, itemId) _UpdateKeyActions(playerid);

// Vehicles
hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger) _UpdateKeyActions(playerid);

hook OnPlayerExitVehicle(playerid, vehicleid) _UpdateKeyActions(playerid);

// Areas
hook OnPlayerEnterDynArea(playerid, areaid) _UpdateKeyActions(playerid);

hook OnPlayerLeaveDynArea(playerid, areaid) _UpdateKeyActions(playerid);

// State change
hook OnPlayerStateChange(playerid, newstate, oldstate) {
	_UpdateKeyActions(playerid);

	if(!IsPlayerToolTipsOn(playerid)) return 1;

	if(newstate != PLAYER_STATE_DRIVER) return 1;

	new vehicleId = GetPlayerVehicleID(playerid);

	if(!IsValidVehicle(vehicleId)) return 1;

	_ShowRepairTip(playerid, vehicleId);

	return 1;
}

_UpdateKeyActions(playerid) {
    if(IsPlayerNPC(playerid)) return;

	if(
		(!IsPlayerSpawned(playerid) && !IsPlayerInTutorial(playerid)) ||
		IsPlayerViewingInventory(playerid) ||
		IsValidContainer(GetPlayerCurrentContainer(playerid)) ||
		IsPlayerKnockedOut(playerid) ||
		!IsPlayerHudOn(playerid)
	) {
		HidePlayerKeyActionUI(playerid);
		return;
	}

	if(IsPlayerInAnyVehicle(playerid)) {
		new vehicleId = GetPlayerVehicleID(playerid);

		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER && Vehicle_IsCar(vehicleId)  || Vehicle_IsHelicopter(vehicleId) || Vehicle_IsPlane(vehicleId)) {
			ClearPlayerKeyActionUI(playerid);
			AddToolTipText(playerid, KEYTEXT_ENGINE, ls(playerid, "player/key-actions/vehicle/toggle_engine"));
			AddToolTipText(playerid, KEYTEXT_LIGHTS, ls(playerid, "player/key-actions/vehicle/toggle_lights"));
			AddToolTipText(playerid, KEYTEXT_DOORS, ls(playerid, "player/key-actions/vehicle/toggle_doors"));
			AddToolTipText(playerid, KEYTEXT_INVENTORY, ls(playerid, "player/key-actions/vehicle/toggle_horn"));
			ShowPlayerKeyActionUI(playerid);
			
			return;
		} else if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER && Vehicle_IsBike(vehicleId) || Vehicle_IsBoat(vehicleId)) {
			ClearPlayerKeyActionUI(playerid);
			AddToolTipText(playerid, KEYTEXT_ENGINE, ls(playerid, "player/key-actions/vehicle/toggle_engine"));
			AddToolTipText(playerid, KEYTEXT_LIGHTS, ls(playerid, "player/key-actions/vehicle/toggle_lights"));
			AddToolTipText(playerid, KEYTEXT_INVENTORY, ls(playerid, "player/key-actions/vehicle/toggle_horn"));
			ShowPlayerKeyActionUI(playerid);
			
			return;
		}
	}

	new
		itemId        = GetPlayerItem(playerid),
		inVehicleArea = GetPlayerVehicleArea(playerid),
		inPlayerArea  = -1;
	
	ClearPlayerKeyActionUI(playerid);

	if(inVehicleArea != INVALID_VEHICLE_ID && !IsPlayerInAnyVehicle(playerid)) {
		if(IsPlayerAtVehicleTrunk(playerid, inVehicleArea)) AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/vehicle/open_trunk"));

		if(IsPlayerAtVehicleBonnet(playerid, inVehicleArea)) AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/vehicle/repair-engine"));
	}

	foreach(new i : Player) {
		if(IsPlayerInPlayerArea(playerid, i)) {
			inPlayerArea = i;
			break;
		}
	}

	if(!IsValidItem(itemId)) {
		if(IsPlayerCuffed(inPlayerArea)) {
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/player/apply_cuffs"));
			ShowPlayerKeyActionUI(playerid);
		}

		// Check if player is standing at an item
		new 
		         currButton         = GetPlayerButtonID(playerid),
		         currButtonItem     = GetItemFromButtonID(currButton),
		ItemType:currButtonItemType = GetItemType(currButtonItem),
		itemTypeName[24];

		GetItemTypeName(currButtonItemType, itemTypeName);

		// printf("[KEY-ACTIONS] currButton: %d, currButtonItemId: %d, itemType: %s", currButton, currButtonItem, itemTypeName);

		if(currButtonItemType != INVALID_ITEM_TYPE) { // Player is standing at an item
			if(IsItemTypeBag(currButtonItemType)) {
				AddToolTipText(playerid, KEYTEXT_INTERACT, "Olhar Dentro");
				AddToolTipText(playerid, KEYTEXT_INTERACT, "Pegar (Segurar)");
			} else if(IsItemTypeCarry(currButtonItemType)) {
				AddToolTipText(playerid, KEYTEXT_INTERACT, "Carregar");
			} else
				AddToolTipText(playerid, KEYTEXT_INTERACT, "Pegar Item");
		}

		AddToolTipText(playerid, KEYTEXT_INVENTORY, ls(playerid, "player/key-actions/player/open_inventory"));			    

		if(IsValidItem(GetPlayerBagItem(playerid))) AddToolTipText(playerid, KEYTEXT_DROP_ITEM, ls(playerid, "player/key-actions/player/remove_bag"));

		if(IsValidItem(GetPlayerHolsterItem(playerid))) AddToolTipText(playerid, KEYTEXT_PUT_AWAY, ls(playerid, "player/key-actions/player/holster-get"));

		ShowPlayerKeyActionUI(playerid);

		return;
	}

	// Itens simples

	new ItemType:itemType = GetItemType(itemId);

	if(itemType == item_Sign)
		AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/player/set_sign"));
	else if(itemType == item_Armour)
		AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/player/wear_vest"));
	else if(itemType == item_Crowbar)
		AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/player/disassemble"));	
	else if(itemType == item_Shield)
		AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/player/use_shield"));
	else if(itemType == item_Clothes)
		AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/player/wear_clothes"));
	else if(itemType == item_HerpDerp)
		AddToolTipText(playerid, KEYTEXT_INTERACT, "Herp-a-Derp");
	else if(itemType == item_HandCuffs) {
		if(inPlayerArea != -1) AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/player/apply_cuffs"));
	} else if(itemType == item_Wheel)
		AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/vehicle/replace_tyre"));
	else if(itemType == item_GasCan) {
		if(inVehicleArea != INVALID_VEHICLE_ID  && !IsPlayerInAnyVehicle(playerid)) {
			if(IsPlayerAtVehicleBonnet(playerid, inVehicleArea))
				AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/vehicle/refuel"));
		} else
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/item/fill-petrolcan"));
	} else if(itemType == item_Headlight) {
		if(inVehicleArea != INVALID_VEHICLE_ID  && !IsPlayerInAnyVehicle(playerid))
			if(IsPlayerAtVehicleBonnet(playerid, inVehicleArea))
				AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/vehicle/replace_light"));
	} else if(itemType == item_Pills)
		AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/items/take_pills"));
	else if(itemType == item_AutoInjec)
		AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, inPlayerArea == -1 ? "player/key-actions/player/inject_me" : "player/key-actions/player/inject_player"));
	else if(itemType == item_Medkit || itemType == item_Bandage || itemType == item_DoctorBag)
		AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, inPlayerArea != -1 ? "player/key-actions/player/heal_player" : "player/key-actions/player/heal_me"));
	else if(itemType == item_Wrench || itemType == item_Screwdriver || itemType == item_Hammer) {
		if(inVehicleArea != INVALID_VEHICLE_ID  && !IsPlayerInAnyVehicle(playerid))
			if(IsPlayerAtVehicleBonnet(playerid, inVehicleArea))
				AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/vehicle/repair-engine"));
	} else {
		if(IsItemTypeFood(itemType))
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/player/eat"));
		else if(IsItemTypeBag(itemType)) {
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/player/open_bag"));
			AddToolTipText(playerid, KEYTEXT_PUT_AWAY, ls(playerid, "player/key-actions/items/equip"));
		} else if(GetHatFromItem(itemType) != -1)
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/items/use-acessory"));
		else if(GetMaskFromItem(itemType) != -1)
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/items/use-acessory"));
		else if(GetItemTypeExplosiveType(itemType) != -1)
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/items/arm_explosive"));
		else if(GetItemTypeLiquidContainerType(itemType) != -1 && itemType != item_GasCan)
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "player/key-actions/player/drink"));
	}
	
	if(GetItemTypeWeapon(itemType) != -1) {
		ClearPlayerKeyActionUI(playerid);

		if(IsValidHolsterItem(itemType)) {
			AddToolTipText(playerid, KEYTEXT_INVENTORY, ls(playerid, "player/key-actions/player/open_inventory"));
			AddToolTipText(playerid, KEYTEXT_PUT_AWAY, ls(playerid, "player/key-actions/player/holster"));
		}

		if(GetItemWeaponCalibre(GetItemTypeWeapon(itemType)) != NO_CALIBRE) {
			if(GetItemTypeAmmoType(GetItemWeaponItemAmmoItem(itemId)) != -1 && GetItemWeaponItemMagAmmo(itemId) + GetItemWeaponItemReserve(itemId) != 0)
				AddToolTipText(playerid, KEYTEXT_DROP_ITEM, ls(playerid, "player/key-actions/item/dropreload-weapon"));
			else
				AddToolTipText(playerid, KEYTEXT_DROP_ITEM, ls(playerid, "player/key-actions/player/item_drop"));
		}
	} else {
		AddToolTipText(playerid, KEYTEXT_INVENTORY, ls(playerid, "player/key-actions/player/open_inventory"));
		AddToolTipText(playerid, KEYTEXT_DROP_ITEM, ls(playerid, "player/key-actions/player/item_drop"));
		    
		if(IsValidItem(GetPlayerHolsterItem(playerid)) && !IsValidItem(itemId)) AddToolTipText(playerid, KEYTEXT_PUT_AWAY, ls(playerid, "player/key-actions/player/holster-get"));
	}

	// if(IsPlayerOnAdminDuty(playerid)) AddToolTipText(playerid, KEYTEXT_INVENTORY, ls(playerid, "player/key-actions/player/open_inventory"));

    //AddToolTipText(playerid, "ALT", ls(playerid, "player/key-actions/player/open_map"));

	ShowPlayerKeyActionUI(playerid);
}

_ShowRepairTip(playerid, vehicleid) {
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