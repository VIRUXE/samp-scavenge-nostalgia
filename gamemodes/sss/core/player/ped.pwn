stock GetPlayerPED(playerid) {
	new ped;

	foreach(new i : Player) {
		if(i == playerid) continue; // skip self
		if(!IsPlayerStreamedIn(i, playerid)) continue; // skip if not streamed in
		if(IsPlayerOnAdminDuty(i)) continue; // skip if admin
		if(!IsPlayerSpawned(i)) continue;

		ped++;
	}
		
	return ped;
}

/*stock GetPlayerVEH(playerid) {
	new v, Float:x, Float:y, Float: z;
	GetVehiclePos(vehicleid, x, y, z);
	foreach(new i : Player) if(GetPlayerDistanceFromPoint(i, x, y, z) < 300.0 && i != vehicleid) v++;
	return v;
}*/
