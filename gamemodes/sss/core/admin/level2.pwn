#include <YSI\y_hooks>


hook OnGameModeInit()
{
	RegisterAdminCommand(STAFF_LEVEL_MODERATOR, ""C_BLUE"/comandoslvl2 - Ver a lista de comandos dos admins n�vel 2\n");
}


//static bool:visible[MAX_PLAYERS];

/*
hook OnPlayerConnect(playerid)
{
    visible[playerid] = true;
}
*/

new dutytick[MAX_PLAYERS];

ACMD:duty[2](playerid)
{
	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING)
	{
		ChatMsg(playerid, YELLOW, " >  Voc� deve sair do /spec.");
		return 1;
	}
	
	if(GetTickCountDifference(GetTickCount(), dutytick[playerid]) < 5000)
	{
	    ChatMsg(playerid, YELLOW, " >  Aguarde no m�nimo 5 segundos para usar esse comando novamente.");
		return 1;
	}
	
	new
	    lastattacker,
		lastweapon;
		
	if(IsPlayerCombatLogging(playerid, lastattacker, lastweapon))
	{
	    ChatMsg(playerid, RED, " >  Voc� est� em Combate-LOG, aguarde.");
		return 1;
	}

	if(IsPlayerOnAdminDuty(playerid))
		TogglePlayerAdminDuty(playerid, false);
	else
		TogglePlayerAdminDuty(playerid, true);

    dutytick[playerid] = GetTickCount();
    
	return 1;
}

ACMD:ir[2](playerid, params[])
{
	if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET)
		return 6;

	new targetid;

	if(sscanf(params, "u", targetid))
	{
		ChatMsg(playerid, YELLOW, " >  Use: /ir [playerid]");
		return 1;
	}

	if(!IsPlayerConnected(targetid))
		return 4;

	TeleportPlayerToPlayer(playerid, targetid);

//	ChatMsg(playerid, YELLOW, " >  Voc� teleportou at� %P", targetid);
	//ChatMsgLang(targetid, YELLOW, "TELEPORTEDT", playerid);
	ChatMsgAdmins(1, BLUE, "[Admin-Log] "C_BLUE"%p(id:%d) Teleportou-se at� %p(id:%d)", playerid, playerid, targetid, targetid);

	return 1;
}

ACMD:puxar[2](playerid, params[])
{
	if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET)
		return 6;

	new targetid;

	if(sscanf(params, "u", targetid))
	{
		ChatMsg(playerid, YELLOW, " >  Use: /puxar [playerid]");
		return 1;
	}

	if(!IsPlayerConnected(targetid))
		return 4;

	TeleportPlayerToPlayer(targetid, playerid);

//	ChatMsg(playerid, YELLOW, " >  Voc� trouxe at� voc�: %P", targetid);
	ChatMsgAdmins(1, BLUE, "[Admin-Log] "C_BLUE"%p(id:%d) Puxou "C_BLUE"%p(id:%d)", playerid, playerid, targetid, targetid);
	//ChatMsgLang(targetid, YELLOW, "TELEPORTEDY", playerid);
	return 1;
}

ACMD:congelar[2](playerid, params[])
{
	new targetid, delay;

	if(sscanf(params, "dD(0)", targetid, delay))
		return ChatMsg(playerid, YELLOW, " >  Use: /congelar [playerid] [segundos]");

	if(GetPlayerAdminLevel(targetid) >= GetPlayerAdminLevel(playerid) && playerid != targetid)
		return 3;

	if(!IsPlayerConnected(targetid))
		return 4;

	FreezePlayer(targetid, delay * 1000, true);
	
	if(delay > 0)
	{
		ChatMsg(playerid, YELLOW, " >  Voc� congelou %P por %d segundos", targetid, delay);
		ChatMsgLang(targetid, YELLOW, "FREEZETIMER", delay);
	}
	else
	{
		ChatMsg(playerid, YELLOW, " >  Voc� congelou %P", targetid);
		ChatMsgLang(targetid, YELLOW, "FREEZEFROZE");
	}

	return 1;
}

ACMD:descongelar[2](playerid, params[])
{
	new targetid;

	if(sscanf(params, "d", targetid))
		return ChatMsg(playerid, YELLOW, " >  Use: /descongelar [playerid]");

	if(!IsPlayerConnected(targetid))
		return 4;

	UnfreezePlayer(targetid);

	ChatMsg(playerid, YELLOW, " >  Voc� descongelou %P", targetid);
	ChatMsgLang(targetid, YELLOW, "FREEZEUNFRE");

	return 1;
}

ACMD:verban[2](playerid, params[])
{
	if(!(3 < strlen(params) < MAX_PLAYER_NAME))
	{
		ChatMsg(playerid, RED, " >  Nome de player inv�lido: '%s'.", params);
		return 1;
	}

	new name[MAX_PLAYER_NAME];

	strcat(name, params);

	if(IsPlayerBanned(name))
		ShowBanInfo(playerid, name);

	else
		ChatMsg(playerid, YELLOW, " >  Player '%s' "C_BLUE"n�o est� "C_YELLOW"banido.", name);

	return 1;
}

