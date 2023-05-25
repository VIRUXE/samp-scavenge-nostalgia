#include <YSI\y_hooks>


#define MAX_TENT			(2048)
#define MAX_TENT_ITEMS		(32)
#define INVALID_TENT_ID		(-1)

enum E_TENT_DATA
{
			tnt_itemId,
			tnt_containerId
}

enum E_TENT_OBJECT_DATA
{
			tnt_objSideR1,
			tnt_objSideR2,
			tnt_objSideL1,
			tnt_objSideL2,
			tnt_objPoleF,
			tnt_objPoleB
}

static
			tnt_Owner[MAX_TENT][24],
			tnt_Data[MAX_TENT][E_TENT_DATA],
			tnt_ObjData[MAX_TENT][E_TENT_OBJECT_DATA],
			tnt_ContainerTent[CNT_MAX] = {INVALID_ITEM_ID, ...},
			tnt_CurrentTentItem[MAX_PLAYERS];

new
   Iterator:tnt_Index<MAX_TENT>;


forward OnTentCreate(tentid);
forward OnTentBuilt(playerid, tentid);
forward OnTentDestroy(tentid);

hook OnPlayerConnect(playerid) {
	tnt_CurrentTentItem[playerid] = INVALID_ITEM_ID;
}

hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "TentPack"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("TentPack"), 1);
}

hook OnItemCreated(itemid)
{
	if(GetItemType(itemid) == item_TentPack) 
		SetItemExtraData(itemid, INVALID_TENT_ID);
}

stock CreateTentFromItem(itemid)
{
	if(GetItemType(itemid) != item_TentPack)
	{
		err("Attempted to create tent from non-tentpack item %d type: %d", itemid, _:GetItemType(itemid));
		return -1;
	}

	new id = Iter_Free(tnt_Index);

	if(id == -1)
	{
		err("MAX_TENT limit reached.");
		return -1;
	}

	Iter_Add(tnt_Index, id);

	new
		Float:x,
		Float:y,
		Float:z,
		Float:rz,
		worldid = GetItemWorld(itemid),
		interiorid = GetItemInterior(itemid);

	GetItemPos(itemid, x, y, z);
	GetItemRot(itemid, rz, rz, rz);

	z += 0.4;
	rz += 90.0;

	tnt_Data[id][tnt_itemId] = itemid;
	tnt_Data[id][tnt_containerId] = CreateContainer("Tenda", MAX_TENT_ITEMS);
	tnt_ContainerTent[tnt_Data[id][tnt_containerId]] = id;

	SetItemExtraData(itemid, id);

	tnt_ObjData[id][tnt_objSideR1] = CreateDynamicObject(19477,
		x + (0.49 * floatsin(-rz + 270.0, degrees)),
		y + (0.49 * floatcos(-rz + 270.0, degrees)),
		z,
		0.0, 45.0, rz, worldid, interiorid, .streamdistance = 100.0);

	tnt_ObjData[id][tnt_objSideR2] = CreateDynamicObject(19477,
		x + (0.48 * floatsin(-rz + 270.0, degrees)),
		y + (0.48 * floatcos(-rz + 270.0, degrees)),
		z,
		0.0, 45.0, rz, worldid, interiorid, .streamdistance = 20.0);

	tnt_ObjData[id][tnt_objSideL1] = CreateDynamicObject(19477,
		x + (0.49 * floatsin(-rz + 90.0, degrees)),
		y + (0.49 * floatcos(-rz + 90.0, degrees)),
		z,
		0.0, -45.0, rz, worldid, interiorid, .streamdistance = 100.0);

	tnt_ObjData[id][tnt_objSideL2] = CreateDynamicObject(19477,
		x + (0.48 * floatsin(-rz + 90.0, degrees)),
		y + (0.48 * floatcos(-rz + 90.0, degrees)),
		z,
		0.0, -45.0, rz, worldid, interiorid, .streamdistance = 20.0);

	tnt_ObjData[id][tnt_objPoleF] = CreateDynamicObject(19087,
		x + (1.3 * floatsin(-rz, degrees)),
		y + (1.3 * floatcos(-rz, degrees)),
		z + 0.48,
		0.0, 0.0, rz, worldid, interiorid, .streamdistance = 10.0);

	tnt_ObjData[id][tnt_objPoleB] = CreateDynamicObject(19087,
		x - (1.3 * floatsin(-rz, degrees)),
		y - (1.3 * floatcos(-rz, degrees)),
		z + 0.48,
		0.0, 0.0, rz, worldid, interiorid, .streamdistance = 10.0);

	SetDynamicObjectMaterial(tnt_ObjData[id][tnt_objSideR1], 0, 2068, "cj_ammo_net", "CJ_cammonet", 0);
	SetDynamicObjectMaterial(tnt_ObjData[id][tnt_objSideR2], 0, 3095, "a51jdrx", "sam_camo", 0);
	SetDynamicObjectMaterial(tnt_ObjData[id][tnt_objSideL1], 0, 2068, "cj_ammo_net", "CJ_cammonet", 0);
	SetDynamicObjectMaterial(tnt_ObjData[id][tnt_objSideL2], 0, 3095, "a51jdrx", "sam_camo", 0);
	SetDynamicObjectMaterial(tnt_ObjData[id][tnt_objPoleF], 0, 1270, "signs", "lamppost", 0);
	SetDynamicObjectMaterial(tnt_ObjData[id][tnt_objPoleB], 0, 1270, "signs", "lamppost", 0);
    
	CallLocalFunction("OnTentCreate", "d", id);

	return id;
}

