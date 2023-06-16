#include <YSI\y_hooks>

#define MAX_DETFIELD_PAGESIZE		(20)
#define MAX_DETFIELD_LOG_PAGESIZE	(32)

// dfm = detection field management
enum {
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


hook OnPlayerConnect(playerid) {
	for(new i; i < MAX_DETFIELD_PAGESIZE; i++) dfm_FieldList[playerid][i] = -1;

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

CMD:field(playerid, params[]) {
	new command[8];

	if(sscanf(params, "s[8] ", command)) return ChatMsg(playerid, YELLOW, GetPlayerAdminLevel(playerid) >= STAFF_LEVEL_MODERATOR ? " >  Use: /field lista/add/remover/log" : " >  Use: /field add [nome]");

	if(isequal(command, "lista", true)) {
		if(GetPlayerAdminLevel(playerid) < STAFF_LEVEL_MODERATOR) return CMD_NOT_ADMIN;

		if(!ShowDetfieldList(playerid)) return ChatMsg(playerid, YELLOW, " >  Não existem fields.");
	} else if(isequal(command, "log", true)) {
		if(GetPlayerAdminLevel(playerid) < STAFF_LEVEL_MODERATOR) return CMD_NOT_ADMIN;

		new fieldName[MAX_DETFIELD_NAME];

		if(sscanf(params, "{s[4]}s[24]", fieldName)) return ChatMsg(playerid, YELLOW, " >  Use: /field log [Nome]");

		new id = GetDetectionFieldIdFromName(fieldName);

		if(!IsValidDetectionField(id)) return ChatMsg(playerid, YELLOW, " >  Nome de field não existente");

		ChatMsg(playerid, YELLOW, ShowDetfieldLog(playerid, id) ? " >  Exibindo log de entradas para a field: '%s'." : " >  Não há log de entradas na field: '%s'.", fieldName);
	} else if(isequal(command, "add", true)) {
		new sintax[] = " >  Use: /field add [nome (Exemplo: 'Nickname-Cidade_Local_Outro')]";
		new fieldName[MAX_DETFIELD_NAME];

		if(sscanf(params, "{s[4]}s[24]", fieldName)) return ChatMsg(playerid, YELLOW, sintax);

		if(!IsValidDetectionFieldName(fieldName)) return ChatMsg(playerid, YELLOW, sintax);

		GetPlayerPos(playerid, dfm_MinZ[playerid], dfm_MinZ[playerid], dfm_MinZ[playerid]);

		dfm_Editing[playerid]       = true;
		dfm_Name[playerid]          = fieldName;
		dfm_MinZ[playerid]         -= 1.0;
		dfm_MaxZ[playerid]          = dfm_MinZ[playerid] + 3.5;
		dfm_CurrentPoint[playerid]  = 0;

		AddNewDetectionFieldPoint(playerid);
	} else if(isequal(command, "remover", true)) {
		new const detfieldId = IsPlayerInsideDetectionField(playerid);

		if(detfieldId == -1) SendClientMessage(playerid, RED, "Você não está dentro de uma Detection Field.");

		if(!IsPlayerDetectionFieldOwner(playerid, detfieldId) && (GetPlayerAdminLevel(playerid) < STAFF_LEVEL_MODERATOR || !IsPlayerOnAdminDuty(playerid))) return SendClientMessage(playerid, RED, "Você não pode remover essa Detection Field.");

		dfm_CurrentDetfield[playerid] = detfieldId;
		ShowDetfieldDeletePrompt(playerid, detfieldId);
	} else if(isequal(command, "rename", true)) {
		if(GetPlayerAdminLevel(playerid) < STAFF_LEVEL_MODERATOR) return CMD_NOT_ADMIN;

		new fieldName[MAX_DETFIELD_NAME];

		if(sscanf(params, "{s[7]}s[24]", fieldName)) return ChatMsg(playerid, YELLOW, " >  Use: /field rename [Nome]");

		new id = GetDetectionFieldIdFromName(fieldName);

		if(!IsValidDetectionField(id)) return ChatMsg(playerid, YELLOW, " >  Nome de field não existente");

		ShowDetfieldRenamePrompt(playerid, id);
	} else if(isequal(command, "ex", true)) {
		new const detfieldId = IsPlayerInsideDetectionField(playerid);

		if(detfieldId == -1) SendClientMessage(playerid, RED, "Você não está dentro de uma Detection Field.");

		if(!IsPlayerDetectionFieldOwner(playerid, detfieldId) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_MODERATOR) return CMD_CANT_USE;

		new playerName[MAX_PLAYER_NAME];

		if(sscanf(params, "{s[3]}s[*]", MAX_PLAYER_NAME, playerName)) return ChatMsg(playerid, YELLOW, " >  Use /field ex [id/nick]");

		if(isnumeric(playerName)) {
			new targetId = strval(playerName);

			if(IsPlayerConnected(targetId)) GetPlayerName(targetId, playerName, MAX_PLAYER_NAME); else return CMD_INVALID_PLAYER;
		}

		if(!AccountExists(playerName)) return ChatMsg(playerid, YELLOW, " >  Conta '%s' não existente.", playerName);

		new result = AddDetectionFieldException(detfieldId, playerName);

		if(result) return ChatMsg(playerid, GREEN, " > "C_WHITE"%s "C_GREEN"adicionado a field com sucesso!", playerName);
		else if(result == -1) return ChatMsg(playerid, RED, " >  Lista de exceções cheias");
		else if(result == -2) return ChatMsg(playerid, RED, " >  Nome inválido ");
		else if(result == -3) return ChatMsg(playerid, RED, " >  Esse jogador já está na lista");

		UpdateDetectionFieldExceptions(detfieldId);
	} else if(isequal(command, "nome", true)) {
		if(GetPlayerAdminLevel(playerid) < STAFF_LEVEL_MODERATOR) return CMD_NOT_ADMIN;

		new fieldName[MAX_PLAYER_NAME];

		if(sscanf(params, "{s[8]}s[24]", fieldName)) return ChatMsg(playerid, YELLOW, " >  Use: /field nome [Nome]");

		if(ShowDetfieldNameFields(playerid, fieldName)) return ChatMsg(playerid, YELLOW, " >  Não há registro de field encontradas em: '"C_BLUE"%s"C_YELLOW"'.", fieldName);
	}

	return 1;
}

ShowDetfieldList(playerid) {
	dfm_CurrentMenu[playerid] = DFM_MENU_DFLIST;

	new list[MAX_DETFIELD_PAGESIZE * (MAX_DETFIELD_NAME + 1)];

	new const totalFields = GetTotalDetectionFields();
	new const count       = GetDetectionFieldList(dfm_FieldList[playerid], list, MAX_DETFIELD_PAGESIZE, dfm_PageIndex[playerid]);

	if(!count) {
		dfm_PageIndex[playerid] = 0;
		return 0;
	}

	ShowPlayerPageButtons(playerid);
    
	Dialog_Show(playerid, DetfieldList, DIALOG_STYLE_LIST, sprintf("Lista de Fields (%d-%d de %d)",
		dfm_PageIndex[playerid],
		(dfm_PageIndex[playerid] + count > totalFields) ? (totalFields) : (dfm_PageIndex[playerid] + count),
		totalFields), list, "Opções", "Fechar");

	return 1;
}

Dialog:DetfieldList(playerid, response, listitem, inputtext[]) {
	if(response) {
		dfm_CurrentDetfield[playerid] = dfm_FieldList[playerid][listitem];
		ShowDetfieldListOptions(playerid, dfm_FieldList[playerid][listitem]);
		HidePlayerPageButtons(playerid);
		CancelSelectTextDraw(playerid);
	} else {
		for(new i; i < MAX_DETFIELD_PAGESIZE; i++) dfm_FieldList[playerid][i] = -1;

		dfm_CurrentMenu[playerid]		= -1;
		dfm_CurrentDetfield[playerid]	= -1;
		dfm_LogIndex[playerid]			= 0;
		dfm_PageIndex[playerid]			= 0;

		HidePlayerPageButtons(playerid);
		CancelSelectTextDraw(playerid);
	}
}

ShowDetfieldListOptions(playerid, detfieldId) {
	if(!IsValidDetectionField(detfieldId)) return 0;

	dfm_CurrentMenu[playerid] = DFM_MENU_DFOPTS;

	new fieldName[MAX_DETFIELD_NAME];

	GetDetectionFieldName(detfieldId, fieldName);

	Dialog_Show(playerid, DetfieldListOptions, DIALOG_STYLE_LIST, fieldName,
		sprintf("%s\nVer Log\nTeleportar\nExcepções (%d)\nRenomear\nDeletar", IsDetectionFieldActive(detfieldId) ? "Desativar" : "Ativar", GetDetectionFieldExceptionCount(detfieldId)),
		"Selecionar", "Voltar");

	return 1;
}

Dialog:DetfieldListOptions(playerid, response, listitem, inputtext[]) {
	if(response) {
		switch(listitem) {
			case 0: { // Ativar ou Desativar
				SetDetectionFieldActive(dfm_CurrentDetfield[playerid], !IsDetectionFieldActive(dfm_CurrentDetfield[playerid]));
			}
			case 1: {
				if(!ShowDetfieldLog(playerid, dfm_CurrentDetfield[playerid])) {
					new fieldName[MAX_DETFIELD_NAME];

					GetDetectionFieldName(dfm_CurrentDetfield[playerid], fieldName);
					ChatMsg(playerid, YELLOW, " >  Não há log de entradas em: '%s'.", fieldName);
					ShowDetfieldListOptions(playerid, dfm_CurrentDetfield[playerid]);
				}
			}
			case 2: {
				if(IsPlayerOnAdminDuty(playerid)) {
					new Float:x, Float:y, Float:z;

					GetDetectionFieldPos(dfm_CurrentDetfield[playerid], x, y, z);
					SetPlayerPos(playerid, x, y, z);
				} else
					ChatMsg(playerid, RED, "server/command/need-duty");
			}
			case 3: ShowDetfieldExceptions(playerid, dfm_CurrentDetfield[playerid]);
			case 4: ShowDetfieldRenamePrompt(playerid, dfm_CurrentDetfield[playerid]);
			case 5: ShowDetfieldDeletePrompt(playerid, dfm_CurrentDetfield[playerid]);
		}
	} else
		ShowDetfieldList(playerid);
}

ShowDetfieldExceptions(playerid, detfieldId) {
	if(!IsValidDetectionField(detfieldId)) return 0;

	dfm_CurrentMenu[playerid] = DFM_MENU_EXCEPTIONS;

	new fieldName[MAX_DETFIELD_NAME];
	GetDetectionFieldName(detfieldId, fieldName);

	if(!GetDetectionFieldExceptionCount(detfieldId)) {
		ChatMsg(playerid, YELLOW, " >  Não há excepções em: '%s'.", fieldName);
		ShowDetfieldListOptions(playerid, detfieldId);
		return 0;
	}

	new list[MAX_DETFIELD_EXCEPTIONS * (MAX_PLAYER_NAME + 3)];

	Dialog_Show(playerid, DetfieldExceptions, DIALOG_STYLE_LIST, sprintf("%s - Excepções (%d)", fieldName, GetDetectionFieldExceptionsList(detfieldId, list, sizeof(list), '\n')), list, "Opções", "Voltar");

	return 1;
}

Dialog:DetfieldExceptions(playerid, response, listitem, inputtext[]) {
	if(response) 
		ShowDetfieldExceptionOptions(playerid, dfm_CurrentDetfield[playerid], listitem);
	else 
		ShowDetfieldListOptions(playerid, dfm_CurrentDetfield[playerid]);
}

ShowDetfieldExceptionOptions(playerid, detfieldId, exceptionId) {
	if(!IsValidDetectionField(detfieldId)) return 0;

	dfm_CurrentMenu[playerid]      = DFM_MENU_EXCEPTION_OPTIONS;
	dfm_CurrentException[playerid] = exceptionId;

	new fieldName[MAX_PLAYER_NAME];

	GetDetectionFieldExceptionName(detfieldId, exceptionId, fieldName);

	Dialog_Show(playerid, DetfieldExceptionOpts, DIALOG_STYLE_LIST, fieldName, sprintf("Adicionar Excepção\nDeletar '%s'", fieldName), "Selecionar", "Voltar");

	return 1;
}

Dialog:DetfieldExceptionOpts(playerid, response, listitem, inputtext[]) {
	if(response) {
		switch(listitem) {
			case 0: ShowDetfieldAddException(playerid, dfm_CurrentDetfield[playerid]);
			case 1: ShowDetfieldDeleteException(playerid, dfm_CurrentDetfield[playerid]);
		}
	} else
		ShowDetfieldExceptions(playerid, dfm_CurrentDetfield[playerid]);
}

ShowDetfieldAddException(playerid, detfieldId) {
	if(!IsValidDetectionField(detfieldId)) return 0;

	dfm_CurrentMenu[playerid] = DFM_MENU_EXCEPTION_ADD;

	new fieldName[MAX_DETFIELD_NAME];
	GetDetectionFieldName(detfieldId, fieldName);

	Dialog_Show(playerid, DetfieldAddExc, DIALOG_STYLE_INPUT, "Adicionar Excepção:", sprintf("Detection Field: %s\n\nEscreva o nome do jogador que quer adicionar:", fieldName), "Adicionar", "Voltar");

	return 1;
}

Dialog:DetfieldAddExc(playerid, response, listitem, inputtext[]) {
	if(response) {
		new tmp[MAX_PLAYER_NAME];
		strcat(tmp, inputtext);

		new result = AddDetectionFieldException(dfm_CurrentDetfield[playerid], tmp);

		if(result) {
			ShowDetfieldExceptions(playerid, dfm_CurrentDetfield[playerid]);
			return 1;
		}

		if(result == 0) {
			ChatMsg(playerid, RED, " >  Field inválida");
			ShowDetfieldAddException(playerid, dfm_CurrentDetfield[playerid]);
		} else if(result == -1) {
			ChatMsg(playerid, RED, " >  Lista de excepções cheia)");
			ShowDetfieldExceptionOptions(playerid, dfm_CurrentDetfield[playerid], dfm_CurrentException[playerid]);
		} else if(result == -2) {
			ChatMsg(playerid, RED, " >  Nome inválido");
			ShowDetfieldAddException(playerid, dfm_CurrentDetfield[playerid]);
		} else if(result == -3) {
			ChatMsg(playerid, RED, " >  Jogador já está na lista");
			ShowDetfieldAddException(playerid, dfm_CurrentDetfield[playerid]);
		}
	} else
		ShowDetfieldExceptionOptions(playerid, dfm_CurrentDetfield[playerid], dfm_CurrentException[playerid]);

	return 0;
}

ShowDetfieldDeleteException(playerid, detfieldId) {
	if(!IsValidDetectionField(detfieldId)) return 0;

	dfm_CurrentMenu[playerid] = DFM_MENU_EXCEPTION_DEL;

	new fieldName[MAX_PLAYER_NAME];

	GetDetectionFieldExceptionName(detfieldId, dfm_CurrentException[playerid], fieldName);

	Dialog_Show(playerid, DetfieldDeleteExc, DIALOG_STYLE_MSGBOX, sprintf("Deletar '%s'", fieldName), "Você tem certeza?", "Voltar", "Deletar");

	return 1;
}

Dialog:DetfieldDeleteExc(playerid, response, listitem, inputtext[]) {
	if(!response) RemoveDetectionFieldExceptionID(dfm_CurrentDetfield[playerid], dfm_CurrentException[playerid]);

	ShowDetfieldExceptions(playerid, dfm_CurrentDetfield[playerid]);

	return 0;
}

ShowDetfieldRenamePrompt(playerid, detfieldId) {
	if(!IsValidDetectionField(detfieldId)) return 0;

	dfm_CurrentMenu[playerid] = DFM_MENU_DFRENAME;

	new fieldName[MAX_DETFIELD_NAME];

	GetDetectionFieldName(detfieldId, fieldName);

	Dialog_Show(playerid, DetfieldRename, DIALOG_STYLE_INPUT, "Renomear Field", sprintf("Nome atual: %s\n\nEscreva o novo nome:", fieldName), "Renomear", "Voltar");

	return 1;
}

Dialog:DetfieldRename(playerid, response, listitem, inputtext[]) {
	if(response) {
		new tmp[MAX_DETFIELD_NAME];

		strcat(tmp, inputtext); // MAX_DETFIELD_NAME limit

		new result = SetDetectionFieldName(dfm_CurrentDetfield[playerid], tmp);

		if(result == -1)
			ChatMsg(playerid, RED, " >  Já possui uma field existente com este nome.");
		else if(result == -2)
			ChatMsg(playerid, RED, " >  Nome de field inválida. Deve começar com um caracter alfabético e pode conter apenas caracteres alfanuméricos.");
	}

	ShowDetfieldListOptions(playerid, dfm_CurrentDetfield[playerid]);
}

ShowDetfieldDeletePrompt(playerid, detfieldId) {
	if(!IsValidDetectionField(detfieldId)) return 0;

	dfm_CurrentMenu[playerid] = DFM_MENU_DFDELETE;

	new fieldName[MAX_DETFIELD_NAME];

	GetDetectionFieldName(detfieldId, fieldName);

	Dialog_Show(playerid, DetfieldDelete, DIALOG_STYLE_MSGBOX, sprintf("Deletar %s", fieldName), "Você tem certeza?", GetPlayerAdminLevel(playerid) ? "Voltar" : "Sair", "Deletar");

	return 1;
}

Dialog:DetfieldDelete(playerid, response, listitem, inputtext[]) {
	if(!response) {
	    new fieldName[MAX_DETFIELD_NAME];

	    GetDetectionFieldName(dfm_CurrentDetfield[playerid], fieldName);
	    RemoveDetectionField(dfm_CurrentDetfield[playerid]);

		ChatMsgAdmins(1, BLUE, "[FIELD]: Field '%s' removida por '%p'", fieldName, playerid);
	}

	if(GetPlayerAdminLevel(playerid) >= STAFF_LEVEL_MODERATOR) ShowDetfieldList(playerid);
}

ShowDetfieldLog(playerid, detfieldId) {
	if(!IsValidDetectionField(detfieldId)) return 0;

	dfm_CurrentMenu[playerid] = DFM_MENU_DFLOG;

	new
		list[MAX_DETFIELD_LOG_PAGESIZE * (MAX_DETFIELD_NAME + 1)],
		fieldName[MAX_DETFIELD_NAME];

	GetDetectionFieldName(detfieldId, fieldName);

	new const count = GetDetectionFieldLogBuffer(detfieldId, dfm_LogBuffer[playerid], MAX_DETFIELD_LOG_PAGESIZE, dfm_LogIndex[playerid]);
	
	new const totalEntries = GetDetectionFieldLogEntries(detfieldId);

	for(new i; i < count; i++) {
		format(list, sizeof(list), "%s%06d:%s %s (%.1f,%.1f,%.1f)\n",
			list,
			dfm_LogBuffer[playerid][i][DETLOG_BUFFER_ROW_ID],
			TimestampToDateTime(dfm_LogBuffer[playerid][i][DETLOG_BUFFER_DATE], "%d/%m/%y %X"),
			dfm_LogBuffer[playerid][i][DETLOG_BUFFER_NAME],
			dfm_LogBuffer[playerid][i][DETLOG_BUFFER_POS_X],
			dfm_LogBuffer[playerid][i][DETLOG_BUFFER_POS_Y],
			dfm_LogBuffer[playerid][i][DETLOG_BUFFER_POS_Z]);
	}

	if(!count) {
		dfm_LogIndex[playerid] = 0;
		return 0;
	}
	
    dfm_CurrentDetfield[playerid] = detfieldId;
    
	ShowPlayerPageButtons(playerid);

	Dialog_Show(playerid, DetfieldLog, DIALOG_STYLE_LIST, sprintf("%s (%d-%d of %d)", fieldName, dfm_LogIndex[playerid], dfm_LogIndex[playerid] + count, totalEntries), list, "Selecionar", "Voltar");

	return 1;
}

Dialog:DetfieldLog(playerid, response, listitem, inputtext[]) {
	if(response) 
		ShowDetfieldLogOptions(playerid, dfm_CurrentDetfield[playerid], listitem);
	else 
		ShowDetfieldListOptions(playerid, dfm_CurrentDetfield[playerid]);

	HidePlayerPageButtons(playerid);
	CancelSelectTextDraw(playerid);
}

ShowDetfieldLogOptions(playerid, detfieldId, logEntry) {
	if(!IsValidDetectionField(detfieldId)) return 0;

	dfm_CurrentMenu[playerid] = DFM_MENU_LOGOPTS;

	new fieldName[MAX_DETFIELD_NAME];

	GetDetectionFieldName(detfieldId, fieldName);
    dfm_CurrentLogEntry[playerid] = logEntry;
	Dialog_Show(playerid, DetfieldLogOpts, DIALOG_STYLE_LIST, fieldName, "Ir\nDeletar\nDeletar todas desse jogador", "Selecionar", "Fechar");

	return 1;
}

Dialog:DetfieldLogOpts(playerid, response, listitem, inputtext[]) {
	if(response) {
		switch(listitem) {
			case 0: {
				if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER) {
					SetPlayerPos(playerid,
						dfm_LogBuffer[playerid][dfm_CurrentLogEntry[playerid] ][DETLOG_BUFFER_POS_X],
						dfm_LogBuffer[playerid][dfm_CurrentLogEntry[playerid] ][DETLOG_BUFFER_POS_Y],
						dfm_LogBuffer[playerid][dfm_CurrentLogEntry[playerid] ][DETLOG_BUFFER_POS_Z]);
				} else
					ChatMsg(playerid, RED, "server/command/need-duty");
			}
			case 1: {
				DeleteDetectionFieldLogEntry(dfm_CurrentDetfield[playerid], dfm_LogBuffer[playerid][dfm_CurrentLogEntry[playerid] ][DETLOG_BUFFER_ROW_ID]);

				ShowDetfieldLog(playerid, dfm_CurrentDetfield[playerid]);
			}
			case 2: {
				DeleteDetectionFieldLogsOfName(dfm_CurrentDetfield[playerid], dfm_LogBuffer[playerid][dfm_CurrentLogEntry[playerid] ][DETLOG_BUFFER_NAME]);

				ShowDetfieldLog(playerid, dfm_CurrentDetfield[playerid]);
			}
		}
	} else
		ShowDetfieldLog(playerid, dfm_CurrentDetfield[playerid]);
}

ShowDetfieldNameFields(playerid, fieldName[]) {
	new list[MAX_DETFIELD_PAGESIZE * (MAX_DETFIELD_NAME + 16)];

	new const count = GetDetectionFieldNameLog(fieldName, list, MAX_DETFIELD_PAGESIZE, dfm_PageIndex[playerid], sizeof(list));

	if(!count) return 0;

	// TODO: make proper pagination for this menu.
	ShowPlayerPageButtons(playerid);

	Dialog_Show(playerid, DetfieldName, DIALOG_STYLE_LIST, sprintf("%s (last %d fields from index %d)", fieldName, count, dfm_PageIndex[playerid]), list, "Selecionar", "Voltar");

	return 1;
}

Dialog:DetfieldName(playerid, response, listitem, inputtext[]) {
	// TODO: do something with the data (jump to field log or something).
}

hook OnPlayerDialogPage(playerid, direction) {
	if(dfm_CurrentMenu[playerid] == DFM_MENU_DFLIST) {
		if(direction == 0) {
			dfm_PageIndex[playerid] -= MAX_DETFIELD_PAGESIZE;

			if(dfm_PageIndex[playerid] < 0) dfm_PageIndex[playerid] = 0;
		} else
			dfm_PageIndex[playerid] += MAX_DETFIELD_PAGESIZE;

		ShowDetfieldList(playerid);
	} else if(dfm_CurrentMenu[playerid] == DFM_MENU_DFLOG) {
		if(direction == 0) {
			dfm_LogIndex[playerid] -= MAX_DETFIELD_LOG_PAGESIZE;

			if(dfm_LogIndex[playerid] < 0) dfm_LogIndex[playerid] = 0;
		} else 
			dfm_LogIndex[playerid] += MAX_DETFIELD_LOG_PAGESIZE;

		ShowDetfieldLog(playerid, dfm_CurrentDetfield[playerid]);
	}
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	if(dfm_Editing[playerid])
		if(newkeys == 128) AddNewDetectionFieldPoint(playerid); // Botao direito do mouse para escolher o ponto

	return 1;
}

AddNewDetectionFieldPoint(playerid) {
	new Float:z;

	GetPlayerPos(playerid,
		dfm_Points[playerid][dfm_CurrentPoint[playerid] * 2],
		dfm_Points[playerid][(dfm_CurrentPoint[playerid] * 2) + 1],
		z);

	if(dfm_CurrentPoint[playerid] == 3) { // ? Porque no 4o ponto quando existem 10?
		dfm_Points[playerid][8] = dfm_Points[playerid][0];
		dfm_Points[playerid][9] = dfm_Points[playerid][1];

		GetPlayerName(playerid, dfm_Exceptions[playerid][0], MAX_PLAYER_NAME); // Adicionamos o criador como excepcao

		dfm_Editing[playerid] = false;

		new result = AddDetectionField(dfm_Name[playerid], dfm_Points[playerid], dfm_MinZ[playerid], dfm_MaxZ[playerid], dfm_Exceptions[playerid], GetPlayerAdminLevel(playerid));

		if(result < 0) {
			switch(result) {
				case -1: ChatMsg(playerid, RED, " >  Esse nome não é válido.", result);
				case -2: ChatMsg(playerid, RED, " >  Já existe uma detection field com esse nome.", result);
				case -3: ChatMsg(playerid, RED, " >  O limite de detection fields foi atingido. Aviso um Administrador.", result);
			}

			return;
		} else {
			ChatMsg(playerid, YELLOW, " >  Ponto %d setado para %f, %f. Field '%s' criada.",
				dfm_CurrentPoint[playerid] + 1,
				dfm_Points[playerid][dfm_CurrentPoint[playerid] * 2],
				dfm_Points[playerid][(dfm_CurrentPoint[playerid] * 2) + 1],
				dfm_Name[playerid]);

			if(!GetPlayerAdminLevel(playerid)) {
				SendClientMessage(playerid, ORANGE, " >  Tem que aguardar pela aprovação da sua Detection Field.");
				ChatMsgAdmins(STAFF_LEVEL_MODERATOR, YELLOW, " >  Detection Field '%s' criada por '%p' aguarda aprovação.", dfm_Name[playerid], playerid);
			}
		}
	} else
		ChatMsg(playerid, YELLOW, " >  Ponto %d setado para %f, %f. Mova para o próximo ponto e pressione "C_BLUE"~k~~PED_LOCK_TARGET~", dfm_CurrentPoint[playerid] + 1, dfm_Points[playerid][dfm_CurrentPoint[playerid] * 2], dfm_Points[playerid][(dfm_CurrentPoint[playerid] * 2) + 1]);

	dfm_CurrentPoint[playerid]++;
}
