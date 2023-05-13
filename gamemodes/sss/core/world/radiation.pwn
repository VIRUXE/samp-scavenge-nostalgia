#include <YSI\y_hooks>

#define RADIATIONCLOUD_BORDER 0.0
#define COLOR_RADIATION 0x00FF00BB

forward OnPlayerEnterRadiation(playerid, Float:percentageInside);
forward OnPlayerExitRadiation(playerid);

static bool:radiationDebug;

// Constantes de comportamento da nuvem
static const Float:CLOUD_MIN_SPEED        = 0.1;
static const Float:CLOUD_MAX_SPEED        = 1.0;
static const Float:CLOUD_SPEED_CHANGE     = 0.05;     // Maximum speed change per second
static const Float:CLOUD_MIN_SIZE         = 500.0;
static const Float:CLOUD_MAX_SIZE         = 1000.0;
static const Float:CLOUD_SIZE_CHANGE      = 50.0;    // Maximum size change per second
static const Float:CLOUD_DIRECTION_CHANGE = 5.0;     // Maximum angle change in degrees

// Propriedades da nuvem
static
    Float:cloudPosX,
    Float:cloudPosY,
    Float:cloudSize,
    Float:cloudSpeed,
    Float:cloudDirection;

static 
    Iterator:playersInside<MAX_PLAYERS>,
    Float:playerExposure[MAX_PLAYERS], // Exposicao em percentagem
    Float:playerDistance[MAX_PLAYERS]; // Distancia para a nuvem (negativo se ja estiver dentro)

static const MIN_COLLISIONS_FOR_PROTECTION = 320;

Float:GetRadiationSize() return cloudSize;

// 0.0 na borda e valor negativo dai para dentro
Float:CalculateDistanceToRadiation(playerid) {
    new Float:playerX, Float:playerY, Float:playerZ;
    GetPlayerPos(playerid, playerX, playerY, playerZ);

    // Calculate the 2D distance between the player and the cloud center
    new Float:centerDistance = Distance2D(playerX, playerY, cloudPosX, cloudPosY);

    // Subtract the size of the cloud to get the distance to the edge
    new Float:edgeDistance = centerDistance - cloudSize;

    playerDistance[playerid] = edgeDistance;

    return edgeDistance;
}

Float:GetPlayerDistanceToRadiation(playerid) return IsPlayerConnected(playerid) ? playerDistance[playerid] : 0.0;

Float:GetPercentageToRadiationCenter(Float:radiationDistance) {
    if (radiationDistance > 0.0) return -1.0; // Player is outside the radiation cloud

    new const Float:positiveDistance = -1.0 * radiationDistance; // Convert the negative distance to a positive value

    return (positiveDistance / cloudSize) * 100.0;
}

bool:IsPlayerInsideRadiation(playerid) {
    foreach(new i : playersInside)
        if(i == playerid) return true;

    return false;
}

// Retorna o itemId se for mesmo uma mascara de gas
IsPlayerWearingGasMask(playerid) {
    new itemId = GetPlayerMaskItem(playerid);
	
	if(!IsValidItem(itemId)) return INVALID_ITEM_ID;

    return GetItemType(itemId) == item_GasMask ? itemId : INVALID_ITEM_ID;
}

Float:GetPlayerGasMaskProtection(playerid) {
    new mask = IsPlayerWearingGasMask(playerid);

    if(mask == INVALID_ITEM_ID) return 0.0; // If the player is not wearing a mask, return 0% protection

    //GetItemExtraData - Para ler a nivel de vida util da mascara

    return 100.0; // ! placeholder apenas
}

Float:GetPlayerRadiationExposure(playerid) return !IsPlayerConnected(playerid) ? 0.0 : playerExposure[playerid];

static Iterator:balls<216>;


