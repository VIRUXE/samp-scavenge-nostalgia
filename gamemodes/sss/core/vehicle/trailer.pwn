#include <YSI\y_hooks>

static
	trl_VehicleTrailer[MAX_VEHICLES] = {INVALID_VEHICLE_ID, ...},
	trl_TrailerVehicle[MAX_VEHICLES] = {INVALID_VEHICLE_ID, ...},
	trl_VehicleTypeHitchSize[MAX_VEHICLE_TYPE] = {-1, ...};

/*
	Used to set which vehicle types can pull specific sizes of trailers. The
	default is -1 (invalid size).
*/
stock SetVehicleTypeTrailerHitch(vehicleType, maxtrailersize) {
	if(!IsValidVehicleType(vehicleType)) return 0;

	trl_VehicleTypeHitchSize[vehicleType] = maxtrailersize;

	return 1;
}

/*
	Don't use AttachTrailerToVehicle anywhere else! Use this instead, which
	ensures everything stays synced properly.
*/
stock SetVehicleTrailer(vehicleId, trailerId) {
	if(!IsValidVehicle(vehicleId) || !IsValidVehicle(trailerId)) return 0;

	if(trl_VehicleTrailer[vehicleId] != INVALID_VEHICLE_ID && trl_VehicleTrailer[vehicleId] != trailerId) {
		if(IsValidVehicle(trl_VehicleTrailer[vehicleId]))
			return 0;
	}

	if(trl_TrailerVehicle[trailerId] != INVALID_VEHICLE_ID && trl_TrailerVehicle[trailerId] != vehicleId) {
		if(IsValidVehicle(trl_TrailerVehicle[trailerId]))
			return 0;
	}

	if(trl_VehicleTypeHitchSize[GetVehicleType(vehicleId)] != GetVehicleTypeSize(GetVehicleType(trailerId))) return 0;

	trl_VehicleTrailer[vehicleId] = trailerId;
	trl_TrailerVehicle[trailerId] = vehicleId;

	AttachTrailerToVehicle(trailerId, vehicleId);

	return 1;
}

/*
	Likewise, don't use DetachTrailerFromVehicle anywhere, use this instead.
*/
stock RemoveVehicleTrailer(vehicleId) {
	if(!IsValidVehicle(vehicleId)) return 0;

	new trailerId = trl_VehicleTrailer[vehicleId];

	if(!IsValidVehicle(trailerId)) return 0;

	trl_VehicleTrailer[vehicleId] = INVALID_VEHICLE_ID;
	trl_TrailerVehicle[trailerId] = INVALID_VEHICLE_ID;

	DetachTrailerFromVehicle(vehicleId);

	return 1;
}

/*
	GetVehicleTrailer will return the client-side trailer. This returns the
	server-side trailer which is more reliable. A combination of both could be
	used for anti-cheat however.
*/
stock GetVehicleTrailerID(vehicleId) {
	if(!IsValidVehicle(vehicleId)) return 0;

	return trl_VehicleTrailer[vehicleId];
}

/*
	Return the vehicle that's pulling the specified trailer because why not.
*/
stock GetTrailerVehicleID(vehicleId) {
	if(!IsValidVehicle(vehicleId)) return 0;

	return trl_TrailerVehicle[vehicleId];
}


/*==============================================================================

	Internal

==============================================================================*/


