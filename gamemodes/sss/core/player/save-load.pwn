#include <YSI\y_hooks>

#define DIRECTORY_PLAYER			DIRECTORY_MAIN"player/"
#define PLAYER_DATA_FILE			DIRECTORY_PLAYER"%s.dat"
#define PLAYER_DAT_FILE(%0,%1)		format(%1, MAX_PLAYER_FILE, PLAYER_DATA_FILE, %0)
#define CHARACTER_DATA_FILE_VERSION	(10)
#define MAX_BAG_CONTAINER_SIZE		(20)

static saveload_Loaded[MAX_PLAYERS];

static enum {
	FILE_VERSION,
	HEALTH,
	ARMOUR,
	FOOD,
	SKIN,
	HAT,
	HOLST,
	HOLSTEX,
	HELD,
	HELDEX,
	STANCE,
	BLEEDING,
	CUFFED,
	WARNS,
	CHATMODE,
	UNUSED,
	TOOLTIPS,
	SPAWN_X,
	SPAWN_Y,
	SPAWN_Z,
	SPAWN_R,
	MASK,
	MUTE_TIME,
	KNOCKOUT,
	BAGTYPE,
	END
}


forward OnPlayerSave(playerid, filename[]);
forward OnPlayerLoad(playerid, filename[]);


hook OnGameModeInit() {
	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_PLAYER);
}

hook OnPlayerConnect(playerid) {
	saveload_Loaded[playerid] = false;
}

SavePlayerChar(playerid) {
	if(IsPlayerOnAdminDuty(playerid)) return 0;

	new
		filename[MAX_PLAYER_FILE],
		session,
		data[ITM_ARR_MAX_ARRAY_DATA + 6],
		animidx = GetPlayerAnimationIndex(playerid),
		itemid,
		items[MAX_BAG_CONTAINER_SIZE],
		itemcount;

	PLAYER_DAT_FILE(GetPlayerNameEx(playerid), filename);

	session = modio_getsession_write(filename);

	if(session != -1) modio_close_session_write(session);

/*
	Character
*/

	data[HEALTH]	= _:GetPlayerHP(playerid);
	data[ARMOUR]	= _:GetPlayerAP(playerid);
	data[FOOD]		= _:GetPlayerFP(playerid);
	data[SKIN]		= GetPlayerClothes(playerid);
	data[HAT]		= _:GetItemType(GetPlayerHatItem(playerid));

	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_DUCK)
		data[STANCE] = 1;
	else if(animidx == 43)
		data[STANCE] = 2;
	else if(animidx == 1381)
		data[STANCE] = 3;

	data[BLEEDING] = _:GetPlayerBleedRate(playerid);
	data[CUFFED]   = (GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_CUFFED);
	data[WARNS]    = GetPlayerWarnings(playerid);
	data[CHATMODE] = GetPlayerChatMode(playerid);
	data[TOOLTIPS] = IsPlayerToolTipsOn(playerid);

	if(GetPlayerInterior(playerid) == 0)
		GetPlayerPos(playerid, Float:data[SPAWN_X], Float:data[SPAWN_Y], Float:data[SPAWN_Z]);
/*	else
	    int_GetPlayerPos(playerid, Float:data[SPAWN_X], Float:data[SPAWN_Y], Float:data[SPAWN_Z]);*/
	    
	GetPlayerFacingAngle(playerid, Float:data[SPAWN_R]);

	data[MASK]      = _:GetItemType(GetPlayerMaskItem(playerid));
	data[MUTE_TIME] = GetPlayerMuteRemainder(playerid);
	data[KNOCKOUT]  = GetPlayerKnockOutRemainder(playerid);

	if(IsValidItem(GetPlayerBagItem(playerid)))
		data[BAGTYPE] = _:GetItemType(GetPlayerBagItem(playerid));

	modio_push(filename, _T<C,H,A,R>, END, data);

/*
	Held item
*/

	itemid = GetPlayerItem(playerid);

	if(IsValidItem(itemid)) {
		data[0] = _:GetItemType(itemid);
		data[1] = GetItemArrayDataSize(itemid);
		GetItemArrayData(itemid, data[2]);
		modio_push(filename, _T<H,E,L,D>, 2 + data[1], data);
	} else {
		data[0] = -1;
		modio_push(filename, _T<H,E,L,D>, 1, data);
	}

/*
	Holstered item
*/

	itemid = GetPlayerHolsterItem(playerid);

	if(IsValidItem(itemid)) {
		data[0] = _:GetItemType(itemid);
		data[1] = GetItemArrayDataSize(itemid);
		GetItemArrayData(itemid, data[2]);
		modio_push(filename, _T<H,O,L,S>, 2 + data[1], data);
	} else {
		data[0] = -1;
		modio_push(filename, _T<H,O,L,S>, 1, data);
	}

