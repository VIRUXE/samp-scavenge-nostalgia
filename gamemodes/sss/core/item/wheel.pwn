#include <YSI_Coding\y_hooks>

static PlayerUpdateWheel[MAX_PLAYERS] = {INVALID_VEHICLE_ID, ...};

new Timer:UpdateVehWheel[MAX_PLAYERS];

hook OnPlayerDisconnect(playerid, reason)
{
	stop UpdateVehWheel[playerid];
	PlayerUpdateWheel[playerid] = INVALID_VEHICLE_ID;
}

hook OnPlayerInteractVehicle(playerid, vehicleid, Float:angle)
{
	dbg("global", CORE, "[OnPlayerInteractVehicle] in /gamemodes/sss/core/item/wheel.pwn");

	new itemid = GetPlayerItem(playerid);
	if(GetItemType(itemid) == item_Wheel && PlayerUpdateWheel[playerid] == INVALID_VEHICLE_ID) _WheelRepair(playerid, vehicleid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

/*hook OnPlayerInteractVehicle(playerid, vehicleid, Float:angle)
{
	dbg("global", CORE, "[OnPlayerInteractVehicle] in /gamemodes/sss/core/item/wheel.pwn");

	new itemid = GetPlayerItem(playerid);

	if(GetItemType(itemid) == item_Wheel)
	{
		if(_WheelRepair(playerid, vehicleid, itemid))
			return Y_HOOKS_BREAK_RETURN_0;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}*/

_WheelRepair(playerid, vehicleid)
{
	new
		wheel = GetPlayerVehicleTire(playerid, vehicleid),
		vehicletype = GetVehicleType(vehicleid),
		panels, doors, lights, tires,
		Float:x, Float:y, Float:z,
		Float:px, Float:py;

	GetVehicleDamageStatus(vehicleid, panels, doors, lights, tires);
	GetVehicleWheelPos(vehicleid, wheel, x, y, z);
	GetPlayerPos(playerid, px, py, z);

	SetPlayerFacingAngle(playerid, GetAngleToPoint(px, py, x, y));

	if(GetVehicleTypeCategory(vehicletype) == VEHICLE_CATEGORY_MOTORBIKE && GetVehicleTypeModel(vehicletype) != 471)
	{
		switch(wheel)
		{
			case WHEELSFRONT_LEFT, WHEELSFRONT_RIGHT: // Front
			{
				if(tires & 0b0010)
				{
					stop UpdateVehWheel[playerid];
					UpdateVehWheel[playerid] = defer upVehWheel(playerid, vehicleid, tires & 0b1101);
					ShowActionText(playerid, ls(playerid, "TIREREPFT"), 7000);
					PlayerUpdateWheel[playerid] = vehicleid;
					ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);
					PlayerPlaySound(playerid, 32000, 0.0, 0.0, 0.0);
					StartHoldAction(playerid, 7000, 1);
				}
				else ShowActionText(playerid, ls(playerid, "TIRENOTBROK"), 2000);
			}

			case WHEELSMID_LEFT, WHEELSMID_RIGHT, WHEELSREAR_LEFT, WHEELSREAR_RIGHT: // back
			{
				if(tires & 0b0001)
				{
					stop UpdateVehWheel[playerid];
					UpdateVehWheel[playerid] = defer upVehWheel(playerid, vehicleid, tires & 0b1110);
					ShowActionText(playerid, ls(playerid, "TIREREPRT"), 7000);
					PlayerUpdateWheel[playerid] = vehicleid;
					ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);
					PlayerPlaySound(playerid, 32000, 0.0, 0.0, 0.0);
					StartHoldAction(playerid, 7000, 1);
				}
				else ShowActionText(playerid, ls(playerid, "TIRENOTBROK"), 2000);
			}

			default: return 0;
		}
	}
	else
	{
		switch(wheel)
		{
			case WHEELSFRONT_LEFT:
			{
				if(tires & 0b1000)
				{
					stop UpdateVehWheel[playerid];
					UpdateVehWheel[playerid] = defer upVehWheel(playerid, vehicleid, 0);
					ShowActionText(playerid, ls(playerid, "TIREREPFL"), 7000);
					PlayerUpdateWheel[playerid] = vehicleid;
					ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);
					PlayerPlaySound(playerid, 32000, 0.0, 0.0, 0.0);
					StartHoldAction(playerid, 7000, 1);
				}
				else ShowActionText(playerid, ls(playerid, "TIRENOTBROK"), 2000);
			}

			case WHEELSFRONT_RIGHT:
			{
				if(tires & 0b0010)
				{
					stop UpdateVehWheel[playerid];
					UpdateVehWheel[playerid] = defer upVehWheel(playerid, vehicleid, 1);
					ShowActionText(playerid, ls(playerid, "TIREREPFR"), 7000);
					PlayerUpdateWheel[playerid] = vehicleid;
					ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);
					PlayerPlaySound(playerid, 32000, 0.0, 0.0, 0.0);
					StartHoldAction(playerid, 7000, 1);
				}
				else ShowActionText(playerid, ls(playerid, "TIRENOTBROK"), 2000);
			}

			case WHEELSREAR_LEFT:
			{
				if(tires & 0b0100)
				{
					stop UpdateVehWheel[playerid];
					UpdateVehWheel[playerid] = defer upVehWheel(playerid, vehicleid, 2);
					ShowActionText(playerid, ls(playerid, "TIREREPBL"), 7000);
					PlayerUpdateWheel[playerid] = vehicleid;
					ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);
					PlayerPlaySound(playerid, 32000, 0.0, 0.0, 0.0);
					StartHoldAction(playerid, 7000, 1);
				}
				else ShowActionText(playerid, ls(playerid, "TIRENOTBROK"), 2000);
			}

			case WHEELSREAR_RIGHT:
			{
				if(tires & 0b0001)
				{
					stop UpdateVehWheel[playerid];
					UpdateVehWheel[playerid] = defer upVehWheel(playerid, vehicleid, 3);
					ShowActionText(playerid, ls(playerid, "TIREREPBR"), 7000);
					PlayerUpdateWheel[playerid] = vehicleid;
					ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);
					PlayerPlaySound(playerid, 32000, 0.0, 0.0, 0.0);
					StartHoldAction(playerid, 7000, 1);
				}
				else ShowActionText(playerid, ls(playerid, "TIRENOTBROK"), 2000);
			}

			default: return 0;
		}
	}

	return 1;
}

