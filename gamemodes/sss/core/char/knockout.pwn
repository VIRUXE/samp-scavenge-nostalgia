#include <YSI\y_hooks>


static
			knockout_MaxDuration = 120000;

static
PlayerBar:	KnockoutBar = INVALID_PLAYER_BAR_ID,
			knockout_KnockedOut[MAX_PLAYERS],
			knockout_InVehicleID[MAX_PLAYERS],
			knockout_InVehicleSeat[MAX_PLAYERS],
			knockout_Tick[MAX_PLAYERS],
			knockout_Duration[MAX_PLAYERS],
Timer:		knockout_Timer[MAX_PLAYERS];


forward OnPlayerKnockOut(playerid);


hook OnPlayerConnect(playerid)
{
	

	KnockoutBar = CreatePlayerProgressBar(playerid, 291.0, 315.0, 57.50, 5.19, RED, 100.0);
	knockout_KnockedOut[playerid] = false;
	knockout_InVehicleID[playerid] = INVALID_VEHICLE_ID;
	knockout_InVehicleSeat[playerid] = -1;
	knockout_Tick[playerid] = 0;
	knockout_Duration[playerid] = 0;
}

hook OnPlayerDisconnect(playerid)
{


	if(gServerRestarting)
		return 1;

	DestroyPlayerProgressBar(playerid, KnockoutBar);

	if(knockout_KnockedOut[playerid])
		WakeUpPlayer(playerid);

	return 1;
}

hook OnPlayerDeath(playerid, killerid, reason)
{


	WakeUpPlayer(playerid);
}

stock KnockOutPlayer(playerid, duration)
{
	if(IsPlayerOnAdminDuty(playerid))
		return 0;

	if(!IsPlayerSpawned(playerid))
		return 0;

	log("[KNOCKOUT] Player %p knocked out for %s", playerid, MsToString(duration, "%1m:%1s.%1d"));

	ShowPlayerProgressBar(playerid, KnockoutBar);

	if(IsPlayerInAnyVehicle(playerid))
	{
		knockout_InVehicleID[playerid] = GetPlayerVehicleID(playerid);
		knockout_InVehicleSeat[playerid] = GetPlayerVehicleSeat(playerid);
	}

	if(knockout_KnockedOut[playerid])
		knockout_Duration[playerid] += duration;

	else
	{
		knockout_Tick[playerid] = GetTickCount();
		knockout_Duration[playerid] = duration;
		knockout_KnockedOut[playerid] = true;

		TogglePlayerVehicleEntry(playerid, false);

		_PlayKnockOutAnimation(playerid);

		stop knockout_Timer[playerid];
		knockout_Timer[playerid] = repeat KnockOutUpdate(playerid);
	}

	if(knockout_Duration[playerid] > knockout_MaxDuration)
		knockout_Duration[playerid] = knockout_MaxDuration;

	CallLocalFunction("OnPlayerKnockOut", "d", playerid);

	ClosePlayerInventory(playerid);
	ClosePlayerContainer(playerid);

	return 1;
}

stock WakeUpPlayer(playerid)
{
	log("[KNOCKOUT] %p (%d) acordou de um knock-out", playerid, playerid);

	stop knockout_Timer[playerid];

	TogglePlayerVehicleEntry(playerid, true);
	HidePlayerProgressBar(playerid, KnockoutBar);
	HideActionText(playerid);
	ApplyAnimation(playerid, "PED", "GETUP_FRONT", 4.0, 0, 1, 1, 0, 0);

	knockout_Tick[playerid]          = GetTickCount();
	knockout_KnockedOut[playerid]    = false;
	knockout_InVehicleID[playerid]   = INVALID_VEHICLE_ID;
	knockout_InVehicleSeat[playerid] = -1;

	PrintAmxBacktrace();
}

