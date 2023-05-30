#include <YSI\y_hooks>

static enum LOCATION_DATA {
    LOCATION_NAME[11],
    Float:LOCATION_X,
    Float:LOCATION_Y,
    Float:LOCATION_Z,
    LOCATION_DESCRIPTION[30]
};

static locations[][LOCATION_DATA] = {
    {"51", 249.6743, 1887.9854, 20.6406, "Area 51"},
    {"69", -1359.2432, 498.4693, 21.2500, "Area 69"},
    {"ap", -2144.5183, -2338.9004, 30.6250, "Angel Pine"},
    {"bb", 0.22, 0.21, 3.11, "BlueBerry"},
    {"bs", -2506.8413, 2358.6741, 4.9860, "Bayside"},
    {"cb", -1918.1047, 640.4106, 46.5625, "Casa Branca"},
    {"dm", 619.8964, -542.9938, 16.4536, "Dillimore"},
    {"ec", -388.5280, 2212.0117, 42.4249, "El Castillo"},
    {"eq", -1527.5648, 2550.4546, 58.1881, "El Quebrados"},
    {"fc", -216.36, 979.20, 20.94, "Fort Carson"},
    {"ilhals", 4472.2578, -1718.3352, 8.3501, "Ilha de Los Santos"},
    {"ilhalv", 258.3774, 4316.2959, 3.3737, "Ilha de Las Venturas"},
    {"ilhasf", -4481.0483, 432.3738, 10.7196, "Ilha de San Fierro"},
    {"kacc", 2590.4778, 2800.8882, 10.8203, "K.A.C.C"},
    {"lb", -736.2372, 1547.7043, 39.0007, "Las Barrancas"},
    {"lp", -240.3974, 2713.4150, 62.6875, "Las Payasadas"},
    {"ls", 1545.14, -1353.26, 329.47, "Los Santos"},
    {"lv", 2026.64, 1008.28, 10.82, "Las Venturas"},
    {"mc", -2323.0515, -1637.6571, 483.7031, "Mount Chilliad"},
    {"mg", 1347.8447, 313.6524, 20.5547, "Montgomery"},
    {"militarls", 1900.0914, -457.6173, 27.4642, "Area Militar em Los Santos"},
    {"militarls1", -1039.7141, -918.3206, 132.6531, "2a Area Militar em Los Santos"},
    {"pc", 2332.5959, 38.6790, 26.4816, "Palomino Creek"},
    {"sf", -2026.95, 156.70, 29.03, "San Fierro"}
};

static TeleportToLocation(playerid, location) {
	if(location < 0 || location > sizeof(locations)-1) return 0;

	SetPlayerPos(playerid, locations[location][LOCATION_X], locations[location][LOCATION_Y], locations[location][LOCATION_Z]);
	ChatMsgAdmins(1, BLUE, "%p (%d) teleportou para %s (/%s)", playerid, playerid, locations[location][LOCATION_DESCRIPTION], locations[location][LOCATION_NAME]);

	return 1;
}

Dialog:LocationsDialog(playerid, response, listitem, inputtext[]) {
	if(response) TeleportToLocation(playerid, listitem);
}

ShowLocationsDialog(playerid) {
	new locStr[2048];

	for(new i = 0; i < sizeof(locations); ++i) strcat(locStr, sprintf("%s - "C_BROWN"(%s)\n", locations[i][LOCATION_DESCRIPTION], locations[i][LOCATION_NAME]));

	Dialog_Show(playerid, LocationsDialog, DIALOG_STYLE_LIST, "Teleportes:", locStr, "Teleportar", "Cancelar");
}

ACMD:goto[3](playerid, params[]) {
    if(!IsPlayerOnAdminDuty(playerid) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_LEAD) return CMD_NOT_DUTY;

   	new location[11];
    if(sscanf(params, "s[6]", location)) {
		ShowLocationsDialog(playerid);
        return 1;
    }

    for(new i = 0; i < sizeof(locations); ++i) {
        if(isequal(location, locations[i][LOCATION_NAME], true)) { 
    		TeleportToLocation(playerid, i);
            return 1;
        }
    }

	ShowLocationsDialog(playerid);

    return 1;
}

ACMD:tp[3](playerid, params[]) return acmd_goto_3(playerid, params);