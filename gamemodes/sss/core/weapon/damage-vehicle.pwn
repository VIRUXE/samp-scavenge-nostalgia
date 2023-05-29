#include <YSI\y_hooks>


static
Float:	dmg_VehicleVelocityKnockMult,
Float:	dmg_VehicleVelocityBleedMult,
		// Always for targetid
Float:	dmg_ReturnBleedrate[MAX_PLAYERS],
Float:	dmg_ReturnKnockMult[MAX_PLAYERS];


forward OnPlayerVehicleCollide(playerid, targetid, Float:bleedrate, Float:knockmult);


hook OnScriptInit()
{
	new Node:vehicle, Node:node;

	JSON_GetObject(Settings, "vehicle", vehicle);
	JSON_GetObject(vehicle, "damage", node);

	JSON_GetFloat(node, "knock-mult", dmg_VehicleVelocityKnockMult);
	JSON_GetFloat(node, "bleed-mult", dmg_VehicleVelocityBleedMult);

	log("[SETTINGS][VEHICLE] Knock Mult: %f", dmg_VehicleVelocityKnockMult);
	log("[SETTINGS][VEHICLE] Bleed Mult: %f", dmg_VehicleVelocityBleedMult);
}

hook OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{


	if(weaponid == 49)
		_DoVehicleCollisionDamage(issuerid, playerid);

	return 1;
}

_DoVehicleCollisionDamage(playerid, targetid)
{
	if(IsPlayerOnAdminDuty(playerid) || IsPlayerOnAdminDuty(targetid))
		return 0;

    /*if(strfind(GetPlayerClan(targetid), GetPlayerClan(playerid), true) != -1 &&
		strfind(GetPlayerClan(playerid), "Nenhum", true) == -1)
		return 0;*/
		
	new
		Float:velocity,
		Float:bleedrate,
		Float:knockmult = 1.0;

	velocity = GetPlayerTotalVelocity(playerid);
	bleedrate = (0.04 * (velocity * 0.02)) * dmg_VehicleVelocityBleedMult;

	if(velocity > 55.0 && frandom(velocity) > 55.0)
		KnockOutPlayer(targetid, floatround((1000 + ((velocity * 0.05) * 1000)) * dmg_VehicleVelocityKnockMult));

	dmg_ReturnBleedrate[targetid] = bleedrate;
	dmg_ReturnKnockMult[targetid] = knockmult;

	if(CallLocalFunction("OnPlayerVehicleCollide", "ddff", playerid, targetid, bleedrate, knockmult))
		return 0;

	if(dmg_ReturnBleedrate[targetid] != bleedrate)
		bleedrate = dmg_ReturnBleedrate[targetid];

	if(dmg_ReturnKnockMult[targetid] != knockmult)
		knockmult = dmg_ReturnKnockMult[targetid];

	PlayerInflictWound(playerid, targetid, E_WOUND_MELEE, bleedrate, 0, NO_CALIBRE, random(2) ? (BODY_PART_TORSO) : (random(2) ? (BODY_PART_RIGHT_LEG) : (BODY_PART_LEFT_LEG)), "Colisão");

	return 1;
}

stock DMG_VEHICLE_SetBleedRate(targetid, Float:bleedrate)
{
	if(!IsPlayerConnected(targetid))
		return 0;

	dmg_ReturnBleedrate[targetid] = bleedrate;

	return 1;
}

stock DMG_VEHICLE_SetKnockMult(targetid, Float:knockmult)
{
	if(!IsPlayerConnected(targetid))
		return 0;

	dmg_ReturnKnockMult[targetid] = knockmult;

	return 1;
}
