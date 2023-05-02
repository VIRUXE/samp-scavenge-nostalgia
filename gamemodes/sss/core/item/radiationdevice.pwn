#include <YSI\y_hooks>

static const MIN_BEEP_INTERVAL       = 500;   // Minimum beep interval in milliseconds
static const MAX_BEEP_INTERVAL       = 5000;  // Maximum beep interval in milliseconds
static const FAR_PROXIMITY_DISTANCE  = 300;   // Distance beyond which beep frequency stops increasing
static const NEAR_PROXIMITY_DISTANCE = 50;    // Distance below which beep frequency stops decreasing

static 
    bool:DeviceActive[MAX_PLAYERS],
    Timer:BeepTimer[MAX_PLAYERS],
    Timer:BeepFrequencyCalculator[MAX_PLAYERS];

ToggleRadiationDevice(playerid, bool:toggle) {
    if(toggle == DeviceActive[playerid]) return;

    if(toggle) {
        BeepFrequencyCalculator[playerid] = repeat CalculateBeepInterval(playerid);
        BeepTimer[playerid] = repeat Beep(playerid, CalculateBeepInterval(playerid));
    } else {
        stop BeepFrequencyCalculator[playerid];
        stop BeepTimer[playerid];
        PlayerPlaySound(playerid, 0, 0.0, 0.0, 0.0);
    }

    DeviceActive[playerid] = toggle;

    printf("[RADIATIONDEVICE] %s para %p", toggle ? "Ativado" : "Desativado", playerid);
    ChatMsg(playerid, RADIATION_COLOR, "Medidor de Radiacao %s", toggle ? "Ativado" : "Desativado");

    return; 
}

DoesPlayerHaveRadiationDevice(playerid) {
    for(new i; i < INV_MAX_SLOTS; i++)
        if(GetItemType(GetInventorySlotItem(playerid, i)) == item_Map) return 1;

    return 0;
}

hook OnPlayerSpawn(playerid) {
    if(DoesPlayerHaveRadiationDevice(playerid)) ToggleRadiationDevice(playerid, true);

    return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDisconnect(playerid) {
    ToggleRadiationDevice(playerid, false);

    return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerPickUpItem(playerid, itemid) {
	if(GetItemType(itemid) == item_RadiationDevice) ToggleRadiationDevice(playerid, true);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDropItem(playerid, itemid) {
	if(GetItemType(itemid) == item_RadiationDevice) ToggleRadiationDevice(playerid, false);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

// Caso simplesmente remova de um container para o inventario
hook OnItemAddToInventory(playerid, itemid) {
	if(GetItemType(itemid) == item_RadiationDevice) ToggleRadiationDevice(playerid, true);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemoveFInventory(playerid, itemid) {
	if(GetItemType(itemid) == item_RadiationDevice) ToggleRadiationDevice(playerid, false);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnAdminToggleDuty(playerid, bool:toggle, bool:goBack) {
    if(DoesPlayerHaveRadiationDevice(playerid)) ToggleRadiationDevice(playerid, !toggle);
}

timer CalculateBeepInterval[SEC(1)](playerid) {
    new frequency = MAX_BEEP_INTERVAL;
    printf("[RADIATIONDEVICE] CalculateBeepInterval(%d)", playerid);

    return frequency;
}

timer Beep[frequency](playerid, frequency) {
    printf("[RADIATIONDEVICE] Beep(%d, %d)", playerid, frequency);

    PlayerPlaySound(playerid, 4203, 0.0, 0.0, 0.0);
}

CMD:raddevice(playerid) {
    ToggleRadiationDevice(playerid, !DeviceActive[playerid]);
}