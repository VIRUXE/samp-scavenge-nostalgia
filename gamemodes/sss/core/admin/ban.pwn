#include <YSI\y_hooks>

#define MAX_BAN_REASON 128

enum {
	FIELD_ID_BANS_NAME,
	FIELD_ID_BANS_IPV4,
	FIELD_ID_BANS_DATE,
	FIELD_ID_BANS_REASON,
	FIELD_ID_BANS_BY,
	FIELD_ID_BANS_DURATION,
	FIELD_ID_BANS_ACTIVE
}

static
DBStatement:	stmt_BanInsert,
DBStatement:	stmt_BanUnban,
DBStatement:	stmt_BanGetFromNameIp,
DBStatement:	stmt_BanNameCheck,
DBStatement:	stmt_BanGetList,
DBStatement:	stmt_BanGetTotal,
DBStatement:	stmt_BanGetInfo,
DBStatement:	stmt_BanUpdateInfo,
DBStatement:	stmt_BanSetIpv4,
DBStatement:	stmt_BanSetReason,
DBStatement:	stmt_BanSetDuration;


hook OnGameModeInit() {
	db_free_result(db_query(Database, "CREATE TABLE IF NOT EXISTS bans (name TEXT, ipv4 INTEGER, date INTEGER, reason TEXT, by TEXT, duration INTEGER, active INTEGER)"));

	DatabaseTableCheck(Database, "Bans", 7);

	stmt_BanInsert				= db_prepare(Database, "INSERT INTO bans VALUES(?, ?, ?, ?, ?, ?, 1)");
	stmt_BanUnban				= db_prepare(Database, "UPDATE bans SET active=0 WHERE name = ? COLLATE NOCASE");
	stmt_BanGetFromNameIp		= db_prepare(Database, "SELECT COUNT(*), date, reason, duration FROM bans WHERE (name = ? COLLATE NOCASE OR ipv4 = ?) AND active=1 ORDER BY date DESC");
	stmt_BanNameCheck			= db_prepare(Database, "SELECT COUNT(*) FROM bans WHERE active=1 AND name = ? COLLATE NOCASE ORDER BY date DESC");
	stmt_BanGetList				= db_prepare(Database, "SELECT * FROM bans WHERE active=1 ORDER BY date DESC LIMIT ?, ? COLLATE NOCASE");
	stmt_BanGetTotal			= db_prepare(Database, "SELECT COUNT(*) FROM bans WHERE active=1");
	stmt_BanGetInfo				= db_prepare(Database, "SELECT * FROM bans WHERE name = ? COLLATE NOCASE ORDER BY date DESC");
	stmt_BanUpdateInfo			= db_prepare(Database, "UPDATE bans SET reason = ?, duration = ? WHERE name = ? COLLATE NOCASE");
	stmt_BanSetIpv4				= db_prepare(Database, "UPDATE bans SET ipv4 = ? WHERE name = ? COLLATE NOCASE");
	stmt_BanSetReason			= db_prepare(Database, "UPDATE bans SET reason = ? WHERE name = ? COLLATE NOCASE");
	stmt_BanSetDuration			= db_prepare(Database, "UPDATE bans SET duration = ? WHERE name = ? COLLATE NOCASE");
}

BanPlayer(playerId, reason[], byId, duration) {
	new playerName[MAX_PLAYER_NAME];

	GetPlayerName(playerId, playerName, MAX_PLAYER_NAME);

	stmt_bind_value(stmt_BanInsert, 0, DB::TYPE_STRING, playerName);
	stmt_bind_value(stmt_BanInsert, 1, DB::TYPE_INTEGER, GetPlayerIpAsInt(playerId));
	stmt_bind_value(stmt_BanInsert, 2, DB::TYPE_INTEGER, gettime());
	stmt_bind_value(stmt_BanInsert, 3, DB::TYPE_STRING, reason, MAX_BAN_REASON);
	stmt_bind_value(stmt_BanInsert, 4, DB::TYPE_PLAYER_NAME, byId);
	stmt_bind_value(stmt_BanInsert, 5, DB::TYPE_INTEGER, duration);

	if(stmt_execute(stmt_BanInsert)) {
		CallLocalFunction("OnPlayerBan", "s", playerName);

   		ChatMsgAll(WHITE, " > %p foi banido!", playerId);
		GameTextForPlayer(playerId, "Banido!", 10000, 6);
		
		defer KickPlayerDelay(playerId);

		return 1;
	}

	return 0;
}

