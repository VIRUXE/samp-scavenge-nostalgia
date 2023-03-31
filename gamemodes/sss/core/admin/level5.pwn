ACMD:gamename[5](playerid,params[])
{
	if(!(0 < strlen(params) < 64)) return ChatMsg(playerid,YELLOW," >  Usage: /gamename [name]");

	SetGameModeText(params);
	ChatMsg(playerid, YELLOW, " >  GameMode name set to "C_BLUE"%s", params);

	return 1;
}

ACMD:hostname[5](playerid,params[])
{
	if(!(0 < strlen(params) < 64)) return ChatMsg(playerid,YELLOW," >  Usage: /hostname [name]");

	new str[74];
	format(str, sizeof(str), "hostname %s", params);
	SendRconCommand(str);

	ChatMsg(playerid, YELLOW, " >  Hostname set to "C_BLUE"%s", params);

	return 1;
}

ACMD:mapname[5](playerid,params[])
{
	if(!(0 < strlen(params) < 64)) return ChatMsg(playerid,YELLOW," >  Usage: /mapname [name]");

	new str[74];
	format(str, sizeof(str), "mapname %s", params);
	SendRconCommand(str);

	return 1;
}

ACMD:gmx[5](playerid)
{
	RestartGamemode();
	return 1;
}

ACMD:loadfs[5](playerid, params[])
{
	if(!(0 < strlen(params) < 64)) return ChatMsg(playerid, YELLOW, " >  Usage: /loadfs [FS name]");

	new str[64];
	format(str, sizeof(str), "loadfs %s", params);
	SendRconCommand(str);
	ChatMsg(playerid, YELLOW, " >  Loading Filterscript: "C_BLUE"'%s'", params);

	return 1;
}

ACMD:reloadfs[5](playerid, params[])
{
	if(!(0 < strlen(params) < 64)) return ChatMsg(playerid, YELLOW, " >  Usage: /loadfs [FS name]");

	new str[64];
	format(str, sizeof(str), "reloadfs %s", params);
	SendRconCommand(str);
	ChatMsg(playerid, YELLOW, " >  Reloading Filterscript: "C_BLUE"'%s'", params);

	return 1;
}

ACMD:unloadfs[5](playerid, params[])
{
	if(!(0 < strlen(params) < 64)) return ChatMsg(playerid, YELLOW, " >  Usage: /loadfs [FS name]");

	new str[64];
	format(str, sizeof(str), "unloadfs %s", params);
	SendRconCommand(str);
	ChatMsg(playerid, YELLOW, " >  Unloading Filterscript: "C_BLUE"'%s'", params);

	return 1;
}

ACMD:setplayerscore[5](playerid,params[])
{
	new targetPlayerId, score;
	if(sscanf(params, "dd", targetPlayerId, score)) return ChatMsg(playerid,YELLOW," >  Use: /setplayerscore [id] [score]");
	
	SetPlayerScore(targetPlayerId, score);

	ChatMsg(playerid, YELLOW, " >  Score de %d %P "C_YELLOW"setado para "C_BLUE"%d", targetPlayerId, targetPlayerId, score);
	ChatMsg(targetPlayerId, YELLOW, " >  Seu score foi setado para "C_BLUE"%d", score);

	return 1;
}

ACMD:hud[5](playerid) // * Na realidade isso deveria estar disponivel para os players
{
	TogglePlayerHUD(playerid, !IsPlayerHudOn(playerid));
}

/*ACMD:nametags[5](playerid, params[])
{
	ToggleNameTagsForPlayer(playerid, !GetPlayerNameTagsToggle(playerid));
	ChatMsg(playerid, YELLOW, " >  Nametags toggled %s", (GetPlayerNameTagsToggle(playerid)) ? ("on") : ("off"));

	return 1;
}*/

/*ACMD:gotoitem[5](playerid, params[])
{
	new
		itemid = strval(params),
		Float:x,
		Float:y,
		Float:z;

	GetItemPos(itemid, x, y, z);
	SetPlayerPos(playerid, x, y, z);

	return 1;
}

ACMD:destroyitemid[5](playerid, params[])
{
	new
		itemid = strval(params);

	DestroyItem(itemid);

	return 1;
}*/

