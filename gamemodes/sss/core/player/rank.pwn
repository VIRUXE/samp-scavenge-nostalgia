// TODO: Refatorar essa merda toda.

#include <YSI\y_hooks>

CMD:rank(playerid)
{
    ShowRankingDialog(playerid);

	return 1;
}

ShowRankingDialog(playerid) {
    Dialog_Show(playerid, Ranking, DIALOG_STYLE_LIST,"{35B330}Ranking - Melhores Onlines","1º- Ranking de Score\n2º- Ranking de Spree\n3º- Ranking Mortes\n4º- Ranking Ping\n5º- Ranking Tempo Vivo","Selecionar","Sair");
}

Dialog:Ranking(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		switch(listitem)
		{
			case 0: ShowTopTenScoreForPlayer(playerid);
			case 1: ShowTopTenSpreeForPlayer(playerid);
			case 2: ShowTopTenMortesForPlayer(playerid);
			case 3: ShowTopTenPingForPlayer(playerid);
			case 4: ShowTopTenATForPlayer(playerid);
		}
	}

	return 1;
}

Dialog:RankingShow(playerid, response, listitem, inputtext[])
{
	if(!response) ShowRankingDialog(playerid);
	    
	return 1;
}

stock ShowTopTenATForPlayer(playerid)
{
	new MaxData[11];
	new MaxDataID[11];
	new bool:OnTheRank[MAX_PLAYERS];
	new DataSource[MAX_PLAYERS];
	new Ranking[570];

	foreach(new i : Player)
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i)) DataSource[i] = GetPlayerAliveTime(i); //FONTE DE DADOS DO RANKING
	}

	for(new i; i < 11; i++){MaxData[i] = -1;MaxDataID[i] = -1;} //Preparar variáveis

	foreach(new i : Player) // Posição 1º
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[1])
			{
				MaxData[1] = DataSource[i];
				MaxDataID[1] = i;
			}
		}
	}
	if(MaxDataID[1] != -1) OnTheRank[MaxDataID[1]] = true;

	foreach(new i : Player) // Posição 2º
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[2] && DataSource[i] <= MaxData[1] && MaxDataID[1] != i && OnTheRank[i] == false)
			{
				MaxData[2] = DataSource[i];
				MaxDataID[2] = i;
			}
		}
	}
	if(MaxDataID[2] != -1) OnTheRank[MaxDataID[2]] = true;

	foreach(new i : Player)
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[3] && DataSource[i] <= MaxData[2] && MaxDataID[2] != i && OnTheRank[i] == false)
			{
				MaxData[3] = DataSource[i];
				MaxDataID[3] = i;
			}
		}
	}
	if(MaxDataID[3] != -1) OnTheRank[MaxDataID[3]] = true;
	foreach(new i : Player) // Posição 4º
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[4] && DataSource[i] <= MaxData[3] && MaxDataID[3] != i && OnTheRank[i] == false)
			{
				MaxData[4] = DataSource[i];
				MaxDataID[4] = i;
			}
		}
	}
	if(MaxDataID[4] != -1) OnTheRank[MaxDataID[4]] = true;

	foreach(new i : Player) // Posição 5º
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[5] && DataSource[i] <= MaxData[4] && MaxDataID[4] != i && OnTheRank[i] == false)
			{
				MaxData[5] = DataSource[i];
				MaxDataID[5] = i;
			}
		}
	}
	if(MaxDataID[5] != -1) OnTheRank[MaxDataID[5]] = true;

	foreach(new i : Player) // Posição 6�
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[6] && DataSource[i] <= MaxData[5] && MaxDataID[5] != i && OnTheRank[i] == false)
			{
				MaxData[6] = DataSource[i];
				MaxDataID[6] = i;
			}
		}
	}
	if(MaxDataID[6] != -1) OnTheRank[MaxDataID[6]] = true;

	foreach(new i : Player) // Posição 7�
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[7] && DataSource[i] <= MaxData[6] && MaxDataID[6] != i && OnTheRank[i] == false)
			{
				MaxData[7] = DataSource[i];
				MaxDataID[7] = i;
			}
		}
	}
	if(MaxDataID[7] != -1) OnTheRank[MaxDataID[7]] = true;

	foreach(new i : Player) // Posição 8�
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[8] && DataSource[i] <= MaxData[7] && MaxDataID[7] != i && OnTheRank[i] == false)
			{
				MaxData[8] = DataSource[i];
				MaxDataID[8] = i;
			}
		}
	}
	if(MaxDataID[8] != -1) OnTheRank[MaxDataID[8]] = true;

	foreach(new i : Player) // Posição 9�
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[9] && DataSource[i] <= MaxData[8] && MaxDataID[8] != i && OnTheRank[i] == false)
			{
				MaxData[9] = DataSource[i];
				MaxDataID[9] = i;
			}
		}
	}
	if(MaxDataID[9] != -1) OnTheRank[MaxDataID[9]] = true;

	foreach(new i : Player) // Posição 10�
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[10] && DataSource[i] <= MaxData[9] && MaxDataID[9] != i && OnTheRank[i] == false)
			{
				MaxData[10] = DataSource[i];
				MaxDataID[10] = i;
			}
		}
	}
	if(MaxDataID[10] != -1) OnTheRank[MaxDataID[10]] = true;

	for(new i; i < 11; i++)
	{
		if(MaxDataID[i] != -1)
		{
			new Name[MAX_PLAYER_NAME];
			GetPlayerName(MaxDataID[i], Name, sizeof(Name));
			PlayerPlaySound(playerid, 1056, 0.0, 0.0, 0.0);
			format(Ranking, sizeof(Ranking), "%s\n%iº - %s(id:%i) - %i", Ranking,i,Name,MaxDataID[i],MaxData[i]);
		}
	}

	Dialog_Show(playerid, RankingShow, DIALOG_STYLE_LIST,"{B4E070}Ranking Tempo Vivo", Ranking, "Sair", "Voltar");

	return 1;
}

