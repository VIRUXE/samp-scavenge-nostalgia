#include <YSI\y_hooks>

static
	clan_Name[MAX_PLAYERS][16],
	bool:clan_Owner[MAX_PLAYERS],
	Convite[MAX_PLAYERS] = {-1, ...},
	Text3D:clan_Tag[MAX_PLAYERS] = {Text3D:INVALID_3DTEXT_ID, ...},
	clan_Tick[MAX_PLAYERS];

hook OnPlayerConnect(playerid)
{
	if(strlen(clan_Name[playerid]) >= 5) {
		new file[32];

		format(file, sizeof(file), "INI_Clan/%s.ini", clan_Name[playerid]);

		if(!dini_Exists(file))
		{
			clan_Name[playerid][0] = EOS;

			return ChatMsg(playerid, RED, " > Seu clan foi exclu�do enquanto voc� estava offline.");
		} else {
			if(dini_Int(file, "Membros") >= 5)
				return ChatMsg(playerid, RED, " > Voc� foi expulso enquanto estava offline e o clan lotou.");
		}
	}
	
	return 1;
}

hook OnPlayerDisconnect(playerid)
{
	DestroyDynamic3DTextLabel(clan_Tag[playerid]);
	clan_Tag[playerid] = Text3D:INVALID_3DTEXT_ID;
	
	foreach(new i : Player)
	{
	    if(!IsPlayerAllyForPlayer(playerid, i))
	        continue;

   		RemovePlayerMapIcon(i, playerid);
	} 

    Convite[playerid] = -1; 

	return 1;
}

/*==============================================================================

	Commands

==============================================================================*/

CMD:ajudaclan(playerid)
{
    new stringajudaclan[380];
    strcat(stringajudaclan, "{FFFF00}Comandos de CLAN:\n");
    strcat(stringajudaclan, " \n");
	strcat(stringajudaclan, "{33AA33}/procurarclan {FFFFFF}- Envia um an�ncio buscando um clan\n");
	strcat(stringajudaclan, "{33AA33}/criarclan {FFFFFF}- Cria um clan\n");
	strcat(stringajudaclan, "{33AA33}/convidarclan {FFFFFF}- Convida um jogador para o clan\n");
	strcat(stringajudaclan, "{33AA33}/expulsarclan {FFFFFF}- Expulsa um jogador do seu clan\n");
	strcat(stringajudaclan, "{33AA33}/sairclan {FFFFFF}- Sair do clan atual\n");
	strcat(stringajudaclan, "{33AA33}/deletarclan {FFFFFF}- Deleta o clan que voc� criou\n");
    ShowPlayerDialog(playerid, 9147, DIALOG_STYLE_MSGBOX, "Ajuda CLAN:", stringajudaclan, "Fechar", "");
    return 1;
}

CMD:procurarclan(playerid)
{
	if(!IsPlayerSpawned(playerid))
	    return ChatMsg(playerid, RED, " > Voc� deve nascer antes.");
	    
    if(GetTickCountDifference(GetTickCount(), clan_Tick[playerid]) < 5000)
        return ChatMsg(playerid, RED, " > Aguarde para usar esse comando novamente.");
    
	if(strlen(clan_Name[playerid]) > 1)
	    return ChatMsg(playerid, RED, " > Voc� j� possui um clan.");

	ChatMsgAll(CHAT_CLAN, "[CLAN] %p(id:%d) Est� procurando um clan.", playerid, playerid);
	
	clan_Tick[playerid] = GetTickCount();
	return 1;
}

CMD:criarclan(playerid, params[])
{
	if(!IsPlayerSpawned(playerid))
	    return ChatMsg(playerid, RED, " > Voc� deve nascer antes.");
	          
    if(strlen(clan_Name[playerid]) > 1)
	    return ChatMsg(playerid, RED, " > Voc� j� possui um clan.");

    if(strlen(params) < 1)
        return ChatMsg(playerid, RED, " > Use /criarclan [Nome do CLAN]");
        
	if(strlen(params) < 5)
	    return ChatMsg(playerid, RED, " > O nome do clan deve ter no m�nimo 5 digitos.");

    if(strlen(params) > 16)
	    return ChatMsg(playerid, RED, " > O nome do clan deve ter no m�ximo 16 digitos.");

	if(HaveSymbols(params) > 0)
	    return ChatMsg(playerid, RED, " > O nome do clan deve conter apenas letras e n�meros.");

	new file[32];

	format(file, sizeof(file), "INI_Clan/%s.ini", params);

	if(dini_Exists(file))
		return ChatMsg(playerid, RED, " > O nome do clan j� existe, escolha outro.");

	format(clan_Name[playerid], 16, "%s", params);
    
	clan_Owner[playerid] = true;
	
    ChatMsgAll(CHAT_CLAN, "[CLAN] %p(id:%d) Fundou o clan: %s.", playerid, playerid, params);
      
	dini_Create(file);
	dini_IntSet(file, "Membros", 1);
    SavePlayerIniData(playerid);
	return 1;
}

