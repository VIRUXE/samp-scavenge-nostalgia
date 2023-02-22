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


static
Timer:	WelcomeMessageTimer[MAX_PLAYERS],
		WelcomeMessageCount[MAX_PLAYERS],
		CanLeaveWelcomeMessage[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	CanLeaveWelcomeMessage[playerid] = true;

	return 1;
}

timer ShowWelcomeMessage[SEC(1)](playerid, count)
{
	new
		str[559],
		button[7];

	strcat(str,
		""C_WHITE"Voc� tem que lutar para sobreviver em um deserto apocal�ptico.\n\n\
	Voc� ter� uma chance melhor em um grupo, mas tenha cuidado em quem voc� confia.\n\n\
	Os suprimentos podem ser encontrados espalhados, armas s�o raras embora.\n\n");

	strcat(str,
			"Evite atacar jogadores desarmados, eles assustam facilmente, mas retornar�o, e em maior n�mero...\n\n\n\n\
	"C_TEAL" Por favor, dedique algum tempo para olhar as regras "C_BLUE"/rules "C_TEAL" e "C_BLUE"/help "C_TEAL" antes de mergulhar no jogo.\n\n\
	Visite "C_YELLOW" scavenge-survive.wikia.com "C_TEAL" para obter mais informa��es.\n\n\n");

	if(count == 0)
	{
		button = "Jogar";

		CanLeaveWelcomeMessage[playerid] = true;
	}
	else
	{
		valstr(button, count);
		count--;

		stop WelcomeMessageTimer[playerid];
		WelcomeMessageTimer[playerid] = defer ShowWelcomeMessage(playerid, count);

		CanLeaveWelcomeMessage[playerid] = false;
	}

	WelcomeMessageCount[playerid] = count;

	Dialog_Show(playerid, WelcomeMessage, DIALOG_STYLE_MSGBOX, "Bem vindo", str, button, "");
	return 1;
}

Dialog:WelcomeMessage(playerid, response, listitem, inputtext[])
{
	if(!CanLeaveWelcomeMessage[playerid])
	{
		ShowWelcomeMessage(playerid, WelcomeMessageCount[playerid] + 1);
	}
}

stock CanPlayerLeaveWelcomeMessage(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return CanLeaveWelcomeMessage[playerid];
}
