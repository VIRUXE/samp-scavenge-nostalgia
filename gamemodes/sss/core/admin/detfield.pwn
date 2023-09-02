#include <YSI\y_hooks>

#define MAX_DETFIELD				(250)
#define MAX_DETFIELD_NAME			(64)
#define MAX_DETFIELD_EXCEPTIONS		(32)


/*
	Schema:
		field_list(name, vert1..4, minZ, maxZ)
		- Contains a list of detection fields.

		field_logs(field, name, pos, time)
		- Contains every log record for each field.
*/

enum {
			FIELD_ID_DETFIELD_NAME,
			FIELD_ID_DETFIELD_VERT1,
			FIELD_ID_DETFIELD_VERT2,
			FIELD_ID_DETFIELD_VERT3,
			FIELD_ID_DETFIELD_VERT4,
			FIELD_ID_DETFIELD_Z1,
			FIELD_ID_DETFIELD_Z2,
			FIELD_ID_DETFIELD_EXCEPTIONS,
			FIELD_ID_DETFIELD_ACTIVE
}

enum {
			FIELD_ID_DETLOG_FIELD,
			FIELD_ID_DETLOG_NAME,
			FIELD_ID_DETLOG_POS,
			FIELD_ID_DETLOG_DATE,
			FIELD_ID_DETLOG_ACTIVE
}

enum E_DETLOG_BUFFER_DATA {
			DETLOG_BUFFER_ROW_ID,
			DETLOG_BUFFER_NAME[MAX_DETFIELD_NAME],
Float:		DETLOG_BUFFER_POS_X,
Float:		DETLOG_BUFFER_POS_Y,
Float:		DETLOG_BUFFER_POS_Z,
			DETLOG_BUFFER_DATE
}


static
			det_Name			[MAX_DETFIELD][MAX_DETFIELD_NAME],
			det_AreaID			[MAX_DETFIELD],
Float:		det_Points			[MAX_DETFIELD][10],
			det_Exceptions		[MAX_DETFIELD][MAX_DETFIELD_EXCEPTIONS][MAX_PLAYER_NAME],
			det_ExceptionCount	[MAX_DETFIELD],
Float:		det_MinZ			[MAX_DETFIELD],
Float:		det_MaxZ			[MAX_DETFIELD],
			det_Lines			[MAX_DETFIELD][8],
bool:		det_Active			[MAX_DETFIELD];

new
   Iterator:det_Index<MAX_DETFIELD>;

static
DB:			det_Database,
DBStatement:det_Stmt_DetfieldAdd,
DBStatement:det_Stmt_DetfieldExists,
DBStatement:det_Stmt_DetfieldDelete,
DBStatement:det_Stmt_DetfieldRename,
DBStatement:det_Stmt_DetfieldRenameRecords,
DBStatement:det_Stmt_DetfieldSetExcps,
DBStatement:det_Stmt_DetfieldLoad,
DBStatement:det_Stmt_DetfieldLogEntry,
DBStatement:det_Stmt_DetfieldLogEntryCount,
DBStatement:det_Stmt_DetfieldLogList,
DBStatement:det_Stmt_DetfieldLogGetName,
DBStatement:det_Stmt_DetfieldLogGetPos,
DBStatement:det_Stmt_DetfieldLogGetTime,
DBStatement:det_Stmt_DetfieldLogDelete,
DBStatement:det_Stmt_DetfieldLogDeleteN,
DBStatement:det_Stmt_DetfieldGetNameLogs;

static bool:trunk_playerNotAllowed[MAX_PLAYERS];

