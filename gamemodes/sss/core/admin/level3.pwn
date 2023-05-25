#include <YSI\y_hooks>


hook OnGameModeInit() {
	RegisterAdminCommand(STAFF_LEVEL_ADMINISTRATOR, ""C_BLUE"/comandoslvl3 - Ver a lista de comandos dos admins nível 3\n");
}

/*
ACMD:whitelist[3](playerid, params[])
{
	new
		command[7],
		name[MAX_PLAYER_NAME];

	if(sscanf(params, "s[7]S()[24]", command, name))
	{
		ChatMsg(playerid, YELLOW, " >  Use: /whitelist [add/remover/on/off/auto/lista] - A whitelist está atualmente %s (auto: %s)", IsWhitelistActive() ? ("on") : ("off"), IsWhitelistAuto() ? ("on") : ("off"));
		return 1;
	}

	if(!strcmp(command, "add", true))
	{
		if(isnull(name))
		{
			ChatMsg(playerid, YELLOW, " >  Use /whitelist add [nome]");
			return 1;
		}

		new result = AddNameToWhitelist(name);

		if(result == 1)
			ChatMsg(playerid, YELLOW, " >  Adicionado "C_BLUE"%s "C_YELLOW"na whitelist.", name);

		if(result == 0)
			ChatMsg(playerid, YELLOW, " >  Esse nome "C_ORANGE"já está "C_YELLOW"na whitelist.");

		if(result == -1)
			ChatMsg(playerid, RED, " >  Ocorreu um erro.");
	}
	else if(!strcmp(command, "remover", true))
	{
		if(isnull(name))
		{
			ChatMsg(playerid, YELLOW, " >  Use /whitelist remover [nome]");
			return 1;
		}

		new result = RemoveNameFromWhitelist(name);

		if(result == 1)
			ChatMsg(playerid, YELLOW, " >  Removido "C_BLUE"%s "C_YELLOW"da whitelist.", name);

		if(result == 0)
			ChatMsg(playerid, YELLOW, " >  Esse nome "C_ORANGE"não está "C_YELLOW"na whitelist.");

		if(result == -1)
			ChatMsg(playerid, RED, " >  Ocorreu um erro.");
	}
	else if(!strcmp(command, "on", true))
	{
		ChatMsgAdmins(1, YELLOW, " >  Whitelist ativada.");
		ToggleWhitelist(true);
	}
	else if(!strcmp(command, "off", true))
	{
		ChatMsgAdmins(1, YELLOW, " >  Whitelist desativada");
		ToggleWhitelist(false);
	}
	else if(!strcmp(command, "auto", true))
	{
		if(!IsWhitelistAuto())
		{
			ChatMsgAdmins(1, YELLOW, " >  Whitelist automática ativada.");
			ToggleAutoWhitelist(true);

			// UpdateSetting("whitelist-auto-toggle", 0);
		}
		else
		{
			ChatMsgAdmins(1, YELLOW, " >  Whitelist automática desativada.");
			ToggleAutoWhitelist(false);

			// UpdateSetting("whitelist-auto-toggle", 0);
		}
	}
	else if(!strcmp(command, "?", true))
	{
		if(IsNameInWhitelist(name))
			ChatMsg(playerid, YELLOW, " >  Esse nome "C_BLUE"está "C_YELLOW"na whitelist.");

		else
			ChatMsg(playerid, YELLOW, " >  Esse nome "C_ORANGE"não está "C_YELLOW"na whitelist");
	}
	else if(!strcmp(command, "lista", true))
	{
		new list[(MAX_PLAYER_NAME + 1) * MAX_PLAYERS];

		foreach(new i : Player)
		{
			GetPlayerName(i, name, MAX_PLAYER_NAME);
			format(list, sizeof(list), "%s%C%s\n", list, IsPlayerInWhitelist(i) ? (GREEN) : (RED), name);
		}

		ShowPlayerDialog(playerid, 10008, DIALOG_STYLE_MSGBOX, "Whitelisted players", list, "Close", "");
	}

	return 1;
}*/

ACMD:spec[3](playerid, params[])
{
	if(!(IsPlayerOnAdminDuty(playerid))) return CMD_NOT_DUTY;

	// If there's only one player, don't do anything
	if(Iter_Count(Player) == 1) return 1;

	if(isnull(params)) {
		if(IsPlayerSpectating(playerid))
			ExitSpectateMode(playerid); // If player is spectating, exit spectate mode
		else { // Select a random player to spectate
			new targetId;
			
			while(!IsPlayerConnected(targetId) || targetId == playerid) targetId = random(MAX_PLAYERS);

			EnterSpectateMode(playerid, targetId);
		}
	} else {
		new targetId = isnumeric(params) ? strval(params) : GetPlayerIDFromName(params);

		if(IsPlayerConnected(targetId) && targetId != playerid) {
			// Não pode observar admins
			if(GetPlayerAdminLevel(playerid) < 6 && GetPlayerAdminLevel(targetId) > 1) return CMD_CANT_USE_ON;

			EnterSpectateMode(playerid, targetId);

            ChatMsgAdmins(1, BLUE, "[Admin] %P"C_BLUE" (%d) está observando %P"C_BLUE" (%d)", playerid, playerid, targetId, targetId);
		}
	}

	return 1;
}

