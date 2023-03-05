#include <YSI\y_hooks>

#define MAX_TUTORIAL_ITEMS      (22)

static
PlayerText:	ClassButtonTutorial		[MAX_PLAYERS],
PlayerText:	TutorialDraw			[MAX_PLAYERS],
bool:		PlayerInTutorial		[MAX_PLAYERS],
			PlayerTutorialProgress	[MAX_PLAYERS],
			PlayerTutorialVehicle	[MAX_PLAYERS],
			PlayerTutorial_Item     [MAX_TUTORIAL_ITEMS][MAX_PLAYERS],
			PlayerTutorial_Pickup   [MAX_TUTORIAL_ITEMS][MAX_PLAYERS],
bool:		PlayerTutorial_VozInv   [MAX_PLAYERS],
bool:		PlayerTutorial_VozCnt   [MAX_PLAYERS],
Timer:		PlayerTutorialUpd		[MAX_PLAYERS];

hook OnPlayerConnect(playerid)
{
	ClassButtonTutorial[playerid]	=CreatePlayerTextDraw(playerid, 320.000000, 300.000000, ls(playerid, "TUTORPROMPT"));
	PlayerTextDrawAlignment			(playerid, ClassButtonTutorial[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, ClassButtonTutorial[playerid], 255);
	PlayerTextDrawFont				(playerid, ClassButtonTutorial[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, ClassButtonTutorial[playerid], 0.45, 3.000000);
	PlayerTextDrawColor				(playerid, ClassButtonTutorial[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, ClassButtonTutorial[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, ClassButtonTutorial[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, ClassButtonTutorial[playerid], 1);
	PlayerTextDrawUseBox			(playerid, ClassButtonTutorial[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, ClassButtonTutorial[playerid], 255);
	PlayerTextDrawTextSize			(playerid, ClassButtonTutorial[playerid], 34.000000, 155.000000);
	PlayerTextDrawSetSelectable		(playerid, ClassButtonTutorial[playerid], true);
	PlayerTextDrawHide     			(playerid, ClassButtonTutorial[playerid]);

	TutorialDraw[playerid] = CreatePlayerTextDraw(playerid, 3.0, 327.0, "Play tutorial >");
	PlayerTextDrawLetterSize(playerid, TutorialDraw[playerid], 0.395, 1.58);
	PlayerTextDrawTextSize(playerid, TutorialDraw[playerid], 190.000000, 40.000000);
	PlayerTextDrawAlignment(playerid, TutorialDraw[playerid], 1);
	PlayerTextDrawColor(playerid, TutorialDraw[playerid], -1);
	PlayerTextDrawUseBox(playerid, TutorialDraw[playerid], 1);
	PlayerTextDrawBoxColor(playerid, TutorialDraw[playerid], 255);
	PlayerTextDrawSetShadow(playerid, TutorialDraw[playerid], 1);
	PlayerTextDrawSetOutline(playerid, TutorialDraw[playerid], 1);
	PlayerTextDrawFont(playerid, TutorialDraw[playerid], 1);
	PlayerTextDrawSetProportional(playerid, TutorialDraw[playerid], 1);

	PlayerTutorialProgress[playerid] = 0;
}

hook OnPlayerSpawnChar(playerid)
{
	dbg("global", CORE, "[OnPlayerSpawnChar] in /gamemodes/sss/core/player/tutorial.pwn");

	PlayerTextDrawHide(playerid, ClassButtonTutorial[playerid]);
	PlayerTextDrawHide(playerid, TutorialDraw[playerid]);
}

hook OnPlayerSpawnNewChar(playerid) {
	PlayerTextDrawHide(playerid, ClassButtonTutorial[playerid]);
	PlayerTextDrawHide(playerid, TutorialDraw[playerid]);
}

hook OnPlayerCreateChar(playerid) {
	PlayerTextDrawShow(playerid, ClassButtonTutorial[playerid]);
}

hook OnPlayerRegister(playerid) {
	EnterTutorial(playerid);
}

hook OnPlayerClickPlayerTD(playerid, PlayerText:playertextid)
{
	dbg("global", CORE, "[OnPlayerClickPlayerTD] in /gamemodes/sss/core/player/tutorial.pwn");

	dbg("gamemodes/sss/core/player/tutorial.pwn", 1, "[OnPlayerClickPlayerTD]");

	if(playertextid == ClassButtonTutorial[playerid])
	{
		EnterTutorial(playerid);

		// Esconde os textdraws de escolha
		PlayerTextDrawHide(playerid, ClassButtonMale[playerid]);
		PlayerTextDrawHide(playerid, ClassButtonFemale[playerid]);
		PlayerTextDrawHide(playerid, ClassButtonTutorial[playerid]);

		// Remove a tela preta
		SetPlayerBrightness(playerid, 255);
	}
}

timer UpdateTutorialProgress[1000](playerid)
{
	if(!PlayerInTutorial[playerid]) return 0;

	new str[190] = "____~y~Tarefas do Tutorial:~n~~n~", tentid, progress, Float:health, bool:active;

	if(IsValidItem(GetPlayerBagItem(playerid)))
		strcat(str, "~g~V Equipar Mochila~n~"), progress++;
	else
		strcat(str, "~r~X~w~ Equipar Mochila~n~");


	GetVehicleHealth(PlayerTutorialVehicle[playerid], health);
	if(health >= VEHICLE_HEALTH_CHUNK_3)
		strcat(str, "~g~V Reparar Veiculo~n~"), progress++;
	else
		strcat(str, "~r~X~w~ Reparar Veiculo~n~");


	GetItemExtraData(PlayerTutorial_Item[9][playerid]);
	if(IsValidTent(tentid))
		strcat(str, "~g~V Montar Tenda~n~"), progress++;
	else
		strcat(str, "~r~X~w~ Montar Tenda~n~");

	
	GetItemArrayDataAtCell(PlayerTutorial_Item[1][playerid], 0);
	if(active)
		strcat(str, "~g~V Montar Porta com Chave~n~"), progress ++;
	else
		strcat(str, "~r~X~w~ Montar Porta com Chave~n~");


	if(IsValidItem(GetPlayerHolsterItem(playerid)))
		strcat(str, "~g~V Colocar Arma no Coldre"), progress++;
	else
		strcat(str, "~r~X~w~ Colocar Arma no Coldre");

	if(progress == 5) {
	    GameTextForPlayer(playerid, "~G~~H~ TUTORIAL TERMINADO!", 3000, 1);
		ExitTutorial(playerid);
	} else
		PlayerTextDrawSetString(playerid, TutorialDraw[playerid], str);

	PlayerTutorialProgress[playerid] = progress;

	PlayerTextDrawShow(playerid, TutorialDraw[playerid]);

	return 0;
}

hook OnVehicleSave(vehicleid) {
	// Não salvar veículos do tutorial
	foreach(new i : Player) if(vehicleid == PlayerTutorialVehicle[i]) return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDeath(playerid)
{
	dbg("global", CORE, "[OnPlayerDeath] in /gamemodes/sss/core/player/tutorial.pwn");

	ExitTutorial(playerid);
}

hook OnPlayerDisconnect(playerid, reason)
{
	dbg("global", CORE, "[OnPlayerDisconnect] in /gamemodes/sss/core/player/tutorial.pwn");

	ExitTutorial(playerid);
}

EnterTutorial(playerid) {
	log("[TUTORIAL] %p (%d) entrou no tutorial.", playerid, playerid);
	
	new virtualworld = playerid + 1;

	// Um armazém vermelho em Las Venturas
	SetPlayerPos(playerid, 928.8049, 2072.3174, 10.8203);
	SetPlayerFacingAngle(playerid, 269.3244);
	SetPlayerVirtualWorld(playerid, virtualworld);
	// SetPlayerWorldBounds(playerid, 2054.0671, 2086.1921, 977.0759, 925.0547); // ? Caralho não sei como colocar correto

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

	FreezePlayer(playerid, gLoginFreezeTime * 1000);
	PrepareForSpawn(playerid);

	PlayerInTutorial[playerid] = true;
	
	PlayerTutorial_VozInv[playerid] = false;
	PlayerTutorial_VozCnt[playerid] = false;

	//	Vehicle
	PlayerTutorialVehicle[playerid] = CreateWorldVehicle(veht_Bobcat, 949.1641,2060.3074,10.8203, 272.1444, random(100), random(100), .world = virtualworld);
	SetVehicleHealth(PlayerTutorialVehicle[playerid], 321.9);
	SetVehicleFuel(PlayerTutorialVehicle[playerid], frandom(1.0));
	FillContainerWithLoot(GetVehicleContainer(PlayerTutorialVehicle[playerid]), 5, GetLootIndexFromName("world_civilian"));
	SetVehicleDamageData(PlayerTutorialVehicle[playerid],
		encode_panels(random(4), random(4), random(4), random(4), random(4), random(4), random(4)),
		encode_doors(random(5), random(5), random(5), random(5)),
		encode_lights(random(2), random(2), random(2), random(2)),
		encode_tires(0, 1, 1, 0)
	);

	//	Items
	new const Float:ITEM_Z = 9.8603, Float:PICKUP_Z_OFFSET = 1.7, Float:PICKUP_Z = ITEM_Z + PICKUP_Z_OFFSET;

	PlayerTutorial_Item[0][playerid]    = CreateItem(item_CorPanel, 975.1069,2071.6677, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	PlayerTutorial_Pickup[0][playerid]  = CreatePickup(1559, 8, 975.1069,2071.6677, PICKUP_Z, virtualworld);
	PlayerTutorial_Item[1][playerid]    = CreateItem(item_CorPanel, 973.7677,2075.0117, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	PlayerTutorial_Pickup[1][playerid]  = CreatePickup(1559, 8, 973.7677,2075.0117, PICKUP_Z, virtualworld);
	PlayerTutorial_Item[2][playerid]    = CreateItem(item_CorPanel, 973.7151,2067.4258, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	PlayerTutorial_Pickup[2][playerid]  = CreatePickup(1559, 8, 973.7151,2067.4258, PICKUP_Z, virtualworld);
	PlayerTutorial_Item[3][playerid]    = CreateItem(item_Wheel, 951.7727,2068.0540, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	PlayerTutorial_Pickup[3][playerid]  = CreatePickup(1559, 8, 951.7727,2068.0540, PICKUP_Z, virtualworld);
	PlayerTutorial_Item[4][playerid]    = CreateItem(item_Wheel, 954.4612,2068.2312, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	PlayerTutorial_Pickup[4][playerid]  = CreatePickup(1559, 8, 954.4612,2068.2312, PICKUP_Z, virtualworld);
	PlayerTutorial_Item[5][playerid]    = CreateItem(item_Wheel, 952.7346,2070.6902, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	PlayerTutorial_Pickup[5][playerid]  = CreatePickup(1559, 8, 952.7346,2070.6902, PICKUP_Z, virtualworld);
	PlayerTutorial_Item[6][playerid]    = CreateItem(item_Wrench, 948.3666,2069.8452, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	PlayerTutorial_Pickup[6][playerid]  = CreatePickup(1559, 8, 948.3666,2069.8452, PICKUP_Z, virtualworld);
	PlayerTutorial_Item[7][playerid]    = CreateItem(item_Screwdriver, 946.4836,2069.7207, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	PlayerTutorial_Pickup[7][playerid]  = CreatePickup(1559, 8, 946.4836,2069.7207, PICKUP_Z, virtualworld);
	PlayerTutorial_Item[8][playerid]    = CreateItem(item_Hammer, 944.1250,2067.6262, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	PlayerTutorial_Pickup[8][playerid]  = CreatePickup(1559, 8, 944.1250,2067.6262, PICKUP_Z, virtualworld);
	PlayerTutorial_Item[9][playerid]    = CreateItem(item_TentPack, 944.1473,2083.2739, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	PlayerTutorial_Pickup[9][playerid]  = CreatePickup(1559, 8, 944.1473,2083.2739, PICKUP_Z, virtualworld);
	PlayerTutorial_Item[10][playerid]   = CreateItem(item_Hammer, 949.4579,2082.9829, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	PlayerTutorial_Pickup[10][playerid] = CreatePickup(1559, 8, 949.4579,2082.9829, PICKUP_Z, virtualworld);
	PlayerTutorial_Item[11][playerid]   = CreateItem(item_Crowbar, 947.3903,2080.4143, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	PlayerTutorial_Pickup[11][playerid] = CreatePickup(1559, 8, 947.3903,2080.4143, PICKUP_Z, virtualworld);
	PlayerTutorial_Item[12][playerid]   = CreateItem(item_Crowbar, 951.6076,2067.8994, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	PlayerTutorial_Pickup[12][playerid] = CreatePickup(1559, 8, 951.6076,2067.8994, PICKUP_Z, virtualworld);
	PlayerTutorial_Item[13][playerid]   = CreateItem(item_Keypad, 971.9176,2069.2117, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	PlayerTutorial_Pickup[13][playerid] = CreatePickup(1559, 8, 971.9176,2069.2117, PICKUP_Z, virtualworld);
	PlayerTutorial_Item[14][playerid]   = CreateItem(item_Motor, 971.4994,2072.1038, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	PlayerTutorial_Pickup[14][playerid] = CreatePickup(1559, 8, 971.4994,2072.1038, PICKUP_Z, virtualworld);
	PlayerTutorial_Item[15][playerid]   = CreateItem(item_Rucksack, 931.9263,2081.7053, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	PlayerTutorial_Pickup[15][playerid] = CreatePickup(1559, 8, 931.9263,2081.7053, PICKUP_Z, virtualworld);
	PlayerTutorial_Item[16][playerid]   = CreateItem(item_LargeBox, 927.8030,2058.6838, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	PlayerTutorial_Pickup[16][playerid] = CreatePickup(1559, 8, 927.8030,2058.6838, PICKUP_Z, virtualworld);
	PlayerTutorial_Item[17][playerid]   = CreateItem(item_MediumBox, 929.4532,2058.3926, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	PlayerTutorial_Pickup[17][playerid] = CreatePickup(1559, 8, 929.4532,2058.3926, PICKUP_Z, virtualworld);
	PlayerTutorial_Item[18][playerid]   = CreateItem(item_SmallBox, 932.5464,2058.3267, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	PlayerTutorial_Pickup[18][playerid] = CreatePickup(1559, 8, 932.5464,2058.3267, PICKUP_Z, virtualworld);
	PlayerTutorial_Item[19][playerid]   = CreateItem(item_PumpShotgun, 959.1787,2082.9680, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	PlayerTutorial_Pickup[19][playerid] = CreatePickup(1559, 8, 959.1787,2082.9680, PICKUP_Z, virtualworld);

	// Shotgun?
	PlayerTutorial_Item[20][playerid]   = CreateItem(item_AmmoBuck, 961.2108,2083.3938, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	SetItemWeaponItemMagAmmo(PlayerTutorial_Item[20][playerid], 12);
	PlayerTutorial_Pickup[20][playerid] = CreatePickup(1559, 8, 961.2108,2083.3938, PICKUP_Z, virtualworld);
	
	// Galão de Gasolina
	PlayerTutorial_Item[21][playerid]   = CreateItem(item_GasCan, 938.4733,2063.2769, ITEM_Z, .rz = frandom(360.0), .world = virtualworld);
	SetLiquidItemLiquidType(PlayerTutorial_Item[21][playerid], liquid_Petrol);
	SetLiquidItemLiquidAmount(PlayerTutorial_Item[21][playerid], 15);
	PlayerTutorial_Pickup[21][playerid] = CreatePickup(1559, 8, 938.4733,2063.2769, PICKUP_Z, virtualworld);

	PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob", ls(playerid, "TUTORINTROD"), ls(playerid, "IDIOMAID")));
//	https://translate.google.com/translate_tts?ie=UTF-8&q=Bem-vindo ao tutorial! Olhe ao redor e tente coisas. As mensagens de ajuda aparecerão aqui!&tl=PT-TW&client=tw-ob
//	https://translate.google.com/translate_tts?ie=UTF-8&q=Welcome to the tutorial! Look around and try things. Help messages will appear here!&tl=EN-TW&client=tw-ob

	for(new i = 0; i < 20; i++) SendClientMessage(playerid, GREEN, "");

	ChatMsg(playerid, WHITE, ""C_GREEN"> "C_WHITE" %s", ls(playerid, "TUTORINTROD"));

	stop PlayerTutorialUpd[playerid];
	PlayerTutorialUpd[playerid] = repeat UpdateTutorialProgress(playerid);
}

ExitTutorial(playerid)
{
	if(!PlayerInTutorial[playerid]) return 0;

	log("[TUTORIAL] %p (%d) saiu do tutorial.", playerid, playerid);

	SetPlayerWorldBounds(playerid, 20000.0000, -20000.0000, 20000.0000, -20000.0000);

	stop PlayerTutorialUpd[playerid];
	PlayerTextDrawHide(playerid, TutorialDraw[playerid]);
		
	for(new i = INV_MAX_SLOTS - 1; i >= 0; i--) RemoveItemFromInventory(playerid, i);
	
	RemovePlayerBag(playerid);
	RemovePlayerHolsterItem(playerid);
	
	PlayerInTutorial[playerid] = false;
	SetPlayerSpawnedState(playerid, false);
	SetPlayerAliveState(playerid, true);
	SetPlayerVirtualWorld(playerid, 0);
	
	PlayerCreateNewCharacter(playerid);
	SetPlayerBrightness(playerid, 255);

	// Destroi os itens e pickups do tutorial
	for(new i = 0; i < MAX_TUTORIAL_ITEMS; i++) {
		DestroyItem(PlayerTutorial_Item[i][playerid]);
		DestroyPickup(PlayerTutorial_Pickup[i][playerid]);
	}
		
	DestroyWorldVehicle(PlayerTutorialVehicle[playerid]);
	PlayerTutorialVehicle[playerid] = INVALID_VEHICLE_ID;

	PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob", ls(playerid, "TUTORIEXIT"), ls(playerid, "IDIOMAID")));
//	https://translate.google.com/translate_tts?ie=UTF-8&q=Você saiu do tutorial, para voltar terá que morrer.&tl=PT-TW&client=tw-ob
//	https://translate.google.com/translate_tts?ie=UTF-8&q=You left the tutorial, to return you will have to die.&tl=EN-TW&client=tw-ob

	// ! Eu já fiz uma função chamada ClearChat. Agora não sei em que branch ficou essa merda. Vou ter que procurar.
	for(new i = 0; i < 20; i++) SendClientMessage(playerid, GREEN, "");

	return ChatMsg(playerid, WHITE, ""C_GREEN"> "C_WHITE" %s", ls(playerid, "TUTORIEXIT"));
}

hook OnPlayerWearBag(playerid, itemid)
{
	dbg("global", CORE, "[OnPlayerWearBag] in /gamemodes/sss/core/player/tutorial.pwn");

	if(PlayerInTutorial[playerid])
	{
		PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob", ls(playerid, "TUTORACCBAG"), ls(playerid, "IDIOMAID")));
//		https://translate.google.com/translate_tts?ie=UTF-8&q=Você pode acessar sua mochila pressionando H e clicando no ícone Mochila na parte inferior direita.&tl=PT-TW&client=tw-ob
//		https://translate.google.com/translate_tts?ie=UTF-8&q=You can access your bag by pressing H and clicking the Bag icon at the bottom right.&tl=EN-TW&client=tw-ob

  		for(new i = 0; i < 20; i++) SendClientMessage(playerid, GREEN, "");
		
		ChatMsg(playerid, WHITE, ""C_GREEN"> "C_WHITE" %s", ls(playerid, "TUTORACCBAG"));
	}

	return 0;
}

hook OnPlayerOpenInventory(playerid)
{
	dbg("global", CORE, "[OnPlayerOpenInventory] in /gamemodes/sss/core/player/tutorial.pwn");

	if(PlayerInTutorial[playerid])
	{
	    if(!PlayerTutorial_VozInv[playerid])
	    {
	    	PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?&q=%s&tl=%s-TW&client=tw-ob",
				GetLanguageString(playerid, "TUTORINTINV", true), GetLanguageString(playerid, "IDIOMAID", true)));

//			https://translate.google.com/translate_tts?ie=UTF-8&q=Este é o seu inventário. Também conhecido como seus bolsos. Esta não é sua mochila.&tl=PT-TW&client=tw-ob
//			https://translate.google.com/translate_tts?ie=UTF-8&q=This is your character inventory also known as your pockets. This is not your bag.&tl=EN-TW&client=tw-ob

            PlayerTutorial_VozInv[playerid] = true;
		}

  		for(new i = 0; i < 20; i++) SendClientMessage(playerid, GREEN, "");
			
		ChatMsg(playerid, WHITE, ""C_GREEN"> "C_WHITE" %s", ls(playerid, "TUTORINTINV"));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerOpenContainer(playerid, containerid)
{
	dbg("global", CORE, "[OnPlayerOpenContainer] in /gamemodes/sss/core/player/tutorial.pwn");

	if(PlayerInTutorial[playerid])
	{
		if(containerid == GetItemArrayDataAtCell(GetPlayerBagItem(playerid), 1))
		{
		    if(!PlayerTutorial_VozCnt[playerid])
		    {
  				PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob", ls(playerid, "TUTORINTBAG"), ls(playerid, "IDIOMAID")));
//				https://translate.google.com/translate_tts?ie=UTF-8&q=Esta é a sua Mochila. Elas são armazenamento extra. Existem muitos tipos diferentes de mochilas com tamanhos diferentes.&tl=PT-TW&client=tw-ob
//				https://translate.google.com/translate_tts?ie=UTF-8&q=This is your bag. Bags are extra storage. There are many different types of bags with different sizes.&tl=EN-TW&client=tw-ob

                PlayerTutorial_VozCnt[playerid] = true;
			}
			
  			for(new i = 0; i < 20; i++) SendClientMessage(playerid, GREEN, "");
			
			ChatMsg(playerid, WHITE, ""C_GREEN"> "C_WHITE" %s", ls(playerid, "TUTORINTBAG"));
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerViewCntOpt(playerid, containerid)
{
	dbg("global", CORE, "[OnPlayerViewCntOpt] in /gamemodes/sss/core/player/tutorial.pwn");

	if(PlayerInTutorial[playerid])
	{
		if(GetItemType(GetContainerSlotItem(containerid, GetPlayerContainerSlot(playerid))) == item_Wrench)
		{
  			PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob",
				ls(playerid, "TUTORITMOPT"), ls(playerid, "IDIOMAID")));

//			https://translate.google.com/translate_tts?ie=UTF-8&q=Estas são suas opções para o item selecionado. Equipar coloca em sua mão.&tl=PT-TW&client=tw-ob
//			https://translate.google.com/translate_tts?ie=UTF-8&q=These are your options for the selected item. Equip puts it in your hand. Combine can be selected on multiple items to attempt to combine them.&tl=EN-TW&client=tw-ob

  			for(new i = 0; i < 20; i++) SendClientMessage(playerid, GREEN, "");

			ChatMsg(playerid, WHITE, ""C_GREEN"> "C_WHITE" %s", ls(playerid, "TUTORITMOPT"));
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDroppedItem(playerid, itemid)
{
	dbg("global", CORE, "[OnPlayerDroppedItem] in /gamemodes/sss/core/player/tutorial.pwn");

	if(PlayerInTutorial[playerid])
	{
		PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob",
			ls(playerid, "TUTORDROITM"), ls(playerid, "IDIOMAID")));

//		https://translate.google.com/translate_tts?ie=UTF-8&q=Quando você soltar um item, outros jogadores podem pegá-lo.&tl=PT-TW&client=tw-ob
//		https://translate.google.com/translate_tts?ie=UTF-8&q=When you drop an item, other players can pick it up.&tl=EN-TW&client=tw-ob


		for(new i = 0; i < 20; i++) SendClientMessage(playerid, GREEN, "");

		ChatMsg(playerid, WHITE, ""C_GREEN"> "C_WHITE" %s", ls(playerid, "TUTORDROITM"));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemAddedToInventory(playerid, itemid, slot)
{
	dbg("global", CORE, "[OnItemAddedToInventory] in /gamemodes/sss/core/player/tutorial.pwn");

	if(PlayerInTutorial[playerid])
	{
		PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob",
			ls(playerid, "TUTORINVADD"), ls(playerid, "IDIOMAID")));

//		https://translate.google.com/translate_tts?ie=UTF-8&q=Você adicionou um item ao seu inventário. Se o seu inventário estiver cheio, o item será colocado na sua Mochila.&tl=PT-TW&client=tw-ob
//		https://translate.google.com/translate_tts?ie=UTF-8&q=You added an item to your inventory. If your inventory is full, the item will be put in your bag.&tl=EN-TW&client=tw-ob

		for(new i = 0; i < 20; i++) SendClientMessage(playerid, GREEN, "");

		ChatMsg(playerid, WHITE, ""C_GREEN"> "C_WHITE" %s", ls(playerid, "TUTORINVADD"));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerViewInvOpt(playerid)
{
	dbg("global", CORE, "[OnPlayerViewInvOpt] in /gamemodes/sss/core/player/tutorial.pwn");

	if(PlayerInTutorial[playerid])
	{
		PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob",
			ls(playerid, "TUTORITMOPT"), ls(playerid, "IDIOMAID")));

//		https://translate.google.com/translate_tts?ie=UTF-8&q=Estas são suas opções para o item selecionado. Equipar coloca em sua mão.&tl=PT-TW&client=tw-ob
//		https://translate.google.com/translate_tts?ie=UTF-8&q=These are your options for the selected item. Equip puts it in your hand. Combine can be selected on multiple items to attempt to combine them.&tl=EN-TW&client=tw-ob

		for(new i = 0; i < 20; i++) SendClientMessage(playerid, GREEN, "");

		ChatMsg(playerid, WHITE, ""C_GREEN"> "C_WHITE" %s", ls(playerid, "TUTORITMOPT"));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemAddedToContainer(containerid, itemid, playerid)
{
	dbg("global", CORE, "[OnItemAddedToContainer] in /gamemodes/sss/core/player/tutorial.pwn");

	if(IsPlayerConnected(playerid))
	{
		if(PlayerInTutorial[playerid])
		{
			if(containerid == GetItemArrayDataAtCell(GetPlayerBagItem(playerid), 1))
			{
 				PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob",
					ls(playerid, "TUTORADDBAG"), ls(playerid, "IDIOMAID")));

//				https://translate.google.com/translate_tts?ie=UTF-8&q=Você adicionou um item a sua mochila. Você pode acessar sua mochila pressionando H e clicando no ícone Mochila na parte inferior direita.&tl=PT-TW&client=tw-ob
//				https://translate.google.com/translate_tts?ie=UTF-8&q=You added an item to your bag. You can access your bag by pressing H and clicking the Bag icon at the bottom right.&tl=EN-TW&client=tw-ob

				for(new i = 0; i < 20; i++) SendClientMessage(playerid, GREEN, "");

				ChatMsg(playerid, WHITE, ""C_GREEN"> "C_WHITE" %s", ls(playerid, "TUTORADDBAG"));
			}
			else
			{
 				PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob",
					ls(playerid, "TUTORADDCNT"), ls(playerid, "IDIOMAID")));

//				https://translate.google.com/translate_tts?ie=UTF-8&q=Você adicionou um item a um container. Os containeres são lugares para armazenar itens&tl=PT-TW&client=tw-ob
//				https://translate.google.com/translate_tts?ie=UTF-8&q=You added an item to a container. Containers are places to store items &tl=EN-TW&client=tw-ob

				for(new i = 0; i < 20; i++) SendClientMessage(playerid, GREEN, "");

				ChatMsg(playerid, WHITE, ""C_GREEN"> "C_WHITE" %s", ls(playerid, "TUTORADDCNT"));
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerHolsteredItem(playerid, itemid)
{
	dbg("global", CORE, "[OnPlayerHolsteredItem] in /gamemodes/sss/core/player/tutorial.pwn");

	if(PlayerInTutorial[playerid])
	{
		PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob",
			ls(playerid, "TUTORITMHOL"), ls(playerid, "IDIOMAID")));

//		https://translate.google.com/translate_tts?ie=UTF-8&q=Você colocou um item no coldre. Os itens no coldre podem ser rapidamente acessados pressionando Y novamente.&tl=PT-TW&client=tw-ob
//		https://translate.google.com/translate_tts?ie=UTF-8&q=You have holstered an item. Holstered items can be quickly accessed by pressing Y again.&tl=EN-TW&client=tw-ob

		for(new i = 0; i < 20; i++) SendClientMessage(playerid, GREEN, "");

		ChatMsg(playerid, WHITE, ""C_GREEN"> "C_WHITE" %s", ls(playerid, "TUTORITMHOL"));
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	dbg("global", CORE, "[OnPlayerUseItemWithItem] in /gamemodes/sss/core/player/tutorial.pwn");

	if(PlayerInTutorial[playerid])
	{
		for(new i = 0; i < 20; i++) SendClientMessage(playerid, GREEN, "");

		ChatMsg(playerid, WHITE, ""C_GREEN"> "C_WHITE" %s", ls(playerid, "TUTORITMUSE"));
	}
}

hook OnItemTweakFinish(playerid, itemid)
{
	if(PlayerInTutorial[playerid])
	{
		PlayAudioStreamForPlayer(playerid, sprintf("https://translate.google.com/translate_tts?ie=UTF-8&q=%s&tl=%s-TW&client=tw-ob",
			ls(playerid, "TUTORIDEF"), ls(playerid, "IDIOMAID")));

//		https://translate.google.com/translate_tts?ie=UTF-8&q=Acabamento da defesa finalizado. Instale um motor e depois um teclado em sua defesa.&tl=PT-TW&client=tw-ob
//		https://translate.google.com/translate_tts?ie=UTF-8&q=Finished defense finished. Install a motor and then a keyboard in your defense.&tl=EN-TW&client=tw-ob

		for(new i = 0; i < 20; i++) SendClientMessage(playerid, GREEN, "");

		ChatMsg(playerid, WHITE, ""C_GREEN"> "C_WHITE" %s", ls(playerid, "TUTORIDEF"));
	}
}

stock IsPlayerInTutorial(playerid) return PlayerInTutorial[playerid] ? 1 : 0;

// Para os admins poderem sair do tutorial
CMD:exittutorial(playerid)
{
	if(!IsPlayerInTutorial(playerid)) return 0;

	if(IsPlayerAdmin(playerid) || GetPlayerAdminLevel(playerid) > 4) ExitTutorial(playerid);
	
	return 1;
}