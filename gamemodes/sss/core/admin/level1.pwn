#include <YSI\y_hooks>


hook OnGameModeInit()
{
	RegisterAdminCommand(STAFF_LEVEL_GAME_MASTER, ""C_BLUE"/comandoslvl1 - Ver a lista de comandos dos admins n�vel 1\n");
}


ACMD:calar[1](playerid, params[])
{
	new
		targetid,
		delay,
		reason[128];

	if(sscanf(params, "dds[128]", targetid, delay, reason))
		return ChatMsg(playerid,YELLOW," >  Use: /calar [playerid] [segundos] [motivo] - use -1 nos segundos para calar permanentemente.");

	if(!IsPlayerConnected(targetid))
		return ChatMsg(playerid,RED, " >  Esse player n�o est� conectado.");

	if(GetPlayerAdminLevel(targetid) >= GetPlayerAdminLevel(playerid))
		return 3;

	if(IsPlayerMuted(targetid))
		return ChatMsg(playerid, YELLOW, " >  Esse player j� est� calado.");

    new admNm[24];GetPlayerName(playerid, admNm, 24);
    new pNm[24];GetPlayerName(targetid, pNm, 24);
	ChatMsgAll(0xC457EBAA, "[Admin]: %s(id:%d) calou %s(id:%d)! "C_WHITE"[Segundos: %d]", admNm, playerid, pNm, targetid, delay);
	
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

	return 1;
}

ACMD:descalar[1](playerid, params[])
{
	new targetid;

	if(sscanf(params, "d", targetid))
		return ChatMsg(playerid, YELLOW, " >  Use: /descalar [playerid]");

	if(GetPlayerAdminLevel(targetid) >= GetPlayerAdminLevel(playerid) && playerid != targetid)
		return 3;

	if(!IsPlayerConnected(targetid))
		return 4;

	TogglePlayerMute(targetid, false);

	ChatMsg(playerid, YELLOW, " >  Descalado: %P", targetid);
	ChatMsgLang(targetid, YELLOW, "MUTEDUNMUTE");

	return 1;
}

ACMD:avisar[1](playerid, params[])
{
	new
		targetid,
		reason[128];

	if(sscanf(params, "ds[128]", targetid, reason))
		return ChatMsg(playerid, YELLOW, " >  Use: /avisar [playerid] [motivo]");

	if(!IsPlayerConnected(targetid))
		return ChatMsg(playerid,RED, " >  Esse player n�o est� conectado");

	if(GetPlayerAdminLevel(targetid) >= GetPlayerAdminLevel(playerid) && playerid != targetid)
		return 3;

	new warnings = GetPlayerWarnings(targetid) + 1;

	SetPlayerWarnings(targetid, warnings);

    new admNm[24];GetPlayerName(playerid, admNm, 24);
    new pNm[24];GetPlayerName(targetid, pNm, 24);
	ChatMsgAll(0xC457EBAA, "[Admin]: %s(id:%d) avisou %s(id:%d)! "C_WHITE"[Motivo: %s]", admNm, playerid, pNm, targetid, reason);
	
	ChatMsg(playerid, ORANGE, " >  %P"C_YELLOW" Levou um aviso. (%d/3) Motivo: %s", targetid, warnings, reason);
	ChatMsgLang(targetid, ORANGE, "WARNEDMESSG", warnings, reason);

	if(warnings >= 3)
	{
	    SetPlayerWarnings(targetid, 0);
		KickPlayer(targetid, "Atingiu 3 avisos da administra��o.");
	}
	return 1;
}

ACMD:kick[1](playerid, params[])
{
	new
		targetid,
		reason[64],
		highestadmin;

	foreach(new i : Player)
	{
		if(GetPlayerAdminLevel(i) > GetPlayerAdminLevel(highestadmin))
			highestadmin = i;
	}

	if(sscanf(params, "ds[64]", targetid, reason))
		return ChatMsg(playerid, YELLOW, " >  Use: /kick [playerid] [motivo]");

	if(GetPlayerAdminLevel(targetid) >= GetPlayerAdminLevel(playerid) && playerid != targetid)
		return 3;

	if(!IsPlayerConnected(targetid))
		return 4;

    new admNm[24];GetPlayerName(playerid, admNm, 24);
    new pNm[24];GetPlayerName(targetid, pNm, 24);
	ChatMsgAll(0xC457EBAA, "[Admin]: %s(id:%d) kickou %s(id:%d)! "C_WHITE"[Motivo: %s]", admNm, playerid, pNm, targetid, reason);
	
	if(GetPlayerAdminLevel(playerid) != GetPlayerAdminLevel(highestadmin))
		ChatMsg(highestadmin, YELLOW, " >  %p kickou o player: (%d)%p motivo: %s", playerid, targetid, targetid, reason);

	if(playerid == targetid)
		ChatMsg(playerid, PINK, " >  %P"C_PINK" voc� n�o pode kickar a si mesmo", playerid);

	KickPlayer(targetid, reason);

	return 1;
}

ACMD:msg[1](playerid, params[])
{
	if(strlen(params) < 1)
        return ChatMsg(playerid,YELLOW," >  Use: /msg [Mensagem]");

	new str[255];
	format(str, 255, "[Admin]: %p(id:%d) Diz"C_WHITE": %s", playerid, playerid, TagScan(params));

	ChatMsgAll(0xC457EBAA, str);
	return 1;
}