timer KnockOutUpdate[100](playerid)
{
	if(!knockout_KnockedOut[playerid]) WakeUpPlayer(playerid);

	if(IsPlayerDead(playerid) || GetTickCountDifference(GetTickCount(), GetPlayerSpawnTick(playerid)) < 1000 || !IsPlayerSpawned(playerid))
	{
		knockout_KnockedOut[playerid] = false;
		HidePlayerProgressBar(playerid, KnockoutBar);
		return;
	}

	if(IsPlayerOnAdminDuty(playerid)) WakeUpPlayer(playerid);

	if(IsValidVehicle(knockout_InVehicleID[playerid]))
	{
		if(!IsPlayerInVehicle(playerid, knockout_InVehicleID[playerid]))
		{
			PutPlayerInVehicle(playerid, knockout_InVehicleID[playerid], knockout_InVehicleSeat[playerid]);

			new animidx = GetPlayerAnimationIndex(playerid);

			if(animidx != 1207 && animidx != 1018 && animidx != 1001) _PlayKnockOutAnimation(playerid);
		}

		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) SetVehicleEngine(knockout_InVehicleID[playerid], 0);
	}
	else
	{
		if(IsPlayerInAnyVehicle(playerid)) RemovePlayerFromVehicle(playerid);

		new animidx = GetPlayerAnimationIndex(playerid);

		if(animidx != 1207 && animidx != 1018 && animidx != 1001) _PlayKnockOutAnimation(playerid);
	}

	SetPlayerProgressBarValue(playerid, KnockoutBar, GetTickCountDifference(GetTickCount(), knockout_Tick[playerid]));
	SetPlayerProgressBarMaxValue(playerid, KnockoutBar, knockout_Duration[playerid]);

	//ShowActionText(playerid, sprintf("%s/%s", MsToString(GetTickCountDifference(GetTickCount(), knockout_Tick[playerid]), "%1m:%1s.%1d"), MsToString(knockout_Duration[playerid], "%1m:%1s.%1d")));

	if(GetTickCountDifference(GetTickCount(), knockout_Tick[playerid]) >= knockout_Duration[playerid]) WakeUpPlayer(playerid);

	return;
}

_PlayKnockOutAnimation(playerid)
{
	if(!IsPlayerInAnyVehicle(playerid)) 
		ApplyAnimation(playerid, "PED", "KO_SHOT_STOM", 4.0, 0, 1, 1, 1, 0, 1);
	else
	{
		new vehicleid = GetPlayerVehicleID(playerid);

		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) SetVehicleEngine(vehicleid, 0);

		switch(GetVehicleTypeCategory(GetVehicleType(vehicleid)))
		{
			case VEHICLE_CATEGORY_MOTORBIKE, VEHICLE_CATEGORY_PUSHBIKE:
			{
				new Float:x, Float:y, Float:z;

				GetVehiclePos(vehicleid, x, y, z);
				RemovePlayerFromVehicle(playerid);
				SetPlayerPos(playerid, x, y, z);
				ApplyAnimation(playerid, "PED", "BIKE_fall_off", 4.0, 0, 1, 1, 0, 0, 1);
			}

			default: ApplyAnimation(playerid, "PED", "CAR_DEAD_LHS", 4.0, 0, 1, 1, 1, 0, 1);
		}
	}
}

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{


	if(knockout_KnockedOut[playerid]) _vehicleCheck(playerid);
}

hook OnPlayerExitVehicle(playerid, vehicleid)
{


	if(knockout_KnockedOut[playerid]) _vehicleCheck(playerid);
}

//PlayerExitVehicle
ORPC:154(playerid, BitStream:bs)
	return !knockout_KnockedOut[playerid];

//ExitVehicle
IRPC:154(playerid, BitStream:bs)
	return !knockout_KnockedOut[playerid];

//EnterVehicle
IRPC:26(playerid, BitStream:bs)
	return !knockout_KnockedOut[playerid];
	
hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{


	if(knockout_KnockedOut[playerid])
		_vehicleCheck(playerid);
}

_vehicleCheck(playerid)
{
	if(IsValidVehicle(knockout_InVehicleID[playerid]))
	{
	    new Float:x, Float:y, Float:z;
	    
        GetPlayerPos(playerid, x, y, z);
        
        SetPlayerPos(playerid, x, y, z);
        
		PutPlayerInVehicle(playerid, knockout_InVehicleID[playerid], knockout_InVehicleSeat[playerid]);

		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
			SetVehicleEngine(knockout_InVehicleID[playerid], 0);
	}
	else RemovePlayerFromVehicle(playerid);

	new animidx = GetPlayerAnimationIndex(playerid);

	if(animidx != 1207 && animidx != 1018 && animidx != 1001)
		_PlayKnockOutAnimation(playerid);
}

stock GetPlayerKnockOutTick(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return knockout_Tick[playerid];
}

stock GetPlayerKnockoutDuration(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return knockout_Duration[playerid];
}

stock GetPlayerKnockOutRemainder(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(!knockout_KnockedOut[playerid])
		return 0;

	return GetTickCountDifference(GetTickCount(), (knockout_Tick[playerid] + knockout_Duration[playerid]));
}

stock IsPlayerKnockedOut(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return knockout_KnockedOut[playerid];
}
