#include <YSI\y_hooks>

static
	player_Coins[MAX_PLAYERS] = 0;

/* =====================================================================

                            STOCKS:

===================================================================== =*/ 
    
stock AddPlayerCoins(playerid, coins){
    player_Coins[playerid] = player_Coins[playerid] + coins;

    return 1;
}

stock RemovePlayerCoins(playerid, coins){
    player_Coins[playerid] = player_Coins[playerid] - coins;

    return 1;
}

stock SetPlayerCoins(playerid, coins){
    player_Coins[playerid] = coins;

    return 1;
}

stock GetPlayerCoins(playerid){
    if(!IsPlayerConnected(playerid))
        return 0;

    return player_Coins[playerid];
}

/* =====================================================================

                                COMANDOS:

===================================================================== =*/ 

ACMD:playercoins[5](playerid, params[]){
    new pid;
	if(sscanf(params, "d", playerid)) return ChatMsg(playerid, YELLOW," >  Use: /playercoins [id]");

    ChatMsg(playerid, GREEN, " > O player tem {FFFF00}%d {33AA33}coins", GetPlayerCoins(pid));
    return 1;
}

ACMD:setcoins[5](playerid, params[]){
    new coins, targetid;
	if(sscanf(params, "dd", targetid, coins)) return ChatMsg(playerid,YELLOW," >  Use: /setcoins [id] [coins]");

	ChatMsg(targetid, YELLOW, " >  %p(id:%d) Setou seus coins para "C_BLUE"%d", playerid, playerid, coins);
    ChatMsgAdmins(1, BLUE, "[Admin-Log] %p(id:%d) Setou os coins de "C_BLUE"%p(id:%d) para %d", playerid, playerid, targetid, targetid, coins);
    
    SetPlayerCoins(targetid, coins);
    return 1;
}

CMD:coins(playerid) return ChatMsg(playerid, GREEN, " > Você possui {FFFF00}%d {33AA33}coins", GetPlayerCoins(playerid));
