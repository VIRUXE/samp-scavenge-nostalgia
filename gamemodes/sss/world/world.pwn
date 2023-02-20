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


#include "sss/world/spawn.pwn"

#if defined GENERATE_WORLD
	#include "sss/world/zones/ls.pwn"
	#include "sss/world/zones/sf.pwn"
	#include "sss/world/zones/lv.pwn"
	#include "sss/world/zones/rc.pwn"
	#include "sss/world/zones/fc.pwn"
	#include "sss/world/zones/bc.pwn"
	#include "sss/world/zones/tr.pwn"
	#include "sss/world/zones/novos.pwn"

	//#include "sss/world/misc/ls_apartments1.pwn"
	//#include "sss/world/misc/ls_apartments2.pwn"
	//#include "sss/world/misc/ls_beachside.pwn"
	//#include "sss/world/misc/sf_zombotech.pwn"

	// #include "sss/world/misc/.pwn"
	#include "sss/world/puzzles/area69.pwn"
	//#include "sss/world/puzzles/ranch.pwn"
	#include "sss/world/puzzles/mtchill.pwn"
	//#include "sss/world/puzzles/codehunt.pwn"

	#include "sss/world/houseloot.pwn"
	//#include "sss/world/xmas.pwn"
#endif

static
	MapName[32] = "San Androcalypse",
	ItemCounts[ITM_MAX_TYPES];

#include <YSI\y_hooks>


hook OnGameModeInit()
{
	// Esgoto:

/*	new buttonid[2];
	buttonid[0] = CreateButton(-2587.3052, 1162.3717, 55.4375, "Pressione F para entrar"); // 
	buttonid[1] = CreateButton(-2578.5449, 1143.6442, 40.1459, "Pressione F para sair"); //
	LinkTP(buttonid[0], buttonid[1]);

	// CasaArvore:

	new buttonid2[2];
	buttonid2[0] = CreateButton(-2111.9375, 2699.9778, 160.6714, "Pressione F para subir"); // 
	buttonid2[1] = CreateButton(-2111.8342, 2699.4351, 175.3425, "Pressione F para descer"); // 
	LinkTP(buttonid2[0], buttonid2[1]);*/
    
	gServerInitialising = true;

	SetGameModeText("Scavenge Survive");
	SendRconCommand("hostname Nostalgia ~ Scavenge (Iniciando)");
	SendRconCommand("password 1234"); // This is just so that the server doesn't get flooded with players while it's loading.

	// store this to a list and compare after
	for(new ItemType:i; i < ITM_MAX_TYPES; i++)
	{
		if(!IsValidItemType(i)) break;

		if(GetItemTypeCount(i) == 0) continue;

		ItemCounts[i] = GetItemTypeCount(i);
	}

#if defined GENERATE_WORLD
	Load_LS();
	Load_SF();
	Load_LV();
	Load_RC();
	Load_FC();
	Load_BC();
	Load_TR();
	Load_Novos();
	Load_HouseLoot();
#endif

	new itemtypename[ITM_MAX_NAME];

	// compare with previous list and print differences
	for(new ItemType:i; i < ITM_MAX_TYPES; i++)
	{
		if(!IsValidItemType(i)) break;

		if(GetItemTypeCount(i) == 0) continue;

		GetItemTypeUniqueName(i, itemtypename);

		log("[%03d] Carregado:%04d, Spawnado:%04d, Total:%04d, '%s'", _:i, ItemCounts[i], GetItemTypeCount(i) - ItemCounts[i], GetItemTypeCount(i), itemtypename);
	}

	gServerInitialising = false;
		// I'd appreciate if you left my credit and the proper gamemode name intact!
	// Failure to do this will result in being blacklisted from the server list.
	// And I'll be less inclined to help you with issues.
	// Unless you have a decent reason to change the gamemode name (heavy mod)
	// I'd still like to be credited for my work. Many servers have claimed
	// they are the sole creator of the mode and this makes me sad and very
	// hesitant to release my work completely free of charge.
	SetGameModeText("Scavenge Survive");
	SendRconCommand("hostname Nostalgia ~ Scavenge");
	SendRconCommand("password 0"); // Removes the password
	
	// Calculate the amount of time it takes to load the server
	gServerLoadTime = GetTickCount() - gServerLoadTime_Start;
	log("\nServer load time: %d seconds", gServerLoadTime /= 1000);
	log("MAX_PLAYERS: %d", MAX_PLAYERS);
}

stock GetMapName() return MapName;