#include <YSI\y_hooks>

hook OnGameModeInit() {
	RegisterAdminCommand(LEVEL_ADMINISTRATOR, "(des)congelar", "Congelar/descongelar players");
    RegisterAdminCommand(LEVEL_ADMINISTRATOR, "(des)banir", "Banir/desbanir players");
    RegisterAdminCommand(LEVEL_ADMINISTRATOR, "delreports", "Apagar todos os reports enviados");
    RegisterAdminCommand(LEVEL_ADMINISTRATOR, "goto/tp", "Ver os comandos de teleportes");
    RegisterAdminCommand(LEVEL_ADMINISTRATOR, "irpos", "Ir em uma determinada coordenada");
    RegisterAdminCommand(LEVEL_ADMINISTRATOR, "move", "Para mover no mundo");
    RegisterAdminCommand(LEVEL_ADMINISTRATOR, "recam", "Da reset na camara depois de /free");
    RegisterAdminCommand(LEVEL_ADMINISTRATOR, "resetarsenha", "Resetar senha de alguém (a senha nova será: 'password')");
    RegisterAdminCommand(LEVEL_ADMINISTRATOR, "setactive", "ativar/desativar contas");
    RegisterAdminCommand(LEVEL_ADMINISTRATOR, "sethp", "Define a vida de um jogador");
    RegisterAdminCommand(LEVEL_ADMINISTRATOR, "spec/free", "Observar alguém, camera livre");
    RegisterAdminCommand(LEVEL_ADMINISTRATOR, "veiculo/veh", "Controlar Veículos");
}