stock ShowTopTenScoreForPlayer(playerid)
{
	new MaxData[11];
	new MaxDataID[11];
	new bool:OnTheRank[MAX_PLAYERS];
	new DataSource[MAX_PLAYERS];
	new Ranking[570];

	foreach(new i : Player)
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i)) DataSource[i] = GetPlayerScore(i); //FONTE DE DADOS DO RANKING
	}

	for(new i; i < 11; i++){MaxData[i] = -1;MaxDataID[i] = -1;} //Preparar variáveis

	foreach(new i : Player) // Posição 1º
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[1])
			{
				MaxData[1] = DataSource[i];
				MaxDataID[1] = i;
			}
		}
	}
	if(MaxDataID[1] != -1) OnTheRank[MaxDataID[1]] = true;

	foreach(new i : Player) // Posição 2º
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[2] && DataSource[i] <= MaxData[1] && MaxDataID[1] != i && OnTheRank[i] == false)
			{
				MaxData[2] = DataSource[i];
				MaxDataID[2] = i;
			}
		}
	}
	if(MaxDataID[2] != -1) OnTheRank[MaxDataID[2]] = true;

	foreach(new i : Player) // Posição 3º
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[3] && DataSource[i] <= MaxData[2] && MaxDataID[2] != i && OnTheRank[i] == false)
			{
				MaxData[3] = DataSource[i];
				MaxDataID[3] = i;
			}
		}
	}
	if(MaxDataID[3] != -1) OnTheRank[MaxDataID[3]] = true;

	foreach(new i : Player) // Posição 4º
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[4] && DataSource[i] <= MaxData[3] && MaxDataID[3] != i && OnTheRank[i] == false)
			{
				MaxData[4] = DataSource[i];
				MaxDataID[4] = i;
			}
		}
	}
	if(MaxDataID[4] != -1) OnTheRank[MaxDataID[4]] = true;

	foreach(new i : Player) // Posição 5º
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[5] && DataSource[i] <= MaxData[4] && MaxDataID[4] != i && OnTheRank[i] == false)
			{
				MaxData[5] = DataSource[i];
				MaxDataID[5] = i;
			}
		}
	}
	if(MaxDataID[5] != -1) OnTheRank[MaxDataID[5]] = true;
	foreach(new i : Player) // Posição 6�
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[6] && DataSource[i] <= MaxData[5] && MaxDataID[5] != i && OnTheRank[i] == false)
			{
				MaxData[6] = DataSource[i];
				MaxDataID[6] = i;
			}
		}
	}
	if(MaxDataID[6] != -1) OnTheRank[MaxDataID[6]] = true;
	foreach(new i : Player) // Posição 7�
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[7] && DataSource[i] <= MaxData[6] && MaxDataID[6] != i && OnTheRank[i] == false)
			{
				MaxData[7] = DataSource[i];
				MaxDataID[7] = i;
			}
		}
	}
	if(MaxDataID[7] != -1) OnTheRank[MaxDataID[7]] = true;

	foreach(new i : Player) // Posição 8�
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[8] && DataSource[i] <= MaxData[7] && MaxDataID[7] != i && OnTheRank[i] == false)
			{
				MaxData[8] = DataSource[i];
				MaxDataID[8] = i;
			}
		}
	}
	if(MaxDataID[8] != -1) OnTheRank[MaxDataID[8]] = true;

	foreach(new i : Player) // Posição 9�
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[9] && DataSource[i] <= MaxData[8] && MaxDataID[8] != i && OnTheRank[i] == false)
			{
				MaxData[9] = DataSource[i];
				MaxDataID[9] = i;
			}
		}
	}
	if(MaxDataID[9] != -1) OnTheRank[MaxDataID[9]] = true;

	foreach(new i : Player) // Posição 10�
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[10] && DataSource[i] <= MaxData[9] && MaxDataID[9] != i && OnTheRank[i] == false)
			{
				MaxData[10] = DataSource[i];
				MaxDataID[10] = i;
			}
		}
	}
	if(MaxDataID[10] != -1) OnTheRank[MaxDataID[10]] = true;

	for(new i; i < 11; i++)
	{
		if(MaxDataID[i] != -1)
		{
			new cor[9];

			PlayerPlaySound(playerid, 1056, 0.0, 0.0, 0.0);

			switch(i)
			{
				case 1: cor  = "{FFFFFF}";
				case 2: cor  = "{DEDEDE}";
				case 3: cor  = "{C2C2C2}";
				case 4: cor  = "{B3B3B3}";
				case 5: cor  = "{A3A3A3}";
				case 6: cor  = "{909191}";
				case 7: cor  = "{6F7273}";
				case 8: cor  = "{545454}";
				case 9: cor  = "{303436}";
				case 10: cor = "{000000}";
			}

			format(Ranking, sizeof(Ranking), "%s\n%s%iº - %s(id:%i) - %i", Ranking, cor, i, GetPlayerNameEx(playerid), MaxDataID[i], MaxData[i]);
		}
	}

	Dialog_Show(playerid, RankingShow, DIALOG_STYLE_LIST,"{B4E070}Ranking de Score", Ranking, "Sair", "Voltar");
	return 1;
}

