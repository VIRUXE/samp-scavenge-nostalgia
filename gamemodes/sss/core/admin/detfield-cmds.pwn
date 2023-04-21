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


#include <YSI\y_hooks>


#define MAX_DETFIELD_PAGESIZE		(20)
#define MAX_DETFIELD_LOG_PAGESIZE	(32)


// dfm = detection field management

enum
{
	DFM_MENU_DFLIST,
	DFM_MENU_DFOPTS,
	DFM_MENU_EXCEPTIONS,
	DFM_MENU_EXCEPTION_OPTIONS,
	DFM_MENU_EXCEPTION_ADD,
	DFM_MENU_EXCEPTION_DEL,
	DFM_MENU_DFRENAME,
	DFM_MENU_DFDELETE,
	DFM_MENU_DFLOG,
	DFM_MENU_LOGOPTS
}


static
		dfm_CurrentLogEntry [MAX_PLAYERS],
		dfm_CurrentMenu		[MAX_PLAYERS],
		dfm_CurrentDetfield	[MAX_PLAYERS],
		dfm_CurrentException[MAX_PLAYERS],
		// Field list
		dfm_FieldList		[MAX_PLAYERS][MAX_DETFIELD_PAGESIZE],
		dfm_PageIndex		[MAX_PLAYERS],
		// Log list
		dfm_LogIndex		[MAX_PLAYERS],
		dfm_LogBuffer		[MAX_PLAYERS][MAX_DETFIELD_LOG_PAGESIZE][E_DETLOG_BUFFER_DATA],
		// Adding
bool:	dfm_Editing			[MAX_PLAYERS],
		dfm_Name			[MAX_PLAYERS][MAX_DETFIELD_NAME],
Float:	dfm_Points			[MAX_PLAYERS][10],
		dfm_CurrentPoint	[MAX_PLAYERS],
Float:	dfm_MinZ			[MAX_PLAYERS],
Float:	dfm_MaxZ			[MAX_PLAYERS],
		dfm_Exceptions		[MAX_PLAYERS][MAX_DETFIELD_EXCEPTIONS][MAX_PLAYER_NAME];


hook OnPlayerConnect(playerid)
{
	dbg("global", CORE, "[OnPlayerConnect] in /gamemodes/sss/core/admin/detfield-cmds.pwn");

	for(new i; i < MAX_DETFIELD_PAGESIZE; i++)
		dfm_FieldList[playerid][i] = -1;

	dfm_CurrentMenu[playerid]		= -1;
	dfm_CurrentDetfield[playerid]	= -1;

	dfm_LogIndex[playerid]			= 0;
	dfm_PageIndex[playerid]			= 0;
	dfm_Editing[playerid]			= false;
	dfm_Name[playerid][0]			= EOS;
	dfm_Points[playerid]			= Float:{0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0};
	dfm_MinZ[playerid]				= 0.0;
	dfm_MaxZ[playerid]				= 0.0;
}