ACMD:addloot[5](playerid, params[])
{
	new
		lootindexname[MAX_LOOT_INDEX_NAME],
		lootindex,
		size;

	if(sscanf(params, "s[32]d", lootindexname, size))
	{
		ChatMsg(playerid, YELLOW, " >  Usage: /addloot [indexname] [size]");
		return 1;
	}

	lootindex = GetLootIndexFromName(lootindexname);

	if(lootindex == -1)
	{
		ChatMsg(playerid, RED, " >  Loot index name invalid!");
		return 1;
	}

	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(playerid, x, y, z);

	CreateLootItem(lootindex, x, y, z, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid));
	//CreateStaticLootSpawn(x, y, z - 0.8568, lootindex, 100, size, GetPlayerVirtualWorld(playerid), GetPlayerInterior(playerid));

	return 1;
}

ACMD:setitemhp[5](playerid, params[])
{
	new
		itemid,
		hitpoints;

	if(sscanf(params, "dd", itemid, hitpoints))
	{
		ChatMsg(playerid, YELLOW, " >  Usage: /setitemhp [itemid] [hitpoints]");
		return 1;
	}

	SetItemHitPoints(itemid, hitpoints);

	return 1;
}

ACMD:vw[5](playerid, params[])
{
	if(isnull(params))
		ChatMsg(playerid, YELLOW, "Current VW: %d", GetPlayerVirtualWorld(playerid));

	else
		SetPlayerVirtualWorld(playerid, strval(params));

	return 1;
}

ACMD:iw[5](playerid, params[])
{
	if(isnull(params))
		ChatMsg(playerid, YELLOW, "Current INT: %d", GetPlayerInterior(playerid));

	else
		SetPlayerInterior(playerid, strval(params));

	return 1;
}

ACMD:food[5](playerid, params[])
{
	new Float:value;

	if(sscanf(params, "f", value))
	{
		ChatMsg(playerid, YELLOW, "Current food %f", GetPlayerFP(playerid));
		return 1;
	}

	SetPlayerFP(playerid, value);
	ChatMsg(playerid, YELLOW, "Set food to %f", value);

	return 1;
}

ACMD:bleed[5](playerid, params[])
{
	new Float:value;

	if(sscanf(params, "f", value))
	{
		ChatMsg(playerid, YELLOW, "Current bleed rate %f", GetPlayerBleedRate(playerid));
		return 1;
	}

	SetPlayerBleedRate(playerid, value);
	ChatMsg(playerid, YELLOW, "Set bleed rate to %f", value);

	return 1;
}

ACMD:knockout[5](playerid, params[])
{
	KnockOutPlayer(playerid, strval(params));
	ChatMsg(playerid, YELLOW, "Set knockout time to %d", strval(params));
	return 1;
}

ACMD:showdamage[5](playerid)
{
	ShowActionText(playerid, sprintf("bleedrate: %f~n~wounds: %d", GetPlayerBleedRate(playerid), GetPlayerWounds(playerid)), 5000);
	return 1;
}

ACMD:removewounds[5](playerid, params[])
{
	RemovePlayerWounds(playerid, strval(params));
	ChatMsg(playerid, YELLOW, "Removed %d wounds.", strval(params));
	return 1;
}

ACMD:wc[5](playerid)
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(playerid, x, y, z);

	WeaponsCacheDrop(x, y, z - 0.8);
	SetPlayerPos(playerid, x, y, z + 1.0);

	return 1;
}

static cloneid[MAX_PLAYERS] = {INVALID_ACTOR_ID, ...};

ACMD:clone[5](playerid)
{
	if(cloneid[playerid] == INVALID_ACTOR_ID)
	{
		new
			Float:x,
			Float:y,
			Float:z,
			Float:a;

		GetPlayerPos(playerid, x, y, z);
		GetPlayerFacingAngle(playerid, a);

		cloneid[playerid] = CreateActor(GetPlayerSkin(playerid), x, y, z, a);
	}
	else
	{
		DestroyActor(cloneid[playerid]);
		cloneid[playerid] = INVALID_ACTOR_ID;
	}

	return 1;
}

