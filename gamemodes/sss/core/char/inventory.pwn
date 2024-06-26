#include <YSI\y_hooks>

#define UI_ELEMENT_TITLE	(0)
#define UI_ELEMENT_TILE		(1)
#define UI_ELEMENT_ITEM		(2)

static
	inv_GearActive[MAX_PLAYERS],
	inv_HealthInfoActive[MAX_PLAYERS],

	PlayerText:GearSlot_Head[3],
	PlayerText:GearSlot_Face[3],
	PlayerText:GearSlot_Hand[3],
	PlayerText:GearSlot_Hols[3],
	PlayerText:GearSlot_Tors[3],
	PlayerText:GearSlot_Back[3],

	inv_TempContainerID[MAX_PLAYERS],
	inv_InventoryOptionID[MAX_PLAYERS],

	inv_EscInventory[MAX_PLAYERS],
	inv_EscContainer[MAX_PLAYERS];


forward CreatePlayerTile(playerid, &PlayerText:title, &PlayerText:tile, &PlayerText:item, Float:x, Float:y, Float:width, Float:height, colour, overlaycolour);

hook OnPlayerConnect(playerid) {
	if(!IsPlayerNPC(playerid)) defer CreateTitles(playerid);
}

timer CreateTitles[100](playerid) {
    if(!IsPlayerConnected(playerid)) {
		log("[LoadAccountDelay] Player %d not connected any more.", playerid);
		return;
	}

	if(gServerInitialising) {
		defer CreateTitles(playerid);
		return;
	}

	CreatePlayerTile(playerid, GearSlot_Head[0], GearSlot_Head[1], GearSlot_Head[2], 490.0, 120.0, 60.0, 60.0, 0x00000044, 0xFFFFFFFF);
	CreatePlayerTile(playerid, GearSlot_Face[0], GearSlot_Face[1], GearSlot_Face[2], 560.0, 120.0, 60.0, 60.0, 0x00000044, 0xFFFFFFFF);
	CreatePlayerTile(playerid, GearSlot_Hand[0], GearSlot_Hand[1], GearSlot_Hand[2], 490.0, 230.0, 60.0, 60.0, 0x00000044, 0xFFFFFFFF);
	CreatePlayerTile(playerid, GearSlot_Hols[0], GearSlot_Hols[1], GearSlot_Hols[2], 560.0, 230.0, 60.0, 60.0, 0x00000044, 0xFFFFFFFF);
	CreatePlayerTile(playerid, GearSlot_Tors[0], GearSlot_Tors[1], GearSlot_Tors[2], 490.0, 340.0, 60.0, 60.0, 0x00000044, 0xFFFFFFFF);
	CreatePlayerTile(playerid, GearSlot_Back[0], GearSlot_Back[1], GearSlot_Back[2], 560.0, 340.0, 60.0, 60.0, 0x00000044, 0xFFFFFFFF);

	PlayerTextDrawSetString(playerid, GearSlot_Head[0], ls(playerid, "player/inventory/slots/head"));
	PlayerTextDrawSetString(playerid, GearSlot_Face[0], ls(playerid, "player/inventory/slots/face"));
	PlayerTextDrawSetString(playerid, GearSlot_Hand[0], ls(playerid, "player/inventory/slots/hand"));
	PlayerTextDrawSetString(playerid, GearSlot_Hols[0], ls(playerid, "player/inventory/slots/holster"));
	PlayerTextDrawSetString(playerid, GearSlot_Tors[0], ls(playerid, "player/inventory/slots/torso"));
	PlayerTextDrawSetString(playerid, GearSlot_Back[0], ls(playerid, "player/inventory/slots/back"));
}