ACMD:field[2](playerid, params[])
{
	if(isnull(params))
	{
		ChatMsg(playerid, YELLOW, " >  Use: /field lista/add/remover/log");
		return 1;
	}

	if(!strcmp(params, "lista", true, 4))
	{
		new ret = ShowDetfieldList(playerid);

		if(ret == 0)
			ChatMsg(playerid, YELLOW, " >  Não há fields existentes.");
	}

	if(!strcmp(params, "log", true, 3))
	{
		new
			name[MAX_DETFIELD_NAME],
			id;

		if(sscanf(params, "{s[4]}s[24]", name))
		{
			ChatMsg(playerid, YELLOW, " >  Use: /field log [Nome]");
			return 1;
		}

		id = GetDetectionFieldIdFromName(name);

		if(!IsValidDetectionField(id))
		{
			ChatMsg(playerid, YELLOW, " >  Nome de field não existente");
			return 1;
		}


		new ret = ShowDetfieldLog(playerid, id);

		if(ret == 1) ChatMsg(playerid, YELLOW, " >  Exibindo log de entradas para a field: '%s'.", name);

		else ChatMsg(playerid, YELLOW, " >  Não há log de entradas na field: '%s'.", name);
	}

	if(!strcmp(params, "add", true, 3))
	{
		new name[MAX_DETFIELD_NAME];

		if(sscanf(params, "{s[4]}s[24]", name))
		{
			ChatMsg(playerid, YELLOW, " >  Use: /field add [Nome]");
			return 1;
		}

		GetPlayerPos(playerid, dfm_MinZ[playerid], dfm_MinZ[playerid], dfm_MinZ[playerid]);

		dfm_Editing[playerid] = true;
		dfm_Name[playerid] = name;
		dfm_MinZ[playerid] -= 1.0;
		dfm_MaxZ[playerid] = dfm_MinZ[playerid] + 3.5;
		dfm_CurrentPoint[playerid] = 0;

		AddNewDetectionFieldPoint(playerid);

		return 1;
	}

	if(!strcmp(params, "remover", true, 6))
	{
		new
			name[MAX_DETFIELD_NAME],
			id;

		if(sscanf(params, "{s[7]}s[24]", name))
		{
			ChatMsg(playerid, YELLOW, " >  Use: /field remover [Nome]");
			return 1;
		}

		id = GetDetectionFieldIdFromName(name);

		if(!IsValidDetectionField(id))
		{
			ChatMsg(playerid, YELLOW, " >  Nome de field não existente");
			return 1;
		}
        dfm_CurrentDetfield[playerid] = id;
		ShowDetfieldDeletePrompt(playerid, id);
	}

	if(!strcmp(params, "rename", true, 6))
	{
		new
			name[MAX_DETFIELD_NAME],
			id;

		if(sscanf(params, "{s[7]}s[24]", name))
		{
			ChatMsg(playerid, YELLOW, " >  Use: /field remover [Nome]");
			return 1;
		}

		id = GetDetectionFieldIdFromName(name);

		if(!IsValidDetectionField(id))
		{
			ChatMsg(playerid, YELLOW, " >  Nome de field não existente");
			return 1;
		}

		ShowDetfieldRenamePrompt(playerid, id);
	}

	if(!strcmp(params, "nome", true, 4))
	{
		new name[MAX_PLAYER_NAME];

		if(sscanf(params, "{s[8]}s[24]", name))
		{
			ChatMsg(playerid, YELLOW, " >  Use: /field nome [Nome]");
			return 1;
		}

		new count = ShowDetfieldNameFields(playerid, name);

		if(count == 0) ChatMsg(playerid, YELLOW, " >  Não há registro de field encontradas em: '"C_BLUE"%s"C_YELLOW"'.", name);
	}

	return 1;
}

ShowDetfieldList(playerid)
{
	dfm_CurrentMenu[playerid] = DFM_MENU_DFLIST;

	new
		total,
		count,
		title[34],
		list[MAX_DETFIELD_PAGESIZE * (MAX_DETFIELD_NAME + 1)];

	total = GetTotalDetectionFields();
	count = GetDetectionFieldList(dfm_FieldList[playerid], list, MAX_DETFIELD_PAGESIZE, dfm_PageIndex[playerid]);

	if(count == 0)
	{
		dfm_PageIndex[playerid] = 0;
		return 0;
	}

	format(title, sizeof(title), "Lista de Fields (%d-%d of %d)",
		dfm_PageIndex[playerid],
		(dfm_PageIndex[playerid] + count > total) ? (total) : (dfm_PageIndex[playerid] + count),
		total);

	ShowPlayerPageButtons(playerid);
    
	Dialog_Show(playerid, DetfieldList, DIALOG_STYLE_LIST, title, list, "Opções", "Fechar");

	return 1;
}

