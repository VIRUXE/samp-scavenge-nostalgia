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
	{"Accelerometer", 1337},
	{"AdvancedKeypad", 1337},
	{"AK47Rifle", 1337},
	{"Ammo308", 1337},
	{"Ammo357", 1337},
	{"Ammo357Tracer", 1337},
	{"Ammo50", 1337},
	{"Ammo50BMG", 1337},
	{"Ammo556", 1337},
	{"Ammo556HP", 1337},
	{"Ammo556Tracer", 1337},
	{"Ammo762", 1337},
	{"Ammo9mm", 1337},
	{"Ammo9mmFMJ", 1337},
	{"AmmoBuck", 1337},
	{"AmmoFlechette", 1337},
	{"AmmoHomeBuck", 1337},
	{"AmmoRocket", 1337},
	{"AntiSepBandage", 50},
	{"AppleJuice", 10},
	{"Armour", 100},
	{"AutoInjec", 1337},
	{"Backpack", 1337},
	{"Banana", 10},
	{"Bandage", 40},
	{"BandanaBl", 5},
	{"BandanaGr", 5},
	{"BandanaPat", 5},
	{"BandanaWh", 5},
	{"Barbecue", 100},
	{"Barstool", 1337},
	{"Bat", 1337},
	{"Baton", 1337},
	{"Battery", 1337},
	{"Beanie", 1337},
	{"Bed", 1337},
	{"BigSword", 1337},
	{"BoaterHat", 1337},
	{"Boot", 1337},
	{"Bottle", 1337},
	{"BowlerHat", 1337},
	{"BoxingGloves", 1337},
	{"Bread", 1337},
	{"BreadLoaf", 1337},
	{"Briquettes", 1337},
	{"Broom", 1337},
	{"Bucket", 1337},
	{"Burger", 1337},
	{"BurgerBag", 1337},
	{"BurgerBox", 1337},
	{"BurntLog", 1337},
	{"CakeSlice", 1337},
	{"Camera", 1337},
	{"Camouflage", 1337},
	{"Campfire", 1337},
	{"CanDrink", 1337},
	{"Cane", 1337},
	{"Canister", 1337},
	{"CapBack1", 1337},
	{"Capsule", 1337},
	{"CaptainsCap", 1337},
	{"Cereal1", 1337},
	{"Cereal2", 1337},
	{"Chainsaw", 1337},
	{"Champagne", 1337},
	{"CodePart", 1337},
	{"Computer", 1337},
	{"ControlBox", 1337},
	{"CowboyHat", 1337},
	{"CrateDoor", 1337},
	{"Cross", 1337},
	{"Crowbar", 1337},
	{"Cupboard", 1337},
	{"DataInterface", 1337},
	{"Daypack", 1337},
	{"DeadLeg", 1337},
	{"DesertEagle", 1337},
	{"Desk", 1337},
	{"Detergent", 1337},
	{"Detonator", 1337},
	{"Dice", 1337},
	{"Dildo1", 1337},
	{"Dildo2", 1337},
	{"Dildo3", 1337},
	{"Dildo4", 1337},
	{"DoctorBag", 1337},
	{"DogsBreath", 1337},
	{"DoorBlin", 1337},
	{"Doormat", 1337},
	{"Dynamite", 1337},
	{"EasterEgg", 1337},
	{"EmpPhoneBomb", 1337},
	{"EmpProxMine", 1337},
	{"EmpTimebomb", 1337},
	{"EmpTripMine", 1337},
	{"Explosive", 1337},
	{"Extinguisher", 1337},
	{"FireLighter", 1337},
	{"FireworkBox", 1337},
	{"FishRod", 1337},
	{"FishyFingers", 1337},
	{"Flag", 1337},
	{"Flamer", 1337},
	{"Flare", 1337},
	{"FlareGun", 1337},
	{"Flashlight", 1337},
	{"Flowers", 1337},
	{"Fluctuator", 1337},
	{"FluxCap", 1337},
	{"Fork", 1337},
	{"FryingPan", 1337},
	{"Fusebox", 1337},
	{"GarageDoor", 1337},
	{"GasCan", 1337},
	{"GasMask", 1337},
	{"GearBox", 1337},
	{"GeigerCounter", 1337},
	{"GolfClub", 1337},
	{"GreenGloop", 1337},
	{"Grenade", 1337},
	{"GrnApple", 1337},
	{"GunCase", 1337},
	{"Gyroscope", 1337},
	{"HackDevice", 1337},
	{"Ham", 1337},
	{"Hammer", 1337},
	{"HardDrive", 1337},
	{"Headlight", 1337},
	{"HeartShapedBox", 1337},
	{"Heatseeker", 1337},
	{"HelmArmy", 1337},
	{"HelmMoto", 1337},
	{"HerpDerp", 1337},
	{"HockeyMask", 1337},
	{"HockeyMaskGreen", 1337},
	{"Holdall", 1337},
	{"HotDog", 1337},
	{"IceCream", 1337},
	{"IceCreamBars", 1337},
	{"IedBomb", 1337},
	{"IedPhoneBomb", 1337},
	{"IedProxMine", 1337},
	{"IedTimebomb", 1337},
	{"IedTripMine", 1337},
	{"InsulDoor", 1337},
	{"IoUnit", 1337},
	{"Ketchup", 1337},
	{"Key", 1337},
	{"Keycard", 1337},
	{"Keypad", 1337},
	{"Knife", 1337},
	{"Knife2", 1337},
	{"Knife3", 1337},
	{"Knuckles", 1337},
	{"LargeBackpack", 1337},
	{"LargeBox", 1337},
	{"LaserPoint", 1337},
	{"Lemon", 1337},
	{"LenKnocksRifle", 1337},
	{"Locator", 1337},
	{"LockBreaker", 1337},
	{"Locker", 1337},
	{"LocksmithKit", 1337},
	{"LongPlank", 1337},
	{"M16Rifle", 1337},
	{"M77RMRifle", 1337},
	{"M9Pistol", 1337},
	{"M9PistolSD", 1337},
	{"Mac10", 1337},
	{"Mailbox", 1337},
	{"Map", 1337},
	{"Meat", 1337},
	{"Meat2", 1337},
	{"MediumBag", 1337},
	{"MediumBox", 1337},
	{"Medkit", 1337},
	{"MetalFrame", 1337},
	{"MetalGate1", 1337},
	{"MetalGate2", 1337},
	{"MetPanel", 1337},
	{"Microphone", 1337},
	{"MilkBottle", 1337},
	{"MilkCarton", 1337},
	{"Minigun", 1337},
	{"MobilePhone", 1337},
	{"Model70Rifle", 1337},
	{"Molotov", 1337},
	{"MolotovEmpty", 1337},
	{"MotionSense", 1337},
	{"Motor", 1337},
	{"MP5", 1337},
	{"Mustard", 1337},
	{"Nailbat", 1337},
	{"NightVision", 1337},
	{"Note", 1337},
	{"OilCan", 1337},
	{"OilDrum", 1337},
	{"Orange", 1337},
	{"OrangeJuice", 1337},
	{"Padlock", 1337},
	{"Pager", 1337},
	{"Pan", 1337},
	{"ParaBag", 1337},
	{"Parachute", 1337},
	{"Parrot", 1337},
	{"PetrolBomb", 1337},
	{"Pills", 1337},
	{"PisschBox", 1337},
	{"Pizza", 1337},
	{"PizzaBox", 1337},
	{"PizzaHat", 1337},
	{"PizzaOnly", 1337},
	{"PlantPot", 1337},
	{"PlotPole", 1337},
	{"PoliceCap", 1337},
	{"PoliceHelm", 1337},
	{"PoolCue", 1337},
	{"PowerSupply", 1337},
	{"Pumpkin", 1337},
	{"PumpShotgun", 1337},
	{"PussyMask", 1337},
	{"Radio", 1337},
	{"RadioBox", 1337},
	{"RadioPole", 1337},
	{"Rake", 1337},
	{"RawFish", 1337},
	{"RedApple", 1337},
	{"RedMask", 1337},
	{"RedPanel", 1337},
	{"RefinedMetal", 1337},
	{"RefineMachine", 1337},
	{"RemoteBomb", 1337},
	{"RemoteControl", 1337},
	{"RocketLauncher", 1337},
	{"Rucksack", 1337},
	{"Satchel", 1337},
	{"Sawnoff", 1337},
	{"ScrapMachine", 1337},
	{"ScrapMetal", 1337},
	{"Screwdriver", 1337},
	{"SeedBag", 1337},
	{"SemiAutoRifle", 1337},
	{"Shield", 1337},
	{"ShipDoor", 1337},
	{"Sign", 1337},
	{"SignShot", 1337},
	{"Sledgehammer", 1337},
	{"SmallBox", 1337},
	{"SmallTable", 1337},
	{"SniperRifle", 1337},
	{"Spade", 1337},
	{"Spanner", 1337},
	{"Spas12", 1337},
	{"Spatula", 1337},
	{"SprayPaint", 1337},
	{"StarterMotor", 1337},
	{"Steak", 1337},
	{"StorageUnit", 1337},
	{"StrawHat", 1337},
	{"StunGun", 1337},
	{"Suitcase", 1337},
	{"SwatHelmet", 1337},
	{"Sword", 1337},
	{"Table", 1337},
	{"Taco", 1337},
	{"TallFrame", 1337},
	{"Teargas", 1337},
	{"Tec9", 1337},
	{"TentPack", 1337},
	{"ThermalVision", 1337},
	{"Timer", 1337},
	{"TntPhoneBomb", 1337},
	{"TntProxMine", 1337},
	{"TntTimebomb", 1337},
	{"TntTripMine", 1337},
	{"Tomato", 1337},
	{"ToolBox", 1337},
	{"TopHat", 1337},
	{"Torso", 1337},
	{"TruckCap", 1337},
	{"VehicleWeapon", 1337},
	{"WalkingCane", 1337},
	{"WASR3Rifle", 1337},
	{"WaterMachine", 1337},
	{"WeddingCake", 1337},
	{"Wheel", 1337},
	{"WheelLock", 1337},
	{"Whisky", 1337},
	{"Wine1", 1337},
	{"Wine2", 1337},
	{"Wine3", 1337},
	{"WitchesHat", 1337},
	{"WoodLog", 1337},
	{"WoodPanel", 1337},
	{"Workbench", 1337},
	{"WrappedMeat", 1337},
	{"Wrench", 1337},
	{"XmasHat", 1337},
	{"ZorroMask", 1337},
 	{"HandCuffs", 1337},
    {"ArmyHelmet2", 1337},
    {"Balaclava", 1337},
    {"CapBack2", 1337},
    {"CapBack3", 1337},
    {"CapBack4", 1337},
    {"CapBack5", 1337},
    {"Clothes", 1337},
    {"CluckinBellHat1", 1337},
    {"CorPanel", 1337},
    {"DiaboMask", 1337},
    {"DupleDoor", 1337},
    {"fire_hat1", 1337},
    {"fire_hat2", 1337},
    {"headphones04", 1337},
    {"InsulPanel", 1337},
    {"MetalBlin", 1337},
    {"MetalStand", 1337},
    {"PortaCofre", 1337}
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

    new itemList[25000] = "Nome:\tPreço (Coins):\tCesto:\n";

    for(new i; i < sizeof(ItemPricing); i++) {
        new itemName[ITM_MAX_NAME];

		new const ItemType:itemType = GetItemTypeFromUniqueName(ItemPricing[i][E_PRICING:name]);

        GetItemTypeName(itemType, itemName);

		new basketQuantity = GetItemQuantityInBasket(playerid, itemType);

        strcat(itemList, sprintf("%s%s\t%d\t%s\n", basketQuantity ? C_GREEN : "", itemName, ItemPricing[i][E_PRICING:price], basketQuantity ? sprintf("x%d", basketQuantity) : ""));
    }

    Dialog_Show(playerid, ShowItemList, DIALOG_STYLE_TABLIST_HEADERS, sprintf("Loja de Itens (Coins Disponíveis: %d)", coinsAvailable), itemList, "Quantidade", GetBasketTotal(playerid) ? "Opções" : "Sair");
    
    return 1;
}
CMD:loja(playerid, params[]) return cmd_store(playerid, params);

CMD:basket(playerid, params[]) {

	return 1;
}
CMD:cesto(playerid, params[]) return cmd_basket(playerid, params);

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
		new const inputQuantity = strval(inputtext);

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

		if(GetPlayerCoins(playerid) - GetBasketTotal(playerid) < GetItemPrice(selectedItem[playerid]) * inputQuantity) {
			ChatMsg(playerid, RED, "Você não tem dinheiro suficiente para comprar x%d de '%s'", inputQuantity, itemName);
			return cmd_store(playerid, "");
		}

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
    } else {
    }
}

Dialog:BasketOptions(playerid, response, listitem, inputtext[]) {
    if(response) {
    } else {
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