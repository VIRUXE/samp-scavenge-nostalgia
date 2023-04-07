#include <YSI\y_hooks>

/*==============================================================================

	Anti-Cheat Kick Msg

==============================================================================*/

AC_KickPlayer(playerid, reason[], info[] = ""){
	if(IsPlayerKicked(playerid)) return 1;
	if(GetPlayerAdminLevel(playerid) > 0) return 1;
	new str[150], name[24], Float:Pos[3];

	GetPlayerName(playerid, name, 24);
	GetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);

	ReportPlayer(name, info, -1, reason, Pos[0], Pos[1], Pos[2], GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), sprintf("%.1f, %.1f, %.1f", Pos[0], Pos[1], Pos[2]) );
	
	if(GetAdminsOnline(1, 6) == 0){
  		format(str, sizeof(str), "[Anti-Cheat] %s(%d) Foi kickado do servidor. Motivo: %s", name, playerid, reason);
		SendClientMessageToAll(0xA9C4E4AA, str);

		format(str, sizeof(str), "[Anti-Cheat] Você foi kickado do servidor. Motivo: %s", reason);
		SendClientMessage(playerid, 0xA9C4E4AA, str);

		SendClientMessage(playerid, 0xA9C4E4AA, " > Se você acha isso injusto, entre em nosso grupo do discord e fale com um administrador. https://discord.gg/jduSSH2Ezf");

	    KickPlayer(playerid, "Anti-Cheat", false);
    }
    else {
        format(str, sizeof(str), "[Anti-Cheat] %s(%d) Está sendo reportado, motivo: %s", name, playerid, reason);
		ChatMsgAdmins(1, 0xA9C4E4AA, str);
    }
    return 1;
}

/*==============================================================================

	Anti-Teleport (Callback do FS AntiAirbreak

==============================================================================*/

forward OnPlayerAirbreak(playerid, Float:x, Float:y, Float:z, Float:ox, Float:oy, Float:oz);
public OnPlayerAirbreak(playerid, Float:x, Float:y, Float:z, Float:ox, Float:oy, Float:oz){
    if(GetPlayerAdminLevel(playerid) > 0) return 0;

    new
		name[MAX_PLAYER_NAME],
		reason[200],
		info[128],
		Float:distance = Distance(x, y, z, ox, oy, oz);

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	format(reason, sizeof(reason), "Movido %.0fm | Velocidade: @%.0f | (%.0f, %.0f, %.0f > %.0f, %.0f, %.0f)", distance, GetPlayerTotalVelocity(playerid), ox, oy, oz, x, y, z);
	format(info, sizeof(info), "%.1f, %.1f, %.1f", x, y, z);
	ReportPlayer(name, reason, -1, REPORT_TYPE_TELEPORT, ox, oy, oz, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), info);

	return 1;
}

/*==============================================================================

	Anti-Wall (Callback do FS AntiWall)

==============================================================================*/

