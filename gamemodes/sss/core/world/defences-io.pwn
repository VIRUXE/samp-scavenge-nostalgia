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


==============================================================================*/#include <YSI\y_hooks>

#define DIRECTORY_DEFENCES	DIRECTORY_MAIN"defences/"

forward OnDefenceLoad(itemid, active, geid[], data[], length);


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit(){
	print("\n[OnScriptInit] Initialising 'defences-io'...");
	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_DEFENCES);
}

hook OnGameModeInit(){
	print("\n[OnGameModeInit] Initialising 'defences-io'...");
	LoadItems(DIRECTORY_DEFENCES, "OnDefenceLoad");
}

hook OnDefenceCreate(itemid){
	SaveDefenceItem(itemid);
}

hook OnDefenceModified(itemid){
	SaveDefenceItem(itemid);
}

hook OnDefenceMove(itemid){
	SaveDefenceItem(itemid);
}

hook OnDefenseDestroyed(itemid){
	SetItemArrayDataAtCell(itemid, 0, 0);
	RemoveSavedItem(itemid, DIRECTORY_DEFENCES);
}

/*==============================================================================

	Save and Load Individual

==============================================================================*/

SaveDefenceItem(itemid){
	if(GetItemWorld(itemid) == 0)
		SaveWorldItem(itemid, DIRECTORY_DEFENCES, true, true);
	return 0;
}

public OnDefenceLoad(itemid, active, geid[], data[], length){
	if(!IsItemTypeDefence(GetItemType(itemid)))
	{
	    RemoveSavedItem(itemid, DIRECTORY_DEFENCES);
	    DestroyItem(itemid);
	}
	else if(active)
	{
	    new Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz;
		GetItemPos(itemid, x, y, z);
		GetItemRot(itemid, rx, ry, rz);
		
	    ActivateDefenceItem(itemid);
	    
	    SetItemPos(itemid, x, y, z);
		SetItemRot(itemid, rx, ry, rz);
		
		CreateDefence(itemid);
	}
	return 1;
}