hook OnScriptInit() {
	det_Database = db_open_persistent("data/detfield.db");

	db_query(det_Database, "CREATE TABLE IF NOT EXISTS field_list (\
		name TEXT,\
		vert1 TEXT,\
		vert2 TEXT,\
		vert3 TEXT,\
		vert4 TEXT,\
		minz REAL,\
		maxz REAL,\
		excps TEXT,\
		active INTEGER)");

	db_query(det_Database, "CREATE TABLE IF NOT EXISTS field_logs (\
		field TEXT,\
		name TEXT,\
		pos TEXT,\
		time INTEGER,\
		active INTEGER)");

	det_Stmt_DetfieldAdd			= db_prepare(det_Database, "INSERT INTO field_list VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?)");
	det_Stmt_DetfieldExists			= db_prepare(det_Database, "SELECT COUNT(*) FROM field_list WHERE name = ?");
	det_Stmt_DetfieldDelete			= db_prepare(det_Database, "DELETE FROM field_list WHERE name = ?");
	det_Stmt_DetfieldRename			= db_prepare(det_Database, "UPDATE field_list SET name = ? WHERE name = ?");
	det_Stmt_DetfieldRenameRecords	= db_prepare(det_Database, "UPDATE field_logs SET field = ? WHERE field = ?");
	det_Stmt_DetfieldSetExcps		= db_prepare(det_Database, "UPDATE field_list SET excps = ? WHERE name = ?");
	det_Stmt_DetfieldLoad			= db_prepare(det_Database, "SELECT * FROM field_list");
	det_Stmt_DetfieldLogEntry		= db_prepare(det_Database, "INSERT INTO field_logs VALUES(?, ?, ?, ?, 1)");
	det_Stmt_DetfieldLogEntryCount	= db_prepare(det_Database, "SELECT COUNT(*) FROM field_logs WHERE field = ?");
	det_Stmt_DetfieldLogList		= db_prepare(det_Database, "SELECT rowid, name, pos, time FROM field_logs WHERE field = ? AND active = 1 ORDER BY time DESC LIMIT ? OFFSET ? COLLATE NOCASE");
	det_Stmt_DetfieldLogGetName		= db_prepare(det_Database, "SELECT name FROM field_logs WHERE field = ? AND rowid = ?");
	det_Stmt_DetfieldLogGetPos		= db_prepare(det_Database, "SELECT pos FROM field_logs WHERE field = ? AND rowid = ?");
	det_Stmt_DetfieldLogGetTime		= db_prepare(det_Database, "SELECT time FROM field_logs WHERE field = ? AND rowid = ?");
	det_Stmt_DetfieldLogDelete		= db_prepare(det_Database, "UPDATE field_logs SET active = 0 WHERE field = ? AND rowid = ?");
	det_Stmt_DetfieldLogDeleteN		= db_prepare(det_Database, "UPDATE field_logs SET active = 0 WHERE field = ? AND name = ?");
	det_Stmt_DetfieldGetNameLogs	= db_prepare(det_Database, "SELECT field, time FROM field_logs WHERE name = ? ORDER BY time DESC LIMIT ? OFFSET ? COLLATE NOCASE");


	DatabaseTableCheck(det_Database, "field_list", 9);
	DatabaseTableCheck(det_Database, "field_logs", 5);

	new
		name[MAX_DETFIELD_NAME],
		vert1[64],
		vert2[64],
		vert3[64],
		vert4[64],
		Float:minZ,
		Float:maxZ,
		exceptions[MAX_PLAYER_NAME * 32],
		Float:points[10],
		exceptionList[MAX_DETFIELD_EXCEPTIONS][MAX_PLAYER_NAME],
		active;

	stmt_bind_result_field(det_Stmt_DetfieldLoad, FIELD_ID_DETFIELD_NAME, DB::TYPE_STRING, name, MAX_DETFIELD_NAME);
	stmt_bind_result_field(det_Stmt_DetfieldLoad, FIELD_ID_DETFIELD_VERT1, DB::TYPE_STRING, vert1, sizeof(vert1));
	stmt_bind_result_field(det_Stmt_DetfieldLoad, FIELD_ID_DETFIELD_VERT2, DB::TYPE_STRING, vert2, sizeof(vert2));
	stmt_bind_result_field(det_Stmt_DetfieldLoad, FIELD_ID_DETFIELD_VERT3, DB::TYPE_STRING, vert3, sizeof(vert3));
	stmt_bind_result_field(det_Stmt_DetfieldLoad, FIELD_ID_DETFIELD_VERT4, DB::TYPE_STRING, vert4, sizeof(vert4));
	stmt_bind_result_field(det_Stmt_DetfieldLoad, FIELD_ID_DETFIELD_Z1, DB::TYPE_FLOAT, minZ);
	stmt_bind_result_field(det_Stmt_DetfieldLoad, FIELD_ID_DETFIELD_Z2, DB::TYPE_FLOAT, maxZ);
	stmt_bind_result_field(det_Stmt_DetfieldLoad, FIELD_ID_DETFIELD_EXCEPTIONS, DB::TYPE_STRING, exceptions, sizeof(exceptions));
	stmt_bind_result_field(det_Stmt_DetfieldLoad, FIELD_ID_DETFIELD_ACTIVE, DB::TYPE_INTEGER, active);

	stmt_execute(det_Stmt_DetfieldLoad);

	while(stmt_fetch_row(det_Stmt_DetfieldLoad)) {
		if(isnull(name)) continue;

		sscanf(vert1, "ff", points[00], points[01]);
		sscanf(vert2, "ff", points[02], points[03]);
		sscanf(vert3, "ff", points[04], points[05]);
		sscanf(vert4, "ff", points[06], points[07]);
		points[08] = points[00];
		points[09] = points[01];

		// Temp, to prevent data "leaking" to the next slot.
		for(new i; i < MAX_DETFIELD_EXCEPTIONS; i++) exceptionList[i][0] = EOS;

		sscanf(exceptions, "a<s[24]>[32]", exceptionList);

		CreateDetectionField(name, points, minZ, maxZ, exceptionList, active);

		printf("[DETFIELD] %s (%s) -> Ativa: %s", name, exceptionList[0], active ? "Sim" : "Não");
	}

	log("[DETFIELD] Loaded %d Detection Fields", Iter_Count(det_Index));

	return 1;
}

stock CreateDetectionField(name[MAX_DETFIELD_NAME], Float:points[10], Float:minZ, Float:maxZ, exceptionList[MAX_DETFIELD_EXCEPTIONS][MAX_PLAYER_NAME], active) {
	new const id = Iter_Free(det_Index);

	if(id == ITER_NONE) {
		err("MAX_DETFIELD limit reached.");
		return -1;
	}

	if(!IsValidDetectionFieldName(name)) return -2;

	det_AreaID[id]         = CreateDynamicPolygon(points, minZ, maxZ, .maxpoints = 10);
	det_Name[id]           = name;
	det_Points[id]         = points;
	det_MinZ[id]           = minZ;
	det_MaxZ[id]           = maxZ;
	det_ExceptionCount[id] = 0;
	det_Active[id]		   = active ? true : false;

	for(new i; i < MAX_DETFIELD_EXCEPTIONS; i++) {
		if(!isnull(exceptionList[det_ExceptionCount[id]]))
			det_Exceptions[id][det_ExceptionCount[id]++] = exceptionList[i];
	}

	Iter_Add(det_Index, id);

	// Linhas (Corda: 19087, Length: 2.46 / Neon: 18649 (verde), Length: 2.00)
	new const lineObjectId = active ? 18652 : 18647, Float:objectLength = 2.00;
	for(new i; i < 8; i += 2) {
		// Linhas para baixo
		det_Lines[id][i + 0] = CreateLineSegment(lineObjectId, objectLength,
			points[i + 0], points[i + 1], minZ,
			points[i + 2], points[i + 3], minZ, .objlengthoffset = -(objectLength/2));

		// Linhas para cima
		det_Lines[id][i + 1] = CreateLineSegment(lineObjectId, objectLength,
			points[i + 0], points[i + 1], maxZ,
			points[i + 2], points[i + 3], maxZ, .objlengthoffset = -(objectLength/2));
	}

	return id;
}

