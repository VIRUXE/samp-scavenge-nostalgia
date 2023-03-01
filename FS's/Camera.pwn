#include <a_samp>
#include <zcmd>
#include <sscanf2>


new PlayerText:TDCam[MAX_PLAYERS];

#define MOVE_SPEED              100.0
#define ACCEL_RATE              0.03
#define CAMERA_MODE_NONE    	0
#define CAMERA_MODE_FLY     	1
#define MOVE_FORWARD    		1
#define MOVE_BACK       		2
#define MOVE_LEFT       		3
#define MOVE_RIGHT      		4
#define MOVE_FORWARD_LEFT       5
#define MOVE_FORWARD_RIGHT      6
#define MOVE_BACK_LEFT          7
#define MOVE_BACK_RIGHT         8
#define PASTA_SAVE              "SaveCamera.pwn"

enum noclipenum
{
	cameramode,
	flyobject,
	mode,
	lrold,
	udold,
	lastmove,
	Float:accelmul
}
new noclipdata[MAX_PLAYERS][noclipenum];

public OnFilterScriptExit()
{
	for(new x; x<MAX_PLAYERS; x++)
	{
		if(noclipdata[x][cameramode] == CAMERA_MODE_FLY) CancelCameraMode(x);
	}
	return 1;
}

public OnPlayerConnect(playerid)
{
	noclipdata[playerid][cameramode] 	= CAMERA_MODE_NONE;
	noclipdata[playerid][lrold]	   	 	= 0;
	noclipdata[playerid][udold]   		= 0;
	noclipdata[playerid][mode]   		= 0;
	noclipdata[playerid][lastmove]   	= 0;
	noclipdata[playerid][accelmul]   	= 0.0;
	return 1;
}

CMD:cameramode(playerid)
{
	if(GetPVarType(playerid, "FlyMode"))
		CancelCameraMode(playerid);
	else
		FlyMode(playerid);
	return 1;
}



CMD:savecamera(playerid, params[])
{
	new nome[74];
	if(sscanf(params, "s[74]", nome))return SendClientMessage(playerid, -1, "Uso: /savecamera <nome>");
	if(GetPVarType(playerid, "FlyMode"))
	    SaveCamera(playerid, params);
	else
		SendClientMessage(playerid, -1, "Você não pode usar este comando agora");
	return 1;
}

public OnPlayerUpdate(playerid)
{
	if(noclipdata[playerid][cameramode] == CAMERA_MODE_FLY)
	{
		new keys,ud,lr;
		GetPlayerKeys(playerid,keys,ud,lr);
		if(noclipdata[playerid][mode] && (GetTickCount() - noclipdata[playerid][lastmove] > 100))
		{
		    MoveCamera(playerid);
		}
		if(noclipdata[playerid][udold] != ud || noclipdata[playerid][lrold] != lr)
		{
			if((noclipdata[playerid][udold] != 0 || noclipdata[playerid][lrold] != 0) && ud == 0 && lr == 0)
			{
				StopPlayerObject(playerid, noclipdata[playerid][flyobject]);
				noclipdata[playerid][mode]      = 0;
				noclipdata[playerid][accelmul]  = 0.0;
			}
			else
			{
				noclipdata[playerid][mode] = GetMoveDirectionFromKeys(ud, lr);
				MoveCamera(playerid);
			}
		}
		noclipdata[playerid][udold] = ud;noclipdata[playerid][lrold] = lr;
  		TextCamera(playerid);
		return 0;
	}
	return 1;
}


stock GetMoveDirectionFromKeys(ud, lr)
{
	new direction = 0;

    if(lr < 0)
	{
		if(ud < 0) 		direction = MOVE_FORWARD_LEFT;
		else if(ud > 0) direction = MOVE_BACK_LEFT;
		else            direction = MOVE_LEFT;
	}
	else if(lr > 0)
	{
		if(ud < 0)      direction = MOVE_FORWARD_RIGHT;
		else if(ud > 0) direction = MOVE_BACK_RIGHT;
		else			direction = MOVE_RIGHT;
	}
	else if(ud < 0) 	direction = MOVE_FORWARD;
	else if(ud > 0) 	direction = MOVE_BACK;

	return direction;
}

