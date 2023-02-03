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


#define DIRECTORY_CRAFTS	DIRECTORY_MAIN"crafts/"

forward OnCraftLoad(itemid, active, geid[], data[], length);


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnPlayerDeconstructed(playerid, itemid, itemid2)
{
    RemoveSavedItem(itemid, DIRECTORY_CRAFTS);
}

hook OnPlayerConstructed(playerid, consset, result)
{
    SaveCraftItem(result);
}

hook OnItemTweakFinish(playerid, itemid)
{
	if(GetDefenceType(itemid) == -1)
	{
    	SaveCraftItem(itemid);
    }
}


hook OnScriptInit()
{
	print("\n[OnScriptInit] Initialising 'crafts-io'...");

	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_CRAFTS);
}

hook OnGameModeInit()
{
	print("\n[OnGameModeInit] Initialising 'crafts-io'...");

	LoadItems(DIRECTORY_CRAFTS, "OnCraftLoad");
}

stock IsCraftTypeSaved(itemid)
{
	if(GetItemType(itemid) == item_Bed)
		return 1;
	    
	if(GetItemType(itemid) == item_Workbench)
	    return 1;
	    
	if(GetItemType(itemid) == item_Desk)
	    return 1;

	if(GetItemType(itemid) == item_Table)
	    return 1;
	    
    if(GetItemType(itemid) == item_GunCase)
	    return 1;
	    
    if(GetItemType(itemid) == item_Barstool)
	    return 1;
	    
    if(GetItemType(itemid) == item_SmallTable)
    	return 1;

	if(GetItemType(itemid) == item_ScrapMachine)
    	return 1;

	if(GetItemType(itemid) == item_RefineMachine)
    	return 1;

	if(GetItemType(itemid) == item_WaterMachine)
    	return 1;
}

/*==============================================================================

	Save and Load Individual

==============================================================================*/


SaveCraftItem(itemid)
{
	if(GetItemType(itemid) != item_Locker)
    	SaveWorldItem(itemid, DIRECTORY_CRAFTS, true, true);
		
	return 0;
}

public OnCraftLoad(itemid, active, geid[], data[], length)
{
	if(GetItemType(itemid) == item_Locker)
	    RemoveSavedItem(itemid, DIRECTORY_CRAFTS), DestroyItem(itemid);

	return 1;
}