ACMD:country[1](playerid, params[])
{
	if(isnumeric(params))
	{
		new targetid = strval(params);

		if(!IsPlayerConnected(targetid))
		{
			if(targetid > 99)
				ChatMsg(playerid, YELLOW, " >  O ID '%d' n�o est� online, tente usar o nome do jogador.", targetid);

			else
				return 4;
		}
		if(!IsPlayerSpawned(playerid)) return ChatMsg(playerid, RED, " > Aguarde o jogador spawnar.!");
		
		new str[520];
		format(str, sizeof(str), "%s\tPa�s: %s", str, GetPlayerCountry(targetid));
   	 	format(str, sizeof(str), "%s\tCidade: %s", str, GetPlayerCity(targetid));
    	format(str, sizeof(str), "%s\tLatitude: %s", str, GetPlayerLatitude(targetid));
    	format(str, sizeof(str), "%s\tLongititude: %s", str, GetPlayerLongtitude(targetid));
    	format(str, sizeof(str), "%s\tProvedor/ISP: %s", str, GetPlayerProvider(targetid));
    	format(str, sizeof(str), "%s\tProxy: %s", str, GetPlayerProxyStatus(targetid));
    	
		ShowPlayerDialog(playerid, 10008, DIALOG_STYLE_MSGBOX, "IP Data", str, "Fechar", "");
	}
	else ChatMsg(playerid, YELLOW, " >  ID de jogador inv�lido.", params);

	return 1;
}

ACMD:allcountry[1](playerid)
{
	new
		list[(MAX_PLAYER_NAME + 3 + MAX_PLAYERS + 1) * MAX_PLAYERS];

	foreach(new i : Player)
	{
		format(list, sizeof(list), "%s%p - %s\n", list, i, GetPlayerCountry(playerid));
	}

	ShowPlayerDialog(playerid, 10008, DIALOG_STYLE_LIST, "Paises dos players", list, "Fechar", "");

	return 1;
}

ACMD:cc[1](playerid)
{
	for(new i;i<100;i++)
		ChatMsgAll(WHITE, " ");

	ChatMsgAll(0xC457EBAA, "[Admin]: %p(id:%d) limpou o chat!", playerid, playerid);
	return 1;
}

ACMD:history[1](playerid, params[])
{
	new
		name[MAX_PLAYER_NAME],
		type,
		lookup;

	if(sscanf(params, "s[24]C(a)C()", name, type, lookup))
	{
		ChatMsg(playerid, YELLOW, " >  Use: /history [playerid/name] [i/h] [n]");
		return 1;
	}

	if(isnumeric(name))
	{
		new targetid = strval(name);

		if(IsPlayerConnected(targetid))
			GetPlayerName(targetid, name, MAX_PLAYER_NAME);

		else if(targetid > 99)
			ChatMsg(playerid, YELLOW, " >  O ID '%d' n�o est� online, tente usar o nome do jogador.", targetid);

		else
			return 4;
	}

	if(!AccountExists(name))
	{
		ChatMsg(playerid, YELLOW, " >  A conta '%s' n�o existe.", name);
		return 1;
	}

	if(GetAdminLevelByName(name) > GetPlayerAdminLevel(playerid))
	{
		new playername[MAX_PLAYER_NAME];

		GetPlayerName(playerid, playername, MAX_PLAYER_NAME);

		if(strcmp(name, playername))
		{
			ChatMsg(playerid, YELLOW, " >  Sem aliases encontradas para %s", name);
			return 1;
		}
	}

	if(type == 'i')
	{
		if(lookup == 'n')
		{
			ShowAccountIPHistoryFromName(playerid, name);
		}
		else
		{
			new ip;
			GetAccountIP(name, ip);
			ShowAccountIPHistoryFromIP(playerid, ip);
		}
	}
	else if(type == 'h')
	{
		if(lookup == 'n')
		{
			ShowAccountGpciHistoryFromName(playerid, name);
		}
		else
		{
			new hash[MAX_GPCI_LEN];
			GetAccountGPCI(name, hash);
			ShowAccountGpciHistoryFromGpci(playerid, hash);
		}
	}
	else
	{
		ChatMsg(playerid, YELLOW, " >  O tipo de pesquisa deve ser um dos: 'i'(ip) 'h'(hash), o par�metro opcional 'n' lista o hist�rico apenas para esse jogador.");
		return 1;
	}

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
    strcat(stringlvl1, ""C_BLUE"/msg - Enviar um an�ncio no chat\n");
    strcat(stringlvl1, ""C_BLUE"/(all)country - Mostrar dados da cidade de um player\n");
    strcat(stringlvl1, ""C_BLUE"/cc - Limpar o chat\n");
    strcat(stringlvl1, ""C_BLUE"/rr - Responder relat�rios\n");
    strcat(stringlvl1, ""C_BLUE"/blockrr - Bloquear algu�m de enviar relat�rio\n");
    ShowPlayerDialog(playerid, 12401, DIALOG_STYLE_MSGBOX, "Admin 1", stringlvl1, "Fechar", "");
    return 1;
}
