#include <YSI\y_hooks>


enum e_plant_pot_data
{
	E_PLANT_POT_ACTIVE,
	E_PLANT_POT_SEED_TYPE,
	E_PLANT_POT_WATER,
	E_PLANT_POT_GROWTH,
	E_PLANT_POT_OBJECT_ID
}


hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "PlantPot"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("PlantPot"), 5);
}

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{


	if(GetItemType(withitemid) == item_PlantPot)
	{

		new
			ItemType:itemtype = GetItemType(itemid),
			potdata[e_plant_pot_data];

		GetItemArrayData(withitemid, potdata);

		if(itemtype == item_SeedBag)
		{
			new amount = GetItemArrayDataAtCell(itemid, E_SEED_BAG_AMOUNT);

			if(amount > 0)
			{
				potdata[E_PLANT_POT_SEED_TYPE] = GetItemArrayDataAtCell(itemid, E_SEED_BAG_TYPE);
				potdata[E_PLANT_POT_ACTIVE] = 1;
				potdata[E_PLANT_POT_GROWTH] = 0;

				SetItemArrayDataAtCell(itemid, amount - 1, E_SEED_BAG_AMOUNT);
				SetItemArrayData(withitemid, potdata, e_plant_pot_data);
				ShowActionText(playerid, ls(playerid, "item/plantpot/seed-added"), 5000);
			}
		}

		if(GetItemTypeLiquidContainerType(itemtype) != -1)
		{
			new
				Float:amount = GetLiquidItemLiquidAmount(itemid),
				type = GetLiquidItemLiquidType(itemid);

			if(amount <= 0.0)
				ShowActionText(playerid, ls(playerid, "item/plantpot/empty"), 5000);
			else if(type != liquid_Water)
				ShowActionText(playerid, ls(playerid, "item/plantpot/bottle-not-water"), 5000);
			else {
				new Float:transfer = (amount < 0.1) ? amount : 0.1;

				SetItemArrayDataAtCell(withitemid, GetItemArrayDataAtCell(withitemid, E_PLANT_POT_WATER) + floatround(transfer * 10), E_PLANT_POT_WATER, 1);
				SetLiquidItemLiquidAmount(itemid, amount - transfer);
				ShowActionText(playerid, ls(playerid, "item/plantpot/water-added"), 5000);
			}
		}

		if(itemtype == item_Knife)
		{
			if(!potdata[E_PLANT_POT_ACTIVE])
			{
				ShowActionText(playerid, ls(playerid, "item/plantpot/no-plant"), 3000);
				return Y_HOOKS_BREAK_RETURN_1;
			}

			new seedtype = potdata[E_PLANT_POT_SEED_TYPE];

			if(!IsValidSeedType(seedtype))
			{
				ShowActionText(playerid, ls(playerid, "item/plantpot/invalid-seed"), 3000);
				return Y_HOOKS_BREAK_RETURN_1;
			}

			if(_:(potdata[E_PLANT_POT_GROWTH] < GetSeedTypeGrowthTime(seedtype)))
			{
				ShowActionText(playerid, ls(playerid, "item/plantpot/not-grown"), 3000);
				return Y_HOOKS_BREAK_RETURN_1;
			}

			new
				Float:x,
				Float:y,
				Float:z,
				world = GetItemWorld(withitemid),
				interior = GetItemInterior(withitemid);

			GetItemPos(withitemid, x, y, z);

			CreateItem(GetSeedTypeItemType(seedtype), x, y, z + 0.5, .world = world, .interior = interior);
			DestroyDynamicObject(potdata[E_PLANT_POT_OBJECT_ID]);

			potdata[E_PLANT_POT_ACTIVE] = 0;
			potdata[E_PLANT_POT_SEED_TYPE] = 0;
			potdata[E_PLANT_POT_WATER] = 0;
			potdata[E_PLANT_POT_GROWTH] = 0;
			potdata[E_PLANT_POT_OBJECT_ID] = INVALID_OBJECT_ID;

			SetItemArrayData(withitemid, potdata, e_plant_pot_data);

			ShowActionText(playerid, ls(playerid, "item/plantpot/harvested"), 3000);
		}

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_pot_Load(itemid)
{
	if(GetItemType(itemid) != item_PlantPot)
	{
		err("Attempted to _pot_Load an item that wasn't a pot (%d type %d).", itemid, _:GetItemType(itemid));
		return;
	}


	new potdata[e_plant_pot_data];

	GetItemArrayData(itemid, potdata);

	if(!potdata[E_PLANT_POT_ACTIVE])
	{
		return;
	}


	if(potdata[E_PLANT_POT_WATER] > 0)
	{
		// Sufficiently watered? Grow and drink some water.
		potdata[E_PLANT_POT_WATER] -= 1;
		potdata[E_PLANT_POT_GROWTH] += 1;
	}
	else
	{
		// No water? Degrade.
		potdata[E_PLANT_POT_GROWTH] -= 1;
	}

	// If growth is reduced to 0, Die :(
	if(potdata[E_PLANT_POT_GROWTH] <= 0)
	{

		potdata[E_PLANT_POT_ACTIVE] = 0;
		potdata[E_PLANT_POT_SEED_TYPE] = -1;
		potdata[E_PLANT_POT_WATER] = 0;
		potdata[E_PLANT_POT_GROWTH] = 0;
	}

	SetItemArrayData(itemid, potdata, e_plant_pot_data);

	_pot_UpdateModel(itemid);

	return;
}

_pot_UpdateModel(itemid, bool:toggle = true)
{

	if(!IsItemInWorld(itemid))
		toggle = false;

	if(toggle)
	{
		if(!GetItemArrayDataAtCell(itemid, E_PLANT_POT_ACTIVE))
			return 0;

		new
			Float:x,
			Float:y,
			Float:z,
			Float:rz,
			world,
			interior,
			seedtype;

		GetItemPos(itemid, x, y, z);
		GetItemRot(itemid, rz, rz, rz);
		world = GetItemWorld(itemid);
		interior = GetItemInterior(itemid);
		seedtype = GetItemArrayDataAtCell(itemid, E_PLANT_POT_SEED_TYPE);

		if(!IsValidSeedType(seedtype))
		{
			return 0;
		}

		new growth = GetItemArrayDataAtCell(itemid, E_PLANT_POT_GROWTH);

		if(0 < growth < GetSeedTypeGrowthTime(seedtype))
		{
			// max: 0.2741 min: 0.0775
			// step size: 0.1966 / max growth
			// pos: step size * current growth+1
			new id = GetItemArrayDataAtCell(itemid, E_PLANT_POT_OBJECT_ID);

			if(id != INVALID_OBJECT_ID)
			{
				DestroyDynamicObject(id);
			}

			z += (0.1966 / GetSeedTypeGrowthTime(seedtype)) * growth;

			id = CreateDynamicObject(2194, x, y, z, 0.0, 0.0, rz, world, interior, _, 50.0, 50.0);
			SetItemArrayDataAtCell(itemid, id, E_PLANT_POT_OBJECT_ID, 0, 0);
		}
		else
		{
			new id = GetItemArrayDataAtCell(itemid, E_PLANT_POT_OBJECT_ID);

			if(id != INVALID_OBJECT_ID)
			{
				DestroyDynamicObject(id);
			}

			z += GetSeedTypePlantOffset(seedtype);

			id = CreateDynamicObject(GetSeedTypePlantModel(seedtype), x, y, z, 0.0, 0.0, rz, world, interior, _, 50.0, 50.0);
			SetItemArrayDataAtCell(itemid, id, E_PLANT_POT_OBJECT_ID, 0, 0);
		}
	}
	else
	{
		DestroyDynamicObject(GetItemArrayDataAtCell(itemid, E_PLANT_POT_OBJECT_ID));
		SetItemArrayDataAtCell(itemid, INVALID_OBJECT_ID, E_PLANT_POT_OBJECT_ID, 0, 0);
	}

	return 1;
}

hook OnItemCreateInWorld(itemid)
{


	if(GetItemType(itemid) == item_PlantPot)
	{


		if(gServerInitialising)
		{

			if(GetItemLootIndex(itemid) != -1)
			{

				new potdata[e_plant_pot_data];

				potdata[E_PLANT_POT_ACTIVE] = 0;
				potdata[E_PLANT_POT_SEED_TYPE] = -1;
				potdata[E_PLANT_POT_WATER] = 0;
				potdata[E_PLANT_POT_GROWTH] = 0;
				potdata[E_PLANT_POT_OBJECT_ID] = INVALID_OBJECT_ID;

				SetItemArrayData(itemid, potdata, e_plant_pot_data);
			}
			else
			{

				_pot_Load(itemid);
			}
		}
	}
}

hook OnPlayerUseItem(playerid, itemid)
{


	if(GetItemType(itemid) == item_PlantPot && IsItemInWorld(itemid))
	{
		new
			potdata[e_plant_pot_data],
			string[256];

		GetItemArrayData(itemid, potdata);

		ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 4.0, 0, 0, 0, 1, 0);

		format(string, sizeof(string), "Active:%d\nSeed type:%d\nWater:%d\nGrowth:%d/%d\n",
			potdata[E_PLANT_POT_ACTIVE],
			potdata[E_PLANT_POT_SEED_TYPE],
			potdata[E_PLANT_POT_WATER],
			potdata[E_PLANT_POT_GROWTH],
			GetSeedTypeGrowthTime(potdata[E_PLANT_POT_SEED_TYPE]));

		Dialog_Show(playerid, PlantPotStatus, DIALOG_STYLE_MSGBOX, "Plant Pot", string, "Close", "");

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

Dialog:PlantPotStatus(playerid, response, listitem, inputtext[])
{
	ClearAnimations(playerid, 1);
}

hook OnPlayerPickUpItem(playerid, itemid)
{


	if(GetItemType(itemid) == item_PlantPot)
		_pot_UpdateModel(itemid, false);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDroppedItem(playerid, itemid)
{


	if(GetItemType(itemid) == item_PlantPot)
		_pot_UpdateModel(itemid);
}

hook OnItemDestroy(itemid)
{


	if(GetItemType(itemid) == item_PlantPot)
		_pot_UpdateModel(itemid, false);
}

ACMD:potg[4](playerid, params[])
{
	new
		itemid,
		growth;

	itemid = strval(params);
	growth = GetItemArrayDataAtCell(itemid, E_PLANT_POT_GROWTH);

	SetItemArrayDataAtCell(itemid, growth, E_PLANT_POT_GROWTH);
	_pot_Load(itemid);

	return 1;
}