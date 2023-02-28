#include <YSI\y_hooks>

static
	PlayerText:	WatchBackground[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...};

new PlayerText:Interface0[MAX_PLAYERS];
new PlayerText:Interface1[MAX_PLAYERS];
new PlayerText:Interface2[MAX_PLAYERS];
new PlayerText:Interface3[MAX_PLAYERS];
new PlayerText:Interface4[MAX_PLAYERS];
new PlayerText:Interface5[MAX_PLAYERS];
new PlayerText:Interface6[MAX_PLAYERS];
new PlayerText:Interface7[MAX_PLAYERS];
new PlayerText:Interface8[MAX_PLAYERS];
new PlayerText:Interface9[MAX_PLAYERS];
new PlayerText:Interface10[MAX_PLAYERS];
new PlayerText:Interface11[MAX_PLAYERS];
new PlayerText:Interface12[MAX_PLAYERS];
new PlayerText:Interface13[MAX_PLAYERS];
new PlayerText:Interface14[MAX_PLAYERS];

ShowWatch(playerid) 
	PlayerTextDrawShow(playerid, WatchBackground[playerid]);

HideWatch(playerid) 
	PlayerTextDrawHide(playerid, WatchBackground[playerid]);


ptask ShowStatus[SEC(1)](playerid)
{
	if(!IsPlayerSpawned(playerid)) return;

	if(IsPlayerInTutorial(playerid)) return;
	    
	new
		str[150],
		Float:food,
		Float:bleed;
		
    food = GetPlayerFP(playerid);
    bleed = GetPlayerBleedRate(playerid);
    
// ---------------------------------------------------------------------------------------
    
	if(food >= 30.0)
		
    format(str, sizeof(str), ls(playerid, "STTFOME"), GetPlayerFP(playerid));

	PlayerTextDrawSetString(playerid, Interface2[playerid], str);
	PlayerTextDrawShow(playerid, Interface2[playerid]);
		
	if(food < 30.0)
	
	format(str, sizeof(str), ls(playerid, "STTFOME2"), GetPlayerFP(playerid));

	PlayerTextDrawSetString(playerid, Interface2[playerid], str);
	PlayerTextDrawShow(playerid, Interface2[playerid]);
	
// ---------------------------------------------------------------------------------------

	if(bleed == 0.00)

	format(str, sizeof(str), ls(playerid, "STTSANGUE"), GetPlayerBleedRate(playerid));

	PlayerTextDrawSetString(playerid, Interface4[playerid], str);
	PlayerTextDrawShow(playerid, Interface4[playerid]);

	if(bleed >= 0.01)

	format(str, sizeof(str), ls(playerid, "STTSANGUE2"), GetPlayerBleedRate(playerid));

	PlayerTextDrawSetString(playerid, Interface4[playerid], str);
	PlayerTextDrawShow(playerid, Interface4[playerid]);

// ---------------------------------------------------------------------------------------

	format(str, sizeof(str), ls(playerid, "STTSCORE"), GetPlayerScore(playerid));
	PlayerTextDrawSetString(playerid, Interface6[playerid], str);
	PlayerTextDrawShow(playerid, Interface6[playerid]);

// ---------------------------------------------------------------------------------------

	format(str, sizeof(str), ls(playerid, "STTPED"), GetPlayerPED(playerid));
	PlayerTextDrawSetString(playerid, Interface8[playerid], str);
	PlayerTextDrawShow(playerid, Interface8[playerid]);

// ---------------------------------------------------------------------------------------

	if(strlen(GetPlayerClan(playerid)) < 5) {
		format(str, sizeof(str), "Sem clan");
	} else {
		format(str, sizeof(str), ls(playerid, "STTCLAN"), GetPlayerClan(playerid));
	}

	//format(str, sizeof(str), ls(playerid, "STTCLAN"), GetPlayerClan(playerid));
	PlayerTextDrawSetString(playerid, Interface12[playerid], str);
	PlayerTextDrawShow(playerid, Interface12[playerid]);

// ---------------------------------------------------------------------------------------

	return;
}

