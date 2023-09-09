#include <YSI\y_hooks>

static DBStatement: stmt_Ipv4Insert;

hook OnGameModeInit() {
	db_query(Database, "CREATE TABLE IF NOT EXISTS ipv4_log (name TEXT, ipv4 INTEGER, date INTEGER, UNIQUE(name, ipv4))");

	DatabaseTableCheck(Database, "ipv4_log", 3);

	stmt_Ipv4Insert = db_prepare(Database, "INSERT IGNORE INTO ipv4_log VALUES(?,?,?)");
}

hook OnPlayerConnect(playerid) {
    if(!IsPlayerNPC(playerid)) {
		new
			name[MAX_PLAYER_NAME],
			ipstring[16],
			ipbyte[4],
			ip;

		GetPlayerName(playerid, name, MAX_PLAYER_NAME);
		GetPlayerIp(playerid, ipstring, 16);

		sscanf(ipstring, "p<.>a<d>[4]", ipbyte);
		ip = ((ipbyte[0] << 24) | (ipbyte[1] << 16) | (ipbyte[2] << 8) | ipbyte[3]);

		stmt_bind_value(stmt_Ipv4Insert, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
		stmt_bind_value(stmt_Ipv4Insert, 1, DB::TYPE_INTEGER, ip);
		stmt_bind_value(stmt_Ipv4Insert, 2, DB::TYPE_INTEGER, gettime());

		if(!stmt_execute(stmt_Ipv4Insert)) err("Failed to execute statement 'stmt_Ipv4Insert'.");
	}

	return 1;
}
