#define MAX_LANGUAGE				(2)
#define MAX_LANGUAGE_ENTRY_LENGTH	(199)
// You tried to use an item with another item because you are holding one already. This can be used sometimes, for example use a lighter with a campfire to light it or use a weapon with ammo to load it.
#define MAX_LANGUAGE_REPLACEMENTS	(25) // Temos 25 de momento (Para cores e teclas) 05/02/23
#define MAX_LANGUAGE_REPL_KEY_LEN	(32)
#define MAX_LANGUAGE_REPL_VAL_LEN	(32)

enum e_LANGUAGE_ENTRY_DATA
{
	lang_key[MAX_LANGUAGE_KEY_LEN],
	lang_val[MAX_LANGUAGE_ENTRY_LENGTH]
}

enum e_LANGUAGE_TAG_REPLACEMENT_DATA
{
	lang_repl_key[MAX_LANGUAGE_REPL_KEY_LEN],
	lang_repl_val[MAX_LANGUAGE_REPL_VAL_LEN]
}


static
	lang_Entries[MAX_LANGUAGE][MAX_LANGUAGE_ENTRIES][e_LANGUAGE_ENTRY_DATA],
	lang_TotalEntries[MAX_LANGUAGE],

	lang_Replacements[MAX_LANGUAGE_REPLACEMENTS][e_LANGUAGE_TAG_REPLACEMENT_DATA],
	lang_TotalReplacements,

    lang_entries[MAX_LANGUAGE],
	lang_Name[MAX_LANGUAGE][MAX_LANGUAGE_NAME],
	lang_Total,
	lang_PlayerLanguage[MAX_PLAYERS];

enum {
	PORTUGUESE,
	ENGLISH
};

/* stock const GetLanguageString(playerid, const name[]) {
    new langid = GetPlayerLanguage(playerid);
    new JSON:i18n, Node:node, Node:temp;

    new nameSplit[32][32], nameSplitCount;

    strsplit(name, "/", nameSplit, nameSplitCount); // Split the name into an array

    // Get the first level
    JSON_ParseFile("scriptfiles/i18n.json", i18n);

    JSON_GetObject(i18n, nameSplit[0], node);

    // Go through each level
    for(new i = 1; i < nameSplitCount; i++) {
        JSON_GetObject(node, nameSplit[i], temp);
        node = temp;
    }

    // Check if the array has at least two entries
    new len;
	JSON_ArrayLength(node, len);

    if (len < 2) {
        printf("Warning: Array '%s' has less than two entries\n", name);
        JSON_ArrayObject(node, 0, temp); // Fallback to the first entry
    } else {
        JSON_ArrayObject(node, langid, temp);
    }

	new output[MAX_LANGUAGE_ENTRY_LENGTH+1];
    JSON_GetNodeString(temp, output);

    JSON_Close(i18n);

    return result;
} */


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

hook OnGameModeInit()
{
	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_LANGUAGES);

	DefineLanguageReplacement("C_YELLOW",					"{FFFF00}");
	DefineLanguageReplacement("C_RED",						"{E85454}");
	DefineLanguageReplacement("C_GREEN",					"{33AA33}");
	DefineLanguageReplacement("C_BLUE",						"{33CCFF}");
	DefineLanguageReplacement("C_ORANGE",					"{FFAA00}");
	DefineLanguageReplacement("C_GREY",						"{AFAFAF}");
	DefineLanguageReplacement("C_PINK",						"{FFC0CB}");
	DefineLanguageReplacement("C_NAVY",						"{000080}");
	DefineLanguageReplacement("C_GOLD",						"{B8860B}");
	DefineLanguageReplacement("C_LGREEN",					"{00FD4D}");
	DefineLanguageReplacement("C_TEAL",						"{008080}");
	DefineLanguageReplacement("C_BROWN",					"{DEB887}");
	DefineLanguageReplacement("C_AQUA",						"{F0F8FF}");
	DefineLanguageReplacement("C_BLACK",					"{000000}");
	DefineLanguageReplacement("C_WHITE",					"{FFFFFF}");
	DefineLanguageReplacement("C_SPECIAL",					"{0025AA}");
	DefineLanguageReplacement("KEYTEXT_INTERACT",			"~k~~VEHICLE_ENTER_EXIT~~w~");
	DefineLanguageReplacement("KEYTEXT_RELOAD",				"~k~~PED_ANSWER_PHONE~~w~");
	DefineLanguageReplacement("KEYTEXT_PUT_AWAY",			"~k~~CONVERSATION_YES~~w~");
	DefineLanguageReplacement("KEYTEXT_DROP_ITEM",			"~k~~CONVERSATION_NO~~w~");
	DefineLanguageReplacement("KEYTEXT_INVENTORY",			"~k~~GROUP_CONTROL_BWD~~w~");
	DefineLanguageReplacement("KEYTEXT_ENGINE",				"~k~~CONVERSATION_YES~~w~");
	DefineLanguageReplacement("KEYTEXT_LIGHTS",				"~k~~CONVERSATION_NO~~w~");
	DefineLanguageReplacement("KEYTEXT_DOORS",				"~k~~TOGGLE_SUBMISSIONS~~w~");
	DefineLanguageReplacement("KEYTEXT_RADIO",				"R");

}

