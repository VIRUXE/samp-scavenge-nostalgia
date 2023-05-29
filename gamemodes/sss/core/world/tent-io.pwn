#include <YSI\y_hooks>

#define DIRECTORY_TENT	DIRECTORY_MAIN"tents/"


static tent_ItemList[ITM_LST_OF_ITEMS(MAX_TENT_ITEMS)];

forward OnTentLoad(itemid, active, geid[], data[], length);


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnScriptInit()
{
	print("\n[OnScriptInit] Initialising 'tent-io'...");

	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_TENT);
}

hook OnGameModeInit()
{
	print("\n[OnGameModeInit] Initialising 'tent-io'...");

	LoadItems(DIRECTORY_TENT, "OnTentLoad");
}

hook OnPlayerCloseContainer(playerid, containerid)
{
	new itemid = GetTentItem(GetContainerTent(containerid));
	if(IsItemTypeTent(GetItemType(itemid)) && !IsPlayerInTutorial(playerid))
	{
		TentSaveCheck(itemid);
		ClearAnimations(playerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenContainer(playerid, containerid)
{
	new itemid = GetTentItem(GetContainerTent(containerid));
	if(IsItemTypeTent(GetItemType(itemid)) && !IsPlayerInTutorial(playerid))
	{
		TentSaveCheck(itemid);
		ClearAnimations(playerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemovedFromCnt(containerid, slotid, playerid)
{
    if(playerid != INVALID_PLAYER_ID)
	{
	    new itemid2 = GetTentItem(GetContainerTent(containerid));
		if(IsItemTypeTent(GetItemType(itemid2)) && !IsPlayerInTutorial(playerid))
		{
			TentSaveCheck(itemid2);
			ClearAnimations(playerid);
		}
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnTentDestroy(tentid)
{
    RemoveSavedItem(GetTentItem(tentid), DIRECTORY_TENT);
}

TentSaveCheck(itemid)
{
		SaveTentItem(itemid);
}

/*==============================================================================

	Save and Load Individual

==============================================================================*/


SaveTentItem(itemid)
{
	new geid[GEID_LEN];

	GetItemGEID(itemid, geid);

    new ItemType:typet = GetItemType(itemid);

	if(typet != item_TentPack)
	{
		printf("[SaveTentItem] ERROR: Can't save tent %d (%s): Item isn't a tent, type: %d", itemid, geid, _:GetItemType(itemid));
		return 2;
	}

	new containerid = GetTentContainer(GetItemArrayDataAtCell(itemid, 0));

	if(IsContainerEmpty(containerid))
	{
		printf("[SaveTentItem] Not saving tent %d (%s): Container is empty", geid, itemid);
		RemoveSavedItem(itemid, DIRECTORY_TENT);
		return 4;
	}

	if(!IsValidContainer(containerid))
	{
		printf("[SaveTentItem] ERROR: Can't save tent %d (%s): Not valid container (%d).", itemid, geid, containerid);
		return 5;
	}

	new
		items[MAX_TENT_ITEMS],
		itemcount,
		itemlist;

	for(new i, j = MAX_TENT_ITEMS; i < j; i++)
	{
		items[i] = GetContainerSlotItem(containerid, i);

		if(!IsValidItem(items[i]))
			break;

        if(IsItemTypeSafebox(GetItemType(items[i])) || IsItemTypeBag(GetItemType(items[i])))
		    continue;

		itemcount++;
	}

	itemlist = CreateItemList(items, itemcount);
	GetItemList(itemlist, tent_ItemList);

	SaveWorldItem(itemid, DIRECTORY_TENT, true, true, tent_ItemList, GetItemListSize(itemlist));

    new filename[256];
    format(filename, sizeof(filename), "%s%s", DIRECTORY_TENT, geid);

 	modio_push(filename, _T<I,T,E,M>, GetItemListSize(itemlist), tent_ItemList);

 	new name[24];
 	GetTentOwner(GetItemArrayDataAtCell(itemid, 0), name);
    modio_push(filename, _T<O,W,N,E>, 24, name);

	DestroyItemList(itemlist);

	return 0;
}

public OnTentLoad(itemid, active, geid[], data[], length)
{
	if(GetItemType(itemid) != item_TentPack)
	{
		printf("[OnTentLoad] ERROR: Loaded item %d (%s) is not a tent (type: %d)", itemid, geid, _:GetItemType(itemid));
		return 0;
	}

    CreateTentFromItem(itemid);

	new
		containerid = GetTentContainer(GetItemArrayDataAtCell(itemid, 0)),
		subitem,
		ItemType:itemtype,
		owner[24],
		itemlist;

    new filename[256];
    format(filename, sizeof(filename), "%s%s", DIRECTORY_TENT, geid);

    length = modio_read(filename, _T<O,W,N,E>, 24, owner, true);
   	SetTentOwner(GetItemArrayDataAtCell(itemid, 0), owner);

    SetItemLabel(itemid, sprintf("Tenda de ({FFFFFF}%s{FFFF00})", owner), 0xFFFF00FF, 10.0, true);

	length = modio_read(filename, _T<I,T,E,M>, sizeof(tent_ItemList), tent_ItemList, true);

	itemlist = ExtractItemList(tent_ItemList, length);

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
