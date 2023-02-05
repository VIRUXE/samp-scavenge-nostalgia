/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/


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

/*==============================================================================

	Relatorio

==============================================================================*/

static
bool: 	RelatorioTempo[MAX_PLAYERS],
		RelatorioTempo2[MAX_PLAYERS],
bool:	RelatorioEnviado[MAX_PLAYERS],
bool:   RelatorioBlock[MAX_PLAYERS];

ACMD:blockrr[1](playerid, params[]){
	new prid;
	if(sscanf(params, "d", prid)) return ChatMsg(playerid, RED, " > Use /blockrr [id]");
    RelatorioBlock[prid] = !RelatorioBlock[prid];
    if(RelatorioBlock[prid]) ChatMsg(playerid, YELLOW, " > Você bloqueou %p de usar o /relatorio!", prid);
    else ChatMsg(playerid, YELLOW, " > %p agora pode usar /relatorio", prid);
	return 1;
}

ACMD:rr[1](playerid, params[])
{
	new prid, msg[200];

	if(sscanf(params, "ds[200]", prid, msg)) return ChatMsg(playerid, RED, " > Use /rr [id] [Mensagem]");

	if(RelatorioEnviado[prid] == false) return ChatMsg(playerid, RED, " > Esse player não enviou nenhum relatório ou já foi respondido.");

    ChatMsg(prid, GREEN, "="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"=");

	new string[500];
	format(string, 500, "[Relatório] %p(id:%d) respondeu: "C_WHITE"%s", playerid, playerid, msg);
	ChatMsg(prid, GREEN, string);

	ChatMsg(prid, GREEN, "="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"="C_WHITE"="C_GREEN"=");

	format(string, 500, " > %p(id:%d) respondeu o relatório de %p(id:%d): %s", playerid, playerid, prid, prid, msg);
	ChatMsgAdmins(1, GREEN, string);

	RelatorioEnviado[prid] = RelatorioTempo[prid] = false, RelatorioTempo2[prid] = 100;
	return 1;
}
CMD:relatorio(playerid, params[])
{
    if(!IsPlayerLoggedIn(playerid))
	{
		ChatMsgLang(playerid, YELLOW, "LOGGEDINREQ");
		return 1;
	}
	
    if(RelatorioTempo[playerid] == true)
	{
		new string[128];
		format(string, 128, " > Aguarde"C_YELLOW" %d "C_RED"segundos para usar esse comando novamente.", RelatorioTempo2[playerid]);
		ChatMsg(playerid, RED, string);
		return 1;
	}

	if(RelatorioBlock[playerid]) return ChatMsg(playerid, RED, " > Aguarde para usar esse comando novamente.");
	
	new msg[200];

    if(sscanf(params, "s[200]", msg)) return ChatMsg(playerid, RED, " > Use /relatorio [mensagem]");

    ChatMsgAdmins(1, BLUE, "="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"=");
    ChatMsgAdmins(1, BLUE, "[Relatório]: %p(id:%d)"C_BLUE": "C_WHITE"%s", playerid, playerid, msg);
    ChatMsgAdmins(1, BLUE, "="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"=");
	RelatorioTempo[playerid] = true;
    RelatorioTempo2[playerid] = 80;
    RelatorioEnviado[playerid] = true;

    defer RelatorioFalse(playerid);

    ChatMsg(playerid, YELLOW, " > Relatório enviado com sucesso. Aguarde a administração do servidor.");
	return 1;
}

hook OnPlayerConnect(playerid){
	RelatorioBlock[playerid] = false;
}
timer RelatorioFalse[1000](playerid)
{
	if(RelatorioTempo2[playerid] > 0)
	{
        RelatorioTempo2[playerid] --;
        defer RelatorioFalse(playerid);
	}
	else
	{
	    RelatorioTempo[playerid] = false;
	}
}

/*==============================================================================

	Submitting reports

==============================================================================*/


CMD:report(playerid, params[]){
    if(GetPlayerAdminLevel(playerid) > 1)
        return ChatMsg(playerid, RED, " > Você não pode usar este comando.");
        
	ShowReportMenu(playerid);

	return 1;
}

ShowReportMenu(playerid)
{
	Dialog_Show(playerid, ReportMenu, DIALOG_STYLE_LIST, ""C_GREEN"Reportando...", "Especificar um ID que está online agora\nEspeficiar o nome do player\nReportar ultimo player que me matou\nReportar player mais próximo de mim", ""C_GREEN"Enviar", ""C_RED"Cancelar");
	return 1;
}

