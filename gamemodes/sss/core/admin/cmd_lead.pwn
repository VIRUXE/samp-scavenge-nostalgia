#include <YSI\y_hooks>

hook OnGameModeInit() {
	RegisterAdminCommand(LEVEL_LEAD, "reiniciar", "Reiniciar o servidor");
    RegisterAdminCommand(LEVEL_LEAD, "(des)congelarall", "(Des)congelar todos os players online");
    RegisterAdminCommand(LEVEL_LEAD, "additem", "Adicionar um item");
    RegisterAdminCommand(LEVEL_LEAD, "addveiculo", "Adicionar um veiculo");
    RegisterAdminCommand(LEVEL_LEAD, "aliases", "Checar IPs");
    RegisterAdminCommand(LEVEL_LEAD, "clima", "Mudar o clima do servidor");
    RegisterAdminCommand(LEVEL_LEAD, "deletar", "Deletar metais, tendas, itens");
}

ACMD:reiniciar[3](playerid, params[]) {
	new duration;

	if(sscanf(params, "D(300)", duration)) return ChatMsg(playerid, YELLOW, " >  Use: /reiniciar (segundos)");

	// ChatMsgAll(RED, " >  O servidor será reiniciado em: "C_BLUE"%02d:%02d"C_RED".", duration / 60, duration % 60);

	SetRestart(duration);

	return 1;
}

ACMD:additem[3](playerid, params[]) {
	new
		ItemType:type = INVALID_ITEM_TYPE,
		itemName[ITM_MAX_NAME + 10],
		exdata[8];

	if(sscanf(params, "p<,>dA<d>(-2147483648)[8]", _:type, exdata) != 0) {
		new tmp[ITM_MAX_NAME + 10];

		if(sscanf(params, "p<,>s[32]A<d>(-2147483648)[8]", tmp, exdata)) return ChatMsg(playerid, YELLOW, " >  Use: /additem [ID do item/Nome do item], [opcional:extra do item, separado]");

		for(new ItemType:i; i < ITM_MAX_TYPES; i++) {
			GetItemTypeUniqueName(i, itemName);

			if(strfind(itemName, tmp, true) != -1) {
				type = i;
				break;
			}
		}

		if(type == INVALID_ITEM_TYPE) {
			for(new ItemType:i; i < ITM_MAX_TYPES; i++) {
				GetItemTypeName(i, itemName);

				if(strfind(itemName, tmp, true) != -1) {
					type = i;
					break;
				}
			}
		}

		if(type == INVALID_ITEM_TYPE) return ChatMsg(playerid, RED, " >  Item '%s' não encontrado.", tmp);
	}

	if(type == INVALID_ITEM_TYPE) return ChatMsg(playerid, RED, " >  Tipo de item inválido: %d", _:type);

	new
		extraDataSize,
		typeMaxSize = GetItemTypeArrayDataSize(type),
		Float:x, Float:y, Float:z, Float:r;

	for(new i; i < 8; ++i) {
		if(exdata[i] != cellmin)
			++extraDataSize;
	}

	if(extraDataSize > typeMaxSize) extraDataSize = typeMaxSize;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	CA_FindZ_For2DCoord(x,y, z);

	new spectateTargetId = GetPlayerSpectateTarget(playerid);

	if(spectateTargetId != INVALID_PLAYER_ID) {
		FreezePlayer(spectateTargetId, SEC(1));
		ChatMsg(spectateTargetId, GREEN, " > Um admin spawnou agora um '%s' para você!", itemName);
	}

	new const Float:itemDistance = 0.25;
	new itemId = CreateItem(type,
		x + (itemDistance * floatsin(-r, degrees)),
		y + (itemDistance * floatcos(-r, degrees)),
		z, .rz = r);

	if(extraDataSize > 0) SetItemArrayData(itemId, exdata, extraDataSize);

	log("[ADMIN][ADDITEM] %p adicionou o item %s (tipo: %d)", playerid, itemName, _:type);

	return ChatMsgAdmins(LEVEL_MODERATOR, BLUE, "%P"C_BLUE" (%d) usou o comando /additem", playerid, playerid);
}