stock ShowTopTenSpreeForPlayer(playerid)
{
	new MaxData[11];
	new MaxDataID[11];
	new bool:OnTheRank[MAX_PLAYERS];
	new DataSource[MAX_PLAYERS];
	new Ranking[570];

	foreach(new i : Player)
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i)) DataSource[i] = GetPlayerSpree(i); //FONTE DE DADOS DO RANKING
	}

	for(new i; i < 11; i++){MaxData[i] = -1;MaxDataID[i] = -1;} //Preparar variáveis

	foreach(new i : Player) // Posição 1º
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[1])
			{
				MaxData[1] = DataSource[i];
				MaxDataID[1] = i;
			}
		}
	}
	if(MaxDataID[1] != -1) OnTheRank[MaxDataID[1]] = true;

	foreach(new i : Player) // Posição 2º
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[2] && DataSource[i] <= MaxData[1] && MaxDataID[1] != i && OnTheRank[i] == false)
			{
				MaxData[2] = DataSource[i];
				MaxDataID[2] = i;
			}
		}
	}
	if(MaxDataID[2] != -1) OnTheRank[MaxDataID[2]] = true;

	foreach(new i : Player)
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[3] && DataSource[i] <= MaxData[2] && MaxDataID[2] != i && OnTheRank[i] == false)
			{
				MaxData[3] = DataSource[i];
				MaxDataID[3] = i;
			}
		}
	}
	if(MaxDataID[3] != -1) OnTheRank[MaxDataID[3]] = true;
	foreach(new i : Player) // Posição 4º
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[4] && DataSource[i] <= MaxData[3] && MaxDataID[3] != i && OnTheRank[i] == false)
			{
				MaxData[4] = DataSource[i];
				MaxDataID[4] = i;
			}
		}
	}
	if(MaxDataID[4] != -1) OnTheRank[MaxDataID[4]] = true;

	foreach(new i : Player) // Posição 5º
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[5] && DataSource[i] <= MaxData[4] && MaxDataID[4] != i && OnTheRank[i] == false)
			{
				MaxData[5] = DataSource[i];
				MaxDataID[5] = i;
			}
		}
	}
	if(MaxDataID[5] != -1) OnTheRank[MaxDataID[5]] = true;

	foreach(new i : Player) // Posição 6�
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[6] && DataSource[i] <= MaxData[5] && MaxDataID[5] != i && OnTheRank[i] == false)
			{
				MaxData[6] = DataSource[i];
				MaxDataID[6] = i;
			}
		}
	}
	if(MaxDataID[6] != -1) OnTheRank[MaxDataID[6]] = true;

	foreach(new i : Player) // Posição 7�
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[7] && DataSource[i] <= MaxData[6] && MaxDataID[6] != i && OnTheRank[i] == false)
			{
				MaxData[7] = DataSource[i];
				MaxDataID[7] = i;
			}
		}
	}
	if(MaxDataID[7] != -1) OnTheRank[MaxDataID[7]] = true;

	foreach(new i : Player) // Posição 8�
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[8] && DataSource[i] <= MaxData[7] && MaxDataID[7] != i && OnTheRank[i] == false)
			{
				MaxData[8] = DataSource[i];
				MaxDataID[8] = i;
			}
		}
	}
	if(MaxDataID[8] != -1) OnTheRank[MaxDataID[8]] = true;

	foreach(new i : Player) // Posição 9�
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[9] && DataSource[i] <= MaxData[8] && MaxDataID[8] != i && OnTheRank[i] == false)
			{
				MaxData[9] = DataSource[i];
				MaxDataID[9] = i;
			}
		}
	}
	if(MaxDataID[9] != -1) OnTheRank[MaxDataID[9]] = true;

	foreach(new i : Player) // Posição 10�
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[10] && DataSource[i] <= MaxData[9] && MaxDataID[9] != i && OnTheRank[i] == false)
			{
				MaxData[10] = DataSource[i];
				MaxDataID[10] = i;
			}
		}
	}
	if(MaxDataID[10] != -1) OnTheRank[MaxDataID[10]] = true;

	for(new i; i < 11; i++)
	{
		if(MaxDataID[i] != -1)
		{
			new Name[MAX_PLAYER_NAME];
			GetPlayerName(MaxDataID[i], Name, sizeof(Name));
			PlayerPlaySound(playerid, 1056, 0.0, 0.0, 0.0);
			format(Ranking, sizeof(Ranking), "%s\n%iº - %s(id:%i) - %i", Ranking,i,Name,MaxDataID[i],MaxData[i]);
		}
	}

	//format(DialogString, sizeof(DialogString), "%s\n\n{FFFF00}Esta lista exibe somente quem est� online\nKills Spree � quantos voc� matou sem morrer.",Ranking);
	Dialog_Show(playerid, RankingShow, DIALOG_STYLE_LIST, "{B4E070}Ranking de Kills Spree", Ranking, "Sair", "Voltar");
	return 1;
}

