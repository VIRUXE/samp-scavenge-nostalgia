#include <YSI\y_hooks>

enum {
	PILL_TYPE_ANTIBIOTICS,
	PILL_TYPE_PAINKILL,
	PILL_TYPE_LSD,
	PILL_TYPE_DTPA // Diethylenetriamine pentaacetate
}

static
	pill_CurrentlyTaking[MAX_PLAYERS];

hook OnItemTypeDefined(uname[]) {
	if(!strcmp(uname, "Pills"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("Pills"), 1);
}

hook OnPlayerConnect(playerid) {
	pill_CurrentlyTaking[playerid] = -1;
}

hook OnItemCreate(itemid) {
	if(GetItemLootIndex(itemid) != -1)
		if(GetItemType(itemid) == item_Pills) SetItemExtraData(itemid, random(3));
}

hook OnItemNameRender(itemid, ItemType:itemtype) {
	if(itemtype == item_Pills) {
		switch(GetItemExtraData(itemid)) {
			case PILL_TYPE_ANTIBIOTICS:		SetItemNameExtra(itemid, "Antibióticos");
			case PILL_TYPE_PAINKILL:		SetItemNameExtra(itemid, "Analgésico");
			case PILL_TYPE_LSD:				SetItemNameExtra(itemid, "LSD");
			case PILL_TYPE_DTPA:			SetItemNameExtra(itemid, "Acido DTPA");
			default:						SetItemNameExtra(itemid, "Vazio");
		}
	}
}

hook OnPlayerUseItem(playerid, itemid) {
	if(GetItemType(itemid) == item_Pills) StartTakingPills(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	if(oldkeys & 16 && pill_CurrentlyTaking[playerid] != -1) StopTakingPills(playerid);

	return 1;
}

StartTakingPills(playerid) {
	pill_CurrentlyTaking[playerid] = GetPlayerItem(playerid);
	ApplyAnimation(playerid, "BAR", "dnk_stndM_loop", 3.0, 0, 1, 1, 0, 1000, 1);
	StartHoldAction(playerid, 1000);
}

StopTakingPills(playerid) {
	ClearAnimations(playerid);
	StopHoldAction(playerid);

	pill_CurrentlyTaking[playerid] = -1;
}

hook OnHoldActionFinish(playerid) {
	if(pill_CurrentlyTaking[playerid] != -1) {
		if(!IsValidItem(pill_CurrentlyTaking[playerid])) return Y_HOOKS_CONTINUE_RETURN_0;

		if(GetPlayerItem(playerid) != pill_CurrentlyTaking[playerid]) return Y_HOOKS_CONTINUE_RETURN_0;

		switch(GetItemExtraData(pill_CurrentlyTaking[playerid])) {
			case PILL_TYPE_ANTIBIOTICS: {
				SetPlayerInfectionIntensity(playerid, 0, 0);

				if(random(100) < 50)  SetPlayerInfectionIntensity(playerid, 1, 0);

				ApplyDrug(playerid, drug_Antibiotic);
			} 
			case PILL_TYPE_PAINKILL: {
				HealPlayer(playerid, 10.0);
				ApplyDrug(playerid, drug_Painkill);
			} 
			case PILL_TYPE_LSD: {
				ApplyDrug(playerid, drug_Lsd);

				SetPlayerTime(playerid, 22, 3);
				SetPlayerWeather(playerid, 33);
			} 
			case PILL_TYPE_DTPA: {
				// Temporariamente parar a infecao
				ApplyDrug(playerid, drug_DTPA);
			}
		}

		DestroyItem(pill_CurrentlyTaking[playerid]);

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDrugWearOff(playerid, drugtype) {
	if(drugtype == drug_Lsd) {
        new hour, minute;

		gettime(hour, minute);
		
		SetPlayerTime(playerid, hour, minute);
	    SetPlayerWeather(playerid, GetSettingInt("world/weather"));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}
