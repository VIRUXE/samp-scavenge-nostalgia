/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/

#include <YSI\y_hooks>

new bool:PlayerVip[MAX_PLAYERS];
	
#define VIP_COLOR 0xFFAA0000

/*==============================================================================

	Interno

==============================================================================*/

ACMD:setplayervip[5](playerid, params[])
{
	new playervipb;

	if(sscanf(params, "d", playervipb))
	{
		ChatMsg(playerid, RED, " > Use: /setplayervip [playerid]");
		return 1;
	}
	
	if(!IsPlayerConnected(playervipb))
	    return ChatMsg(playerid, RED, " > Player não se encontra online.");
	    
	PlayerVip[playervipb] = !PlayerVip[playervipb];
	
	if(PlayerVip[playervipb]){
		SetPlayerColor(playervipb, VIP_COLOR);

		ChatMsgAll(PINK, " > %p(%d) É o mais novo VIP do servidor. Parabéns!! :D", playervipb, playervipb);
	}
	else {
	    SetPlayerColor(playervipb, 0xB8B8B800);
	    
		ChatMsg(playervipb, RED, " > Seu vip foi removido.");
	}
	return 1;
}

CMD:ajudavip(playerid)
{
    new stringajudavip[1300];
    strcat(stringajudavip, "{FFFF00}Benefícios dos VIPS: {33AA33}(Preço: 1 Mês - R$20,00 | 2 Meses - R$35,00\n");
    strcat(stringajudavip, " \n");
	strcat(stringajudavip, "{FFAA00}- Tem uma maior variedade de spawns ap�s morrer\n");
//	strcat(stringajudavip, "{FFAA00}- Consegue trocar o nickname usando {FFFFFF}/mudarnick\n");
	strcat(stringajudavip, "{FFAA00}- Consegue trocar o estilo de luta usando {FFFFFF}/mudarluta\n");
	strcat(stringajudavip, "{FFAA00}- Nickname colorido (destacado)\n");
	strcat(stringajudavip, "{FFAA00}- Cargo VIP permanente no discord\n");
	strcat(stringajudavip, "{FFAA00}- Chat e canal de voz VIP no discord\n");
	strcat(stringajudavip, "{FFAA00}- Consegue se matar usando {FFFFFF}/kill\n");
	strcat(stringajudavip, "{FFAA00}- Consegue fazer um anúncio vip no chat usando {FFFFFF}/avip\n");
	strcat(stringajudavip, "{FFAA00}- Consegue alterar a cor de veículos usando {FFFFFF}/pintar\n");
	strcat(stringajudavip, "{FFAA00}- Monta e desmonta estruturas 3x mais rápido\n");
	strcat(stringajudavip, "{FFAA00}- Consegue consertar o veículo 3x mais rápido\n");
	strcat(stringajudavip, "{FFAA00}- Consegue resetar o status (Score, Spree, Mortes) com {FFFFFF}/resetarstatus\n");
	strcat(stringajudavip, "{FFAA00}- Consegue colocar uma frase de login destacada para todos com {FFFFFF}/frase\n");
	strcat(stringajudavip, "{FFAA00}- Spawna sem fome (jogadores sem vip nascem com 20% de fome faltando)\n");
	strcat(stringajudavip, "{FFAA00}- Recebe o dobro de kills (score) ao eliminar algum jogador\n");
	strcat(stringajudavip, "{FFAA00}- Consegue trocar a skin usando {FFFFFF}/skin\n");
	strcat(stringajudavip, "{FFAA00}- Nasce com chave de roda, chave de fenda, mapa, mochila pequena e um bast�o\n");
    ShowPlayerDialog(playerid, 9146, DIALOG_STYLE_MSGBOX, "Ajuda VIP:", stringajudavip, "Fechar", "");
    return 1;
}

/*==============================================================================

	Beneficios/Comandos

==============================================================================*/

new bool:aviptimer[MAX_PLAYERS];

