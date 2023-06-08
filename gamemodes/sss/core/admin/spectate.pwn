#include <YSI\y_hooks>

enum {
	SPECTATE_TYPE_NONE,
	SPECTATE_TYPE_TARGET,
	SPECTATE_TYPE_FREE
}

static
			spectate_Type[MAX_PLAYERS],
			spectate_Target[MAX_PLAYERS],
			spectate_ClickTick[MAX_PLAYERS],
Timer:		spectate_Timer[MAX_PLAYERS],
PlayerText:	spectate_Name,
PlayerText:	spectate_Info,
			spectate_CameraObject[MAX_PLAYERS] = {INVALID_OBJECT_ID, ...},
Float:		spectate_StartPos[MAX_PLAYERS][3];


hook OnPlayerConnect(playerid) {
	spectate_Type[playerid]   = SPECTATE_TYPE_NONE;
	spectate_Target[playerid] = INVALID_PLAYER_ID;

	DestroyObject(spectate_CameraObject[playerid]);
	spectate_CameraObject[playerid] = INVALID_OBJECT_ID;
	stop spectate_Timer[playerid];

	spectate_Name						=CreatePlayerTextDraw(playerid, 320.000000, 365.000000, "[HLF]Southclaw");
	PlayerTextDrawAlignment			(playerid, spectate_Name, 2);
	PlayerTextDrawBackgroundColor	(playerid, spectate_Name, 255);
	PlayerTextDrawFont				(playerid, spectate_Name, 1);
	PlayerTextDrawLetterSize		(playerid, spectate_Name, 0.200000, 1.000000);
	PlayerTextDrawColor				(playerid, spectate_Name, -1);
	PlayerTextDrawSetOutline		(playerid, spectate_Name, 0);
	PlayerTextDrawSetProportional	(playerid, spectate_Name, 1);
	PlayerTextDrawSetShadow			(playerid, spectate_Name, 1);
	PlayerTextDrawUseBox			(playerid, spectate_Name, 1);
	PlayerTextDrawBoxColor			(playerid, spectate_Name, 255);
	PlayerTextDrawTextSize			(playerid, spectate_Name, 100.000000, 340.000000);

	spectate_Info						=CreatePlayerTextDraw(playerid, 320.000000, 380.000000, "Is awesome");
	PlayerTextDrawAlignment			(playerid, spectate_Info, 2);
	PlayerTextDrawBackgroundColor	(playerid, spectate_Info, 255);
	PlayerTextDrawFont				(playerid, spectate_Info, 1);
	PlayerTextDrawLetterSize		(playerid, spectate_Info, 0.200000, 1.000000);
	PlayerTextDrawColor				(playerid, spectate_Info, -1);
	PlayerTextDrawSetOutline		(playerid, spectate_Info, 0);
	PlayerTextDrawSetProportional	(playerid, spectate_Info, 1);
	PlayerTextDrawSetShadow			(playerid, spectate_Info, 1);
	PlayerTextDrawUseBox			(playerid, spectate_Info, 1);
	PlayerTextDrawBoxColor			(playerid, spectate_Info, 255);
	PlayerTextDrawTextSize			(playerid, spectate_Info, 100.000000, 340.000000);
}

hook OnPlayerDisconnect(playerid) {
	if(spectate_Type[playerid] != SPECTATE_TYPE_NONE) ExitSpectateMode(playerid);

	foreach(new admin : Player) {
		if(spectate_Target[admin] != playerid) continue;

		ChatMsg(admin, YELLOW, "[SPECTATE] Você estava vendo %p, mas ele saiu.", playerid);
		printf("[SPECTATE] %p estava vendo %p, quando ele saiu.", admin, playerid);

		if(Iter_Count(Player) > 1) SpectateNextTarget(admin); else ExitSpectateMode(admin);
	}

	return 1;
}

EnterSpectateMode(playerid, targetId) {
	if(!IsPlayerConnected(targetId)) return 0;

	if(spectate_Type[playerid] == SPECTATE_TYPE_FREE) ExitFreeMode(playerid);

	// Salva a posicao inicial
	GetPlayerPos(playerid, spectate_StartPos[playerid][0], spectate_StartPos[playerid][1], spectate_StartPos[playerid][2]);

	TogglePlayerSpectating(playerid, true);

	spectate_Type[playerid]   = SPECTATE_TYPE_TARGET;
	spectate_Target[playerid] = targetId;

	_RefreshSpectate(playerid);

	PlayerTextDrawShow(playerid, spectate_Name);
	PlayerTextDrawShow(playerid, spectate_Info);

	stop spectate_Timer[playerid];
	spectate_Timer[playerid] = repeat UpdateSpectateMode(playerid);

	log("[ESPECTADOR] %p está espectando %p", playerid, targetId);

	return 1;
}

