#include <YSI\y_hooks>

#define MAX_GPCI_LOG_RESULTS	(32)

#define FIELD_GPCI_NAME			"name"		// 00
#define FIELD_GPCI_GPCI			"hash"		// 01
#define FIELD_GPCI_DATE			"date"		// 02

enum e_gpci_list_output_structure {
	gpci_name[MAX_PLAYER_NAME],
	gpci_gpci[MAX_GPCI_LEN],
	gpci_date
}


static
DBStatement:	stmt_GpciInsert,
DBStatement:	stmt_GpciCheckName,
DBStatement:	stmt_GpciGetRecordsFromGpci,
DBStatement:	stmt_GpciGetRecordsFromName,
DBStatement:	stmt_GpciPlayerAllowed;


hook OnGameModeInit() {
	db_query(Database, "CREATE TABLE IF NOT EXISTS gpci_log (name TEXT, hash TEXT, date INTEGER)");
	db_query(Database, "CREATE TABLE IF NOT EXISTS gpci_allowed (name TEXT, hash TEXT, date INTEGER)");

	DatabaseTableCheck(Database, "gpci_log", 3);

	stmt_GpciInsert				= db_prepare(Database, "INSERT INTO gpci_log VALUES(?,?,?)");
	stmt_GpciCheckName			= db_prepare(Database, "SELECT COUNT(*) FROM gpci_log WHERE name=? AND hash=?");
	stmt_GpciGetRecordsFromGpci	= db_prepare(Database, "SELECT * FROM gpci_log WHERE hash=? ORDER BY date DESC");
	stmt_GpciGetRecordsFromName	= db_prepare(Database, "SELECT * FROM gpci_log WHERE name=? COLLATE NOCASE ORDER BY date DESC");

	/*
	This SQL query checks if a player is allowed to join the game using a hash that is present in the 'gpci_log' table more than once.

	The query uses the 'EXISTS' function to return a boolean value: 

	1. It returns 1 (true) if the player's name and hash exist in the 'gpci_allowed' table and the same hash is used by more than one player (found in the 'gpci_log' table).
	2. It returns 0 (false) if the above conditions are not met, meaning the player's hash is either not found in the 'gpci_log' table, is not used by more than one player, or the player's name and hash are not present in the 'gpci_allowed' table.

	This is useful to ensure that a player is only allowed to join the game if they have previously been granted permission to use a hash that is shared by multiple players.
	*/
	stmt_GpciPlayerAllowed		= db_prepare(Database,
		"SELECT 1\
		FROM gpci_log\
		WHERE gpci_log.hash = ?\
		GROUP BY gpci_log.hash\
		HAVING COUNT(gpci_log.hash) > 0 \
		AND NOT EXISTS (\
			SELECT 1 \
			FROM gpci_allowed\
			WHERE gpci_allowed.name = ?\
			AND gpci_allowed.hash = gpci_log.hash\
		);"
	);
}

