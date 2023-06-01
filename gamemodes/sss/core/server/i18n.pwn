#define MAX_LANGUAGE_ENTRY_LENGTH 750 // A rota maior e a "help"

enum {
	PORTUGUESE,
	ENGLISH
}

static
	playerLanguage[MAX_PLAYERS],
	Node:jsonData;

static const languageStrings[][3][] = {
	#include "language_strings.pwn"
};

GetLanguageString(playerId, const key[]) {
	new output[MAX_LANGUAGE_ENTRY_LENGTH] = "MISSING";

	for(new e; e < sizeof(languageStrings); e++) {
		if(isequal(languageStrings[e][0], key)) {
			strcpy(output, languageStrings[e][GetPlayerLanguage(playerId)+1]);
			break;
		}
	}

	return output;
}

GetPlayerLanguage(playerId) {
	if(!IsPlayerConnected(playerId)) return -1;

	return playerLanguage[playerId];
}

SetPlayerLanguage(playerId, langId) {
	if(!IsPlayerConnected(playerId)) return -1;

	if(langId != 0 && langId != 1) {
		printf("[i18n] Invalid language id: %d", langId);
		PrintBacktrace();
		return -1;
	}

	playerLanguage[playerId] = langId;

	log("[LANGUAGE] %p (%d) tem o idioma '%s' (%d)", playerId, playerId, langId == 0 ? "Português" : "English", langId);

	return 1;
}

/* SavePlayerLanguage(playerId, langId) {
	return db_query(gAccounts, sprintf("UPDATE players SET language = %d WHERE name = '%s'", langId, GetPlayerNameEx(playerId)));
} */

/*
	Credit for this function goes to Y_Less:
	http://forum.sa-mp.com/showpost.php?p=3015480&postcount=6

*/
stock ConvertEncoding(string[]) {
	new const real[256] = {
			  0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,  12,  13,  14,  15,
			 16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  26,  27,  28,  29,  30,  31,
			 32,  33,  34,  35,  36,  37,  38,  39,  40,  41,  42,  43,  44,  45,  46,  47,
			 48,  49,  50,  51,  52,  53,  54,  55,  56,  57,  58,  59,  60,  61,  62,  63,
			 64,  65,  66,  67,  68,  69,  70,  71,  72,  73,  74,  75,  76,  77,  78,  79,
			 80,  81,  82,  83,  84,  85,  86,  87,  88,  89,  90,  91,  92,  93,  94,  95,
			 96,  97,  98,  99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111,
			112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127,
			128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143,
			144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159,
			160,  94, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175,
			124, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 175,
			128, 129, 130, 195, 131, 197, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141,
			208, 173, 142, 143, 144, 213, 145, 215, 216, 146, 147, 148, 149, 221, 222, 150,
			151, 152, 153, 227, 154, 229, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164,
			240, 174, 165, 166, 167, 245, 168, 247, 248, 169, 170, 171, 172, 253, 254, 255
		};

	for(new i = 0, len = strlen(string), ch; i != len; ++i) {
		// Check if this character is in our reduced range.
		// If it is, replace it with the real character.
		if(0 <= (ch = string[i]) < 256) string[i] = real[ch];
	}
}


hook OnGameModeInit() {
	new result = JSON_ParseFile("./scriptfiles/i18n.json", jsonData);

	printf("[i18n] Carregamento %s.", result ? "Falhou" : "Sucedido");

	if(result) for(;;){}
}

ACMD:idioma[3](playerId, params[]) {
	new targetId = INVALID_PLAYER_ID, lang[3];

	if(isnull(params)) return ChatMsg(playerId, YELLOW, " >  Use: /idioma [id/nick] [pt/en]");

	sscanf(params, "rs[3]", targetId, lang);

	if(targetId == INVALID_PLAYER_ID) return ChatMsg(playerId, YELLOW, "Esse jogador não existe.");

	if(isempty(lang)) return ChatMsg(playerId, YELLOW, "Tem que escolher um idioma: /idioma [id/nick] [pt/en]");

	if(isequal(lang, "pt")) {
		SetPlayerLanguage(targetId, PORTUGUESE);
	} else if(isequal(lang, "en")) {
		SetPlayerLanguage(targetId, ENGLISH);
	} else 
		return ChatMsg(playerId, YELLOW, "Tem que escolher um idioma: /idioma [id/nick] [pt/en]");

	ChatMsg(targetId, YELLOW, " > Seu idioma foi alterado para '%s'.", lang);

	return ChatMsg(playerId, YELLOW, " > Idioma de %P"C_YELLOW" alterado para '%s'.", targetId, lang);
}