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

static Basket[MAX_PLAYERS][32][E_BASKET], Iterator:BasketIndex<MAX_BASKET_ITEMS>;

static ItemType:selectedItem[MAX_PLAYERS];

static ItemPricing[][E_PRICING] = {
	// Explosivos
	{"Dynamite", 1337},
	{"TntPhoneBomb", 1337},
	{"TntProxMine", 1337},
	{"TntTimebomb", 1337},
	{"TntTripMine", 1337},
	{"IedBomb", 1337},
	{"IedPhoneBomb", 1337},
	{"IedProxMine", 1337},
	{"IedTimebomb", 1337},
	{"IedTripMine", 1337},
	{"FireworkBox", 1337},
	{"EmpPhoneBomb", 1337},
	{"EmpProxMine", 1337},
	{"EmpTimebomb", 1337},
	{"EmpTripMine", 1337},
	{"Explosive", 1337},
	{"MobilePhone", 1337},

	// Médico
	{"Medkit", 1337},
	{"Bandage", 40},
	{"AntiSepBandage", 50},
	{"DoctorBag", 1337},
	
	// Ferramentas
	{"Spanner", 1337},
	{"Wrench", 1337},
	{"Screwdriver", 1337},
	{"Hammer", 1337},
	{"Crowbar", 1337},

	{"Map", 1337},
	{"MediumBag", 1337},
	{"LargeBackpack", 1337},
	{"MediumBox", 1337},
	{"LargeBox", 1337},
	{"Wheel", 1337},
	{"Key", 1337},
	{"LocksmithKit", 1337},
	{"Keypad", 1337},

	// Defesas
	{"InsulDoor", 1337},
	{"ShipDoor", 1337},
	{"TallFrame", 1337},
	{"MetalFrame", 1337},
	{"MetalGate1", 1337},
	{"MetalGate2", 1337},
	{"MetPanel", 1337},
	{"WoodPanel", 1337},
    {"CorPanel", 1337},
    {"DiaboMask", 1337},
    {"DupleDoor", 1337},
    {"fire_hat1", 1337},
    {"fire_hat2", 1337},
    {"headphones04", 1337},
    {"InsulPanel", 1337},
    {"MetalBlin", 1337},
    {"MetalStand", 1337},
	{"GarageDoor", 1337},
	{"DoorBlin", 1337},
    {"PortaCofre", 1337},

	// Armas
	{"M16Rifle", 1337},
	{"M77RMRifle", 1337},
	{"M9Pistol", 1337},
	{"M9PistolSD", 1337},
	{"Mac10", 1337},
	{"MP5", 1337},
	{"PumpShotgun", 1337},
	{"SemiAutoRifle", 1337},
	{"Sawnoff", 1337},
	{"Spas12", 1337},
	{"Tec9", 1337},
	{"WASR3Rifle", 1337},
	{"SniperRifle", 1337},
	{"Model70Rifle", 1337},
	{"Molotov", 1337},
	{"AK47Rifle", 1337},
	{"Armour", 100},
	{"Flamer", 1337},

	{"AdvancedKeypad", 1337},
	{"Backpack", 1337},
	{"Barbecue", 100},
	{"Battery", 1337},
	{"Bed", 1337},
	{"Campfire", 1337},
	{"DataInterface", 1337},
	{"DesertEagle", 1337},
	{"Detonator", 1337},
	{"FireLighter", 1337},
	{"Fluctuator", 1337},
	{"FluxCap", 1337},
	{"Fusebox", 1337},
	{"GasCan", 1337},
	{"GasMask", 1337},
	{"GeigerCounter", 1337},
	{"Gyroscope", 1337},
	{"HackDevice", 1337},
	{"HardDrive", 1337},
	{"Headlight", 1337},
	{"Heatseeker", 1337},
	{"Holdall", 1337},
	{"IoUnit", 1337},

	{"LenKnocksRifle", 1337},
	{"Locator", 1337},
	{"LockBreaker", 1337},
	{"Locker", 1337},
	{"LongPlank", 1337},
	{"MotionSense", 1337},
	{"Motor", 1337},
	{"NightVision", 1337},
	{"Padlock", 1337},
	{"ParaBag", 1337},
	{"Pills", 1337},
	{"PowerSupply", 1337},
	{"RemoteBomb", 1337},
	{"RemoteControl", 1337},
	{"Spatula", 1337},
	{"StunGun", 1337},
	{"Teargas", 1337},
	{"TentPack", 1337},
	{"ThermalVision", 1337},
	{"Timer", 1337},
	{"WheelLock", 1337},
	{"WoodLog", 1337},
	{"Workbench", 1337}
};

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
    new const coinsAvailable = GetPlayerCoins(playerid) - GetBasketTotal(playerid);

    new itemList[35000] = "Nome:\tPreço (Coins):\tQuant. Poss.:\tCesto:\n";

    for(new i; i < sizeof(ItemPricing); i++) {
        new itemName[ITM_MAX_NAME];
		new const ItemType:itemType = GetItemTypeFromUniqueName(ItemPricing[i][E_PRICING:name]);
		new const basketQuantity    = GetItemQuantityInBasket(playerid, itemType);
		new const bool:canBuy       = coinsAvailable >= ItemPricing[i][E_PRICING:price];
		new const itemPrice         = GetItemPrice(selectedItem[playerid]);
		new const quantityPossible  = coinsAvailable % itemPrice;
		new listItem[1024];

        GetItemTypeName(itemType, itemName);

		format(listItem, sizeof(listItem), "%s%s\t%s%d\t%s\t%s\n", basketQuantity ? C_GREEN : "", itemName, !canBuy ? C_RED : "", ItemPricing[i][E_PRICING:price], quantityPossible ? sprintf("x%s", quantityPossible) : "", basketQuantity ? sprintf("x%d", basketQuantity) : "");

        strcat(itemList, listItem);
    }

    Dialog_Show(playerid, ShowItemList, DIALOG_STYLE_TABLIST_HEADERS, sprintf("Loja de Itens (Coins Disponíveis: %d)", coinsAvailable), itemList, "Quantidade", GetBasketTotal(playerid) ? "Opções" : "Sair");
    
    return 1;
}
CMD:loja(playerid, params[]) return cmd_store(playerid, params);