Dialog:ReportMenu(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		switch(listitem)
		{
			case 0: // Specific player ID (who is online now)
			{
				ShowReportOnlinePlayer(playerid);
				send_TargetType[playerid] = 1;
			}
			case 1: // Specific Player Name (Who isn't online now)
			{
				ShowReportOfflinePlayer(playerid);
				send_TargetType[playerid] = 2;
			}
			case 2: // Player that last killed me
			{
				new name[MAX_PLAYER_NAME];

				GetLastKilledBy(playerid, name);

				if(!isnull(name))
				{
					send_TargetName[playerid][0] = EOS;
					send_TargetName[playerid] = name;
				}
				else
				{
					GetLastHitBy(playerid, name);

					if(!isnull(name))
					{
						send_TargetName[playerid][0] = EOS;
						send_TargetName[playerid] = name;
					}
					else
					{
						ChatMsgLang(playerid, RED, "REPNOPFOUND");
						return 1;
					}
				}

				GetPlayerDeathPos(playerid, send_TargetPos[playerid][0], send_TargetPos[playerid][1], send_TargetPos[playerid][2]);
				send_TargetWorld[playerid] = -1;
				send_TargetInterior[playerid] = -1;

				ShowReportReasonInput(playerid);
				send_TargetType[playerid] = 3;
			}
			case 3: // Player closest to me
			{
				new
					Float:distance = 100.0,
					targetid;

				targetid = GetClosestPlayerFromPlayer(playerid, distance);

				if(!IsPlayerConnected(targetid))
				{
					targetid = playerid;
					return 1;
				}

				GetPlayerName(targetid, send_TargetName[playerid], MAX_PLAYER_NAME);
				GetPlayerPos(targetid, send_TargetPos[playerid][0], send_TargetPos[playerid][1], send_TargetPos[playerid][2]);
				send_TargetWorld[playerid] = GetPlayerVirtualWorld(targetid);
				send_TargetInterior[playerid] = GetPlayerInterior(targetid);

				ShowReportReasonInput(playerid);
				send_TargetType[playerid] = 4;
			}
		}
	}

	return 0;
}

ShowReportOnlinePlayer(playerid)
{
	new
		name[MAX_PLAYER_NAME],
		list[MAX_PLAYERS * (MAX_PLAYER_NAME + 1)];

	foreach(new i : Player)
	{
		GetPlayerName(i, name, MAX_PLAYER_NAME);
		strcat(list, name);
		strcat(list, "\n");
	}

	Dialog_Show(playerid, ReportOnlinePlayer, DIALOG_STYLE_LIST, "Reportar um player online", list, "Reportar", "Voltar");

	return 1;
}

Dialog:ReportOnlinePlayer(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		GetPlayerPos(playerid, send_TargetPos[playerid][0], send_TargetPos[playerid][1], send_TargetPos[playerid][2]);
		send_TargetWorld[playerid] = -1;
		send_TargetInterior[playerid] = -1;
		strmid(send_TargetName[playerid], inputtext, 0, strlen(inputtext));

		ShowReportReasonInput(playerid);
	}
	else
	{
		ShowReportMenu(playerid);
	}
}

ShowReportOfflinePlayer(playerid)
{
	Dialog_Show(playerid, ReportOfflinePlayer, DIALOG_STYLE_INPUT, "Reportar um player offline", "Insira o nome do jogador", "Reportar", "Voltar");

	return 1;
}

Dialog:ReportOfflinePlayer(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		send_TargetName[playerid][0] = EOS;
		strcat(send_TargetName[playerid], inputtext);

		send_TargetPos[playerid][0] = 0.0;
		send_TargetPos[playerid][1] = 0.0;
		send_TargetPos[playerid][2] = 0.0;
		send_TargetWorld[playerid] = -1;
		send_TargetInterior[playerid] = -1;

		ShowReportReasonInput(playerid);
	}
	else
	{
		ShowReportMenu(playerid);
	}
}

ShowReportReasonInput(playerid)
{
	Dialog_Show(playerid, ReportReasonInput, DIALOG_STYLE_INPUT, "Motivo do report", "Digite o motivo do seu relatï¿½rio abaixo.", "Reportar", "Voltar");
}

