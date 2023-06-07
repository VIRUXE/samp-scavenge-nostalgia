new AFKTime[MAX_PLAYERS];
new lastUpdateTime[MAX_PLAYERS]; // Set last update time for each player

#include <a_samp>
#include <foreach>

#define AFK_THRESHOLD 5 // Time threshold in seconds to consider a player AFK

forward OnPlayerAFK(playerid, bool:afk);

hook OnPlayerUpdate(playerid) {
    lastUpdateTime[playerid] = gettime();
}

hook OnPlayerDisconnect(playerid, reason) {
    if (AFKTime[playerid]) {
        AFKTime[playerid] = 0;

        CallLocalFunction("OnPlayerAFK", "ib", playerid, false);
    }
}

public OnPlayerAFK(playerid, bool:afk) {
	printf("[AFK] %p %s AFK", playerid, AFKTime[playerid] ? "ficou" : "saiu de");
}

ptask AFKCheck[SEC(1)](playerid) {
	if(!IsPlayerSpawned(playerid)) return;

	if(gettime() - lastUpdateTime[playerid] > AFK_THRESHOLD) {
		if (!AFKTime[playerid]) {
			AFKTime[playerid] = gettime();

			CallLocalFunction("OnPlayerAFK", "ib", playerid, true);
		}
	} else { // Updates normais
		if (AFKTime[playerid]) { // Estava AFK
			AFKTime[playerid] = 0;

			CallLocalFunction("OnPlayerAFK", "ib", playerid, false);
		}
	}
}

IsPlayerAFK(playerid) {
	if(IsPlayerConnected(playerid)) return -1
	
	return AFKTime[playerid];
}