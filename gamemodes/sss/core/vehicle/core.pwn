#include <YSI\y_hooks>

#define VEHICLE_HEALTH_CHUNK_1				300.0
#define VEHICLE_HEALTH_CHUNK_2				450.0
#define VEHICLE_HEALTH_CHUNK_3				650.0
#define VEHICLE_HEALTH_CHUNK_4				800.0
#define VEHICLE_HEALTH_MAX					990.0

#define VEHICLE_UI_INACTIVE					0xFF0000FF
#define VEHICLE_UI_ACTIVE					852308735

enum {
	VEHICLE_STATE_ALIVE,
	VEHICLE_STATE_DYING,
	VEHICLE_STATE_DEAD
}

enum E_VEHICLE_DATA {
	veh_type,
	Float:veh_health,
	Float:veh_Fuel,
	veh_key,
	veh_engine,
	veh_panels,
	veh_doors,
	veh_lights,
	veh_tires,
	veh_armour,
	veh_colour1,
	veh_colour2,
	Float:veh_spawnX,
	Float:veh_spawnY,
	Float:veh_spawnZ,
	Float:veh_spawnR,

	veh_lastUsed,
	veh_used,
	veh_occupied,
	veh_state,

	veh_geid[GEID_LEN]
}

enum E_VEHICLE_TOOLS {
	PlayerText:VEH_TOOL_WRENCH,
	PlayerText:VEH_TOOL_SCREWDRIVER,
	PlayerText:VEH_TOOL_HAMMER,
	PlayerText:VEH_TOOL_SPANNER
}

static
	veh_Data[MAX_VEHICLES][E_VEHICLE_DATA],
	veh_TypeCount[MAX_VEHICLE_TYPE],
	bool:veh_ShowingRepairStatus[MAX_PLAYERS]; // Para evitar que se esteja que se repita mostrar o ui de reparação

new
	Iterator:veh_Index<MAX_VEHICLES>;

