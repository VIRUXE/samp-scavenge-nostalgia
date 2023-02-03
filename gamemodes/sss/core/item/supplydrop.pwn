#include <YSI\y_hooks>

hook OnPlayerUseItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_SupplyDrop)
	{
		if(CallDropWithFlareGun(playerid))
		DestroyItem(itemid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
