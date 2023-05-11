#include <YSI\y_hooks>

#define VEHICLE_HEALTH_CHUNK_1				(300.0)
#define VEHICLE_HEALTH_CHUNK_2				(450.0)
#define VEHICLE_HEALTH_CHUNK_3				(650.0)
#define VEHICLE_HEALTH_CHUNK_4				(800.0)
#define VEHICLE_HEALTH_MAX					(990.0)

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

static const colours[256] = {
	// The existing colours from San Andreas
	0x000000FF, 0xF5F5F5FF, 0x2A77A1FF, 0x840410FF, 0x263739FF, 0x86446EFF, 0xD78E10FF, 0x4C75B7FF, 0xBDBEC6FF, 0x5E7072FF,
	0x46597AFF, 0x656A79FF, 0x5D7E8DFF, 0x58595AFF, 0xD6DAD6FF, 0x9CA1A3FF, 0x335F3FFF, 0x730E1AFF, 0x7B0A2AFF, 0x9F9D94FF,
	0x3B4E78FF, 0x732E3EFF, 0x691E3BFF, 0x96918CFF, 0x515459FF, 0x3F3E45FF, 0xA5A9A7FF, 0x635C5AFF, 0x3D4A68FF, 0x979592FF,
	0x421F21FF, 0x5F272BFF, 0x8494ABFF, 0x767B7CFF, 0x646464FF, 0x5A5752FF, 0x252527FF, 0x2D3A35FF, 0x93A396FF, 0x6D7A88FF,
	0x221918FF, 0x6F675FFF, 0x7C1C2AFF, 0x5F0A15FF, 0x193826FF, 0x5D1B20FF, 0x9D9872FF, 0x7A7560FF, 0x989586FF, 0xADB0B0FF,
	0x848988FF, 0x304F45FF, 0x4D6268FF, 0x162248FF, 0x272F4BFF, 0x7D6256FF, 0x9EA4ABFF, 0x9C8D71FF, 0x6D1822FF, 0x4E6881FF,
	0x9C9C98FF, 0x917347FF, 0x661C26FF, 0x949D9FFF, 0xA4A7A5FF, 0x8E8C46FF, 0x341A1EFF, 0x6A7A8CFF, 0xAAAD8EFF, 0xAB988FFF,
	0x851F2EFF, 0x6F8297FF, 0x585853FF, 0x9AA790FF, 0x601A23FF, 0x20202CFF, 0xA4A096FF, 0xAA9D84FF, 0x78222BFF, 0x0E316DFF,
	0x722A3FFF, 0x7B715EFF, 0x741D28FF, 0x1E2E32FF, 0x4D322FFF, 0x7C1B44FF, 0x2E5B20FF, 0x395A83FF, 0x6D2837FF, 0xA7A28FFF,
	0xAFB1B1FF, 0x364155FF, 0x6D6C6EFF, 0x0F6A89FF, 0x204B6BFF, 0x2B3E57FF, 0x9B9F9DFF, 0x6C8495FF, 0x4D8495FF, 0xAE9B7FFF,
	0x406C8FFF, 0x1F253BFF, 0xAB9276FF, 0x134573FF, 0x96816CFF, 0x64686AFF, 0x105082FF, 0xA19983FF, 0x385694FF, 0x525661FF,
	0x7F6956FF, 0x8C929AFF, 0x596E87FF, 0x473532FF, 0x44624FFF, 0x730A27FF, 0x223457FF, 0x640D1BFF, 0xA3ADC6FF, 0x695853FF,
	0x9B8B80FF, 0x620B1CFF, 0x5B5D5EFF, 0x624428FF, 0x731827FF, 0x1B376DFF, 0xEC6AAEFF, 0x000000FF,
	// SA-MP extended colours (0.3x)
	0x177517FF, 0x210606FF, 0x125478FF, 0x452A0DFF, 0x571E1EFF, 0x010701FF, 0x25225AFF, 0x2C89AAFF, 0x8A4DBDFF, 0x35963AFF,
	0xB7B7B7FF, 0x464C8DFF, 0x84888CFF, 0x817867FF, 0x817A26FF, 0x6A506FFF, 0x583E6FFF, 0x8CB972FF, 0x824F78FF, 0x6D276AFF,
	0x1E1D13FF, 0x1E1306FF, 0x1F2518FF, 0x2C4531FF, 0x1E4C99FF, 0x2E5F43FF, 0x1E9948FF, 0x1E9999FF, 0x999976FF, 0x7C8499FF,
	0x992E1EFF, 0x2C1E08FF, 0x142407FF, 0x993E4DFF, 0x1E4C99FF, 0x198181FF, 0x1A292AFF, 0x16616FFF, 0x1B6687FF, 0x6C3F99FF,
	0x481A0EFF, 0x7A7399FF, 0x746D99FF, 0x53387EFF, 0x222407FF, 0x3E190CFF, 0x46210EFF, 0x991E1EFF, 0x8D4C8DFF, 0x805B80FF,
	0x7B3E7EFF, 0x3C1737FF, 0x733517FF, 0x781818FF, 0x83341AFF, 0x8E2F1CFF, 0x7E3E53FF, 0x7C6D7CFF, 0x020C02FF, 0x072407FF,
	0x163012FF, 0x16301BFF, 0x642B4FFF, 0x368452FF, 0x999590FF, 0x818D96FF, 0x99991EFF, 0x7F994CFF, 0x839292FF, 0x788222FF,
	0x2B3C99FF, 0x3A3A0BFF, 0x8A794EFF, 0x0E1F49FF, 0x15371CFF, 0x15273AFF, 0x375775FF, 0x060820FF, 0x071326FF, 0x20394BFF,
	0x2C5089FF, 0x15426CFF, 0x103250FF, 0x241663FF, 0x692015FF, 0x8C8D94FF, 0x516013FF, 0x090F02FF, 0x8C573AFF, 0x52888EFF,
	0x995C52FF, 0x99581EFF, 0x993A63FF, 0x998F4EFF, 0x99311EFF, 0x0D1842FF, 0x521E1EFF, 0x42420DFF, 0x4C991EFF, 0x082A1DFF,
	0x96821DFF, 0x197F19FF, 0x3B141FFF, 0x745217FF, 0x893F8DFF, 0x7E1A6CFF, 0x0B370BFF, 0x27450DFF, 0x071F24FF, 0x784573FF,
	0x8A653AFF, 0x732617FF, 0x319490FF, 0x56941DFF, 0x59163DFF, 0x1B8A2FFF, 0x38160BFF, 0x041804FF, 0x355D8EFF, 0x2E3F5BFF,
	0x561A28FF, 0x4E0E27FF, 0x706C67FF, 0x3B3E42FF, 0x2E2D33FF, 0x7B7E7DFF, 0x4A4442FF, 0x28344EFF
};

