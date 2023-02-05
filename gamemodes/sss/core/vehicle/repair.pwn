/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2017 Barnaby "Southclaws" Keene

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


static
		fix_TargetVehicle[MAX_PLAYERS],
Float:	fix_Progress[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	fix_TargetVehicle[playerid] = INVALID_VEHICLE_ID;
}

hook OnPlayerInteractVehicle(playerid, vehicleid, Float:angle)
{


	if(angle < 25.0 || angle > 335.0)
	{
		new
			Float:vehiclehealth,
			ItemType:itemtype;

		GetVehicleHealth(vehicleid, vehiclehealth);
		itemtype = GetItemType(GetPlayerItem(playerid));

		if(itemtype == item_Wrench)
		{
			if(VEHICLE_HEALTH_CHUNK_1 - 2.0 <= vehiclehealth <= VEHICLE_HEALTH_CHUNK_2)
			{
				CancelPlayerMovement(playerid);
				StartRepairingVehicle(playerid, vehicleid);
				return Y_HOOKS_BREAK_RETURN_1;
			}
			else
			{
				ShowActionText(playerid, GetLanguageString(playerid, "NEEDANOTOOL", true), 3000, 100);
			}
		}	
		else if(itemtype == item_Screwdriver)
		{
			if(VEHICLE_HEALTH_CHUNK_2 - 2.0 <= vehiclehealth <= VEHICLE_HEALTH_CHUNK_3)
			{
				CancelPlayerMovement(playerid);
				StartRepairingVehicle(playerid, vehicleid);
				return Y_HOOKS_BREAK_RETURN_1;
			}
			else
			{
				ShowActionText(playerid, GetLanguageString(playerid, "NEEDANOTOOL", true), 3000, 100);
			}
		}	
		else if(itemtype == item_Hammer)
		{
			if(VEHICLE_HEALTH_CHUNK_3 - 2.0 <= vehiclehealth <= VEHICLE_HEALTH_CHUNK_4)
			{
				CancelPlayerMovement(playerid);
				StartRepairingVehicle(playerid, vehicleid);
				return Y_HOOKS_BREAK_RETURN_1;
			}
			else
			{
				ShowActionText(playerid, GetLanguageString(playerid, "NEEDANOTOOL", true), 3000, 100);
			}
		}
		else if(itemtype == item_Spanner)
		{
			if(VEHICLE_HEALTH_CHUNK_4 - 2.0 <= vehiclehealth <= VEHICLE_HEALTH_MAX)
			{
				CancelPlayerMovement(playerid);
				StartRepairingVehicle(playerid, vehicleid);
				return Y_HOOKS_BREAK_RETURN_1;
			}
			else
			{
				ShowActionText(playerid, GetLanguageString(playerid, "NEEDANOTOOL", true), 3000, 100);
			}
		}
		else if(itemtype == item_Wheel)
		{
			CancelPlayerMovement(playerid);
			ShowActionText(playerid, ls(playerid, "INTERACTWHE", true), 5000);
		}
		else if(itemtype == item_Headlight)
		{
			CancelPlayerMovement(playerid);
			ShowLightList(playerid, vehicleid);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{


	if(oldkeys & 16)
	{
		StopRepairingVehicle(playerid);
		StopRefuellingVehicle(playerid);
	}
}

StartRepairingVehicle(playerid, vehicleid)
{
	GetVehicleHealth(vehicleid, fix_Progress[playerid]);

	if(fix_Progress[playerid] >= 990.0)
	{
		return 0;
	}

	ApplyAnimation(playerid, "INT_SHOP", "SHOP_CASHIER", 4.0, 1, 0, 0, 0, 0, 1);
	VehicleBonnetState(fix_TargetVehicle[playerid], 1);

	if(IsPlayerVip(playerid))
    	StartHoldAction(playerid, 38000, floatround(fix_Progress[playerid] * 38));
	else
    	StartHoldAction(playerid, 50000, floatround(fix_Progress[playerid] * 50));

	fix_TargetVehicle[playerid] = vehicleid;

	return 1;
}

StopRepairingVehicle(playerid)
{
	if(fix_TargetVehicle[playerid] == INVALID_VEHICLE_ID)
		return 0;

	if(fix_Progress[playerid] >= 988.0)
	{
        SetVehicleHealth(fix_TargetVehicle[playerid], 990.0);
        
        // Reparar lataria do veículo
        
		new Float:lataria, j1, j2, j3, j4, p1, p2, p3, p4, aux, luzes, pneus;
	    GetVehicleHealth(fix_TargetVehicle[playerid], lataria);
 		GetVehicleParamsCarDoors(fix_TargetVehicle[playerid], p1, p2, p3, p4);
 		GetVehicleParamsCarWindows(fix_TargetVehicle[playerid], j1, j2, j3, j4);
 	    GetVehicleDamageStatus(fix_TargetVehicle[playerid], aux, aux, luzes, pneus);
	  	RepairVehicle(fix_TargetVehicle[playerid]);
    	SetVehicleHealth(fix_TargetVehicle[playerid], lataria);
   		UpdateVehicleDamageStatus(fix_TargetVehicle[playerid], 0, 0, luzes, pneus);
    	SetVehicleParamsCarWindows(fix_TargetVehicle[playerid], j1, j2, j3, j4);
    	SetVehicleParamsCarDoors(fix_TargetVehicle[playerid], p1, p2, p3, p4);
    	ShowActionText(playerid, GetLanguageString(playerid, "VEHICLEBODY", true), 5000);
 }

	VehicleBonnetState(fix_TargetVehicle[playerid], 0);
	StopHoldAction(playerid);
	ClearAnimations(playerid);

	fix_TargetVehicle[playerid] = INVALID_VEHICLE_ID;

	return 1;
}

hook OnHoldActionUpdate(playerid, progress)
{


	if(fix_TargetVehicle[playerid] != INVALID_VEHICLE_ID)
	{
		new ItemType:itemtype = GetItemType(GetPlayerItem(playerid));

		if(!IsValidItemType(itemtype))
		{
			StopRepairingVehicle(playerid);
			return Y_HOOKS_BREAK_RETURN_1;
		}

		if(!IsPlayerInVehicleArea(playerid, fix_TargetVehicle[playerid]) || !IsValidVehicle(fix_TargetVehicle[playerid]))
		{
			StopRepairingVehicle(playerid);
			return Y_HOOKS_BREAK_RETURN_1;
		}

		if(CompToolHealth(itemtype, fix_Progress[playerid]))
		{
			fix_Progress[playerid] += (float(2000) / 1000.0);
			SetVehicleHealth(fix_TargetVehicle[playerid], fix_Progress[playerid]);
			SetPlayerToFaceVehicle(playerid, fix_TargetVehicle[playerid]);	
		}
		else
		{
			StopRepairingVehicle(playerid);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

CompToolHealth(ItemType:itemtype, Float:health)
{
	if(VEHICLE_HEALTH_CHUNK_1 - 2.0 <= health <= VEHICLE_HEALTH_CHUNK_2 - 2.0)
	{
		if(itemtype == item_Wrench)
			return 1;
	}
	else if(VEHICLE_HEALTH_CHUNK_2 - 2.0 <= health <= VEHICLE_HEALTH_CHUNK_3 - 2.0)
	{
		if(itemtype == item_Screwdriver)
			return 1;
	}
	else if(VEHICLE_HEALTH_CHUNK_3 - 2.0 <= health <= VEHICLE_HEALTH_CHUNK_4 - 2.0)
	{
		if(itemtype == item_Hammer)
			return 1;
	}
	else if(VEHICLE_HEALTH_CHUNK_4 - 2.0 <= health <= VEHICLE_HEALTH_MAX - 2.0)
	{
		if(itemtype == item_Spanner)
			return 1;
	}

	return 0;
}
