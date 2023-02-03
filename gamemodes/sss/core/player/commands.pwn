CMD:discord(playerid) return ChatMsg(playerid, 0xFFAA00, " » https://discord.gg/jduSSH2Ezf");

CMD:dicas(playerid)
{
	if(IsPlayerToolTipsOn(playerid))
	{
		ChatMsgLang(playerid, YELLOW, "TOOLTIPSOFF");
		SetPlayerToolTips(playerid, false);
		HideHelpTip(playerid);
	}
	else
	{
		ChatMsgLang(playerid, YELLOW, "TOOLTIPSON");
		SetPlayerToolTips(playerid, true);
	}

	return 1;
}

CMD:consejos(playerid)
{
	if(IsPlayerToolTipsOn(playerid))
	{
		ChatMsgLang(playerid, YELLOW, "TOOLTIPSOFF");
		SetPlayerToolTips(playerid, false);
		HideHelpTip(playerid);
	}
	else
	{
		ChatMsgLang(playerid, YELLOW, "TOOLTIPSON");
		SetPlayerToolTips(playerid, true);
	}

	return 1;
}

CMD:tooltips(playerid)
{
	if(IsPlayerToolTipsOn(playerid))
	{
		ChatMsgLang(playerid, YELLOW, "TOOLTIPSOFF");
		SetPlayerToolTips(playerid, false);
		HideHelpTip(playerid);
	}
	else
	{
		ChatMsgLang(playerid, YELLOW, "TOOLTIPSON");
		SetPlayerToolTips(playerid, true);
	}

	return 1;
}

CMD:changepass(playerid,params[])
{
	new
		oldpass[32],
		newpass[32],
		buffer[MAX_PASSWORD_LEN];

	if(!IsPlayerLoggedIn(playerid))
	{
		ChatMsgLang(playerid, YELLOW, "LOGGEDINREQ");
		return 1;
	}

	if(sscanf(params, "s[32]s[32]", oldpass, newpass))
	{
		ChatMsgLang(playerid, YELLOW, "CHANGEPASSW");
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
				ChatMsgLang(playerid, YELLOW, "PASSCHANGED", newpass);
			}
			else
			{
				ChatMsgLang(playerid, RED, "PASSCHERROR");
			}
		}
		else
		{
			ChatMsgLang(playerid, RED, "PASSCHNOMAT");
		}
	}
	return 1;
}

CMD:pos(playerid)
{
	new
		Float:x,
		Float:y,
		Float:z;

	GetPlayerPos(playerid, x, y, z);

	ChatMsg(playerid, YELLOW, " >  Sua posição: "C_BLUE"%.2f, %.2f, %.2f", x, y, z);

	return 1;
}

CMD:mudarsenha(playerid,params[])
{
	new
		oldpass[32],
		newpass[32],
		buffer[MAX_PASSWORD_LEN];

	if(!IsPlayerLoggedIn(playerid))
	{
		ChatMsgLang(playerid, YELLOW, "LOGGEDINREQ");
		return 1;
	}

	if(sscanf(params, "s[32]s[32]", oldpass, newpass))
	{
		ChatMsgLang(playerid, YELLOW, "CHANGEPASSW");
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
				ChatMsgLang(playerid, YELLOW, "PASSCHANGED", newpass);
			}
			else
			{
				ChatMsgLang(playerid, RED, "PASSCHERROR");
			}
		}
		else
		{
			ChatMsgLang(playerid, RED, "PASSCHNOMAT");
		}
	}
	return 1;
}

// ===========================================================================================================

CMD:ajuda(playerid)
{
	ShowPlayerDialog(playerid, 10008, DIALOG_STYLE_MSGBOX, "Informações gerais", ls(playerid, "GENCOMDHELP"), "X", "");
	return 1;
}

CMD:ayuda(playerid)
{
	ShowPlayerDialog(playerid, 10008, DIALOG_STYLE_MSGBOX, "Informações gerais", ls(playerid, "GENCOMDHELP"), "X", "");
	return 1;
}

CMD:comandos(playerid)
{
	ShowPlayerDialog(playerid, 10008, DIALOG_STYLE_MSGBOX, "Informações gerais", ls(playerid, "GENCOMDHELP"), "X", "");
	return 1;
}

CMD:help(playerid)
{
	ShowPlayerDialog(playerid, 10008, DIALOG_STYLE_MSGBOX, "Informações gerais", ls(playerid, "GENCOMDHELP"), "X", "");
	return 1;
}

CMD:cmds(playerid)
{
	ShowPlayerDialog(playerid, 10008, DIALOG_STYLE_MSGBOX, "Informações gerais", ls(playerid, "GENCOMDHELP"), "X", "");
	return 1;
}

