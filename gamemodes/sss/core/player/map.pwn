#include <YSI\y_hooks>

#define MAP_SIZE 3000
#define MAP_SIZE_FLOAT float(MAP_SIZE)

static mapOverlay = INVALID_GANG_ZONE; // Gangzone que cobre o mapa completo

// Mapa apenas pode ir no inventario, por alguma razao
bool:DoesPlayerHaveMap(playerid) {
	for(new i; i < INV_MAX_SLOTS; i++)
        if(GetItemType(GetInventorySlotItem(playerid, i)) == item_Map) return true;

    return false;
}

ToggleMap(playerid, bool:toggle) {
    if(toggle)
        GangZoneHideForPlayer(playerid, mapOverlay);
    else
        GangZoneShowForPlayer(playerid, mapOverlay, 0x000000FF);

    ToggleHudComponent(playerid, HUD_COMPONENT_RADAR, !toggle);

    CallLocalFunction("OnPlayerUsingMap", "db", playerid, toggle);
}

function OnPlayerUsingMap(playerid, bool:yes) {
    printf("[MAP] %s map for %p.", yes ? "Showing" : "Hiding", playerid);
}

hook OnGameModeInit() {
    mapOverlay = GangZoneCreate(-6000, -6000, 6000, 6000);
}

hook OnPlayerConnect(playerid) {
    // Esconder sempre. Se depois o personagem tiver o item mapa, ele fica liberado
    GangZoneShowForPlayer(playerid, mapOverlay, 0x000000FF);
}

hook OnItemAddToInventory(playerid, itemid) {
    // printf("[MAP] OnItemAddToInventory(%d, %d)", playerid, itemid);
	if(GetItemType(itemid) == item_Map) ToggleMap(playerid, true);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemoveFInventory(playerid, itemid) {
	if(GetItemType(itemid) == item_Map) ToggleMap(playerid, false);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerSpawnCharacter(playerid) {
    new bool:map = DoesPlayerHaveMap(playerid);

    ToggleMap(playerid, map);
    
    printf("[MAP] OnPlayerSpawnCharacter(%d) -> Has Map: %s", playerid, booltostr(map));
}

// ? Nao tenho a certeza se esse callback e chamado unicamente ou juntamente com o OnPlayerSpawnCharacter
hook OnPlayerSpawnNewChar(playerid) {
    new bool:map = DoesPlayerHaveMap(playerid);

    ToggleMap(playerid, map);
    
    printf("[MAP] OnPlayerSpawnNewChar(%d) -> Map: %s", playerid, booltostr(map));
}