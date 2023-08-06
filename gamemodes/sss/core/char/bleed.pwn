#include <YSI\y_hooks>

static Float:bld_BleedRate[MAX_PLAYERS];

hook OnPlayerScriptUpdate(playerid) {
	if(!IsPlayerSpawned(playerid) || IsPlayerOnAdminDuty(playerid)) {
        RemovePlayerAttachedObject(playerid, ATTACHSLOT_BLOOD);
        return;
    }

	if(IsNaN(bld_BleedRate[playerid]) || bld_BleedRate[playerid] < 0.0) bld_BleedRate[playerid] = 0.0;

	if(bld_BleedRate[playerid] > 0.0) {
		new Float:playerHealthPoints = GetPlayerHP(playerid);

		if(frandom(1.0) < 0.7) {
			SetPlayerHP(playerid, playerHealthPoints - bld_BleedRate[playerid]);

			if(GetPlayerHP(playerid) < 0.1) SetPlayerHP(playerid, 0.0);
		}

		/*
			Slow bleeding based on health and wound count. Less wounds means
			faster degradation of bleed rate. As blood rate drops, the bleed
			rate will slow down faster (pseudo blood pressure). Results in a
			bleed-out that slows down faster over time (only subtly). No wounds
			will automatically stop the bleed rate due to the nature of the
			formula (however this is still intentional).
		*/
		if(random(100) < 50) bld_BleedRate[playerid] -= (((((100.0 - playerHealthPoints) / 360.0) * bld_BleedRate[playerid]) / GetPlayerWounds(playerid)) / 100.0);

		if(debug_conditional(\"gamemodes/sss/core/char/bleed.pwn\", 1))
			ShowActionText(playerid, sprintf("HP: %f Sangramento: %f~n~Feridas %d Sangramento lento: %f", playerHealthPoints, bld_BleedRate[playerid], GetPlayerWounds(playerid)));

		if(IsPlayerInAnyVehicle(playerid)) { // Remove o sangue se estiver dentro de um veículo
			RemovePlayerAttachedObject(playerid, ATTACHSLOT_BLOOD);
		} else if(IsPlayerAttachedObjectSlotUsed(playerid, ATTACHSLOT_BLOOD) && frandom(0.1) < 0.1 - bld_BleedRate[playerid]) { // Remove o sangue se a taxa for quase nula
			RemovePlayerAttachedObject(playerid, ATTACHSLOT_BLOOD);
		} else if(frandom(0.1) < bld_BleedRate[playerid]) {
			SetPlayerAttachedObject(playerid, ATTACHSLOT_BLOOD, 18706, 1,  0.088999, 0.020000, 0.044999,  0.088999, 0.020000, 0.044999,  1.179000, 1.510999, 0.005000);
		}
	} else {
		if(IsPlayerAttachedObjectSlotUsed(playerid, ATTACHSLOT_BLOOD)) RemovePlayerAttachedObject(playerid, ATTACHSLOT_BLOOD);

		HealPlayer(playerid, 0.001925925 * GetPlayerFP(playerid) * (GetPlayerInfectionIntensity(playerid, INFECT_TYPE_WOUND) ? 0.5 : 1.0));

		if(bld_BleedRate[playerid] < 0.0) bld_BleedRate[playerid] = 0.0;
	}

	if(IsPlayerUnderDrugEffect(playerid, drug_Morphine)) {
		SetPlayerDrunkLevel(playerid, 2200);

		if(random(100) < 80) HealPlayer(playerid, 0.5);
	}

	return;
}

stock SetPlayerBleedRate(playerid, Float:rate) {
	if(!IsPlayerConnected(playerid)) return 0;

	bld_BleedRate[playerid] = rate;

	return 1;
}

forward Float:GetPlayerBleedRate(playerid);
stock Float:GetPlayerBleedRate(playerid) {
	if(!IsPlayerConnected(playerid)) return 0.0;

	return bld_BleedRate[playerid];
}
