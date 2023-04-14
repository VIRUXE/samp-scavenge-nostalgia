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
	KeyActionsText[playerid][0] = EOS;

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
	HidePlayerKeyActionUI(playerid);

hook OnPlayerCloseInventory(playerid)
	_UpdateKeyActions(playerid);
	
hook OnPlayerOpenContainer(playerid, containerid)
	HidePlayerKeyActionUI(playerid);

hook OnPlayerCloseContainer(playerid, containerid)
	_UpdateKeyActions(playerid);

hook OnPlayerAddToInventory(playerid, itemid)
	_UpdateKeyActions(playerid);

hook OnItemRemovedFromInv(playerid, itemid, slot)
	_UpdateKeyActions(playerid);

hook OnItemRemovedFromPlayer(playerid, itemid)
	_UpdateKeyActions(playerid);

// Pickup/drop item
hook OnPlayerPickedUpItem(playerid, itemid)
	_UpdateKeyActions(playerid);

hook OnPlayerDroppedItem(playerid, itemid)
	_UpdateKeyActions(playerid);

hook OnPlayerGetItem(playerid, itemid)
	_UpdateKeyActions(playerid);

hook OnPlayerGiveItem(playerid, targetid, itemid)
	_UpdateKeyActions(playerid);

hook OnPlayerGivenItem(playerid, targetid, itemid)
	_UpdateKeyActions(playerid);

// Vehicles
hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
	_UpdateKeyActions(playerid);

hook OnPlayerExitVehicle(playerid, vehicleid)
	_UpdateKeyActions(playerid);

// Areas
hook OnPlayerEnterDynArea(playerid, areaid)
	_UpdateKeyActions(playerid);