IsPlayerSpectating(playerid) return spectate_Type[playerid] != SPECTATE_TYPE_NONE;

EnterFreeMode(playerid, Float:camX = 0.0, Float:camY = 0.0, Float:camZ = 0.0) {
	if(camX * camY * camZ == 0.0) GetPlayerCameraPos(playerid, camX, camY, camZ);

	spectate_Type[playerid] = SPECTATE_TYPE_FREE;
	TogglePlayerControllable(playerid, true);

	DestroyObject(spectate_CameraObject[playerid]);
	spectate_CameraObject[playerid] = CreateObject(19300, camX, camY, camZ, 0.0, 0.0, 0.0);
	TogglePlayerSpectating(playerid, false); // ? Porque?
	TogglePlayerSpectating(playerid, true);
	AttachCameraToObject(playerid, spectate_CameraObject[playerid]);
	GetPlayerPos(playerid, spectate_StartPos[playerid][0], spectate_StartPos[playerid][1], spectate_StartPos[playerid][2]);
	spectate_Timer[playerid] = repeat UpdateSpectateMode(playerid);
}

ExitFreeMode(playerid) {
	if(spectate_Type[playerid] == SPECTATE_TYPE_TARGET) ExitSpectateMode(playerid);

	spectate_Target[playerid] = INVALID_PLAYER_ID;
	spectate_Type[playerid]   = SPECTATE_TYPE_NONE;

	DestroyObject(spectate_CameraObject[playerid]);
	spectate_CameraObject[playerid] = INVALID_OBJECT_ID;

	TogglePlayerSpectating(playerid, false);
	stop spectate_Timer[playerid];

	defer ReturnToStartPosition(playerid);

	return 1;
}

ExitSpectateMode(playerid) {
	if(spectate_Target[playerid] == INVALID_PLAYER_ID) return 0;

	if(spectate_Type[playerid] == SPECTATE_TYPE_FREE) ExitFreeMode(playerid);

	spectate_Target[playerid] = INVALID_PLAYER_ID;
	spectate_Type[playerid]   = SPECTATE_TYPE_NONE;

	PlayerTextDrawHide(playerid, spectate_Name);
	PlayerTextDrawHide(playerid, spectate_Info);

	TogglePlayerSpectating(playerid, false);
	stop spectate_Timer[playerid];

	defer ReturnToStartPosition(playerid);

	return 1;
}

static timer ReturnToStartPosition[250](playerid) {
	if(!IsPlayerOnAdminDuty(playerid)) return;

	SetPlayerPos(playerid, spectate_StartPos[playerid][0], spectate_StartPos[playerid][1], spectate_StartPos[playerid][2]);

	SetPlayerSkin(playerid, isequal(GetPlayerNameEx(playerid), "VIRUXE") ? 303 : (GetPlayerGender(playerid) == GENDER_MALE ? 217 : 211));
}

SpectateNextTarget(playerid) {
	new id = spectate_Target[playerid] + 1, iters;

	if(id == MAX_PLAYERS) id = 0;

	while(id < MAX_PLAYERS && iters <= MAX_PLAYERS) {
		iters++;

		if(!CanPlayerSpectate(playerid, id)) {
			id++;

			if(id >= MAX_PLAYERS - 1) id = 0;

			continue;
		}

		break;
	}

	spectate_Target[playerid] = id;
	_RefreshSpectate(playerid);
}

SpectatePrevTarget(playerid) {
	new id = spectate_Target[playerid] - 1, iters;

	if(id < 0) id = MAX_PLAYERS-1;

	while(id >= 0 && iters <= MAX_PLAYERS) {
		iters++;

		if(!CanPlayerSpectate(playerid, id)) {
			id--;

			if(id < 0) id = MAX_PLAYERS - 1;

			continue;
		}

		break;
	}

	spectate_Target[playerid] = id;
	_RefreshSpectate(playerid);
}

