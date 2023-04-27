enum E_COLOUR_EMBED_DATA
{
	ce_char,
	ce_colour[9]
}

new EmbedColours[9][E_COLOUR_EMBED_DATA]=
{
	{'r', #C_RED},
	{'g', #C_GREEN},
	{'b', #C_BLUE},
	{'y', #C_YELLOW},
	{'p', #C_PINK},
	{'w', #C_WHITE},
	{'o', #C_ORANGE},
	{'n', #C_NAVY},
	{'a', #C_AQUA}
};

stock TagScan(chat[], colour = WHITE)
{
	new
		text[256],
		length,
		a,
		tags;

	strcpy(text, chat, 256);
	length = strlen(chat);

	while(a < (length - 1) && tags < 3) {
		if(text[a]=='@') {
			if(IsCharNumeric(text[a+1])) {
				new id, tmp[3];

				strmid(tmp, text, a+1, a+3);
				id = strval(tmp);

				if(IsPlayerConnected(id))
				{
					new tmpName[MAX_PLAYER_NAME+17];

					format(tmpName, MAX_PLAYER_NAME+17, "%P%C", id, colour);

					strdel(text[a], 0, id < 10 ? 2 : 3);

					strins(text[a], tmpName, 0);

					length += strlen(tmpName);
					a += strlen(tmpName);
					tags++;

					GameTextForPlayer(id, "~G~~H~ VOCE FOI MENCIONADO(A)!", 3000, 1);
    
					PlayerPlaySound(id, 5205, 0.0,0.0,0.0);

					continue;
				} else a++;
			} else a++;
		} else if(text[a]=='&') {
			if(IsCharAlphabetic(text[a+1])) {
				new replacements;

				for(new i; i < sizeof(EmbedColours); i++) {
					if(text[a+1] == EmbedColours[i][ce_char]) {
						strdel(text[a], 0, 2);
						strins(text[a], EmbedColours[i][ce_colour], 0);
						length += 8;
						a += 8;
						replacements++;
						break;
					}
				}

				if(replacements==0) a++;
			} else a++;
		} else a++;
	}

	return text;
}
