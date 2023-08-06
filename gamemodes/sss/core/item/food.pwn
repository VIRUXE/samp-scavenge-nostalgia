#include <YSI\y_hooks>

#define MAX_FOOD_ITEM 64

enum e_FOOD_ITEM_DATA {
			food_cooked,
			food_amount,
			food_subType
}

enum E_FOOD_DATA {
ItemType:	food_itemType,
			food_maxBites,
Float:		food_biteValue,
			food_canCook,
			food_canRawInfect,
			food_destroyOnEnd
}


static
			food_Data[MAX_FOOD_ITEM][E_FOOD_DATA],
			food_ItemTypeFoodType[ITM_MAX_TYPES] = {-1, ...},
			food_Total,
			food_CurrentItem[MAX_PLAYERS];

forward OnPlayerEat(playerid, itemid);
forward OnPlayerEaten(playerid, itemid);

hook OnPlayerEat(playerid, itemid) {
    PlayerPlaySound(playerid, 32200, 0.0, 0.0, 0.0);
}

hook OnPlayerConnect(playerid) {
	food_CurrentItem[playerid] = -1;
}

DefineFoodItem(ItemType:itemType, maxBites, Float:biteValue, canCook, canRawInfect, destroyOnEnd) {
	SetItemTypeMaxArrayData(itemType, 3);

	food_Data[food_Total][food_itemType]		= itemType;
	food_Data[food_Total][food_maxBites]		= maxBites;
	food_Data[food_Total][food_biteValue]		= biteValue;
	food_Data[food_Total][food_canCook]			= canCook;
	food_Data[food_Total][food_canRawInfect]	= canRawInfect;
	food_Data[food_Total][food_destroyOnEnd]	= destroyOnEnd;

	food_ItemTypeFoodType[itemType] = food_Total;

	return food_Total++;
}

hook OnItemCreate(itemid) {
	if(GetItemLootIndex(itemid) != -1) {
		new foodType = GetItemTypeFoodType(GetItemType(itemid));

		if(foodType != -1) {
			SetItemArrayDataAtCell(itemid, 0, food_cooked, 0);
			SetItemArrayDataAtCell(itemid, food_Data[_:foodType][food_maxBites] - random(food_Data[_:foodType][food_maxBites] / 2), food_amount, 1);
		}
	}
}

hook OnPlayerUseItem(playerid, itemid) {
	if(GetItemTypeFoodType(GetItemType(itemid)) != -1) _StartEating(playerid, itemid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	if(oldkeys & 16 && food_CurrentItem[playerid] != -1) _StopEating(playerid);

	return 1;
}

_StartEating(playerid, itemid, continuing = false) {
	if(!IsPlayerIdle(playerid) && !continuing) return;

	if(IsPlayerAtAnyVehicleTrunk(playerid)) return;

	food_CurrentItem[playerid] = itemid;

	if(CallLocalFunction("OnPlayerEat", "dd", playerid, itemid)) {
		_StopEating(playerid);
		return;
	}

	ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.1, 0, 0, 0, 0, 0);
	StartHoldAction(playerid, 3200);

	return;
}

_StopEating(playerid) {
	ClearAnimations(playerid);
	StopHoldAction(playerid);

	food_CurrentItem[playerid] = -1;
}

