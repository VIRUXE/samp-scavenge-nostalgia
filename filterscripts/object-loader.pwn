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


/*==============================================================================


	Southclaw's Map Loader/Parser

		Loads .map files populated with CreateObject (or any variation) lines.
		Existence of a 'maps.cfg' file enables Unix style option input.
		Currently only supports '-d<0-4>' for various levels of debugging.


==============================================================================*/


#define FILTERSCRIPT

#include <a_samp>


/*==============================================================================

	Predefinitions and External Dependencies

==============================================================================*/


#include <ColAndreas>
#include <streamer>					// By Incognito:			http://forum.sa-mp.com/showthread.php?t=102865
#include <sscanf2>					// By Y_Less:				http://forum.sa-mp.com/showthread.php?t=120356
#include <FileManager>				// By JaTochNietDan:		http://forum.sa-mp.com/showthread.php?t=92246


/*==============================================================================

	Constants

==============================================================================*/


#define DIRECTORY_SCRIPTFILES	"./scriptfiles/"
#define DIRECTORY_MAPS			"Maps/"
#define DIRECTORY_SESSION		"session/"
#define CONFIG_FILE				DIRECTORY_MAPS"maps.cfg"

#define MAX_REMOVED_OBJECTS		(300)
#define MAX_MATERIAL_SIZE		(14)
#define MAX_MATERIAL_LEN		(8)
#define SESSION_NAME_LEN		(40)


/*==============================================================================

	Debug levels

==============================================================================*/


enum
{
	DEBUG_LEVEL_NONE = -1,	// (-1) No prints
	DEBUG_LEVEL_INFO,		// (0) Print information messages
	DEBUG_LEVEL_FOLDERS,	// (1) Print each folder
	DEBUG_LEVEL_FILES,		// (2) Print each loaded file
	DEBUG_LEVEL_DATA,		// (3) Print each loaded data line in each file
	DEBUG_LEVEL_LINES		// (4) Print each line in each file
}

enum E_REMOVE_DATA
{
		remove_Model,
Float:	remove_PosX,
Float:	remove_PosY,
Float:	remove_PosZ,
Float:	remove_Range
}


/*==============================================================================

	Variables

==============================================================================*/


new
		gDebugLevel = 0,
		gTotalLoadedObjects,
		gModelRemoveData[MAX_REMOVED_OBJECTS][E_REMOVE_DATA],
		gLoadedRemoveBuffer[MAX_PLAYERS][MAX_REMOVED_OBJECTS][5],
		gTotalObjectsToRemove;


/*==============================================================================

	Core

==============================================================================*/

