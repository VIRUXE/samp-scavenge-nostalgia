#include <YSI\y_hooks>

#define MAX_BAG_TYPE (10)


enum E_BAG_TYPE_DATA
{
			bag_name[ITM_MAX_NAME],
ItemType:	bag_itemtype,
			bag_size
}


enum E_BAG_FLOAT_DATA
{
Float:		bag_offs_x,
Float:		bag_offs_y,
Float:		bag_offs_z,
Float:		bag_offs_rx,
Float:		bag_offs_ry,
Float:		bag_offs_rz,
Float:		bag_offs_sx,
Float:		bag_offs_sy,
Float:		bag_offs_sz
}


static
			bag_TypeDataFloat[MAX_BAG_TYPE][MAX_SKINS][E_BAG_FLOAT_DATA],
			bag_TypeData[MAX_BAG_TYPE][E_BAG_TYPE_DATA],
			bag_TypeTotal,
			bag_ItemTypeBagType[ITM_MAX_TYPES] = {-1, ...};

static
			bag_ContainerItem		[CNT_MAX],
			bag_ContainerPlayer		[CNT_MAX];

static
			bag_PlayerBagID			[MAX_PLAYERS],
			bag_InventoryOptionID	[MAX_PLAYERS],
bool:		bag_PuttingInBag		[MAX_PLAYERS],
bool:		bag_TakingOffBag		[MAX_PLAYERS],
			bag_CurrentBag			[MAX_PLAYERS],
//Timer:		bag_OtherPlayerEnter	[MAX_PLAYERS],
			bag_LookingInBag		[MAX_PLAYERS];


forward OnPlayerWearBag(playerid, itemid);
forward OnPlayerRemoveBag(playerid, itemid);


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	for(new i; i < CNT_MAX; i++)
	{
		bag_ContainerPlayer[i] = INVALID_PLAYER_ID;
		bag_ContainerItem[i] = INVALID_ITEM_ID;
	}
}

hook OnPlayerConnect(playerid)
{


	bag_PlayerBagID[playerid] = INVALID_ITEM_ID;
	bag_PuttingInBag[playerid] = false;
	bag_TakingOffBag[playerid] = false;
	bag_CurrentBag[playerid] = INVALID_ITEM_ID;
	bag_LookingInBag[playerid] = INVALID_PLAYER_ID;
}


/*==============================================================================

	Core

==============================================================================*/

stock SetBagOffsetsForSkin(bagtype, skinid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, Float:sx, Float:sy, Float:sz){
    bag_TypeDataFloat[bagtype][skinid][bag_offs_x] = x;
    bag_TypeDataFloat[bagtype][skinid][bag_offs_y] = y;
    bag_TypeDataFloat[bagtype][skinid][bag_offs_z] = z;

    bag_TypeDataFloat[bagtype][skinid][bag_offs_rx] = rx;
    bag_TypeDataFloat[bagtype][skinid][bag_offs_ry] = ry;
    bag_TypeDataFloat[bagtype][skinid][bag_offs_rz] = rz;

    bag_TypeDataFloat[bagtype][skinid][bag_offs_sx] = sx;
    bag_TypeDataFloat[bagtype][skinid][bag_offs_sy] = sy;
    bag_TypeDataFloat[bagtype][skinid][bag_offs_sz] = sz;
}

stock DefineBagType(name[ITM_MAX_NAME], ItemType:itemtype, size)
{


	if(bag_TypeTotal == MAX_BAG_TYPE)
		return -1;

	SetItemTypeMaxArrayData(itemtype, 2);

	bag_TypeData[bag_TypeTotal][bag_name]			= name;
	bag_TypeData[bag_TypeTotal][bag_itemtype]		= itemtype;
	bag_TypeData[bag_TypeTotal][bag_size]			= size;

	bag_ItemTypeBagType[itemtype] = bag_TypeTotal;

	return bag_TypeTotal++;
}

