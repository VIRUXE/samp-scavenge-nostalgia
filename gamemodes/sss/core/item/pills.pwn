/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/


#include <YSI\y_hooks>


#define PILL_TYPE_ANTIBIOTICS	(0)
#define PILL_TYPE_PAINKILL		(1)
#define PILL_TYPE_LSD			(2)


static
	pill_CurrentlyTaking[MAX_PLAYERS];

hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "Pills"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("Pills"), 1);
}

hook OnPlayerConnect(playerid)
{
	dbg("global", CORE, "[OnPlayerConnect] in /gamemodes/sss/core/item/pills.pwn");

	pill_CurrentlyTaking[playerid] = -1;
}

hook OnItemCreate(itemid)
{
	dbg("global", CORE, "[OnItemCreate] in /gamemodes/sss/core/item/pills.pwn");

	if(GetItemLootIndex(itemid) != -1)
	{
		if(GetItemType(itemid) == item_Pills)
		{
			SetItemExtraData(itemid, random(3));
		}
	}
}

hook OnItemNameRender(itemid, ItemType:itemtype)
{
	dbg("global", CORE, "[OnItemNameRender] in /gamemodes/sss/core/item/pills.pwn");

	if(itemtype == item_Pills)
	{
		switch(GetItemExtraData(itemid))
		{
			case PILL_TYPE_ANTIBIOTICS:		SetItemNameExtra(itemid, "Antibi�ticos");
			case PILL_TYPE_PAINKILL:		SetItemNameExtra(itemid, "Analg�sico");
			case PILL_TYPE_LSD:				SetItemNameExtra(itemid, "LSD");
			default:						SetItemNameExtra(itemid, "Vazio");
		}
	}
}

hook OnPlayerUseItem(playerid, itemid)
{
	dbg("global", CORE, "[OnPlayerUseItem] in /gamemodes/sss/core/item/pills.pwn");

	if(GetItemType(itemid) == item_Pills)
	{
		StartTakingPills(playerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	dbg("global", CORE, "[OnPlayerKeyStateChange] in /gamemodes/sss/core/item/pills.pwn");

	if(oldkeys & 16 && pill_CurrentlyTaking[playerid] != -1)
	{
		StopTakingPills(playerid);
	}

	return 1;
}

StartTakingPills(playerid)
{
	pill_CurrentlyTaking[playerid] = GetPlayerItem(playerid);
	ApplyAnimation(playerid, "BAR", "dnk_stndM_loop", 3.0, 0, 1, 1, 0, 1000, 1);
	StartHoldAction(playerid, 1000);
}

StopTakingPills(playerid)
{
	ClearAnimations(playerid);
	StopHoldAction(playerid);

	pill_CurrentlyTaking[playerid] = -1;
}

hook OnHoldActionFinish(playerid)
{
	if(pill_CurrentlyTaking[playerid] != -1)
	{
		if(!IsValidItem(pill_CurrentlyTaking[playerid]))
			return Y_HOOKS_CONTINUE_RETURN_0;

		if(GetPlayerItem(playerid) != pill_CurrentlyTaking[playerid])
			return Y_HOOKS_CONTINUE_RETURN_0;

		switch(GetItemExtraData(pill_CurrentlyTaking[playerid]))
		{
			case PILL_TYPE_ANTIBIOTICS:
			{
				SetPlayerInfectionIntensity(playerid, 0, 0);

				if(random(100) < 50)
					SetPlayerInfectionIntensity(playerid, 1, 0);

				ApplyDrug(playerid, drug_Antibiotic);
			}
			case PILL_TYPE_PAINKILL:
			{
				GivePlayerHP(playerid, 10.0);
				ApplyDrug(playerid, drug_Painkill);
			}
			case PILL_TYPE_LSD:
			{
				ApplyDrug(playerid, drug_Lsd);

				new
					hour = 22,
					minute = 3,
					weather = 33;

				SetPlayerTime(playerid, hour, minute);
				SetPlayerWeather(playerid, weather);
			}
		}

		DestroyItem(pill_CurrentlyTaking[playerid]);

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDrugWearOff(playerid, drugtype)
{
	dbg("global", CORE, "[OnPlayerDrugWearOff] in /gamemodes/sss/core/item/pills.pwn");

	if(drugtype == drug_Lsd)
	{
        new
			hour,
			minute;

		gettime(hour, minute);
		
		SetPlayerTime(playerid, hour, minute);
		SetPlayerWeather(playerid, 10);
//		SetPlayerTime(playerid, dini_Int("Servidor.ini", "Hora"), 0);
	    SetPlayerWeather(playerid, dini_Int("Servidor.ini", "Clima"));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