stock DefineLanguageReplacement(key[], val[])
{
	strcat(lang_Replacements[lang_TotalReplacements][lang_repl_key], key, MAX_LANGUAGE_REPL_KEY_LEN);
	strcat(lang_Replacements[lang_TotalReplacements][lang_repl_val], val, MAX_LANGUAGE_REPL_VAL_LEN);

	lang_TotalReplacements++;
}

_doReplace(input[], output[])
{
	new
		bool:in_tag = false,
		tag_start = -1,
		output_idx;

	for(new i = 0; input[i] != EOS; ++i)
	{
		if(in_tag)
		{
			if(input[i] == '}')
			{
				for(new j; j < lang_TotalReplacements; ++j)
				{
					if(!strcmp(input[tag_start], lang_Replacements[j][lang_repl_key], false, i - tag_start))
					{
						for(new k; lang_Replacements[j][lang_repl_val][k] != 0 && output_idx < MAX_LANGUAGE_ENTRY_LENGTH; ++k)
							output[output_idx++] = lang_Replacements[j][lang_repl_val][k];

						break;
					}
				}

				in_tag = false;
				continue;
			}
		}
		else
		{
			if(input[i] == '{')
			{
				tag_start = i + 1;
				in_tag = true;
				continue;
			}
			else if(input[i] == '\\')
			{
				if(input[i + 1] == 'n')
				{
					output[output_idx++] = '\n';
					i += 1;
				}
				else if(input[i + 1] == 't')
				{
					output[output_idx++] = '\t';
					i += 1;
				}
			}
			else output[output_idx++] = input[i];
		}
	}
}

_qs(array[][], left, right)
{
	new
		tempLeft = left,
		tempRight = right,
		pivot = array[(left + right) / 2][0];

	while(tempLeft <= tempRight)
	{
		while(array[tempLeft][0] < pivot) tempLeft++;

		while(array[tempRight][0] > pivot) tempRight--;

		if(tempLeft <= tempRight)
		{
			_swap(array[tempLeft][lang_key], array[tempRight][lang_key]);
			_swap(array[tempLeft][lang_val], array[tempRight][lang_val]);

			tempLeft++;
			tempRight--;
		}
	}

	if(left < tempRight) _qs(array, left, tempRight);

	if(tempLeft < right) _qs(array, tempLeft, right);
}

_swap(str1[], str2[])
{
	new tmp;

	for(new i; str1[i] != '\0' || str2[i] != '\0'; i++)
	{
		tmp = str1[i];
		str1[i] = str2[i];
		str2[i] = tmp;
	}
}

/* stock GetLanguageString(languageId, key[], bool:encode = false)
{
	new
		result[MAX_LANGUAGE_ENTRY_LENGTH],
		ret;

	if(!(0 <= languageId < lang_Total))
	{
		err("Invalid language id %d.", languageId);
		PrintAmxBacktrace();

		return result;
	}

	ret = _GetLanguageString(languageId, key, result, encode);

	switch(ret)
	{
		case 1:
		{
			printf("Malformed key '%s' must be alphabetical.", key);
		}
		case 2:
		{
			printf("Key not found: '%s' in language '%s'", key, lang_Name[languageId]);

			// return English if key not found
			if(languageId != 0)
				strcat(result, GetLanguageString(0, key, encode), MAX_LANGUAGE_ENTRY_LENGTH);
		}
	}

	return result;
} */

static stock _GetLanguageString(languageId, key[], result[], bool:encode = false)
{
	if(!('A' <= key[0] <= 'Z')) return 1; // Must be all uppercase

	new bool:keyFound = false;

	// Loop through all entries to find the key
	for(new entry; entry < lang_TotalEntries[languageId]; ++entry)
	{
		// If the key matches, copy the value to the result
		if(!strcmp(lang_Entries[languageId][entry][lang_key], key, false, MAX_LANGUAGE_ENTRY_LENGTH)) {
			// Copy the value to the result
			strcat(result, lang_Entries[languageId][entry][lang_val], MAX_LANGUAGE_ENTRY_LENGTH);

			keyFound = true;
			break;
		}
	}

	if(!keyFound) return 2;

	if(encode) ConvertEncoding(result);

	return 0;
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