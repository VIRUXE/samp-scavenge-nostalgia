#include <YSI\y_hooks>

// Constantes de comportamento da nuvem
#define CLOUD_MIN_SPEED 5.0
#define CLOUD_MAX_SPEED 20.0
#define CLOUD_MIN_SIZE 500.0
#define CLOUD_MAX_SIZE 5000.0
#define CLOUD_UPDATE_INTERVAL 1000 // Atualiza a cada 1000 ms

static const RADIATION_COLOR = 0x00FF00FF;

// Propriedades da nuvem
static Float:cloudPosX;
static Float:cloudPosY;
static Float:cloudSize;
static Float:cloudSpeed;
static Float:cloudDirection;
static cloudGangZone = INVALID_GANG_ZONE;
static dummyObject; // Bola de Basket para vermos a posicao da nuvem

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

bool:IsPlayerAffectedByRadiation(playerid) {
    if(IsPlayerInsideCloud(playerid)) {
        // Check if the player is inside a building
        if(GetPlayerInterior(playerid)) return false; // Player is inside a building, not affected by radiation

        // Check if the player is in a covered vehicle
        const vehicleid = GetPlayerVehicleID(playerid);
        if(vehicleid != INVALID_VEHICLE_ID) {
            const modelid = GetVehicleModel(vehicleid);

            if(IsModelOpenTopVehicle(modelid)) return false; // Player is in a covered car, not affected by radiation
        }

        // Check if the player has a ceiling above them using ColAndreas
        new Float:playerPosX, Float:playerPosY, Float:playerPosZ;
        new Float:hitPosX, Float:hitPosY, Float:hitPosZ;

        GetPlayerPos(playerid, playerPosX, playerPosY, playerPosZ);

        if(CA_RayCastLine(playerPosX, playerPosY, playerPosZ, playerPosX, playerPosY, playerPosZ + 50.0, hitPosX, hitPosY, hitPosZ) == 1) {
            return false; // Player has a ceiling above them, not affected by radiation
        }

        // Check if the player is wearing a mask
        if(IsPlayerWearingRadiationMask(playerid)) return false; // Player is wearing a mask, not affected by radiation

        return true; // Player is under the cloud and not protected, affected by radiation
    }

    return false; // Player is not under the cloud, not affected by radiation
}

static InitializeRadiationCloud() {
    // Escolhemos uma borda aleatória: 0 - topo, 1 - inferior, 2 - esquerda, 3 - direita
    new const border = random(4);

    switch (border) {
        case 0: // Borda superior
        {
            cloudPosX = random_float(-20000.0, 20000.0);
            cloudPosY = 20000.0;
        }
        case 1: // Borda inferior
        {
            cloudPosX = random_float(-20000.0, 20000.0);
            cloudPosY = -20000.0;
        }
        case 2: // Borda esquerda
        {
            cloudPosX = -20000.0;
            cloudPosY = random_float(-20000.0, 20000.0);
        }
        case 3: // Borda direita
        {
            cloudPosX = 20000.0;
            cloudPosY = random_float(-20000.0, 20000.0);
        }
    }

    // Define outras propriedades da nuvem
    cloudSize      = random_float(CLOUD_MIN_SIZE, CLOUD_MAX_SIZE);
    cloudSpeed     = random_float(CLOUD_MIN_SPEED, CLOUD_MAX_SPEED);
    cloudDirection = random_float(0.0, 360.0);

    // Cria uma zona de gangue para a nuvem de radiação
    cloudGangZone = GangZoneCreate(-100.0, -100.0, 100.0, 100.0);
    GangZoneShowForAll(cloudGangZone, RADIATION_COLOR); // Define a cor da nuvem de radiação para verde tóxico

    printf("[RADIATION] Border: %d, Size: %.2f, Speed: %.2f, Direction: %.2f", border, cloudSize, cloudSpeed, cloudDirection);
}

// Atualiza a função UpdateRadiationCloud para criar/atualizar o objeto dummy com as mesmas coordenadas X e Y da nuvem:
static task UpdateRadiationCloud[SEC(1)]() {
    // Atualiza a posição da nuvem com base na velocidade e direção
    cloudPosX += cloudSpeed * floatsin(-cloudDirection, degrees);
    cloudPosY += cloudSpeed * floatcos(-cloudDirection, degrees);

    // Atualiza o tamanho da nuvem aleatoriamente
    cloudSize = random_float(CLOUD_MIN_SIZE, CLOUD_MAX_SIZE);

    // Calculate the coordinates for the gangzone
    new const Float:cloudWidth  = cloudSize * 2.0;
    new const Float:cloudHeight = cloudSize * 2.0;
    new const Float:cloudMinX   = cloudPosX - cloudWidth / 2.0;
    new const Float:cloudMaxX   = cloudPosX + cloudWidth / 2.0;
    new const Float:cloudMinY   = cloudPosY - cloudHeight / 2.0;
    new const Float:cloudMaxY   = cloudPosY + cloudHeight / 2.0;

    // Atualiza a posição e o tamanho da zona de gangue
    GangZoneDestroy(cloudGangZone);
    cloudGangZone = GangZoneCreate(cloudMinX, cloudMinY, cloudMaxX, cloudMaxY);
    GangZoneShowForAll(cloudGangZone, RADIATION_COLOR);

    // Cria/atualiza o objeto dummy na posição X e Y da nuvem
    new Float:groundZ;
    if(CA_FindZ_For2DCoord(cloudPosX, cloudPosY, groundZ)) {
        if(dummyObject == INVALID_OBJECT_ID) {
            dummyObject = CreateObject(1598, cloudPosX, cloudPosY, groundZ, 0.0, 0.0, 0.0); // Use the basketball object model (1598)
        } else {
            SetObjectPos(dummyObject, cloudPosX, cloudPosY, groundZ);
        }
    }

    // Verifica se a nuvem alcançou a borda oposta do mapa e reinicializa
    if((cloudPosX > 20000) || (cloudPosX < -20000) || (cloudPosY > 20000) || (cloudPosY < -20000)) {
        printf("[RADIATION] Nuvem bateu numa borda. Iniciando outra.");

        InitializeRadiationCloud();
    }
}

hook OnGameModeInit() {
    InitializeRadiationCloud();
}

static timer FollowCloud[100](playerid) {
    new Float:groundZ;

    if(CA_FindZ_For2DCoord(cloudPosX, cloudPosY, groundZ))
        SetPlayerPos(playerid, cloudPosX, cloudPosY, groundZ + 2.0); // Teleport the player 2.0 units above the ground to avoid falling through
}

static Timer:followTimer;

ACMD:gotorad[5](playerid) {
    static bool:follow;

    follow = !follow;

    if(follow) {
        FollowCloud(playerid);
        followTimer = repeat FollowCloud(playerid);
    } else
        stop followTimer;

    return 1;
}