#include <YSI\y_hooks>

#define VIP_COLOR 0xFFAA0000
	
new 
bool:	VIP[MAX_PLAYERS],
		VIP_Anuncio;

ACMD:setvip[5](playerid, params[])
{
	new targetId;

	if(sscanf(params, "r", targetId)) return ChatMsg(playerid, RED, " > Use: /setvip [id/nick]");
	
	if(targetId == INVALID_PLAYER_ID) return 4; // CMD_INVALID_PLAYER

	SetPlayerVip(targetId, !VIP[targetId]);

	db_query(gAccounts, sprintf("UPDATE players SET vip = %d WHERE name = '%s'", VIP[targetId] ? 1 : 0, GetPlayerNameEx(targetId)));

	SetPlayerColor(targetId, VIP[targetId] ? VIP_COLOR : 0xB8B8B800);

	ChatMsgAll(PINK, VIP[targetId] ? " > %p (%d) É o mais novo VIP do servidor. Parabéns!!! :D" : " > %p (%d) Perdeu o vip do servidor. :(", targetId, targetId);

	return 1;
}

CMD:vip(playerid, params[]) // ajuda, anuncio, reset, skin, pintar, frase, kill, nick, luta
{
	if(!IsPlayerVip(playerid)) return ChatMsg(playerid, RED, " > Esse comando é apenas para jogadores VIP.");

	new command[8];

	if(sscanf(params, "s[8]", command)) return ChatMsg(playerid, RED, " > Use: /vip [ajuda, anuncio, reset, skin, pintar, frase, kill, nick, luta]");

	if(isequal(command, "ajuda", true)) {
		// TODO: refazer o dialog com informações atualizadas
		ShowPlayerDialog(playerid, 9146, DIALOG_STYLE_MSGBOX, "Ajuda VIP:",
		"{FFFF00}Benefícios dos VIPS: {33AA33}(Preço: 1 Mês - R$20,00 | 2 Meses - R$35,00\n\n\
		{FFAA00}- Tem uma maior variedade de spawns após morrer\n\
		{FFAA00}- Consegue trocar o nickname usando {FFFFFF}/mudarnick\n\
		{FFAA00}- Consegue trocar o estilo de luta usando {FFFFFF}/mudarluta\n\
		{FFAA00}- Nickname colorido (destacado)\n\
		{FFAA00}- Cargo VIP permanente no discord\n\
		{FFAA00}- Chat e canal de voz VIP no discord\n\
		{FFAA00}- Consegue se matar usando {FFFFFF}/kill\n\
		{FFAA00}- Consegue fazer um anúncio vip no chat usando {FFFFFF}/avip\n\
		{FFAA00}- Consegue alterar a cor de veículos usando {FFFFFF}/pintar\n\
		{FFAA00}- Monta e desmonta estruturas 3x mais rápido\n\
		{FFAA00}- Consegue consertar o veículo 3x mais rápido\n\
		{FFAA00}- Consegue resetar o status (Score, Spree, Mortes) com {FFFFFF}/resetarstatus\n\
		{FFAA00}- Consegue colocar uma frase de login destacada para todos com {FFFFFF}/frase\n\
		{FFAA00}- Spawna sem fome (jogadores sem vip nascem com 20% de fome faltando)\n\
		{FFAA00}- Recebe o dobro de kills (score) ao eliminar algum jogador\n\
		{FFAA00}- Consegue trocar a skin usando {FFFFFF}/skin\n\
		{FFAA00}- Nasce com chave de roda, chave de fenda, mapa, mochila pequena e um bastão\n\
		{FFAA00}- Consegue reparar a lataria do veículo ao finalizar o reparo com ferramentas.",
		"Fechar", "");
	} else if(isequal(command, "anuncio", true)) {
		// Espera 3 segundos para fazer outro anúncio
		if(GetTickCountDifference(VIP_Anuncio, GetTickCount()) < SEC(3)) return ChatMsg(playerid, RED, "> O ultimo anúncio foi feito a menos de 3 segundos.");

		new anuncio[150];

		if(sscanf(params, "{s[7]}s[150]", anuncio)) return ChatMsg(playerid, RED, " > Use: /vip anuncio [mensagem]");

		ChatMsgAll(VIP_COLOR, "[Anúncio VIP] "C_WHITE"%P (%d): {FFAA00}%s", playerid, playerid, anuncio);

		VIP_Anuncio = GetTickCount();
	} else if(isequal(command, "reset", true)) {
		SetPlayerScore(playerid, 0);
		SetPlayerDeathCount(playerid, 0);
		SetPlayerSpree(playerid, 0);
		SavePlayerIniData(playerid);

		ChatMsg(playerid, GREEN, " > Seu status foi resetado.");
	} else if(isequal(command, "skin", true)) {
		if(GetPlayerSkin(playerid) == 287) return ChatMsg(playerid, RED, " > Você não pode trocar sua skin usando uma Camuflagem.");

		new skinid;

		if(sscanf(params, "{s[5]}d", skinid)) return ChatMsg(playerid, RED, " > Use: /vip skin [1-311]");

		if(skinid > 311 || skinid < 1 || skinid == 211 || skinid == 217 || skinid == 287) return ChatMsg(playerid, RED, " > ID de skin inválido.");

		SetPlayerSkin(playerid, skinid);
	} else if(isequal(command, "pintar", true)) {
		if(!IsPlayerInAnyVehicle(playerid)) return ChatMsg(playerid, RED, " > Você precisa estár dentro de um veículo.");

		new cor1, cor2;

		if(sscanf(params, "{s[7]}I(*)I(*)", random(255), cor1, random(255), cor2)) return ChatMsg(playerid, RED, " > Use : /vip pintar (0-255) (0-255)");

		if(cor1 < 0 || cor1 > 255 || cor2 < 0 || cor2 > 255) return ChatMsg(playerid, RED, "Cores de 0 a 255!");

		ChangeVehicleColor(GetPlayerVehicleID(playerid), cor1, cor2);
	} else if(isequal(command, "kill", true)) {
		// Tem que aguardar 1 minuto
		if(GetTickCountDifference(GetTickCount(), GetPlayerSpawnTick(playerid)) < MIN(1)) return 2;

		SetPlayerHealth(playerid, 0.0);
	} else if(isequal(command, "luta", true)) {
		new luta;

		if(sscanf(params, "{s[5]}d", luta)) return ChatMsg(playerid, RED, " > Use: /vip luta [1-4]");

		if(luta < 1 || luta > 4) return ChatMsg(playerid, RED, " > Use: /vip luta [1-4]");
		
		if(luta == 1)
			SetPlayerFightingStyle(playerid, FIGHT_STYLE_KUNGFU);
		else if(luta == 2)
			SetPlayerFightingStyle(playerid, FIGHT_STYLE_KNEEHEAD);
		else if(luta == 3)
			SetPlayerFightingStyle(playerid, FIGHT_STYLE_ELBOW);
		else
			SetPlayerFightingStyle(playerid, FIGHT_STYLE_GRABKICK);
			
		return ChatMsg(playerid, VIP_COLOR, " > Estilo de luta alterado com Sucesso.");
	} else if(isequal(command, "nick", true)) {
		if(!IsPlayerLoggedIn(playerid)) return ChatMsg(playerid, YELLOW, "server/command/cant-use-not-logged-in");

		new nick[MAX_PLAYER_NAME];

		if(sscanf(params, "s[24]", nick)) return ChatMsg(playerid, YELLOW, "Use: /vip nick [nick]");

		if(strlen(nick) > MAX_PLAYER_NAME || strlen(nick) < 3) return ChatMsg(playerid, YELLOW, "Seu nick deve ter entre 3 e 22 caracteres.");

		if(!IsValidUsername(nick)) return ChatMsg(playerid, YELLOW, "O Nick que você digitou possui algum caracter inválido");

		if(AccountExists(nick)) return ChatMsg(playerid, YELLOW, "Este nick já está registrado no Servidor.");

		SetAccountName(GetPlayerNameEx(playerid), nick);

		SetPlayerName(playerid, nick);

		ChatMsgAll(RED, "  > %P(%d)"C_RED" alterou seu nickname para '%s' (usando /vip nick)", playerid, playerid, nick);

		log("[NICK] %p alterou o nick para '%s'", playerid, nick);

		ChatMsg(playerid, GREEN, " > Você alterou seu nome para "C_WHITE"%s"C_GREEN".", nick);
		ChatMsg(playerid, GREEN, " > Quando for entrar no servidor novamente, altere seu nick no SA-MP.");
		
		KickPlayer(playerid, "Relogue com seu novo nick", true);
	}

	return 1;
}

hook OnPlayerConnect(playerid) {
	if(GetPlayerAdminLevel(playerid) == 0 && Iter_Count(Player) >= 35 && !IsPlayerVip(playerid)) 
		return KickPlayer(playerid, "O servidor está lotado com 35 online. VIPS possuem 5 slots reservados!", true);

	return 1;
}

hook OnPlayerLogin(playerid) {
	if(IsPlayerVip(playerid)) {
		SetPlayerColor(playerid, VIP_COLOR);

		ChatMsg(playerid, VIP_COLOR, " > Você é um jogador VIP! Obrigado por apoiar o servidor.");
	}
}

hook OnPlayerSpawnNewChar(playerid) {
	if(IsPlayerVip(playerid)) {
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

stock IsPlayerVip(playerid) return VIP[playerid];

stock SetPlayerVip(playerid, bool:toggle) {
	if(toggle == VIP[playerid]) return 0;

    VIP[playerid] = toggle;

	return 1;
}