stock DestroyDetectionField(detfieldId) {
	if(!Iter_Contains(det_Index, detfieldId)) return 0;

	DestroyDynamicArea(det_AreaID[detfieldId]);
	det_Name[detfieldId][0] = EOS;

	for(new i; i < 8; i++) {
		DestroyLineSegment(det_Lines[detfieldId][i]);
		det_Lines[detfieldId][i] = INVALID_LINE_SEGMENT_ID;
	}

	Iter_Remove(det_Index, detfieldId);

	return 1;
}

bool:IsDetectionFieldActive(detfieldId) return det_Active[detfieldId];

AddDetectionField(name[MAX_DETFIELD_NAME], Float:points[10], Float:minZ, Float:maxZ, exceptionList[MAX_DETFIELD_EXCEPTIONS][MAX_PLAYER_NAME], active) {
	if(!IsValidDetectionFieldName(name)) return -1;

	if(DetectionFieldExists(name)) return -2;

	new id = CreateDetectionField(name, points, minZ, maxZ, exceptionList, active);

	if(id < 0) return -3;

	new
		vert1[32],
		vert2[32],
		vert3[32],
		vert4[32],
		exceptions[MAX_DETFIELD_EXCEPTIONS * (MAX_PLAYER_NAME + 1) + 1];

	format(vert1, sizeof(vert1), "%f %f", points[0], points[1]);
	format(vert2, sizeof(vert2), "%f %f", points[2], points[3]);
	format(vert3, sizeof(vert3), "%f %f", points[4], points[5]);
	format(vert4, sizeof(vert4), "%f %f", points[6], points[7]);

	for(new i; i < det_ExceptionCount[id]; i++) {
		if(i) strcat(exceptions, " ");

		strcat(exceptions, exceptionList[i]);
	}

	stmt_bind_value(det_Stmt_DetfieldAdd, 0, DB::TYPE_STRING, name, MAX_DETFIELD_NAME);
	stmt_bind_value(det_Stmt_DetfieldAdd, 1, DB::TYPE_STRING, vert1, sizeof(vert1));
	stmt_bind_value(det_Stmt_DetfieldAdd, 2, DB::TYPE_STRING, vert2, sizeof(vert2));
	stmt_bind_value(det_Stmt_DetfieldAdd, 3, DB::TYPE_STRING, vert3, sizeof(vert3));
	stmt_bind_value(det_Stmt_DetfieldAdd, 4, DB::TYPE_STRING, vert4, sizeof(vert4));
	stmt_bind_value(det_Stmt_DetfieldAdd, 5, DB::TYPE_FLOAT, minZ);
	stmt_bind_value(det_Stmt_DetfieldAdd, 6, DB::TYPE_FLOAT, maxZ);
	stmt_bind_value(det_Stmt_DetfieldAdd, 7, DB::TYPE_STRING, exceptions, sizeof(exceptions));
	stmt_bind_value(det_Stmt_DetfieldAdd, 8, DB::TYPE_INTEGER, active ? 1 : 0);

	if(!stmt_execute(det_Stmt_DetfieldAdd)) return -4;

	return id;
}

stock RemoveDetectionField(detfieldId) {
	if(!Iter_Contains(det_Index, detfieldId)) return 0;

	stmt_bind_value(det_Stmt_DetfieldDelete, 0, DB::TYPE_STRING, det_Name[detfieldId], MAX_DETFIELD_NAME);

	DestroyDetectionField(detfieldId);

	if(!stmt_execute(det_Stmt_DetfieldDelete)) return 0;

	return 1;
}

stock DetectionFieldExists(name[]) {
	new count;

	stmt_bind_value(det_Stmt_DetfieldExists, 0, DB::TYPE_STRING, name, MAX_DETFIELD_NAME);
	stmt_bind_result_field(det_Stmt_DetfieldExists, 0, DB::TYPE_INTEGER, count);

	if(!stmt_execute(det_Stmt_DetfieldExists)) return 0;

	stmt_fetch_row(det_Stmt_DetfieldExists);

	if(count) return 1;

	return 0;
}

SetDetectionFieldActive(detfieldId, bool:active) {
	if(!Iter_Contains(det_Index, detfieldId)) return 0;

	det_Active[detfieldId] = active;

	db_query(det_Database, sprintf("UPDATE field_list SET active = %d WHERE name = '%s';", active ? 1 : 0, det_Name[detfieldId]));

	// Eliminamos as linhas antigas
	for(new i; i < 8; i++) {
		DestroyLineSegment(det_Lines[detfieldId][i]);
		det_Lines[detfieldId][i] = INVALID_LINE_SEGMENT_ID;
	}

	// Criamos com a nova cor de neon
	new const lineObjectId = active ? 18652 : 18647, Float:objectLength = 2.00;
	for(new i; i < 8; i += 2) {
		// Linhas para baixo
		det_Lines[detfieldId][i + 0] = CreateLineSegment(lineObjectId, objectLength,
			det_Points[detfieldId][i + 0], det_Points[detfieldId][i + 1], det_MinZ[detfieldId],
			det_Points[detfieldId][i + 2], det_Points[detfieldId][i + 3], det_MinZ[detfieldId], .objlengthoffset = -(objectLength/2));

		// Linhas para cima
		det_Lines[detfieldId][i + 1] = CreateLineSegment(lineObjectId, objectLength,
			det_Points[detfieldId][i + 0], det_Points[detfieldId][i + 1], det_MaxZ[detfieldId],
			det_Points[detfieldId][i + 2], det_Points[detfieldId][i + 3], det_MaxZ[detfieldId], .objlengthoffset = -(objectLength/2));
	}

	log("[DETFIELD] SetDetectionFieldActive(%d, %s)", detfieldId, booltostr(active));

	return 1;
}

