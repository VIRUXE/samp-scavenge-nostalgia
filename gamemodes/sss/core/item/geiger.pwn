#include <YSI\y_hooks>

static const MIN_BEEP_INTERVAL            = 250;    // Minimum beep interval in milliseconds
static const MAX_BEEP_INTERVAL            = 2500;   // Maximum beep interval in milliseconds
static const Float:MIN_DETECTION_DISTANCE = 1000.0;  // Distance beyond which beep frequency stops increasing

static 
    bool: geigerActive[MAX_PLAYERS],
    Timer: beepTimer[MAX_PLAYERS],
    Timer: barTimer[MAX_PLAYERS],
    PlayerText: distanceTextDraw[MAX_PLAYERS],
    PlayerBar: intensityBar = INVALID_PLAYER_BAR_ID;

static enum {
    GEIGER_NONE,
    GEIGER_IN_HAND,
    GEIGER_IN_INV,
    GEIGER_IN_BAG
}

ToggleGeiger(playerid, bool:toggle) {
    if(toggle == geigerActive[playerid]) return;

    if(toggle) {
        // Mostrar a barra apenas se estiver na mao
        if(DoesPlayerHaveGeiger(playerid) == GEIGER_IN_HAND) {
            barTimer[playerid] = repeat UpdateBar(playerid);
            ShowPlayerProgressBar(playerid, intensityBar);
        }

        beepTimer[playerid] = defer Beep(playerid, CalculateBeepInterval(playerid));
        
        // PlayerTextDrawShow(playerid, distanceTextDraw[playerid]);
    } else {
        if(barTimer[playerid]) {
            stop barTimer[playerid];
            HidePlayerProgressBar(playerid, intensityBar);
        }

        stop beepTimer[playerid];
        PlayerPlaySound(playerid, 0, 0.0, 0.0, 0.0);

        // PlayerTextDrawHide(playerid, distanceTextDraw[playerid]);
    }

    geigerActive[playerid] = toggle;

    printf("[GEIGER] %s para %p", toggle ? "Ativado" : "Desativado", playerid);
    ChatMsg(playerid, COLOR_RADIATION, "Contador Geiger %s", toggle ? "Ativado" : "Desativado");

    PrintBacktrace();

    return; 
}

DoesPlayerHaveGeiger(playerid) {
    // Na mao
    if(GetItemType(GetPlayerItem(playerid)) == item_GeigerCounter) return GEIGER_IN_HAND;

    // No inventario
    for(new i; i < INV_MAX_SLOTS; i++)
        if(GetItemType(GetInventorySlotItem(playerid, i)) == item_GeigerCounter) return GEIGER_IN_INV;

    // Na mochila
    new const bagItem = GetPlayerBagItem(playerid);
    if(!IsValidItem(bagItem)) return GEIGER_NONE;

    new const containerId = GetBagItemContainerID(bagItem);
    for(new i; i < GetContainerSize(containerId); i++)
        if(GetItemType(GetContainerSlotItem(containerId, i)) == item_GeigerCounter) return GEIGER_IN_BAG;

    return GEIGER_NONE;
}

CalculateBeepInterval(playerid) {
    new const Float:radiationDistance = GetPlayerDistanceToRadiation(playerid);
    new interval = MAX_BEEP_INTERVAL;
    // printf("[GEIGER] CalculateBeepInterval(%d)", playerid);
    // printf("\t[GEIGER] Cloud Distance: %0.2f", radiationDistance);

    if(radiationDistance >= RADIATIONCLOUD_BORDER) { // Quanto ja esta 
        new Float:distanceFactor = (radiationDistance < MIN_DETECTION_DISTANCE) ? radiationDistance : MIN_DETECTION_DISTANCE;
        interval = floatround(((distanceFactor / MIN_DETECTION_DISTANCE) * (MAX_BEEP_INTERVAL - MIN_BEEP_INTERVAL)) + MIN_BEEP_INTERVAL);
        // printf("\t[GEIGER] Distance Factor: %0.2f", distanceFactor);
    } else {
        interval = MIN_BEEP_INTERVAL;
    }
    
    PlayerTextDrawSetString(playerid, distanceTextDraw[playerid], sprintf("%.0f", radiationDistance));

    // printf("\t[GEIGER] New Beep Interval: %d", interval);

    return interval;
}

hook OnPlayerConnect(playerid) {
    intensityBar = CreatePlayerProgressBar(playerid, 638.0, 69.0, 10.0, 70.0, COLOR_RADIATION, 100.0, BAR_DIRECTION_UP);

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
    DestroyPlayerProgressBar(playerid, intensityBar);
    ToggleGeiger(playerid, false);

    return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerLoad(playerid, filename[]) {
    if(DoesPlayerHaveGeiger(playerid)) ToggleGeiger(playerid, true);

    return Y_HOOKS_CONTINUE_RETURN_0;
}

// * Problema aqui e que se escolher dropar ele chama
hook OnPlayerGetItem(playerid, itemid) {
    if(GetItemType(itemid) == item_GeigerCounter) ToggleGeiger(playerid, true);
}

hook OnPlayerPickUpItem(playerid, itemid) {
	if(GetItemType(itemid) == item_GeigerCounter) ToggleGeiger(playerid, true);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDropItem(playerid, itemid) {
	if(GetItemType(itemid) == item_GeigerCounter) ToggleGeiger(playerid, false);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

// Caso simplesmente remova de um container para o inventario
hook OnItemAddToInventory(playerid, itemid) {
	if(GetItemType(itemid) == item_GeigerCounter) ToggleGeiger(playerid, true);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemoveFInventory(playerid, itemid) {
	if(GetItemType(itemid) == item_GeigerCounter) ToggleGeiger(playerid, false);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnAdminToggleDuty(playerid, bool:toggle, bool:goBack) {
    if(DoesPlayerHaveGeiger(playerid)) ToggleGeiger(playerid, !toggle);
}

static timer UpdateBar[SEC(1)](playerid) {
    new const Float:radiationDistance = GetPlayerDistanceToRadiation(playerid);
    new const Float:radiationSize     = GetRadiationSize();

    if(radiationDistance <= MIN_DETECTION_DISTANCE) {
        // We need to add the radiation size because when the player is inside, the distance turns negative
        new const Float:totalDistance = radiationDistance + radiationSize;
        // Scale the totalDistance to a range of 0 to 100.0
        new Float:distancePercentage = (totalDistance / (MIN_DETECTION_DISTANCE + radiationSize)) * 100.0;
        // Invert the distancePercentage value
        distancePercentage = 100.0 - distancePercentage;

        SetPlayerProgressBarValue(playerid, intensityBar, frandom(distancePercentage, distancePercentage-5.0));
    } else {
        SetPlayerProgressBarValue(playerid, intensityBar, frandom(5.0));
    }
}


static timer Beep[interval](playerid, interval) {
    if(!geigerActive[playerid]) return;

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
    ToggleGeiger(playerid, !geigerActive[playerid]);

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