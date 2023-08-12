ACMD:gamename[5](playerid,params[]) {
	if(!(0 < strlen(params) < 64)) return ChatMsg(playerid,YELLOW," >  Usage: /gamename [name]");

	SetGameModeText(params);
	ChatMsg(playerid, YELLOW, " >  GameMode name set to "C_BLUE"%s", params);

	return 1;
}

ACMD:hostname[5](playerid,params[]) {
	if(!(0 < strlen(params) < 64)) return ChatMsg(playerid,YELLOW," >  Usage: /hostname [name]");

	SendRconCommand(sprintf("hostname %s", params));

	ChatMsg(playerid, YELLOW, " >  Hostname set to "C_BLUE"%s", params);

	return 1;
}

ACMD:mapname[5](playerid,params[]) {
	if(!(0 < strlen(params) < 64)) return ChatMsg(playerid,YELLOW," >  Usage: /mapname [name]");

	SendRconCommand(sprintf("mapname %s", params));

	return 1;
}

ACMD:gmx[5](playerid) {
	RestartGamemode();
	return 1;
}

ACMD:loadfs[5](playerid, params[]) {
	if(!(0 < strlen(params) < 64)) return ChatMsg(playerid, YELLOW, " >  Usage: /loadfs [FS name]");

	SendRconCommand(sprintf("loadfs %s", params));
	ChatMsg(playerid, YELLOW, " >  Loading Filterscript: "C_BLUE"'%s'", params);

	return 1;
}

ACMD:reloadfs[5](playerid, params[]) {
	if(!(0 < strlen(params) < 64)) return ChatMsg(playerid, YELLOW, " >  Usage: /loadfs [FS name]");

	SendRconCommand(sprintf("reloadfs %s", params));
	ChatMsg(playerid, YELLOW, " >  Reloading Filterscript: "C_BLUE"'%s'", params);

	return 1;
}

ACMD:unloadfs[5](playerid, params[]) {
	if(!(0 < strlen(params) < 64)) return ChatMsg(playerid, YELLOW, " >  Usage: /loadfs [FS name]");

	SendRconCommand(sprintf("unloadfs %s", params));
	ChatMsg(playerid, YELLOW, " >  Unloading Filterscript: "C_BLUE"'%s'", params);

	return 1;
}

ACMD:nametags[5](playerid, params[]) {
	ToggleNameTagsForPlayer(playerid, !GetPlayerNameTagsToggle(playerid));
	ChatMsg(playerid, YELLOW, " >  Nametags toggled %s", (GetPlayerNameTagsToggle(playerid)) ? ("on") : ("off"));

	return 1;
}

/*ACMD:gotoitem[5](playerid, params[]) {
	new
		itemid = strval(params),
		Float:x,
		Float:y,
		Float:z;

	GetItemPos(itemid, x, y, z);
	SetPlayerPos(playerid, x, y, z);

	return 1;
}

ACMD:destroyitemid[5](playerid, params[]) {
	new
		itemid = strval(params);

	DestroyItem(itemid);

	return 1;
}*/

ACMD:addloot[5](playerid, params[]) {
	new
		lootIndexName[MAX_LOOT_INDEX_NAME],
		lootIndex,
		size;

	if(sscanf(params, "s[32]d", lootIndexName, size)) return ChatMsg(playerid, YELLOW, " >  Usage: /addloot [indexname] [size]");

	lootIndex = GetLootIndexFromName(lootIndexName);

	if(lootIndex == -1) return ChatMsg(playerid, RED, " >  Loot index name invalid!");

	new Float:x, Float:y, Float:z;

	GetPlayerPos(playerid, x, y, z);

	CreateLootItem(lootIndex, x, y, z, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid));
	//CreateStaticLootSpawn(x, y, z - 0.8568, lootindex, 100, size, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid));

	return 1;
}

ACMD:setitemhp[5](playerid, params[]) {
	new itemid, hitpoints;

	if(sscanf(params, "dd", itemid, hitpoints)) return ChatMsg(playerid, YELLOW, " >  Usage: /setitemhp [itemid] [hitpoints]");

	SetItemHitPoints(itemid, hitpoints);

	return 1;
}

