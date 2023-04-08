#include <YSI\y_hooks>


hook OnGameModeInit()
{
	RegisterAdminCommand(STAFF_LEVEL_GAME_MASTER, ""C_BLUE"/comandoslvl1 - Ver a lista de comandos dos admins nível 1\n");
}

ACMD:calar[1](playerid, params[])
{
	new targetid, delay, reason[128];

	if(sscanf(params, "dds[128]", targetid, delay, reason)) return ChatMsg(playerid,YELLOW," >  Use: /calar [playerid] [segundos] [motivo] - use -1 nos segundos para calar permanentemente.");

	if(!IsPlayerConnected(targetid)) return ChatMsg(playerid,RED, " >  Esse player não está conectado.");

	if(GetPlayerAdminLevel(targetid) >= GetPlayerAdminLevel(playerid)) return 3;

	if(IsPlayerMuted(targetid)) return ChatMsg(playerid, YELLOW, " >  Esse player já está calado.");

	if(delay > 0)
	{
		TogglePlayerMute(targetid, true, delay);
		ChatMsg(playerid, YELLOW, " >  Calou o player %P "C_WHITE"por %d segundos.", targetid, delay);
		ChatMsgLang(targetid, YELLOW, "MUTEDANTIME", delay, reason);
	}
	else
	{
		TogglePlayerMute(targetid, true);
		ChatMsg(playerid, YELLOW, " > Player calado: %P", targetid);
		ChatMsgLang(targetid, YELLOW, "MUTEDREASON", reason);
	}

	return ChatMsgAll(0xC457EBAA, "[Admin]: %P (%d) calou %P (%d)! "C_WHITE"[Segundos: %d]", playerid, playerid, targetid, targetid, delay);
}

ACMD:descalar[1](playerid, params[])
{
	new targetid;

	if(sscanf(params, "d", targetid)) return ChatMsg(playerid, YELLOW, " >  Use: /descalar [playerid]");

	if(GetPlayerAdminLevel(targetid) >= GetPlayerAdminLevel(playerid) && playerid != targetid) return 3;

	if(!IsPlayerConnected(targetid)) return 4;

	TogglePlayerMute(targetid, false);

	ChatMsg(playerid, YELLOW, " >  Descalado: %P", targetid);
	ChatMsgLang(targetid, YELLOW, "MUTEDUNMUTE");

	return 1;
}

ACMD:avisar[1](playerid, params[])
{
	new targetid, reason[128];

	if(sscanf(params, "ds[128]", targetid, reason)) return ChatMsg(playerid, YELLOW, " >  Use: /avisar [playerid] [motivo]");

	if(!IsPlayerConnected(targetid)) return ChatMsg(playerid,RED, " >  Esse player não está conectado");

	if(GetPlayerAdminLevel(targetid) >= GetPlayerAdminLevel(playerid) && playerid != targetid) return 3;

	new warnings = GetPlayerWarnings(targetid) + 1;

	SetPlayerWarnings(targetid, warnings);
	
	ChatMsg(playerid, ORANGE, " >  %P"C_YELLOW" levou um aviso. (%d/3) Motivo: %s", targetid, warnings, reason);
	ChatMsgLang(targetid, ORANGE, "WARNEDMESSG", warnings, reason);

	if(warnings >= 3)
	{
	    SetPlayerWarnings(targetid, 0);
		KickPlayer(targetid, "Atingiu 3 avisos da administração.");
	}

	return ChatMsgAll(0xC457EBAA, "[Admin]: %P (%d) avisou %P (%d)! "C_WHITE"[Motivo: %s]", playerid, playerid, targetid, targetid, reason);
}

ACMD:kick[1](playerid, params[])
{
	new targetid, reason[64], highestadmin;

	foreach(new i : Player) if(GetPlayerAdminLevel(i) > GetPlayerAdminLevel(highestadmin)) highestadmin = i;

	if(sscanf(params, "ds[64]", targetid, reason)) return ChatMsg(playerid, YELLOW, " >  Use: /kick [playerid] [motivo]");

	if(playerid == targetid) return ChatMsg(playerid, PINK, " >  %P"C_PINK" você não pode kickar a si mesmo", playerid);

	if(!IsPlayerConnected(targetid)) return 4;

	if(GetPlayerAdminLevel(targetid) >= GetPlayerAdminLevel(playerid) && playerid != targetid) return 3;

	if(GetPlayerAdminLevel(playerid) != GetPlayerAdminLevel(highestadmin)) ChatMsg(highestadmin, YELLOW, " >  %p kickou o player: (%d)%p motivo: %s", playerid, targetid, targetid, reason);

	KickPlayer(targetid, reason, true);

	return ChatMsgAll(0xC457EBAA, "[Admin]: %P (%d) kickou %P (%d)! "C_WHITE"[Motivo: %s]", playerid, playerid, targetid, targetid, reason);
}

