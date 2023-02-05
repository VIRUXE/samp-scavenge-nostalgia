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
PlayerText:	KeyActions[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
			KeyActionsText[MAX_PLAYERS][512];


hook OnPlayerConnect(playerid)
{
	KeyActions[playerid]			=CreatePlayerTextDraw(playerid, 618.000000, 120.000000, "fixed it");
	PlayerTextDrawAlignment			(playerid, KeyActions[playerid], 3);
	PlayerTextDrawBackgroundColor	(playerid, KeyActions[playerid], 255);
	PlayerTextDrawFont				(playerid, KeyActions[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, KeyActions[playerid], 0.300000, 1.499999);
	PlayerTextDrawColor				(playerid, KeyActions[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, KeyActions[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, KeyActions[playerid], 1);
}


/*==============================================================================

	Core

==============================================================================*/

stock ShowPlayerKeyActionUI(playerid)
{
	PlayerTextDrawSetString(playerid, KeyActions[playerid], KeyActionsText[playerid]);
	PlayerTextDrawShow(playerid, KeyActions[playerid]);
}

stock HidePlayerKeyActionUI(playerid)
{
	if(!IsPlayerNPC(playerid))
		PlayerTextDrawHide(playerid, KeyActions[playerid]);
}

stock ClearPlayerKeyActionUI(playerid)
{
	KeyActionsText[playerid][0] = EOS;
}

stock AddToolTipText(playerid, key[], use[])
{
	new tmp[158];
	format(tmp, sizeof(tmp), "~y~%s ~w~%s~n~", key, use);
	strcat(KeyActionsText[playerid], tmp);
}


/*==============================================================================

	Internal

==============================================================================*/


// Enter/exit inventory
hook OnPlayerOpenInventory(playerid)
{
	HidePlayerKeyActionUI(playerid);
}

hook OnPlayerCloseInventory(playerid)
{
	_UpdateKeyActions(playerid);
}

hook OnPlayerOpenContainer(playerid, containerid)
{
	HidePlayerKeyActionUI(playerid);
}

hook OnPlayerCloseContainer(playerid, containerid)
{
	_UpdateKeyActions(playerid);
}

hook OnPlayerAddToInventory(playerid, itemid)
{
	_UpdateKeyActions(playerid);
}

hook OnItemRemovedFromInv(playerid, itemid, slot)
{
	_UpdateKeyActions(playerid);
}

hook OnItemRemovedFromPlayer(playerid, itemid)
{
	_UpdateKeyActions(playerid);
}

// Pickup/drop item
hook OnPlayerPickedUpItem(playerid, itemid)
{
	_UpdateKeyActions(playerid);
}

hook OnPlayerDroppedItem(playerid, itemid)
{
	_UpdateKeyActions(playerid);
}

hook OnPlayerGetItem(playerid, itemid)
{
	_UpdateKeyActions(playerid);
}

hook OnPlayerGiveItem(playerid, targetid, itemid)
{
	_UpdateKeyActions(playerid);
}

hook OnPlayerGivenItem(playerid, targetid, itemid)
{
	_UpdateKeyActions(playerid);
}

// Vehicles
hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	_UpdateKeyActions(playerid);
}

hook OnPlayerExitVehicle(playerid, vehicleid)
{
	_UpdateKeyActions(playerid);
}

// Areas
hook OnPlayerEnterDynArea(playerid, areaid)
{
	_UpdateKeyActions(playerid);
}

hook OnPlayerLeaveDynArea(playerid, areaid)
{
	_UpdateKeyActions(playerid);
}

// State change
hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	_UpdateKeyActions(playerid);

	if(!IsPlayerToolTipsOn(playerid))
		return 1;

	if(newstate != PLAYER_STATE_DRIVER)
		return 1;

	new vehicleid = GetPlayerVehicleID(playerid);

	if(!IsValidVehicle(vehicleid))
		return 1;

	_ShowRepairTip(playerid, vehicleid);

	return 1;
}
_UpdateKeyActions(playerid)
{
    if(!IsPlayerNPC(playerid))
    {
	if(!IsPlayerSpawned(playerid))
	{
		HidePlayerKeyActionUI(playerid);
		return;		
	}
	if(IsPlayerViewingInventory(playerid))
	{
		HidePlayerKeyActionUI(playerid);
		return;		
	}

	if(IsValidContainer(GetPlayerCurrentContainer(playerid)))
	{
		HidePlayerKeyActionUI(playerid);
		return;		
	}

	if(IsPlayerKnockedOut(playerid))
	{
		HidePlayerKeyActionUI(playerid);
		return;		
	}
	
	if(!IsPlayerHudOn(playerid))
	{
		HidePlayerKeyActionUI(playerid);
		return;		
	}

	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
	{
		ClearPlayerKeyActionUI(playerid);
		AddToolTipText(playerid, KEYTEXT_ENGINE, ls(playerid, "KA_ENGINE"));
		AddToolTipText(playerid, KEYTEXT_LIGHTS, ls(playerid, "KA_LIGHTS"));
		AddToolTipText(playerid, KEYTEXT_DOORS, ls(playerid, "KA_DOORS"));
		ShowPlayerKeyActionUI(playerid);

		return;
	}

	new
		itemid = GetPlayerItem(playerid),
		invehiclearea = GetPlayerVehicleArea(playerid),
		inplayerarea = -1;

	ClearPlayerKeyActionUI(playerid);

	if(invehiclearea != INVALID_VEHICLE_ID && !IsPlayerInAnyVehicle(playerid))
	{
		if(IsPlayerAtVehicleTrunk(playerid, invehiclearea))
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "KA_OPENTRUNK"));

		if(IsPlayerAtVehicleBonnet(playerid, invehiclearea))
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "KA_REPAIRWF"));
	}

	foreach(new i : Player)
	{
		if(IsPlayerInPlayerArea(playerid, i))
		{
			inplayerarea = i;
			break;
		}
	}

	if(!IsValidItem(itemid))
	{
		if(IsPlayerCuffed(inplayerarea))
		{
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "KA_REMOVEAL"));
			ShowPlayerKeyActionUI(playerid);
		}

		AddToolTipText(playerid, KEYTEXT_INVENTORY, GetLanguageString(playerid, "KA_OPENINV", true));
		
		//AddToolTipText(playerid, "ALT", ls(playerid, "KA_OPENMAP"));
		    
		if(IsValidItem(GetPlayerBagItem(playerid)))
			AddToolTipText(playerid, KEYTEXT_DROP_ITEM, ls(playerid, "KA_REMOVEBAG"));

		ShowPlayerKeyActionUI(playerid);

		return;
	}

	new ItemType:itemtype = GetItemType(itemid);

	if(itemtype == item_Sign)
	{
		AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "KA_PPLACA"));
	}
	else if(itemtype == item_Armour)
	{
		AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "KA_USEARMOUR"));
	}
	else if(itemtype == item_Crowbar)
	{
		AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "KA_DESMONT"));
	}
	else if(itemtype == item_Shield)
	{
		AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "KA_COLOCE"));
	}
	else if(itemtype == item_HandCuffs)
	{
		if(inplayerarea != -1)
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "KA_ALGP"));
	}
	else if(itemtype == item_Wheel)
	{
		AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "KA_REPAIRVW", true));
	}
	else if(itemtype == item_GasCan)
	{
		if(invehiclearea != INVALID_VEHICLE_ID  && !IsPlayerInAnyVehicle(playerid))
		{
			if(IsPlayerAtVehicleBonnet(playerid, invehiclearea))
				AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "KA_REFULLV", true));
		}
		else
		{
		    new pInB = -1;
		    if(IsPlayerInRangeOfPoint(playerid, 3.5, -1465.4766, 1868.2734, 32.8203)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -1464.9375, 1860.5625, 32.8203)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -1477.8516, 1867.3125, 32.8203)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -1477.6563, 1859.7344, 32.8203)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -1327.0313, 2685.5938, 50.4531)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -1327.7969, 2680.1250, 50.4531)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -1328.5859, 2674.7109, 50.4531)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -1329.2031, 2669.2813, 50.4531)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 603.48438, 1707.23438, 6.17969)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 606.89844, 1702.21875, 6.17969)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 610.25000, 1697.26563, 6.17969)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 613.71875, 1692.26563, 6.17969)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 617.12500, 1687.45313, 6.17969)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 620.53125, 1682.46094, 6.17969)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 624.04688, 1677.60156, 6.17969)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -2246.7031, -2559.7109, 31.0625)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -2241.7188, -2562.2891, 31.0625)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -1600.6719, -2707.8047, 47.9297)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -1603.9922, -2712.2031, 47.9297)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -1607.3047, -2716.6016, 47.9297)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -1610.6172, -2721.0000, 47.9297)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -85.2422, -1165.0313, 2.6328)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -90.1406, -1176.6250, 2.6328)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -92.1016, -1161.7891, 2.9609)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -97.0703, -1173.7500, 3.0313)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 1941.65625, -1778.45313, 14.14063)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 1941.65625, -1774.31250, 14.14063)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 1941.65625, -1771.34375, 14.14063)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 1941.65625, -1767.28906, 14.14063)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 2120.82031, 914.718750, 11.25781)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 2114.90625, 914.718750, 11.25781)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 2109.04688, 914.718750, 11.25781)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 2120.82031, 925.507810, 11.25781)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 2114.90625, 925.507810, 11.25781)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 2109.04688, 925.507810, 11.25781)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 2207.69531, 2480.32813, 11.31250)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 2207.69531, 2474.68750, 11.31250)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 2207.69531, 2470.25000, 11.31250)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 2196.89844, 2480.32813, 11.31250)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 2196.89844, 2474.68750, 11.31250)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 2196.89844, 2470.25000, 11.31250)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 2153.31250, 2742.52344, 11.27344)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 2147.53125, 2742.52344, 11.27344)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 2141.67188, 2742.52344, 11.27344)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 2153.31250, 2753.32031, 11.27344)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 2147.53125, 2753.32031, 11.27344)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 2141.67188, 2753.32031, 11.27344)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 1590.35156, 2204.50000, 11.31250)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 1596.13281, 2204.50000, 11.31250)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 1602.00000, 2204.50000, 11.31250)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 1590.35156, 2193.71094, 11.31250)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 1596.13281, 2193.71094, 11.31250)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 1602.00000, 2193.71094, 11.31250)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 2634.64063, 1100.94531, 11.25000)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 2639.87500, 1100.96094, 11.25000)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 2645.25000, 1100.96094, 11.25000)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 2634.64063, 1111.75000, 11.25000)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 2639.87500, 1111.75000, 11.25000)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 2645.25000, 1111.75000, 11.25000)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 1378.96094, 461.03906, 19.32813)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 1380.63281, 460.27344, 19.32813)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 1383.39844, 459.07031, 19.32813)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 1385.07813, 458.29688, 19.32813)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 655.66406, -558.92969, 15.35938)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 655.66406, -560.54688, 15.35938)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 655.66406, -569.60156, 15.35938)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, 655.66406, -571.21094, 15.35938)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -2410.80, 970.85, 44.48)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -2410.80, 976.19, 44.48)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -2410.80, 981.52, 44.48)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -1679.3594, 403.0547, 6.3828)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -1675.2188, 407.1953, 6.3828)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -1669.9063, 412.5313, 6.3828)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -1665.5234, 416.9141, 6.3828)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -1685.9688, 409.6406, 6.3828)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -1681.8281, 413.7813, 6.3828)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -1676.5156, 419.1172, 6.3828)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -1672.1328, 423.5000, 6.3828)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -1465.4766, 1868.2734, 32.8203)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -1464.9375, 1860.5625, 32.8203)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -1477.8516, 1867.3125, 32.8203)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -1477.6563, 1859.7344, 32.8203)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -1327.0313, 2685.5938, 50.4531)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -1327.7969, 2680.1250, 50.4531)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -1328.5859, 2674.7109, 50.4531)) pInB = 1;
			else if(IsPlayerInRangeOfPoint(playerid, 3.5, -1329.2031, 2669.2813, 50.4531)) pInB = 1;

			if(pInB == 1)
			{
				AddToolTipText(playerid, KEYTEXT_INTERACT, GetLanguageString(playerid, "KA_REFULLG", true));
			}
			else
			{
			    if(GetLiquidItemLiquidAmount(GetPlayerItem(playerid)) <= 0.0)
				{
				    ShowHelpTip(playerid, GetLanguageString(playerid, "KA_GOTOPOST", true));
				}
				else AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "KA_REFULLV"));
			}
		}
	}
	else if(itemtype == item_Headlight)
	{
		if(invehiclearea != INVALID_VEHICLE_ID  && !IsPlayerInAnyVehicle(playerid))
		{
			if(IsPlayerAtVehicleBonnet(playerid, invehiclearea))
				AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "KA_INSTFAROL"));
		}
	}
	else if(itemtype == item_Pills)
	{
		AddToolTipText(playerid, KEYTEXT_INTERACT,ls(playerid, "KA_TPILULA") );
	}
	else if(itemtype == item_AutoInjec)
	{
		if(inplayerarea == -1)
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "KA_INJECT"));

		else
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "KA_INJECTOTHER"));
	}
	else if(itemtype == item_Medkit || itemtype == item_Bandage || itemtype == item_DoctorBag)
	{
		if(inplayerarea != -1)
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "KA_CUREP"));
		
		else
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "KA_CUREME"));
	}
	else if(itemtype == item_Wrench || itemtype == item_Screwdriver || itemtype == item_Hammer)
	{
		if(invehiclearea != INVALID_VEHICLE_ID  && !IsPlayerInAnyVehicle(playerid))
		{
			if(IsPlayerAtVehicleBonnet(playerid, invehiclearea))
				AddToolTipText(playerid, KEYTEXT_INTERACT, GetLanguageString(playerid, "KA_REPAIRMV", true));
		}
	}
	else
	{
		if(IsItemTypeFood(itemtype))
		{
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "KA_COMER"));
		}
		else if(IsItemTypeBag(itemtype))
		{
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "KA_OPENBAG"));
			AddToolTipText(playerid, KEYTEXT_PUT_AWAY, ls(playerid, "KA_USE"));
		}
		else if(GetHatFromItem(itemtype) != -1)
		{
			AddToolTipText(playerid, KEYTEXT_INTERACT, GetLanguageString(playerid, "KA_USEAC", true));
		}
		else if(GetMaskFromItem(itemtype) != -1)
		{
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "KA_USEAC"));
		}
		else if(GetItemTypeExplosiveType(itemtype) != -1)
		{
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "KA_ARMEXP"));
		}
		else if(GetItemTypeLiquidContainerType(itemtype) != -1)
		{
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "KA_BBER"));
		}
	}
	
	if(GetItemTypeWeapon(itemtype) != -1)
	{
		ClearPlayerKeyActionUI(playerid);

		foreach(new i : Player)
		{
			if(IsPlayerInPlayerArea(playerid, i))
			{
				inplayerarea = i;
				break;
			}
		}

		AddToolTipText(playerid, KEYTEXT_RELOAD, ls(playerid, "KA_RECARRG"));
		AddToolTipText(playerid, KEYTEXT_DROP_ITEM, ls(playerid, "KA_DERECARRG"));
		AddToolTipText(playerid, KEYTEXT_PUT_AWAY, ls(playerid, "KA_CCOLDRE"));
	}
	else
	{
		AddToolTipText(playerid, KEYTEXT_PUT_AWAY, ls(playerid, "KA_GUARD"));
	}
	
	if(inplayerarea == -1)
	{
		AddToolTipText(playerid, KEYTEXT_DROP_ITEM, ls(playerid, "KA_DROPITEM"));
	}
	else
	{
		AddToolTipText(playerid, KEYTEXT_DROP_ITEM, ls(playerid, "KA_GIVEITEM"));
	}

    //AddToolTipText(playerid, "ALT", ls(playerid, "KA_OPENMAP"));
		    
	AddToolTipText(playerid, KEYTEXT_INVENTORY, ls(playerid, "KA_OPENINV"));
	ShowPlayerKeyActionUI(playerid);
	}
	return;
}

_ShowRepairTip(playerid, vehicleid)
{
	new Float:health;

	GetVehicleHealth(vehicleid, health);

	if(health <= VEHICLE_HEALTH_CHUNK_2)
	{
		ShowHelpTip(playerid, GetLanguageString(playerid, "TUTORVEHVER", true));
		return;
	}
	else if(health <= VEHICLE_HEALTH_CHUNK_3)
	{
		ShowHelpTip(playerid, GetLanguageString(playerid, "TUTORVEHBRO", true));
		return;
	}
	else if(health <= VEHICLE_HEALTH_CHUNK_4)
	{
		ShowHelpTip(playerid, GetLanguageString(playerid, "TUTORVEHBIT", true));
		return;
	}
	else if(health <= VEHICLE_HEALTH_MAX)
	{
		ShowHelpTip(playerid, GetLanguageString(playerid, "TUTORVEHSLI", true));
		return;
	}

	return;
}
