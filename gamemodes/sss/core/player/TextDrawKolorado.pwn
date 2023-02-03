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
	PlayerText:p_StatusText[MAX_PLAYERS]= {PlayerText:INVALID_TEXT_DRAW, ...};

ptask ShowStatus[1000](playerid)
{
	if(!IsPlayerSpawned(playerid))
	    return;
	    
	new
		str[150],
		Float:food,
		Float:bleed;
		
    food = GetPlayerFP(playerid);
    bleed = GetPlayerBleedRate(playerid);
    
// ---------------------------------------------------------------------------------------
    
	if(food > 30.0 && bleed == 0.00)
		
    format(str, sizeof(str), ls(playerid, "STATUSUPD"),
	    GetPlayerScore(playerid), GetPlayerDeathCount(playerid),
		GetPlayerSpree(playerid), GetPlayerBleedRate(playerid), GetPlayerFP(playerid));

	PlayerTextDrawSetString(playerid, p_StatusText[playerid], str);
	PlayerTextDrawShow(playerid, p_StatusText[playerid]);
	
// ---------------------------------------------------------------------------------------
	
	if(food < 30.0 && bleed > 0.00)
	
	format(str, sizeof(str), ls(playerid, "STATUSUPD2"),
	    GetPlayerScore(playerid), GetPlayerDeathCount(playerid),
		GetPlayerSpree(playerid), GetPlayerBleedRate(playerid), GetPlayerFP(playerid));

	PlayerTextDrawSetString(playerid, p_StatusText[playerid], str);
	PlayerTextDrawShow(playerid, p_StatusText[playerid]);
	
// ---------------------------------------------------------------------------------------

	if(food < 30.0 && bleed == 0.00)

	format(str, sizeof(str), ls(playerid, "STATUSUPD3"),
	    GetPlayerScore(playerid), GetPlayerDeathCount(playerid),
		GetPlayerSpree(playerid), GetPlayerBleedRate(playerid), GetPlayerFP(playerid));

	PlayerTextDrawSetString(playerid, p_StatusText[playerid], str);
	PlayerTextDrawShow(playerid, p_StatusText[playerid]);

// ---------------------------------------------------------------------------------------

	if(food > 30.0 && bleed > 0.00)

	format(str, sizeof(str), ls(playerid, "STATUSUPD4"),
	    GetPlayerScore(playerid), GetPlayerDeathCount(playerid),
		GetPlayerSpree(playerid), GetPlayerBleedRate(playerid), GetPlayerFP(playerid));

	PlayerTextDrawSetString(playerid, p_StatusText[playerid], str);
	PlayerTextDrawShow(playerid, p_StatusText[playerid]);

// ---------------------------------------------------------------------------------------

	return;
}
    
hook OnPlayerConnect(playerid)
{
	p_StatusText[playerid] = 	CreatePlayerTextDraw(playerid, 3.377638, 432.000000, "Score: 1000 - Mortes: 100 - Spree: 100 - Sangramento: 100 - Fome: 100");
	PlayerTextDrawAlignment			(playerid, p_StatusText[playerid], 1);
	PlayerTextDrawBackgroundColor	(playerid, p_StatusText[playerid], 255);
	PlayerTextDrawFont				(playerid, p_StatusText[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, p_StatusText[playerid], 0.222887, 1.532798);
	PlayerTextDrawColor				(playerid, p_StatusText[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, p_StatusText[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, p_StatusText[playerid], 1);
}