ptask player_Check[SEC(1)](playerid)
{
    /*==========================================================================
    
		Anti-Fly

	==========================================================================*/

	if(GetTickCountDifference(GetTickCount(), GetPlayerServerJoinTick(playerid)) < 10000) return;

	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING) return;

	if(IsPlayerDead(playerid)) return;
		
    if(GetPlayerAdminLevel(playerid) > 0) return;

	if(GetPlayerAnimationIndex(playerid) == 373)
        AC_KickPlayer(playerid, "Fly Hack");
	else if(GetPlayerAnimationIndex(playerid) == 958 || GetPlayerAnimationIndex(playerid) == 959 &&
	GetPlayerWeapon(playerid) != 46)
        AC_KickPlayer(playerid, "Fly Hack");

	new
		animlib[32],
		animname[32];

	GetAnimationName(GetPlayerAnimationIndex(playerid), animlib, sizeof(animlib), animname, sizeof(animname));

	if(isnull(animlib))
		return;

	if(!strcmp(animlib, "SWIM")){
		new Float:x, Float:y, Float:z;

		GetPlayerPos(playerid, x, y, z);

		if(x == 0.0 && y == 0.0 && z == 0.0) return;

		if(-5.0 < (x - DEFAULT_POS_X) < 5.0 && -5.0 < (y - DEFAULT_POS_Y) < 5.0 && -5.0 < (z - DEFAULT_POS_Z) < 5.0) return;

		if(z > 5.0 && !IsPosInWater(x, y, z)) AC_KickPlayer(playerid, "Fly Hack");
	}

	/*==========================================================================

		Dinheiro e mochila ajato bloqueadas

	==========================================================================*/
	
    if(GetPlayerMoney(playerid) > 0) BanPlayer(playerid, "Money-Hack", -1, 0);

    if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USEJETPACK) BanPlayer(playerid, "JetPack-Hack", -1, 0);
		
	/*==========================================================================

		Anti-Car Tune

	==========================================================================*/
	
    new vehicleid, component;

	vehicleid = GetPlayerVehicleID(playerid);

	component = GetVehicleComponentInSlot(vehicleid, CARMODTYPE_NITRO);

	if(component == 1008 || component == 1009 || component == 1010) {
		BanPlayer(playerid, "Detectado Nitro no veículo.", -1, 0);
		RemoveVehicleComponent(vehicleid, CARMODTYPE_NITRO);
	}

	component = GetVehicleComponentInSlot(vehicleid, CARMODTYPE_HYDRAULICS);

	if(component == 1087) {
		BanPlayer(playerid, "Detectado Hydraulica no veículo.", -1, 0);
		RemoveVehicleComponent(vehicleid, CARMODTYPE_HYDRAULICS);
	}
	
    new
		Float:vehiclehp;

	GetVehicleHealth(vehicleid, vehiclehp);

	if(vehiclehp > 990.0 && GetPlayerVehicleSeat(playerid) == 0) { // Only check the driver - Checking passengers causes a false ban 
		AC_KickPlayer(playerid, "Veículo Health-Hack");

		defer vh_ResetVehiclePosition(GetPlayerVehicleID(playerid));
	}
	
	// Anti NameTag
    foreach(new i : Player)
		ShowPlayerNameTagForPlayer(playerid, i, false);

    // Anti Cam Hack
	CameraDistanceCheck(playerid);
}

timer vh_ResetVehiclePosition[SEC(1)](vehicleid)
{
	SetVehicleHealth(vehicleid, 300.0);
}

/*==============================================================================

	Entering locked vehicles

==============================================================================*/


hook OnPlayerStateChange(playerid, newstate, oldstate){
	if(newstate == PLAYER_STATE_DRIVER)
	{
		new
			vehicleid,
			E_LOCK_STATE:lockstate;

		vehicleid = GetPlayerVehicleID(playerid);
		lockstate = GetVehicleLockState(vehicleid);

		if(lockstate != E_LOCK_STATE_OPEN && GetTickCountDifference(GetTickCount(), GetVehicleLockTick(vehicleid)) > 3500)
		{
		    AC_KickPlayer(playerid, "Teleporte Veículo");
			defer StillInVeh(playerid, vehicleid, _:lockstate);

			return 1;
		}
	}

	if(newstate == PLAYER_STATE_PASSENGER)
	{
		new
			vehicleid,
			E_LOCK_STATE:lockstate;

		vehicleid = GetPlayerVehicleID(playerid);
		lockstate = GetVehicleLockState(vehicleid);

		if(lockstate != E_LOCK_STATE_OPEN && GetTickCountDifference(GetTickCount(), GetVehicleLockTick(vehicleid)) > 3500)
		{
			AC_KickPlayer(playerid, "Teleporte Veículo");
			defer StillInVeh(playerid, vehicleid, _:lockstate);
			return 1;
		}
	}

	return 1;
}

timer StillInVeh[SEC(1)](playerid, vehicleid, ls)
{
	if(!IsPlayerConnected(playerid)) return;

	SetVehicleExternalLock(vehicleid, E_LOCK_STATE:ls);
}

/*==============================================================================

	Infinite Ammo and Shooting Animations

==============================================================================*/


static
	ammo_LastShot[MAX_PLAYERS],
	ammo_ShotCounter[MAX_PLAYERS];

