#include <YSI\y_hooks>

#define DialogComerciante  (850)
#define DialogCompra       (851)
#define DialogVenda        (852)

new pickuptrade, actor, Text3D:labelcow, Text3D:labelseller;
new comerciantetick[MAX_PLAYERS];
new bool:dialogOpen[MAX_PLAYERS];

/*======================================================================

                            FUN��ES/STOCKS

=======================================================================*/ 

hook OnPlayerPickUpPickup(playerid, pickupid)
{
	if(pickupid == pickuptrade && !dialogOpen[playerid])
	{
		new str[100];
		format(str, sizeof str, "Comprar Itens\nVender Itens\n"C_YELLOW"> Coins: %d", GetPlayerCoins(playerid));

		ShowPlayerDialog(playerid, DialogComerciante, DIALOG_STYLE_LIST, "Comerciante:", str, ""C_GREEN">", ""C_RED"X");

		dialogOpen[playerid] = true;
	}
	return 1;
}

hook OnDialogResponse(playerid, dialogid, response, listitem)
{
    if(dialogid == DialogComerciante)
	{
		if(response)
		{
			if(!response) return 0;
			switch(listitem)
			{
				case 0:
				{
                    ShowPlayerDialog(playerid, DialogCompra, DIALOG_STYLE_TABLIST_HEADERS, "Compra de Itens:", "Itens\tPre�o\tQuantidade\n\
                    Camuflagem\t30 Coins\t1\n\
                    Sinalizador\t25 Coins\t1\n\
					EMP de Proximidade\t25 Coins\t1\n\
                    Teclado Avan�ado\t20 Coins\t1\n\
                    Lockpick\t20 Coins\t1\n\
                    Molotov\t15 Coins\t1\n\
                    Faca de Combate\t10 Coins\t1\n\
                    Mapa\t10 Coins\t1", ""C_GREEN">", ""C_RED"X");
				}
				case 1:
				{
                    ShowPlayerDialog(playerid, DialogVenda, DIALOG_STYLE_TABLIST_HEADERS, "Venda de Itens:", "Item\tPre�o\n\
                    Corpo\t1 Coin\n\
                    Peda�o de Metal\t1 Coin", ""C_GREEN">", ""C_RED"X");
				}
				case 2: 
				{
					ChatMsg(playerid, GREEN, " >  Voc� possui {FFFFFF}%d {33AA33}coins.", GetPlayerCoins(playerid));

					dialogOpen[playerid] = false;
				}
		   }
	    } else {
			dialogOpen[playerid] = false;
	    }
   	}

	/* ----------------------------------------------------------------------------------------------------------------------------------------------------- */

	if(dialogid == DialogCompra)
	{
	    if(response)
		{
			if(!response) return 0;
			switch(listitem)
			{
				case 0:
				{
					if(GetPlayerCoins(playerid) < 30) {
						dialogOpen[playerid] = false;
						return SendClientMessage(playerid, RED, " > Voc� n�o tem coins o suficiente."); 
					}   
					dialogOpen[playerid] = false;    
					SendClientMessage(playerid, RED, " > Item desativado temporariamente."); 
					//BuyItem(playerid, 0, 30);
				}
				case 1:
				{
					if(GetPlayerCoins(playerid) < 25) {
						dialogOpen[playerid] = false;
						return SendClientMessage(playerid, RED, " > Voc� n�o tem coins suficiente.");
					}		
					BuyItem(playerid, 1, 25);
				}
				case 2:
				{
					if(GetPlayerCoins(playerid) < 25) {
						dialogOpen[playerid] = false;
						return SendClientMessage(playerid, RED, " > Voc� n�o tem coins suficiente.");
					}
					BuyItem(playerid, 2, 25);
				}
				case 3:
				{
					if(GetPlayerCoins(playerid) < 20) {
						dialogOpen[playerid] = false;
						return SendClientMessage(playerid, RED, " > Voc� n�o tem coins suficiente.");
					}
					BuyItem(playerid, 3, 20);
				}
				case 4:
				{
					if(GetPlayerCoins(playerid) < 20) {
						dialogOpen[playerid] = false;
						return SendClientMessage(playerid, RED, " > Voc� n�o tem coins suficiente.");
					}
					BuyItem(playerid, 4, 20);
				}
				case 5:
				{
					if(GetPlayerCoins(playerid) < 15) {
						dialogOpen[playerid] = false;
						return SendClientMessage(playerid, RED, " > Voc� n�o tem coins suficiente.");
					}
					BuyItem(playerid, 5, 15);
				}
				case 6:
				{
					if(GetPlayerCoins(playerid) < 10) {
						dialogOpen[playerid] = false;
						return SendClientMessage(playerid, RED, " > Voc� n�o tem coins suficiente.");
					}
					BuyItem(playerid, 6, 10);
				}
				case 7:
				{
					if(GetPlayerCoins(playerid) < 10) {
						dialogOpen[playerid] = false;
						return SendClientMessage(playerid, RED, " > Voc� n�o tem coins suficiente.");
					}
					BuyItem(playerid, 7, 10);
				}
			}
		} else {
			dialogOpen[playerid] = false;
		}
	}

	/* ----------------------------------------------------------------------------------------------------------------------------------------------------- */
	new
		itemid,
		ItemType:itemtype;

	itemid = GetPlayerItem(playerid);
	itemtype = GetItemType(itemid);

	if(dialogid == DialogVenda)
	{
		if(response)
		{
			if(!response) return 0;
			switch(listitem)
			{
				case 0:
				{
					if(itemtype == item_Torso)
					{
						SellItem(playerid, itemid, 1);
					}else{
						ChatMsg(playerid, RED, " > Voc� n�o tem o item selecionado em m�os para vender.");
						dialogOpen[playerid] = false;
					}
				}
				case 1:
				{
					if(itemtype == item_MetalFrame)
					{	
	                     SellItem(playerid, itemid, 1);
					}else{
                        ChatMsg(playerid, RED, " > Voc� n�o tem o item selecionado em m�os para vender.");
						dialogOpen[playerid] = false;
					}
				}
			}
		 } else {
			dialogOpen[playerid] = false;
		 }
	  }

	/* ----------------------------------------------------------------------------------------------------------------------------------------------------- */

	return 1;
}

