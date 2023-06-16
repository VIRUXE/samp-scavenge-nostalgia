#include <YSI\y_hooks>

hook OnGameModeInit() {
    RegisterAdminCommand(STAFF_LEVEL_GAME_MASTER, "(des)calar", "(Des)calar um jogador");
    RegisterAdminCommand(STAFF_LEVEL_GAME_MASTER, "avisar", "Dar aviso em um jogador");
    RegisterAdminCommand(STAFF_LEVEL_GAME_MASTER, "kick", "Kickar jogadores");
    RegisterAdminCommand(STAFF_LEVEL_GAME_MASTER, "msg", "Enviar um Anúncio no Chat");
    RegisterAdminCommand(STAFF_LEVEL_GAME_MASTER, "cc", "Limpar o Chat");
    RegisterAdminCommand(STAFF_LEVEL_GAME_MASTER, "rr", "Responder a um Relatório");
    RegisterAdminCommand(STAFF_LEVEL_GAME_MASTER, "blockrr", "Bloquear alguém de enviar relatórios");
    RegisterAdminCommand(STAFF_LEVEL_GAME_MASTER, "tapa", "Dar tapa em algum player");
}

ACMD:tapa[1](playerid, params[]) {
	new admin = GetPlayerAdminLevel(playerid);

    if(admin < STAFF_LEVEL_LEAD && admin > STAFF_LEVEL_GAME_MASTER && !IsPlayerOnAdminDuty(playerid)) return CMD_NOT_DUTY;
		
    new targetId;
	
	if(sscanf(params, "r", targetId)) return SendClientMessage(playerid, YELLOW, " > Use: /tapa [id/nick]");

	if(GetPlayerAdminLevel(targetId) > 1) return CMD_CANT_USE_ON;

	new Float:x, Float:y, Float:z;
	GetPlayerPos(targetId, x, y, z);
	SetPlayerPos(targetId, x, y, z + 6.0);

	return ChatMsgAdmins(1, BLUE, "[Admin] %P"C_BLUE" (%d) deu um tapa em %P"C_BLUE" (%d)", playerid, playerid, targetId, targetId);
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

	return ChatMsgAll(0xC457EBAA, "[Admin]: %P{C457EB} (%d) calou %P{C457EB} (%d)! "C_WHITE"[Segundos: %d]", playerid, playerid, targetId, targetId, delay);
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
	
	ChatMsg(playerid, ORANGE, " >  %P"C_YELLOW" levou um aviso. (%d/3) Motivo: %s", targetId, warnings, reason);
	ChatMsg(targetId, ORANGE, "WARNEDMESSG", warnings, reason);

	if(warnings >= 3) {
	    SetPlayerWarnings(targetId, 0);
		KickPlayer(targetId, "Atingiu 3 avisos da administraÃ§Ã£o.");
	}

	return ChatMsgAll(0xC457EBAA, "[Admin]: %P{C457EB} (%d) avisou %P{C457EB} (%d)! "C_WHITE"[Motivo: %s]", playerid, playerid, targetId, targetId, reason);
}

ACMD:kick[1](playerid, params[]) {
	new targetId, reason[64], highestadmin;

	foreach(new i : Player) if(GetPlayerAdminLevel(i) > GetPlayerAdminLevel(highestadmin)) highestadmin = i;

	if(sscanf(params, "rs[64]", targetId, reason)) return ChatMsg(playerid, YELLOW, " >  Use: /kick [id/nick] [motivo]");

	if(playerid == targetId) return ChatMsg(playerid, PINK, " >  %P"C_PINK" Você não pode kickar a si mesmo", playerid);

	if(!IsPlayerConnected(targetId)) return CMD_INVALID_PLAYER;

	if(GetPlayerAdminLevel(targetId) >= GetPlayerAdminLevel(playerid) && playerid != targetId) return CMD_CANT_USE_ON;

	if(GetPlayerAdminLevel(playerid) != GetPlayerAdminLevel(highestadmin)) ChatMsg(highestadmin, YELLOW, " >  %p kickou o player: (%d)%p motivo: %s", playerid, targetId, targetId, reason);

	KickPlayer(targetId, reason, true);

	return ChatMsgAll(0xC457EBAA, "[Admin]: %P{C457EB} (%d) kickou %P{C457EB} (%d)! "C_WHITE"[Motivo: %s]", playerid, playerid, targetId, targetId, reason);
}

ACMD:msg[1](playerid, params[]) {
	new anuncio[255];

	if(sscanf(params, "s[255]", anuncio)) return ChatMsg(playerid, RED, " > Use: /msg [mensagem]");

	SendClientMessageToAll(COLOR_RADIATION, " >>>>> Administração: <<<<<");
	return ChatMsgAll(COLOR_RADIATION, " > %p disse: {FFFFFF}%s", playerid, anuncio);
}

ACMD:cc[1](playerid) {
	for(new i;i<100;i++) ChatMsgAll(WHITE, " ");

	return ChatMsgAll(0xC457EBAA, "[Admin]: %P{C457EB} (%d) limpou o chat!", playerid, playerid);
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