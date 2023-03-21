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
				"motd", JSON_String("Bem vindo ao servidor Scavenge Nostalgia!"),
				"address", JSON_String("scavengenostalgia.fun"),
				"website", JSON_String("http://www.scavengenostalgia.fun"),
				"discord", JSON_String("http://discord.scavengenostalgia.fun"),
				"global-debug-level", JSON_Int(0),
				"loot-spawn-multiplier", JSON_Float(0.010000),
				"max-uptime", JSON_Int(14400), // 4 horas em segundos
				"rules", JSON_Array(
					JSON_String("Não use hacks."),
					JSON_String("Não use bugs."),
					JSON_String("Não use exploits."),
					JSON_String("Não use macros."),
					JSON_String("Não use programas de terceiros.")
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
				"weather", JSON_Int(4)
			)
		);

		JSON_SaveFile("settings.json", Settings, .pretty = true);
	}

	// ! Sem validação mesmo, se o cara colocar um valor errado, vai dar merda. Que se foda.

	// Carrega as configurações do servidor
	JSON_GetObject(Settings, "server", node);

	JSON_GetString(node, "motd", gMessageOfTheDay);
	log("[SETTINGS] Mensagem do dia: %s", gMessageOfTheDay);

	JSON_GetString(node, "website", gWebsiteURL);
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