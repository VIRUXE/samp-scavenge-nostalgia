#include <YSI\y_hooks>

#define MAX_BASKET_ITEMS 32

static enum E_BASKET {
    ItemType:type,
    quantity
}

static enum E_PRICING {
    name[ITM_MAX_NAME],
    price
}

// Database Statements
static
DBStatement:stmt_AddItemOrder,
DBStatement:stmt_RedeemOrderItem,
DBStatement:stmt_GetRedeemableOrderItem,
DBStatement:stmt_GetRedeemableOrderItems;

static Basket[MAX_PLAYERS][32][E_BASKET], Iterator:BasketIndex<MAX_BASKET_ITEMS>;

static ItemType:SelectedItem[MAX_PLAYERS];

static ItemPricing[][E_PRICING] = {
	// Explosivos
	{"Dynamite", 120},
	{"TntPhoneBomb", 120},
	{"TntProxMine", 120},
	{"TntTimebomb", 120},
	{"TntTripMine", 120},
	{"IedBomb", 100},
	{"IedPhoneBomb", 110},
	{"IedProxMine", 120},
	{"IedTimebomb", 120},
	{"IedTripMine", 120},
	{"FireworkBox", 80},
	{"EmpPhoneBomb", 100},
	{"EmpProxMine", 100},
	{"EmpTimebomb", 100},
	{"EmpTripMine", 100},
	{"Explosive", 100},
	{"MobilePhone", 20},

	// Médico
	{"Medkit", 60},
	{"Bandage", 40},
	{"AntiSepBandage", 50},
	{"DoctorBag", 70},
	
	// Ferramentas
	{"Spanner", 10},
	{"Wrench", 5},
	{"Screwdriver", 10},
	{"Hammer", 10},
	{"Crowbar", 15},

	{"Map", 50},
	{"MediumBag", 80},
	{"LargeBackpack", 100},
	{"MediumBox", 70},
	{"LargeBox", 100},
	{"Wheel", 10},
	{"Key", 100},
	{"LocksmithKit", 150},
	{"Keypad", 150},
	{"AdvancedKeypad", 9999},

	// Defesas
	{"InsulDoor", 50},
	{"ShipDoor", 50},
	{"TallFrame", 50},
	{"MetalFrame", 50},
	{"MetalGate1", 50},
	{"MetalGate2", 50},
	{"MetPanel", 50},
	{"WoodPanel", 50},
    {"CorPanel", 50},
    {"DupleDoor", 50},
    {"InsulPanel", 50},
    {"MetalBlin", 50},
    {"MetalStand", 50},
	{"GarageDoor", 50},
	{"DoorBlin", 50},
    {"PortaCofre", 50},

	// Armas
	{"M9Pistol", 250},
	{"M9PistolSD", 250},
	{"DesertEagle", 1337},
	{"M16Rifle", 250},
	{"M77RMRifle", 250},
	{"Mac10", 250},
	{"MP5", 250},
	{"PumpShotgun", 250},
	{"SemiAutoRifle", 250},
	{"Sawnoff", 250},
	{"Spas12", 250},
	{"Tec9", 250},
	{"WASR3Rifle", 250},
	{"SniperRifle", 400},
	{"Model70Rifle", 250},
	{"Molotov", 5},
	{"AK47Rifle", 250},
	{"Armour", 100},
	{"Flamer", 250},
	{"LenKnocksRifle", 250},

	{"Backpack", 40},
	{"Barbecue", 100},
	{"Battery", 10},
	{"Bed", 9999},
	{"Campfire", 10},
	// {"DataInterface", 1337},
	// {"Detonator", 1337},
	{"FireLighter", 5},
	// {"Fluctuator", 1337},
	{"Fusebox", 5},
	{"GasCan", 10},
	{"GasMask", 20},
	{"GeigerCounter", 120},
	{"HackDevice", 500},
	{"HardDrive", 20},
	{"Headlight", 20},
	{"Heatseeker", 9999},
	{"Holdall", 20},
	{"IoUnit", 50},

	// {"Locator", 1337},
	// {"LockBreaker", 1337},
	// {"Locker", 1337},
	// {"LongPlank", 1337},
	{"MotionSense", 10},
	{"Motor", 15},
	{"NightVision", 80},
	{"Padlock", 40},
	{"ParaBag", 50},
	// {"Pills", 1337},
	{"PowerSupply", 1337},
	// {"RemoteBomb", 1337},
	// {"RemoteControl", 1337},
	{"StunGun", 1337},
	{"Teargas", 1337},
	{"TentPack", 1337},
	{"ThermalVision", 200},
	// {"Timer", 1337},
	{"WheelLock", 25}
	// {"WoodLog", 1337},
	// {"Workbench", 1337}
};

