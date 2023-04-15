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

hook OnPlayerConnect(playerid)
	if(!IsPlayerNPC(playerid)) defer CreateTitles(playerid);

timer CreateTitles[100](playerid)
{
    if(!IsPlayerConnected(playerid))
	{
		log("[LoadAccountDelay] Player %d not connected any more.", playerid);
		return;
	}

	if(gServerInitialising)
	{
		defer CreateTitles(playerid);
		return;
	}

	CreatePlayerTile(playerid, GearSlot_Head[0], GearSlot_Head[1], GearSlot_Head[2], 490.0, 120.0, 60.0, 60.0, 0x00000044, 0xFFFFFFFF);
	CreatePlayerTile(playerid, GearSlot_Face[0], GearSlot_Face[1], GearSlot_Face[2], 560.0, 120.0, 60.0, 60.0, 0x00000044, 0xFFFFFFFF);
	CreatePlayerTile(playerid, GearSlot_Hand[0], GearSlot_Hand[1], GearSlot_Hand[2], 490.0, 230.0, 60.0, 60.0, 0x00000044, 0xFFFFFFFF);
	CreatePlayerTile(playerid, GearSlot_Hols[0], GearSlot_Hols[1], GearSlot_Hols[2], 560.0, 230.0, 60.0, 60.0, 0x00000044, 0xFFFFFFFF);
	CreatePlayerTile(playerid, GearSlot_Tors[0], GearSlot_Tors[1], GearSlot_Tors[2], 490.0, 340.0, 60.0, 60.0, 0x00000044, 0xFFFFFFFF);
	CreatePlayerTile(playerid, GearSlot_Back[0], GearSlot_Back[1], GearSlot_Back[2], 560.0, 340.0, 60.0, 60.0, 0x00000044, 0xFFFFFFFF);

	PlayerTextDrawSetString(playerid, GearSlot_Head[0], "Cabea");
	PlayerTextDrawSetString(playerid, GearSlot_Face[0], "Rosto");
	PlayerTextDrawSetString(playerid, GearSlot_Hand[0], "Mo");
	PlayerTextDrawSetString(playerid, GearSlot_Hols[0], "Coldre");
	PlayerTextDrawSetString(playerid, GearSlot_Tors[0], "Corpo");
	PlayerTextDrawSetString(playerid, GearSlot_Back[0], "Costas");
}