stock DestroyTent(tentid)
{
	if(!Iter_Contains(tnt_Index, tentid)) return 0;

	CallLocalFunction("OnTentDestroy", "d", tentid);

	SetItemExtraData(tnt_Data[tentid][tnt_itemId], INVALID_TENT_ID);
	DestroyContainer(tnt_Data[tentid][tnt_containerId]);

	DestroyDynamicObject(tnt_ObjData[tentid][tnt_objSideR1]);
	DestroyDynamicObject(tnt_ObjData[tentid][tnt_objSideR2]);
	DestroyDynamicObject(tnt_ObjData[tentid][tnt_objSideL1]);
	DestroyDynamicObject(tnt_ObjData[tentid][tnt_objSideL2]);
	DestroyDynamicObject(tnt_ObjData[tentid][tnt_objPoleF]);
	DestroyDynamicObject(tnt_ObjData[tentid][tnt_objPoleB]);
	tnt_ObjData[tentid][tnt_objSideR1] = INVALID_OBJECT_ID;
	tnt_ObjData[tentid][tnt_objSideR2] = INVALID_OBJECT_ID;
	tnt_ObjData[tentid][tnt_objSideL1] = INVALID_OBJECT_ID;
	tnt_ObjData[tentid][tnt_objSideL2] = INVALID_OBJECT_ID;
	tnt_ObjData[tentid][tnt_objPoleF] = INVALID_OBJECT_ID;
	tnt_ObjData[tentid][tnt_objPoleB] = INVALID_OBJECT_ID;

	Iter_SafeRemove(tnt_Index, tentid, tentid);

	return tentid;
}


/*==============================================================================

	Internal functions and hooks

==============================================================================*/


