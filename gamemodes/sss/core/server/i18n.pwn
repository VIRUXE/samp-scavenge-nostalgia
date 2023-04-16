#define MAX_LANGUAGE_ENTRY_LENGTH 199 // json_longest_string.py

static
	lang_PlayerLanguage[MAX_PLAYERS];

enum {
	PORTUGUESE,
	ENGLISH
};

/* static ReplaceTag(content[]) {
    new replacements[][2] = {
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

    return 1;
}
 */
stock GetLanguageString(playerid, const route[]) {
    new Node:node;

    JSON_ParseFile("./scriptfiles/i18n.json", node);

	/* 
		* i18n_array_size.py 15/04/23

		Max depth: 6
		Max key length: 24

		* Função 'strsplit' retorna um tamanho de 32 de qualquer das formas... Talvez utilizar outra função?
	*/
    new routeSplit[6][32], routeSplitCount;

    strsplit(route, "/", routeSplit, routeSplitCount); // Split the name into an array

	// printf("[i18n] Route '%s' has %d parts.", route, routeSplitCount);

    // Go through each level, minus the last one, that is an array
    for(new i = 0; i < routeSplitCount-1; i++) {
		// printf("[i18n] Getting part '%s' (%d)", routeSplit[i], i);

        JSON_GetObject(node, routeSplit[i], node);
    }

	// printf("[i18n] Getting Array part: %s", routeSplit[routeSplitCount-1]);

	JSON_GetArray(node, routeSplit[routeSplitCount-1], node);

    // Check if the array has at least two entries
    new len;
	JSON_ArrayLength(node, len);

	// printf("[i18n] Array '%s' is %d in length", routeSplit[routeSplitCount-1], len);

	new output[MAX_LANGUAGE_ENTRY_LENGTH] = "MISSING";

	if(len >= 1) {
		JSON_ArrayObject(node, len == 1 ? 0 : GetPlayerLanguage(playerid), node);
		JSON_GetNodeString(node, output, MAX_LANGUAGE_ENTRY_LENGTH);

		// ReplaceTag(output);
	} else
		printf("[i18] Route '%s' doesn't have any strings.", route);

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

	lang_PlayerLanguage[playerid] = langid;

	log("[LANGUAGE] %p (%d) tem o idioma '%s'", playerid, playerid, langid == 0 ? "Português" : "English");

	return 1;
}

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