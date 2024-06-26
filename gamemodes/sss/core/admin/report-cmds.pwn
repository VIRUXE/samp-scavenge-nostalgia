static
		send_TargetName				[MAX_PLAYERS][MAX_PLAYER_NAME],
		send_TargetType				[MAX_PLAYERS],
Float:	send_TargetPos				[MAX_PLAYERS][3],
		send_TargetWorld			[MAX_PLAYERS],
		send_TargetInterior			[MAX_PLAYERS],

		report_CurrentReportList	[MAX_PLAYERS][MAX_REPORTS_PER_PAGE][e_report_list_struct],

		report_CurrentReason		[MAX_PLAYERS][MAX_REPORT_REASON_LENGTH],
		report_CurrentType			[MAX_PLAYERS][MAX_REPORT_TYPE_LENGTH],
Float:	report_CurrentPos			[MAX_PLAYERS][3],
		report_CurrentWorld			[MAX_PLAYERS],
		report_CurrentInterior		[MAX_PLAYERS],
		report_CurrentInfo			[MAX_PLAYERS][MAX_REPORT_INFO_LENGTH],
		report_CurrentItem			[MAX_PLAYERS];

static
bool: 	RelatorioTempo[MAX_PLAYERS],
		RelatorioTempo2[MAX_PLAYERS],
bool:	RelatorioEnviado[MAX_PLAYERS],
bool:   RelatorioBlock[MAX_PLAYERS];

ACMD:blockrr[1](playerid, params[]) {
	new targetId;

	if(sscanf(params, "r", targetId)) return ChatMsg(playerid, RED, " > Use /blockrr [id/nome]");
    
	RelatorioBlock[targetId] = !RelatorioBlock[targetId];
    
	return ChatMsg(playerid, YELLOW, RelatorioBlock[targetId] ? " > Voc� bloqueou %p de usar o /relatorio!" : " > %p agora pode usar /relatorio", targetId);
}

ACMD:rr[1](playerid, params[]) {
	new targetId, msg[200];

	if(sscanf(params, "rs[200]", targetId, msg)) return ChatMsg(playerid, RED, " > Use /rr [id/nome] [mensagem]");

	if(!RelatorioEnviado[targetId]) return ChatMsg(playerid, RED, " > Esse player n�o enviou nenhum relat�rio ou j� foi respondido.");

    ChatMsg(targetId, GREEN, "="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"=");
	ChatMsg(targetId, GREEN, sprintf("[Relat�rio] %p(id:%d) respondeu: "C_WHITE"%s", playerid, playerid, msg));
	ChatMsg(targetId, GREEN, "="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"=");

	ChatMsgAdmins(1, GREEN, sprintf(" > %p(id:%d) respondeu o relat�rio de %p(id:%d): %s", playerid, playerid, targetId, targetId, msg));

	RelatorioEnviado[targetId] = RelatorioTempo[targetId] = false, RelatorioTempo2[targetId] = 100;

	return 1;
}

CMD:relatorio(playerid, params[]) {
    if(!IsPlayerLoggedIn(playerid)) return ChatMsg(playerid, YELLOW, "server/command/cant-use-not-logged-in");
	
    if(RelatorioTempo[playerid])
		return ChatMsg(playerid, RED, sprintf(" > Aguarde"C_YELLOW" %d "C_RED"segundos para usar esse comando novamente.", RelatorioTempo2[playerid]));

	if(RelatorioBlock[playerid]) return ChatMsg(playerid, RED, " > Aguarde para usar esse comando novamente.");
	
	new msg[200];

    if(sscanf(params, "s[200]", msg)) return ChatMsg(playerid, RED, " > Use /relatorio [mensagem]");

    ChatMsgAdmins(1, BLUE, "="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"=");
    ChatMsgAdmins(1, BLUE, "[Relat�rio]: %p(id:%d)"C_BLUE": "C_WHITE"%s", playerid, playerid, msg);
    ChatMsgAdmins(1, BLUE, "="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"=");
	RelatorioTempo[playerid]   = true;
	RelatorioTempo2[playerid]  = 80;
	RelatorioEnviado[playerid] = true;

    defer RelatorioFalse(playerid);

	return ChatMsg(playerid, YELLOW, " > Relat�rio enviado com sucesso. Aguarde a administra��o do servidor.");
}

