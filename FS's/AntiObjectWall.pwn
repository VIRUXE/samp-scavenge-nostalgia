#include <a_samp>

#undef MAX_PLAYERS
#define MAX_PLAYERS  (50)

#define FILTERSCRIPT

#include <a_samp>
#include <Pawn.RakNet>
#include <ColAndreas>
#include <YSI\y_timers>

new
	Timer:PlayerCheckViewObj[MAX_PLAYERS][MAX_OBJECTS];

// CreateObject
ORPC:44(playerid, BitStream:bs)
{
	new
		objectid,
		ModelID,
		Float:X,
		Float:Y,
		Float:Z,
		Float:RX,
		Float:RY,
		Float:RZ,
		Float:d,
		NoCamera,
		attobj,
		attve;
		
    BS_ReadValue(bs,
		PR_UINT16, objectid,
		PR_UINT32, ModelID,
		PR_FLOAT, X,
		PR_FLOAT, Y,
		PR_FLOAT, Z,
		PR_FLOAT, RX,
		PR_FLOAT, RY,
		PR_FLOAT, RZ,
		PR_FLOAT, d,
		PR_UINT8, NoCamera,
        PR_UINT16, attobj,
        PR_UINT16, attve
	);
	    
	if(ModelID == 1279 || ModelID == 19477 || ModelID == 19087 ||
		ModelID == 3014 || ModelID == 2969 || ModelID == 1271)
	{
	    if(IsPlayerViewingObject(playerid, X, Y, Z, ModelID))
	    	return 1;
	    
		stop PlayerCheckViewObj[playerid][objectid];

	    PlayerCheckViewObj[playerid][objectid] = defer CheckViewObj(playerid, objectid,\
		    	ModelID, X, Y, Z, RX, RY, RZ, d, NoCamera, attobj, attve);

		return 0;
	}
	else return 1;
}

timer CheckViewObj[100](playerid, objectid, ModelID, Float:X, Float:Y, Float:Z, Float:RX, Float:RY, Float:RZ, Float:d, NoCamera, attobj, attve)
{
	if(IsPlayerViewingObject(playerid, X, Y, Z, ModelID))
	{
    	ShowObjectForPlayer(objectid, playerid, ModelID, X, Y, Z, RX, RY, RZ, d, NoCamera, attobj, attve);
	}
	else
	{
	    PlayerCheckViewObj[playerid][objectid] = defer CheckViewObj(playerid, objectid,\
	    	ModelID, X, Y, Z, RX, RY, RZ, d, NoCamera, attobj, attve);
	}
}

// DestroyObject
ORPC:47(playerid, BitStream:bs)
{
	new objectid;
    BS_ReadValue(bs, PR_UINT16, objectid);

    stop PlayerCheckViewObj[playerid][objectid];
	return 1;
}

stock IsPlayerViewingObject(playerid, Float:X, Float:Y, Float:Z, modelid)
{
	new
	    Float:px,
	    Float:py,
	    Float:pz,
		Float:tmp,
		rayid;

	GetPlayerPos(playerid, px, py, pz);

	rayid = CA_RayCastLine(X, Y, Z, px, py, pz, tmp, tmp, tmp);
	    
	if(rayid == modelid)
	    return 1;
	
	return IsObjectVisible(rayid);
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

ShowObjectForPlayer(objectid, toplayerid, ModelID, Float:X, Float:Y, Float:Z, Float:RX, Float:RY, Float:RZ, Float:d, NoCamera, attobj, attve)
{
    new BitStream:bs = BS_New();
    BS_WriteValue(bs,
		PR_UINT16, objectid,
		PR_UINT32, ModelID,
		PR_FLOAT, X,
		PR_FLOAT, Y,
		PR_FLOAT, Z,
		PR_FLOAT, RX,
		PR_FLOAT, RY,
		PR_FLOAT, RZ,
		PR_FLOAT, d,
		PR_UINT8, NoCamera,
        PR_UINT16, attobj,
        PR_UINT16, attve
	);
	
    PR_SendRPC(bs, toplayerid, 44);
    BS_Delete(bs);
}
