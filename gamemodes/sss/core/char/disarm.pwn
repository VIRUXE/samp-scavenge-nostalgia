#include <YSI\y_hooks>


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{


	if(GetPlayerWeapon(playerid) != 0 || IsValidItem(GetPlayerItem(playerid)) || GetPlayerInteractingItem(playerid) != INVALID_ITEM_ID)
		return 1;

	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED || IsPlayerOnAdminDuty(playerid) || IsPlayerKnockedOut(playerid) || GetPlayerAnimationIndex(playerid) == 1381)
		return 1;

	if(newkeys & 16)
	{
		foreach(new i : Player)
		{
			if(IsPlayerInPlayerArea(playerid, i))
			{
				if(IsPlayerKnockedOut(i) || GetPlayerAnimationIndex(i) == 1381)
				{
					DisarmPlayer(playerid, i);
					break;
				}
			}
		}
	}

	return 1;
}

DisarmPlayer(playerid, i)
{
	if(IsValidItem(GetPlayerItem(playerid)))
		return 0;
		
	if(GetPlayerInteractingItem(playerid) != INVALID_ITEM_ID)
	    return 0;
	    
	new itemid = GetPlayerItem(i);

	if(IsValidItem(itemid))
	{
		RemoveCurrentItem(i);
		GiveWorldItemToPlayer(playerid, itemid);

		return 1;
	}

	itemid = GetPlayerHolsterItem(i);

	if(IsValidItem(itemid))
	{
		RemovePlayerHolsterItem(i);
		CreateItemInWorld(itemid);
		GiveWorldItemToPlayer(playerid, itemid);

		return 1;
	}

	return 0;
}