hook OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
    if(GetPlayerAdminLevel(playerid) > 0) return 1;

	if(GetTickCountDifference(GetTickCount(), ammo_LastShot[playerid]) < GetWeaponShotInterval(weaponid) + 10)
	{
		ammo_ShotCounter[playerid]++;

		if(ammo_ShotCounter[playerid] > GetWeaponMagSize(weaponid))
			AC_KickPlayer(playerid, "Weapon - Hack", sprintf("Arma: %d", weaponid));
	}
	else
		ammo_ShotCounter[playerid] = 1;

	ammo_LastShot[playerid] = GetTickCount();

	switch(weaponid)
	{
		case 27:
		{
			if(GetPlayerAnimationIndex(playerid) == 222)
			{
				AC_KickPlayer(playerid, "Weapon - Hack", sprintf("Arma: %d", weaponid));
				return 0;
			}
		}
		case 23:
		{
			if(GetPlayerAnimationIndex(playerid) == 1454)
			{
				AC_KickPlayer(playerid, "Weapon - Hack", sprintf("Arma: %d", weaponid));
				return 0;
			}
		}
		case 25:
		{
			if(GetPlayerAnimationIndex(playerid) == 1450)
			{
				AC_KickPlayer(playerid, "Weapon - Hack", sprintf("Arma: %d", weaponid));
				return 0;
			}
		}
		case 29:
		{
			if(GetPlayerAnimationIndex(playerid) == 1645)
			{
				AC_KickPlayer(playerid, "Weapon - Hack", sprintf("Arma: %d", weaponid));
				return 0;
			}
		}
		case 30, 31, 33:
		{
			if(GetPlayerAnimationIndex(playerid) == 1367)
			{
				AC_KickPlayer(playerid, "Weapon - Hack", sprintf("Arma: %d", weaponid));
				return 0;
			}
		}
		case 24:
		{
			if(GetPlayerAnimationIndex(playerid) == 1333)
			{
				AC_KickPlayer(playerid, "Weapon - Hack", sprintf("Arma: %d", weaponid));
				return 0;
			}
		}
        case 22, 26, 28, 32, 34, 38:
		{
			// Do nothing
		}
		default:
		{
			if(hittype == BULLET_HIT_TYPE_PLAYER)
			{
				AC_KickPlayer(playerid, "Weapon - Hack", sprintf("Arma: %d", weaponid));
				return 0;
			}
		}
	}

	// by IstuntmanI, thanks!
	if(hittype == BULLET_HIT_TYPE_PLAYER)
	{
		if(!(-20.0 <= fX <= 20.0) || !(-20.0 <= fY <= 20.0) || !(-20.0 <= fZ <= 20.0))
		{
			AC_KickPlayer(playerid, "Weapon - Hack", sprintf("Arma: %d", weaponid));
			return 0;
		}
	}
	return 1;
}


/*==============================================================================

	Camera Distance

==============================================================================*/

#define CAMERA_DISTANCE_INCAR			(150.0)
#define CAMERA_DISTANCE_INCAR_MOVING	(150.0)
#define CAMERA_DISTANCE_INCAR_CINEMATIC	(250.0)
#define CAMERA_DISTANCE_INCAR_CINEMOVE	(150.0)
#define CAMERA_DISTANCE_ONFOOT			(45.0)


enum
{
	CAMERA_TYPE_NONE,				// 0
	CAMERA_TYPE_INCAR,				// 1
	CAMERA_TYPE_INCAR_MOVING,		// 2
	CAMERA_TYPE_INCAR_CINEMATIC,	// 3
	CAMERA_TYPE_INCAR_CINEMOVE,		// 4
	CAMERA_TYPE_ONFOOT				// 5
}

static
		cd_ReportTick		[MAX_PLAYERS],
		cd_DetectDelay		[MAX_PLAYERS];
		
