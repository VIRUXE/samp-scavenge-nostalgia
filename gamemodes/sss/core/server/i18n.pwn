#define MAX_LANGUAGE_ENTRY_LENGTH 199 // json_longest_string.py

#define CACHE_SIZE 50
#define CACHE_ROUTE_LENGTH 40 // player/key-actions/player/open_inventory

enum {
	PORTUGUESE,
	ENGLISH
};

static
	lang_PlayerLanguage[MAX_PLAYERS],
	Node:lang_i18n;

static ReplaceTags(content[]) {
	enum REPLACEMENTS {
		TAG[17+1],
		REPLACEMENT[26+1]
	};
	
    new replacements[][REPLACEMENTS] = {
        {"C_YELLOW", "{FFFF00}"},
        {"C_RED", "{E85454}"},
        {"C_GREEN", "{33AA33}"},
        {"C_BLUE", "{33CCFF}"},
        {"C_ORANGE", "{FFAA00}"},
        {"C_GREY", "{AFAFAF}"},
        {"C_PINK", "{FFC0CB}"},
        {"C_NAVY", "{000080}"},
        {"C_GOLD", "{B8860B}"},
        {"C_LGREEN", "{00FD4D}"},
        {"C_TEAL", "{008080}"},
        {"C_BROWN", "{DEB887}"},
        {"C_AQUA", "{F0F8FF}"},
        {"C_BLACK", "{000000}"},
        {"C_WHITE", "{FFFFFF}"},
        {"C_SPECIAL", "{0025AA}"},
        {"KEYTEXT_INTERACT", "~k~~VEHICLE_ENTER_EXIT~~w~"},
        {"KEYTEXT_RELOAD", "~k~~PED_ANSWER_PHONE~~w~"},
        {"KEYTEXT_PUT_AWAY", "~k~~CONVERSATION_YES~~w~"},
        {"KEYTEXT_DROP_ITEM", "~k~~CONVERSATION_NO~~w~"},
        {"KEYTEXT_INVENTORY", "~k~~GROUP_CONTROL_BWD~~w~"},
        {"KEYTEXT_ENGINE", "~k~~CONVERSATION_YES~~w~"},
        {"KEYTEXT_LIGHTS", "~k~~CONVERSATION_NO~~w~"},
        {"KEYTEXT_DOORS", "~k~~TOGGLE_SUBMISSIONS~~w~"},
        {"KEYTEXT_RADIO", "R"}
    };

    for (new i = 0; i < sizeof(replacements); i++)
    {
        new formattedTag[20];
        format(formattedTag, sizeof(formattedTag), "{%s}", replacements[i][TAG]);

        new findIndex = -1;
        while ((findIndex = strfind(content, formattedTag, false, findIndex + 1)) != -1)
        {
            strdel(content, findIndex, findIndex + strlen(formattedTag));
            strins(content, replacements[i][REPLACEMENT], findIndex, strlen(replacements[i][REPLACEMENT]));
        }
    }
}

GetLanguageString(playerid, const route[]) {
    new Node:node;

    // Split the route and navigate through the JSON tree
    new 
        routeSplit[12][64],
        routeSplitCount;

    routeSplitCount = strexplode(routeSplit, route, "/");

    JSON_GetObject(lang_i18n, routeSplit[0], node);

    for (new i = 1; i < routeSplitCount-1; i++) {
        JSON_GetObject(node, routeSplit[i], node);
    }

    JSON_GetArray(node, routeSplit[routeSplitCount-1], node);

    // Check if the array has at least two entries
    new len;
    JSON_ArrayLength(node, len);

    new output[MAX_LANGUAGE_ENTRY_LENGTH];
    strcopy(output, route);
    
    if(len >= 1) {
        new player_language = GetPlayerLanguage(playerid);
        
        JSON_ArrayObject(node, len == 1 ? 0 : player_language, node);
        JSON_GetNodeString(node, output, MAX_LANGUAGE_ENTRY_LENGTH);

        if(isempty(output)) {
            printf("[i18] Route '%s' for language %d is empty", route, player_language);
            return output;
        }

        ReplaceTags(output);

        // printf("GetLanguageString(%d (Language: %d), '%s'): %s", playerid, player_language, route, output);
    } else {
        printf("[i18] Route '%s' doesn't have any strings.", route);
    }

    return output;
}

GetPlayerLanguage(playerid)
{
	if(!IsPlayerConnected(playerid)) return -1;

	return lang_PlayerLanguage[playerid];
}

SetPlayerLanguage(playerid, langid)
{
	if(!IsPlayerConnected(playerid)) return -1;

    if(langid != 0 && langid != 1) {
        printf("[i18n] Invalid language id: %d", langid);
        PrintBacktrace();
        return -1;
    }

	lang_PlayerLanguage[playerid] = langid;

	log("[LANGUAGE] %p (%d) tem o idioma '%s' (%d)", playerid, playerid, langid == 0 ? "Português" : "English", langid);

	return 1;
}

/* SavePlayerLanguage(playerid, langid) {
    return db_query(gAccounts, sprintf("UPDATE players SET language = %d WHERE name = '%s'", langid, GetPlayerNameEx(playerid)));
} */

/*
	Credit for this function goes to Y_Less:
	http://forum.sa-mp.com/showpost.php?p=3015480&postcount=6

*/
stock ConvertEncoding(string[])
{
	static const
		real[256] =
		{
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

	for(new i = 0, len = strlen(string), ch; i != len; ++i)
	{
		// Check if this character is in our reduced range.
		// If it is, replace it with the real character.
		if(0 <= (ch = string[i]) < 256) string[i] = real[ch];
	}
}


hook OnGameModeInit() {
    printf("[i18n] Carregamento %s.", JSON_ParseFile("./scriptfiles/i18n.json", lang_i18n) ? "Falhou" : "Sucedido");
}

ACMD:i18n[5](playerid, params[]) {
    ChatMsg(playerid, -1, params);

    return 1;
}

ACMD:idioma[3](playerid, params[])
{
	new targetId = INVALID_PLAYER_ID, lang[3];

	if(isnull(params)) return ChatMsg(playerid, YELLOW, " >  Use: /idioma [id/nick] [pt/en]");

	sscanf(params, "rs[3]", targetId, lang);

	if(targetId == INVALID_PLAYER_ID) return ChatMsg(playerid, YELLOW, "Esse jogador não existe.");

	if(isempty(lang)) return ChatMsg(playerid, YELLOW, "Tem que escolher um idioma: /idioma [id/nick] [pt/en]");

	if(isequal(lang, "pt")) {
        SetPlayerLanguage(targetId, 0);
        // SavePlayerLanguage(playerid, 0);
    } else if(isequal(lang, "en")) {
        SetPlayerLanguage(targetId, 1);
        // SavePlayerLanguage(playerid, 1);
    } else 
        return ChatMsg(playerid, YELLOW, "Tem que escolher um idioma: /idioma [id/nick] [pt/en]");


	ChatMsg(targetId, YELLOW, " > Seu idioma foi alterado para '%s'.", lang);

	return ChatMsg(playerid, YELLOW, " > Idioma de %P"C_YELLOW" alterado para '%s'.", targetId, lang);
}