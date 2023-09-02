#include <a_samp>
#include <float>

/*==============================================================================

	Anti-Airbreak By Kolor4dO   (Pawn.RakNet + ColAndreas)

==============================================================================*/

#define FILTERSCRIPT

#include <ColAndreas>	// By Pottus:       https://github.com/Pottus/ColAndreas
#include <Pawn.RakNet>  // By urShadow:    	https://github.com/urShadow/Pawn.RakNet

new bool:Checking[MAX_PLAYERS],
	LastPositionCheck[MAX_PLAYERS],
	Float:LastX[MAX_PLAYERS],
	Float:LastY[MAX_PLAYERS],
	Float:LastZ[MAX_PLAYERS];

public OnFilterScriptInit() {
	// Pega a Posição dos jogadores conectados
    for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i)) GetPlayerPos(i, LastX[i], LastY[i], LastZ[i]);

	return 1;
}

public OnPlayerDisconnect(playerid) Checking[playerid] = false;

public OnIncomingPacket(playerid, packetid, BitStream:bs) {
	if(packetid == 207) { // ONFOOT_SYNC
     	new data[PR_OnFootSync];
	    BS_IgnoreBits(bs, 8);
	    BS_ReadOnFootSync(bs, data);

	    return PositionCheck(playerid, data[PR_position][0], data[PR_position][1], data[PR_position][2]);
	} else if(packetid == 200) { // DRIVER_SYNC
	    new data[PR_InCarSync];
		BS_IgnoreBits(bs, 8);
		BS_ReadInCarSync(bs, data);

		return PositionCheck(playerid, data[PR_position][0], data[PR_position][1], data[PR_position][2]);
	} else if(packetid == 211) { // PASSENGER_SYNC
		new data[PR_PassengerSync];
	    BS_IgnoreBits(bs, 8);
	    BS_ReadPassengerSync(bs, data);

	    return PositionCheck(playerid, data[PR_position][0], data[PR_position][1], data[PR_position][2]);
	}

	return 1;
}

// Verifica a Posição do jogador e compara com a antiga;
PositionCheck(playerid, Float:x, Float:y, Float:z) {
	if(!IsPlayerConnected(playerid)) return 0;

	if(
		GetPlayerVirtualWorld(playerid) != 0 ||
		LastPositionCheck[playerid] > gettime() ||
		LastX[playerid] == x && LastY[playerid] == y && LastZ[playerid] == z || // Se a Posição for igual a antiga, segue
		GetPlayerSkin(playerid) == 0 || GetPlayerSkin(playerid) == 217 || GetPlayerSkin(playerid) == 211 // Se a skin for CJ ou Staff, ignora
	) return 1;
	    
 	new
		Float:c,
		Float:playerX, Float:playerY, Float:playerZ, 
		objectHit;

	GetPlayerPos(playerid, playerX, playerY, playerZ);


	new Float:dist = floatsqroot((LastX[playerid] - playerX) * (LastX[playerid] - playerX) + (LastY[playerid] - playerY) * (LastY[playerid] - playerY) + (LastZ[playerid] - playerZ) * (LastZ[playerid] - playerZ));

	// Se a distância for maior que 10.0, ou se o jogador estiver em um Veículo e a distância for maior que 40.0, ou se o jogador estiver em um Veículo e a distância for diferente de 0.0, entÃ£o o jogador está usando airbreak
	if( ((!IsPlayerInAnyVehicle(playerid) && dist > 10.0) || (IsPlayerInAnyVehicle(playerid) && dist > 40.0)) || (Checking[playerid] && dist != 0.0)) 
		objectHit = 10; // ? why
	else {
		objectHit = CA_RayCastLine(playerX, playerY, playerZ + 0.9, x, y, z + 0.9, c, c, c);

		if(!objectHit) objectHit = CA_RayCastLine(playerX + 0.25, playerY, playerZ + 0.9, x - 0.25, y, z + 0.9, c, c, c);

		if(!objectHit) objectHit = CA_RayCastLine(playerX, playerY + 0.25, playerZ + 0.9, x - 0.25, y, z + 0.9, c, c, c);
	}

	if(objectHit && objectHit != WATER_OBJECT) {
		static oldObject[MAX_PLAYERS];

		if(objectHit != oldObject[playerid]) {
			new name[MAX_PLAYER_NAME + 1];
			GetPlayerName(playerid, name, sizeof(name));

			printf("\t[ANTI-AIRBREAK] %s (%d) atravessou o objeto: %d -> %.2f, %.2f, %.2f", name, playerid, objectHit, playerX, playerY, playerZ);

			oldObject[playerid] = objectHit;
		}

		ClearAnimations(playerid);
		
	    SetPlayerVelocity(playerid, 0.0, 0.0, 0.0);
	    Checking[playerid] = true;
        
     	if(LastZ[playerid] < 0.0) {
	    	CA_FindZ_For2DCoord(LastX[playerid], LastY[playerid], LastZ[playerid]);
	        LastZ[playerid] += 0.5;
	    }

		// Seta a Posição "correta" para o jogador
     	new BitStream:bs = BS_New();
	    BS_WriteValue(bs,
	        PR_FLOAT, LastX[playerid],
	        PR_FLOAT, LastY[playerid],
	        PR_FLOAT, LastZ[playerid]
	    );
	    PR_SendRPC(bs, playerid, 12); // RPC 12 = SetPlayerPos
	    BS_Delete(bs);
	    
	    return 0;
	} else if(Checking[playerid]) Checking[playerid] = false; 
	
	LastX[playerid] = playerX; LastY[playerid] = playerY; LastZ[playerid] = playerZ;

	return 1;
}

//SetPlayerPos
ORPC:12(playerid, BitStream:bs) {
	if(!IsPlayerConnected(playerid)) return 0;
	    
	BS_ReadValue(bs,
		PR_FLOAT, LastX[playerid],
		PR_FLOAT, LastY[playerid],
		PR_FLOAT, LastZ[playerid]
	);
	
	LastPositionCheck[playerid] = 0;
	return 1;
}

// GiveTakeDamage
IRPC:115(playerid, BitStream:bs) return !Checking[playerid];

//SendSpawn
IRPC:52(playerid, BitStream:bs) {
 	LastPositionCheck[playerid] = gettime() + 2;
	return 1;
}

//SendDeathNotification
IRPC:53(playerid, BitStream:bs) {
 	LastPositionCheck[playerid] = gettime() + 2;
	return 1;
}