ACMD:setadmin[5](playerid, params[])
{
	new
		id,
		name[MAX_PLAYER_NAME],
		level;

	if(!sscanf(params, "dd", id, level))
	{
		if(playerid == id)
			return ChatMsg(playerid, RED, " >  You cannot set your own level");

		if(!IsPlayerConnected(id))
			return 4;

		if(!SetPlayerAdminLevel(id, level))
			return ChatMsg(playerid, RED, " >  Admin level must be equal to or between 0 and 3");

		ChatMsg(playerid, YELLOW, " >  You made %P"C_YELLOW" a Level %d Admin", id, level);
		ChatMsg(id, YELLOW, " >  %P"C_YELLOW" Made you a Level %d Admin", playerid, level);
	}
	else if(!sscanf(params, "s[24]d", name, level))
	{
		new playername[MAX_PLAYER_NAME];

		GetPlayerName(playerid, playername, MAX_PLAYER_NAME);

		if(!strcmp(name, playername))
			return ChatMsg(playerid, RED, " >  You cannot set your own level");

		UpdateAdmin(name, level);

		ChatMsg(playerid, YELLOW, " >  You set %s to admin level %d.", name, level);
	}
	else
	{
		ChatMsg(playerid, YELLOW, " >  Usage: /setadmin [playerid] [level]");
		return 1;
	}

	return 1;
}

ACMD:setpinglimit[5](playerid, params[])
{
	new val = strval(params);

	if(!(100 < val < 1000))
	{
		ChatMsg(playerid, YELLOW, " >  Ping limit must be between 100 and 1000");
		return 1;
	}

	gPingLimit = strval(params);
	ChatMsg(playerid, YELLOW, " >  Ping limit has been updated to %d.", gPingLimit);

	return 1;
}

ACMD:debug[5](playerid, params[])
{
	new
		handlername[32],
		level;

	if(sscanf(params, "s[32]d", handlername, level))
	{
		ChatMsg(playerid, YELLOW, " >  Usage: /debug [handlername] [level]");
		return 1;
	}

	debug_set_level(handlername, level);

	ChatMsg(playerid, YELLOW, " >  SS debug level for '%s': %d", handlername, level);

	return 1;
}

ACMD:sifdebug[5](playerid, params[])
{
	new
		handlername[32],
		level,
		handler;

	if(sscanf(params, "s[32]d", handlername, level))
	{
		ChatMsg(playerid, YELLOW, " >  Usage: /sifdebug [handlername] [level]");
		return 1;
	}

	handler = sif_debug_handler_search(handlername);

	if(handler == -1)
	{
		ChatMsg(playerid, YELLOW, "Invalid handler");
		return 1;
	}

	if(!(0 <= level <= 10))
	{
		ChatMsg(playerid, YELLOW, "Invalid level");
		return 1;
	}

	sif_debug_get_handler_name(handler, handlername);

	sif_debug_plevel(playerid, handler, level);

	ChatMsg(playerid, YELLOW, " >  SIF debug level for '%s': %d", handlername, level);

	return 1;
}

ACMD:sifgdebug[5](playerid, params[])
{
	new
		handlername[32],
		level,
		handler;

	if(sscanf(params, "s[32]d", handlername, level))
	{
		ChatMsg(playerid, YELLOW, " >  Usage: /sifgdebug [handlername] [level]");
		return 1;
	}

	handler = sif_debug_handler_search(handlername);

	if(handler == -1)
	{
		ChatMsg(playerid, YELLOW, "Invalid handler");
		return 1;
	}

	if(!(0 <= level <= 10))
	{
		ChatMsg(playerid, YELLOW, "Invalid level");
		return 1;
	}

	sif_debug_get_handler_name(handler, handlername);

	sif_debug_level(handler, level);

	ChatMsg(playerid, YELLOW, " >  Global SIF debug level for '%s': %d", handlername, level);

	return 1;
}

ACMD:dbl[5](playerid)
{
	#if defined SIF_USE_DEBUG_LABELS
		if(IsPlayerToggledAllDebugLabels(playerid))
		{
			HideAllDebugLabelsForPlayer(playerid);
			ChatMsg(playerid, YELLOW, " >  Debug labels toggled off.");
		}
		else
		{
			ShowAllDebugLabelsForPlayer(playerid);
			ChatMsg(playerid, YELLOW, " >  Debug labels toggled on.");
		}
	#else
		ChatMsg(playerid, YELLOW, " >  Debug labels are not compiled.");
	#endif

	return 1;
}

ACMD:otp[5](playerid)
{
	new bool:otp = IsOTPModeEnabled();

	ToggleOTPMode(!otp);

	ChatMsgAdmins(1, YELLOW, " >  Modo de Chave Unica %s", !otp ? "ativado" : "desativado");

	return 1;
}
