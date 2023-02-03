#include <YSI\y_hooks>


hook OnGameModeInit()
{
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
	if(!(IsPlayerOnAdminDuty(playerid)))
		return 6;

	if(isnull(params)){
		ExitSpectateMode(playerid);
	}
	else{
		new targetid = strval(params);

		if(IsPlayerConnected(targetid) && targetid != playerid){
			if(GetPlayerAdminLevel(playerid) < 6){
				new name[MAX_PLAYER_NAME];
				GetPlayerName(targetid, name, MAX_PLAYER_NAME);
				if(GetPlayerAdminLevel(targetid) > 1){
				    ChatMsg(playerid, YELLOW, " >  Você não pode fazer isto neste player.");
					return 1;
				}
			}
            ChatMsgAdmins(1, BLUE, "[Admin-Log] "C_BLUE"%p(id:%d) Está observando "C_BLUE"%p(id:%d)", playerid, playerid, targetid, targetid);
			EnterSpectateMode(playerid, targetid);
		}
	}

	return 1;
}

ACMD:free[3](playerid)
{
	if(!IsPlayerOnAdminDuty(playerid))
		return 6;

	if(GetPlayerSpectateType(playerid) == SPECTATE_TYPE_FREE)
		ExitFreeMode(playerid);

	else
		EnterFreeMode(playerid);

	return 1;
}

/*ACMD:recam[4](playerid, params[])
{
	SetCameraBehindPlayer(playerid);
	return 1;
}*/

ACMD:ip[3](playerid, params[])
{
	if(isnumeric(params))
	{
		new targetid = strval(params);

		if(!IsPlayerConnected(targetid))
		{
			if(targetid > 99)
				ChatMsg(playerid, YELLOW, " >  O ID '%d' não está online, tente usar o nome do jogador.", targetid);

			else
				return 4;
		}

		ChatMsg(playerid, YELLOW, " >  IP de %P"C_YELLOW": %s", targetid, IpIntToStr(GetPlayerIpAsInt(targetid)));
	}
	else
	{
		if(!AccountExists(params))
		{
			ChatMsg(playerid, YELLOW, " >  A conta '%s' não existe.", params);
			return 1;
		}

		new ip;

		GetAccountIP(params, ip);

		ChatMsg(playerid, YELLOW, " >  IP de "C_BLUE"%s"C_YELLOW": %s", params, IpIntToStr(ip));
	}

	return 1;
}

