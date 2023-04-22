
#include <YSI\y_hooks>

stock ShowStatusPlayerForPlayer(i, forplayer){
	if(IsPlayerViewingInventory(forplayer))
    	ClosePlayerInventory(forplayer, true);
    
    gBigString[i][0] = EOS;
    
    strcat(gBigString[i], sprintf(C_YELLOW"Score"C_WHITE": %d\n \n", ls(i, "player/score"), GetPlayerScore(i)));
    strcat(gBigString[i], sprintf(C_YELLOW"%s"C_WHITE": %d\n \n", ls(i, "player/kills"), GetPlayerDeathCount(i)));
    strcat(gBigString[i], sprintf(C_YELLOW"Killing Spree"C_WHITE": %d\n \n", ls(i, "player/killingspree"), GetPlayerSpree(i)));
    strcat(gBigString[i], sprintf(C_YELLOW"%s"C_WHITE": %d\n \n", ls(i, "player/aliveminutes"), GetPlayerAliveTime(i) / 60));
	strcat(gBigString[i], sprintf(C_YELLOW"%s"C_WHITE": %s\n \n", ls(i, "player/clan"), GetPlayerClan(i)));
	
	new name[MAX_PLAYER_NAME];
	GetPlayerName(i, name, MAX_PLAYER_NAME);

	ShowPlayerDialog(forplayer, 10008, DIALOG_STYLE_MSGBOX, name, gBigString[i], "X", "");
}

/*new status_InventoryOption[MAX_PLAYERS];

hook OnPlayerOpenInventory(playerid){
	status_InventoryOption[playerid] = AddInventoryListItem(playerid, "{C_YELLOW}Status >");
	return Y_HOOKS_CONTINUE_RETURN_0;
}*/

/*hook OnPlayerSelectExtraItem(playerid, item){
	if(item == status_InventoryOption[playerid])
        ShowStatusPlayerForPlayer(playerid, playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}*/

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
    ShowStatusPlayerForPlayer(clickedplayerid, playerid);