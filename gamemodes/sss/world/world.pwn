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

	#include "sss/world/puzzles/mtchill.pwn"
//	#include "sss/world/puzzles/area69.pwn"
//	#include "sss/world/puzzles/ranch.pwn"
//	#include "sss/world/puzzles/codehunt.pwn"

	#include "sss/world/houseloot.pwn"
	//#include "sss/world/xmas.pwn"
	
#endif

static
	MapName[32] = "San Androcalypse",
	ItemCounts[ITM_MAX_TYPES];

#include <YSI\y_hooks>


hook OnGameModeInit()
{   
	gServerInitialising = true;

	new Node:node, servername[24];

	JSON_GetObject(Settings, "server", node);
	JSON_GetString(node, "name", servername);

	SetGameModeText("Scavenge Survive");
	SendRconCommand(sprintf("hostname %s (Iniciando)", servername));
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
	SendRconCommand(sprintf("hostname %s", servername));

	new result, password[24];
	JSON_GetObject(Settings, "server", node);
	result = JSON_GetString(node, "password", password);
	if(result || isempty(password)) { // Configuracao nao existe no arquivo ou esta vazia
		log("[INFO] Nenhuma senha definida no arquivo de configuracao. Senha inicial removida.");
		SendRconCommand("password 0"); // Remove a senha inicial
	} else {
		log("[INFO] Senha carregada com sucesso.");
		SendRconCommand(sprintf("password %s", password));
	}
	
	// Calculate the amount of time it takes to load the server
	gServerLoadTime = GetTickCount() - gServerLoadTime_Start;
	log("\nTempo de Carregamento: %d segundos", gServerLoadTime /= 1000);
	log("MAX_PLAYERS: %d", MAX_PLAYERS);
}

stock GetMapName() return MapName;