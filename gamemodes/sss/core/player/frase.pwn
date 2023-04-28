#include <YSI\y_hooks>

#define MAX_JOINSENTENCE_LEN 90

GetPlayerJoinSentence(playerid) {
	new DBResult:result, frase[MAX_JOINSENTENCE_LEN];

	result = db_query(gAccounts, sprintf("SELECT joinsentence FROM players WHERE name = '%s';", GetPlayerNameEx(playerid)));

	db_get_field(result, 0, frase, sizeof(frase));
	db_free_result(result);

	return frase;
}

/* hook OnPlayerLogin(playerid)
{

	if(!isempty(frase)) ChatMsg(playerid, YELLOW, " >  %s: "C_WHITE"%s", ls(playerid, "player/join-sentence/onplayerlogin"), frase);

	foreach(new i : Player) 
		if(i != playerid) ChatMsg(i, WHITE, "player/join", playerid, GetPlayerLanguage(playerid) == 0 ? "PT" : "EN", !isnull(frase) ? sprintf(" -> %s", frase) : "");
} */

CMD:frase(playerid, params[])
{
    if(!IsPlayerLoggedIn(playerid)) return ChatMsg(playerid, RED, " > Você precisa estar logado para isso.");

	if(!IsPlayerVip(playerid)) return ChatMsg(playerid, RED, " > Você precisa ser VIP para usar este comando.");

    if(GetPlayerScore(playerid) < 100) return ChatMsg(playerid, RED, ls(playerid, "player/join-sentence/points"));

	// if(isnull(params)) return ChatMsg(playerid, YELLOW, ls(playerid, "player/join-sentence/cmd-syntax"));
	if(isnull(params)) return ChatMsg(playerid, YELLOW, "Sua frase de entrada: %s", GetPlayerJoinSentence(playerid));

 	if(strlen(params) > MAX_JOINSENTENCE_LEN) return ChatMsg(playerid, RED, ls(playerid, "player/join-sentence/big-sentence"));

	db_query(gAccounts, sprintf("UPDATE Player SET joinsentence = '%s' WHERE name = '%s';", params, GetPlayerNameEx(playerid)));

	return ChatMsg(playerid, GREEN, " >  %s: "C_WHITE"%s", ls(playerid, "player/join-sentence/changed"), params);
}