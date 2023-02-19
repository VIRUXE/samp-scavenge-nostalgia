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


hook OnItemCreate(itemid)
{
	dbg("global", CORE, "[OnItemCreate] in /gamemodes/sss/core/weapon/core.pwn");

	new lootindex = GetItemLootIndex(itemid);

	if(lootindex != -1)
	{
		new ItemType:itemtype = GetItemType(itemid);

		if(GetItemTypeWeapon(itemtype) != -1)
		{
			new calibre = GetItemTypeWeaponCalibre(itemtype);
			if(calibre != NO_CALIBRE)
			{
				new
					ItemType:ammotypelist[4],
					ammotypes;

				ammotypes = GetAmmoItemTypesOfCalibre(calibre, ammotypelist);

				if(ammotypes > 0)
				{
					new magsize = GetItemTypeWeaponMagSize(itemtype);

					if(lootindex == 8 || lootindex == 4 || lootindex == 13) // world_civilian, vehicle_civilian, world_survivor
					{
						SetItemWeaponItemMagAmmo(itemid, random(magsize));
						SetItemWeaponItemAmmoItem(itemid, ammotypelist[random(ammotypes)]);
					}
					// world_police, world_military, vehicle_police, vehicle_military, airdrop_low_weapons, airdrop_military_weapons
					else if(lootindex == 12 || lootindex == 11 || lootindex == 7 || lootindex == 6 || lootindex == 2 || lootindex == 3)
					{
						switch(random(100))
						{
							case 00..29: // spawn empty
							{
								SetItemWeaponItemMagAmmo(itemid, 0);
								SetItemWeaponItemAmmoItem(itemid, INVALID_ITEM_TYPE);
							}

							case 30..49: // spawn with random ammo
							{
								SetItemWeaponItemMagAmmo(itemid, random(magsize + 1) - 1);
								SetItemWeaponItemAmmoItem(itemid, ammotypelist[random(ammotypes)]);
							}

							case 50..99: // spawn full
							{
								SetItemWeaponItemMagAmmo(itemid, magsize);
								SetItemWeaponItemAmmoItem(itemid, ammotypelist[random(ammotypes)]);
							}
						}
					}
				}
			}
		}
	}
}
