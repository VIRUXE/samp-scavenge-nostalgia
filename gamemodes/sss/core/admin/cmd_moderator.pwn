#include <YSI\y_hooks>

hook OnGameModeInit() {
	RegisterAdminCommand(LEVEL_MODERATOR, "duty", "Entrar em modo admin");
	RegisterAdminCommand(LEVEL_MODERATOR, "banidos", "Lista de banidos do servidor");
	RegisterAdminCommand(LEVEL_MODERATOR, "field", "Detection Fields");
	RegisterAdminCommand(LEVEL_MODERATOR, "ir/puxar", "Teleportar players");
	RegisterAdminCommand(LEVEL_MODERATOR, "verban", "Checar se está banido");
	RegisterAdminCommand(LEVEL_MODERATOR, "(des)calar", "(Des)calar um jogador");
	RegisterAdminCommand(LEVEL_MODERATOR, "avisar", "Dar aviso em um jogador");
	RegisterAdminCommand(LEVEL_MODERATOR, "kick", "Kickar jogadores");
	RegisterAdminCommand(LEVEL_MODERATOR, "msg", "Enviar um Anúncio no Chat");
	RegisterAdminCommand(LEVEL_MODERATOR, "cc", "Limpar o Chat");
	RegisterAdminCommand(LEVEL_MODERATOR, "rr", "Responder a um Relatório");
	RegisterAdminCommand(LEVEL_MODERATOR, "blockrr", "Bloquear alguém de enviar relatórios");
	RegisterAdminCommand(LEVEL_MODERATOR, "tapa", "Dar tapa em algum player");
}

ACMD:duty[1](playerid, params[]) {
	static dutyTick[MAX_PLAYERS];

	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING) return ChatMsg(playerid, YELLOW, " >  Você deve sair do /spec.");
	
	if(GetTickCountDifference(GetTickCount(), dutyTick[playerid]) < SEC(5)) return ChatMsg(playerid, YELLOW, " >  Aguarde no minimo 5 segundos para utilizar esse comando novamente.");
	
	new lastattacker, lastweapon;
		
	if(IsPlayerCombatLogging(playerid, lastattacker, lastweapon)) return ChatMsg(playerid, RED, " >  Você está em combate, aguarde.");

	TogglePlayerAdminDuty(playerid, !IsPlayerOnAdminDuty(playerid), !isequal(params, "aqui", true));

    dutyTick[playerid] = GetTickCount();
    
	return 1;
}

ACMD:ir[1](playerid, params[]) {
	if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < LEVEL_SECRET) return 6;

	new targetId;

	if(sscanf(params, "r", targetId)) return ChatMsg(playerid, YELLOW, " >  Use: /ir [id/nome]");

	if(!IsPlayerConnected(targetId)) return CMD_INVALID_PLAYER;

	if(GetPlayerState(targetId) == PLAYER_STATE_SPECTATING) return CMD_CANT_USE_ON;

	TeleportPlayerToPlayer(playerid, targetId);

	FreezePlayer(targetId, SEC(2));

	if(!GetPlayerAdminLevel(targetId)) ChatMsg(targetId, YELLOW, "admin/teleported-to", playerid);
	ChatMsgAdmins(LEVEL_MODERATOR, COLOR_NONE, "%P"C_WHITE" (%d) teleportou-se até %P"C_WHITE" (%d)", playerid, playerid, targetId, targetId);

	return 1;
}

ACMD:puxar[1](playerid, params[]) {
	if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < LEVEL_SECRET) return 6;

	new targetId;

	if(sscanf(params, "r", targetId)) return ChatMsg(playerid, YELLOW, " >  Use: /puxar [id/nome]");

	if(!IsPlayerConnected(targetId)) return CMD_INVALID_PLAYER;

	if(IsPlayerInTutorial(targetId)) return CMD_CANT_USE_ON;

	if(GetPlayerState(targetId) == PLAYER_STATE_SPECTATING) return CMD_CANT_USE_ON;

	TeleportPlayerToPlayer(targetId, playerid);

	ChatMsgAdmins(LEVEL_MODERATOR, COLOR_NONE, "%P"C_WHITE" (%d) puxou %P"C_WHITE" (%d)", playerid, playerid, targetId, targetId);

	return 1;
}

