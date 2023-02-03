/*OnPlayerWeaponShot Bug fix by RogueDrifter
Created on Feb the 4th 2018

Bug Describton according to SA-MP Wiki:
	*************************************************************************************************************
	* It is called as BULLET_HIT_TYPE_VEHICLE with the correct hitid (the hit player's vehicleid)			    *
	* if you are shooting a player which is in a vehicle. It won't be called as BULLET_HIT_TYPE_PLAYER at all.  *
	*************************************************************************************************************

This include will:
******************

	Call the OPWS callback only once for hittype BULLET_HIT_TYPE_PLAYER if it does damage the player and
	Call it BULLET_HIT_TYPE_VEHICLE if it doesn't damage the player. BUT due to paused players not getting
	Damage, this adds a new hittype #5 which is called if a player shoots a vehicle that has a player who
	is paused, you can either do this one on your own or exclude it from your anti cheat for false positives.
	****************************************************************
*/

#if defined _EOpwsFix_included
	#endinput
#endif

#define _EOpwsFix_included
#define BULLET_HIT_TYPE_PAUSED_DRIVER 5
#define BULLET_HIT_TYPE_PAUSED_PASSENGER 6

#include <a_samp>

enum E_eFix_OPWS_INFO
{
	eFixPauseTicks,

	bool:eFixPlayerDamaged,
	bool:eFixDesyncPassg,
	bool:eFixDoubleCFix,
	bool:eFixJustShot,

	Float:eFixShotX,
	Float:eFixShotY,
	Float:eFixShotZ,

	Float:eFixATypeHealth,
	Float:eFixBTypeHealth,

	Float:eFixATypeArmour,
	Float:eFixBTypeArmour
};

new
	eFix_Player[MAX_PLAYERS][E_eFix_OPWS_INFO];

#if defined eFix_OnPlayerWeaponShot
	forward eFix_OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ);
#endif

#if defined eFix_OnPlayerUpdate
	forward eFix_OnPlayerUpdate(playerid);
#endif

#if defined eFix_OnPlayerSpawn
	forward eFix_OnPlayerSpawn(playerid);
#endif

#if defined eFix_OnPlayerStateChange
	forward eFix_OnPlayerStateChange(playerid, newstate, oldstate);
#endif

#if defined eFix_OnPlayerConnect
	forward eFix_OnPlayerConnect(playerid);
#endif

#if defined eFix_OnPlayerDeath
	forward eFix_OnPlayerDeath(playerid, killerid, reason);
#endif

forward eFix_ResetHandler(handleid, caseid);
forward eFix_OpwsCheck(playerid, weaponid, vehicleid, Float:x, Float:y, Float:z, shooterid);
forward eFix_DesyncP(playerid, weaponid, vehicleid, Float:x, Float:y, Float:z, shooterid);

public OnPlayerConnect(playerid)
{
	eFix_Player[playerid][eFixPlayerDamaged] = false;
	eFix_Player[playerid][eFixDoubleCFix] = false;
	eFix_Player[playerid][eFixDesyncPassg] = false;
	eFix_Player[playerid][eFixJustShot] = false;

	#if defined eFix_OnPlayerConnect
	    return eFix_OnPlayerConnect(playerid);
	#else
	    return 1;
	#endif
}

public OnPlayerSpawn(playerid)
{
	eFix_Player[playerid][eFixDesyncPassg] = false;

	#if defined eFix_OnPlayerSpawn
	    return eFix_OnPlayerSpawn(playerid);
	#else
	    return 1;
	#endif
}

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	if(hittype == BULLET_HIT_TYPE_VEHICLE)
	{
		if(!eFix_Player[playerid][eFixJustShot]) SetTimerEx("eFix_ResetHandler", 650, false, "ii", playerid, 1);
		eFix_Player[playerid][eFixShotX]=fX;
		eFix_Player[playerid][eFixShotY]=fY;
		eFix_Player[playerid][eFixShotZ]=fZ;
		eFix_Player[playerid][eFixJustShot] = true;

        #if !defined foreach
            for(new i, j = GetPlayerPoolSize(); i <= j; i++)
            {
                if(GetPlayerVehicleID(i) == hitid && !eFix_Player[i][eFixDoubleCFix])
                    return SetTimerEx("eFix_OpwsCheck", 285, false, "dddfffd", i, weaponid, hitid, Float:fX, Float:fY, Float:fZ, playerid);
            }
        #else
            foreach (new i: Player)
            {
                if(GetPlayerVehicleID(i) == hitid && !eFix_Player[i][eFixDoubleCFix])
                    return SetTimerEx("eFix_OpwsCheck", 285, false, "dddfffd", i, weaponid, hitid, Float:fX, Float:fY, Float:fZ, playerid);
            }
        #endif
	}

	#if defined eFix_OnPlayerWeaponShot
	    return eFix_OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ);
	#else
	    return 1;
	#endif
}