CameraDistanceCheck(playerid)
{
	if(
		//IsAutoSaving() ||
		IsPlayerDead(playerid) ||
		IsPlayerUnfocused(playerid) ||
		IsPlayerOnZipline(playerid) ||
		IsValidVehicle(GetPlayerSurfingVehicleID(playerid)) ||
		IsValidObject(GetPlayerSurfingObjectID(playerid)) ||
		GetPlayerInterior(playerid) != 0 ||
		GetPlayerVirtualWorld(playerid) != 0 ||
		!IsPlayerLoggedIn(playerid)) 
	{
		cd_DetectDelay[playerid] = GetTickCount();
		return;
	}

	if(GetPlayerInterior(playerid) != 0 || GetPlayerVirtualWorld(playerid) != 0) return;
	    
	if(GetTickCountDifference(GetTickCount(), GetPlayerVehicleExitTick(playerid)) < 5000) return;

	if(GetTickCountDifference(GetTickCount(), GetPlayerServerJoinTick(playerid)) < 20000) return;
		
	if(GetTickCountDifference(GetTickCount(), cd_DetectDelay[playerid]) < 5000) return;
		
	if(GetTickCountDifference(GetTickCount(), cd_ReportTick[playerid]) < 3000) return;

	new Float:vx, Float:vy, Float:vz;

	if(IsPlayerInAnyVehicle(playerid))
	{
		GetVehicleVelocity(GetPlayerVehicleID(playerid), vx, vy, vz);

		if(vz < -1.0) return;
	}
	else
	{
		GetPlayerVelocity(playerid, vx, vy, vz);

		if(vz < -1.0) return;
	}

	new
		Float:cx,
		Float:cy,
		Float:cz,
		Float:px,
		Float:py,
		Float:pz,
		Float:cx_vec,
		Float:cy_vec,
		Float:cz_vec,
		Float:distance,
		Float:cmp,
		type;

	GetPlayerCameraPos(playerid, cx, cy, cz);
	GetPlayerCameraFrontVector(playerid, cx_vec, cy_vec, cz_vec);

	if(IsAtDefaultPos(cx, cy, cz)) return;

	if(IsPlayerInAnyVehicle(playerid))
	{
		new cameramode = GetPlayerCameraMode(playerid);

		GetVehiclePos(GetPlayerVehicleID(playerid), px, py, pz);

		distance = Distance(px, py, pz, cx, cy, cz);

		if(cameramode == 56)
		{
			type = CAMERA_TYPE_INCAR_CINEMATIC;
			cmp = CAMERA_DISTANCE_INCAR_CINEMATIC;
		}
		else if(cameramode == 57)
		{
			type = CAMERA_TYPE_INCAR_CINEMATIC;
			cmp = CAMERA_DISTANCE_INCAR_CINEMATIC;
		}
		else if(cameramode == 15)
		{
			type = CAMERA_TYPE_INCAR_CINEMOVE;
			cmp = CAMERA_DISTANCE_INCAR_CINEMOVE;
		}
		else
		{
			if(vx + vy > 0.0)
			{
				type = CAMERA_TYPE_INCAR_MOVING;
				cmp = CAMERA_DISTANCE_INCAR_MOVING;
			}
			else
			{
				type = CAMERA_TYPE_INCAR;
				cmp = CAMERA_DISTANCE_INCAR;
			}
		}

		if(distance > cmp)
		{
			new
				name[MAX_PLAYER_NAME],
				reason[128],
				info[128];

			GetPlayerName(playerid, name, MAX_PLAYER_NAME);

			format(reason, sizeof(reason), " >  %s(%d) camera distance %.0f (incar, %d, %d at %.0f, %.0f, %.0f)", name, playerid, distance, type, cameramode, cx, cy, cz);
			format(info, sizeof(info), "%.1f, %.1f, %.1f, %.1f, %.1f, %.1f", cx, cy, cz, vx, vy, vz);
			//ReportPlayer(name, reason, -1, REPORT_TYPE_CAMDIST, px, py, pz, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), info);
			ChatMsgAdmins(3, YELLOW, reason);

			cd_ReportTick[playerid] = GetTickCount();
		}
	}
	else
	{
		new cameramode = GetPlayerCameraMode(playerid);

		GetPlayerPos(playerid, px, py, pz);

		if(IsAtDefaultPos(px, py, pz)) return;

		if(px == 1133.0 && py == -2038.0) return;

		if(px == 0.0 && py == 0.0 && pz == 0.0) return;

		if(-5.0 < (cx - 1093.0) < 5.0 && -5.0 < (cy - -2036.0) < 5.0 && -5.0 < (cz - 90.0) < 5.0) return;

		if(cx == 0.0 && cy == 0.0 && cz == 0.0) return;

		if(pz < -50.0 || cz < 50.0) return;

		type = CAMERA_TYPE_ONFOOT;
		distance = Distance(px, py, pz, cx, cy, cz);

		if(distance > CAMERA_DISTANCE_ONFOOT)
		{
			new
				name[MAX_PLAYER_NAME],
				reason[128],
				info[128];

			GetPlayerName(playerid, name, MAX_PLAYER_NAME);

			format(reason, sizeof(reason), "Camera distance from player %.0f (onfoot, %d, %d at %.0f, %.0f, %.0f)", distance, type, cameramode, cx, cy, cz);
			format(info, sizeof(info), "%.1f, %.1f, %.1f, %.1f, %.1f, %.1f", cx, cy, cz, cx_vec, cy_vec, cz_vec);
			ReportPlayer(name, reason, -1, REPORT_TYPE_CAMDIST, px, py, pz, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid), info);
			TimeoutPlayer(playerid, reason);

			cd_ReportTick[playerid] = GetTickCount();
		}
	}

	return;
}