ACMD:free[3](playerid) {
	if(!IsPlayerOnAdminDuty(playerid)) return CMD_NOT_DUTY;

	if(GetPlayerSpectateType(playerid) == SPECTATE_TYPE_FREE) ExitFreeMode(playerid); else EnterFreeMode(playerid);

	return 1;
}

ACMD:recam[4](playerid, params[]) {
	SetCameraBehindPlayer(playerid);
	return 1;
}

ACMD:ip[3](playerid, params[]) {
	if(isnumeric(params)) {
		new targetId = strval(params);

		if(!IsPlayerConnected(targetId)) return ChatMsg(playerid, YELLOW, " >  O ID '%d' não está online, tente usar o nome do jogador.", targetId);

		ChatMsg(playerid, YELLOW, " >  IP de %P"C_YELLOW": %s", targetId, IpIntToStr(GetPlayerIpAsInt(targetId)));
	} else {
		if(!AccountExists(params)) return ChatMsg(playerid, YELLOW, " >  A conta '%s' não existe.", params);

		new ip;
		GetAccountIP(params, ip);

		ChatMsg(playerid, YELLOW, " >  IP de "C_BLUE"%s"C_YELLOW": %s", params, IpIntToStr(ip));
	}

	return 1;
}

ACMD:veiculo[3](playerid, params[]) {
	if(!IsPlayerOnAdminDuty(playerid) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET) return CMD_NOT_DUTY;

	new command[30], vehicleid;

	if(sscanf(params, "s[30]D(-1)", command, vehicleid)) 
		return ChatMsg(playerid, YELLOW, " >  Sintaxe: /veiculo [puxar, ir, entrar, deletar, reparar, respawnar, resetar, trancar, destrancar, removerchave, destruir] (id)");

	if(vehicleid == -1) vehicleid = GetPlayerVehicleID(playerid);

	if(!IsValidVehicle(vehicleid)) return ChatMsg(playerid, RED, "Tem que ou especificar um id de veiculo, ou estar dentro de um");

	if(isequal(command, "puxar", true)) {
		new Float:x, Float:y, Float:z;

		GetPlayerPos(playerid, x, y, z);
		PutPlayerInVehicle(playerid, vehicleid, 0);
		SetVehiclePos(vehicleid, x, y, z);
		SetPlayerPos(playerid, x, y, z + 2);
		SetCameraBehindPlayer(playerid);

		return 1;
	} else if(isequal(command, "ir", true)) {
		new Float:x, Float:y, Float:z;

		GetVehiclePos(vehicleid, x, y, z);
		SetPlayerPos(playerid, x, y, z);

		return 1;
	} else if(isequal(command, "entrar", true)) {
		PutPlayerInVehicle(playerid, vehicleid, 0);

		return 1;
	}
	else if(isequal(command, "deletar", true)) {
		DestroyWorldVehicle(vehicleid, true);

		return ChatMsg(playerid, YELLOW, " >  Veiculo %d deletado", vehicleid);
	} else if(isequal(command, "respawnar", true)) {
		RespawnVehicle(vehicleid);
		
		SaveVehicle(vehicleid);

		return ChatMsg(playerid, YELLOW, " >  Veiculo %d respawnado", vehicleid);
	} else if(isequal(command, "resetar", true)) {
		ResetVehicle(vehicleid);
		
		SaveVehicle(vehicleid);

		return ChatMsg(playerid, YELLOW, " >  Veiculo %d resetado", vehicleid);
	} else if(isequal(command, "trancar", true)) {
		SetVehicleExternalLock(vehicleid, E_LOCK_STATE_EXTERNAL);

		return ChatMsg(playerid, YELLOW, " >  Veiculo %d trancado", vehicleid);
	} else if(isequal(command, "destrancar", true)) {
		SetVehicleExternalLock(vehicleid, E_LOCK_STATE_OPEN);

		return ChatMsg(playerid, YELLOW, " >  Veiculo %d destrancado", vehicleid);
	} else if(isequal(command, "removerchave", true)) {
		SetVehicleKey(vehicleid, 0);

		return ChatMsg(playerid, YELLOW, " >  Removido a chave do veiculo %d", vehicleid);
	} else if(isequal(command, "destruir", true)) {
		SetVehicleHealth(vehicleid, 0.0);
		
		SaveVehicle(vehicleid);

		return ChatMsg(playerid, YELLOW, " >  Veiculo %d destruido", vehicleid);
	} else if(isequal(command, "reparar", true)) {// Reparar completamente o veiculo
		/* 
			Como o RepairVehicle coloca o Ve�culo com 1000.0 de vida,
			precisamos colocar 990.0 para não ser declarado como hack.
		 */
		// Primeiro removemos os jogadores do Ve�culo, para o servidor não os declarar como hack
		// Armazemos os jogadores em um array, para os colocarmos de volta depois
		new occupants[4] = {INVALID_PLAYER_ID, ...}; // 4 é o máximo de jogadores que podem estar em um Ve�culo
		
		foreach(new i : Player) {
			if(GetPlayerVehicleID(i) == vehicleid) {
				new seat = GetPlayerVehicleSeat(i);

				if(seat == -1) continue; // Se por alguma razão o jogador já não estiver mais no Ve�culo, continuamos

				occupants[seat] = i; // Armazenamos o jogador de acordo com a sua posição no Ve�culo

				RemovePlayerFromVehicle(i);
			}
		}

		RepairVehicle(vehicleid); // Repara a lataria
		SetVehicleHealth(vehicleid, 990.0); // Não podemos reparar o Ve�culo mais do que 990.0. Mais do que isso é hack.

		// Colocamos os jogadores de volta no Ve�culo
		for(new i = 0; i < sizeof(occupants); i++) {
			if(!IsPlayerConnected(occupants[i])) continue;

			CancelPlayerMovement(playerid); // ! Experimental. Como o jogador nessa altura ainda se encontra a sair do veiculo, não conseguimos colocá-lo de volta no Ve�culo no preciso momento.
			PutPlayerInVehicleTimed(occupants[i], vehicleid, i);
		}
		
		SaveVehicle(vehicleid);

		return ChatMsg(playerid, YELLOW, " >  Veiculo %d reparado", vehicleid);
	}

	return 1;
}

