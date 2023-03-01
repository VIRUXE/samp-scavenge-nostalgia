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


#define MAX_BANS_PER_PAGE (20)


static
	banlist_ViewingList[MAX_PLAYERS],
	banlist_CurrentIndex[MAX_PLAYERS],
	banlist_CurrentName[MAX_PLAYERS][MAX_PLAYER_NAME];


ShowListOfBans(playerid, index = 0)
{
	new
		list[MAX_BANS_PER_PAGE][MAX_PLAYER_NAME],
		totalbans,
		listitems;

	totalbans = GetTotalBans();

	if(index > totalbans)
		index = 0;

	if(index < 0)
		index = totalbans - (totalbans % MAX_BANS_PER_PAGE);

	listitems = GetBanList(list, MAX_BANS_PER_PAGE, index);

	if(listitems == 0)
		return 0;

	if(listitems == -1)
		return -1;

	new
		idx,
		string[((MAX_PLAYER_NAME + 1) * MAX_BANS_PER_PAGE)],
		title[22];

	while(idx < listitems )
	{
		strcat(string, list[idx]);
		strcat(string, "\n");
		idx++;
	}

	format(title, sizeof(title), "Banidos (%d-%d of %d)", index, index + listitems, totalbans);

	banlist_ViewingList[playerid] = true;
	banlist_CurrentIndex[playerid] = index;

	ShowPlayerPageButtons(playerid);

	Dialog_Show(playerid, ListOfBans, DIALOG_STYLE_LIST, title, string, "Abrir", "Fechar");

	return 1;
}

Dialog:ListOfBans(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new name[MAX_PLAYER_NAME];
		strmid(name, inputtext, 0, MAX_PLAYER_NAME);
		ShowBanInfo(playerid, name);
	}

	banlist_ViewingList[playerid] = false;
	HidePlayerPageButtons(playerid);
	CancelSelectTextDraw(playerid);
}

ShowBanInfo(playerid, name[MAX_PLAYER_NAME])
{
	new
		timestamp,
		reason[MAX_BAN_REASON],
		bannedby[MAX_PLAYER_NAME],
		duration;

	if(!GetBanInfo(name, timestamp, reason, bannedby, duration))
		return 0;

	new str[256];

	format(str, 256, "\
		"C_YELLOW"Data:\n\t\t"C_BLUE"%s - %s\n\n\n\
		"C_YELLOW"Por:\n\t\t"C_BLUE"%s\n\n\n\
		"C_YELLOW"Motivo:\n\t\t"C_BLUE"%s",
		TimestampToDateTime(timestamp),
		duration ? TimestampToDateTime(timestamp + duration) : "Nunca",
		bannedby,
		reason);

	banlist_CurrentName[playerid] = name;

	Dialog_Show(playerid, BanInfo, DIALOG_STYLE_MSGBOX, name, str, "Opções", "Voltar");

	return 1;
}

Dialog:BanInfo(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		ShowBanOptions(playerid);
	}
	else
	{
		ShowListOfBans(playerid);
	}
}

ShowBanOptions(playerid)
{
	Dialog_Show(playerid, BanOptions, DIALOG_STYLE_LIST, banlist_CurrentName[playerid], "Editar motivo\nEditar duração\nSetar a data\nDesbanir\n", "Selecionar", "Voltar");

	return 1;
}

Dialog:BanOptions(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		switch(listitem)
		{
			case 0: // Edit reason
				ShowBanReasonEdit(playerid);

			case 1: // Edit duration
				ShowBanDurationEdit(playerid);

			case 2: // Edit set unban
				ShowBanDateEdit(playerid);

			case 3: // Unban
				ShowUnbanPrompt(playerid);
		}
	}
	else
	{
		ShowBanInfo(playerid, banlist_CurrentName[playerid]);
	}
}

ShowBanReasonEdit(playerid)
{
	Dialog_Show(playerid, BanReasonEdit, DIALOG_STYLE_INPUT, "Editar o motivo do banimento", "Insira o novo motivo de banimento.", "Confirmar", "Cancelar");

	return 1;
}

Dialog:BanReasonEdit(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		SetBanReason(banlist_CurrentName[playerid], inputtext);
	}

	ShowBanOptions(playerid);
}

ShowBanDurationEdit(playerid)
{
	Dialog_Show(playerid, BanDurationEdit, DIALOG_STYLE_INPUT, "Editar a duração do banimento", "Insira a nova duração do banimento abaixo no formato <número> <days/weeks/months>", "Confirmar", "Cancelar");

	return 1;
}

Dialog:BanDurationEdit(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new duration;

		if(!strcmp(inputtext, "forever", true))
			duration = 0;

		else
			duration = GetDurationFromString(inputtext);

		if(duration == -1)
		{
			ChatMsg(playerid, YELLOW, " >  Inválido. Use <Número> <days/weeks/months>.");
			ShowBanDurationEdit(playerid);
		}
		else
		{
			SetBanDuration(banlist_CurrentName[playerid], duration);
			ShowBanOptions(playerid);
		}
	}

	ShowBanOptions(playerid);
}

ShowBanDateEdit(playerid)
{
	Dialog_Show(playerid, BanDateEdit, DIALOG_STYLE_INPUT, "Editar a data do banimento", "Insira o formato da data: dd/mm/yy", "Confirmar", "Cancelar");

	return 1;
}

Dialog:BanDateEdit(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		ChatMsg(playerid, YELLOW, " >  Not implemented.");
	}

	ShowBanOptions(playerid);
}

ShowUnbanPrompt(playerid)
{
	Dialog_Show(playerid, UnbanPrompt, DIALOG_STYLE_MSGBOX, "Desbanimento", "Quer mesmo desbanir?", "Confirmar", "Cancelar");

	return 1;
}

Dialog:UnbanPrompt(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		UnBanPlayer(banlist_CurrentName[playerid]);
	}

	ShowBanOptions(playerid);
}

hook OnPlayerDialogPage(playerid, direction)
{
	dbg("global", CORE, "[OnPlayerDialogPage] in /gamemodes/sss/core/admin/ban-list.pwn");

	if(banlist_ViewingList[playerid])
	{
		if(direction == 0)
			banlist_CurrentIndex[playerid] -= MAX_BANS_PER_PAGE;

		else
			banlist_CurrentIndex[playerid] += MAX_BANS_PER_PAGE;

		ShowListOfBans(playerid, banlist_CurrentIndex[playerid]);
	}
}