hook OnPlayerConnect(playerid)
{
	Interface0[playerid] = CreatePlayerTextDraw(playerid, 652.000000, 421.000000, "_");
	PlayerTextDrawBackgroundColor(playerid, Interface0[playerid], 255);
	PlayerTextDrawFont(playerid, Interface0[playerid], 0);
	PlayerTextDrawLetterSize(playerid, Interface0[playerid], 0.400000, 2.799999);
	PlayerTextDrawColor(playerid, Interface0[playerid], 153);
	PlayerTextDrawSetOutline(playerid, Interface0[playerid], 0);
	PlayerTextDrawSetProportional(playerid, Interface0[playerid], 1);
	PlayerTextDrawSetShadow(playerid, Interface0[playerid], 1);
	PlayerTextDrawUseBox(playerid, Interface0[playerid], 1);
	PlayerTextDrawBoxColor(playerid, Interface0[playerid], 153);
	PlayerTextDrawTextSize(playerid, Interface0[playerid], 559.000000, 0.000000);

	Interface1[playerid] = CreatePlayerTextDraw(playerid, 563.000000, 421.000000, "hud:radar_burgershot");
	PlayerTextDrawBackgroundColor(playerid, Interface1[playerid], 255);
	PlayerTextDrawFont(playerid, Interface1[playerid], 4);
	PlayerTextDrawLetterSize(playerid, Interface1[playerid], 0.500000, 1.000000);
	PlayerTextDrawColor(playerid, Interface1[playerid], -1);
	PlayerTextDrawSetOutline(playerid, Interface1[playerid], 0);
	PlayerTextDrawSetProportional(playerid, Interface1[playerid], 1);
	PlayerTextDrawSetShadow(playerid, Interface1[playerid], 1);
	PlayerTextDrawUseBox(playerid, Interface1[playerid], 1);
	PlayerTextDrawBoxColor(playerid, Interface1[playerid], 255);
	PlayerTextDrawTextSize(playerid, Interface1[playerid], 10.000000, 10.000000);

	Interface2[playerid] = CreatePlayerTextDraw(playerid, 576.000000, 420.000000, "87.4");
	PlayerTextDrawBackgroundColor(playerid, Interface2[playerid], 255);
	PlayerTextDrawFont(playerid, Interface2[playerid], 1);
	PlayerTextDrawLetterSize(playerid, Interface2[playerid], 0.250000, 1.200000);
	PlayerTextDrawColor(playerid, Interface2[playerid], -1);
	PlayerTextDrawSetOutline(playerid, Interface2[playerid], 0);
	PlayerTextDrawSetProportional(playerid, Interface2[playerid], 1);
	PlayerTextDrawSetShadow(playerid, Interface2[playerid], 1);

	Interface3[playerid] = CreatePlayerTextDraw(playerid, 563.000000, 436.000000, "hud:radar_centre");
	PlayerTextDrawBackgroundColor(playerid, Interface3[playerid], 255);
	PlayerTextDrawFont(playerid, Interface3[playerid], 4);
	PlayerTextDrawLetterSize(playerid, Interface3[playerid], 0.500000, 1.000000);
	PlayerTextDrawColor(playerid, Interface3[playerid], -16776961);
	PlayerTextDrawSetOutline(playerid, Interface3[playerid], 0);
	PlayerTextDrawSetProportional(playerid, Interface3[playerid], 1);
	PlayerTextDrawSetShadow(playerid, Interface3[playerid], 1);
	PlayerTextDrawUseBox(playerid, Interface3[playerid], 1);
	PlayerTextDrawBoxColor(playerid, Interface3[playerid], 255);
	PlayerTextDrawTextSize(playerid, Interface3[playerid], 10.000000, 10.000000);

	Interface4[playerid] = CreatePlayerTextDraw(playerid, 576.000000, 435.000000, "0.00");
	PlayerTextDrawBackgroundColor(playerid, Interface4[playerid], 255);
	PlayerTextDrawFont(playerid, Interface4[playerid], 1);
	PlayerTextDrawLetterSize(playerid, Interface4[playerid], 0.250000, 1.200000);
	PlayerTextDrawColor(playerid, Interface4[playerid], -1);
	PlayerTextDrawSetOutline(playerid, Interface4[playerid], 0);
	PlayerTextDrawSetProportional(playerid, Interface4[playerid], 1);
	PlayerTextDrawSetShadow(playerid, Interface4[playerid], 1);

	Interface5[playerid] = CreatePlayerTextDraw(playerid, 606.000000, 422.000000, "hud:radar_emmetGun");
	PlayerTextDrawBackgroundColor(playerid, Interface5[playerid], 255);
	PlayerTextDrawFont(playerid, Interface5[playerid], 4);
	PlayerTextDrawLetterSize(playerid, Interface5[playerid], 0.500000, 1.000000);
	PlayerTextDrawColor(playerid, Interface5[playerid], -1);
	PlayerTextDrawSetOutline(playerid, Interface5[playerid], 0);
	PlayerTextDrawSetProportional(playerid, Interface5[playerid], 1);
	PlayerTextDrawSetShadow(playerid, Interface5[playerid], 1);
	PlayerTextDrawUseBox(playerid, Interface5[playerid], 1);
	PlayerTextDrawBoxColor(playerid, Interface5[playerid], 255);
	PlayerTextDrawTextSize(playerid, Interface5[playerid], 10.000000, 10.000000);

	Interface6[playerid] = CreatePlayerTextDraw(playerid, 619.000000, 421.000000, "14");
	PlayerTextDrawBackgroundColor(playerid, Interface6[playerid], 255);
	PlayerTextDrawFont(playerid, Interface6[playerid], 1);
	PlayerTextDrawLetterSize(playerid, Interface6[playerid], 0.250000, 1.200000);
	PlayerTextDrawColor(playerid, Interface6[playerid], -1);
	PlayerTextDrawSetOutline(playerid, Interface6[playerid], 0);
	PlayerTextDrawSetProportional(playerid, Interface6[playerid], 1);
	PlayerTextDrawSetShadow(playerid, Interface6[playerid], 1);

	Interface7[playerid] = CreatePlayerTextDraw(playerid, 606.000000, 436.200012, "hud:radar_gangy");
	PlayerTextDrawBackgroundColor(playerid, Interface7[playerid], 255);
	PlayerTextDrawFont(playerid, Interface7[playerid], 4);
	PlayerTextDrawLetterSize(playerid, Interface7[playerid], 0.500000, 1.000000);
	PlayerTextDrawColor(playerid, Interface7[playerid], -1);
	PlayerTextDrawSetOutline(playerid, Interface7[playerid], 0);
	PlayerTextDrawSetProportional(playerid, Interface7[playerid], 1);
	PlayerTextDrawSetShadow(playerid, Interface7[playerid], 1);
	PlayerTextDrawUseBox(playerid, Interface7[playerid], 1);
	PlayerTextDrawBoxColor(playerid, Interface7[playerid], 255);
	PlayerTextDrawTextSize(playerid, Interface7[playerid], 10.000000, 10.000000);

	Interface8[playerid] = CreatePlayerTextDraw(playerid, 619.000000, 435.000000, "3");
	PlayerTextDrawBackgroundColor(playerid, Interface8[playerid], 255);
	PlayerTextDrawFont(playerid, Interface8[playerid], 1);
	PlayerTextDrawLetterSize(playerid, Interface8[playerid], 0.250000, 1.200000);
	PlayerTextDrawColor(playerid, Interface8[playerid], -1);
	PlayerTextDrawSetOutline(playerid, Interface8[playerid], 0);
	PlayerTextDrawSetProportional(playerid, Interface8[playerid], 1);
	PlayerTextDrawSetShadow(playerid, Interface8[playerid], 1);

	Interface9[playerid] = CreatePlayerTextDraw(playerid, 652.000000, 402.000000, "_");
	PlayerTextDrawBackgroundColor(playerid, Interface9[playerid], 255);
	PlayerTextDrawFont(playerid, Interface9[playerid], 0);
	PlayerTextDrawLetterSize(playerid, Interface9[playerid], 0.400000, 1.299999);
	PlayerTextDrawColor(playerid, Interface9[playerid], -1);
	PlayerTextDrawSetOutline(playerid, Interface9[playerid], 0);
	PlayerTextDrawSetProportional(playerid, Interface9[playerid], 1);
	PlayerTextDrawSetShadow(playerid, Interface9[playerid], 1);
	PlayerTextDrawUseBox(playerid, Interface9[playerid], 1);
	PlayerTextDrawBoxColor(playerid, Interface9[playerid], 153);
	PlayerTextDrawTextSize(playerid, Interface9[playerid], 559.000000, 13.000000);

	Interface10[playerid] = CreatePlayerTextDraw(playerid, 562.000000, 421.000000, "_");
	PlayerTextDrawBackgroundColor(playerid, Interface10[playerid], 255);
	PlayerTextDrawFont(playerid, Interface10[playerid], 0);
	PlayerTextDrawLetterSize(playerid, Interface10[playerid], 0.400000, 2.799999);
	PlayerTextDrawColor(playerid, Interface10[playerid], 361504767);
	PlayerTextDrawSetOutline(playerid, Interface10[playerid], 0);
	PlayerTextDrawSetProportional(playerid, Interface10[playerid], 1);
	PlayerTextDrawSetShadow(playerid, Interface10[playerid], 1);
	PlayerTextDrawUseBox(playerid, Interface10[playerid], 1);
	PlayerTextDrawBoxColor(playerid, Interface10[playerid], 748);
	PlayerTextDrawTextSize(playerid, Interface10[playerid], 555.999023, 0.000000);

	Interface11[playerid] = CreatePlayerTextDraw(playerid, 563.000000, 403.000000, "hud:radar_gangg");
	PlayerTextDrawBackgroundColor(playerid, Interface11[playerid], 255);
	PlayerTextDrawFont(playerid, Interface11[playerid], 4);
	PlayerTextDrawLetterSize(playerid, Interface11[playerid], 0.500000, 1.000000);
	PlayerTextDrawColor(playerid, Interface11[playerid], -1);
	PlayerTextDrawSetOutline(playerid, Interface11[playerid], 0);
	PlayerTextDrawSetProportional(playerid, Interface11[playerid], 1);
	PlayerTextDrawSetShadow(playerid, Interface11[playerid], 1);
	PlayerTextDrawUseBox(playerid, Interface11[playerid], 1);
	PlayerTextDrawBoxColor(playerid, Interface11[playerid], 255);
	PlayerTextDrawTextSize(playerid, Interface11[playerid], 10.000000, 10.000000);

	Interface12[playerid] = CreatePlayerTextDraw(playerid, 574.000000, 404.000000, "Voc� est� sem um clan.");
	PlayerTextDrawBackgroundColor(playerid, Interface12[playerid], 255);
	PlayerTextDrawFont(playerid, Interface12[playerid], 1);
	PlayerTextDrawLetterSize(playerid, Interface12[playerid], 0.160000, 0.899999);
	PlayerTextDrawColor(playerid, Interface12[playerid], -1);
	PlayerTextDrawSetOutline(playerid, Interface12[playerid], 0);
	PlayerTextDrawSetProportional(playerid, Interface12[playerid], 1);
	PlayerTextDrawSetShadow(playerid, Interface12[playerid], 1);

	Interface13[playerid] = CreatePlayerTextDraw(playerid, 562.000000, 402.000000, "_");
	PlayerTextDrawBackgroundColor(playerid, Interface13[playerid], 255);
	PlayerTextDrawFont(playerid, Interface13[playerid], 0);
	PlayerTextDrawLetterSize(playerid, Interface13[playerid], 0.469999, 1.299999);
	PlayerTextDrawColor(playerid, Interface13[playerid], 361504767);
	PlayerTextDrawSetOutline(playerid, Interface13[playerid], 0);
	PlayerTextDrawSetProportional(playerid, Interface13[playerid], 1);
	PlayerTextDrawSetShadow(playerid, Interface13[playerid], 1);
	PlayerTextDrawUseBox(playerid, Interface13[playerid], 1);
	PlayerTextDrawBoxColor(playerid, Interface13[playerid], 748);
	PlayerTextDrawTextSize(playerid, Interface13[playerid], 555.999023, 0.000000);

	Interface14[playerid] = CreatePlayerTextDraw(playerid, 602.000244, 421.000000, "_");
	PlayerTextDrawBackgroundColor(playerid, Interface14[playerid], 255);
	PlayerTextDrawFont(playerid, Interface14[playerid], 0);
	PlayerTextDrawLetterSize(playerid, Interface14[playerid], 0.400000, 2.799999);
	PlayerTextDrawColor(playerid, Interface14[playerid], 361504767);
	PlayerTextDrawSetOutline(playerid, Interface14[playerid], 0);
	PlayerTextDrawSetProportional(playerid, Interface14[playerid], 1);
	PlayerTextDrawSetShadow(playerid, Interface14[playerid], 1);
	PlayerTextDrawUseBox(playerid, Interface14[playerid], 1);
	PlayerTextDrawTextSize(playerid, Interface14[playerid], 598.999023, 0.000000);
	PlayerTextDrawBoxColor(playerid, Interface14[playerid], 255);

	WatchBackground[playerid]		=CreatePlayerTextDraw(playerid, 33.000000, 338.000000, "LD_POOL:ball");
	PlayerTextDrawBackgroundColor	(playerid, WatchBackground[playerid], 255);
	PlayerTextDrawFont				(playerid, WatchBackground[playerid], 4);
	PlayerTextDrawLetterSize		(playerid, WatchBackground[playerid], 0.500000, 0.000000);
	PlayerTextDrawColor				(playerid, WatchBackground[playerid], 255);
	PlayerTextDrawSetOutline		(playerid, WatchBackground[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, WatchBackground[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, WatchBackground[playerid], 1);
	PlayerTextDrawUseBox			(playerid, WatchBackground[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, WatchBackground[playerid], 255);
	PlayerTextDrawTextSize			(playerid, WatchBackground[playerid], 108.000000, 89.000000);

}

LoadPlayerHUD(playerid)
{
	PlayerTextDrawShow(playerid, Interface0[playerid]);
	PlayerTextDrawShow(playerid, Interface1[playerid]);
	PlayerTextDrawShow(playerid, Interface3[playerid]);
	PlayerTextDrawShow(playerid, Interface5[playerid]);
	PlayerTextDrawShow(playerid, Interface7[playerid]);
	PlayerTextDrawShow(playerid, Interface9[playerid]);
	PlayerTextDrawShow(playerid, Interface10[playerid]);
	PlayerTextDrawShow(playerid, Interface11[playerid]);
	PlayerTextDrawShow(playerid, Interface13[playerid]);
	PlayerTextDrawShow(playerid, Interface14[playerid]);
	ShowWatch(playerid);
}

UnloadPlayerHUD(playerid)
{
	PlayerTextDrawHide(playerid, Interface0[playerid]);
	PlayerTextDrawHide(playerid, Interface1[playerid]);
	PlayerTextDrawHide(playerid, Interface3[playerid]);
	PlayerTextDrawHide(playerid, Interface5[playerid]);
	PlayerTextDrawHide(playerid, Interface7[playerid]);
	PlayerTextDrawHide(playerid, Interface9[playerid]);
	PlayerTextDrawHide(playerid, Interface10[playerid]);
	PlayerTextDrawHide(playerid, Interface11[playerid]);
	PlayerTextDrawHide(playerid, Interface13[playerid]);
	PlayerTextDrawHide(playerid, Interface14[playerid]);
	HideWatch(playerid);
}
