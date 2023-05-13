#include <YSI\y_hooks>

#define MAP_SIZE 3000
#define MAP_SIZE_FLOAT float(MAP_SIZE)

forward OnPlayerUsingMap(playerid, bool:yes);

static mapOverlay = INVALID_GANG_ZONE; // Gangzone que cobre o mapa completo

// Mapa apenas pode ir no inventario, por alguma razao
bool:DoesPlayerHaveMap(playerid) {
	for(new i; i < INV_MAX_SLOTS; i++)
        if(GetItemType(GetInventorySlotItem(playerid, i)) == item_Map) return true;

    return false;
}

ToggleMap(playerid, bool:toggle) {
    if(toggle == DoesPlayerHaveMap(playerid)) return;

    if(toggle)
        GangZoneHideForPlayer(playerid, mapOverlay);
    else
        GangZoneShowForPlayer(playerid, mapOverlay, 0x000000FF);

    ToggleHudComponent(playerid, HUD_COMPONENT_RADAR, !toggle);

    CallLocalFunction("OnPlayerUsingMap", "db", playerid, toggle);
}

hook OnGamemodeInit() {
    mapOverlay = GangZoneCreate(-MAP_SIZE, -MAP_SIZE, MAP_SIZE, MAP_SIZE);

    print("[MAP] GangZone criada.");
}

hook OnPlayerConnect(playerid) {
    ToggleMap(playerid, false);
}

hook OnItemAddToInventory(playerid, itemid) {
    printf("[MAP] OnItemAddToInventory(%d, %d)", playerid, itemid);

	if(GetItemType(itemid) == item_Map) ToggleMap(playerid, true);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemoveFInventory(playerid, itemid) {
	if(GetItemType(itemid) == item_Map) ToggleMap(playerid, false);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerSpawnCharacter(playerid) {
    new bool:map = DoesPlayerHaveMap(playerid);
    printf("[MAP] OnPlayerSpawnCharacter(%d): Map: %s", playerid, booltostr(map));
    ToggleMap(playerid, map);
}

// ? Nao tenho a certeza se esse callback e chamado unicamente ou juntamente com o OnPlayerSpawnCharacter
hook OnPlayerSpawnNewChar(playerid) {
    new bool:map = DoesPlayerHaveMap(playerid);
    printf("[MAP] OnPlayerSpawnNewChar(%d): Map: %s", playerid, booltostr(map));
    ToggleMap(playerid, map);
}