#include <YSI\y_hooks>

static Text3D: player_Nametag[MAX_PLAYERS] = {Text3D:INVALID_3DTEXT_ID, ...};

hook OnPlayerConnect(playerid)
{
	new name[24];
	GetPlayerName(playerid, name, 24);

    player_Nametag[playerid] = CreateDynamic3DTextLabel(
		name,
		0xB8B8B8FF,
		0.0,
		0.0,
		0.0,
		15.0,
		playerid,
		INVALID_VEHICLE_ID,
		-1
	);
	return 1;
}

hook OnPlayerDisconnect(playerid, reason)
{
	DestroyDynamic3DTextLabel(player_Nametag[playerid]);
	player_Nametag[playerid] = Text3D:INVALID_3DTEXT_ID;
	return 1;
}