
new Node:Settings;

LoadSettings()
{
	log("[SETTINGS] Carregando configura??es...");

	if(JSON_ParseFile("settings.json", Settings)) { // N?o foi poss?vel carregar o arquivo
		log("[SETTINGS] Erro: N?o foi poss?vel carregar o arquivo de configura??es. Usando as configura??es padr?o.");

		Settings = JSON_Object(
			"server", JSON_Object(
				"env", JSON_String("prod"),
				"name", JSON_String("Nostalgia ~ Scavenge"),
				"address", JSON_String("scavengenostalgia.fun"),
				"website", JSON_String("http://www.scavengenostalgia.fun"),
				"discord", JSON_String("http://discord.scavengenostalgia.fun"),
				"global-debug-level", JSON_Int(0),
				"max-uptime", JSON_Int(14400), // 4 horas em segundos
				"motd", JSON_Array(
					JSON_String("Bem vindo ao servidor Nostalgia ~ Scavenge!"),
					JSON_String("Welcome to the Nostalgia ~ Scavenge server!")
				),
				"rules", JSON_Array(
					JSON_String("N?o use hacks."),
					JSON_String("N?o use bugs."),
					JSON_String("N?o use exploits."),
					JSON_String("N?o use macros."),
					JSON_String("N?o use programas de terceiros.")
				),
				"otp", JSON_Object(
					"enabled", JSON_Bool(false),
					"length", JSON_Int(6)
				)
			),
			"player", JSON_Object(
				"combat-log-window", JSON_Int(30),
				"login-freeze-time", JSON_Int(8),
				"max-tab-out-time", JSON_Int(60),
				"ping-limit", JSON_Int(300),
				"spawn", JSON_Object(
					// Normal e VIP
					"blood", JSON_Object(
						"normal", JSON_Float(100.0),
						"vip", JSON_Float(100.0)
					),
					"food", JSON_Object(
						"normal", JSON_Float(80.0),
						"vip", JSON_Float(100.0)
					),
					"bleed", JSON_Object(
						"normal", JSON_Float(0.0),
						"vip", JSON_Float(0.0)
					)
				),
				"tips", JSON_Array(
					JSON_Array(
						JSON_String("Caso tenha alguma d?vida, use o /relatorio para falar com algu?m da staff."),
						JSON_String("If you have any questions, use /report to speak with a staff member.")
					),
					JSON_Array(
						JSON_String("Caso encontre algum BUG, use o /bug para reportar a staff."),
						JSON_String("If you find any bugs, use /bug to report them to the staff.")
					),
					JSON_Array(
						JSON_String("Use o /dicas para desativar as dicas de ajuda."),
						JSON_String("Use /tips to turn off the help messages.")
					),
					JSON_Array(
						JSON_String("Entre em nosso grupo no discord e fique por dentro de todas as novidades."),
						JSON_String("Join our Discord group and stay up-to-date with all the latest news.")
					),
					JSON_Array(
						JSON_String("Chame seus amigos para jogar no servidor, jogar em grupo ? mais legal e lucrativo."),
						JSON_String("Invite your friends to play on the server, playing in a group is more fun and rewarding.")
					),
					JSON_Array(
						JSON_String("Voc? viu algu?m fazendo o que n?o devia? Use /report para denunciar."),
						JSON_String("Did you see someone doing something they shouldn't? Use /report to report them.")
					),
					JSON_Array(
						JSON_String("N?o fique triste quando morrer ou perder a base, isso faz parte do jogo."),
						JSON_String("Don't get upset when you die or lose your base, it's part of the game.")
					),
					JSON_Array(
						JSON_String("Lembre-se que o servidor ? mantido por doa??es, ajude-nos a manter o servidor online."),
						JSON_String("Remember that the server is maintained by donations, help us keep the server online.")
					),
					JSON_Array(
						JSON_String("Voc? pode usar o /ajuda para ver todos os comandos dispon?veis."),
						JSON_String("You can use /help to see all the available commands.")
					),
					JSON_Array(
						JSON_String("Lembre-se de utilizar o /votekick para votar em jogadores que est?o quebrando as regras."),
						JSON_String("Remember to use /votekick to vote on players who are breaking the rules.")
					)
				),
				"info", JSON_Array(
					JSON_Array(
						JSON_Object(
							"command", JSON_String("bug")
						),
						JSON_Array(
							JSON_String("Bugs devem ser reportados apenas no Discord"),
							JSON_String("Bugs must be reported on Discord only")
						)
					),
					JSON_Array(
						JSON_Object(
							"command", JSON_String("tst")
						),
						JSON_Array(
							JSON_String("O servidor ainda se encontra em fase de testes. Significa que nao existe suporte e que pode ter reset."),
							JSON_String("The server is still under testing. Which means there is no support and resets can occur.")
						)
					),
					JSON_Array(
						JSON_Object(
							"command", JSON_String("otp")
						),
						JSON_Array(
							JSON_String("'Uma senha ?nica' ou 'Senha de uso ?nico' ? uma senha que ? v?lida apenas por uma sess?o de login ou transa??o e torna-se inv?lida ap?s isso."),
							JSON_String("One Time Password (OTP) is a password that is valid for only one login session or transaction, and becomes invalid after that.")
						)
					)
				)
			),
			"vehicle", JSON_Object(
				"spawn", JSON_Object(
					"chance", JSON_Float(4.0),
					"print-each", JSON_Bool(false),
					"print-total", JSON_Bool(true)
				),
				"damage", JSON_Object(
					"knock-mult", JSON_Float(1.0),
					"bleed-mult", JSON_Float(1.0)
				)
			),
			"world", JSON_Object(
				"loot-spawn-multiplier", JSON_Float(1.4),
				"weather", JSON_Int(4)
			)
		);

		JSON_SaveFile("settings.json", Settings, true);
	}

	CallLocalFunction("OnSettingsLoaded", "");
}

