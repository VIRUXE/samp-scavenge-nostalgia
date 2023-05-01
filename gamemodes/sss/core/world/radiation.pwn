#include <YSI\y_hooks>

// Constantes de comportamento da nuvem
static const Float:CLOUD_MIN_SPEED        = 5.0;
static const Float:CLOUD_MAX_SPEED        = 10.0;
static const Float:CLOUD_MIN_SIZE         = 500.0;
static const Float:CLOUD_MAX_SIZE         = 1000.0;
static const Float:CLOUD_SIZE_CHANGE      = 50.0;    // Maximum size change per second
static const Float:CLOUD_SPEED_CHANGE     = 0.0001;     // Maximum speed change per second
static const Float:CLOUD_DIRECTION_CHANGE = 5.0;     // Maximum angle change in degrees

static const RADIATION_COLOR = 0x00FF00FF;

// Propriedades da nuvem
static Float:cloudPosX;
static Float:cloudPosY;
static Float:cloudSize;
static Float:cloudSpeed;
static Float:cloudDirection;
static cloudGangZone = INVALID_GANG_ZONE;

// Retorna o tamanho da nuvem de radiação
stock Float:GetRadiationCloudSize() return cloudSize;

// Retorna a velocidade da nuvem de radiação
stock Float:GetRadiationCloudSpeed() return cloudSpeed;

// Retorna a localização da nuvem de radiação (posição X e posição Y)
stock GetRadiationCloudLocation(&Float:x, &Float:y) {
    x = cloudPosX;
    y = cloudPosY;
}

// Retorna a distância até a nuvem de radiação
Float:GetDistanceToRadiationCloud(Float: posX, Float: posY) return Distance2D(posX, posY, cloudPosX, cloudPosY);

bool:IsPlayerInsideCloud(playerid) {
    new Float:playerX, Float:playerY, Float:playerZ;
    GetPlayerPos(playerid, playerX, playerY, playerZ);

    // Calculate the distance between the player and the cloud center using Distance2D function
    new Float:distance = Distance2D(playerX, playerY, cloudPosX, cloudPosY);

    // Check if the player's distance from the cloud center is less than or equal to the cloud size
    return distance <= cloudSize;
}

bool:IsPlayerWearingRadiationMask(playerid) return GetPlayerMaskItem(playerid) == item_GasMask ? true : false;

bool:IsPlayerExposedToRadiation(playerid) {
    if (!IsPlayerInsideCloud(playerid)) return false;

    printf("[IsPlayerBeingAffectedByRadiation] Player %d is inside the cloud.", playerid);

    // Check if the player is inside a building
    if (GetPlayerInterior(playerid)) {
        printf("[IsPlayerBeingAffectedByRadiation] Player %d is inside a building.", playerid);
        return false; // Player is inside a building, not affected by radiation
    }

    // Check if the player is in a covered vehicle
    const vehicleid = GetPlayerVehicleID(playerid);
    if (vehicleid != INVALID_VEHICLE_ID && !IsModelOpenTopVehicle(GetVehicleModel(vehicleid))) {
        printf("[IsPlayerBeingAffectedByRadiation] Player %d is in a covered vehicle.", playerid);
        return false; // Player is in a covered car, not affected by radiation
    }

    // Check if the player is inside a well protected structure
    new Float:playerPosX, Float:playerPosY, Float:playerPosZ;
    GetPlayerPos(playerid, playerPosX, playerPosY, playerPosZ);

    new Float:collisions[100][3];
    new numCollisions = CA_RayCastExplode(playerPosX, playerPosY, playerPosZ, 50.0, 20.0, collisions);

    new minCollisionsForProtection = floatround(numCollisions * 0.9, floatround_floor);
    printf("[IsPlayerBeingAffectedByRadiation] Player %d has %d collisions out of %d needed for protection.", playerid, numCollisions, minCollisionsForProtection);

    if (numCollisions >= minCollisionsForProtection) {
        printf("[IsPlayerBeingAffectedByRadiation] Player %d is in a confined space.", playerid);
        return false; // Player has a structure above them, not affected by radiation
    }

    // Check if the player is wearing a mask
    if (IsPlayerWearingRadiationMask(playerid)) {
        printf("[IsPlayerBeingAffectedByRadiation] Player %d is wearing a radiation mask.", playerid);
        return false; // Player is wearing a mask, not affected by radiation
    }

    printf("[IsPlayerBeingAffectedByRadiation] Player %d is affected by radiation.", playerid);
    return true; // Player is under the cloud and not protected, affected by radiation
}