public OnFilterScriptInit()
{
/*  SendRconCommand("loadfs AntiAirbreak");
    SendRconCommand("loadfs AntiBot");
    SendRconCommand("loadfs mapfix");*/
    
    static const rIds[] = {
		WATER_OBJECT, 3261, 19868, 19869, 1492, 1502, 1494, 19802, 4515, 1411, 1499, 4518, 1374, 6048,
		1290, 1223, 1226, 1297, 1298, 2072, 3460, 3463, 3472, 1294, 1568, 1232, 1231, 3853, 8378,
		4516, 4517, 4524, 4523, 3261, 4525, 3294, 4504, 1412, 10353, 4509, 16775,
  		6047, 4508, 6037, 6038, 4527, 1283, 1491, 4514, 4507, 1496, 1413, 4522, 4506,
  		4520, 4526, 4512, 3260, 4521, 4511, 4510, 4505, 3168, 1468, 4519, 6391, 4513, 6006, 3278,
  		3276, 7499, 17290, 5772, 5674, 11258, 8541, 3172, 7503, 8626, 8627, 8630, 11230, 8858, 8860, 6502,
		6501, 6292, 6290, 6252, 6251, 6250, 6249, 11255, 11256, 11261, 11260, 11259, 11257, 11252, 11253,
		11254, 7205, 13513, 9030, 17245, 17170, 16034, 16026, 12831, 14716, 11465, 11464, 11306, 4884, 11232,
		7501, 6914, 7502, 16037, 11482, 11481, 11468, 8207, 8208, 7500, 16266, 11462, 17297, 17296, 17287,
		17286, 17285, 7498, 17283, 6915, 16571, 5478, 5479, 8634, 8633, 8632, 5480, 8629, 8628, 5513, 6912,
		8624, 8597, 8592, 8588, 3858, 1447, 16732, 6010, 3280, 16203, 1418, 1315, 1410,
		625, 626, 627, 628, 629, 630, 631, 632, 633, 642, 643, 644, 646, 650, 716, 717, 737, 738, 792, 858, 881, 882, 883,
		884, 885, 886, 887, 888, 889, 890, 891, 892, 893, 894, 895, 904, 905, 941, 955, 956, 959, 961, 990, 993, 996, 1209,
		1211, 1213, 1219, 1220, 1221, 1223, 1224, 1225, 1226, 1227, 1228, 1229, 1230, 1231, 1232, 1235, 1238, 1244, 1251,
		1255, 1257, 1262, 1264, 1265, 1270, 1280, 1281, 1282, 1283, 1284, 1285, 1286, 1287, 1288, 1289, 1291, 1293,
		1294, 1297, 1300, 1302, 1315, 1328, 1329, 1330, 1338, 1350, 1351, 1352, 1370, 1373, 1374, 1375, 1407, 1408, 1409,
		1410, 1411, 1412, 1413, 1414, 1415, 1417, 1418, 1419, 1420, 1421, 1422, 1423, 1424, 1425, 1426, 1428, 1429, 1431,
		1432, 1433, 1436, 1437, 1438, 1440, 1441, 1443, 1444, 1445, 1446, 1447, 1448, 1449, 1450, 1451, 1452, 1456, 1457,
		1458, 1459, 1460, 1461, 1462, 1463, 1464, 1465, 1466, 1467, 1468, 1469, 1470, 1471, 1472, 1473, 1474, 1475, 1476,
		1477, 1478, 1479, 1480, 1481, 1482, 1483, 1514, 1517, 1520, 1534, 1543, 1544, 1545, 1551, 1553, 1554, 1558, 1564,
		1568, 1582, 1583, 1584, 1588, 1589, 1590, 1591, 1592, 1645, 1646, 1647, 1654, 1664, 1666, 1667, 1668, 1669, 1670,
		1672, 1676, 1684, 1686, 1775, 1776, 1949, 1950, 1951, 1960, 1961, 1962, 1975, 1976, 1977, 2647, 2663, 2682, 2683,
		2885, 2886, 2887, 2900, 2918, 2920, 2925, 2932, 2933, 2942, 2943, 2945, 2947, 2958, 2959, 2966, 2968, 2971, 2977,
		2987, 2988, 2989, 2991, 2994, 3006, 3018, 3019, 3020, 3021, 3022, 3023, 3024, 3029, 3032, 3036, 3058, 3059, 3067,
		3083, 3091, 3221, 3260, 3261, 3262, 3263, 3264, 3265, 3267, 3275, 3276, 3278, 3280, 3281, 3282, 3302, 3374, 3409,
		3460, 3516, 3794, 3795, 3797, 3853, 3855, 3864, 3884, 11103, 12840, 16627, 16628, 16629, 16630, 16631, 16632,
		16633, 16634, 16635, 16636, 16732, 17968,4504, 4505, 4506, 4507, 4508, 4509, 4510, 4511, 4512, 4513,
		4514, 4516, 4517, 4518, 4519, 4520, 4521, 4522, 4523, 3857, 3859, 3851,
		4524, 4525, 4526, 4527, 16436, 16437, 16438, 16439, 1662, 12841, 6039,1349, 4587, 6007, 6042, 6053,
		16773, 16775, 16501, 17951, 6517, 13817, 13188, 13187, 16500, 9099, 7930, 10246, 11327, 10671, 9823, 7927, 5061, // Garagens
		6054, 6055 // KACC
 	};

 	for(new i = 0; i < sizeof(rIds); i++)
		CA_RemoveBuilding(rIds[i], 0.0, 0.0, 0.0, 4242.6407);
		
	if(!dir_exists(DIRECTORY_SCRIPTFILES))
	{
		print("ERROR: Directory '"DIRECTORY_SCRIPTFILES"' not found. Creating directory.");
		dir_create(DIRECTORY_SCRIPTFILES);
	}

	if(!dir_exists(DIRECTORY_SCRIPTFILES DIRECTORY_MAPS))
	{
		print("ERROR: Directory '"DIRECTORY_SCRIPTFILES DIRECTORY_MAPS"' not found. Creating directory.");
		dir_create(DIRECTORY_SCRIPTFILES DIRECTORY_MAPS);
	}

	if(!dir_exists(DIRECTORY_SCRIPTFILES DIRECTORY_MAPS DIRECTORY_SESSION))
	{
		print("ERROR: Directory '"DIRECTORY_SCRIPTFILES DIRECTORY_MAPS DIRECTORY_SESSION"' not found. Creating directory.");
		dir_create(DIRECTORY_SCRIPTFILES DIRECTORY_MAPS DIRECTORY_SESSION);
	}

	// Load config if exists
	if(fexist(CONFIG_FILE))
		LoadConfig();

	if(gDebugLevel > DEBUG_LEVEL_NONE)
		printf("INFO: [Init] Debug Level: %d", gDebugLevel);

	LoadMapsFromFolder(DIRECTORY_MAPS);

	// Yes a standard loop is required here.
	for(new i; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerConnected(i))
			RemoveObjects_OnLoad(i);
	}

	if(gDebugLevel >= DEBUG_LEVEL_INFO){
		printf("INFO: [Init] %d Total objects", gTotalLoadedObjects);
		printf("INFO: [Init] %d Objects to remove", gTotalObjectsToRemove);
	}
		
    CA_Init();
	return 1;
}

