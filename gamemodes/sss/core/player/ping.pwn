#include <YSI\y_hooks>

static PING_LIMIT;
static const MAX_STRIKES = 10;

static 
    cachedPing[MAX_PLAYERS],
    limitStrikes[MAX_PLAYERS];

GetPlayerCachedPing(playerid) {
    if(!IsPlayerConnected(playerid)) return 0;

    return cachedPing[playerid];
}

static ptask CheckPing[SEC(1)](playerid) {
    if(!PING_LIMIT) return;

    if(IsPlayerOnAdminDuty(playerid)) {
        if(limitStrikes[playerid]) limitStrikes[playerid] = 0;
        return;
    }

    new ping = GetPlayerPing(playerid);

    cachedPing[playerid] = ping;

    // Check if the ping exceeds the limit
    if (ping > PING_LIMIT) {
        limitStrikes[playerid]++;

        if (limitStrikes[playerid] >= MAX_STRIKES) TimeoutPlayer(playerid, sprintf("%s: %d/%d.", ls(playerid, "player/ping"), ping, PING_LIMIT), MIN(1));
    } else
        limitStrikes[playerid] = 0;
}

hook OnGameModeInit() {
    new Node:node;

	JSON_GetObject(Settings, "player", node);
	JSON_GetInt(node, "ping-limit", PING_LIMIT);

	log("[SETTINGS][PING] Limite: %d", PING_LIMIT);
}

hook OnPlayerDisconnect(playerid) {
    if(limitStrikes[playerid]) limitStrikes[playerid] = 0;
}

ACMD:setpinglimit[5](playerid, params[])
{
	new limit = strval(params);

	if(!(100 < limit < 1000)) return ChatMsg(playerid, YELLOW, " >  O limite tem que ser entre 100 e 1000");

	PING_LIMIT = limit;

	return ChatMsg(playerid, GREEN, " >  Limite definido para %d.", PING_LIMIT);
}