stock TextCamera(playerid)
{
	new Float:FV[3], Float:CP[3], str[128],Float:X, Float:Y, Float:Z;

	GetPlayerCameraPos(playerid, CP[0], CP[1], CP[2]);

	GetPlayerCameraFrontVector(playerid, FV[0], FV[1], FV[2]);

	GetNextCameraPositionEx(CP, FV, X, Y, Z);

	format(str, sizeof str, "~b~Cam Pos:~w~~h~ %0.2f, %0.2f, %0.2f~n~~b~Look AT:~w~~h~ %0.2f, %0.2f, %0.2f",CP[0], CP[1], CP[2],X, Y, Z);
	PlayerTextDrawSetString(playerid, TDCam[playerid], str);
	return 1;
}

stock MoveCamera(playerid)
{
	new Float:FV[3], Float:CP[3],Float:X, Float:Y, Float:Z;

	GetPlayerCameraPos(playerid, CP[0], CP[1], CP[2]);
    GetPlayerCameraFrontVector(playerid, FV[0], FV[1], FV[2]);
	if(noclipdata[playerid][accelmul] <= 1)
	{

		noclipdata[playerid][accelmul] += ACCEL_RATE;

	}

	new Float:speed = MOVE_SPEED * noclipdata[playerid][accelmul];

	GetNextCameraPosition(noclipdata[playerid][mode], CP, FV, X, Y, Z);
	MovePlayerObject(playerid, noclipdata[playerid][flyobject], X, Y, Z, speed);

	noclipdata[playerid][lastmove] = GetTickCount();
	return 1;
}

stock SaveCamera(playerid, nome[])
{
	new Float:FV[3], Float:CP[3], File:file, str[420],Float:X, Float:Y, Float:Z;

	GetPlayerCameraPos(playerid, CP[0], CP[1], CP[2]);

	GetPlayerCameraFrontVector(playerid, FV[0], FV[1], FV[2]);

	GetNextCameraPositionEx(CP, FV, X, Y, Z);

	file = fopen(PASTA_SAVE,io_append);
	format(str, sizeof str, "\n\n\n//---------- %s ----------\nSetPlayerCameraPos(playerid, %0.2f, %0.2f, %0.2f);\nSetPlayerCameraLookAt(playerid, %0.2f, %0.2f, %0.2f);\n//-----------------------------------",
	nome, CP[0], CP[1], CP[2], X, Y, Z);
    fwrite(file,str);
    fclose(file);
    SendClientMessage(playerid, 0xF6F600FF, "-----------------------------------------------------------------------------------------------------------------------------");
	format(str, sizeof str, "A posição da camera '{FFFFFF}%s{F6F600}' foi salva no arquivo ({FFFFFF}%s{F6F600}) em sua pasta 'scriptfiles'",nome, PASTA_SAVE);
    SendClientMessage(playerid, 0xF6F600FF, str);
	SendClientMessage(playerid, 0xF6F600FF, "-----------------------------------------------------------------------------------------------------------------------------");
	return 1;
}