CMD:deletarclan(playerid)
{
	if(!IsPlayerSpawned(playerid))
	    return ChatMsg(playerid, RED, " > Voc� deve nascer antes.");
	           
    if(!clan_Owner[playerid])
	    return ChatMsg(playerid, RED, " > Voc� n�o � dono de um clan");

	clan_Owner[playerid] = false;

    ChatMsgAll(CHAT_CLAN, "[CLAN] %p(id:%d) Deletou o clan: %s.", playerid, playerid, clan_Name[playerid]);

    foreach(new i : Player)
	{
	    if(!IsPlayerAllyForPlayer(playerid, i))
	        continue;
	        
   		ClanNameTagUpdate(i);
   		
   		clan_Name[i][0] = EOS;
	}

	new file[32];

	format(file, sizeof(file), "INI_Clan/%s.ini", clan_Name[playerid]);

	dini_Remove(file);
	
	clan_Name[playerid][0] = EOS;
	SavePlayerIniData(playerid);
	return 1;
}

CMD:sairclan(playerid)
{       
    if(strlen(clan_Name[playerid]) < 5)
	    return ChatMsg(playerid, RED, " > Voc� n�o possui um clan");

    if(clan_Owner[playerid])
	    return ChatMsg(playerid, RED, " > Voc� � dono do clan portanto n�o pode sair. Use /deletarclan");

    ChatMsgAll(CHAT_CLAN, "[CLAN] %p(id:%d) Saiu do clan %s.", playerid, playerid, clan_Name[playerid]);

	new file[32];

	format(file, sizeof(file), "INI_Clan/%s.ini", clan_Name[playerid]);

	if(dini_Exists(file))
		dini_IntSet(file, "Membros", dini_Int(file, "Membros") - 1);

    clan_Name[playerid][0] = EOS;
    ClanNameTagUpdate(playerid);
   	SavePlayerIniData(playerid);

	return 1;
}

CMD:expulsarclan(playerid, params[])
{
	if(!IsPlayerSpawned(playerid)) 
		return ChatMsg(playerid, RED, " > Voc� deve nascer antes.");
	          
	if(!clan_Owner[playerid])
	    return ChatMsg(playerid, RED, " > Voc� n�o � dono de um clan");

	new arg[MAX_PLAYER_NAME];
	
	if(sscanf(params, "s[24]", arg)) 
		return ChatMsg(playerid, YELLOW, " >  Use: /expulsarclan [id/nome]");

	if(isnumeric(arg)) { //passou ID e jogador est� conectado
		new id = strval(params);

		if(!IsPlayerConnected(id))
	    	return ChatMsg(playerid, RED, " > Jogador n�o conectado.");
	    
    	if(!IsPlayerAllyForPlayer(playerid, id))
        	return ChatMsg(playerid, RED, " > Este jogador n�o est� no seu clan.");

		foreach(new i : Player)
		{
			if(IsPlayerAllyForPlayer(playerid, i))
				continue;
				
			ChatMsg(i, CHAT_CLAN, "[CLAN] %p(id:%d) Expulsou %p(id:%d)!", playerid, playerid, id, id);
		}

		clan_Name[id][0] = EOS;
		ClanNameTagUpdate(id);
		SavePlayerIniData(id);
	} else {
		new idByName = GetPlayerIDFromName(params);

		if(idByName != INVALID_PLAYER_ID) { //passou NOME e jogador est� conectado
			if(!IsPlayerConnected(idByName))
				return ChatMsg(playerid, RED, " > Jogador n�o conectado.");
			
			if(!IsPlayerAllyForPlayer(playerid, idByName))
				return ChatMsg(playerid, RED, " > Este jogador n�o est� no seu clan.");

			foreach(new i : Player)
			{
				if(IsPlayerAllyForPlayer(playerid, i))
					continue;
					
				ChatMsg(i, CHAT_CLAN, "[CLAN] %p(id:%d) Expulsou %p(id:%d)!", playerid, playerid, idByName, idByName);
			}

			clan_Name[idByName][0] = EOS;
			ClanNameTagUpdate(idByName);
			SavePlayerIniData(idByName);
		} else { //passou NOME e jogador n�o est� conectado
			new file[16 + MAX_PLAYER_NAME];

			format(file, sizeof(file), "INI_Data/%s.ini", arg);

			if(dini_Exists(file)) {
				//verificar se � ally
				if (strcmp(dini_Get(file, "Clan"), clan_Name[playerid]))
					return ChatMsg(playerid, RED, " > Este jogador n�o est� no seu clan.");

				dini_Set(file, "Clan", "");
			} else return ChatMsg(playerid, RED, " > Este jogador n�o est� no seu clan.");

			foreach(new i : Player)
			{
				if(IsPlayerAllyForPlayer(playerid, i))
					continue;
					
				ChatMsg(i, CHAT_CLAN, "[CLAN] %p(id:%d) Expulsou %s!", playerid, playerid, arg);
			}
		}
	}

	new file[32];

	format(file, sizeof(file), "INI_Clan/%s.ini", clan_Name[playerid]);

	if(dini_Exists(file))
		dini_IntSet(file, "Membros", dini_Int(file, "Membros") - 1);
    
	return 1;
}

