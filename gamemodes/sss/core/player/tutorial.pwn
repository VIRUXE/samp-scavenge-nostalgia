/* 
	Passos necessários para completar o tutorial:
	- Abrir Inventario
	- Equipar Mochila
	- Adicionar Item ao Inventario
	- Abrir Opcoes do Inventario
	- Abrir Container
	- Adicionar Item ao Container
	- Abrir Opcoes do Container
	- Dropar Item
	- Colocar Arma no coldre
	- Utilizar Item noutro Item
	- Terminar Ajuste de Item
	- Montar Tenda
	- Reparar Veiculo
 */

#include <YSI\y_hooks>

forward OnPlayerProgressTutorial(playerid, stepscompleted);
forward OnPlayerExitTutorial(playerid, bool:completed);

#define MAX_TUTORIAL_ITEMS 20
#define MAX_TUTORIAL_STEPS 13

static enum E_TUTORIAL_ITEMS {
	TUT_ITEM_CORPANEL[3],
	TUT_ITEM_CROWBAR,
	TUT_ITEM_GASCAN,
	TUT_ITEM_HAMMER[2],
	TUT_ITEM_KEYPAD,
	TUT_ITEM_LARGEBOX,
	TUT_ITEM_MEDIUMBOX,
	TUT_ITEM_MOTOR,
	TUT_ITEM_PUMPSHOTGUN,
	TUT_ITEM_RUCKSACK,
	TUT_ITEM_SCREWDRIVER,
	TUT_ITEM_SMALLBOX,
	TUT_ITEM_SPANNER,
	TUT_ITEM_TENT,
	TUT_ITEM_WHEEL[3],
	TUT_ITEM_WRENCH,
}

// Bool para cada passo do tutorial porque ele pode ser feito em qualquer ordem.
static enum E_TUTORIAL_STEPS {
    bool:OPEN_INVENTORY,
    bool:EQUIP_BACKPACK,
    bool:ADD_ITEM_TO_INVENTORY,
    bool:VIEW_INVENTORY_OPTIONS,
    bool:OPEN_CONTAINER, // Mochila
    bool:ADD_ITEM_TO_CONTAINER, // Mochila
    bool:VIEW_CONTAINER_OPTIONS,
    bool:DROP_ITEM,
    bool:HOLSTER_WEAPON,
    bool:USE_ITEM_ON_ANOTHER_ITEM,
    bool:FINISH_ITEM_TWEAK,
    bool:BUILD_TENT,
    bool:REPAIR_VEHICLE
};

static enum E_TUTORIAL {
	PlayerText:TUT_STATUS,
	TUT_STEPS[E_TUTORIAL_STEPS],
	TUT_VEHICLE,
	TUT_ITEMS[E_TUTORIAL_ITEMS],
	TUT_PICKUPS[E_TUTORIAL_ITEMS],
	TUT_GATE_OBJ
}

static Tutorial[MAX_PLAYERS][E_TUTORIAL];

hook OnPlayerConnect(playerid) {
	Tutorial[playerid][TUT_VEHICLE]  = INVALID_VEHICLE_ID;
	Tutorial[playerid][TUT_GATE_OBJ] = INVALID_OBJECT_ID;

	Tutorial[playerid][TUT_STATUS] = CreatePlayerTextDraw(playerid, 320.000, 422.916666, sprintf("~b~Tarefa Atual ~y~(1/%d)~w~:~n~Abrir Inventario", MAX_TUTORIAL_STEPS));
	PlayerTextDrawLetterSize(playerid, Tutorial[playerid][TUT_STATUS], 0.256761, 1.303703);
	PlayerTextDrawTextSize(playerid, Tutorial[playerid][TUT_STATUS], 450.666666, 128.125);
	PlayerTextDrawAlignment(playerid, Tutorial[playerid][TUT_STATUS], 2);
	PlayerTextDrawColor(playerid, Tutorial[playerid][TUT_STATUS], -1);
	PlayerTextDrawUseBox(playerid, Tutorial[playerid][TUT_STATUS], 1);
	PlayerTextDrawBoxColor(playerid, Tutorial[playerid][TUT_STATUS], 0x00000044);
	PlayerTextDrawSetShadow(playerid, Tutorial[playerid][TUT_STATUS], 1);
	PlayerTextDrawSetOutline(playerid, Tutorial[playerid][TUT_STATUS], 1);
	PlayerTextDrawBackgroundColor(playerid, Tutorial[playerid][TUT_STATUS], BLACK);
	PlayerTextDrawFont(playerid, Tutorial[playerid][TUT_STATUS], 1);
	PlayerTextDrawSetProportional(playerid, Tutorial[playerid][TUT_STATUS], 1);
}