/*
ACMD:whitelist[2](playerid, params[]) {
	new
		command[7],
		name[MAX_PLAYER_NAME];

	if(sscanf(params, "s[7]S()[24]", command, name)) {
		ChatMsg(playerid, YELLOW, " >  Use: /whitelist [add/remover/on/off/auto/lista] - A whitelist está atualmente %s (auto: %s)", IsWhitelistActive() ? ("on") : ("off"), IsWhitelistAuto() ? ("on") : ("off"));
		return 1;
	}

	if(!strcmp(command, "add", true)) {
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
	else if(!strcmp(command, "remover", true)) {
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
	else if(!strcmp(command, "on", true)) {
		ChatMsgAdmins(1, YELLOW, " >  Whitelist ativada.");
		ToggleWhitelist(true);
	}
	else if(!strcmp(command, "off", true)) {
		ChatMsgAdmins(1, YELLOW, " >  Whitelist desativada");
		ToggleWhitelist(false);
	}
	else if(!strcmp(command, "auto", true)) {
		if(!IsWhitelistAuto())
		{
			ChatMsgAdmins(1, YELLOW, " >  Whitelist automÃ¡tica ativada.");
			ToggleAutoWhitelist(true);

			// UpdateSetting("whitelist-auto-toggle", 0);
		}
		else
		{
			ChatMsgAdmins(1, YELLOW, " >  Whitelist automÃ¡tica desativada.");
			ToggleAutoWhitelist(false);

			// UpdateSetting("whitelist-auto-toggle", 0);
		}
	}
	else if(!strcmp(command, "?", true)) {
		if(IsNameInWhitelist(name))
			ChatMsg(playerid, YELLOW, " >  Esse nome "C_BLUE"está "C_YELLOW"na whitelist.");

		else
			ChatMsg(playerid, YELLOW, " >  Esse nome "C_ORANGE"não está "C_YELLOW"na whitelist");
	}
	else if(!strcmp(command, "lista", true)) {
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

ACMD:spec[2](playerid, params[]) {
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

ACMD:free[2](playerid) {
	if(!IsPlayerOnAdminDuty(playerid)) return CMD_NOT_DUTY;

	// TODO: Adicionar opcao para coordenada
	if(GetPlayerSpectateType(playerid) == SPECTATE_TYPE_FREE) ExitFreeMode(playerid); else EnterFreeMode(playerid);

	return 1;
}

ACMD:recam[4](playerid, params[]) {
	SetCameraBehindPlayer(playerid);
	return 1;
}

ACMD:veiculo[2](playerid, params[]) {
	if(!IsPlayerOnAdminDuty(playerid) && GetPlayerAdminLevel(playerid) < LEVEL_LEAD) return CMD_NOT_DUTY;

	new command[30], vehicleId;

	if(sscanf(params, "s[30]D(-1)", command, vehicleId)) 
		return ChatMsg(playerid, YELLOW, " >  Sintaxe: /veiculo [puxar, ir, entrar, deletar, reparar, respawnar, resetar, trancar, destrancar, removerchave, destruir] (id)");

	if(vehicleId == -1) vehicleId = GetPlayerVehicleID(playerid);

	if(!IsValidVehicle(vehicleId)) return ChatMsg(playerid, RED, "Tem que ou especificar um id de veiculo, ou estar dentro de um");

	if(isequal(command, "puxar", true)) {
		new Float:x, Float:y, Float:z;

		GetPlayerPos(playerid, x, y, z);
		PutPlayerInVehicle(playerid, vehicleId, 0);
		SetVehiclePos(vehicleId, x, y, z);
		SetPlayerPos(playerid, x, y, z + 2);
		SetCameraBehindPlayer(playerid);

		return 1;
	} else if(isequal(command, "ir", true)) {
		new Float:x, Float:y, Float:z;

		GetVehiclePos(vehicleId, x, y, z);
		SetPlayerPos(playerid, x, y, z);

		return 1;
	} else if(isequal(command, "entrar", true)) {
		PutPlayerInVehicle(playerid, vehicleId, 0);

		return 1;
	} else if(isequal(command, "deletar", true)) {
		DestroyWorldVehicle(vehicleId, true);

		return ChatMsg(playerid, YELLOW, " >  Veiculo %d deletado", vehicleId);
	} else if(isequal(command, "respawnar", true)) {
		RespawnVehicle(vehicleId);
		
		SaveVehicle(vehicleId);

		return ChatMsg(playerid, YELLOW, " >  Veiculo %d respawnado", vehicleId);
	} else if(isequal(command, "resetar", true)) {
		ResetVehicle(vehicleId);
		
		SaveVehicle(vehicleId);

		return ChatMsg(playerid, YELLOW, " >  Veiculo %d resetado", vehicleId);
	} else if(isequal(command, "trancar", true)) {
		SetVehicleExternalLock(vehicleId, E_LOCK_STATE_EXTERNAL);

		return ChatMsg(playerid, YELLOW, " >  Veiculo %d trancado", vehicleId);
	} else if(isequal(command, "destrancar", true)) {
		SetVehicleExternalLock(vehicleId, E_LOCK_STATE_OPEN);

		return ChatMsg(playerid, YELLOW, " >  Veiculo %d destrancado", vehicleId);
	} else if(isequal(command, "removerchave", true)) {
		SetVehicleKey(vehicleId, 0);

		return ChatMsg(playerid, YELLOW, " >  Removido a chave do veiculo %d", vehicleId);
	} else if(isequal(command, "destruir", true)) {
		SetVehicleHealth(vehicleId, 0.0);
		
		SaveVehicle(vehicleId);

		return ChatMsg(playerid, YELLOW, " >  Veiculo %d destruido", vehicleId);
	} else if(isequal(command, "reparar", true)) { // Reparar completamente o veiculo
		/* 
			Como o RepairVehicle coloca o Veículo com 1000.0 de vida,
			precisamos colocar 990.0 para não ser declarado como hack.
		 */
		// Primeiro removemos os jogadores do Veículo, para o servidor não os declarar como hack
		// Armazemos os jogadores em um array, para os colocarmos de volta depois
		new occupants[4] = {INVALID_PLAYER_ID, ...}; // 4 é o máximo de jogadores que podem estar em um Veículo
		
		foreach(new i : Player) {
			if(GetPlayerVehicleID(i) == vehicleId) {
				new seat = GetPlayerVehicleSeat(i);

				if(seat == -1) continue; // Se por alguma razÃ£o o jogador já não estiver mais no Veículo, continuamos

				occupants[seat] = i; // Armazenamos o jogador de acordo com a sua Posição no Veículo

				RemovePlayerFromVehicle(i);
			}
		}

		RepairVehicle(vehicleId); // Repara a lataria
		SetVehicleHealth(vehicleId, 990.0); // Não podemos reparar o Veículo mais do que 990.0. Mais do que isso é hack.

		// Colocamos os jogadores de volta no Veículo
		for(new i = 0; i < sizeof(occupants); i++) {
			if(!IsPlayerConnected(occupants[i])) continue;

			CancelPlayerMovement(playerid); // ! Experimental. Como o jogador nessa altura ainda se encontra a sair do veiculo, não conseguimos colocÃ¡-lo de volta no Veículo no preciso momento.
			defer PutPlayerInVehicleTimed(occupants[i], vehicleId, i);
		}
		
		SaveVehicle(vehicleId);

		return ChatMsg(playerid, YELLOW, " >  Veiculo %d reparado", vehicleId);
	}

	return 1;
}
ACMD:veh[2](playerid, params[]) return acmd_veiculo_2(playerid, params);

ACMD:move[2](playerid, params[]) {
	if(!IsPlayerOnAdminDuty(playerid) && GetPlayerAdminLevel(playerid) < LEVEL_LEAD) return CMD_NOT_DUTY;

	new
		direction[10],
		Float:amount;

	if(!sscanf(params, "s[10]F(2.0)", direction, amount)) {
		new Float:x, Float:y, Float:z, Float:r;

		GetPlayerPos(playerid, x, y, z);
		GetPlayerFacingAngle(playerid, r);

		if(direction[0] == 'f') // forwards
			x += amount * floatsin(-r, degrees), y += amount * floatcos(-r, degrees);
		else if(direction[0] == 'b') // backwards
			x -= amount * floatsin(-r, degrees), y -= amount * floatcos(-r, degrees);
		else if(direction[0] == 'u') // up
			z += amount;
		else if(direction[0] == 'd') // down
			z -= amount;

		SetPlayerPos(playerid, x, y, z);

		return 1;
	}

	ChatMsg(playerid, YELLOW, " >  Use: /move [f/b/u/d] [distância]");
	ChatMsg(playerid, YELLOW, " >  F = frente, B = atrÃ¡s, U = pra cima, D = pra baixo.");

	return 1;
}