static InitializeRadiationCloud() {
    // Escolhemos uma borda aleatória: 0 - topo, 1 - inferior, 2 - esquerda, 3 - direita
    new const border = random(4);

    switch (border) {
        case 0: // Borda superior
        {
            cloudPosX = random_float(-3000.0, 3000.0);
            cloudPosY = 3000.0;
        }
        case 1: // Borda inferior
        {
            cloudPosX = random_float(-3000.0, 3000.0);
            cloudPosY = -3000.0;
        }
        case 2: // Borda esquerda
        {
            cloudPosX = -3000.0;
            cloudPosY = random_float(-3000.0, 3000.0);
        }
        case 3: // Borda direita
        {
            cloudPosX = 3000.0;
            cloudPosY = random_float(-3000.0, 3000.0);
        }
    }

    // Define outras propriedades da nuvem
    cloudSize      = random_float(CLOUD_MIN_SIZE, CLOUD_MAX_SIZE);
    cloudSpeed     = random_float(CLOUD_MIN_SPEED, CLOUD_MAX_SPEED);
    cloudDirection = random_float(0.0, 360.0);

    // Cria uma zona de gangue para a nuvem de radiação
    cloudGangZone = GangZoneCreate(-100.0, -100.0, 100.0, 100.0);
    GangZoneShowForAll(cloudGangZone, RADIATION_COLOR); // Define a cor da nuvem de radiação para verde tóxico

    new const borderDescriptions[][] = {"Superior", "Inferior", "Esquerda", "Direita"};

    printf("[RADIATION] Borda: %s, Tamanho: %.2f, Velocidade: %.2f, Direção: %.2f", borderDescriptions[border], cloudSize, cloudSpeed, cloudDirection);
}

// Atualiza a função UpdateRadiationCloud para criar/atualizar o objeto dummy com as mesmas coordenadas X e Y da nuvem:
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

    // Verifica se a posição central da nuvem está sobre a terra
    if (IsPosition2DOnLand(cloudPosX, cloudPosY)) {
        if (!isCloudOnLand) {
            printf("[RADIATION] Cloud hit land.");
            isCloudOnLand = true;
        }
    } else {
        if (isCloudOnLand) {
            printf("[RADIATION] Cloud isn't on land anymore.");
            isCloudOnLand = false;
        }
    }

    // Atualiza a posição e o tamanho da zona de gangue
    GangZoneDestroy(cloudGangZone);
    cloudGangZone = GangZoneCreate(cloudMinX, cloudMinY, cloudMaxX, cloudMaxY);
    GangZoneShowForAll(cloudGangZone, RADIATION_COLOR);

    // Calculate the coordinates for the dummy object
    new Float:groundZ;
    if(CA_FindZ_For2DCoord(cloudPosX, cloudPosY, groundZ)) {
        static ballObject = INVALID_OBJECT_ID;

        if(ballObject == INVALID_OBJECT_ID)
            ballObject = CreateObject(1946, cloudPosX, cloudPosY, groundZ + 2.0, 0.0, 0.0, 0.0);
        else
            SetObjectPos(ballObject, cloudPosX, cloudPosY, groundZ + 2.0);
    }

    // Verifica se a nuvem alcançou a borda oposta do mapa e reinicializa
    if((cloudPosX > 3000) || (cloudPosX < -3000) || (cloudPosY > 3000) || (cloudPosY < -3000)) {
        printf("[RADIATION] Nuvem bateu numa borda. Iniciando outra.");

        InitializeRadiationCloud();
    }
}

hook OnGameModeInit() {
    InitializeRadiationCloud();
}

static timer GotoCloud[100](playerid) {
    new Float:groundZ;

    if(CA_FindZ_For2DCoord(cloudPosX, cloudPosY, groundZ))
        SetPlayerPos(playerid, cloudPosX, cloudPosY, groundZ + 2.0); // Teleport the player 2.0 units above the ground to avoid falling through
}

ACMD:followcloud[5](playerid) {
    static bool:follow;
    static Timer:followTimer;

    follow = !follow;

    if(follow)
        followTimer = repeat GotoCloud(playerid);
    else
        stop followTimer;

    return 1;
}