hook OnPlayerDisconnect(playerid, reason) {
	if(IsPlayerInTutorial(playerid)) ExitTutorial(playerid, false);
}

hook OnPlayerRegister(playerid) {
	EnterTutorial(playerid);
}

hook OnVehicleSave(vehicleid) {
	// Não salvar veículos do tutorial
	foreach(new i : Player) {
		if(vehicleid == Tutorial[i][TUT_VEHICLE]) {
			printf("[TUTORIAL] Veículo %d de %p (%d) não será salvo.", vehicleid, i, i);
			return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerWearBag(playerid, itemid) {
	if(IsPlayerInTutorial(playerid)) {
		PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob", ls(playerid, "tutorial/tip/access_bag"), ls(playerid, "common/lang-shortcode")));
//		https://translate.google.com/translate_tts?ie=UTF-8&q=Você pode acessar sua mochila pressionando H e clicando no ícone Mochila na parte inferior direita.&tl=PT-TW&client=tw-ob
//		https://translate.google.com/translate_tts?ie=UTF-8&q=You can access your bag by pressing H and clicking the Bag icon at the bottom right.&tl=EN-TW&client=tw-ob

		IncreaseTutorialProgress(playerid, EQUIP_BACKPACK);

		ChatMsg(playerid, GREEN, " > "C_WHITE" %s", ls(playerid, "tutorial/tip/access_bag"));
	}
}

hook OnPlayerOpenInventory(playerid) {
	if(IsPlayerInTutorial(playerid)) {
/* 	    if(!PlayerTutorial_VozInv[playerid])
	    {
	    	// PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?&q=%s&tl=%s-TW&client=tw-ob",
				ls(playerid, "tutorial/tip/access_inventory"), ls(playerid, "common/lang-shortcode")));

//			https://translate.google.com/translate_tts?ie=UTF-8&q=Este é o seu inventário. Também conhecido como seus bolsos. Esta não é sua mochila.&tl=PT-TW&client=tw-ob
//			https://translate.google.com/translate_tts?ie=UTF-8&q=This is your character inventory also known as your pockets. This is not your bag.&tl=EN-TW&client=tw-ob

            PlayerTutorial_VozInv[playerid] = true;
		} */

		// PlayerTextDrawHide(playerid, Tutorial[playerid][TUT_STATUS]);

		IncreaseTutorialProgress(playerid, OPEN_INVENTORY);

		ChatMsg(playerid, GREEN, " > "C_WHITE" %s", ls(playerid, "tutorial/tip/access_inventory"));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseInventory(playerid) {
	if(IsPlayerInTutorial(playerid)) {
		// PlayerTextDrawShow(playerid, Tutorial[playerid][TUT_STATUS]);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenContainer(playerid, containerid) {
	if(IsPlayerInTutorial(playerid)) {
		if(containerid == GetItemArrayDataAtCell(GetPlayerBagItem(playerid), 1)) // ? Container Mochila?
		{
/* 		    if(!PlayerTutorial_VozCnt[playerid])
		    {
  				// PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob", ls(playerid, "tutorial/tip/access_bag_own"), ls(playerid, "common/lang-shortcode")));
//				https://translate.google.com/translate_tts?ie=UTF-8&q=Esta é a sua Mochila. Elas são armazenamento extra. Existem muitos tipos diferentes de mochilas com tamanhos diferentes.&tl=PT-TW&client=tw-ob
//				https://translate.google.com/translate_tts?ie=UTF-8&q=This is your bag. Bags are extra storage. There are many different types of bags with different sizes.&tl=EN-TW&client=tw-ob

                PlayerTutorial_VozCnt[playerid] = true;
			} */

			// PlayerTextDrawHide(playerid, Tutorial[playerid][TUT_STATUS]);
			
			IncreaseTutorialProgress(playerid, OPEN_CONTAINER);

			ChatMsg(playerid, GREEN, " > "C_WHITE" %s", ls(playerid, "tutorial/tip/access_bag_own"));
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerCloseContainer(playerid, containerid) {
	if(IsPlayerInTutorial(playerid)) {
		if(containerid == GetItemArrayDataAtCell(GetPlayerBagItem(playerid), 1)) { // ? Container Mochila?
			// PlayerTextDrawShow(playerid, Tutorial[playerid][TUT_STATUS]);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerViewCntOpt(playerid, containerid) {
	if(IsPlayerInTutorial(playerid)) {
		// if(GetItemType(GetContainerSlotItem(containerid, GetPlayerContainerSlot(playerid))) == item_Wrench)
		// {
  			PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob", ls(playerid, "tutorial/tip/item-options"), ls(playerid, "common/lang-shortcode")));

//			https://translate.google.com/translate_tts?ie=UTF-8&q=Estas são suas opções para o item selecionado. Equipar coloca em sua mão.&tl=PT-TW&client=tw-ob
//			https://translate.google.com/translate_tts?ie=UTF-8&q=These are your options for the selected item. Equip puts it in your hand. Combine can be selected on multiple items to attempt to combine them.&tl=EN-TW&client=tw-ob

			IncreaseTutorialProgress(playerid, VIEW_CONTAINER_OPTIONS);

			ChatMsg(playerid, GREEN, " > "C_WHITE" %s", ls(playerid, "tutorial/tip/item-options"));
		// }
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDroppedItem(playerid, itemid) {
	if(IsPlayerInTutorial(playerid)) {
		PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob", ls(playerid, "tutorial/tip/item-drop"), ls(playerid, "common/lang-shortcode")));

//		https://translate.google.com/translate_tts?ie=UTF-8&q=Quando você soltar um item, outros jogadores podem pegá-lo.&tl=PT-TW&client=tw-ob
//		https://translate.google.com/translate_tts?ie=UTF-8&q=When you drop an item, other players can pick it up.&tl=EN-TW&client=tw-ob

		IncreaseTutorialProgress(playerid, DROP_ITEM);

		ChatMsg(playerid, GREEN, " > "C_WHITE" %s", ls(playerid, "tutorial/tip/item-drop"));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemAddedToInventory(playerid, itemid, slot) {
	if(IsPlayerInTutorial(playerid)) {
		PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob", ls(playerid, "tutorial/tip/item-add"), ls(playerid, "common/lang-shortcode")));

//		https://translate.google.com/translate_tts?ie=UTF-8&q=Você adicionou um item ao seu inventário. Se o seu inventário estiver cheio, o item será colocado na sua Mochila.&tl=PT-TW&client=tw-ob
//		https://translate.google.com/translate_tts?ie=UTF-8&q=You added an item to your inventory. If your inventory is full, the item will be put in your bag.&tl=EN-TW&client=tw-ob

		IncreaseTutorialProgress(playerid, ADD_ITEM_TO_INVENTORY);

		ChatMsg(playerid, GREEN, " > "C_WHITE" %s", ls(playerid, "tutorial/tip/item-add"));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerViewInvOpt(playerid) {
	if(IsPlayerInTutorial(playerid)) {
		PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob", ls(playerid, "tutorial/tip/item-options"), ls(playerid, "common/lang-shortcode")));

//		https://translate.google.com/translate_tts?ie=UTF-8&q=Estas são suas opções para o item selecionado. Equipar coloca em sua mão.&tl=PT-TW&client=tw-ob
//		https://translate.google.com/translate_tts?ie=UTF-8&q=These are your options for the selected item. Equip puts it in your hand. Combine can be selected on multiple items to attempt to combine them.&tl=EN-TW&client=tw-ob

		IncreaseTutorialProgress(playerid, VIEW_INVENTORY_OPTIONS);

		ChatMsg(playerid, GREEN, " > "C_WHITE" %s", ls(playerid, "tutorial/tip/item-options"));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemAddedToContainer(containerid, itemid, playerid) {
	if(IsPlayerInTutorial(playerid)) {
		IncreaseTutorialProgress(playerid, ADD_ITEM_TO_CONTAINER);

		if(containerid == GetItemArrayDataAtCell(GetPlayerBagItem(playerid), 1)) {
			PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob", ls(playerid, "tutorial/tip/item-add-bag"), ls(playerid, "common/lang-shortcode")));

//				https://translate.google.com/translate_tts?ie=UTF-8&q=Você adicionou um item a sua mochila. Você pode acessar sua mochila pressionando H e clicando no ícone Mochila na parte inferior direita.&tl=PT-TW&client=tw-ob
//				https://translate.google.com/translate_tts?ie=UTF-8&q=You added an item to your bag. You can access your bag by pressing H and clicking the Bag icon at the bottom right.&tl=EN-TW&client=tw-ob

			ChatMsg(playerid, GREEN, " > "C_WHITE" %s", ls(playerid, "tutorial/tip/item-add-bag"));
		} else {
			PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob", ls(playerid, "tutorial/tip/item-add-container"), ls(playerid, "common/lang-shortcode")));

//				https://translate.google.com/translate_tts?ie=UTF-8&q=Você adicionou um item a um container. Os containeres são lugares para armazenar itens&tl=PT-TW&client=tw-ob
//				https://translate.google.com/translate_tts?ie=UTF-8&q=You added an item to a container. Containers are places to store items &tl=EN-TW&client=tw-ob

			ChatMsg(playerid, GREEN, " > "C_WHITE" %s", ls(playerid, "tutorial/tip/item-add-container"));
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerHolsteredItem(playerid, itemid) {
	if(IsPlayerInTutorial(playerid)) {
		PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob", ls(playerid, "tutorial/tip/weapon-holster"), ls(playerid, "common/lang-shortcode")));

//		https://translate.google.com/translate_tts?ie=UTF-8&q=Você colocou um item no coldre. Os itens no coldre podem ser rapidamente acessados pressionando Y novamente.&tl=PT-TW&client=tw-ob
//		https://translate.google.com/translate_tts?ie=UTF-8&q=You have holstered an item. Holstered items can be quickly accessed by pressing Y again.&tl=EN-TW&client=tw-ob

		ChatMsg(playerid, GREEN, " > "C_WHITE" %s", ls(playerid, "tutorial/tip/weapon-holster"));

		IncreaseTutorialProgress(playerid, HOLSTER_WEAPON);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid) {
	if(IsPlayerInTutorial(playerid)) {
		IncreaseTutorialProgress(playerid, USE_ITEM_ON_ANOTHER_ITEM);

		ChatMsg(playerid, GREEN, " > "C_WHITE" %s", ls(playerid, "tutorial/tip/item-use-item"));
	}
}

hook OnTentBuilt(playerid, tentid) {
	if(IsPlayerInTutorial(playerid)) {
		IncreaseTutorialProgress(playerid, BUILD_TENT);

		ChatMsg(playerid, GREEN, " > "C_WHITE" %s", ls(playerid, "tutorial/tip/tent-built"));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemTweakFinish(playerid, itemid) {
	if(IsPlayerInTutorial(playerid)) {
		PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob", ls(playerid, "tutorial/tip/defence"), ls(playerid, "common/lang-shortcode")));

//		https://translate.google.com/translate_tts?ie=UTF-8&q=Acabamento da defesa finalizado. Instale um motor e depois um teclado em sua defesa.&tl=PT-TW&client=tw-ob
//		https://translate.google.com/translate_tts?ie=UTF-8&q=Finished defense finished. Install a motor and then a keyboard in your defense.&tl=EN-TW&client=tw-ob

		IncreaseTutorialProgress(playerid, FINISH_ITEM_TWEAK);

		ChatMsg(playerid, GREEN, " > "C_WHITE" %s", ls(playerid, "tutorial/tip/defence"));
	}
}

hook OnVehicleRepairStopped(playerid, vehicleid) {
	if(IsPlayerInTutorial(playerid)) {
		new Float:health;

		GetVehicleHealth(vehicleid, health);

		if(health >= VEHICLE_HEALTH_CHUNK_3) {
			IncreaseTutorialProgress(playerid, REPAIR_VEHICLE);
		}
	}
}

public OnPlayerProgressTutorial(playerid, stepscompleted) {
	printf("OnPlayerProgressTutorial(%d, %d)", playerid, stepscompleted);

	if(stepscompleted == MAX_TUTORIAL_STEPS) {
		HideRepairStatus(playerid);
		ExitTutorial(playerid);
	} else {
		// TODO: Fazer internacionalizacao
		new const steps[][] = {
			"Abrir Inventario",
			"Equipar Mochila",
			"Adicionar Item ao Inventario",
			"Abrir Opcoes do Inventario",
			"Abrir Mochila",
			"Adicionar Item a Mochila",
			"Abrir Opcoes da Mochila",
			"Dropar Item",
			"Colocar Arma no Coldre",
			"Construir Metal Corrugado",
			"Terminar Edicao da Defesa",
			"Montar Tenda",
			"Reparar Veiculo"
		};

		// Encontra a tarefa mais baixa que ainda nao foi completada
		new next_step = -1;
		for(new i = 0; i < MAX_TUTORIAL_STEPS; i++) {
			if(!Tutorial[playerid][TUT_STEPS][E_TUTORIAL_STEPS:i]) {
				next_step = i;
				break;
			}
		}

		// TODO: Fazer internacionalizacao
		// Dicas para cada tarefa/passo
		if(E_TUTORIAL_STEPS:next_step == USE_ITEM_ON_ANOTHER_ITEM) {
			ChatMsg(playerid, GREEN, " > Dica: "C_GOLD"Você acabou de interagir um item com outro. Em muitos momentos do jogo você usará essa função. Exemplo:");
			ChatMsg(playerid, GREEN, " > Dica: "C_GOLD"Carregar uma arma, craftings, construções, e diversas combinações de itens.");
		}

		PlayerTextDrawSetString(playerid, Tutorial[playerid][TUT_STATUS], sprintf("~b~Tarefa Atual ~y~(%d/%d)~w~:~n~%s", stepscompleted+1, MAX_TUTORIAL_STEPS, steps[next_step]));
	}
}

static IsStepCompleted(playerid, E_TUTORIAL_STEPS:step) return Tutorial[playerid][TUT_STEPS][step];

IncreaseTutorialProgress(playerid, E_TUTORIAL_STEPS:step) {
	if(!IsPlayerInTutorial(playerid)) return 0;
	if(IsStepCompleted(playerid, step)) return 0;

	// Limpa o chat
	for(new i = 0; i < 20; i++) SendClientMessage(playerid, WHITE, "");

	GameTextForPlayer(playerid, "Tarefa Concluida", 3000, 6);
	PlayerPlaySound(playerid, 5205, 0.0, 0.0, 0.0);

	Tutorial[playerid][TUT_STEPS][step] = true;

	// Calculate how many steps are completed
	new stepscompleted = 0;
	for(new s = 0; s < MAX_TUTORIAL_STEPS; s++) {
		if(IsStepCompleted(playerid, E_TUTORIAL_STEPS:s)) stepscompleted++;
	}

	CallLocalFunction("OnPlayerProgressTutorial", "ii", playerid, stepscompleted);

	return 1;
}

EnterTutorial(playerid) {
	if(IsPlayerInTutorial(playerid)) return;

	log("[TUTORIAL] %p (%d) entrou no tutorial.", playerid, playerid);
	
	new virtualworld = playerid + 1;

	// Um armazém vermelho em Las Venturas
	SetPlayerPos(playerid, 928.8049, 2072.3174, 10.8203);
	SetPlayerFacingAngle(playerid, 269.3244);
	SetPlayerVirtualWorld(playerid, virtualworld);

	PlayerTextDrawShow(playerid, Tutorial[playerid][TUT_STATUS]);

	// Define uma roupa aleatória
	new skin;
	switch(random(14))
	{
		case 0 : skin = skin_Civ0M;
		case 1 : skin = skin_Civ1M;
		case 2 : skin = skin_Civ2M;
		case 3 : skin = skin_Civ3M;
		case 4 : skin = skin_Civ4M;
		case 5 : skin = skin_MechM;
		case 6 : skin = skin_BikeM;
		case 7 : skin = skin_Civ0F;
		case 8 : skin = skin_Civ1F;
		case 9 : skin = skin_Civ2F;
		case 10: skin = skin_Civ3F;
		case 11: skin = skin_Civ4F;
		case 12: skin = skin_ArmyF;
		case 13: skin = skin_IndiF;
	}

	SetPlayerClothesID(playerid, skin);

	SetPlayerHP(playerid, 100.0);
	SetPlayerAP(playerid, 0.0);
	SetPlayerFP(playerid, 80.0);
	SetPlayerClothes(playerid, GetPlayerClothesID(playerid));
	SetPlayerGender(playerid, GetClothesGender(GetPlayerClothesID(playerid)));
	SetPlayerBleedRate(playerid, 0.0);

	SetPlayerAliveState(playerid, false);
	SetPlayerSpawnedState(playerid, false);

	FreezePlayer(playerid, SEC(3));
	PrepareForSpawn(playerid);

	Tutorial[playerid][TUT_VEHICLE] = CreateWorldVehicle(veht_Bobcat, 949.1641,2060.3074,10.8203, 272.1444, random(100), random(100), .world = virtualworld);
	SetVehicleHealth(Tutorial[playerid][TUT_VEHICLE], 321.9);
	SetVehicleFuel(Tutorial[playerid][TUT_VEHICLE], frandom(1.0));
	FillContainerWithLoot(GetVehicleContainer(Tutorial[playerid][TUT_VEHICLE]), 5, GetLootIndexFromName("world_civilian"));
	SetVehicleDamageData(Tutorial[playerid][TUT_VEHICLE],
		encode_panels(random(4), random(4), random(4), random(4), random(4), random(4), random(4)),
		encode_doors(random(5), random(5), random(5), random(5)),
		encode_lights(random(2), random(2), random(2), random(2)),
		encode_tires(0, 1, 1, 0)
	);

	// Portão bloqueando a entrada do galpão

	Tutorial[playerid][TUT_GATE_OBJ] = CreatePlayerObject(playerid, 971, 977.73792, 2073.38745, 10.37790,   0.00000, 0.00000, 90.00000, 300.0);

	//	Items
	new const Float:ITEM_Z = 9.8603, Float:PICKUP_Z_OFFSET = 1.7, Float:PICKUP_Z = ITEM_Z + PICKUP_Z_OFFSET;

	Tutorial[playerid][TUT_ITEMS][TUT_ITEM_CORPANEL][0]   = CreateItem(item_CorPanel, 973.7151, 2067.4258, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	Tutorial[playerid][TUT_PICKUPS][TUT_ITEM_CORPANEL][0] = CreatePickup(1559, 8, 973.7151, 2067.4258, PICKUP_Z, virtualworld);

	Tutorial[playerid][TUT_ITEMS][TUT_ITEM_CORPANEL][1]   = CreateItem(item_CorPanel, 973.7677, 2075.0117, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	Tutorial[playerid][TUT_PICKUPS][TUT_ITEM_CORPANEL][1] = CreatePickup(1559, 8, 973.7677, 2075.0117, PICKUP_Z, virtualworld);

	Tutorial[playerid][TUT_ITEMS][TUT_ITEM_CORPANEL][2]   = CreateItem(item_CorPanel, 975.1069, 2071.6677, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	Tutorial[playerid][TUT_PICKUPS][TUT_ITEM_CORPANEL][2] = CreatePickup(1559, 8, 975.1069, 2071.6677, PICKUP_Z, virtualworld);

	Tutorial[playerid][TUT_ITEMS][TUT_ITEM_CROWBAR]   = CreateItem(item_Crowbar, 947.3903, 2080.4143, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	Tutorial[playerid][TUT_PICKUPS][TUT_ITEM_CROWBAR] = CreatePickup(1559, 8, 947.3903, 2080.4143, PICKUP_Z, virtualworld);

	Tutorial[playerid][TUT_ITEMS][TUT_ITEM_GASCAN]   = CreateItem(item_GasCan, 938.4733, 2063.2769, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	Tutorial[playerid][TUT_PICKUPS][TUT_ITEM_GASCAN] = CreatePickup(1559, 8, 938.4733, 2063.2769, PICKUP_Z, virtualworld);

	Tutorial[playerid][TUT_ITEMS][TUT_ITEM_WRENCH]   = CreateItem(item_Wrench, 944.1250, 2067.6262, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	Tutorial[playerid][TUT_PICKUPS][TUT_ITEM_WRENCH] = CreatePickup(1559, 8, 944.1250, 2067.6262, PICKUP_Z, virtualworld);

	Tutorial[playerid][TUT_ITEMS][TUT_ITEM_HAMMER][1]   = CreateItem(item_Hammer, 949.4579, 2082.9829, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	Tutorial[playerid][TUT_PICKUPS][TUT_ITEM_HAMMER][1] = CreatePickup(1559, 8, 949.4579, 2082.9829, PICKUP_Z, virtualworld);

	Tutorial[playerid][TUT_ITEMS][TUT_ITEM_KEYPAD]   = CreateItem(item_Keypad, 971.9176, 2069.2117, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	Tutorial[playerid][TUT_PICKUPS][TUT_ITEM_KEYPAD] = CreatePickup(1559, 8, 971.9176, 2069.2117, PICKUP_Z, virtualworld);

	Tutorial[playerid][TUT_ITEMS][TUT_ITEM_LARGEBOX]   = CreateItem(item_LargeBox, 927.8030, 2058.6838, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	Tutorial[playerid][TUT_PICKUPS][TUT_ITEM_LARGEBOX] = CreatePickup(1559, 8, 927.8030, 2058.6838, PICKUP_Z, virtualworld);

	Tutorial[playerid][TUT_ITEMS][TUT_ITEM_MEDIUMBOX]   = CreateItem(item_MediumBox, 929.4532, 2058.3926, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	Tutorial[playerid][TUT_PICKUPS][TUT_ITEM_MEDIUMBOX] = CreatePickup(1559, 8, 929.4532, 2058.3926, PICKUP_Z, virtualworld);

	Tutorial[playerid][TUT_ITEMS][TUT_ITEM_MOTOR]   = CreateItem(item_Motor, 971.4994, 2072.1038, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	Tutorial[playerid][TUT_PICKUPS][TUT_ITEM_MOTOR] = CreatePickup(1559, 8, 971.4994, 2072.1038, PICKUP_Z, virtualworld);

	Tutorial[playerid][TUT_ITEMS][TUT_ITEM_PUMPSHOTGUN]   = CreateItem(item_PumpShotgun, 959.1787, 2082.9680, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	Tutorial[playerid][TUT_PICKUPS][TUT_ITEM_PUMPSHOTGUN] = CreatePickup(1559, 8, 959.1787, 2082.9680, PICKUP_Z, virtualworld);

	Tutorial[playerid][TUT_ITEMS][TUT_ITEM_RUCKSACK]   = CreateItem(item_Rucksack, 931.9263, 2081.7053, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	Tutorial[playerid][TUT_PICKUPS][TUT_ITEM_RUCKSACK] = CreatePickup(1559, 8, 931.9263, 2081.7053, PICKUP_Z, virtualworld);

	Tutorial[playerid][TUT_ITEMS][TUT_ITEM_HAMMER][0]   = CreateItem(item_Hammer, 946.4836, 2069.7207, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	Tutorial[playerid][TUT_PICKUPS][TUT_ITEM_HAMMER][0] = CreatePickup(1559, 8, 946.4836, 2069.7207, PICKUP_Z, virtualworld);

	Tutorial[playerid][TUT_ITEMS][TUT_ITEM_SMALLBOX]   = CreateItem(item_SmallBox, 931.4957, 2058.7312, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	Tutorial[playerid][TUT_PICKUPS][TUT_ITEM_SMALLBOX] = CreatePickup(1559, 8, 931.4957, 2058.7312, PICKUP_Z, virtualworld);

	Tutorial[playerid][TUT_ITEMS][TUT_ITEM_SPANNER]   = CreateItem(item_Spanner, 947.2153, 2067.1333, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	Tutorial[playerid][TUT_PICKUPS][TUT_ITEM_SPANNER] = CreatePickup(1559, 8, 947.2153, 2067.1333, PICKUP_Z, virtualworld);

	Tutorial[playerid][TUT_ITEMS][TUT_ITEM_TENT]   = CreateItem(item_TentPack, 944.1473, 2083.2739, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	Tutorial[playerid][TUT_PICKUPS][TUT_ITEM_TENT] = CreatePickup(1559, 8, 944.1473, 2083.2739, PICKUP_Z, virtualworld);

	Tutorial[playerid][TUT_ITEMS][TUT_ITEM_WHEEL][0]   = CreateItem(item_Wheel, 951.7727, 2068.0540, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	Tutorial[playerid][TUT_PICKUPS][TUT_ITEM_WHEEL][0] = CreatePickup(1559, 8, 951.7727, 2068.0540, PICKUP_Z, virtualworld);

	Tutorial[playerid][TUT_ITEMS][TUT_ITEM_WHEEL][1]   = CreateItem(item_Wheel, 952.7346, 2070.6902, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	Tutorial[playerid][TUT_PICKUPS][TUT_ITEM_WHEEL][1] = CreatePickup(1559, 8, 952.7346, 2070.6902, PICKUP_Z, virtualworld);

	Tutorial[playerid][TUT_ITEMS][TUT_ITEM_WHEEL][2]   = CreateItem(item_Wheel, 954.4612, 2068.2312, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	Tutorial[playerid][TUT_PICKUPS][TUT_ITEM_WHEEL][2] = CreatePickup(1559, 8, 954.4612, 2068.2312, PICKUP_Z, virtualworld);

	Tutorial[playerid][TUT_ITEMS][TUT_ITEM_SCREWDRIVER]   = CreateItem(item_Screwdriver, 971.1041, 2074.8508, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	Tutorial[playerid][TUT_PICKUPS][TUT_ITEM_SCREWDRIVER] = CreatePickup(1559, 8, 971.1041, 2074.8508, PICKUP_Z, virtualworld);

	// Municao para a arma
	SetItemWeaponItemMagAmmo(Tutorial[playerid][TUT_ITEMS][TUT_ITEM_PUMPSHOTGUN], 12);
	
	// Gasolina para o veiculo
	SetLiquidItemLiquidType(Tutorial[playerid][TUT_ITEMS][TUT_ITEM_GASCAN], liquid_Petrol);
	SetLiquidItemLiquidAmount(Tutorial[playerid][TUT_ITEMS][TUT_ITEM_GASCAN], 15);

	PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob", ls(playerid, "tutorial/intro"), ls(playerid, "common/lang-shortcode")));
//	https://translate.google.com/translate_tts?ie=UTF-8&q=Bem-vindo ao tutorial! Olhe ao redor e tente coisas. As mensagens de ajuda aparecerão aqui!&tl=PT-TW&client=tw-ob
//	https://translate.google.com/translate_tts?ie=UTF-8&q=Welcome to the tutorial! Look around and try things. Help messages will appear here!&tl=EN-TW&client=tw-ob

	for(new i = 0; i < 20; i++) SendClientMessage(playerid, WHITE, "");

	ChatMsg(playerid, GREEN, " > "C_WHITE" %s", ls(playerid, "tutorial/intro"));

	PlayerTextDrawShow(playerid, Tutorial[playerid][TUT_STATUS]);
}

ExitTutorial(playerid, bool:completed = true) {
	if(!IsPlayerInTutorial(playerid)) return 0;
		
	for(new i = INV_MAX_SLOTS - 1; i >= 0; i--) RemoveItemFromInventory(playerid, i);
	
	RemovePlayerBag(playerid);
	RemovePlayerHolsterItem(playerid);
	
	SetPlayerSpawnedState(playerid, false);
	SetPlayerAliveState(playerid, true);
	SetPlayerVirtualWorld(playerid, 0);

	// Resetar os passos do tutorial
	for(new step = 0; step < MAX_TUTORIAL_STEPS; step++) Tutorial[playerid][TUT_STEPS][E_TUTORIAL_STEPS:step] = false;

	// Destroi os itens e pickups do tutorial
	for(new i = 0; i < MAX_TUTORIAL_ITEMS; i++) {
		DestroyItem(Tutorial[playerid][TUT_ITEMS][E_TUTORIAL_ITEMS:i]);
		DestroyPickup(Tutorial[playerid][TUT_PICKUPS][E_TUTORIAL_ITEMS:i]);
	}

	// Destroi a tenda
	if(IsValidTent(Tutorial[playerid][TUT_ITEMS][TUT_ITEM_TENT]))
		DestroyTent(Tutorial[playerid][TUT_ITEMS][TUT_ITEM_TENT]);
		
	// Destroi o Bobcat
	DestroyWorldVehicle(Tutorial[playerid][TUT_VEHICLE], true);
	Tutorial[playerid][TUT_VEHICLE] = INVALID_VEHICLE_ID;

	// Destroi o Portao
	DestroyPlayerObject(playerid, Tutorial[playerid][TUT_GATE_OBJ]);
	Tutorial[playerid][TUT_GATE_OBJ] = INVALID_OBJECT_ID;

	if(completed) {
		log("[TUTORIAL] %p (%d) saiu do tutorial.", playerid, playerid);

		PlayerTextDrawDestroy(playerid, Tutorial[playerid][TUT_STATUS]);
		Tutorial[playerid][TUT_STATUS] = PlayerText:INVALID_TEXT_DRAW;
		
		ShowCharacterCreationScreen(playerid);

		PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob", ls(playerid, "tutorial/exit"), ls(playerid, "common/lang-shortcode")));
	//	https://translate.google.com/translate_tts?ie=UTF-8&q=Você saiu do tutorial, para voltar terá que morrer.&tl=PT-TW&client=tw-ob
	//	https://translate.google.com/translate_tts?ie=UTF-8&q=You left the tutorial, to return you will have to die.&tl=EN-TW&client=tw-ob

		// ! Eu já fiz uma função chamada ClearChat. Agora não sei em que branch ficou essa merda. Vou ter que procurar.
		for(new i = 0; i < 20; i++) SendClientMessage(playerid, GREEN, "");

		ChatMsg(playerid, GREEN, " > "C_WHITE" %s", ls(playerid, "tutorial/exit"));
	}

	CallLocalFunction("OnPlayerExitTutorial", "db", playerid, completed);

	return 1;
}

IsPlayerInTutorial(playerid) {
	if(!IsPlayerConnected(playerid)) return false; // ! Gambiarra mas pronto

	/* if(playerid >= Iter_Count(Player)) {
		log("IsPlayerInTutorial: playerid invalido (%d)", playerid);
		PrintAmxBacktrace();
		return false;
	} */

	return Tutorial[playerid][TUT_VEHICLE] != INVALID_VEHICLE_ID;
}

/* ACMD:settutorial[3](playerid, params[]) {
	new targetId;

	if(sscanf(params, "r", targetId)) return ChatMsg(playerid, YELLOW, " >  Use: /settutorial [id/nick]"); 

	if(targetId == INVALID_PLAYER_ID) return CMD_INVALID_PLAYER;

	if(GetPlayerAdminLevel(targetId)) return CMD_CANT_USE_ON;

	if(!IsPlayerLoggedIn(playerid)) return CMD_CANT_USE_ON;

	// Salva tudo do jogador primeiro
	Logout(playerid);
	EnterTutorial(targetId);

	return 1;
} */

public OnPlayerExitTutorial(playerid, bool:completed) {
	if(completed) {
		AnnouncePlayerJoined(playerid);
		ShowMotd(playerid);
	}
}

// Para os admins poderem sair do tutorial
CMD:exittutorial(playerid) {
	if(!IsPlayerInTutorial(playerid)) return CMD_NOT_ADMIN;

	if(IsPlayerAdmin(playerid)) ExitTutorial(playerid);
	
	return 1;
}