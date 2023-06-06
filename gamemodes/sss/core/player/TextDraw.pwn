#include <YSI\y_hooks>

static PlayerText:HUD[MAX_PLAYERS][MAX_HUD_COMPONENTS];

/* 
	Isso continua a ser uma prática terrível.
	Os valores apenas deveria ser atuaiizados quando necessário. N�o a cada segundo.
 */
ptask UpdateHUD[SEC(1)](playerid) {
	if(!IsPlayerSpawned(playerid)) return 0;

	new const Float:food          = GetPlayerFP(playerid);
	new const Float:bleed         = GetPlayerBleedRate(playerid);
	new clan[MAX_CLAN_NAME];
	
	clan = GetPlayerClan(playerid);
    
	SetHudComponentString(playerid, HUD_STATUS_FOOD_VALUE,  sprintf("~%s~~h~~h~%0.1f", food >= 20.0 ? "g" : "r", food));
	SetHudComponentString(playerid, HUD_STATUS_BLEED_VALUE, sprintf("~%s~~h~~h~%0.2f", bleed > 0.009999 ? "r" : "g", bleed));
	SetHudComponentString(playerid, HUD_STATUS_KILLS_VALUE, sprintf("%d", GetPlayerScore(playerid)));
	SetHudComponentString(playerid, HUD_STATUS_PED_VALUE,   sprintf("%d", GetPlayerPED(playerid)));
	SetHudComponentString(playerid, HUD_STATUS_CLAN_VALUE,  strlen(clan) > 5 ? clan : "Sem Clan");

	return 1;
}

