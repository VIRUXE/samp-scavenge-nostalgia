#include <a_samp>

#undef MAX_PLAYERS
#define MAX_PLAYERS (40)

#define FILTERSCRIPT

#include <a_samp>
#include <Pawn.RakNet>
#include <ColAndreas>
#include <YSI\y_timers>

new Timer:PlayerCheckViewVeh[MAX_PLAYERS][MAX_VEHICLES];

// WorldVehicleAdd
ORPC:164(playerid, BitStream:bs)
{
    if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
        return 1;

	new vehicleid, ModelID,
		Float:X, Float:Y, Float:Z, Float:Angle,
		InteriorColor1, InteriorColor2, Float:Health,
		interior, DoorDamageStatus, PanelDamageStatus,
		LightDamageStatus, tireDamageStatus, addsiren,
		modslot0, modslot1, modslot2, modslot3,
		modslot4, modslot5, modslot6, modslot7,
		modslot8, modslot9, modslot10, modslot11,
		modslot12, modslot13, modslot14, PaintJob, BodyColor1, BodyColor2;

    BS_ReadValue(bs,
		PR_UINT16, vehicleid,
		PR_UINT32, ModelID,
		PR_FLOAT, X,
		PR_FLOAT, Y,
		PR_FLOAT, Z,
		PR_FLOAT, Angle,
		PR_UINT8, InteriorColor1,
		PR_UINT8, InteriorColor2,
		PR_FLOAT, Health,
		PR_UINT32, interior,
		PR_UINT32, DoorDamageStatus,
		PR_UINT32, PanelDamageStatus,
		PR_UINT8, LightDamageStatus,
		PR_UINT8, tireDamageStatus,
		PR_UINT8, addsiren,
		PR_UINT8, modslot0,
		PR_UINT8, modslot1,
		PR_UINT8, modslot2,
		PR_UINT8, modslot3,
		PR_UINT8, modslot4,
		PR_UINT8, modslot5,
		PR_UINT8, modslot6,
		PR_UINT8, modslot7,
		PR_UINT8, modslot8,
		PR_UINT8, modslot9,
		PR_UINT8, modslot10,
		PR_UINT8, modslot11,
		PR_UINT8, modslot12,
		PR_UINT8, modslot13,
		PR_UINT8, modslot14,
		PR_UINT8, PaintJob,
		PR_UINT32, BodyColor1,
		PR_UINT32, BodyColor2
	);

	stop PlayerCheckViewVeh[playerid][vehicleid];
	PlayerCheckViewVeh[playerid][vehicleid] = defer CheckViewVeh(playerid, vehicleid,\
		ModelID, X, Y, Z, Angle,InteriorColor1, InteriorColor2, Health,\
		interior, DoorDamageStatus, PanelDamageStatus,\
		LightDamageStatus, tireDamageStatus, addsiren,\
		modslot0, modslot1, modslot2, modslot3,\
		modslot4, modslot5, modslot6, modslot7,\
		modslot8, modslot9, modslot10, modslot11,\
		modslot12, modslot13, modslot14, PaintJob, BodyColor1, BodyColor2);
		
	return 0;
}

timer CheckViewVeh[100](playerid, vehicleid,\
ModelID, Float:X, Float:Y, Float:Z, Float:Angle,InteriorColor1, InteriorColor2,\
Float:Health, interior, DoorDamageStatus, PanelDamageStatus,\
LightDamageStatus, tireDamageStatus, addsiren,\
modslot0, modslot1, modslot2, modslot3,\
modslot4, modslot5, modslot6, modslot7,\
modslot8, modslot9, modslot10, modslot11,\
modslot12, modslot13, modslot14, PaintJob, BodyColor1, BodyColor2)
{
	if(IsPlayerViewingVehicle(playerid, vehicleid))
	{
    	ShowVehicleForPlayer(vehicleid, playerid, ModelID, X, Y, Z, Angle,InteriorColor1, InteriorColor2,\
			Health, interior, DoorDamageStatus, PanelDamageStatus,\
			LightDamageStatus, tireDamageStatus, addsiren,\
			modslot0, modslot1, modslot2, modslot3,\
			modslot4, modslot5, modslot6, modslot7,\
			modslot8, modslot9, modslot10, modslot11,\
			modslot12, modslot13, modslot14, PaintJob, BodyColor1, BodyColor2);
	}
	else
	{
	    PlayerCheckViewVeh[playerid][vehicleid] = defer CheckViewVeh(playerid, vehicleid,\
	    	ModelID, X, Y, Z, Angle,InteriorColor1, InteriorColor2,\
			Health, interior, DoorDamageStatus, PanelDamageStatus,\
			LightDamageStatus, tireDamageStatus, addsiren,\
			modslot0, modslot1, modslot2, modslot3,\
			modslot4, modslot5, modslot6, modslot7,\
			modslot8, modslot9, modslot10, modslot11,\
			modslot12, modslot13, modslot14, PaintJob, BodyColor1, BodyColor2);
	}
}