CreatePlayerTile(playerid, &PlayerText:title, &PlayerText:tile, &PlayerText:item, Float:x, Float:y, Float:width, Float:height, colour, overlaycolour) {
	title							=CreatePlayerTextDraw(playerid, x + width / 2.0, y - 12.0, "_");
	PlayerTextDrawAlignment			(playerid, title, 2);
	PlayerTextDrawBackgroundColor	(playerid, title, 255);
	PlayerTextDrawFont				(playerid, title, 1);
	PlayerTextDrawLetterSize		(playerid, title, 0.15, 1.0);
	PlayerTextDrawColor				(playerid, title, -1);
	PlayerTextDrawSetOutline		(playerid, title, 1);
	PlayerTextDrawSetProportional	(playerid, title, 1);
	PlayerTextDrawBoxColor			(playerid, title, 0xDEB88766);
	PlayerTextDrawTextSize			(playerid, title, height, width - 4);
	PlayerTextDrawUseBox			(playerid, title, true);

	tile							=CreatePlayerTextDraw(playerid, x, y, "_");
	PlayerTextDrawFont				(playerid, tile, TEXT_DRAW_FONT_MODEL_PREVIEW);
	PlayerTextDrawBackgroundColor	(playerid, tile, colour);
	PlayerTextDrawColor				(playerid, tile, overlaycolour);
	PlayerTextDrawTextSize			(playerid, tile, width, height);
	PlayerTextDrawSetSelectable		(playerid, tile, true);

	item							=CreatePlayerTextDraw(playerid, x + width / 2.0, y + height, "_");
	PlayerTextDrawAlignment			(playerid, item, 2);
	PlayerTextDrawBackgroundColor	(playerid, item, 255);
	PlayerTextDrawFont				(playerid, item, 1);
	PlayerTextDrawLetterSize		(playerid, item, 0.15, 1.0);
	PlayerTextDrawColor				(playerid, item, -1);
	PlayerTextDrawSetOutline		(playerid, item, 1);
	PlayerTextDrawSetProportional	(playerid, item, 1);
	PlayerTextDrawTextSize			(playerid, item, height, width + 10);
}

ShowPlayerGear(playerid) {
	inv_GearActive[playerid] = true;

	for(new i; i < 3; i++) {
		PlayerTextDrawShow(playerid, GearSlot_Head[i]);
		PlayerTextDrawShow(playerid, GearSlot_Face[i]);
		PlayerTextDrawShow(playerid, GearSlot_Hand[i]);
		PlayerTextDrawShow(playerid, GearSlot_Hols[i]);
		PlayerTextDrawShow(playerid, GearSlot_Tors[i]);
		PlayerTextDrawShow(playerid, GearSlot_Back[i]);
	}

	return 1;
}