hook OnGamemodeInit() {
	db_query(Database, "CREATE TABLE IF NOT EXISTS orders (\
	player TEXT NOT NULL,\
	item TEXT NOT NULL,\
	purchased INTEGER NOT NULL,\
	redeemed INTEGER)");

	db_query(Database, "CREATE INDEX IF NOT EXISTS player_index ON orders(player)");

	stmt_AddItemOrder            = db_prepare(Database, "INSERT INTO orders VALUES(?,?,?,0);");
	stmt_RedeemOrderItem         = db_prepare(Database, "UPDATE orders SET redeemed = redeemed + 1 WHERE item = ? AND player = ?;");
	stmt_GetRedeemableOrderItem  = db_prepare(Database, "SELECT purchased - redeemed as `redeemable` FROM orders WHERE item = ? AND player = ?;");
	stmt_GetRedeemableOrderItems = db_prepare(Database, "SELECT item, purchased - redeemed as `redeemable` FROM orders WHERE player = ?;");
}

bool:RemoveItemFromBasket(playerid, ItemType:item) {
	foreach(new i : BasketIndex) {
		if(Basket[playerid][i][E_BASKET:type] == item) {
			Basket[playerid][i][E_BASKET:type]     = INVALID_ITEM_TYPE;
			Basket[playerid][i][E_BASKET:quantity] = -1;

			Iter_Remove(BasketIndex, i);

			return true;
		}
	}

	return false;
}

CMD:store(playerid, params[]) {
    new const remainingCoins = GetPlayerCoins(playerid) - GetBasketTotal(playerid);

    new itemList[35000] = "Nome:\tCoins:\tQuant. Poss.:\tCesto:\n";

    for(new i; i < sizeof(ItemPricing); i++) {
        new itemName[ITM_MAX_NAME];
		new const ItemType:itemType  = GetItemTypeFromUniqueName(ItemPricing[i][E_PRICING:name]);
		new const basketItemQuantity = GetItemQuantityInBasket(playerid, itemType);
		new const bool:canBuy        = remainingCoins >= ItemPricing[i][E_PRICING:price];
		new const quantityPossible   = remainingCoins / GetItemPrice(itemType);

        GetItemTypeName(itemType, itemName);

        strcat(itemList, sprintf("%s%s\t%s%d\t%s\t%s\n", basketItemQuantity ? C_GREEN : "", itemName, !canBuy ? C_RED : "", ItemPricing[i][E_PRICING:price], quantityPossible ? sprintf("x%d", quantityPossible) : " ", basketItemQuantity ? sprintf("x%d", basketItemQuantity) : " "));
    }

    Dialog_Show(playerid, ShowItemList, DIALOG_STYLE_TABLIST_HEADERS, sprintf("Loja de Itens (Coins Disponíveis: %d)", remainingCoins), itemList, "Quantidade", GetBasketTotal(playerid) ? "Opções" : "Sair");
  
    return 1;
}
CMD:loja(playerid, params[]) return cmd_store(playerid, params);

CMD:basket(playerid, params[]) {
    new itemList[25000] = "Nome:\tQuantidade:\n";

    foreach(new i : BasketIndex) {
        new itemName[ITM_MAX_NAME];

        GetItemTypeName(Basket[playerid][i][E_BASKET:type], itemName);

        strcat(itemList, sprintf("%s\tx%d\n", itemName, Basket[playerid][i][E_BASKET:quantity]));
    }

    Dialog_Show(playerid, ShowBasket, DIALOG_STYLE_TABLIST_HEADERS, sprintf("Cesto da Loja - Total: %d Coins", GetBasketTotal(playerid)), itemList, "Pagar", "Voltar");

	return 1;
}
CMD:cesto(playerid, params[]) return cmd_basket(playerid, params);

CMD:itens(playerid, paramsp[]) {
	new itemList[25000] = "Nome:\tQuantidade:\n";

	// Query the database for the purchased items

    Dialog_Show(playerid, PurchasedItems, DIALOG_STYLE_TABLIST_HEADERS, "Itens Comprados na Loja:", itemList, "Spawn", "Sair");

	return 1;
}

Dialog:PurchasedItems(playerid, response, listitem, inputtext[]) {
    if(response) {
	} else {
	}
}

