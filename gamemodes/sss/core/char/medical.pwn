#include <YSI\y_hooks>

#define HEAL_PROGRESS_MAX (4000)
#define REVIVE_PROGRESS_MAX (6000)

static med_HealTarget[MAX_PLAYERS];

hook OnPlayerConnect(playerid) {
	med_HealTarget[playerid] = INVALID_PLAYER_ID;
}

hook OnItemTypeDefined(uname[]) {
	if(!strcmp(uname, "DoctorBag"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("DoctorBag"), 2);
}

hook OnItemCreate(itemId) {
	if(GetItemLootIndex(itemId) != -1) {
		if(GetItemType(itemId) == item_DoctorBag) {
			SetItemArrayDataAtCell(itemId, 1 + random(3), 0, 1);

			switch(random(4)) {
				case 0: SetItemArrayDataAtCell(itemId, drug_Antibiotic, 1, 1);
				case 1: SetItemArrayDataAtCell(itemId, drug_Painkill, 1, 1);
				case 2: SetItemArrayDataAtCell(itemId, drug_Morphine, 1, 1);
				case 3: SetItemArrayDataAtCell(itemId, drug_Adrenaline, 1, 1);
			}
		}
	}
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	new ItemType:itemType = GetItemType(GetPlayerItem(playerid));

	if(itemType == item_Medkit || itemType == item_Bandage || itemType == item_DoctorBag || itemType == item_AntiSepBandage) {
		if(newkeys == 16) {
			if(IsPlayerKnockedOut(playerid)) return 0;

			med_HealTarget[playerid] = playerid;
			foreach(new i : Character) {
				if(IsPlayerInPlayerArea(playerid, i) && !IsPlayerInAnyVehicle(i))
					med_HealTarget[playerid] = i;
			}

			PlayerStartHeal(playerid, med_HealTarget[playerid]);
		}

		if(oldkeys == 16) PlayerStopHeal(playerid);
	}

	return 1;
}


PlayerStartHeal(playerid, target) {
	new duration = HEAL_PROGRESS_MAX;

	med_HealTarget[playerid] = target;

	if(target != playerid) {
		if(IsPlayerKnockedOut(target)) {
			ApplyAnimation(playerid, "MEDIC", "CPR", 4.0, 1, 0, 0, 0, 0);
			duration = REVIVE_PROGRESS_MAX;
		} else
			ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);

		SetPlayerProgressBarMaxValue(target, ActionBar, duration);
		SetPlayerProgressBarValue(target, ActionBar, 0.0);
	} else
		ApplyAnimation(playerid, "SWEET", "Sweet_injuredloop", 4.0, 1, 0, 0, 0, 0);

	StartHoldAction(playerid, duration);
}

PlayerStopHeal(playerid) {
	if(med_HealTarget[playerid] != INVALID_PLAYER_ID) {
		if(med_HealTarget[playerid] != playerid) HidePlayerProgressBar(med_HealTarget[playerid], ActionBar);

		StopHoldAction(playerid);
		ClearAnimations(playerid);

		med_HealTarget[playerid] = INVALID_PLAYER_ID;
	}
}

hook OnItemNameRender(itemId, ItemType:itemtype) {
	if(itemtype == item_DoctorBag) {
		new data[2];

		GetItemArrayData(itemId, data);

		if(data[0] > 0) {
			new name[MAX_DRUG_NAME];

			GetDrugName(data[1], name);

			SetItemNameExtra(itemId, sprintf("%d/3, %s", data, name));
		}
	}
}

