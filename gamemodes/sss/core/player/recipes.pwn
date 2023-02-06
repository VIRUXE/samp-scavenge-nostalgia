/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.

		This file was originally written by Adam Kadar:
		<https://github.com/kadaradam>


==============================================================================*/


CMD:crafts(playerid, params[])
{
	ShowCraftTypes(playerid);
	return 1;
}

ShowCraftTypes(playerid)
{
	Dialog_Show(playerid, CraftTypes, DIALOG_STYLE_LIST, "Combina��es", "No invent�rio\nNo ch�o\n"C_GREEN"Ajuda", "Selecionar", "Fechar");
}

Dialog:CraftTypes(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		switch(listitem)
		{
			case 0:
				ShowCraftList(playerid, 1);
			case 1:
				ShowCraftList(playerid, 2);
			case 2:
				ShowCraftHelp(playerid);
				
		}
	}
}

ShowCraftList(playerid, type)
{
	// 0 All
	// 1 Combine
	// 2 Consset

	new
		f_str[812],
		itemname[ITM_MAX_NAME];

	for(new i; i < GetCraftSetTotal(); i++)
	{
		if(IsValidCraftSet(i))
		{
			if(type == 1)
			{
				if(GetCraftSetConstructSet(i) != -1)
					continue;
			}
			if(type == 2)
			{
				new
					consset = GetCraftSetConstructSet(i);

				if(consset == -1)
					continue;
			}
			GetItemTypeName(GetCraftSetResult(i), itemname);
		}
		else
		{
			itemname = "INVALID CRAFT SET";
		}

		format(f_str, sizeof(f_str), "%s%i. %s\n", f_str, i, itemname);
	}

	Dialog_Show(playerid, CraftList, DIALOG_STYLE_LIST, "Lista de Crafts", f_str, "Ver", "Fechar");
}

Dialog:CraftList(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new consset;

		sscanf(inputtext, "p<.>i{s[96]}", consset);

		ShowIngredients(playerid, consset);
	}
	else
	{
		ShowCraftTypes(playerid);
	}
}

ShowIngredients(playerid, craftset)
{
	if(!IsValidCraftSet(craftset))
		return 1;

	gBigString[playerid][0] = EOS;

	new
		ItemType:itemType,
		itemname[ITM_MAX_NAME],
		toolname[ITM_MAX_NAME],
		consset = GetCraftSetConstructSet(craftset);

	for(new i; i < GetCraftSetItemCount(craftset); i++)
	{
		itemType = GetCraftSetItemType(craftset, i);
		GetItemTypeName(itemType, itemname);
		format(gBigString[playerid], sizeof(gBigString[]), "%s\t\t\t%s\n", gBigString[playerid], itemname);
	}

	if(consset != -1)
	{
		GetItemTypeName(GetConstructionSetTool(consset), toolname);
		format(gBigString[playerid], sizeof(gBigString[]), "\
			"C_WHITE"Ferramenta: 			"C_YELLOW"%s\n\n\
			"C_WHITE"Ingredientes:	"C_YELLOW"\n%s", toolname, gBigString[playerid]);
	}
	else
	{
		format(gBigString[playerid], sizeof(gBigString[]), "\
			"C_WHITE"Ingredientes:	"C_YELLOW"\n%s", gBigString[playerid]);
	}

	GetItemTypeName(GetCraftSetResult(craftset), itemname);

	Dialog_Show(playerid, Ingredients, DIALOG_STYLE_MSGBOX, itemname, gBigString[playerid], "Fechar", "Voltar");

	return 0;
}

Dialog:Ingredients(playerid, response, listitem, inputtext[])
{
	if(!response)
	{
		ShowCraftTypes(playerid);
	}
}

ShowCraftHelp(playerid)
{
	gBigString[playerid][0] = EOS;

	strcat(gBigString[playerid], "Crafting � uma forma de criar novos itens a partir de itens existentes.\n");
	strcat(gBigString[playerid], "Existem tr�s maneiras de combinar itens em Scavenge e Survive:\n\n");

	strcat(gBigString[playerid], C_YELLOW"Em Telas de Invent�rio (Craftando ou Combinando):\n\n");
	strcat(gBigString[playerid], C_WHITE"Ao ver o seu invent�rio ou um container (porta malas, caixas, mochilas, etc)\n");
	strcat(gBigString[playerid], C_WHITE"Selecione 'Combinar' nas op��es do item\n");
	strcat(gBigString[playerid], C_WHITE"Volte e abra as op��es para outro item\n");
	strcat(gBigString[playerid], C_WHITE"Selecione 'Combinar com ...' para combinar os itens juntos\n");
	strcat(gBigString[playerid], C_WHITE"Se uma combina��o precisar de mais de dois itens, basta repetir.\n\n");

	strcat(gBigString[playerid], C_GREEN"No ch�o (Constru��o):\n\n");
	strcat(gBigString[playerid], C_WHITE"Coloque todos os ingredientes no ch�o\n");
	strcat(gBigString[playerid], C_WHITE"Equipar o item 'Ferramenta' especificado na p�gina da combina��o\n");
	strcat(gBigString[playerid], C_WHITE"Segure a tecla F enquanto est� perto dos ingredientes\n\n");

	strcat(gBigString[playerid], C_BLUE"Mesa de Trabalho:\n\n");
	strcat(gBigString[playerid], C_WHITE"Coloque todos os itens de ingrediente na Mesa de Trabalho (A Mesa de Trabalho atua como uma caixa)\n");
	strcat(gBigString[playerid], C_WHITE"Equipar o item 'Ferramenta' especificado na p�gina da Combina��o\n");
	strcat(gBigString[playerid], C_WHITE"Segure a tecla F proximo da Mesa de Trabalho");

	Dialog_Show(playerid, CraftHelp, DIALOG_STYLE_MSGBOX, "Crafting Help", gBigString[playerid], "Voltar", "Cancelar");
}

Dialog:CraftHelp(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		ShowCraftTypes(playerid);
	}
}