Dialog:ShowItemList(playerid, response, listitem, inputtext[]) {
    if(response) {
		new const remainingCoins = GetPlayerCoins(playerid) - GetBasketTotal(playerid);

		/* if(remainingCoins < ItemPricing[listitem][E_PRICING:price]) {
			if(GetItemQuantityInBasket(playerid, itemType)) { // No more money but we already have this item in the basket

			} else { // No money and not in basket
				SendClientMessage(playerid, RED, "Você não tem dinheiro para comprar esse Item");
				return cmd_store(playerid, "");
			}
		} */

		new const ItemType:itemType = GetItemTypeFromUniqueName(ItemPricing[listitem][E_PRICING:name]);
		new itemName[ITM_MAX_NAME];

		GetItemTypeName(itemType, itemName);

		new basketItemQuantity = GetItemQuantityInBasket(playerid, itemType);

		SelectedItem[playerid] = itemType;

		// Define the quantity for this item
		Dialog_Show(playerid, AddItemToBasket, DIALOG_STYLE_INPUT, 
		sprintf(C_WHITE"Quantidade de "C_GREEN"'%s'"C_WHITE" no Cesto:", itemName), 
		sprintf("%sEscolha a quantidade para esse item.\n\n\
		"C_WHITE"Quantidade Atual no Cesto: "C_GREEN"x%d"C_WHITE"\n\n\
		Esse item custa "C_GREEN"%d Coins"C_WHITE" por unidade. Você tem "C_GREEN"%d Coins"C_WHITE". Pode comprar x%d.", basketItemQuantity ? C_YELLOW : C_BLUE, basketItemQuantity, ItemPricing[listitem][E_PRICING:price], remainingCoins, remainingCoins / GetItemPrice(itemType)),
		basketItemQuantity ? "Atualizar" : "Adicionar", "Voltar");
    } else {
		if(GetBasketTotal(playerid)) { // Meaning there are some items
			new itemName[ITM_MAX_NAME];

			new const ItemType:itemType = GetItemTypeFromUniqueName(ItemPricing[listitem][E_PRICING:name]);

			GetItemTypeName(itemType, itemName);

			SelectedItem[playerid] = itemType;

    		Dialog_Show(playerid, ShowItemListOptions, DIALOG_STYLE_LIST, 
			sprintf("Loja de Itens - Opções (%s)", itemName), 
			"Remover do Cesto\nVer Cesto\nEsvaziar Cesto\nSair", 
			"OK", "Voltar");
		}
    }

	return 1;
}

Dialog:AddItemToBasket(playerid, response, listitem, inputtext[]) {
    if(response) {
		new inputQuantity = strval(inputtext);

		if(!isnumeric(inputtext) || inputQuantity < 0) {
			SendClientMessage(playerid, RED, "Tem que introduzir ou 0 para remover do Cesto ou um número positivo.");
			return cmd_store(playerid, "");
		}

		new itemName[ITM_MAX_NAME];

		GetItemTypeName(SelectedItem[playerid], itemName);

		if(inputQuantity == 0) {
			// Remove the item if it's in the Basket
			if(RemoveItemFromBasket(playerid, SelectedItem[playerid])) ChatMsg(playerid, YELLOW, "Removeu '%s' do Cesto", itemName);

			return cmd_store(playerid, "");
		}

		new const remainingCoins     = GetPlayerCoins(playerid) - GetBasketTotal(playerid);
		new const itemPrice          = GetItemPrice(SelectedItem[playerid]);
		new const basketItemQuantity = GetItemQuantityInBasket(playerid, SelectedItem[playerid]);
		new const basketItemValue    = itemPrice * basketItemQuantity;
		new const coins              = basketItemQuantity ? remainingCoins + basketItemValue : remainingCoins;

		if(coins < itemPrice * inputQuantity) {
			ChatMsg(playerid, YELLOW, "Você não tem dinheiro suficiente para comprar x%d de '%s'", inputQuantity, itemName);

			inputQuantity = min(inputQuantity, coins / itemPrice);

			// If the remainder is 0 or the quantity is the same then just go back to the list
			if(!inputQuantity) return cmd_store(playerid, "");
		}

		if(basketItemQuantity == inputQuantity) return cmd_store(playerid, "");

		new bool:itemInBasket;

		// Find out of the item type already exists in the basket and update the quantity
		foreach(new i : BasketIndex) {
			if(Basket[playerid][i][E_BASKET:type] == SelectedItem[playerid]) {
				Basket[playerid][i][E_BASKET:quantity] = inputQuantity;
				itemInBasket = true;
				ChatMsg(playerid, GREEN, "Tem agora x%d de '%s' no Cesto", inputQuantity, itemName);

				break;
			}
		}

		// Try to add the item type if it doesn't exist already.
		if(!itemInBasket) {
			new const index = Iter_Free(BasketIndex);

			if(index == ITER_NONE) {
				SendClientMessage(playerid, RED, "O seu cesto está cheio.");
				return cmd_store(playerid, "");
			}

			Basket[playerid][index][E_BASKET:type]     = SelectedItem[playerid];
			Basket[playerid][index][E_BASKET:quantity] = inputQuantity;

			Iter_Add(BasketIndex, index);

			ChatMsg(playerid, GREEN, "x%d de '%s' adicionado(s) ao Cesto (%d/32)", inputQuantity, itemName, Iter_Count(BasketIndex));
		}
	}

	return cmd_store(playerid, "");
}