CreatePlayerTile(playerid, &PlayerText:title, &PlayerText:tile, &PlayerText:item, Float:x, Float:y, Float:width, Float:height, colour, overlaycolour)
{
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

ShowPlayerGear(playerid)
{
	inv_GearActive[playerid] = true;

	for(new i; i < 3; i++)
	{
		PlayerTextDrawShow(playerid, GearSlot_Head[i]);
		PlayerTextDrawShow(playerid, GearSlot_Face[i]);
		PlayerTextDrawShow(playerid, GearSlot_Hand[i]);
		PlayerTextDrawShow(playerid, GearSlot_Hols[i]);
		PlayerTextDrawShow(playerid, GearSlot_Tors[i]);
		PlayerTextDrawShow(playerid, GearSlot_Back[i]);
	}

	return 1;
}

HidePlayerGear(playerid)
{
	inv_GearActive[playerid] = false;

	for(new i; i < 3; i++)
	{
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
ShowPlayerHealthInfo(playerid)
{
	new
		string[64],
		tmp,
		bodypartwounds[7],
		drugslist[MAX_DRUG_TYPE],
		drugs,
		drugname[MAX_DRUG_NAME],
		Float:bleedrate = GetPlayerBleedRate(playerid),
		infected1 = GetPlayerInfectionIntensity(playerid, 0),
		infected2 = GetPlayerInfectionIntensity(playerid, 1);

	GetPlayerWoundsPerBodypart(playerid, bodypartwounds);
	drugs = GetPlayerDrugsList(playerid, drugslist);

	inv_HealthInfoActive[playerid] = true;

	HideBodyPreviewUI(playerid);
	ShowBodyPreviewUI(playerid);

	new strc[15];

	format(strc, sizeof(strc), "Cabeça: %d", bodypartwounds[6]);
	ConvertEncoding(strc);
	SetBodyPreviewLabel(playerid, 0, tmp++, 35.0, strc,
		bodypartwounds[6] ? RGBAToHex(max(bodypartwounds[6] * 50, 255), 0, 0, 255) : 0xFFFFFFFF);

	SetBodyPreviewLabel(playerid, 0, tmp++, 25.0, sprintf("Tronco: %d", bodypartwounds[0]),
		bodypartwounds[0] ? RGBAToHex(max(bodypartwounds[0] * 50, 255), 0, 0, 255) : 0xFFFFFFFF);

    format(strc, sizeof(strc), "Braço D: %d", bodypartwounds[3]);
	ConvertEncoding(strc);
	SetBodyPreviewLabel(playerid, 0, tmp++, 30.0, strc,
		bodypartwounds[3] ? RGBAToHex(max(bodypartwounds[3] * 50, 255), 0, 0, 255) : 0xFFFFFFFF);

    format(strc, sizeof(strc), "Braço E: %d", bodypartwounds[2]);
	ConvertEncoding(strc);
	SetBodyPreviewLabel(playerid, 0, tmp++, 20.0, strc,
		bodypartwounds[2] ? RGBAToHex(max(bodypartwounds[2] * 50, 255), 0, 0, 255) : 0xFFFFFFFF);

	SetBodyPreviewLabel(playerid, 0, tmp++, 20.0, sprintf("Virilha: %d", bodypartwounds[1]),
		bodypartwounds[1] ? RGBAToHex(max(bodypartwounds[1] * 50, 255), 0, 0, 255) : 0xFFFFFFFF);

	SetBodyPreviewLabel(playerid, 0, tmp++, 20.0, sprintf("Perna D: %d", bodypartwounds[5]),
		bodypartwounds[5] ? RGBAToHex(max(bodypartwounds[5] * 50, 255), 0, 0, 255) : 0xFFFFFFFF);

	SetBodyPreviewLabel(playerid, 0, tmp++, 20.0, sprintf("Perna E: %d", bodypartwounds[4]),
		bodypartwounds[4] ? RGBAToHex(max(bodypartwounds[4] * 50, 255), 0, 0, 255) : 0xFFFFFFFF);

	tmp = 0;

	if(bleedrate > 0.0)
		SetBodyPreviewLabel(playerid, 1, tmp++, 35.0, ls(GetPlayerLanguage(playerid), "BODYBLEED"), RGBAToHex(truncateforbyte(floatround(bleedrate * 3200.0)), truncateforbyte(255 - floatround(bleedrate * 3200.0)), 0, 255));

	if(infected1)
		SetBodyPreviewLabel(playerid, 1, tmp++, 20.0, GetLanguageString(GetPlayerLanguage(playerid), "common/empty"), 0xFF0000FF);

	if(infected2)
		SetBodyPreviewLabel(playerid, 1, tmp++, 20.0, GetLanguageString(GetPlayerLanguage(playerid), "common/empty"), 0xFF0000FF);

	for(new i; i < drugs; i++)
	{
		GetDrugName(drugslist[i], drugname);
		SetBodyPreviewLabel(playerid, 1, tmp++, 20.0, drugname, 0xFFFF00FF);
	}

	format(string, sizeof(string), "Chance de Desmaio: %.1f%%", (GetPlayerKnockoutChance(playerid, 5.7) + GetPlayerKnockoutChance(playerid, 22.6)) / 2);
	SetBodyPreviewFooterText(playerid, string);
}

HidePlayerHealthInfo(playerid)
{
	inv_HealthInfoActive[playerid] = false;
	HideBodyPreviewUI(playerid);
}

UpdatePlayerGear(playerid, show = 1)
{
	new
		tmp[5 + ITM_MAX_NAME + ITM_MAX_TEXT],
		itemid;

	itemid = GetPlayerHatItem(playerid);

	if(IsValidItem(itemid))
	{
		GetItemTypeName(GetItemType(itemid), tmp);
		ConvertEncoding(tmp);
		PlayerTextDrawSetString(playerid, GearSlot_Head[UI_ELEMENT_ITEM], tmp);
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Head[UI_ELEMENT_TILE], GetItemTypeModel(GetItemType(itemid)));
		PlayerTextDrawSetPreviewRot(playerid, GearSlot_Head[UI_ELEMENT_TILE], -45.0, 0.0, -45.0, 1.0);
	}
	else
	{
		PlayerTextDrawSetString(playerid, GearSlot_Head[UI_ELEMENT_ITEM], "<Vazio>");
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Head[UI_ELEMENT_TILE], 19300);
	}

	itemid = GetPlayerMaskItem(playerid);
	if(IsValidItem(itemid))
	{
		GetItemTypeName(GetItemType(itemid), tmp);
		ConvertEncoding(tmp);
		PlayerTextDrawSetString(playerid, GearSlot_Face[UI_ELEMENT_ITEM], tmp);
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Face[UI_ELEMENT_TILE], GetItemTypeModel(GetItemType(itemid)));
		PlayerTextDrawSetPreviewRot(playerid, GearSlot_Face[UI_ELEMENT_TILE], -45.0, 0.0, -45.0, 1.0);
	}
	else
	{
		PlayerTextDrawSetString(playerid, GearSlot_Face[UI_ELEMENT_ITEM], "<Vazio>");
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Face[UI_ELEMENT_TILE], 19300);
	}

	itemid = GetPlayerItem(playerid);
	if(IsValidItem(itemid))
	{
		GetItemName(itemid, tmp);
		ConvertEncoding(tmp);
		format(tmp, sizeof(tmp), "(%02d) %s", GetItemTypeSize(GetItemType(itemid)), tmp);
		PlayerTextDrawSetString(playerid, GearSlot_Hand[UI_ELEMENT_ITEM], tmp);
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Hand[UI_ELEMENT_TILE], GetItemTypeModel(GetItemType(itemid)));
		PlayerTextDrawSetPreviewRot(playerid, GearSlot_Hand[UI_ELEMENT_TILE], -45.0, 0.0, -45.0, 1.0);
	}
	else
	{
		PlayerTextDrawSetString(playerid, GearSlot_Hand[UI_ELEMENT_ITEM], "<Vazio>");
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Hand[UI_ELEMENT_TILE], 19300);
	}

	itemid = GetPlayerHolsterItem(playerid);
	if(IsValidItem(itemid))
	{
		GetItemName(itemid, tmp);
		ConvertEncoding(tmp);
		format(tmp, sizeof(tmp), "(%02d) %s", GetItemTypeSize(GetItemType(itemid)), tmp);
		PlayerTextDrawSetString(playerid, GearSlot_Hols[UI_ELEMENT_ITEM], tmp);
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Hols[UI_ELEMENT_TILE], GetItemTypeModel(GetItemType(itemid)));
		PlayerTextDrawSetPreviewRot(playerid, GearSlot_Hols[UI_ELEMENT_TILE], -45.0, 0.0, -45.0, 1.0);
	}
	else
	{
		PlayerTextDrawSetString(playerid, GearSlot_Hols[UI_ELEMENT_ITEM], "<Vazio>");
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Hols[UI_ELEMENT_TILE], 19300);
	}

	if(GetPlayerAP(playerid) > 0.0)
	{
		PlayerTextDrawSetString(playerid, GearSlot_Tors[UI_ELEMENT_ITEM], sprintf("Colete (%.0f)", GetPlayerAP(playerid)));
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Tors[UI_ELEMENT_TILE], 19515);
		PlayerTextDrawSetPreviewRot(playerid, GearSlot_Tors[UI_ELEMENT_TILE], -45.0, 0.0, -45.0, 1.0);
	}
	else
	{
		PlayerTextDrawSetString(playerid, GearSlot_Tors[UI_ELEMENT_ITEM], "<Vazio>");
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Tors[UI_ELEMENT_TILE], 19300);
	}

	itemid = GetPlayerBagItem(playerid);
	if(IsValidItem(itemid))
	{
		GetItemName(itemid, tmp);
		ConvertEncoding(tmp);
		PlayerTextDrawSetString(playerid, GearSlot_Back[UI_ELEMENT_ITEM], tmp);
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Back[UI_ELEMENT_TILE], GetItemTypeModel(GetItemType(itemid)));
		PlayerTextDrawSetPreviewRot(playerid, GearSlot_Back[UI_ELEMENT_TILE], 0.0, 0.0, -45.0, 1.0);
	}
	else
	{
		PlayerTextDrawSetString(playerid, GearSlot_Back[UI_ELEMENT_ITEM], "<Vazio>");
		PlayerTextDrawSetPreviewModel(playerid, GearSlot_Back[UI_ELEMENT_TILE], 19300);
	}

	if(show) ShowPlayerGear(playerid);

	return;
}