ACMD:setmotd[2](playerid, params[])
{
	if(sscanf(params, "s[128]", gMessageOfTheDay))
	{
		ChatMsg(playerid, YELLOW, " >  Use: /setmotd [Mensagem]");
		return 1;
	}

	new admNm[24];GetPlayerName(playerid, admNm, 24);
	ChatMsgAll(0xC457EBAA, "[Admin]: %s(id:%d) atualizou o motd para: "C_WHITE"%s", admNm, playerid, gMessageOfTheDay);

	return 1;
}

/*
ACMD:invisible[2](playerid, params[])
{
	if(!IsPlayerOnAdminDuty(playerid))
	{
		ChatMsg(playerid, YELLOW, " >  Voc� deve estar em /duty para usar esse comando.");
	    return 1;
	}
	
	foreach(new i : Player)
	{
	    if(!IsPlayerNPC(i) && !IsPlayerOnAdminDuty(i) && i != playerid)
		{
	        if(visible[playerid] == false)
			{
			    ShowPlayerForPlayer(playerid, i);
			}
			else
			{
			    RemovePlayerForPlayer(playerid, i);
			}
		}
	}
	
	
	if(visible[playerid] == false)
	{
	    if(GetPlayerGender(playerid) == GENDER_MALE)
			SetPlayerSkin(playerid, 217);

		else
			SetPlayerSkin(playerid, 211);
			
	    ChatMsg(playerid, YELLOW, " >  Modo invis�vel desativado.");
	    visible[playerid] = true;
	}
	else
	{
	    if(GetPlayerGender(playerid) == GENDER_MALE)
			SetPlayerSkin(playerid, 45);

		else
			SetPlayerSkin(playerid, 251);
			
	    ChatMsg(playerid, YELLOW, " >  Modo invis�vel ativado.");
	    visible[playerid] = false;
	}
	
	return 1;
}

hook OnPlayerStreamIn(playerid, forplayerid)
{
    if(GetTickCountDifference(GetTickCount(), GetPlayerServerJoinTick(playerid)) > 10000)
	{
	    if(GetTickCountDifference(GetTickCount(), GetPlayerServerJoinTick(forplayerid)) > 10000)
		{
			if(visible[playerid] == false)
			{
			    if(!IsPlayerNPC(forplayerid) && !IsPlayerNPC(playerid) && !IsPlayerOnAdminDuty(forplayerid))
			    	RemovePlayerForPlayer(playerid, forplayerid);
			}
			if(visible[forplayerid] == false)
			{
			    if(!IsPlayerNPC(playerid) && !IsPlayerNPC(forplayerid) && !IsPlayerOnAdminDuty(playerid))
			    	RemovePlayerForPlayer(forplayerid, playerid);
			}
		}
	}
}

ShowPlayerForPlayer(playerid, toplayerid)
{
    new BitStream:bs = BS_New();

    BS_WriteValue(
        bs,
        PR_UINT16, playerid
    );

    BS_RPC(bs, toplayerid, 32, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
    BS_Delete(bs);
    return 1;
}

RemovePlayerForPlayer(playerid, toplayerid)
{
    new BitStream:bs = BS_New();

    BS_WriteValue(
        bs,
        PR_UINT16, playerid
    );

    BS_RPC(bs, toplayerid, 163, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
    BS_Delete(bs);
    return 1;
}
*/

ACMD:comandoslvl2[2](playerid)
{
    new stringlvl2[800];
    strcat(stringlvl2, "{FFFF00}Comandos dos Admins N�vel 2:\n");
    strcat(stringlvl2, "{FF0000}\n");
    strcat(stringlvl2, ""C_BLUE"/duty - Entrar em modo admin\n");
    strcat(stringlvl2, ""C_BLUE"/field - Ver comandos de field no servidor\n");
    strcat(stringlvl2, ""C_BLUE"/rdpon - /rdpoff - Ver zonas onde poss�i fields nas bases (cercado com uma corda em todas as pontas)\n");
    strcat(stringlvl2, ""C_BLUE"/ir /puxar - Teleportar players\n");
    strcat(stringlvl2, ""C_BLUE"/banidos - Lista de banidos do servidor\n");
    strcat(stringlvl2, ""C_BLUE"/verban - Checar se est� banido\n");
    strcat(stringlvl2, ""C_BLUE"/setmotd - Mudar as not�cias do servidor\n");
    strcat(stringlvl2, ""C_BLUE"/setglobal - Mudar o tempo de enviar mensagem no global\n");
//    strcat(stringlvl2, ""C_BLUE"/invisible - Ficar invis�vel (Ajuda detectar wallhack's)\n");
    ShowPlayerDialog(playerid, 12402, DIALOG_STYLE_MSGBOX, "Admin 2", stringlvl2, "Fechar", "");
    return 1;
}