stock GetNextCameraPosition(move_mode, Float:CP[3], Float:FV[3], &Float:X, &Float:Y, &Float:Z)
{
    #define OFFSET_X (FV[0]*6000.0)
	#define OFFSET_Y (FV[1]*6000.0)
	#define OFFSET_Z (FV[2]*6000.0)
	switch(move_mode)
	{
		case MOVE_FORWARD:
		{
			X = CP[0]+OFFSET_X;
			Y = CP[1]+OFFSET_Y;
			Z = CP[2]+OFFSET_Z;
		}
		case MOVE_BACK:
		{
			X = CP[0]-OFFSET_X;
			Y = CP[1]-OFFSET_Y;
			Z = CP[2]-OFFSET_Z;
		}
		case MOVE_LEFT:
		{
			X = CP[0]-OFFSET_Y;
			Y = CP[1]+OFFSET_X;
			Z = CP[2];
		}
		case MOVE_RIGHT:
		{
			X = CP[0]+OFFSET_Y;
			Y = CP[1]-OFFSET_X;
			Z = CP[2];
		}
		case MOVE_BACK_LEFT:
		{
			X = CP[0]+(-OFFSET_X - OFFSET_Y);
 			Y = CP[1]+(-OFFSET_Y + OFFSET_X);
		 	Z = CP[2]-OFFSET_Z;
		}
		case MOVE_BACK_RIGHT:
		{
			X = CP[0]+(-OFFSET_X + OFFSET_Y);
 			Y = CP[1]+(-OFFSET_Y - OFFSET_X);
		 	Z = CP[2]-OFFSET_Z;
		}
		case MOVE_FORWARD_LEFT:
		{
			X = CP[0]+(OFFSET_X  - OFFSET_Y);
			Y = CP[1]+(OFFSET_Y  + OFFSET_X);
			Z = CP[2]+OFFSET_Z;
		}
		case MOVE_FORWARD_RIGHT:
		{
			X = CP[0]+(OFFSET_X  + OFFSET_Y);
			Y = CP[1]+(OFFSET_Y  - OFFSET_X);
			Z = CP[2]+OFFSET_Z;
		}
	}
}



stock GetNextCameraPositionEx(Float:CP[3], Float:FV[3], &Float:X, &Float:Y, &Float:Z)
{
    #define OFFSET_XX (FV[0]*6.0)
	#define OFFSET_YY (FV[1]*6.0)
	#define OFFSET_ZZ (FV[2]*6.0)
	X = CP[0]+OFFSET_XX;
	Y = CP[1]+OFFSET_YY;
	Z = CP[2]+OFFSET_ZZ;
}

stock CancelCameraMode(playerid)
{
    SendClientMessage(playerid, 0xF6F600FF, "Você foi spawnado.");
	DeletePVar(playerid, "FlyMode");
	CancelEdit(playerid);
	TogglePlayerSpectating(playerid, false);
	PlayerTextDrawDestroy(playerid, TDCam[playerid]);
	DestroyPlayerObject(playerid, noclipdata[playerid][flyobject]);
	noclipdata[playerid][cameramode] = CAMERA_MODE_NONE;
	SetTimerEx("SetPlayerOriginalPos", 1000, false, "d", playerid);
	return 1;
}

forward SetPlayerOriginalPos(playerid);
public SetPlayerOriginalPos(playerid)
{
	SetPlayerPos(playerid, GetPVarFloat(playerid, "OriginalX"),GetPVarFloat(playerid, "OriginalY"),GetPVarFloat(playerid, "OriginalZ"));
}

stock FlyMode(playerid)
{
	TDCam[playerid] = CreatePlayerTextDraw(playerid, 32.000000, 310.000000, " ");
	PlayerTextDrawBackgroundColor(playerid, TDCam[playerid], 70);
	PlayerTextDrawFont(playerid, TDCam[playerid], 1);
	PlayerTextDrawLetterSize(playerid, TDCam[playerid], 0.250000, 1.300000);
	PlayerTextDrawColor(playerid, TDCam[playerid], -1);
	PlayerTextDrawSetOutline(playerid, TDCam[playerid], 1);
	PlayerTextDrawSetProportional(playerid, TDCam[playerid], 1);
	PlayerTextDrawShow(playerid, TDCam[playerid]);
	new Float:X, Float:Y, Float:Z;
	GetPlayerPos(playerid, X, Y, Z);
	noclipdata[playerid][flyobject] = CreatePlayerObject(playerid, 19300, X, Y, Z, 0.0, 0.0, 0.0);
 	TogglePlayerSpectating(playerid, true);
	AttachCameraToPlayerObject(playerid, noclipdata[playerid][flyobject]);
	SetPVarInt(playerid, "FlyMode", 1);
	noclipdata[playerid][cameramode] = CAMERA_MODE_FLY;
	SetPVarFloat(playerid, "OriginalX", X);
	SetPVarFloat(playerid, "OriginalY", Y);
	SetPVarFloat(playerid, "OriginalZ", Z);
	return 1;
}

//--------------------------------------------------
