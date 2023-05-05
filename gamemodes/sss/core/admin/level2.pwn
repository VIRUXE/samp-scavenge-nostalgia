#include <YSI\y_hooks>


hook OnGameModeInit()
{
	RegisterAdminCommand(STAFF_LEVEL_MODERATOR, ""C_BLUE"/comandoslvl2 - Ver a lista de comandos dos admins nível 2\n");
}


//static bool:visible[MAX_PLAYERS];

/*
hook OnPlayerConnect(playerid)
{
    visible[playerid] = true;
}
*/

new dutytick[MAX_PLAYERS];

ACMD:duty[2](playerid, params[])
{
	if(GetPlayerState(playerid) == PLAYER_STATE_SPECTATING) return ChatMsg(playerid, YELLOW, " >  Você deve sair do /spec.");
	
	if(GetTickCountDifference(GetTickCount(), dutytick[playerid]) < 5000) return ChatMsg(playerid, YELLOW, " >  Aguarde no mínimo 5 segundos para usar esse comando novamente.");
	
	new
	    lastattacker,
		lastweapon;
		
	if(IsPlayerCombatLogging(playerid, lastattacker, lastweapon)) return ChatMsg(playerid, RED, " >  Você está em combate, aguarde.");

	TogglePlayerAdminDuty(playerid, !IsPlayerOnAdminDuty(playerid), !isequal(params, "aqui", true));

    dutytick[playerid] = GetTickCount();
    
	return 1;
}

ACMD:ir[2](playerid, params[])
{
	if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET) return 6;

	new targetId;

	if(sscanf(params, "r", targetId)) return ChatMsg(playerid, YELLOW, " >  Use: /ir [playerid]");

	if(!IsPlayerConnected(targetId)) return 4;

	if(GetPlayerState(targetId) == PLAYER_STATE_SPECTATING) return ChatMsg(playerid, RED, " > O admin está no modo /spec. Você não pode ir até ele.");

	TeleportPlayerToPlayer(playerid, targetId);

	FreezePlayer(targetId, SEC(1));

//	ChatMsg(playerid, YELLOW, " >  Você teleportou até %P", targetId);
	ChatMsg(targetId, YELLOW, "admin/teleported-to", playerid);
	ChatMsgAdmins(1, BLUE, "[Admin] %P"C_BLUE" (%d) teleportou-se até %P"C_BLUE" (%d)", playerid, playerid, targetId, targetId);

	return 1;
}

ACMD:puxar[2](playerid, params[])
{
	if(!(IsPlayerOnAdminDuty(playerid)) && GetPlayerAdminLevel(playerid) < STAFF_LEVEL_SECRET) return 6;

	new targetid;

	if(sscanf(params, "r", targetid)) return ChatMsg(playerid, YELLOW, " >  Use: /puxar [playerid]");

	if(!IsPlayerConnected(targetid)) return 4;

	if(GetPlayerState(targetid) == PLAYER_STATE_SPECTATING) return ChatMsg(playerid, RED, " > O jogador está no modo /spec. Você não pode puxar ele.");

	TeleportPlayerToPlayer(targetid, playerid);

	ChatMsgAdmins(1, BLUE, "[Admin] %P"C_BLUE" (%d) puxou %P"C_BLUE" (%d)", playerid, playerid, targetid, targetid);

	return 1;
}

ACMD:congelar[2](playerid, params[])
{
	new targetid, delay;

	if(sscanf(params, "dD(0)", targetid, delay)) return ChatMsg(playerid, YELLOW, " >  Use: /congelar [playerid] [segundos]");

	if(GetPlayerAdminLevel(targetid) >= GetPlayerAdminLevel(playerid) && playerid != targetid) return 3;

	if(!IsPlayerConnected(targetid)) return 4;

	FreezePlayer(targetid, delay * 1000, true);
	
	if(delay > 0) {
		ChatMsg(playerid, YELLOW, " >  Você congelou %P"C_YELLOW" por %d segundos", targetid, delay);
		ChatMsg(targetid, YELLOW, "FREEZETIMER", delay);
	} else {
		ChatMsg(playerid, YELLOW, " >  Você congelou %P", targetid);
		ChatMsg(targetid, YELLOW, "FREEZEFROZE");
	}

	return 1;
}

ACMD:descongelar[2](playerid, params[])
{
	new targetid;

	if(sscanf(params, "d", targetid)) return ChatMsg(playerid, YELLOW, " >  Use: /descongelar [playerid]");

	if(!IsPlayerConnected(targetid)) return 4;

	UnfreezePlayer(targetid);

	ChatMsg(playerid, YELLOW, " >  Você descongelou %P", targetid);
	ChatMsg(targetid, YELLOW, "FREEZEUNFRE");

	return 1;
}

ACMD:verban[2](playerid, params[])
{
	if(!(3 < strlen(params) < MAX_PLAYER_NAME)) return ChatMsg(playerid, RED, " >  Nome de player inválido: '%s'.", params);

	new name[MAX_PLAYER_NAME];

	strcat(name, params);

	if(IsPlayerBanned(name))
		ShowBanInfo(playerid, name);
	else
		ChatMsg(playerid, YELLOW, " >  O jogador '%s' "C_BLUE"não está "C_YELLOW"banido.", name);

	return 1;
}

/*
ACMD:invisible[2](playerid, params[])
{
	if(!IsPlayerOnAdminDuty(playerid))
	{
		ChatMsg(playerid, YELLOW, " >  Você deve estar em /duty para usar esse comando.");
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
			
	    ChatMsg(playerid, YELLOW, " >  Modo invisível desativado.");
	    visible[playerid] = true;
	}
	else
	{
	    if(GetPlayerGender(playerid) == GENDER_MALE)
			SetPlayerSkin(playerid, 45);

		else
			SetPlayerSkin(playerid, 251);
			
	    ChatMsg(playerid, YELLOW, " >  Modo invisível ativado.");
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
    strcat(stringlvl2, "{FFFF00}Comandos dos Admins Nível 2:\n");
    strcat(stringlvl2, "{FF0000}\n");
    strcat(stringlvl2, ""C_BLUE"/duty - Entrar em modo admin\n");
    strcat(stringlvl2, ""C_BLUE"/field - Ver comandos de field no servidor\n");
    strcat(stringlvl2, ""C_BLUE"/rdpon - /rdpoff - Ver zonas onde possuí fields nas bases (cercado com uma corda em todas as pontas)\n");
    strcat(stringlvl2, ""C_BLUE"/ir /puxar - Teleportar players\n");
    strcat(stringlvl2, ""C_BLUE"/banidos - Lista de banidos do servidor\n");
    strcat(stringlvl2, ""C_BLUE"/verban - Checar se está banido\n");
    strcat(stringlvl2, ""C_BLUE"/setmotd - Mudar as notícias do servidor\n");
    strcat(stringlvl2, ""C_BLUE"/setglobal - Mudar o tempo de enviar mensagem no global\n");
//    strcat(stringlvl2, ""C_BLUE"/invisible - Ficar invisível (Ajuda detectar wallhack's)\n");
    ShowPlayerDialog(playerid, 12402, DIALOG_STYLE_MSGBOX, "Admin 2", stringlvl2, "Fechar", "");
    return 1;
}
