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


#define MAX_WEPCACHE_LOCATIONS			(256)
#define WEPCACHE_INTERVAL				(1500000 + random(600000)) // 25 minutes + random 10 minutes
#define WEPCACHE_SIGNAL_INTERVAL		(200000)
#define ICON_WC							56


enum E_WEPCACHE_LOCATION_DATA
{
Float:	wepc_posX,
Float:	wepc_posY,
Float:	wepc_posZ
}

static
Float:		wepc_DropLocationData[MAX_WEPCACHE_LOCATIONS][E_WEPCACHE_LOCATION_DATA],
   Iterator:wepc_Index<MAX_WEPCACHE_LOCATIONS>,
Float:		wepc_CurrentPosX,
Float:		wepc_CurrentPosY,
Float:		wepc_CurrentPosZ,
			webc_ActiveDrop = -1;

new WCDropped = 0;

hook OnGameModeInit()
{
	defer WeaponsCacheTimer();
	return 1;
}

DefineWeaponsCachePos(Float:x, Float:y, Float:z)
{
	new id = Iter_Free(wepc_Index);

	if(id == ITER_NONE)
	{
		err("Weapons cache pos definition limit reached.");
		return -1;
	}

	wepc_DropLocationData[id][wepc_posX] = x;
	wepc_DropLocationData[id][wepc_posY] = y;
	wepc_DropLocationData[id][wepc_posZ] = z;

	Iter_Add(wepc_Index, id);

	return id;
}

timer WeaponsCacheTimer[WEPCACHE_INTERVAL]()
{
	if(Iter_Count(Player) < 4)
		return;

	// There are no more locations available, kill the timer.
	if(Iter_Count(wepc_Index) == 0)
	{
		err("Weapons caches run out, stopping weapons cache timer.");
		return;
	}

	// Pick a location without any players nearby
	new
		id = Iter_Random(wepc_Index),
		checked;

	while(GetPlayersNearDropLocation(id) > 0)
	{
		if(checked == Iter_Count(wepc_Index))
		{
			checked = -1;
			break;
		}

		id = Iter_Random(wepc_Index);
		checked++;
	}

	if(checked > -1)
	{
		WeaponsCacheDrop(wepc_DropLocationData[id][wepc_posX], wepc_DropLocationData[id][wepc_posY], wepc_DropLocationData[id][wepc_posZ]);

		Iter_Remove(wepc_Index, id);

		webc_ActiveDrop = id;
	}

	defer WeaponsCacheTimer();

	return;
}

GetPlayersNearDropLocation(id)
{
	new count;

	foreach(new i : Player)
	{
		if(IsPlayerInRangeOfPoint(i, 500.0, wepc_DropLocationData[id][wepc_posX], wepc_DropLocationData[id][wepc_posY], wepc_DropLocationData[id][wepc_posZ]))
			count++;
	}

	return count;
}

WeaponsCacheDrop(Float:x, Float:y, Float:z)
{
	if(webc_ActiveDrop != -1)
		return 0;

	CreateDynamicObject(964, x, y, z - 0.0440, 0.0, 0.0, 0.0, .streamdistance = 1000.0, .drawdistance = 1000.0);

	wepc_CurrentPosX = x;
	wepc_CurrentPosY = y;
	wepc_CurrentPosZ = z;

	FillContainerWithLoot(CreateContainer("Caixa de Armamentos", 32, CreateButton(x, y, z + 1.5, "Caixa de Armamentos", .label =1, .labeltext = "Caixa de Armamentos")), 22 + random(11), GetLootIndexFromName("airdrop_military_weapons"));

	defer WeaponsCacheSignal(1, x, y, z);

	WCIcon(wepc_CurrentPosX, wepc_CurrentPosY, wepc_CurrentPosZ);

	return 1;
}

timer WeaponsCacheSignal[WEPCACHE_SIGNAL_INTERVAL](count, Float:x, Float:y, Float:z)
{
	// Gets a random supply drop location and uses it as a reference point.
	// Announces the angle and distance from that location to the weapons cache.
	new
		locationlist[MAX_SUPPLY_DROP_LOCATIONS],
		idx,
		location,
		name[MAX_SUPPLY_DROP_LOCATION_NAME],
		Float:ref_x,
		Float:ref_y,
		Float:ref_z;

	for(new i, j = random(GetTotalSupplyDropLocations()); i < j; i++)
	{
		GetSupplyDropLocationPos(i, ref_x, ref_y, ref_z);

		if(Distance(ref_x, ref_y, ref_z, wepc_CurrentPosX, wepc_CurrentPosY, wepc_CurrentPosZ) < 1000.0)
		{
			locationlist[idx++] = i;
		}
	}

	if(idx > 0)
	{
		location = locationlist[random(idx)];

		GetSupplyDropLocationName(location, name);

		foreach(new i : Player)
			ChatMsgLang(i, YELLOW, "WCDROP", name);
	}
	else
	{
		err("No reference point found.");
		return;
	}

	if(count < 3)
	{
		defer WeaponsCacheSignal(count + 1, x, y, z);
	}
	else
	{
		webc_ActiveDrop = -1;
	}

	return;
}

stock WCIconSpawn(playerid)
{
	if(WCDropped == 1)
	{
		SetPlayerMapIcon(playerid, ICON_WC, wepc_CurrentPosX, wepc_CurrentPosY, wepc_CurrentPosZ, 44, 0, MAPICON_GLOBAL);
	}
}

stock WCIcon(Float:x, Float:y, Float:z)
{
	foreach(new i : Player)
	{
		if(PlayerMapCheck(i))
		{
			SetPlayerMapIcon(i, ICON_WC, x, y, z, 44, 0, MAPICON_GLOBAL);
			WCDropped = 1;
		}
	}
}

hook OnPlayerDisconnect(playerid, reason)
{
	if(WCDropped == 1)
    {
		RemovePlayerMapIcon(playerid, ICON_WC);   
	}
}