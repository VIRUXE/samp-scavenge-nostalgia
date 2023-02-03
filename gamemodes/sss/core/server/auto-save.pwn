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
		autosave_Block[ITM_MAX],
		autosave_Max,
bool:	autosave_Active;


hook OnScriptInit()
{
	defer AutoSave();
}

timer AutoSave[70000]()
{
	if(Iter_Count(Player) == 0)
	{
		defer AutoSave();
		return;
	}

	if(gServerUptime > gServerMaxUptime - 40)
		return;

	AutoSave_Player();

	return;
}

AutoSave_Player()
{
	new idx;

	foreach(new i : Player)
	{
		autosave_Block[idx] = i;
		idx++;
	}
	autosave_Max = idx;

	defer Player_BlockSaveTime(0);
}

timer Player_BlockSaveTime[300](index)
{
	autosave_Active = true;

	if(gServerUptime > gServerMaxUptime - 40)
		return;

	new i;

	for(i = index; i < index + 1 && i < autosave_Max; i++)
	{
		if(!IsPlayerConnected(autosave_Block[i]))
			continue;

		SavePlayerData(autosave_Block[i]);
	}

	if(i < autosave_Max)
		defer Player_BlockSaveTime(i);

	else
		defer AutoSave();

	autosave_Active = false;

	return;
}


/*==============================================================================

	Interface

==============================================================================*/


stock IsAutoSaving()
{
	return autosave_Active;
}
