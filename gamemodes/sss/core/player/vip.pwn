#include <YSI\y_hooks>

#define VIP_COLOR 0xFFAA0000
	
new bool:VIP[MAX_PLAYERS];

ACMD:setvip[5](playerid, params[])
{
	new targetId;

	if(sscanf(params, "u", targetId)) return ChatMsg(playerid, RED, " > Use: /setVIP [playerid]");
	
	if(targetId == INVALID_PLAYER_ID) return ChatMsg(playerid, RED, " > Esse jogador não se encontra online.");
	    
	VIP[targetId] = !VIP[targetId];
	
	if(VIP[targetId]) {
		SetPlayerColor(targetId, VIP_COLOR);

		ChatMsgAll(PINK, " > %p (%d) É o mais novo VIP do servidor. Parabéns!!! :D", targetId, targetId);
	} else {
	    SetPlayerColor(targetId, WHITE);
	    
		ChatMsg(targetId, RED, " > Seu vip foi removido.");
	}

	return 1;
}

CMD:ajudavip(playerid)
{
    new stringajudavip[1300];

    strcat(stringajudavip, "{FFFF00}Benefícios dos VIPS: {33AA33}(Preço: 1 Mês - R$20,00 | 2 Meses - R$35,00\n");
    strcat(stringajudavip, " \n");
	strcat(stringajudavip, "{FFAA00}- Tem uma maior variedade de spawns após morrer\n");
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
	strcat(stringajudavip, "{FFAA00}- Nasce com chave de roda, chave de fenda, mapa, mochila pequena e um bastão\n");
	strcat(stringajudavip, "{FFAA00}- Consegue reparar a lataria do veículo ao finalizar o reparo com ferramentas.\n");

    ShowPlayerDialog(playerid, 9146, DIALOG_STYLE_MSGBOX, "Ajuda VIP:", stringajudavip, "Fechar", "");

    return 1;
}

/*==============================================================================

	Beneficios/Comandos

==============================================================================*/

new bool:aviptimer[MAX_PLAYERS];

CMD:avip(playerid, params[])
{
    if(!VIP[playerid]) return ChatMsg(playerid, RED, "> Esse comando é apenas para jogadores VIP.");

	if(aviptimer[playerid] == true) return ChatMsg(playerid, RED, "Erro: aguarde 3 minutos para usar esse comando novamente.");

    new anuncio[150];

	if(sscanf(params, "s[150]", anuncio)) return ChatMsg(playerid, RED, " > Use: /avip [anúncio]");

	ChatMsgAll(VIP_COLOR, "[Anúncio-VIP] {FFFFFF}%p(id:%d): {FFAA00}%s", playerid, playerid, anuncio);

	aviptimer[playerid] = true;
	defer DesTempAVip(playerid);

	return 1;
}

timer DesTempAVip[SEC(3)](playerid)
{
    aviptimer[playerid] = false;
}

CMD:resetarstatus(playerid){
	if(!VIP[playerid]) return ChatMsg(playerid, RED, " > Esse comando é apenas para jogadores VIP.");

	SetPlayerScore(playerid, 0);
	SetPlayerDeathCount(playerid, 0);
	SetPlayerSpree(playerid, 0);
	SavePlayerIniData(playerid);

	return 1;
}

CMD:skin(playerid, params[]) {
	new skinid;

    if(!VIP[playerid]) return ChatMsg(playerid, RED, " > Esse comando é apenas para jogadores VIP.");

	if(GetPlayerSkin(playerid) == 287) return ChatMsg(playerid, RED, " > Você não pode trocar sua skin usando uma Camuflagem.");

    if(sscanf(params, "d", skinid)) return ChatMsg(playerid, RED, " > Use: /skin [ID]");

	if(skinid > 311 || skinid < 1) return ChatMsg(playerid, RED, " > ID de skin inválido.");

	if(skinid == 211 || skinid == 217 || skinid == 287) return ChatMsg(playerid, RED, " > ID de skin inválido.");

	SetPlayerSkin(playerid, skinid);

	return 1;
}

