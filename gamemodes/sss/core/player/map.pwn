hook OnItemAddToInventory(playerid, itemid) 
{
    new ItemType:itemtype = GetItemType(itemid);

	if(itemtype == item_Map) 
    {
        GangZoneHideForPlayer(playerid, MiniMapOverlay);
        WCIconSpawn(playerid);
        ShowSupplyIconSpawn(playerid);
        ToggleHudComponent(playerid, HUD_COMPONENT_RADAR, false);
    }

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemoveFInventory(playerid, itemid)
{
    new ItemType:itemtype = GetItemType(itemid);

	if(itemtype == item_Map) 
    {
        GangZoneShowForPlayer(playerid, MiniMapOverlay, 0x000000FF);
        ToggleHudComponent(playerid, HUD_COMPONENT_RADAR, true);

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
    ToggleHudComponent(playerid, HUD_COMPONENT_RADAR, true);
}