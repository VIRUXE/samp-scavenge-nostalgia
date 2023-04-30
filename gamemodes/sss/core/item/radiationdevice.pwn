#include <YSI\y_hooks>

static const MIN_BEEP_INTERVAL       = 500;   // Minimum beep interval in milliseconds
static const MAX_BEEP_INTERVAL       = 5000;  // Maximum beep interval in milliseconds
static const FAR_PROXIMITY_DISTANCE  = 300;   // Distance beyond which beep frequency stops increasing
static const NEAR_PROXIMITY_DISTANCE = 50;    // Distance below which beep frequency stops decreasing

static 
    bool:DeviceActive[MAX_PLAYERS],
    Timer:BeepTimer[MAX_PLAYERS],
    Timer:BeepFrequencyCalculator[MAX_PLAYERS];

bool:ToggleRadiationDevice(playerid, bool:toggle) {
    if(toggle == DeviceActive[playerid]) return;

    if(toggle) {
        BeepFrequencyCalculator[playerid] = repeat CalculateBeepInterval(playerid);
        BeepTimer[playerid] = repeat Beep(playerid, CalculateBeepInterval(playerid));
    } else {
        stop BeepFrequencyCalculator[playerid];
        stop BeepTimer[playerid];
    }

    DeviceActive[playerid] = toggle;

    printf("[RADIATIONDEVICE] %s para %p", toggle ? "Ativado" : "Desativado", playerid);

    return;
}

hook OnPlayerSpawn(playerid) {
    // Verificamos o conteudo do inventario do jogador ou a mao. Qual deles vier primeiro
    // Se tiver um Radiation Device entao ativamos

    new ItemType:itemtype = GetItemType(GetPlayerItem(playerid));

    if(itemtype == item_RadiationDevice) {
        ToggleRadiationDevice(playerid, true);
	}

    return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDisconnect(playerid) {

    return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerPickUpItem(playerid, itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(itemtype == item_RadiationDevice) {
        ToggleRadiationDevice(playerid, true);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDropItem(playerid, itemid) {
    new ItemType:itemtype = GetItemType(itemid);

	if(itemtype == item_RadiationDevice) {
        ToggleRadiationDevice(playerid, false);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

// Caso simplesmente remova de um container para o inventario
hook OnItemAddToInventory(playerid, itemid)
{
    new ItemType:itemtype = GetItemType(itemid);

	if(itemtype == item_RadiationDevice) {
        ToggleRadiationDevice(playerid, true);
    }

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemoveFInventory(playerid, itemid)
{
    new ItemType:itemtype = GetItemType(itemid);

	if(itemtype == item_RadiationDevice) {
        ToggleRadiationDevice(playerid, false);
    }

	return Y_HOOKS_CONTINUE_RETURN_0;
}

timer CalculateBeepInterval[SEC(1)](playerid) {
    new frequency = MAX_BEEP_INTERVAL;
    printf("[RADIATIONDEVICE] CalculateBeepInterval(%d)", playerid);

    return frequency;
}

timer Beep[frequency](playerid, frequency) {
    printf("[RADIATIONDEVICE] Beep(%d, %d)", playerid, frequency);

    PlayerPlaySound(playerid, 2103, 0.0, 0.0, 0.0);
}