Dialog:DetfieldList(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		dfm_CurrentDetfield[playerid] = dfm_FieldList[playerid][listitem];
		ShowDetfieldListOptions(playerid, dfm_FieldList[playerid][listitem]);
		HidePlayerPageButtons(playerid);
		CancelSelectTextDraw(playerid);
	}
	else
	{
		for(new i; i < MAX_DETFIELD_PAGESIZE; i++)
			dfm_FieldList[playerid][i] = -1;

		dfm_CurrentMenu[playerid]		= -1;
		dfm_CurrentDetfield[playerid]	= -1;
		dfm_LogIndex[playerid]			= 0;
		dfm_PageIndex[playerid]			= 0;

		HidePlayerPageButtons(playerid);
		CancelSelectTextDraw(playerid);
	}
}

ShowDetfieldListOptions(playerid, detfieldid)
{
	if(!IsValidDetectionField(detfieldid))
		return 0;

	dfm_CurrentMenu[playerid] = DFM_MENU_DFOPTS;

	new
		name[MAX_DETFIELD_NAME],
		exceptioncount;

	GetDetectionFieldName(detfieldid, name);
	exceptioncount = GetDetectionFieldExceptionCount(detfieldid);

	Dialog_Show(playerid, DetfieldListOptions, DIALOG_STYLE_LIST, name, sprintf("Ver Log\nIr\nexceções (%d)\nRenomear\nDeletar", exceptioncount), "Selecionar", "Voltar");

	return 1;
}

Dialog:DetfieldListOptions(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		switch(listitem)
		{
			case 0:
			{
				if(!ShowDetfieldLog(playerid, dfm_CurrentDetfield[playerid]))
				{
					new name[MAX_DETFIELD_NAME];

					GetDetectionFieldName(dfm_CurrentDetfield[playerid], name);
					ChatMsg(playerid, YELLOW, " >  Não há log de entradas em: '%s'.", name);
					ShowDetfieldListOptions(playerid, dfm_CurrentDetfield[playerid]);
				}
			}

			case 1:
			{
				if(IsPlayerOnAdminDuty(playerid))
				{
					new
						Float:x,
						Float:y,
						Float:z;

					GetDetectionFieldPos(dfm_CurrentDetfield[playerid], x, y, z);
					SetPlayerPos(playerid, x, y, z);
				}
				else ChatMsg(playerid, RED, "server/command/need-duty");
			}

			case 2: ShowDetfieldExceptions(playerid, dfm_CurrentDetfield[playerid]);
			case 3: ShowDetfieldRenamePrompt(playerid, dfm_CurrentDetfield[playerid]);
			case 4:ShowDetfieldDeletePrompt(playerid, dfm_CurrentDetfield[playerid]);
		}
	}
	else ShowDetfieldList(playerid);
}

ShowDetfieldExceptions(playerid, detfieldid)
{
	if(!IsValidDetectionField(detfieldid))
		return 0;

	dfm_CurrentMenu[playerid] = DFM_MENU_EXCEPTIONS;

	new name[MAX_DETFIELD_NAME];
	GetDetectionFieldName(detfieldid, name);

	if(GetDetectionFieldExceptionCount(detfieldid) == 0)
	{
		ChatMsg(playerid, YELLOW, " >  Não há exceções em: '%s'.", name);
		ShowDetfieldListOptions(playerid, detfieldid);
		return 0;
	}

	new
		list[MAX_DETFIELD_EXCEPTIONS * (MAX_PLAYER_NAME + 3)],
		count;

	count = GetDetectionFieldExceptionsList(detfieldid, list, sizeof(list), '\n');

	Dialog_Show(playerid, DetfieldExceptions, DIALOG_STYLE_LIST, sprintf("%s Exceções (%d)", name, count), list, "Opções", "Voltar");

	return 1;
}

