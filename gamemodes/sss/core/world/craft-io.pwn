#include <YSI\y_hooks>

new const DIRECTORY_CRAFTS[] = "data/crafts/"

forward OnCraftLoad(itemid, active, geid[], data[], length);

hook OnPlayerDeconstructed(playerid, itemid, itemid2) {
    RemoveSavedItem(itemid, DIRECTORY_CRAFTS);
}

hook OnPlayerConstructed(playerid, consset, result) {
	if(!IsPlayerInTutorial(playerid))
    	SaveCraftItem(result);
}

hook OnItemTweakFinish(playerid, itemid) {
	if(GetDefenceType(itemid) == -1 && !IsPlayerInTutorial(playerid))
    	SaveCraftItem(itemid);
}


hook OnScriptInit() {
	print("\n[OnScriptInit] Initialising 'crafts-io'...");

	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_CRAFTS);
}

hook OnGameModeInit() {
	print("\n[OnGameModeInit] Initialising 'crafts-io'...");

	LoadItems(DIRECTORY_CRAFTS, "OnCraftLoad");
}

// Para que essa merda?
stock IsCraftTypeSaved(itemid) {
	new ItemType:itemType = GetItemType(itemid);

	if(itemType == item_Bed) return 1;
	    
	if(itemType == item_Workbench) return 1;
	    
	if(itemType == item_Desk) return 1;

	if(itemType == item_Table) return 1;
	    
    if(itemType == item_GunCase) return 1;
	    
    if(itemType == item_Barstool) return 1;
	    
    if(itemType == item_SmallTable) return 1;

	if(itemType == item_ScrapMachine) return 1;

	if(itemType == item_RefineMachine) return 1;

	if(itemType == item_WaterMachine) return 1;
}

SaveCraftItem(itemid) {
	if(GetItemType(itemid) != item_Locker) SaveWorldItem(itemid, DIRECTORY_CRAFTS, true, true);
		
	return 0;
}

public OnCraftLoad(itemid, active, geid[], data[], length) {
	if(GetItemType(itemid) == item_Locker) RemoveSavedItem(itemid, DIRECTORY_CRAFTS), DestroyItem(itemid);

	return 1;
}
