#include <YSI\y_hooks>

new p_OnlineTime[MAX_PLAYERS];

hook OnPlayerConnect(playerid)
{
    new namep[24];
	GetPlayerName(playerid, namep, 24);
	p_OnlineTime[playerid] = dini_Int("uptime.ini", namep);
}

hook OnPlayerDisconnect(playerid, reason)
{
    new namep[24];
	GetPlayerName(playerid, namep, 24);
    dini_IntSet("uptime.ini", namep, p_OnlineTime[playerid]);
}

ptask UptimeUpdate[MIN(1)](playerid)
{
	if(!IsPlayerSpawned(playerid)) return;
	    
    if(IsPlayerOnAdminDuty(playerid)) return;
        
	if(IsPlayerUnfocused(playerid)) return;
	    
	if(IsPlayerDead(playerid)) return;
	    
    p_OnlineTime[playerid] ++;
    
    if(p_OnlineTime[playerid] == 30)
    {
        PlayerPlaySound(playerid, 1056, 0.0, 0.0, 0.0);
	    ChatMsg(playerid, BLUE, "[Uptime]: Fique online mais 30 minutos e ganhe um pr�mio.");
	}
	if(p_OnlineTime[playerid] == 40)
    {
        PlayerPlaySound(playerid, 1056, 0.0, 0.0, 0.0);
	    ChatMsg(playerid, BLUE, "[Uptime]: Fique online mais 20 minutos e ganhe um pr�mio.");
	}
	if(p_OnlineTime[playerid] == 50)
    {
        PlayerPlaySound(playerid, 1056, 0.0, 0.0, 0.0);
	    ChatMsg(playerid, BLUE, "[Uptime]: Fique online mais 10 minutos e ganhe um pr�mio.");
	}
	if(p_OnlineTime[playerid] == 55)
    {
        PlayerPlaySound(playerid, 1056, 0.0, 0.0, 0.0);
	    ChatMsg(playerid, BLUE, "[Uptime]: Fique online mais 5 minutos e ganhe um pr�mio.");
	}
	if(p_OnlineTime[playerid] == 60)
    {
        new randomPrime = random(3);
        
        if(randomPrime == 0)
        {
	        SetPlayerScore(playerid, GetPlayerScore(playerid) + 3);
	        ChatMsg(playerid, BLUE, "[Uptime]: Parab�ns, voc� ganhou + 3 score por ficar 1 hora em nosso servidor.");
        }
        if(randomPrime == 1)
        {
	        SetPlayerScore(playerid, GetPlayerScore(playerid) + 2);
	        ChatMsg(playerid, BLUE, "[Uptime]: Parab�ns, voc� ganhou + 2 score por ficar 1 hora em nosso servidor.");
        }
        if(randomPrime == 2)
        {
	        SetPlayerScore(playerid, GetPlayerScore(playerid) + 1);
	        ChatMsg(playerid, BLUE, "[Uptime]: Parab�ns, voc� ganhou + 1 score por ficar 1 hora em nosso servidor.");
        }
        
        PlayerPlaySound(playerid, 1056, 0.0, 0.0, 0.0);
        p_OnlineTime[playerid] = 0;
	}
}