Dialog:DetfieldExceptions(playerid, response, listitem, inputtext[])
{
	if(response) ShowDetfieldExceptionOptions(playerid, dfm_CurrentDetfield[playerid], listitem);

	else ShowDetfieldListOptions(playerid, dfm_CurrentDetfield[playerid]);
}

ShowDetfieldExceptionOptions(playerid, detfieldid, exceptionid)
{
	if(!IsValidDetectionField(detfieldid))
		return 0;

	dfm_CurrentMenu[playerid] = DFM_MENU_EXCEPTION_OPTIONS;
	dfm_CurrentException[playerid] = exceptionid;

	new name[MAX_PLAYER_NAME];

	GetDetectionFieldExceptionName(detfieldid, exceptionid, name);

	Dialog_Show(playerid, DetfieldExceptionOpts, DIALOG_STYLE_LIST, name, sprintf("Adicionar Exceção\nDeletar '%s'", name), "Selecionar", "Voltar");

	return 1;
}

Dialog:DetfieldExceptionOpts(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		switch(listitem)
		{
			case 0: ShowDetfieldAddException(playerid, dfm_CurrentDetfield[playerid]);
			case 1: ShowDetfieldDeleteException(playerid, dfm_CurrentDetfield[playerid]);
		}
	}
	else ShowDetfieldExceptions(playerid, dfm_CurrentDetfield[playerid]);
}

ShowDetfieldAddException(playerid, detfieldid)
{
	if(!IsValidDetectionField(detfieldid))
		return 0;

	dfm_CurrentMenu[playerid] = DFM_MENU_EXCEPTION_ADD;

	new name[MAX_DETFIELD_NAME];
	GetDetectionFieldName(detfieldid, name);

	Dialog_Show(playerid, DetfieldAddExc, DIALOG_STYLE_INPUT, sprintf("Adicionar Exceção para: %s", name), "Escreva o nome do usuário:", "Adicionar", "Voltar");

	return 1;
}

Dialog:DetfieldAddExc(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new tmp[MAX_PLAYER_NAME];
		strcat(tmp, inputtext);

		new ret = AddDetectionFieldException(dfm_CurrentDetfield[playerid], tmp);

		if(ret)
		{
			ShowDetfieldExceptions(playerid, dfm_CurrentDetfield[playerid]);
			return 1;
		}

		if(ret == 0)
		{
			ChatMsg(playerid, RED, " >  Field inválida");
			ShowDetfieldAddException(playerid, dfm_CurrentDetfield[playerid]);
		}

		if(ret == -1)
		{
			ChatMsg(playerid, RED, " >  Lista de exceções cheia)");
			ShowDetfieldExceptionOptions(playerid, dfm_CurrentDetfield[playerid], dfm_CurrentException[playerid]);
		}

		if(ret == -2)
		{
			ChatMsg(playerid, RED, " >  Nome inválido");
			ShowDetfieldAddException(playerid, dfm_CurrentDetfield[playerid]);
		}

		if(ret == -3)
		{
			ChatMsg(playerid, RED, " >  Jogador já está na lista");
			ShowDetfieldAddException(playerid, dfm_CurrentDetfield[playerid]);
		}
	}
	else ShowDetfieldExceptionOptions(playerid, dfm_CurrentDetfield[playerid], dfm_CurrentException[playerid]);

	return 0;
}

ShowDetfieldDeleteException(playerid, detfieldid)
{
	if(!IsValidDetectionField(detfieldid))
		return 0;

	dfm_CurrentMenu[playerid] = DFM_MENU_EXCEPTION_DEL;

	new name[MAX_PLAYER_NAME];

	GetDetectionFieldExceptionName(detfieldid, dfm_CurrentException[playerid], name);

	Dialog_Show(playerid, DetfieldDeleteExc, DIALOG_STYLE_MSGBOX, sprintf("Deletar '%s'", name), "Você tem certeza?", "Voltar", "Deletar");

	return 1;
}