CMD:convidarclan(playerid, params[])
{	    
	new targetid;

	if(!IsPlayerSpawned(playerid))
	    return ChatMsg(playerid, RED, " > Voc� deve nascer antes.");
        
    if(!clan_Owner[playerid])
	    return ChatMsg(playerid, RED, " > Voc� n�o � dono de um clan");

	if(sscanf(params, "d", targetid)) 
		return ChatMsg(playerid, YELLOW, " >  Use: /convidarclan [id]");

//	new id = strval(params);

	if(!IsPlayerConnected(targetid))
	    return ChatMsg(playerid, RED, " > Jogador n�o conectado.");

    if(strlen(clan_Name[targetid]) > 4)
	    return ChatMsg(playerid, RED, " > Este jogador j� possui um clan");

    ChatMsg(targetid, CHAT_CLAN, "[CLAN] %p(id:%d) convidou voc� para o clan: %s.", playerid, playerid, clan_Name[playerid]);
    ChatMsg(targetid, CHAT_CLAN, "[CLAN] para aceitar: "C_GREEN"/aceitar");
    ChatMsg(targetid, CHAT_CLAN, "[CLAN] para recusar: "C_RED"/recusar");
    
    ChatMsg(playerid, CHAT_CLAN, "[CLAN] Convite enviado com sucesso!");
    
    Convite[targetid] = playerid;
	return 1;
}

CMD:aceitar(playerid)
{
	if(!IsPlayerSpawned(playerid))
	    return ChatMsg(playerid, RED, " > Voc� deve nascer antes.");
	          
	if(!IsPlayerConnected(Convite[playerid]))
	    return ChatMsg(playerid, RED, " > Convite expirado.");
	    
    if(strlen(clan_Name[Convite[playerid]]) < 5)
	    return ChatMsg(playerid, RED, " > Convite expirado.");

	new file[32];

	format(file, sizeof(file), "INI_Clan/%s.ini", clan_Name[Convite[playerid]]);

	if(dini_Exists(file))
	{
		if(dini_Int(file, "Membros") >= 5)
			return ChatMsg(playerid, RED, " > O clan est� lotado (limite 5 membros).");
	}
	    
    format(clan_Name[playerid], 16, "%s", clan_Name[Convite[playerid]]);
    
    ChatMsgAll(CHAT_CLAN, "[CLAN] %p(id:%d) � o mais novo membro do clan %s.", playerid, playerid, clan_Name[playerid]);
    
    foreach(new i : Player)
	{
	    if(!IsPlayerAllyForPlayer(playerid, i))
	        continue;

  		ClanNameTagUpdate(i);
	}
	
    ClanNameTagUpdate(playerid);
    
	dini_IntSet(file, "Membros", dini_Int(file, "Membros") + 1);
    SavePlayerIniData(Convite[playerid]);
    
    Convite[playerid] = -1; 
	return 1;
}

