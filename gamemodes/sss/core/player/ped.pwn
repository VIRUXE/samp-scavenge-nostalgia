#include <YSI\y_hooks>


stock GetPlayerPED(playerid)
{
	new ped;
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);
	foreach(new i : Player) if(GetPlayerDistanceFromPoint(i, x, y, z) < 300.0 && i != playerid)

	if(!IsPlayerOnAdminDuty(i) && GetPlayerSkin(i) != 0)
		ped++;
		
	return ped;
}

/*stock GetPlayerVEH(playerid) 
{
	new v;
	new Float:x, Float:y, Float: z;
	GetVehiclePos(vehicleid, x, y, z);
	foreach(new i : Player) if(GetPlayerDistanceFromPoint(i, x, y, z) < 300.0 && i != vehicleid) v++;
	return v;
}*/

/*CMD:ped(playerid)
{
 	new stringped;
 	stringped = GetPlayerPED(playerid);
 	ChatMsg(playerid, RED, "> SEU PED É: %i", stringped);
 	return 1;
 }*/