hook OnPlayerPickUpItem(playerid, itemid)
{
	if(GetItemType(itemid) == item_TentPack)
	{
		new tentid = GetItemExtraData(itemid);

		if(IsValidTent(tentid))
		{
			DisplayContainerInventory(playerid, tnt_Data[tentid][tnt_containerId]);
			return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	if(GetItemType(withitemid) == item_TentPack)
	{
		new tentid = GetItemArrayDataAtCell(withitemid, 0);

		if(!IsValidTent(tentid))
		{
			if(GetItemType(itemid) == item_Hammer)
			{
				StartBuildingTent(playerid, withitemid);
				return Y_HOOKS_BREAK_RETURN_1;
			}
		}
		else
		{
			if(GetItemType(itemid) == item_Crowbar)
			{
				if(IsBadInteract(playerid)) return Y_HOOKS_BREAK_RETURN_0;

				StartRemovingTent(playerid, withitemid);
				return Y_HOOKS_BREAK_RETURN_1;
			}
			else
			{
				DisplayContainerInventory(playerid, tnt_Data[tentid][tnt_containerId]);
				return Y_HOOKS_BREAK_RETURN_1;
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

StartBuildingTent(playerid, itemid)
{
	if(GetPlayerInterior(playerid) != 0) return SendClientMessage(playerid, RED, " > Voc� não pode construir aqui.");
		
	StartHoldAction(playerid, IsPlayerVip(playerid) ? 5000 : 10000);
    	
	ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
	ShowActionText(playerid, ls(playerid, "item/tent_building"));
	tnt_CurrentTentItem[playerid] = itemid;

	if(!IsPlayerInvadedField(playerid) || !IsPlayerInTutorial(playerid))
		ChatMsg(playerid, GREEN, " > [FIELD] Após construir a sua base, chame um admin no /relatorio para por uma proteção (field) contra hackers.");

	return 1;
}

StopBuildingTent(playerid)
{
	if(tnt_CurrentTentItem[playerid] == INVALID_ITEM_ID) return;

	StopHoldAction(playerid);
	ClearAnimations(playerid);
	HideActionText(playerid);
	tnt_CurrentTentItem[playerid] = INVALID_ITEM_ID;

	return;
}

StartRemovingTent(playerid, itemid)
{
	StartHoldAction(playerid, 15000);

	ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
	ShowActionText(playerid, ls(playerid, "item/tent/packing"));
	tnt_CurrentTentItem[playerid] = itemid;
}

StopRemovingTent(playerid)
{
	if(tnt_CurrentTentItem[playerid] == INVALID_ITEM_ID) return;

	StopHoldAction(playerid);
	ClearAnimations(playerid);
	HideActionText(playerid);
	tnt_CurrentTentItem[playerid] = INVALID_ITEM_ID;

	return;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(oldkeys & 16)
	{
		if(tnt_CurrentTentItem[playerid] != INVALID_ITEM_ID)
		{
			new ItemType:itemtype = GetItemType(GetPlayerItem(playerid));

			if(itemtype == item_Hammer)
				StopBuildingTent(playerid);
				
			else if(itemtype == item_Crowbar)
				StopRemovingTent(playerid);
		}
	}

	return 1;
}

hook OnHoldActionFinish(playerid)
{
	if(tnt_CurrentTentItem[playerid] != INVALID_ITEM_ID)
	{
		if(GetItemType(GetPlayerItem(playerid)) == item_Hammer)
		{
			new tentid = CreateTentFromItem(tnt_CurrentTentItem[playerid]);
			GetPlayerName(playerid, tnt_Owner[tentid], MAX_PLAYER_NAME);
   			SetItemLabel(tnt_CurrentTentItem[playerid], sprintf("Tenda de ({FFFFFF}%s{FFFF00})", tnt_Owner[tentid]), 0xFFFF00FF, 10.0, true);
			StopBuildingTent(playerid);

			CallLocalFunction("OnTentBuilt", "ii", playerid, tentid);
		}

		if(GetItemType(GetPlayerItem(playerid)) == item_Crowbar)
		{
			new
				Float:x,
				Float:y,
				Float:z,
				tentid = GetItemExtraData(tnt_CurrentTentItem[playerid]);

			if(!IsValidTent(tentid))
			{
				err("Player %d attempted to destroy invalid tent %d from item %d", playerid, tentid, tnt_CurrentTentItem[playerid]);
				return Y_HOOKS_CONTINUE_RETURN_0;
			}

			GetItemPos(tnt_CurrentTentItem[playerid], x, y, z);

			for(new i = GetContainerItemCount(tnt_Data[tentid][tnt_containerId]); i >= 0; i--)
				CreateItemInWorld(GetContainerSlotItem(tnt_Data[tentid][tnt_containerId], i), x, y, z, 0.0, 0.0, frandom(360.0));

			DestroyTent(tentid);
			StopRemovingTent(playerid);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}


/*==============================================================================

	Interface

==============================================================================*/


stock GetTentOwner(tentid, Owner[])
	format(Owner, 24, "%s", tnt_Owner[tentid]);

stock SetTentOwner(tentid, Owner[])
    format(tnt_Owner[tentid], 24, "%s", Owner);

stock IsValidTent(tentid)
{
	if(!Iter_Contains(tnt_Index, tentid))
		return 0;

	return 1;
}

// tnt_itemId
stock GetTentItem(tentid)
{
	if(!Iter_Contains(tnt_Index, tentid))
		return 0;

	return tnt_Data[tentid][tnt_itemId];
}

// tnt_containerId
stock GetTentContainer(tentid)
{
	if(!Iter_Contains(tnt_Index, tentid))
		return 0;

	return tnt_Data[tentid][tnt_containerId];
}

stock GetContainerTent(containerid)
{
	if(!IsValidContainer(containerid))
		return INVALID_TENT_ID;

	return tnt_ContainerTent[containerid];
}

stock GetTentPos(tentid, &Float:x, &Float:y, &Float:z)
{
	if(!Iter_Contains(tnt_Index, tentid))
		return 0;

	return GetItemPos(tnt_Data[tentid][tnt_itemId], x, y, z);
}

stock IsItemTypeTent(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return false;

	if(itemtype == item_TentPack)
		return true;

	return false;
}