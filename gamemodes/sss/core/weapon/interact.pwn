


hook OnPlayerGetItem(playerid, itemid)
{


	UpdatePlayerWeaponItem(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerGivenItem(playerid, targetid, itemid)
{


	if(GetItemTypeWeapon(GetItemType(itemid)) != -1)
	{
		RemovePlayerWeapon(playerid);
		UpdatePlayerWeaponItem(targetid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDroppedItem(playerid, itemid)
{


	if(GetItemTypeWeapon(GetItemType(itemid)) != -1)
	{
		RemovePlayerWeapon(playerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{


	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED || IsPlayerOnAdminDuty(playerid) || IsPlayerKnockedOut(playerid) || GetPlayerAnimationIndex(playerid) == 1381)
		return 1;

	_PickUpAmmoTransferCheck(playerid, itemid, withitemid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_PickUpAmmoTransferCheck(playerid, helditemid, ammoitemid)
{
	new
		ItemType:helditemtype,
		ItemType:ammoitemtype,
		heldtypeid;

	// Item being held and used with world item
	helditemtype = GetItemType(helditemid);
	// Item in the world
	ammoitemtype = GetItemType(ammoitemid);
	// Weapon type of held item
	heldtypeid = GetItemTypeWeapon(helditemtype);

	if(heldtypeid != -1) // Player is holding a weapon
	{
		new ammotypeid = GetItemTypeWeapon(ammoitemtype);

		if(ammotypeid != -1) // Transfer ammo from weapon to held weapon
		{
			new heldcalibre = GetItemWeaponCalibre(heldtypeid);

			if(heldcalibre == NO_CALIBRE)
				return 1;

			if(GetItemWeaponFlags(heldtypeid) & WEAPON_FLAG_LIQUID_AMMO)
				return 1;

			if(heldcalibre != GetItemWeaponCalibre(ammotypeid))
			{
				ShowActionText(playerid, ls(playerid, "item/weapon/wrong-calibre"), 3000);
				return 1;
			}

			new ItemType:loadedammoitemtype = GetItemWeaponItemAmmoItem(helditemid);

			if(GetItemTypeAmmoType(loadedammoitemtype) != -1)
			{
				if(loadedammoitemtype != GetItemWeaponItemAmmoItem(ammoitemid))
				{
					ShowActionText(playerid, ls(playerid, "item/weapon/diff-ammo"), 5000);
					return 1;
				}
			}

			ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 5.0, 1, 0, 0, 0, 450);
			_TransferWeaponToWeapon(playerid, ammoitemid, helditemid);

			return 1;
		}

		ammotypeid = GetItemTypeAmmoType(ammoitemtype);

		if(ammotypeid != -1) // Transfer ammo from ammo item to held weapon
		{
			new heldcalibre = GetItemWeaponCalibre(heldtypeid);

			if(heldcalibre == NO_CALIBRE)
				return 1;

			if(GetItemWeaponFlags(heldtypeid) & WEAPON_FLAG_LIQUID_AMMO)
			{
				// heldcalibre represents a liquidtype

				if(GetItemTypeLiquidContainerType(GetItemType(ammoitemid)) == -1)
					return 1;

				new
					Float:canfuel,
					Float:transfer;

				canfuel = GetLiquidItemLiquidAmount(ammoitemid);

				if(canfuel <= 0.0)
				{
					ShowActionText(playerid, ls(playerid, "common/empty"), 3000);
					return 1;
				}

				transfer = (canfuel - 1.0 < 0.0) ? canfuel : 1.0;
				SetLiquidItemLiquidAmount(ammoitemid, canfuel - transfer);
				SetItemWeaponItemMagAmmo(helditemid, GetItemWeaponItemMagAmmo(helditemid) + floatround(transfer) * 100);
				SetItemWeaponItemAmmoItem(helditemid, item_GasCan);
				UpdatePlayerWeaponItem(playerid);
				// todo: remove dependency on itemtypes for liquid based weaps

				return 1;
			}

			if(heldcalibre != GetAmmoTypeCalibre(ammotypeid))
			{
				ShowActionText(playerid, ls(playerid, "item/weapon/wrong-calibre"), 3000);
				return 1;
			}

			new ItemType:loadedammoitemtype = GetItemWeaponItemAmmoItem(helditemid);

			if(GetItemTypeAmmoType(loadedammoitemtype) != -1)
			{
				if(loadedammoitemtype != ammoitemtype)
				{
					ShowActionText(playerid, ls(playerid, "item/weapon/diff-ammo"), 5000);
					return 1;
				}
			}

			ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 5.0, 1, 0, 0, 0, 450);
			_TransferTinToWeapon(playerid, ammoitemid, helditemid);

			return 1;
		}
	}

	heldtypeid = GetItemTypeAmmoType(helditemtype);

	if(heldtypeid != -1) // Player is holding an ammo item
	{
		new ammotypeid = GetItemTypeWeapon(ammoitemtype);

		if(ammotypeid != -1) // Transfer ammo from weapon to held ammo item
		{
			new heldcalibre = GetAmmoTypeCalibre(heldtypeid);

			if(heldcalibre == NO_CALIBRE)
				return 1;

			if(GetItemWeaponFlags(ammotypeid) & WEAPON_FLAG_LIQUID_AMMO)
				return 1;

			if(heldcalibre != GetItemWeaponCalibre(ammotypeid))
			{
				ShowActionText(playerid, ls(playerid, "item/weapon/wrong-calibre"), 3000);
				return 1;
			}

			new ItemType:loadedammoitemtype = GetItemWeaponItemAmmoItem(ammoitemid);

			if(GetItemTypeAmmoType(loadedammoitemtype) != -1)
			{
				if(loadedammoitemtype != helditemtype)
				{
					ShowActionText(playerid, ls(playerid, "item/weapon/diff-ammo"), 5000);
					return 1;
				}
			}

			ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 5.0, 1, 0, 0, 0, 450);
			_TransferWeaponToTin(playerid, ammoitemid, helditemid);

			return 1;
		}

		ammotypeid = GetItemTypeAmmoType(ammoitemtype);

		if(ammotypeid != -1) // Transfer ammo from ammo item to held ammo item
		{
			if(GetItemExtraData(helditemid) == 0)
			{
				new heldcalibre = GetAmmoTypeCalibre(heldtypeid);

				if(heldcalibre == NO_CALIBRE)
					return 1;

				if(heldcalibre != GetAmmoTypeCalibre(ammotypeid))
				{
					ShowActionText(playerid, "Calibre errado em caixa de munição", 3000);
					return 1;
				}
			}

			if(ammoitemtype != helditemtype)
			{
				ShowActionText(playerid, ls(playerid, "item/weapon/ammo-mismatch"), 5000);
				return 1;
			}

			ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 5.0, 1, 0, 0, 0, 450);
			_TransferTinToTin(playerid, ammoitemid, helditemid);

			return 1;
		}
	}

	return 1;
}


// Transfer ammo from weapon to held weapon
_TransferWeaponToWeapon(playerid, srcitem, tgtitem)
{
	new
		magammo,
		reserveammo,
		remainder;

	magammo = GetItemWeaponItemMagAmmo(srcitem);
	reserveammo = GetItemWeaponItemReserve(srcitem);

	if(reserveammo + magammo > 0)
	{
		SetItemWeaponItemAmmoItem(tgtitem, GetItemWeaponItemAmmoItem(srcitem));
		remainder = GivePlayerAmmo(playerid, reserveammo + magammo);

		SetItemWeaponItemMagAmmo(srcitem, 0);
		SetItemWeaponItemReserve(srcitem, remainder);

		ShowActionText(playerid, sprintf(ls(playerid, "item/weapon/transfer/weapon-weapon"), (reserveammo + magammo) - remainder), 3000);
	}

	ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_2IDLE", 4.0, 0, 0, 0, 0, 0);
}

// Transfer ammo from ammo item to held weapon
// Damn y_timers and it's length restrictions!
_TransferTinToWeapon(playerid, srcitem, tgtitem)
{
	new
		ammo,
		remainder;

	ammo = GetItemExtraData(srcitem);

	if(ammo > 0)
	{
		SetItemWeaponItemAmmoItem(tgtitem, GetItemType(srcitem));
		remainder = GivePlayerAmmo(playerid, ammo);

		SetItemExtraData(srcitem, remainder);

		ShowActionText(playerid, sprintf(ls(playerid, "item/weapon/transfer/tin-weapon"), ammo - remainder), 3000);
	}

	ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_2IDLE", 4.0, 0, 0, 0, 0, 0);
}

// Transfer ammo from weapon to held ammo item
_TransferWeaponToTin(playerid, srcitem, tgtitem)
{
	new
		existing = GetItemExtraData(tgtitem),
		amount = GetItemWeaponItemMagAmmo(srcitem) + GetItemWeaponItemReserve(srcitem);

	SetItemExtraData(tgtitem, existing + amount);
	SetItemWeaponItemMagAmmo(srcitem, 0);
	SetItemWeaponItemReserve(srcitem, 0);

	ShowActionText(playerid, sprintf(ls(playerid, "item/weapon/transfer/weapon-tin"), amount), 3000);

	ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_2IDLE", 4.0, 0, 0, 0, 0, 0);
}

// Transfer ammo from ammo item to held ammo item
_TransferTinToTin(playerid, srcitem, tgtitem)
{
	new
		existing = GetItemExtraData(tgtitem),
		amount = GetItemExtraData(srcitem);

	SetItemExtraData(tgtitem, existing + amount);
	SetItemExtraData(srcitem, 0);

	ShowActionText(playerid, sprintf(ls(playerid, "item/weapon/transfer/tin-tin"), amount), 3000);

	ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_2IDLE", 4.0, 0, 0, 0, 0, 0);
}


/*==============================================================================

	Transfer ammo in inventories

==============================================================================*/
/*
static
	trans_ContainerOptionID[MAX_PLAYERS] = {-1, ...},
	trans_ContainerID[MAX_PLAYERS] = {INVALID_CONTAINER_ID, ...},
	trans_SelectedItem[MAX_PLAYERS] = {INVALID_ITEM_ID, ...};

hook OnPlayerConnect(playerid)
{
    trans_ContainerOptionID[playerid] = -1;
    trans_ContainerID[playerid] = INVALID_CONTAINER_ID;
    trans_SelectedItem[playerid] = INVALID_ITEM_ID;
}

hook OnPlayerViewCntOpt(playerid, containerid)
{
	new
		itemid,
		ItemType:itemtype;

	itemid = GetContainerSlotItem(containerid, GetPlayerContainerSlot(playerid));
	itemtype = GetItemType(itemid);

	if((GetItemTypeWeapon(itemtype) != -1 && GetItemTypeWeaponCalibre(itemtype) != -1) || GetItemTypeAmmoType(itemtype) != -1)
	{
		if(IsValidItem(trans_SelectedItem[playerid]) && trans_SelectedItem[playerid] != itemid)
		{
			trans_ContainerOptionID[playerid] = AddContainerOption(playerid, "Transferir munição aqui");
		}
		else
		{
			trans_ContainerOptionID[playerid] = AddContainerOption(playerid, "Transferir munição...");
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerSelectCntOpt(playerid, containerid, option)
{
	if(option == trans_ContainerOptionID[playerid])
	{
		if(IsValidItem(trans_SelectedItem[playerid]) && trans_SelectedItem[playerid] != GetContainerSlotItem(containerid, GetPlayerContainerSlot(playerid)))
		{
			DisplayTransferAmmoDialog(playerid, containerid);
		}
		else
		{
			trans_SelectedItem[playerid] = GetContainerSlotItem(containerid, GetPlayerContainerSlot(playerid));
			DisplayContainerInventory(playerid, containerid);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

DisplayTransferAmmoDialog(playerid, containerid, msg[] = "")
{
	new
		sourceitemid,
		ItemType:sourceitemtype,
		sourceitemname[ITM_MAX_NAME],
		targetitemid,
		ItemType:targetitemtype,
		targetitemname[ITM_MAX_NAME];

	sourceitemid = trans_SelectedItem[playerid];
	sourceitemtype = GetItemType(sourceitemid);
	GetItemTypeName(sourceitemtype, sourceitemname);
	targetitemid = GetContainerSlotItem(containerid, GetPlayerContainerSlot(playerid));
	targetitemtype = GetItemType(targetitemid);
	GetItemTypeName(targetitemtype, targetitemname);

    trans_ContainerID[playerid] = containerid;
	Dialog_Show(playerid, AmmoTransfer, DIALOG_STYLE_INPUT, "Transferir munição", sprintf("Insira a quantidade de munição para transferir de %s para %s\n\n%s", sourceitemname, targetitemname, msg), "Pronto", "Cancelar");
}

Dialog:AmmoTransfer(playerid, response, listitem, inputtext[])
{
	new
		sourceitemid,
		ItemType:sourceitemtype,
		sourceitemname[ITM_MAX_NAME],
		targetitemid,
		ItemType:targetitemtype,
		targetitemname[ITM_MAX_NAME];

	sourceitemid = trans_SelectedItem[playerid];
	sourceitemtype = GetItemType(sourceitemid);
	GetItemTypeName(sourceitemtype, sourceitemname);
	targetitemid = GetContainerSlotItem(trans_ContainerID[playerid], GetPlayerContainerSlot(playerid));
	targetitemtype = GetItemType(targetitemid);
	GetItemTypeName(targetitemtype, targetitemname);
	
	if(response)
	{
		new amount = strval(inputtext);

		if(GetItemTypeWeapon(sourceitemtype) != -1)
		{
			if(GetItemTypeWeapon(targetitemtype) != -1)
			{
				// weapon to weapon
				new
					sourceitemammo = GetItemWeaponItemReserve(sourceitemid),
					targetitemammo = GetItemWeaponItemReserve(targetitemid);

				if(0 < amount <= sourceitemammo)
				{
					SetItemWeaponItemReserve(sourceitemid, sourceitemammo - amount);
					SetItemWeaponItemReserve(targetitemid, targetitemammo + amount);
					SetItemWeaponItemAmmoItem(targetitemid, sourceitemtype);
				}
				else
				{
					DisplayTransferAmmoDialog(playerid, trans_ContainerID[playerid], sprintf("%s cont�m apenas %d munições", sourceitemname, sourceitemammo));
				}

			}
			else if(GetItemTypeAmmoType(targetitemtype) != -1)
			{
				// weapon to ammo
				new
					sourceitemammo = GetItemWeaponItemReserve(sourceitemid),
					targetitemammo = GetItemArrayDataAtCell(targetitemid, 0);

				if(0 < amount <= sourceitemammo)
				{
					SetItemWeaponItemReserve(sourceitemid, sourceitemammo - amount);
					SetItemArrayDataAtCell(targetitemid, targetitemammo + amount, 0);
				}
				else
				{
					DisplayTransferAmmoDialog(playerid, trans_ContainerID[playerid], sprintf("%s cont�m apenas %d munições", sourceitemname, sourceitemammo));
				}
			}
		}
		else if(GetItemTypeAmmoType(sourceitemtype) != -1)
		{
			if(GetItemTypeWeapon(targetitemtype) != -1)
			{
				// ammo to weapon
				new
					sourceitemammo = GetItemArrayDataAtCell(sourceitemid, 0),
					targetitemammo = GetItemWeaponItemReserve(targetitemid);

				if(0 < amount <= sourceitemammo)
				{
					SetItemArrayDataAtCell(sourceitemid, sourceitemammo - amount, 0);
					SetItemWeaponItemReserve(targetitemid, targetitemammo + amount);
					SetItemWeaponItemAmmoItem(targetitemid, sourceitemtype);
				}
				else
				{
					DisplayTransferAmmoDialog(playerid, trans_ContainerID[playerid], sprintf("%s cont�m apenas %d munições", sourceitemname, sourceitemammo));
				}
			}
			else if(GetItemTypeAmmoType(targetitemtype) != -1)
			{
				// ammo to ammo
				new
					sourceitemammo = GetItemArrayDataAtCell(sourceitemid, 0),
					targetitemammo = GetItemArrayDataAtCell(targetitemid, 0);

				if(0 < amount <= sourceitemammo)
				{
					SetItemArrayDataAtCell(sourceitemid, sourceitemammo - amount, 0);
					SetItemArrayDataAtCell(targetitemid, targetitemammo + amount, 0);
				}
				else
				{
					DisplayTransferAmmoDialog(playerid, trans_ContainerID[playerid], sprintf("%s cont�m apenas %d munições", sourceitemname, sourceitemammo));
				}
			}
		}
	}

	trans_ContainerOptionID[playerid] = -1;
	trans_SelectedItem[playerid] = INVALID_ITEM_ID;
	DisplayContainerInventory(playerid, trans_ContainerID[playerid]);
}
*/