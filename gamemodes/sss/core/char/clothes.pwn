#include <YSI\y_hooks>

#define MAX_SKIN_NAME	(32)

enum E_SKIN_DATA {
			skin_model,
			skin_name[MAX_SKIN_NAME],
			skin_gender,
Float:		skin_lootSpawnChance,
			skin_canWearHats,
			skin_canWearMasks
}


static
			skin_Total,
			skin_Data[MAX_SKINS][E_SKIN_DATA],
			skin_CurrentSkin[MAX_PLAYERS],
			skin_CurrentlyUsing[MAX_PLAYERS];


hook OnItemTypeDefined(uname[]) {
	if(!strcmp(uname, "Clothes")) SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("Clothes"), 1);
}

hook OnPlayerConnect(playerId) {
	skin_CurrentlyUsing[playerId] = INVALID_ITEM_ID;
}

DefineClothesType(modelid, name[MAX_SKIN_NAME], gender, Float:spawnchance, bool:wearhats, bool:wearmasks) {
	skin_Data[skin_Total][skin_model]           = modelid;
	skin_Data[skin_Total][skin_name]            = name;
	skin_Data[skin_Total][skin_gender]          = gender;
	skin_Data[skin_Total][skin_lootSpawnChance] = spawnchance;
	skin_Data[skin_Total][skin_canWearHats]     = wearhats;
	skin_Data[skin_Total][skin_canWearMasks]    = wearmasks;

	return skin_Total++;
}

hook OnItemCreate(itemId) {
	if(GetItemType(itemId) == item_Clothes) {
		new
			list[MAX_SKINS],
			idx,
			skinId;

		for(new i; i < skin_Total; i++) {
			if(frandom(1.0) < skin_Data[i][skin_lootSpawnChance])
				list[idx++] = i;
		}

		skinId = list[random(idx)];

		while(skinId == 287) skinId = list[random(idx)];

		SetItemExtraData(itemId, skinId);
	}

	return 1;
}

hook OnItemNameRender(itemId, ItemType:itemType) {
	if(itemType == item_Clothes)
		SetItemNameExtra(itemId, sprintf("%s (%s)", skin_Data[GetItemExtraData(itemId)][skin_name], skin_Data[GetItemExtraData(itemId)][skin_gender] == GENDER_MALE ? "Masculina" : "Feminina"));

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerId, newKeys, oldKeys) {
	if(newKeys == 16) {
		new itemId = GetPlayerItem(playerId);

		if(GetItemType(itemId) == item_Clothes) {
			if(skin_Data[GetItemExtraData(itemId)][skin_gender] == GetPlayerGender(playerId)) {
				if(GetPlayerSkin(playerId) == 287)
					ShowActionText(playerId, ls(playerId, "item/clothes/invalid-skin"), 3000);
				else
					StartUsingClothes(playerId, itemId);
			} else
				ShowActionText(playerId, ls(playerId, "item/clothes/invalid-gender"), 3000, 130);
		}
	}

	if(oldKeys == 16)
		if(skin_CurrentlyUsing[playerId] != INVALID_ITEM_ID) StopUsingClothes(playerId);

	return 1;
}

StartUsingClothes(playerId, itemId) {
	StartHoldAction(playerId, 3000);
	CancelPlayerMovement(playerId);
	skin_CurrentlyUsing[playerId] = itemId;
}

StopUsingClothes(playerId) {
	if(skin_CurrentlyUsing[playerId] != INVALID_ITEM_ID) {
		StopHoldAction(playerId);
		ClearAnimations(playerId);
		skin_CurrentlyUsing[playerId] = INVALID_ITEM_ID;
	}
}

hook OnHoldActionFinish(playerId) {
	if(skin_CurrentlyUsing[playerId] != INVALID_ITEM_ID) {
		new currentclothes = skin_CurrentSkin[playerId];
		SetPlayerClothes(playerId, GetItemExtraData(skin_CurrentlyUsing[playerId]));
		SetItemExtraData(skin_CurrentlyUsing[playerId], currentclothes);
		StopUsingClothes(playerId);

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

stock IsValidClothes(skinId) {
	if(!(0 <= skinId < skin_Total)) return 0;

	return 1;
}

stock GetPlayerClothes(playerId) {
	if(!(0 <= playerId < MAX_PLAYERS)) return 0;

	return skin_CurrentSkin[playerId];
}

stock SetPlayerClothes(playerId, skinId) {
	if(!(0 <= skinId < skin_Total)) return 0;

	SetPlayerSkin(playerId, skin_Data[skinId][skin_model]);
	skin_CurrentSkin[playerId] = skinId;

    SetPlayerMaskItem(playerId, GetPlayerMaskItem(playerId));
    SetPlayerHatItem(playerId, GetPlayerHatItem(playerId));
	return 1;
}

stock GetClothesModel(skinId) {
	if(!(0 <= skinId < skin_Total)) return -1;

	return skin_Data[skinId][skin_model];
}

stock GetClothesName(skinId, name[]) {
	if(!(0 <= skinId < skin_Total)) return 0;

	name[0] = EOS;
	strcat(name, skin_Data[skinId][skin_name], MAX_SKIN_NAME);

	return 1;
}

stock GetClothesGender(skinId) {
	if(!(0 <= skinId < skin_Total)) return -1;

	return skin_Data[skinId][skin_gender];
}

stock GetClothesHatStatus(skinId) {
	if(!(0 <= skinId < skin_Total)) return false;

	return skin_Data[skinId][skin_canWearHats];
}

stock GetClothesMaskStatus(skinId) {
	if(!(0 <= skinId < skin_Total)) return false;

	return skin_Data[skinId][skin_canWearMasks];
}