ACMD:vw[5](playerid, params[]) {
	if(isnull(params))
		ChatMsg(playerid, YELLOW, "Current VW: %d", GetPlayerVirtualWorld(playerid));
	else
		SetPlayerVirtualWorld(playerid, strval(params));

	return 1;
}

ACMD:iw[5](playerid, params[]) {
	if(isnull(params))
		ChatMsg(playerid, YELLOW, "Current INT: %d", GetPlayerInterior(playerid));
	else
		SetPlayerInterior(playerid, strval(params));

	return 1;
}

ACMD:food[5](playerid, params[]) {
	new targetId, Float:value;

	if(sscanf(params, "rF(100)", targetId, value)) return ChatMsg(playerid, YELLOW, " > Sintaxe: /food [id/nick] (valor)");

	if(targetId == INVALID_PLAYER_ID) return 4;

	SetPlayerFP(targetId, value);

	ChatMsg(playerid, YELLOW, "Set food to %f", value);
	ChatMsg(targetId, YELLOW, "Sua fome foi colocada para %f por %P", value, playerid);

	return 1;
}

ACMD:bleed[5](playerid, params[]) {
	new targetId, Float:value;

	if(sscanf(params, "R(*)F(100.0)", playerid, targetId, value)) return 1;

	SetPlayerBleedRate(targetId, value);
	ChatMsg(playerid, YELLOW, "Set %p bleed rate to %.2f", value);

	return 1;
}

ACMD:knockout[5](playerid, params[]) {
	KnockOutPlayer(playerid, strval(params));
	ChatMsg(playerid, YELLOW, "Set knockout time to %d", strval(params));
	return 1;
}

ACMD:showdamage[5](playerid) {
	ShowActionText(playerid, sprintf("bleedrate: %f~n~wounds: %d", GetPlayerBleedRate(playerid), GetPlayerWounds(playerid)), 5000);
	return 1;
}

ACMD:removewounds[5](playerid, params[]) {
	RemovePlayerWounds(playerid, strval(params));
	ChatMsg(playerid, YELLOW, "Removed %d wounds.", strval(params));
	return 1;
}

ACMD:wc[5](playerid) {
	new Float:x, Float:y, Float:z;

	GetPlayerPos(playerid, x, y, z);

	WeaponsCacheDrop(x, y, z - 0.8);
	SetPlayerPos(playerid, x, y, z + 1.0);

	return 1;
}

static cloneid[MAX_PLAYERS] = {INVALID_ACTOR_ID, ...};

ACMD:clone[5](playerid) {
	if(cloneid[playerid] == INVALID_ACTOR_ID) {
		new Float:x, Float:y, Float:z, Float:a;

		GetPlayerPos(playerid, x, y, z);
		GetPlayerFacingAngle(playerid, a);

		cloneid[playerid] = CreateActor(GetPlayerSkin(playerid), x, y, z, a);
	} else {
		DestroyActor(cloneid[playerid]);
		cloneid[playerid] = INVALID_ACTOR_ID;
	}

	return 1;
}

CMD:setadmin(playerid, params[]) {
	if(!IsPlayerAdmin(playerid) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_LEAD) return 0;

	new targetId, level;

	if(!sscanf(params, "rd", targetId, level)) {
		new playerName[MAX_PLAYER_NAME];

		if(targetId != INVALID_PLAYER_ID)
			GetPlayerName(targetId, playerName, MAX_PLAYER_NAME);
		else
			sscanf(params, "s[*]{d}", MAX_PLAYER_NAME, playerName);
		
		if(!SetPlayerAdminLevel(playerName, level)) return ChatMsg(playerid, RED, " >  Admin level must be equal to or between 0 and 3");

		new rankName[15];
		
		rankName = GetAdminRankName(level);

		ChatMsg(playerid, YELLOW, " >  You made %s a %s", playerName, rankName);
		if(targetId != INVALID_PLAYER_ID) ChatMsg(targetId, YELLOW, " >  %P"C_YELLOW" colocou voce como "C_WHITE"%s", playerid, rankName);
	} else
		ChatMsg(playerid, YELLOW, " >  Usage: /setadmin [id/nick] [level]");

	return 1;
}