static
PlayerText:	veh_FuelUI				[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText: veh_DmgUI				[MAX_PLAYERS][E_VEHICLE_TOOLS] = {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:	veh_EngineUI			[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:	veh_DoorsUI				[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:	veh_NameUI				[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:	veh_BarraUI				[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
PlayerText:	veh_SpeedUI				[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},

Float:		veh_TempHealth			[MAX_PLAYERS],
Float:		veh_TempVelocity		[MAX_PLAYERS],
			veh_Current				[MAX_PLAYERS],
			veh_Entering			[MAX_PLAYERS],
			veh_EnterTick			[MAX_PLAYERS],
			veh_ExitTick			[MAX_PLAYERS];

forward OnVehicleCreated(vehicleid);
forward OnVehicleDestroyed(vehicleid);
forward OnVehicleReset(oldid, newid);


hook OnPlayerConnect(playerid) {
	veh_NameUI[playerid] 			= CreatePlayerTextDraw(playerid, 319.799, 356.299, "HUNTLEY");
	PlayerTextDrawLetterSize		(playerid, veh_NameUI[playerid], 0.230, 1.299);
	PlayerTextDrawAlignment			(playerid, veh_NameUI[playerid], 2);
	PlayerTextDrawColor				(playerid, veh_NameUI[playerid], -1);
	PlayerTextDrawSetShadow			(playerid, veh_NameUI[playerid], 0);
	PlayerTextDrawSetOutline		(playerid, veh_NameUI[playerid], 1);
	PlayerTextDrawBackgroundColor	(playerid, veh_NameUI[playerid], 150);
	PlayerTextDrawFont				(playerid, veh_NameUI[playerid], 2);
	PlayerTextDrawSetProportional	(playerid, veh_NameUI[playerid], 1);

	veh_BarraUI[playerid]	 		= CreatePlayerTextDraw(playerid, 265.000, 375.000, "-");
	PlayerTextDrawLetterSize		(playerid, veh_BarraUI[playerid], 7.639, -0.500);
	PlayerTextDrawAlignment			(playerid, veh_BarraUI[playerid], 1);
	PlayerTextDrawColor				(playerid, veh_BarraUI[playerid], -2139062017);
	PlayerTextDrawSetShadow			(playerid, veh_BarraUI[playerid], 1);
	PlayerTextDrawSetOutline		(playerid, veh_BarraUI[playerid], 1);
	PlayerTextDrawBackgroundColor	(playerid, veh_BarraUI[playerid], 150);
	PlayerTextDrawFont				(playerid, veh_BarraUI[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, veh_BarraUI[playerid], 1);

	veh_SpeedUI[playerid]			=CreatePlayerTextDraw(playerid, 620.000000, 401.000000, "220km/h");
	PlayerTextDrawAlignment			(playerid, veh_SpeedUI[playerid], 3);
	PlayerTextDrawBackgroundColor	(playerid, veh_SpeedUI[playerid], 255);
	PlayerTextDrawFont				(playerid, veh_SpeedUI[playerid], 2);
	PlayerTextDrawLetterSize		(playerid, veh_SpeedUI[playerid], 0.250000, 1.599998);
	PlayerTextDrawColor				(playerid, veh_SpeedUI[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, veh_SpeedUI[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, veh_SpeedUI[playerid], 1);

	veh_FuelUI[playerid] 			= CreatePlayerTextDraw(playerid, 319.799, 417.299, "104.17L/104.17L");
	PlayerTextDrawLetterSize		(playerid, veh_FuelUI[playerid], 0.230, 1.299);
	PlayerTextDrawAlignment			(playerid, veh_FuelUI[playerid], 2);
	PlayerTextDrawColor				(playerid, veh_FuelUI[playerid], -1);
	PlayerTextDrawSetShadow			(playerid, veh_FuelUI[playerid], 0);
	PlayerTextDrawSetOutline		(playerid, veh_FuelUI[playerid], 1);
	PlayerTextDrawBackgroundColor	(playerid, veh_FuelUI[playerid], 150);
	PlayerTextDrawFont				(playerid, veh_FuelUI[playerid], 2);
	PlayerTextDrawSetProportional	(playerid, veh_FuelUI[playerid], 1);

	veh_DmgUI[playerid][VEH_TOOL_WRENCH] = CreatePlayerTextDraw(playerid, 246.500, 360.000, "_");
	PlayerTextDrawTextSize(playerid, veh_DmgUI[playerid][VEH_TOOL_WRENCH], 90.000, 90.000);
	PlayerTextDrawAlignment(playerid, veh_DmgUI[playerid][VEH_TOOL_WRENCH], 1);
	PlayerTextDrawColor(playerid, veh_DmgUI[playerid][VEH_TOOL_WRENCH], RED);
	PlayerTextDrawSetShadow(playerid, veh_DmgUI[playerid][VEH_TOOL_WRENCH], 0);
	PlayerTextDrawSetOutline(playerid, veh_DmgUI[playerid][VEH_TOOL_WRENCH], 0);
	PlayerTextDrawBackgroundColor(playerid, veh_DmgUI[playerid][VEH_TOOL_WRENCH], 0);
	PlayerTextDrawFont(playerid, veh_DmgUI[playerid][VEH_TOOL_WRENCH], 5);
	PlayerTextDrawSetProportional(playerid, veh_DmgUI[playerid][VEH_TOOL_WRENCH], 0);
	PlayerTextDrawSetPreviewModel(playerid, veh_DmgUI[playerid][VEH_TOOL_WRENCH], 18633);
	PlayerTextDrawSetPreviewRot(playerid, veh_DmgUI[playerid][VEH_TOOL_WRENCH], 0.000, 90.000, 90.000, 2.000);
	PlayerTextDrawSetPreviewVehCol(playerid, veh_DmgUI[playerid][VEH_TOOL_WRENCH], 0, 0);

	veh_DmgUI[playerid][VEH_TOOL_SCREWDRIVER] = CreatePlayerTextDraw(playerid, 266.500, 373.000, "_");
	PlayerTextDrawTextSize(playerid, veh_DmgUI[playerid][VEH_TOOL_SCREWDRIVER], 90.000, 90.000);
	PlayerTextDrawAlignment(playerid, veh_DmgUI[playerid][VEH_TOOL_SCREWDRIVER], 1);
	PlayerTextDrawColor(playerid, veh_DmgUI[playerid][VEH_TOOL_SCREWDRIVER], RED);
	PlayerTextDrawSetShadow(playerid, veh_DmgUI[playerid][VEH_TOOL_SCREWDRIVER], 0);
	PlayerTextDrawSetOutline(playerid, veh_DmgUI[playerid][VEH_TOOL_SCREWDRIVER], 0);
	PlayerTextDrawBackgroundColor(playerid, veh_DmgUI[playerid][VEH_TOOL_SCREWDRIVER], 0);
	PlayerTextDrawFont(playerid, veh_DmgUI[playerid][VEH_TOOL_SCREWDRIVER], 5);
	PlayerTextDrawSetProportional(playerid, veh_DmgUI[playerid][VEH_TOOL_SCREWDRIVER], 0);
	PlayerTextDrawSetPreviewModel(playerid, veh_DmgUI[playerid][VEH_TOOL_SCREWDRIVER], 18644);
	PlayerTextDrawSetPreviewRot(playerid, veh_DmgUI[playerid][VEH_TOOL_SCREWDRIVER], 0.000, 180.000, 4.000, 2.000);

	veh_DmgUI[playerid][VEH_TOOL_HAMMER] = CreatePlayerTextDraw(playerid, 274.500, 350.000, "_");
	PlayerTextDrawTextSize(playerid, veh_DmgUI[playerid][VEH_TOOL_HAMMER], 90.000, 90.000);
	PlayerTextDrawAlignment(playerid, veh_DmgUI[playerid][VEH_TOOL_HAMMER], 1);
	PlayerTextDrawColor(playerid, veh_DmgUI[playerid][VEH_TOOL_HAMMER], RED);
	PlayerTextDrawSetShadow(playerid, veh_DmgUI[playerid][VEH_TOOL_HAMMER], 0);
	PlayerTextDrawSetOutline(playerid, veh_DmgUI[playerid][VEH_TOOL_HAMMER], 0);
	PlayerTextDrawBackgroundColor(playerid, veh_DmgUI[playerid][VEH_TOOL_HAMMER], 0);
	PlayerTextDrawFont(playerid, veh_DmgUI[playerid][VEH_TOOL_HAMMER], 5);
	PlayerTextDrawSetProportional(playerid, veh_DmgUI[playerid][VEH_TOOL_HAMMER], 0);
	PlayerTextDrawSetPreviewModel(playerid, veh_DmgUI[playerid][VEH_TOOL_HAMMER], 18635);
	PlayerTextDrawSetPreviewRot(playerid, veh_DmgUI[playerid][VEH_TOOL_HAMMER], 0.000, -6.000, 180.000, 2.000);
	PlayerTextDrawSetPreviewVehCol(playerid, veh_DmgUI[playerid][VEH_TOOL_HAMMER], 0, 0);

	veh_DmgUI[playerid][VEH_TOOL_SPANNER] = CreatePlayerTextDraw(playerid, 300.500, 350.000, "_");
	PlayerTextDrawTextSize(playerid, veh_DmgUI[playerid][VEH_TOOL_SPANNER], 90.000, 90.000);
	PlayerTextDrawAlignment(playerid, veh_DmgUI[playerid][VEH_TOOL_SPANNER], 1);
	PlayerTextDrawColor(playerid, veh_DmgUI[playerid][VEH_TOOL_SPANNER], RED);
	PlayerTextDrawSetShadow(playerid, veh_DmgUI[playerid][VEH_TOOL_SPANNER], 0);
	PlayerTextDrawSetOutline(playerid, veh_DmgUI[playerid][VEH_TOOL_SPANNER], 0);
	PlayerTextDrawBackgroundColor(playerid, veh_DmgUI[playerid][VEH_TOOL_SPANNER], 0);
	PlayerTextDrawFont(playerid, veh_DmgUI[playerid][VEH_TOOL_SPANNER], 5);
	PlayerTextDrawSetProportional(playerid, veh_DmgUI[playerid][VEH_TOOL_SPANNER], 0);
	PlayerTextDrawSetPreviewModel(playerid, veh_DmgUI[playerid][VEH_TOOL_SPANNER], 19627);
	PlayerTextDrawSetPreviewRot(playerid, veh_DmgUI[playerid][VEH_TOOL_SPANNER], -90.000, -180.000, -90.000, 2.000);
	PlayerTextDrawSetPreviewVehCol(playerid, veh_DmgUI[playerid][VEH_TOOL_SPANNER], 0, 0);

	veh_EngineUI[playerid] 			= CreatePlayerTextDraw(playerid, 297.790, 432.000, "MOTOR");
	PlayerTextDrawLetterSize		(playerid, veh_EngineUI[playerid], 0.230, 1.299);
	PlayerTextDrawAlignment			(playerid, veh_EngineUI[playerid], 2);
	PlayerTextDrawColor				(playerid, veh_EngineUI[playerid], RED);
//	PlayerTextDrawColor				(playerid, veh_EngineUI[playerid], 852308735);
	PlayerTextDrawSetShadow			(playerid, veh_EngineUI[playerid], 0);
	PlayerTextDrawSetOutline		(playerid, veh_EngineUI[playerid], 1);
	PlayerTextDrawBackgroundColor	(playerid, veh_EngineUI[playerid], 150);
	PlayerTextDrawFont				(playerid, veh_EngineUI[playerid], 2);
	PlayerTextDrawSetProportional	(playerid, veh_EngineUI[playerid], 1);

	veh_DoorsUI[playerid] 			= CreatePlayerTextDraw(playerid, 338.790, 432.000, "PORTAS");
	PlayerTextDrawLetterSize		(playerid, veh_DoorsUI[playerid], 0.230, 1.299);
	PlayerTextDrawAlignment			(playerid, veh_DoorsUI[playerid], 2);
	PlayerTextDrawColor				(playerid, veh_DoorsUI[playerid], RED);
//	PlayerTextDrawColor				(playerid, veh_DoorsUI[playerid], 852308735);
	PlayerTextDrawSetShadow			(playerid, veh_DoorsUI[playerid], 0);
	PlayerTextDrawSetOutline		(playerid, veh_DoorsUI[playerid], 1);
	PlayerTextDrawBackgroundColor	(playerid, veh_DoorsUI[playerid], 150);
	PlayerTextDrawFont				(playerid, veh_DoorsUI[playerid], 2);
	PlayerTextDrawSetProportional	(playerid, veh_DoorsUI[playerid], 1);
}

/*SetPlayerVehicleSpeedUI(playerid, str[]) {
	PlayerTextDrawSetString(playerid, veh_SpeedUI[playerid], str);
}*/

stock CreateWorldVehicle(type, Float:x, Float:y, Float:z, Float:r, colour1, colour2, world = 0, geid[GEID_LEN] = "") {
	if(!(0 <= type < veh_TypeTotal)) return 0;

	// log("[CreateWorldVehicle] Creating vehicle of type %d model %d at %f, %f, %f", type, veh_TypeData[type][veh_modelId], x, y, z);

	new vehicleid = _veh_create(type, x, y, z, r, colour1, colour2, world, geid);

	veh_TypeCount[type]++;

	CallLocalFunction("OnVehicleCreated", "d", vehicleid);
	_veh_SyncData(vehicleid);

	return vehicleid;
}

stock DestroyWorldVehicle(vehicleid, bool:perma = false) {
	if(!IsValidVehicle(vehicleid)) return 0;

    veh_Data[vehicleid][veh_state] = VEHICLE_STATE_DEAD;
    
	CallLocalFunction("OnVehicleDestroyed", "d", vehicleid);
	
	Iter_Remove(veh_Index, vehicleid);
	
	if(perma) {
		log("[DestroyWorldVehicle] Permanently destroying vehicle %d", vehicleid);
		DestroyVehicle(vehicleid);
	} else
			{
		log("[DestroyWorldVehicle] Destroying vehicle %d", vehicleid);

		new Float:x, Float:y, Float:z;

		GetVehiclePos(vehicleid, x, y, z);

		SetVehicleExternalLock(vehicleid, E_LOCK_STATE_EXTERNAL);
		veh_Data[vehicleid][veh_key] = 0;

		if(!IsPosInWater(x, y, z - 1.0)) {
			CreateDynamicObject(18690, x, y, z - 2.0, 0.0, 0.0, 0.0);
			SetVehicleTrunkLock(vehicleid, true);
		} else 
			SetVehicleTrunkLock(vehicleid, false);
	}

	return 1;
}

stock ResetVehicle(vehicleid) {
	new
		type = GetVehicleType(vehicleid),
		tmp[E_VEHICLE_DATA],
		geid[GEID_LEN],
		newid;

	tmp = veh_Data[vehicleid];

	strcat(geid, veh_Data[vehicleid][veh_geid], GEID_LEN);

	DestroyVehicle(vehicleid);

	newid = _veh_create(type,
		veh_Data[vehicleid][veh_spawnX],
		veh_Data[vehicleid][veh_spawnY],
		veh_Data[vehicleid][veh_spawnZ],
		veh_Data[vehicleid][veh_spawnR],
		veh_Data[vehicleid][veh_colour1],
		veh_Data[vehicleid][veh_colour2],
		_,
		geid);

	log("[ResetVehicle] Resetting vehicle %d, new ID: %d", vehicleid, newid);

	CallLocalFunction("OnVehicleReset", "dd", vehicleid, newid);

	veh_Data[newid] = tmp;

	_veh_SyncData(newid);
	SetVehicleSpawnPoint(newid, veh_Data[newid][veh_spawnX], veh_Data[newid][veh_spawnY], veh_Data[newid][veh_spawnZ], veh_Data[newid][veh_spawnR]);
}

stock RespawnVehicle(vehicleid) {
	SetVehicleToRespawn(vehicleid);
	_veh_SyncData(vehicleid);
}

static bool:IsColourPink(index) {
	if (index < 0 || index >= 256) return false; // Return false if the index is out of range
    
	new const pink_indeces[15] = {5, 85, 126, 178, 220, 171, 232, 233, 136, 146, 176, 147, 167, 177, 237};

    for(new i = 0; i < sizeof(pink_indeces); i++) if (pink_indeces[i] == index) return true;
    
    return false;
}

static GetNonPinkColour() {
    new colour = random(256);

	while(IsColourPink(colour)) colour = random(256);

	return colour;
}

_veh_create(type, Float:x, Float:y, Float:z, Float:r, colour1, colour2, world = 0, geid[GEID_LEN] = "") {
	if(IsColourPink(colour1)) colour1 = GetNonPinkColour();

	new vehicleid = CreateVehicle(GetVehicleTypeModel(type), x, y, z, r, colour1, random(2) ? 157 : 133, 864000);

	if(!IsValidVehicle(vehicleid)) return 0;

	SetVehicleVirtualWorld(vehicleid, world);

	veh_Data[vehicleid][veh_type]		= type;
	veh_Data[vehicleid][veh_health]		= VEHICLE_HEALTH_MAX;
	veh_Data[vehicleid][veh_Fuel]		= 0.0;
	veh_Data[vehicleid][veh_key]		= 0;

	veh_Data[vehicleid][veh_engine]		= 0;
	veh_Data[vehicleid][veh_panels]		= 0;
	veh_Data[vehicleid][veh_doors]		= 0;
	veh_Data[vehicleid][veh_lights]		= 0;
	veh_Data[vehicleid][veh_tires]		= 0;

	veh_Data[vehicleid][veh_armour]		= 0;

	veh_Data[vehicleid][veh_colour1]	= colour1;
	veh_Data[vehicleid][veh_colour2]	= colour2;

	veh_Data[vehicleid][veh_spawnX]		= x;
	veh_Data[vehicleid][veh_spawnY]		= y;
	veh_Data[vehicleid][veh_spawnZ]		= z;
	veh_Data[vehicleid][veh_spawnR]		= r;

	veh_Data[vehicleid][veh_lastUsed]	= 0;
	veh_Data[vehicleid][veh_used]		= 0;
	veh_Data[vehicleid][veh_occupied]	= 0;
	veh_Data[vehicleid][veh_state]		= 0;

	if(isnull(geid)) 
		mkgeid(vehicleid, veh_Data[vehicleid][veh_geid]);
	else 
		strcat(veh_Data[vehicleid][veh_geid], geid, GEID_LEN);

	return vehicleid;
}

_veh_SyncData(vehicleid) {
	if(veh_Data[vehicleid][veh_health] > VEHICLE_HEALTH_MAX) veh_Data[vehicleid][veh_health] = VEHICLE_HEALTH_CHUNK_4;

	SetVehicleHealth(vehicleid, veh_Data[vehicleid][veh_health]);

	UpdateVehicleDamageStatus(vehicleid, veh_Data[vehicleid][veh_panels], veh_Data[vehicleid][veh_doors], veh_Data[vehicleid][veh_lights], veh_Data[vehicleid][veh_tires]);

	if(VEHICLE_CATEGORY_MOTORBIKE <= GetVehicleTypeCategory(GetVehicleType(vehicleid)) <= VEHICLE_CATEGORY_PUSHBIKE) 
		SetVehicleParamsEx(vehicleid, 1, 0, 0, 0, 0, 0, 0);
	else 
		SetVehicleParamsEx(vehicleid, 0, 0, 0, _:GetVehicleLockState(vehicleid), 0, 0, 0);

	return 1;
}

// Ligar e desligar motor/luzes de um veiculo
hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	if(IsPlayerKnockedOut(playerid)) return 0;

	if(IsPlayerInAnyVehicle(playerid)) {
		new vehicleid = GetPlayerVehicleID(playerid);

		if(newkeys & KEY_YES) {
			if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
				new
					Float:health,
					type = GetVehicleType(vehicleid);

				GetVehicleHealth(vehicleid, health);

				if(GetVehicleTypeMaxFuel(type) > 0.0)
					if(health >= 300.0)
						if(GetVehicleFuel(vehicleid) > 0.0) SetVehicleEngine(vehicleid, !GetVehicleEngine(vehicleid));
			}
		}

		if(newkeys & KEY_NO) VehicleLightsState(vehicleid, !VehicleLightsState(vehicleid));

		return 1;
	}

/*
	if(HOLDING(KEY_SPRINT) || PRESSED(KEY_SPRINT) || RELEASED(KEY_SPRINT)) {
		if(GetPlayerState(playerid) == PLAYER_STATE_ENTER_VEHICLE_DRIVER) {
			foreach(new i : Player) {
				if(i == playerid)
					continue;

				if(GetPlayerVehicleID(i) == veh_Entering[playerid])
					CancelPlayerMovement(playerid);
			}
		}
	}
*/
	return 1;
}

// Esconde o status de reparo do Ve�culo, após 3 segundos.
timer HideRepairStatus[SEC(3)](playerid) {
	// printf("HideRepairStatus(%d)", playerid);

	veh_ShowingRepairStatus[playerid] = false;

	// Esconde as textdraws veh_DmgUI
	PlayerTextDrawHide(playerid, veh_DmgUI[playerid][VEH_TOOL_WRENCH]);
	PlayerTextDrawHide(playerid, veh_DmgUI[playerid][VEH_TOOL_SCREWDRIVER]);
	PlayerTextDrawHide(playerid, veh_DmgUI[playerid][VEH_TOOL_HAMMER]);
	PlayerTextDrawHide(playerid, veh_DmgUI[playerid][VEH_TOOL_SPANNER]);
}

UpdateRepairStatus(playerid, vehicleid) {
	// Prepara as cores de acordo com o reparo necessário.
	new Float:health;

	GetVehicleHealth(vehicleid, health);

	// printf("UpdateRepairStatus(%d, %d) - Health: %.1f", playerid, vehicleid, health);

	/* 
		Chunk 1: 300.0 - Motor n�o liga mais
		Chunk 2: 450.0 - Menos do que isso, o motor vai falhar
		Chunk 3: 650.0
		Chunk 4: 800.0
		Max Health: 990.0
	 */
	PlayerTextDrawColor(playerid, veh_DmgUI[playerid][VEH_TOOL_WRENCH], 		health >= 448.0 ? -1 : 0xFF0000FF);
	PlayerTextDrawColor(playerid, veh_DmgUI[playerid][VEH_TOOL_SCREWDRIVER], 	health >= 648.0 ? -1 : 0xFF0000FF);
	PlayerTextDrawColor(playerid, veh_DmgUI[playerid][VEH_TOOL_HAMMER], 		health >= 798.0 ? -1 : 0xFF0000FF);
	PlayerTextDrawColor(playerid, veh_DmgUI[playerid][VEH_TOOL_SPANNER], 		health >= 988.0 ? -1 : 0xFF0000FF);
}

// Mostra o status de reparo do Ve�culo, durante 3 segundos.
ShowRepairStatus(playerid, vehicleid, bool:hide = true) {
	if(veh_ShowingRepairStatus[playerid]) return;

	// printf("ShowRepairStatus(%d, %d)", playerid, vehicleid);

	veh_ShowingRepairStatus[playerid] = true;

	UpdateRepairStatus(playerid, vehicleid);

	// Mostra as textdraws veh_DmgUI
	PlayerTextDrawShow(playerid, veh_DmgUI[playerid][VEH_TOOL_WRENCH]);
	PlayerTextDrawShow(playerid, veh_DmgUI[playerid][VEH_TOOL_SCREWDRIVER]);
	PlayerTextDrawShow(playerid, veh_DmgUI[playerid][VEH_TOOL_HAMMER]);
	PlayerTextDrawShow(playerid, veh_DmgUI[playerid][VEH_TOOL_SPANNER]);

	if(hide)
		defer HideRepairStatus(playerid); // Esconde o status de reparo do Ve�culo, após 3 segundos.
}

PlayerVehicleUpdate(playerid) {
	new
		vehicleid,
		vehicleType,
		Float:health,
//		Float:velocitychange,
		Float:maxfuel,
		Float:fuelcons,
		playerstate;

	vehicleid   = GetPlayerVehicleID(playerid);
	vehicleType = GetVehicleType(vehicleid);

	if(!IsValidVehicleType(vehicleType)) return;

	if(GetVehicleTypeCategory(vehicleType) == VEHICLE_CATEGORY_PUSHBIKE) return;

	GetVehicleHealth(vehicleid, health);
//	velocitychange = floatabs(veh_TempVelocity[playerid] - GetPlayerTotalVelocity(playerid));
	maxfuel     = GetVehicleTypeMaxFuel(vehicleType);
	fuelcons    = GetVehicleTypeFuelConsumption(vehicleType);
	playerstate = GetPlayerState(playerid);

	if(playerstate == PLAYER_STATE_DRIVER) {
		if(health > 300.0) {
			new Float:diff = veh_TempHealth[playerid] - health;

			if(diff > 10.0 && veh_TempHealth[playerid] < VEHICLE_HEALTH_MAX) {
				health += diff * 0.8;
				SetVehicleHealth(vehicleid, health);
			}
		}
		else SetVehicleHealth(vehicleid, 299.0);
	}

	// Faz o jogador sofrer dano de acordo com a velocidade do embate.
/* 	if(velocitychange > 70.0) {
		switch(GetVehicleTypeCategory(vehicleType)) {
			case VEHICLE_CATEGORY_HELICOPTER, VEHICLE_CATEGORY_PLANE:
				SetVehicleAngularVelocity(vehicleid, 0.0, 0.0, 1.0);

			default:
				PlayerInflictWound(INVALID_PLAYER_ID, playerid, E_WND_TYPE:1, velocitychange * 0.0001136, velocitychange * 0.00166, -1, BODY_PART_HEAD, "Collision");
		}
	} */

	if(maxfuel > 0.0) { // If the vehicle is a fuel powered vehicle
		// Se utiliza combustível então podemos mostrar o estado do motor (ferramentas).
		UpdateRepairStatus(playerid, vehicleid);

		new Float:fuel = GetVehicleFuel(vehicleid);

		if(fuel <= 0.0) {
			SetVehicleEngine(vehicleid, 0);
			PlayerTextDrawColor(playerid, veh_EngineUI[playerid], VEHICLE_UI_INACTIVE);
		}

		PlayerTextDrawSetString(playerid, veh_FuelUI[playerid], sprintf("%.2fL/%.2f", GetVehicleFuel(vehicleid), maxfuel));
		PlayerTextDrawShow(playerid, veh_FuelUI[playerid]);

		if(GetVehicleEngine(vehicleid)) {
			if(fuel > 0.0) fuel -= ((fuelcons / 100) * (((GetPlayerTotalVelocity(playerid)/60)/60)/10) + 0.0001);

			SetVehicleFuel(vehicleid, fuel);
			PlayerTextDrawColor(playerid, veh_EngineUI[playerid], VEHICLE_UI_ACTIVE);

			if(health <= VEHICLE_HEALTH_CHUNK_1) {
				SetVehicleEngine(vehicleid, 0);
				PlayerTextDrawColor(playerid, veh_EngineUI[playerid], VEHICLE_UI_INACTIVE);
			} else if(health <= VEHICLE_HEALTH_CHUNK_2 && GetPlayerTotalVelocity(playerid) > 1.0) {
				new Float:enginechance = (20 - ((health - VEHICLE_HEALTH_CHUNK_2) / 3));

				SetVehicleHealth(vehicleid, health - ((VEHICLE_HEALTH_CHUNK_1 - (health - VEHICLE_HEALTH_CHUNK_1)) / 1000.0));

				if(GetPlayerTotalVelocity(playerid) > 30.0) {
					if(random(100) < enginechance) {
						VehicleEngineState(vehicleid, 0);
						PlayerTextDrawColor(playerid, veh_EngineUI[playerid], VEHICLE_UI_INACTIVE);
					}
				} else {
					if(random(100) < 100 - enginechance) {
						VehicleEngineState(vehicleid, 1);
						PlayerTextDrawColor(playerid, veh_EngineUI[playerid], VEHICLE_UI_ACTIVE);
					}
				}
			}
		} else
			PlayerTextDrawColor(playerid, veh_EngineUI[playerid], VEHICLE_UI_INACTIVE);
	} else
		PlayerTextDrawHide(playerid, veh_FuelUI[playerid]);

	if(IsVehicleTypeLockable(vehicleType)) {
		PlayerTextDrawColor(playerid, veh_DoorsUI[playerid], VehicleDoorsState(vehicleid) ? VEHICLE_UI_INACTIVE : VEHICLE_UI_ACTIVE);

		PlayerTextDrawShow(playerid, veh_DoorsUI[playerid]);
	} else
		PlayerTextDrawHide(playerid, veh_DoorsUI[playerid]);

	PlayerTextDrawShow(playerid, veh_EngineUI[playerid]);

	if(IsBaseWeaponDriveby(GetPlayerWeapon(playerid))) {
		if(GetTickCountDifference(GetTickCount(), GetPlayerVehicleExitTick(playerid)) > 3000 && playerstate == PLAYER_STATE_DRIVER) 
			SetPlayerArmedWeapon(playerid, 0);
	}

	veh_TempVelocity[playerid] = GetPlayerTotalVelocity(playerid);
	veh_TempHealth[playerid]   = health;

	return;
}


hook OnPlayerStateChange(playerid, newstate, oldstate) {
	veh_TempHealth[playerid]   = 0.0;
	veh_TempVelocity[playerid] = 0.0;
	veh_Entering[playerid]     = -1;

	if(newstate == PLAYER_STATE_DRIVER) {
		new Float:x, Float:y, Float:z;

		veh_Current[playerid] = GetPlayerVehicleID(playerid);
		GetVehiclePos(veh_Current[playerid], x, y, z);

		if(GetVehicleTypeCategory(GetVehicleType(veh_Current[playerid])) == VEHICLE_CATEGORY_PUSHBIKE)
			SetVehicleEngine(veh_Current[playerid], 1);
		else
			VehicleEngineState(veh_Current[playerid], veh_Data[veh_Current[playerid]][veh_engine]);

		veh_Data[veh_Current[playerid]][veh_used]     = true;
		veh_Data[veh_Current[playerid]][veh_occupied] = true;

		ShowVehicleUI(playerid, veh_Current[playerid]);

		veh_EnterTick[playerid] = GetTickCount();

		log("[VEHICLE] %p entered %s (%d) as driver at %f, %f, %f", playerid, GetVehicleGEID(veh_Current[playerid]), veh_Current[playerid], x, y, z);
	} else if(newstate == PLAYER_STATE_PASSENGER) {
		new
			vehicleType,
			vehicleName[32],
			Float:x, Float:y, Float:z;

		veh_Current[playerid] = GetPlayerVehicleID(playerid);
		vehicleType           = GetVehicleType(veh_Current[playerid]);
		GetVehicleTypeName(vehicleType, vehicleName);
		GetVehiclePos(veh_Current[playerid], x, y, z);

		ShowVehicleUI(playerid, GetPlayerVehicleID(playerid));

		log("[VEHICLE] %p entered %s (%d) as passenger at %f, %f, %f", playerid, GetVehicleGEID(veh_Current[playerid]), veh_Current[playerid], x, y, z);
	}

	if(oldstate == PLAYER_STATE_DRIVER) {
		if(!IsValidVehicle(veh_Current[playerid])) {
			err("player state changed from vehicle but veh_Current is invalid", veh_Current[playerid]);
			return 0;
		}

		GetVehiclePos(veh_Current[playerid], veh_Data[veh_Current[playerid]][veh_spawnX], veh_Data[veh_Current[playerid]][veh_spawnY], veh_Data[veh_Current[playerid]][veh_spawnZ]);
		GetVehicleZAngle(veh_Current[playerid], veh_Data[veh_Current[playerid]][veh_spawnR]);

		veh_Data[veh_Current[playerid]][veh_occupied] = false;
		veh_Data[veh_Current[playerid]][veh_lastUsed] = GetTickCount();

		SetVehicleExternalLock(veh_Current[playerid], E_LOCK_STATE_OPEN);
		SetCameraBehindPlayer(playerid);
		HideVehicleUI(playerid);

		log("[VEHICLE] %p exited %s (%d) as driver at %f, %f, %f", playerid, GetVehicleGEID(veh_Current[playerid]), veh_Current[playerid], veh_Data[veh_Current[playerid]][veh_spawnX], veh_Data[veh_Current[playerid]][veh_spawnY], veh_Data[veh_Current[playerid]][veh_spawnZ]);
	} else if(oldstate == PLAYER_STATE_PASSENGER) {
		if(!IsValidVehicle(veh_Current[playerid])) {
			err("player state changed from vehicle but veh_Current is invalid", veh_Current[playerid]);
			return 0;
		}

		new
			vehicleType,
			vehicleName[32],
			Float:x, Float:y, Float:z;

		vehicleType = GetVehicleType(veh_Current[playerid]);
		GetVehicleTypeName(vehicleType, vehicleName);
		GetVehiclePos(veh_Current[playerid], x, y, z);

		SetVehicleExternalLock(GetPlayerLastVehicle(playerid), E_LOCK_STATE_OPEN);
		HideVehicleUI(playerid);
		log("[VEHICLE] %p exited %s (%d) as passenger at %f, %f, %f", playerid, GetVehicleGEID(veh_Current[playerid]), veh_Current[playerid], x, y, z);
	}

	return 1;
}

ShowVehicleUI(playerid, vehicleid) {
	new vehicleName[MAX_VEHICLE_TYPE_NAME];

	GetVehicleTypeName(GetVehicleType(vehicleid), vehicleName);

	PlayerTextDrawSetString(playerid, veh_NameUI[playerid], vehicleName);
	
//	PlayerTextDrawSetString(playerid, veh_DmgUI[playerid][VEH_TOOL_SPANNER], ls(playerid, "vehicle/hud/damage"));
    PlayerTextDrawSetString(playerid, veh_EngineUI[playerid], ls(playerid, "player/key-actions/vehicle/toggle_engine"));
    PlayerTextDrawSetString(playerid, veh_DoorsUI[playerid], ls(playerid, "player/key-actions/vehicle/toggle_doors"));
    
	PlayerTextDrawShow(playerid, veh_NameUI[playerid]);
	PlayerTextDrawShow(playerid, veh_BarraUI[playerid]);
	//PlayerTextDrawShow(playerid, veh_SpeedUI[playerid]);

	if(GetVehicleTypeCategory(GetVehicleType(vehicleid)) != VEHICLE_CATEGORY_PUSHBIKE) {
		ShowRepairStatus(playerid, vehicleid, false);

		PlayerTextDrawShow(playerid, veh_FuelUI[playerid]);
		PlayerTextDrawShow(playerid, veh_EngineUI[playerid]);
		PlayerTextDrawShow(playerid, veh_DoorsUI[playerid]);
		PlayerTextDrawShow(playerid, veh_BarraUI[playerid]);
	}
}

HideVehicleUI(playerid) {
	HideRepairStatus(playerid);

	PlayerTextDrawHide(playerid, veh_NameUI[playerid]);
	//PlayerTextDrawHide(playerid, veh_SpeedUI[playerid]);
	PlayerTextDrawHide(playerid, veh_FuelUI[playerid]);
	PlayerTextDrawHide(playerid, veh_EngineUI[playerid]);
	PlayerTextDrawHide(playerid, veh_DoorsUI[playerid]);
	PlayerTextDrawHide(playerid, veh_BarraUI[playerid]);
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger) {
	if(IsItemTypeCarry(ItemType:GetItemType(GetPlayerItem(playerid)))) PlayerDropItem(playerid);
	
	if(!ispassenger) veh_Entering[playerid] = vehicleid;

	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid) {
	veh_Data[vehicleid][veh_lastUsed] = GetTickCount();
	veh_ExitTick[playerid]            = GetTickCount();
}

public OnVehicleDamageStatusUpdate(vehicleid, playerid) {
	// TODO: Some anticheat magic before syncing.

	PlayerTextDrawShow(playerid, veh_DmgUI[playerid][VEH_TOOL_WRENCH]);
	PlayerTextDrawShow(playerid, veh_DmgUI[playerid][VEH_TOOL_SCREWDRIVER]);
	PlayerTextDrawShow(playerid, veh_DmgUI[playerid][VEH_TOOL_HAMMER]);
	PlayerTextDrawShow(playerid, veh_DmgUI[playerid][VEH_TOOL_SPANNER]);
	
	GetVehicleDamageStatus(vehicleid,
		veh_Data[vehicleid][veh_panels],
		veh_Data[vehicleid][veh_doors],
		veh_Data[vehicleid][veh_lights],
		veh_Data[vehicleid][veh_tires]
	);
}
/*
// Nao deixa veiculos desocupados se moverem
hook OnUnoccupiedVehicleUpd(vehicleid, playerid, passenger_seat, Float:new_x, Float:new_y, Float:new_z, Float:vel_x, Float:vel_y, Float:vel_z) {
	if(IsValidVehicle(GetTrailerVehicleID(vehicleid))) return Y_HOOKS_CONTINUE_RETURN_0;

	new
		Float:old_x,
		Float:old_y,
		Float:old_z,
		Float:old_r,
		Float:xydistance,
		Float:zdistance;

	GetVehiclePos(vehicleid, old_x, old_y, old_z);
	GetVehicleZAngle(vehicleid, old_r);
	xydistance = Distance2D(old_x, old_y, new_x, new_y);
	zdistance = floatabs(new_z - old_z);

	if(old_x * old_y * old_z == 0.0) return Y_HOOKS_CONTINUE_RETURN_0;

	if(xydistance > 0.01) {
		if(GetTickCountDifference(GetTickCount(), veh_Data[vehicleid][veh_lastUsed]) < 10000)
			return Y_HOOKS_CONTINUE_RETURN_0;

		new
			Float:xythresh = 0.25,
			Float:zthresh = 0.8;

		switch(GetVehicleTypeCategory(GetVehicleType(vehicleid))) {
			case VEHICLE_CATEGORY_TRUCK:
			{
				xythresh = 0.02;
				zthresh = 1.0;
			}

			case VEHICLE_CATEGORY_MOTORBIKE, VEHICLE_CATEGORY_PUSHBIKE:
			{
				xythresh = 0.5;
				zthresh = 0.5;
			}

			case VEHICLE_CATEGORY_BOAT:
			{
				xythresh = 2.5;
				zthresh = 3.6;
			}

			case VEHICLE_CATEGORY_HELICOPTER, VEHICLE_CATEGORY_PLANE:
			{
				xythresh = 0.01;
				zthresh = 0.5;
			}
		}

		if(xydistance > xythresh) {
			// log("xy: %f > %f = %d z: %f > %f = %d", xydistance, xythresh, xydistance > xythresh, zdistance, zthresh, zdistance > zthresh);
			SetVehiclePos(vehicleid, old_x, old_y, old_z);
			SetVehicleZAngle(vehicleid, old_r);
		}

		if(zdistance > zthresh) {
			// log("xy: %f > %f = %d z: %f > %f = %d", xydistance, xythresh, xydistance > xythresh, zdistance, zthresh, zdistance > zthresh);
			SetVehiclePos(vehicleid, new_x, new_y, old_z);
		}

		return Y_HOOKS_CONTINUE_RETURN_0;
	}

	return Y_HOOKS_CONTINUE_RETURN_1;
}
*/
IsVehicleValidOutOfBounds(vehicleid) {
	if(IsPosInWater(veh_Data[vehicleid][veh_spawnX], veh_Data[vehicleid][veh_spawnY], veh_Data[vehicleid][veh_spawnZ] - 5.0)) {
		switch(GetVehicleTypeCategory(GetVehicleType(vehicleid))) {
			case VEHICLE_CATEGORY_HELICOPTER, VEHICLE_CATEGORY_PLANE, VEHICLE_CATEGORY_BOAT: return 1;
			default: return 0;
		}
	}

	return 0;
}

/*
	Handling vehicle deaths:
	When a vehicle "dies" (reported by the client) it might be false. This hook
	aims to fix bugs with vehicle deaths and all code that's intended to run
	when a vehicle is destroyed should be put under OnVehicleDestroy(ed).
*/

public OnVehicleDeath(vehicleid, killerid) {
	GetVehiclePos(vehicleid, veh_Data[vehicleid][veh_spawnX], veh_Data[vehicleid][veh_spawnY], veh_Data[vehicleid][veh_spawnZ]);

	veh_Data[vehicleid][veh_state] = VEHICLE_STATE_DYING;

	DestroyVehicle(vehicleid);

	log("[VEHICLE][DEATH] %s (%d) killed by %p -> %f %f %f", GetVehicleGEID(vehicleid), vehicleid, killerid, veh_Data[vehicleid][veh_spawnX], veh_Data[vehicleid][veh_spawnY], veh_Data[vehicleid][veh_spawnZ]);
}

public OnVehicleSpawn(vehicleid) {
	if(veh_Data[vehicleid][veh_state] == VEHICLE_STATE_DYING) {
		if(IsVehicleValidOutOfBounds(vehicleid)) {
			log("[VEHICLE][DEATH] Dead Vehicle %s (%d) Spawned out of bounds - probably glitched vehicle death, respawning.", GetVehicleGEID(vehicleid), vehicleid);

			veh_Data[vehicleid][veh_state] = VEHICLE_STATE_ALIVE;
			ResetVehicle(vehicleid);
		} else {
			log("[VEHICLE][DEATH] Dead Vehicle %s (%d) Spawned, setting as inactive.", GetVehicleGEID(vehicleid), vehicleid);

			veh_Data[vehicleid][veh_health] = 300.0;
			ResetVehicle(vehicleid);

			DestroyWorldVehicle(vehicleid);
		}
	}

	return 1;
}

/*
	Hook for CreateVehicle, if the first parameter isn't a valid model ID but is
	a valid vehicle-type from this index, use the index create function instead.
*/
stock vti_CreateVehicle(vehicleType, Float:x, Float:y, Float:z, Float:rotation, color1, color2, respawn_delay) {
	#pragma unused vehicleType, x, y, z, rotation, color1, color2, respawn_delay
	err("Cannot create vehicle by model ID.");

	return 0;
}
#define _P p,_R<u>
#if defined _ALS_CreateVehicle
	#undef CreateVehicle
#else
	#define _ALS_CreateVehicle
#endif
#define CreateVehicle vti_CreateVehicle


/*==============================================================================

	Interface

==============================================================================*/


// veh_type
stock GetVehicleType(vehicleid) {
	if(!IsValidVehicle(vehicleid)) return INVALID_VEHICLE_TYPE;

	return veh_Data[vehicleid][veh_type];
}

// veh_health
stock Float:GetVehicleHP(vehicleid) {
	if(!IsValidVehicle(vehicleid)) return 0.0;

	return veh_Data[vehicleid][veh_health];
}

stock SetVehicleHP(vehicleid, Float:health) {
	if(!IsValidVehicle(vehicleid)) return 0;

	veh_Data[vehicleid][veh_health] = health;
	_veh_SyncData(vehicleid); // hotfix

	return 1;
}

// veh_Fuel
forward Float:GetVehicleFuel(vehicleid);
stock Float:GetVehicleFuel(vehicleid) {
	if(!IsValidVehicle(vehicleid)) return 0.0;

	if(veh_Data[vehicleid][veh_Fuel] < 0.0) veh_Data[vehicleid][veh_Fuel] = 0.0;

	return veh_Data[vehicleid][veh_Fuel];
}

stock SetVehicleFuel(vehicleid, Float:amount) {
	if(!IsValidVehicle(vehicleid)) return 0;

	new Float:maxfuel = GetVehicleTypeMaxFuel(GetVehicleType(vehicleid));

	if(amount > maxfuel) amount = maxfuel;

	veh_Data[vehicleid][veh_Fuel] = amount;

	return 1;
}

stock GiveVehicleFuel(vehicleid, Float:amount) {
	if(!IsValidVehicle(vehicleid)) return 0;

	new maxfuel = GetVehicleTypeMaxFuel(GetVehicleType(vehicleid));

	veh_Data[vehicleid][veh_Fuel] += amount;

	if(veh_Data[vehicleid][veh_Fuel] > maxfuel) veh_Data[vehicleid][veh_Fuel] = maxfuel;

	return 1;
}

// veh_key
stock GetVehicleKey(vehicleid) {
	if(!IsValidVehicle(vehicleid)) return -1;

	return veh_Data[vehicleid][veh_key];
}

stock SetVehicleKey(vehicleid, key) {
	if(!IsValidVehicle(vehicleid)) return 0;

	veh_Data[vehicleid][veh_key] = key;

	return 1;
}

// veh_engine
stock GetVehicleEngine(vehicleid) {
	if(!IsValidVehicle(vehicleid)) return 0;

	return veh_Data[vehicleid][veh_engine];
}

stock SetVehicleEngine(vehicleid, toggle) {
	if(!IsValidVehicle(vehicleid)) return 0;

	veh_Data[vehicleid][veh_engine] = toggle;
	VehicleEngineState(vehicleid, toggle);

	return 1;
}

// veh_panels
// veh_doors
// veh_lights
// veh_tires
stock SetVehicleDamageData(vehicleid, panels, doors, lights, tires) {
	if(!IsValidVehicle(vehicleid)) return 0;

	veh_Data[vehicleid][veh_panels] = panels;
	veh_Data[vehicleid][veh_doors]  = doors;
	veh_Data[vehicleid][veh_lights] = lights;
	veh_Data[vehicleid][veh_tires]  = tires;

	UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires);

	return 1;
}

// veh_armour

// veh_colour1
// veh_colour2
stock GetVehicleColours(vehicleid, &colour1, &colour2) {
	if(!IsValidVehicle(vehicleid)) return 0;

	colour1 = veh_Data[vehicleid][veh_colour1];
	colour2 = veh_Data[vehicleid][veh_colour2];

	return 1;
}

stock SetVehicleColours(vehicleid, colour1, colour2) {
	if(!IsValidVehicle(vehicleid)) return 0;

	veh_Data[vehicleid][veh_colour1] = colour1;
	veh_Data[vehicleid][veh_colour2] = colour2;

	return 1;
}

// veh_spawnX
// veh_spawnY
// veh_spawnZ
// veh_spawnR
stock SetVehicleSpawnPoint(vehicleid, Float:x, Float:y, Float:z, Float:r) {
	if(!IsValidVehicle(vehicleid)) return 0;

	veh_Data[vehicleid][veh_spawnX] = x;
	veh_Data[vehicleid][veh_spawnY] = y;
	veh_Data[vehicleid][veh_spawnZ] = z;
	veh_Data[vehicleid][veh_spawnR] = r;

	return 1;
}

stock GetVehicleSpawnPoint(vehicleid, &Float:x, &Float:y, &Float:z, &Float:r) {
	if(!IsValidVehicle(vehicleid)) return 0;

	x = veh_Data[vehicleid][veh_spawnX];
	y = veh_Data[vehicleid][veh_spawnY];
	z = veh_Data[vehicleid][veh_spawnZ];
	r = veh_Data[vehicleid][veh_spawnR];

	return 1;
}

// veh_lastUsed
stock GetVehicleLastUseTick(vehicleid) {
	if(!IsValidVehicle(vehicleid)) return 0;

	return veh_Data[vehicleid][veh_lastUsed];
}

// veh_used
stock IsVehicleUsed(vehicleid) {
	if(!IsValidVehicle(vehicleid)) return 0;

	return veh_Data[vehicleid][veh_used];
}

// veh_occupied
stock IsVehicleOccupied(vehicleid) {
	if(!IsValidVehicle(vehicleid)) return 0;

	return veh_Data[vehicleid][veh_occupied];
}


// veh_state
stock IsVehicleDead(vehicleid) {
	if(!IsValidVehicle(vehicleid)) return 0;

	return veh_Data[vehicleid][veh_state] == VEHICLE_STATE_DEAD;
}

// veh_geid
stock GetVehicleGEID(vehicleid) {
	new geid[GEID_LEN];

	if(!IsValidVehicle(vehicleid)) return geid;

	strcat(geid, veh_Data[vehicleid][veh_geid], GEID_LEN);

	return geid;
}

// veh_TypeCount
stock GetVehicleTypeCount(vehicleType) {
	if(!(0 <= vehicleType < veh_TypeTotal)) return 0;

	return veh_TypeCount[vehicleType];
}

// veh_Current
stock GetPlayerLastVehicle(playerid) {
	if(!IsPlayerConnected(playerid)) return 0;

	return veh_Current[playerid];
}

// veh_Entering
stock GetPlayerEnteringVehicle(playerid) {
	if(!IsPlayerConnected(playerid)) return 0;

	return veh_Entering[playerid];
}

// veh_EnterTick
stock GetPlayerVehicleEnterTick(playerid) {
	if(!IsPlayerConnected(playerid)) return 0;

	return veh_EnterTick[playerid];
}

// veh_ExitTick
stock GetPlayerVehicleExitTick(playerid) {
	if(!IsPlayerConnected(playerid)) return 0;

	return veh_ExitTick[playerid];
}

timer PutPlayerInVehicleTimed[750](playerId, vehicleId, seatId) {
	if(
		!IsPlayerConnected(playerId) ||
		!IsVehicleDead(vehicleId)
		) return 0;

	printf("[VEHICLE] PutPlayerInVehicleTimed(%d, %d, %d)", playerId, vehicleId, seatId);

	PutPlayerInVehicle(playerId, vehicleId, seatId);

	return 1;
}