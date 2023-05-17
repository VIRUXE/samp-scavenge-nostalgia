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
	Text:HitMark_centre = Text:INVALID_TEXT_DRAW,
	Text:HitMark_offset = Text:INVALID_TEXT_DRAW;


public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	if(IsPlayerOnAdminDuty(playerid) || IsPlayerOnAdminDuty(issuerid))
		return 0;

	if(!IsPlayerSpawned(playerid) || !IsPlayerSpawned(issuerid))
		return 0;

    if(IsPlayerNPC(playerid) || IsPlayerNPC(issuerid))
		return 0;

	if(!IsPlayerStreamedIn(issuerid, playerid) || !IsPlayerStreamedIn(playerid, issuerid))
        return 0;

	if(IsPlayerUnfocused(playerid))
	    return 1;
	    	
	switch(weaponid)
	{
		case 31:
		{
			new model = GetVehicleModel(GetPlayerVehicleID(playerid));

			if(model == 447 || model == 476)
				_DoFirearmDamage(issuerid, playerid, INVALID_ITEM_ID, item_VehicleWeapon, bodypart);
		}
		case 38:
		{
			if(GetVehicleModel(GetPlayerVehicleID(playerid)) == 425)
				_DoFirearmDamage(issuerid, playerid, INVALID_ITEM_ID, item_VehicleWeapon, bodypart);
		}
	}

	return 1;
}

ShowHitMarker(playerid, weapon)
{
/*	if(weapon == 0 || IsWeaponMelee(weapon))
		return 0;*/

	if(weapon == 34 || weapon == 35){
		TextDrawShowForPlayer(playerid, HitMark_centre);
		defer HideHitMark(playerid, HitMark_centre);
	}else{
		TextDrawShowForPlayer(playerid, HitMark_offset);
		defer HideHitMark(playerid, HitMark_offset);
	}

	return 1;
}

timer HideHitMark[SEC(5)](playerid, Text:hitmark)
	TextDrawHideForPlayer(playerid, hitmark);

hook OnGameModeInit()
{
	HitMark_centre = TextDrawCreate(315.799987, 216.299957, "X");
	TextDrawBackgroundColor(HitMark_centre, 255);
	TextDrawFont(HitMark_centre, 1);
	TextDrawLetterSize(HitMark_centre, 0.389999, 1.399999);
	TextDrawColor(HitMark_centre, -16776961);
	TextDrawSetOutline(HitMark_centre, 1);
	TextDrawSetProportional(HitMark_centre, 1);
	TextDrawSetSelectable(HitMark_centre, 0);

	HitMark_offset = TextDrawCreate(334.799987, 172.299957, "X");
	TextDrawBackgroundColor(HitMark_offset, 255);
	TextDrawFont(HitMark_offset, 1);
	TextDrawLetterSize(HitMark_offset, 0.390000, 1.399999);
	TextDrawColor(HitMark_offset, -16776961);
	TextDrawSetOutline(HitMark_offset, 1);
	TextDrawSetProportional(HitMark_offset, 1);
	TextDrawSetSelectable(HitMark_offset, 0);
}