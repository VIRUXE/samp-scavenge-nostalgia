#include <YSI\y_hooks>


static
	arm_PlayerArmourItem[MAX_PLAYERS];


hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "Armour"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("Armour"), 1);
}

hook OnItemCreate(itemid)
{


	if(GetItemLootIndex(itemid) != -1)
	{
		if(GetItemType(itemid) == item_Armour)
			SetItemExtraData(itemid, 25 + random(75));
	}
}


hook OnPlayerUseItem(playerid, itemid)
{


	if(GetItemType(itemid) == item_Armour)
	{
		if(GetPlayerAP(playerid) <= 0.0)
		{
			new data = GetItemExtraData(itemid);
			if(data > 0)
			{
				SetPlayerArmourItem(playerid, itemid);
				SetPlayerAP(playerid, float(data));
				return Y_HOOKS_BREAK_RETURN_1;
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemNameRender(itemid, ItemType:itemtype)
{


	if(itemtype == item_Armour)
	{
		new
			amount = GetItemExtraData(itemid),
			str[11];

		format(str, sizeof(str), "%d", amount);
		ConvertEncoding(str);

		SetItemNameExtra(itemid, str);
	}
}


hook OnPlayerShootPlayer(playerid, targetid, bodypart, Float:bleedrate, Float:knockmult, Float:bulletvelocity, Float:distance)
{


	if(bodypart == 3)
	{
		new Float:ap = GetPlayerAP(targetid);

		if(ap > 0.0)
		{
			new Float:penetration = GetAmmoTypePenetration(GetItemTypeAmmoType(GetItemWeaponItemAmmoItem(GetPlayerItem(playerid))));

			bleedrate *= penetration;
			ap -= ((ap + 10) * (bleedrate * 10.0));

			SetPlayerAP(targetid, ap);
			SetItemExtraData(arm_PlayerArmourItem[playerid], floatround(ap));

			if(ap <= 0.0)
				DestroyItem(RemovePlayerArmourItem(playerid));

			DMG_FIREARM_SetBleedRate(targetid, bleedrate);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

stock CreatePlayerArmour(playerid)
{
	return SetPlayerArmourItem(playerid, CreateItem(item_Armour));
}

stock SetPlayerArmourItem(playerid, itemid)
{
	if(!IsValidItem(itemid))
		return 0;

	SetPlayerAttachedObject(playerid, ATTACHSLOT_ARMOUR, 19515, 1,
		0.072999, 0.036000, 0.002999,  0.000000, 0.000000, 4.400002,  1.043000, 1.190000, 1.139000);

	RemoveItemFromWorld(itemid);
	RemoveCurrentItem(GetItemHolder(itemid));
	arm_PlayerArmourItem[playerid] = itemid;

	return 1;
}

stock RemovePlayerArmourItem(playerid)
{
	new itemid = arm_PlayerArmourItem[playerid];

	RemovePlayerAttachedObject(playerid, ATTACHSLOT_ARMOUR);
	arm_PlayerArmourItem[playerid] = INVALID_ITEM_ID;

	return itemid;
}

stock GetPlayerArmourItem(playerid)
{
	if(!IsPlayerConnected(playerid))
		return INVALID_ITEM_ID;

	return arm_PlayerArmourItem[playerid];
}