ACMD:veiculo[3](playerid, params[])
{
	if(!IsPlayerOnAdminDuty(playerid) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET)
		return 6;

	new
		command[30],
		vehicleid;

	if(sscanf(params, "s[30]D(-1)", command, vehicleid))
	{
		ChatMsg(playerid, YELLOW, " >  Use: /veiculo [puxar/ir/entrar/deletar/respawnar/resetar/trancar/destrancar/removerchave/destruir] [id]");
		return 1;
	}

	if(vehicleid == -1)
		vehicleid = GetPlayerVehicleID(playerid);

	if(!IsValidVehicle(vehicleid))
		return 4;

	if(!strcmp(command, "puxar"))
	{
		new
			Float:x,
			Float:y,
			Float:z;

		GetPlayerPos(playerid, x, y, z);
		PutPlayerInVehicle(playerid, vehicleid, 0);
		SetVehiclePos(vehicleid, x, y, z);
		SetPlayerPos(playerid, x, y, z + 2);
		SetCameraBehindPlayer(playerid);

		return 1;
	}

	if(!strcmp(command, "ir"))
	{
		new
			Float:x,
			Float:y,
			Float:z;

		GetVehiclePos(vehicleid, x, y, z);
		SetPlayerPos(playerid, x, y, z);

		return 1;
	}

	if(!strcmp(command, "entrar"))
	{
		PutPlayerInVehicle(playerid, vehicleid, 0);

		return 1;
	}

	if(!strcmp(command, "deletar"))
	{
		DestroyWorldVehicle(vehicleid, true);

		ChatMsg(playerid, YELLOW, " >  Veiculo %d deletado", vehicleid);

		return 1;
	}

	if(!strcmp(command, "respawnar"))
	{
		RespawnVehicle(vehicleid);
		
		SaveVehicle(vehicleid);

		ChatMsg(playerid, YELLOW, " >  Veiculo %d respawnado", vehicleid);

		return 1;
	}

	if(!strcmp(command, "resetar"))
	{
		ResetVehicle(vehicleid);
		
		SaveVehicle(vehicleid);

		ChatMsg(playerid, YELLOW, " >  Veiculo %d resetado", vehicleid);

		return 1;
	}

	if(!strcmp(command, "trancar"))
	{
		SetVehicleExternalLock(vehicleid, E_LOCK_STATE_EXTERNAL);

		ChatMsg(playerid, YELLOW, " >  Veiculo %d trancado", vehicleid);

		return 1;
	}

	if(!strcmp(command, "destrancar"))
	{
		SetVehicleExternalLock(vehicleid, E_LOCK_STATE_OPEN);

		ChatMsg(playerid, YELLOW, " >  Veiculo %d destrancado", vehicleid);

		return 1;
	}

	if(!strcmp(command, "removerchave"))
	{
		SetVehicleKey(vehicleid, 0);

		ChatMsg(playerid, YELLOW, " >  Removido a chave do veiculo %d", vehicleid);

		return 1;
	}

	if(!strcmp(command, "destruir"))
	{
		SetVehicleHealth(vehicleid, 0.0);
		
		SaveVehicle(vehicleid);

		ChatMsg(playerid, YELLOW, " >  Veiculo %d destruido", vehicleid);

		return 1;
	}

	ChatMsg(playerid, YELLOW, " >  Use: /veiculo [puxar/ir/entrar/deletar/respawnar/resetar/trancar/destrancar/removerchave/destruir] [id]");

	return 1;
}

ACMD:move[3](playerid, params[])
{
	if(!IsPlayerOnAdminDuty(playerid) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET)
		return 6;

	new
		direction[10],
		Float:amount;

	if(!sscanf(params, "s[10]F(2.0)", direction, amount))
	{
		new
			Float:x,
			Float:y,
			Float:z,
			Float:r;

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
	if(isnull(params))
	{
		ChatMsg(playerid, YELLOW, " >  Use: /resetarsenha [Nick]");
		return 1;
	}

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
	new
		name[MAX_PLAYER_NAME],
		active;

	if(sscanf(params, "s[24]d", name, active))
	{
		ChatMsg(playerid, YELLOW, " >  Use: /setactive [nick] [1/0] (1 = ativar, 0 = desativar)");
		return 1;
	}

	if(!AccountExists(name))
	{
		ChatMsg(playerid, RED, " >  Essa conta não existe.");
		return 1;
	}

    if(!active)
		ChatMsgAdmins(1, BLUE, "[Admin-Log] "C_BLUE"%p(id:%d) Desativou a conta %s!", playerid, playerid, name);
	else
		ChatMsgAdmins(1, BLUE, "[Admin-Log] "C_BLUE"%p(id:%d) Ativou a conta %s!", playerid, playerid, name);

	SetAccountActiveState(name, active);

	ChatMsg(playerid, YELLOW, " >  %s "C_BLUE"'%s' "C_YELLOW"conta.", active ? ("Activated") : ("Deactivated"), name);

	return 1;
}

ACMD:irpos[3](playerid, params[])
{
    if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET)
		return 6;
		
	new
		Float:x,
		Float:y,
		Float:z;

	if(sscanf(params, "fff", x, y, z) && sscanf(params, "p<,>fff", x, y, z))
		return ChatMsg(playerid, YELLOW, " > Use: /irpos x, y, z (Com ou sem vírgulas)");

//	ChatMsg(playerid, YELLOW, " >  Teleportado para %f, %f, %f", x, y, z);
	SetPlayerPos(playerid, x, y, z);

	ChatMsgAdmins(1, BLUE, "[Admin-Log] "C_BLUE"%p(id:%d) Foi até a posição: %0.2f, %0.2f, %0.2f", playerid, playerid, x, y, z);

	return 1;
}

