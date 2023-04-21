#include <YSI\y_hooks>

#define IDLE_FOOD_RATE (0.06)

hook OnPlayerScriptUpdate(playerid)
{
	if(IsPlayerOnAdminDuty(playerid) || !IsPlayerSpawned(playerid) || IsPlayerUnfocused(playerid))
		return;

	new
		E_MOVEMENT_TYPE:movementstate,
		Float:food = GetPlayerFP(playerid),
		intensity = GetPlayerInfectionIntensity(playerid, 0);

	if(food > 100.0) 
		food = 100.0;

	if(food < 0.0) 
		food = 0.0;

	if(food >= 19.8 && food <= 20.0 || food >= 9.8 && food <= 10.0) 
		ShowActionText(playerid, sprintf(ls(playerid, "FOODRATE"), food), 5000);

	if(food < 20.0) 
		SetPlayerHP(playerid, GetPlayerHP(playerid) - (20.0 - food) / 30.0);

	if(intensity)
		food -= IDLE_FOOD_RATE;

	GetPlayerMovementState(playerid, movementstate);

	switch(movementstate)
	{
		case E_MOVEMENT_TYPE_UNKNOWN:	food -= IDLE_FOOD_RATE;
		case E_MOVEMENT_TYPE_IDLE:		food -= IDLE_FOOD_RATE;
		case E_MOVEMENT_TYPE_FALLING:	food -= IDLE_FOOD_RATE;
		case E_MOVEMENT_TYPE_STOPPING:	food -= IDLE_FOOD_RATE;
		case E_MOVEMENT_TYPE_SWIMMING:	food -= IDLE_FOOD_RATE * 4.0;
		case E_MOVEMENT_TYPE_CLIMBING:	food -= IDLE_FOOD_RATE * 3.5;
		case E_MOVEMENT_TYPE_JUMPING:	food -= IDLE_FOOD_RATE * 3.2;
		case E_MOVEMENT_TYPE_SPRINTING:	food -= IDLE_FOOD_RATE * 2.2;
		case E_MOVEMENT_TYPE_DIVING:	food -= IDLE_FOOD_RATE * 2.2;
		case E_MOVEMENT_TYPE_LANDING:	food -= IDLE_FOOD_RATE * 2.0;
		case E_MOVEMENT_TYPE_RUNNING:	food -= IDLE_FOOD_RATE * 1.8;
		case E_MOVEMENT_TYPE_WALKING:	food -= IDLE_FOOD_RATE * 1.2;
		case E_MOVEMENT_TYPE_CROUCHING:	food -= IDLE_FOOD_RATE * 1.1;
		case E_MOVEMENT_TYPE_SITTING:	food -= IDLE_FOOD_RATE * 0.2;
	}

	if(!IsPlayerUnderDrugEffect(playerid, drug_Morphine) && !IsPlayerUnderDrugEffect(playerid, drug_Air))
	{
		if(food < 30.0)
		{
			if(!IsPlayerUnderDrugEffect(playerid, drug_Adrenaline))
				if(intensity == 0) SetPlayerDrunkLevel(playerid, 0);

				else SetPlayerDrunkLevel(playerid, 2000 + floatround((31.0 - food) * 300.0));
		}
		else if(intensity == 0) SetPlayerDrunkLevel(playerid, 0);
	}
	
	SetPlayerFP(playerid, food);

	return;
}
