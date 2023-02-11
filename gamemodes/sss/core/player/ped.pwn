stock GetPlayerPED(playerid){
	new ped, Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);

	foreach(new i : Player) if(GetPlayerDistanceFromPoint(i, x, y, z) < 300.0 && i != playerid)

	if(!IsPlayerOnAdminDuty(i) && GetPlayerSkin(i) != 0)
		ped++;
		
	return ped;
}

/*stock GetPlayerVEH(playerid) {
	new v, Float:x, Float:y, Float: z;
	GetVehiclePos(vehicleid, x, y, z);
	foreach(new i : Player) if(GetPlayerDistanceFromPoint(i, x, y, z) < 300.0 && i != vehicleid) v++;
	return v;
}*/