_RefreshSpectate(playerid) {
	if(spectate_Type[playerid] == SPECTATE_TYPE_TARGET) {
		SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(spectate_Target[playerid]));
		SetPlayerInterior(playerid, GetPlayerInterior(spectate_Target[playerid]));

		if(IsPlayerInAnyVehicle(spectate_Target[playerid]))
			PlayerSpectateVehicle(playerid, GetPlayerVehicleID(spectate_Target[playerid]));
		else
			PlayerSpectatePlayer(playerid, spectate_Target[playerid]);
	} else if(spectate_Type[playerid] == SPECTATE_TYPE_FREE) {
		new Float:x, Float:y, Float:z;

		GetPlayerPos(spectate_Target[playerid], x, y, z);

		SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(spectate_Target[playerid]));
		SetPlayerInterior(playerid, GetPlayerInterior(spectate_Target[playerid]));
		SetObjectPos(spectate_CameraObject[playerid], x, y, z + 1.0);
		AttachCameraToObject(playerid, spectate_CameraObject[playerid]);
	}
}

timer UpdateSpectateMode[100](playerid) {
	if(spectate_Type[playerid] == SPECTATE_TYPE_NONE) {
		stop spectate_Timer[playerid];
		return;
	}

	new targetId = spectate_Target[playerid];

	if(targetId == INVALID_PLAYER_ID) {
		new
			k,
			ud,
			lr,
			Float:camX,Float:camY,Float:camZ,
			Float:vecX, Float:vecY, Float:vecZ,
			Float:speed = 10.0;

		GetPlayerKeys(playerid, k, ud, lr);
		GetPlayerCameraPos(playerid, camX, camY, camZ);
		GetPlayerCameraFrontVector(playerid, vecX, vecY, vecZ);

		if(k & KEY_JUMP) speed = 50.0;
		if(k & KEY_WALK) speed = 0.5;

		// ? Isso nao deveria ser else if?
		if(ud == KEY_UP) {
			camX += vecX * 100;
			camY += vecY * 100;
			camZ += vecZ * 100;
		}
		if(ud == KEY_DOWN) {
			camX -= vecX * 100;
			camY -= vecY * 100;
			camZ -= vecZ * 100;
		}
		if(lr == KEY_RIGHT) {
			new Float:rotation = -(atan2(vecY, vecX) - 90.0);

			camX += (100 * floatsin(rotation + 90.0, degrees));
			camY += (100 * floatcos(rotation + 90.0, degrees));
		}
		if(lr == KEY_LEFT) {
			new Float:rotation = -(atan2(vecY, vecX) - 90.0);

			camX += (100 * floatsin(rotation - 90.0, degrees));
			camY += (100 * floatcos(rotation - 90.0, degrees));
		}
		if(k & KEY_SPRINT) camZ += 100.0;
		if(k & KEY_CROUCH) camZ -= 100.0;

		MoveObject(spectate_CameraObject[playerid], camX, camY, camZ, speed);

		if(ud == 0 && lr == 0 && !(k & KEY_SPRINT) && !(k & KEY_CROUCH))
			StopObject(spectate_CameraObject[playerid]);
	} else {
		new
			name[MAX_PLAYER_NAME],
			title[MAX_PLAYER_NAME + 6],
			str[256];

		new langId = GetPlayerLanguage(playerid);

		if(!IsPlayerHudOn(playerid)) {
			PlayerTextDrawHide(playerid, spectate_Info);
			return;
		}

		if(IsPlayerInAnyVehicle(targetId)) {
			new
				itemName[ITM_MAX_NAME + ITM_MAX_TEXT],
				cameraModeName[37];

			if(!GetItemName(GetPlayerItem(targetId), langId, itemName)) itemName = "Nenhum";

			GetCameraModeName(GetPlayerCameraMode(targetId), cameraModeName);

			format(str, sizeof(str), "Vida: %.2f Colete: %.2f Fome: %.2f Int: %d VW: %d~n~\
				Caido: %s Sangramento: %.2f Item: %s~n~\
				Camera: %s Velocidade: %.2f~n~\
				Veiculo %d Como %s Gasolina: %.2f Trancado: %d",
				GetPlayerHP(targetId),
				GetPlayerAP(targetId),
				GetPlayerFP(targetId),
				GetPlayerInterior(targetId),
				GetPlayerVirtualWorld(targetId),
				IsPlayerKnockedOut(targetId) ? MsToString(GetPlayerKnockOutRemainder(targetId), "%1m:%1s") : ("Nao"),
				GetPlayerBleedRate(targetId),
				itemName,
				cameraModeName,
				GetPlayerTotalVelocity(targetId),
				GetPlayerLastVehicle(targetId),
				GetPlayerState(targetId) == PLAYER_STATE_DRIVER ? "Motorista" : "Passageiro",
				GetVehicleFuel(GetPlayerLastVehicle(targetId)),
				_:GetVehicleLockState(GetPlayerLastVehicle(targetId)));
		} else {
			new
				itemName[ITM_MAX_NAME + ITM_MAX_TEXT],
				holsterItemName[32],
				cameraModeName[37],
				Float:vx, Float:vy, Float:vz,
				Float:velocity;

			if(!GetItemName(GetPlayerItem(targetId), langId, itemName)) itemName = "Nenhum";

			if(!GetItemName(GetPlayerHolsterItem(targetId), langId, holsterItemName)) holsterItemName = "Nenhum";

			GetCameraModeName(GetPlayerCameraMode(targetId), cameraModeName);
			GetPlayerVelocity(targetId, vx, vy, vz);

			velocity = floatsqroot( (vx*vx)+(vy*vy)+(vz*vz) ) * 150.0;

			format(str, sizeof(str), "Vida: %.2f Colete: %.2f Fome: %.2f Int: %d VW: %d~n~\
				Caido: %s Sangramento: %.2f Camera: %s Velocidade: %.2f~n~\
				Item: %s Coldre: %s",
				GetPlayerHP(targetId),
				GetPlayerAP(targetId),
				GetPlayerFP(targetId),
				GetPlayerInterior(targetId),
				GetPlayerVirtualWorld(targetId),
				IsPlayerKnockedOut(targetId) ? MsToString(GetPlayerKnockOutRemainder(targetId), "%1m:%1s") : ("Não"),
				GetPlayerBleedRate(targetId),
				cameraModeName,
				velocity,
				itemName,
				holsterItemName);
		}

		GetPlayerName(targetId, name, MAX_PLAYER_NAME);

		format(title, sizeof(title), "%s (%d)", name, targetId);

		PlayerTextDrawSetString(playerid, spectate_Name, title);
		PlayerTextDrawSetString(playerid, spectate_Info, str);
		PlayerTextDrawShow(playerid, spectate_Info);
	}
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	if(spectate_Target[playerid] != INVALID_PLAYER_ID) {
		if(GetTickCountDifference(GetTickCount(), spectate_ClickTick[playerid]) < 1000) return 1;

		spectate_ClickTick[playerid] = GetTickCount();

		if(newkeys == 128) 
			SpectateNextTarget(playerid);
		else if(newkeys == 4) 
			SpectatePrevTarget(playerid);
		else if(newkeys == 512) 
			EnterSpectateMode(playerid, spectate_Target[playerid]);
	}

	return 1;
}