ACMD:banir[3](playerid, params[])
{
	new name[MAX_PLAYER_NAME];

	if(sscanf(params, "s[24]", name))
	{
		ChatMsg(playerid, YELLOW, " >  Use: /banir [playerid/nome]");
		return 1;
	}

	if(isnumeric(name))
	{
		new targetid = strval(name);

		if(IsPlayerConnected(targetid))
			GetPlayerName(targetid, name, MAX_PLAYER_NAME);

		else
			ChatMsg(playerid, YELLOW, " >  O ID '%d' não está online, tente usar o nome do jogador.", targetid);
	}

	if(!AccountExists(name))
	{
		ChatMsg(playerid, YELLOW, " > a conta '%s' não existe.", name);
		return 1;
	}

	if(GetAdminLevelByName(name) > STAFF_LEVEL_NONE)
		return 2;

	BanAndEnterInfo(playerid, name);

	ChatMsg(playerid, YELLOW, " >  Preparando banimento de: %s", name);

	return 1;
}

ACMD:desbanir[3](playerid, params[])
{
	new name[MAX_PLAYER_NAME];

	if(sscanf(params, "s[24]", name))
		return ChatMsg(playerid, YELLOW, " >  Use: /desbanir [Nick]");

	if(UnBanPlayer(name))
		ChatMsg(playerid, YELLOW, " >  A conta "C_BLUE"%s"C_YELLOW" foi desbanida.", name);

	else
		ChatMsg(playerid, YELLOW, " >  A conta '%s' não está banida.");

	return 1;
}

ACMD:banidos[3](playerid, params[])
{
	new ret = ShowListOfBans(playerid, 0);

	if(ret == 0)
		ChatMsg(playerid, YELLOW, " >  Não há nenhum player banido.");

	if(ret == -1)
//		ChatMsg(playerid, YELLOW, " >  Ocorreu um erro ao executar 'stmt_BanGetList'.");
		ChatMsg(playerid, YELLOW, " >  Ocorreu um erro.");

	return 1;
}

ACMD:bb[3](playerid){
    if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] "C_BLUE"%p(id:%d) usou o teleporte /bb", playerid, playerid);
    SetPlayerPos(playerid,0.22, 0.21, 3.11);
	return 1;
}

ACMD:sf[3](playerid){
    if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
		return 6;

	ChatMsgAdmins(1, BLUE, "[Admin-Log] "C_BLUE"%p(id:%d) usou o teleporte /sf", playerid, playerid);
    SetPlayerPos(playerid,-2026.95, 156.70, 29.03);
	return 1;
}

ACMD:lv[3](playerid){
    if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] "C_BLUE"%p(id:%d) usou o teleporte /lv", playerid, playerid);
    SetPlayerPos(playerid,2026.64, 1008.28, 10.82);
	return 1;
}

ACMD:ls[3](playerid){
    if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
		return 6;

	ChatMsgAdmins(1, BLUE, "[Admin-Log] "C_BLUE"%p(id:%d) usou o teleporte /ls", playerid, playerid);
    SetPlayerPos(playerid,1481.09, -1764.00, 18.79);
	return 1;
}

ACMD:fc[3](playerid){
    if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] "C_BLUE"%p(id:%d) usou o teleporte /fc", playerid, playerid);
    SetPlayerPos(playerid,-216.36, 979.20, 20.94);
	return 1;
}

ACMD:bs[3](playerid){
    if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] "C_BLUE"%p(id:%d) usou o teleporte /bs", playerid, playerid);
    SetPlayerPos(playerid,-2506.8413, 2358.6741, 4.9860);
	return 1;
}

ACMD:mg[3](playerid){
    if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] "C_BLUE"%p(id:%d) usou o teleporte /mg", playerid, playerid);
    SetPlayerPos(playerid,1347.8447, 313.6524, 20.5547);
	return 1;
}