// ===========================================================================================================

CMD:regras(playerid)
{
	ShowPlayerDialog(playerid, 12450, DIALOG_STYLE_MSGBOX, "Regras", ls(playerid, "RULESLIST"), "X", "");
	return 1;
}

CMD:rules(playerid)
{
	ShowPlayerDialog(playerid, 12450, DIALOG_STYLE_MSGBOX, "Rules", ls(playerid, "RULESLIST"), "X", "");
	return 1;
}

CMD:reglas(playerid)
{
	ShowPlayerDialog(playerid, 12450, DIALOG_STYLE_MSGBOX, "Reglas", ls(playerid, "RULESLIST"), "X", "");
	return 1;
}

CMD:regles(playerid)
{
	ShowPlayerDialog(playerid, 12450, DIALOG_STYLE_MSGBOX, "Regles", ls(playerid, "RULESLIST"), "X", "");
	return 1;
}

// ===========================================================================================================

CMD:explosivos(playerid)
{
	ShowPlayerDialog(playerid, 12550, DIALOG_STYLE_MSGBOX, "Explosivos", ls(playerid, "BOMBSLIST"), "X", "");
	return 1;
}

CMD:explosives(playerid)
{
	ShowPlayerDialog(playerid, 12550, DIALOG_STYLE_MSGBOX, "Explosives", ls(playerid, "BOMBSLIST"), "X", "");
	return 1;
}

CMD:bombas(playerid)
{
	ShowPlayerDialog(playerid, 12550, DIALOG_STYLE_MSGBOX, "Bombas", ls(playerid, "BOMBSLIST"), "X", "");
	return 1;
}

CMD:explosifs(playerid)
{
	ShowPlayerDialog(playerid, 12550, DIALOG_STYLE_MSGBOX, "Explosifs", ls(playerid, "BOMBSLIST"), "X", "");
	return 1;
}

// ===========================================================================================================

CMD:metais(playerid)
{
	ShowPlayerDialog(playerid, 12650, DIALOG_STYLE_MSGBOX, "Metais", ls(playerid, "DEFENCESLIST"), "X", "");
	return 1;
}

CMD:defences(playerid)
{
	ShowPlayerDialog(playerid, 12650, DIALOG_STYLE_MSGBOX, "Defences", ls(playerid, "DEFENCESLIST"), "X", "");
	return 1;
}

CMD:defensas(playerid)
{
	ShowPlayerDialog(playerid, 12650, DIALOG_STYLE_MSGBOX, "Defensas", ls(playerid, "DEFENCESLIST"), "X", "");
	return 1;
}

CMD:defenses(playerid)
{
	ShowPlayerDialog(playerid, 12650, DIALOG_STYLE_MSGBOX, "Defenses", ls(playerid, "DEFENCESLIST"), "X", "");
	return 1;
}

// ===========================================================================================================

CMD:mochilas(playerid)
{
	ShowPlayerDialog(playerid, 12750, DIALOG_STYLE_MSGBOX, "Mochilas", ls(playerid, "BACKPACKLIST"), "X", "");
	return 1;
}

CMD:backpacks(playerid)
{
	ShowPlayerDialog(playerid, 12750, DIALOG_STYLE_MSGBOX, "Backpacks", ls(playerid, "BACKPACKLIST"), "X", "");
	return 1;
}

CMD:bolsas(playerid)
{
	ShowPlayerDialog(playerid, 12750, DIALOG_STYLE_MSGBOX, "Bolsas", ls(playerid, "BACKPACKLIST"), "X", "");
	return 1;
}

CMD:sacs(playerid)
{
	ShowPlayerDialog(playerid, 12750, DIALOG_STYLE_MSGBOX, "Sacs", ls(playerid, "BACKPACKLIST"), "X", "");
	return 1;
}

// ===========================================================================================================

CMD:caixas(playerid)
{
	ShowPlayerDialog(playerid, 12850, DIALOG_STYLE_MSGBOX, "Caixas", ls(playerid, "BOXESLIST"), "X", "");
	return 1;
}

CMD:boxes(playerid)
{
	ShowPlayerDialog(playerid, 12850, DIALOG_STYLE_MSGBOX, "Boxes", ls(playerid, "BOXESLIST"), "X", "");
	return 1;
}

CMD:cajas(playerid)
{
	ShowPlayerDialog(playerid, 12850, DIALOG_STYLE_MSGBOX, "Cajas", ls(playerid, "BOXESLIST"), "X", "");
	return 1;
}

CMD:boites(playerid)
{
	ShowPlayerDialog(playerid, 12850, DIALOG_STYLE_MSGBOX, "Boites", ls(playerid, "BOXESLIST"), "X", "");
	return 1;
}

// ===========================================================================================================