hook OnPlayerLeaveDynArea(playerid, areaid)
	_UpdateKeyActions(playerid);

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

	if(!IsPlayerSpawned(playerid) || IsPlayerViewingInventory(playerid) || IsValidContainer(GetPlayerCurrentContainer(playerid)) || IsPlayerKnockedOut(playerid) || !IsPlayerHudOn(playerid))
	{
		HidePlayerKeyActionUI(playerid);
		return;		
	}

	if(IsPlayerInAnyVehicle(playerid))
	{
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
		{
			ClearPlayerKeyActionUI(playerid);
			AddToolTipText(playerid, KEYTEXT_ENGINE, ls(playerid, "KA_ENGINE"));
			AddToolTipText(playerid, KEYTEXT_LIGHTS, ls(playerid, "KA_LIGHTS"));
			AddToolTipText(playerid, KEYTEXT_DOORS, ls(playerid, "KA_DOORS"));
			AddToolTipText(playerid, KEYTEXT_INVENTORY, ls(playerid, "KA_HORN"));
			ShowPlayerKeyActionUI(playerid);
			return;
		}
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

		AddToolTipText(playerid, KEYTEXT_INVENTORY, GetLanguageString(GetPlayerLanguage(playerid), "KA_OPENINV", true));			    

		if(IsValidItem(GetPlayerBagItem(playerid)))
			AddToolTipText(playerid, KEYTEXT_DROP_ITEM, ls(playerid, "KA_REMOVEBAG"));

		if(IsValidItem(GetPlayerHolsterItem(playerid)))
			AddToolTipText(playerid, KEYTEXT_PUT_AWAY, ls(playerid, "KA_CCOLDRE2"));

		ShowPlayerKeyActionUI(playerid);

		return;
	}

	// Itens simples

	new ItemType:itemtype = GetItemType(itemid);

	if(itemtype == item_Sign)
		AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "KA_PPLACA"));
	else if(itemtype == item_Armour)
		AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "KA_USEARMOUR"));
	else if(itemtype == item_Crowbar)
		AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "KA_DESMONT"));	
	else if(itemtype == item_Shield)
		AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "KA_COLOCE"));
	else if(itemtype == item_Clothes)
		AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "KA_CLOTHES"));
	else if(itemtype == item_HerpDerp)
		AddToolTipText(playerid, KEYTEXT_INTERACT, "Herp-a-Derp");

	else if(itemtype == item_HandCuffs)
	{
		if(inplayerarea != -1)
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "KA_ALGP"));
	}

	else if(itemtype == item_Wheel)
		AddToolTipText(playerid, KEYTEXT_INTERACT, GetLanguageString(GetPlayerLanguage(playerid), "KA_REPAIRVW", true));

	else if(itemtype == item_GasCan)
	{
		if(invehiclearea != INVALID_VEHICLE_ID  && !IsPlayerInAnyVehicle(playerid))
		{
			if(IsPlayerAtVehicleBonnet(playerid, invehiclearea))
				AddToolTipText(playerid, KEYTEXT_INTERACT, GetLanguageString(GetPlayerLanguage(playerid), "KA_REFULLV", true));
		}
		else
			AddToolTipText(playerid, KEYTEXT_INTERACT, GetLanguageString(GetPlayerLanguage(playerid), "KA_REFULLG", true));
	}

	else if(itemtype == item_Headlight)
	{
		if(invehiclearea != INVALID_VEHICLE_ID  && !IsPlayerInAnyVehicle(playerid))
			if(IsPlayerAtVehicleBonnet(playerid, invehiclearea))
				AddToolTipText(playerid, KEYTEXT_INTERACT, GetLanguageString(GetPlayerLanguage(playerid), "KA_INSTFAROL", true));
	}
	else if(itemtype == item_Pills)
		AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "KA_TPILULA"));
	else if(itemtype == item_AutoInjec)
		AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, inplayerarea == -1 ? "KA_INJECT" : "KA_INJECTOTHER"));
	else if(itemtype == item_Medkit || itemtype == item_Bandage || itemtype == item_DoctorBag)
		AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, inplayerarea != -1 ? "KA_CUREP" : "KA_CUREME"));
	else if(itemtype == item_Wrench || itemtype == item_Screwdriver || itemtype == item_Hammer)
	{
		if(invehiclearea != INVALID_VEHICLE_ID  && !IsPlayerInAnyVehicle(playerid))
			if(IsPlayerAtVehicleBonnet(playerid, invehiclearea))
				AddToolTipText(playerid, KEYTEXT_INTERACT, GetLanguageString(GetPlayerLanguage(playerid), "KA_REPAIRMV", true));
	}
	else
	{
		if(IsItemTypeFood(itemtype))
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "KA_COMER"));

		else if(IsItemTypeBag(itemtype))
		{
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "KA_OPENBAG"));
			AddToolTipText(playerid, KEYTEXT_PUT_AWAY, ls(playerid, "KA_USE"));
		}

		else if(GetHatFromItem(itemtype) != -1)
			AddToolTipText(playerid, KEYTEXT_INTERACT, GetLanguageString(GetPlayerLanguage(playerid), "KA_USEAC", true));
		else if(GetMaskFromItem(itemtype) != -1)
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "KA_USEAC"));
		else if(GetItemTypeExplosiveType(itemtype) != -1)
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "KA_ARMEXP"));
		else if(GetItemTypeLiquidContainerType(itemtype) != -1 && itemtype != item_GasCan)
			AddToolTipText(playerid, KEYTEXT_INTERACT, ls(playerid, "KA_BBER"));
	}
	
	if(GetItemTypeWeapon(itemtype) != -1)
	{
		ClearPlayerKeyActionUI(playerid);

		if(IsValidHolsterItem(itemtype))
		{
			AddToolTipText(playerid, KEYTEXT_INVENTORY, GetLanguageString(GetPlayerLanguage(playerid), "KA_OPENINV", true));
			AddToolTipText(playerid, KEYTEXT_PUT_AWAY, ls(playerid, "KA_CCOLDRE"));
		}

		if(GetItemWeaponCalibre(GetItemTypeWeapon(itemtype)) != NO_CALIBRE)
		{
			if(GetItemTypeAmmoType(GetItemWeaponItemAmmoItem(itemid)) != -1 && GetItemWeaponItemMagAmmo(itemid) + GetItemWeaponItemReserve(itemid) != 0)
				AddToolTipText(playerid, KEYTEXT_DROP_ITEM, ls(playerid, "KA_DROPRELOAD"));
			else
				AddToolTipText(playerid, KEYTEXT_DROP_ITEM, ls(playerid, "KA_DROPITEM"));
		}
	}

	else
	{
		AddToolTipText(playerid, KEYTEXT_INVENTORY, GetLanguageString(GetPlayerLanguage(playerid), "KA_OPENINV", true));
		AddToolTipText(playerid, KEYTEXT_DROP_ITEM, ls(playerid, "KA_DROPITEM"));
		    
		if(IsValidItem(GetPlayerHolsterItem(playerid)))
			AddToolTipText(playerid, KEYTEXT_PUT_AWAY, ls(playerid, "KA_CCOLDRE2"));
	}

	if(IsPlayerOnAdminDuty(playerid))
		AddToolTipText(playerid, KEYTEXT_INVENTORY, GetLanguageString(GetPlayerLanguage(playerid), "KA_OPENINV", true));

    //AddToolTipText(playerid, "ALT", ls(playerid, "KA_OPENMAP"));

	ShowPlayerKeyActionUI(playerid);
	}
}

_ShowRepairTip(playerid, vehicleid)
{
	new Float:health;
	GetVehicleHealth(vehicleid, health);

	if(health <= VEHICLE_HEALTH_CHUNK_2)
		ShowHelpTip(playerid, GetLanguageString(GetPlayerLanguage(playerid), "TUTORVEHVER", true));
	else if(health <= VEHICLE_HEALTH_CHUNK_3)
		ShowHelpTip(playerid, GetLanguageString(GetPlayerLanguage(playerid), "TUTORVEHBRO", true));
	else if(health <= VEHICLE_HEALTH_CHUNK_4)
		ShowHelpTip(playerid, GetLanguageString(GetPlayerLanguage(playerid), "TUTORVEHBIT", true));
	else if(health <= VEHICLE_HEALTH_MAX)
		ShowHelpTip(playerid, GetLanguageString(GetPlayerLanguage(playerid), "TUTORVEHSLI", true));
	
	return;
}
