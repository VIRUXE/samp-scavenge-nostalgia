#include <YSI\y_hooks>

#define INJECT_TYPE_EMPTY		(0)
#define INJECT_TYPE_MORPHINE	(1)
#define INJECT_TYPE_ADRENALINE	(2)
#define INJECT_TYPE_HEROIN		(3)


static
	inj_CurrentItem[MAX_PLAYERS],
	inj_CurrentTarget[MAX_PLAYERS];

hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "AutoInjec"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("AutoInjec"), 1);
}

hook OnPlayerConnect(playerid)
{
	

	inj_CurrentItem[playerid] = -1;
	inj_CurrentTarget[playerid] = -1;
}

hook OnItemCreate(itemid)
{


	if(GetItemLootIndex(itemid) != -1)
	{
		if(GetItemType(itemid) == item_AutoInjec)
		{
			SetItemExtraData(itemid, 1 + random(3));
		}
	}
}

hook OnItemNameRender(itemid, ItemType:itemtype)
{


	if(itemtype == item_AutoInjec)
	{
		switch(GetItemExtraData(itemid))
		{
			case INJECT_TYPE_EMPTY:			SetItemNameExtra(itemid, "Vazio");
			case INJECT_TYPE_MORPHINE:		SetItemNameExtra(itemid, "Morfina");
			case INJECT_TYPE_ADRENALINE:	SetItemNameExtra(itemid, "Adrenalina");
			case INJECT_TYPE_HEROIN:		SetItemNameExtra(itemid, "Heroína");
			default:						SetItemNameExtra(itemid, "Vazio");
		}
	}
}

hook OnPlayerUseItem(playerid, itemid)
{


	if(GetItemType(itemid) == item_AutoInjec)
	{
		new targetid = playerid;

		foreach(new i : Player)
		{
			if(IsPlayerInPlayerArea(playerid, i))
			{
				targetid = i;
				break;
			}
		}

		StartInjecting(playerid, targetid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{


	if(oldkeys & 16 && inj_CurrentItem[playerid] != -1)
		StopInjecting(playerid);

	return 1;
}

StartInjecting(playerid, targetid)
{
	if(playerid == targetid)
	{
		ApplyAnimation(playerid, "PED", "IDLE_CSAW", 4.0, 0, 1, 1, 0, 500, 1);
	//	ApplyAnimation(playerid, "BAR", "dnk_stndM_loop", 3.0, 0, 1, 1, 0, 500, 1);
	}

	else
	{
		if(IsPlayerKnockedOut(targetid))
			ApplyAnimation(playerid, "KNIFE", "KNIFE_G", 2.0, 0, 0, 0, 0, 0);

		else ApplyAnimation(playerid, "ROCKET", "IDLE_ROCKET", 4.0, 0, 1, 1, 0, 500, 1);
	}

	inj_CurrentItem[playerid] = GetPlayerItem(playerid);
	inj_CurrentTarget[playerid] = targetid;

	StartHoldAction(playerid, 1000);
}

StopInjecting(playerid)
{
	ClearAnimations(playerid);
	StopHoldAction(playerid);

	inj_CurrentItem[playerid] = -1;
	inj_CurrentTarget[playerid] = -1;
}

hook OnHoldActionFinish(playerid)
{


	if(inj_CurrentItem[playerid] != -1)
	{
		if(!IsPlayerConnected(inj_CurrentTarget[playerid]))
			return Y_HOOKS_BREAK_RETURN_1;

		if(!IsValidItem(inj_CurrentItem[playerid]))
			return Y_HOOKS_BREAK_RETURN_1;

		if(GetPlayerItem(playerid) != inj_CurrentItem[playerid])
			return Y_HOOKS_BREAK_RETURN_1;

		switch(GetItemExtraData(inj_CurrentItem[playerid]))
		{
			case INJECT_TYPE_EMPTY: ApplyDrug(inj_CurrentTarget[playerid], drug_Air);
			case INJECT_TYPE_MORPHINE: ApplyDrug(inj_CurrentTarget[playerid], drug_Morphine);

			case INJECT_TYPE_ADRENALINE:
			{
				ApplyDrug(inj_CurrentTarget[playerid], drug_Adrenaline);

				if(IsPlayerKnockedOut(inj_CurrentTarget[playerid]) && inj_CurrentTarget[playerid] != playerid)
					WakeUpPlayer(inj_CurrentTarget[playerid]);
			}

			case INJECT_TYPE_HEROIN:
			{
				ApplyDrug(inj_CurrentTarget[playerid], drug_Heroin);

				new
					hour = 22,
					minute = 30,
					weather = 33;

				SetPlayerTime(playerid, hour, minute);
				SetPlayerWeather(playerid, weather);
			}
		}

		SetItemExtraData(inj_CurrentItem[playerid], INJECT_TYPE_EMPTY);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDrugWearOff(playerid, drugtype)
{


	if(drugtype == drug_Heroin)
	{
		new hour, minute;
		gettime(hour, minute);

		SetPlayerTime(playerid, hour, minute);
		SetPlayerWeather(playerid, GetSettingInt("world/weather"));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