HidePlayerGear(playerid) {
	inv_GearActive[playerid] = false;

	for(new i; i < 3; i++) {
		PlayerTextDrawHide(playerid, GearSlot_Head[i]);
		PlayerTextDrawHide(playerid, GearSlot_Face[i]);
		PlayerTextDrawHide(playerid, GearSlot_Hand[i]);
		PlayerTextDrawHide(playerid, GearSlot_Hols[i]);
		PlayerTextDrawHide(playerid, GearSlot_Tors[i]);
		PlayerTextDrawHide(playerid, GearSlot_Back[i]);
	}

	CancelSelectTextDraw(playerid);
}
/*
hook OnScriptExit()
{
	foreach(new playerid : Player)
	{
		inv_GearActive[playerid] = false;

		for(new i; i < 3; i++)
		{
			PlayerTextDrawDestroy(playerid, GearSlot_Head[i]);
			PlayerTextDrawDestroy(playerid, GearSlot_Face[i]);
			PlayerTextDrawDestroy(playerid, GearSlot_Hand[i]);
			PlayerTextDrawDestroy(playerid, GearSlot_Hols[i]);
			PlayerTextDrawDestroy(playerid, GearSlot_Tors[i]);
			PlayerTextDrawDestroy(playerid, GearSlot_Back[i]);
		}
	}
}
*/
ShowPlayerHealthInfo(playerid) {
	new
		tmp,
		bodypartWounds[7],
		drugsList[MAX_DRUG_TYPE],
		drugs,
		drugName[MAX_DRUG_NAME],
		Float:bleedRate     = GetPlayerBleedRate(playerid),
		      infectedFood  = GetPlayerInfectionIntensity(playerid, 0),
		      infectedWound = GetPlayerInfectionIntensity(playerid, 1);

	GetPlayerWoundsPerBodypart(playerid, bodypartWounds);
	drugs = GetPlayerDrugsList(playerid, drugsList);

	inv_HealthInfoActive[playerid] = true;

	HideBodyPreviewUI(playerid);
	ShowBodyPreviewUI(playerid);

	SetBodyPreviewLabel(playerid, 0, tmp++, 35.0, sprintf("Cabe�a: %d", bodypartWounds[6]),
		bodypartWounds[6] ? RGBAToHex(max(bodypartWounds[6] * 50, 255), 0, 0, 255) : 0xFFFFFFFF);

	SetBodyPreviewLabel(playerid, 0, tmp++, 25.0, sprintf("Tronco: %d", bodypartWounds[0]),
		bodypartWounds[0] ? RGBAToHex(max(bodypartWounds[0] * 50, 255), 0, 0, 255) : 0xFFFFFFFF);

	SetBodyPreviewLabel(playerid, 0, tmp++, 30.0, sprintf("Bra�o D: %d", bodypartWounds[3]),
		bodypartWounds[3] ? RGBAToHex(max(bodypartWounds[3] * 50, 255), 0, 0, 255) : 0xFFFFFFFF);

	SetBodyPreviewLabel(playerid, 0, tmp++, 20.0, sprintf("Bra�o E: %d", bodypartWounds[2]),
		bodypartWounds[2] ? RGBAToHex(max(bodypartWounds[2] * 50, 255), 0, 0, 255) : 0xFFFFFFFF);

	SetBodyPreviewLabel(playerid, 0, tmp++, 20.0, sprintf("Virilha: %d", bodypartWounds[1]),
		bodypartWounds[1] ? RGBAToHex(max(bodypartWounds[1] * 50, 255), 0, 0, 255) : 0xFFFFFFFF);

	SetBodyPreviewLabel(playerid, 0, tmp++, 20.0, sprintf("Perna D: %d", bodypartWounds[5]),
		bodypartWounds[5] ? RGBAToHex(max(bodypartWounds[5] * 50, 255), 0, 0, 255) : 0xFFFFFFFF);

	SetBodyPreviewLabel(playerid, 0, tmp++, 20.0, sprintf("Perna E: %d", bodypartWounds[4]),
		bodypartWounds[4] ? RGBAToHex(max(bodypartWounds[4] * 50, 255), 0, 0, 255) : 0xFFFFFFFF);

	tmp = 0;

	if(bleedRate > 0.0)
		SetBodyPreviewLabel(playerid, 1, tmp++, 35.0, ls(playerid, "player/health/status_ui/bleeding"), RGBAToHex(truncateforbyte(floatround(bleedRate * 3200.0)), truncateforbyte(255 - floatround(bleedRate * 3200.0)), 0, 255));

	if(infectedFood)
		SetBodyPreviewLabel(playerid, 1, tmp++, 20.0, ls(playerid, "player/health/status_ui/infections/food"), 0xFF0000FF);

	if(infectedWound)
		SetBodyPreviewLabel(playerid, 1, tmp++, 20.0, ls(playerid, "player/health/status_ui/infections/wound"), 0xFF0000FF);

	for(new i; i < drugs; i++) {
		GetDrugName(drugsList[i], drugName);
		SetBodyPreviewLabel(playerid, 1, tmp++, 20.0, drugName, 0xFFFF00FF);
	}

	SetBodyPreviewFooterText(playerid, sprintf("Chance de Desmaio: %.1f%%", (GetPlayerKnockoutChance(playerid, 5.7) + GetPlayerKnockoutChance(playerid, 22.6)) / 2));
}

HidePlayerHealthInfo(playerid) {
	inv_HealthInfoActive[playerid] = false;
	HideBodyPreviewUI(playerid);
}

