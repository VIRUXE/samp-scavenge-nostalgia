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


#define MAX_MOVEMENT_RANGE	(7.0)
#define NO_GO_ZONE_SIZE		(2.2)
#define TWK_AREA_IDENTIFIER	(1234)


#include <YSI\y_hooks>


static
			twk_Item[MAX_PLAYERS] = {INVALID_ITEM_ID, ...},
			twk_Tweaker[ITM_MAX] = {INVALID_PLAYER_ID, ...},
Float:		twk_Origin[MAX_PLAYERS][3],
			twk_Locked[MAX_PLAYERS],
			twk_NoGoZone[MAX_PLAYERS] = {INVALID_STREAMER_ID, ...},
			twk_NoGoZoneCount[MAX_PLAYERS];

static
bool:		fixDRAW2[MAX_PLAYERS],
PlayerText:	twk_MoveU[MAX_PLAYERS],
PlayerText:	twk_MoveD[MAX_PLAYERS],
PlayerText:	twk_MoveF[MAX_PLAYERS],
PlayerText:	twk_MoveB[MAX_PLAYERS],
PlayerText:	twk_MoveL[MAX_PLAYERS],
PlayerText:	twk_MoveR[MAX_PLAYERS],
PlayerText:	twk_RotR[MAX_PLAYERS],
PlayerText:	twk_RotL[MAX_PLAYERS],
PlayerText:	twk_Unlock[MAX_PLAYERS],
PlayerText:	twk_Done[MAX_PLAYERS];

forward OnItemTweakUpdate(playerid, itemid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz);
forward OnItemTweakFinish(playerid, itemid);


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnPlayerConnect(playerid)
{
	twk_Item[playerid] = INVALID_ITEM_ID;
	_twk_Reset(playerid);
	_twk_BuildUI(playerid);
}

hook OnPlayerDisconnect(playerid, reason)
{
	if(IsValidItem(twk_Item[playerid]))
	{
		_twk_Commit(playerid);
	}
}

/*==============================================================================

	Core Functions

==============================================================================*/

stock TweakItem(playerid, itemid)
{
	dbg("gamemodes/sss/core/world/item-tweak.pwn", 1, "TweakItem %d %d", playerid, itemid);

	new
		geid[GEID_LEN],
		data[2];

	GetItemGEID(itemid, geid);

	if(twk_Item[playerid] != -1)
		err("twk_Item already set to %d", twk_Item[playerid]);

	log("[TWEAK] %p Tweaked item %d (%s)", playerid, itemid, geid);

	twk_Item[playerid] = itemid;
	twk_Tweaker[itemid] = playerid;
	GetItemPos(itemid, twk_Origin[playerid][0], twk_Origin[playerid][1], twk_Origin[playerid][2]);
	twk_NoGoZone[playerid] = CreateDynamicSphere(twk_Origin[playerid][0], twk_Origin[playerid][1], twk_Origin[playerid][2], NO_GO_ZONE_SIZE, GetItemWorld(itemid), GetItemInterior(itemid));

	data[0] = TWK_AREA_IDENTIFIER;
	data[1] = itemid;
	Streamer_SetArrayData(STREAMER_TYPE_AREA, twk_NoGoZone[playerid], E_STREAMER_EXTRA_ID, data);

	_twk_ShowUI(playerid);
	_twk_ToggleMouse(playerid, false);
	ShowHelpTip(playerid, ls(playerid, "TIPTWEAKITM"));

	return 1;
}


/*==============================================================================

	Internal

==============================================================================*/


_twk_Reset(playerid)
{
	twk_Locked[playerid] = false;
	DestroyDynamicArea(twk_NoGoZone[playerid]);
	twk_NoGoZone[playerid] = INVALID_STREAMER_ID;
	twk_NoGoZoneCount[playerid] = 0;

	if(IsValidItem(twk_Item[playerid]))
		twk_Tweaker[twk_Item[playerid]] = INVALID_PLAYER_ID;

	twk_Item[playerid] = INVALID_ITEM_ID;

	_twk_HideUI(playerid);
}

