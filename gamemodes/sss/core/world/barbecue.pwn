#include <YSI\y_hooks>

#define MAX_BBQ				(256)

#define COOKER_STATE_NONE	(0)
#define COOKER_STATE_COOK	(1)


// Struct for item data
enum //E_BBQ_DATA
{
			bbq_state,
			bbq_fuel,
			bbq_grillItem1,
			bbq_grillItem2, 
			bbq_grillPart1,
			bbq_grillPart2,
Timer:		bbq_cookTimer
}


static
			bbq_PlaceFoodTick[MAX_PLAYERS],
			bbq_ItemBBQ[ITM_MAX] = {-1, ...};


hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "Barbecue"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("Barbecue"), 7);
}

hook OnItemCreate(itemid)
{


	if(GetItemType(itemid) == item_Barbecue)
	{


		new data[7];

		if(GetItemLootIndex(itemid) != -1)
		{
			data[bbq_fuel] = random(10);
		}

		data[bbq_state] = COOKER_STATE_NONE;
		data[bbq_grillItem1] = INVALID_ITEM_ID;
		data[bbq_grillItem2] = INVALID_ITEM_ID;
		data[bbq_grillPart1] = INVALID_ITEM_ID;
		data[bbq_grillPart2] = INVALID_ITEM_ID;
		data[bbq_cookTimer] = Timer:0;









		SetItemArrayData(itemid, data, 7);
	}
}

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{




	if(GetItemType(withitemid) == item_Barbecue)
	{
		if(_UseBbqHandler(playerid, itemid, withitemid))
			return 1;
	}



	return Y_HOOKS_CONTINUE_RETURN_0;
}

_UseBbqHandler(playerid, itemid, withitemid)
{


	new data[7];

	GetItemArrayData(withitemid, data);









	new ItemType:itemtype = GetItemType(itemid);

	if(GetItemTypeLiquidContainerType(itemtype) != -1)
	{


		if(GetLiquidItemLiquidType(itemid) != liquid_Petrol)
		{
			ShowActionText(playerid, ls(playerid, "item/molotov/petrolcan-no-fuel"), 3000);
			return 1;
		}

		new 
			Float:canfuel = GetLiquidItemLiquidAmount(itemid),
			Float:transfer;

		if(canfuel > 0.0)
		{
			transfer = (canfuel - 0.6 < 0.0) ? canfuel : 0.6;
			SetLiquidItemLiquidAmount(itemid, canfuel - transfer);
			SetItemArrayDataAtCell(withitemid, data[bbq_fuel] + 10, bbq_fuel);
			ShowActionText(playerid, ls(playerid, "item/bbq/added-petrol"), 3000);
		}
		else
		{
			ShowActionText(playerid, ls(playerid, "item/jerrycan-empty"), 3000);
		}

		return 1;
	}

	if(IsItemTypeFood(itemtype))
	{


		if(GetItemExtraData(itemid) != 0)
		{
			ShowActionText(playerid, ls(playerid, "item/bbq/food-cooked"), 3000);
			return 1;
		}

		new
			Float:x,
			Float:y,
			Float:z,
			Float:r;

		GetItemPos(withitemid, x, y, z);
		GetItemRot(withitemid, r, r, r);

		if(data[bbq_grillItem1] <= 0)// == INVALID_ITEM_ID) temp fix
		{


			CreateItemInWorld(itemid,
				x + (0.25 * floatsin(-r + 90.0, degrees)),
				y + (0.25 * floatcos(-r + 90.0, degrees)),
				z + 0.818,
				.rz = r);

			bbq_ItemBBQ[itemid] = withitemid;
			SetItemArrayDataAtCell(withitemid, itemid, bbq_grillItem1);
			bbq_PlaceFoodTick[playerid] = GetTickCount();
			ShowActionText(playerid, ls(playerid, "item/bbq/food-added"), 3000);

			return 1;
		}
		else if(data[bbq_grillItem2] <= 0)// == INVALID_ITEM_ID) temp fix
		{


			CreateItemInWorld(itemid,
				x + (0.25 * floatsin(-r - 90.0, degrees)),
				y + (0.25 * floatcos(-r - 90.0, degrees)),
				z + 0.818,
				.rz = r);

			bbq_ItemBBQ[itemid] = withitemid;
			SetItemArrayDataAtCell(withitemid, itemid, bbq_grillItem2);
			bbq_PlaceFoodTick[playerid] = GetTickCount();
			ShowActionText(playerid, ls(playerid, "item/bbq/food-added"), 3000);

			return 1;
		}
	}

	if(itemtype == item_FireLighter)
	{


		if(data[bbq_fuel] <= 0)
		{

			ShowActionText(playerid, ls(playerid, "item/bbq/needs-petrol"), 3000);
			return 1;
		}

		new Timer:timerid = defer bbq_FinishCooking(withitemid);

		SetItemArrayDataAtCell(withitemid, _:timerid, bbq_cookTimer);
		SetItemArrayDataAtCell(withitemid, COOKER_STATE_COOK, bbq_state);

		_LightBBQ(withitemid);

		ShowActionText(playerid, ls(playerid, "item/bbq/cooking"), 3000);

		return 1;
	}

	return 0;
}

