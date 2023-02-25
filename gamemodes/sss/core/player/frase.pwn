#include <YSI\y_hooks>

#define MAX_FRASE_LEN 90

hook OnPlayerLogin(playerid)
{
	new DBResult:result, frase[MAX_FRASE_LEN];

	result = db_query(gAccounts, sprintf("SELECT joinsentence FROM Player WHERE name = '%s';", GetPlayerNameEx(playerid)));

	db_get_field(result, 0, frase, sizeof(frase));
	db_free_result(result);

	if(!isempty(frase)) ChatMsg(playerid, YELLOW, " >  Sua frase de entrada: "C_WHITE"%s", frase);

	foreach(new i : Player) if(i != playerid) ChatMsgLang(i, WHITE, "PJOINSV", playerid, playerid, GetPlayerLanguage(playerid) == 0 ? "PT" : "EN", frase);
}

CMD:frase(playerid, params[])
{
    if(!IsPlayerLoggedIn(playerid)) return SendClientMessage(playerid, RED, " > Você precisa estar logado para isso.");

	if(!IsPlayerVip(playerid)) return SendClientMessage(playerid, RED, " > Você precisa ser VIP para usar este comando.");

    if(GetPlayerScore(playerid) < 100) return SendClientMessage(playerid, RED, " > Você precisa de 100 pontos para usar este comando.");

	if(isnull(params)) return SendClientMessage(playerid, YELLOW, " > Use: /frase [frase]");

 	if(strlen(params) > MAX_FRASE_LEN) return SendClientMessage(playerid, RED, " > Frase muito grande.");

	db_query(gAccounts, sprintf("UPDATE Player SET joinsentence = '%s' WHERE name = '%s';", params, GetPlayerNameEx(playerid)));

	return ChatMsg(playerid, GREEN, " >  Frase de entrada alterada para: "C_WHITE"%s", params);
}
