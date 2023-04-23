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
				"tips", JSON_Array(
					JSON_Array(
						JSON_String("Caso tenha alguma dúvida, use o /relatorio para falar com alguém da staff."),
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
						JSON_String("Chame seus amigos para jogar no servidor, jogar em grupo é mais legal e lucrativo."),
						JSON_String("Invite your friends to play on the server, playing in a group is more fun and rewarding.")
					),
					JSON_Array(
						JSON_String("Você viu alguém fazendo o que não devia? Use /report para denunciar."),
						JSON_String("Did you see someone doing something they shouldn't? Use /report to report them.")
					),
					JSON_Array(
						JSON_String("Não fique triste quando morrer ou perder a base, isso faz parte do jogo."),
						JSON_String("Don't get upset when you die or lose your base, it's part of the game.")
					),
					JSON_Array(
						JSON_String("Lembre-se que o servidor é mantido por doações, ajude-nos a manter o servidor online."),
						JSON_String("Remember that the server is maintained by donations, help us keep the server online.")
					),
					JSON_Array(
						JSON_String("Você pode usar o /ajuda para ver todos os comandos disponíveis."),
						JSON_String("You can use /help to see all the available commands.")
					),
					JSON_Array(
						JSON_String("Lembre-se de utilizar o /votekick para votar em jogadores que estão quebrando as regras."),
						JSON_String("Remember to use /votekick to vote on players who are breaking the rules.")
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

		JSON_SaveFile("settings.json", Settings, .pretty = true);
	}

	// Carrega as configurações do servidor
	new Node:server;
	JSON_GetObject(Settings, "server", server);

	new env[5];
	JSON_GetString(server, "env", env);

	// No caso de a propriedade nao existir, coloca em modo de producao
	gEnvironment = isequal(env, "dev") ? DEVELOPMENT : PRODUCTION;

	JSON_GetArray(server, "motd", node);
	JSON_ArrayObject(node, 0, node);
	JSON_GetNodeString(node, gMessageOfTheDay);
	log("[SETTINGS] Mensagem do dia: %s", gMessageOfTheDay);

	JSON_GetString(server, "website", gWebsiteURL);
	SendRconCommand(sprintf("weburl %s", gWebsiteURL));
	log("[SETTINGS] Website: %s", gWebsiteURL);

	// Podemos carregar ate 24 regras (MAX_RULE)
	new Node:rules;
	JSON_GetArray(server, "rules", rules);
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

	JSON_GetInt(server, "max-uptime", gServerMaxUptime);
	log("[SETTINGS] Ciclo de Restart: %d horas", (gServerMaxUptime ? gServerMaxUptime : 14400) / 3600);

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