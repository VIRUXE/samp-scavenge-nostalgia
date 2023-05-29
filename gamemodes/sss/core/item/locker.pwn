#include <YSI\y_hooks>

hook OnPlayerOpenContainer(playerid, containerid)
{
	new itemid = GetContainerSafeboxItem(containerid);

	if(GetItemType(itemid) == item_Locker)
	{
		Streamer_SetIntData(STREAMER_TYPE_OBJECT, GetItemObjectID(itemid), E_STREAMER_MODEL_ID, 11730);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseContainer(playerid, containerid)
{
	new itemid = GetContainerSafeboxItem(containerid);

	if(GetItemType(itemid) == item_Locker)
	{
		Streamer_SetIntData(STREAMER_TYPE_OBJECT, GetItemObjectID(itemid), E_STREAMER_MODEL_ID, 11729);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerPickUpItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Locker)
	{
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