Dialog:DetfieldDeleteExc(playerid, response, listitem, inputtext[])
{
	if(!response)
		RemoveDetectionFieldExceptionID(dfm_CurrentDetfield[playerid], dfm_CurrentException[playerid]);

	ShowDetfieldExceptions(playerid, dfm_CurrentDetfield[playerid]);
	return 0;
}

ShowDetfieldRenamePrompt(playerid, detfieldid)
{
	if(!IsValidDetectionField(detfieldid))
		return 0;

	dfm_CurrentMenu[playerid] = DFM_MENU_DFRENAME;

	new name[MAX_DETFIELD_NAME];

	GetDetectionFieldName(detfieldid, name);

	Dialog_Show(playerid, DetfieldRename, DIALOG_STYLE_INPUT, sprintf("Renomear %s", name), "Escreva o novo nome:", "Renomear", "Voltar");

	return 1;
}

Dialog:DetfieldRename(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new
			tmp[MAX_DETFIELD_NAME],
			ret;

		strcat(tmp, inputtext);

		ret = SetDetectionFieldName(dfm_CurrentDetfield[playerid], tmp);

		if(ret == -1)
			ChatMsg(playerid, RED, " >  Já possuí uma field existente com este nome.");

		if(ret == -2)
			ChatMsg(playerid, RED, " >  Nome de field inválida. Deve começar com um caractere alfabético e pode conter apenas caracteres alfanuméricos.");
	}

	ShowDetfieldListOptions(playerid, dfm_CurrentDetfield[playerid]);
}

ShowDetfieldDeletePrompt(playerid, detfieldid)
{
	if(!IsValidDetectionField(detfieldid))
		return 0;

	dfm_CurrentMenu[playerid] = DFM_MENU_DFDELETE;

	new name[MAX_DETFIELD_NAME];

	GetDetectionFieldName(detfieldid, name);

	Dialog_Show(playerid, DetfieldDelete, DIALOG_STYLE_MSGBOX, sprintf("Deletar %s", name), "Você tem certeza?", "Voltar", "Deletar");

	return 1;
}

Dialog:DetfieldDelete(playerid, response, listitem, inputtext[])
{
	if(!response)
	{
	    new name[MAX_DETFIELD_NAME];
	    new namep[24];
	    GetPlayerName(playerid, namep, 24);
	    GetDetectionFieldName(dfm_CurrentDetfield[playerid], name);
//	    ReportPlayer(namep, sprintf("Removeu a field '%s'", name), -1, "R_FIELD", 0.0,0.0,0.0, 0, 0, "");
		ChatMsgAdmins(1, BLUE, "[Admin-Log]: %s(id:%d) Deletou a field '%s'", namep, playerid, name);
	    RemoveDetectionField(dfm_CurrentDetfield[playerid]);
	}
	ShowDetfieldList(playerid);
}

ShowDetfieldLog(playerid, detfieldid)
{
	if(!IsValidDetectionField(detfieldid))
		return 0;

	dfm_CurrentMenu[playerid] = DFM_MENU_DFLOG;

	new
		list[MAX_DETFIELD_LOG_PAGESIZE * (MAX_DETFIELD_NAME + 1)],
		name[MAX_DETFIELD_NAME],
		title[MAX_DETFIELD_NAME + 32],
		count,
		total;

	count = GetDetectionFieldLogBuffer(detfieldid, dfm_LogBuffer[playerid], MAX_DETFIELD_LOG_PAGESIZE, dfm_LogIndex[playerid]);
	GetDetectionFieldName(detfieldid, name);
	total = GetDetectionFieldLogEntries(detfieldid);

	for(new i; i < count; i++)
	{
		format(list, sizeof(list), "%s%06d:%s %s (%.1f,%.1f,%.1f)\n",
			list,
			dfm_LogBuffer[playerid][i][DETLOG_BUFFER_ROW_ID],
			TimestampToDateTime(dfm_LogBuffer[playerid][i][DETLOG_BUFFER_DATE], "%d/%m/%y %X"),
			dfm_LogBuffer[playerid][i][DETLOG_BUFFER_NAME],
			dfm_LogBuffer[playerid][i][DETLOG_BUFFER_POS_X],
			dfm_LogBuffer[playerid][i][DETLOG_BUFFER_POS_Y],
			dfm_LogBuffer[playerid][i][DETLOG_BUFFER_POS_Z]);
	}

	format(title, sizeof(title), "%s (%d-%d of %d)", name, dfm_LogIndex[playerid], dfm_LogIndex[playerid] + count, total);

	if(count == 0)
	{
		dfm_LogIndex[playerid] = 0;
		return 0;
	}
	
    dfm_CurrentDetfield[playerid] = detfieldid;
    
	ShowPlayerPageButtons(playerid);

	Dialog_Show(playerid, DetfieldLog, DIALOG_STYLE_LIST, title, list, "Selecionar", "Voltar");

	return 1;
}

