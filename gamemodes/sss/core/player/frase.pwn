/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/


#include <YSI\y_hooks>

#define MAX_FRASE_LEN 90

hook OnPlayerConnect(playerid)
{
    SetPlayerColor(playerid, 0xB8B8B8FF);
/*
	new namep[24], string[MAX_FRASE_LEN];
	GetPlayerName(playerid, namep, 24);

	format(string, MAX_FRASE_LEN, "%s", dini_Get("Frases.ini",namep));

//    ChatMsgAll(WHITE, " >  %P (%d)"C_WHITE" Entrou no Servidor. "C_YELLOW"%s", playerid, playerid, string);
    foreach(new i : Player) ChatMsgLang(i, WHITE, "PJOINSV", playerid, playerid, ls(playerid, "IDIOMAID"), string);*/
}

CMD:frase(playerid, params[])
{
    if(!IsPlayerLoggedIn(playerid)) return SendClientMessage(playerid, RED, " > Você precisa estar logado para isso.");
    if(GetPlayerScore(playerid) < 100 && !IsPlayerVip(playerid)) return SendClientMessage(playerid, RED, " > Você precisa ter no mínimo 100 score para usar este comando.");
	if(isnull(params)) return SendClientMessage(playerid, YELLOW, " > Use: /frase [Frase]");
 	if(strlen(params) > MAX_FRASE_LEN) return SendClientMessage(playerid, RED, " > Frase muito grande.");

    new namep[24];
	GetPlayerName(playerid, namep, 24);
    dini_Set("Frases.ini", namep, params);

	ChatMsg(playerid, GREEN, " > Frase de entrada alterada para: "C_YELLOW"%s", params);

	return 1;
}