/*
	Inventory
*/

	for(new i; i < INV_MAX_SLOTS; i++) {
		items[i] = GetInventorySlotItem(playerid, i);

		if(!IsValidItem(items[i])) break;

		itemcount++;
	}

	if(!SerialiseItems(items, itemcount)) {
		modio_push(filename, _T<I,N,V,0>, GetSerialisedSize(), itm_arr_Serialized);
		ClearSerializer();
	}

/*
	Bag
*/

	itemcount = 0;

	if(IsValidItem(GetPlayerBagItem(playerid))) {
		new containerid = GetBagItemContainerID(GetPlayerBagItem(playerid));

		for(new i, j = GetContainerSize(containerid); i < j && i < MAX_BAG_CONTAINER_SIZE; i++) {
			items[i] = GetContainerSlotItem(containerid, i);

			if(!IsValidItem(items[i])) break;

			itemcount++;
		}

		if(!SerialiseItems(items, itemcount)) {
			modio_push(filename, _T<B,A,G,0>, GetSerialisedSize(), itm_arr_Serialized);
			ClearSerializer();
		}
	}

	CallLocalFunction("OnPlayerSave", "ds", playerid, filename);

	return 1;
}

LoadPlayerChar(playerid) {
	new
		filename[MAX_PLAYER_FILE],
		data[ITM_ARR_MAX_ARRAY_DATA + 6],
		ItemType:itemtype,
		itemid,
		length;

	PLAYER_DAT_FILE(GetPlayerNameEx(playerid), filename);

	length = modio_read(filename, _T<C,H,A,R>, sizeof(data), data);

	if(length == 0) return 0;

	//	Character
	if(Float:data[HEALTH] <= 0.0) data[HEALTH] = _:1.0;

	SetPlayerHP(playerid, Float:data[HEALTH]);
	SetPlayerAP(playerid, Float:data[ARMOUR]);
	SetPlayerFP(playerid, Float:data[FOOD]);
	SetPlayerClothesID(playerid, data[SKIN]);
	SetPlayerClothes(playerid, data[SKIN]);

	if(IsValidItemType(ItemType:data[HAT])) SetPlayerHatItem(playerid, CreateItem(ItemType:data[HAT]));

	if(GetPlayerAP(playerid) > 0.0) CreatePlayerArmour(playerid);

	if(GetPlayerSkin(playerid) == 287) EquipCamou(playerid);

/*
	Legacy code for old held/holstered item format. Depreciated because it only
	stores 1 cell of data (extradata) with items. These items are now stored in
	separate modio tags so the full array data is stored with them.
*/

	if(data[HELD] > 0) {
		itemid = CreateItem(ItemType:data[HELD]);

		if(!IsItemTypeExtraDataDependent(ItemType:data[HELD])) SetItemExtraData(itemid, data[HELDEX]);

		if(0 < data[HELD] < WEAPON_PARACHUTE) {
			new ItemType:ammotype[1];

			// Get the first ammo item type for this weapon's calibre.
			GetAmmoItemTypesOfCalibre(GetItemTypeWeaponCalibre(ItemType:data[HELD]), ammotype, 1);

			if(IsValidItemType(ammotype[0])) {
				SetItemWeaponItemAmmoItem(itemid, ammotype[0]);
				SetItemWeaponItemMagAmmo(itemid, 0);
				SetItemWeaponItemReserve(itemid, 0);
				AddAmmoToWeapon(itemid, data[HELDEX]);
			}
		}

		GiveWorldItemToPlayer(playerid, itemid);
	}

	if(data[HOLST] > 0) {
		itemid = CreateItem(ItemType:data[HOLST]);

		if(!IsItemTypeExtraDataDependent(ItemType:data[HOLST])) SetItemExtraData(itemid, data[HOLSTEX]);

		if(0 < data[HOLST] < WEAPON_PARACHUTE) {
			new ItemType:ammotype[1];

			GetAmmoItemTypesOfCalibre(GetItemTypeWeaponCalibre(ItemType:data[HOLST]), ammotype, 1);

			if(IsValidItemType(ammotype[0])) {
				SetItemWeaponItemAmmoItem(itemid, ammotype[0]);
				SetItemWeaponItemMagAmmo(itemid, 0);
				SetItemWeaponItemReserve(itemid, 0);
				AddAmmoToWeapon(itemid, data[HOLSTEX]);
			}
		}

		SetPlayerHolsterItem(playerid, itemid);
	}

	if(data[BLEEDING] == 1) data[BLEEDING] = _:Float:0.01;

	if(Float:data[BLEEDING] > 1.0) data[BLEEDING] = _:(Float:data[BLEEDING] / 10.0);

	SetPlayerStance(playerid, data[STANCE]);
	SetPlayerBleedRate(playerid, Float:data[BLEEDING]);
	SetPlayerCuffs(playerid, data[CUFFED]);
	SetPlayerWarnings(playerid, data[WARNS]);
	SetPlayerChatMode(playerid, data[CHATMODE]);
	SetPlayerToolTips(playerid, bool:data[TOOLTIPS]);
	SetPlayerSpawnPos(playerid, Float:data[SPAWN_X], Float:data[SPAWN_Y], Float:data[SPAWN_Z]);
	SetPlayerSpawnRot(playerid, Float:data[SPAWN_R]);

	if(IsValidItemType(ItemType:data[MASK])) SetPlayerMaskItem(playerid, CreateItem(ItemType:data[MASK]));

	if(data[MUTE_TIME] != 0)
		TogglePlayerMute(playerid, true, data[MUTE_TIME]);
	else
		TogglePlayerMute(playerid, false);

	if(data[KNOCKOUT] > 0) KnockOutPlayer(playerid, data[KNOCKOUT]);

	if(IsItemTypeBag(ItemType:data[BAGTYPE])) GivePlayerBag(playerid, CreateItem(ItemType:data[BAGTYPE], 0.0, 0.0, 0.0));
	
	SetPlayerVirtualWorld(playerid, 0);
	SetPlayerInterior(playerid, 0);

	//	Held item
	data[0] = -1;

	length = modio_read(filename, _T<H,E,L,D>, sizeof(data), data);

	if(IsValidItemType(ItemType:data[0]) && length > 0) {
		itemid = AllocNextItemID(ItemType:data[0]);
		SetItemNoResetArrayData(itemid, true);
		SetItemArrayData(itemid, data[2], data[1]);
		CreateItem_ExplicitID(itemid);
		GiveWorldItemToPlayer(playerid, itemid);
	}

	//	Holstered item
	data[0] = -1;

	length = modio_read(filename, _T<H,O,L,S>, sizeof(data), data);

	if(IsValidItemType(ItemType:data[0]) && length > 0) {
		itemid = AllocNextItemID(ItemType:data[0]);
		SetItemNoResetArrayData(itemid, true);
		SetItemArrayData(itemid, data[2], data[1]);
		CreateItem_ExplicitID(itemid);
		SetPlayerHolsterItem(playerid, itemid);
	}

	//	Inventory
	length = modio_read(filename, _T<I,N,V,0>, ITEM_SERIALIZER_RAW_SIZE, itm_arr_Serialized);

	if(!DeserialiseItems(itm_arr_Serialized, length, false)) {
		for(new i, j = GetStoredItemCount(); i < j; i++) {
			itemtype = GetStoredItemType(i);

			if(length == 0) break;

			if(itemtype == INVALID_ITEM_TYPE) break;

			if(itemtype == ItemType:0) break;

			itemid = CreateItem(itemtype, .virtual = 1);

			if(!IsItemTypeSafebox(itemtype) && !IsItemTypeBag(itemtype)) SetItemArrayDataFromStored(itemid, i);

			AddItemToInventory(playerid, itemid, 0);
		}

		ClearSerializer();
	}

	//	Bag
	if(IsItemTypeBag(ItemType:data[BAGTYPE])) {
		length = modio_read(filename, _T<B,A,G,0>, ITEM_SERIALIZER_RAW_SIZE, itm_arr_Serialized);

		if(!DeserialiseItems(itm_arr_Serialized, length, false)) {
			new containerid = GetBagItemContainerID(GetPlayerBagItem(playerid));

			for(new i, j = GetStoredItemCount(); i < j; i++) {
				itemtype = GetStoredItemType(i);
				itemid = CreateItem(itemtype, .virtual = 1);

				if(!IsItemTypeSafebox(itemtype) && !IsItemTypeBag(itemtype))
					SetItemArrayDataFromStored(itemid, i);

				AddItemToContainer(containerid, itemid);
			}

			ClearSerializer();
		}
	}

	CallLocalFunction("OnPlayerLoad", "ds", playerid, filename);

	saveload_Loaded[playerid] = true;

	return 1;
}

//	Gamemode exit fix for modio
hook OnScriptExit() {
	new
		filename[64],
		session;

	log("Closing open modio sessions for player data.");

	foreach(new i : Player) {
		PLAYER_DAT_FILE(GetPlayerNameEx(i), filename);

		session = modio_getsession_write(filename);

		log("- Closing file '%s' for playerid: %d (session: %d)", filename, i, session);

		if(session != -1) modio_finalise_write(session, true);
	}
}

stock IsPlayerDataLoaded(playerid) return !IsPlayerConnected(playerid) ? 0 : saveload_Loaded[playerid];