/* =====================================================================

                            FUN��ES/STOCKS

===================================================================== =*/ 

hook OnGameModeInit(){
    CreateSeller1();
	return 1;
}

hook OnGameModeExit(){
    DestroySeller();
    return 1;
}

stock CreateSeller1(){
    pickuptrade = CreatePickup(1274, 1, 1992.2799, -2152.3064, 13.5469);
	actor = CreateActor(293, 1995.0674, -2152.3403, 13.5469, 89.4920);
	labelcow = Create3DTextLabel("MrToddy", PINK, 2013.364624, -2130.511718, 14.347700 + 1.5, 5.0, 0, 1);

	labelseller = Create3DTextLabel("Kolor4dO (Comerciante)", YELLOW, 1995.0674, -2152.3403, 13.5469 + 1.2, 5.0, 0, 1);
	ApplyActorAnimation(actor, "DEALER", "DEALER_IDLE", 4.1, 1, 0, 0, 0, 0);

	return 1;
}

stock DestroySeller(){
    DestroyPickup(pickuptrade);
	DestroyActor(actor);
 	Delete3DTextLabel(labelcow);
	Delete3DTextLabel(labelseller);
 	return 1;
}

stock BuyItem(playerid, item, value){
	if(GetTickCountDifference(GetTickCount(), comerciantetick[playerid]) < 1000)
	{
		ChatMsg(playerid, YELLOW, " >  Aguarde no m�nimo 1 segundo para interagir com o comerciante novamente.");
		return 1;
	}

    new Float:x, Float:y, Float:z;

	x = 1993.8102;
	y = -2152.3206;
	z = 14.5271;

	switch(item){
		//case 0: CreateItem(item_Camouflage, x, y, z - FLOOR_OFFSET);
		case 1: CreateItem(item_SupplyDrop, x, y, z - FLOOR_OFFSET);
		case 2: CreateItem(item_EmpProxMine, x, y, z - FLOOR_OFFSET);
		case 3: CreateItem(item_AdvancedKeypad, x, y, z - FLOOR_OFFSET);
		case 4: CreateItem(item_LockBreaker, x, y, z - FLOOR_OFFSET);
		case 5: CreateItem(item_Molotov, x, y, z - FLOOR_OFFSET);
		case 6: CreateItem(item_Knife, x, y, z - FLOOR_OFFSET);
		case 7: CreateItem(item_Map, x, y, z - FLOOR_OFFSET);
	}
    RemovePlayerCoins(playerid, value);
	PlayerPlaySound(playerid, 1052, 0.0, 0.0, 0.0);

	ChatMsg(playerid, GREEN, " >  Voc� comprou um item com sucesso.");
	ChatMsg(playerid, GREEN, " >  Agora voc� possui {FFFFFF}%d {33AA33}coins.", GetPlayerCoins(playerid));

	dialogOpen[playerid] = false;
	comerciantetick[playerid] = GetTickCount();

	return 1;
}

stock SellItem(playerid, itemid, value){
	if(GetTickCountDifference(GetTickCount(), comerciantetick[playerid]) < 1000)
	{
		ChatMsg(playerid, YELLOW, " >  Aguarde no m�nimo 1 segundo para interagir com o comerciante novamente.");
		return 1;
	}

    DestroyItem(itemid);
    AddPlayerCoins(playerid, value);
	PlayerPlaySound(playerid, 1058, 0.0, 0.0, 0.0);

	ChatMsg(playerid, GREEN, " >  Voc� vendeu um item com sucesso.");
	ChatMsg(playerid, GREEN, " >  Agora voc� possui {FFFFFF}%d {33AA33}coins.", GetPlayerCoins(playerid));

	dialogOpen[playerid] = false;
	comerciantetick[playerid] = GetTickCount();

	return 1;
}