_LightBBQ(itemid)
{


	new
		Float:x,
		Float:y,
		Float:z,
		Float:r;

	GetItemPos(itemid, x, y, z);
	GetItemRot(itemid, r, r, r);

	SetItemArrayDataAtCell(itemid, CreateDynamicObject(18701,
		x + (0.25 * floatsin(-r + 90.0, degrees)),
		y + (0.25 * floatcos(-r + 90.0, degrees)),
		z - 0.6,
		0.0, 0.0, r), bbq_grillPart1);

	SetItemArrayDataAtCell(itemid, CreateDynamicObject(18701,
		x + (0.25 * floatsin(-r + 270.0, degrees)),
		y + (0.25 * floatcos(-r + 270.0, degrees)),
		z - 0.6,
		0.0, 0.0, r), bbq_grillPart2);

	return 1;
}

timer bbq_FinishCooking[SEC(30)](itemid)
{


	new data[7];

	GetItemArrayData(itemid, data);

	DestroyDynamicObject(data[bbq_grillPart1]);
	DestroyDynamicObject(data[bbq_grillPart2]);

	SetItemExtraData(data[bbq_grillItem1], 1);
	SetItemExtraData(data[bbq_grillItem2], 1);

	SetItemArrayDataAtCell(itemid, data[bbq_fuel] - 1, bbq_fuel);
	SetItemArrayDataAtCell(itemid, COOKER_STATE_NONE, bbq_state);
}


hook OnPlayerPickUpItem(playerid, itemid)
{



	if(GetItemType(itemid) == item_Barbecue)
	{

		if(GetTickCountDifference(GetTickCount(), bbq_PlaceFoodTick[playerid]) < 1000)
			return Y_HOOKS_BREAK_RETURN_1;

		new data[7];

		GetItemArrayData(itemid, data);









		if(data[bbq_state] != COOKER_STATE_NONE)
			return Y_HOOKS_BREAK_RETURN_1;

		if(IsValidItem(data[bbq_grillItem1]) && data[bbq_grillItem1] > 0) // temp fix
		{
			GiveWorldItemToPlayer(playerid, data[bbq_grillItem1], 1);
			SetItemArrayDataAtCell(itemid, INVALID_ITEM_ID, bbq_grillItem1);
			return Y_HOOKS_BREAK_RETURN_1;
		}

		if(IsValidItem(data[bbq_grillItem2]) && data[bbq_grillItem2] > 0) // temp fix
		{
			GiveWorldItemToPlayer(playerid, data[bbq_grillItem2], 1);
			SetItemArrayDataAtCell(itemid, INVALID_ITEM_ID, bbq_grillItem2);
			return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	if(bbq_ItemBBQ[itemid] != -1)
	{


		if(GetItemArrayDataAtCell(bbq_ItemBBQ[itemid], bbq_grillItem1) == itemid)
		{

			SetItemArrayDataAtCell(bbq_ItemBBQ[itemid], INVALID_ITEM_ID, bbq_grillItem1);
		}

		else if(GetItemArrayDataAtCell(bbq_ItemBBQ[itemid], bbq_grillItem2) == itemid)
		{

			SetItemArrayDataAtCell(bbq_ItemBBQ[itemid], INVALID_ITEM_ID, bbq_grillItem2);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}