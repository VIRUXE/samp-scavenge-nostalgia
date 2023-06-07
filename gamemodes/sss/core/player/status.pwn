
// #include <YSI\y_hooks>

stock ShowPlayerStatus(playerId, targetId) {
	if(IsPlayerViewingInventory(playerId)) ClosePlayerInventory(playerId, true);
    
    gBigString[playerId][0] = EOS;
    
    strcat(gBigString[playerId], sprintf(C_YELLOW"Score"C_WHITE": %d\n \n", ls(playerId, "player/score"), GetPlayerScore(targetId)));
    strcat(gBigString[playerId], sprintf(C_YELLOW"%s"C_WHITE": %d\n \n", ls(playerId, "player/kills"), GetPlayerDeathCount(targetId)));
    strcat(gBigString[playerId], sprintf(C_YELLOW"Killing Spree"C_WHITE": %d\n \n", ls(playerId, "player/killingspree"), GetPlayerSpree(targetId)));
    strcat(gBigString[playerId], sprintf(C_YELLOW"%s"C_WHITE": %d\n \n", ls(playerId, "player/aliveminutes"), GetPlayerAliveTime(targetId) / 60));
	strcat(gBigString[playerId], sprintf(C_YELLOW"%s"C_WHITE": %s\n \n", ls(playerId, "player/clan"), GetPlayerClan(targetId)));
	
	ShowPlayerDialog(playerId, DIALOG_PLAYER_STATUS, DIALOG_STYLE_MSGBOX, GetPlayerNameEx(playerId), gBigString[playerId], "Ok", "");
}

/*new status_InventoryOption[MAX_PLAYERS];

hook OnPlayerOpenInventory(playerId){
	status_InventoryOption[playerId] = AddInventoryListItem(playerId, "{C_YELLOW}Status >");
	return Y_HOOKS_CONTINUE_RETURN_0;
}*/

/*hook OnPlayerSelectExtraItem(playerId, item){
	if(item == status_InventoryOption[playerId])
        ShowPlayerStatus(playerId, playerId);
	return Y_HOOKS_CONTINUE_RETURN_0;
}*/

public OnPlayerClickPlayer(playerid, clickedplayerid, source) ShowPlayerStatus(playerid, clickedplayerid);