LoadConfig()
{
	new
		File:file,
		line[32];

	file = fopen(CONFIG_FILE, io_read);

	if(file)
	{
		new len;

		fread(file, line, 32);

		len = strlen(line);

		for(new i; i < len; i++)
		{
			switch(line[i])
			{
				case ' ', '-', '\r', '\n':
					continue;
			}

			if(line[i] == 'd' && (i < len - 3))
			{
				i++;

				new val = line[i] - 48;

				if(DEBUG_LEVEL_NONE < val <= DEBUG_LEVEL_LINES)
					gDebugLevel = val;

				continue;
			}

			printf("ERROR: Unknown option character at column %d.", i);

			/*
				Ideas for future options:
				-r[path] = set the root directory to load maps from
				-s[value] = set default stream distance
				-S[value] = override all per-file stream distances
				-m[value] = set object limit
				-I[path] = include another directory for loading maps
			*/

		}

		fclose(file);
	}

	return 1;
}

LoadMapsFromFolder(folder[])
{
	new
		foldername[256],
		dir:dirhandle,
		item[64],
		type,
		filename[256];

	format(foldername, sizeof(foldername), DIRECTORY_SCRIPTFILES"%s", folder);
	dirhandle = dir_open(foldername);

	if(gDebugLevel >= DEBUG_LEVEL_FOLDERS)
	{
		new
			totalfiles,
			totalmapfiles,
			totalfolders;

		while(dir_list(dirhandle, item, type))
		{
			if(type == FM_FILE)
			{
				totalfiles++;

				if(!strcmp(item[strlen(item) - 4], ".map"))
					totalmapfiles++;
			}

			if(type == FM_DIR && strcmp(item, "..") && strcmp(item, ".") && strcmp(item, "_"))
				totalfolders++;
		}

		// Reopen the directory so the next code can run properly.
		dir_close(dirhandle);
		dirhandle = dir_open(foldername);

		printf("DEBUG: [LoadMapsFromFolder] Reading directory '%s': %d files, %d .map files, %d folders", foldername, totalfiles, totalmapfiles, totalfolders);
	}

	while(dir_list(dirhandle, item, type))
	{
		if(type == FM_FILE)
		{
			if(!strcmp(item[strlen(item) - 4], ".map"))
			{
				filename[0] = EOS;
				format(filename, sizeof(filename), "%s%s", folder, item);
				LoadMap(filename);
			}
		}

		if(type == FM_DIR && strcmp(item, "..") && strcmp(item, ".") && strcmp(item, "_"))
		{
			filename[0] = EOS;
			format(filename, sizeof(filename), "%s%s/", folder, item);
			LoadMapsFromFolder(filename);
		}
	}

	dir_close(dirhandle);

	if(gDebugLevel >= DEBUG_LEVEL_FOLDERS)
		print("DEBUG: [LoadMapsFromFolder] Finished reading directory.");
}