ACMD:dm[3](playerid){
    if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] "C_BLUE"%p(id:%d) usou o teleporte /dm", playerid, playerid);
    SetPlayerPos(playerid,619.8964, -542.9938, 16.4536);
	return 1;
}

ACMD:pc[3](playerid){
    if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] "C_BLUE"%p(id:%d) usou o teleporte /pc", playerid, playerid);
    SetPlayerPos(playerid,2332.5959, 38.6790, 26.4816);
	return 1;
}

ACMD:ap[3](playerid){
    if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] "C_BLUE"%p(id:%d) usou o teleporte /ap", playerid, playerid);
    SetPlayerPos(playerid,-2144.5183, -2338.9004, 30.6250);
	return 1;
}

ACMD:lp[3](playerid){
    if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] "C_BLUE"%p(id:%d) usou o teleporte /lp", playerid, playerid);
    SetPlayerPos(playerid,-240.3974, 2713.4150, 62.6875);
	return 1;
}

ACMD:lb[3](playerid){
    if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] "C_BLUE"%p(id:%d) usou o teleporte /lb", playerid, playerid);
    SetPlayerPos(playerid,-736.2372, 1547.7043, 39.0007);
	return 1;
}

ACMD:eq[3](playerid){
    if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] "C_BLUE"%p(id:%d) usou o teleporte /eq", playerid, playerid);
    SetPlayerPos(playerid,-1527.5648, 2550.4546, 58.1881);
	return 1;
}

ACMD:ec[3](playerid){
    if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] "C_BLUE"%p(id:%d) usou o teleporte /ec", playerid, playerid);
    SetPlayerPos(playerid,-388.5280, 2212.0117, 42.4249);
	return 1;
}

ACMD:mc[3](playerid){
    if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] "C_BLUE"%p(id:%d) usou o teleporte /mc", playerid, playerid);
    SetPlayerPos(playerid,-2323.0515, -1637.6571, 483.7031);
	return 1;
}

ACMD:69[3](playerid){
    if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] "C_BLUE"%p(id:%d) usou o teleporte /69", playerid, playerid);
    SetPlayerPos(playerid,-1359.2432, 498.4693, 21.2500);
	return 1;
}

ACMD:cb[3](playerid){
    if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] "C_BLUE"%p(id:%d) usou o teleporte /cb", playerid, playerid);
    SetPlayerPos(playerid,-1918.1047, 640.4106, 46.5625);
	return 1;
}

ACMD:51[3](playerid){
    if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] "C_BLUE"%p(id:%d) usou o teleporte /51", playerid, playerid);
    SetPlayerPos(playerid,249.6743, 1887.9854, 20.6406);
	return 1;
}

ACMD:kacc[3](playerid){
    if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] "C_BLUE"%p(id:%d) usou o teleporte /kacc", playerid, playerid);
    SetPlayerPos(playerid,2590.4778, 2800.8882, 10.8203);
	return 1;
}

ACMD:militarls1[3](playerid){
    if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] "C_BLUE"%p(id:%d) usou o teleporte /militarls1", playerid, playerid);
    SetPlayerPos(playerid,1900.0914, -457.6173, 27.4642);
	return 1;
}

ACMD:militarls2[3](playerid){
    if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] "C_BLUE"%p(id:%d) usou o teleporte /militarls2", playerid, playerid);
    SetPlayerPos(playerid,-1039.7141, -918.3206, 132.6531);
	return 1;
}

ACMD:ilhals[3](playerid){
    if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] "C_BLUE"%p(id:%d) usou o teleporte /ilhals", playerid, playerid);
    SetPlayerPos(playerid,4472.2578, -1718.3352, 8.3501);
	return 1;
}

ACMD:ilhalv[3](playerid){
    if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] "C_BLUE"%p(id:%d) usou o teleporte /ilhalv", playerid, playerid);
    SetPlayerPos(playerid,258.3774, 4316.2959, 3.3737);
	return 1;
}

