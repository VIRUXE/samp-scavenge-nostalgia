#include <YSI\y_hooks>


hook OnItemCreate(itemid)
{


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

					if(lootindex == GetLootIndexFromName("world_civilian") || lootindex == GetLootIndexFromName("vehicle_civilian") || lootindex == GetLootIndexFromName("world_survivor"))
					{
						SetItemWeaponItemMagAmmo(itemid, random(magsize));
						SetItemWeaponItemAmmoItem(itemid, ammotypelist[random(ammotypes)]);
					}
					else if(lootindex == GetLootIndexFromName("world_police") || lootindex == GetLootIndexFromName("world_military") || lootindex == GetLootIndexFromName("vehicle_police") || lootindex == GetLootIndexFromName("vehicle_military") || lootindex == GetLootIndexFromName("airdrop_low_weapons") || lootindex == GetLootIndexFromName("airdrop_military_weapons"))
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
