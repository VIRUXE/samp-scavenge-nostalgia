#include <YSI\y_hooks>

forward OnPlayerUsingMap(playerid, bool:yes);

// Mapa apenas pode ir no inventario, por alguma razao
bool:DoesPlayerHaveMap(playerid) {
	for(new i; i < INV_MAX_SLOTS; i++)
        if(GetItemType(GetInventorySlotItem(playerid, i)) == item_Map) return true;

    return false;
}

ToggleMap(playerid, bool:toggle) {
    if(toggle == DoesPlayerHaveMap(playerid)) return;

    if(toggle)
        GangZoneHideForPlayer(playerid, MiniMapOverlay);
    else
        GangZoneShowForPlayer(playerid, MiniMapOverlay, 0x000000FF);

    ToggleHudComponent(playerid, HUD_COMPONENT_RADAR, !toggle);

    CallLocalFunction("OnPlayerUsingMap", "db", playerid, toggle);
}

hook OnPlayerConnect(playerid) {
    ToggleMap(playerid, false);
}

hook OnItemAddToInventory(playerid, itemid) {
	if(GetItemType(itemid) == item_Map) ToggleMap(playerid, true);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemoveFInventory(playerid, itemid) {
	if(GetItemType(itemid) == item_Map) ToggleMap(playerid, false);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerSpawn(playerid) {
    ToggleMap(playerid, DoesPlayerHaveMap(playerid));
}