CMD:recusar(playerid)
{       
	if(!IsPlayerConnected(Convite[playerid]))
	    return ChatMsg(playerid, RED, " > Convite expirado.");

    if(strlen(clan_Name[Convite[playerid]]) < 5)
	    return ChatMsg(playerid, RED, " > Convite expirado.");

    ChatMsg(Convite[playerid], CHAT_CLAN, "[CLAN] %p(id:%d) recusou seu convite.", playerid, playerid);

    Convite[playerid] = -1;
	return 1;
}

ptask ClanNameTagUpdate_t[SEC(5)](playerid)
{
    ClanNameTagUpdate(playerid);
}

ClanNameTagUpdate(playerid)
{
	if(clan_Tag[playerid] != Text3D:INVALID_3DTEXT_ID)
	{
	    DestroyDynamic3DTextLabel(clan_Tag[playerid]);
		clan_Tag[playerid] = Text3D:INVALID_3DTEXT_ID;
	}

	new
		players[MAX_PLAYERS],
		maxplayers,
		name[24];

	GetPlayerName(playerid, name, 24);

	foreach(new i : Player)
	{
		if(IsPlayerAllyForPlayer(playerid, i))
		{
			players[maxplayers++] = i;
		}
	}

	clan_Tag[playerid] = CreateDynamic3DTextLabelEx(
		name, CHAT_CLAN, 0.0, 0.0, 0.5, 300.0, playerid,
		.testlos = 0,
		.streamdistance = 300.0,
		.players = players,
		.maxplayers = maxplayers);
}

ptask UpdatePlayerClanGPS[500](playerid)
{
	foreach(new i : Player)
	{
		new
			BitStream:bs = BS_New();

		if(IsPlayerAllyForPlayer(playerid, i) && !IsPlayerOnAdminDuty(i))
		{
            BS_WriteValue(bs, PR_UINT16, playerid, PR_UINT32, 0x00FF0000);
            
            new
				Float:x,
				Float:y,
				Float:z;
				
            GetPlayerPos(i, x, y, z);
            SetPlayerMapIcon(playerid, i, x, y, z, 62, 0, MAPICON_GLOBAL);
		}
		else
		{
		    BS_WriteValue(bs, PR_UINT16, playerid, PR_UINT32, GetPlayerColor(playerid));
		    RemovePlayerMapIcon(playerid, i);
		}

		PR_SendRPC(bs, i, 72); // SetPlayerColor
	    BS_Delete(bs);
	}
}

/*==============================================================================

	Functions

==============================================================================*/

stock IsPlayerAllyForPlayer(playerid, allyid)
{
	if(!IsPlayerConnected(playerid) || !IsPlayerConnected(allyid))
	    return 0;

/*    if(!IsPlayerConnected(allyid))
	    return 0;*/
	    
	if(playerid == allyid)
	    return 0;

	if(strlen(clan_Name[playerid]) < 5)
	    return 0;

	if(strlen(clan_Name[allyid]) < 5)
	    return 0;
	    
	return !strcmp(clan_Name[playerid], clan_Name[allyid]);
}

forward GetPlayerClan(playerid);
stock GetPlayerClan(playerid)
	return clan_Name[playerid];

stock SetPlayerClan(playerid, Clan[])
{
    if(!IsPlayerConnected(playerid))
	    return 0;

	format(clan_Name[playerid], 16, "%s", Clan);
	return 1;
}

stock IsPlayerClanOwner(playerid)
	return clan_Owner[playerid];

stock SetPlayerClanOwner(playerid, bool:Owner){
    if(!IsPlayerConnected(playerid))
	    return 0;
	    
    clan_Owner[playerid] = Owner;
    return 1;
}

stock HaveSymbols(const text[]) 
{
	new detects = 0;

	for (new i = 0, j = strlen(text); i < j; i++) {
		if(!(
			(text[i] >= 'a' && text[i] <= 'z') || 
			(text[i] >= 'A' && text[i] <= 'Z') || 
			!(text[i] > '9' || text[i] < '0')
			)) detects++;
	}

	return detects;
}
