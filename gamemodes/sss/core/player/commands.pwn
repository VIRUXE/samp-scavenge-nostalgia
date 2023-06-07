CMD:discord(playerid) return ChatMsg(playerid, 0xFFAA00, " > http://discord.scavengenostalgia.fun");

CMD:dicas(playerid) {
	new tooltips = IsPlayerToolTipsOn(playerid);

	if(tooltips) HideHelpTip(playerid);

	ChatMsg(playerid, YELLOW, tooltips ? "player/tips/off" : "player/tips/on");
	SetPlayerToolTips(playerid, !tooltips);

	return 1;
}

CMD:tooltips(playerid) return cmd_dicas(playerid);

CMD:mudarsenha(playerid, params[]) {
	if(!IsPlayerLoggedIn(playerid)) return ChatMsg(playerid, YELLOW, "player/command/cant-use-not-logged-in");

	new
		oldpass[32],
		newpass[32],
		buffer[MAX_PASSWORD_LEN];

	if(sscanf(params, "s[32]s[32]", oldpass, newpass))
		ChatMsg(playerid, YELLOW, "player/changepassword/syntax");
	else {
		new storedhash[MAX_PASSWORD_LEN];

		GetPlayerPassHash(playerid, storedhash);
		WP_Hash(buffer, MAX_PASSWORD_LEN, oldpass);

		if(!strcmp(buffer, storedhash)) {
			new name[MAX_PLAYER_NAME];

			GetPlayerName(playerid, name, MAX_PLAYER_NAME);

			WP_Hash(buffer, MAX_PASSWORD_LEN, newpass);

			if(SetAccountPassword(name, buffer)) {
				SetPlayerPassHash(playerid, buffer);
				ChatMsg(playerid, YELLOW, "player/changepassword/success", newpass);
			} else
				ChatMsg(playerid, RED, "player/changepassword/error");
		} else
			ChatMsg(playerid, RED, "player/changepassword/no-match");
	}

	return 1;
}

CMD:pos(playerid){
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);

	ChatMsg(playerid, YELLOW, " >  Sua Posição: "C_BLUE"%.2f, %.2f, %.2f", x, y, z);

	return 1;
}

CMD:ajuda(playerid) {
	ShowPlayerDialog(playerid, DIALOG_AJUDA, DIALOG_STYLE_MSGBOX, GetPlayerLanguage(playerid) ? "Informations" : "Informações", ls(playerid, "server/command/help"), "Ok", "");
	return 1;
}

CMD:help(playerid) return cmd_ajuda(playerid);
CMD:comandos(playerid) return cmd_ajuda(playerid);

// ===========================================================================================================

CMD:regras(playerid) {
	ShowPlayerDialog(playerid, DIALOG_REGRAS, DIALOG_STYLE_MSGBOX, GetPlayerLanguage(playerid) ? "Rules" : "Regras", ls(playerid, "server/command/lists/rules"), "Ok", "");
	return 1;
}

CMD:rules(playerid) return cmd_regras(playerid);

// ===========================================================================================================

CMD:explosivos(playerid) {
	ShowPlayerDialog(playerid, DIALOG_EXPLOSIVOS, DIALOG_STYLE_MSGBOX, GetPlayerLanguage(playerid) ? "Explosives" : "Explosivos", ls(playerid, "server/command/bombs-list"), "Ok", "");
	return 1;
}

CMD:explosives(playerid) return cmd_explosivos(playerid);
CMD:bombas(playerid) return cmd_explosivos(playerid);

// ===========================================================================================================

CMD:metais(playerid) {
	ShowPlayerDialog(playerid, DIALOG_METAIS, DIALOG_STYLE_MSGBOX, GetPlayerLanguage(playerid) ? "Defences" : "Defesas", ls(playerid, "defences-list"), "Ok", "");
	return 1;
}

CMD:defences(playerid) return cmd_metais(playerid);

// ===========================================================================================================

CMD:mochilas(playerid) {
	ShowPlayerDialog(playerid, DIALOG_MOCHILAS, DIALOG_STYLE_MSGBOX, GetPlayerLanguage(playerid) ? "Backpacks" : "Mochilas", ls(playerid, "server/command/lists/backpack"), "Ok", "");
	return 1;
}

CMD:backpacks(playerid) return cmd_mochilas(playerid);

// ===========================================================================================================

CMD:caixas(playerid) {
	ShowPlayerDialog(playerid, DIALOG_CAIXAS, DIALOG_STYLE_MSGBOX, GetPlayerLanguage(playerid) ? "Boxes" : "Caixas", ls(playerid, "server/command/lists/boxes"), "Ok", "");
	return 1;
}

CMD:boxes(playerid) return cmd_caixas(playerid);

// ===========================================================================================================