_twk_Commit(playerid)
{
	if(!IsValidItem(twk_Item[playerid]))
		return 0;

	new
		geid[GEID_LEN],
		Float:x,
		Float:y,
		Float:z,
		Float:rx,
		Float:ry,
		Float:rz;

	GetItemGEID(twk_Item[playerid], geid);
	GetItemPos(twk_Item[playerid], x, y, z);
	GetItemRot(twk_Item[playerid], rx, ry, rz);

	log("[TWEAK] %p Tweaked item %d (%s) %d (%f, %f, %f, %f, %f, %f)",
		playerid, twk_Item[playerid], geid, GetItemTypeModel(GetItemType(twk_Item[playerid])),
		x, y, z, rx, ry, rz);

	CallLocalFunction("OnItemTweakFinish", "dd", playerid, twk_Item[playerid]);

	_twk_HideUI(playerid);
	CancelSelectTextDraw(playerid);
	CancelPlayerMovement(playerid);
	ShowActionText(playerid, ls(playerid, "ITEMTWKFINI"), 5000);
	_twk_Reset(playerid);

	return 1;
}

stock twk_ItemPlayer(playerid) return twk_Item[playerid];

_twk_ShowUI(playerid)
{
    PlayerTextDrawShow(playerid, twk_MoveU[playerid]);
    PlayerTextDrawShow(playerid, twk_MoveD[playerid]);
	PlayerTextDrawShow(playerid, twk_MoveF[playerid]);
	PlayerTextDrawShow(playerid, twk_MoveB[playerid]);
	PlayerTextDrawShow(playerid, twk_MoveL[playerid]);
	PlayerTextDrawShow(playerid, twk_MoveR[playerid]);
	PlayerTextDrawShow(playerid, twk_RotR[playerid]);
	PlayerTextDrawShow(playerid, twk_RotL[playerid]);
	PlayerTextDrawShow(playerid, twk_Unlock[playerid]);
	PlayerTextDrawShow(playerid, twk_Done[playerid]);
}

_twk_HideUI(playerid)
{
    PlayerTextDrawHide(playerid, twk_MoveU[playerid]);
    PlayerTextDrawHide(playerid, twk_MoveD[playerid]);
	PlayerTextDrawHide(playerid, twk_MoveF[playerid]);
	PlayerTextDrawHide(playerid, twk_MoveB[playerid]);
	PlayerTextDrawHide(playerid, twk_MoveL[playerid]);
	PlayerTextDrawHide(playerid, twk_MoveR[playerid]);
	PlayerTextDrawHide(playerid, twk_RotR[playerid]);
	PlayerTextDrawHide(playerid, twk_RotL[playerid]);
	PlayerTextDrawHide(playerid, twk_Unlock[playerid]);
	PlayerTextDrawHide(playerid, twk_Done[playerid]);
	fixDRAW2[playerid] = false;
}

_twk_ToggleMouse(playerid, bool:toggle)
{
	if(toggle)
	{
		twk_Locked[playerid] = true;
        fixDRAW2[playerid] = true;
		SelectTextDraw(playerid, 0xffff00ff);
		PlayerTextDrawSetString(playerid, twk_Unlock[playerid], ls(playerid, "ITEMTWKBTNM"));
	}
	else
	{
	    fixDRAW2[playerid] = false;
		twk_Locked[playerid] = false;
		CancelSelectTextDraw(playerid);
		PlayerTextDrawSetString(playerid, twk_Unlock[playerid], ls(playerid, "ITEMTWKBTNE"));
	}
}

hook OnPlayerClickPlayerTD(playerid, PlayerText:playertextid)
{
	if(IsValidItem(twk_Item[playerid]))
	{
	    if(playertextid == twk_MoveD[playerid])
		{
			_twk_AdjustItemPos(playerid, 0.0, 0.0, 0.0, -0.025);
		}

		if(playertextid == twk_MoveU[playerid])
		{
			_twk_AdjustItemPos(playerid, 0.0, 0.0, 0.0, 0.025);
		}

		if(playertextid == twk_MoveF[playerid])
		{
			_twk_AdjustItemPos(playerid, 0.05, 0.0, 0.0);
		}

		if(playertextid == twk_MoveB[playerid])
		{
			_twk_AdjustItemPos(playerid, 0.05, 180.0, 0.0);
		}

		if(playertextid == twk_MoveL[playerid])
		{
			_twk_AdjustItemPos(playerid, 0.05, 90.0, 0.0);
		}

		if(playertextid == twk_MoveR[playerid])
		{
			_twk_AdjustItemPos(playerid, 0.05, -90.0, 0.0);
		}

		if(playertextid == twk_RotR[playerid])
		{
			_twk_AdjustItemPos(playerid, 0.0, 0.0, -1.0);
		}

		if(playertextid == twk_RotL[playerid])
		{
			_twk_AdjustItemPos(playerid, 0.0, 0.0, 1.0);
		}

		if(playertextid == twk_Unlock[playerid])
		{
			_twk_ToggleMouse(playerid, false);
		}

		if(playertextid == twk_Done[playerid])
		{
			_twk_Commit(playerid);
		}
	}
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsValidItem(twk_Item[playerid]))
	{
		if(!twk_Locked[playerid] && newkeys & KEY_WALK)
			_twk_ToggleMouse(playerid, true);

		else if(twk_Locked[playerid] && newkeys & 16)
			_twk_Commit(playerid);
	}
}

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	if(IsValidItem(twk_Item[playerid]))
		_twk_Commit(playerid);
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(!IsPlayerNPC(playerid))
	{
			if(IsValidItem(twk_Item[playerid]))
		_twk_Commit(playerid);
	}
}

