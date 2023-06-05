#include <YSI\y_hooks>

#define MAX_ADMIN_LEVELS			(7)

forward OnAdminToggleDuty(playerid, bool:toggle, bool:goBack);

enum {
	STAFF_LEVEL_NONE,
	STAFF_LEVEL_GAME_MASTER,
	STAFF_LEVEL_MODERATOR,
	STAFF_LEVEL_ADMINISTRATOR,
	STAFF_LEVEL_LEAD,
	STAFF_LEVEL_DEVELOPER,
	STAFF_LEVEL_SECRET
}

enum e_admin_data {
	admin_Name[MAX_PLAYER_NAME],
	admin_Rank
}

static
				admin_Data[MAX_ADMIN][e_admin_data],
				admin_Total,
				admin_Names[MAX_ADMIN_LEVELS][15] = {
					"Jogador",	// 0 (Unused)
					"Ajudante",	// 1
					"Moderador",	// 2
					"Administrador",	// 3
					"Lider de Admin",	// 4
					"Desenvolvedor",	// 5
					"Secreto"	// 6
				},
				admin_Colours[MAX_ADMIN_LEVELS] = {
					WHITE,			// 0 (Unused)
					TEAL,			// 1
					BLUE,			// 2
					ORANGE,			// 3
					RED,			// 4
					0x00FF00FF,		// 5
					BLACK			// 6
				},
				admin_Commands[4][1024],
DBStatement:	stmt_AdminLoadAll,
DBStatement:	stmt_AdminExists,
DBStatement:	stmt_AdminInsert,
DBStatement:	stmt_AdminUpdate,
DBStatement:	stmt_AdminDelete,
DBStatement:	stmt_AdminGetLevel;

static
				admin_Level[MAX_PLAYERS],
				admin_OnDuty[MAX_PLAYERS],
				admin_PlayerKicked[MAX_PLAYERS];

hook OnScriptInit() {
	db_free_result(db_query(Database, "CREATE TABLE IF NOT EXISTS Admins (name TEXT, level INTEGER)"));

	DatabaseTableCheck(Database, "Admins", 2);

	stmt_AdminLoadAll	= db_prepare(Database, "SELECT * FROM Admins ORDER BY level DESC");
	stmt_AdminExists	= db_prepare(Database, "SELECT COUNT(*) FROM Admins WHERE name = ?");
	stmt_AdminInsert	= db_prepare(Database, "INSERT INTO Admins VALUES(?, ?)");
	stmt_AdminUpdate	= db_prepare(Database, "UPDATE Admins SET level = ? WHERE name = ?");
	stmt_AdminDelete	= db_prepare(Database, "DELETE FROM Admins WHERE name = ?");
	stmt_AdminGetLevel	= db_prepare(Database, "SELECT * FROM Admins WHERE name = ?");

	LoadAdminData();
}

hook OnPlayerConnect(playerid) {
	admin_Level[playerid]        = 0;
	admin_OnDuty[playerid]       = 0;
	admin_PlayerKicked[playerid] = 0;

	SetPVarInt(playerid, "duty", 0);

	return 1;
}

hook OnPlayerDisconnected(playerid) {
	admin_Level[playerid]        = 0;
	admin_OnDuty[playerid]       = 0;
	admin_PlayerKicked[playerid] = 0;
}