Dialog:DetfieldLog(playerid, response, listitem, inputtext[])
{
	if(response) ShowDetfieldLogOptions(playerid, dfm_CurrentDetfield[playerid], listitem);
	else ShowDetfieldListOptions(playerid, dfm_CurrentDetfield[playerid]);

	HidePlayerPageButtons(playerid);
	CancelSelectTextDraw(playerid);
}

ShowDetfieldLogOptions(playerid, detfieldid, logentry)
{
	if(!IsValidDetectionField(detfieldid))
		return 0;

	dfm_CurrentMenu[playerid] = DFM_MENU_LOGOPTS;

	new name[MAX_DETFIELD_NAME];

	GetDetectionFieldName(detfieldid, name);
    dfm_CurrentLogEntry[playerid] = logentry;
	Dialog_Show(playerid, DetfieldLogOpts, DIALOG_STYLE_LIST, name, "Ir\nDeletar\nDeletar todas desse jogador", "Selecionar", "Fechar");

	return 1;
}

Dialog:DetfieldLogOpts(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		switch(listitem)
		{
			case 0:
			{
				if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
				{
					SetPlayerPos(playerid,
						dfm_LogBuffer[playerid][dfm_CurrentLogEntry[playerid] ][DETLOG_BUFFER_POS_X],
						dfm_LogBuffer[playerid][dfm_CurrentLogEntry[playerid] ][DETLOG_BUFFER_POS_Y],
						dfm_LogBuffer[playerid][dfm_CurrentLogEntry[playerid] ][DETLOG_BUFFER_POS_Z]);
				}
				else ChatMsg(playerid, RED, "server/command/need-duty");
			}

			case 1:
			{
				DeleteDetectionFieldLogEntry(dfm_CurrentDetfield[playerid], dfm_LogBuffer[playerid][dfm_CurrentLogEntry[playerid] ][DETLOG_BUFFER_ROW_ID]);

				ShowDetfieldLog(playerid, dfm_CurrentDetfield[playerid]);
			}

			case 2:
			{
				DeleteDetectionFieldLogsOfName(dfm_CurrentDetfield[playerid], dfm_LogBuffer[playerid][dfm_CurrentLogEntry[playerid] ][DETLOG_BUFFER_NAME]);

				ShowDetfieldLog(playerid, dfm_CurrentDetfield[playerid]);
			}
		}
	}
	else
	{
		ShowDetfieldLog(playerid, dfm_CurrentDetfield[playerid]);
	}
}

ShowDetfieldNameFields(playerid, name[])
{
	new
		count,
		title[64],
		list[MAX_DETFIELD_PAGESIZE * (MAX_DETFIELD_NAME + 16)];

	count = GetDetectionFieldNameLog(name, list, MAX_DETFIELD_PAGESIZE, dfm_PageIndex[playerid], sizeof(list));

	format(title, sizeof(title), "%s (last %d fields from index %d)", name, count, dfm_PageIndex[playerid]);

	if(count == 0) return 0;

	// TODO: make proper pagination for this menu.
	ShowPlayerPageButtons(playerid);

	Dialog_Show(playerid, DetfieldName, DIALOG_STYLE_LIST, title, list, "Selecionar", "Voltar");

	return 1;
}