Float:CalculateRadiationExposure(playerid, Float:radiationDistance = -0.0) {
    if(!IsPlayerInsideRadiation(playerid)) return 0.0;
    if(GetPlayerInterior(playerid)) {
        if(radiationDebug) ChatMsg(playerid, -1, "[CalculateRadiationExposure] You are in an interior, no exposure.");
        return 0.0;
    }

    if(radiationDistance == -0.0) radiationDistance = CalculateDistanceToRadiation(playerid);
    new const Float:distancePercentage = GetPercentageToRadiationCenter(radiationDistance);

    if(radiationDebug) ChatMsg(playerid, -1, "[CalculateRadiationExposure] Distance percentage: %f", distancePercentage);

    new Float:protectionPercentage;

    // Calcula se esta esta por baixo ou dentro de uma estrutura
    new Float:playerPosX, Float:playerPosY, Float:playerPosZ;
    GetPlayerPos(playerid, playerPosX, playerPosY, playerPosZ);

    foreach(new b : balls) DestroyObject(b);

    if (CA_GetRoomHeight(playerPosX, playerPosY, playerPosZ) > 0.0) {

//        new Float:collisions[324][3];
//        new numCollisions = CA_RayCastExplode(playerPosX, playerPosY, playerPosZ, 40.0, 10.0, 20.0, collisions);

        new Float:collisions[324][3];
        new numCollisions = CA_RayCastExplode(playerPosX, playerPosY, playerPosZ, 40.0, 10.0, collisions);

        for(new c; c < numCollisions; c++) Iter_Add(balls, CreateObject(1946, collisions[c][0], collisions[c][1], collisions[c][2], 0.0, 0.0, 0.0));

        if(radiationDebug) ChatMsg(playerid, GREY, "[CalculateRadiationExposure] Esta por baixo de uma estrutura (%d colisoes)", numCollisions);

        // Calculamos o quanto a estrutura protege
        if (numCollisions >= MIN_COLLISIONS_FOR_PROTECTION) {
            if(radiationDebug) ChatMsg(playerid, YELLOW, "[CalculateRadiationExposure] You are under a a well-protected structure");

            return 0.0;
        } else {
            protectionPercentage += (numCollisions / float(MIN_COLLISIONS_FOR_PROTECTION)) * 100.0;
            if(radiationDebug) ChatMsg(playerid, GREEN, "[CalculateRadiationExposure] You are under a structure, protection percentage: %f", protectionPercentage);
        }
    }

    // Protecao em veiculo coberto
    new const vehicleId = GetPlayerVehicleID(playerid);
    if (vehicleId && !IsVehicleOpenTop(vehicleId)) {
        new Float:minx, Float:miny, Float:minz, Float:maxx, Float:maxy, Float:maxz;
        
        CA_GetModelBoundingBox(GetVehicleModel(vehicleId), minx, miny, minz, maxx, maxy, maxz);
        
        new const Float:vehicleSize = (maxx - minx) * (maxy - miny) * (maxz - minz);

        new Float:vehicleProtection = 20.0 - (5000.0 / vehicleSize);
        vehicleProtection = fclamp(vehicleProtection, 10.0, 20.0);

        if(radiationDebug) ChatMsg(playerid, -1, "[CalculateRadiationExposure] Vehicle (%d) protection: %f", vehicleId, vehicleProtection);

        protectionPercentage += vehicleProtection;
    }

    // Protecao usando mascara de gas
    new Float:maskProtection = GetPlayerGasMaskProtection(playerid);

    if(maskProtection > 0.0) {
        protectionPercentage += maskProtection;
        if(radiationDebug) ChatMsg(playerid, -1, "[CalculateRadiationExposure] Mask protection: %f", maskProtection);
    }

    // Protecao vestindo skin de swap
    if (GetPlayerSkin(playerid) == 285) {
        protectionPercentage += 50.0;
        if(radiationDebug) ChatMsg(playerid, -1, "[CalculateRadiationExposure] Skin protection: %f", protectionPercentage);
    }

    protectionPercentage = fclamp(protectionPercentage, 0.0, 100.0);

    if(radiationDebug) ChatMsg(playerid, -1, "[CalculateRadiationExposure] Total protection percentage: %f", protectionPercentage);

    new const Float:exposure = 100.0 * (distancePercentage / 100.0) * (1.0 - (protectionPercentage / 100.0));

    playerExposure[playerid] = exposure;

    return exposure;
}

static InitializeRadiationCloud() {
    // Escolhemos uma borda aleat?ria: 0 - topo, 1 - inferior, 2 - esquerda, 3 - direita
    new const border = random(4);

    switch (border) {
        case 0: { // Borda superior
            cloudPosX = random_float(-MAP_SIZE, MAP_SIZE);
            cloudPosY = MAP_SIZE;
        } case 1: { // Borda inferior
            cloudPosX = random_float(-MAP_SIZE, MAP_SIZE);
            cloudPosY = -MAP_SIZE;
        } case 2: { // Borda esquerda
            cloudPosX = -MAP_SIZE;
            cloudPosY = random_float(-MAP_SIZE, MAP_SIZE);
        } case 3: { // Borda direita
            cloudPosX = MAP_SIZE;
            cloudPosY = random_float(-MAP_SIZE, MAP_SIZE);
        }
    }

    // Define as propriedades iniciais da nuvem
    cloudSize      = random_float(CLOUD_MIN_SIZE, CLOUD_MAX_SIZE);
    cloudSpeed     = random_float(CLOUD_MIN_SPEED, CLOUD_MAX_SPEED);
    cloudDirection = random_float(0.0, 360.0);

    new const borderDescriptions[][9] = {"Superior", "Inferior", "Esquerda", "Direita"};

    printf("[RADIATION] Nuvem Criada -> Borda: %s, Tamanho: %.2f, Velocidade: %.2f, Dire??o: %.2f", borderDescriptions[border], cloudSize, cloudSpeed, cloudDirection);
}

