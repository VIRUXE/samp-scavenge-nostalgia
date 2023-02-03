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

#define MAX_BLEEDS  (10)


static
Float:	bld_BleedRate[MAX_PLAYERS],
		bld_pDropID[MAX_PLAYERS];

new
		bld_Obj[MAX_PLAYERS][MAX_BLEEDS];

hook OnPlayerScriptUpdate(playerid)
{
	if(!IsPlayerSpawned(playerid))
		return;

	if(IsPlayerOnAdminDuty(playerid))
		return;

	if(IsNaN(bld_BleedRate[playerid]) || bld_BleedRate[playerid] < 0.0)
		bld_BleedRate[playerid] = 0.0;

	if(bld_BleedRate[playerid] > 0.0)
	{
		new
			Float:hp = GetPlayerHP(playerid),
			Float:slowrate = (((((100.0 - hp) / 360.0) * bld_BleedRate[playerid]) / GetPlayerWounds(playerid)) / 100.0);

		if(frandom(1.0) < 0.7)
		{
		    if(!IsPlayerInAnyVehicle(playerid))
			{
				new
					Float:x,
					Float:y,
					Float:z,
					Float:rx,
					Float:ry,
					Float:rz;

				GetPlayerPos(playerid, x, y, z);

				CA_RayCastLineAngle(x, y, z, x, y, z - 10.0, x, y, z, rx, ry, rz);

	            bld_pDropID[playerid] ++;
	            if(bld_pDropID[playerid] >= MAX_BLEEDS)
	                bld_pDropID[playerid] = 0;

				if(IsValidDynamicObject(bld_Obj[playerid][bld_pDropID[playerid]]))
				    DestroyDynamicObject(bld_Obj[playerid][bld_pDropID[playerid]]);

				bld_Obj[playerid][bld_pDropID[playerid]] = CreateDynamicObject(19836, x, y, z, rx, ry, rz, GetPlayerVirtualWorld(playerid),GetPlayerInterior(playerid),-1,50.0);
			}
			SetPlayerHP(playerid, hp - bld_BleedRate[playerid]);

			if(GetPlayerHP(playerid) < 0.1)
				SetPlayerHP(playerid, 0.0);
		}

		if(random(100) < 50)
			bld_BleedRate[playerid] -= slowrate;
	}
	else
	{
		new intensity = GetPlayerInfectionIntensity(playerid, 1);

		GivePlayerHP(playerid, 0.001925925 * GetPlayerFP(playerid) * (intensity ? 0.5 : 1.0));

		if(bld_BleedRate[playerid] < 0.0)
			bld_BleedRate[playerid] = 0.0;
	}

	if(IsPlayerUnderDrugEffect(playerid, drug_Morphine))
	{
		SetPlayerDrunkLevel(playerid, 2200);

		if(random(100) < 80)
			GivePlayerHP(playerid, 0.5);
	}

	return;
}

hook OnPlayerConnect(playerid){
    bld_pDropID[playerid] = 0;
    
    for(new i = 0; i < MAX_BLEEDS; i++)
        if(IsValidDynamicObject(bld_Obj[playerid][i]))
    		DestroyDynamicObject(bld_Obj[playerid][i]);
}

stock SetPlayerBleedRate(playerid, Float:rate)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	bld_BleedRate[playerid] = rate;

	return 1;
}

stock Float:GetPlayerBleedRate(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0.0;

	return bld_BleedRate[playerid];
}