stock ShowTopTenMortesForPlayer(playerid)
{
	new MaxData[11];
	new MaxDataID[11];
	new bool:OnTheRank[MAX_PLAYERS];
	new DataSource[MAX_PLAYERS];
	new Ranking[570];

	foreach(new i : Player)
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i)) DataSource[i] = GetPlayerDeathCount(i); //FONTE DE DADOS DO RANKING
	}

	for(new i; i < 11; i++){MaxData[i] = -1;MaxDataID[i] = -1;} //Preparar variáveis

	foreach(new i : Player) // Posição 1º
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[1])
			{
				MaxData[1] = DataSource[i];
				MaxDataID[1] = i;
			}
		}
	}
	if(MaxDataID[1] != -1) OnTheRank[MaxDataID[1]] = true;

	foreach(new i : Player) // Posição 2º
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[2] && DataSource[i] <= MaxData[1] && MaxDataID[1] != i && OnTheRank[i] == false)
			{
				MaxData[2] = DataSource[i];
				MaxDataID[2] = i;
			}
		}
	}
	if(MaxDataID[2] != -1) OnTheRank[MaxDataID[2]] = true;

	foreach(new i : Player) // Posição 3º
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[3] && DataSource[i] <= MaxData[2] && MaxDataID[2] != i && OnTheRank[i] == false)
			{
				MaxData[3] = DataSource[i];
				MaxDataID[3] = i;
			}
		}
	}
	if(MaxDataID[3] != -1) OnTheRank[MaxDataID[3]] = true;

	foreach(new i : Player) // Posição 4º
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[4] && DataSource[i] <= MaxData[3] && MaxDataID[3] != i && OnTheRank[i] == false)
			{
				MaxData[4] = DataSource[i];
				MaxDataID[4] = i;
			}
		}
	}
	if(MaxDataID[4] != -1) OnTheRank[MaxDataID[4]] = true;

	foreach(new i : Player) // Posição 5º
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[5] && DataSource[i] <= MaxData[4] && MaxDataID[4] != i && OnTheRank[i] == false)
			{
				MaxData[5] = DataSource[i];
				MaxDataID[5] = i;
			}
		}
	}
	if(MaxDataID[5] != -1) OnTheRank[MaxDataID[5]] = true;

	foreach(new i : Player) // Posição 6�
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[6] && DataSource[i] <= MaxData[5] && MaxDataID[5] != i && OnTheRank[i] == false)
			{
				MaxData[6] = DataSource[i];
				MaxDataID[6] = i;
			}
		}
	}
	if(MaxDataID[6] != -1) OnTheRank[MaxDataID[6]] = true;

	foreach(new i : Player) // Posição 7�
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[7] && DataSource[i] <= MaxData[6] && MaxDataID[6] != i && OnTheRank[i] == false)
			{
				MaxData[7] = DataSource[i];
				MaxDataID[7] = i;
			}
		}
	}
	if(MaxDataID[7] != -1) OnTheRank[MaxDataID[7]] = true;

	foreach(new i : Player) // Posição 8�
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[8] && DataSource[i] <= MaxData[7] && MaxDataID[7] != i && OnTheRank[i] == false)
			{
				MaxData[8] = DataSource[i];
				MaxDataID[8] = i;
			}
		}
	}
	if(MaxDataID[8] != -1) OnTheRank[MaxDataID[8]] = true;

	foreach(new i : Player) // Posição 9�
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[9] && DataSource[i] <= MaxData[8] && MaxDataID[8] != i && OnTheRank[i] == false)
			{
				MaxData[9] = DataSource[i];
				MaxDataID[9] = i;
			}
		}
	}
	if(MaxDataID[9] != -1) OnTheRank[MaxDataID[9]] = true;

	foreach(new i : Player) // Posição 10�
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[10] && DataSource[i] <= MaxData[9] && MaxDataID[9] != i && OnTheRank[i] == false)
			{
				MaxData[10] = DataSource[i];
				MaxDataID[10] = i;
			}
		}
	}
	if(MaxDataID[10] != -1) OnTheRank[MaxDataID[10]] = true;

	for(new i; i < 11; i++)
	{
		if(MaxDataID[i] != -1)
		{
			new Name[MAX_PLAYER_NAME];
			GetPlayerName(MaxDataID[i], Name, sizeof(Name));
			PlayerPlaySound(playerid, 1056, 0.0, 0.0, 0.0);
			format(Ranking, sizeof(Ranking), "%s\n%iº - %s(id:%i) - %i", Ranking,i,Name,MaxDataID[i],MaxData[i]);
		}
	}

	Dialog_Show(playerid, RankingShow, DIALOG_STYLE_LIST,"{B4E070}Ranking mortes",Ranking,"Sair","Voltar");

	return 1;
}

