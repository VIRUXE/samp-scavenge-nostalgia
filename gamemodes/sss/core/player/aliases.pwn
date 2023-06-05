#include <YSI\y_hooks>


static
DBStatement:	stmt_AliasesFromIp,
DBStatement:	stmt_AliasesFromPass,
DBStatement:	stmt_AliasesFromHash,
DBStatement:	stmt_AliasesFromAll;


hook OnGameModeInit() {
	stmt_AliasesFromIp   = db_prepare(Database, "SELECT name FROM players WHERE ipv4=? AND active=1 AND name!=? COLLATE NOCASE");
	stmt_AliasesFromPass = db_prepare(Database, "SELECT name FROM players WHERE pass=? AND active=1 AND name!=? COLLATE NOCASE");
	stmt_AliasesFromHash = db_prepare(Database, "SELECT name FROM players WHERE gpci=? AND active=1 AND name!=? COLLATE NOCASE");
	stmt_AliasesFromAll  = db_prepare(Database, "SELECT name FROM players WHERE (pass=? OR ipv4=? OR gpci = ?) AND active=1 AND name!=? COLLATE NOCASE");
}

stock GetAccountAliasesByIP(name[], list[][MAX_PLAYER_NAME], &count, max, &adminlevel) {
	new ip, tempname[MAX_PLAYER_NAME], templevel;

	GetAccountIP(name, ip);

	if(ip == 0) return 0;

	stmt_bind_value(stmt_AliasesFromIp, 0, DB::TYPE_INTEGER, ip);
	stmt_bind_value(stmt_AliasesFromIp, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_AliasesFromIp, 0, DB::TYPE_STRING, tempname, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AliasesFromIp)) return 0;

	while(stmt_fetch_row(stmt_AliasesFromIp)) {
		if(count < max) strcat(list[count], tempname, max * MAX_PLAYER_NAME);

		templevel = GetAdminLevelByName(tempname);

		if(templevel > adminlevel) adminlevel = templevel;

		count++;
	}

	return 1;
}

stock GetAccountAliasesByPass(name[], list[][MAX_PLAYER_NAME], &count, max, &adminlevel) {
	new pass[129], tempname[MAX_PLAYER_NAME], templevel;

	GetAccountPassword(name, pass);

	if(isnull(pass)) return 0;

	stmt_bind_value(stmt_AliasesFromPass, 0, DB::TYPE_STRING, pass, 129);
	stmt_bind_value(stmt_AliasesFromPass, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_AliasesFromPass, 0, DB::TYPE_STRING, tempname, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AliasesFromPass)) return 0;

	while(stmt_fetch_row(stmt_AliasesFromPass)) {
		if(count < max) strcat(list[count], tempname, max * MAX_PLAYER_NAME);

		templevel = GetAdminLevelByName(tempname);

		if(templevel > adminlevel) adminlevel = templevel;

		count++;
	}

	return 1;
}

stock GetAccountAliasesByHash(name[], list[][MAX_PLAYER_NAME], &count, max, &adminlevel) {
	new serial[MAX_GPCI_LEN], tempname[MAX_PLAYER_NAME], templevel;

	GetAccountGPCI(name, serial);

	if(isnull(serial)) return 0;

	if(serial[0] == '0') return 0;

	stmt_bind_value(stmt_AliasesFromHash, 0, DB::TYPE_STRING, serial, MAX_GPCI_LEN);
	stmt_bind_value(stmt_AliasesFromHash, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_AliasesFromHash, 0, DB::TYPE_STRING, tempname, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AliasesFromHash)) return 0;

	while(stmt_fetch_row(stmt_AliasesFromHash)) {
		if(count < max) strcat(list[count], tempname, max * MAX_PLAYER_NAME);

		templevel = GetAdminLevelByName(tempname);

		if(templevel > adminlevel) adminlevel = templevel;

		count++;
	}

	return 1;
}

stock GetAccountAliasesByAll(name[], list[][MAX_PLAYER_NAME], &count, max, &adminlevel) {
	new
		pass[129],
		ip,
		serial[MAX_GPCI_LEN],
		tempname[MAX_PLAYER_NAME],
		templevel;

	GetAccountAliasData(name, pass, ip, serial);

	if(isnull(serial)) return 0;

	if(serial[0] == '0') return 0;

	stmt_bind_value(stmt_AliasesFromAll, 0, DB::TYPE_STRING, pass, sizeof(pass));
	stmt_bind_value(stmt_AliasesFromAll, 1, DB::TYPE_INTEGER, ip);
	stmt_bind_value(stmt_AliasesFromAll, 2, DB::TYPE_STRING, serial, sizeof(serial));
	stmt_bind_value(stmt_AliasesFromAll, 3, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_AliasesFromAll, 0, DB::TYPE_STRING, tempname, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_AliasesFromAll)) return 0;

	while(stmt_fetch_row(stmt_AliasesFromAll)) {
		if(count < max) strcat(list[count], tempname, max * MAX_PLAYER_NAME);

		templevel = GetAdminLevelByName(tempname);

		if(templevel > adminlevel) adminlevel = templevel;

		count++;
	}

	return 1;
}

hook OnPlayerLogin(playerid) {
	// Verificar se o jogador tem contas extras se ele não for admin
	if(!GetPlayerAdminLevel(playerid)) CheckForExtraAccounts(playerid);
}

hook OnPlayerRegister(playerid) CheckForExtraAccounts(playerid);

CheckForExtraAccounts(playerid) {
	if(!IsPlayerRegistered(playerid) || !IsPlayerLoggedIn(playerid)) return 0;

	new
		name[MAX_PLAYER_NAME],
		list[15][MAX_PLAYER_NAME],
		count,
		adminlevel,
		bool:doneWarning,
		string[(MAX_PLAYER_NAME + 2) * 15];

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	GetAccountAliasesByAll(name, list, count, 15, adminlevel);

	if(count == 0) return 0;

	if(count == 1) strcat(string, list[0]);

	if(count > 1) {
		for(new i; i < count && i < sizeof(list); i++) {
			strcat(string, list[i]);
			strcat(string, ", ");

			if(IsPlayerBanned(list[i]) && !doneWarning) {
				ChatMsgAdmins(1, RED, " > Aviso: Um ou mais desses aliases sÃ£o banidos");
				doneWarning = true;
			}
		}
	}

	if(doneWarning && GetAdminsOnline() == 0) {
		KickPlayer(playerid, "Uma de suas contas usadas anteriormente está banida.");
		return 0;
	}

	return ChatMsgAdmins(1, YELLOW, " >  Aliases: "C_BLUE"(%d)"C_ORANGE" %s", count, string);
}