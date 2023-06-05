#include <YSI\y_hooks>

#define MIN_CLAN_NAME 5
#define MAX_CLAN_NAME 16
#define MAX_CLAN_TAG 3

static Clan[MAX_PLAYERS][MAX_CLAN_NAME];

SetPlayerClan(playerid, clan[MAX_CLAN_NAME]) {
	strcpy(Clan[playerid], clan, MAX_CLAN_NAME); // Define na memória

	if(isempty(clan)) 
		log("[CLAN] Clan removido de %p (%d)", playerid, playerid);
	else
		log("[CLAN] Clan '%s' definido para %p (%d)", clan, playerid, playerid);
}

SavePlayerClan(playerid) {
	new clan[MAX_CLAN_NAME];

	clan = GetPlayerClan(playerid);

	db_query(Database, sprintf("UPDATE players SET clan = '%s' WHERE name = '%s';", clan, GetPlayerNameEx(playerid)));
}

GetPlayerClan(playerid) return Clan[playerid];

GetClanTag(const clan[MAX_CLAN_NAME]) {
	new DBResult:result, tag[MAX_CLAN_TAG];

	result = db_query(Database, sprintf("SELECT tag FROM clans WHERE name = '%s';", clan));

	db_get_field(result, 0, tag);

	return tag;
}

ToggleClanTag(playerid, toggle) {
}

// Obtem o nome do dono ou simplesmente para saber se o clan existe
GetClanOwner(const clan[MAX_CLAN_NAME]) {
	// Consulta o banco de dados e retorna o nome do dono do clan
	new DBResult:result, owner[MAX_PLAYER_NAME];

	result = db_query(Database, sprintf("SELECT owner FROM clans WHERE name = '%s';", clan));

	db_get_field(result, 0, owner);

	return owner;
}

IsPlayerClanOwner(playerid) return isequal(GetClanOwner(GetPlayerClan(playerid)), GetPlayerNameEx(playerid));

AddPlayerToClan(playerid, clan[MAX_CLAN_NAME]) {
	db_query(Database, sprintf("UPDATE players SET clan = '%s' WHERE name = '%s';", clan, GetPlayerNameEx(playerid)));

	SetPlayerClan(playerid, clan);

	SavePlayerClan(playerid);
}

bool:RemovePlayerFromClan(playerid) {
	if(IsPlayerConnected(playerid)) return false;

	new clan[MAX_CLAN_NAME];

	clan = GetPlayerClan(playerid);

	if(isnull(clan)) return false;

	printf("[CLAN] '%p' foi removido do clan '%s'", playerid, clan);

	SetPlayerClan(playerid, "");

	SavePlayerClan(playerid);

	return true;
}

hook OnGameModeInit() {
	db_query(Database, "CREATE TABLE IF NOT EXISTS clans (\
		name TEXT NOT NULL,\
		tag TEXT NOT NULL,\
		owner TEXT NOT NULL,\
		created_at INTEGER NOT NULL,\
		last_used INTEGER NOT NULL,\
		active INTEGER NOT NULL)");

	if(db_changes(Database)) log("[CLAN] Tabela de banco de dados criada.");

	db_query(Database, "CREATE INDEX IF NOT EXISTS clan_index ON clans(name)");
}

hook OnPlayerLogin(playerid) {
	new clan[MAX_CLAN_NAME];

	clan = GetPlayerClan(playerid);

	if(!isempty(clan)) {
		new clan_owner[MAX_PLAYER_NAME];
		
		clan_owner = GetClanOwner(clan);

		if(!isempty(clan_owner)) 
			ChatMsg(playerid, WHITE, isequal(GetPlayerNameEx(playerid), clan_owner) ? "Voce e o dono do clan '%s'" : "Voce pertence ao clan '%s'", clan);
	}
}

CMD:clan(playerid, params[]) {
	if(!IsPlayerSpawned(playerid)) return 0;

    new command[9];

    if (sscanf(params, "s[9]", command)) return ChatMsg(playerid, RED, " > Use: /clan [ajuda/procurar/criar/convidar/expulsar/sair/deletar]");

	if(isequal(command, "ajuda", true)) {
		ShowPlayerDialog(playerid, 9147, DIALOG_STYLE_MSGBOX, "Ajuda CLAN:", 
		"{FFFF00}Comandos de CLAN:\n\
		{33AA33}/clan {FFFFFF}- ok\n"
		, "Fechar", "");
	} else if(isequal(command, "procurar", true)) {
		ChatMsgAll(CHAT_CLAN, "[CLAN] %P (%d) está procurando um clan!", playerid, playerid);
	} else if(isequal(command, "criar", true)) {
		new clanName[MAX_CLAN_NAME], clanTag[MAX_CLAN_TAG];

		log("params = %s", params);

		if(sscanf(params, "{s[9]}s[17]s[4]", clanName, clanTag)) return ChatMsg(playerid, RED, " > Use: /clan criar [nome(5-16)] [tag(3)]");

		log("strlen(clanName) = %d, strlen(clanTag) = %d", strlen(clanName), strlen(clanTag));

		if(strlen(clanName) < MIN_CLAN_NAME || strlen(clanName) > MAX_CLAN_NAME) return ChatMsg(playerid, RED, " > O nome do clan deve ter de 5 a 16 caracteres.");

		if(strlen(clanTag) != MAX_CLAN_TAG) return ChatMsg(playerid, RED, " > A tag do clan deve ter 3 caracteres.");

		if(!isstringalphanumeric(clanName)) return ChatMsg(playerid, RED, " > O nome do clan apenas pode conter caracteres alfanuméricos (A-Z, a-z, 0-9).");

		if(!isempty(GetClanOwner(clanName))) return ChatMsg(playerid, RED, " > Este clan já existe.");

		log("[CLAN] Criando clan '%s' com tag '%s' para %p (%d)", clanName, clanTag, playerid, playerid);
		
	} else if(isequal(command, "convidar", true)) {
		

	} else if(isequal(command, "expulsar", true)) {
		if(!IsPlayerClanOwner(playerid)) return ChatMsg(playerid, RED, "Voce nao tem um clan");

		new targetId;

		if(sscanf(params, "{s[8]}r", targetId)) return ChatMsg(playerid, RED, "Sintaxe: /clan expulsar [id/nick]");

		if(targetId == INVALID_PLAYER_ID) return CMD_INVALID_PLAYER;

		new bool:removed = RemovePlayerFromClan(playerid);

		ChatMsg(playerid, removed ? GREEN : RED, removed ? "Voce removou %p do clan" : "Nao foi possivel remover %p do clan");
	} else if(isequal(command, "sair", true) || isequal(command, "deletar", true)) {
		// Se for sair e o player for o lider, deletar o clan. Se nao, apenas sair.

	} else {
		ChatMsg(playerid, RED, " > Use /clan [ajuda/procurar/criar/convidar/expulsar/sair/deletar]");
	}

	return 1;
}