public OnPlayerEnterRadiation(playerid, Float:percentageInside) {
    // ChatMsgAll(COLOR_RADIATION, "%p entrou na radiacao. (%.1f dentro)", playerid, percentageInside);

    SetPlayerWeather(playerid, 249);
    SetPlayerTime(playerid, 22, 00);
}

public OnPlayerExitRadiation(playerid) {
    // ChatMsgAll(COLOR_RADIATION, "%p conseguiu fugir da radiacao", playerid);

	ResetClimate(playerid);
}

// Atualiza a fun??o UpdateRadiationCloud para criar/atualizar o objeto dummy com as mesmas coordenadas X e Y da nuvem:
static task UpdateRadiationCloud[SEC(1)]() {
    static bool:isCloudOnLand;

    // Gradual direction change
    cloudDirection += random_float(-CLOUD_DIRECTION_CHANGE, CLOUD_DIRECTION_CHANGE);

    // Keep the direction angle within 0 to 360 degrees
    cloudDirection = cloudDirection < 0.0 ? (cloudDirection + 360.0) : (cloudDirection >= 360.0) ? (cloudDirection - 360.0) : cloudDirection;

    cloudSpeed += random_float(-CLOUD_SPEED_CHANGE, CLOUD_SPEED_CHANGE);
    cloudPosX  += cloudSpeed * floatsin(-cloudDirection, degrees);
    cloudPosY  += cloudSpeed * floatcos(-cloudDirection, degrees);
    cloudSize  += random_float(-CLOUD_SIZE_CHANGE, CLOUD_SIZE_CHANGE);
    
    // Calculate the coordinates for the gangzone
    new const Float:cloudWidth  = cloudSize * 2.0;
    new const Float:cloudHeight = cloudSize * 2.0;
    new const Float:cloudMinX   = cloudPosX - cloudWidth / 2.0;
    new const Float:cloudMaxX   = cloudPosX + cloudWidth / 2.0;
    new const Float:cloudMinY   = cloudPosY - cloudHeight / 2.0;
    new const Float:cloudMaxY   = cloudPosY + cloudHeight / 2.0;

    // Verifica se a posi??o central da nuvem est? sobre a terra
    if (IsPosition2DOnLand(cloudPosX, cloudPosY)) {
        if (!isCloudOnLand) {
            printf("[RADIATION] Nuvem chegou em terra.");
            isCloudOnLand = true;
        }
    } else {
        if (isCloudOnLand) {
            printf("[RADIATION] Nuvem saiu de terra.");
            isCloudOnLand = false;
        }
    }

    // Atualiza a posi??o e o tamanho da zona de gangue
    static cloudGangZone = INVALID_GANG_ZONE;

    GangZoneDestroy(cloudGangZone);
    cloudGangZone = GangZoneCreate(cloudMinX, cloudMinY, cloudMaxX, cloudMaxY);

    // Liberar componentes do mapa apenas para quem tem o item mapa
    foreach(new p : Player) {
        if(DoesPlayerHaveMap(p)) {
            GangZoneShowForPlayer(p, cloudGangZone, COLOR_RADIATION);

            if(IsPlayerVip(p)) {
                DestroyDynamicMapIcon(99);
                SetPlayerMapIcon(p, 99, cloudPosX, cloudPosY, 0.0, 23, COLOR_RADIATION, MAPICON_GLOBAL);
            }
        }
    }
    
    // Calculate the coordinates for the dummy object
    new Float:groundZ;
    if(CA_FindZ_For2DCoord(cloudPosX, cloudPosY, groundZ)) {
        static ballObject = INVALID_OBJECT_ID;

        if(ballObject == INVALID_OBJECT_ID)
            ballObject = CreateObject(1946, cloudPosX, cloudPosY, groundZ + 2.0, 0.0, 0.0, 0.0);
        else {
            new Float:oldPosX, Float:oldPosY, Float:oldPosZ;
            GetObjectPos(ballObject, oldPosX, oldPosY, oldPosZ);

            new const Float:distance = Distance(cloudPosX, cloudPosY, groundZ + 2.0, oldPosX, oldPosY, oldPosZ);

            MoveObject(ballObject, cloudPosX, cloudPosY, groundZ + 2.0, distance);
        }
    }

    // Verifica se a nuvem alcan?ou a borda oposta do mapa e reinicializa
    if((cloudPosX > MAP_SIZE) || (cloudPosX < -MAP_SIZE) || (cloudPosY > MAP_SIZE) || (cloudPosY < -MAP_SIZE)) {
        printf("[RADIATION] Nuvem bateu numa borda. Iniciando outra.");

        InitializeRadiationCloud();
    } else
        if(radiationDebug) printf("[RADIATION] -> Direction: %.2f, Speed: %.2f, Size: %.2f, Position X: %.2f, Position Y: %.2f", cloudDirection, cloudSpeed, cloudSize, cloudPosX, cloudPosY);
}