LoadMap(filename[])
{
	new
		File:file,
		line[256],

		linenumber = 1,
		objects,
		operations,

		funcname[32],
		funcargs[128],

		globalworld = -1,
		globalinterior = -1,
		Float:globalrange = 350.0,

		modelid,
		Float:posx,
		Float:posy,
		Float:posz,
		Float:rotx,
		Float:roty,
		Float:rotz,
		world,
		interior,
		Float:range,

		tmpObjID,
		tmpObjIdx,
		tmpObjMod,
		tmpObjTxd[32],
		tmpObjTex[32],
		tmpObjMatCol,

		tmpObjText[128],
		tmpObjResName[32],
		tmpObjRes,
		tmpObjFont[32],
		tmpObjFontSize,
		tmpObjBold,
		tmpObjFontCol,
		tmpObjBackCol,
		tmpObjAlign,

		matSizeTable[MAX_MATERIAL_SIZE][MAX_MATERIAL_LEN] =
		{
			"32x32",
			"64x32",
			"64x64",
			"128x32",
			"128x64",
			"128x128",
			"256x32",
			"256x64",
			"256x128",
			"256x256",
			"512x64",
			"512x128",
			"512x256",
			"512x512"
		};

	if(!fexist(filename))
	{
		printf("ERROR: file: \"%s\" NOT FOUND", filename);
		return 0;
	}

	file = fopen(filename, io_read);

	if(!file)
	{
		printf("ERROR: file: \"%s\" NOT LOADED", filename);
		return 0;
	}

	if(gDebugLevel >= DEBUG_LEVEL_FILES)
	{
		new totallines;

		while(fread(file, line))
			totallines++;

		// Reopen the file so the actual read code runs properly.
		fclose(file);
		file = fopen(filename, io_read);

		printf("\nDEBUG: [LoadMap] Reading file '%s': %d lines.", filename, totallines);
	}

	while(fread(file, line))
	{
		if(gDebugLevel == DEBUG_LEVEL_LINES)
			print(line);

		if(line[0] < 65)
		{
			linenumber++;
			continue;
		}

		if(sscanf(line, "p<(>s[32]p<)>s[128]{s[96]}", funcname, funcargs))
		{
			linenumber++;
			continue;
		}

		if(!strcmp(funcname, "options", false))
		{
			if(!sscanf(funcargs, "p<,>ddf", globalworld, globalinterior, globalrange))
			{
				if(gDebugLevel >= DEBUG_LEVEL_DATA)
					printf(" DEBUG: [LoadMap] Updated options to: %d, %d, %f", globalworld, globalinterior, globalrange);

				operations++;
			}
		}

		if(!strcmp(funcname, "Create", false, 6)) // Scan for any function starting with 'Create', this covers CreateObject, CreateDynamicObject, CreateStreamedObject, etc.
		{
			if(!sscanf(funcargs, "p<,>dffffffD(-1)D(-1){D(-1)}F(-1.0)", modelid, posx, posy, posz, rotx, roty, rotz, world, interior, range))
			{
				if(world == -1)
					world = globalworld;

				if(interior == -1)
					interior = globalinterior;

				if(range == -1.0)
					range = globalrange;

				if(gDebugLevel == DEBUG_LEVEL_DATA)
				{
					printf(" DEBUG: [LoadMap] Object: %d, %.2f, %.2f, %.2f, %.2f, %.2f, %.2f (%d, %d, %f)",
						modelid, posx, posy, posz, rotx, roty, rotz, world, interior, range);
				}


				tmpObjID = CreateDynamicObject(modelid, posx, posy, posz, rotx, roty, rotz, world, interior, -1, range + 400.0, range + 400.0);
                gTotalLoadedObjects++;
				objects++;
				operations++;
				static const rIds[] = {
					WATER_OBJECT, 3261, 19868, 19869, 1492, 1502, 1494, 19802, 1411, 1499, 4518, 1374,
					1290, 1223, 1226, 1297, 1298, 2072, 3460, 3463, 3472, 1294, 1568, 1232, 1231, 3853, 8378,
					4516, 4517, 4524, 4523, 3261, 4525, 3294, 4504, 1412, 10353, 4509, 16775,
			  		6047, 4508, 6037, 6038, 4527, 1283, 1491, 4514, 4507, 1496, 1413, 4522, 4506,
			  		4520, 4526, 4512, 3260, 4521, 4511, 4510, 4505, 3168, 1468, 4519, 6391, 4513, 6006, 3278,
			  		3276, 7499, 17290, 5772, 5674, 11258, 8541, 3172, 7503, 8626, 8627, 8630, 11230, 8858, 8860, 6502,
					6501, 6292, 6290, 6252, 6251, 6250, 6249, 11255, 11256, 11261, 11260, 11259, 11257, 11252, 11253,
					11254, 7205, 13513, 9030, 17245, 17170, 16034, 16026, 12831, 14716, 11465, 11464, 11306, 4884, 11232,
					7501, 6914, 7502, 16037, 11482, 11481, 11468, 8207, 8208, 7500, 16266, 11462, 17297, 17296, 17287,
					17286, 17285, 7498, 17283, 6915, 16571, 5478, 5479, 8634, 8633, 8632, 5480, 8629, 8628, 5513, 6912,
					8624, 8597, 8592, 8588, 3858, 1447, 16732, 6010, 3280, 16203, 1418, 1315, 1410,
					625, 626, 627, 628, 629, 630, 631, 632, 633, 642, 643, 644, 646, 650, 716, 717, 737, 738, 792, 858, 881, 882, 883,
					884, 885, 886, 887, 888, 889, 890, 891, 892, 893, 894, 895, 904, 905, 941, 955, 956, 959, 961, 990, 993, 996, 1209,
					1211, 1213, 1219, 1220, 1221, 1223, 1224, 1225, 1226, 1227, 1228, 1229, 1230, 1231, 1232, 1235, 1238, 1244, 1251,
					1255, 1257, 1262, 1264, 1265, 1270, 1280, 1281, 1282, 1283, 1284, 1285, 1286, 1287, 1288, 1289, 1291, 1293,
					1294, 1297, 1300, 1302, 1315, 1328, 1329, 1330, 1338, 1350, 1351, 1352, 1370, 1373, 1374, 1375, 1407, 1408, 1409,
					1410, 1411, 1412, 1413, 1414, 1415, 1417, 1418, 1419, 1420, 1421, 1422, 1423, 1424, 1425, 1426, 1428, 1429, 1431,
					1432, 1433, 1436, 1437, 1438, 1440, 1441, 1443, 1444, 1445, 1446, 1447, 1448, 1449, 1450, 1451, 1452, 1456, 1457,
					1458, 1459, 1460, 1461, 1462, 1463, 1464, 1465, 1466, 1467, 1468, 1469, 1470, 1471, 1472, 1473, 1474, 1475, 1476,
					1477, 1478, 1479, 1480, 1481, 1482, 1483, 1514, 1517, 1520, 1534, 1543, 1544, 1545, 1551, 1553, 1554, 1558, 1564,
					1568, 1582, 1583, 1584, 1588, 1589, 1590, 1591, 1592, 1645, 1646, 1647, 1654, 1664, 1666, 1667, 1668, 1669, 1670,
					1672, 1676, 1684, 1686, 1775, 1776, 1949, 1950, 1951, 1960, 1961, 1962, 1975, 1976, 1977, 2647, 2663, 2682, 2683,
					2885, 2886, 2887, 2900, 2918, 2920, 2925, 2932, 2933, 2942, 2943, 2945, 2947, 2958, 2959, 2966, 2968, 2971, 2977,
					2987, 2988, 2989, 2991, 2994, 3006, 3018, 3019, 3020, 3021, 3022, 3023, 3024, 3029, 3032, 3036, 3058, 3059, 3067,
					3083, 3091, 3221, 3260, 3261, 3262, 3263, 3264, 3265, 3267, 3275, 3276, 3278, 3280, 3281, 3282, 3302, 3374, 3409,
					3460, 3516, 3794, 3795, 3797, 3853, 3855, 3864, 3884, 11103, 12840, 16627, 16628, 16629, 16630, 16631, 16632,
					16633, 16634, 16635, 16636, 16732, 17968,4504, 4505, 4506, 4507, 4508, 4509, 4510, 4511, 4512, 4513,
					4514, 4515, 4516, 4517, 4518, 4519, 4520, 4521, 4522, 4523, 3857, 3859, 3851, 6048,
					4524, 4525, 4526, 4527, 16436, 16437, 16438, 16439, 1662, 12841, 6039,1349, 4587, 6007, 6042, 6053,
					16773, 16775, 16501, 17951, 6517, 13817, 13188, 13187, 16500, 9099, 7930, 10246, 11327, 10671, 9823, 7927, 5061 // Garagens
			 	};
				new isid = 0;
			 	for(new i = 0; i < sizeof(rIds); i++)
					if(modelid == rIds[i]) isid ++;
					
				if(!isid)CA_CreateObject(modelid, posx, posy, posz, rotx, roty, rotz);
			}
		}

		if(!strcmp(funcname, "SetObjectMaterialText"))
		{
			if(!sscanf(funcargs, "p<,>{s[32]} d p<\">{s[2]}s[32]p<,>{s[2]} s[32] p<\">{s[2]}s[32]p<,>{s[2]} ddxxd", tmpObjIdx, tmpObjText, tmpObjResName, tmpObjFont, tmpObjFontSize, tmpObjBold, tmpObjFontCol, tmpObjBackCol, tmpObjAlign))
			{
				if(gDebugLevel == DEBUG_LEVEL_DATA)
				{
					printf(" DEBUG: [LoadMap] Object Text: '%s', %d, '%s', '%s', %d, %d, %x, %x, %d",
						tmpObjText, tmpObjIdx, tmpObjResName, tmpObjFont, tmpObjFontSize, tmpObjBold, tmpObjFontCol, tmpObjBackCol, tmpObjAlign);
				}

				new len = strlen(tmpObjText);

				tmpObjRes = strval(tmpObjResName[0]);

				if(tmpObjRes == 0)
				{
					for(new i; i < sizeof(matSizeTable); i++)
					{
						if(strfind(tmpObjResName, matSizeTable[i]) != -1)
							tmpObjRes = (i + 1) * 10;
					}
				}

				for(new i; i < len; i++)
				{
					if(tmpObjText[i] == '\\' && i != len-1)
					{
						if(tmpObjText[i+1] == 'n')
						{
							strdel(tmpObjText, i, i+1);
							tmpObjText[i] = '\n';
						}
					}
				}

				SetDynamicObjectMaterialText(tmpObjID, tmpObjIdx, tmpObjText, tmpObjRes, tmpObjFont, tmpObjFontSize, tmpObjBold, tmpObjFontCol, tmpObjBackCol, tmpObjAlign);
				operations++;
			}
		}

		if(!strcmp(funcname, "SetDynamicObjectMaterialText"))
		{
			if(!sscanf(funcargs, "p<,>{s[16]} p<\">{s[1]}s[32]p<,>{s[1]} d s[32] p<\">{s[1]}s[32]p<,>{s[1]} ddxxd", tmpObjText, tmpObjIdx, tmpObjResName, tmpObjFont, tmpObjFontSize, tmpObjBold, tmpObjFontCol, tmpObjBackCol, tmpObjAlign))
			{
				if(gDebugLevel == DEBUG_LEVEL_DATA)
				{
					printf(" DEBUG: [LoadMap] Object Text: '%s', %d, '%s', '%s', %d, %d, %x, %x, %d",
						tmpObjText, tmpObjIdx, tmpObjResName, tmpObjFont, tmpObjFontSize, tmpObjBold, tmpObjFontCol, tmpObjBackCol, tmpObjAlign);
				}

				new len = strlen(tmpObjText);

				tmpObjRes = strval(tmpObjResName[0]);

				if(tmpObjRes == 0)
				{
					for(new i; i < sizeof(matSizeTable); i++)
					{
						if(strfind(tmpObjResName, matSizeTable[i]) != -1)
							tmpObjRes = (i + 1) * 10;
					}
				}

				for(new i; i < len; i++)
				{
					if(tmpObjText[i] == '\\' && i != len-1)
					{
						if(tmpObjText[i+1] == 'n')
						{
							strdel(tmpObjText, i, i+1);
							tmpObjText[i] = '\n';
						}
					}
				}

				SetDynamicObjectMaterialText(tmpObjID, tmpObjIdx, tmpObjText, tmpObjRes, tmpObjFont, tmpObjFontSize, tmpObjBold, tmpObjFontCol, tmpObjBackCol, tmpObjAlign);
				operations++;
			}
		}

		if(!strcmp(funcname, "SetObjectMaterial"))
		{
			if(!sscanf(funcargs, "p<,>{s[16]}dd p<\">{s[1]}s[32]p<,>{s[1]} p<\">{s[1]}s[32]p<,>{s[1]} x", tmpObjIdx, tmpObjMod, tmpObjTxd, tmpObjTex, tmpObjMatCol))
			{
				if(gDebugLevel == DEBUG_LEVEL_DATA)
				{
					printf(" DEBUG: [LoadMap] Object Material: %d, %d, '%s', '%s', %x",
						tmpObjIdx, tmpObjMod, tmpObjTxd, tmpObjTex, tmpObjMatCol);
				}

				SetDynamicObjectMaterial(tmpObjID, tmpObjIdx, tmpObjMod, tmpObjTxd, tmpObjTex, tmpObjMatCol);
				operations++;
			}
		}

		if(!strcmp(funcname, "RemoveBuildingForPlayer"))
		{
			if(gTotalObjectsToRemove < MAX_REMOVED_OBJECTS)
			{
				if(!sscanf(funcargs, "p<,>{s[16]}dffff", modelid, posx, posy, posz, range))
				{
					if(gDebugLevel == DEBUG_LEVEL_DATA)
					{
						printf(" DEBUG: [LoadMap] Removal: %d, %.2f, %.2f, %.2f, %.2f",
							modelid, posx, posy, posz, range);
					}

					gModelRemoveData[gTotalObjectsToRemove][remove_Model] = modelid;
					gModelRemoveData[gTotalObjectsToRemove][remove_PosX] = posx;
					gModelRemoveData[gTotalObjectsToRemove][remove_PosY] = posy;
					gModelRemoveData[gTotalObjectsToRemove][remove_PosZ] = posz;
					gModelRemoveData[gTotalObjectsToRemove][remove_Range] = range;

					CA_RemoveBuilding(modelid, posx, posy, posz, range);

					gTotalObjectsToRemove++;
					operations++;
				}
			}
			else
			{
				printf(" ERROR: [LoadMap] Removal on line %d failed. Removal limit reached.", linenumber);
			}
		}

		linenumber++;
	}

	fclose(file);

	if(gDebugLevel >= DEBUG_LEVEL_FILES)
		printf("DEBUG: [LoadMap] Finished reading file. %d objects loaded from %d lines, %d total operations.", objects, linenumber, operations);

	return linenumber;
}