public OnPlayerUpdate(playerid)
{
	eFix_Player[playerid][eFixPauseTicks] = GetTickCount();
	new E_State = GetPlayerState(playerid);

	if(E_State == 3 || E_State == 2 )
	{
		GetPlayerHealth(playerid, eFix_Player[playerid][eFixBTypeHealth]);
		GetPlayerArmour(playerid, eFix_Player[playerid][eFixBTypeArmour]);
		if(eFix_Player[playerid][eFixATypeHealth] > eFix_Player[playerid][eFixBTypeHealth] && !eFix_Player[playerid][eFixPlayerDamaged]
		&& eFix_Player[playerid][eFixBTypeArmour] == 0.0)
		{
			eFix_Player[playerid][eFixATypeHealth] = eFix_Player[playerid][eFixBTypeHealth];
			eFix_Player[playerid][eFixPlayerDamaged] = true;
			SetTimerEx("eFix_ResetHandler", 490, false, "ii", playerid, 2);
		}
		else if(eFix_Player[playerid][eFixBTypeHealth] <= 0.0)
		{
			eFix_Player[playerid][eFixATypeHealth] = eFix_Player[playerid][eFixBTypeHealth];
			eFix_Player[playerid][eFixPlayerDamaged] = true;
			SetTimerEx("eFix_ResetHandler", 490, false, "ii", playerid, 2);
		}
		else if(eFix_Player[playerid][eFixBTypeArmour] > 0.0)
		{
			if(eFix_Player[playerid][eFixATypeArmour] > eFix_Player[playerid][eFixBTypeArmour]
			&& !eFix_Player[playerid][eFixPlayerDamaged])
			{
				eFix_Player[playerid][eFixATypeArmour] = eFix_Player[playerid][eFixBTypeArmour];
				eFix_Player[playerid][eFixPlayerDamaged] = true;
				SetTimerEx("eFix_ResetHandler", 490, false, "ii", playerid, 2);
			}
		}
	}

	#if defined eFix_OnPlayerUpdate
	    return eFix_OnPlayerUpdate(playerid);
	#else
	    return 1;
	#endif
}

public OnPlayerDeath(playerid, killerid, reason)
{
	eFix_Player[playerid][eFixDesyncPassg] = true;

	#if defined eFix_OnPlayerDeath
	    return eFix_OnPlayerDeath(playerid, killerid, reason);
	#else
	    return 1;
	#endif
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
		if(newstate == 3 || newstate == 2 )
		{
			GetPlayerHealth(playerid, eFix_Player[playerid][eFixBTypeHealth]);
			GetPlayerArmour(playerid, eFix_Player[playerid][eFixBTypeArmour]);
			GetPlayerHealth(playerid, eFix_Player[playerid][eFixATypeHealth]);
			GetPlayerArmour(playerid, eFix_Player[playerid][eFixATypeArmour]);
		}

	#if defined eFix_OnPlayerStateChange
	    return eFix_OnPlayerStateChange(playerid, newstate, oldstate);
	#else
	    return 1;
	#endif
}

public eFix_ResetHandler(handleid, caseid)
{
	switch(caseid)
	{
		case 1: return eFix_Player[handleid][eFixJustShot]          = false;
		case 2: return eFix_Player[handleid][eFixPlayerDamaged]     = false;
		case 3: return eFix_Player[handleid][eFixDoubleCFix]        = false;
	}
	return 0;
}

