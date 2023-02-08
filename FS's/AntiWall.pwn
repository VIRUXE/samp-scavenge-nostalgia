#include <a_samp>

#undef MAX_PLAYERS
#define MAX_PLAYERS (40)

#define FILTERSCRIPT

#include <a_samp>
#include <Pawn.RakNet>
#include <ColAndreas>
#include <YSI\y_timers>

enum Attachments
{
	ModelID,
	Bone,
	Float:ox,
	Float:oy,
	Float:oz,
	Float:rx,
	Float:ry,
	Float:rz,
	Float:sx,
	Float:sy,
	Float:sz,
	color1,
	color2
}

static
	attchEnum[MAX_PLAYERS][MAX_PLAYER_ATTACHED_OBJECTS][Attachments],
	Timer:PlayerCheckView[MAX_PLAYERS][MAX_PLAYERS];

// WorldPlayerAdd
ORPC:32(playerid, BitStream:bs)
{
	new streamid;
    BS_ReadValue(bs, PR_UINT16, streamid);
	stop PlayerCheckView[playerid][streamid];
	
 	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING ||
		GetPlayerSkin(playerid) == 217 ||
		GetPlayerSkin(playerid) == 211 ||
		GetPlayerSkin(playerid) == 0)
        return 1;
        
	PlayerCheckView[playerid][streamid] = defer CheckView(playerid, streamid);

	return 0;
}

timer CheckView[100](playerid, streamid)
{
	if(IsPlayerViewingPlayer(playerid, streamid))
    	ShowPlayerForPlayer(streamid, playerid);
	else
	    PlayerCheckView[playerid][streamid] = defer CheckView(playerid, streamid);
}

// WorldPlayerRemove
ORPC:163(playerid, BitStream:bs){

	new streamid;
    BS_ReadValue(bs, PR_UINT16, streamid);
    stop PlayerCheckView[playerid][streamid];
	return 1;
}

stock IsPlayerViewingPlayer(playerid, viewid)
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
	GetPlayerPos(viewid, vx, vy, vz);

	return IsObjectVisible(CA_RayCastLine(px, py, pz, vx, vy, vz, tmp, tmp, tmp));
}

// Detecta se o objeto � uma grade, vidro etc. (Feito por min mesmo)
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

ShowPlayerForPlayer(playerid, toplayerid)
{
	new
		Float:x,
		Float:y,
		Float:z,
		Float:a;
		
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, a);
	
    new BitStream:bs = BS_New();
    BS_WriteValue(bs,
        PR_UINT16, playerid,
        PR_UINT8, GetPlayerTeam(playerid),
        PR_UINT32, GetPlayerSkin(playerid),
        PR_FLOAT, x,
        PR_FLOAT, y,
        PR_FLOAT, z,
        PR_FLOAT, a,
        PR_UINT32, GetPlayerColor(playerid),
        PR_UINT8, GetPlayerFightingStyle(playerid)
    );
    PR_SendRPC(bs, toplayerid, 32);
    BS_Delete(bs);
    
   	for(new i = 0; i < MAX_PLAYER_ATTACHED_OBJECTS; i++)
	{
		if(IsPlayerAttachedObjectSlotUsed(playerid, i))
		{
			new BitStream:bs_att = BS_New();
			BS_WriteValue(
				bs_att,
				PR_UINT16, playerid,
				PR_UINT32, i,
				PR_BOOL, 1,
				PR_UINT32, attchEnum[playerid][i][ModelID],
				PR_UINT32, attchEnum[playerid][i][Bone],
				PR_FLOAT, attchEnum[playerid][i][ox],
				PR_FLOAT, attchEnum[playerid][i][oy],
				PR_FLOAT, attchEnum[playerid][i][oz],
				PR_FLOAT, attchEnum[playerid][i][rx],
				PR_FLOAT, attchEnum[playerid][i][ry],
				PR_FLOAT, attchEnum[playerid][i][rz],
				PR_FLOAT, attchEnum[playerid][i][sx],
				PR_FLOAT, attchEnum[playerid][i][sy],
				PR_FLOAT, attchEnum[playerid][i][sz],
				PR_UINT32, attchEnum[playerid][i][color1],
				PR_UINT32, attchEnum[playerid][i][color2]
			);
			PR_SendRPC(bs_att, toplayerid, 113);
			BS_Delete(bs_att);
		}
	}
}

// SetPlayerAttachedObject
ORPC:113(playerid, BitStream:bs)
{
	new index,
		modelid,
		bone,
		Float:x, Float:y, Float:z,
		Float:rox, Float:roy, Float:roz,
		Float:scx, Float:scy, Float:scz,
		mColor1,
		mColor2;

    BS_ReadValue(bs,
		PR_UINT16, playerid,
        PR_UINT32, index,
        PR_BOOL, 0,
        PR_UINT32, modelid,
        PR_UINT32, bone,
        PR_FLOAT, x,
        PR_FLOAT, y,
        PR_FLOAT, z,
        PR_FLOAT, rox,
        PR_FLOAT, roy,
        PR_FLOAT, roz,
        PR_FLOAT, scx,
        PR_FLOAT, scy,
        PR_FLOAT, scz,
        PR_UINT32, mColor1,
        PR_UINT32, mColor1
	);

    attchEnum[playerid][index][ModelID] = modelid;

	attchEnum[playerid][index][Bone] = bone;

	attchEnum[playerid][index][ox] = x;
	attchEnum[playerid][index][oy] = y;
	attchEnum[playerid][index][oz] = z;

	attchEnum[playerid][index][rx] = rox;
	attchEnum[playerid][index][ry] = roy;
	attchEnum[playerid][index][rz] = roz;

	attchEnum[playerid][index][sx] = scx;
	attchEnum[playerid][index][sy] = scy;
	attchEnum[playerid][index][sz] = scz;

	attchEnum[playerid][index][color1] = mColor1;
	attchEnum[playerid][index][color2] = mColor2;
	return 1;
}