public OnPlayerConnect(playerid)
{
	RemoveObjects_FirstLoad(playerid);

	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	new
		name[MAX_PLAYER_NAME],
		filename[SESSION_NAME_LEN];

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	format(filename, sizeof(filename), DIRECTORY_MAPS DIRECTORY_SESSION"%s.dat", name);

	if(gDebugLevel >= DEBUG_LEVEL_INFO)
		printf("INFO: [OnPlayerDisconnect] Removing session data file for %s", name);

	fremove(filename);

	return 1;
}

RemoveObjects_FirstLoad(playerid)
{
	new
		File:file,
		name[MAX_PLAYER_NAME],
		filename[SESSION_NAME_LEN],
		buffer[5];

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	format(filename, sizeof(filename), DIRECTORY_MAPS DIRECTORY_SESSION"%s.dat", name);

	file = fopen(filename, io_write);

	if(!file)
		printf("ERROR: [RemoveObjects_FirstLoad] Opening file '%s' for write.", filename);

	if(gDebugLevel >= DEBUG_LEVEL_INFO)
		printf("INFO: [RemoveObjects_FirstLoad] Created session data for %s", name);

	for(new i; i < gTotalObjectsToRemove; i++)
	{
		RemoveBuildingForPlayer(playerid, gModelRemoveData[i][remove_Model],
			gModelRemoveData[i][remove_PosX],
			gModelRemoveData[i][remove_PosY],
			gModelRemoveData[i][remove_PosZ],
			gModelRemoveData[i][remove_Range]);

		// Build a list of removed objects for checking against when the script is
		// reloaded. This way, the reload function isn't called unnecessarily.

		buffer[0] = gModelRemoveData[i][remove_Model];
		buffer[1] = _:gModelRemoveData[i][remove_PosX];
		buffer[2] = _:gModelRemoveData[i][remove_PosY];
		buffer[3] = _:gModelRemoveData[i][remove_PosZ];
		buffer[4] = _:gModelRemoveData[i][remove_Range];

		if(gDebugLevel >= DEBUG_LEVEL_DATA)
			printf("INFO: [RemoveObjects_FirstLoad] Write: [%x.%x.%x.%x.%x]", buffer[0], buffer[1], buffer[2], buffer[3], buffer[4]);

		fblockwrite(file, buffer);
	}

	fclose(file);

	return 1;
}

