#include <YSI\y_hooks>

#define VIP_COLOR 0xFFAA0000
#define MAX_JOINSENTENCE_LEN 90

enum {
	VIP_NONE,
	VIP_COPPER,
	VIP_SILVER,
	VIP_GOLD
}

static VIP[MAX_PLAYERS], VIP_Anuncio;

ACMD:setvip[5](playerid, params[]) {
	new targetId, tier;

	if(sscanf(params, "rD(*)", targetId, VIP_NONE, tier)) return ChatMsg(playerid, RED, " > Use: /setvip [id/nick] (plano)");
	
	if(targetId == INVALID_PLAYER_ID) return 4; // CMD_INVALID_PLAYER

	SetPlayerVip(targetId, tier);

	db_query(Database, sprintf("UPDATE players SET vip = %d WHERE name = '%s'", VIP[targetId] ? 1 : 0, GetPlayerNameEx(targetId)));

	SetPlayerColor(targetId, VIP[targetId] ? VIP_COLOR : 0xB8B8B800);

	return ChatMsgAll(PINK, VIP[targetId] ? " > %p (%d) É o mais novo VIP (%s) do servidor. Parabéns!!! :D" : " > %p (%d) Perdeu o vip do servidor. :(", targetId, GetVipTierName(tier), targetId);
}

CMD:vip(playerid, params[]) { // anuncio, reset, skin, pintar, frase, kill, nick, luta
	new help[] = 
		"{FFFF00}Benefícios de ser VIP: {33AA33}(Preço: 1 Mês - R$20,00 | 2 Meses - R$35,00){FFAA00}\n\n\
		- Tem uma maior variedade de Locais de Spawn após morrer\n\
		- Consegue trocar o Nickname usando {FFFFFF}'nick'{FFAA00}\n\
		- Consegue trocar o Estilo de Luta usando {FFFFFF}'luta'{FFAA00}\n\
		- Nickname colorido (destacado)\n\
		- Cargo VIP permanente no Discord\n\
		- Chat e Voz VIP no Discord\n\
		- Consegue se Matar usando {FFFFFF}'kill'{FFAA00}\n\
		- Consegue fazer um Anúncio VIP no chat usando {FFFFFF}'anuncio'{FFAA00}\n\
		- Consegue alterar a Cor de Veículos usando {FFFFFF}'pintar'{FFAA00}\n\
		- Monta e Desmonta estruturas 3x mais rápido\n\
		- Consegue Consertar o Veículo 3x mais rápido\n\
		- Consegue Resetar o Status (Kills, Spree, Mortes) com {FFFFFF}'resetar'{FFAA00}\n\
		- Consegue colocar uma Frase de Login destacada para todos com {FFFFFF}'frase'{FFAA00}\n\
		- Spawna sem Fome (jogadores sem VIP nascem com 20% de fome faltando)\n\
		- Recebe o dobro de Kills (Score) ao eliminar algum jogador\n\
		- Consegue trocar a Skin usando {FFFFFF}'skin'{FFAA00}\n\
		- Nasce com Chave de Roda, Chave de Fenda, Mapa, Mochila Pequena e um Bastão\n\
		- Consegue Reparar a Lataria do Veículo ao finalizar o Reparo com Ferramentas.",
		
		syntax[] = " > Use: /vip [anuncio, reset, skin, pintar, frase, kill, nick, luta]";

	if(!VIP[playerid]) {
		ShowPlayerDialog(playerid, 9146, DIALOG_STYLE_MSGBOX, "Ajuda VIP:", help, "Fechar", "");
		return 1;
	}

	new command[8];

	if(sscanf(params, "s[8] ", command)) {
		ShowPlayerDialog(playerid, 9146, DIALOG_STYLE_MSGBOX, "Ajuda VIP:", help, "Fechar", "");
		return ChatMsg(playerid, RED, syntax);
	}

	if(isequal(command, "anuncio", true)) {
		// Espera 3 segundos para fazer outro anúncio
		if(VIP_Anuncio && GetTickCountDifference(GetTickCount(), VIP_Anuncio) < SEC(3)) return ChatMsg(playerid, RED, "> O ultimo anúncio foi feito a menos de 3 segundos.");

		new anuncio[150];

		if(sscanf(params, "{s[8]}s[150]", anuncio)) return ChatMsg(playerid, RED, " > Use: /vip anuncio [mensagem]");

		ChatMsgAll(VIP_COLOR, "[Anúncio VIP] "C_WHITE"%P (%d): {FFAA00}%s", playerid, playerid, anuncio);

		VIP_Anuncio = GetTickCount();
	} else if(isequal(command, "frase", true)) {
		new frase[MAX_JOINSENTENCE_LEN];

		if(sscanf(params, "{s[6]}s[*]", MAX_JOINSENTENCE_LEN, frase)) return ChatMsg(playerid, YELLOW, "Sua frase de entrada: %s", GetPlayerJoinSentence(playerid));

		db_query(Database, sprintf("UPDATE players SET joinSentence = '%s' WHERE name = '%s';", frase, GetPlayerNameEx(playerid)));

		ChatMsg(playerid, GREEN, " >  %s: "C_WHITE"%s", ls(playerid, "player/join-sentence/changed"), frase);
	} else if(isequal(command, "reset", true)) {
		SetPlayerScore(playerid, 0);
		SetPlayerDeathCount(playerid, 0);
		SetPlayerSpree(playerid, 0);

		db_query(Database, sprintf("UPDATE players SET kills = 0, deaths = 0 WHERE name = '%s';", params, GetPlayerNameEx(playerid)));

		ChatMsg(playerid, GREEN, " > Seu status foi resetado.");
	} else if(isequal(command, "skin", true)) {
		if(GetPlayerSkin(playerid) == 287) return ChatMsg(playerid, RED, " > Você não pode trocar sua skin usando uma Camuflagem.");

		new skinId;

		if(sscanf(params, "{s[5]}i", skinId)) return ChatMsg(playerid, RED, " > Use: /vip skin [1-311]");

		if(skinId > 311 || skinId < 1 || skinId == 211 || skinId == 217 || skinId == 287) return ChatMsg(playerid, RED, " > ID de skin inválido.");

		SetPlayerSkin(playerid, skinId);
	} else if(isequal(command, "pintar", true)) {
		if(!IsPlayerInAnyVehicle(playerid)) return ChatMsg(playerid, RED, " > Você precisa estár dentro de um veículo.");

		new cor1, cor2;

		sscanf(params, "{s[7]}I(*)I(*)", random(255), cor1, random(255), cor2);

		if(cor1 < 0 || cor1 > 255 || cor2 < 0 || cor2 > 255) return ChatMsg(playerid, RED, "Cores de 0 a 255!");

		ChangeVehicleColor(GetPlayerVehicleID(playerid), cor1, cor2);
	} else if(isequal(command, "kill", true)) {
		if(GetTickCountDifference(GetTickCount(), GetPlayerSpawnTick(playerid)) < MIN(1)) return CMD_CANT_USE; // Tem que aguardar 1 minuto

		SetPlayerHP(playerid, 0.0);
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

		if(sscanf(params, "{s[5]}s[24]", nick)) return ChatMsg(playerid, YELLOW, "Use: /vip nick [nick]");

		if(strlen(nick) > MAX_PLAYER_NAME || strlen(nick) < 3) return ChatMsg(playerid, YELLOW, "Seu nick deve ter entre 3 e 22 caracteres.");

		if(!IsValidUsername(nick)) return ChatMsg(playerid, YELLOW, "O Nick que você digitou possui algum caracter inválido");

		if(AccountExists(nick)) return ChatMsg(playerid, YELLOW, "Este nick já está registrado no Servidor.");

		SetAccountName(GetPlayerNameEx(playerid), nick);

		SetPlayerName(playerid, nick);

		ChatMsgAll(RED, "  > %P(%d)"C_RED" alterou seu nickname para '%s' (usando seus beneficios de VIP)", playerid, playerid, nick);

		ChatMsg(playerid, GREEN, " > Você alterou seu nome para "C_WHITE"%s"C_GREEN".", nick);
		ChatMsg(playerid, GREEN, " > Quando for entrar no servidor novamente, altere seu nick no SA-MP.");
		
		KickPlayer(playerid, "Relogue com seu novo nick", true);
	} else
		ChatMsg(playerid, RED, syntax);

	return 1;
}