// WorldVehicleRemove
ORPC:165(playerid, BitStream:bs){
	new vehicleid;
    BS_ReadValue(bs, PR_UINT16, vehicleid);
    stop PlayerCheckViewVeh[playerid][vehicleid];
	return 1;
}

stock IsPlayerViewingVehicle(playerid, vehicleid)
{
	new
	    Float:px,
	    Float:py,
	    Float:pz,
		Float:vx,
		Float:vy,
		Float:vz,
		Float:tmp;
		
	GetPlayerPos(playerid, px, py, pz);
	GetVehiclePos(vehicleid, vx, vy, vz);

	return IsObjectVisible(CA_RayCastLine(px, py, pz, vx, vy, vz, tmp, tmp, tmp));
}

stock IsObjectVisible(objectid)
{
    new const VisibleIDs[] =
	{
		19869,19868,19913,7657,989,3036,2930,2909,988,980,975,969,8167,14883, 0, WATER_OBJECT,
		19870,2990,2933,986,985,971,19912,976,14468,1447,987,985,986,987,1411,
		1412,3058,7524,7560,7368,7369,7370,7319,7361,7367,7370,7371,7377,7378,7379,7380,7381,
		7538,7560,3475,4190,4195,4196,4201,4202,4196,4697,4714,4727,5030,7039,7212,7504,7505,
		7664,7665,8147,8148,8149,8150,8151,8152,8153,8154,8154,8155,8165,8167,8209,8249,8262,8263,
		8311,8313,8314,8315,8320,8369,8416,8673,8674,8680,10396,10402,10611,10437,10682,10683,10806,
		10807,10808,10809,11474,14469,14459,14501,15064,16293,16394,16370,16669,16668,16664,
		19312,19313,19868,19869,19870,19912,19913,1413,16391,16089,16670,16094,16389,3444,7418,3451,
		10835,3851,11305,3857,16392, 19466, 6042, 8378, 19303
	};
	
	for(new o = 0; o < sizeof(VisibleIDs); o++) if(objectid == VisibleIDs[o]) return 1;
	return 0;
}

ShowVehicleForPlayer(vehicleid, toplayerid,\
ModelID, Float:X, Float:Y, Float:Z, Float:Angle,InteriorColor1, InteriorColor2,\
Float:Health, interior, DoorDamageStatus, PanelDamageStatus,\
LightDamageStatus, tireDamageStatus, addsiren,\
modslot0, modslot1, modslot2, modslot3,\
modslot4, modslot5, modslot6, modslot7,\
modslot8, modslot9, modslot10, modslot11,\
modslot12, modslot13, modslot14, PaintJob, BodyColor1, BodyColor2)
{
    new BitStream:bs = BS_New();
    BS_WriteValue(bs,
        PR_UINT16, vehicleid,
		PR_UINT32, ModelID,
		PR_FLOAT, X,
		PR_FLOAT, Y,
		PR_FLOAT, Z,
		PR_FLOAT, Angle,
		PR_UINT8, InteriorColor1,
		PR_UINT8, InteriorColor2,
		PR_FLOAT, Health,
		PR_UINT32, interior,
		PR_UINT32, DoorDamageStatus,
		PR_UINT32, PanelDamageStatus,
		PR_UINT8, LightDamageStatus,
		PR_UINT8, tireDamageStatus,
		PR_UINT8, addsiren,
		PR_UINT8, modslot0,
		PR_UINT8, modslot1,
		PR_UINT8, modslot2,
		PR_UINT8, modslot3,
		PR_UINT8, modslot4,
		PR_UINT8, modslot5,
		PR_UINT8, modslot6,
		PR_UINT8, modslot7,
		PR_UINT8, modslot8,
		PR_UINT8, modslot9,
		PR_UINT8, modslot10,
		PR_UINT8, modslot11,
		PR_UINT8, modslot12,
		PR_UINT8, modslot13,
		PR_UINT8, modslot14,
		PR_UINT8, PaintJob,
		PR_UINT32, BodyColor1,
		PR_UINT32, BodyColor2
	);
    PR_SendRPC(bs, toplayerid, 164);
    BS_Delete(bs);
}