stock GivePlayerBag(playerid, itemid)
{


	if(!IsValidItem(itemid))
		return 0;

	new bagtype = bag_ItemTypeBagType[GetItemType(itemid)];

	if(bagtype != -1)
	{
		new containerid = GetItemArrayDataAtCell(itemid, 1);

		if(!IsValidContainer(containerid))
		{
			err("Bag (%d) container ID (%d) was invalid container has to be recreated.", itemid, containerid);

			containerid = CreateContainer(bag_TypeData[bagtype][bag_name], bag_TypeData[bagtype][bag_size]);

			bag_ContainerItem[containerid] = itemid;
			bag_ContainerPlayer[containerid] = INVALID_PLAYER_ID;

			SetItemArrayDataSize(itemid, 2);
			SetItemArrayDataAtCell(itemid, containerid, 1);
		}

		new
			colour = GetItemTypeColour(bag_TypeData[bagtype][bag_itemtype]),
			skinid = GetPlayerSkin(playerid);

		bag_PlayerBagID[playerid] = itemid;
			
        SetPlayerAttachedObject(playerid, ATTACHSLOT_BAG, GetItemTypeModel(bag_TypeData[bagtype][bag_itemtype]), 1,
			bag_TypeDataFloat[bagtype][skinid][bag_offs_x],
  			bag_TypeDataFloat[bagtype][skinid][bag_offs_y],
		    bag_TypeDataFloat[bagtype][skinid][bag_offs_z],
		    bag_TypeDataFloat[bagtype][skinid][bag_offs_rx],
		    bag_TypeDataFloat[bagtype][skinid][bag_offs_ry],
		    bag_TypeDataFloat[bagtype][skinid][bag_offs_rz],
		    bag_TypeDataFloat[bagtype][skinid][bag_offs_sx],
		    bag_TypeDataFloat[bagtype][skinid][bag_offs_sy],
		    bag_TypeDataFloat[bagtype][skinid][bag_offs_sz], colour, colour);

		bag_ContainerItem[containerid] = itemid;
		bag_ContainerPlayer[containerid] = playerid;
		RemoveItemFromWorld(itemid);
		RemoveCurrentItem(GetItemHolder(itemid));

		return 1;
	}

	return 0;
}

stock RemovePlayerBag(playerid)
{


	if(!IsPlayerConnected(playerid))
		return 0;

	if(!IsValidItem(bag_PlayerBagID[playerid]))
		return 0;

	new containerid = GetItemArrayDataAtCell(bag_PlayerBagID[playerid], 1);

	if(!IsValidContainer(containerid))
	{
		new bagtype = bag_ItemTypeBagType[GetItemType(bag_PlayerBagID[playerid])];

		if(bagtype == -1)
		{
			err("Player (%d) bag item type (%d) is not a valid bag type.", playerid, bagtype);
			return 0;
		}

		err("Bag (%d) container ID (%d) was invalid container has to be recreated.", bag_PlayerBagID[playerid], containerid);

		containerid = CreateContainer(bag_TypeData[bagtype][bag_name], bag_TypeData[bagtype][bag_size]);

        bag_ContainerItem[containerid] = bag_PlayerBagID[playerid];
		bag_ContainerPlayer[containerid] = INVALID_PLAYER_ID;

		SetItemArrayDataSize(bag_PlayerBagID[playerid], 2);
		SetItemArrayDataAtCell(bag_PlayerBagID[playerid], containerid, 1);
	}

	RemovePlayerAttachedObject(playerid, ATTACHSLOT_BAG);
	CreateItemInWorld(bag_PlayerBagID[playerid], 0.0, 0.0, 0.0, .world = GetPlayerVirtualWorld(playerid), .interior = GetPlayerInterior(playerid));

	bag_ContainerPlayer[containerid] = INVALID_PLAYER_ID;
	bag_PlayerBagID[playerid] = INVALID_ITEM_ID;

	return 1;
}