ACMD:msg[1](playerid, params[])
{
	new anuncio[255];

	if(sscanf(params, "s[255]", anuncio)) return ChatMsg(playerid, RED, " > Use: /msg [mensagem]");

	return ChatMsgAll(0xC457EBAA, "[Admin] %P{C457EBA} (%d) disse: {FFFFFF}%s", playerid, playerid, anuncio);
}

ACMD:cc[1](playerid)
{
	for(new i;i<100;i++) ChatMsgAll(WHITE, " ");

	return ChatMsgAll(0xC457EBAA, "[Admin]: %P{C457EBA} (%d) limpou o chat!", playerid, playerid);
}

ACMD:history[1](playerid, params[])
{
	new
		name[MAX_PLAYER_NAME],
		type,
		lookup;

	if(sscanf(params, "s[24]C(a)C()", name, type, lookup)) return ChatMsg(playerid, YELLOW, " >  Use: /history [playerid/name] [i/h] [n]");

	if(isnumeric(name))
	{
		new targetid = strval(name);

		if(IsPlayerConnected(targetid))
			GetPlayerName(targetid, name, MAX_PLAYER_NAME);
		else if(targetid > 99)
			ChatMsg(playerid, YELLOW, " >  O ID '%d' não está online, tente usar o nome do jogador.", targetid);
		else
			return 4;
	}

	if(!AccountExists(name)) return ChatMsg(playerid, YELLOW, " >  A conta '%s' não existe.", name);

	if(GetAdminLevelByName(name) > GetPlayerAdminLevel(playerid))
	{
		new playername[MAX_PLAYER_NAME];
		GetPlayerName(playerid, playername, MAX_PLAYER_NAME);

		if(strcmp(name, playername)) return ChatMsg(playerid, YELLOW, " >  Sem aliases encontradas para %s", name);
	}

	if(type == 'i')
	{
		if(lookup == 'n') ShowAccountIPHistoryFromName(playerid, name);
		else
		{
			new ip;
			GetAccountIP(name, ip);
			ShowAccountIPHistoryFromIP(playerid, ip);
		}
	}
	else if(type == 'h')
	{
		if(lookup == 'n') ShowAccountGpciHistoryFromName(playerid, name);
		else
		{
			new hash[MAX_GPCI_LEN];
			GetAccountGPCI(name, hash);
			ShowAccountGpciHistoryFromGpci(playerid, hash);
		}
	}
	else return ChatMsg(playerid, YELLOW, " >  O tipo de pesquisa deve ser um dos: 'i'(ip) 'h'(hash), o parâmetro opcional 'n' lista o histórico apenas para esse jogador.");

	return 1;
}

ACMD:comandoslvl1[1](playerid)
{
    new stringlvl1[800];

    strcat(stringlvl1, "{FFFF00}Comandos dos Admins Nivel 1:\n");
    strcat(stringlvl1, "{FF0000}\n");
    strcat(stringlvl1, ""C_BLUE"/(des)calar - calar/descalar um player\n");
    strcat(stringlvl1, ""C_BLUE"/avisar - Dar aviso em um player\n");
    strcat(stringlvl1, ""C_BLUE"/kick - Kickar players\n");
    strcat(stringlvl1, ""C_BLUE"/msg - Enviar um anúncio no chat\n");
    strcat(stringlvl1, ""C_BLUE"/(all)country - Mostrar dados da cidade de um player\n");
    strcat(stringlvl1, ""C_BLUE"/cc - Limpar o chat\n");
    strcat(stringlvl1, ""C_BLUE"/rr - Responder relatórios\n");
    strcat(stringlvl1, ""C_BLUE"/blockrr - Bloquear alguém de enviar relatório\n");
	
    ShowPlayerDialog(playerid, 12401, DIALOG_STYLE_MSGBOX, "Admin 1", stringlvl1, "Fechar", "");

    return 1;
}
