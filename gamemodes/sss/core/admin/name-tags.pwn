#include <YSI\y_hooks>

static
		tags_Toggle[MAX_PLAYERS],
Text3D:	tags_Nametag[MAX_PLAYERS] = {Text3D:INVALID_3DTEXT_ID, ...};

hook OnPlayerConnect(playerid) {
	new
		players[MAX_PLAYERS],
		maxplayers;

	tags_Toggle[playerid] = false;

	foreach(new i : Player) {
		if(tags_Toggle[i])
			players[maxplayers++] = i;
	}

	tags_Nametag[playerid] = CreateDynamic3DTextLabelEx(
		sprintf("(%d) %s", playerid, GetPlayerNameEx(playerid)), YELLOW, 0.0, 0.0, 0.0, 6000.0, playerid,
		.testlos        = 0,
		.streamdistance = 6000.0,
		.players        = players,
		.maxworlds      = 1,
		.maxinteriors   = 1,
		.maxplayers     = maxplayers);

	return 1;
}

hook OnPlayerDisconnect(playerid, reason) {
	DestroyDynamic3DTextLabel(tags_Nametag[playerid]);
	tags_Nametag[playerid] = Text3D:INVALID_3DTEXT_ID;

	foreach(new i : Player) {
		if(IsValidDynamic3DTextLabel(tags_Nametag[i]))
			Streamer_RemoveArrayData(STREAMER_TYPE_3D_TEXT_LABEL, tags_Nametag[i], E_STREAMER_PLAYER_ID, playerid);
	}		

	return 1;
}

ToggleNameTagsForPlayer(playerid, toggle) {
	if(!IsPlayerConnected(playerid)) return 0;

	tags_Toggle[playerid] = toggle;

	if(toggle) {
		foreach(new i : Player) {
			if(!Streamer_IsInArrayData(STREAMER_TYPE_3D_TEXT_LABEL, tags_Nametag[i], E_STREAMER_PLAYER_ID, playerid))
				Streamer_AppendArrayData(STREAMER_TYPE_3D_TEXT_LABEL, tags_Nametag[i], E_STREAMER_PLAYER_ID, playerid);
		}
	} else {
		foreach(new i : Player) {
			Streamer_RemoveArrayData(STREAMER_TYPE_3D_TEXT_LABEL, tags_Nametag[i], E_STREAMER_PLAYER_ID, playerid);
		}
	}

	return 1;
}

stock GetPlayerNameTagsToggle(playerid) {
	if(!IsPlayerConnected(playerid)) return 0;

	return tags_Toggle[playerid];
}
