#include <YSI\y_hooks>

forward OnVehicleRepairStopped(playerid, vehicleid);

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

		/* if(vehiclehealth >= VEHICLE_HEALTH_MAX) { // Não precisa de reparos.
			CancelPlayerMovement(playerid);
			ShowRepairStatus(playerid, vehicleid);
			return Y_HOOKS_CONTINUE_RETURN_0;
		} */

		if(itemtype == item_Wrench)
		{
			CancelPlayerMovement(playerid);

			if(VEHICLE_HEALTH_CHUNK_1 - 2.0 <= vehiclehealth <= VEHICLE_HEALTH_CHUNK_2)
			{
				StartRepairingVehicle(playerid, vehicleid);
				return Y_HOOKS_BREAK_RETURN_1;
			}
			else {
				ShowRepairStatus(playerid, vehicleid);
				ShowActionText(playerid, ls(playerid, "vehicle/repair/tool/another"), 3000, 100);
			}
		}	
		else if(itemtype == item_Screwdriver)
		{
			CancelPlayerMovement(playerid);

			if(VEHICLE_HEALTH_CHUNK_2 - 2.0 <= vehiclehealth <= VEHICLE_HEALTH_CHUNK_3)
			{
				StartRepairingVehicle(playerid, vehicleid);
				return Y_HOOKS_BREAK_RETURN_1;
			}
			else {
				ShowRepairStatus(playerid, vehicleid);
				ShowActionText(playerid, ls(playerid, "vehicle/repair/tool/another"), 3000, 100);
			}
		}	
		else if(itemtype == item_Hammer)
		{
			CancelPlayerMovement(playerid);

			if(VEHICLE_HEALTH_CHUNK_3 - 2.0 <= vehiclehealth <= VEHICLE_HEALTH_CHUNK_4)
			{
				StartRepairingVehicle(playerid, vehicleid);
				return Y_HOOKS_BREAK_RETURN_1;
			}
			else {
				ShowRepairStatus(playerid, vehicleid);
				ShowActionText(playerid, ls(playerid, "vehicle/repair/tool/another"), 3000, 100);
			}
		}
		else if(itemtype == item_Spanner)
		{
			CancelPlayerMovement(playerid);

			if(VEHICLE_HEALTH_CHUNK_4 - 2.0 <= vehiclehealth <= VEHICLE_HEALTH_MAX)
			{
				StartRepairingVehicle(playerid, vehicleid);
				return Y_HOOKS_BREAK_RETURN_1;
			}
			else {
				ShowRepairStatus(playerid, vehicleid);
				ShowActionText(playerid, ls(playerid, "vehicle/repair/tool/another"), 3000, 100);
			}
		}
		else if(itemtype == item_Wheel)
		{
			CancelPlayerMovement(playerid);
			ShowActionText(playerid, ls(playerid, "vehicle/repair/wheel/closer"), 5000);
		}
		else if(itemtype == item_Headlight)
		{
			CancelPlayerMovement(playerid);
			ShowLightList(playerid, vehicleid);
		} 
		else ShowRepairStatus(playerid, vehicleid); // Útil para mostrar as ferramentas necessárias para reparar o veí­culo
		}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(oldkeys & KEY_SECONDARY_ATTACK) // * Botao direito do mouse. Em caso de querer mirar.
	{
		if(fix_TargetVehicle[playerid] != INVALID_VEHICLE_ID)
		{
			StopRepairingVehicle(playerid);
			StopRefuellingVehicle(playerid);
		}
	}
}

StartRepairingVehicle(playerid, vehicleid) {
	GetVehicleHealth(vehicleid, fix_Progress[playerid]);

	if(fix_Progress[playerid] >= 990.0) return 0;

	ApplyAnimation(playerid, "INT_SHOP", "SHOP_CASHIER", 4.0, 1, 0, 0, 0, 0, 1);
	VehicleBonnetState(fix_TargetVehicle[playerid], 1); // Abre o capô do veí­culo

	new buildtime = GetPlayerVipMulti(playerid, 50);

   	StartHoldAction(playerid, buildtime * 1000, floatround(fix_Progress[playerid] * buildtime));

	fix_TargetVehicle[playerid] = vehicleid;

	return 1;
}

StopRepairingVehicle(playerid) {
	if(fix_TargetVehicle[playerid] == INVALID_VEHICLE_ID) return 0;

	if(fix_Progress[playerid] >= 988.0) {
		if(GetPlayerVipTier(playerid)) {
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
			
			ShowActionText(playerid, ls(playerid, "vehicle/repair/body/fixed"), 5000);
		}
		
        SetVehicleHealth(fix_TargetVehicle[playerid], 990.0);
 	}

	VehicleBonnetState(fix_TargetVehicle[playerid], 0); // Fecha o capô do veí­culo
	StopHoldAction(playerid);
	ClearAnimations(playerid);

	ShowRepairStatus(playerid, fix_TargetVehicle[playerid]);

	// Call callback
	CallLocalFunction("OnVehicleRepairStopped", "ii", playerid, fix_TargetVehicle[playerid]);

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
		else StopRepairingVehicle(playerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

CompToolHealth(ItemType:itemtype, Float:health)
{
	if(VEHICLE_HEALTH_CHUNK_1 - 2.0 <= health <= VEHICLE_HEALTH_CHUNK_2 - 2.0)
	{
		if(itemtype == item_Wrench) return 1;
	}
	else if(VEHICLE_HEALTH_CHUNK_2 - 2.0 <= health <= VEHICLE_HEALTH_CHUNK_3 - 2.0)
	{
		if(itemtype == item_Screwdriver) return 1;
	}
	else if(VEHICLE_HEALTH_CHUNK_3 - 2.0 <= health <= VEHICLE_HEALTH_CHUNK_4 - 2.0)
	{
		if(itemtype == item_Hammer) return 1;
	}
	else if(VEHICLE_HEALTH_CHUNK_4 - 2.0 <= health <= VEHICLE_HEALTH_MAX - 2.0)
	{
		if(itemtype == item_Spanner) return 1;
	}

	return 0;
}