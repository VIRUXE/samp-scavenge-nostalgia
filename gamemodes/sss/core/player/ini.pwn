
#include <YSI\y_hooks>

hook OnPlayerConnect(playerid)
{
    SetPlayerVip(playerid, false);
    
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
	    SetPlayerVip(playerid, dini_Bool(file, "VIP"));
	    SetPlayerClan(playerid, dini_Get(file, "Clan"));
		SetPlayerClanOwner(playerid, dini_Bool(file, "ClanOwner"));
    }
    else
	{
		SetPlayerCoins(playerid, 0);
		SetPlayerClan(playerid, "");
		SetPlayerClanOwner(playerid, false);
        dini_Create(file);
	}

	if(Iter_Count(Player) > 35 && !IsPlayerVip(playerid))
	{
		ChatMsg(playerid, RED, " ");
		ChatMsg(playerid, RED, " ");
		ChatMsg(playerid, RED, " ");
		ChatMsg(playerid, RED, "> Kickado por o servidor estar lotado com 35 online. VIPS possuem 5 slots reservados!");
		KickPlayer(playerid, "O servidor est� lotado com 35 online. VIPS possuem 5 slots reservados!");
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
		dini_BoolSet(file, "VIP", bool:IsPlayerVip(playerid));
		dini_Set(file, "Clan", GetPlayerClan(playerid));
		dini_BoolSet(file, "ClanOwner", bool:IsPlayerClanOwner(playerid));
	}
	
	return 1;
}

hook OnPlayerDisconnect(playerid)
{
	if(SavePlayerIniData(playerid))
	{
		SetPlayerClan(playerid, "");
		SetPlayerClanOwner(playerid, false);
		SetPlayerCoins(playerid, 0);
		SetPlayerVip(playerid, false);
	}

	return 1;
}