CMD:avip(playerid, params[])
{
    if(!PlayerVip[playerid]) return ChatMsg(playerid, RED, "> Esse comando é apenas para jogadores VIP.");
	if(aviptimer[playerid] == true) return ChatMsg(playerid, RED, "Erro: aguarde 3 minutos para usar esse comando novamente.");

    new Anuncio[100];

	if(sscanf(params, "s[100]", Anuncio))
	{
		ChatMsg(playerid, RED, " > Use: /avip [anúncio]");
		return 1;
	}

	new name[24];
	GetPlayerName(playerid, name, 24);

	ChatMsgAll(VIP_COLOR, "[An�ncio-VIP] {FFFFFF}(%d) %s: {FFAA00}%s", playerid, name, Anuncio);

	aviptimer[playerid] = true;
	defer DesTempAVip(playerid);

	return 1;
}

timer DesTempAVip[3000](playerid)
{
    aviptimer[playerid] = false;
}

CMD:resetarstatus(playerid){
	if(!PlayerVip[playerid]) return ChatMsg(playerid, RED, " > Esse comando é apenas para jogadores VIP.");
	SetPlayerScore(playerid, 0);
	SetPlayerDeathCount(playerid, 0);
	SetPlayerSpree(playerid, 0);
	SavePlayerIniData(playerid);
	return 1;
}

CMD:skin(playerid, params[]){
	new skinid;
    if(!PlayerVip[playerid]) return ChatMsg(playerid, RED, " > Esse comando é apenas para jogadores VIP.");
	if(GetPlayerSkin(playerid) == 287) return ChatMsg(playerid, RED, " > Você não pode trocar sua skin usando uma Camuflagem.");
    if(sscanf(params, "d", skinid)) return ChatMsg(playerid, RED, " > Use: /skin [ID]");
	if(skinid > 311 || skinid < 1) return ChatMsg(playerid, RED, " > ID de skin inválido.");
	if(skinid == 211 || skinid == 217 || skinid == 287) return ChatMsg(playerid, RED, " > ID de skin inválido.");
	SetPlayerSkin(playerid, skinid);
	return 1;
}

CMD:pintar(playerid, params[]){
    if(!PlayerVip[playerid]) return ChatMsg(playerid, RED, " > Esse comando é apenas para jogadores VIP.");
    if(!IsPlayerInAnyVehicle(playerid)) return ChatMsg(playerid, RED, "{FF0000}[X] Você precisa está dentro de um veículo.");
    new Cor1 = strval(params), Cor2 = strval(params);
    if(sscanf(params, "ii", Cor1, Cor2)) return ChatMsg(playerid, RED, "{FFFF00}[X] Use : /pintar [0-255][0-255]");
    if(Cor1 < 0 || Cor1 > 255) return ChatMsg(playerid, -1, "{FFAA00}Cores de 0 a 255!");
    if(Cor2 < 0 || Cor2 > 255) return ChatMsg(playerid, -1, "{FFAA00}Cores de 0 a 255!");
    ChangeVehicleColor(GetPlayerVehicleID(playerid), Cor1, Cor2);
    ChatMsg(playerid, 0x54FF9FFF, "Você alterou a cor do seu veículo!");
    return true;
}

CMD:kill(playerid)
{
	if(!PlayerVip[playerid]) return ChatMsg(playerid, RED, " > Esse comando é apenas para jogadores VIP.");
	
	if(GetTickCountDifference(GetTickCount(), GetPlayerSpawnTick(playerid)) < 60000)
		return 2;

	SetPlayerHealth(playerid, 0.0);
	return 1;
}

