#include <YSI\y_hooks>

hook OnGameModeInit() {
	RegisterAdminCommand(STAFF_LEVEL_MODERATOR, "duty", "Entrar em modo admin");
    RegisterAdminCommand(STAFF_LEVEL_MODERATOR, "banidos", "Lista de banidos do servidor");
    RegisterAdminCommand(STAFF_LEVEL_MODERATOR, "field", "Detection Fields");
    RegisterAdminCommand(STAFF_LEVEL_MODERATOR, "ir/puxar", "Teleportar players");
    RegisterAdminCommand(STAFF_LEVEL_MODERATOR, "verban", "Checar se está banido");
}

//static bool:visible[MAX_PLAYERS];

/*
hook OnPlayerConnect(playerid) {
    visible[playerid] = true;
}
*/


ACMD:duty[2](playerid, params[]) {
	static dutyTick[MAX_PLAYERS];

	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING) return ChatMsg(playerid, YELLOW, " >  Você deve sair do /spec.");
	
	if(GetTickCountDifference(GetTickCount(), dutyTick[playerid]) < SEC(5)) return ChatMsg(playerid, YELLOW, " >  Aguarde no minimo 5 segundos para utilizar esse comando novamente.");
	
	new lastattacker, lastweapon;
		
	if(IsPlayerCombatLogging(playerid, lastattacker, lastweapon)) return ChatMsg(playerid, RED, " >  Você está em combate, aguarde.");

	TogglePlayerAdminDuty(playerid, !IsPlayerOnAdminDuty(playerid), !isequal(params, "aqui", true));

    dutyTick[playerid] = GetTickCount();
    
	return 1;
}

ACMD:ir[2](playerid, params[]) {
	if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET) return 6;

	new targetId;

	if(sscanf(params, "r", targetId)) return ChatMsg(playerid, YELLOW, " >  Use: /ir [playerid]");

	if(!IsPlayerConnected(targetId)) return CMD_INVALID_PLAYER;

	if(GetPlayerState(targetId) == PLAYER_STATE_SPECTATING) return CMD_CANT_USE_ON;

	TeleportPlayerToPlayer(playerid, targetId);

	FreezePlayer(targetId, SEC(2));

	ChatMsg(targetId, YELLOW, "admin/teleported-to", playerid);
	ChatMsgAdmins(1, BLUE, "[Admin] %P"C_BLUE" (%d) teleportou-se até %P"C_BLUE" (%d)", playerid, playerid, targetId, targetId);

	return 1;
}

ACMD:puxar[2](playerid, params[]) {
	if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET) return 6;

	new targetId;

	if(sscanf(params, "r", targetId)) return ChatMsg(playerid, YELLOW, " >  Use: /puxar [playerid]");

	if(!IsPlayerConnected(targetId)) return CMD_INVALID_PLAYER;

	if(IsPlayerInTutorial(targetId)) return CMD_CANT_USE_ON;

	if(GetPlayerState(targetId) == PLAYER_STATE_SPECTATING) return CMD_CANT_USE_ON;

	TeleportPlayerToPlayer(targetId, playerid);

	ChatMsgAdmins(1, BLUE, "[Admin] %P"C_BLUE" (%d) puxou %P"C_BLUE" (%d)", playerid, playerid, targetId, targetId);

	return 1;
}

ACMD:congelar[2](playerid, params[]) {
	new targetid, delay;

	if(sscanf(params, "dD(0)", targetid, delay)) return ChatMsg(playerid, YELLOW, " >  Use: /congelar [playerid] [segundos]");

	if(GetPlayerAdminLevel(targetid) >= GetPlayerAdminLevel(playerid) && playerid != targetid) return 3;

	if(!IsPlayerConnected(targetid)) return 4;

	FreezePlayer(targetid, delay * 1000, true);
	
	if(delay > 0) {
		ChatMsg(playerid, YELLOW, " >  Você congelou %P"C_YELLOW" por %d segundos", targetid, delay);
		ChatMsg(targetid, YELLOW, "FREEZETIMER", delay);
	} else {
		ChatMsg(playerid, YELLOW, " >  Você congelou %P", targetid);
		ChatMsg(targetid, YELLOW, "FREEZEFROZE");
	}

	return 1;
}