public eFix_DesyncP(playerid,  weaponid, vehicleid, Float:x, Float:y, Float:z, shooterid)
{
	if(eFix_Player[playerid][eFixDesyncPassg])
	{
		return OnPlayerWeaponShot(shooterid, weaponid, 1, playerid, x, y, z);
	}
	else if(!eFix_Player[playerid][eFixDesyncPassg])
	{
		new Float:eFix_xx, Float:eFix_yy, Float:eFix_zz;
		GetPlayerPos(playerid, eFix_xx,eFix_yy,eFix_zz);

        #if !defined foreach
            for(new i, j = GetPlayerPoolSize(); i <= j; i++)
            {
                new eWep = GetPlayerWeapon(i);
                if(!IsPlayerConnected(i)) continue;

                if(eFix_IsAmmoable(eWep) && eFix_Player[i][eFixJustShot] && IsPlayerInRangeOfPoint(i, 50.0, eFix_xx, eFix_yy, eFix_zz)
                && IsPlayerInRangeOfPoint(playerid, 2.0, eFix_Player[i][eFixShotX], eFix_Player[i][eFixShotY], eFix_Player[i][eFixShotZ])
                && eFix_IsPAiming(i))
                {
                    return OnPlayerWeaponShot(i, eWep, BULLET_HIT_TYPE_PAUSED_PASSENGER, playerid, eFix_Player[i][eFixShotX], eFix_Player[i][eFixShotY], eFix_Player[i][eFixShotZ]);
                }
            }
        #else
            foreach (new i: Player)
            {
                new eWep = GetPlayerWeapon(i);
                if(!IsPlayerConnected(i)) continue;

                if(eFix_IsAmmoable(eWep) && eFix_Player[i][eFixJustShot] && IsPlayerInRangeOfPoint(i, 50.0, eFix_xx, eFix_yy, eFix_zz)
                && IsPlayerInRangeOfPoint(playerid, 2.0, eFix_Player[i][eFixShotX], eFix_Player[i][eFixShotY], eFix_Player[i][eFixShotZ])
                && eFix_IsPAiming(i))
                {
                    return OnPlayerWeaponShot(i, eWep, BULLET_HIT_TYPE_PAUSED_PASSENGER, playerid, eFix_Player[i][eFixShotX], eFix_Player[i][eFixShotY], eFix_Player[i][eFixShotZ]);
                }
            }
        #endif
	}
	return 1;
}

public eFix_OpwsCheck(playerid, weaponid, vehicleid, Float:x, Float:y, Float:z, shooterid)
{
	new Float:eFix_Health;
	GetPlayerHealth(playerid, eFix_Health);

	if(eFix_Player[playerid][eFixDesyncPassg]) return OnPlayerWeaponShot(shooterid, weaponid, 1, playerid, x, y, z);

	if(GetTickCount() > eFix_Player[playerid][eFixPauseTicks]+800)
	{
		if(GetPlayerState(playerid) == 3 ) return SetTimerEx("eFix_DesyncP", 150, false, "d", playerid,  weaponid, vehicleid, Float:x, Float:y, Float:z, shooterid);
		return OnPlayerWeaponShot(shooterid, weaponid, BULLET_HIT_TYPE_PAUSED_DRIVER, playerid, x, y, z);
	}
	else
	{
		if(eFix_Player[playerid][eFixPlayerDamaged] || eFix_Health <= 0.0)
		    return OnPlayerWeaponShot(shooterid, weaponid, 1, playerid, x, y, z);

		else if(!eFix_Player[playerid][eFixPlayerDamaged])
		{
			return
			eFix_Player[playerid][eFixDoubleCFix] = true, OnPlayerWeaponShot(shooterid, weaponid, 2, vehicleid, x, y, z),
			SetTimerEx("eFix_ResetHandler", 20, false, "ii", playerid, 3);
		}
	}
	return 1;
}

static eFix_IsAmmoable(weaponid)
	return (22 <= weaponid <= 34 || weaponid == 38);

static eFix_IsPAiming(playerid)
{
	switch(GetPlayerAnimationIndex(playerid))
	{
		case 1160, 1163, 1167, 1365, 1643, 1453, 220: return 1;
	}
	return 0;
}

#if defined _ALS_OnPlayerStateChange
  #undef OnPlayerStateChange
#else
	#define _ALS_OnPlayerStateChange
#endif
#define OnPlayerStateChange eFix_OnPlayerStateChange

#if defined _ALS_OnPlayerUpdate
  #undef OnPlayerUpdate
#else
	#define _ALS_OnPlayerUpdate
#endif
#define OnPlayerUpdate eFix_OnPlayerUpdate

#if defined _ALS_OnPlayerWeaponShot
  #undef OnPlayerWeaponShot
#else
	#define _ALS_OnPlayerWeaponShot
#endif
#define OnPlayerWeaponShot eFix_OnPlayerWeaponShot

#if defined _ALS_OnPlayerConnect
  #undef OnPlayerConnect
#else
	#define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect eFix_OnPlayerConnect

#if defined _ALS_OnPlayerDeath
  #undef OnPlayerDeath
#else
	#define _ALS_OnPlayerDeath
#endif
#define OnPlayerDeath eFix_OnPlayerDeath

#if defined _ALS_OnPlayerSpawn
  #undef OnPlayerSpawn
#else
	#define _ALS_OnPlayerSpawn
#endif
#define OnPlayerSpawn eFix_OnPlayerSpawn
