

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{


	if(GetItemType(withitemid) == item_MolotovEmpty)
	{
		new 
			ItemType:itemtype = GetItemType(itemid);

		if(GetItemTypeLiquidContainerType(itemtype) == -1)
			return Y_HOOKS_BREAK_RETURN_1;
			
		if(GetLiquidItemLiquidType(itemid) != liquid_Petrol)
		{
			ShowActionText(playerid, ls(playerid, "item/molotov/petrolcan-no-fuel"), 3000);
			return Y_HOOKS_BREAK_RETURN_1;
		}

		new 
			Float:canfuel = GetLiquidItemLiquidAmount(itemid);

		if(canfuel <= 0.0)
		{
			ShowActionText(playerid, ls(playerid, "item/jerrycan-empty"), 3000);
			return Y_HOOKS_BREAK_RETURN_1;
		}

		new
			Float:x,
			Float:y,
			Float:z,
			Float:rz,
			Float:transfer;

		GetItemPos(withitemid, x, y, z);
		GetItemRot(withitemid, rz, rz, rz);

		DestroyItem(withitemid);
		CreateItem(ItemType:18, x, y, z, .rz = rz);

		ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 4.0, 0, 0, 0, 0, 0);
		ShowActionText(playerid, ls(playerid, "item/molotov/fueled"), 3000);
		
		transfer = (canfuel - 0.5 < 0.0) ? canfuel : 0.5;
		SetLiquidItemLiquidAmount(itemid, canfuel - transfer);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}