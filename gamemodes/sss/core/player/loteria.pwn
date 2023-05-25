static
	LoteriaNumero = -1,
	Timer:AnuncioLot,
	AnuncioCount;

task Loteria[MIN(60)]() { 
    LoteriaNumero = random(100);
	ChatMsgAll(0x0cfcecFF, "[Loteria]: Acerte o número de 0 a 100 e ganhe um item aleatório ou score.");
    ChatMsgAll(0x0cfcecFF, "[Loteria]: Para apostar digite: {FFFFFF}/loteria [número]");
    stop AnuncioLot;
	AnuncioLot = defer AnunciarLoteria();
}

timer AnunciarLoteria[MIN(1)](){
	if(LoteriaNumero == -1)
	    return;

	if(AnuncioCount == 5){
	    ChatMsgAll(0x0cfcecFF, "[Loteria]: Loteria encerrada por ninguém acertar. O número era {FFFFFF}%d", LoteriaNumero);
	    LoteriaNumero = -1;
	    stop AnuncioLot;
	    return;
	}
	
    ChatMsgAll(0x0cfcecFF, "[Loteria]: Acerte o número de 0 a 100 e ganhe um item aleatório ou score.");
    ChatMsgAll(0x0cfcecFF, "[Loteria]: Para apostar digite: {FFFFFF}/loteria [número]");
    stop AnuncioLot;
	AnuncioLot = defer AnunciarLoteria();
	AnuncioCount ++;
}

CMD:loteria(playerid, params[]){
	if(!IsPlayerSpawned(playerid))
	    return ChatMsg(playerid, 0x0cfcecFF, "[Loteria]: Voc� deve nascer para usar esse comando.");

    if(LoteriaNumero == -1)
		return ChatMsg(playerid, 0x0cfcecFF, "[Loteria]: Loteria não está liberada no momento.");

    if(strval(params[0]) > 100 || strval(params[0]) < 0)
		return ChatMsg(playerid, 0x0cfcecFF, "[Loteria]: O número deve ser entre 0 e 100.");

	if(strval(params[0]) == LoteriaNumero){
	    ChatMsgAll(0x0cfcecFF, "[Loteria]: {FFFFFF}%p{0cfcec} Acertou, parabéns! O número era {FFFFFF}%d", playerid, LoteriaNumero);
	    LoteriaNumero = -1;
	    stop AnuncioLot;
	    
		new
			premio = random(6),
			Float:x,
			Float:y,
			Float:z,
			itemid;
			
		GetPlayerPos(playerid, x, y, z);
		if(premio == 0){
		    itemid = CreateItem(item_LocksmithKit, x, y, z);
		    ChatMsg(playerid, 0x0cfcecFF, " > Parabéns, Voc� ganhou o item {FFFFFF}Kit Chaveiro{0cfcec}.");
		}
		else if(premio == 1){
		    itemid = CreateItem(item_AK47Rifle, x, y, z);
		    SetItemExtraData(itemid, 0);
		    ChatMsg(playerid, 0x0cfcecFF, " > Parabéns, Voc� ganhou o item {FFFFFF}AK-47{0cfcec}.");
		}
		else if(premio == 2){
		    itemid = CreateItem(item_Rucksack, x, y, z);
		    ChatMsg(playerid, 0x0cfcecFF, " > Parabéns, Voc� ganhou o item {FFFFFF}Mochila de Acampamento{0cfcec}.");
		}
		else if(premio == 3){
		    itemid = CreateItem(item_Medkit, x, y, z);
		    ChatMsg(playerid, 0x0cfcecFF, " > Parabéns, Voc� ganhou o item {FFFFFF}Med Kit{0cfcec}.");
		}
		else if(premio == 4){
		    itemid = CreateItem(item_M16Rifle, x, y, z);
		    SetItemExtraData(itemid, 0);
		    ChatMsg(playerid, 0x0cfcecFF, " > Parabéns, Voc� ganhou o item {FFFFFF}M16{0cfcec}.");
		}
		else if(premio == 5){
		    itemid = CreateItem(item_Spas12, x, y, z);
		    SetItemExtraData(itemid, 0);
		    ChatMsg(playerid, 0x0cfcecFF, " > Parabéns, Voc� ganhou o item {FFFFFF}Spas 12{0cfcec}.");
		}
		else if(premio == 6){
		    itemid = CreateItem(item_XmasHat, x, y, z);
		    ChatMsg(playerid, 0x0cfcecFF, " > Parabéns, Voc� ganhou o item {FFFFFF}Gorro{0cfcec}.");
		}
		else {
		    itemid = CreateItem(item_Sledgehammer, x, y, z);
		    ChatMsg(playerid, 0x0cfcecFF, " > Parabéns, Voc� ganhou o item {FFFFFF}Marreta{0cfcec}.");
		}
	}
	else ChatMsg(playerid, 0x0cfcecFF, "[Loteria]: Voc� errou :( ... Tente novamente!");
	return 1;
}
