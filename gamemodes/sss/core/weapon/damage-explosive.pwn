#include <YSI\y_hooks>


static
		// Always for targetid
Float:	dmg_ReturnBleedrate[MAX_PLAYERS],
Float:	dmg_ReturnKnockMult[MAX_PLAYERS];


forward OnPlayerExplosiveDmg(playerid, Float:bleedrate, Float:knockmult);


hook OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{


	if(weaponid == 51)
		_DoExplosiveDamage(issuerid, playerid, amount);

	return 1;
}

_DoExplosiveDamage(playerid, targetid, Float:multiplier)
{
	if(IsPlayerOnAdminDuty(playerid) || IsPlayerOnAdminDuty(targetid))
		return 0;

    /*if(strfind(GetPlayerClan(targetid), GetPlayerClan(playerid), true) != -1 &&
		strfind(GetPlayerClan(playerid), "Nenhum", true) == -1)
		return 0;*/
		
	new
		Float:bleedrate = 0.5 * (multiplier / 80.0),
		Float:knockmult = 150.0 + multiplier;

	dmg_ReturnBleedrate[targetid] = bleedrate;
	dmg_ReturnKnockMult[targetid] = knockmult;

	if(CallLocalFunction("OnPlayerExplosiveDmg", "dfd", targetid, bleedrate, knockmult))
		return 0;

	if(dmg_ReturnBleedrate[targetid] != bleedrate)
		bleedrate = dmg_ReturnBleedrate[targetid];

	if(dmg_ReturnKnockMult[targetid] != knockmult)
		knockmult = dmg_ReturnKnockMult[targetid];

	PlayerInflictWound(playerid, targetid, E_WOUND_BURN, bleedrate, knockmult, NO_CALIBRE, random(2) ? (BODY_PART_TORSO) : (random(2) ? (BODY_PART_RIGHT_LEG) : (BODY_PART_LEFT_LEG)), "Explosão");

	return 1;
}

stock DMG_EXPLOSIVE_SetBleedRate(targetid, Float:bleedrate)
{
	if(!IsPlayerConnected(targetid))
		return 0;

	dmg_ReturnBleedrate[targetid] = bleedrate;

	return 1;
}

stock DMG_EXPLOSIVE_SetKnockMult(targetid, knockmult)
{
	if(!IsPlayerConnected(targetid))
		return 0;

	dmg_ReturnKnockMult[targetid] = knockmult;

	return 1;
}