ACMD:move[3](playerid, params[])
{
	if(!IsPlayerOnAdminDuty(playerid) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET) return CMD_NOT_DUTY;

	new
		direction[10],
		Float:amount;

	if(!sscanf(params, "s[10]F(2.0)", direction, amount))
	{
		new Float:x, Float:y, Float:z, Float:r;

		GetPlayerPos(playerid, x, y, z);
		GetPlayerFacingAngle(playerid, r);

		if(direction[0] == 'f') // forwards
			x += amount * floatsin(-r, degrees), y += amount * floatcos(-r, degrees);

		if(direction[0] == 'b') // backwards
			x -= amount * floatsin(-r, degrees), y -= amount * floatcos(-r, degrees);

		if(direction[0] == 'u') // up
			z += amount;

		if(direction[0] == 'd') // down
			z -= amount;

		SetPlayerPos(playerid, x, y, z);

		return 1;
	}

	ChatMsg(playerid, YELLOW, " >  Use: /move [f/b/u/d] [distância]");
	ChatMsg(playerid, YELLOW, " >  F = frente, B = atrás, U = pra cima, D = pra baixo.");

	return 1;
}

ACMD:resetarsenha[3](playerid, params[])
{
	if(isnull(params)) return ChatMsg(playerid, YELLOW, " >  Use: /resetarsenha [Nick]");

	new buffer[129];

	WP_Hash(buffer, MAX_PASSWORD_LEN, "password");

	if(SetAccountPassword(params, buffer))
		ChatMsg(playerid, YELLOW, " >  A senha de '%s' foi resetada. Nova senha: password", params);
	else
		ChatMsg(playerid, RED, " >  Ocorreu um erro.");

	return 1;
}

ACMD:setactive[3](playerid, params[])
{
	new name[MAX_PLAYER_NAME], active;

	if(sscanf(params, "s[24]d", name, active)) return ChatMsg(playerid, YELLOW, " >  Use: /setactive [nick] [1/0] (1 = ativar, 0 = desativar)");

	if(!AccountExists(name)) return ChatMsg(playerid, RED, " >  Essa conta não existe.");

	ChatMsgAdmins(1, BLUE, "[Admin] %P (%d)"C_BLUE" %s a conta '%s'!", playerid, playerid, active ? ("ativou") : ("desativou"), name);

	SetAccountActiveState(name, active);

	ChatMsg(playerid, YELLOW, " >  Conta '%s' %s.", name, active ? ("Ativada") : ("Desativada"));

	return 1;
}

