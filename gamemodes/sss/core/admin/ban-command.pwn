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
	ban_CurrentName[MAX_PLAYERS][MAX_PLAYER_NAME], // Store the name in case the player quits mid-ban
	ban_CurrentReason[MAX_PLAYERS][MAX_BAN_REASON],
	ban_CurrentDuration[MAX_PLAYERS];


hook OnPlayerConnect(playerid)
{
	dbg("global", CORE, "[OnPlayerConnect] in /gamemodes/sss/core/admin/ban-command.pwn");

	ResetBanVariables(playerid);
}

BanAndEnterInfo(playerid, name[MAX_PLAYER_NAME])
{
	BanPlayerByName(name, "Não informado", playerid, 0);
	FormatBanReasonDialog(playerid);

	ban_CurrentName[playerid] = name;
}

ResetBanVariables(playerid)
{
	ban_CurrentName[playerid][0] = EOS;
	ban_CurrentReason[playerid][0] = EOS;
	ban_CurrentDuration[playerid] = 0;
}

FormatBanReasonDialog(playerid)
{
	Dialog_Show(playerid, BanReason, DIALOG_STYLE_INPUT, "Insira o motivo do banimento", "Digite o motivo do banimento abaixo. O limite de caracteres é 128. Após essa tela, você definirá a duração do banimento.", "Continuar", "Cancelar");
}

Dialog:BanReason(playerid, response, listitem, inputtext[])
{
		if(response)
		{
			ban_CurrentReason[playerid][0] = EOS;
			strcat(ban_CurrentReason[playerid], inputtext);

			FormatBanDurationDialog(playerid);
		}
		else
		{
			ResetBanVariables(playerid);
		}
}

FormatBanDurationDialog(playerid)
{
	Dialog_Show(playerid, BanDuration, DIALOG_STYLE_INPUT, "Insira a duração do banimento", "Enter the ban duration below. You can type a number then one of either: 'days', 'weeks' or 'months'. Type 'forever' for perma-ban.", "Continuar", "Voltar");

	return 1;
}

Dialog:BanDuration(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		if(!strcmp(inputtext, "forever", true))
		{
			ban_CurrentDuration[playerid] = 0;
			FinaliseBan(playerid);
			return 1;
		}

		new duration = GetDurationFromString(inputtext);

		if(duration == -1)
		{
			FormatBanDurationDialog(playerid);
		}
		else
		{
			ban_CurrentDuration[playerid] = duration;
			FinaliseBan(playerid);
		}
	}
	else
	{
		FormatBanReasonDialog(playerid);
	}

	return 0;
}

FinaliseBan(playerid)
{
	if(isnull(ban_CurrentName[playerid]))
	{
		ChatMsg(playerid, RED, " >  Ocorreu um erro: 'ban_CurrentName' está vazio.");
		return 0;
	}

	if(!UpdateBanInfo(ban_CurrentName[playerid], ban_CurrentReason[playerid], ban_CurrentDuration[playerid]))
	{
		ChatMsg(playerid, RED, " >  Ocorreu um erro: 'UpdateBanInfo' retornou 0.");
		return 0;
	}

	ChatMsg(playerid, YELLOW, " >  Você baniu "C_BLUE"%s", ban_CurrentName[playerid]);

	log("[BAN] %p baniu %s motivo: %s", playerid, ban_CurrentName[playerid], ban_CurrentReason[playerid]);

	return 1;
}