hook OnPlayerConnect(playerid) {
	RelatorioBlock[playerid] = false;
}

timer RelatorioFalse[SEC(1)](playerid) {
	if(RelatorioTempo2[playerid] > 0)
	{
        RelatorioTempo2[playerid] --;
        defer RelatorioFalse(playerid);
	} else
		RelatorioTempo[playerid] = false;
}

CMD:report(playerid) {
    if(GetPlayerAdminLevel(playerid) > 1) return ChatMsg(playerid, RED, " > Voc� n�o pode usar este comando.");
        
	ShowReportMenu(playerid);

	return 1;
}

ShowReportMenu(playerid) {
	Dialog_Show(playerid, ReportMenu, DIALOG_STYLE_LIST, ""C_GREEN"Reportando...", "Especificar um ID que est� online agora\nEspeficiar o nome do player\nReportar ultimo player que me matou\nReportar player mais próximo de mim", ""C_GREEN"Enviar", ""C_RED"Cancelar");
	return 1;
}

Dialog:ReportMenu(playerid, response, listitem, inputtext[]) {
	if(response) {
		switch(listitem)
		{ case 0: { // Specific player ID (who is online now)
				ShowReportOnlinePlayer(playerid);
				send_TargetType[playerid] = 1;
			}
			case 1: { // Specific Player Name (Who isn't online now)
				ShowReportOfflinePlayer(playerid);
				send_TargetType[playerid] = 2;
			}
			case 2: { // Player that last killed me
				new name[MAX_PLAYER_NAME];

				GetLastKilledBy(playerid, name);

				if(!isnull(name)) {
					send_TargetName[playerid][0] = EOS;
					send_TargetName[playerid]    = name;
				} else {
					GetLastHitBy(playerid, name);

					if(!isnull(name)) {
						send_TargetName[playerid][0] = EOS;
						send_TargetName[playerid]    = name;
					} else 
						return ChatMsg(playerid, RED, "player/not-found");
				}

				GetPlayerDeathPos(playerid, send_TargetPos[playerid][0], send_TargetPos[playerid][1], send_TargetPos[playerid][2]);
				send_TargetWorld[playerid]    = -1;
				send_TargetInterior[playerid] = -1;

				ShowReportReasonInput(playerid);
				send_TargetType[playerid] = 3;
			}
			case 3: { // Player closest to me
				new
					Float:distance = 100.0,
					targetId;

				targetId = GetClosestPlayerFromPlayer(playerid, distance);

				if(!IsPlayerConnected(targetId)) {
					targetId = playerid;
					return 1;
				}

				GetPlayerName(targetId, send_TargetName[playerid], MAX_PLAYER_NAME);
				GetPlayerPos(targetId, send_TargetPos[playerid][0], send_TargetPos[playerid][1], send_TargetPos[playerid][2]);
				send_TargetWorld[playerid]    = GetPlayerVirtualWorld(targetId);
				send_TargetInterior[playerid] = GetPlayerInterior(targetId);

				ShowReportReasonInput(playerid);
				send_TargetType[playerid] = 4;
			}
		}
	}

	return 0;
}

ShowReportOnlinePlayer(playerid) {
	new
		name[MAX_PLAYER_NAME],
		list[MAX_PLAYERS * (MAX_PLAYER_NAME + 1)];

	foreach(new i : Player) {
		GetPlayerName(i, name, MAX_PLAYER_NAME);
		strcat(list, name);
		strcat(list, "\n");
	}

	Dialog_Show(playerid, ReportOnlinePlayer, DIALOG_STYLE_LIST, "Reportar um player online", list, "Reportar", "Voltar");

	return 1;
}

