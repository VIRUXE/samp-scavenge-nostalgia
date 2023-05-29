#include <YSI\y_hooks>

hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "Locator"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("Locator"), 1);
}

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{


	if(GetItemType(itemid) == item_Locator && GetItemType(withitemid) == item_MobilePhone)
	{
		SetItemExtraData(itemid, withitemid);
		SetItemExtraData(withitemid, 1);

		ChatMsg(playerid, YELLOW, "item/locator/synced");
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItem(playerid, itemid)
{


	if(GetItemType(itemid) != item_Locator)
		return Y_HOOKS_CONTINUE_RETURN_0;

	new phoneitemid = GetItemExtraData(itemid);

	if(!IsValidItem(phoneitemid) || GetItemType(phoneitemid) != item_MobilePhone)
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(GetItemExtraData(phoneitemid) != 1)
		return Y_HOOKS_CONTINUE_RETURN_0;

	new
		Float:x,
		Float:y,
		Float:z,
		Float:phone_x,
		Float:phone_y,
		Float:phone_z,
		Float:distance;

	GetPlayerPos(playerid, x, y, z);
	GetItemAbsolutePos(phoneitemid, phone_x, phone_y, phone_z);
	distance = Distance(phone_x, phone_y, phone_z, x, y, z);

	ShowActionText(playerid, sprintf(ls(playerid, "common/distance"), distance), 2000);

	// ShowActionText(playerid, ls(playerid, "item/locator/failed"), 2000);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemCreate(itemid)
{


	if(GetItemType(itemid) == item_Locator)
	{
		SetItemExtraData(itemid, INVALID_ITEM_ID);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}