hook OnItemAddToInventory(playerid, itemid) 
{
    new ItemType:itemtype = GetItemType(itemid);

	if(itemtype == item_Map) 
    {
        GangZoneHideForPlayer(playerid, MiniMapOverlay);
        WCIconSpawn(playerid);
        ShowSupplyIconSpawn(playerid);
        HideWatch(playerid);
    }

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemoveFInventory(playerid, itemid)
{
    new ItemType:itemtype = GetItemType(itemid);

	if(itemtype == item_Map) 
    {
        GangZoneShowForPlayer(playerid, MiniMapOverlay, 0x000000FF);
        ShowWatch(playerid);

        if(WCDropped == 1)
            RemovePlayerMapIcon(playerid, ICON_WC);

        if(supplyCrateDropped == 1)
		    RemovePlayerMapIcon(playerid, ICON_SUPPLY);

    }

	return Y_HOOKS_CONTINUE_RETURN_0;
}

stock HideDutyGangZone(playerid)
{
    GangZoneHideForPlayer(playerid, MiniMapOverlay);
    ShowWatch(playerid);
}