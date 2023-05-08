#include <YSI\y_hooks>

enum E_LOCK_STATE {
	E_LOCK_STATE_OPEN,		// 0 Vehicle is enterable
	E_LOCK_STATE_EXTERNAL,	// 1 Installed lock, cannot be broken with crowbar
	E_LOCK_STATE_DEFAULT	// 2 Default manufacturer's lock, broken with crowbar
}

static
E_LOCK_STATE:	lock_Status				[MAX_VEHICLES],
				lock_LastChange			[MAX_VEHICLES],
				lock_DisableForPlayer	[MAX_PLAYERS];


hook OnItemTypeDefined(uname[]) {
	if(!strcmp(uname, "Key"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("Key"), 2);
}

hook OnVehicleCreated(vehicleid) {
	lock_Status[vehicleid]     = E_LOCK_STATE_OPEN;
	lock_LastChange[vehicleid] = 0;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnVehicleReset(oldid, newid) {
	lock_Status[newid] = lock_Status[oldid];
}

hook OnPlayerConnect(playerid) {
	lock_DisableForPlayer[playerid] = false;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	if(newkeys & KEY_SUBMISSION) {
		if(IsPlayerInAnyVehicle(playerid)) {
			_HandleLockKey(playerid);
			PlayerPlaySound(playerid, 24600, 0.0, 0.0, 0.0);
		}
	}

	if(newkeys & 16) {
		new vehicleid = GetPlayerVehicleArea(playerid);

		if(IsValidVehicle(vehicleid) && !IsPlayerInAnyVehicle(playerid)) {
			if(lock_Status[vehicleid] == E_LOCK_STATE_DEFAULT)
				ShowActionText(playerid, ls(playerid, "vehicle/lock/door-locked"), SEC(6));
			else if(lock_Status[vehicleid] == E_LOCK_STATE_EXTERNAL)
				ShowActionText(playerid, ls(playerid, "vehicle/lock/door-locked-persn"), SEC(6));
		}
	}

	return 1;
}

_HandleLockKey(playerid) {
	if(IsPlayerKnockedOut(playerid)) return 0;

	new vehicleid = GetPlayerVehicleID(playerid);
	SetVehicleExternalLock(vehicleid, lock_Status[vehicleid] == E_LOCK_STATE_OPEN ? E_LOCK_STATE_DEFAULT : E_LOCK_STATE_OPEN);

	return 1;
}

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger) {
	if(lock_Status[vehicleid] != E_LOCK_STATE_OPEN) {
		CancelPlayerMovement(playerid);
		ShowActionText(playerid, ls(playerid, "vehicle/lock/locked"), 3000);
	}

	return 1;
}

hook OnPlayerEnterVehArea(playerid, vehicleid) {
	SetVehicleParamsForPlayer(vehicleid, playerid, 0, lock_Status[vehicleid] == E_LOCK_STATE_OPEN && !lock_DisableForPlayer[playerid] && !IsVehicleDead(vehicleid) ? 0 : 1);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerLeaveVehArea(playerid, vehicleid) {
	SetVehicleParamsForPlayer(vehicleid, playerid, 0, 1);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

stock E_LOCK_STATE:GetVehicleLockState(vehicleid) return !IsValidVehicle(vehicleid) ? E_LOCK_STATE_OPEN : lock_Status[vehicleid];

stock SetVehicleExternalLock(vehicleid, E_LOCK_STATE:status) {
	if(!IsValidVehicle(vehicleid)) return 0;

	if(IsVehicleDead(vehicleid)) {
		lock_Status[vehicleid] = E_LOCK_STATE_EXTERNAL;
		VehicleDoorsState(vehicleid, true);
		return 1;
	}

	lock_LastChange[vehicleid] = GetTickCount();
	lock_Status[vehicleid]     = status;

	VehicleDoorsState(vehicleid, status == E_LOCK_STATE_OPEN ? false : true);

	return 1;
}

stock GetVehicleLockTick(vehicleid) return !IsValidVehicle(vehicleid) ? 0 : lock_LastChange[vehicleid];

stock TogglePlayerVehicleEntry(playerid, bool:toggle) {
	if(!IsPlayerConnected(playerid)) return 0;

	lock_DisableForPlayer[playerid] = !toggle;

	return 1;
}