stock ShowTopTenPingForPlayer(playerid)
{
	new MaxData[11];
	new MaxDataID[11];
	new bool:OnTheRank[MAX_PLAYERS];
	new DataSource[MAX_PLAYERS];
	new Ranking[570];

	foreach(new i : Player)
		if(IsPlayerConnected(i) && !IsPlayerNPC(i)) DataSource[i] = GetPlayerPing(i); //FONTE DE DADOS DO RANKING

	for(new i; i < 11; i++){MaxData[i] = -1;MaxDataID[i] = -1;} //Preparar variáveis

	foreach(new i : Player) // Posição 1º
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[1])
			{
				MaxData[1] = DataSource[i];
				MaxDataID[1] = i;
			}
		}
	}

	if(MaxDataID[1] != -1) OnTheRank[MaxDataID[1]] = true;

	foreach(new i : Player) // Posição 2º
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[2] && DataSource[i] <= MaxData[1] && MaxDataID[1] != i && OnTheRank[i] == false)
			{
				MaxData[2] = DataSource[i];
				MaxDataID[2] = i;
			}
		}
	}
	if(MaxDataID[2] != -1) OnTheRank[MaxDataID[2]] = true;

	foreach(new i : Player) // Posição 3º
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[3] && DataSource[i] <= MaxData[2] && MaxDataID[2] != i && OnTheRank[i] == false)
			{
				MaxData[3] = DataSource[i];
				MaxDataID[3] = i;
			}
		}
	}
	if(MaxDataID[3] != -1) OnTheRank[MaxDataID[3]] = true;

	foreach(new i : Player) // Posição 4º
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[4] && DataSource[i] <= MaxData[3] && MaxDataID[3] != i && OnTheRank[i] == false)
			{
				MaxData[4] = DataSource[i];
				MaxDataID[4] = i;
			}
		}
	}
	if(MaxDataID[4] != -1) OnTheRank[MaxDataID[4]] = true;

	foreach(new i : Player) // Posição 5º
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[5] && DataSource[i] <= MaxData[4] && MaxDataID[4] != i && OnTheRank[i] == false)
			{
				MaxData[5] = DataSource[i];
				MaxDataID[5] = i;
			}
		}
	}
	if(MaxDataID[5] != -1) OnTheRank[MaxDataID[5]] = true;

	foreach(new i : Player) // Posição 6�
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[6] && DataSource[i] <= MaxData[5] && MaxDataID[5] != i && OnTheRank[i] == false)
			{
				MaxData[6] = DataSource[i];
				MaxDataID[6] = i;
			}
		}
	}
	if(MaxDataID[6] != -1) OnTheRank[MaxDataID[6]] = true;

	foreach(new i : Player) // Posição 7�
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[7] && DataSource[i] <= MaxData[6] && MaxDataID[6] != i && OnTheRank[i] == false)
			{
				MaxData[7] = DataSource[i];
				MaxDataID[7] = i;
			}
		}
	}
	if(MaxDataID[7] != -1) OnTheRank[MaxDataID[7]] = true;

	foreach(new i : Player) // Posição 8�
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[8] && DataSource[i] <= MaxData[7] && MaxDataID[7] != i && OnTheRank[i] == false)
			{
				MaxData[8] = DataSource[i];
				MaxDataID[8] = i;
			}
		}
	}
	if(MaxDataID[8] != -1) OnTheRank[MaxDataID[8]] = true;

	foreach(new i : Player) // Posição 9�
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[9] && DataSource[i] <= MaxData[8] && MaxDataID[8] != i && OnTheRank[i] == false)
			{
				MaxData[9] = DataSource[i];
				MaxDataID[9] = i;
			}
		}
	}
	if(MaxDataID[9] != -1) OnTheRank[MaxDataID[9]] = true;

	foreach(new i : Player) // Posição 10�
	{
		if(IsPlayerConnected(i) && !IsPlayerNPC(i))
		{
			if(DataSource[i] > MaxData[10] && DataSource[i] <= MaxData[9] && MaxDataID[9] != i && OnTheRank[i] == false)
			{
				MaxData[10] = DataSource[i];
				MaxDataID[10] = i;
			}
		}
	}
	if(MaxDataID[10] != -1) OnTheRank[MaxDataID[10]] = true;

	for(new i; i < 11; i++)
	{
		if(MaxDataID[i] != -1)
		{
			new Name[MAX_PLAYER_NAME];
			GetPlayerName(MaxDataID[i], Name, sizeof(Name));
			PlayerPlaySound(playerid, 1056, 0.0, 0.0, 0.0);
			format(Ranking, sizeof(Ranking), "%s\n%iº - %s(id:%i) - %i", Ranking,i,Name,MaxDataID[i],MaxData[i]);
		}
	}

	Dialog_Show(playerid, RankingShow, DIALOG_STYLE_LIST,"{B4E070}Ranking Ping",Ranking,"Sair","Voltar");
	return 1;
}