hook OnPlayerConnect(playerid) {
	HUD[playerid][HUD_STATUS_BG] = CreatePlayerTextDraw(playerid, 652.000000, 421.000000, "_");
	PlayerTextDrawBackgroundColor(playerid, HUD[playerid][HUD_STATUS_BG], 255);
	PlayerTextDrawFont(playerid, HUD[playerid][HUD_STATUS_BG], 0);
	PlayerTextDrawLetterSize(playerid, HUD[playerid][HUD_STATUS_BG], 0.400000, 2.799999);
	PlayerTextDrawColor(playerid, HUD[playerid][HUD_STATUS_BG], 153);
	PlayerTextDrawSetOutline(playerid, HUD[playerid][HUD_STATUS_BG], 0);
	PlayerTextDrawSetProportional(playerid, HUD[playerid][HUD_STATUS_BG], 1);
	PlayerTextDrawSetShadow(playerid, HUD[playerid][HUD_STATUS_BG], 1);
	PlayerTextDrawUseBox(playerid, HUD[playerid][HUD_STATUS_BG], 1);
	PlayerTextDrawBoxColor(playerid, HUD[playerid][HUD_STATUS_BG], 153);
	PlayerTextDrawTextSize(playerid, HUD[playerid][HUD_STATUS_BG], 559.000000, 0.000000);

	HUD[playerid][HUD_STATUS_FOOD_SPRITE] = CreatePlayerTextDraw(playerid, 563.000000, 421.000000, "hud:radar_burgershot");
	PlayerTextDrawBackgroundColor(playerid, HUD[playerid][HUD_STATUS_FOOD_SPRITE], 255);
	PlayerTextDrawFont(playerid, HUD[playerid][HUD_STATUS_FOOD_SPRITE], 4);
	PlayerTextDrawLetterSize(playerid, HUD[playerid][HUD_STATUS_FOOD_SPRITE], 0.500000, 1.000000);
	PlayerTextDrawColor(playerid, HUD[playerid][HUD_STATUS_FOOD_SPRITE], -1);
	PlayerTextDrawSetOutline(playerid, HUD[playerid][HUD_STATUS_FOOD_SPRITE], 0);
	PlayerTextDrawSetProportional(playerid, HUD[playerid][HUD_STATUS_FOOD_SPRITE], 1);
	PlayerTextDrawSetShadow(playerid, HUD[playerid][HUD_STATUS_FOOD_SPRITE], 1);
	PlayerTextDrawUseBox(playerid, HUD[playerid][HUD_STATUS_FOOD_SPRITE], 1);
	PlayerTextDrawBoxColor(playerid, HUD[playerid][HUD_STATUS_FOOD_SPRITE], 255);
	PlayerTextDrawTextSize(playerid, HUD[playerid][HUD_STATUS_FOOD_SPRITE], 10.000000, 10.000000);

	HUD[playerid][HUD_STATUS_FOOD_VALUE] = CreatePlayerTextDraw(playerid, 576.000000, 420.000000, "87.4");
	PlayerTextDrawBackgroundColor(playerid, HUD[playerid][HUD_STATUS_FOOD_VALUE], 255);
	PlayerTextDrawFont(playerid, HUD[playerid][HUD_STATUS_FOOD_VALUE], 1);
	PlayerTextDrawLetterSize(playerid, HUD[playerid][HUD_STATUS_FOOD_VALUE], 0.250000, 1.200000);
	PlayerTextDrawColor(playerid, HUD[playerid][HUD_STATUS_FOOD_VALUE], -1);
	PlayerTextDrawSetOutline(playerid, HUD[playerid][HUD_STATUS_FOOD_VALUE], 0);
	PlayerTextDrawSetProportional(playerid, HUD[playerid][HUD_STATUS_FOOD_VALUE], 1);
	PlayerTextDrawSetShadow(playerid, HUD[playerid][HUD_STATUS_FOOD_VALUE], 1);

	HUD[playerid][HUD_STATUS_BLEED_SPRITE] = CreatePlayerTextDraw(playerid, 563.000000, 436.000000, "hud:radar_centre");
	PlayerTextDrawBackgroundColor(playerid, HUD[playerid][HUD_STATUS_BLEED_SPRITE], 255);
	PlayerTextDrawFont(playerid, HUD[playerid][HUD_STATUS_BLEED_SPRITE], 4);
	PlayerTextDrawLetterSize(playerid, HUD[playerid][HUD_STATUS_BLEED_SPRITE], 0.500000, 1.000000);
	PlayerTextDrawColor(playerid, HUD[playerid][HUD_STATUS_BLEED_SPRITE], -16776961);
	PlayerTextDrawSetOutline(playerid, HUD[playerid][HUD_STATUS_BLEED_SPRITE], 0);
	PlayerTextDrawSetProportional(playerid, HUD[playerid][HUD_STATUS_BLEED_SPRITE], 1);
	PlayerTextDrawSetShadow(playerid, HUD[playerid][HUD_STATUS_BLEED_SPRITE], 1);
	PlayerTextDrawUseBox(playerid, HUD[playerid][HUD_STATUS_BLEED_SPRITE], 1);
	PlayerTextDrawBoxColor(playerid, HUD[playerid][HUD_STATUS_BLEED_SPRITE], 255);
	PlayerTextDrawTextSize(playerid, HUD[playerid][HUD_STATUS_BLEED_SPRITE], 10.000000, 10.000000);

	HUD[playerid][HUD_STATUS_BLEED_VALUE] = CreatePlayerTextDraw(playerid, 576.000000, 435.000000, "0.00");
	PlayerTextDrawBackgroundColor(playerid, HUD[playerid][HUD_STATUS_BLEED_VALUE], 255);
	PlayerTextDrawFont(playerid, HUD[playerid][HUD_STATUS_BLEED_VALUE], 1);
	PlayerTextDrawLetterSize(playerid, HUD[playerid][HUD_STATUS_BLEED_VALUE], 0.250000, 1.200000);
	PlayerTextDrawColor(playerid, HUD[playerid][HUD_STATUS_BLEED_VALUE], -1);
	PlayerTextDrawSetOutline(playerid, HUD[playerid][HUD_STATUS_BLEED_VALUE], 0);
	PlayerTextDrawSetProportional(playerid, HUD[playerid][HUD_STATUS_BLEED_VALUE], 1);
	PlayerTextDrawSetShadow(playerid, HUD[playerid][HUD_STATUS_BLEED_VALUE], 1);

	HUD[playerid][HUD_STATUS_KILLS_SPRITE] = CreatePlayerTextDraw(playerid, 606.000000, 422.000000, "hud:radar_emmetGun");
	PlayerTextDrawBackgroundColor(playerid, HUD[playerid][HUD_STATUS_KILLS_SPRITE], 255);
	PlayerTextDrawFont(playerid, HUD[playerid][HUD_STATUS_KILLS_SPRITE], 4);
	PlayerTextDrawLetterSize(playerid, HUD[playerid][HUD_STATUS_KILLS_SPRITE], 0.500000, 1.000000);
	PlayerTextDrawColor(playerid, HUD[playerid][HUD_STATUS_KILLS_SPRITE], -1);
	PlayerTextDrawSetOutline(playerid, HUD[playerid][HUD_STATUS_KILLS_SPRITE], 0);
	PlayerTextDrawSetProportional(playerid, HUD[playerid][HUD_STATUS_KILLS_SPRITE], 1);
	PlayerTextDrawSetShadow(playerid, HUD[playerid][HUD_STATUS_KILLS_SPRITE], 1);
	PlayerTextDrawUseBox(playerid, HUD[playerid][HUD_STATUS_KILLS_SPRITE], 1);
	PlayerTextDrawBoxColor(playerid, HUD[playerid][HUD_STATUS_KILLS_SPRITE], 255);
	PlayerTextDrawTextSize(playerid, HUD[playerid][HUD_STATUS_KILLS_SPRITE], 10.000000, 10.000000);

	HUD[playerid][HUD_STATUS_KILLS_VALUE] = CreatePlayerTextDraw(playerid, 619.000000, 421.000000, "14");
	PlayerTextDrawBackgroundColor(playerid, HUD[playerid][HUD_STATUS_KILLS_VALUE], 255);
	PlayerTextDrawFont(playerid, HUD[playerid][HUD_STATUS_KILLS_VALUE], 1);
	PlayerTextDrawLetterSize(playerid, HUD[playerid][HUD_STATUS_KILLS_VALUE], 0.250000, 1.200000);
	PlayerTextDrawColor(playerid, HUD[playerid][HUD_STATUS_KILLS_VALUE], WHITE);
	PlayerTextDrawSetOutline(playerid, HUD[playerid][HUD_STATUS_KILLS_VALUE], 0);
	PlayerTextDrawSetProportional(playerid, HUD[playerid][HUD_STATUS_KILLS_VALUE], 1);
	PlayerTextDrawSetShadow(playerid, HUD[playerid][HUD_STATUS_KILLS_VALUE], 1);

	HUD[playerid][HUD_STATUS_PED_SPRITE] = CreatePlayerTextDraw(playerid, 606.000000, 436.200012, "hud:radar_gangy");
	PlayerTextDrawBackgroundColor(playerid, HUD[playerid][HUD_STATUS_PED_SPRITE], 255);
	PlayerTextDrawFont(playerid, HUD[playerid][HUD_STATUS_PED_SPRITE], 4);
	PlayerTextDrawLetterSize(playerid, HUD[playerid][HUD_STATUS_PED_SPRITE], 0.500000, 1.000000);
	PlayerTextDrawColor(playerid, HUD[playerid][HUD_STATUS_PED_SPRITE], -1);
	PlayerTextDrawSetOutline(playerid, HUD[playerid][HUD_STATUS_PED_SPRITE], 0);
	PlayerTextDrawSetProportional(playerid, HUD[playerid][HUD_STATUS_PED_SPRITE], 1);
	PlayerTextDrawSetShadow(playerid, HUD[playerid][HUD_STATUS_PED_SPRITE], 1);
	PlayerTextDrawUseBox(playerid, HUD[playerid][HUD_STATUS_PED_SPRITE], 1);
	PlayerTextDrawBoxColor(playerid, HUD[playerid][HUD_STATUS_PED_SPRITE], 255);
	PlayerTextDrawTextSize(playerid, HUD[playerid][HUD_STATUS_PED_SPRITE], 10.000000, 10.000000);

	HUD[playerid][HUD_STATUS_PED_VALUE] = CreatePlayerTextDraw(playerid, 619.000000, 435.000000, "3");
	PlayerTextDrawBackgroundColor(playerid, HUD[playerid][HUD_STATUS_PED_VALUE], 255);
	PlayerTextDrawFont(playerid, HUD[playerid][HUD_STATUS_PED_VALUE], 1);
	PlayerTextDrawLetterSize(playerid, HUD[playerid][HUD_STATUS_PED_VALUE], 0.250000, 1.200000);
	PlayerTextDrawColor(playerid, HUD[playerid][HUD_STATUS_PED_VALUE], -1);
	PlayerTextDrawSetOutline(playerid, HUD[playerid][HUD_STATUS_PED_VALUE], 0);
	PlayerTextDrawSetProportional(playerid, HUD[playerid][HUD_STATUS_PED_VALUE], 1);
	PlayerTextDrawSetShadow(playerid, HUD[playerid][HUD_STATUS_PED_VALUE], 1);

	HUD[playerid][HUD_STATUS_CLAN_BG] = CreatePlayerTextDraw(playerid, 652.000000, 402.000000, "_");
	PlayerTextDrawBackgroundColor(playerid, HUD[playerid][HUD_STATUS_CLAN_BG], 255);
	PlayerTextDrawFont(playerid, HUD[playerid][HUD_STATUS_CLAN_BG], 0);
	PlayerTextDrawLetterSize(playerid, HUD[playerid][HUD_STATUS_CLAN_BG], 0.400000, 1.299999);
	PlayerTextDrawColor(playerid, HUD[playerid][HUD_STATUS_CLAN_BG], -1);
	PlayerTextDrawSetOutline(playerid, HUD[playerid][HUD_STATUS_CLAN_BG], 0);
	PlayerTextDrawSetProportional(playerid, HUD[playerid][HUD_STATUS_CLAN_BG], 1);
	PlayerTextDrawSetShadow(playerid, HUD[playerid][HUD_STATUS_CLAN_BG], 1);
	PlayerTextDrawUseBox(playerid, HUD[playerid][HUD_STATUS_CLAN_BG], 1);
	PlayerTextDrawBoxColor(playerid, HUD[playerid][HUD_STATUS_CLAN_BG], 153);
	PlayerTextDrawTextSize(playerid, HUD[playerid][HUD_STATUS_CLAN_BG], 559.000000, 13.000000);

	HUD[playerid][HUD_STATUS_CLAN_BORDER_LEFT] = CreatePlayerTextDraw(playerid, 562.000000, 421.000000, "_");
	PlayerTextDrawBackgroundColor(playerid, HUD[playerid][HUD_STATUS_CLAN_BORDER_LEFT], 255);
	PlayerTextDrawFont(playerid, HUD[playerid][HUD_STATUS_CLAN_BORDER_LEFT], 0);
	PlayerTextDrawLetterSize(playerid, HUD[playerid][HUD_STATUS_CLAN_BORDER_LEFT], 0.400000, 2.799999);
	PlayerTextDrawColor(playerid, HUD[playerid][HUD_STATUS_CLAN_BORDER_LEFT], 361504767);
	PlayerTextDrawSetOutline(playerid, HUD[playerid][HUD_STATUS_CLAN_BORDER_LEFT], 0);
	PlayerTextDrawSetProportional(playerid, HUD[playerid][HUD_STATUS_CLAN_BORDER_LEFT], 1);
	PlayerTextDrawSetShadow(playerid, HUD[playerid][HUD_STATUS_CLAN_BORDER_LEFT], 1);
	PlayerTextDrawUseBox(playerid, HUD[playerid][HUD_STATUS_CLAN_BORDER_LEFT], 1);
	PlayerTextDrawBoxColor(playerid, HUD[playerid][HUD_STATUS_CLAN_BORDER_LEFT], 748);
	PlayerTextDrawTextSize(playerid, HUD[playerid][HUD_STATUS_CLAN_BORDER_LEFT], 555.999023, 0.000000);

	HUD[playerid][HUD_STATUS_CLAN_SPRITE] = CreatePlayerTextDraw(playerid, 563.000000, 403.000000, "hud:radar_gangg");
	PlayerTextDrawBackgroundColor(playerid, HUD[playerid][HUD_STATUS_CLAN_SPRITE], 255);
	PlayerTextDrawFont(playerid, HUD[playerid][HUD_STATUS_CLAN_SPRITE], 4);
	PlayerTextDrawLetterSize(playerid, HUD[playerid][HUD_STATUS_CLAN_SPRITE], 0.500000, 1.000000);
	PlayerTextDrawColor(playerid, HUD[playerid][HUD_STATUS_CLAN_SPRITE], -1);
	PlayerTextDrawSetOutline(playerid, HUD[playerid][HUD_STATUS_CLAN_SPRITE], 0);
	PlayerTextDrawSetProportional(playerid, HUD[playerid][HUD_STATUS_CLAN_SPRITE], 1);
	PlayerTextDrawSetShadow(playerid, HUD[playerid][HUD_STATUS_CLAN_SPRITE], 1);
	PlayerTextDrawUseBox(playerid, HUD[playerid][HUD_STATUS_CLAN_SPRITE], 1);
	PlayerTextDrawBoxColor(playerid, HUD[playerid][HUD_STATUS_CLAN_SPRITE], 255);
	PlayerTextDrawTextSize(playerid, HUD[playerid][HUD_STATUS_CLAN_SPRITE], 10.000000, 10.000000);

	HUD[playerid][HUD_STATUS_CLAN_VALUE] = CreatePlayerTextDraw(playerid, 574.000000, 404.000000, "Sem clan.");
	PlayerTextDrawBackgroundColor(playerid, HUD[playerid][HUD_STATUS_CLAN_VALUE], 255);
	PlayerTextDrawFont(playerid, HUD[playerid][HUD_STATUS_CLAN_VALUE], 1);
	PlayerTextDrawLetterSize(playerid, HUD[playerid][HUD_STATUS_CLAN_VALUE], 0.160000, 0.899999);
	PlayerTextDrawColor(playerid, HUD[playerid][HUD_STATUS_CLAN_VALUE], -1);
	PlayerTextDrawSetOutline(playerid, HUD[playerid][HUD_STATUS_CLAN_VALUE], 0);
	PlayerTextDrawSetProportional(playerid, HUD[playerid][HUD_STATUS_CLAN_VALUE], 1);
	PlayerTextDrawSetShadow(playerid, HUD[playerid][HUD_STATUS_CLAN_VALUE], 1);

	HUD[playerid][HUD_STATUS_BORDER_LEFT] = CreatePlayerTextDraw(playerid, 562.000000, 402.000000, "_");
	PlayerTextDrawBackgroundColor(playerid, HUD[playerid][HUD_STATUS_BORDER_LEFT], 255);
	PlayerTextDrawFont(playerid, HUD[playerid][HUD_STATUS_BORDER_LEFT], 0);
	PlayerTextDrawLetterSize(playerid, HUD[playerid][HUD_STATUS_BORDER_LEFT], 0.469999, 1.299999);
	PlayerTextDrawColor(playerid, HUD[playerid][HUD_STATUS_BORDER_LEFT], 361504767);
	PlayerTextDrawSetOutline(playerid, HUD[playerid][HUD_STATUS_BORDER_LEFT], 0);
	PlayerTextDrawSetProportional(playerid, HUD[playerid][HUD_STATUS_BORDER_LEFT], 1);
	PlayerTextDrawSetShadow(playerid, HUD[playerid][HUD_STATUS_BORDER_LEFT], 1);
	PlayerTextDrawUseBox(playerid, HUD[playerid][HUD_STATUS_BORDER_LEFT], 1);
	PlayerTextDrawBoxColor(playerid, HUD[playerid][HUD_STATUS_BORDER_LEFT], 748);
	PlayerTextDrawTextSize(playerid, HUD[playerid][HUD_STATUS_BORDER_LEFT], 555.999023, 0.000000);

	HUD[playerid][HUD_STATUS_DIVIDER] = CreatePlayerTextDraw(playerid, 602.000244, 421.000000, "_");
	PlayerTextDrawBackgroundColor(playerid, HUD[playerid][HUD_STATUS_DIVIDER], 255);
	PlayerTextDrawFont(playerid, HUD[playerid][HUD_STATUS_DIVIDER], 0);
	PlayerTextDrawLetterSize(playerid, HUD[playerid][HUD_STATUS_DIVIDER], 0.400000, 2.799999);
	PlayerTextDrawColor(playerid, HUD[playerid][HUD_STATUS_DIVIDER], 361504767);
	PlayerTextDrawSetOutline(playerid, HUD[playerid][HUD_STATUS_DIVIDER], 0);
	PlayerTextDrawSetProportional(playerid, HUD[playerid][HUD_STATUS_DIVIDER], 1);
	PlayerTextDrawSetShadow(playerid, HUD[playerid][HUD_STATUS_DIVIDER], 1);
	PlayerTextDrawUseBox(playerid, HUD[playerid][HUD_STATUS_DIVIDER], 1);
	PlayerTextDrawTextSize(playerid, HUD[playerid][HUD_STATUS_DIVIDER], 598.999023, 0.000000);
	PlayerTextDrawBoxColor(playerid, HUD[playerid][HUD_STATUS_DIVIDER], 255);

	HUD[playerid][HUD_COMPONENT_RADAR]		=CreatePlayerTextDraw(playerid, 33.000000, 338.000000, "LD_POOL:ball");
	PlayerTextDrawBackgroundColor	(playerid, HUD[playerid][HUD_COMPONENT_RADAR], 255);
	PlayerTextDrawFont				(playerid, HUD[playerid][HUD_COMPONENT_RADAR], 4);
	PlayerTextDrawLetterSize		(playerid, HUD[playerid][HUD_COMPONENT_RADAR], 0.500000, 0.000000);
	PlayerTextDrawColor				(playerid, HUD[playerid][HUD_COMPONENT_RADAR], 255);
	PlayerTextDrawSetOutline		(playerid, HUD[playerid][HUD_COMPONENT_RADAR], 0);
	PlayerTextDrawSetProportional	(playerid, HUD[playerid][HUD_COMPONENT_RADAR], 1);
	PlayerTextDrawSetShadow			(playerid, HUD[playerid][HUD_COMPONENT_RADAR], 1);
	PlayerTextDrawUseBox			(playerid, HUD[playerid][HUD_COMPONENT_RADAR], 1);
	PlayerTextDrawBoxColor			(playerid, HUD[playerid][HUD_COMPONENT_RADAR], 255);
	PlayerTextDrawTextSize			(playerid, HUD[playerid][HUD_COMPONENT_RADAR], 108.000000, 89.000000);
}

