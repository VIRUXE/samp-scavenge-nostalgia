#include 	<a_samp>

#define		FILTERSCRIPT

#include 	<Pawn.RakNet>

#define     MAX_PED_SLOTS_USED  (10)

new
	psu_Timer[MAX_PLAYERS],
	psu_View[MAX_PED_SLOTS_USED][MAX_PLAYERS];

public OnFilterScriptInit()
{
	for(new i = 0; i < MAX_PLAYERS; ++i)
		if(IsPlayerConnected(i))
			OnPlayerSpawn(i);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	KillTimer(psu_Timer[playerid]);
	psu_Timer[playerid] = SetTimerEx("UpdatePlayerPSU", 500, true, "i", playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    KillTimer(psu_Timer[playerid]);
	return 1;
}

forward UpdatePlayerPSU(playerid);
public UpdatePlayerPSU(playerid)
{
    if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING ||
		GetPlayerSkin(playerid) == 217 ||
		GetPlayerSkin(playerid) == 211 ||
		GetPlayerSkin(playerid) == 0)
        return 1;
        
    for(new i = 0; i < MAX_PED_SLOTS_USED; i++)
    {
        if(!IsPlayerConnected(i))
            continue;
            
        if(!IsPlayerStreamedIn(i, playerid))
        {
            new BitStream:bs = BS_New();
            
			if(random(2) == 1 && psu_View[i][playerid])
			{
			    BS_WriteValue(bs, PR_UINT16, i);
			    PR_SendRPC(bs, playerid, 163); // WorldPlayerRemove
				psu_View[i][playerid] = false; 
			}
			else if(!psu_View[i][playerid])
			{
			    BS_WriteValue(bs,
					PR_UINT16, i,
			        PR_UINT8, GetPlayerTeam(i),
			        PR_UINT32, GetPlayerSkin(i),
			        PR_FLOAT, 0.0,
			        PR_FLOAT, 0.0,
			        PR_FLOAT, 0.0,
			        PR_FLOAT, 0.0,
			        PR_UINT32, GetPlayerColor(i),
			        PR_UINT8, GetPlayerFightingStyle(i)
			    ); // WorldPlayerAdd
			    
			    PR_SendRPC(bs, playerid, 32);
				psu_View[i][playerid] = true;
			}
			
			BS_Delete(bs);
		}
	}
	return 1;
}
