#include <YSI\y_hooks>

enum E_COINS {
    bool:set,
    owned,
    Timer:updateTimer
}

static Coins[MAX_PLAYERS][E_COINS];

stock AddPlayerCoins(playerId, amount) {
    // Banir se o dinheiro for diferente do montante de coins que temos internamente
    // if(Coins[playerId][set] && GetPlayerMoney(playerId) != Coins[playerId][owned]) BanPlayer(playerId, "Bad coins.", -1, 0);

    Coins[playerId][owned] = Coins[playerId][owned] + amount;
    
    Coins[playerId][updateTimer] = repeat UpdateMoney(playerId, amount);

    return;
}

timer UpdateMoney[10](playerId, amount) {
    if(GetPlayerMoney(playerId) < amount)
        GivePlayerMoney(playerId, 1);
    else
        stop Coins[playerId][updateTimer];
}

stock RemovePlayerCoins(playerId, coins) {
    Coins[playerId][owned] = Coins[playerId][owned] - coins;

    return 1;
}

stock SetPlayerCoins(playerId, coins) {
    if(!Coins[playerId][set]) Coins[playerId][set] = true;

    Coins[playerId][owned] = coins;

    ResetPlayerMoney(playerId);

    Coins[playerId][updateTimer] = repeat UpdateMoney(playerId, coins);

    return 1;
}

stock GetPlayerCoins(playerId) {
    if(!IsPlayerConnected(playerId)) return 0;

    return Coins[playerId][owned];
}

ACMD:setcoins[5](playerId, params[]) {
    new coins, targetId;
	if(sscanf(params, "dd", targetId, coins)) return ChatMsg(playerId,YELLOW," >  Use: /setcoins [id] [coins]");

	ChatMsg(targetId, YELLOW, " >  %p(id:%d) Setou seus coins para "C_BLUE"%d", playerId, playerId, coins);
    ChatMsgAdmins(1, BLUE, "[Admin-Log] %p(id:%d) Setou os coins de "C_BLUE"%p(id:%d) para %d", playerId, playerId, targetId, targetId, coins);
    
    SetPlayerCoins(targetId, coins);
    return 1;
}

ACMD:givecoins[5](playerId, params[]) {
    new targetId, coins;
	if(sscanf(params, "rd", targetId, coins)) return ChatMsg(playerId,YELLOW," >  Use: /givecoins [id/nome] [coins]");

	ChatMsg(targetId, YELLOW, " >  %p(id:%d) Setou seus coins para "C_BLUE"%d", playerId, playerId, coins);
    ChatMsgAdmins(1, BLUE, "[Admin-Log] %p(id:%d) Setou os coins de "C_BLUE"%p(id:%d) para %d", playerId, playerId, targetId, targetId, coins);
    
    AddPlayerCoins(targetId, coins);

    return 1;
}

CMD:coins(playerId) return ChatMsg(playerId, GREEN, " > Voc� possui {FFFF00}%d {33AA33}coins", GetPlayerCoins(playerId));