Dialog:ReportOnlinePlayer(playerid, response, listitem, inputtext[]) {
	if(response) {
		GetPlayerPos(playerid, send_TargetPos[playerid][0], send_TargetPos[playerid][1], send_TargetPos[playerid][2]);
		send_TargetWorld[playerid]    = -1;
		send_TargetInterior[playerid] = -1;
		strmid(send_TargetName[playerid], inputtext, 0, strlen(inputtext));

		ShowReportReasonInput(playerid);
	}
	else 
		ShowReportMenu(playerid);
}

ShowReportOfflinePlayer(playerid) {
	Dialog_Show(playerid, ReportOfflinePlayer, DIALOG_STYLE_INPUT, "Reportar um player offline", "Insira o nome do jogador", "Reportar", "Voltar");

	return 1;
}

Dialog:ReportOfflinePlayer(playerid, response, listitem, inputtext[]) {
	if(response) {
		send_TargetName[playerid][0] = EOS;
		strcat(send_TargetName[playerid], inputtext);

		send_TargetPos[playerid][0]   = 0.0;
		send_TargetPos[playerid][1]   = 0.0;
		send_TargetPos[playerid][2]   = 0.0;
		send_TargetWorld[playerid]    = -1;
		send_TargetInterior[playerid] = -1;

		ShowReportReasonInput(playerid);
	} else
		ShowReportMenu(playerid);
}

ShowReportReasonInput(playerid) {
	Dialog_Show(playerid, ReportReasonInput, DIALOG_STYLE_INPUT, "Motivo do report", "Digite o motivo do seu relat�rio abaixo.", "Reportar", "Voltar");
}

Dialog:ReportReasonInput(playerid, response, listitem, inputtext[]) {
	if(response) {
		new reportType[MAX_REPORT_TYPE_LENGTH];

		switch(send_TargetType[playerid]) {
			case 1: reportType = REPORT_TYPE_PLAYER_ID;
			case 2: reportType = REPORT_TYPE_PLAYER_NAME;
			case 3: reportType = REPORT_TYPE_PLAYER_KILLER;
			case 4: reportType = REPORT_TYPE_PLAYER_CLOSE;
		}

		ChatMsgAdmins(1, BLUE, "="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"=");
   		ChatMsgAdmins(1, BLUE, "[REPORT]: %p reportou %s motivo"C_BLUE": "C_WHITE"%s", playerid, send_TargetName[playerid], inputtext);
    	ChatMsgAdmins(1, BLUE, "="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"=");

		//ReportPlayer(send_TargetName[playerid], inputtext, playerid, reportType, send_TargetPos[playerid][0], send_TargetPos[playerid][1], send_TargetPos[playerid][2], send_TargetWorld[playerid], send_TargetInterior[playerid], "");
	} else
		ShowReportMenu(playerid);
}

ACMD:reports[1](playerid, params[]) {
	if(!ShowListOfReports(playerid)) ChatMsg(playerid, YELLOW, " >  N�o existem reports.");

	return 1;
}

ShowListOfReports(playerid) {
	new totalReports = GetReportList(report_CurrentReportList[playerid]);

	if(!totalReports) return 0;

	new
		colour[9],
		string[(8 + MAX_PLAYER_NAME + 13 + 1) * MAX_REPORTS_PER_PAGE],
		idx;

	while(idx < totalReports && idx < MAX_REPORTS_PER_PAGE) {
		if(isequal(report_CurrentReportList[playerid][idx][report_type], "R_FIELD")) // Invasao de field
            colour = C_GREEN;
		else if(IsPlayerBanned(report_CurrentReportList[playerid][idx][report_name])) 
			colour = C_RED;
		else if(!report_CurrentReportList[playerid][idx][report_read]) 
			colour = C_YELLOW;
		else 
			colour = C_WHITE;

		format(string, sizeof(string), "%s%s%s (%s)\n", string, colour, report_CurrentReportList[playerid][idx][report_name], report_CurrentReportList[playerid][idx][report_type]);

		idx++;
	}

	ShowPlayerPageButtons(playerid);

	Dialog_Show(playerid, ListOfReports, DIALOG_STYLE_LIST, "Reports", string, "Abrir", "Fechar");

	return 1;
}