ACMD:resetarsenha[2](playerid, params[]) {
	if(isnull(params)) return ChatMsg(playerid, YELLOW, " >  Use: /resetarsenha [Nick]");

	new buffer[129];

	WP_Hash(buffer, MAX_PASSWORD_LEN, "password");

	if(SetAccountPassword(params, buffer))
		ChatMsg(playerid, YELLOW, " >  A senha de '%s' foi resetada. Nova senha: password", params);
	else
		ChatMsg(playerid, RED, " >  Ocorreu um erro.");

	return 1;
}

ACMD:setactive[2](playerid, params[]) {
	new name[MAX_PLAYER_NAME], active;

	if(sscanf(params, "s[24]d", name, active)) return ChatMsg(playerid, YELLOW, " >  Use: /setactive [nick] [1/0] (1 = ativar, 0 = desativar)");

	if(!AccountExists(name)) return ChatMsg(playerid, RED, " >  Essa conta não existe.");

	ChatMsgAdmins(1, BLUE, "[Admin] %P (%d)"C_BLUE" %s a conta '%s'!", playerid, playerid, active ? ("ativou") : ("desativou"), name);

	SetAccountActiveState(name, active);

	ChatMsg(playerid, YELLOW, " >  Conta '%s' %s.", name, active ? ("Ativada") : ("Desativada"));

	return 1;
}

ACMD:irpos[2](playerid, params[]) {
    if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < LEVEL_LEAD) return CMD_NOT_DUTY;
		
	new Float:x, Float:y, Float:z;

	if(sscanf(params, "fff", x, y, z) && sscanf(params, "p<,>fff", x, y, z))
		return ChatMsg(playerid, YELLOW, " > Use: /irpos x, y, z (Com ou sem vírgulas)");

	SetPlayerPos(playerid, x, y, z);

	ChatMsgAdmins(1, BLUE, "[Admin] %P (%d)"C_BLUE" teleportou para "C_WHITE"%0.2f, %0.2f, %0.2f", playerid, playerid, x, y, z);

	return 1;
}

ACMD:banir[2](playerid, params[]) {
	new name[MAX_PLAYER_NAME];

	if(sscanf(params, "s[24]", name)) return ChatMsg(playerid, YELLOW, " >  Use: /banir [playerid/nome]");

	if(isnumeric(name)) {
		new targetId = strval(name);

		if(IsPlayerConnected(targetId))
			GetPlayerName(targetId, name, MAX_PLAYER_NAME);
		else
			ChatMsg(playerid, YELLOW, " >  O ID '%d' não está online, tente usar o nome do jogador.", targetId);
	}

	if(!AccountExists(name)) return ChatMsg(playerid, YELLOW, " > a conta '%s' não existe.", name);

	if(GetAdminLevelByName(name) > LEVEL_NONE) return 2;

	BanAndEnterInfo(playerid, name);

	return 1;
}

ACMD:desbanir[2](playerid, params[]) {
	new name[MAX_PLAYER_NAME];

	if(sscanf(params, "s[24]", name)) return ChatMsg(playerid, YELLOW, " >  Use: /desbanir [Nick]");

	if(UnBanPlayer(name))
		ChatMsg(playerid, YELLOW, " >  A conta "C_BLUE"%s"C_YELLOW" foi desbanida.", name);
	else
		ChatMsg(playerid, YELLOW, " >  A conta '%s' não está banida.");

	return 1;
}

ACMD:banidos[2](playerid, params[]) {
	new result = ShowListOfBans(playerid, 0);

	if(result == 0) return ChatMsg(playerid, YELLOW, " >  Não há nenhum player banido.");
	if(result == -1) return ChatMsg(playerid, YELLOW, " >  Ocorreu um erro.");

	return 1;
}

ACMD:sethp[2](playerid, params[]) {
	new targetId, hp;

	if(sscanf(params, "rD(100)", targetId, hp)) return ChatMsg(playerid, RED, " >  Use: /sethp [id/nick] (hp)");

	if(targetId == INVALID_PLAYER_ID) return 4;

	if(!IsPlayerLoggedIn(targetId)) return ChatMsg(playerid, RED, " >  O jogador não está logado.");

	if(hp < 0 || hp > 100) return ChatMsg(playerid, RED, " >  HP tem que ser entre 0 e 100.");

	SetPlayerHP(targetId, hp);

	printf("[ADMIN] %p (%d) setou a vida de %p (%d) para %d", playerid, playerid, targetId, targetId, hp);

	return ChatMsgAdmins(1, BLUE, "[Admin] %P (%d)"C_BLUE" setou a vida de %P (%d)"C_BLUE" para %d", playerid, playerid, targetId, targetId, hp);
}