#include <YSI\y_hooks>

#define TIME_SLEEP 30 //Segundos

static
Timer:  Bed_Sleeping[MAX_PLAYERS],
Timer:  Bed_SleepingBrightness[MAX_PLAYERS],
        Bed_PlayerSleeping[MAX_PLAYERS];

hook OnPlayerDisconnect(playerid, reason) {
    stop Bed_Sleeping[playerid];
    stop Bed_SleepingBrightness[playerid];

    Bed_PlayerSleeping[playerid] = 0;
}

CMD:dormir(playerid) {
	if(!IsPlayerSpawned(playerid)) return 0;

	if(Bed_PlayerSleeping[playerid] != 0) return 1;

	new Float:x, Float:y, Float:z;
	new Float:x2, Float:y2, Float:z2;
	
	GetPlayerPos(playerid, x, y, z);

    new
		items[256],
		Float:rz,
		Bed_ItemID;

	new const count = GetItemsInRange(x, y, z, 1.0, items);

	if(count == 0) return 1;

	for (new o; o < count; o++) {
		if(GetItemType(items[o]) == item_Bed)
		    Bed_ItemID = items[o];
	}

	if(!Bed_ItemID) return ChatMsg(playerid, PINK, " > Não há nenhuma cama por perto");

    foreach(new i : Player) {
	    if(Bed_PlayerSleeping[i] == Bed_ItemID && i != playerid)
	    	Bed_ItemID = 0;
	}

	if(!Bed_ItemID) return ChatMsg(playerid, PINK, " > Alguém está dormindo nesta cama.");

 	GetItemPos(Bed_ItemID, x, y, z);
 	GetItemPos(Bed_ItemID, x2, y2, z2);

    GetItemRot(Bed_ItemID, rz, rz, rz);

	SetPlayerFacingAngle(playerid, rz + 90.0);

    x += 2.45 * floatsin(-rz + 7.0, degrees);
    y += 2.30 * floatcos(-rz, degrees);

	SetPlayerPos(playerid, x, y, z + 1.0);

    stop Bed_SleepingBrightness[playerid];
    Bed_SleepingBrightness[playerid] = defer SleepingBrightness(playerid);

    Bed_PlayerSleeping[playerid] = Bed_ItemID;
    //ApplyAnimation(playerid,"CRACK","crckdeth2", 10.1, 0, 1, 1, 1, 0, 1);
    stop Bed_Sleeping[playerid];
    Bed_Sleeping[playerid] = defer Stop_Sleeping(playerid, x2, y2, z2);

    StartHoldAction(playerid, TIME_SLEEP * 900);

    GetPlayerFacingAngle(playerid, rz);
    GetPlayerPos(playerid, z, z, z);

    defer CheckPlayerSleep(playerid);

    GameTextForPlayer(playerid, "_~n~Dormindo...", TIME_SLEEP * 1000, 3);

	return 1;
}

timer CheckPlayerSleep[SEC(1)](playerid) {
	ApplyAnimation(playerid,"CRACK","crckdeth2", 10.1, 0, 1, 1, 1, 0, 1);
}

timer SleepingBrightness[300](playerid) {
    // SetPlayerScreenFade(playerid, GetPlayerScreenFade(playerid) + 6);
    if(GetPlayerScreenFade(playerid) < 200) Bed_SleepingBrightness[playerid] = defer SleepingBrightness(playerid);
}

timer Stop_Sleeping[TIME_SLEEP * SEC(1)](playerid, Float:x, Float:y, Float:z) {
    Bed_PlayerSleeping[playerid] = 0;
	ClearAnimations(playerid);
	SetPlayerPos(playerid, x, y, z + 1.0);
	SetPlayerHP(playerid, 100.0);
	ChatMsg(playerid, PINK, " > Você dormiu e recuperou a vida. Quando Você morrer nascerá aqui.");
}

hook OnPlayerPickUpItem(playerid, itemid) {
	new ItemType:itemtype = GetItemType(itemid);

	if(itemtype == item_Bed) return Y_HOOKS_BREAK_RETURN_1;

	return 1;
}

stock IsPlayerSleeping(playerid) return Bed_PlayerSleeping[playerid] > 0;