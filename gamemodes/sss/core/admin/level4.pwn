#include <YSI\y_hooks>

hook OnGameModeInit() {
	RegisterAdminCommand(STAFF_LEVEL_LEAD, "reiniciar", "Reiniciar o servidor");
    RegisterAdminCommand(STAFF_LEVEL_LEAD, "(des)congelarall", "(Des)congelar todos os players online");
    RegisterAdminCommand(STAFF_LEVEL_LEAD, "additem", "Adicionar um item");
    RegisterAdminCommand(STAFF_LEVEL_LEAD, "addveiculo", "Adicionar um veiculo");
    RegisterAdminCommand(STAFF_LEVEL_LEAD, "aliases", "Checar IPs");
    RegisterAdminCommand(STAFF_LEVEL_LEAD, "clima", "Mudar o clima do servidor");
    RegisterAdminCommand(STAFF_LEVEL_LEAD, "deletar", "Deletar metais, tendas, itens");
    RegisterAdminCommand(STAFF_LEVEL_LEAD, "tapa", "Dar tapa em algum player");
}

ACMD:reiniciar[4](playerid, params[]) {
	new duration;

	if(sscanf(params, "D(300)", duration)) return ChatMsg(playerid, YELLOW, " >  Use: /reiniciar (segundos)");

	// ChatMsgAll(RED, " >  O servidor será reiniciado em: "C_BLUE"%02d:%02d"C_RED".", duration / 60, duration % 60);

	SetRestart(duration);

	return 1;
}

ACMD:additem[4](playerid, params[]) {
	new
		ItemType:type = INVALID_ITEM_TYPE,
		itemname[ITM_MAX_NAME + 10],
		exdata[8];

	if(sscanf(params, "p<,>dA<d>(-2147483648)[8]", _:type, exdata) != 0) {
		new tmp[ITM_MAX_NAME + 10];

		if(sscanf(params, "p<,>s[32]A<d>(-2147483648)[8]", tmp, exdata)) return ChatMsg(playerid, YELLOW, " >  Use: /additem [ID do item/Nome do item], [opcional:extra do item, separado]");

		for(new ItemType:i; i < ITM_MAX_TYPES; i++) {
			GetItemTypeUniqueName(i, itemname);

			if(strfind(itemname, tmp, true) != -1) {
				type = i;
				break;
			}
		}

		if(type == INVALID_ITEM_TYPE) {
			for(new ItemType:i; i < ITM_MAX_TYPES; i++) {
				GetItemTypeName(i, itemname);

				if(strfind(itemname, tmp, true) != -1) {
					type = i;
					break;
				}
			}
		}

		if(type == INVALID_ITEM_TYPE) return ChatMsg(playerid, RED, " >  Item '%s' não encontrado.", tmp);
	}

	if(type == INVALID_ITEM_TYPE) return ChatMsg(playerid, RED, " >  Tipo de item inválido: %d", _:type);

	new
		exdatasize,
		typemaxsize = GetItemTypeArrayDataSize(type),
		itemid,
		Float:x, Float:y, Float:z, Float:r;

	for(new i; i < 8; ++i) {
		if(exdata[i] != cellmin)
			++exdatasize;
	}

	if(exdatasize > typemaxsize) exdatasize = typemaxsize;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	itemid = CreateItem(type,
		x + (0.5 * floatsin(-r, degrees)),
		y + (0.5 * floatcos(-r, degrees)),
		z - FLOOR_OFFSET, .rz = r);

	if(exdatasize > 0) SetItemArrayData(itemid, exdata, exdatasize);

	log("[ADMIN][ADDITEM] %p adicionou o item %s (tipo: %d)", playerid, itemname, _:type);

	return ChatMsgAdmins(1, BLUE, "[Admin] %P"C_BLUE" (%d) usou o comando /additem", playerid, playerid);
}

ACMD:veh[4](playerid, params[]) {
    if(isnull(params)) return ChatMsg(playerid, YELLOW, " >  Use: /addveiculo [Nome ou ID]");
	
	new
		type,
		Float:x, Float:y, Float:z, Float:r,
		vehicleid;

	type = isnumeric(params) ? strval(params) : GetVehicleTypeFromName(params, true, true);

	if(!IsValidVehicleType(type)) return ChatMsg(playerid, YELLOW, " >  Tipo de veiculo inválido.");

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	vehicleid = CreateLootVehicle(type, x, y, z, r);
	SetVehicleFuel(vehicleid, 1000.0);
	SetVehicleHealth(vehicleid, 990.0);
	SetVehicleExternalLock(vehicleid, E_LOCK_STATE_OPEN);
	
	return ChatMsgAdmins(1, BLUE, "[Admin] %P"C_BLUE" (%d) usou o comando /addveiculo", playerid, playerid);
}

ACMD:addveiculo[4](playerid, params[]) return acmd_veh_4(playerid, params);
ACMD:av[4](playerid, params[]) return acmd_veh_4(playerid, params);

