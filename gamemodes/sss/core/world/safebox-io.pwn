#include <YSI\y_hooks>

#define DIRECTORY_SAFEBOX	DIRECTORY_MAIN"safebox/"


static box_ItemList[ITM_LST_OF_ITEMS(45)];

forward OnSafeboxLoad(itemid, active, geid[], data[], length);


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	print("\n[OnScriptInit] Initialising 'safebox-io'...");

	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_SAFEBOX);
}

hook OnGameModeInit()
{
	print("\n[OnGameModeInit] Initialising 'safebox-io'...");

	LoadItems(DIRECTORY_SAFEBOX, "OnSafeboxLoad");
}


/*==============================================================================

	Save and Load Individual

==============================================================================*/

hook OnPlayerPickUpItem(playerid, itemid)
{
	if(IsItemTypeSafebox(GetItemType(itemid)) && GetItemType(itemid) != item_Workbench && !IsPlayerInTutorial(playerid))
		RemoveSavedItem(itemid, DIRECTORY_SAFEBOX);

	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerDroppedItem(playerid, itemid)
{
	if(IsItemTypeSafebox(GetItemType(itemid)) && !IsPlayerInTutorial(playerid))
		SaveSafeboxItem(itemid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseContainer(playerid, containerid)
{
	SaveBoxCnt(playerid);
    return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenContainer(playerid, containerid)
{
	SaveBoxCnt(playerid);
    return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemovedFromCnt(containerid, slotid, playerid)
{
    if(playerid != INVALID_PLAYER_ID)
	{
	    SaveBoxCnt(playerid);
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseInventory(playerid)
{
	SaveBoxCnt(playerid);
    return Y_HOOKS_CONTINUE_RETURN_0;
}

SaveBoxCnt(playerid)
{
    new safe_itemid = GetPlayerCurrentBoxItem(playerid);

	if(IsValidItem(safe_itemid) && GetItemType(safe_itemid) != item_Workbench && !IsPlayerInTutorial(playerid))
	{
	    if(IsItemTypeSafebox(GetItemType(safe_itemid)))
		{
			SaveSafeboxItem(safe_itemid);
			ClearAnimations(playerid);
		}
	}
}


hook OnItemDestroy(itemid)
{


	if(IsItemTypeSafebox(GetItemType(itemid)) && GetItemType(itemid) != item_Workbench)
		RemoveSavedItem(itemid, DIRECTORY_SAFEBOX);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

SaveSafeboxItem(itemid, bool:active = true)
{
	new geid[GEID_LEN];

	GetItemGEID(itemid, geid);

	if(!IsItemTypeSafebox(GetItemType(itemid)))
	{
		printf("[SaveSafeboxItem] ERROR: Can't save safebox %d (%s): Item isn't a safebox, type: %d", itemid, geid, _:GetItemType(itemid));
		return 2;
	}

	new containerid = GetItemArrayDataAtCell(itemid, 0);

	if(IsContainerEmpty(containerid))
	{
		printf("[SaveSafeboxItem] Not saving safebox %d (%s): Container is empty", geid, itemid);
		RemoveSavedItem(itemid, DIRECTORY_SAFEBOX);
		return 4;
	}

	if(!IsValidContainer(containerid))
	{
		printf("[SaveSafeboxItem] ERROR: Can't save safebox %d (%s): Not valid container (%d).", itemid, geid, containerid);
		return 5;
	}

	new
		items[13],
		itemcount,
		itemlist;

	for(new i, j = GetContainerSize(containerid); i < j; i++)
	{
		items[i] = GetContainerSlotItem(containerid, i);

		if(!IsValidItem(items[i]))
			break;

        if(IsItemTypeSafebox(GetItemType(items[i])) || IsItemTypeBag(GetItemType(items[i])))
		    continue;

		itemcount++;
	}

	itemlist = CreateItemList(items, itemcount);
	GetItemList(itemlist, box_ItemList);

	SaveWorldItem(itemid, DIRECTORY_SAFEBOX, active, true, box_ItemList, GetItemListSize(itemlist));

    new filename[256];
    format(filename, sizeof(filename), "%s%s", DIRECTORY_SAFEBOX, geid);
 	modio_push(filename, _T<I,T,E,M>, GetItemListSize(itemlist), box_ItemList);

	DestroyItemList(itemlist);

	return 0;
}

public OnSafeboxLoad(itemid, active, geid[], data[], length)
{
	if(!IsItemTypeSafebox(GetItemType(itemid)))
	{
		printf("[OnSafeboxLoad] ERROR: Loaded item %d (%s) is not a safebox (type: %d)", itemid, geid, _:GetItemType(itemid));
		return 0;
	}

	new filename[256];
    format(filename, sizeof(filename), "%s%s", DIRECTORY_SAFEBOX, geid);

	length = modio_read(filename, _T<I,T,E,M>, sizeof(box_ItemList), box_ItemList, true);

	new
		containerid = GetItemArrayDataAtCell(itemid, 0),
		subitem,
		ItemType:itemtype,
		itemlist;

	itemlist = ExtractItemList(box_ItemList, length);

	for(new i, j = GetItemListItemCount(itemlist); i < j; i++)
	{
		itemtype = GetItemListItem(itemlist, i);

		if(length == 0)
			break;

		if(itemtype == INVALID_ITEM_TYPE)
			continue;

		if(itemtype == ItemType:0)
			continue;

		subitem = CreateItem(itemtype);

		if(!IsItemTypeSafebox(itemtype) && !IsItemTypeBag(itemtype))
			SetItemArrayDataFromListItem(subitem, itemlist, i);

		AddItemToContainer(containerid, subitem);
	}
	
	DestroyItemList(itemlist);

	return 1;
}