LoadAdminData() {
	new name[MAX_PLAYER_NAME], level;

	stmt_bind_result_field(stmt_AdminLoadAll, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
	stmt_bind_result_field(stmt_AdminLoadAll, 1, DB::TYPE_INTEGER, level);

	if(stmt_execute(stmt_AdminLoadAll)) {
		while(stmt_fetch_row(stmt_AdminLoadAll)) {
			if(level > 0 && !isnull(name)) {
				admin_Data[admin_Total][admin_Name] = name;
				admin_Data[admin_Total][admin_Rank] = level;

				admin_Total++;
			} else RemoveAdminFromDatabase(name);
		}
	}

	SortDeepArray(admin_Data, admin_Rank, .order = SORT_DESC);
}

UpdateAdmin(name[MAX_PLAYER_NAME], level) {
	if(level == 0) return RemoveAdminFromDatabase(name);

	new count;

	stmt_bind_value(stmt_AdminExists, 0, DB::TYPE_STRING, name);
	stmt_bind_result_field(stmt_AdminExists, 0, DB::TYPE_INTEGER, count);
	stmt_execute(stmt_AdminExists);
	stmt_fetch_row(stmt_AdminExists);

	if(count == 0) {
		stmt_bind_value(stmt_AdminInsert, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);
		stmt_bind_value(stmt_AdminInsert, 1, DB::TYPE_INTEGER, level);

		if(stmt_execute(stmt_AdminInsert)) {
			admin_Data[admin_Total][admin_Name] = name;
			admin_Data[admin_Total][admin_Rank] = level;
			admin_Total++;

			SortDeepArray(admin_Data, admin_Rank, .order = SORT_DESC);

			return 1;
		}
	} else {
		stmt_bind_value(stmt_AdminUpdate, 0, DB::TYPE_INTEGER, level);
		stmt_bind_value(stmt_AdminUpdate, 1, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

		if(stmt_execute(stmt_AdminUpdate)) {
			for(new i; i < admin_Total; i++) {
				if(!strcmp(name, admin_Data[i][admin_Name]))
				{
					admin_Data[i][admin_Rank] = level;
					break;
				}
			}

			SortDeepArray(admin_Data, admin_Rank, .order = SORT_DESC);

			return 1;
		}
	}

	return 1;
}

RemoveAdminFromDatabase(name[]) {
	stmt_bind_value(stmt_AdminDelete, 0, DB::TYPE_STRING, name, MAX_PLAYER_NAME);

	if(stmt_execute(stmt_AdminDelete)) {
		new bool:found = false;

		for(new i; i < admin_Total; i++) {
			if(!strcmp(name, admin_Data[i][admin_Name])) found = true;

			if(found && i < MAX_ADMIN-1) {
				format(admin_Data[i][admin_Name], 24, admin_Data[i+1][admin_Name]);
				admin_Data[i][admin_Rank] = admin_Data[i+1][admin_Rank];
			}
		}

		admin_Total--;

		return 1;
	}

	return 0;
}

CheckAdminLevel(playerid) {
	new name[MAX_PLAYER_NAME];

	for(new i; i < admin_Total; i++) {
		GetPlayerName(playerid, name, MAX_PLAYER_NAME);

		if(!strcmp(name, admin_Data[i][admin_Name])) {
			admin_Level[playerid] = admin_Data[i][admin_Rank];
			break;
		}
	}
}

timer DeferedTimeout[500](playerid, time) {
	new ip[16];
	GetPlayerIp(playerid, ip, sizeof(ip));
	BlockIpAddress(ip, time);

	admin_PlayerKicked[playerid] = true;
}

TimeoutPlayer(playerid, reason[], bool:tellPlayer = true, time = HOUR(1)) {
	if(!IsPlayerConnected(playerid)) return 0;

	if(admin_PlayerKicked[playerid]) return 0;

	if(tellPlayer) ChatMsg(playerid, RED, "Você foi desconectado por %d minuto%s. Motivo: %s", time / 60000, time / 60000 > 1 ? "s" : "", reason);

	defer DeferedTimeout(playerid, time);

	log("[TIMEOUT] %p (%d) levou timeout. Tempo (ms) %d, razão: %s", playerid, playerid, time, reason);

	ChatMsgAdmins(1, GREY, " >  A conexão de %P"C_GREY" foi cortada. Motivo: "C_BLUE"%s", playerid, reason);

	return 1;
}

KickPlayer(playerid, reason[], bool:tellPlayer = true) {
	if(!IsPlayerConnected(playerid)) return 0;

	if(admin_PlayerKicked[playerid]) return 0;

	SetPlayerScreenFade(playerid, 1, 255, 10);

	defer KickPlayerDelay(playerid);
	admin_PlayerKicked[playerid] = true;

	log("[KICK] %p (%d), razão: %s", playerid, playerid, reason);

	ChatMsgAdmins(1, GREY, " >  %P"C_GREY" Kickado, motivo: "C_BLUE"%s", playerid, reason);

	if(tellPlayer) ChatMsg(playerid, GREY, sprintf(" >  %s", ls(playerid, "player/kicked")), reason);

	return 1;
}

stock IsPlayerKicked(playerid) return admin_PlayerKicked[playerid];

timer KickPlayerDelay[SEC(1)](playerid) {
	Kick(playerid);
	admin_PlayerKicked[playerid] = false;
}

ChatMsgAdminsFlat(level, colour, string[]) {
	if(level == 0) {
		err("MsgAdmins parameter 'level' cannot be 0");
		return 0;
	}

	if(strlen(string) > 127) {
		new
			string2[128],
			splitpos;

		for(new c = 128; c>0; c--) {
			if(string[c] == ' ' || string[c] ==  ',' || string[c] ==  '.') {
				splitpos = c;
				break;
			}
		}

		strcat(string2, string[splitpos]);
		string[splitpos] = EOS;

		foreach(new i : Player) {
			if(admin_Level[i] < level) continue;

			SendClientMessage(i, colour, string);
			SendClientMessage(i, colour, string2);
		}
	} else {
		foreach(new i : Player) {
			if(admin_Level[i] < level) continue;

			SendClientMessage(i, colour, string);
		}
	}

	return 1;
}

TogglePlayerAdminDuty(playerid, bool:toggle, bool:goBack = true) {
	if(toggle) {
		new
			itemId,
			ItemType:itemType,
			Float:x, Float:y, Float:z;

		itemId   = GetPlayerItem(playerid);
		itemType = GetItemType(itemId);

		GetPlayerPos(playerid, x, y, z);
		SetPlayerSpawnPos(playerid, x, y, z);

		// Se o admin estiver com uma mochila ou caixa na mao, colocamos no chao
		if((IsItemTypeSafebox(itemType) || IsItemTypeBag(itemType) && !IsContainerEmpty(GetItemExtraData(itemId)))) CreateItemInWorld(itemId, x, y, z - FLOOR_OFFSET);

		Logout(playerid, 0); // docombatlogcheck = 0

		RemovePlayerArmourItem(playerid);

		RemoveAllDrugs(playerid);

		SetPlayerSkin(playerid, isequal(GetPlayerNameEx(playerid), "VIRUXE") ? 0 : (GetPlayerGender(playerid) == GENDER_MALE ? 217 : 211));

		// Tornamos os markers dos jogadores visiveis
		foreach(new p : Player) SetPlayerMarkerForPlayer(playerid, p, (GetPlayerColor(p) | 0x000000FF));
	} else { // Sair de Duty
		LoadPlayerChar(playerid);

		// Se voltamos para o local onde entramos no duty...
		if(goBack) {
			new Float:x, Float:y, Float:z;
			GetPlayerSpawnPos(playerid, x, y, z);
			SetPlayerPos(playerid, x, y, z);
		}

		// Removemos os markers dos jogadores
		foreach(new p : Player) SetPlayerMarkerForPlayer(playerid, p, (GetPlayerColor(p) & 0xFFFFFF00));
	}

	admin_OnDuty[playerid] = toggle;

	ToggleNameTagsForPlayer(playerid, toggle);

	SetPVarInt(playerid, "duty", toggle);

	CallLocalFunction("OnAdminToggleDuty", "dbb", playerid, toggle, goBack);
}

stock SetPlayerAdminLevel(playerid, level) {
	if(!(0 <= level < MAX_ADMIN_LEVELS)) return 0;

	admin_Level[playerid] = level;

	UpdateAdmin(GetPlayerNameEx(playerid), level);

	return 1;
}

stock GetPlayerAdminLevel(playerid) {
	if(!IsPlayerConnected(playerid)) return 0;

	return admin_Level[playerid];
}

stock GetAdminLevelByName(name[MAX_PLAYER_NAME]) {
	new level;

	stmt_bind_value(stmt_AdminGetLevel, 0, DB::TYPE_STRING, name);
	stmt_bind_result_field(stmt_AdminGetLevel, 1, DB::TYPE_INTEGER, level);
	stmt_execute(stmt_AdminGetLevel);
	stmt_fetch_row(stmt_AdminGetLevel);

	return level;
}

stock GetAdminTotal() return admin_Total;

stock GetAdminsOnline(from = 1, to = 6) {
	new count;

	foreach(new i : Player) {
		if(from <= admin_Level[i] <= to)
			count++;
	}

	return count;
}

stock GetAdminRankName(rank) {
	if(!(0 < rank < MAX_ADMIN_LEVELS)) return admin_Names[0];

	return admin_Names[rank];
}

stock GetAdminRankColour(rank) {
	if(!(0 < rank < MAX_ADMIN_LEVELS)) return admin_Colours[0];

	return admin_Colours[rank];
}

stock IsPlayerOnAdminDuty(playerid) {
	if(!IsPlayerConnected(playerid)) return 0;

	return admin_OnDuty[playerid];
}

stock RegisterAdminCommand(level, command[], description[]) {
    if (!(STAFF_LEVEL_GAME_MASTER <= level <= STAFF_LEVEL_LEAD)) {
        err("Cannot register admin command for level %d", level);
        return 0;
    }

    /* new tabs[32] = "\t";
    new commandLength = strlen(command);
    new tabCount = (13 - commandLength) / 4;  // Assuming 4 spaces per tab

	printf("tabCount: %d", tabCount);

    for (new i = 0; i < tabCount; i++) {
        strcat(tabs, "\t");
    } */

    strcat(admin_Commands[level - 1], sprintf("\t/%s - %s\n", command, description));

    return 1;
}

ACMD:acmds[1](playerid) {
	gBigString[playerid] = C_WHITE"a [mensagem] - Chat de Administração";

	if(admin_Level[playerid] >= STAFF_LEVEL_LEAD) 
		strcat(gBigString[playerid], sprintf("\n\n%C%s:\n%s", admin_Colours[STAFF_LEVEL_LEAD], admin_Names[STAFF_LEVEL_LEAD], admin_Commands[3]));

	if(admin_Level[playerid] >= STAFF_LEVEL_ADMINISTRATOR) 
		strcat(gBigString[playerid], sprintf("\n\n%C%s:\n%s", admin_Colours[STAFF_LEVEL_ADMINISTRATOR], admin_Names[STAFF_LEVEL_ADMINISTRATOR], admin_Commands[2]));

	if(admin_Level[playerid] >= STAFF_LEVEL_MODERATOR) 
		strcat(gBigString[playerid], sprintf("\n\n%C%s:\n%s", admin_Colours[STAFF_LEVEL_MODERATOR], admin_Names[STAFF_LEVEL_MODERATOR], admin_Commands[1]));

	if(admin_Level[playerid] >= STAFF_LEVEL_GAME_MASTER) 
		strcat(gBigString[playerid], sprintf("\n\n%C%s:\n%s", admin_Colours[STAFF_LEVEL_GAME_MASTER], admin_Names[STAFF_LEVEL_GAME_MASTER], admin_Commands[0]));

	ShowPlayerDialog(playerid, DIALOG_ADMIN_COMMANDS, DIALOG_STYLE_MSGBOX, "Comandos de Admin:", gBigString[playerid], "OK", "");

	printf("strlen: %d", strlen(admin_Commands[3]));
	printf("strlen: %d", strlen(admin_Commands[2]));
	printf("strlen: %d", strlen(admin_Commands[1]));
	printf("strlen: %d", strlen(admin_Commands[0]));

	return 1;
}

CMD:admins(playerid) {
	new line[52];

	gBigString[playerid][0] = EOS;

	gBigString[playerid] = C_WHITE"Legenda: "C_GREEN"Online"C_WHITE" - "C_GREY"Offline"C_WHITE;

	strcat(gBigString[playerid], "\n\n");

	for(new i; i < admin_Total; i++) {
		if(admin_Data[i][admin_Rank] == STAFF_LEVEL_SECRET) continue;

		format(line, sizeof(line), "%s %C%s (%s)\n",
			GetPlayerIDFromName(admin_Data[i][admin_Name]) != INVALID_PLAYER_ID ? "Online" : "Offline",
			admin_Colours[admin_Data[i][admin_Rank]],
			admin_Data[i][admin_Name],
			admin_Names[admin_Data[i][admin_Rank]]);

		strcat(gBigString[playerid], GetPlayerIDFromName(admin_Data[i][admin_Name]) != INVALID_PLAYER_ID ? C_GREEN : C_GREY);

		strcat(gBigString[playerid], line);
	}

	ShowPlayerDialog(playerid, 10008, DIALOG_STYLE_MSGBOX, sprintf("Lista de Admins (%d)", admin_Total), gBigString[playerid], "OK", "");

	return 1;
}