RemoveObjects_OnLoad(playerid)
{
	new
		File:file,
		name[MAX_PLAYER_NAME],
		filename[SESSION_NAME_LEN],
		buffer[5],
		idx;

	GetPlayerName(playerid, name, MAX_PLAYER_NAME);

	format(filename, sizeof(filename), DIRECTORY_MAPS DIRECTORY_SESSION"%s.dat", name);

	if(!fexist(filename))
	{
		if(gDebugLevel >= DEBUG_LEVEL_INFO)
			printf("INFO: [RemoveObjects_OnLoad] Session data for %s doesn't exist, running firstload.", name);

		RemoveObjects_FirstLoad(playerid);

		return 0;
	}

	file = fopen(filename, io_read);

	if(gDebugLevel >= DEBUG_LEVEL_INFO)
		printf("INFO: [RemoveObjects_OnLoad] Loading removals for %s", name);

	// Build a list of existing removed objects for this player

	while(fblockread(file, gLoadedRemoveBuffer[playerid][idx], 5))
		idx++;

	fclose(file);

	file = fopen(filename, io_append);

	for(new i; i < gTotalObjectsToRemove; i++)
	{
		new skip;

		for(new j; j < idx; j++)
		{
			if(
				_:gModelRemoveData[i][remove_Model] == gLoadedRemoveBuffer[playerid][j][0] &&
				_:gModelRemoveData[i][remove_PosX] == gLoadedRemoveBuffer[playerid][j][1] &&
				_:gModelRemoveData[i][remove_PosY] == gLoadedRemoveBuffer[playerid][j][2] &&
				_:gModelRemoveData[i][remove_PosZ] == gLoadedRemoveBuffer[playerid][j][3] &&
				_:gModelRemoveData[i][remove_Range] == gLoadedRemoveBuffer[playerid][j][4])
			{
				skip = true;
				break;
			}
		}

		if(skip)
		{
			if(gDebugLevel == DEBUG_LEVEL_DATA)
				printf(" DEBUG: [RemoveObjects_OnLoad] Skipping object removal %d (model: %d)", i, gModelRemoveData[i][remove_Model]);

			continue;
		}

		if(gDebugLevel == DEBUG_LEVEL_DATA)
			printf(" DEBUG: [RemoveObjects_OnLoad] Removing object %d (model: %d)", i, gModelRemoveData[i][remove_Model]);

		RemoveBuildingForPlayer(playerid, gModelRemoveData[i][remove_Model],
			gModelRemoveData[i][remove_PosX],
			gModelRemoveData[i][remove_PosY],
			gModelRemoveData[i][remove_PosZ],
			gModelRemoveData[i][remove_Range]);

		// This object is new, append it to the player's session data file.

		buffer[0] = gModelRemoveData[i][remove_Model];
		buffer[1] = _:gModelRemoveData[i][remove_PosX];
		buffer[2] = _:gModelRemoveData[i][remove_PosY];
		buffer[3] = _:gModelRemoveData[i][remove_PosZ];
		buffer[4] = _:gModelRemoveData[i][remove_Range];

		if(gDebugLevel >= DEBUG_LEVEL_DATA)
			printf("INFO: [RemoveObjects_OnLoad] Append: [%x.%x.%x.%x.%x]", buffer[0], buffer[1], buffer[2], buffer[3], buffer[4]);

		fblockwrite(file, buffer);
	}

	fclose(file);

	return 1;
}
