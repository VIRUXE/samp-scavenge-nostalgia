CMD:discord(playerid) return ChatMsg(playerid, 0xFFAA00, " > https://discord.gg/jduSSH2Ezf");

CMD:dicas(playerid)
{
	if(IsPlayerToolTipsOn(playerid)){
		ChatMsg(playerid, YELLOW, "player/tips/off");
		SetPlayerToolTips(playerid, false);
		HideHelpTip(playerid);
	}else{
		ChatMsg(playerid, YELLOW, "player/tips/on");
		SetPlayerToolTips(playerid, true);
	}

	return 1;
}

CMD:tooltips(playerid) return cmd_dicas(playerid);

CMD:mudarsenha(playerid, params[])
{
	new
		oldpass[32],
		newpass[32],
		buffer[MAX_PASSWORD_LEN];

	if(!IsPlayerLoggedIn(playerid))
	{
		ChatMsg(playerid, YELLOW, "player/command/cant-use-not-logged-in");
		return 1;
	}

	if(sscanf(params, "s[32]s[32]", oldpass, newpass))
	{
		ChatMsg(playerid, YELLOW, "player/changepassword/syntax");
		return 1;
	}
	else
	{
		new storedhash[MAX_PASSWORD_LEN];

		GetPlayerPassHash(playerid, storedhash);
		WP_Hash(buffer, MAX_PASSWORD_LEN, oldpass);

		if(!strcmp(buffer, storedhash))
		{
			new name[MAX_PLAYER_NAME];

			GetPlayerName(playerid, name, MAX_PLAYER_NAME);

			WP_Hash(buffer, MAX_PASSWORD_LEN, newpass);

			if(SetAccountPassword(name, buffer))
			{
				SetPlayerPassHash(playerid, buffer);
				ChatMsg(playerid, YELLOW, "PASSCHANGED", newpass);
			}
			else
			{
				ChatMsg(playerid, RED, "player/changepassword/error");
			}
		}
		else
		{
			ChatMsg(playerid, RED, "player/changepassword/no-match");
		}
	}
	return 1;
}

CMD:pos(playerid){
	new Float:x, Float:y, Float:z;
	GetPlayerPos(playerid, x, y, z);

	ChatMsg(playerid, YELLOW, " >  Sua posição: "C_BLUE"%.2f, %.2f, %.2f", x, y, z);

	return 1;
}

// ===========================================================================================================

CMD:ajuda(playerid)
{
	ShowPlayerDialog(playerid, 10008, DIALOG_STYLE_MSGBOX, "Informações/Informations", ls(playerid, "server/command/help"), "X", "");
	return 1;
}

CMD:help(playerid) return cmd_ajuda(playerid);
CMD:comandos(playerid) return cmd_ajuda(playerid);

// ===========================================================================================================

CMD:regras(playerid)
{
	ShowPlayerDialog(playerid, 12450, DIALOG_STYLE_MSGBOX, "Regras/Rules", ls(playerid, "server/command/lists/rules"), "X", "");
	return 1;
}

CMD:rules(playerid) return cmd_regras(playerid);

// ===========================================================================================================

CMD:explosivos(playerid)
{
	ShowPlayerDialog(playerid, 12550, DIALOG_STYLE_MSGBOX, "Explosivos/Explosives", ls(playerid, "server/command/bombs-list"), "X", "");
	return 1;
}

CMD:explosives(playerid) return cmd_explosivos(playerid);
CMD:bombas(playerid) return cmd_explosivos(playerid);

// ===========================================================================================================

CMD:metais(playerid)
{
	ShowPlayerDialog(playerid, 12650, DIALOG_STYLE_MSGBOX, "Defesas/Defences", ls(playerid, "defences-list"), "X", "");
	return 1;
}

CMD:defences(playerid) return cmd_metais(playerid);

// ===========================================================================================================

CMD:mochilas(playerid)
{
	ShowPlayerDialog(playerid, 12750, DIALOG_STYLE_MSGBOX, "Mochilas/Backpacks", ls(playerid, "server/command/lists/backpack"), "X", "");
	return 1;
}

CMD:backpacks(playerid) return cmd_mochilas(playerid);

// ===========================================================================================================

CMD:caixas(playerid)
{
	ShowPlayerDialog(playerid, 12850, DIALOG_STYLE_MSGBOX, "Caixas/Boxes", ls(playerid, "server/command/lists/boxes"), "X", "");
	return 1;
}

CMD:boxes(playerid) return cmd_caixas(playerid);

// ===========================================================================================================