hook OnPlayerDropItem(playerid, itemid)
{
	if(IsValidItem(twk_Item[playerid]))
		_twk_Commit(playerid);
}

hook OnPlayerGiveItem(playerid, targetid, itemid)
{
	if(IsValidItem(twk_Item[playerid]))
		_twk_Commit(playerid);
}

hook OnPlayerOpenInventory(playerid)
{
	if(IsValidItem(twk_Item[playerid]))
		_twk_Commit(playerid);
}

hook OnPlayerOpenContainer(playerid, containerid)
{
	if(IsValidItem(twk_Item[playerid]))
		_twk_Commit(playerid);
}

_twk_AdjustItemPos(playerid, Float:distance, Float:direction, Float:rotation, Float:z = 0.0)
{
	if(!IsPlayerConnected(playerid))
	{
		err("Called on invalid player %d", playerid);
		return 1;
	}

	if(!IsValidItem(twk_Item[playerid]))
	{
		err("Called on invalid item %d", twk_Item[playerid]);
		_twk_Reset(playerid);
		return 2;
	}

	if(twk_NoGoZoneCount[playerid] > 0)
	{
		ShowActionText(playerid, ls(playerid, "ITEMTWKMOVE"), 6000);
		return 3;
	}

	new
		Float:new_x,
		Float:new_y,
		Float:new_z,
		Float:rx,
		Float:ry,
		Float:rz;

	GetItemPos(twk_Item[playerid], new_x, new_y, new_z);
	GetItemRot(twk_Item[playerid], rx, ry, rz);

	new_x += distance * floatsin(-(rz + direction), degrees);
	new_y += distance * floatcos(-(rz + direction), degrees);
	rz += rotation;
	new_z = new_z + z;

	if(Distance(new_x, new_y, new_z, twk_Origin[playerid][0], twk_Origin[playerid][1], twk_Origin[playerid][2]) >= MAX_MOVEMENT_RANGE)
	{
		ShowActionText(playerid, ls(playerid, "ITEMTWKTFAR"), 6000);
		return 5;
	}

	if(new_z < twk_Origin[playerid][2])
	{
		ShowActionText(playerid, "Você não pode mover mais para baixo", 6000);
		return 6;
	}

	SetItemPos(twk_Item[playerid], new_x, new_y, new_z);
	SetItemRot(twk_Item[playerid], rx, ry, rz);

	CallLocalFunction("OnItemTweakUpdate", "ddffffff", playerid, twk_Item[playerid], new_x, new_y, new_z, rx, ry, rz);

	return 0;
}