hook OnPlayerConnect(playerid) {
	if(!IsPlayerNPC(playerid)) {
		new
			name[MAX_PLAYER_NAME],
			hash[MAX_GPCI_LEN],
			count;

		GetPlayerName(playerid, name, MAX_PLAYER_NAME);
		gpci(playerid, hash, MAX_GPCI_LEN);

		// Insert the GPCI, but only if it's not been added for this player
		stmt_bind_result_field(stmt_GpciCheckName, 0, DB::TYPE_INTEGER, count);
		stmt_bind_value(stmt_GpciCheckName, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
		stmt_bind_value(stmt_GpciCheckName, 1, DB::TYPE_STRING, hash, MAX_GPCI_LEN);

		stmt_execute(stmt_GpciCheckName);

		stmt_fetch_row(stmt_GpciCheckName);

		if(!count) {
			stmt_bind_value(stmt_GpciInsert, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
			stmt_bind_value(stmt_GpciInsert, 1, DB::TYPE_STRING, hash, MAX_GPCI_LEN);
			stmt_bind_value(stmt_GpciInsert, 2, DB::TYPE_INTEGER, gettime());

			if(!stmt_execute(stmt_GpciInsert)) err("Failed to execute statement 'stmt_GpciInsert'.");
		}
	}

	return 1;
}

// Check if there are multiple rows of the same hash
stock IsPlayerNotAllowedWithHash(playerName[MAX_PLAYER_NAME], hash[MAX_GPCI_LEN]) {
	new result;

	log("(IsPlayerNotAllowedWithHash) name: %s hash: %s", playerName, hash);

	stmt_bind_result_field(stmt_GpciPlayerAllowed, 0, DB::TYPE_INTEGER, result);

	stmt_bind_value(stmt_GpciPlayerAllowed, 0, DB::TYPE_STRING, hash, MAX_GPCI_LEN);
	stmt_bind_value(stmt_GpciPlayerAllowed, 1, DB::TYPE_STRING, playerName, MAX_GPCI_LEN);

	stmt_execute(stmt_GpciPlayerAllowed);

	return result;
}

stock GetAccountGpciHistoryFromGpci(inputgpci[MAX_GPCI_LEN], output[][e_gpci_list_output_structure], max, &count) {
	new
		name[MAX_PLAYER_NAME],
		hash[MAX_GPCI_LEN],
		date;

	stmt_bind_result_field(stmt_GpciGetRecordsFromGpci, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_GpciGetRecordsFromGpci, 1, DB::TYPE_STRING, hash, MAX_GPCI_LEN);
	stmt_bind_result_field(stmt_GpciGetRecordsFromGpci, 2, DB::TYPE_INTEGER, date);
	stmt_bind_value(stmt_GpciGetRecordsFromGpci, 0, DB::TYPE_STRING, inputgpci, MAX_GPCI_LEN);

	if(!stmt_execute(stmt_GpciGetRecordsFromGpci)) return 0;

	while(stmt_fetch_row(stmt_GpciGetRecordsFromGpci) && count < max) {
		strcat(output[count][gpci_name], name, MAX_PLAYER_NAME);
		strcat(output[count][gpci_gpci], hash, MAX_GPCI_LEN);
		output[count][gpci_date] = date;

		count++;
	}

	return 1;
}

stock GetAccountGpciHistoryFromName(inputname[], output[][e_gpci_list_output_structure], max, &count)
{
	new
		name[MAX_PLAYER_NAME],
		hash[MAX_GPCI_LEN],
		date;

	stmt_bind_result_field(stmt_GpciGetRecordsFromName, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_GpciGetRecordsFromName, 1, DB::TYPE_STRING, hash, MAX_GPCI_LEN);
	stmt_bind_result_field(stmt_GpciGetRecordsFromName, 2, DB::TYPE_INTEGER, date);
	stmt_bind_value(stmt_GpciGetRecordsFromName, 0, DB::TYPE_STRING, inputname, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_GpciGetRecordsFromName))
		return 0;

	while(stmt_fetch_row(stmt_GpciGetRecordsFromName) && count < max)
	{
		strcat(output[count][gpci_name], name, MAX_PLAYER_NAME);
		strcat(output[count][gpci_gpci], hash, MAX_GPCI_LEN);
		output[count][gpci_date] = date;

		count++;
	}

	return 1;
}

ShowAccountGpciHistoryFromGpci(playerid, hash[MAX_GPCI_LEN])
{
	new
		list[MAX_GPCI_LOG_RESULTS][e_gpci_list_output_structure],
		newlist[MAX_GPCI_LOG_RESULTS][MAX_PLAYER_NAME],
		count;

	if(!GetAccountGpciHistoryFromGpci(hash, list, MAX_GPCI_LOG_RESULTS, count))
	{
		ChatMsg(playerid, YELLOW, " >  Failed");
		return 1;
	}

	if(count == 0)
	{
		ChatMsg(playerid, YELLOW, " >  No results");
		return 1;
	}

	for(new i; i < count; i++)
	{
		strcat(newlist[i], list[i][gpci_name], MAX_PLAYER_NAME);
	}

	ShowPlayerList(playerid, newlist, count, true);

	return 1;
}

ShowAccountGpciHistoryFromName(playerid, name[])
{
    if(!IsPlayerNPC(playerid))
	{
	new
		list[MAX_GPCI_LOG_RESULTS][e_gpci_list_output_structure],
		newlist[MAX_GPCI_LOG_RESULTS][MAX_PLAYER_NAME],
		count;

	if(!GetAccountGpciHistoryFromName(name, list, MAX_GPCI_LOG_RESULTS, count))
	{
		ChatMsg(playerid, YELLOW, " >  Failed");
		return 1;
	}

	if(count == 0)
	{
		ChatMsg(playerid, YELLOW, " >  No results");
		return 1;
	}

	gBigString[playerid][0] = EOS;

	for(new i; i < count; i++)
	{
		strcat(newlist[i], list[i][gpci_name], MAX_PLAYER_NAME);
	}

	ShowPlayerList(playerid, newlist, count, true);
	}
	return 1;
}
