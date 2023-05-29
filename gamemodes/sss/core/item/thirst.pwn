#include <YSI\y_hooks>

#define MAX_FOOD_ITEM (64)


enum e_FOOD_ITEM_DATA
{
			food_cooked,
			food_amount,
			food_subType
}

enum E_FOOD_DATA
{
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

hook OnPlayerEat(playerid, itemid)
{
    PlayerPlaySound(playerid, 32200, 0.0, 0.0, 0.0);
}
hook OnPlayerConnect(playerid)
{
	

	food_CurrentItem[playerid] = -1;
}


/*==============================================================================

	Core

==============================================================================*/


DefineFoodItem(ItemType:itemtype, maxbites, Float:bitevalue, cancook, canrawinfect, destroyonend)
{
	SetItemTypeMaxArrayData(itemtype, 3);

	food_Data[food_Total][food_itemType]		= itemtype;
	food_Data[food_Total][food_maxBites]		= maxbites;
	food_Data[food_Total][food_biteValue]		= bitevalue;
	food_Data[food_Total][food_canCook]			= cancook;
	food_Data[food_Total][food_canRawInfect]	= canrawinfect;
	food_Data[food_Total][food_destroyOnEnd]	= destroyonend;

	food_ItemTypeFoodType[itemtype] = food_Total;

	return food_Total++;
}


/*==============================================================================

	Hooks and Internal

==============================================================================*/


hook OnItemCreate(itemid)
{


	if(GetItemLootIndex(itemid) != -1)
	{
		new foodtype = GetItemTypeFoodType(GetItemType(itemid));

		if(foodtype != -1)
		{
			SetItemArrayDataAtCell(itemid, 0, food_cooked, 0);
			SetItemArrayDataAtCell(itemid, food_Data[_:foodtype][food_maxBites] - random(food_Data[_:foodtype][food_maxBites] / 2), food_amount, 1);
		}
	}
}

hook OnPlayerUseItem(playerid, itemid)
{


	if(GetItemTypeFoodType(GetItemType(itemid)) != -1)
		_StartEating(playerid, itemid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{


	if(oldkeys & 16 && food_CurrentItem[playerid] != -1)
	{
		_StopEating(playerid);
	}

	return 1;
}

_StartEating(playerid, itemid, continuing = false)
{
	if(!IsPlayerIdle(playerid) && !continuing)
		return;

	if(IsPlayerAtAnyVehicleTrunk(playerid))
		return;

	food_CurrentItem[playerid] = itemid;

	if(CallLocalFunction("OnPlayerEat", "dd", playerid, itemid))
	{
		_StopEating(playerid);
		return;
	}

	ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.1, 0, 0, 0, 0, 0);
	StartHoldAction(playerid, 3200);

	return;
}

_StopEating(playerid)
{
	ClearAnimations(playerid);
	StopHoldAction(playerid);

	food_CurrentItem[playerid] = -1;
}

_EatItem(playerid, itemid)
{
	if(!IsValidItem(itemid))
		return 0;

	if(GetPlayerItem(playerid) != itemid)
		return 0;

	new foodtype = GetItemTypeFoodType(GetItemType(itemid));

	if(foodtype == -1)
		return 0;

	if(CallLocalFunction("OnPlayerEaten", "dd", playerid, itemid))
	{
		_StopEating(playerid);
		return 0;
	}

	if(GetItemArrayDataAtCell(itemid, food_amount) > 0)
	{
		if(food_Data[foodtype][food_canCook] && GetItemArrayDataAtCell(itemid, food_cooked) == 0)
		{
			SetPlayerFP(playerid, GetPlayerFP(playerid) + food_Data[foodtype][food_biteValue] * 0.7);

			if(food_Data[foodtype][food_canRawInfect])
				SetPlayerInfectionIntensity(playerid, 0, 1);
		}
		else
		{
			SetPlayerFP(playerid, GetPlayerFP(playerid) + food_Data[foodtype][food_biteValue]);
		}

		SetItemArrayDataAtCell(itemid, GetItemArrayDataAtCell(itemid, food_amount) - 1, food_amount, 0);
	}

	if(GetItemArrayDataAtCell(itemid, food_amount) > 0)
	{
		_StartEating(playerid, itemid, true);
	}
	else
	{
		_StopEating(playerid);

		if(food_Data[foodtype][food_destroyOnEnd])
			DestroyItem(itemid);
	}

	return 1;
}

hook OnHoldActionFinish(playerid)
{


	if(food_CurrentItem[playerid] != -1)
	{
		_EatItem(playerid, food_CurrentItem[playerid]);
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemNameRender(itemid, ItemType:itemtype)
{


	new foodtype = GetItemTypeFoodType(itemtype);

	if(foodtype != -1)
	{
		if(food_Data[foodtype][food_canCook])
		{
			if(GetItemArrayDataAtCell(itemid, food_cooked) == 1)
				SetItemNameExtra(itemid, sprintf("Cozido, %d%%", floatround((float(GetItemArrayDataAtCell(itemid, food_amount)) / food_Data[foodtype][food_maxBites]) * 100.0)));

			else
				SetItemNameExtra(itemid, sprintf("Não cozido, %d%%", floatround((float(GetItemArrayDataAtCell(itemid, food_amount)) / food_Data[foodtype][food_maxBites]) * 100.0)));
		}
		else
		{
			SetItemNameExtra(itemid, sprintf("%d%%", floatround((float(GetItemArrayDataAtCell(itemid, food_amount)) / food_Data[foodtype][food_maxBites]) * 100.0)));
		}
	}
}


/*==============================================================================

	Interface

==============================================================================*/


stock IsItemTypeFood(ItemType:itemtype)
{
	return GetItemTypeFoodType(itemtype) != -1;
}

stock GetItemTypeFoodType(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return -1;

	return food_ItemTypeFoodType[itemtype];
}

// food_itemType
stock ItemType:GetFoodTypeItemType(foodtype)
{
	if(!(0 <= foodtype < food_Total))
		return INVALID_ITEM_TYPE;

	return food_Data[foodtype][food_itemType];
}

// food_maxBites
stock GetFoodTypeMaxBites(foodtype)
{
	if(!(0 <= foodtype < food_Total))
		return 0;

	return food_Data[foodtype][food_maxBites];
}

// food_biteValue
stock Float:GetFoodTypeBiteValue(foodtype)
{
	if(!(0 <= foodtype < food_Total))
		return 0.0;

	return food_Data[foodtype][food_biteValue];
}

// food_canCook
stock GetFoodTypeCanCook(foodtype)
{
	if(!(0 <= foodtype < food_Total))
		return 0;

	return food_Data[foodtype][food_canCook];
}

// food_canRawInfect
stock GetFoodTypeCanRawInfect(foodtype)
{
	if(!(0 <= foodtype < food_Total))
		return 0;

	return food_Data[foodtype][food_canRawInfect];
}

// food_destroyOnEnd
stock GetFoodTypeDestroyOnEnd(foodtype)
{
	if(!(0 <= foodtype < food_Total))
		return 0;

	return food_Data[foodtype][food_destroyOnEnd];
}

// Item specific

// food_cooked
stock GetFoodItemCooked(itemid)
{
	return GetItemArrayDataAtCell(itemid, food_cooked);
}

stock SetFoodItemCooked(itemid, value)
{
	return SetItemArrayDataAtCell(itemid, value, food_cooked);
}

// food_amount
stock GetFoodItemAmount(itemid)
{
	return GetItemArrayDataAtCell(itemid, food_amount);
}

stock SetFoodItemAmount(itemid, value)
{
	return SetItemArrayDataAtCell(itemid, value, food_amount);
}

// food_subType
stock GetFoodItemSubType(itemid)
{
	return GetItemArrayDataAtCell(itemid, food_subType);
}

stock SetFoodItemSubType(itemid, value)
{
	return SetItemArrayDataAtCell(itemid, value, food_subType);
}
