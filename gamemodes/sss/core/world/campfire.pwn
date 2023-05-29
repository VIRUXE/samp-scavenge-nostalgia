#include <YSI\y_hooks>


enum e_CAMPFIRE_DATA
{
			cmp_objSmoke,
			cmp_foodItem,
Timer:		cmp_LifeTimer,
Timer:		cmp_CookTimer
}


static
			cmp_ItemBeingCooked[ITM_MAX] = {INVALID_ITEM_ID, ...};


hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "Campfire"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("Campfire"), _:e_CAMPFIRE_DATA);
}

hook OnItemCreateInWorld(itemid)
{


	if(GetItemType(itemid) == item_Campfire)
	{
		new
			Float:x,
			Float:y,
			Float:z,
			data[e_CAMPFIRE_DATA];

		GetItemPos(itemid, x, y, z);

		data[cmp_objSmoke] = INVALID_OBJECT_ID;
		data[cmp_foodItem] = INVALID_ITEM_ID;

		SetItemArrayData(itemid, data, _:e_CAMPFIRE_DATA);


		data[cmp_LifeTimer] = defer cmp_BurnOut(itemid, 600000);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemDestroy(itemid)
{
	if(GetItemType(itemid) == item_Campfire)
	{
		new fooditem = GetItemArrayDataAtCell(itemid, cmp_foodItem);

		if(IsValidItem(fooditem))
			cmp_ItemBeingCooked[fooditem] = INVALID_ITEM_ID;
	}
}

hook OnPlayerPickUpItem(playerid, itemid)
{


	if(GetItemType(itemid) == item_Campfire)
		return Y_HOOKS_BREAK_RETURN_1;

	if(cmp_ItemBeingCooked[itemid] != INVALID_ITEM_ID)
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{


	if(GetItemType(withitemid) == item_Campfire)
	{
		if(IsItemTypeFood(GetItemType(itemid)))
		{
			if(GetItemArrayDataAtCell(withitemid, cmp_foodItem) == INVALID_ITEM_ID)
			{
				cmp_CookItem(withitemid, itemid);
				ShowActionText(playerid, ls(playerid, "item/campfire/cooking"), 3000);
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

cmp_CookItem(itemid, fooditem)
{
	new
		Float:x,
		Float:y,
		Float:z,
		data[e_CAMPFIRE_DATA];

	GetItemPos(itemid, x, y, z);

	CreateItemInWorld(fooditem, x, y, z + 0.3, .rz = frandom(360.0));

	cmp_ItemBeingCooked[fooditem] = itemid;
	data[cmp_foodItem] = fooditem;
	data[cmp_CookTimer] = defer cmp_FinishCooking(itemid);
	SetItemArrayData(itemid, data, e_CAMPFIRE_DATA);
}

timer cmp_BurnOut[time](itemid, time)
{
	#pragma unused time
	new
		Float:x,
		Float:y,
		Float:z;

	GetItemPos(itemid, x, y, z);
	DestroyItem(itemid);

	CreateItem(item_BurntLog, x - 0.25 + frandom(0.5), y - 0.25 + frandom(0.5), z, .rz = random(360));
	CreateItem(item_BurntLog, x - 0.25 + frandom(0.5), y - 0.25 + frandom(0.5), z, .rz = random(360));
	CreateItem(item_BurntLog, x - 0.25 + frandom(0.5), y - 0.25 + frandom(0.5), z, .rz = random(360));
}

timer cmp_FinishCooking[MIN(1)](itemid)
{
	new
		Float:x,
		Float:y,
		Float:z,
		fooditem = GetItemArrayDataAtCell(itemid, cmp_foodItem);

	if(!IsValidItem(fooditem))
		return;

	GetItemPos(itemid, x, y, z);

	CreateTimedDynamicObject(18726, x, y, z - 1.0, 0.0, 0.0, 0.0, 2000);
	SetFoodItemCooked(fooditem, 1);
	cmp_ItemBeingCooked[fooditem] = INVALID_ITEM_ID;

	return;
}