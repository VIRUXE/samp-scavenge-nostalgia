#include <YSI\y_hooks>


hook OnPlayerPickUpItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Workbench)
	{
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