stock DestroyPlayerBag(playerid)
{


	if(!(0 <= playerid < MAX_PLAYERS))
		return 0;

	if(!IsValidItem(bag_PlayerBagID[playerid]))
		return 0;

	new containerid = GetItemArrayDataAtCell(bag_PlayerBagID[playerid], 1);

	if(IsValidContainer(containerid))
	{
		bag_ContainerPlayer[containerid] = INVALID_PLAYER_ID;
		DestroyContainer(containerid);
	}

	RemovePlayerAttachedObject(playerid, ATTACHSLOT_BAG);
	DestroyItem(bag_PlayerBagID[playerid]);

	bag_PlayerBagID[playerid] = INVALID_ITEM_ID;

	return 1;
}

/*
	Automatically determines whether to add to the player's inventory or bag.
*/
stock AddItemToPlayer(playerid, itemid, useinventory = false, playeraction = true)
{


	new ItemType:itemtype = GetItemType(itemid);

	if(IsItemTypeCarry(itemtype))
		return -1;

	if(WillItemTypeFitInInventory(playerid, itemtype))
	{
		//
		if(useinventory)
			AddItemToInventory(playerid, itemid);

		return -2;
	}

	new containerid = GetItemArrayDataAtCell(bag_PlayerBagID[playerid], 1);

	if(!IsValidContainer(containerid))
		return -3;

	new
		itemsize = GetItemTypeSize(GetItemType(itemid)),
		freeslots = GetContainerFreeSlots(containerid);

	if(itemsize > freeslots)
	{
		ShowActionText(playerid, sprintf(ls(playerid, "player/bag/extra-slots"), itemsize - freeslots), 3000, 150);
		return -4;
	}

	if(playeraction)
	{
	    if(IsValidItem(bag_PlayerBagID[playerid]))
	    {
			ShowActionText(playerid, ls(playerid, "player/bag/item-added"), 3000, 150);
			ApplyAnimation(playerid, "PED", "PHONE_IN", 4.0, 1, 0, 0, 0, 300);
			bag_PuttingInBag[playerid] = true;
			defer bag_PutItemIn(playerid, itemid, containerid);
		}
		else ShowActionText(playerid, sprintf(ls(playerid, "item/container/extra-slots-inventory"), itemsize), 3000, 150);
	}
	else return AddItemToContainer(containerid, itemid, playerid);

	return 0;
}

hook OnItemCreated(itemid) {
	new bagtype = bag_ItemTypeBagType[GetItemType(itemid)];

	if(bagtype != -1) {
		new
			containerid,
			lootindex = GetItemLootIndex(itemid);

		containerid = CreateContainer(bag_TypeData[bagtype][bag_name], bag_TypeData[bagtype][bag_size]);

		bag_ContainerItem[containerid] = itemid;
		bag_ContainerPlayer[containerid] = INVALID_PLAYER_ID;

		SetItemArrayDataSize(itemid, 2);
		SetItemArrayDataAtCell(itemid, containerid, 1);

		if(lootindex != -1) {
			if(!IsValidContainer(containerid))
				FillContainerWithLoot(containerid, random(4), lootindex);
		}
	}
}

/*hook OnItemCreateInWorld(itemid)
{


	if(IsItemTypeBag(GetItemType(itemid)))
	{
		SetButtonText(GetItemButtonID(itemid), "Segure "KEYTEXT_INTERACT" para pegar~n~Pressione "KEYTEXT_INTERACT" para abrir");
	}
}*/

hook OnItemDestroy(itemid)
{
	if(IsItemTypeBag(GetItemType(itemid)))
	{
		new containerid = GetItemArrayDataAtCell(itemid, 1);

		if(IsValidContainer(containerid))
		{
			bag_ContainerPlayer[containerid] = INVALID_PLAYER_ID;
			bag_ContainerItem[containerid] = INVALID_ITEM_ID;
			DestroyContainer(containerid);
		}
	}
}

