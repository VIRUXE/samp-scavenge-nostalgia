

Hook_SetPlayerSkin(playerid, skinid, retry_on_fail = true)
{
	new specialaction = GetPlayerSpecialAction(playerid);

	if(specialaction == SPECIAL_ACTION_ENTER_VEHICLE || specialaction == SPECIAL_ACTION_EXIT_VEHICLE)
	{
		if(retry_on_fail)
			return _: defer Retry_SetPlayerSkin(playerid, skinid);
	}

	return SetPlayerSkin(playerid, skinid);
}
#define SetPlayerSkin Hook_SetPlayerSkin

timer Retry_SetPlayerSkin[100](playerid, skinid)
{
	Hook_SetPlayerSkin(playerid, skinid);
}