Dialog:DetfieldName(playerid, response, listitem, inputtext[])
{
	// TODO: do something with the data (jump to field log or something).
}

hook OnPlayerDialogPage(playerid, direction)
{
	dbg("global", CORE, "[OnPlayerDialogPage] in /gamemodes/sss/core/admin/detfield-cmds.pwn");

	if(dfm_CurrentMenu[playerid] == DFM_MENU_DFLIST)
	{
		if(direction == 0)
		{
			dfm_PageIndex[playerid] -= MAX_DETFIELD_PAGESIZE;

			if(dfm_PageIndex[playerid] < 0)
				dfm_PageIndex[playerid] = 0;
		}
		else dfm_PageIndex[playerid] += MAX_DETFIELD_PAGESIZE;

		ShowDetfieldList(playerid);
	}

	if(dfm_CurrentMenu[playerid] == DFM_MENU_DFLOG)
	{
		if(direction == 0)
		{
			dfm_LogIndex[playerid] -= MAX_DETFIELD_LOG_PAGESIZE;

			if(dfm_LogIndex[playerid] < 0)
				dfm_LogIndex[playerid] = 0;
		}
		else dfm_LogIndex[playerid] += MAX_DETFIELD_LOG_PAGESIZE;

		ShowDetfieldLog(playerid, dfm_CurrentDetfield[playerid]);
	}
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	dbg("global", CORE, "[OnPlayerKeyStateChange] in /gamemodes/sss/core/admin/detfield-cmds.pwn");

	if(dfm_Editing[playerid])
		if(newkeys == 128) AddNewDetectionFieldPoint(playerid);

	return 1;
}

AddNewDetectionFieldPoint(playerid)
{
	new Float:z;

	GetPlayerPos(playerid,
		dfm_Points[playerid][dfm_CurrentPoint[playerid] * 2],
		dfm_Points[playerid][(dfm_CurrentPoint[playerid] * 2) + 1],
		z);

	if(dfm_CurrentPoint[playerid] == 3)
	{
		dfm_Points[playerid][8] = dfm_Points[playerid][0];
		dfm_Points[playerid][9] = dfm_Points[playerid][1];

		GetPlayerName(playerid, dfm_Exceptions[playerid][0], MAX_PLAYER_NAME);

		dfm_Editing[playerid] = false;

		new ret = AddDetectionField(dfm_Name[playerid], dfm_Points[playerid], dfm_MinZ[playerid], dfm_MaxZ[playerid], dfm_Exceptions[playerid]);

		if(ret < 0) 
		ChatMsg(playerid, RED, " >  Ocorreu um erro ao fazer isto (code: %d)", ret);
		else
		{
			ChatMsg(playerid, YELLOW, " >  Ponto %d setado para %f, %f. Field '%s' criada.",
				dfm_CurrentPoint[playerid] + 1,
				dfm_Points[playerid][dfm_CurrentPoint[playerid] * 2],
				dfm_Points[playerid][(dfm_CurrentPoint[playerid] * 2) + 1],
				dfm_Name[playerid]);
		}
	}
	else ChatMsg(playerid, YELLOW, " >  Ponto %d setado para %f, %f. Mova para o próximo ponto e pressione "C_BLUE"~k~~PED_LOCK_TARGET~", dfm_CurrentPoint[playerid] + 1, dfm_Points[playerid][dfm_CurrentPoint[playerid] * 2], dfm_Points[playerid][(dfm_CurrentPoint[playerid] * 2) + 1]);

	dfm_CurrentPoint[playerid]++;
}