/*
	This timer ensures two things: trailers detached from unoccupied vehicles
	are reattached (it might be desync or a player trying to pull the trailer
	away or something) and that trailers detached from occupied vehicles are
	also cleared on the server side (so the server doesn't still think the
	trailer is attached).
*/
task _trailerSync[SEC(1)]() {
	new trailerId;

	foreach(new i : veh_Index) {
		// If this vehicle doesn't have a trailer, skip.
		if(trl_VehicleTrailer[i] == INVALID_VEHICLE_ID) {
			trailerId = GetVehicleTrailer(i);

			// Check for a client-sided trailer and try to add it
			if(IsValidVehicle(trailerId))
				SetVehicleTrailer(i, trailerId);
			else
				continue;
		}

		// If this vehicle apparently did have a trailer but it doesn't exist,
		// clear that trailer from memory.
		if(!IsValidVehicle(trl_VehicleTrailer[i])) {
			trl_TrailerVehicle[trl_VehicleTrailer[i]] = INVALID_VEHICLE_ID;
			trl_VehicleTrailer[i]                     = INVALID_VEHICLE_ID;
			continue;
		}

		// If the vehicle does have a trailer client-side and it's the server
		// side trailer, everything is fine so skip.
		if(GetVehicleTrailer(i) == trl_VehicleTrailer[i]) continue;

		// If not, and the vehicle is occupied then remove the trailer using the
		// function to remove it server-side. If the vehicle isn't occupied,
		// attach the trailer again for all streamed players.
		if(IsVehicleOccupied(i))
			RemoveVehicleTrailer(i);
		else
			AttachTrailerToVehicle(trl_VehicleTrailer[i], i);
	}
}

/*
	If a vehicle pulling a trailer or a trailer itself dies, clean up.
*/
hook OnVehicleDeath(vehicleId, killerid) {
	if(IsValidVehicle(trl_VehicleTrailer[vehicleId])) {
		trl_TrailerVehicle[trl_VehicleTrailer[vehicleId]] = INVALID_VEHICLE_ID;
		trl_VehicleTrailer[vehicleId] = INVALID_VEHICLE_ID;
	}

	if(IsValidVehicle(trl_TrailerVehicle[vehicleId])) {
		trl_VehicleTrailer[trl_TrailerVehicle[vehicleId]] = INVALID_VEHICLE_ID;
		trl_TrailerVehicle[vehicleId] = INVALID_VEHICLE_ID;
	}

	return 1;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	if(!IsPlayerInAnyVehicle(playerid)) return 1;

	if(newkeys == KEY_ACTION) _HandleTrailerTowKey(playerid);

	return 1;
}

_HandleTrailerTowKey(playerid) {
	new
		vehicleId,
		vehicleType;

	vehicleId = GetPlayerVehicleID(playerid);
	vehicleType = GetVehicleType(vehicleId);

	if(!IsValidVehicleType(vehicleType)) return 0;

	if(trl_VehicleTypeHitchSize[vehicleType] == -1) return 0;

	new
		tmpType,
		Float:vx1, Float:vy1, Float:vz1,
		Float:size_x1, Float:size_y1, Float:size_z1,
		Float:vx2, Float:vy2, Float:vz2,
		Float:size_x2, Float:size_y2, Float:size_z2;

	GetVehiclePos(vehicleId, vx1, vy1, vz1);
	GetVehicleModelInfo(GetVehicleTypeModel(vehicleType), VEHICLE_MODEL_INFO_SIZE, size_x1, size_y1, size_z1);

	if(IsTrailerAttachedToVehicle(vehicleId)) {
		RemoveVehicleTrailer(vehicleId);
		return 1;
	}

	foreach(new i : veh_Index) {
		if(i == vehicleId) continue;

		tmpType = GetVehicleType(i);

		if(!IsVehicleTypeTrailer(tmpType)) continue;

		if(GetVehicleTypeSize(tmpType) != trl_VehicleTypeHitchSize[vehicleType]) continue;

		GetVehiclePos(i, vx2, vy2, vz2);
		GetVehicleModelInfo(GetVehicleTypeModel(tmpType), VEHICLE_MODEL_INFO_SIZE, size_x2, size_y2, size_z2);

		if(Distance(vx1, vy1, vz1, vx2, vy2, vz2) < size_y1 + size_y2 + 1.0) {
			SetVehicleTrailer(vehicleId, i);

			break;
		}
	}

	return 1;
}
