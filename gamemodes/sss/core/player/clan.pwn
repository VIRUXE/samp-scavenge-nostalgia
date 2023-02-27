#include <YSI\y_hooks>

#define MIN_CLAN_NAME 5
#define MAX_CLAN_NAME 16
#define MAX_CLAN_TAG 3

static
	Clan[MAX_PLAYERS][MAX_CLAN_NAME];

SetPlayerClan(playerid, clan[MAX_CLAN_NAME]) {
	strcpy(Clan[playerid], clan, MAX_CLAN_NAME); // Define na memória

	ToggleClanTag(playerid, !isempty(clan)); // Se o clan não estiver vazio, ativa o tag

	if(isempty(clan)) 
		log("[CLAN] Clan removido de %p (%d)", playerid, playerid);
	else
		log("[CLAN] Clan '%s' definido para %p (%d)", clan, playerid, playerid);
}

GetPlayerClan(playerid) return Clan[playerid];

GetClanTag(const clan[MAX_CLAN_NAME]) {
	new DBResult:result, tag[MAX_CLAN_TAG];

	result = db_query(gAccounts, sprintf("SELECT tag FROM clans WHERE name = '%s'", clan));

	db_get_field(result, 0, tag);

	return tag;
}

ToggleClanTag(playerid, toggle) {
	if(toggle) {
		new clan[MAX_CLAN_NAME];

		clan = GetPlayerClan(playerid);

		if(isempty(clan)) return;

		SetPlayerName(playerid, sprintf("[%s] %s", GetClanTag(clan), GetPlayerOriginalName(playerid)));
	} else {
		SetPlayerName(playerid, GetPlayerNameEx(playerid));
	}
}

// Obtem o nome do dono ou simplesmente para saber se o clan existe
GetClanOwner(const clan[MAX_CLAN_NAME]) {
	// Consulta o banco de dados e retorna o nome do dono do clan
	new DBResult:result, owner[MAX_PLAYER_NAME];

	result = db_query(gAccounts, sprintf("SELECT owner FROM clans WHERE name = '%s'", clan));

	db_get_field(result, 0, owner);

	return owner;
}

IsPlayerClanOwner(playerid) {
	return isequal(GetClanOwner(GetPlayerClan(playerid)), GetPlayerOriginalName(playerid));
}

AddPlayerToClan(playerid, clan[MAX_CLAN_NAME]) {
	// Define no banco de dados
	db_query(gAccounts, sprintf("UPDATE Player SET clan = '%s' WHERE name = '%s'", clan, GetPlayerOriginalName(playerid)));

	SetPlayerClan(playerid, clan);
	ToggleClanTag(playerid, true);
}

RemovePlayerFromClan(playerid) {
	SetPlayerClan(playerid, "");
	ToggleClanTag(playerid, false);
}

hook OnGameModeInit() {
	db_query(gAccounts, "CREATE TABLE IF NOT EXISTS clans (\
		name TEXT NOT NULL,\
		tag TEXT NOT NULL,\
		owner TEXT NOT NULL,\
		created_at INTEGER NOT NULL,\
		last_used INTEGER NOT NULL,\
		active INTEGER NOT NULL)");

	if(db_changes(gAccounts)) log("[CLAN] Tabela de banco de dados criada.");

	db_query(gAccounts, "CREATE INDEX IF NOT EXISTS clan_index ON clans(name)");
}

hook OnPlayerLogin(playerid) {

}

CMD:clan(playerid, params[])
{
	if(!IsPlayerSpawned(playerid)) return ChatMsg(playerid, RED, " > Você deve nascer antes.");

	new command[9]; // 8 é o tamanho máximo de um comando

	if(sscanf(params, "s[8] ", command)) return ChatMsg(playerid, RED, " > Use: /clan [ajuda/procurar/criar/convidar/expulsar/sair/deletar]");

	if(isequal(command, "ajuda", true)) {
		ShowPlayerDialog(playerid, 9147, DIALOG_STYLE_MSGBOX, "Ajuda CLAN:", 
		"{FFFF00}Comandos de CLAN:\n\
		{33AA33}/clan {FFFFFF}- ok\n"
		, "Fechar", "");
	} else if(isequal(command, "procurar", true)) {
		ChatMsgAll(CHAT_CLAN, "[CLAN] %P (%d) está procurando um clan!", playerid, playerid);
	} else if(isequal(command, "criar", true)) {
		new clanName[MAX_CLAN_NAME], clanTag[MAX_CLAN_TAG];

		if(sscanf(params, "{s[5]}ss", clanName, clanTag)) return ChatMsg(playerid, RED, " > Use: /clan criar [nome(5-16)] [tag(3)]");

		if(strlen(clanName) < MIN_CLAN_NAME || strlen(clanName) > MAX_CLAN_NAME) return ChatMsg(playerid, RED, " > O nome do clan deve ter de 5 a 16 caracteres.");

		if(!isstringalphanumeric(clanName)) return ChatMsg(playerid, RED, " > O nome do clan apenas pode conter caracteres alfanuméricos (A-Z, a-z, 0-9).");

		if(!isempty(GetClanOwner(clanName))) return ChatMsg(playerid, RED, " > Este clan já existe.");

		log("[CLAN] Criando clan '%s'...", clanName);
		
	} else if(isequal(command, "convidar", true)) {
		

	} else if(isequal(command, "expulsar", true)) {

	} else if(isequal(command, "sair", true) || isequal(command, "deletar", true)) {
		// Se for sair e o player for o lider, deletar o clan. Se nao, apenas sair.

	} else {
		ChatMsg(playerid, RED, " > Use /clan [ajuda/procurar/criar/convidar/expulsar/sair/deletar]");
	}

	return 1;
}