ACMD:irpos[3](playerid, params[])
{
    if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET) return CMD_NOT_DUTY;
		
	new Float:x, Float:y, Float:z;

	if(sscanf(params, "fff", x, y, z) && sscanf(params, "p<,>fff", x, y, z))
		return ChatMsg(playerid, YELLOW, " > Use: /irpos x, y, z (Com ou sem vírgulas)");

	SetPlayerPos(playerid, x, y, z);

	ChatMsgAdmins(1, BLUE, "[Admin] %P (%d)"C_BLUE" teleportou para "C_WHITE"%0.2f, %0.2f, %0.2f", playerid, playerid, x, y, z);

	return 1;
}

ACMD:banir[3](playerid, params[])
{
	new name[MAX_PLAYER_NAME];

	if(sscanf(params, "s[24]", name)) return ChatMsg(playerid, YELLOW, " >  Use: /banir [playerid/nome]");

	if(isnumeric(name))
	{
		new targetid = strval(name);

		if(IsPlayerConnected(targetid))
			GetPlayerName(targetid, name, MAX_PLAYER_NAME);
		else
			ChatMsg(playerid, YELLOW, " >  O ID '%d' não está online, tente usar o nome do jogador.", targetid);
	}

	if(!AccountExists(name)) return ChatMsg(playerid, YELLOW, " > a conta '%s' não existe.", name);

	if(GetAdminLevelByName(name) > STAFF_LEVEL_NONE) return 2;

	BanAndEnterInfo(playerid, name);

	ChatMsg(playerid, YELLOW, " >  Preparando banimento de: %s", name);

	return 1;
}

ACMD:desbanir[3](playerid, params[])
{
	new name[MAX_PLAYER_NAME];

	if(sscanf(params, "s[24]", name)) return ChatMsg(playerid, YELLOW, " >  Use: /desbanir [Nick]");

	if(UnBanPlayer(name))
		ChatMsg(playerid, YELLOW, " >  A conta "C_BLUE"%s"C_YELLOW" foi desbanida.", name);
	else
		ChatMsg(playerid, YELLOW, " >  A conta '%s' não está banida.");

	return 1;
}

ACMD:banidos[3](playerid, params[])
{
	new result = ShowListOfBans(playerid, 0);

	if(result == 0) return ChatMsg(playerid, YELLOW, " >  Não há nenhum player banido.");

	if(result == -1) return ChatMsg(playerid, YELLOW, " >  Ocorreu um erro.");

	return 1;
}

ACMD:sethp[3](playerid, params[]) {
	new targetId, hp;

	if(sscanf(params, "rD(100)", targetId, hp)) return ChatMsg(playerid, RED, " >  Use: /sethp [id/nick] (hp)");

	if(targetId == INVALID_PLAYER_ID) return 4;

	if(!IsPlayerLoggedIn(targetId)) return ChatMsg(playerid, RED, " >  O jogador não está logado.");

	if(hp < 0 || hp > 100) return ChatMsg(playerid, RED, " >  HP tem que ser entre 0 e 100.");

	SetPlayerHP(targetId, hp);

	printf("[ADMIN] %p (%d) setou a vida de %p (%d) para %d", playerid, playerid, targetId, targetId, hp);

	return ChatMsgAdmins(1, BLUE, "[Admin] %P (%d)"C_BLUE" setou a vida de %P (%d)"C_BLUE" para %d", playerid, playerid, targetId, targetId, hp);
}

ACMD:comandoslvl3[3](playerid) {
    new stringlvl3[800];
    strcat(stringlvl3, "{FFFF00}Comandos dos Admins Nível 3:\n");
    strcat(stringlvl3, "{FF0000}\n");
    strcat(stringlvl3, ""C_BLUE"/(des)congelar - Congelar/descongelar players\n");
    strcat(stringlvl3, ""C_BLUE"/(des)banir - Banir/desbanir players\n");
    strcat(stringlvl3, ""C_BLUE"/spec /free - Observar alguém, camera livre\n");
    strcat(stringlvl3, ""C_BLUE"/ip - Pegar ip de players\n");
    strcat(stringlvl3, ""C_BLUE"/veiculo - Controlar Ve�culos\n");
    strcat(stringlvl3, ""C_BLUE"/move - Mover-se\n");
    strcat(stringlvl3, ""C_BLUE"/irpos - Ir em uma determinada coordenada\n");
    strcat(stringlvl3, ""C_BLUE"/resetarsenha - Resetar senha de alguém (a senha nova será: 'password')\n");
    strcat(stringlvl3, ""C_BLUE"/setactive - ativar/desativar contas\n");
    strcat(stringlvl3, ""C_BLUE"/goto ou /tp - Ver os comandos de teleportes\n");
    strcat(stringlvl3, ""C_BLUE"/delreports - Apagar todos os reports enviados\n");
    ShowPlayerDialog(playerid, 12403, DIALOG_STYLE_MSGBOX, "Admin 3", stringlvl3, "Fechar", "");

    return 1;
}