ACMD:addveh[3](playerid, params[]) {
    if(isnull(params)) return ChatMsg(playerid, YELLOW, " >  Use: /veh [id/nome]");
	
	new Float:x, Float:y, Float:z, Float:r;

	new const type = isnumeric(params) ? strval(params) : GetVehicleTypeFromName(params, true, true);

	if(!IsValidVehicleType(type)) return ChatMsg(playerid, YELLOW, " >  Tipo de veiculo inválido.");

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	new const vehicleId = CreateLootVehicle(type, x, y, z, r);
	SetVehicleFuel(vehicleId, 1000.0);
	SetVehicleHealth(vehicleId, 990.0);
	SetVehicleExternalLock(vehicleId, E_LOCK_STATE_OPEN);
	
	return ChatMsgAdmins(LEVEL_MODERATOR, BLUE, "%P"C_BLUE" (%d) usou o comando /veh", playerid, playerid);
}
ACMD:addveiculo[3](playerid, params[]) return acmd_addveh_3(playerid, params);
ACMD:av[3](playerid, params[]) return acmd_addveh_3(playerid, params);

ACMD:deletar[3](playerid, params[]) {
	if(!IsPlayerOnAdminDuty(playerid) && GetPlayerAdminLevel(playerid) < LEVEL_LEAD) return CMD_NOT_DUTY;

	new type[8], Float:range;

	if(sscanf(params, "s[8]F(1.5)", type, range)) return ChatMsg(playerid, YELLOW, " >  Use: /deletar [itens/tendas/defesas] (distância)");

	printf("%s %f", type, range);

	if(range > 50.0) return ChatMsg(playerid, YELLOW, " >  Limite de Área: 50 metros");

	new
		Float:pX, Float:pY, Float:pZ, 
		Float:iX, Float:iY, Float:iZ,
		count;

	GetPlayerPos(playerid, pX, pY, pZ);

	if(isequal(type, "itens", true)) {
		foreach(new i : itm_Index) {
		    // if(GetItemTypeDefenceType(GetItemType(i)) != INVALID_DEFENCE_TYPE) continue;

			GetItemPos(i, iX, iY, iZ);

			if(Distance(pX, pY, pZ, iX, iY, iZ) < range) {
				count++;
				i = DestroyItem(i);
			}
		}
	} else if(isequal(type, "tendas", true)) {
		foreach(new i : tnt_Index) {
			GetTentPos(i, iX, iY, iZ);

			if(Distance(pX, pY, pZ, iX, iY, iZ) < range) {
				count++;
				i = DestroyTent(i);
				//CallLocalFunction("OnTentDestroy", "d", GetTentID(i));
			}
		}
	} else if(isequal(type, "defesas", true)) {
		foreach(new i : itm_Index) {
			if(GetItemTypeDefenceType(GetItemType(i)) == INVALID_DEFENCE_TYPE) continue;

			GetItemPos(i, iX, iY, iZ);

			if(Distance(pX, pY, pZ, iX, iY, iZ) < range) {
				count++;
				i = DestroyItem(i);
			    CallLocalFunction("OnDefenceDestroy", "d", i);
			}
		}
	} else
		return ChatMsg(playerid, YELLOW, " >  Use: /deletar [itens/tendas/defesas] (distância)");

	return ChatMsg(playerid, GREEN, " > %d %s", count, type);
}
ACMD:del[3](playerid, params[]) return acmd_deletar_3(playerid, params);

ACMD:congelarall[3](playerid) {
	foreach(new i : Player) TogglePlayerControllable(i, false);

	return ChatMsgAll(0xC457EBAA, "[Admin]: %p{0xC457EBAA} (%d) congelou todos os players online do servidor!", playerid, playerid);
}

ACMD:descongelarall[3](playerid) {
	foreach(new i : Player) TogglePlayerControllable(i, true);

	return ChatMsgAll(0xC457EBAA, "[Admin]: %p{0xC457EBAA} (%d) descongelou todos os players online do servidor!", playerid, playerid);
}

ACMD:clima[3](playerid, params[]) {
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

ACMD:aliases[3](playerid, params[]) {
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