_twk_BuildUI(playerid)
{
	twk_MoveU[playerid] = CreatePlayerTextDraw(playerid, 567.058959, 270.666534, "~U~");
	PlayerTextDrawLetterSize(playerid, twk_MoveU[playerid], 0.398234, 2.183333);
	PlayerTextDrawTextSize(playerid, twk_MoveU[playerid], 581.176513, 43.750000);
	PlayerTextDrawAlignment(playerid, twk_MoveU[playerid], 1);
	PlayerTextDrawColor(playerid, twk_MoveU[playerid], -1);
	PlayerTextDrawUseBox(playerid, twk_MoveU[playerid], true);
	PlayerTextDrawBoxColor(playerid, twk_MoveU[playerid], 255);
	PlayerTextDrawSetShadow(playerid, twk_MoveU[playerid], 0);
	PlayerTextDrawSetOutline(playerid, twk_MoveU[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, twk_MoveU[playerid], 51);
	PlayerTextDrawFont(playerid, twk_MoveU[playerid], 1);
	PlayerTextDrawSetProportional(playerid, twk_MoveU[playerid], 1);
	PlayerTextDrawSetSelectable		(playerid, twk_MoveU[playerid], true);

	twk_MoveD[playerid] = CreatePlayerTextDraw(playerid, 589.235595, 271.666503, "~D~");
	PlayerTextDrawLetterSize(playerid, twk_MoveD[playerid], 0.398234, 2.183333);
	PlayerTextDrawTextSize(playerid, twk_MoveD[playerid], 604.705932, 46.666667);
	PlayerTextDrawAlignment(playerid, twk_MoveD[playerid], 1);
	PlayerTextDrawColor(playerid, twk_MoveD[playerid], -1);
	PlayerTextDrawUseBox(playerid, twk_MoveD[playerid], true);
	PlayerTextDrawBoxColor(playerid, twk_MoveD[playerid], 255);
	PlayerTextDrawSetShadow(playerid, twk_MoveD[playerid], 0);
	PlayerTextDrawSetOutline(playerid, twk_MoveD[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, twk_MoveD[playerid], 51);
	PlayerTextDrawFont(playerid, twk_MoveD[playerid], 1);
	PlayerTextDrawSetProportional(playerid, twk_MoveD[playerid], 1);
	PlayerTextDrawSetSelectable		(playerid, twk_MoveD[playerid], true);

	twk_MoveF[playerid]				=CreatePlayerTextDraw(playerid, 580.000000, 320.000000, "~u~");
	PlayerTextDrawBackgroundColor	(playerid, twk_MoveF[playerid], 255);
	PlayerTextDrawFont				(playerid, twk_MoveF[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, twk_MoveF[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, twk_MoveF[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, twk_MoveF[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, twk_MoveF[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, twk_MoveF[playerid], 1);
	PlayerTextDrawUseBox			(playerid, twk_MoveF[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, twk_MoveF[playerid], 255);
	PlayerTextDrawTextSize			(playerid, twk_MoveF[playerid], 594.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, twk_MoveF[playerid], true);

	twk_MoveB[playerid]				=CreatePlayerTextDraw(playerid, 580.000000, 360.000000, "~d~");
	PlayerTextDrawBackgroundColor	(playerid, twk_MoveB[playerid], 255);
	PlayerTextDrawFont				(playerid, twk_MoveB[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, twk_MoveB[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, twk_MoveB[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, twk_MoveB[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, twk_MoveB[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, twk_MoveB[playerid], 1);
	PlayerTextDrawUseBox			(playerid, twk_MoveB[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, twk_MoveB[playerid], 255);
	PlayerTextDrawTextSize			(playerid, twk_MoveB[playerid], 594.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, twk_MoveB[playerid], true);

	twk_MoveL[playerid]				=CreatePlayerTextDraw(playerid, 560.000000, 340.000000, "~<~");
	PlayerTextDrawBackgroundColor	(playerid, twk_MoveL[playerid], 255);
	PlayerTextDrawFont				(playerid, twk_MoveL[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, twk_MoveL[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, twk_MoveL[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, twk_MoveL[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, twk_MoveL[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, twk_MoveL[playerid], 1);
	PlayerTextDrawUseBox			(playerid, twk_MoveL[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, twk_MoveL[playerid], 255);
	PlayerTextDrawTextSize			(playerid, twk_MoveL[playerid], 574.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, twk_MoveL[playerid], true);

	twk_MoveR[playerid]				=CreatePlayerTextDraw(playerid, 600.000000, 340.000000, "~>~");
	PlayerTextDrawBackgroundColor	(playerid, twk_MoveR[playerid], 255);
	PlayerTextDrawFont				(playerid, twk_MoveR[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, twk_MoveR[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, twk_MoveR[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, twk_MoveR[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, twk_MoveR[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, twk_MoveR[playerid], 1);
	PlayerTextDrawUseBox			(playerid, twk_MoveR[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, twk_MoveR[playerid], 255);
	PlayerTextDrawTextSize			(playerid, twk_MoveR[playerid], 614.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, twk_MoveR[playerid], true);

	twk_RotR[playerid]				=CreatePlayerTextDraw(playerid, 610.000000, 310.000000, "R");
	PlayerTextDrawBackgroundColor	(playerid, twk_RotR[playerid], 255);
	PlayerTextDrawFont				(playerid, twk_RotR[playerid], 2);
	PlayerTextDrawLetterSize		(playerid, twk_RotR[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, twk_RotR[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, twk_RotR[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, twk_RotR[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, twk_RotR[playerid], 1);
	PlayerTextDrawUseBox			(playerid, twk_RotR[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, twk_RotR[playerid], 255);
	PlayerTextDrawTextSize			(playerid, twk_RotR[playerid], 624.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, twk_RotR[playerid], true);

	twk_RotL[playerid]				=CreatePlayerTextDraw(playerid, 550.000000, 310.000000, "L");
	PlayerTextDrawBackgroundColor	(playerid, twk_RotL[playerid], 255);
	PlayerTextDrawFont				(playerid, twk_RotL[playerid], 2);
	PlayerTextDrawLetterSize		(playerid, twk_RotL[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, twk_RotL[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, twk_RotL[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, twk_RotL[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, twk_RotL[playerid], 1);
	PlayerTextDrawUseBox			(playerid, twk_RotL[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, twk_RotL[playerid], 255);
	PlayerTextDrawTextSize			(playerid, twk_RotL[playerid], 564.000000, 20.000000);
	PlayerTextDrawSetSelectable		(playerid, twk_RotL[playerid], true);

	twk_Unlock[playerid]			=CreatePlayerTextDraw(playerid, 587.000000, 390.000000, "Mover");
	PlayerTextDrawAlignment			(playerid, twk_Unlock[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, twk_Unlock[playerid], 255);
	PlayerTextDrawFont				(playerid, twk_Unlock[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, twk_Unlock[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, twk_Unlock[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, twk_Unlock[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, twk_Unlock[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, twk_Unlock[playerid], 1);
	PlayerTextDrawUseBox			(playerid, twk_Unlock[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, twk_Unlock[playerid], 255);
	PlayerTextDrawTextSize			(playerid, twk_Unlock[playerid], 20.0, 80.0);
	PlayerTextDrawSetSelectable		(playerid, twk_Unlock[playerid], true);

	twk_Done[playerid]				=CreatePlayerTextDraw(playerid, 587.000000, 420.000000, "Pronto");
	PlayerTextDrawAlignment			(playerid, twk_Done[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, twk_Done[playerid], 255);
	PlayerTextDrawFont				(playerid, twk_Done[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, twk_Done[playerid], 0.500000, 2.000000);
	PlayerTextDrawColor				(playerid, twk_Done[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, twk_Done[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, twk_Done[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, twk_Done[playerid], 1);
	PlayerTextDrawUseBox			(playerid, twk_Done[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, twk_Done[playerid], 255);
	PlayerTextDrawTextSize			(playerid, twk_Done[playerid], 20.0, 80.0);
	PlayerTextDrawSetSelectable		(playerid, twk_Done[playerid], true);
}

hook OnPlayerEnterDynArea(playerid, areaid)
{
    if(!IsPlayerNPC(playerid))
	{
	new data[2];
	Streamer_GetArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, data);

	if(data[0] != TWK_AREA_IDENTIFIER)
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(!IsValidItem(data[1]))
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(!IsPlayerConnected(twk_Tweaker[data[1]]))
	{
		err("Player entered area of tweaked item %d item has no connected player.", data[1]);
		return Y_HOOKS_CONTINUE_RETURN_0;
	}

	ShowActionText(playerid, ls(playerid, "ITEMTWKBLOC"), 6000);
	twk_NoGoZoneCount[twk_Tweaker[data[1]]]++;
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerLeaveDynArea(playerid, areaid)
{
    if(!IsPlayerNPC(playerid))
	{
	new data[2];
	Streamer_GetArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, data);

	if(data[0] != TWK_AREA_IDENTIFIER)
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(!IsValidItem(data[1]))
		return Y_HOOKS_CONTINUE_RETURN_0;

	if(!IsPlayerConnected(twk_Tweaker[data[1]]))
	{
		err("Player left area of tweaked item %d item has no connected player.", data[1]);
		return Y_HOOKS_CONTINUE_RETURN_0;
	}

	twk_NoGoZoneCount[twk_Tweaker[data[1]]]--;
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}
hook OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	dbg("global", CORE, "[OnPlayerClickTextDraw] in /gamemodes/sss/core/char/inventory.pwn");

	if(clickedid == Text:65535)
	{
	 	if(fixDRAW2[playerid])
		{
		    _twk_ToggleMouse(playerid, true);
		}
	}
}