function OnSettingsLoaded() {
	new Node:node, length;
	
	// Carrega as configura??es do servidor
	new Node:server;
	JSON_GetObject(Settings, "server", server);

	new env[5];
	JSON_GetString(server, "env", env);

	// No caso de a propriedade nao existir, coloca em modo de producao
	gEnvironment = isequal(env, "dev") ? DEVELOPMENT : PRODUCTION;

	new website[64];
	JSON_GetString(server, "website", website);
	SendRconCommand(sprintf("weburl %s", website));
	log("[SETTINGS] Website: %s", website);

	// Podemos carregar ate 24 regras (MAX_RULE)
	new Node:rules;
	JSON_GetArray(server, "rules", rules);
	JSON_ArrayLength(rules, length);

	// Certificar de que n?o tentamos carregar mais regras do que o m?ximo permitido (MAX_RULE)
	if(length > MAX_RULE) {
		length = MAX_RULE;
		log("[SETTINGS] Aviso: O n?mero de regras excede o m?ximo permitido. As regras extras ser?o ignoradas.");
	}

	for(new i = 0; i < length; i++) {
		new Node:rule;

		JSON_ArrayObject(rules, i, rule);
		JSON_GetNodeString(rule, gRuleList[i], MAX_RULE_LEN);

		log("[SETTINGS] Regra %d: %s", i + 1, gRuleList[i]);
	}

	JSON_GetInt(server, "max-uptime", gServerMaxUptime);
	log("[SETTINGS] Ciclo de Restart: %d horas", (gServerMaxUptime ? gServerMaxUptime : 14400) / 3600);

	// Carrega as configura??es do jogador
	JSON_GetObject(Settings, "player", node);

	JSON_GetInt(node, "combat-log-window", gCombatLogWindow);
	log("[SETTINGS] Janela de Log de Combate: %d segundos", gCombatLogWindow);

	JSON_GetInt(node, "login-freeze-time", gLoginFreezeTime);
	log("[SETTINGS] Tempo de congelamento de login: %d segundos", gLoginFreezeTime);
}

stock GetSettingInt(const name[]) {
	new Node:node, Node:temp, i, result;
	new nameSplit[32][32], nameSplitCount;

	strsplit(name, "/", nameSplit, nameSplitCount); // Split the name into an array

	// Get the first level
	JSON_GetObject(Settings, nameSplit[0], node);

	// Go through each level
	for(i = 1; i < nameSplitCount; i++) {
		JSON_GetObject(node, nameSplit[i], temp);
		node = temp;
	}

	// Get the value
	JSON_GetNodeInt(node, result);

	return result;
}

stock Float:GetSettingFloat(const name[]) {
	new Node:node, Node:temp, i;
	new nameSplit[32][32], nameSplitCount;
	new Float:result;

	strsplit(name, "/", nameSplit, nameSplitCount); // Split the name into an array

	// Get the first level
	JSON_GetObject(Settings, nameSplit[0], node);

	// Go through each level
	for(i = 1; i < nameSplitCount; i++) {
		JSON_GetObject(node, nameSplit[i], temp);
		node = temp;
	}

	// Get the value
	JSON_GetNodeFloat(node, result);

	return result;
}

ACMD:rsettings[5](playerid) {
	new result = JSON_ParseFile("settings.json", Settings);

	if(!result)
		ChatMsgAdmins(1, YELLOW, "%p recarregou as definicoes", playerid);
	else
		ChatMsg(playerid, RED, "Nao foi possivel recarregar as definicoes");

	return 1;
}