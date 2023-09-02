#include <YSI\y_hooks>

#define MAX_GPCI_LOG_RESULTS	32

enum e_gpci_list_output_structure {
	gpci_name[MAX_PLAYER_NAME],
	gpci_gpci[MAX_GPCI_LEN],
	gpci_date
}

static
DBStatement:	stmt_GpciInsert,
DBStatement:	stmt_GpciCheckName,
DBStatement:	stmt_GpciGetRecordsFromGpci,
DBStatement:	stmt_GpciGetRecordsFromName;

hook OnGameModeInit() {
	db_query(Database, "CREATE TABLE IF NOT EXISTS gpci_log (name TEXT, hash TEXT, windows_username TEXT, date INTEGER, UNIQUE(name, hash));");
	db_query(Database, "CREATE TABLE IF NOT EXISTS gpci_allowed (name TEXT, hash TEXT, date INTEGER);");

	DatabaseTableCheck(Database, "gpci_log", 4);

	stmt_GpciInsert				= db_prepare(Database, "INSERT OR IGNORE INTO gpci_log (name, hash, date) VALUES(?, ?, ?);");
	stmt_GpciCheckName			= db_prepare(Database, "SELECT COUNT(*) FROM gpci_log WHERE name=? AND hash=?");
	stmt_GpciGetRecordsFromGpci	= db_prepare(Database, "SELECT * FROM gpci_log WHERE hash=? ORDER BY date DESC");
	stmt_GpciGetRecordsFromName	= db_prepare(Database, "SELECT * FROM gpci_log WHERE name=? COLLATE NOCASE ORDER BY date DESC");
}

/* hook OnPlayerConnect(playerid) {
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
} */

stock RegisterGPCI(playerName[MAX_PLAYER_NAME], playerHash[MAX_GPCI_LEN]) {
	stmt_bind_value(stmt_GpciInsert, 0, DB::TYPE_STRING, playerName, MAX_PLAYER_NAME);
	stmt_bind_value(stmt_GpciInsert, 1, DB::TYPE_STRING, playerHash, MAX_GPCI_LEN);
	stmt_bind_value(stmt_GpciInsert, 2, DB::TYPE_INTEGER, gettime());

	if(!stmt_execute(stmt_GpciInsert)) {
		err("Failed to execute statement 'stmt_GpciInsert'.");
		return 0;
	}

	return 1;
}

stock IsValidHash(hash[MAX_GPCI_LEN]) {
	new const HASH_LENGTH   = 40;
	new const VALID_CHARS[] = "0123456789ABCDEF";

    if(strlen(hash) != HASH_LENGTH) return -1;

    for (new i = 0; i < HASH_LENGTH; i++) {
        new found = false;
		
        for (new j = 0; j < strlen(VALID_CHARS); j++) {
            if (hash[i] == VALID_CHARS[j]) {
                found = true;
                break;
            }
        }
		
        if (!found) return 0; // Character is not valid
    }

    return 1;
}

// Check if there are multiple rows of the same hash
stock CheckPlayerHashStatus(playerName[MAX_PLAYER_NAME], hash[MAX_GPCI_LEN]) {
	new validationResult = IsValidHash(hash);

    if(!validationResult) {
		log("[GPCI] '%s' - IsValidHash(%s): %d", playerName, hash, validationResult);
		ChatMsgAdmins(LEVEL_DEVELOPER, WHITE, "%s tem uma hash inválida (%s).", playerName, validationResult == 0 ? "Formato" : sprintf("Tamanho: %d", strlen(hash)));

		if(validationResult == 0) return -1; // Invalid hash format
	}

	if(isequal(hash, "ED40ED0E8089CC44C08EE9580F4C8C44EE8EE990")) return -2; // Android peasant

    new query[1024];

    format(query, sizeof(query),
        "SELECT \
            CASE \
				WHEN COUNT(gpci_log.hash) = 0 THEN 3 \
				WHEN COUNT(gpci_log.hash) = 1 THEN 2 \
                WHEN COUNT(gpci_log.hash) > 1 AND EXISTS ( \
                    SELECT 1 \
                    FROM gpci_allowed \
                    WHERE gpci_allowed.name = '%s' \
                    AND gpci_allowed.hash = '%s' \
                ) THEN 1 \
                WHEN COUNT(gpci_log.hash) > 1 AND NOT EXISTS ( \
                    SELECT 1 \
                    FROM gpci_allowed \
                    WHERE gpci_allowed.name = '%s' \
                    AND gpci_allowed.hash = '%s' \
                ) THEN 0 \
            END \
        FROM gpci_log \
        WHERE gpci_log.hash = '%s';", playerName, hash, playerName, hash, hash);

    new DBResult:dbResult = db_query(Database, query);

    if (dbResult == DB::INVALID_RESULT) {
        log("Error executing query: %s", query);
        return -3; // Error occurred during query execution
    }

    if (db_num_rows(dbResult) == 0) {
		log("Error occurred, no row returned: %s", query);
        db_free_result(dbResult);
        return -3; // Error occurred, no row returned
    }

    new result = db_get_field_int(dbResult, 0);
    db_free_result(dbResult);

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

stock GetAccountGpciHistoryFromName(inputname[], output[][e_gpci_list_output_structure], max, &count) {
	new
		name[MAX_PLAYER_NAME],
		hash[MAX_GPCI_LEN],
		date;

	stmt_bind_result_field(stmt_GpciGetRecordsFromName, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_GpciGetRecordsFromName, 1, DB::TYPE_STRING, hash, MAX_GPCI_LEN);
	stmt_bind_result_field(stmt_GpciGetRecordsFromName, 2, DB::TYPE_INTEGER, date);
	stmt_bind_value(stmt_GpciGetRecordsFromName, 0, DB::TYPE_STRING, inputname, MAX_PLAYER_NAME);

	if(!stmt_execute(stmt_GpciGetRecordsFromName)) return 0;

	while(stmt_fetch_row(stmt_GpciGetRecordsFromName) && count < max) {
		strcat(output[count][gpci_name], name, MAX_PLAYER_NAME);
		strcat(output[count][gpci_gpci], hash, MAX_GPCI_LEN);
		output[count][gpci_date] = date;

		count++;
	}

	return 1;
}