Dialog:ListOfReports(playerid, response, listitem, inputtext[]) {
	if(response) {
		ShowReport(playerid, listitem);
		HidePlayerPageButtons(playerid);
		report_CurrentItem[playerid] = listitem;
	} else
		HidePlayerPageButtons(playerid);
}

ShowReport(playerid, reportlistitem) {
	new
		timestamp,
		reporter[MAX_PLAYER_NAME];

	if(!GetReportInfo(report_CurrentReportList[playerid][reportlistitem][report_rowid], report_CurrentReason[playerid], timestamp, report_CurrentType[playerid], report_CurrentPos[playerid][0], report_CurrentPos[playerid][1], report_CurrentPos[playerid][2], report_CurrentWorld[playerid], report_CurrentInterior[playerid], report_CurrentInfo[playerid], reporter)) return 0;

	new message[512];

	format(message, sizeof(message), "\
		"C_YELLOW"Data:\n\t\t"C_BLUE"%s\n\n\n\
		"C_YELLOW"Motivo:\n\t\t"C_BLUE"%s\n\n\n\
		"C_YELLOW"Por:\n\t\t"C_BLUE"%s",
		TimestampToDateTime(timestamp),
		report_CurrentReason[playerid],
		reporter);

	SetReportRead(report_CurrentReportList[playerid][reportlistitem][report_rowid], 1);

	Dialog_Show(playerid, Report, DIALOG_STYLE_MSGBOX, report_CurrentReportList[playerid][reportlistitem][report_name], message, "Opções", "Voltar");

	return 1;
}

Dialog:Report(playerid, response, listitem, inputtext[]) {
	if(response) ShowReportOptions(playerid); else ShowListOfReports(playerid);
}

ShowReportOptions(playerid) {
	new options[128] = "Banir\nDeletar\nDeletar reports do jogador\nDeixar lido\n";

	if(IsPlayerOnAdminDuty(playerid) && GetPlayerAdminLevel(playerid) >= LEVEL_LEAD) {
		strcat(options, "Ir para a Posi��o do report\n");

		if(isequal(report_CurrentType[playerid], "TELE"))
			strcat(options, "Ir para o destino de teleporte\n");

		if(isequal(report_CurrentType[playerid], "CAM")) {
			strcat(options, "Ir para o local da câmera\n");
			strcat(options, "Ver a câmera\n");
		}

		if(isequal(report_CurrentType[playerid], "VTP"))
			strcat(options, "Ir para a Posi��o do Ve�culo\n");
	}

	HidePlayerPageButtons(playerid);

	Dialog_Show(playerid, ReportOptions, DIALOG_STYLE_LIST, report_CurrentReportList[playerid][report_CurrentItem[playerid]][report_name], options, "Selecionar", "Voltar");
}