CMD:mudarluta(playerid, params[]){
    if(!PlayerVip[playerid]) return ChatMsg(playerid, RED, " > Esse comando é apenas para jogadores VIP.");
    
	new lutaid;
    if(sscanf(params, "d", lutaid)) return ChatMsg(playerid, RED, " > Use: /mudarluta [1-4]");
    
    if(lutaid == 1)
        SetPlayerFightingStyle(playerid, FIGHT_STYLE_KUNGFU);
	else if(lutaid == 2)
	    SetPlayerFightingStyle(playerid, FIGHT_STYLE_KNEEHEAD);
	else if(lutaid == 3)
	    SetPlayerFightingStyle(playerid, FIGHT_STYLE_ELBOW);
	else
	    SetPlayerFightingStyle(playerid, FIGHT_STYLE_GRABKICK);
	    
	ChatMsg(playerid, VIP_COLOR, " > Estilo de luta alterado com Sucesso.");
	return 1;
}

/*CMD:mudarnick(playerid,params[])
{
    if(!PlayerVip[playerid]) return ChatMsg(playerid, RED, " > Esse comando é apenas para jogadores VIP.");
    
	new
		novonome[24];

	if(!IsPlayerLoggedIn(playerid))
	{
		ChatMsgLang(playerid, YELLOW, "LOGGEDINREQ");
		return 1;
	}

	if(sscanf(params, "s[24]", novonome))
	{
		ChatMsg(playerid, YELLOW, "Use: /mudarnick [Novo Nome]");
		return 1;
	}
	else if(AccountExists(novonome))
	{
	    ChatMsg(playerid, YELLOW, "Este nick j� está registrado no Servidor.");
		return 1;
	}
	else if(strlen(novonome) > 21 || strlen(novonome) < 3)
	{
	    ChatMsg(playerid, YELLOW, "Seu nick deve ter entre 3 e 22 caracteres.");
		return 1;
	}
	else if(!IsValidUsername(novonome))
	{
	    ChatMsg(playerid, YELLOW, "O Nick que voc� digitou possui algum caracter inválido");
		return 1;
	}
	else
	{
     	new oldname[24];
	    GetPlayerName(playerid, oldname, 24);
	    SetAccountName(oldname, novonome);

	    CallLocalFunction("OnPlayerChangeName", "ss", oldname, novonome);

		SetPlayerName(playerid, novonome);

		new file[16 + MAX_PLAYER_NAME];

		format(file, sizeof(file), "INI_Data/%s.ini", oldname);
        dini_Remove(file);
        format(file, sizeof(file), "INI_Data/%s.ini", novonome);
		dini_Create(file);
        
		ChatMsgAll(RED, "[NICK]: %s(id:%d) alterou seu nickname para %s (usando /mudarnick)", oldname, playerid, novonome);

		log("[MudarNick] %s Alterou o nick para %s", oldname, novonome);

		ChatMsg(playerid, GREEN, " > Você alterou seu nome para "C_WHITE"%s"C_GREEN".", novonome);
		ChatMsg(playerid, GREEN, " > Quando for entrar no servidor novamente, altere seu nick no SA-MP.");
		KickPlayer(playerid, "Relogue com seu novo nick");
	}
	return 1;
}*/

/*==============================================================================

	Hooks

==============================================================================*/

hook OnPlayerSpawn(playerid)
{
	if(PlayerVip[playerid])
	{
 		SetPlayerColor(playerid, VIP_COLOR);
	}
}

hook OnPlayerSpawnNewChar(playerid){
    if(PlayerVip[playerid])
	{
//	    SetPlayerColor(playerid, VIP_COLOR);

	    new itemid;

		itemid = CreateItem(item_Satchel);
		GivePlayerBag(playerid, itemid);
		
		itemid = CreateItem(item_Wrench);
		AddItemToPlayer(playerid, itemid, true, false);

	    itemid = CreateItem(item_Screwdriver);
		AddItemToPlayer(playerid, itemid, true, false);

		itemid = CreateItem(item_Map);
		AddItemToPlayer(playerid, itemid, true, false);

		itemid = CreateItem(item_Bat);
		GiveWorldItemToPlayer(playerid, itemid);
	}
}

/*==============================================================================

	Fun��es

==============================================================================*/

stock IsPlayerVip(playerid){
	return PlayerVip[playerid];
}

stock SetPlayerVip(playerid, bool:vip){
    PlayerVip[playerid] = vip;
	return 1;
}
