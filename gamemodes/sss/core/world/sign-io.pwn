/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but,
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/


#include <YSI\y_hooks>


#define DIRECTORY_SIGN	DIRECTORY_MAIN"sign/"

forward OnSignLoad(itemid, active, geid[], data[], length);


/*==============================================================================

	Zeroing

==============================================================================*/
hook OnSignCreate(itemid)
{
    SaveSignItem(itemid);
}

hook OnScriptInit()
{
	print("\n[OnScriptInit] Initialising 'sign-io'...");

	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_SIGN);
}

hook OnGameModeInit()
{
	print("\n[OnGameModeInit] Initialising 'sign-io'...");

	LoadItems(DIRECTORY_SIGN, "OnSignLoad");
}

hook OnPlayerPickUpItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Sign)
	{
		RemoveSavedItem(itemid, DIRECTORY_SIGN);
	}

	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerDroppedItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_Sign)
	{
		SaveSignItem(itemid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
hook OnItemArrayDataChanged(itemid)
{
	if(GetItemType(itemid) == item_Sign)
	{
	    SaveSignItem(itemid);
	}
}
/*==============================================================================

	Save and Load Individual

==============================================================================*/


SaveSignItem(itemid)
{
    new data[MAX_SIGN_TEXT];
	GetItemArrayData(itemid, data);

	if(isnull(data))
        RemoveSavedItem(itemid, DIRECTORY_SIGN);
        
	else
		SaveWorldItem(itemid, DIRECTORY_SIGN, true, true);
		
	return 0;
}

public OnSignLoad(itemid, active, geid[], data[], length)
{
	return 1;
}