ACMD:deletar[4](playerid, params[]) {
	if(!IsPlayerOnAdminDuty(playerid) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_LEAD) return CMD_NOT_DUTY;

	new
		type[8],
		Float:range;

	if(sscanf(params, "s[7]F(1.5)", type, range)) return ChatMsg(playerid, YELLOW, " >  Use: /deletar [itens/tendas/defesas] (distância)");

	if(range > 50.0) return ChatMsg(playerid, YELLOW, " >  Limite de Área: 50 metros");

	new
		Float:px, Float:py, Float:pz, 
		Float:ix, Float:iy, Float:iz;

	GetPlayerPos(playerid, px, py, pz);

	if(!strcmp(type, "itens", true, 4)) {
		foreach(new i : itm_Index) {
		    if(GetItemTypeDefenceType(GetItemType(i)) != INVALID_DEFENCE_TYPE) continue;

			GetItemPos(i, ix, iy, iz);

			if(Distance(px, py, pz, ix, iy, iz) < range) i = DestroyItem(i);
		}

		return 1;
	} else if(!strcmp(type, "tendas", true, 4)) {
		foreach(new i : tnt_Index) {
		    if(GetItemTypeDefenceType(GetItemType(i)) != INVALID_DEFENCE_TYPE) continue;

			GetTentPos(i, ix, iy, iz);

			if(Distance(px, py, pz, ix, iy, iz) < range) {
				i = DestroyTent(i);
				//CallLocalFunction("OnTentDestroy", "d", GetTentID(i));
			}
		}

		return 1;
	} else if(!strcmp(type, "defesas", true, 7)) {
		foreach(new i : itm_Index) {
			if(GetItemTypeDefenceType(GetItemType(i)) == INVALID_DEFENCE_TYPE) continue;

			GetItemPos(i, ix, iy, iz);

			if(Distance(px, py, pz, ix, iy, iz) < range) {
			    CallLocalFunction("OnDefenceDestroy", "d", i);
				i = DestroyItem(i);
			}
		}

		return 1;
	}

	return ChatMsg(playerid, YELLOW, " >  Use: /deletar [itens/tendas/defesas] [distância] - (recomendado: 1 de distância)");
}

ACMD:congelarall[4](playerid) {
	foreach(new i : Player) TogglePlayerControllable(i, false);

	return ChatMsgAll(0xC457EBAA, "[Admin]: %p{0xC457EBAA} (%d) congelou todos os players online do servidor!", playerid, playerid);
}

ACMD:descongelarall[4](playerid) {
	foreach(new i : Player) TogglePlayerControllable(i, true);

	return ChatMsgAll(0xC457EBAA, "[Admin]: %p{0xC457EBAA} (%d) descongelou todos os players online do servidor!", playerid, playerid);
}

ACMD:clima[4](playerid, params[]) {
	new clima;

	if(sscanf(params, "D(20)", clima)) return SendClientMessage(playerid, YELLOW, " > Use: /mudarclima [ID do Clima]");

	if(clima < 0 || clima > 45) return ChatMsg(playerid, RED," > Climas: 0 a 45");

    SetWeather(clima);

	new Node:node;
	JSON_GetObject(Settings, "world", node);
	JSON_SetInt(node, "weather", clima);
	JSON_SetObject(Settings, "world", node);
	JSON_SaveFile("settings.json", Settings, .pretty = true);
	
	return ChatMsgAdmins(1, 0xC457EBAA, "[Admin]: %p (%d) mudou o clima do servidor!", playerid, playerid);
}

ACMD:tapa[4](playerid, params[]) {
    if(!IsPlayerOnAdminDuty(playerid) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_LEAD) return CMD_NOT_DUTY;
		
    new targetId;
	
	if(sscanf(params, "r", targetId)) return SendClientMessage(playerid, YELLOW, " > Use: /tapa [id/nick]");

	if(GetPlayerAdminLevel(targetId) > 1) return CMD_CANT_USE_ON;

	new Float:x, Float:y, Float:z;
	GetPlayerPos(targetId, x, y, z);
	SetPlayerPos(targetId, x, y, z + 6.0);

	return ChatMsgAdmins(1, BLUE, "[Admin] %P"C_BLUE" (%d) deu um tapa em %P"C_BLUE" (%d)", playerid, playerid, targetId, targetId);
}

ACMD:aliases[4](playerid, params[]) {
	new
		name[MAX_PLAYER_NAME],
		type;

	// TODO: Isso pode ser feito de outra forma com "u"
	if(sscanf(params, "s[24]C(a)", name, type)) return ChatMsg(playerid, YELLOW, " >  Use: /aliases [id/nick] [i/p/h/a]");

	if(isnumeric(name)) {
		new targetId = strval(name);

		if(IsPlayerConnected(targetId)) GetPlayerName(targetId, name, MAX_PLAYER_NAME);
	}

	if(!AccountExists(name)) return ChatMsg(playerid, YELLOW, " >  A conta '%s' não existe.", name);

	new
		result,
		list[MAX_PLAYERS][MAX_PLAYER_NAME],
		count,
		adminLevel;

	if(type == 'a') result = GetAccountAliasesByAll(name, list, count, MAX_PLAYERS, adminLevel);
	else if(type == 'i') result = GetAccountAliasesByIP(name, list, count, MAX_PLAYERS, adminLevel);
	else if(type == 'p') result = GetAccountAliasesByPass(name, list, count, MAX_PLAYERS, adminLevel);
	else if(type == 'h') result = GetAccountAliasesByHash(name, list, count, MAX_PLAYERS, adminLevel);
	else return ChatMsg(playerid, YELLOW, " >  O tipo de pesquisa deve ser um dos: 'i'(ip) 'p'(senha) 'h'(hash) 'a'(all)");

	if(!result) return ChatMsg(playerid, RED, " >  Ocorreu um erro.");

	if(!count) return ChatMsg(playerid, YELLOW, " >  Sem aliases encontradas para %s", name);

	ShowPlayerList(playerid, list, (count > MAX_PLAYERS) ? MAX_PLAYERS : count, true);

	return 1;
}
