new Node:Settings;

LoadSettings()
{
	new result;
	new Node:node, length;

	log("[SETTINGS] Carregando configurações...");

	result = JSON_ParseFile("settings.json", Settings);
	if(result) // Não foi possível carregar o arquivo
	{
		log("[SETTINGS] Erro: Não foi possível carregar o arquivo de configurações. Usando as configurações padrão.");

		Settings = JSON_Object(
			"server", JSON_Object(
				"name", JSON_String("Scavenge Nostalgia"),
				"address", JSON_String("scavengenostalgia.fun"),
				"website", JSON_String("http://www.scavengenostalgia.fun"),
				"discord", JSON_String("http://discord.scavengenostalgia.fun"),
				"global-debug-level", JSON_Int(0),
				"max-uptime", JSON_Int(14400), // 4 horas em segundos
				"motd", JSON_Object(
					"pt", JSON_String("Bem vindo ao servidor Scavenge Nostalgia!"),
					"en", JSON_String("Welcome to the Scavenge Nostalgia server!")
				),
				"rules", JSON_Array(
					JSON_String("Não use hacks."),
					JSON_String("Não use bugs."),
					JSON_String("Não use exploits."),
					JSON_String("Não use macros."),
					JSON_String("Não use programas de terceiros.")
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
				"tooltips", JSON_Array(
					JSON_Object(
						"pt", JSON_String("Caso tenha alguma dúvida, use o /relatorio para falar com alguém da staff."),
						"en", JSON_String("If you have any questions, use /report to speak with a staff member.")
					),
					JSON_Object(
						"pt", JSON_String("Caso encontre algum BUG, use o /bug para reportar a staff."),
						"en", JSON_String("If you find any bugs, use /bug to report them to the staff.")
					),
					JSON_Object(
						"pt", JSON_String("Use o /dicas para desativar as dicas de ajuda."),
						"en", JSON_String("Use /tips to turn off the help messages.")
					),
					JSON_Object(
						"pt", JSON_String("Entre em nosso grupo no discord e fique por dentro de todas as novidades."),
						"en", JSON_String("Join our Discord group and stay up-to-date with all the latest news.")
					),
					JSON_Object(
						"pt", JSON_String("Chame seus amigos para jogar no servidor, jogar em grupo é mais legal e lucrativo."),
						"en", JSON_String("Invite your friends to play on the server, playing in a group is more fun and rewarding.")
					),
					JSON_Object(
						"pt", JSON_String("Você viu alguém fazendo o que não devia? Use /report para denunciar."),
						"en", JSON_String("Did you see someone doing something they shouldn't? Use /report to report them.")
					),
					JSON_Object(
						"pt", JSON_String("Não fique triste quando morrer ou perder a base, isso faz parte do jogo."),
						"en", JSON_String("Don't get upset when you die or lose your base, it's part of the game.")
					),
					JSON_Object(
						"pt", JSON_String("Lembre-se que o servidor é mantido por doações, ajude-nos a manter o servidor online."),
						"en", JSON_String("Remember that the server is maintained by donations, help us keep the server online.")
					),
					JSON_Object(
						"pt", JSON_String("Você pode usar o /ajuda para ver todos os comandos disponíveis."),
						"en", JSON_String("You can use /help to see all the available commands.")
					),
					JSON_Object(
						"pt", JSON_String("Lembre-se de utilizar o /votekick para votar em jogadores que estão quebrando as regras."),
						"en", JSON_String("Remember to use /votekick to vote on players who are breaking the rules.")
					)
				)
			),
			"vehicle", JSON_Object(
				"spawn", JSON_Object(
					"chance", JSON_Float(1.0),
					"print-each", JSON_Bool(false),
					"print-total", JSON_Bool(true)
				),
				"damage", JSON_Object(
					"knock-mult", JSON_Float(1.0),
					"bleed-mult", JSON_Float(1.0)
				)
			),
			"world", JSON_Object(
				"loot-spawn-multiplier", JSON_Float(0.010000),
				"weather", JSON_Int(4)
			)
		);

		JSON_SaveFile("settings.json", Settings, .pretty = true);
	}

	// ! Sem validação mesmo, se o cara colocar um valor errado, vai dar merda. Que se foda.

	// Carrega as configurações do servidor
	JSON_GetObject(Settings, "server", node);

	new Node:motd;
	JSON_GetArray(node, "motd", motd);
	JSON_GetString(motd, "pt", gMessageOfTheDay);
	log("[SETTINGS] Mensagem do dia: %s", gMessageOfTheDay);

	JSON_GetString(node, "website", gWebsiteURL);
	SendRconCommand(sprintf("weburl %s", gWebsiteURL));
	log("[SETTINGS] Website: %s", gWebsiteURL);

	// Podemos carregar ate 24 regras (MAX_RULE)
	new Node:rules;

	JSON_GetArray(node, "rules", rules);
	JSON_ArrayLength(rules, length);

	// Certificar de que não tentamos carregar mais regras do que o máximo permitido (MAX_RULE)
	if(length > MAX_RULE) {
		length = MAX_RULE;
		log("[SETTINGS] Aviso: O número de regras excede o máximo permitido. As regras extras serão ignoradas.");
	}

	for(new i = 0; i < length; i++) {
		new Node:rule;

		JSON_ArrayObject(rules, i, rule);
		JSON_GetNodeString(rule, gRuleList[i], MAX_RULE_LEN);

		log("[SETTINGS] Regra %d: %s", i + 1, gRuleList[i]);
	}

	JSON_GetInt(node, "max-uptime", gServerMaxUptime);
	log("[SETTINGS] Ciclo de Restart: %d horas", gServerMaxUptime / 3600);

	// Carrega as configurações do jogador
	JSON_GetObject(Settings, "player", node);

	JSON_GetInt(node, "combat-log-window", gCombatLogWindow);
	log("[SETTINGS] Janela de Log de Combate: %d segundos", gCombatLogWindow);

	JSON_GetInt(node, "login-freeze-time", gLoginFreezeTime);
	log("[SETTINGS] Tempo de congelamento de login: %d segundos", gLoginFreezeTime);

	JSON_GetInt(node, "max-tab-out-time", gMaxTaboutTime);
	log("[SETTINGS] Tempo máximo de tab-out: %d segundos", gMaxTaboutTime);

	JSON_GetInt(node, "ping-limit", gPingLimit);
	log("[SETTINGS] Limite de ping: %d", gPingLimit);
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