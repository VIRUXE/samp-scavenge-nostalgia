#include <YSI\y_hooks>

static
bool:	frz_Frozen[MAX_PLAYERS],
Timer:	frz_DelayTimer[MAX_PLAYERS],
Timer:	frz_CheckTimer[MAX_PLAYERS];

hook OnPlayerConnect(playerid) {
	frz_Frozen[playerid] = false;

	return 1;
}

hook OnPlayerDisconnect(playerid, reason) {
	stop frz_DelayTimer[playerid];

	return 1;
}

FreezePlayer(playerid, duration = 0, msg = 0) {
	log("[FREEZE] %p (%d) foi congelado por %d segundos", playerid, playerid, duration);

	TogglePlayerControllable(playerid, false);
	if(msg) ShowActionText(playerid, "player/frozen", SEC(2));
	frz_Frozen[playerid] = true;

	if(duration > 0) {
		stop frz_DelayTimer[playerid];
		frz_DelayTimer[playerid] = defer UnfreezePlayer_delay(playerid, duration, msg);
	}

	// Verificar se tem s0beit
	if(duration > 4000 || duration == 0) {
		stop frz_CheckTimer[playerid];

		if(GetPlayerAnimationIndex(playerid) != 1130) // if not falling
			frz_CheckTimer[playerid] = defer UnfreezePlayer_check(playerid);
	}
}

UnfreezePlayer(playerid, msg = 0) {
	TogglePlayerControllable(playerid, true);
	frz_Frozen[playerid] = false;
	stop frz_DelayTimer[playerid];
	stop frz_CheckTimer[playerid];

	if(msg) ShowActionText(playerid, "player/unfrozen", SEC(1));
}

timer UnfreezePlayer_delay[time](playerid, time, msg) {
	#pragma unused time

	UnfreezePlayer(playerid, msg);
}

// * Creio que ja nao funciona nas versoes mais recentes do s0beit
timer UnfreezePlayer_check[SEC(4)](playerid) {
	if(GetPlayerAnimationIndex(playerid) == 1130) return; // Animação de queda
		
	new Float:z;

	GetPlayerCameraFrontVector(playerid, z, z, z);

	if(-0.994 >= z >= -0.997 || 0.9958 >= z >= 0.9946) ChatMsgAdmins(2, YELLOW, " >  Possível usuário de sobeit: "C_ORANGE"%p (%d)", playerid, playerid);

	return;
}

stock IsPlayerFrozen(playerid) {
	if(!IsPlayerConnected(playerid)) return 0;

	return frz_Frozen[playerid];
}