ACMD:descongelar[2](playerid, params[]) {
	new targetid;

	if(sscanf(params, "d", targetid)) return ChatMsg(playerid, YELLOW, " >  Use: /descongelar [playerid]");

	if(!IsPlayerConnected(targetid)) return 4;

	UnfreezePlayer(targetid);

	ChatMsg(playerid, YELLOW, " >  Você descongelou %P", targetid);
	ChatMsg(targetid, YELLOW, "FREEZEUNFRE");

	return 1;
}

ACMD:verban[2](playerid, params[]) {
	if(!(3 < strlen(params) < MAX_PLAYER_NAME)) return ChatMsg(playerid, RED, " >  Nome de player inválido: '%s'.", params);

	new name[MAX_PLAYER_NAME];

	strcat(name, params);

	if(IsPlayerBanned(name))
		ShowBanInfo(playerid, name);
	else
		ChatMsg(playerid, YELLOW, " >  O jogador '%s' "C_BLUE"não está "C_YELLOW"banido.", name);

	return 1;
}

/*
ACMD:invisible[2](playerid, params[]) {
	if(!IsPlayerOnAdminDuty(playerid))
	{
		ChatMsg(playerid, YELLOW, " >  Você deve estar em /duty para usar esse comando.");
	    return 1;
	}
	
	foreach(new i : Player)
	{
	    if(!IsPlayerNPC(i) && !IsPlayerOnAdminDuty(i) && i != playerid)
		{
	        if(visible[playerid] == false)
			{
			    ShowPlayerForPlayer(playerid, i);
			}
			else
			{
			    RemovePlayerForPlayer(playerid, i);
			}
		}
	}
	
	
	if(visible[playerid] == false)
	{
	    if(GetPlayerGender(playerid) == GENDER_MALE)
			SetPlayerSkin(playerid, 217);

		else
			SetPlayerSkin(playerid, 211);
			
	    ChatMsg(playerid, YELLOW, " >  Modo invisível desativado.");
	    visible[playerid] = true;
	}
	else
	{
	    if(GetPlayerGender(playerid) == GENDER_MALE)
			SetPlayerSkin(playerid, 45);

		else
			SetPlayerSkin(playerid, 251);
			
	    ChatMsg(playerid, YELLOW, " >  Modo invisível ativado.");
	    visible[playerid] = false;
	}
	
	return 1;
}

hook OnPlayerStreamIn(playerid, forplayerid) {
    if(GetTickCountDifference(GetTickCount(), GetPlayerServerJoinTick(playerid)) > 10000)
	{
	    if(GetTickCountDifference(GetTickCount(), GetPlayerServerJoinTick(forplayerid)) > 10000)
		{
			if(visible[playerid] == false)
			{
			    if(!IsPlayerNPC(forplayerid) && !IsPlayerNPC(playerid) && !IsPlayerOnAdminDuty(forplayerid))
			    	RemovePlayerForPlayer(playerid, forplayerid);
			}
			if(visible[forplayerid] == false)
			{
			    if(!IsPlayerNPC(playerid) && !IsPlayerNPC(forplayerid) && !IsPlayerOnAdminDuty(playerid))
			    	RemovePlayerForPlayer(forplayerid, playerid);
			}
		}
	}
}

ShowPlayerForPlayer(playerid, toplayerid) {
    new BitStream:bs = BS_New();

    BS_WriteValue(
        bs,
        PR_UINT16, playerid
    );

    BS_RPC(bs, toplayerid, 32, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
    BS_Delete(bs);
    return 1;
}

RemovePlayerForPlayer(playerid, toplayerid) {
    new BitStream:bs = BS_New();

    BS_WriteValue(
        bs,
        PR_UINT16, playerid
    );

    BS_RPC(bs, toplayerid, 163, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
    BS_Delete(bs);
    return 1;
}
*/