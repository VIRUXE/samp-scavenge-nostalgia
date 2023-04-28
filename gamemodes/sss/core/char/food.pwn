#include <YSI\y_hooks>

#define IDLE_FOOD_RATE (0.013)

hook OnPlayerScriptUpdate(playerid)
{
	if(
		IsPlayerOnAdminDuty(playerid) || 
		!IsPlayerSpawned(playerid) ||
		IsPlayerInTutorial(playerid)
	) return;

	new
		intensity = GetPlayerInfectionIntensity(playerid, 0),
		animidx   = GetPlayerAnimationIndex(playerid),
		k, ud, lr,
		Float: food;

	GetPlayerKeys(playerid, k, ud, lr);
	food = GetPlayerFP(playerid);

	if(food < 0.0) food   = 0.0;
	if(food > 100.0) food = 100.0;
	if(food < 20.0) SetPlayerHP(playerid, GetPlayerHP(playerid) - (20.0 - food) / 30.0);

	if(food >= 19.8 && food <= 20.0 || food >= 9.8 && food <= 10.0) 
		ShowActionText(playerid, sprintf(ls(playerid, "player/health/dieing/food"), food), 5000);

	if(intensity) food -= IDLE_FOOD_RATE;

	if   (animidx == 43) food     -= IDLE_FOOD_RATE * 0.2;  // Sitting
	else if(animidx == 1159) food -= IDLE_FOOD_RATE * 1.1;  // Crouching
	else if(animidx == 1195) food -= IDLE_FOOD_RATE * 3.2;  // Jumping	
	else if(animidx == 1231) { // Running
		if   (k & KEY_WALK) food     -= IDLE_FOOD_RATE * 1.2;  // Walking
		else if(k & KEY_SPRINT) food -= IDLE_FOOD_RATE * 2.2;  // / Sprinting
		else if(k & KEY_JUMP) food   -= IDLE_FOOD_RATE * 3.2;  // Jump
		else food                    -= IDLE_FOOD_RATE * 2.0;  // Idle
	} else food -= IDLE_FOOD_RATE;

	if(!IsPlayerUnderDrugEffect(playerid, drug_Morphine) && !IsPlayerUnderDrugEffect(playerid, drug_Air)) {
		if(food < 30.0) {
			if(!IsPlayerUnderDrugEffect(playerid, drug_Adrenaline))
				SetPlayerDrunkLevel(playerid, intensity == 0 ? 0 : 2000 + floatround((31.0 - food) * 300.0));
		}
		else if(intensity == 0) SetPlayerDrunkLevel(playerid, 0);
	}

	if(food < 20.0)
		SetPlayerHP(playerid, GetPlayerHP(playerid) - (20.0 - food) / 30.0);
	
	SetPlayerFP(playerid, food);

	return;
}
