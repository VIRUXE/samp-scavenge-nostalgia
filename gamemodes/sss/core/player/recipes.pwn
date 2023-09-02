
CMD:crafts(playerid, params[]) {
	ShowCraftTypes(playerid);
	return 1;
}

ShowCraftTypes(playerid) {
	Dialog_Show(playerid, CraftTypes, DIALOG_STYLE_LIST, "Combinações", "No inventário\nNo chão\n"C_GREEN"Ajuda", "Selecionar", "Fechar");
}

Dialog:CraftTypes(playerid, response, listitem, inputtext[]) {
	if(response) {
		switch(listitem) {
			case 0: ShowCraftList(playerid, 1);
			case 1: ShowCraftList(playerid, 2);
			case 2: ShowCraftHelp(playerid);
		}
	}
}

ShowCraftList(playerid, type) {
	// 0 All
	// 1 Combine
	// 2 Consset

	new
		f_str[812],
		itemName[ITM_MAX_NAME];

	for(new i; i < GetCraftSetTotal(); i++) {
		if(IsValidCraftSet(i)) {
			if(type == 1) {
				if(GetCraftSetConstructSet(i) != -1) continue;
			} else if(type == 2) {
				if(GetCraftSetConstructSet(i) == -1) continue;
			}

			GetItemTypeName(GetCraftSetResult(i), itemName);
		}
		else
			itemName = "INVALID CRAFT SET";

		format(f_str, sizeof(f_str), "%s%i. %s\n", f_str, i, itemName);
	}

	Dialog_Show(playerid, CraftList, DIALOG_STYLE_LIST, "Lista de Crafts", f_str, "Ver", "Fechar");
}

Dialog:CraftList(playerid, response, listitem, inputtext[]) {
	if(response) {
		new consset;

		sscanf(inputtext, "p<.>i{s[96]}", consset);

		ShowIngredients(playerid, consset);
	} else
		ShowCraftTypes(playerid);
}

ShowIngredients(playerid, craftset) {
	if(!IsValidCraftSet(craftset)) return 1;

	gBigString[playerid][0] = EOS;

	new
		ItemType:itemType,
		itemName[ITM_MAX_NAME],
		constructionSet = GetCraftSetConstructSet(craftset);

	for(new i; i < GetCraftSetItemCount(craftset); i++) {
		itemType = GetCraftSetItemType(craftset, i);
		GetItemTypeName(itemType, itemName);
		format(gBigString[playerid], sizeof(gBigString[]), "%s\t\t\t%s\n", gBigString[playerid], itemName);
	}

	if(constructionSet != -1) {
		new toolName[ITM_MAX_NAME];

		GetItemTypeName(GetConstructionSetTool(constructionSet), toolName);

		format(gBigString[playerid], sizeof(gBigString[]), "\
			"C_WHITE"Ferramenta: 			"C_YELLOW"%s\n\n\
			"C_WHITE"Ingredientes:	"C_YELLOW"\n%s", toolName, gBigString[playerid]);
	} else
		format(gBigString[playerid], sizeof(gBigString[]), C_WHITE"Ingredientes:	"C_YELLOW"\n%s", gBigString[playerid]);

	GetItemTypeName(GetCraftSetResult(craftset), itemName);

	Dialog_Show(playerid, Ingredients, DIALOG_STYLE_MSGBOX, itemName, gBigString[playerid], "Fechar", "Voltar");

	return 0;
}

Dialog:Ingredients(playerid, response, listitem, inputtext[]) {
	if(!response) ShowCraftTypes(playerid);
}

ShowCraftHelp(playerid) {
	gBigString[playerid][0] = EOS;

	strcat(gBigString[playerid], "Crafting é uma forma de criar novos itens a partir de itens existentes.\n");
	strcat(gBigString[playerid], "Existem três maneiras de combinar itens no Scavenge e Survive:\n\n");

	strcat(gBigString[playerid], C_YELLOW"Em Telas de Inventário (Craftando ou Combinando):\n\n");
	strcat(gBigString[playerid], C_WHITE"Ao ver o seu Inventário ou um Container (porta malas, caixas, mochilas, etc)\n");
	strcat(gBigString[playerid], C_WHITE"Selecione 'Combinar' nas opções do item\n");
	strcat(gBigString[playerid], C_WHITE"Volte e abra as opções para outro item\n");
	strcat(gBigString[playerid], C_WHITE"Selecione 'Combinar com ...' para combinar os itens juntos\n");
	strcat(gBigString[playerid], C_WHITE"Se uma combinação precisar de mais de dois itens, basta repetir.\n\n");

	strcat(gBigString[playerid], C_GREEN"No chão (Construção):\n\n");
	strcat(gBigString[playerid], C_WHITE"Coloque todos os ingredientes no chão\n");
	strcat(gBigString[playerid], C_WHITE"Equipar o item 'Ferramenta' especificado no dialog da combinação\n");
	strcat(gBigString[playerid], C_WHITE"Segure a tecla F enquanto está perto dos ingredientes\n\n");

	strcat(gBigString[playerid], C_BLUE"Mesa de Trabalho:\n\n");
	strcat(gBigString[playerid], C_WHITE"Coloque todos os itens de ingrediente na Mesa de Trabalho (A Mesa de Trabalho atua como uma caixa)\n");
	strcat(gBigString[playerid], C_WHITE"Equipar o item 'Ferramenta' especificado no dialog da combinação\n");
	strcat(gBigString[playerid], C_WHITE"Segure a tecla F proximo da Mesa de Trabalho");

	Dialog_Show(playerid, CraftHelp, DIALOG_STYLE_MSGBOX, "Ajuda de Crafting:", gBigString[playerid], "Voltar", "Cancelar");
}

Dialog:CraftHelp(playerid, response, listitem, inputtext[]) {
	if(response) ShowCraftTypes(playerid);
}
