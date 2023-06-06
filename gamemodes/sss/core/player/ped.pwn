stock GetPlayerPedCount(playerid) {
	new count;

	foreach(new i : Player) {
		if(
			i == playerid ||
			!IsPlayerStreamedIn(i, playerid) ||
			IsPlayerOnAdminDuty(i) ||
			!IsPlayerSpawned(i)
		) continue;

		count++;
	}
		
	return count;
}

/*stock GetPlayerVEH(playerid) {
	new v, Float:x, Float:y, Float: z;
	GetVehiclePos(vehicleid, x, y, z);
	foreach(new i : Player) if(GetPlayerDistanceFromPoint(i, x, y, z) < 300.0 && i != vehicleid) v++;
	return v;
}*/