UpdatePlayerGear(playerid, show = 1) {
	new 
		tmp[5 + ITM_MAX_NAME + ITM_MAX_TEXT],
		itemId = GetPlayerHatItem(playerid),
		langId = GetPlayerLanguage(playerid);

	if(IsValidItem(itemId)) {
		GetItemTypeName(GetItemType(itemId), tmp);
		PlayerTextDrawSetString(playerid, GearSlot_Head[UI_ELEMENT_ITEM], tmp);
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Head[UI_ELEMENT_TILE], GetItemTypeModel(GetItemType(itemId)));
		PlayerTextDrawSetPreviewRot(playerid, GearSlot_Head[UI_ELEMENT_TILE], -45.0, 0.0, -45.0, 1.0);
	} else {
		PlayerTextDrawSetString(playerid, GearSlot_Head[UI_ELEMENT_ITEM], ls(playerid, "common/empty"));
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Head[UI_ELEMENT_TILE], 19300);
	}

	itemId = GetPlayerMaskItem(playerid);
	if(IsValidItem(itemId)) {
		GetItemTypeName(GetItemType(itemId), tmp);
		PlayerTextDrawSetString(playerid, GearSlot_Face[UI_ELEMENT_ITEM], tmp);
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Face[UI_ELEMENT_TILE], GetItemTypeModel(GetItemType(itemId)));
		PlayerTextDrawSetPreviewRot(playerid, GearSlot_Face[UI_ELEMENT_TILE], -45.0, 0.0, -45.0, 1.0);
	} else {
		PlayerTextDrawSetString(playerid, GearSlot_Face[UI_ELEMENT_ITEM], ls(playerid, "common/empty"));
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Face[UI_ELEMENT_TILE], 19300);
	}

	itemId = GetPlayerItem(playerid);
	if(IsValidItem(itemId)) {
		GetItemName(itemId, langId, tmp);
		format(tmp, sizeof(tmp), "(%02d) %s", GetItemTypeSize(GetItemType(itemId)), tmp);
		PlayerTextDrawSetString(playerid, GearSlot_Hand[UI_ELEMENT_ITEM], tmp);
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Hand[UI_ELEMENT_TILE], GetItemTypeModel(GetItemType(itemId)));
		PlayerTextDrawSetPreviewRot(playerid, GearSlot_Hand[UI_ELEMENT_TILE], -45.0, 0.0, -45.0, 1.0);
	} else {
		PlayerTextDrawSetString(playerid, GearSlot_Hand[UI_ELEMENT_ITEM], ls(playerid, "common/empty"));
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Hand[UI_ELEMENT_TILE], 19300);
	}

	itemId = GetPlayerHolsterItem(playerid);
	if(IsValidItem(itemId)) {
		GetItemName(itemId, langId, tmp);
		format(tmp, sizeof(tmp), "(%02d) %s", GetItemTypeSize(GetItemType(itemId)), tmp);
		PlayerTextDrawSetString(playerid, GearSlot_Hols[UI_ELEMENT_ITEM], tmp);
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Hols[UI_ELEMENT_TILE], GetItemTypeModel(GetItemType(itemId)));
		PlayerTextDrawSetPreviewRot(playerid, GearSlot_Hols[UI_ELEMENT_TILE], -45.0, 0.0, -45.0, 1.0);
	} else {
		PlayerTextDrawSetString(playerid, GearSlot_Hols[UI_ELEMENT_ITEM], ls(playerid, "common/empty"));
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Hols[UI_ELEMENT_TILE], 19300);
	}

	if(GetPlayerAP(playerid) > 0.0) {
		PlayerTextDrawSetString(playerid, GearSlot_Tors[UI_ELEMENT_ITEM], sprintf("Colete (%.0f)", GetPlayerAP(playerid)));
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Tors[UI_ELEMENT_TILE], 19515);
		PlayerTextDrawSetPreviewRot(playerid, GearSlot_Tors[UI_ELEMENT_TILE], 0.0, -90.0, 0.0, 1.0);
	} else {
		PlayerTextDrawSetString(playerid, GearSlot_Tors[UI_ELEMENT_ITEM], ls(playerid, "common/empty"));
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Tors[UI_ELEMENT_TILE], 19300);
	}

	itemId = GetPlayerBagItem(playerid);
	if(IsValidItem(itemId)) {
		GetItemName(itemId, langId, tmp);
		PlayerTextDrawSetString(playerid, GearSlot_Back[UI_ELEMENT_ITEM], tmp);
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Back[UI_ELEMENT_TILE], GetItemTypeModel(GetItemType(itemId)));
		PlayerTextDrawSetPreviewRot(playerid, GearSlot_Back[UI_ELEMENT_TILE], 0.0, 0.0, -45.0, 1.0);
	} else {
		PlayerTextDrawSetString(playerid, GearSlot_Back[UI_ELEMENT_ITEM], ls(playerid, "common/empty"));
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Back[UI_ELEMENT_TILE], 19300);
	}

	if(show) ShowPlayerGear(playerid);

	return;
}