CMD:pintar(playerid, params[]) {
    if(!VIP[playerid]) return ChatMsg(playerid, RED, " > Esse comando é apenas para jogadores VIP.");

    if(!IsPlayerInAnyVehicle(playerid)) return ChatMsg(playerid, RED, " > Você precisa estár dentro de um veículo.");

    new cor1 = strval(params), cor2 = strval(params);

    if(sscanf(params, "ii", cor1, cor2)) return ChatMsg(playerid, RED, " > Use : /pintar [0-255][0-255]");

    if(cor1 < 0 || cor1 > 255) return ChatMsg(playerid, -1, "{FFAA00}Cores de 0 a 255!");

    if(cor2 < 0 || cor2 > 255) return ChatMsg(playerid, -1, "{FFAA00}Cores de 0 a 255!");

    ChangeVehicleColor(GetPlayerVehicleID(playerid), cor1, cor2);

    ChatMsg(playerid, 0x54FF9FFF, "Você alterou a cor do seu veículo!");

    return true;
}

CMD:kill(playerid)
{
	if(!VIP[playerid]) return ChatMsg(playerid, RED, " > Esse comando é apenas para jogadores VIP.");
	
	// Tem que aguardar 1 minuto
	if(GetTickCountDifference(GetTickCount(), GetPlayerSpawnTick(playerid)) < MIN(1)) return 2;

	SetPlayerHealth(playerid, 0.0);
	
	return 1;
}

CMD:mudarluta(playerid, params[]){
    if(!VIP[playerid]) return ChatMsg(playerid, RED, " > Esse comando é apenas para jogadores VIP.");
    
	new luta;

    if(sscanf(params, "d", luta)) return ChatMsg(playerid, RED, " > Use: /mudarluta [1-4]");
    
    if(luta == 1)
        SetPlayerFightingStyle(playerid, FIGHT_STYLE_KUNGFU);
	else if(luta == 2)
	    SetPlayerFightingStyle(playerid, FIGHT_STYLE_KNEEHEAD);
	else if(luta == 3)
	    SetPlayerFightingStyle(playerid, FIGHT_STYLE_ELBOW);
	else
	    SetPlayerFightingStyle(playerid, FIGHT_STYLE_GRABKICK);
	    
	return ChatMsg(playerid, VIP_COLOR, " > Estilo de luta alterado com Sucesso.");
}

CMD:mudarnick(playerid,params[])
{
    if(!VIP[playerid]) return ChatMsg(playerid, RED, " > Esse comando é apenas para jogadores VIP.");
    
	new nick[MAX_PLAYER_NAME];

	if(!IsPlayerLoggedIn(playerid)) return ChatMsgLang(playerid, YELLOW, "LOGGEDINREQ");

	if(sscanf(params, "s[24]", nick)) return ChatMsg(playerid, YELLOW, "Use: /mudarnick [nick]");

	if(AccountExists(nick)) return ChatMsg(playerid, YELLOW, "Este nick já está registrado no Servidor.");

	if(strlen(nick) > MAX_PLAYER_NAME || strlen(nick) < 3) return ChatMsg(playerid, YELLOW, "Seu nick deve ter entre 3 e 22 caracteres.");

	if(!IsValidUsername(nick)) return ChatMsg(playerid, YELLOW, "O Nick que você digitou possui algum caracter inválido");

	SetAccountName(GetPlayerNameEx(playerid), nick);

	SetPlayerName(playerid, nick);

	ChatMsgAll(RED, "  > %P(%d)"C_RED" alterou seu nickname para '%s' (usando /mudarnick)", playerid, playerid, nick);

	log("[NICK] %p alterou o nick para '%s'", playerid, nick);

	ChatMsg(playerid, GREEN, " > Você alterou seu nome para "C_WHITE"%s"C_GREEN".", nick);
	ChatMsg(playerid, GREEN, " > Quando for entrar no servidor novamente, altere seu nick no SA-MP.");
	
	KickPlayer(playerid, "Relogue com seu novo nick", true);

	return 1;
}

hook OnPlayerConnect(playerid) {
	if(GetPlayerAdminLevel(playerid) == 0 && Iter_Count(Player) >= 35 && !IsPlayerVip(playerid)) 
		return KickPlayer(playerid, "O servidor está lotado com 35 online. VIPS possuem 5 slots reservados!", true);

	return 1;
}

hook OnPlayerLogin(playerid) {
	if(VIP[playerid]) {
		SetPlayerColor(playerid, VIP_COLOR);

		ChatMsg(playerid, VIP_COLOR, " > Você é um jogador VIP! Obrigado por apoiar o servidor.");
	}
}

hook OnPlayerSpawnNewChar(playerid) {
    if(VIP[playerid])
	{
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

	Funções

==============================================================================*/

stock IsPlayerVip(playerid) return VIP[playerid];

stock SetPlayerVip(playerid, bool:toggle) {
	if(toggle == VIP[playerid]) return 0;

    VIP[playerid] = toggle;

	return 1;
}