_EatItem(playerid, itemid) {
	if(!IsValidItem(itemid)) return 0;

	if(GetPlayerItem(playerid) != itemid) return 0;

	new foodType = GetItemTypeFoodType(GetItemType(itemid));

	if(foodType == -1) return 0;

	if(CallLocalFunction("OnPlayerEaten", "dd", playerid, itemid)) {
		_StopEating(playerid);
		return 0;
	}

	new foodAmount = GetItemArrayDataAtCell(itemid, food_amount);

	if(foodAmount <= 0) {
		_StopEating(playerid);
		if(food_Data[foodType][food_destroyOnEnd]) DestroyItem(itemid);
		return 1;
	}

	new Float:playerFoodPoints = GetPlayerFP(playerid);

	if(food_Data[foodType][food_canCook] && GetItemArrayDataAtCell(itemid, food_cooked) == 0) {
		SetPlayerFP(playerid, playerFoodPoints + food_Data[foodType][food_biteValue] * 0.7);
		if(food_Data[foodType][food_canRawInfect]) SetPlayerInfectionIntensity(playerid, INFECT_TYPE_FOOD, 1);
	} else
		SetPlayerFP(playerid, playerFoodPoints + food_Data[foodType][food_biteValue]);

	SetItemArrayDataAtCell(itemid, foodAmount - 1, food_amount, 0);
	_StartEating(playerid, itemid, true);

	if(food_Data[foodType][food_destroyOnEnd]) DestroyItem(itemid);

	return 1;
}

hook OnHoldActionFinish(playerid) {
	if(food_CurrentItem[playerid] != -1) {
		_EatItem(playerid, food_CurrentItem[playerid]);
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemNameRender(itemid, ItemType:itemtype) {
	new foodType = GetItemTypeFoodType(itemtype);

	if(foodType != -1) {
		if(food_Data[foodType][food_canCook])
			SetItemNameExtra(itemid, sprintf(GetItemArrayDataAtCell(itemid, food_cooked) == 1 ? "Cozido, %d%%" : "Nao cozido, %d%%", floatround((float(GetItemArrayDataAtCell(itemid, food_amount)) / food_Data[foodType][food_maxBites]) * 100.0)));
		else
			SetItemNameExtra(itemid, sprintf("%d%%", floatround((float(GetItemArrayDataAtCell(itemid, food_amount)) / food_Data[foodType][food_maxBites]) * 100.0)));
	}
}

stock IsItemTypeFood(ItemType:itemtype) {
	return GetItemTypeFoodType(itemtype) != -1;
}

stock GetItemTypeFoodType(ItemType:itemtype) {
	if(!IsValidItemType(itemtype)) return -1;

	return food_ItemTypeFoodType[itemtype];
}

stock ItemType:GetFoodTypeItemType(foodtype) {
	if(!(0 <= foodtype < food_Total)) return INVALID_ITEM_TYPE;

	return food_Data[foodtype][food_itemType];
}

stock GetFoodTypeMaxBites(foodtype) {
	if(!(0 <= foodtype < food_Total)) return 0;

	return food_Data[foodtype][food_maxBites];
}

stock Float:GetFoodTypeBiteValue(foodtype) {
	if(!(0 <= foodtype < food_Total)) return 0.0;

	return food_Data[foodtype][food_biteValue];
}

stock GetFoodTypeCanCook(foodtype) {
	if(!(0 <= foodtype < food_Total)) return 0;

	return food_Data[foodtype][food_canCook];
}

stock GetFoodTypeCanRawInfect(foodtype) {
	if(!(0 <= foodtype < food_Total)) return 0;

	return food_Data[foodtype][food_canRawInfect];
}

stock GetFoodTypeDestroyOnEnd(foodtype) {
	if(!(0 <= foodtype < food_Total)) return 0;

	return food_Data[foodtype][food_destroyOnEnd];
}

stock GetFoodItemCooked(itemid) {
	return GetItemArrayDataAtCell(itemid, food_cooked);
}

stock SetFoodItemCooked(itemid, value) {
	return SetItemArrayDataAtCell(itemid, value, food_cooked);
}

stock GetFoodItemAmount(itemid) {
	return GetItemArrayDataAtCell(itemid, food_amount);
}

stock SetFoodItemAmount(itemid, value) {
	return SetItemArrayDataAtCell(itemid, value, food_amount);
}

stock GetFoodItemSubType(itemid) {
	return GetItemArrayDataAtCell(itemid, food_subType);
}

stock SetFoodItemSubType(itemid, value) {
	return SetItemArrayDataAtCell(itemid, value, food_subType);
}