/*==============================================================================

	Anti-Parkour

==============================================================================*/

public OnPlayerTurnUpsideDown(playerid, Float:angle){
    AC_KickPlayer(playerid, "Parkour Mod");
	return 1;
}

/*==============================================================================

	Anti-SpeedHack (Vehicle)

==============================================================================*/

IPacket:200(playerid, BitStream:bs){
	new inCarData[PR_InCarSync];
	BS_IgnoreBits(bs, 8);
	BS_ReadInCarSync(bs, inCarData);
	static Float:S;
	S = floatsqroot(floatpower(floatabs(inCarData[PR_velocity][0]), 2.0) + floatpower(floatabs(inCarData[PR_velocity][1]), 2.0) + floatpower(floatabs(inCarData[PR_velocity][2]), 2.0)) * 253.3;

	if(S > 350.0)
	{
	    if(!IsPlayerDead(playerid) &&
		   !gServerRestarting &&
		   GetPlayerWeapon(playerid) != WEAPON_PARACHUTE &&
		   IsPlayerSpawned(playerid) &&
			!IsPlayerKicked(playerid)){
		    if(GetVehicleModel(GetPlayerVehicleID(playerid)) != 476)
                AC_KickPlayer(playerid, "Speed Hack (Vehicle)");
		}
		//return 0;
	}
	return 1;
}

IPacket:207(playerid, BitStream:bs)
{
    new onFootData[PR_OnFootSync];
	BS_IgnoreBits(bs, 8);
	BS_ReadOnFootSync(bs, onFootData);

	// Anti Fly
	switch (onFootData[PR_animationId])
    {
        case 157, 159, 161:
        {
            if (!IsPlayerInAnyVehicle(playerid))
            {
                onFootData[PR_animationId] = 1189;
                onFootData[PR_velocity][0] = onFootData[PR_velocity][1] = onFootData[PR_velocity][2] = 0.0;

                BS_SetWriteOffset(bs, 8);
                BS_WriteOnFootSync(bs, onFootData);
            }
        }
    }
    
    //Anti Speed
    
    if(	IsValidVehicle(GetPlayerSurfingVehicleID(playerid)) ||
		IsValidObject(GetPlayerSurfingObjectID(playerid)) ||
		//IsAutoSaving() ||
		IsPlayerDead(playerid) ||
		IsPlayerUnfocused(playerid) ||
		IsPlayerOnZipline(playerid) ||
		!IsPlayerSpawned(playerid) ||
		onFootData[PR_animationId] == 1129 ||
		onFootData[PR_animationId] == 1130 ||
		onFootData[PR_animationId] == 1132)
		return 1;
    
	if(GetPlayerTotalVelocity(playerid) > 50.0)
	{
        SetPlayerVelocity(playerid, onFootData[PR_velocity][0] / 2, onFootData[PR_velocity][1] / 2, onFootData[PR_velocity][2]);
        return 0;
	}
	
	return 1;
}