ACMD:congelar[1](playerid, params[]) {
	new targetid, delay;

	if(sscanf(params, "dD(0)", targetid, delay)) return ChatMsg(playerid, YELLOW, " >  Use: /congelar [id/nome] [segundos]");

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

ACMD:descongelar[1](playerid, params[]) {
	new targetid;

	if(sscanf(params, "d", targetid)) return ChatMsg(playerid, YELLOW, " >  Use: /descongelar [id/nome]");

	if(!IsPlayerConnected(targetid)) return 4;

	UnfreezePlayer(targetid);

	ChatMsg(playerid, YELLOW, " >  Você descongelou %P", targetid);
	ChatMsg(targetid, YELLOW, "FREEZEUNFRE");

	return 1;
}

ACMD:verban[1](playerid, params[]) {
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
ACMD:invisible[1](playerid, params[]) {
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

ACMD:tapa[1](playerid, params[]) {
	new admin = GetPlayerAdminLevel(playerid);

    if(admin < LEVEL_LEAD && admin > LEVEL_MODERATOR && !IsPlayerOnAdminDuty(playerid)) return CMD_NOT_DUTY;
		
    new targetId;
	
	if(sscanf(params, "r", targetId)) return SendClientMessage(playerid, YELLOW, " > Use: /tapa [id/nick]");

	if(targetId != playerid && GetPlayerAdminLevel(targetId) > GetPlayerAdminLevel(playerid)) return CMD_CANT_USE_ON;

	new Float:x, Float:y, Float:z;
	GetPlayerPos(targetId, x, y, z);
	SetPlayerPos(targetId, x, y, z + 6.0);

	return ChatMsgAdmins(LEVEL_MODERATOR, WHITE, "%P"C_WHITE" (%d) deu um tapa em %P"C_WHITE" (%d)", playerid, playerid, targetId, targetId);
}

ACMD:calar[1](playerid, params[]) {
	new targetId, delay, reason[128];

	if(sscanf(params, "rds[128]", targetId, delay, reason)) return ChatMsg(playerid,YELLOW," >  Use: /calar [id/nome] [segundos] [motivo] - use -1 nos segundos para calar permanentemente.");

	if(!IsPlayerConnected(targetId)) return ChatMsg(playerid,RED, " >  Esse player não está conectado.");

	if(GetPlayerAdminLevel(targetId) >= GetPlayerAdminLevel(playerid)) return CMD_CANT_USE_ON;

	if(IsPlayerMuted(targetId)) return ChatMsg(playerid, YELLOW, " >  Esse player já está calado.");

	if(delay) {
		TogglePlayerMute(targetId, true, delay);
		ChatMsg(playerid, YELLOW, " >  Calou o player %P "C_WHITE"por %d segundos.", targetId, delay);
		ChatMsg(targetId, YELLOW, "player/muted-time", delay, reason);
	} else {
		TogglePlayerMute(targetId, true);
		ChatMsg(playerid, YELLOW, " > Player calado: %P", targetId);
		ChatMsg(targetId, YELLOW, "player/muted-reas", reason);
	}

	return ChatMsgAdmins(LEVEL_MODERATOR, WHITE, "%P"C_WHITE" (%d) calou %P"C_WHITE" (%d)! "C_WHITE"Segundos: %d", playerid, playerid, targetId, targetId, delay);
}

ACMD:descalar[1](playerid, params[]) {
	new targetId;

	if(sscanf(params, "r", targetId)) return ChatMsg(playerid, YELLOW, " >  Use: /descalar [id/nick]");

	if(GetPlayerAdminLevel(targetId) >= GetPlayerAdminLevel(playerid) && playerid != targetId) return CMD_CANT_USE_ON;

	if(!IsPlayerConnected(targetId)) return CMD_INVALID_PLAYER;

	TogglePlayerMute(targetId, false);

	ChatMsg(playerid, YELLOW, " >  Descalado: %P", targetId);
	ChatMsg(targetId, YELLOW, "player/unmuted");

	return 1;
}

ACMD:avisar[1](playerid, params[]) {
	new targetId, reason[128];

	if(sscanf(params, "rs[128]", targetId, reason)) return ChatMsg(playerid, YELLOW, " >  Use: /avisar [id/nick] [motivo]");

	if(!IsPlayerConnected(targetId)) return ChatMsg(playerid,RED, " >  Esse player não está conectado");

	if(GetPlayerAdminLevel(targetId) >= GetPlayerAdminLevel(playerid) && playerid != targetId) return CMD_CANT_USE_ON;

	new warnings = GetPlayerWarnings(targetId) + 1;

	SetPlayerWarnings(targetId, warnings);
	
	ChatMsg(targetId, ORANGE, "WARNEDMESSG", warnings, reason);

	if(warnings >= 3) {
	    SetPlayerWarnings(targetId, 0);
		KickPlayer(targetId, "Atingiu 3 avisos.");
	}

	return ChatMsgAdmins(LEVEL_MODERATOR, WHITE, "%P"C_WHITE" (%d) avisou %P"C_WHITE" (%d)! "C_WHITE"Motivo: %s", playerid, playerid, targetId, targetId, reason);
}

ACMD:kick[1](playerid, params[]) {
	new targetId, reason[64];

	if(sscanf(params, "rs[64]", targetId, reason)) return ChatMsg(playerid, YELLOW, " >  Use: /kick [id/nick] [motivo]");

	if(playerid == targetId) return ChatMsg(playerid, PINK, " >  %P"C_PINK" Você não pode kickar a si mesmo", playerid);

	if(!IsPlayerConnected(targetId)) return CMD_INVALID_PLAYER;

	if(GetPlayerAdminLevel(targetId) >= GetPlayerAdminLevel(playerid) && playerid != targetId) return CMD_CANT_USE_ON;

	KickPlayer(targetId, reason, true);

	return ChatMsgAdmins(LEVEL_MODERATOR, WHITE, "%P"C_WHITE" (%d) kickou %P"C_WHITE" (%d)! "C_WHITE"Motivo: %s", playerid, playerid, targetId, targetId, reason);
}

ACMD:msg[1](playerid, params[]) {
	new anuncio[255];

	if(sscanf(params, "s[255]", anuncio)) return ChatMsg(playerid, RED, " > Use: /msg [mensagem]");

	anuncio[0] = toupper(anuncio[0]); // Capitalize the first letter

	SendClientMessageToAll(COLOR_RADIATION, " >>>>> Administração: <<<<<");
	return ChatMsgAll(COLOR_RADIATION, " > %p disse: {FFFFFF}%s", playerid, anuncio);
}

ACMD:cc[1](playerid) {
	for(new i;i<100;i++) ChatMsgAll(WHITE, " ");

	return ChatMsgAdmins(LEVEL_MODERATOR, WHITE, "%P{C457EB} (%d) limpou o chat!", playerid, playerid);
}

ACMD:history[1](playerid, params[]) {
	new
		name[MAX_PLAYER_NAME],
		type,
		lookup;

	if(sscanf(params, "s[24]C(a)C()", name, type, lookup)) return ChatMsg(playerid, YELLOW, " >  Use: /history [playerid/name] [i/h] [n]");

	if(isnumeric(name)) {
		new targetId = strval(name);

		if(IsPlayerConnected(targetId))
			GetPlayerName(targetId, name, MAX_PLAYER_NAME);
		else if(targetId > 99)
			ChatMsg(playerid, YELLOW, " >  O ID '%d' não está online, tente usar o nome do jogador.", targetId);
		else
			return CMD_INVALID_PLAYER;
	}

	if(!AccountExists(name)) return ChatMsg(playerid, YELLOW, " >  A conta '%s' não existe.", name);

	if(GetAdminLevelByName(name) > GetPlayerAdminLevel(playerid)) {
		new playername[MAX_PLAYER_NAME];
		GetPlayerName(playerid, playername, MAX_PLAYER_NAME);

		if(strcmp(name, playername)) return ChatMsg(playerid, YELLOW, " >  Sem aliases encontradas para %s", name);
	}

	if(type == 'i') {
		if(lookup == 'n') 
			ShowAccountIPHistoryFromName(playerid, name);
		else {
			new ip;
			GetAccountIP(name, ip);
			ShowAccountIPHistoryFromIP(playerid, ip);
		}
	}
	else if(type == 'h') {
		if(lookup == 'n') 
			ShowAccountGpciHistoryFromName(playerid, name);
		else {
			new hash[MAX_GPCI_LEN];
			GetAccountGPCI(name, hash);
			ShowAccountGpciHistoryFromGpci(playerid, hash);
		}
	} else
		return ChatMsg(playerid, YELLOW, " >  O tipo de pesquisa deve ser um dos: 'i'(ip) 'h'(hash), o parâmetro opcional 'n' lista o histÃ³rico apenas para esse jogador.");

	return 1;
}