stock SetDetectionFieldName(detfieldId, name[MAX_DETFIELD_NAME]) {
	if(!Iter_Contains(det_Index, detfieldId)) return 0;

	if(DetectionFieldExists(name)) return -1;

	if(!IsValidDetectionFieldName(name)) return -2;

	stmt_bind_value(det_Stmt_DetfieldRename, 0, DB::TYPE_STRING, name, MAX_DETFIELD_NAME);
	stmt_bind_value(det_Stmt_DetfieldRename, 1, DB::TYPE_STRING, det_Name[detfieldId], MAX_DETFIELD_NAME);

	stmt_execute(det_Stmt_DetfieldRename);

	stmt_bind_value(det_Stmt_DetfieldRenameRecords, 0, DB::TYPE_STRING, name, MAX_DETFIELD_NAME);
	stmt_bind_value(det_Stmt_DetfieldRenameRecords, 1, DB::TYPE_STRING, det_Name[detfieldId], MAX_DETFIELD_NAME);

	stmt_execute(det_Stmt_DetfieldRenameRecords);

	db_query(det_Database, sprintf("ALTER TABLE %s RENAME TO %s", det_Name[detfieldId], name));

	det_Name[detfieldId] = name;

	return 1;
}

stock GetDetectionFieldList(list[], string[], limit, offset) {
	new
		j,
		count = Iter_Count(det_Index);

	if(offset > count) offset = count;

	foreach(new i : det_Index) {
		if(j >= offset) {
			if(j >= offset + limit) break;

			list[j - offset] = i;

			if(i) strcat(string, "\n", limit * (MAX_DETFIELD_NAME + 1));

			strcat(string, det_Active[i] ? det_Name[i] : sprintf("%s%s", C_YELLOW, det_Name[i]), limit * (MAX_DETFIELD_NAME + 1));
		}

		j++;
	}

	return j - offset;
}

