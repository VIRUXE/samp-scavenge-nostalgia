#include <YSI\y_hooks>

new
	Float: int_pPos[MAX_PLAYERS][3];

hook OnPlayerUpdate(playerid){
    SetPlayerShopName(playerid, "");
    if(GetPlayerInterior(playerid) == 0 && IsPlayerSpawned(playerid))
	    GetPlayerPos(playerid, int_pPos[playerid][0], int_pPos[playerid][1], int_pPos[playerid][2]);
    return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
    if(newinteriorid == 0 && oldinteriorid != 0){
        SetPlayerVirtualWorld(playerid, 0);
	}
	else if(newinteriorid != 0){
	    SetPlayerVirtualWorld(playerid, playerid + 1);

	    foreach(new i : Player){

	        if(GetPlayerVirtualWorld(i) == 0)
				continue;

	        if(playerid == i)
				continue;

			if(Distance(int_pPos[playerid][0], int_pPos[playerid][1], int_pPos[playerid][2],
			    int_pPos[i][0], int_pPos[i][1], int_pPos[i][2]) < 10.0)
					SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(i));
	    }
	}
    return 1;
}

stock int_GetPlayerPos(playerid, &Float:x, &Float:y, &Float:z){
	x = int_pPos[playerid][0];
	y = int_pPos[playerid][1];
	z = int_pPos[playerid][2];
	return 1;
}
