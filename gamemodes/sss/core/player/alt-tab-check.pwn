#include <YSI\y_hooks>

static
		tab_Check[MAX_PLAYERS],
bool:	tab_IsTabbed[MAX_PLAYERS],
		tab_TabOutTick[MAX_PLAYERS],
		maxUnfocusedTime;

forward OnPlayerFocusChange(playerid, status);

hook OnPlayerUpdate(playerid) {
	tab_Check[playerid] = 0;
	return 1;
}

hook OnSettingsLoaded() {
	new Node:node;

	JSON_GetObject(Settings, "player", node);

	JSON_GetInt(node, "max-tab-out-time", maxUnfocusedTime);
	log("[SETTINGS] Tempo maximo de tab-out: %d segundos", maxUnfocusedTime);
}

ptask AfkCheckUpdate[100](playerid) {
	if(
		!IsPlayerSpawned(playerid) ||
 		GetTickCountDifference(GetTickCount(), GetPlayerServerJoinTick(playerid)) < 10000
	) return;

	new
		comparison = 500,
		Float:x, Float:y, Float:z,
		playerstate;

	playerstate = GetPlayerState(playerid);

	if(playerstate <= 1)
		GetPlayerVelocity(playerid, z, y, z);
	else if(playerstate <= 3)
		GetVehicleVelocity(GetPlayerVehicleID(playerid), x, y, z);

	if(GetTickCountDifference(GetTickCount(), GetPlayerVehicleExitTick(playerid)) < 2000)
		comparison = 3000;
	else if((x == 0.0 && y == 0.0 && z == 0.0))
		comparison = 2500;

	comparison += GetPlayerPing(playerid);

	// ShowActionText(playerid, sprintf("%d :: %s%d - %d", playerstate, (tab_Check[playerid] > comparison) ? ("~r~") : ("~w~"), tab_Check[playerid], comparison), 0);

	if(tab_Check[playerid] > comparison) {
		if(!tab_IsTabbed[playerid]) {
			CallLocalFunction("OnPlayerFocusChange", "dd", playerid, 0);

			log("[FOCUS] %p unfocused game", playerid);

			tab_TabOutTick[playerid] = GetTickCount();
			tab_IsTabbed[playerid]   = true;
		}

		if(!IsPlayerOnAdminDuty(playerid)) {
			if(GetTickCountDifference(GetTickCount(), tab_TabOutTick[playerid]) > maxUnfocusedTime * 1000) {
			    GetPlayerPos(playerid, x, y, z);

	   			foreach(new i : Player)
				    if(GetPlayerDistanceFromPoint(i, x, y, z) < 30.0 && IsPlayerOnAdminDuty(i)) return;
				
				new lastattacker, lastweapon;

				if(IsPlayerCombatLogging(playerid, lastattacker, lastweapon))
					KickPlayer(playerid, sprintf("Ficou ausente (ESC) por %d segundos.", maxUnfocusedTime));
				
				return;
			}
		}
	}

	if(!tab_Check[playerid]) {
		if(tab_IsTabbed[playerid]) {
			CallLocalFunction("OnPlayerFocusChange", "dd", playerid, 1);

			log("[FOCUS] %p focused back to game", playerid);

			tab_IsTabbed[playerid] = false;
		}
	}

	tab_Check[playerid] += 100;

	return;
}

stock IsPlayerUnfocused(playerid) return tab_IsTabbed[playerid];