timer upVehWheel[SEC(7)](playerid, vehicleid, wheelpos) {

	new panels, doors, lights, tires;
	GetVehicleDamageStatus(vehicleid, panels, doors, lights, tires);

	switch(wheelpos) {
		case 0: UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires & 0b0111);
		case 1: UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires & 0b1101);
		case 2: UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires & 0b1011);
		case 3: UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires & 0b1110);
	}

	StopHoldAction(playerid);
	ClearAnimations(playerid);
	PlayerUpdateWheel[playerid] = INVALID_VEHICLE_ID;
	
	ShowActionText(playerid, ls(playerid, "TIREREPP"), 2000);

	if(GetItemType(GetPlayerItem(playerid)) == item_Wheel) DestroyItem(GetPlayerItem(playerid));
}

hook OnPlayerOpenInventory(playerid){
	if(PlayerUpdateWheel[playerid] != INVALID_VEHICLE_ID) StopInstallWheel(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenContainer(playerid, containerid){
	if(PlayerUpdateWheel[playerid] != INVALID_VEHICLE_ID) StopInstallWheel(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDropItem(playerid, itemid){
	if(PlayerUpdateWheel[playerid] != INVALID_VEHICLE_ID) StopInstallWheel(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemovedFromPlayer(playerid, itemid){
	if(PlayerUpdateWheel[playerid] != INVALID_VEHICLE_ID) StopInstallWheel(playerid);
}

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger) {
	if(PlayerUpdateWheel[playerid] != INVALID_VEHICLE_ID) StopInstallWheel(playerid);

	return 1;
}

hook OnPlayerDroppedItem(playerid, itemid){
	if(GetItemType(itemid) == item_Wheel) {
		new Float:x, Float:y, Float:z, Float:r;

		GetItemPos(itemid, x, y, z);
		GetPlayerFacingAngle(playerid, r);

		x += 0.413054 * floatsin(-r, degrees), y += 0.413054 * floatcos(-r, degrees);
		SetItemPos(itemid, x, y, z);
	}
}

StopInstallWheel(playerid){
	stop UpdateVehWheel[playerid];
	StopHoldAction(playerid);
	PlayerUpdateWheel[playerid] = INVALID_VEHICLE_ID;
	ClearAnimations(playerid);
}

// Instalação de rodas
hook OnHoldActionUpdate(playerid, progress){
	if(PlayerUpdateWheel[playerid] != INVALID_VEHICLE_ID) {
		if(GetPlayerTotalVelocity(playerid) > 1.0) {
			StopInstallWheel(playerid);
			return Y_HOOKS_BREAK_RETURN_0;
		}

		ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);
		return Y_HOOKS_BREAK_RETURN_0;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}