forward OnVehicleCreated(vehicleid);
forward OnVehicleDestroyed(vehicleid);
forward OnVehicleReset(oldid, newid);


hook OnPlayerConnect(playerid)
{
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

/*SetPlayerVehicleSpeedUI(playerid, str[])
{
	PlayerTextDrawSetString(playerid, veh_SpeedUI[playerid], str);
}*/


/*==============================================================================

	Core

==============================================================================*/


stock CreateWorldVehicle(type, Float:x, Float:y, Float:z, Float:r, colour1, colour2, world = 0, geid[GEID_LEN] = "")
{
	if(!(0 <= type < veh_TypeTotal)) return 0;

	// log("[CreateWorldVehicle] Creating vehicle of type %d model %d at %f, %f, %f", type, veh_TypeData[type][veh_modelId], x, y, z);

	new vehicleid = _veh_create(type, x, y, z, r, colour1, colour2, world, geid);

	veh_TypeCount[type]++;

	CallLocalFunction("OnVehicleCreated", "d", vehicleid);
	_veh_SyncData(vehicleid);

	return vehicleid;
}

stock DestroyWorldVehicle(vehicleid, bool:perma = false)
{
	if(!IsValidVehicle(vehicleid)) return 0;

    veh_Data[vehicleid][veh_state] = VEHICLE_STATE_DEAD;
    
	CallLocalFunction("OnVehicleDestroyed", "d", vehicleid);
	
	Iter_Remove(veh_Index, vehicleid);
	
	if(perma)
	{
		log("[DestroyWorldVehicle] Permanently destroying vehicle %d", vehicleid);
		DestroyVehicle(vehicleid);
	}
	else
	{
		log("[DestroyWorldVehicle] Destroying vehicle %d", vehicleid);

		new Float:x, Float:y, Float:z;

		GetVehiclePos(vehicleid, x, y, z);

		SetVehicleExternalLock(vehicleid, E_LOCK_STATE_EXTERNAL);
		veh_Data[vehicleid][veh_key] = 0;

		if(!IsPosInWater(x, y, z - 1.0))
		{
			CreateDynamicObject(18690, x, y, z - 2.0, 0.0, 0.0, 0.0);
			SetVehicleTrunkLock(vehicleid, true);
		}
		else SetVehicleTrunkLock(vehicleid, false);
	}

	return 1;
}

stock ResetVehicle(vehicleid)
{
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

stock RespawnVehicle(vehicleid)
{
	SetVehicleToRespawn(vehicleid);
	_veh_SyncData(vehicleid);
}

static bool:IsColourPink(index) {
    if (index < 0 || index >= sizeof(colours)) return false; // Return false if the index is out of range
    
    new colour = colours[index];
    new r = (colour >> 24) & 0xFF, g = (colour >> 16) & 0xFF, b = (colour >> 8) & 0xFF;

    if (r > 200 && g < 150 && b < 150) return true;
    
    return false;
}

static GetNonPinkColour() {
    new indices[sizeof(colours)], count = 0;
    
    // Store indices of all non-pink colors
    for (new i = 0; i < sizeof(colours); i++) {
        if (!IsColourPink(i)) indices[count++] = i;
    }
    
    if (count) return indices[random(count)]; // Choose a random index from the non-pink colors
    
    return -1; // Return -1 if no non-pink color is found
}

_veh_create(type, Float:x, Float:y, Float:z, Float:r, colour1, colour2, world = 0, geid[GEID_LEN] = "") {
	if(IsColourPink(colour1)) colour1 = GetNonPinkColour();
	if(IsColourPink(colour2)) colour2 = GetNonPinkColour();

	new vehicleid = CreateVehicle(GetVehicleTypeModel(type), x, y, z, r, colour1, colour2, 864000);

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

	if(isnull(geid)) mkgeid(vehicleid, veh_Data[vehicleid][veh_geid]);
	else strcat(veh_Data[vehicleid][veh_geid], geid, GEID_LEN);

	return vehicleid;
}

_veh_SyncData(vehicleid)
{
	if(veh_Data[vehicleid][veh_health] > VEHICLE_HEALTH_MAX)
		veh_Data[vehicleid][veh_health] = VEHICLE_HEALTH_CHUNK_4;

	SetVehicleHealth(vehicleid, veh_Data[vehicleid][veh_health]);

	UpdateVehicleDamageStatus(vehicleid, veh_Data[vehicleid][veh_panels], veh_Data[vehicleid][veh_doors], veh_Data[vehicleid][veh_lights], veh_Data[vehicleid][veh_tires]);

	if(VEHICLE_CATEGORY_MOTORBIKE <= GetVehicleTypeCategory(GetVehicleType(vehicleid)) <= VEHICLE_CATEGORY_PUSHBIKE) SetVehicleParamsEx(vehicleid, 1, 0, 0, 0, 0, 0, 0);
	else SetVehicleParamsEx(vehicleid, 0, 0, 0, _:GetVehicleLockState(vehicleid), 0, 0, 0);

	return 1;
}


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsPlayerKnockedOut(playerid))
		return 0;

	if(IsPlayerInAnyVehicle(playerid))
	{
		new vehicleid = GetPlayerVehicleID(playerid);

		if(newkeys & KEY_YES)
		{
			if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
			{
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
	if(HOLDING(KEY_SPRINT) || PRESSED(KEY_SPRINT) || RELEASED(KEY_SPRINT))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_ENTER_VEHICLE_DRIVER)
		{
			foreach(new i : Player)
			{
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

// Esconde o status de reparo do veículo, após 3 segundos.
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
		Chunk 1: 300.0 - Motor não liga mais
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

// Mostra o status de reparo do veículo, durante 3 segundos.
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
		defer HideRepairStatus(playerid); // Esconde o status de reparo do veículo, após 3 segundos.
}

PlayerVehicleUpdate(playerid)
{
	new
		vehicleid,
		vehicletype,
		Float:health,
//		Float:velocitychange,
		Float:maxfuel,
		Float:fuelcons,
		playerstate;

	vehicleid   = GetPlayerVehicleID(playerid);
	vehicletype = GetVehicleType(vehicleid);

	if(!IsValidVehicleType(vehicletype)) return;

	if(GetVehicleTypeCategory(vehicletype) == VEHICLE_CATEGORY_PUSHBIKE) return;

	GetVehicleHealth(vehicleid, health);
//	velocitychange = floatabs(veh_TempVelocity[playerid] - GetPlayerTotalVelocity(playerid));
	maxfuel     = GetVehicleTypeMaxFuel(vehicletype);
	fuelcons    = GetVehicleTypeFuelConsumption(vehicletype);
	playerstate = GetPlayerState(playerid);

	if(playerstate == PLAYER_STATE_DRIVER)
	{
		if(health > 300.0)
		{
			new Float:diff = veh_TempHealth[playerid] - health;

			if(diff > 10.0 && veh_TempHealth[playerid] < VEHICLE_HEALTH_MAX)
			{
				health += diff * 0.8;
				SetVehicleHealth(vehicleid, health);
			}
		}
		else SetVehicleHealth(vehicleid, 299.0);
	}

	// Faz o jogador sofrer dano de acordo com a velocidade do embate.
/* 	if(velocitychange > 70.0)
	{
		switch(GetVehicleTypeCategory(vehicletype))
		{
			case VEHICLE_CATEGORY_HELICOPTER, VEHICLE_CATEGORY_PLANE:
				SetVehicleAngularVelocity(vehicleid, 0.0, 0.0, 1.0);

			default:
				PlayerInflictWound(INVALID_PLAYER_ID, playerid, E_WND_TYPE:1, velocitychange * 0.0001136, velocitychange * 0.00166, -1, BODY_PART_HEAD, "Collision");
		}
	} */

	if(maxfuel > 0.0) // If the vehicle is a fuel powered vehicle
	{
		new
			Float:fuel = GetVehicleFuel(vehicleid),
			str[18];
		
		// Se utiliza combustível então podemos mostrar o estado do motor (ferramentas).
		UpdateRepairStatus(playerid, vehicleid);

		if(fuel <= 0.0)
		{
			SetVehicleEngine(vehicleid, 0);
			PlayerTextDrawColor(playerid, veh_EngineUI[playerid], VEHICLE_UI_INACTIVE);
		}

		format(str, 18, "%.2fL/%.2f", GetVehicleFuel(vehicleid), maxfuel);
		PlayerTextDrawSetString(playerid, veh_FuelUI[playerid], str);
		PlayerTextDrawShow(playerid, veh_FuelUI[playerid]);

		if(GetVehicleEngine(vehicleid))
		{
			if(fuel > 0.0) fuel -= ((fuelcons / 100) * (((GetPlayerTotalVelocity(playerid)/60)/60)/10) + 0.0001);

			SetVehicleFuel(vehicleid, fuel);
			PlayerTextDrawColor(playerid, veh_EngineUI[playerid], VEHICLE_UI_ACTIVE);

			if(health <= VEHICLE_HEALTH_CHUNK_1)
			{
				SetVehicleEngine(vehicleid, 0);
				PlayerTextDrawColor(playerid, veh_EngineUI[playerid], VEHICLE_UI_INACTIVE);
			}
			else if(health <= VEHICLE_HEALTH_CHUNK_2 && GetPlayerTotalVelocity(playerid) > 1.0)
			{
				new Float:enginechance = (20 - ((health - VEHICLE_HEALTH_CHUNK_2) / 3));

				SetVehicleHealth(vehicleid, health - ((VEHICLE_HEALTH_CHUNK_1 - (health - VEHICLE_HEALTH_CHUNK_1)) / 1000.0));

				if(GetPlayerTotalVelocity(playerid) > 30.0)
				{
					if(random(100) < enginechance)
					{
						VehicleEngineState(vehicleid, 0);
						PlayerTextDrawColor(playerid, veh_EngineUI[playerid], VEHICLE_UI_INACTIVE);
					}
				}
				else
				{
					if(random(100) < 100 - enginechance)
					{
						VehicleEngineState(vehicleid, 1);
						PlayerTextDrawColor(playerid, veh_EngineUI[playerid], VEHICLE_UI_ACTIVE);
					}
				}
			}
		}
		else PlayerTextDrawColor(playerid, veh_EngineUI[playerid], VEHICLE_UI_INACTIVE);
	}
	else PlayerTextDrawHide(playerid, veh_FuelUI[playerid]);

	if(IsVehicleTypeLockable(vehicletype))
	{
		if(VehicleDoorsState(vehicleid)) PlayerTextDrawColor(playerid, veh_DoorsUI[playerid], VEHICLE_UI_ACTIVE);
		else PlayerTextDrawColor(playerid, veh_DoorsUI[playerid], VEHICLE_UI_INACTIVE);

		PlayerTextDrawShow(playerid, veh_DoorsUI[playerid]);
	}
	else PlayerTextDrawHide(playerid, veh_DoorsUI[playerid]);

	PlayerTextDrawShow(playerid, veh_EngineUI[playerid]);

	if(IsBaseWeaponDriveby(GetPlayerWeapon(playerid)))
	{
		if(GetTickCountDifference(GetTickCount(), GetPlayerVehicleExitTick(playerid)) > 3000 && playerstate == PLAYER_STATE_DRIVER) SetPlayerArmedWeapon(playerid, 0);
	}

	veh_TempVelocity[playerid] = GetPlayerTotalVelocity(playerid);
	veh_TempHealth[playerid]   = health;

	return;
}


hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	veh_TempHealth[playerid] = 0.0;
	veh_TempVelocity[playerid] = 0.0;
	veh_Entering[playerid] = -1;

	if(newstate == PLAYER_STATE_DRIVER)
	{
		new Float:x, Float:y, Float:z;

		veh_Current[playerid] = GetPlayerVehicleID(playerid);
		GetVehiclePos(veh_Current[playerid], x, y, z);

		if(GetVehicleTypeCategory(GetVehicleType(veh_Current[playerid])) == VEHICLE_CATEGORY_PUSHBIKE)
			SetVehicleEngine(veh_Current[playerid], 1);
		else
			VehicleEngineState(veh_Current[playerid], veh_Data[veh_Current[playerid]][veh_engine]);

		veh_Data[veh_Current[playerid]][veh_used] = true;
		veh_Data[veh_Current[playerid]][veh_occupied] = true;

		ShowVehicleUI(playerid, veh_Current[playerid]);

		veh_EnterTick[playerid] = GetTickCount();

		log("[VEHICLE] %p entered %s (%d) as driver at %f, %f, %f", playerid, GetVehicleGEID(veh_Current[playerid]), veh_Current[playerid], x, y, z);
	} else if(newstate == PLAYER_STATE_PASSENGER) {
		new
			
			vehicletype,
			vehiclename[32],
			Float:x,
			Float:y,
			Float:z;

		veh_Current[playerid] = GetPlayerVehicleID(playerid);
		vehicletype = GetVehicleType(veh_Current[playerid]);
		GetVehicleTypeName(vehicletype, vehiclename);
		GetVehiclePos(veh_Current[playerid], x, y, z);

		ShowVehicleUI(playerid, GetPlayerVehicleID(playerid));

		log("[VEHICLE] %p entered %s (%d) as passenger at %f, %f, %f", playerid, GetVehicleGEID(veh_Current[playerid]), veh_Current[playerid], x, y, z);
	}

	if(oldstate == PLAYER_STATE_DRIVER)
	{
		if(!IsValidVehicle(veh_Current[playerid]))
		{
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
		if(!IsValidVehicle(veh_Current[playerid]))
		{
			err("player state changed from vehicle but veh_Current is invalid", veh_Current[playerid]);
			return 0;
		}

		new
			vehicletype,
			vehiclename[32],
			Float:x,
			Float:y,
			Float:z;

		vehicletype = GetVehicleType(veh_Current[playerid]);
		GetVehicleTypeName(vehicletype, vehiclename);
		GetVehiclePos(veh_Current[playerid], x, y, z);

		SetVehicleExternalLock(GetPlayerLastVehicle(playerid), E_LOCK_STATE_OPEN);
		HideVehicleUI(playerid);
		log("[VEHICLE] %p exited %s (%d) as passenger at %f, %f, %f", playerid, GetVehicleGEID(veh_Current[playerid]), veh_Current[playerid], x, y, z);
	}

	return 1;
}

ShowVehicleUI(playerid, vehicleid)
{
	new vehiclename[MAX_VEHICLE_TYPE_NAME];

	GetVehicleTypeName(GetVehicleType(vehicleid), vehiclename);

	PlayerTextDrawSetString(playerid, veh_NameUI[playerid], vehiclename);
	
//	PlayerTextDrawSetString(playerid, veh_DmgUI[playerid][VEH_TOOL_SPANNER], ls(playerid, "vehicle/hud/damage"));
    PlayerTextDrawSetString(playerid, veh_EngineUI[playerid], ls(playerid, "player/key-actions/vehicle/toggle_engine"));
    PlayerTextDrawSetString(playerid, veh_DoorsUI[playerid], ls(playerid, "player/key-actions/vehicle/toggle_doors"));
    
	PlayerTextDrawShow(playerid, veh_NameUI[playerid]);
	PlayerTextDrawShow(playerid, veh_BarraUI[playerid]);
	//PlayerTextDrawShow(playerid, veh_SpeedUI[playerid]);

	if(GetVehicleTypeCategory(GetVehicleType(vehicleid)) != VEHICLE_CATEGORY_PUSHBIKE)
	{
		ShowRepairStatus(playerid, vehicleid, false);

		PlayerTextDrawShow(playerid, veh_FuelUI[playerid]);
		PlayerTextDrawShow(playerid, veh_EngineUI[playerid]);
		PlayerTextDrawShow(playerid, veh_DoorsUI[playerid]);
		PlayerTextDrawShow(playerid, veh_BarraUI[playerid]);
	}
}

HideVehicleUI(playerid)
{
	HideRepairStatus(playerid);

	PlayerTextDrawHide(playerid, veh_NameUI[playerid]);
	//PlayerTextDrawHide(playerid, veh_SpeedUI[playerid]);
	PlayerTextDrawHide(playerid, veh_FuelUI[playerid]);
	PlayerTextDrawHide(playerid, veh_EngineUI[playerid]);
	PlayerTextDrawHide(playerid, veh_DoorsUI[playerid]);
	PlayerTextDrawHide(playerid, veh_BarraUI[playerid]);
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	if(IsItemTypeCarry(ItemType:GetItemType(GetPlayerItem(playerid)))) PlayerDropItem(playerid);
	
	if(!ispassenger) veh_Entering[playerid] = vehicleid;

	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	veh_Data[vehicleid][veh_lastUsed] = GetTickCount();
	veh_ExitTick[playerid] = GetTickCount();
}

public OnVehicleDamageStatusUpdate(vehicleid, playerid)
{
	// TODO: Some anticheat magic before syncing.

	PlayerTextDrawShow(playerid, veh_DmgUI[playerid][VEH_TOOL_WRENCH]);
	PlayerTextDrawShow(playerid, veh_DmgUI[playerid][VEH_TOOL_SCREWDRIVER]);
	PlayerTextDrawShow(playerid, veh_DmgUI[playerid][VEH_TOOL_HAMMER]);
	PlayerTextDrawShow(playerid, veh_DmgUI[playerid][VEH_TOOL_SPANNER]);
	
	GetVehicleDamageStatus(vehicleid,
		veh_Data[vehicleid][veh_panels],
		veh_Data[vehicleid][veh_doors],
		veh_Data[vehicleid][veh_lights],
		veh_Data[vehicleid][veh_tires]);
}
/*
hook OnUnoccupiedVehicleUpd(vehicleid, playerid, passenger_seat, Float:new_x, Float:new_y, Float:new_z, Float:vel_x, Float:vel_y, Float:vel_z)
{
	if(IsValidVehicle(GetTrailerVehicleID(vehicleid)))
		return Y_HOOKS_CONTINUE_RETURN_0;

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

	if(old_x * old_y * old_z == 0.0)
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(xydistance > 0.01)
	{
		if(GetTickCountDifference(GetTickCount(), veh_Data[vehicleid][veh_lastUsed]) < 10000)
			return Y_HOOKS_CONTINUE_RETURN_0;

		new
			Float:xythresh = 0.25,
			Float:zthresh = 0.8;

		switch(GetVehicleTypeCategory(GetVehicleType(vehicleid)))
		{
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

		if(xydistance > xythresh)
		{
			// log("xy: %f > %f = %d z: %f > %f = %d", xydistance, xythresh, xydistance > xythresh, zdistance, zthresh, zdistance > zthresh);
			SetVehiclePos(vehicleid, old_x, old_y, old_z);
			SetVehicleZAngle(vehicleid, old_r);
		}

		if(zdistance > zthresh)
		{
			// log("xy: %f > %f = %d z: %f > %f = %d", xydistance, xythresh, xydistance > xythresh, zdistance, zthresh, zdistance > zthresh);
			SetVehiclePos(vehicleid, new_x, new_y, old_z);
		}

		return Y_HOOKS_CONTINUE_RETURN_0;
	}

	return Y_HOOKS_CONTINUE_RETURN_1;
}
*/
IsVehicleValidOutOfBounds(vehicleid)
{
	if(IsPosInWater(veh_Data[vehicleid][veh_spawnX], veh_Data[vehicleid][veh_spawnY], veh_Data[vehicleid][veh_spawnZ] - 5.0))
	{
		switch(GetVehicleTypeCategory(GetVehicleType(vehicleid)))
		{
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

public OnVehicleDeath(vehicleid, killerid)
{
	GetVehiclePos(vehicleid, veh_Data[vehicleid][veh_spawnX], veh_Data[vehicleid][veh_spawnY], veh_Data[vehicleid][veh_spawnZ]);

	veh_Data[vehicleid][veh_state] = VEHICLE_STATE_DYING;

/*	DestroyVehicle(vehicleid);
	ChatMsgAll(YELLOW, "> %p(id:%d) destrui�u o ve�culo ID: %d", killerid, killerid, vehicleid);*/
	log("[VEHICLE][DEATH] %s (%d) killed by %p -> %f %f %f", GetVehicleGEID(vehicleid), vehicleid, killerid, veh_Data[vehicleid][veh_spawnX], veh_Data[vehicleid][veh_spawnY], veh_Data[vehicleid][veh_spawnZ]);
}

public OnVehicleSpawn(vehicleid)
{
	if(veh_Data[vehicleid][veh_state] == VEHICLE_STATE_DYING)
	{
		if(IsVehicleValidOutOfBounds(vehicleid))
		{
			log("[VEHICLE][DEATH] Dead Vehicle %s (%d) Spawned out of bounds - probably glitched vehicle death, respawning.", GetVehicleGEID(vehicleid), vehicleid);

			veh_Data[vehicleid][veh_state] = VEHICLE_STATE_ALIVE;
			ResetVehicle(vehicleid);
		}
		else
		{
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
stock vti_CreateVehicle(vehicletype, Float:x, Float:y, Float:z, Float:rotation, color1, color2, respawn_delay)
{
	#pragma unused vehicletype, x, y, z, rotation, color1, color2, respawn_delay
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
stock GetVehicleType(vehicleid)
{
	if(!IsValidVehicle(vehicleid)) return INVALID_VEHICLE_TYPE;

	return veh_Data[vehicleid][veh_type];
}

// veh_health
stock Float:GetVehicleHP(vehicleid)
{
	if(!IsValidVehicle(vehicleid)) return 0.0;

	return veh_Data[vehicleid][veh_health];
}

stock SetVehicleHP(vehicleid, Float:health)
{
	if(!IsValidVehicle(vehicleid)) return 0;

	veh_Data[vehicleid][veh_health] = health;
	_veh_SyncData(vehicleid); // hotfix

	return 1;
}

// veh_Fuel
forward Float:GetVehicleFuel(vehicleid);
stock Float:GetVehicleFuel(vehicleid)
{
	if(!IsValidVehicle(vehicleid)) return 0.0;

	if(veh_Data[vehicleid][veh_Fuel] < 0.0) veh_Data[vehicleid][veh_Fuel] = 0.0;

	return veh_Data[vehicleid][veh_Fuel];
}

stock SetVehicleFuel(vehicleid, Float:amount)
{
	if(!IsValidVehicle(vehicleid)) return 0;

	new Float:maxfuel = GetVehicleTypeMaxFuel(GetVehicleType(vehicleid));

	if(amount > maxfuel) amount = maxfuel;

	veh_Data[vehicleid][veh_Fuel] = amount;

	return 1;
}

stock GiveVehicleFuel(vehicleid, Float:amount)
{
	if(!IsValidVehicle(vehicleid)) return 0;

	new maxfuel = GetVehicleTypeMaxFuel(GetVehicleType(vehicleid));

	veh_Data[vehicleid][veh_Fuel] += amount;

	if(veh_Data[vehicleid][veh_Fuel] > maxfuel) veh_Data[vehicleid][veh_Fuel] = maxfuel;

	return 1;
}

// veh_key
stock GetVehicleKey(vehicleid)
{
	if(!IsValidVehicle(vehicleid)) return -1;

	return veh_Data[vehicleid][veh_key];
}

stock SetVehicleKey(vehicleid, key)
{
	if(!IsValidVehicle(vehicleid)) return 0;

	veh_Data[vehicleid][veh_key] = key;

	return 1;
}

// veh_engine
stock GetVehicleEngine(vehicleid)
{
	if(!IsValidVehicle(vehicleid)) return 0;

	return veh_Data[vehicleid][veh_engine];
}

stock SetVehicleEngine(vehicleid, toggle)
{
	if(!IsValidVehicle(vehicleid)) return 0;

	veh_Data[vehicleid][veh_engine] = toggle;
	VehicleEngineState(vehicleid, toggle);

	return 1;
}

// veh_panels
// veh_doors
// veh_lights
// veh_tires
stock SetVehicleDamageData(vehicleid, panels, doors, lights, tires)
{
	if(!IsValidVehicle(vehicleid)) return 0;

	veh_Data[vehicleid][veh_panels] = panels;
	veh_Data[vehicleid][veh_doors] = doors;
	veh_Data[vehicleid][veh_lights] = lights;
	veh_Data[vehicleid][veh_tires] = tires;

	UpdateVehicleDamageStatus(vehicleid, panels, doors, lights, tires);

	return 1;
}

// veh_armour

// veh_colour1
// veh_colour2
stock GetVehicleColours(vehicleid, &colour1, &colour2)
{
	if(!IsValidVehicle(vehicleid)) return 0;

	colour1 = veh_Data[vehicleid][veh_colour1];
	colour2 = veh_Data[vehicleid][veh_colour2];

	return 1;
}

stock SetVehicleColours(vehicleid, colour1, colour2)
{
	if(!IsValidVehicle(vehicleid)) return 0;

	veh_Data[vehicleid][veh_colour1] = colour1;
	veh_Data[vehicleid][veh_colour2] = colour2;

	return 1;
}

// veh_spawnX
// veh_spawnY
// veh_spawnZ
// veh_spawnR
stock SetVehicleSpawnPoint(vehicleid, Float:x, Float:y, Float:z, Float:r)
{
	if(!IsValidVehicle(vehicleid)) return 0;

	veh_Data[vehicleid][veh_spawnX] = x;
	veh_Data[vehicleid][veh_spawnY] = y;
	veh_Data[vehicleid][veh_spawnZ] = z;
	veh_Data[vehicleid][veh_spawnR] = r;

	return 1;
}

stock GetVehicleSpawnPoint(vehicleid, &Float:x, &Float:y, &Float:z, &Float:r)
{
	if(!IsValidVehicle(vehicleid)) return 0;

	x = veh_Data[vehicleid][veh_spawnX];
	y = veh_Data[vehicleid][veh_spawnY];
	z = veh_Data[vehicleid][veh_spawnZ];
	r = veh_Data[vehicleid][veh_spawnR];

	return 1;
}

// veh_lastUsed
stock GetVehicleLastUseTick(vehicleid)
{
	if(!IsValidVehicle(vehicleid)) return 0;

	return veh_Data[vehicleid][veh_lastUsed];
}

// veh_used
stock IsVehicleUsed(vehicleid)
{
	if(!IsValidVehicle(vehicleid)) return 0;

	return veh_Data[vehicleid][veh_used];
}

// veh_occupied
stock IsVehicleOccupied(vehicleid)
{
	if(!IsValidVehicle(vehicleid)) return 0;

	return veh_Data[vehicleid][veh_occupied];
}


// veh_state
stock IsVehicleDead(vehicleid)
{
	if(!IsValidVehicle(vehicleid)) return 0;

	return veh_Data[vehicleid][veh_state] == VEHICLE_STATE_DEAD;
}

// veh_geid
stock GetVehicleGEID(vehicleid)
{
	new geid[GEID_LEN];

	if(!IsValidVehicle(vehicleid)) return geid;

	strcat(geid, veh_Data[vehicleid][veh_geid], GEID_LEN);

	return geid;
}

// veh_TypeCount
stock GetVehicleTypeCount(vehicletype)
{
	if(!(0 <= vehicletype < veh_TypeTotal)) return 0;

	return veh_TypeCount[vehicletype];
}

// veh_Current
stock GetPlayerLastVehicle(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;

	return veh_Current[playerid];
}

// veh_Entering
stock GetPlayerEnteringVehicle(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;

	return veh_Entering[playerid];
}

// veh_EnterTick
stock GetPlayerVehicleEnterTick(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;

	return veh_EnterTick[playerid];
}

// veh_ExitTick
stock GetPlayerVehicleExitTick(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;

	return veh_ExitTick[playerid];
}