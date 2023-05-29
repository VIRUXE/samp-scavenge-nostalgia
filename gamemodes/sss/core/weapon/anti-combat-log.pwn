


static
	combatlog_LastAttacked[MAX_PLAYERS] = {INVALID_PLAYER_ID, ...},
	combatlog_LastAttacker[MAX_PLAYERS] = {INVALID_PLAYER_ID, ...},
	combatlog_LastItem[MAX_PLAYERS] = {INVALID_ITEM_ID, ...};


hook OnPlayerShootPlayer(playerid, targetid, bodypart, Float:bleedrate, Float:knockmult, Float:bulletvelocity, Float:distance)
{


	_CombatLogHandleDamage(playerid, targetid, GetPlayerItem(playerid));

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerMeleePlayer(playerid, targetid, Float:bleedrate, Float:knockmult)
{


	_CombatLogHandleDamage(playerid, targetid, GetPlayerItem(playerid));

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerExplosiveDmg(playerid, Float:bleedrate, Float:knockmult)
{


	_CombatLogHandleDamage(INVALID_PLAYER_ID, playerid, INVALID_ITEM_ID);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerVehicleCollide(playerid, targetid, Float:bleedrate, Float:knockmult)
{


	_CombatLogHandleDamage(playerid, targetid, INVALID_ITEM_ID);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_CombatLogHandleDamage(playerid, targetid, itemid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(IsPlayerConnected(playerid))
	{
		combatlog_LastAttacked[playerid] = targetid;
		combatlog_LastAttacker[targetid] = playerid;
	}
	else combatlog_LastAttacker[targetid] = INVALID_PLAYER_ID;

	combatlog_LastItem[targetid] = itemid;

	return 1;
}

hook OnPlayerSpawn(playerid)
{


	combatlog_LastAttacker[playerid] = INVALID_PLAYER_ID;
	combatlog_LastItem[playerid] = INVALID_ITEM_ID;
}

hook OnPlayerDisconnect(playerid, reason)
{


	if(combatlog_LastAttacked[playerid] != INVALID_PLAYER_ID)
	{
		combatlog_LastAttacker[combatlog_LastAttacked[playerid]] = INVALID_PLAYER_ID;
		combatlog_LastItem[combatlog_LastAttacked[playerid]] = INVALID_ITEM_ID;
		combatlog_LastAttacked[playerid] = INVALID_PLAYER_ID;
	}
}

stock IsPlayerCombatLogging(playerid, &lastattacker, &lastweapon)
{
	if(!IsPlayerConnected(combatlog_LastAttacker[playerid]))
	    return 0;
	    
    if(gServerRestarting)
        return 0;
        
	if(GetTickCountDifference(GetTickCount(), GetPlayerTookDamageTick(playerid)) < _:gCombatLogWindow * 1000)
	{
		lastattacker = combatlog_LastAttacker[playerid];
		lastweapon = combatlog_LastItem[playerid];

		return 1;
	}

	return 0;
}
