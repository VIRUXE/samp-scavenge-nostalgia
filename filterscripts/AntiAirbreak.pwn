#include <a_samp>

/*==============================================================================

	Anti-Airbreak By Kolor4dO   (Pawn.RakNet + ColAndreas)

==============================================================================*/

#define FILTERSCRIPT

#undef 	MAX_PLAYERS
#define MAX_PLAYERS (40)

#include <ColAndreas>	// By Pottus:       https://github.com/Pottus/ColAndreas
#include <Pawn.RakNet>  // By urShadow:    	https://github.com/urShadow/Pawn.RakNet

bool:ab_Check[MAX_PLAYERS],
	ab_ChangePosTick[MAX_PLAYERS],
	Float:ab_SetX[MAX_PLAYERS],
	Float:ab_SetY[MAX_PLAYERS],
	Float:ab_SetZ[MAX_PLAYERS];

public OnFilterScriptInit() {
	// Pega a posição dos jogadores conectados
    for(new i = 0; i < MAX_PLAYERS; i++) if(IsPlayerConnected(i)) GetPlayerPos(i, ab_SetX[i], ab_SetY[i], ab_SetZ[i]);

	return 1;
}

public OnPlayerConnect(playerid) ab_Check[playerid] = false;

public OnIncomingPacket(playerid, packetid, BitStream:bs){
	// ONFOOT_SYNC
	if(packetid == 207) {
     	new data[PR_OnFootSync];
	    BS_IgnoreBits(bs, 8);
	    BS_ReadOnFootSync(bs, data);

	    return ab_PosCheck(playerid, data[PR_position][0], data[PR_position][1],data[PR_position][2]);
	}
	// DRIVER_SYNC
	else if(packetid == 200) { 
	    new data[PR_InCarSync];
		BS_IgnoreBits(bs, 8);
		BS_ReadInCarSync(bs, data);

		return ab_PosCheck(playerid, data[PR_position][0], data[PR_position][1],data[PR_position][2]);
	}
	// PASSENGER_SYNC
	else if(packetid == 211){
		new data[PR_PassengerSync];
	    BS_IgnoreBits(bs, 8);
	    BS_ReadPassengerSync(bs, data);

	    return ab_PosCheck(playerid, data[PR_position][0], data[PR_position][1],data[PR_position][2]);
	}

	return 1;
}

// Verifica a posição do jogador e compara com a antiga;
ab_PosCheck(playerid, Float:x, Float:y, Float:z)
{
	if(!IsPlayerConnected(playerid)) return 0;
	    
	if(ab_ChangePosTick[playerid] > gettime()) return 1;
	    
 	if(ab_SetX[playerid] == x && ab_SetY[playerid] == y && ab_SetZ[playerid] == z) return 1; // Se a posição for igual a antiga, segue

 	new
		Float:c,
		Float:ox,
		Float:oy,
		Float:oz,
		id;

	GetPlayerPos(playerid, ox, oy, oz);

	new Float:dist = GetPlayerDistanceFromPoint(playerid, ab_SetX[playerid], ab_SetY[playerid], ab_SetZ[playerid]);

	// Se a distância for maior que 10.0, ou se o jogador estiver em um veículo e a distância for maior que 40.0, ou se o jogador estiver em um veículo e a distância for diferente de 0.0, então o jogador está usando airbreak
	if( ((!IsPlayerInAnyVehicle(playerid) && dist > 10.0) || (IsPlayerInAnyVehicle(playerid) && dist > 40.0)) || (ab_Check[playerid] && dist != 0.0)) id = 10; 
	else
	{
		id = CA_RayCastLine(ox, oy, oz + 0.9, x, y, z + 0.9, c, c, c);

		if(!id)
		    id = CA_RayCastLine(ox + 0.25, oy, oz + 0.9, x - 0.25, y, z + 0.9, c, c, c);

		if(!id)
		    id = CA_RayCastLine(ox, oy + 0.25, oz + 0.9, x - 0.25, y, z + 0.9, c, c, c);
	}
	
	if(id && id != WATER_OBJECT){
		ClearAnimations(playerid);
	    SetPlayerVelocity(playerid, 0.0, 0.0, 0.0);
	    ab_Check[playerid] = true;
        
     	if(ab_SetZ[playerid] < 0.0){
	    	CA_FindZ_For2DCoord(ab_SetX[playerid], ab_SetY[playerid], ab_SetZ[playerid]);
	        ab_SetZ[playerid] += 0.5;
	    }

		// Set a posição "correta" para o jogador
     	new BitStream:bs = BS_New();
	    BS_WriteValue(bs,
	        PR_FLOAT, ab_SetX[playerid],
	        PR_FLOAT, ab_SetY[playerid],
	        PR_FLOAT, ab_SetZ[playerid]
	    );
	    PR_SendRPC(bs, playerid, 12); // RPC 12 = SetPlayerPos
	    BS_Delete(bs);
	    
	    return 0;
	}
	else if(ab_Check[playerid]) ab_Check[playerid] = false; 
	
	GetPlayerPos(playerid, ab_SetX[playerid], ab_SetY[playerid], ab_SetZ[playerid]);

	return 1;
}

//SetPlayerPos
ORPC:12(playerid, BitStream:bs){
	if(!IsPlayerConnected(playerid)) return 0;
	    
	BS_ReadValue(bs,
		PR_FLOAT, ab_SetX[playerid],
		PR_FLOAT, ab_SetY[playerid],
		PR_FLOAT, ab_SetZ[playerid]
	);
	
	ab_ChangePosTick[playerid] = 0;
	return 1;
}

// GiveTakeDamage
IRPC:115(playerid, BitStream:bs) return !ab_Check[playerid];

//SendSpawn
IRPC:52(playerid, BitStream:bs){
 	ab_ChangePosTick[playerid] = gettime() + 2;
	return 1;
}

//SendDeathNotification
IRPC:53(playerid, BitStream:bs){
 	ab_ChangePosTick[playerid] = gettime() + 2;
	return 1;
}