#include <YSI\y_hooks>

#define PING_CHECK_INTERVAL 1000

static PING_LIMIT;
static const MAX_STRIKES = 10;

static limitStrikes[MAX_PLAYERS];

static ptask CheckPing[PING_CHECK_INTERVAL](playerid) {
    if(!PING_LIMIT) return;
    if(IsPlayerOnAdminDuty(playerid)) {
        if(limitStrikes[playerid]) limitStrikes[playerid] = 0;
        return;
    }

    new ping = GetPlayerPing(playerid);

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