Dialog:ShowItemListOptions(playerid, response, listitem, inputtext[]) {
    if(response) { // "Remover do Cesto\nVer Cesto\nEsvaziar Cesto\nSair", 
		switch(listitem) {
			case 0: {
				if(RemoveItemFromBasket(playerid, SelectedItem[playerid])) {
					new itemName[ITM_MAX_NAME];

					GetItemTypeName(SelectedItem[playerid], itemName);
					ChatMsg(playerid, YELLOW, "Removeu '%s' do Cesto", itemName);
				}

				return cmd_store(playerid, "");
			}
			case 1:	return cmd_basket(playerid, "");
			case 2: {
				// EmptyBasket(playerid);

				return cmd_store(playerid, "");
			}
			default: return 1; // ? Redundant?
		}
	} else 
		return cmd_store(playerid, "");

	return 1;
}

Dialog:ShowBasket(playerid, response, listitem, inputtext[]) {
    if(response) {
		new const total = GetBasketTotal(playerid);

		printf("[STORE] Salvando Ordem para '%p'", playerid);

		// Create the order in the database
		// stmt_bind_value(stmt_AddItemOrder, 0, DB::TYPE_PLAYER_NAME, playerid);

		new bool:badOrder;

		foreach(new i : BasketIndex) {
			new uniqueName[ITM_MAX_NAME];

			GetItemTypeUniqueName(Basket[playerid][i][E_BASKET:type], uniqueName);

			printf("\tItem: %s Quantidade: %d", uniqueName, Basket[playerid][i][E_BASKET:quantity]);

			// stmt_bind_value(stmt_AddItemOrder, 1, DB::TYPE_STRING, uniqueName, ITM_MAX_NAME);
			// stmt_bind_value(stmt_AddItemOrder, 2, DB::TYPE_INTEGER, Basket[playerid][i][E_BASKET:quantity]);

			// if(!stmt_execute(stmt_AddItemOrder)) badOrder = true;

			// ! wtf SQLitei Warning: (stmt_bind_value) Parameter index larger than number of parameters (1 > 0).

			db_query(Database, sprintf("INSERT INTO orders VALUES('%s','%s',%d,0);", GetPlayerNameEx(playerid), uniqueName, Basket[playerid][i][E_BASKET:quantity]));
		}

		if(!badOrder) {
			RemovePlayerCoins(playerid, total);
			// EmptyBasket(playerid);

			db_query(Database, sprintf("UPDATE players SET coins = coins - %d WHERE name = '%s';", total, GetPlayerNameEx(playerid)));

			SendClientMessage(playerid, GREEN, "Parabéns, concluiu a sua compra. Pode agora redimir os seus itens utilizando '/itens'");
		} else
			SendClientMessage(playerid, RED, "Ocorreu um erro ao efetuar a sua compra. Abra um post no fórum do Discord.");
	} else {
		cmd_store(playerid, "");
    }
}

GetItemPrice(ItemType:item) {
	new uniqueName[ITM_MAX_NAME];

	GetItemTypeUniqueName(item, uniqueName);

	for(new i; i < sizeof(ItemPricing); i++) {
		if(isequal(ItemPricing[i][E_PRICING:name], uniqueName))
			return ItemPricing[i][E_PRICING:price];
	}

	return 0;
}

GetItemQuantityInBasket(playerid, ItemType:item) {
	foreach(new i : BasketIndex) {
		if(Basket[playerid][i][E_BASKET:type] == item) 
			return Basket[playerid][i][E_BASKET:quantity];
	}

	return 0;
}

GetBasketTotal(playerid) {
	new total;

	foreach(new basketItem : BasketIndex) {
		new uniqueName[ITM_MAX_NAME];

		GetItemTypeUniqueName(Basket[playerid][basketItem][E_BASKET:type], uniqueName);

		// Search the pricing table
		for(new i; i < sizeof(ItemPricing); i++) {
			if(isequal(ItemPricing[i][E_PRICING:name], uniqueName)) {
				total += ItemPricing[i][E_PRICING:price] * Basket[playerid][basketItem][E_BASKET:quantity];
				break;
			}
		}
	}

    return total;
}

EmptyBasket(playerid) {
	new count;

	foreach(new i : BasketIndex) {
		Basket[playerid][i][E_BASKET:type]     = INVALID_ITEM_TYPE;
		Basket[playerid][i][E_BASKET:quantity] = -1;

		Iter_Remove(BasketIndex, i);

		count++;
	}
	
	return count;
}