hook OnHoldActionUpdate(playerid, progress) {
	if(med_HealTarget[playerid] != INVALID_PLAYER_ID) {
		if(med_HealTarget[playerid] != playerid) {
			if(!IsPlayerInPlayerArea(playerid, med_HealTarget[playerid])) {
				StopHoldAction(playerid);
				return Y_HOOKS_BREAK_RETURN_1;
			}

			new progresscap = HEAL_PROGRESS_MAX;

			if(IsPlayerKnockedOut(med_HealTarget[playerid])) progresscap = REVIVE_PROGRESS_MAX;

			SetPlayerToFacePlayer(playerid, med_HealTarget[playerid]);
			SetPlayerProgressBarMaxValue(med_HealTarget[playerid], ActionBar, progresscap);
			SetPlayerProgressBarValue(med_HealTarget[playerid], ActionBar, progress);
			ShowPlayerProgressBar(med_HealTarget[playerid], ActionBar);
		}

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnHoldActionFinish(playerid) {
	if(med_HealTarget[playerid] != INVALID_PLAYER_ID) {
		new
			itemId,
			ItemType:itemType;

		itemId   = GetPlayerItem(playerid);
		itemType = GetItemType(itemId);

		if(itemType == item_Bandage) {
			new Float:bleedRate = GetPlayerBleedRate(med_HealTarget[playerid]);

			if(bleedRate > 0.0) {
				bleedRate -= bleedRate * floatpower(1.0091 - bleedRate, 2.1);
				bleedRate = (bleedRate < 0.00001) ? 0.0 : bleedRate;

				if(random(100) < 33) {
					SetPlayerInfectionIntensity(playerid, 1, 1);
					ShowActionText(playerid, ls(playerid, "player/health/wounds/infected"), 5000);
				}

				ChatMsg(playerid, YELLOW, "player/reducebleed", GetPlayerBleedRate(med_HealTarget[playerid]), bleedRate);

				SetPlayerBleedRate(med_HealTarget[playerid], bleedRate);

				DestroyItem(itemId);
			}
		} else if(itemType == item_Medkit) {
			new
				Float:bleedRate = GetPlayerBleedRate(med_HealTarget[playerid]),
				woundCount = (med_HealTarget[playerid] == playerid) ? 1 + random(2) : 2 + random(2);

			if(bleedRate > 0.0) {
				bleedRate -= bleedRate * floatpower(1.0091 - bleedRate, 2.1);
				bleedRate = (bleedRate < 0.00001) ? 0.0 : bleedRate;

				ChatMsg(playerid, YELLOW, "player/reducebleed", GetPlayerBleedRate(med_HealTarget[playerid]), bleedRate);
				SetPlayerBleedRate(med_HealTarget[playerid], bleedRate);
			}

			if(woundCount > 0) {
				RemovePlayerWounds(med_HealTarget[playerid], woundCount);
				ShowActionText(playerid, sprintf(ls(playerid, "player/health/wounds/cured"), woundCount), 5000);

				DestroyItem(itemId);
			}
		} else if(itemType == item_DoctorBag) {
			new woundCount = (med_HealTarget[playerid] == playerid) ? 1 + random(2) : 3 + random(3);

			if(woundCount > 0) {
				RemovePlayerWounds(med_HealTarget[playerid], woundCount);
				ShowActionText(playerid, sprintf(ls(playerid, "player/health/wounds/cured"), woundCount), 5000);
			}

			SetPlayerBleedRate(med_HealTarget[playerid], 0.0);
			SetPlayerInfectionIntensity(playerid, 1, 0);

			new data[2];

			GetItemArrayData(itemId, data);

			if(data[0] > 1)
				SetItemArrayDataAtCell(itemId, data[0] - 1, 0);
			else
				DestroyItem(itemId);

			ApplyDrug(med_HealTarget[playerid], data[1]);
		} else if(itemType == item_AntiSepBandage) {
			new Float:bleedRate = GetPlayerBleedRate(med_HealTarget[playerid]);

			if(bleedRate > 0.0) {
				bleedRate -= bleedRate * floatpower(1.0091 - bleedRate, 2.1);
				bleedRate = (bleedRate < 0.00001) ? 0.0 : bleedRate;

				ChatMsg(playerid, YELLOW, "player/reducebleed", GetPlayerBleedRate(med_HealTarget[playerid]), bleedRate);

				SetPlayerBleedRate(med_HealTarget[playerid], bleedRate);
				DestroyItem(itemId);
			}

			SetPlayerInfectionIntensity(playerid, 1, 0);
		}

		if(med_HealTarget[playerid] != playerid && IsPlayerKnockedOut(med_HealTarget[playerid])) WakeUpPlayer(med_HealTarget[playerid]);
		    
		PlayerStopHeal(playerid);

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}