public OnPlayerSuspectedForAimbot(playerid,hitid,weaponid,warnings)
{
    new
	    lastattacker,
		lastweapon;

	if(!IsPlayerCombatLogging(playerid, lastattacker, lastweapon))
    	AC_KickPlayer(playerid, "Suspeita de Aimbot");
    	
	return 1;
}

IPacket:206(playerid, BitStream:bs)
{
	new bulletData[PR_BulletSync];
	BS_IgnoreBits(bs, 8);
	BS_ReadBulletSync(bs, bulletData);
	if(!IsPlayerAdmin(playerid) && bulletData[PR_weaponId] == WEAPON_MINIGUN && GetPlayerWeapon(playerid) != WEAPON_MINIGUN)
	{
	    AC_KickPlayer(playerid, "Arma Minigun invisível");
		return 0;
	}
	return 1;
}

/*==============================================================================

	Vehicle Teleport

==============================================================================*/

static
		vt_MovedFar[MAX_VEHICLES],
		vt_MovedFarTick[MAX_VEHICLES],
		vt_MovedFarPlayer[MAX_VEHICLES];

public OnUnoccupiedVehicleUpdate(vehicleid, playerid, passenger_seat, Float:new_x, Float:new_y, Float:new_z, Float:vel_x, Float:vel_y, Float:vel_z)
{
	if(GetTickCountDifference(GetTickCount(), vt_MovedFarTick[vehicleid]) < 5000) return 1;

	if(GetTickCountDifference(GetTickCount(), GetPlayerSpawnTick(playerid)) < 15000) return 1;

	if(GetTickCountDifference(GetTickCount(), GetPlayerVehicleExitTick(playerid)) < 10000) return 1;

	if(GetTickCountDifference(GetTickCount(), GetVehicleLastUseTick(vehicleid)) < 5000) return 1;

	if(IsVehicleOccupied(vehicleid)) return 1;

    if(GetPlayerAdminLevel(playerid) > 0) return 1;

	new
		Float:x,
		Float:y,
		Float:z,
		Float:distance;

	GetVehiclePos(vehicleid, x, y, z);

	distance = Distance(x, y, z, new_x, new_y, new_z);

	if(IsNaN(distance))
	{
		RespawnVehicle(vehicleid);
		return 1;
	}

	if(20.0 < distance < 500.0)
	{
		new Float:distancetoplayer = 10000.0;

		vt_MovedFarPlayer[vehicleid] = GetClosestPlayerFromPoint(x, y, z, distancetoplayer);

		if(distancetoplayer < 10.0)
		{
			vt_MovedFar[vehicleid] = true;
			vt_MovedFarTick[vehicleid] = GetTickCount();

			foreach(new i : veh_Index) {
				if(GetVehicleTrailer(i) == vehicleid) return 1;
			}

			new
				name[MAX_PLAYER_NAME],
				vehicletype,
				vehiclename[MAX_VEHICLE_TYPE_NAME],
				reason[128],
				info[128];

			GetPlayerName(vt_MovedFarPlayer[vehicleid], name, MAX_PLAYER_NAME);
			vehicletype = GetVehicleType(vehicleid);
			GetVehicleTypeName(vehicletype, vehiclename);

			format(reason, sizeof(reason), "Teleportado a %s %.0fm", vehiclename, distance);

			format(info, sizeof(info), "%f, %f, %f", new_x, new_y, new_z);
			ReportPlayer(name, reason, -1, REPORT_TYPE_CARTELE, x, y, z, GetPlayerVirtualWorld(vt_MovedFarPlayer[vehicleid]), GetPlayerInterior(vt_MovedFarPlayer[vehicleid]), info);
			TimeoutPlayer(vt_MovedFarPlayer[vehicleid], reason);

			// RespawnVehicle(vehicleid);
			return 0;
		}
	}

	return 1;
}