hook OnPlayerUseItem(playerid, itemid)
{


	if(bag_ItemTypeBagType[GetItemType(itemid)] != -1)
	{
		if(IsValidContainer(GetPlayerCurrentContainer(playerid)))
			return Y_HOOKS_CONTINUE_RETURN_0;

		if(IsItemInWorld(itemid))
			_DisplayBagDialog(playerid, itemid, true);

		else
			_DisplayBagDialog(playerid, itemid, false);

		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{


	if(bag_ItemTypeBagType[GetItemType(withitemid)] != -1)
	{
		_DisplayBagDialog(playerid, withitemid, true);
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{


	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED || IsPlayerOnAdminDuty(playerid) || IsPlayerKnockedOut(playerid) || GetPlayerAnimationIndex(playerid) == 1381 || GetTickCountDifference(GetTickCount(), GetPlayerLastHolsterTick(playerid)) < 1000)
		return 1;

	if(IsPlayerInAnyVehicle(playerid))
		return 1;

	if(newkeys & KEY_YES) _BagEquipHandler(playerid);
	if(newkeys & KEY_NO) _BagDropHandler(playerid);

	//if(newkeys & 16) _BagRummageHandler(playerid);

	return 1;
}

_BagEquipHandler(playerid)
{
	new itemid = GetPlayerItem(playerid);

	if(!IsValidItem(itemid))
		return 0;

	if(bag_PuttingInBag[playerid])
		return 0;

	if(GetTickCountDifference(GetTickCount(), GetPlayerLastHolsterTick(playerid)) < 1000)
		return 0;

	new ItemType:itemtype = GetItemType(itemid);

	if(IsItemTypeBag(itemtype))
	{
		if(IsValidItem(bag_PlayerBagID[playerid]))
		{
			new currentbagitem = bag_PlayerBagID[playerid];

			RemovePlayerBag(playerid);
			GivePlayerBag(playerid, itemid);
			GiveWorldItemToPlayer(playerid, currentbagitem, 1);
		}
		else
		{
			if(CallLocalFunction("OnPlayerWearBag", "dd", playerid, itemid))
				return 0;

			GivePlayerBag(playerid, itemid);
		}

		return 0;
	}
	else AddItemToPlayer(playerid, itemid);

	return 1;
}

_BagDropHandler(playerid)
{
	if(!IsValidItem(bag_PlayerBagID[playerid]))
		return 0;

	if(IsValidItem(GetPlayerItem(playerid)))
		return 0;

	if(IsValidItem(GetPlayerInteractingItem(playerid)))
		return 0;

	if(CallLocalFunction("OnPlayerRemoveBag", "dd", playerid, bag_PlayerBagID[playerid]))
		return 0;

	new containerid = GetItemArrayDataAtCell(bag_PlayerBagID[playerid], 1);

	if(!IsValidContainer(containerid))
		return 0;

	RemovePlayerAttachedObject(playerid, ATTACHSLOT_BAG);
	CreateItemInWorld(bag_PlayerBagID[playerid], 0.0, 0.0, 0.0, .world = GetPlayerVirtualWorld(playerid), .interior = GetPlayerInterior(playerid));
	GiveWorldItemToPlayer(playerid, bag_PlayerBagID[playerid], 1);
	bag_ContainerPlayer[containerid] = INVALID_PLAYER_ID;
	bag_PlayerBagID[playerid] = INVALID_ITEM_ID;
	bag_TakingOffBag[playerid] = true;

	return 1;
}

/*_BagRummageHandler(playerid)
{
	foreach(new i : Player)
	{
		if(IsPlayerInPlayerArea(playerid, i))
		{
			if(IsValidItem(bag_PlayerBagID[i]))
			{
				new
					Float:px,
					Float:py,
					Float:pz,
					Float:tx,
					Float:ty,
					Float:tz,
					Float:tr,
					Float:angle;

				GetPlayerPos(playerid, px, py, pz);
				GetPlayerPos(i, tx, ty, tz);
				GetPlayerFacingAngle(i, tr);

				angle = absoluteangle(tr - GetAngleToPoint(tx, ty, px, py));

				if(155.0 < angle < 205.0)
				{
					CancelPlayerMovement(playerid);
					bag_OtherPlayerEnter[playerid] = defer bag_EnterOtherPlayer(playerid, i);
					break;
				}
			}
		}
	}

	return 1;
}
*/
timer bag_PutItemIn[300](playerid, itemid, containerid)
{
	AddItemToContainer(containerid, itemid, playerid);
	bag_PuttingInBag[playerid] = false;
}

timer bag_EnterOtherPlayer[250](playerid, targetid)
{

	_DisplayBagDialog(playerid, bag_PlayerBagID[targetid], false);
	bag_LookingInBag[playerid] = targetid;
}

PlayerBagUpdate(playerid)
{
	if(IsPlayerConnected(bag_LookingInBag[playerid]))
	{
		if(GetPlayerDist3D(playerid, bag_LookingInBag[playerid]) > 1.0)
		{
			ClosePlayerContainer(playerid);
			CancelSelectTextDraw(playerid);
			bag_LookingInBag[playerid] = -1;
		}
	}
}

_DisplayBagDialog(playerid, itemid, animation)
{
	new
		containerid = GetItemArrayDataAtCell(itemid, 1),
		bagtype = bag_ItemTypeBagType[GetItemType(itemid)];
	
	if(GetContainerSize(containerid) != bag_TypeData[bagtype][bag_size])
	{
	    containerid = CreateContainer(bag_TypeData[bagtype][bag_name], bag_TypeData[bagtype][bag_size]);

		bag_ContainerItem[containerid] = itemid;
		bag_ContainerPlayer[containerid] = INVALID_PLAYER_ID;

		SetItemArrayDataSize(itemid, 2);
		SetItemArrayDataAtCell(itemid, containerid, 1);
	}
	
	DisplayContainerInventory(playerid, containerid);
	bag_CurrentBag[playerid] = itemid;

	if(animation)
		ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 4.0, 0, 0, 0, 1, 0);

	else CancelPlayerMovement(playerid);
}

hook OnItemAddToInventory(playerid, itemid, slot)
{


	new ItemType:itemtype = GetItemType(itemid);

	if(IsItemTypeBag(itemtype))
		return Y_HOOKS_BREAK_RETURN_1;

	if(IsItemTypeCarry(itemtype))
		return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerAddToInventory(playerid, itemid, success)
{


	if(success)
	{
		new ItemType:itemtype = GetItemType(itemid);

		if(IsItemTypeBag(itemtype))
			return Y_HOOKS_BREAK_RETURN_1;

		if(IsItemTypeCarry(itemtype))
			return Y_HOOKS_BREAK_RETURN_1;
	}
	else
	{
		new ItemType:itemtype = GetItemType(itemid);

		if(IsItemTypeBag(itemtype))
			return Y_HOOKS_BREAK_RETURN_1;

		if(IsItemTypeCarry(itemtype))
			return Y_HOOKS_BREAK_RETURN_1;

		new
			itemsize = GetItemTypeSize(GetItemType(itemid)),
			freeslots = GetInventoryFreeSlots(playerid);

		ShowActionText(playerid, sprintf(ls(playerid, "player/bag/extra-slots"), itemsize - freeslots), 3000, 150);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseContainer(playerid, containerid)
{


	if(IsValidItem(bag_CurrentBag[playerid]))
	{
		ClearAnimations(playerid);
		bag_CurrentBag[playerid] = INVALID_ITEM_ID;
		bag_LookingInBag[playerid] = -1;
	}
}

hook OnPlayerDropItem(playerid, itemid)
{


	if(IsItemTypeBag(GetItemType(itemid)))
	{
		if(bag_TakingOffBag[playerid])
		{
			bag_TakingOffBag[playerid] = false;
			return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerGiveItem(playerid, targetid, itemid)
{


	if(IsItemTypeBag(GetItemType(itemid)))
	{
		if(bag_TakingOffBag[playerid])
		{
			bag_TakingOffBag[playerid] = false;
			return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerViewInvOpt(playerid)
{


	if(IsValidItem(bag_PlayerBagID[playerid]) && !IsValidContainer(GetPlayerCurrentContainer(playerid)))
	{
		bag_InventoryOptionID[playerid] = AddInventoryOption(playerid, "Mover para a Mochila");
	}
}

hook OnPlayerSelectInvOpt(playerid, option)
{


	if(IsValidItem(bag_PlayerBagID[playerid]) && !IsValidContainer(GetPlayerCurrentContainer(playerid)))
	{
		if(option == bag_InventoryOptionID[playerid])
		{
			new
				containerid,
				slot,
				itemid;

			containerid = GetItemArrayDataAtCell(bag_PlayerBagID[playerid], 1);
			slot = GetPlayerSelectedInventorySlot(playerid);
			itemid = GetInventorySlotItem(playerid, slot);

			if(!IsValidItem(itemid))
			{
				DisplayPlayerInventory(playerid);
				return Y_HOOKS_CONTINUE_RETURN_0;
			}

			new required = AddItemToContainer(containerid, itemid, playerid);

			if(required > 0)
				ShowActionText(playerid, sprintf(ls(playerid, "player/bag/extra-slots"), required), 3000, 150);

			DisplayPlayerInventory(playerid);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerViewCntOpt(playerid, containerid)
{


	if(IsValidItem(bag_PlayerBagID[playerid]) && containerid != GetItemArrayDataAtCell(bag_PlayerBagID[playerid], 1))
	{
		bag_InventoryOptionID[playerid] = AddContainerOption(playerid, "Mover para a Mochila >");
	}
}

hook OnPlayerSelectCntOpt(playerid, containerid, option)
{


	if(IsValidItem(bag_PlayerBagID[playerid]) && containerid != GetItemArrayDataAtCell(bag_PlayerBagID[playerid], 1))
	{
		if(option == bag_InventoryOptionID[playerid])
		{
			new
				bagcontainerid,
				slot,
				itemid;

			bagcontainerid = GetItemArrayDataAtCell(bag_PlayerBagID[playerid], 1);
			slot = GetPlayerContainerSlot(playerid);
			itemid = GetContainerSlotItem(containerid, slot);

			if(!IsValidItem(itemid))
			{
				DisplayContainerInventory(playerid, containerid);
				return Y_HOOKS_CONTINUE_RETURN_0;
			}

			new required = AddItemToContainer(bagcontainerid, itemid, playerid);

			if(required > 0)
				ShowActionText(playerid, sprintf(ls(playerid, "player/bag/extra-slots"), required), 3000, 150);

			DisplayContainerInventory(playerid, containerid);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemAddToContainer(containerid, itemid, playerid)
{

	if(GetContainerBagItem(containerid) != INVALID_ITEM_ID)
	{

		if(IsItemTypeCarry(GetItemType(itemid)))
		{

			return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}


/*==============================================================================

	Interface

==============================================================================*/


stock IsItemTypeBag(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return 0;

	return (bag_ItemTypeBagType[itemtype] != -1) ? (true) : (false);
}

stock GetItemBagType(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return 0;

	return bag_ItemTypeBagType[itemtype];
}

stock GetPlayerBagItem(playerid)
{
	if(!(0 <= playerid < MAX_PLAYERS))
		return INVALID_ITEM_ID;

	return bag_PlayerBagID[playerid];
}

stock GetContainerPlayerBag(containerid)
{
	if(!IsValidContainer(containerid))
		return INVALID_PLAYER_ID;

	return bag_ContainerPlayer[containerid];
}

stock GetContainerBagItem(containerid)
{
	if(!IsValidContainer(containerid))
		return INVALID_ITEM_ID;

	return bag_ContainerItem[containerid];
}

stock GetBagItemContainerID(itemid)
{
	if(!IsItemTypeBag(GetItemType(itemid)))
		return INVALID_CONTAINER_ID;

	return GetItemArrayDataAtCell(itemid, 1);
}