Dialog:ReportReasonInput(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new reporttype[MAX_REPORT_TYPE_LENGTH];

		switch(send_TargetType[playerid])
		{
			case 1: reporttype = REPORT_TYPE_PLAYER_ID;
			case 2: reporttype = REPORT_TYPE_PLAYER_NAME;
			case 3: reporttype = REPORT_TYPE_PLAYER_KILLER;
			case 4: reporttype = REPORT_TYPE_PLAYER_CLOSE;
		}
		ChatMsgAdmins(1, BLUE, "="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"=");
   		ChatMsgAdmins(1, BLUE, "[REPORT]: %p reportou %s motivo"C_BLUE": "C_WHITE"%s", playerid, send_TargetName[playerid], inputtext);
    	ChatMsgAdmins(1, BLUE, "="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"="C_WHITE"="C_BLUE"=");

		//ReportPlayer(send_TargetName[playerid], inputtext, playerid, reporttype, send_TargetPos[playerid][0], send_TargetPos[playerid][1], send_TargetPos[playerid][2], send_TargetWorld[playerid], send_TargetInterior[playerid], "");
	}
	else
	{
		ShowReportMenu(playerid);
	}
}


/*==============================================================================

	Reading reports

==============================================================================*/


ACMD:reports[1](playerid, params[])
{
	new ret;

	ret = ShowListOfReports(playerid);

	if(ret == 0)
		ChatMsg(playerid, YELLOW, " >  Não tem nenhum report para mostrar.");

	return 1;
}

ACMD:delreports[5](playerid){
	DeleteReadReports();
	ChatMsg(playerid, YELLOW, " >  Todos os reports lidos foram deletados.");
	return 1;
}

ShowListOfReports(playerid)
{
	new totalreports = GetReportList(report_CurrentReportList[playerid]);

	if(totalreports == 0)
		return 0;

	new
		colour[9],
		string[(8 + MAX_PLAYER_NAME + 13 + 1) * MAX_REPORTS_PER_PAGE],
		idx;

	while(idx < totalreports && idx < MAX_REPORTS_PER_PAGE)
	{
		if(!strcmp(report_CurrentReportList[playerid][idx][report_type], "R_FIELD"))
            colour = "{33AA33}";
            
		else if(IsPlayerBanned(report_CurrentReportList[playerid][idx][report_name]))
			colour = "{FF0000}";

		else if(!report_CurrentReportList[playerid][idx][report_read])
			colour = "{FFFF00}";

		else
			colour = "{FFFFFF}";

		format(string, sizeof(string), "%s%s%s (%s)\n", string, colour, report_CurrentReportList[playerid][idx][report_name], report_CurrentReportList[playerid][idx][report_type]);

		idx++;
	}

	ShowPlayerPageButtons(playerid);

	Dialog_Show(playerid, ListOfReports, DIALOG_STYLE_LIST, "Reports", string, "Abrir", "Fechar");

	return 1;
}

Dialog:ListOfReports(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		ShowReport(playerid, listitem);
		HidePlayerPageButtons(playerid);
		report_CurrentItem[playerid] = listitem;
	}
}


ShowReport(playerid, reportlistitem)
{
	new
		ret,
		timestamp,
		reporter[MAX_PLAYER_NAME];

	ret = GetReportInfo(report_CurrentReportList[playerid][reportlistitem][report_rowid],
		report_CurrentReason[playerid],
		timestamp, report_CurrentType[playerid],
		report_CurrentPos[playerid][0],
		report_CurrentPos[playerid][1],
		report_CurrentPos[playerid][2],
		report_CurrentWorld[playerid],
		report_CurrentInterior[playerid],
		report_CurrentInfo[playerid],
		reporter);

	if(!ret)
		return 0;

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

Dialog:Report(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		ShowReportOptions(playerid);
	}
	else
	{
		ShowListOfReports(playerid);
	}
}

ShowReportOptions(playerid)
{
	new options[128];

	options = "Banir\nDeletar\nDeletar reports do jogador\nDeixar lido\n";

	if((IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) == STAFF_LEVEL_DEVELOPER)
	{
		strcat(options, "Ir para a posição do report\n");

		if(!strcmp(report_CurrentType[playerid], "TELE"))
		{
			strcat(options, "Ir para o destino de teleporte\n");
		}

		if(!strcmp(report_CurrentType[playerid], "CAM"))
		{
			strcat(options, "Ir para o local da câmera\n");
			strcat(options, "Ver a câmera\n");
		}

		if(!strcmp(report_CurrentType[playerid], "VTP"))
		{
			strcat(options, "Ir para a posição do veículo\n");
		}
	}

	HidePlayerPageButtons(playerid);

	Dialog_Show(playerid, ReportOptions, DIALOG_STYLE_LIST, report_CurrentReportList[playerid][report_CurrentItem[playerid]][report_name], options, "Selecionar", "Voltar");
}

