#include <YSI\y_hooks>

hook OnGameModeInit() {
    RegisterAdminCommand(STAFF_LEVEL_GAME_MASTER, "(des)calar", "(Des)calar um jogador");
    RegisterAdminCommand(STAFF_LEVEL_GAME_MASTER, "avisar", "Dar aviso em um jogador");
    RegisterAdminCommand(STAFF_LEVEL_GAME_MASTER, "kick", "Kickar jogadores");
    RegisterAdminCommand(STAFF_LEVEL_GAME_MASTER, "anun", "Enviar um An˙ncio no Chat");
    RegisterAdminCommand(STAFF_LEVEL_GAME_MASTER, "cc", "Limpar o Chat");
    RegisterAdminCommand(STAFF_LEVEL_GAME_MASTER, "rr", "Responder a um RelatÛrio");
    RegisterAdminCommand(STAFF_LEVEL_GAME_MASTER, "blockrr", "Bloquear alguÈm de enviar relatÛrios");
}

ACMD:calar[1](playerid, params[]) {
	new targetId, delay, reason[128];

	if(sscanf(params, "dds[128]", targetId, delay, reason)) return ChatMsg(playerid,YELLOW," >  Use: /calar [playerid] [segundos] [motivo] - use -1 nos segundos para calar permanentemente.");

	if(!IsPlayerConnected(targetId)) return ChatMsg(playerid,RED, " >  Esse player n„o est· conectado.");

	if(GetPlayerAdminLevel(targetId) >= GetPlayerAdminLevel(playerid)) return 3;

	if(IsPlayerMuted(targetId)) return ChatMsg(playerid, YELLOW, " >  Esse player j· est· calado.");

	if(delay > 0) {
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

	if(GetPlayerAdminLevel(targetId) >= GetPlayerAdminLevel(playerid) && playerid != targetId) return 3;

	if(!IsPlayerConnected(targetId)) return 4;

	TogglePlayerMute(targetId, false);

	ChatMsg(playerid, YELLOW, " >  Descalado: %P", targetId);
	ChatMsg(targetId, YELLOW, "player/unmuted");

	return 1;
}

ACMD:avisar[1](playerid, params[]) {
	new targetId, reason[128];

	if(sscanf(params, "rs[128]", targetId, reason)) return ChatMsg(playerid, YELLOW, " >  Use: /avisar [id/nick] [motivo]");

	if(!IsPlayerConnected(targetId)) return ChatMsg(playerid,RED, " >  Esse player n„o est· conectado");

	if(GetPlayerAdminLevel(targetId) >= GetPlayerAdminLevel(playerid) && playerid != targetId) return 3;

	new warnings = GetPlayerWarnings(targetId) + 1;

	SetPlayerWarnings(targetId, warnings);
	
	ChatMsg(playerid, ORANGE, " >  %P"C_YELLOW" levou um aviso. (%d/3) Motivo: %s", targetId, warnings, reason);
	ChatMsg(targetId, ORANGE, "WARNEDMESSG", warnings, reason);

	if(warnings >= 3) {
	    SetPlayerWarnings(targetId, 0);
		KickPlayer(targetId, "Atingiu 3 avisos da administra√ß√£o.");
	}

	return ChatMsgAll(0xC457EBAA, "[Admin]: %P{C457EB} (%d) avisou %P{C457EB} (%d)! "C_WHITE"[Motivo: %s]", playerid, playerid, targetId, targetId, reason);
}

ACMD:kick[1](playerid, params[]) {
	new targetId, reason[64], highestadmin;

	foreach(new i : Player) if(GetPlayerAdminLevel(i) > GetPlayerAdminLevel(highestadmin)) highestadmin = i;

	if(sscanf(params, "rs[64]", targetId, reason)) return ChatMsg(playerid, YELLOW, " >  Use: /kick [id/nick] [motivo]");

	if(playerid == targetId) return ChatMsg(playerid, PINK, " >  %P"C_PINK" VocÍ n„o pode kickar a si mesmo", playerid);

	if(!IsPlayerConnected(targetId)) return CMD_INVALID_PLAYER;

	if(GetPlayerAdminLevel(targetId) >= GetPlayerAdminLevel(playerid) && playerid != targetId) return CMD_CANT_USE_ON;

	if(GetPlayerAdminLevel(playerid) != GetPlayerAdminLevel(highestadmin)) ChatMsg(highestadmin, YELLOW, " >  %p kickou o player: (%d)%p motivo: %s", playerid, targetId, targetId, reason);

	KickPlayer(targetId, reason, true);

	return ChatMsgAll(0xC457EBAA, "[Admin]: %P{C457EB} (%d) kickou %P{C457EB} (%d)! "C_WHITE"[Motivo: %s]", playerid, playerid, targetId, targetId, reason);
}

ACMD:anun[1](playerid, params[]) {
	new anuncio[255];

	if(sscanf(params, "s[255]", anuncio)) return ChatMsg(playerid, RED, " > Use: /anun [mensagem]");

	SendClientMessageToAll(COLOR_RADIATION, " > An˙ncio de AdministraÁ„o:");
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
			ChatMsg(playerid, YELLOW, " >  O ID '%d' n„o est· online, tente usar o nome do jogador.", targetId);
		else
			return 4;
	}

	if(!AccountExists(name)) return ChatMsg(playerid, YELLOW, " >  A conta '%s' n„o existe.", name);

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
		return ChatMsg(playerid, YELLOW, " >  O tipo de pesquisa deve ser um dos: 'i'(ip) 'h'(hash), o par‚metro opcional 'n' lista o hist√≥rico apenas para esse jogador.");

	return 1;
}