CMD:basket(playerid, params[]) {
	new const coinsAvailable = GetPlayerCoins(playerid) - GetBasketTotal(playerid);

    new itemList[25000] = "Nome:\tQuantidade:\n";

    foreach(new i : BasketIndex) {
        new itemName[ITM_MAX_NAME];

        GetItemTypeName(Basket[playerid][i][E_BASKET:type], itemName);

        strcat(itemList, sprintf("%s\tx%d\n", itemName, Basket[playerid][i][E_BASKET:quantity]));
    }

    Dialog_Show(playerid, ShowBasket, DIALOG_STYLE_TABLIST_HEADERS, sprintf("Cesto da Loja - Total: %d Coins (Coins Disponíveis: %d)", coinsAvailable), itemList, "Pagar", "Voltar");

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

		new basketQuantity = GetItemQuantityInBasket(playerid, itemType);

		selectedItem[playerid] = itemType;

		// Define the quantity for this item
		Dialog_Show(playerid, AddItemToBasket, DIALOG_STYLE_INPUT, 
		sprintf(C_WHITE"Quantidade de "C_GREEN"'%s'"C_WHITE" no Cesto:", itemName), 
		sprintf("%sEscolha a quantidade para esse item.\n\n\
		"C_WHITE"Quantidade Atual no Cesto: "C_GREEN"x%d"C_WHITE"\n\n\
		Esse item custa "C_GREEN"%d Coins"C_WHITE" por unidade. Você tem "C_GREEN"%d Coins"C_WHITE".", basketQuantity ? C_YELLOW : C_BLUE, basketQuantity, ItemPricing[listitem][E_PRICING:price], remainingCoins),
		basketQuantity ? "Atualizar" : "Adicionar", "Voltar");
    } else {
		if(GetBasketTotal(playerid)) { // Meaning there are some items
			new itemName[ITM_MAX_NAME];

			new const ItemType:itemType = GetItemTypeFromUniqueName(ItemPricing[listitem][E_PRICING:name]);

			GetItemTypeName(itemType, itemName);

			selectedItem[playerid] = itemType;

    		Dialog_Show(playerid, ShowItemListOptions, DIALOG_STYLE_LIST, 
			sprintf("Loja de Itens - Opções (%s)", itemName), 
			"Remover do Cesto\nVer Cesto\nSair", 
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

		GetItemTypeName(selectedItem[playerid], itemName);

		if(inputQuantity == 0) {
			// Remove the item if it's in the Basket
			if(RemoveItemFromBasket(playerid, selectedItem[playerid])) ChatMsg(playerid, YELLOW, "Removeu '%s' do Cesto", itemName);

			return cmd_store(playerid, "");
		}

		new const coinsAvailable = GetPlayerCoins(playerid) - GetBasketTotal(playerid);
		new const itemPrice      = GetItemPrice(selectedItem[playerid]);

		if(coinsAvailable < itemPrice * inputQuantity) {
			ChatMsg(playerid, YELLOW, "Você não tem dinheiro suficiente para comprar x%d de '%s'", inputQuantity, itemName);

			inputQuantity = coinsAvailable % itemPrice;

			// If the remainder is 0 or the quantity is the same then just go back to the list
			if(!inputQuantity)  return cmd_store(playerid, "");
		}

		if(GetItemQuantityInBasket(playerid, selectedItem[playerid]) == inputQuantity) return cmd_store(playerid, "");

		new bool:itemInBasket;

		// Find out of the item type already exists in the basket and update the quantity
		foreach(new i : BasketIndex) {
			if(Basket[playerid][i][E_BASKET:type] == selectedItem[playerid]) {
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

			Basket[playerid][index][E_BASKET:type]     = selectedItem[playerid];
			Basket[playerid][index][E_BASKET:quantity] = inputQuantity;

			Iter_Add(BasketIndex, index);

			ChatMsg(playerid, GREEN, "x%d de '%s' adicionado(s) ao Cesto (%d/32)", inputQuantity, itemName, Iter_Count(BasketIndex));
		}
	}

	return cmd_store(playerid, "");
}

Dialog:ShowItemListOptions(playerid, response, listitem, inputtext[]) {
    if(response) { //Remover do Cesto\nVer Cesto\nSair
		switch(listitem) {
			case 0: {
				if(RemoveItemFromBasket(playerid, selectedItem[playerid])) {
					new itemName[ITM_MAX_NAME];

					GetItemTypeName(selectedItem[playerid], itemName);
					ChatMsg(playerid, YELLOW, "Removeu '%s' do Cesto", itemName);
				}

				return cmd_store(playerid, "");
			}
			case 1:	return cmd_basket(playerid, "");
		}
	} else 
		return cmd_store(playerid, "");

	return 1;
}

Dialog:ShowBasket(playerid, response, listitem, inputtext[]) {
    if(response) {
		new const total = GetBasketTotal(playerid);
		// Cria a encomenda

		RemovePlayerCoins(playerid, total);
		EmptyBasket(playerid);
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
	for(new i; i < MAX_BASKET_ITEMS; i++) 
		if(Basket[playerid][i][E_BASKET:type] == item) return Basket[playerid][i][E_BASKET:quantity];

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