ACMD:debug[5](playerid, params[]) {
	new
		handlername[32],
		level;

	if(sscanf(params, "s[32]d", handlername, level)) return ChatMsg(playerid, YELLOW, " >  Usage: /debug [handlername] [level]");

	debug_set_level(handlername, level);

	ChatMsg(playerid, YELLOW, " >  SS debug level for '%s': %d", handlername, level);

	return 1;
}

ACMD:sifdebug[5](playerid, params[]) {
	new
		handlername[32],
		level,
		handler;

	if(sscanf(params, "s[32]d", handlername, level)) return ChatMsg(playerid, YELLOW, " >  Usage: /sifdebug [handlername] [level]");

	handler = sif_debug_handler_search(handlername);

	if(handler == -1) return ChatMsg(playerid, YELLOW, "Invalid handler");

	if(!(0 <= level <= 10)) return ChatMsg(playerid, YELLOW, "Invalid level");

	sif_debug_get_handler_name(handler, handlername);

	sif_debug_plevel(playerid, handler, level);

	ChatMsg(playerid, YELLOW, " >  SIF debug level for '%s': %d", handlername, level);

	return 1;
}

ACMD:sifgdebug[5](playerid, params[]) {
	new
		handlername[32],
		level,
		handler;

	if(sscanf(params, "s[32]d", handlername, level)) return ChatMsg(playerid, YELLOW, " >  Usage: /sifgdebug [handlername] [level]");

	handler = sif_debug_handler_search(handlername);

	if(handler == -1) return ChatMsg(playerid, YELLOW, "Invalid handler");

	if(!(0 <= level <= 10)) return ChatMsg(playerid, YELLOW, "Invalid level");

	sif_debug_get_handler_name(handler, handlername);

	sif_debug_level(handler, level);

	ChatMsg(playerid, YELLOW, " >  Global SIF debug level for '%s': %d", handlername, level);

	return 1;
}

ACMD:dbl[5](playerid) {
	#if defined SIF_USE_DEBUG_LABELS
		if(IsPlayerToggledAllDebugLabels(playerid)) {
			HideAllDebugLabelsForPlayer(playerid);
			ChatMsg(playerid, YELLOW, " >  Debug labels toggled off.");
		} else {
			ShowAllDebugLabelsForPlayer(playerid);
			ChatMsg(playerid, YELLOW, " >  Debug labels toggled on.");
		}
	#else
		ChatMsg(playerid, YELLOW, " >  Debug labels are not compiled.");
	#endif

	return 1;
}

ACMD:otp[5](playerid, params[]) {
	new targetId;

	if(sscanf(params, "r", targetId)) { // Se nao especificar um jogador, ativa/desativa o modo de chave unica para o proprio jogador
		new bool:otp = IsOTPModeEnabled();

		ToggleOTPMode(!otp);

		ChatMsgAdmins(1, YELLOW, " >  Modo de Chave Unica %s", !otp ? "ativado" : "desativado");
	} else {
		if(targetId == INVALID_PLAYER_ID) return CMD_INVALID_PLAYER;
		if(!IsPlayerWaitingOTP(targetId)) return ChatMsg(playerid, YELLOW, " >  Este jogador nao esta esperando por uma chave unica.");

		PassOTP(targetId);

		ChatMsgAdmins(1, YELLOW, " >  %P"C_YELLOW" invalidou a chave unica de %p.", playerid, targetId);
	}

	return 1;
}

ACMD:delreports[5](playerid) {
    for(new i = 0; i < 5000; i++) SetReportRead(i, 1); // * 5 mil? caralho
		
	ChatMsg(playerid, YELLOW, " >  Todos os reports foram deletados.");
	DeleteReadReports();

	return 1;
}