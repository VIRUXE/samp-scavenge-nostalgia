#include <YSI\y_hooks>

hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "StunGun"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("StunGun"), 1);
}

hook OnPlayerMeleePlayer(playerid, targetid, Float:bleedrate, Float:knockmult)
{


	new itemid = GetPlayerItem(playerid);

	if(GetItemType(itemid) == item_StunGun)
	{
		if(GetItemExtraData(itemid) == 1)
		{
			new
				Float:x,
				Float:y,
				Float:z;

			GetPlayerPos(targetid, x, y, z);

			KnockOutPlayer(targetid, 60000);
			SetItemExtraData(itemid, 0);
			CreateTimedDynamicObject(18724, x, y, z-1.0, 0.0, 0.0, 0.0, 1000);

			return Y_HOOKS_BREAK_RETURN_1;
		}
		else
		{
			ShowActionText(playerid, ls(playerid, "item/stungun/discharged"), 3000);
			return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{


	if(GetItemType(itemid) == item_StunGun && GetItemType(withitemid) == item_Battery)
	{
		SetItemExtraData(itemid, 1);
		DestroyItem(withitemid);
		ShowActionText(playerid, ls(playerid, "item/stungun/charged"), 3000);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemNameRender(itemid, ItemType:itemtype)
{


	if(itemtype == item_StunGun)
	{
		if(GetItemExtraData(itemid) == 1)
			SetItemNameExtra(itemid, "Carregada");

		else
			SetItemNameExtra(itemid, "Nao carregada");
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}