Dialog:ReportOptions(playerid, response, listitem, inputtext[]) {
	if(response) {
		switch(listitem) {
			case 0: ShowReportBanPrompt(playerid);
			case 1: {
				DeleteReport(report_CurrentReportList[playerid][report_CurrentItem[playerid]][report_rowid]);
				ShowListOfReports(playerid);
			}
			case 2: {
				DeleteReportsOfPlayer(report_CurrentReportList[playerid][report_CurrentItem[playerid]][report_name]);
				ShowListOfReports(playerid);
			}
			case 3: {
				SetReportRead(report_CurrentReportList[playerid][report_CurrentItem[playerid]][report_rowid], 0);
				ShowListOfReports(playerid);
			}
			case 4: {
				if(IsPlayerOnAdminDuty(playerid)) {
					SetPlayerPos(playerid, report_CurrentPos[playerid][0], report_CurrentPos[playerid][1], report_CurrentPos[playerid][2]);
					SetPlayerVirtualWorld(playerid, report_CurrentWorld[playerid]);
					SetPlayerInterior(playerid, report_CurrentInterior[playerid]);
				}
			}
			case 5: {
				if(isequal(report_CurrentType[playerid], "TELE")) {
					if(IsPlayerOnAdminDuty(playerid)) {
						new Float:x, Float:y, Float:z;

						sscanf(report_CurrentInfo[playerid], "p<,>fff", x, y, z);
						SetPlayerPos(playerid, x, y, z);
						SetPlayerVirtualWorld(playerid, report_CurrentWorld[playerid]);
						SetPlayerInterior(playerid, report_CurrentInterior[playerid]);
					}
				} else if(isequal(report_CurrentType[playerid], "CAM")) {
					if(IsPlayerOnAdminDuty(playerid)) {
						new Float:x, Float:y, Float:z;

						sscanf(report_CurrentInfo[playerid], "p<,>fff{fff}", x, y, z);
						SetPlayerPos(playerid, x, y, z);
						SetPlayerVirtualWorld(playerid, report_CurrentWorld[playerid]);
						SetPlayerInterior(playerid, report_CurrentInterior[playerid]);
					}
				} else if(isequal(report_CurrentType[playerid], "VTP")) {
					if(IsPlayerOnAdminDuty(playerid)) {
						new Float:x, Float:y, Float:z;

						sscanf(report_CurrentInfo[playerid], "p<,>fff", x, y, z);
						SetPlayerPos(playerid, x, y, z);
						SetPlayerVirtualWorld(playerid, report_CurrentWorld[playerid]);
						SetPlayerInterior(playerid, report_CurrentInterior[playerid]);
					}
				}
			}
			case 6: {
				if(isequal(report_CurrentType[playerid], "CAM")) {
					if(IsPlayerOnAdminDuty(playerid)) {
						new
							Float:x, Float:y, Float:z,
							Float:vx, Float:vy, Float:vz;

						sscanf(report_CurrentInfo[playerid], "p<,>ffffff", x, y, z, vx, vy, vz);

						SetPlayerPos(playerid, report_CurrentPos[playerid][0], report_CurrentPos[playerid][1], report_CurrentPos[playerid][2]);
						SetPlayerVirtualWorld(playerid, report_CurrentWorld[playerid]);
						SetPlayerInterior(playerid, report_CurrentInterior[playerid]);
						SetPlayerCameraPos(playerid, x, y, z);
						SetPlayerCameraLookAt(playerid, x + vx, y + vy, z + vz);

						ChatMsg(playerid, YELLOW, " >  Use /recam para resetar sua câmera");
					}
				}
			}
		}
	}
	else
		ShowReport(playerid, report_CurrentItem[playerid]);
}

ShowReportBanPrompt(playerid) {
	if(GetPlayerAdminLevel(playerid) < 3) {
		ChatMsg(playerid, RED, "Voc� n�o tem permissão para banir jogadores.");
		ShowReportOptions(playerid);

		return 0;
	}

	Dialog_Show(playerid, BanPrompt, DIALOG_STYLE_INPUT, "Insira a duração do banimento", "Digite a duração do banimento abaixo, insira o n�mero e o tempo. Exemplo: '1 days': 'days', 'weeks' ou 'months'. Escreva 'forever' para um ban permanente.", "Continar", "Cancelar");

	return 1;
}

Dialog:BanPrompt(playerid, response, listitem, inputtext[]) {
	if(response) {
		new const duration = isequal(inputtext, "forever", true) ? 0 : GetDurationFromString(inputtext);

		if(duration == -1) {
			ShowReportBanPrompt(playerid);
			return 0;
		}

		BanPlayerByName(report_CurrentReportList[playerid][report_CurrentItem[playerid]][report_name], report_CurrentReason[playerid], playerid, duration);
		ShowListOfReports(playerid);
	} else
		ShowReportOptions(playerid);

	return 0;
}

/* hook OnPlayerDialogPage(playerid, direction) {
	if(banlist_ViewingList[playerid]) {
		if(direction == 0) 
			banlist_CurrentIndex[playerid] -= MAX_BANS_PER_PAGE;
		else 
			banlist_CurrentIndex[playerid] += MAX_BANS_PER_PAGE;

		ShowListOfBans(playerid, banlist_CurrentIndex[playerid]);
	}
} */