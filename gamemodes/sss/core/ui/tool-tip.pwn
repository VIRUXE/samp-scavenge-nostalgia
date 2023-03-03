/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/


#include <YSI\y_hooks>


static
	bool:		ToolTips[MAX_PLAYERS],
	PlayerText:	ToolTipText[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
	Timer:      ToolTipeTimer[MAX_PLAYERS],
	MsgAuto = 0;

task SendAutoMessage[MIN(5)]() {
	foreach(new i : Player)
	    if(ToolTips[i])
	    	ChatMsg(i, BLUE, ""C_BLUE"%s", ls(i, sprintf("AUTOMSG%d", MsgAuto)));

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

			format(str, sizeof(str), "~r~!~w~ %s", GetLanguageString(playerid, itemtipkey, true));

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