static timer GotoCloud[SEC(1)](playerid, follow) {
    const Float:CAMERA_DISTANCE            = 20.0;
    const Float:CAMERA_HEIGHT_ABOVE_GROUND = 7.5;

    // Calculate the position offset based on cloud's direction
    new const Float:offsetX = -CAMERA_DISTANCE * floatsin(-cloudDirection, degrees);
    new const Float:offsetY = -CAMERA_DISTANCE * floatcos(-cloudDirection, degrees);

    // Calculate the camera position
    new const Float:x = cloudPosX + offsetX;
    new const Float:y = cloudPosY + offsetY;

    // Find the ground Z position
    new Float:groundZ;
    if (CA_FindZ_For2DCoord(x, y, groundZ)) {
        if(follow) {
            new const Float:z = groundZ + CAMERA_HEIGHT_ABOVE_GROUND;

            // Set the camera position and look at the cloud
            SetPlayerCameraPos(playerid, x, y, z);
            SetPlayerCameraLookAt(playerid, cloudPosX, cloudPosY, groundZ + 2.0, CAMERA_MOVE);
        } else
            SetPlayerPos(playerid, x,y, groundZ + 2.0);
    }
}

static ptask RadiationAreaCheck[SEC(1)](playerid) {
    if(!IsPlayerSpawned(playerid) || IsPlayerOnAdminDuty(playerid)) return;

    new Float:radiationDistance = CalculateDistanceToRadiation(playerid);

    if(radiationDistance <= RADIATIONCLOUD_BORDER) { // Se o player esta dentro da radiacao ou nao
        if(!IsPlayerInsideRadiation(playerid)) { // Se ainda nao esta no array entao adicionamos
            Iter_Add(playersInside, playerid);

            CallLocalFunction("OnPlayerEnterRadiation", "df", playerid, GetPercentageToRadiationCenter(radiationDistance));
        }

        // Atualiza o nivel de exposicao enquanto estiver dentro da nuvem
        new const Float:exposure = CalculateRadiationExposure(playerid, radiationDistance);

        new const Float:hpLost = 2.0 * (exposure / 100.0);

        if(hpLost) {
            ShowActionText(playerid, sprintf("Perdeu %.2f por exposicao (%.2f) radiativa.", hpLost, exposure), 500); 

            SetPlayerHP(playerid, GetPlayerHP(playerid) - hpLost);
        }
    } else {
        if(IsPlayerInsideRadiation(playerid)) {
            Iter_Remove(playersInside, playerid);

            CallLocalFunction("OnPlayerExitRadiation", "d", playerid);
        }
    }

    return;
}

// Apenas iniciar a nuvem quando o mundo acabar de gerar
hook OnWorldGenerated() {
    InitializeRadiationCloud();
}

ACMD:rad[5](playerid, params[]) {
    new subcmd[10];

    if(sscanf(params, "s[10]", subcmd)) return SendClientMessage(playerid, WHITE, "USAGE: /rad [debug|goto|follow|new]");

    if(isequal(subcmd, "exposure", true)) {
        new const Float:exposure = CalculateRadiationExposure(playerid);

        ChatMsg(playerid, COLOR_RADIATION, "Nivel de Exposicao Radioativa: %.2f", exposure);
    } else if(isequal(subcmd, "goto", true)) {
        GotoCloud(playerid, false);
    } else if(isequal(subcmd, "follow", true)) {
        static bool:follow;
        static Timer:followTimer;

        follow = !follow;

        if(follow)
            followTimer = repeat GotoCloud(playerid, true);
        else {
            SetCameraBehindPlayer(playerid);
            stop followTimer;
        }
    } else if(isequal(subcmd, "new", true))
        InitializeRadiationCloud();
    else if(isequal(subcmd, "debug", true)) {
        radiationDebug = !radiationDebug;

        ChatMsg(playerid, COLOR_RADIATION, "Debug de Nuvem %s", radiationDebug ? "Ativado" : "Desativado");
    } else
        SendClientMessage(playerid, WHITE, "USAGE: /rad [debug|goto|follow|new]");

    return 1;
}