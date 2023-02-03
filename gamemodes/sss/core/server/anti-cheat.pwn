#include <YSI\y_hooks>

static
	player_AntiCheat[MAX_PLAYERS] = 0;

hook OnPlayerConnect(playerid)
{
    new ip[16], nick[MAX_PLAYER_NAME], string[106];

	GetPlayerIp(playerid, ip, sizeof ip);
	GetPlayerName(playerid, nick, MAX_PLAYER_NAME);

	format(string, sizeof string, "vulpecula.flaviopereira.digital/nostalgia/anticheat.php?ip=%s&nick=%s", ip, nick);

	HTTP(playerid, HTTP_GET, string, "", "MyHttpResponse");
}

forward MyHttpResponse(playerid, response_code, data[]);
public MyHttpResponse(playerid, response_code, data[])
{
	new ip[16];
	GetPlayerIp(playerid, ip, sizeof ip);
	if(strcmp(ip, "127.0.0.1", true) == 0)
	{
        return 1;
	}
	if(response_code == 202)
	{
		player_AntiCheat[playerid] = 1;
	} else
	if(response_code == 403 || response_code == 404)
	{
		if(GetAdminsOnline() == 0)
		{
	    	AC_KickPlayer(playerid, "AntiCheat não iniciado");
		}
		else ChatMsgAdmins(1, YELLOW, "[Anti-Cheat] %P (id:%d) Está sem anti-cheat aberto!", playerid, playerid);
		
		player_AntiCheat[playerid] = 2;
	} else
	{
		if(GetAdminsOnline() == 0)
		{
			AC_KickPlayer(playerid, "AntiCheat não iniciado");
		}
		else ChatMsgAdmins(1, YELLOW, "[Anti-Cheat] %P (id:%d) Está sem anti-cheat aberto!", playerid, playerid);

		player_AntiCheat[playerid] = 2;
	}

	return 1;
}

stock PlayerAntiCheat(playerid)
	return player_AntiCheat[playerid];

stock IsPlayerAntiCheatOpen(playerid)
{
	if(!IsPlayerConnected(playerid))
		return false;

	if (player_AntiCheat[playerid] == 2 || player_AntiCheat[playerid] == 0)
		return false;

	return true;
}