CanPlayerSpectate(playerid, targetId) {
	if(targetId == playerid || !IsPlayerConnected(targetId) || !(IsPlayerSpawned(targetId)) || GetPlayerState(targetId) == PLAYER_STATE_SPECTATING) return 0;

	// Permitir spec para admins lvl 1 apenas se o jogador foi reportado
	if(GetPlayerAdminLevel(playerid) == 1 && !IsPlayerReported(GetPlayerNameEx(playerid))) return 0;

	return 1;
}

GetPlayerSpectateTarget(playerid) return !IsPlayerConnected(playerid) ? INVALID_PLAYER_ID : spectate_Target[playerid];

GetPlayerSpectateType(playerid) return !IsPlayerConnected(playerid) ? -1 : spectate_Type[playerid];

ACMD:freezecam[2](playerid) {
	if(!IsPlayerOnAdminDuty(playerid)) return CMD_NOT_DUTY;

	new Float:camX, Float:camY, Float:camZ, Float:vecX, Float:vecY, Float:vecZ;

	GetPlayerCameraPos(playerid, camX, camY, camZ);
	GetPlayerCameraFrontVector(playerid, vecX, vecY, vecZ);

	SetPlayerCameraPos(playerid, camX, camY, camZ);
	SetPlayerCameraLookAt(playerid, camX+vecX, camY+vecY, camZ+vecZ);
	
	return 1;
}
