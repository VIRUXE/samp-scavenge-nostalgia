
#include <YSI\y_hooks>

// TODO: Passar essa merda para o banco de dados

hook OnPlayerConnect(playerid)
{
	new
		name[MAX_PLAYER_NAME],
		file[16 + MAX_PLAYER_NAME];

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	format(file, sizeof(file), "INI_Data/%s.ini", name);
    
	if(dini_Exists(file))
	{
	    SetPlayerScore(playerid, dini_Int(file, "Score"));
	    SetPlayerDeathCount(playerid, dini_Int(file, "Mortes"));
	    SetPlayerSpree(playerid, dini_Int(file, "Spree"));
	    SetPlayerAliveTime(playerid, dini_Int(file, "AliveTime"));
	    SetPlayerCoins(playerid, dini_Int(file, "Coins"));
    }
    else
	{
		SetPlayerCoins(playerid, 0);
        dini_Create(file);
	}
}

stock SavePlayerIniData(playerid)
{
	new
		name[MAX_PLAYER_NAME],
		file[16 + MAX_PLAYER_NAME];

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	format(file, sizeof(file), "INI_Data/%s.ini", name);

    if(dini_Exists(file))
	{
		dini_IntSet(file, "Score", GetPlayerScore(playerid));
		dini_IntSet(file, "Mortes", GetPlayerDeathCount(playerid));
		dini_IntSet(file, "Spree", GetPlayerSpree(playerid));
		dini_IntSet(file, "AliveTime", GetPlayerAliveTime(playerid));
		dini_IntSet(file, "Coins", GetPlayerCoins(playerid));
	}
	
	return 1;
}

hook OnPlayerDisconnect(playerid)
{
	if(SavePlayerIniData(playerid)) SetPlayerCoins(playerid, 0);

	return 1;
}
