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

#define MAX_CONQUISTAS 5

#define CONQUISTA_1_ZOMBIE 	0
#define CONQUISTA_1_KILL 	1

static
bool:	Conquista[MAX_PLAYERS][MAX_CONQUISTAS],
		PlayerText:TextConqusita,
		cqst_InventoryItem[MAX_PLAYERS];

hook OnPlayerConnect(playerid)
{
    TextConqusita			=CreatePlayerTextDraw(playerid, 320.000000, 430.000000, "+ Conquista desbloqueada");
	PlayerTextDrawAlignment			(playerid, TextConqusita, 2);
	PlayerTextDrawBackgroundColor	(playerid, TextConqusita, 255);
	PlayerTextDrawFont				(playerid, TextConqusita, 1);
	PlayerTextDrawLetterSize		(playerid, TextConqusita, 0.400000, 1.399999);
	PlayerTextDrawColor				(playerid, TextConqusita, 16711935);
	PlayerTextDrawSetOutline		(playerid, TextConqusita, 1);
	PlayerTextDrawSetProportional	(playerid, TextConqusita, 1);
}

hook OnPlayerOpenInventory(playerid)
{
	cqst_InventoryItem[playerid] = AddInventoryListItem(playerid, "Conquistas >" );
}

hook OnPlayerSelectExtraItem(playerid, item)
{
	if(item == cqst_InventoryItem[playerid])
	{
		cqst_ShowConquistasList(playerid);
	}
}

cqst_ShowConquistasList(playerid)
{
    gBigString[playerid][0] = EOS;
    gBigString[playerid][0] = ""C_WHITE"Lista de Conquistas >\n"C_YELLOW"";

    if(Conquista[playerid][CONQUISTA_1_ZOMBIE])
			format(gBigString[playerid], sizeof(gBigString[]), "%sPrimeiro Zombie Kill\n", gBigString[playerid]);
			
    if(Conquista[playerid][CONQUISTA_1_KILL])
		format(gBigString[playerid], sizeof(gBigString[]), "%sPrimeiro Kill\n", gBigString[playerid]);

	
	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, inputtext
		
		if(!response)
			DisplayPlayerInventory(playerid);
			
		else if(listitem != 0)
			cqst_ShowConquistasList(playerid);
			
		else
			ShowServerConquistas(playerid);
	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, "Conquistas", gBigString[playerid], "Selecionar", "Voltar");

	return 1;
}

stock ShowServerConquistas(playerid)
{
    gBigString[playerid][0] = EOS;
    
    if(Conquista[playerid][CONQUISTA_1_ZOMBIE])
    	format(gBigString[playerid], sizeof(gBigString[]), ""C_GREEN"Primeiro Zombie Kill\n", gBigString[playerid]);

	else format(gBigString[playerid], sizeof(gBigString[]), "%s"C_WHITE"Primeiro Zombie Kill\n", gBigString[playerid]);
	
	if(Conquista[playerid][CONQUISTA_1_KILL])
    	format(gBigString[playerid], sizeof(gBigString[]), ""C_GREEN"Primeiro Kill\n", gBigString[playerid]);

	else format(gBigString[playerid], sizeof(gBigString[]), "%s"C_WHITE"Primeiro Kill\n", gBigString[playerid]);
    
	inline Response(pid, dialogid, response, listitem, string:inputtext[])
	{
		#pragma unused pid, dialogid, response, listitem, inputtext

		cqst_ShowConquistasList(playerid);

	}
	Dialog_ShowCallback(playerid, using inline Response, DIALOG_STYLE_LIST, ""C_WHITE"Brasilian"C_YELLOW"Z "C_WHITE"Conquistas", gBigString[playerid], "Voltar", "");
}

stock GivePlayerConquista(playerid, conquista)
{
    Conquista[playerid][conquista] = true;
    PlayerTextDrawShow(playerid, TextConqusita);
	defer HideConquistaText(playerid);
	return 1;
}

timer HideConquistaText[4000](playerid)
{
    PlayerTextDrawHide(playerid, TextConqusita);
}

hook OnPlayerSave(playerid, filename[])
{
    modio_push(filename, _T<C,Q,T,A>, MAX_CONQUISTAS, Conquista[playerid]);
}

hook OnPlayerLoad(playerid, filename[])
{
	modio_read(filename, _T<C,Q,T,A>, MAX_CONQUISTAS, Conquista[playerid]);
}