CMD:v(playerid, params[]) {
	if(!VIP[playerid] && !GetPlayerAdminLevel(playerid)) return 0;

	if(isnull(params)) {
		SetPlayerChatMode(playerid, CHAT_MODE_VIP);
		ChatMsg(playerid, WHITE, "player/radio/vip");
	} else {
		PlayerSendChat(playerid, params, 4.0);

		if(GetPlayerChatMode(playerid) == CHAT_MODE_VIP) ChatMsg(playerid, GREY, "player/chat/mode/already-tip");
	}

	// return 7;
	return 1;
}

hook OnPlayerConnect(playerid) {
	if(GetPlayerAdminLevel(playerid) == 0 && Iter_Count(Player) >= 35 && !VIP[playerid]) 
		return KickPlayer(playerid, "O servidor está lotado com 35 online. VIPS possuem 5 slots reservados!", true);

	return 1;
}

// ? Sera mesmo necessario?
/* hook OnPlayerDisconnect(playerid) {
	SetPlayerVip(playerid, false);
} */

hook OnPlayerLogin(playerid) {
	if(VIP[playerid]) {
		SetPlayerColor(playerid, VIP_COLOR);

		ChatMsg(playerid, VIP_COLOR, " > Você é um jogador VIP! Obrigado por apoiar o servidor.");
	}
}

hook OnPlayerSpawnNewChar(playerid) {
	if(VIP[playerid]) {
		// * Creio que existe uma forma melhor de dar itens ao jogador
		GivePlayerBag(playerid, CreateItem(item_Satchel));
		AddItemToPlayer(playerid, CreateItem(item_Wrench), true, false);
		AddItemToPlayer(playerid, CreateItem(item_Screwdriver), true, false);
		AddItemToPlayer(playerid, CreateItem(item_Map), true, false);
		GiveWorldItemToPlayer(playerid, CreateItem(item_Bat));
	}
}

GetPlayerJoinSentence(playerid) {
	new DBResult:result = db_query(Database, sprintf("SELECT joinSentence FROM players WHERE name = '%s';", GetPlayerNameEx(playerid)));

	new frase[MAX_JOINSENTENCE_LEN];
	db_get_field(result, 0, frase, sizeof(frase));
	db_free_result(result);

	return frase;
}

GetPlayerVipTier(playerid) return VIP[playerid];

Float:GetPlayerVipMulti(playerid, baseValue) {
	switch(VIP[playerid]) {
		case VIP_COPPER: return baseValue / 1.5;
		case VIP_SILVER: return baseValue / 2.0;
		case VIP_GOLD:   return baseValue / 3.0;
	}
	
	return baseValue * 0.0;
}

SetPlayerVip(playerid, tier) {
	if(VIP[playerid] == tier) return 0;

    VIP[playerid] = tier;

	return 1;
}

GetVipTierName(tier) {
	new name[6];

	switch(tier) {
		case VIP_COPPER: name = "Cobre";
		case VIP_SILVER: name = "Prata";
		case VIP_GOLD:   name = "Ouro";
	}

	return name;
}