SetHudComponentString(playerid, componentId, string[]) {
	PlayerTextDrawSetString(playerid, HUD[playerid][componentId], string);
}

ToggleHudComponent(playerid, componentid, bool:toggle) {
	if(componentid >= MAX_HUD_COMPONENTS) {
		printf("ToggleHudComponent: Invalid component id %d", componentid);
		return;
	}

	if(toggle)
		PlayerTextDrawShow(playerid, HUD[playerid][componentid]);
	else
		PlayerTextDrawHide(playerid, HUD[playerid][componentid]);
}

ToggleHud(playerid, bool:toggle) {
	ToggleHudComponent(playerid, HUD_STATUS_BG, toggle);
	ToggleHudComponent(playerid, HUD_STATUS_FOOD_SPRITE, toggle);
	ToggleHudComponent(playerid, HUD_STATUS_FOOD_VALUE, toggle);
	ToggleHudComponent(playerid, HUD_STATUS_BLEED_SPRITE, toggle);
	ToggleHudComponent(playerid, HUD_STATUS_BLEED_VALUE, toggle);
	ToggleHudComponent(playerid, HUD_STATUS_KILLS_SPRITE, toggle);
	ToggleHudComponent(playerid, HUD_STATUS_KILLS_VALUE, toggle);
	ToggleHudComponent(playerid, HUD_STATUS_PED_SPRITE, toggle);
	ToggleHudComponent(playerid, HUD_STATUS_PED_VALUE, toggle);
	ToggleHudComponent(playerid, HUD_STATUS_CLAN_BG, toggle);
	ToggleHudComponent(playerid, HUD_STATUS_CLAN_BORDER_LEFT, toggle);
	ToggleHudComponent(playerid, HUD_STATUS_CLAN_SPRITE, toggle);
	ToggleHudComponent(playerid, HUD_STATUS_CLAN_VALUE, toggle);
	ToggleHudComponent(playerid, HUD_STATUS_BORDER_LEFT, toggle);
	ToggleHudComponent(playerid, HUD_STATUS_DIVIDER, toggle);
}

/* CMD:hud(playerid, params[]) {

	ToggleHud(playerid, true, false);
} */