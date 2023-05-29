#include <YSI\y_hooks>

hook OnPlayerUseItem(playerid, itemid)
{


	if(GetItemType(itemid) == item_Sign)
	{
		new
			tmpsign,
			Float:x,
			Float:y,
			Float:z,
			Float:a;

		GetPlayerPos(playerid, x, y, z);
		GetPlayerFacingAngle(playerid, a);

		DestroyItem(itemid);
		tmpsign = CreateSign("Placa", x + floatsin(-a, degrees), y + floatcos(-a, degrees), z - 1.0, a - 90.0);
		EditSign(playerid, tmpsign);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
