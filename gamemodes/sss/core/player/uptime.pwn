/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/


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

ptask UptimeUpdate[60000](playerid)
{
	if(!IsPlayerSpawned(playerid))
	    return;
	    
    if(IsPlayerOnAdminDuty(playerid))
        return;
        
	if(IsPlayerUnfocused(playerid))
	    return;
	    
	if(IsPlayerDead(playerid))
	    return;
	    
    p_OnlineTime[playerid] ++;
    
    if(p_OnlineTime[playerid] == 30)
    {
        PlayerPlaySound(playerid, 1056, 0.0, 0.0, 0.0);
	    ChatMsg(playerid, BLUE, "[Uptime]: Fique online mais 30 minutos e ganhe um prêmio.");
	}
	if(p_OnlineTime[playerid] == 40)
    {
        PlayerPlaySound(playerid, 1056, 0.0, 0.0, 0.0);
	    ChatMsg(playerid, BLUE, "[Uptime]: Fique online mais 20 minutos e ganhe um prêmio.");
	}
	if(p_OnlineTime[playerid] == 50)
    {
        PlayerPlaySound(playerid, 1056, 0.0, 0.0, 0.0);
	    ChatMsg(playerid, BLUE, "[Uptime]: Fique online mais 10 minutos e ganhe um prêmio.");
	}
	if(p_OnlineTime[playerid] == 55)
    {
        PlayerPlaySound(playerid, 1056, 0.0, 0.0, 0.0);
	    ChatMsg(playerid, BLUE, "[Uptime]: Fique online mais 5 minutos e ganhe um prêmio.");
	}
	if(p_OnlineTime[playerid] == 60)
    {
        new randomPrime = random(3);
        
        if(randomPrime == 0)
        {
	        SetPlayerScore(playerid, GetPlayerScore(playerid) + 3);
	        ChatMsg(playerid, BLUE, "[Uptime]: Parabéns, você ganhou + 3 score por ficar 1 hora em nosso servidor.");
        }
        if(randomPrime == 1)
        {
	        SetPlayerScore(playerid, GetPlayerScore(playerid) + 2);
	        ChatMsg(playerid, BLUE, "[Uptime]: Parabéns, você ganhou + 2 score por ficar 1 hora em nosso servidor.");
        }
        if(randomPrime == 2)
        {
	        SetPlayerScore(playerid, GetPlayerScore(playerid) + 1);
	        ChatMsg(playerid, BLUE, "[Uptime]: Parabéns, você ganhou + 1 score por ficar 1 hora em nosso servidor.");
        }
        
        PlayerPlaySound(playerid, 1056, 0.0, 0.0, 0.0);
        p_OnlineTime[playerid] = 0;
	}
}

