#include 	<a_samp>

#define		FILTERSCRIPT

#define     MAX_PLAYER_IP   (3)

#include <Pawn.RakNet>

public OnPlayerConnect(playerid)
{
    new pip2[16], c, player_ip[16];
    
    GetPlayerIp(playerid, player_ip, 16);

	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(!IsPlayerConnected(i)) continue;
	    if(i == playerid) continue;
	    GetPlayerIp(i, pip2, sizeof(pip2));
	    if(!strcmp( player_ip,pip2)) c ++;
	}

	if(c >= MAX_PLAYER_IP)
    	Ban(playerid);

	return 1;
}
