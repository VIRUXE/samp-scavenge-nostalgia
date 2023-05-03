#include <YSI\y_hooks>

static const MIN_BEEP_INTERVAL            = 250;    // Minimum beep interval in milliseconds
static const MAX_BEEP_INTERVAL            = 2500;   // Maximum beep interval in milliseconds
static const Float:FAR_PROXIMITY_DISTANCE = 1000.0;  // Distance beyond which beep frequency stops increasing

static 
    bool:       deviceActive[MAX_PLAYERS],
    Timer:      beepTimer[MAX_PLAYERS],
    PlayerText: distanceTextDraw[MAX_PLAYERS];

ToggleRadiationDevice(playerid, bool:toggle) {
    if(toggle == deviceActive[playerid]) return;

    if(toggle) {
        beepTimer[playerid] = defer Beep(playerid, CalculateBeepInterval(playerid));
        
        PlayerTextDrawShow(playerid, distanceTextDraw[playerid]);
    } else {
        stop beepTimer[playerid];
        PlayerPlaySound(playerid, 0, 0.0, 0.0, 0.0);

        PlayerTextDrawHide(playerid, distanceTextDraw[playerid]);
    }

    deviceActive[playerid] = toggle;

    printf("[GEIGER] %s para %p", toggle ? "Ativado" : "Desativado", playerid);
    ChatMsg(playerid, COLOR_RADIATION, "Contador Geiger %s", toggle ? "Ativado" : "Desativado");

    PrintBacktrace();

    return; 
}

DoesPlayerHaveRadiationDevice(playerid) {
    for(new i; i < INV_MAX_SLOTS; i++)
        if(GetItemType(GetInventorySlotItem(playerid, i)) == item_Map) return 1;

    return 0;
}

bool:IsRadiationDeviceActive(playerid) return deviceActive[playerid];

CalculateBeepInterval(playerid) {
    new const Float:cloudDistance = GetPlayerDistanceToRadiation(playerid);

    new interval = MAX_BEEP_INTERVAL;
    // printf("[GEIGER] CalculateBeepInterval(%d)", playerid);
    // printf("\t[GEIGER] Cloud Distance: %0.2f", cloudDistance);

    if (cloudDistance >= 0.0) {
        new Float:distanceFactor = (cloudDistance < FAR_PROXIMITY_DISTANCE) ? cloudDistance : FAR_PROXIMITY_DISTANCE;
        interval = floatround(((distanceFactor / FAR_PROXIMITY_DISTANCE) * (MAX_BEEP_INTERVAL - MIN_BEEP_INTERVAL)) + MIN_BEEP_INTERVAL);
        // printf("\t[GEIGER] Distance Factor: %0.2f", distanceFactor);
    } else
        interval = MIN_BEEP_INTERVAL;

    PlayerTextDrawSetString(playerid, distanceTextDraw[playerid], sprintf("%.0f", cloudDistance));

    // printf("\t[GEIGER] New Beep Interval: %d", interval);

    return interval;
}

hook OnPlayerConnect(playerid) {
    distanceTextDraw[playerid] = CreatePlayerTextDraw(playerid, 382, 14, "Distance");

	PlayerTextDrawLetterSize(playerid, distanceTextDraw[playerid], 1, 3.5);
	PlayerTextDrawTextSize(playerid, distanceTextDraw[playerid], 522, 45.999999);
	PlayerTextDrawAlignment(playerid, distanceTextDraw[playerid], 1);
	PlayerTextDrawColor(playerid, distanceTextDraw[playerid], 0xFFFFFFFF);
	PlayerTextDrawUseBox(playerid, distanceTextDraw[playerid], 1);
	PlayerTextDrawBoxColor(playerid, distanceTextDraw[playerid], 0x000000AA);
	PlayerTextDrawSetShadow(playerid, distanceTextDraw[playerid], 0);
	PlayerTextDrawSetOutline(playerid, distanceTextDraw[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, distanceTextDraw[playerid], 0x000000FF);
	PlayerTextDrawFont(playerid, distanceTextDraw[playerid], 1);
	PlayerTextDrawSetProportional(playerid, distanceTextDraw[playerid], 1);
}

hook OnPlayerDisconnect(playerid, reason) {
    ToggleRadiationDevice(playerid, false);

    return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerLoad(playerid, filename[]) {
    if(DoesPlayerHaveRadiationDevice(playerid)) ToggleRadiationDevice(playerid, true);

    return Y_HOOKS_CONTINUE_RETURN_0;
}

// * Problema aqui e que se escolher dropar ele chama
hook OnPlayerGetItem(playerid, itemid) {
    if(GetItemType(itemid) == item_GeigerCounter) ToggleRadiationDevice(playerid, true);
}

hook OnPlayerPickUpItem(playerid, itemid) {
	if(GetItemType(itemid) == item_GeigerCounter) ToggleRadiationDevice(playerid, true);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDropItem(playerid, itemid) {
	if(GetItemType(itemid) == item_GeigerCounter) ToggleRadiationDevice(playerid, false);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

// Caso simplesmente remova de um container para o inventario
hook OnItemAddToInventory(playerid, itemid) {
	if(GetItemType(itemid) == item_GeigerCounter) ToggleRadiationDevice(playerid, true);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemoveFInventory(playerid, itemid) {
	if(GetItemType(itemid) == item_GeigerCounter) ToggleRadiationDevice(playerid, false);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnAdminToggleDuty(playerid, bool:toggle, bool:goBack) {
    if(DoesPlayerHaveRadiationDevice(playerid)) ToggleRadiationDevice(playerid, !toggle);
}

timer Beep[interval](playerid, interval) {
    if(!deviceActive[playerid]) return;

    // printf("[GEIGER] Beep(%d, %d)", playerid, interval);

    // Nao reproduzir som se for MAX_BEEP_INTERVAL ou acima, pois ja estara bastante longe, entao nao deteta radiacao
    if(interval < MAX_BEEP_INTERVAL) {
        new Float:x, Float:y, Float:z;
        GetPositionBehindPlayer(playerid, x, y, z, 20.0);
        PlayerPlaySound(playerid, 4203, x, y, z);
    }

    defer Beep(playerid, CalculateBeepInterval(playerid));
}

CMD:raddevice(playerid) {
    ToggleRadiationDevice(playerid, !deviceActive[playerid]);

    return 1;
}

// * Temporario
GetPositionBehindPlayer(playerid, &Float:x, &Float:y, &Float:z, Float:distance = 1.0) {
    new Float:playerX, Float:playerY, Float:playerZ, Float:playerAngle;
    GetPlayerPos(playerid, playerX, playerY, playerZ);
    GetPlayerFacingAngle(playerid, playerAngle);

    x = playerX - distance * floatsin(-playerAngle, degrees);
    y = playerY - distance * floatcos(-playerAngle, degrees);
    z = playerZ;
}