task ShowRandomRank[60000 * 6]()
{
	new id, id2, id3, id4, id5;
	new MaxScore = -1, MaxMortes = -1, MaxSpree = -1, MaxPing = -1, MaxHS = -1;

	foreach(new i : Player)
	{
		if(IsPlayerConnected(i) && !IsPlayerInTutorial(i))
		{
			if(GetPlayerScore(i) > MaxScore)
			{
				MaxScore = GetPlayerScore(i);
				id = i;
			}
			if(GetPlayerDeathCount(i) > MaxMortes)
			{
				MaxMortes = GetPlayerDeathCount(i);
				id2 = i;
			}
			if(GetPlayerSpree(i) > MaxSpree)
			{
				MaxSpree = GetPlayerSpree(i);
				id3 = i;
			}
			if(GetPlayerPing(i) > MaxPing)
			{
				MaxPing = GetPlayerPing(i);
				id4 = i;
			}
			if(GetPlayerAliveTime(i) > MaxHS)
			{
				MaxHS = GetPlayerAliveTime(i);
				id5 = i;
			}
	  	}

	}

	switch (random(6))
	{
		case 0: ChatMsgAll(0x35B330ff, "[Rank]: {B4E070} %p Tem o maior número de Score. Com{35B330} %d {B4E070}Assassinatos.", id, MaxScore);
		case 1: ChatMsgAll(0x35B330ff, "[Rank]: {B4E070} %p Tem o maior número de Mortes. Com{35B330} %d {B4E070}Mortes.", id2, MaxMortes);
		case 2: ChatMsgAll(0x35B330ff, "[Rank]: {B4E070} %p Tem o melhor Killing Spree do server com{35B330} %d {B4E070}Spree!", id3, MaxSpree);
		case 3: ChatMsgAll(0x35B330ff, "[Rank]: {B4E070} %p É o mais lagado online, com{35B330} %d {B4E070}de Ping!", id4, MaxPing);
		default: ChatMsgAll(0x35B330ff, "[Rank]: {B4E070} %p Tem o maior tempo vivo, {35B330}%d minutos{B4E070} Vivo!", id5, (MaxHS / 60));
	}
}