hook OnPlayerOpenInventory(playerid) {
	ShowPlayerGear(playerid);
	UpdatePlayerGear(playerid);
	ShowPlayerHealthInfo(playerid);
	SelectTextDraw(playerid, 0xFFFF00FF);
	HideHelpTip(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseInventory(playerid) {
	ClearAnimations(playerid);
	HidePlayerGear(playerid);
	HidePlayerHealthInfo(playerid);

	if(inv_EscInventory[playerid])
		inv_EscInventory[playerid] = false;
	else
		CancelSelectTextDraw(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenContainer(playerid, containerId) {
	ShowPlayerGear(playerid);
	UpdatePlayerGear(playerid);
	ShowPlayerHealthInfo(playerid);
	SelectTextDraw(playerid, 0xFFFF00FF);
	HideHelpTip(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseContainer(playerid, containerId) {
	HidePlayerGear(playerid);
	HidePlayerHealthInfo(playerid);

	if(inv_EscContainer[playerid])
		inv_EscContainer[playerid] = false;
 	else
		CancelSelectTextDraw(playerid);
	
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemoveFromCnt(containerId, slotid, playerid) {
	if(IsPlayerConnected(playerid))
		if(containerId == GetBagItemContainerID(GetPlayerBagItem(playerid))) UpdatePlayerGear(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemoveFromInv(playerid, itemId, slot) {
	UpdatePlayerGear(playerid, 0);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemAddToInventory(playerid, itemId, slot) {
	if(IsItemTypeCarry(GetItemType(itemId))) return 1;

	UpdatePlayerGear(playerid, 0);
	ShowActionText(playerid, ls(playerid, "player/inventory/item-added"), 3000);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemovedFromPlayer(playerid, itemId) {
	if(IsItemTypeCarry(GetItemType(itemId))) SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
	
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerClickPlayerTD(playerid, PlayerText:playertextid) {
	if(playertextid == GearSlot_Head[UI_ELEMENT_TILE])
		_inv_HandleGearSlotClick_Head(playerid);
	else if(playertextid == GearSlot_Face[UI_ELEMENT_TILE])
		_inv_HandleGearSlotClick_Face(playerid);
	else if(playertextid == GearSlot_Hand[UI_ELEMENT_TILE])
		_inv_HandleGearSlotClick_Hand(playerid);
	else if(playertextid == GearSlot_Hols[UI_ELEMENT_TILE])
		_inv_HandleGearSlotClick_Hols(playerid);
	else if(playertextid == GearSlot_Tors[UI_ELEMENT_TILE])
		_inv_HandleGearSlotClick_Tors(playerid);
	else if(playertextid == GearSlot_Back[UI_ELEMENT_TILE])
		_inv_HandleGearSlotClick_Back(playerid);

	return 1;
}

_inv_HandleGearSlotClick_Head(playerid) {
	new itemId = GetPlayerHatItem(playerid);
	
	if(!IsValidItem(itemId)) return 0;

	new containerId = GetPlayerCurrentContainer(playerid);

	if(IsValidContainer(containerId)) {
		if(IsContainerFull(containerId)) {
			if(!IsValidItem(GetPlayerItem(playerid))) {
				RemovePlayerHatItem(playerid);
				GiveWorldItemToPlayer(playerid, itemId);
				ShowActionText(playerid, ls(playerid, "player/inventory/hat-removed"), 3000);
			} else 
				ShowActionText(playerid, ls(playerid, "player/inventory/holding-item"), 3000);
		} else {
			new required = AddItemToContainer(containerId, itemId, playerid);

			if(required > 0) 
				ShowActionText(playerid, sprintf(ls(playerid, "item/container/extra-slots"), required), 3000);
			else if(required == 0) {
				RemovePlayerHatItem(playerid);
				ShowActionText(playerid, ls(playerid, "player/inventory/hat-removed"), 3000);
			}
		}

		DisplayContainerInventory(playerid, containerId);
	} else {
		if(IsPlayerInventoryFull(playerid)) {
			if(!IsValidItem(GetPlayerItem(playerid))) {
				RemovePlayerHatItem(playerid);
				GiveWorldItemToPlayer(playerid, itemId);
				ShowActionText(playerid, ls(playerid, "player/inventory/hat-removed"), 3000);
			}
			else 
				ShowActionText(playerid, ls(playerid, "player/inventory/holding-item"), 3000);
		} else {
			new required = AddItemToInventory(playerid, itemId);

			if(required > 0) 
				ShowActionText(playerid, sprintf(ls(playerid, "item/container/extra-slots-inventory"), required), 3000);
			else if(required == 0) {
				RemovePlayerHatItem(playerid);
				ShowActionText(playerid, ls(playerid, "player/inventory/hat-removed"), 3000);
			}
		}

		DisplayPlayerInventory(playerid);
	}

	UpdatePlayerGear(playerid);

	return 1;
}

_inv_HandleGearSlotClick_Face(playerid) {
	new itemId = GetPlayerMaskItem(playerid);
	
	if(!IsValidItem(itemId)) return 0;

	new containerId = GetPlayerCurrentContainer(playerid);

	if(IsValidContainer(containerId)) {
		if(IsContainerFull(containerId)) {
			if(!IsValidItem(GetPlayerItem(playerid))) {
				RemovePlayerMaskItem(playerid);
				GiveWorldItemToPlayer(playerid, itemId);
				ShowActionText(playerid, ls(playerid, "player/inventory/mask-removed"), 3000);
			}
			else 
				ShowActionText(playerid, ls(playerid, "player/inventory/holding-item"), 3000);
		} else {
			new required = AddItemToContainer(containerId, itemId, playerid);

			if(required > 0) 
				ShowActionText(playerid, sprintf(ls(playerid, "item/container/extra-slots"), required), 3000);
			else if(required == 0) {
				RemovePlayerMaskItem(playerid);
				ShowActionText(playerid, ls(playerid, "player/inventory/mask-removed"), 3000);
			}
		}

		DisplayContainerInventory(playerid, containerId);
	} else {
		if(IsPlayerInventoryFull(playerid)) {
			if(!IsValidItem(GetPlayerItem(playerid))) {
				RemovePlayerMaskItem(playerid);
				GiveWorldItemToPlayer(playerid, itemId);
				ShowActionText(playerid, ls(playerid, "player/inventory/mask-removed"), 3000);
			} else 
				ShowActionText(playerid, ls(playerid, "player/inventory/holding-item"), 3000);
		} else {
			new required = AddItemToInventory(playerid, itemId);

			if(required > 0) 
				ShowActionText(playerid, sprintf(ls(playerid, "item/container/extra-slots-inventory"), required), 3000);
			else if(required == 0) {
				RemovePlayerMaskItem(playerid);
				ShowActionText(playerid, ls(playerid, "player/inventory/mask-removed"), 3000);
			}
		}

		DisplayPlayerInventory(playerid);
	}

	UpdatePlayerGear(playerid);

	return 1;
}

_inv_HandleGearSlotClick_Hand(playerid) {
	new itemId = GetPlayerItem(playerid);
	
	if(!IsValidItem(itemId)) return 0;

	new containerId = GetPlayerCurrentContainer(playerid);

	if(IsValidContainer(containerId)) {
		if(IsItemTypeBag(GetItemType(itemId))) if(containerId == GetBagItemContainerID(itemId)) return 1;

		if(IsItemTypeSafebox(GetItemType(itemId))) if(GetContainerSafeboxItem(containerId) == itemId) return 1;

		new required = AddItemToContainer(containerId, itemId, playerid);

		if(required > 0) {
			ShowActionText(playerid, sprintf(ls(playerid, "item/container/extra-slots"), required), 3000);
			return 1;
		}

		DisplayContainerInventory(playerid, containerId);
	} else {
		new required = AddItemToInventory(playerid, itemId);

		if(required > 0) {
			ShowActionText(playerid, sprintf(ls(playerid, "item/container/extra-slots-inventory"), required), 3000, 150);
			return 1;
		}

		DisplayPlayerInventory(playerid);
	}

	UpdatePlayerGear(playerid);

	return 1;
}

_inv_HandleGearSlotClick_Hols(playerid) {
	new itemId = GetPlayerHolsterItem(playerid);
	
	if(!IsValidItem(itemId)) return 0;

	new containerId = GetPlayerCurrentContainer(playerid);

	if(IsValidContainer(containerId)) {
		if(IsItemTypeBag(GetItemType(itemId))) if(containerId == GetBagItemContainerID(itemId)) return 1;

		new required = AddItemToContainer(containerId, itemId, playerid);

		if(required > 0) 
			ShowActionText(playerid, sprintf(ls(playerid, "item/container/extra-slots"), required), 3000, 150);
		else if(required == 0) 
			RemovePlayerHolsterItem(playerid);

		DisplayContainerInventory(playerid, containerId);
	} else {
		new required = AddItemToInventory(playerid, itemId);

		if(required > 0) 
			ShowActionText(playerid, sprintf(ls(playerid, "item/container/extra-slots-inventory"), required), 3000, 150);
		else if(required == 0) 
			RemovePlayerHolsterItem(playerid);
		
		DisplayPlayerInventory(playerid);
	}

	UpdatePlayerGear(playerid);

	return 1;
}

_inv_HandleGearSlotClick_Tors(playerid) {
	if(GetPlayerAP(playerid) == 0.0) return 0;

	new
		itemId = GetPlayerArmourItem(playerid),
		containerId = GetPlayerCurrentContainer(playerid);

	if(IsValidContainer(containerId)) {
		new required = AddItemToContainer(containerId, itemId, playerid);

		if(required > 0) {
			ShowActionText(playerid, sprintf(ls(playerid, "item/container/extra-slots"), required), 3000, 150);

			if(!IsValidItem(GetPlayerItem(playerid))) {
				SetItemExtraData(itemId, floatround(GetPlayerAP(playerid)));
				SetPlayerAP(playerid, 0.0);
				RemovePlayerArmourItem(playerid);
				GiveWorldItemToPlayer(playerid, itemId);
			}
			else 
				ShowActionText(playerid, ls(playerid, "player/inventory/holding-item"), 3000);
		} else if(required == 0) {
			SetItemExtraData(itemId, floatround(GetPlayerAP(playerid)));
			SetPlayerAP(playerid, 0.0);
			RemovePlayerArmourItem(playerid);
			ShowActionText(playerid, ls(playerid, "player/inventory/armour-removed"), 3000);
		}

		DisplayContainerInventory(playerid, containerId);
	} else {
		new required = AddItemToInventory(playerid, itemId);

		if(required > 0) {
			ShowActionText(playerid, sprintf(ls(playerid, "item/container/extra-slots-inventory"), required), 3000, 150);

			if(!IsValidItem(GetPlayerItem(playerid))) {
				SetItemExtraData(itemId, floatround(GetPlayerAP(playerid)));
				SetPlayerAP(playerid, 0.0);
				RemovePlayerArmourItem(playerid);
				GiveWorldItemToPlayer(playerid, itemId);
			}
			else 
				ShowActionText(playerid, ls(playerid, "player/inventory/holding-item"), 3000);
		} else if(required == 0) {
			SetItemExtraData(itemId, floatround(GetPlayerAP(playerid)));
			SetPlayerAP(playerid, 0.0);
			RemovePlayerArmourItem(playerid);
			ShowActionText(playerid, ls(playerid, "player/inventory/armour-removed"), 3000);
		}

		DisplayPlayerInventory(playerid);
	}

	UpdatePlayerGear(playerid);

	return 1;
}

_inv_HandleGearSlotClick_Back(playerid) {
	new itemId = GetPlayerBagItem(playerid);
	
	if(!IsValidItem(itemId)) return 0;

	if(GetPlayerCurrentContainer(playerid) == GetBagItemContainerID(itemId)) {
		ClosePlayerContainer(playerid);

		if(IsValidContainer(inv_TempContainerID[playerid]))
			DisplayContainerInventory(playerid, inv_TempContainerID[playerid]);
		else
			DisplayPlayerInventory(playerid);

		inv_TempContainerID[playerid] = INVALID_CONTAINER_ID;
	} else {
		inv_TempContainerID[playerid] = GetPlayerCurrentContainer(playerid);

		DisplayContainerInventory(playerid, GetBagItemContainerID(itemId));
	}

	UpdatePlayerGear(playerid, 0);

	return 1;
}

hook OnPlayerViewCntOpt(playerid, containerId) {
	if(containerId == GetBagItemContainerID(GetPlayerBagItem(playerid))) {
		if(IsValidContainer(inv_TempContainerID[playerid])) {
			new name[CNT_MAX_NAME];

			GetContainerName(inv_TempContainerID[playerid], name);

			inv_InventoryOptionID[playerid] = AddContainerOption(playerid, sprintf("Mover para %s", name));
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerSelectCntOpt(playerid, containerId, option) {
	if(containerId == GetBagItemContainerID(GetPlayerBagItem(playerid))) {
		if(IsValidContainer(inv_TempContainerID[playerid])) {
			if(option == inv_InventoryOptionID[playerid]) {
				new
					slot   = GetPlayerContainerSlot(playerid),
					itemId = GetContainerSlotItem(containerId, slot);

				if(!IsValidItem(itemId)) {
					DisplayContainerInventory(playerid, containerId);
					return 0;
				}

				new required = AddItemToContainer(inv_TempContainerID[playerid], itemId, playerid);

				if(required > 0)
					ShowActionText(playerid, sprintf(ls(playerid, "item/container/extra-slots"), required), 3000, 150);
				else
					DisplayContainerInventory(playerid, containerId);
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerClickTextDraw(playerid, Text:clickedid) {
	if(clickedid == Text:65535) {
		if(IsPlayerViewingInventory(playerid)) {
			HidePlayerGear(playerid);
			HidePlayerHealthInfo(playerid);
			ClosePlayerInventory(playerid);
			inv_EscInventory[playerid] = true;
			ClearAnimations(playerid);
			// DisplayPlayerInventory(playerid);
		}

		if(GetPlayerCurrentContainer(playerid) != INVALID_CONTAINER_ID) {
			HidePlayerGear(playerid);
			HidePlayerHealthInfo(playerid);
			ClosePlayerContainer(playerid);
			ClearAnimations(playerid);
			inv_EscContainer[playerid] = true;
			// DisplayContainerInventory(playerid, GetPlayerCurrentContainer(playerid));
		}
	}
}

hook OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart) {
	// ? Que porra e essa?
	if(IsPlayerSpawned(playerid)) 
		if(inv_HealthInfoActive[playerid]) ShowPlayerHealthInfo(playerid);
}