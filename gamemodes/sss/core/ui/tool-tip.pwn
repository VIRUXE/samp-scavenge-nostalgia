#include <YSI\y_hooks>

#define MAX_TOOLTIP_SIZE 72 // "Invite your friends to play on the server, playing in a group is more fun and rewarding."

static
	bool:		ToolTips[MAX_PLAYERS],
	PlayerText:	ToolTipText[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
	Timer:      ToolTipeTimer[MAX_PLAYERS],
	MsgAuto = 0;

task SendAutoMessage[MIN(5)]() {
	foreach(new i : Player)
	    if(ToolTips[i]) {
			new Node:node, total_tooltips;

			JSON_GetObject(Settings, "player", node);
			JSON_GetArray(node, "tooltips", node);
			JSON_ArrayLength(node, total_tooltips);

			if(total_tooltips > 0) {
				new tooltip[MAX_TOOLTIP_SIZE+1];

				JSON_ArrayObject(node, random(total_tooltips), node);
				JSON_GetString(node, GetPlayerLanguage(i) == ENGLISH ? "en" : "pt", tooltip, sizeof(tooltip));

				printf("SendAutoMessage: %s", tooltip);

				ChatMsg(i, GOLD, " > %s", tooltip);
			}
		}

    MsgAuto++;
	if(MsgAuto >= 7) MsgAuto = 0;
}


ShowHelpTip(playerid, text[], time = 0)
{
	if(!ToolTips[playerid]) return 0;

	PlayerTextDrawSetString(playerid, ToolTipText[playerid], text);
	PlayerTextDrawShow(playerid, ToolTipText[playerid]);

	stop ToolTipeTimer[playerid];
	
	if(time > 0) ToolTipeTimer[playerid] = defer HideHelpTip_Delay(playerid, time);

	return 1;
}

timer HideHelpTip_Delay[time](playerid, time)
{
	HideHelpTip(playerid);
	#pragma unused time
}

HideHelpTip(playerid)
	PlayerTextDrawHide(playerid, ToolTipText[playerid]);

hook OnPlayerConnect(playerid)
{
	dbg("global", CORE, "[OnPlayerConnect] in /gamemodes/sss/core/ui/tip-text.pwn");

	ToolTipText[playerid] = CreatePlayerTextDraw(playerid, 12.894577, 162.983322, "Use isso para reabastecer veículos");
	PlayerTextDrawLetterSize(playerid, ToolTipText[playerid], 0.279665, 1.952331);
	PlayerTextDrawTextSize(playerid, ToolTipText[playerid], 182.651519, 35.466674);
	PlayerTextDrawAlignment(playerid, ToolTipText[playerid], 1);
	PlayerTextDrawColor(playerid, ToolTipText[playerid], -1);
	PlayerTextDrawUseBox(playerid, ToolTipText[playerid], true);
	PlayerTextDrawBoxColor(playerid, ToolTipText[playerid], 100);
	PlayerTextDrawSetShadow(playerid, ToolTipText[playerid], 1);
	PlayerTextDrawSetOutline(playerid, ToolTipText[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, ToolTipText[playerid], 255);
	PlayerTextDrawFont(playerid, ToolTipText[playerid], 1);
	PlayerTextDrawSetProportional(playerid, ToolTipText[playerid], 1);
}

hook OnPlayerPickedUpItem(playerid, itemid)
{
	dbg("global", CORE, "[OnPlayerPickUpItem] in /gamemodes/sss/core/player/tool-tips.pwn");

	if(ToolTips[playerid])
	{
			new itemname[ITM_MAX_NAME], itemtipkey[12], str[288];

			GetItemTypeUniqueName(GetItemType(itemid), itemname);

			if(strlen(itemname) > 9) itemname[9] = EOS;

			format(itemtipkey, sizeof(itemtipkey), "%s_T", itemname);
			itemtipkey[11] = EOS;

			format(str, sizeof(str), "~r~!~w~ %s", GetLanguageString(GetPlayerLanguage(playerid), itemtipkey, true));

			ShowHelpTip(playerid, str, 20000);
	}
}

hook OnPlayerDropItem(playerid, itemid)
{
	dbg("global", CORE, "[OnPlayerDropItem] in /gamemodes/sss/core/player/tool-tips.pwn");

	if(ToolTips[playerid]) HideHelpTip(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

stock IsPlayerToolTipsOn(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;

	return ToolTips[playerid];
}

stock SetPlayerToolTips(playerid, bool:st)
{
	if(!IsPlayerConnected(playerid)) return 0;

	if(!st) HideHelpTip(playerid);
	    
	ToolTips[playerid] = st;

	return 1;
}