ACMD:ilhasf[3](playerid){
    if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_DEVELOPER)
		return 6;

    ChatMsgAdmins(1, BLUE, "[Admin-Log] "C_BLUE"%p(id:%d) usou o teleporte /ilhasf", playerid, playerid);
    SetPlayerPos(playerid,-4481.0483, 432.3738, 10.7196);
	return 1;
}

ACMD:teleportes[3](playerid)
{
    new stringtp[800];
    strcat(stringtp, ""C_BLUE"Los Santos - /ls\n");
    strcat(stringtp, ""C_BLUE"Las Venturas - /lv\n");
    strcat(stringtp, ""C_BLUE"San Fierro - /sf\n");
    strcat(stringtp, ""C_BLUE"BlueBerry - /bb\n");
    strcat(stringtp, ""C_BLUE"Bayside - /bs\n");
    strcat(stringtp, ""C_BLUE"Montgomery - /mg\n");
    strcat(stringtp, ""C_BLUE"Dillimore - /dm\n");
    strcat(stringtp, ""C_BLUE"Palomino Creek - /pc\n");
    strcat(stringtp, ""C_BLUE"Angel Pine - /ap\n");
    strcat(stringtp, ""C_BLUE"Las Payasadas - /lp\n");
    strcat(stringtp, ""C_BLUE"Las Barrancas - /lb\n");
    strcat(stringtp, ""C_BLUE"El Quebrados - /eq\n");
    strcat(stringtp, ""C_BLUE"El Castillo - /ec\n");
    strcat(stringtp, ""C_BLUE"MontiChillad - /mc\n");
    strcat(stringtp, ""C_BLUE"69 - /69\n");
    strcat(stringtp, ""C_BLUE"Casa Branca - /cb\n");
    strcat(stringtp, ""C_BLUE"51 - /51\n");
    strcat(stringtp, ""C_BLUE"K.A.C.C - /kacc\n");
	strcat(stringtp, ""C_BLUE"Ilha LS - /ilhals\n");
    strcat(stringtp, ""C_BLUE"Ilha LV - /ilhalv\n");
    strcat(stringtp, ""C_BLUE"Ilha SF - /ilhasf\n");
    ShowPlayerDialog(playerid, 11478, DIALOG_STYLE_MSGBOX, "Teleportes", stringtp, "Fechar", "");
	return 1;
}

ACMD:comandoslvl3[3](playerid)
{
    new stringlvl3[800];
    strcat(stringlvl3, "{FFFF00}Comandos dos Admins Nível 3:\n");
    strcat(stringlvl3, "{FF0000}\n");
    strcat(stringlvl3, ""C_BLUE"/(des)congelar - Congelar/descongelar players\n");
    strcat(stringlvl3, ""C_BLUE"/(des)banir - Banir/desbanir players\n");
    strcat(stringlvl3, ""C_BLUE"/spec /free - Observar alguém, camera livre\n");
    strcat(stringlvl3, ""C_BLUE"/ip - Pegar ip de players\n");
    strcat(stringlvl3, ""C_BLUE"/veiculo - Controlar veículos\n");
    strcat(stringlvl3, ""C_BLUE"/move - Mover-se\n");
    strcat(stringlvl3, ""C_BLUE"/irpos - Ir em uma determinada coordenada\n");
    strcat(stringlvl3, ""C_BLUE"/resetarsenha - Resetar senha de alguém (a senha nova será: password)\n");
    strcat(stringlvl3, ""C_BLUE"/setactive - ativar/desativar contas\n");
    strcat(stringlvl3, ""C_BLUE"/teleportes - Ver os comandos de teleportes\n");
    strcat(stringlvl3, ""C_BLUE"/delreports - Apagar todos os reports enviados\n");
    ShowPlayerDialog(playerid, 12403, DIALOG_STYLE_MSGBOX, "Admin 3", stringlvl3, "Fechar", "");
    return 1;
}
