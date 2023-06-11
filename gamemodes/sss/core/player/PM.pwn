#include <YSI\y_hooks>

static bool:PmBlock[MAX_PLAYERS] = {false, ...};

hook OnPlayerDisconnect(playerid) PmBlock[playerid] = false;

CMD:pm(playerid, params[]) {
	if(!IsPlayerSpawned(playerid)) return 2;

	new targetId, mensagem[300];
	
    if(sscanf(params, "rs[300]", targetId, mensagem)) return SendClientMessage(playerid, RED, "[PM]: Use /pm [id/nick] [mensagem]");

    if(targetId == INVALID_PLAYER_ID) return CMD_INVALID_PLAYER;

    if(targetId == playerid) return SendClientMessage(playerid, RED, "[PM]: Você não pode enviar uma mensagem para Você mesmo!");

    if(PmBlock[playerid]) return SendClientMessage(playerid, RED, "[PM]: Você não pode enviar uma mensagem pois usou /blockpm!");

    if(!IsPlayerLoggedIn(playerid)) return CMD_CANT_USE_ON;

    if(PmBlock[targetId]) return ChatMsg(playerid, RED, "[PM]: Você não pode enviar uma mensagem para %P"C_RED" pois ele está com o PM Bloqueado!", targetId);

    ChatMsg(playerid, RED, "[PM PARA %C%p (%d)"C_RED"]: {00AA00}%s", IsPlayerOnAdminDuty(targetId) ? GetAdminRankColour(GetPlayerAdminLevel(targetId)) : GetPlayerColor(targetId), targetId, targetId, mensagem);

    ChatMsg(targetId, 0x555555AA, "[PM DE %C%p (%d){555555}]: {00AA00}%s", IsPlayerOnAdminDuty(playerid) ? GetAdminRankColour(GetPlayerAdminLevel(playerid)) : GetPlayerColor(playerid), playerid, playerid, mensagem);
        
    GameTextForPlayer(targetId, "~G~~H~ MENSAGEM RECEBIDA!", 3000, 1);
    
    PlayerPlaySound(targetId,5205,0.0,0.0,0.0);
    PlayerPlaySound(playerid,5205,0.0,0.0,0.0);

    return 1;
}
	
CMD:blockpm(playerid) {
    PmBlock[playerid] = !PmBlock[playerid];
    
    return ChatMsg(playerid, RED, "[PM]: Mensagens privadas %sbloqueadas!", !PmBlock[playerid] ? "des" : "");
}