Dialog:ReportOptions(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		switch(listitem)
		{
			case 0:
			{
				ShowReportBanPrompt(playerid);
			}
			case 1:
			{
				DeleteReport(report_CurrentReportList[playerid][report_CurrentItem[playerid]][report_rowid]);

				ShowListOfReports(playerid);
			}
			case 2:
			{
				DeleteReportsOfPlayer(report_CurrentReportList[playerid][report_CurrentItem[playerid]][report_name]);

				ShowListOfReports(playerid);
			}
			case 3:
			{
				SetReportRead(report_CurrentReportList[playerid][report_CurrentItem[playerid]][report_rowid], 0);

				ShowListOfReports(playerid);
			}
			case 4:
			{
				if(IsPlayerOnAdminDuty(playerid))
				{
					SetPlayerPos(playerid, report_CurrentPos[playerid][0], report_CurrentPos[playerid][1], report_CurrentPos[playerid][2]);
					SetPlayerVirtualWorld(playerid, report_CurrentWorld[playerid]);
					SetPlayerInterior(playerid, report_CurrentInterior[playerid]);
				}
			}
			case 5:
			{
				if(!strcmp(report_CurrentType[playerid], "TELE"))
				{
					if(IsPlayerOnAdminDuty(playerid))
					{
						new
							Float:x,
							Float:y,
							Float:z;

						sscanf(report_CurrentInfo[playerid], "p<,>fff", x, y, z);
						SetPlayerPos(playerid, x, y, z);
						SetPlayerVirtualWorld(playerid, report_CurrentWorld[playerid]);
						SetPlayerInterior(playerid, report_CurrentInterior[playerid]);
					}
				}

				if(!strcmp(report_CurrentType[playerid], "CAM"))
				{
					if(IsPlayerOnAdminDuty(playerid))
					{
						new
							Float:x,
							Float:y,
							Float:z;

						sscanf(report_CurrentInfo[playerid], "p<,>fff{fff}", x, y, z);
						SetPlayerPos(playerid, x, y, z);
						SetPlayerVirtualWorld(playerid, report_CurrentWorld[playerid]);
						SetPlayerInterior(playerid, report_CurrentInterior[playerid]);
					}
				}

				if(!strcmp(report_CurrentType[playerid], "VTP"))
				{
					if(IsPlayerOnAdminDuty(playerid))
					{
						new
							Float:x,
							Float:y,
							Float:z;

						sscanf(report_CurrentInfo[playerid], "p<,>fff", x, y, z);
						SetPlayerPos(playerid, x, y, z);
						SetPlayerVirtualWorld(playerid, report_CurrentWorld[playerid]);
						SetPlayerInterior(playerid, report_CurrentInterior[playerid]);
					}
				}
			}
			case 6:
			{
				if(!strcmp(report_CurrentType[playerid], "CAM"))
				{
					if(IsPlayerOnAdminDuty(playerid))
					{
						new
							Float:x,
							Float:y,
							Float:z,
							Float:vx,
							Float:vy,
							Float:vz;

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
	{
		ShowReport(playerid, report_CurrentItem[playerid]);
	}
}

ShowReportBanPrompt(playerid)
{
	if(GetPlayerAdminLevel(playerid) < 3)
	{
		ChatMsg(playerid, RED, "Você não tem permissão para banir jogadores.");
		ShowReportOptions(playerid);

		return 0;
	}

	Dialog_Show(playerid, BanPrompt, DIALOG_STYLE_INPUT, "Insira a duração do banimento", "Digite a duração do banimento abaixo, insira o número e o tempo. Exemplo: '1 days': 'days', 'weeks' ou 'months'. Escreva 'forever' para um ban permanente.", "Continar", "Cancelar");

	return 1;
}

Dialog:BanPrompt(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new duration;

		if(!strcmp(inputtext, "forever", true))
			duration = 0;

		else
			duration = GetDurationFromString(inputtext);

		if(duration == -1)
		{
			ShowReportBanPrompt(playerid);
			return 0;
		}

		BanPlayerByName(report_CurrentReportList[playerid][report_CurrentItem[playerid]][report_name], report_CurrentReason[playerid], playerid, duration);
		ShowListOfReports(playerid);
	}
	else
	{
		ShowReportOptions(playerid);
	}

	return 0;
}