BanPlayerByName(name[], reason[], byid, duration) {
	new
		playerId = GetPlayerIDFromName(name),
		ip,
		byName[MAX_PLAYER_NAME];

	if(byid == -1)
		byName = "Server";
	else
		GetPlayerName(byid, byName, MAX_PLAYER_NAME);

	if(playerId == INVALID_PLAYER_ID) {
		GetAccountIP(name, ip);
	} else {
		ChatMsgAll(WHITE, " > %s foi banido!", name);
	    GameTextForPlayer(playerId, "Kickado!", 10000, 6);

		ip = GetPlayerIpAsInt(playerId);

		defer KickPlayerDelay(playerId);
	}

    CallLocalFunction("OnPlayerBan", "s", name);
    
	stmt_bind_value(stmt_BanInsert, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_value(stmt_BanInsert, 1, DB::TYPE_INTEGER, ip);
	stmt_bind_value(stmt_BanInsert, 2, DB::TYPE_INTEGER, gettime());
	stmt_bind_value(stmt_BanInsert, 3, DB::TYPE_STRING, reason, MAX_BAN_REASON);
	stmt_bind_value(stmt_BanInsert, 4, DB::TYPE_STRING, byName, MAX_PLAYER_NAME);
	stmt_bind_value(stmt_BanInsert, 5, DB::TYPE_INTEGER, duration);

	if(!stmt_execute(stmt_BanInsert)) return 0;

	return 1;
}

UpdateBanInfo(name[], reason[], duration) {
	stmt_bind_value(stmt_BanUpdateInfo, 0, DB::TYPE_STRING, reason, MAX_BAN_REASON);
	stmt_bind_value(stmt_BanUpdateInfo, 1, DB::TYPE_INTEGER, duration);
	stmt_bind_value(stmt_BanUpdateInfo, 2, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(stmt_execute(stmt_BanUpdateInfo)) return 1;
	
	return 0;
}

UnBanPlayer(name[]) {
	if(!IsPlayerBanned(name)) return 0;

	stmt_bind_value(stmt_BanUnban, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(stmt_execute(stmt_BanUnban)) return 1;

	return 0;
}

BanCheck(playerid) {
	new
		banned,
		timestamp,
		reason[MAX_BAN_REASON],
		duration;

	stmt_bind_value(stmt_BanGetFromNameIp, 0, DB::TYPE_PLAYER_NAME, playerid);
	stmt_bind_value(stmt_BanGetFromNameIp, 1, DB::TYPE_INTEGER, GetPlayerIpAsInt(playerid));

	stmt_bind_result_field(stmt_BanGetFromNameIp, 0, DB::TYPE_INTEGER, banned);
	stmt_bind_result_field(stmt_BanGetFromNameIp, 1, DB::TYPE_INTEGER, timestamp);
	stmt_bind_result_field(stmt_BanGetFromNameIp, 2, DB::TYPE_STRING, reason, MAX_BAN_REASON);
	stmt_bind_result_field(stmt_BanGetFromNameIp, 3, DB::TYPE_INTEGER, duration);

	if(stmt_execute(stmt_BanGetFromNameIp)) {
		stmt_fetch_row(stmt_BanGetFromNameIp);

		if(banned) {
			if(duration) {
				if(gettime() > (timestamp + duration)) {
					new name[MAX_PLAYER_NAME];
					GetPlayerName(playerid, name, MAX_PLAYER_NAME);
					UnBanPlayer(name);

					ChatMsg(playerid, YELLOW, "BANLIFMESSG", TimestampToDateTime(timestamp));
					log("[UNBAN] Ban lifted automatically for %s", name);

					return 0;
				}
			}

			new string[900];

			format(string, 900, "\
				"C_YELLOW"Data:\n\t\t"C_BLUE"%s\n\n\
				"C_YELLOW"Motivo:\n\t\t"C_BLUE"%s\n\n\
				"C_YELLOW"Desban:\n\t\t"C_BLUE"%s\n\n\
				"C_RED"Se Você acha isso injusto, entre em nosso grupo do discord e fale com um administrador. http://discord.scavengenostalgia.fun",
				TimestampToDateTime(timestamp),
				reason,
				duration ? (TimestampToDateTime(timestamp + duration)) : "Nunca");

			ShowPlayerDialog(playerid, 10008, DIALOG_STYLE_MSGBOX, "Banido", string, "Fechar", "");

			stmt_bind_value(stmt_BanSetIpv4, 0, DB::TYPE_INTEGER, GetPlayerIpAsInt(playerid));
			stmt_bind_value(stmt_BanSetIpv4, 1, DB::TYPE_PLAYER_NAME, playerid);
			stmt_execute(stmt_BanSetIpv4);

			defer KickPlayerDelay(playerid);

			return 1;
		}
	}

	return 0;
}

forward external_BanPlayer(name[], reason[], duration);
public external_BanPlayer(name[], reason[], duration) {
	BanPlayerByName(name, reason, -1, duration);
}

stock IsPlayerBanned(name[]) {
	new count;

	stmt_bind_value(stmt_BanNameCheck, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_BanNameCheck, 0, DB::TYPE_INTEGER, count);

	if(stmt_execute(stmt_BanNameCheck)) {
		stmt_fetch_row(stmt_BanNameCheck);

		if(count) return 1;
	}

	return 0;
}

stock GetBanList(string[][MAX_PLAYER_NAME], limit, offset) {
	new name[MAX_PLAYER_NAME];

	stmt_bind_value(stmt_BanGetList, 0, DB::TYPE_INTEGER, offset);
	stmt_bind_value(stmt_BanGetList, 1, DB::TYPE_INTEGER, limit);
	stmt_bind_result_field(stmt_BanGetList, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_BanGetList)) return -1;

	new idx;

	while(stmt_fetch_row(stmt_BanGetList)) {
		string[idx] = name;
		idx++;
	}

	return idx;
}

stock GetTotalBans() {
	new total;

	stmt_bind_result_field(stmt_BanGetTotal, 0, DB::TYPE_INTEGER, total);
	stmt_execute(stmt_BanGetTotal);
	stmt_fetch_row(stmt_BanGetTotal);

	return total;
}

stock GetBanInfo(name[], &timestamp, reason[], bannedby[], &duration) {
	stmt_bind_value(stmt_BanGetInfo, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	stmt_bind_result_field(stmt_BanGetInfo, FIELD_ID_BANS_DATE, DB::TYPE_INTEGER, timestamp);
	stmt_bind_result_field(stmt_BanGetInfo, FIELD_ID_BANS_REASON, DB::TYPE_STRING, reason, MAX_BAN_REASON);
	stmt_bind_result_field(stmt_BanGetInfo, FIELD_ID_BANS_BY, DB::TYPE_STRING, bannedby, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_BanGetInfo, FIELD_ID_BANS_DURATION, DB::TYPE_INTEGER, duration);

	if(!stmt_execute(stmt_BanGetInfo)) return 0;

	stmt_fetch_row(stmt_BanGetInfo);

	return 1;
}

stock SetBanIpv4(name[], ipv4) {
	stmt_bind_value(stmt_BanSetIpv4, 0, DB::TYPE_INTEGER, ipv4);
	stmt_bind_value(stmt_BanSetIpv4, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_BanSetIpv4);
}

stock SetBanReason(name[], reason[]) {
	stmt_bind_value(stmt_BanSetReason, 0, DB::TYPE_STRING, reason, MAX_BAN_REASON);
	stmt_bind_value(stmt_BanSetReason, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_BanSetReason);
}

stock SetBanDuration(name[], duration) {
	stmt_bind_value(stmt_BanSetDuration, 0, DB::TYPE_INTEGER, duration);
	stmt_bind_value(stmt_BanSetDuration, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	return stmt_execute(stmt_BanSetDuration);
}
