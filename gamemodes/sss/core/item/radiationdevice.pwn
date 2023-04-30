static Timer:BeepTimer[MAX_PLAYERS];

hook OnItemAddToInventory(playerid, itemid)
{
    new ItemType:itemtype = GetItemType(itemid);

	if(itemtype == item_RadiationDevice) 
    {
    }

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemoveFInventory(playerid, itemid)
{
    new ItemType:itemtype = GetItemType(itemid);

	if(itemtype == item_RadiationDevice) 
    {
    }

	return Y_HOOKS_CONTINUE_RETURN_0;
}

UpdateBeepFrequency(playerid, frequency) {
}

timer BeepFrequency[frequency](frequency) {

}