stock GetDetectionFieldNameLog(name[], string[], limit, offset, len = sizeof(string)) {
	new
		fieldname[MAX_PLAYER_NAME],
		timestamp,
		count;

	stmt_bind_value(det_Stmt_DetfieldGetNameLogs, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_value(det_Stmt_DetfieldGetNameLogs, 1, DB::TYPE_INTEGER, limit);
	stmt_bind_value(det_Stmt_DetfieldGetNameLogs, 2, DB::TYPE_INTEGER, offset);
	stmt_bind_result_field(det_Stmt_DetfieldGetNameLogs, 0, DB::TYPE_STRING, fieldname, MAX_DETFIELD_NAME);
	stmt_bind_result_field(det_Stmt_DetfieldGetNameLogs, 1, DB::TYPE_INTEGER, timestamp);

	if(!stmt_execute(det_Stmt_DetfieldGetNameLogs)) return 0;

	while(stmt_fetch_row(det_Stmt_DetfieldGetNameLogs)) {
		format(string, len, "%s%s %s\n", string, fieldname, TimestampToDateTime(timestamp, "%d/%m/%y %X"));
		count++;
	}

	return count;
}

stock GetDetectionFieldLogBuffer(detfieldId, output[][E_DETLOG_BUFFER_DATA], limit, offset) {
	if(!Iter_Contains(det_Index, detfieldId)) return 0;

	new
		rowid,
		name[MAX_PLAYER_NAME],
		pos[32],
		timestamp,
		Float:x, Float:y, Float:z,
		count;

	stmt_bind_value(det_Stmt_DetfieldLogList, 0, DB::TYPE_STRING, det_Name[detfieldId], MAX_DETFIELD_NAME);
	stmt_bind_value(det_Stmt_DetfieldLogList, 1, DB::TYPE_INTEGER, limit);
	stmt_bind_value(det_Stmt_DetfieldLogList, 2, DB::TYPE_INTEGER, offset);

	stmt_bind_result_field(det_Stmt_DetfieldLogList, 0, DB::TYPE_INTEGER, rowid);
	stmt_bind_result_field(det_Stmt_DetfieldLogList, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(det_Stmt_DetfieldLogList, 2, DB::TYPE_STRING, pos, sizeof(pos));
	stmt_bind_result_field(det_Stmt_DetfieldLogList, 3, DB::TYPE_INTEGER, timestamp);

	if(!stmt_execute(det_Stmt_DetfieldLogList)) return -1;

	while(stmt_fetch_row(det_Stmt_DetfieldLogList)) {
		sscanf(pos, "fff", x, y, z);

		output[count][DETLOG_BUFFER_ROW_ID]  = rowid;
		output[count][DETLOG_BUFFER_NAME][0] = EOS;
		strcpy(output[count][DETLOG_BUFFER_NAME], name, MAX_PLAYER_NAME);
		output[count][DETLOG_BUFFER_POS_X] = x;
		output[count][DETLOG_BUFFER_POS_Y] = y;
		output[count][DETLOG_BUFFER_POS_Z] = z;
		output[count][DETLOG_BUFFER_DATE]  = timestamp;
		count++;
	}

	return count;
}

stock GetDetectionFields() return Iter_Count(det_Index);

stock GetDetectionFieldLogEntries(detfieldId) {
	if(!Iter_Contains(det_Index, detfieldId)) return 0;

	new count;

	stmt_bind_value(det_Stmt_DetfieldLogEntryCount, 0, DB::TYPE_STRING, det_Name[detfieldId], MAX_DETFIELD_NAME);
	stmt_bind_result_field(det_Stmt_DetfieldLogEntryCount, 0, DB::TYPE_INTEGER, count);

	if(!stmt_execute(det_Stmt_DetfieldLogEntryCount)) return 0;

	stmt_fetch_row(det_Stmt_DetfieldLogEntryCount);

	return count;
}

stock GetDetectionFieldExceptions(detfieldId, list[MAX_DETFIELD_EXCEPTIONS][MAX_PLAYER_NAME]) {
	if(!Iter_Contains(det_Index, detfieldId)) return 0;

	new i;

	for(i = 0; i < det_ExceptionCount[detfieldId]; i++) {
		if(isnull(det_Exceptions[detfieldId][i])) break;

		list[i] = det_Exceptions[detfieldId][i];
	}

	return i;
}

stock GetDetectionFieldExceptionsList(detfieldId, list[], length, delimiter = '\n') {
	if(!Iter_Contains(det_Index, detfieldId)) return 0;

	new i;

	for(i = 0; i < det_ExceptionCount[detfieldId]; i++) {
		if(isnull(det_Exceptions[detfieldId][i])) break;

		if(i > 0) list[strlen(list)] = delimiter;

		strcat(list, det_Exceptions[detfieldId][i], length);
	}

	return i;
}

static bool:fld_PlayerInvade[MAX_PLAYERS];

stock AddDetectionFieldException(detfieldId, name[MAX_PLAYER_NAME]) {
	if(!Iter_Contains(det_Index, detfieldId)) return 0;

	if(det_ExceptionCount[detfieldId] == MAX_DETFIELD_EXCEPTIONS) return -1;

	if(!IsValidNickname(name)) return -2;

	if(IsNameInExceptionList(detfieldId, name)) return -3;

	det_Exceptions[detfieldId][det_ExceptionCount[detfieldId]] = name;
	det_ExceptionCount[detfieldId]++;

	UpdateDetectionFieldExceptions(detfieldId);

	new targetId = GetPlayerIDFromName(name);
	if(targetId != INVALID_PLAYER_ID) {
		ChatMsg(targetId, GREEN, "Você foi adicionado como excepção em uma base com campo de proteção (%s).", det_Name[detfieldId]);
        fld_PlayerInvade[targetId] = false;
	}

	return det_ExceptionCount[detfieldId];
}

stock RemoveDetectionFieldExceptionID(detfieldId, exceptionId) {
	if(!Iter_Contains(det_Index, detfieldId)) return 0;

	if(!det_ExceptionCount[detfieldId]) return -1;

	if(exceptionId > det_ExceptionCount[detfieldId]) return -2;

	for(new i = exceptionId; i < det_ExceptionCount[detfieldId]; i++) {
		if(i + 1 == det_ExceptionCount[detfieldId]) {
			det_Exceptions[detfieldId][i][0] = EOS;
			break;
		}

		det_Exceptions[detfieldId][i] = det_Exceptions[detfieldId][i + 1];
	}

	det_ExceptionCount[detfieldId]--;
	UpdateDetectionFieldExceptions(detfieldId);

	return det_ExceptionCount[detfieldId];
}

stock RemoveDetectionFieldException(detfieldId, name[MAX_PLAYER_NAME]) {
	if(!Iter_Contains(det_Index, detfieldId)) return 0;

	if(det_ExceptionCount[detfieldId] == 0) return -1;

	new found;

	for(new i; i < det_ExceptionCount[detfieldId]; i++) {
		if(!found) {
			if(!strcmp(det_Exceptions[detfieldId][i], name) && isnull(det_Exceptions[detfieldId][i]))
				found = true;
		} else {
			if(i + 1 == det_ExceptionCount[detfieldId]) {
				det_Exceptions[detfieldId][i][0] = EOS;
				break;
			}

			det_Exceptions[detfieldId][i] = det_Exceptions[detfieldId][i + 1];
		}
	}

	det_ExceptionCount[detfieldId]--;
	UpdateDetectionFieldExceptions(detfieldId);

	return det_ExceptionCount[detfieldId];
}

stock GetDetectionFieldLogEntryName(detfieldId, logEntry, name[MAX_PLAYER_NAME]) {
	if(!Iter_Contains(det_Index, detfieldId)) return 0;

	stmt_bind_value(det_Stmt_DetfieldLogGetName, 0, DB::TYPE_INTEGER, logEntry);
	stmt_bind_value(det_Stmt_DetfieldLogGetName, 1, DB::TYPE_STRING, det_Name[detfieldId], MAX_DETFIELD_NAME);
	stmt_bind_result_field(det_Stmt_DetfieldLogGetName, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(det_Stmt_DetfieldLogGetName)) return 0;

	stmt_fetch_row(det_Stmt_DetfieldLogGetName);

	return 1;
}

stock GetDetectionFieldLogEntryPos(detfieldId, logEntry, &Float:x, &Float:y, &Float:z) {
	if(!Iter_Contains(det_Index, detfieldId)) return 0;

	new pos[32];

	stmt_bind_value(det_Stmt_DetfieldLogGetPos, 0, DB::TYPE_STRING, det_Name[detfieldId], MAX_DETFIELD_NAME);
	stmt_bind_value(det_Stmt_DetfieldLogGetPos, 1, DB::TYPE_INTEGER, logEntry);
	stmt_bind_result_field(det_Stmt_DetfieldLogGetPos, 0, DB::TYPE_STRING, pos, sizeof(pos));

	if(!stmt_execute(det_Stmt_DetfieldLogGetPos)) return 0;

	stmt_fetch_row(det_Stmt_DetfieldLogGetPos);

	sscanf(pos, "fff", x, y, z);

	return 1;
}

stock GetDetectionFieldLogEntryTime(detfieldId, logEntry) {
	if(!Iter_Contains(det_Index, detfieldId)) return 0;

	new timestamp;

	stmt_bind_value(det_Stmt_DetfieldLogGetTime, 0, DB::TYPE_INTEGER, logEntry);
	stmt_bind_value(det_Stmt_DetfieldLogGetTime, 1, DB::TYPE_STRING, det_Name[detfieldId], MAX_DETFIELD_NAME);
	stmt_bind_result_field(det_Stmt_DetfieldLogGetTime, 0, DB::TYPE_INTEGER, timestamp);

	if(!stmt_execute(det_Stmt_DetfieldLogGetTime)) return 0;

	stmt_fetch_row(det_Stmt_DetfieldLogGetTime);

	return timestamp;
}

stock DeleteDetectionFieldLogEntry(detfieldId, logEntry) {
	if(!Iter_Contains(det_Index, detfieldId)) return 0;

	stmt_bind_value(det_Stmt_DetfieldLogDelete, 0, DB::TYPE_STRING, det_Name[detfieldId], MAX_DETFIELD_NAME);
	stmt_bind_value(det_Stmt_DetfieldLogDelete, 1, DB::TYPE_INTEGER, logEntry);

	if(!stmt_execute(det_Stmt_DetfieldLogDelete)) return 0;

	return 1;
}

stock DeleteDetectionFieldLogsOfName(detfieldId, name[]) {
	if(!Iter_Contains(det_Index, detfieldId)) return 0;

	stmt_bind_value(det_Stmt_DetfieldLogDeleteN, 0, DB::TYPE_STRING, det_Name[detfieldId], MAX_DETFIELD_NAME);
	stmt_bind_value(det_Stmt_DetfieldLogDeleteN, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(!stmt_execute(det_Stmt_DetfieldLogDeleteN)) return 0;

	return 1;
}

timer HandleFieldInvasionOnLogin[SEC(1)](playerid) {
	new detfieldId = IsPlayerInsideDetectionField(playerid);

	if(detfieldId != -1 && !IsNameInExceptionList(detfieldId, GetPlayerNameEx(playerid))) {
		// TODO: Achar uma forma de simplesmente colocar fora e nao dar spawn aleatorio
		new Float:x, Float:y, Float:z, Float:r;

		GenerateSpawnPoint(playerid, x, y, z, r);
		Streamer_UpdateEx(playerid, x, y, z, 0, 0);
		SetPlayerPos(playerid, x, y, z);
		SetPlayerFacingAngle(playerid, r);
		SetPlayerVirtualWorld(playerid, 0);
		SetPlayerInterior(playerid, 0);
		SetCameraBehindPlayer(playerid);
		fld_PlayerInvade[playerid] = false;

		ChatMsg(playerid, YELLOW, " > Você nasceu em uma área com Campo de Deteção e foi respawnado!");
	}
}

hook OnPlayerConnect(playerid) {
	fld_PlayerInvade[playerid]       = false;
	trunk_playerNotAllowed[playerid] = false;
}

hook OnPlayerLogin(playerid) {
	// Esperamos o mundo carregar completamente (1 seg) e depois verificamos se o jogador esta numa field sem excepcao
	defer HandleFieldInvasionOnLogin(playerid);

	if(GetPlayerAdminLevel(playerid) >= LEVEL_MODERATOR) {
		foreach(new d : det_Index) {
			if(!det_Active[d]) {
				SendClientMessage(playerid, RED, " > Existem Campos de Deteção por Ativar!");
				break;
			}
		}
	}
}

IsPlayerInsideDetectionField(playerid) {
	new Float:x, Float:y, Float:z;

	GetPlayerPos(playerid, x,y,z);

	foreach(new i : det_Index) if(IsPointInDynamicArea(det_AreaID[i], x, y, z)) return i;

	return -1;
}

IsPlayerDetectionFieldOwner(playerid, detfieldId) {
	if(IsValidDetectionField(detfieldId)) return -1;

	if(isequal(det_Exceptions[detfieldId][0], GetPlayerNameEx(playerid))) return 1;

	return 0;
}

hook OnPlayerEnterDynArea(playerid, areaid) {
	if(GetPlayerVirtualWorld(playerid) != 0) return Y_HOOKS_CONTINUE_RETURN_0;

	foreach(new i : det_Index) {
		if(areaid != det_AreaID[i]) continue; // Ignorar se nao for uma detfield

		if(!IsPlayerOnAdminDuty(playerid)) { // Jogador normal
			if(!IsDetectionFieldActive(i)) continue; // Ignore se nao estiver ativa

			DetectionFieldLogPlayer(playerid, i);

			if(!IsNameInExceptionList(i, GetPlayerNameEx(playerid))) {
				ShowPlayerDialog(playerid, DIALOG_ENTER_DETFIELD, DIALOG_STYLE_MSGBOX, "Proteção Anti-Cheater "C_RED"FIELD DETECTION", 
					C_WHITE"Você entrou em uma base com proteção FIELD sem ter acesso.\n\n\
					Você não poderá fazer as seguintes coisas:\n\n\
					"C_YELLOW"\t- Construir.\n\
					\t- Desmontar com pé de cabra.\n\
					\t- Interagir tendas e caixas.\n\
					\t- Interagir com veículos.\n\n\
					"C_WHITE"Se você entrou em uma base aberta ou explodiu ela, chame um membro da equipe para remover a proteção.\n\n\
					"C_RED"[AVISO] Isso serve para evitar que hackers invadam bases no servidor.",
				"Fechar", "");

				new fmt[] = "%p (%d) entrou em uma base sem acesso. Nome: %s";
				
				log(sprintf("[DETFIELD] %s", fmt), playerid, playerid, det_Name[i]);
				ChatMsgAdmins(LEVEL_MODERATOR, PINK, fmt, playerid, playerid, det_Name[i]);
				
				PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);

				fld_PlayerInvade[playerid] = true;
			} else
				ShowHelpTip(playerid, "Você entrou como excepção em uma base com Detection Field.", 8000);
		} else if(GetPlayerAdminLevel(playerid)) // Aviso de field para admin
			GameTextForPlayer(playerid, sprintf("Field: ~w~%s", det_Name[i]), SEC(2), 3);
	}

	return Y_HOOKS_CONTINUE_RETURN_1;
}

stock IsPlayerInvadedField(playerid) return fld_PlayerInvade[playerid];

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid) {
	if(fld_PlayerInvade[playerid]) {
		StopHoldAction(playerid);
		ClearAnimations(playerid);
		HideActionText(playerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger) {	
	if(BlockFieldVehicle(playerid, vehicleid)) CancelPlayerMovement(playerid);

	return 1;
}

hook OnPlayerLeaveDynArea(playerid, areaid) {
	foreach(new i : det_Index) {
		if(!IsDetectionFieldActive(i)) continue;

		if(areaid == det_AreaID[i]) {
		    if(fld_PlayerInvade[playerid]) {
				new fmt[] = "%p (%d) saiu de uma base sem acesso. Nome: %s";

				log(sprintf("[DETFIELD] %s", fmt), playerid, playerid, det_Name[i]);
				ChatMsgAdmins(LEVEL_MODERATOR, PINK, fmt, playerid, playerid, det_Name[i]);

				fld_PlayerInvade[playerid] = false;
			}
		}
	}
}

stock IsPlayerInvaddedField(playerid) {
	if(!IsPlayerConnected(playerid)) return 0;

	if(fld_PlayerInvade[playerid]) return 1;

    new Float:x, Float:y, Float:z, bool:pinf, pName[24];
	GetPlayerPos(playerid, x, y, z);

	GetPlayerName(playerid, pName, 24);

	pinf = false;

    foreach(new i : det_Index) {
		if(!IsDetectionFieldActive(i)) continue;

		if(IsPointInDynamicArea(det_AreaID[i], x, y, z))
			if(!IsNameInExceptionList(i, pName)) pinf = true;

		if(IsPointInDynamicArea(det_AreaID[i], x + 3.0, y, z))
			if(!IsNameInExceptionList(i, pName)) pinf = true;

		if(IsPointInDynamicArea(det_AreaID[i], x - 3.0, y, z))
			if(!IsNameInExceptionList(i, pName)) pinf = true;

		if(IsPointInDynamicArea(det_AreaID[i], x, y + 3.0, z))
			if(!IsNameInExceptionList(i, pName)) pinf = true;

		if(IsPointInDynamicArea(det_AreaID[i], x, y - 3.0, z))
			if(!IsNameInExceptionList(i, pName)) pinf = true;

		if(IsPointInDynamicArea(det_AreaID[i], x + 3.0, y + 3.0, z))
			if(!IsNameInExceptionList(i, pName)) pinf = true;

		if(IsPointInDynamicArea(det_AreaID[i], x + 3.0, y - 3.0, z))
			if(!IsNameInExceptionList(i, pName)) pinf = true;

		if(IsPointInDynamicArea(det_AreaID[i], x - 3.0, y + 3.0, z))
			if(!IsNameInExceptionList(i, pName)) pinf = true;

		if(IsPointInDynamicArea(det_AreaID[i], x - 3.0, y - 3.0, z))
			if(!IsNameInExceptionList(i, pName)) pinf = true;
	}

	return pinf;
}

// ? que merda e essa
stock BlockFieldVehicle(playerid, vehicleid) {
	if(!IsValidVehicle(vehicleid)) return 0;

	new Float:vehX, Float:vehY, Float:vehZ;
		
	GetVehiclePos(vehicleid, vehX, vehY, vehZ);

	foreach(new i : det_Index) {
		if(!IsDetectionFieldActive(i)) continue;

		if(IsPointInDynamicArea(det_AreaID[i], vehX, vehY, vehZ)) trunk_playerNotAllowed[playerid] = !IsNameInExceptionList(i, GetPlayerNameEx(playerid));
	}

	return trunk_playerNotAllowed[playerid];
}

DetectionFieldLogPlayer(playerid, detfieldId) {
	new name[MAX_PLAYER_NAME];

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	for(new i; i < det_ExceptionCount[detfieldId]; i++) {
		if(!strcmp(det_Exceptions[detfieldId][i], name, _, true)) 
			return 0;
	}

	new Float:x, Float:y, Float:z,
		pos[32],
		timestamp,
		line[MAX_PLAYER_NAME + 36 + 2];

	GetPlayerPos(playerid, x, y, z);
	format(pos, sizeof(pos), "%.2f %.2f %.2f", x, y, z);
	timestamp = gettime();

	stmt_bind_value(det_Stmt_DetfieldLogEntry, 0, DB::TYPE_STRING, det_Name[detfieldId], MAX_DETFIELD_NAME);
	stmt_bind_value(det_Stmt_DetfieldLogEntry, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_value(det_Stmt_DetfieldLogEntry, 2, DB::TYPE_STRING, pos, sizeof(pos));
	stmt_bind_value(det_Stmt_DetfieldLogEntry, 3, DB::TYPE_INTEGER, timestamp);

	if(!stmt_execute(det_Stmt_DetfieldLogEntry)) return -1;

	format(line, sizeof(line), "%p, %s\r\n", playerid, TimestampToDateTime(gettime()));

	log("[DETFIELD] %p entered %s at %s", playerid, det_Name[detfieldId], TimestampToDateTime(gettime()));

	return 1;
}

UpdateDetectionFieldExceptions(detfieldId) {
	if(!Iter_Contains(det_Index, detfieldId)) return 0;

	new exceptionList[MAX_DETFIELD_EXCEPTIONS * (MAX_PLAYER_NAME + 1)];

	for(new i; i < det_ExceptionCount[detfieldId]; i++) {
		if(i) strcat(exceptionList, " ");

		strcat(exceptionList, det_Exceptions[detfieldId][i]);
	}

	stmt_bind_value(det_Stmt_DetfieldSetExcps, 0, DB::TYPE_STRING, exceptionList, sizeof(exceptionList));
	stmt_bind_value(det_Stmt_DetfieldSetExcps, 1, DB::TYPE_STRING, det_Name[detfieldId], MAX_DETFIELD_NAME);

	return stmt_execute(det_Stmt_DetfieldSetExcps);
}


stock IsValidDetectionField(detfieldId) {
	if(!Iter_Contains(det_Index, detfieldId)) return 0;

	return 1;
}

stock GetTotalDetectionFields() return Iter_Count(det_Index);

stock GetDetectionFieldName(detfieldId, name[MAX_DETFIELD_NAME]) {
	if(!Iter_Contains(det_Index, detfieldId)) return 0;

	name = det_Name[detfieldId];

	return 1;
}

stock GetDetectionFieldPos(detfieldId, &Float:x, &Float:y, &Float:z) {
	if(!Iter_Contains(det_Index, detfieldId)) return 0;

	x = (det_Points[detfieldId][0] + det_Points[detfieldId][2] + det_Points[detfieldId][4] + det_Points[detfieldId][6]) / 4;
	y = (det_Points[detfieldId][1] + det_Points[detfieldId][3] + det_Points[detfieldId][5] + det_Points[detfieldId][7]) / 4;
	z = (det_MinZ[detfieldId] + det_MaxZ[detfieldId]) / 2;

	return 1;
}

stock GetDetectionFieldIdFromName(name[], bool:ignorecase = false) {
	foreach(new i : det_Index) {
		if(!strcmp(name, det_Name[i], ignorecase)) return i;
	}

	return -1;
}

stock GetDetectionFieldPoints(detfieldId, Float:points[10]) {
	if(!Iter_Contains(det_Index, detfieldId)) return 0;

	points = det_Points[detfieldId];

	return 1;
}

stock GetDetectionFieldMinZ(detfieldId, &Float:minZ) {
	if(!Iter_Contains(det_Index, detfieldId)) return 0;

	minZ = det_MinZ[detfieldId];

	return 1;
}

stock GetDetectionFieldMaxZ(detfieldId, &Float:maxZ) {
	if(!Iter_Contains(det_Index, detfieldId)) return 0;

	maxZ = det_MaxZ[detfieldId];

	return 1;
}

stock IsValidDetectionFieldName(name[]) {
    if(strlen(name) <= 5 || !isalphabetic(name[0])) return 0;

    new idx = strfind(name, "-");
    if(idx == -1) return 0;
    
    new nickname[MAX_PLAYER_NAME + 1];
    new remainder[256];
    
    strmid(nickname, name, 0, idx);
    strmid(remainder, name, idx + 1, strlen(name) - idx);

    if(!IsValidNickname(nickname)) return 0;
    
    idx = strfind(remainder, "_");
    if(idx == -1) return 0;
    
    new city[3];
    new other_part[256];
    
    strmid(city, remainder, 0, idx);
    strmid(other_part, remainder, idx + 1, strlen(remainder) - idx);
    
    if(!strcmp(city, "LS") && !strcmp(city, "SF") && !strcmp(city, "LV")) return 0;
    if(strlen(other_part) == 0) return 0;
    
    idx = strfind(other_part, "_");
    new other[256];
    new optional[256];
    
    if(idx == -1) {
        strcopy(other, other_part);
        optional[0] = EOS;
    } else {
        strmid(other, other_part, 0, idx);
        strmid(optional, other_part, idx + 1, strlen(other_part) - idx);
    }
    
    if(strlen(other) == 0 || isnumeric(other[0])) return 0;
    if(strlen(optional) > 0 && optional[0] == EOS) return 0;
    
    return 1;
}

stock GetDetectionFieldExceptionCount(detfieldId) {
	if(!Iter_Contains(det_Index, detfieldId)) return 0;

	return det_ExceptionCount[detfieldId];
}

stock GetDetectionFieldExceptionName(detfieldId, exceptionId, name[MAX_PLAYER_NAME]) {
	if(!Iter_Contains(det_Index, detfieldId)) return 0;

	if(exceptionId > det_ExceptionCount[detfieldId]) return -1;

	name = det_Exceptions[detfieldId][exceptionId];

	return 1;
}

stock SetPlayerNameField(oldName[MAX_PLAYER_NAME], newName[MAX_PLAYER_NAME]) {
    foreach(new i : det_Index) 
		if(IsNameInExceptionList(i, oldName)) AddDetectionFieldException(i, newName);

	return 1;
}

stock IsNameInExceptionList(detfieldId, name[MAX_PLAYER_NAME]) {
	if(!Iter_Contains(det_Index, detfieldId)) return 0;

	for(new i; i < det_ExceptionCount[detfieldId]; i++) {
		if(!strcmp(det_Exceptions[detfieldId][i], name)) 
			return 1;
	}

	return 0;
}