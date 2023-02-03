#include <YSI\y_hooks>

static
	bool:map_Show			[MAX_PLAYERS],
    Text:map_Td1,
	Text:map_Td2,
	Text:map_Td3,
	Text:map_Td4,
    Text:map_Localizer[20],
    
	PlayerText:map_Td5		[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
	PlayerText:map_Td6		[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...};

hook OnGameModeInit()
{
    map_Td1 = TextDrawCreate(124.000000, 115.866737, "samaps:gtasamapbit1");
	TextDrawLetterSize(map_Td1, 0.000000, 0.000000);
	TextDrawTextSize(map_Td1, 201.411544, 164.149963);
	TextDrawAlignment(map_Td1, 1);
	TextDrawColor(map_Td1, -1);
	TextDrawSetShadow(map_Td1, 0);
	TextDrawSetOutline(map_Td1, 0);
	TextDrawFont(map_Td1, 4);

	map_Td2 = TextDrawCreate(325.470428, 115.866737, "samaps:gtasamapbit2");
	TextDrawLetterSize(map_Td2, 0.000000, 0.000000);
	TextDrawTextSize(map_Td2, 201.411544, 164.149963);
	TextDrawAlignment(map_Td2, 1);
	TextDrawColor(map_Td2, -1);
	TextDrawSetShadow(map_Td2, 0);
	TextDrawSetOutline(map_Td2, 0);
	TextDrawFont(map_Td2, 4);

	map_Td3 = TextDrawCreate(124.000000, 280.033386, "samaps:gtasamapbit3");
	TextDrawLetterSize(map_Td3, 0.000000, 0.000000);
	TextDrawTextSize(map_Td3, 201.411544, 164.149963);
	TextDrawAlignment(map_Td3, 1);
	TextDrawColor(map_Td3, -1);
	TextDrawSetShadow(map_Td3, 0);
	TextDrawSetOutline(map_Td3, 0);
	TextDrawFont(map_Td3, 4);

	map_Td4 = TextDrawCreate(325.470428, 280.033386, "samaps:gtasamapbit4");
	TextDrawLetterSize(map_Td4, 0.000000, 0.000000);
	TextDrawTextSize(map_Td4, 201.411544, 164.149963);
	TextDrawAlignment(map_Td4, 1);
	TextDrawColor(map_Td4, -1);
	TextDrawSetShadow(map_Td4, 0);
	TextDrawSetOutline(map_Td4, 0);
	TextDrawFont(map_Td4, 4);

    map_Localizer[0] = TextDrawCreate(177.058776, 119.900000, "usebox");
	TextDrawLetterSize(map_Localizer[0], 0.000000, 35.700000);
	TextDrawTextSize(map_Localizer[0], 177.058776 - 8.9, 0.1);
	TextDrawAlignment(map_Localizer[0], 1);
	TextDrawColor(map_Localizer[0], 0);
	TextDrawUseBox(map_Localizer[0], true);
	TextDrawBoxColor(map_Localizer[0], 102);
	TextDrawSetShadow(map_Localizer[0], 0);
	TextDrawSetOutline(map_Localizer[0], 0);
	TextDrawFont(map_Localizer[0], 0);

	map_Localizer[1] = TextDrawCreate(245.764480, 119.900000, "usebox");
	TextDrawLetterSize(map_Localizer[1], 0.000000, 35.700000);
	TextDrawTextSize(map_Localizer[1], 245.764480 - 8.9, 0.1);
	TextDrawAlignment(map_Localizer[1], 1);
	TextDrawColor(map_Localizer[1], 0);
	TextDrawUseBox(map_Localizer[1], true);
	TextDrawBoxColor(map_Localizer[1], 102);
	TextDrawSetShadow(map_Localizer[1], 0);
	TextDrawSetOutline(map_Localizer[1], 0);
	TextDrawFont(map_Localizer[1], 0);

	map_Localizer[2] = TextDrawCreate(320.588165, 119.900000, "usebox");
	TextDrawLetterSize(map_Localizer[2], 0.000000, 35.700000);
	TextDrawTextSize(map_Localizer[2], 320.588165 - 8.9, 0.1);
	TextDrawAlignment(map_Localizer[2], 1);
	TextDrawColor(map_Localizer[2], 0);
	TextDrawUseBox(map_Localizer[2], true);
	TextDrawBoxColor(map_Localizer[2], 102);
	TextDrawSetShadow(map_Localizer[2], 0);
	TextDrawSetOutline(map_Localizer[2], 0);
	TextDrawFont(map_Localizer[2], 0);

	map_Localizer[3] = TextDrawCreate(393.058746, 119.900000, "usebox");
	TextDrawLetterSize(map_Localizer[3], 0.000000, 35.700000);
	TextDrawTextSize(map_Localizer[3], 393.058746 - 8.9, 0.1);
	TextDrawAlignment(map_Localizer[3], 1);
	TextDrawColor(map_Localizer[3], 0);
	TextDrawUseBox(map_Localizer[3], true);
	TextDrawBoxColor(map_Localizer[3], 102);
	TextDrawSetShadow(map_Localizer[3], 0);
	TextDrawSetOutline(map_Localizer[3], 0);
	TextDrawFont(map_Localizer[3], 0);

	map_Localizer[4] = TextDrawCreate(463.646911, 119.900000, "usebox");
	TextDrawLetterSize(map_Localizer[4], 0.000000, 35.700000);
	TextDrawTextSize(map_Localizer[4], 463.646911 - 8.9, 0.1);
	TextDrawAlignment(map_Localizer[4], 1);
	TextDrawColor(map_Localizer[4], 0);
	TextDrawUseBox(map_Localizer[4], true);
	TextDrawBoxColor(map_Localizer[4], 102);
	TextDrawSetShadow(map_Localizer[4], 0);
	TextDrawSetOutline(map_Localizer[4], 0);
	TextDrawFont(map_Localizer[4], 0);

	map_Localizer[5] = TextDrawCreate(528.176513, 183.500000, "usebox");
	TextDrawLetterSize(map_Localizer[5], 0.000000, -1.1);
	TextDrawTextSize(map_Localizer[5], 125.000000, 0.000000);
	TextDrawAlignment(map_Localizer[5], 1);
	TextDrawColor(map_Localizer[5], 0);
	TextDrawUseBox(map_Localizer[5], true);
	TextDrawBoxColor(map_Localizer[5], 102);
	TextDrawSetShadow(map_Localizer[5], 0);
	TextDrawSetOutline(map_Localizer[5], 0);
	TextDrawFont(map_Localizer[5], 0);

	map_Localizer[6] = TextDrawCreate(528.176513, 252.916656, "usebox");
	TextDrawLetterSize(map_Localizer[6], 0.000000, -1.1);
	TextDrawTextSize(map_Localizer[6], 125.000000, 0.000000);
	TextDrawAlignment(map_Localizer[6], 1);
	TextDrawColor(map_Localizer[6], 0);
	TextDrawUseBox(map_Localizer[6], true);
	TextDrawBoxColor(map_Localizer[6], 102);
	TextDrawSetShadow(map_Localizer[6], 0);
	TextDrawSetOutline(map_Localizer[6], 0);
	TextDrawFont(map_Localizer[6], 0);

	map_Localizer[7] = TextDrawCreate(528.176513, 322.333312, "usebox");
	TextDrawLetterSize(map_Localizer[7], 0.000000, -1.1);
	TextDrawTextSize(map_Localizer[7], 125.000000, 0.000000);
	TextDrawAlignment(map_Localizer[7], 1);
	TextDrawColor(map_Localizer[7], 0);
	TextDrawUseBox(map_Localizer[7], true);
	TextDrawBoxColor(map_Localizer[7], 102);
	TextDrawSetShadow(map_Localizer[7], 0);
	TextDrawSetOutline(map_Localizer[7], 0);
	TextDrawFont(map_Localizer[7], 0);

	map_Localizer[8] = TextDrawCreate(528.176513, 393.499938, "usebox");
	TextDrawLetterSize(map_Localizer[8], 0.000000, -1.1);
	TextDrawTextSize(map_Localizer[8], 125.000000, 0.000000);
	TextDrawAlignment(map_Localizer[8], 1);
	TextDrawColor(map_Localizer[8], 0);
	TextDrawUseBox(map_Localizer[8], true);
	TextDrawBoxColor(map_Localizer[8], 102);
	TextDrawSetShadow(map_Localizer[8], 0);
	TextDrawSetOutline(map_Localizer[8], 0);
	TextDrawFont(map_Localizer[8], 0);

	map_Localizer[9] = TextDrawCreate(114.411781, 142.333328, "A");
	TextDrawLetterSize(map_Localizer[9],  0.449999, 1.600000);
	TextDrawAlignment(map_Localizer[9],  1);
	TextDrawColor(map_Localizer[9],  -558331990);
	TextDrawSetShadow(map_Localizer[9],  0);
	TextDrawSetOutline(map_Localizer[9],  1);
	TextDrawBackgroundColor(map_Localizer[9],  255);
	TextDrawFont(map_Localizer[9],  1);
	TextDrawSetProportional(map_Localizer[9],  1);

	map_Localizer[10] = TextDrawCreate(114.411781, 206.333267, "B");
	TextDrawLetterSize(map_Localizer[10],  0.449999, 1.600000);
	TextDrawAlignment(map_Localizer[10],  1);
	TextDrawColor(map_Localizer[10],  -558331990);
	TextDrawSetShadow(map_Localizer[10],  0);
	TextDrawSetOutline(map_Localizer[10],  1);
	TextDrawBackgroundColor(map_Localizer[10],  255);
	TextDrawFont(map_Localizer[10],  1);
	TextDrawSetProportional(map_Localizer[10],  1);

	map_Localizer[11] = TextDrawCreate(114.411781, 275.256591, "C");
	TextDrawLetterSize(map_Localizer[11],  0.449999, 1.600000);
	TextDrawAlignment(map_Localizer[11],  1);
	TextDrawColor(map_Localizer[11],  -558331990);
	TextDrawSetShadow(map_Localizer[11],  0);
	TextDrawSetOutline(map_Localizer[11],  1);
	TextDrawBackgroundColor(map_Localizer[11],  255);
	TextDrawFont(map_Localizer[11],  1);
	TextDrawSetProportional(map_Localizer[11],  1);

	map_Localizer[12] = TextDrawCreate(114.411781, 347.166656, "D");
	TextDrawLetterSize(map_Localizer[12],  0.449999, 1.600000);
	TextDrawAlignment(map_Localizer[12],  1);
	TextDrawColor(map_Localizer[12],  -558331990);
	TextDrawSetShadow(map_Localizer[12],  0);
	TextDrawSetOutline(map_Localizer[12],  1);
	TextDrawBackgroundColor(map_Localizer[12],  255);
	TextDrawFont(map_Localizer[12],  1);
	TextDrawSetProportional(map_Localizer[12],  1);

	map_Localizer[13] = TextDrawCreate(114.411781, 410.000061, "E");
	TextDrawLetterSize(map_Localizer[13],  0.449999, 1.600000);
	TextDrawAlignment(map_Localizer[13],  1);
	TextDrawColor(map_Localizer[13],  -558331990);
	TextDrawSetShadow(map_Localizer[13],  0);
	TextDrawSetOutline(map_Localizer[13],  1);
	TextDrawBackgroundColor(map_Localizer[13],  255);
	TextDrawFont(map_Localizer[13],  1);
	TextDrawSetProportional(map_Localizer[13],  1);

	map_Localizer[14] = TextDrawCreate(148.764602, 104.166656, "1");
	TextDrawLetterSize(map_Localizer[14],  0.449999, 1.600000);
	TextDrawAlignment(map_Localizer[14],  1);
	TextDrawColor(map_Localizer[14],  -558331990);
	TextDrawSetShadow(map_Localizer[14],  0);
	TextDrawSetOutline(map_Localizer[14],  1);
	TextDrawBackgroundColor(map_Localizer[14],  255);
	TextDrawFont(map_Localizer[14],  0);
	TextDrawSetProportional(map_Localizer[14],  1);

	map_Localizer[15] = TextDrawCreate(208.588104, 104.166656, "2");
	TextDrawLetterSize(map_Localizer[15],  0.449999, 1.600000);
	TextDrawAlignment(map_Localizer[15],  1);
	TextDrawColor(map_Localizer[15],  -558331990);
	TextDrawSetShadow(map_Localizer[15],  0);
	TextDrawSetOutline(map_Localizer[15],  1);
	TextDrawBackgroundColor(map_Localizer[15],  255);
	TextDrawFont(map_Localizer[15],  0);
	TextDrawSetProportional(map_Localizer[15],  1);

	map_Localizer[16] = TextDrawCreate(278.293945, 104.166656, "3");
	TextDrawLetterSize(map_Localizer[16],  0.449999, 1.600000);
	TextDrawAlignment(map_Localizer[16],  1);
	TextDrawColor(map_Localizer[16],  -558331990);
	TextDrawSetShadow(map_Localizer[16],  0);
	TextDrawSetOutline(map_Localizer[16],  1);
	TextDrawBackgroundColor(map_Localizer[16],  255);
	TextDrawFont(map_Localizer[16],  0);
	TextDrawSetProportional(map_Localizer[16],  1);

	map_Localizer[17] = TextDrawCreate(343.764434, 104.166656, "4");
	TextDrawLetterSize(map_Localizer[17],  0.449999, 1.600000);
	TextDrawAlignment(map_Localizer[17],  1);
	TextDrawColor(map_Localizer[17],  -558331990);
	TextDrawSetShadow(map_Localizer[17],  0);
	TextDrawSetOutline(map_Localizer[17],  1);
	TextDrawBackgroundColor(map_Localizer[17],  255);
	TextDrawFont(map_Localizer[17],  0);
	TextDrawSetProportional(map_Localizer[17],  1);

	map_Localizer[18] = TextDrawCreate(418.176177, 104.166656, "5");
	TextDrawLetterSize(map_Localizer[18],  0.449999, 1.600000);
	TextDrawAlignment(map_Localizer[18],  1);
	TextDrawColor(map_Localizer[18],  -558331990);
	TextDrawSetShadow(map_Localizer[18],  0);
	TextDrawSetOutline(map_Localizer[18],  1);
	TextDrawBackgroundColor(map_Localizer[18],  255);
	TextDrawFont(map_Localizer[18],  0);
	TextDrawSetProportional(map_Localizer[18],  1);

	map_Localizer[19] = TextDrawCreate(486.940765, 104.166656, "6");
	TextDrawLetterSize(map_Localizer[19],  0.449999, 1.600000);
	TextDrawAlignment(map_Localizer[19],  1);
	TextDrawColor(map_Localizer[19],  -558331990);
	TextDrawSetShadow(map_Localizer[19],  0);
	TextDrawSetOutline(map_Localizer[19],  1);
	TextDrawBackgroundColor(map_Localizer[19],  255);
	TextDrawFont(map_Localizer[19],  0);
	TextDrawSetProportional(map_Localizer[19],  1);
}

ptask UpdatePlayerMapPosition[500](playerid)
{
	if(map_Show[playerid] && IsPlayerConnected(playerid))
	{
		new Float:x, Float:y, Float:z, name[MAX_PLAYER_NAME], string[MAX_PLAYER_NAME + 7];

		GetPlayerPos(playerid, x, y, z);
		GetPlayerName(playerid, name, 24);
		format(string, sizeof(string), "   %s", name, playerid);

		new Float:map_x = 118.000000 + 402.352966 * (x + 3000.0) / 6000.0;
		new Float:map_y = 104.083335 + 328.999969 * (3000.0 - y) / 6000.0;

		PlayerTextDrawDestroy(playerid, map_Td5[playerid]);
		PlayerTextDrawDestroy(playerid, map_Td6[playerid]);

		if(!IsPlayerInAnyVehicle(playerid))
			map_Td6[playerid] = CreatePlayerTextDraw(playerid, map_x, map_y, "hud:radar_gangN");
		else
		    map_Td6[playerid] = CreatePlayerTextDraw(playerid, map_x, map_y, "hud:radar_impound");

		PlayerTextDrawLetterSize(playerid, map_Td6[playerid], 0.000000, 0.000000);
		PlayerTextDrawTextSize(playerid, map_Td6[playerid], 11.294107, 12.249990);
		PlayerTextDrawAlignment(playerid, map_Td6[playerid], 1);
		PlayerTextDrawColor(playerid, map_Td6[playerid], -1);
		PlayerTextDrawSetShadow(playerid, map_Td6[playerid], 0);
		PlayerTextDrawSetOutline(playerid, map_Td6[playerid], 0);
		PlayerTextDrawFont(playerid, map_Td6[playerid], 4);

		map_Td5[playerid] = CreatePlayerTextDraw(playerid, map_x + 0.5, map_y + 2.0, string);
		PlayerTextDrawLetterSize(playerid, map_Td5[playerid], 0.207646, 0.929167);
		PlayerTextDrawAlignment(playerid, map_Td5[playerid], 1);
		PlayerTextDrawColor(playerid, map_Td5[playerid], -1);
		PlayerTextDrawSetShadow(playerid, map_Td5[playerid], 0);
		PlayerTextDrawSetOutline(playerid, map_Td5[playerid], 1);
		PlayerTextDrawBackgroundColor(playerid, map_Td5[playerid], 255);
		PlayerTextDrawFont(playerid, map_Td5[playerid], 1);
		PlayerTextDrawSetProportional(playerid, map_Td5[playerid], 1);

		PlayerTextDrawShow(playerid, map_Td5[playerid]);
		PlayerTextDrawShow(playerid, map_Td6[playerid]);


	}
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(!(oldkeys & KEY_WALK) && (newkeys & KEY_WALK) && !IsPlayerInAnyVehicle(playerid) ||
	   !(oldkeys & KEY_FIRE) && (newkeys & KEY_FIRE) && IsPlayerInAnyVehicle(playerid))
	{
	    if(map_Show[playerid])
	        HidePlayerDynamicMap(playerid);

		else
			ShowPlayerDynamicMap(playerid);
	}
}

hook OnPlayerConnect(playerid)
{
    map_Show[playerid] = false;
}

stock ShowPlayerDynamicMap(playerid)
{
    if(GetPlayerWeapon(playerid) > 2 && IsPlayerInAnyVehicle(playerid))
		return 1;

	if(!IsPlayerSpawned(playerid))
	    return 1;
	    
	if(IsPlayerSleeping(playerid))
	    return 1;
	    
	if(twk_ItemPlayer(playerid) != INVALID_ITEM_ID)
		return 1;
	
   	TextDrawShowForPlayer(playerid, map_Td1);
    TextDrawShowForPlayer(playerid, map_Td2);
    TextDrawShowForPlayer(playerid, map_Td3);
    TextDrawShowForPlayer(playerid, map_Td4);

    for (new i; i < 20; i++)
	{
	    TextDrawShowForPlayer(playerid, map_Localizer[i]);
	}

    map_Show[playerid] = true;

    PlayerPlaySound(playerid,1145,0.0,0.0,0.0);
    return 1;
}

stock HidePlayerDynamicMap(playerid)
{
    TextDrawHideForPlayer(playerid, map_Td1);
    TextDrawHideForPlayer(playerid, map_Td2);
    TextDrawHideForPlayer(playerid, map_Td3);
    TextDrawHideForPlayer(playerid, map_Td4);

    for (new i; i < 20; i++)
	    TextDrawHideForPlayer(playerid, map_Localizer[i]);

    PlayerTextDrawDestroy(playerid, map_Td5[playerid]);
    PlayerTextDrawDestroy(playerid, map_Td6[playerid]);

    map_Show[playerid] = false;

    PlayerPlaySound(playerid,1145,0.0,0.0,0.0);
}

stock IsPlayerInDynamicMap(playerid)
{
    if(!IsPlayerConnected(playerid))
		return 0;
		
	return map_Show[playerid];
}
