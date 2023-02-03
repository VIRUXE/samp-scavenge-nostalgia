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


#define MAX_ISSUE_LENGTH			(128)
#define MAX_ISSUES_PER_PAGE			(32)
#define ACCOUNTS_TABLE_BUGS			"Bugs"
#define FIELD_BUGS_NAME				"name"		// 00
#define FIELD_BUGS_REASON			"reason"	// 01
#define FIELD_BUGS_DATE				"date"		// 02

enum
{
	FIELD_ID_BUGS_NAME,
	FIELD_ID_BUGS_REASON,
	FIELD_ID_BUGS_DATE
}


static
				issue_RowIndex[MAX_ISSUES_PER_PAGE],

DBStatement:	stmt_BugInsert,
DBStatement:	stmt_BugDelete,
DBStatement:	stmt_BugList,
DBStatement:	stmt_BugTotal,
DBStatement:	stmt_BugInfo;


hook OnGameModeInit()
{
	db_free_result(db_query(gAccounts, "CREATE TABLE IF NOT EXISTS "ACCOUNTS_TABLE_BUGS" (\
		"FIELD_BUGS_NAME" TEXT,\
		"FIELD_BUGS_REASON" TEXT,\
		"FIELD_BUGS_DATE" INTEGER)"));

	DatabaseTableCheck(gAccounts, ACCOUNTS_TABLE_BUGS, 3);

	stmt_BugInsert	= db_prepare(gAccounts, "INSERT INTO "ACCOUNTS_TABLE_BUGS" VALUES(?, ?, ?)");
	stmt_BugDelete	= db_prepare(gAccounts, "DELETE FROM "ACCOUNTS_TABLE_BUGS" WHERE rowid = ?");
	stmt_BugList	= db_prepare(gAccounts, "SELECT "FIELD_BUGS_NAME", "FIELD_BUGS_REASON", rowid FROM "ACCOUNTS_TABLE_BUGS"");
	stmt_BugTotal	= db_prepare(gAccounts, "SELECT COUNT(*) FROM "ACCOUNTS_TABLE_BUGS"");
	stmt_BugInfo	= db_prepare(gAccounts, "SELECT * FROM "ACCOUNTS_TABLE_BUGS" WHERE rowid = ? LIMIT 1");
}


/*==============================================================================

	Submitting reports

==============================================================================*/


CMD:bug(playerid)
{
	Dialog_Show(playerid, BugReport, DIALOG_STYLE_INPUT, "Reportar um BUG", ls(playerid, "BUGREPORTDI"), "Confirmar", "Cancelar");
    
	return 1;
}

Dialog:BugReport(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		ReportBug(playerid, inputtext);
		ChatMsgLang(playerid, YELLOW, "BUGREPORTSU");
	}
	return 1;
}

ReportBug(playerid, bug[])
{
	stmt_bind_value(stmt_BugInsert, 0, DB::TYPE_PLAYER_NAME, playerid);
	stmt_bind_value(stmt_BugInsert, 1, DB::TYPE_STRING, bug, MAX_ISSUE_LENGTH);
	stmt_bind_value(stmt_BugInsert, 2, DB::TYPE_INTEGER, gettime());

	if(stmt_execute(stmt_BugInsert))
	{
		ChatMsgAdmins(1, YELLOW, " >  %P"C_YELLOW" reportou o bug %s", playerid, bug);
	}
}


/*==============================================================================

	Listing reports

==============================================================================*/


CMD:bugs(playerid)
{
	new ret;

	ret = ShowListOfBugs(playerid);

	if(ret == 0)
		ChatMsg(playerid, YELLOW, " >  Não tem nenhum report de BUG para mostrar.");

	return 1;
}

ShowListOfBugs(playerid)
{
	new
		name[MAX_PLAYER_NAME],
		bug[32],
		rowid;

	stmt_bind_result_field(stmt_BugList, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_BugList, 1, DB::TYPE_STRING, bug, 32);
	stmt_bind_result_field(stmt_BugList, 2, DB::TYPE_INTEGER, rowid);

	if(!stmt_execute(stmt_BugList))
		return 0;

	new
		list[(MAX_PLAYER_NAME + 2 + 32 + 1) * MAX_ISSUES_PER_PAGE],
		idx;

	// Some bug in sqlite causes 'name' to appear empty sometimes.
	while(stmt_fetch_row(stmt_BugList) && idx < MAX_ISSUES_PER_PAGE)
	{
		strcat(list, name);
		strcat(list, ": ");

		strcat(list, bug);

		if(bug[30] != EOS)
			strcat(list, "[...]");

		strcat(list, "\n");

		issue_RowIndex[idx++] = rowid;
	}

	if(idx == 0)
		return 0;

	Dialog_Show(playerid, BugReport2, DIALOG_STYLE_LIST, "BUGS", list, "Abrir", "Fechar");
    
	return 1;
}

Dialog:BugReport2(playerid, response, listitem, inputtext[])
{
    if(response)
	{
		if(!ShowBugReportInfo(playerid, issue_RowIndex[listitem]))
			ChatMsg(playerid, RED, " >  An error occurred while trying to execute statement 'stmt_BugInfo'.");
	}
	return 1;
}

new Rowidbr3[MAX_PLAYERS];

ShowBugReportInfo(playerid, rowid)
{
	new
		name[MAX_PLAYER_NAME],
		bug[MAX_ISSUE_LENGTH],
		date,
		message[512];

	stmt_bind_value(stmt_BugInfo, 0, DB::TYPE_INTEGER, rowid);
	stmt_bind_result_field(stmt_BugInfo, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_BugInfo, 1, DB::TYPE_STRING, bug, MAX_ISSUE_LENGTH);
	stmt_bind_result_field(stmt_BugInfo, 2, DB::TYPE_INTEGER, date);

	if(!stmt_execute(stmt_BugInfo))
		return 0;

	stmt_fetch_row(stmt_BugInfo);

    Rowidbr3[playerid] = rowid;
    
	format(message, sizeof(message),
		""C_YELLOW"Reportou:\n\t\t"C_BLUE"%s\n\n\
		"C_YELLOW"BUG:\n\t\t"C_BLUE"%s\n\n\
		"C_YELLOW"Data:\n\t\t"C_BLUE"%s",
		name, bug, TimestampToDateTime(date));

	if(GetPlayerAdminLevel(playerid) > 1)
		Dialog_Show(playerid, BugReport3, DIALOG_STYLE_MSGBOX, "Bugs", message, "Deletar", "Voltar");

	else
		Dialog_Show(playerid, BugReport3, DIALOG_STYLE_MSGBOX, "Bugs", message, "Voltar", "");

	return 1;
}

Dialog:BugReport3(playerid, response, listitem, inputtext[])
{
    if(response)
	{
		if(GetPlayerAdminLevel(playerid) > 1)
		{
			stmt_bind_value(stmt_BugDelete, 0, DB::TYPE_INTEGER, Rowidbr3[playerid]);
			stmt_execute(stmt_BugDelete);
		}
	}

	ShowListOfBugs(playerid);
	return 1;
}

/*==============================================================================

	Interface

==============================================================================*/


stock GetBugReports()
{
	new count;

	stmt_bind_result_field(stmt_BugTotal, 0, DB::TYPE_INTEGER, count);
	stmt_execute(stmt_BugTotal);
	stmt_fetch_row(stmt_BugTotal);

	return count;
}