hook OnPlayerOpenInventory(playerid)
{
	dbg("global", CORE, "[OnPlayerOpenInventory] in /gamemodes/sss/core/char/inventory.pwn");

	ShowPlayerGear(playerid);
	UpdatePlayerGear(playerid);
	ShowPlayerHealthInfo(playerid);
	SelectTextDraw(playerid, 0xFFFF00FF);
	HideHelpTip(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseInventory(playerid)
{
	dbg("global", CORE, "[OnPlayerCloseInventory] in /gamemodes/sss/core/char/inventory.pwn");

	ClearAnimations(playerid);
	HidePlayerGear(playerid);
	HidePlayerHealthInfo(playerid);

	if(inv_EscInventory[playerid])
		inv_EscInventory[playerid] = false;
	else
		CancelSelectTextDraw(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenContainer(playerid, containerid)
{
	dbg("global", CORE, "[OnPlayerOpenContainer] in /gamemodes/sss/core/char/inventory.pwn");

	ShowPlayerGear(playerid);
	UpdatePlayerGear(playerid);
	ShowPlayerHealthInfo(playerid);
	SelectTextDraw(playerid, 0xFFFF00FF);
	HideHelpTip(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseContainer(playerid, containerid)
{
	dbg("global", CORE, "[OnPlayerCloseContainer] in /gamemodes/sss/core/char/inventory.pwn");

	HidePlayerGear(playerid);
	HidePlayerHealthInfo(playerid);

	if(inv_EscContainer[playerid])
		inv_EscContainer[playerid] = false;
 	else
		CancelSelectTextDraw(playerid);
	
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemoveFromCnt(containerid, slotid, playerid)
{
	dbg("global", CORE, "[OnItemRemoveFromCnt] in /gamemodes/sss/core/char/inventory.pwn");

	if(IsPlayerConnected(playerid))
		if(containerid == GetBagItemContainerID(GetPlayerBagItem(playerid))) UpdatePlayerGear(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemoveFromInv(playerid, itemid, slot)
{
	dbg("global", CORE, "[OnItemRemoveFromInv] in /gamemodes/sss/core/char/inventory.pwn");

	UpdatePlayerGear(playerid, 0);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemAddToInventory(playerid, itemid, slot)
{
	dbg("global", CORE, "[OnItemAddToInventory] in /gamemodes/sss/core/char/inventory.pwn");

	if(IsItemTypeCarry(GetItemType(itemid))) return 1;

	UpdatePlayerGear(playerid, 0);
	ShowActionText(playerid, GetLanguageString(GetPlayerLanguage(playerid), "common/empty"), 3000);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemovedFromPlayer(playerid, itemid)
{
	dbg("global", CORE, "[OnItemRemovedFromPlayer] in /gamemodes/sss/core/char/inventory.pwn");

	if(IsItemTypeCarry(GetItemType(itemid))) SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
	
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerClickPlayerTD(playerid, PlayerText:playertextid)
{
	dbg("global", CORE, "[OnPlayerClickPlayerTD] in /gamemodes/sss/core/char/inventory.pwn");

	if(playertextid == GearSlot_Head[UI_ELEMENT_TILE])
		_inv_HandleGearSlotClick_Head(playerid);

	if(playertextid == GearSlot_Face[UI_ELEMENT_TILE])
		_inv_HandleGearSlotClick_Face(playerid);

	if(playertextid == GearSlot_Hand[UI_ELEMENT_TILE])
		_inv_HandleGearSlotClick_Hand(playerid);

	if(playertextid == GearSlot_Hols[UI_ELEMENT_TILE])
		_inv_HandleGearSlotClick_Hols(playerid);

	if(playertextid == GearSlot_Tors[UI_ELEMENT_TILE])
		_inv_HandleGearSlotClick_Tors(playerid);

	if(playertextid == GearSlot_Back[UI_ELEMENT_TILE])
		_inv_HandleGearSlotClick_Back(playerid);

	return 1;
}


_inv_HandleGearSlotClick_Head(playerid)
{
	new itemid = GetPlayerHatItem(playerid);
	
	if(!IsValidItem(itemid)) return 0;

	new containerid = GetPlayerCurrentContainer(playerid);

	if(IsValidContainer(containerid))
	{
		if(IsContainerFull(containerid))
		{
			if(!IsValidItem(GetPlayerItem(playerid)))
			{
				RemovePlayerHatItem(playerid);
				GiveWorldItemToPlayer(playerid, itemid);
				ShowActionText(playerid, GetLanguageString(GetPlayerLanguage(playerid), "common/empty"), 3000);
			}
			else 
				ShowActionText(playerid, GetLanguageString(GetPlayerLanguage(playerid), "common/empty"), 3000);
				
		}
		else
		{
			new required = AddItemToContainer(containerid, itemid, playerid);

			if(required > 0) 
				ShowActionText(playerid, sprintf(GetLanguageString(GetPlayerLanguage(playerid), "common/empty"), required), 3000);
			else if(required == 0)
			{
				RemovePlayerHatItem(playerid);
				ShowActionText(playerid, GetLanguageString(GetPlayerLanguage(playerid), "common/empty"), 3000);
			}
		}

		DisplayContainerInventory(playerid, containerid);
	}
	else
	{
		if(IsPlayerInventoryFull(playerid))
		{
			if(!IsValidItem(GetPlayerItem(playerid)))
			{
				RemovePlayerHatItem(playerid);
				GiveWorldItemToPlayer(playerid, itemid);
				ShowActionText(playerid, GetLanguageString(GetPlayerLanguage(playerid), "common/empty"), 3000);
			}
			else 
				ShowActionText(playerid, GetLanguageString(GetPlayerLanguage(playerid), "common/empty"), 3000);
		}
		else
		{
			new required = AddItemToInventory(playerid, itemid);

			if(required > 0) 
				ShowActionText(playerid, sprintf(GetLanguageString(GetPlayerLanguage(playerid), "common/empty"), required), 3000);
			else if(required == 0)
			{
				RemovePlayerHatItem(playerid);
				ShowActionText(playerid, GetLanguageString(GetPlayerLanguage(playerid), "common/empty"), 3000);
			}
		}

		DisplayPlayerInventory(playerid);
	}

	UpdatePlayerGear(playerid);

	return 1;
}

_inv_HandleGearSlotClick_Face(playerid)
{
	new itemid = GetPlayerMaskItem(playerid);
	
	if(!IsValidItem(itemid)) return 0;

	new containerid = GetPlayerCurrentContainer(playerid);

	if(IsValidContainer(containerid))
	{
		if(IsContainerFull(containerid))
		{
			if(!IsValidItem(GetPlayerItem(playerid)))
			{
				RemovePlayerMaskItem(playerid);
				GiveWorldItemToPlayer(playerid, itemid);
				ShowActionText(playerid, GetLanguageString(GetPlayerLanguage(playerid), "common/empty"), 3000);
			}
			else 
				ShowActionText(playerid, GetLanguageString(GetPlayerLanguage(playerid), "common/empty"), 3000);
		}
		else
		{
			new required = AddItemToContainer(containerid, itemid, playerid);

			if(required > 0) 
				ShowActionText(playerid, sprintf(GetLanguageString(GetPlayerLanguage(playerid), "common/empty"), required), 3000);
			else if(required == 0)
			{
				RemovePlayerMaskItem(playerid);
				ShowActionText(playerid, GetLanguageString(GetPlayerLanguage(playerid), "common/empty"), 3000);
			}
		}

		DisplayContainerInventory(playerid, containerid);
	}
	else
	{
		if(IsPlayerInventoryFull(playerid))
		{
			if(!IsValidItem(GetPlayerItem(playerid)))
			{
				RemovePlayerMaskItem(playerid);
				GiveWorldItemToPlayer(playerid, itemid);
				ShowActionText(playerid, GetLanguageString(GetPlayerLanguage(playerid), "common/empty"), 3000);
			}
			else 
				ShowActionText(playerid, GetLanguageString(GetPlayerLanguage(playerid), "common/empty"), 3000);
		}
		else
		{
			new required = AddItemToInventory(playerid, itemid);

			if(required > 0) 
				ShowActionText(playerid, sprintf(GetLanguageString(GetPlayerLanguage(playerid), "common/empty"), required), 3000);
			else if(required == 0)
			{
				RemovePlayerMaskItem(playerid);
				ShowActionText(playerid, GetLanguageString(GetPlayerLanguage(playerid), "common/empty"), 3000);
			}
		}

		DisplayPlayerInventory(playerid);
	}

	UpdatePlayerGear(playerid);

	return 1;
}

_inv_HandleGearSlotClick_Hand(playerid)
{
	new itemid = GetPlayerItem(playerid);
	
	if(!IsValidItem(itemid)) return 0;

	new containerid = GetPlayerCurrentContainer(playerid);

	if(IsValidContainer(containerid))
	{
		if(IsItemTypeBag(GetItemType(itemid))) if(containerid == GetBagItemContainerID(itemid)) return 1;

		if(IsItemTypeSafebox(GetItemType(itemid))) if(GetContainerSafeboxItem(containerid) == itemid) return 1;

		new required = AddItemToContainer(containerid, itemid, playerid);

		if(required > 0)
		{
			ShowActionText(playerid, sprintf(GetLanguageString(GetPlayerLanguage(playerid), "common/empty"), required), 3000);
			return 1;
		}

		DisplayContainerInventory(playerid, containerid);
	}
	else
	{
		new required = AddItemToInventory(playerid, itemid);

		if(required > 0)
		{
			ShowActionText(playerid, sprintf(GetLanguageString(GetPlayerLanguage(playerid), "common/empty"), required), 3000, 150);
			return 1;
		}

		DisplayPlayerInventory(playerid);
	}

	UpdatePlayerGear(playerid);

	return 1;
}

_inv_HandleGearSlotClick_Hols(playerid)
{
	new itemid = GetPlayerHolsterItem(playerid);
	
	if(!IsValidItem(itemid)) return 0;

	new containerid = GetPlayerCurrentContainer(playerid);

	if(IsValidContainer(containerid))
	{
		if(IsItemTypeBag(GetItemType(itemid))) if(containerid == GetBagItemContainerID(itemid)) return 1;

		new required = AddItemToContainer(containerid, itemid, playerid);

		if(required > 0) 
			ShowActionText(playerid, sprintf(GetLanguageString(GetPlayerLanguage(playerid), "common/empty"), required), 3000, 150);
		else if(required == 0) 
			RemovePlayerHolsterItem(playerid);

		DisplayContainerInventory(playerid, containerid);
	}
	else
	{
		new required = AddItemToInventory(playerid, itemid);

		if(required > 0) 
			ShowActionText(playerid, sprintf(GetLanguageString(GetPlayerLanguage(playerid), "common/empty"), required), 3000, 150);
		else if(required == 0) 
			RemovePlayerHolsterItem(playerid);
		
		DisplayPlayerInventory(playerid);
	}

	UpdatePlayerGear(playerid);

	return 1;
}

_inv_HandleGearSlotClick_Tors(playerid)
{
	if(GetPlayerAP(playerid) == 0.0) return 0;

	new
		itemid = GetPlayerArmourItem(playerid),
		containerid = GetPlayerCurrentContainer(playerid);

	if(IsValidContainer(containerid))
	{
		new required = AddItemToContainer(containerid, itemid, playerid);

		if(required > 0)
		{
			ShowActionText(playerid, sprintf(GetLanguageString(GetPlayerLanguage(playerid), "common/empty"), required), 3000, 150);

			if(!IsValidItem(GetPlayerItem(playerid)))
			{
				SetItemExtraData(itemid, floatround(GetPlayerAP(playerid)));
				SetPlayerAP(playerid, 0.0);
				RemovePlayerArmourItem(playerid);
				GiveWorldItemToPlayer(playerid, itemid);
			}
			else 
				ShowActionText(playerid, GetLanguageString(GetPlayerLanguage(playerid), "common/empty"), 3000);
		}
		else if(required == 0)
		{
			SetItemExtraData(itemid, floatround(GetPlayerAP(playerid)));
			SetPlayerAP(playerid, 0.0);
			RemovePlayerArmourItem(playerid);
			ShowActionText(playerid, GetLanguageString(playerid, "common/empty"), 3000);
		}

		DisplayContainerInventory(playerid, containerid);
	}
	else
	{
		new required = AddItemToInventory(playerid, itemid);

		if(required > 0)
		{
			ShowActionText(playerid, sprintf(GetLanguageString(GetPlayerLanguage(playerid), "common/empty"), required), 3000, 150);

			if(!IsValidItem(GetPlayerItem(playerid)))
			{
				SetItemExtraData(itemid, floatround(GetPlayerAP(playerid)));
				SetPlayerAP(playerid, 0.0);
				RemovePlayerArmourItem(playerid);
				GiveWorldItemToPlayer(playerid, itemid);
			}
			else 
				ShowActionText(playerid, GetLanguageString(GetPlayerLanguage(playerid), "common/empty"), 3000);
		}
		else if(required == 0)
		{
			SetItemExtraData(itemid, floatround(GetPlayerAP(playerid)));
			SetPlayerAP(playerid, 0.0);
			RemovePlayerArmourItem(playerid);
			ShowActionText(playerid, GetLanguageString(playerid, "common/empty"), 3000);
		}

		DisplayPlayerInventory(playerid);
	}

	UpdatePlayerGear(playerid);

	return 1;
}

_inv_HandleGearSlotClick_Back(playerid)
{
	new itemid = GetPlayerBagItem(playerid);
	
	if(!IsValidItem(itemid)) return 0;

	if(GetPlayerCurrentContainer(playerid) == GetBagItemContainerID(itemid))
	{
		ClosePlayerContainer(playerid);

		if(IsValidContainer(inv_TempContainerID[playerid]))
			DisplayContainerInventory(playerid, inv_TempContainerID[playerid]);
		else
			DisplayPlayerInventory(playerid);

		inv_TempContainerID[playerid] = INVALID_CONTAINER_ID;
	}
	else
	{
		inv_TempContainerID[playerid] = GetPlayerCurrentContainer(playerid);

		DisplayContainerInventory(playerid, GetBagItemContainerID(itemid));
	}

	UpdatePlayerGear(playerid, 0);

	return 1;
}


hook OnPlayerViewCntOpt(playerid, containerid)
{
	dbg("global", CORE, "[OnPlayerViewCntOpt] in /gamemodes/sss/core/char/inventory.pwn");

	if(containerid == GetBagItemContainerID(GetPlayerBagItem(playerid)))
	{
		if(IsValidContainer(inv_TempContainerID[playerid]))
		{
			new
				name[CNT_MAX_NAME],
				str[9 + CNT_MAX_NAME];

			GetContainerName(inv_TempContainerID[playerid], name);
			ConvertEncoding(str);
			format(str, sizeof(str), "Mover para %s", name);

			inv_InventoryOptionID[playerid] = AddContainerOption(playerid, str);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerSelectCntOpt(playerid, containerid, option)
{
	dbg("global", CORE, "[OnPlayerSelectCntOpt] in /gamemodes/sss/core/char/inventory.pwn");

	if(containerid == GetBagItemContainerID(GetPlayerBagItem(playerid)))
	{
		if(IsValidContainer(inv_TempContainerID[playerid]))
		{
			if(option == inv_InventoryOptionID[playerid])
			{
				new
					slot,
					itemid;

				slot = GetPlayerContainerSlot(playerid);
				itemid = GetContainerSlotItem(containerid, slot);

				if(!IsValidItem(itemid))
				{
					DisplayContainerInventory(playerid, containerid);
					return 0;
				}

				new required = AddItemToContainer(inv_TempContainerID[playerid], itemid, playerid);

				if(required > 0)
					ShowActionText(playerid, sprintf(GetLanguageString(GetPlayerLanguage(playerid), "common/empty"), required), 3000, 150);
				else
					DisplayContainerInventory(playerid, containerid);
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	dbg("global", CORE, "[OnPlayerClickTextDraw] in /gamemodes/sss/core/char/inventory.pwn");

	if(clickedid == Text:65535)
	{
		if(IsPlayerViewingInventory(playerid))
		{
			HidePlayerGear(playerid);
			HidePlayerHealthInfo(playerid);
			ClosePlayerInventory(playerid);
			inv_EscInventory[playerid] = true;
			ClearAnimations(playerid);
			// DisplayPlayerInventory(playerid);
		}

		if(GetPlayerCurrentContainer(playerid) != INVALID_CONTAINER_ID)
		{
			HidePlayerGear(playerid);
			HidePlayerHealthInfo(playerid);
			ClosePlayerContainer(playerid);
			ClearAnimations(playerid);
			inv_EscContainer[playerid] = true;
			// DisplayContainerInventory(playerid, GetPlayerCurrentContainer(playerid));
		}
	}
}

hook OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	dbg("global", CORE, "[OnPlayerTakeDamage] in /gamemodes/sss/core/char/inventory.pwn");

	// ? Que porra e essa?
	if(IsPlayerSpawned(playerid)) 
		if(inv_HealthInfoActive[playerid]) ShowPlayerHealthInfo(playerid);
}
