#include <YSI\y_hooks>

#define MAX_DEFENCE_ITEM		17
#define MAX_DEFENCE				8000
#define INVALID_DEFENCE_ID		-1
#define INVALID_DEFENCE_TYPE	-1

enum {
	DEFENCE_POSE_HORIZONTAL,
	DEFENCE_POSE_VERTICAL
}

enum E_DEFENCE_ITEM_DATA {
ItemType:	def_itemtype,
Float:		def_verticalRotX,
Float:		def_verticalRotY,
Float:		def_verticalRotZ,
Float:		def_horizontalRotX,
Float:		def_horizontalRotY,
Float:		def_horizontalRotZ,
Float:		def_placeOffsetZ,
bool:		def_movable
}

enum e_DEFENCE_DATA {
bool:		def_active,
			def_pose,
			def_motor,
			def_keypad,
			def_pass,
}

static
			def_TypeData[MAX_DEFENCE_ITEM][E_DEFENCE_ITEM_DATA],
			def_TypeTotal,
			def_ItemTypeDefenceType[ITM_MAX_TYPES] = {INVALID_DEFENCE_TYPE, ...},
			def_TweakArrow[MAX_PLAYERS] = {INVALID_OBJECT_ID, ...},
			def_CurrentDefenceItem[MAX_PLAYERS],
			def_CurrentDefenceEdit[MAX_PLAYERS],
			def_CurrentDefenceOpen[MAX_PLAYERS],
			def_LastPassEntry[MAX_PLAYERS],
			def_Cooldown[MAX_PLAYERS],
			def_PassFails[MAX_PLAYERS],
Iterator:   def_Index <MAX_DEFENCE>,
			def_Col[ITM_MAX];


forward OnDefenceCreate(itemId);
forward OnDefenseDestroyed(itemId);
forward OnDefenceModified(itemId);
forward OnDefenceMove(itemId);

hook OnGameModeExit() { // ? Que merda e essa
    foreach(new i : def_Index) {
		if(IsItemTypeDefence(GetItemType(i))) {
			if(GetItemArrayDataAtCell(i, def_active))
				CA_DestroyObject(def_Col[i]);
		}
    }
}

stock CreateDefence(itemId) {
	new Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz;

	GetItemPos(itemId, x, y, z);
	GetItemRot(itemId, rx, ry, rz);

    def_Col[itemId] = CA_CreateObject(GetItemTypeModel(GetItemType(itemId)), x, y, z, rx, ry, rz, true);
}

// ? Maybe shoot down defenses?
public OnPlayerShootDynamicObject(playerid, weaponid, STREAMER_TAG_OBJECT:objectid, Float:x, Float:y, Float:z) {

	return 1;
}

hook OnPlayerConnect(playerid) {
	def_CurrentDefenceItem[playerid] = INVALID_ITEM_ID;
	def_CurrentDefenceEdit[playerid] = -1;
	def_CurrentDefenceOpen[playerid] = -1;
	def_LastPassEntry[playerid]      = 0;
	def_Cooldown[playerid]           = 2000;
	def_PassFails[playerid]          = 0;
}

stock DefineDefenceItem(ItemType:itemType, Float:v_rx, Float:v_ry, Float:v_rz, Float:h_rx, Float:h_ry, Float:h_rz, Float:zoffset, bool:movable) {
	SetItemTypeMaxArrayData(itemType, e_DEFENCE_DATA);

	def_TypeData[def_TypeTotal][def_itemtype]       = itemType;
	def_TypeData[def_TypeTotal][def_verticalRotX]   = v_rx;
	def_TypeData[def_TypeTotal][def_verticalRotY]   = v_ry;
	def_TypeData[def_TypeTotal][def_verticalRotZ]   = v_rz;
	def_TypeData[def_TypeTotal][def_horizontalRotX] = h_rx;
	def_TypeData[def_TypeTotal][def_horizontalRotY] = h_ry;
	def_TypeData[def_TypeTotal][def_horizontalRotZ] = h_rz;
	def_TypeData[def_TypeTotal][def_placeOffsetZ]   = zoffset;
	def_TypeData[def_TypeTotal][def_movable]        = movable;

	def_ItemTypeDefenceType[itemType] = def_TypeTotal;

	return def_TypeTotal++;
}

ActivateDefenceItem(itemId) {
    Iter_Add(def_Index, itemId);
    
	new ItemType:itemType = GetItemType(itemId);

	if(!IsValidItemType(itemType)) {
		err("Attempted to create defence from item with invalid type (%d)", _:itemType);
		return INVALID_ITEM_ID;
	}

	new defenceType = def_ItemTypeDefenceType[itemType];

	if(defenceType == INVALID_DEFENCE_TYPE) {
		err("Attempted to create defence from item that is not a defence type (%d)", _:itemType);
		return INVALID_ITEM_ID;
	}

    SetItemArrayDataAtCell(itemId, DEFENCE_POSE_VERTICAL, def_pose);
    
	new
		itemTypeName[ITM_MAX_NAME],
		itemData[e_DEFENCE_DATA];

	GetItemTypeName(def_TypeData[defenceType][def_itemtype], itemTypeName);
	GetItemArrayData(itemId, itemData);

	itemData[def_active] = true;

	SetItemArrayData(itemId, itemData, e_DEFENCE_DATA);

    SetButtonSize(GetItemButtonID(itemId), 2.2);

    SetItemLabel(itemId, sprintf("%s\n%d/%d", itemTypeName, GetItemHitPoints(itemId), GetItemTypeMaxHitPoints(itemType)), 0xFFFF00FF, 5.0, false);

	return itemId;
}

DeconstructDefence(itemId) {
    Iter_Remove(def_Index, itemId);
    
	new
		Float:x, Float:y, Float:z,
		ItemType:itemType,
		itemData[e_DEFENCE_DATA];

	GetItemPos(itemId, x, y, z);
	itemType = GetItemType(itemId);
	GetItemArrayData(itemId, itemData);

	if(itemData[def_motor]) {
		if(itemData[def_pose] == DEFENCE_POSE_VERTICAL)
			z -= def_TypeData[def_ItemTypeDefenceType[itemType]][def_placeOffsetZ];
	} else {
		if(itemData[def_pose] == DEFENCE_POSE_VERTICAL)
			z -= def_TypeData[def_ItemTypeDefenceType[itemType]][def_placeOffsetZ];
	}

    new itemTypeName[ITM_MAX_NAME];

	GetItemTypeName(def_TypeData[def_ItemTypeDefenceType[itemType]][def_itemtype], itemTypeName);

    SetItemLabel(itemId, sprintf("%s", itemTypeName), 0xFFFF00FF);

	SetItemPos(itemId, x, y, z);
	SetItemRot(itemId, 0.0, 0.0, 0.0, true);

	SetItemArrayDataAtCell(itemId, 0, def_keypad);
	SetItemArrayDataAtCell(itemId, 0, def_motor);
	SetItemArrayDataAtCell(itemId, 0, def_pose);
	
	CA_DestroyObject(def_Col[itemId]);
	CallLocalFunction("OnDefenseDestroyed", "d", itemId);
}

// Quando o jogador larga uma defesa
hook OnPlayerDroppedItem(playerid, itemId) {
    new const ItemType:itemType = GetItemType(itemId);
    
    if(def_ItemTypeDefenceType[itemType] != INVALID_DEFENCE_TYPE) {
		new Float:x, Float:y, Float:z;
		GetItemPos(itemId, x, y, z);

		new Float:hitX, Float:hitY, Float:hitZ;
		new objectId = CA_RayCastLine(x, y, z, x, y, z - 2.0, hitX, hitY, hitZ);

		if(objectId && objectId != WATER_OBJECT) SetItemPos(itemId, hitX, hitY, hitZ);
	}
}

hook OnPlayerPickUpItem(playerid, itemId) {
	new ItemType:itemType = GetItemType(itemId);

	if(def_ItemTypeDefenceType[itemType] != INVALID_DEFENCE_TYPE) {
		if(GetItemArrayDataAtCell(itemId, def_active)) {
			_InteractDefence(playerid, itemId);
			return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return 1;
}

hook OnPlayerUseItemWithItem(playerid, itemId, withitemId) {
	new ItemType:withitemtype = GetItemType(withitemId);

	if(def_ItemTypeDefenceType[withitemtype] != INVALID_DEFENCE_TYPE) {
		if(GetItemArrayDataAtCell(withitemId, def_active)) {
			if(!_InteractDefenceWithItem(playerid, withitemId, itemId))
   				_InteractDefence(playerid, withitemId);
		} else {
			new ItemType:itemType = GetItemType(itemId);

			if(itemType == item_Hammer || itemType == item_Screwdriver)
				StartBuildingDefence(playerid, withitemId);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	if(oldkeys & 16)
		StopBuildingDefence(playerid);
}

StartBuildingDefence(playerid, itemId) {
	if(GetPlayerInterior(playerid) != 0) return ChatMsg(playerid, RED, " > Você não pode construir aqui.");

	// Zonas do mapa em que não se pode construir
	new const Float:blockedZones[][4] = {
		// [radius, x, y, z]
		{10.0, -688.34, 937.39, 13.63}, // Torino Ranch
		{40.0, 2000.7017, -2139.0505, 13.5537},  // Comerciante Los Santos
		{180.0, 4547.9453, -1642.1956, -0.2185}, // Ilha Los Santos
		{150.0, -1951.6232, 678.3726, 46.5625},  // Casa Branca San Fierro
		{150.0, -1471.0057, 392.3958, 30.0859},  // Navio 69 San Fierro
		{150.0, -4474.6050, 476.7611, 10.7196},  // Ilha San Fierro
		{200.0, 2609.5820, 2749.2007, 26.9102}   // K.A.C.C Las Venturas
	};

	for(new i = 0; i < sizeof(blockedZones); i++) {
		if(IsPlayerInRangeOfPoint(playerid, blockedZones[i][0], blockedZones[i][1], blockedZones[i][2], blockedZones[i][3]))
			return ChatMsg(playerid, RED, " > Você não pode construir aqui.");
	}

	new itemTypeName[ITM_MAX_NAME];

	GetItemTypeName(GetItemType(itemId), itemTypeName);

	def_CurrentDefenceItem[playerid] = itemId;
	
	StartHoldAction(playerid, CalculateVIPAdjustedTime(playerid, 8000));
	
	ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
	ShowActionText(playerid, sprintf(ls(playerid, "item/defence/building"), itemTypeName));

	return 1;
}

StopBuildingDefence(playerid) {
	if(!IsValidItem(GetPlayerItem(playerid))) return;

	if(def_CurrentDefenceItem[playerid] != INVALID_ITEM_ID)
		def_CurrentDefenceItem[playerid] = INVALID_ITEM_ID;

	if(def_CurrentDefenceEdit[playerid] != INVALID_ITEM_ID) // ? Nao deveria ser else if?
		def_CurrentDefenceEdit[playerid] = INVALID_ITEM_ID;

	StopHoldAction(playerid);
	ClearAnimations(playerid);
	HideActionText(playerid);

	return;
}

_InteractDefence(playerid, itemId) {
    if(GetItemType(GetPlayerItem(playerid)) == item_Crowbar) return 0;
        
    if(GetItemTypeExplosiveType(GetItemType(GetPlayerItem(playerid))) != INVALID_EXPLOSIVE_TYPE) return 0;
        
	new data[e_DEFENCE_DATA];

	GetItemArrayData(itemId, data);

	if(data[def_motor]) {
		if(data[def_keypad] == 1) {
			if(data[def_pass] == 0) {
				if(def_CurrentDefenceEdit[playerid] != -1) {
					HideKeypad(playerid);
					Dialog_Close(playerid);
				}

				def_CurrentDefenceEdit[playerid] = itemId;
				ShowSetPassDialog_Keypad(playerid);
			} else {
				if(def_CurrentDefenceOpen[playerid] != -1) {
					HideKeypad(playerid);
					Dialog_Close(playerid);
				}

				def_CurrentDefenceOpen[playerid] = itemId;

				ShowEnterPassDialog_Keypad(playerid);
				CancelPlayerMovement(playerid);
			}
		}
		else if(data[def_keypad] == 2) {
			if(data[def_pass] == 0) {
				if(def_CurrentDefenceEdit[playerid] != -1) {
					HideKeypad(playerid);
					Dialog_Close(playerid);
				}

				def_CurrentDefenceEdit[playerid] = itemId;
				ShowSetPassDialog_KeypadAdv(playerid);
			} else {
				if(def_CurrentDefenceOpen[playerid] != -1) {
					HideKeypad(playerid);
					Dialog_Close(playerid);
				}

				def_CurrentDefenceOpen[playerid] = itemId;

				ShowEnterPassDialog_KeypadAdv(playerid);
				CancelPlayerMovement(playerid);
			}
		} else {
			ShowActionText(playerid, ls(playerid, "item/defence/moving"), 3000);
			defer MoveDefence(itemId, playerid);
		}
	}
	return 1;
}

_InteractDefenceWithItem(playerid, itemId, tool) {
	new
		defenceType,
		ItemType:toolType,
		Float:angle;

	defenceType = def_ItemTypeDefenceType[GetItemType(itemId)];
	toolType    = GetItemType(tool);
	GetItemRot(itemId, angle, angle, angle);

	angle = absoluteangle((angle - def_TypeData[defenceType][def_verticalRotZ]) - GetButtonAngleToPlayer(playerid, GetItemButtonID(itemId)));

	// ensures the player can only perform these actions on the back-side.
	if(!(90.0 < angle < 270.0)) return 0;
		
	new
	    Float:x, Float:y, Float:z,
		Float:ix, Float:iy, Float:iz;
	    
	GetPlayerPos(playerid, x, y, z);
	GetItemPos(itemId, ix, iy, iz);

	if(Distance(x, y, z, ix, iy, iz) > 1.5) return 0;
	    
	if(toolType == item_Crowbar) {
		new itemTypeName[ITM_MAX_NAME];

		GetItemTypeName(def_TypeData[defenceType][def_itemtype], itemTypeName);

		def_CurrentDefenceEdit[playerid] = itemId;
		StartHoldAction(playerid, 8000);
		
		StartHoldAction(playerid, CalculateVIPAdjustedTime(playerid, 8000));
	    
		ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);
		ShowActionText(playerid, sprintf(ls(playerid, "item/defence/removing"), itemTypeName));

		return 1;
	}

	if(toolType == item_Motor) {
	    if(!def_TypeData[defenceType][def_movable]) {
			ShowActionText(playerid, ls(playerid, "item/defence/not-movable"));
			return 1;
		}
		
	    if(GetItemArrayDataAtCell(itemId, def_pose) == DEFENCE_POSE_HORIZONTAL) return 1;

		new itemTypeName[ITM_MAX_NAME];

		GetItemTypeName(def_TypeData[defenceType][def_itemtype], itemTypeName);

		def_CurrentDefenceEdit[playerid] = itemId;
		
		StartHoldAction(playerid, CalculateVIPAdjustedTime(playerid, 6000));
	    	
		ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);

		ShowActionText(playerid, sprintf(ls(playerid, "item/defence/modifying"), itemTypeName));

		return 1;
	}

	if(toolType == item_Keypad) {
        if(GetItemArrayDataAtCell(itemId, def_pose) == DEFENCE_POSE_HORIZONTAL) return 0;

		if(!GetItemArrayDataAtCell(itemId, _:def_motor)) {
			ShowActionText(playerid, ls(playerid, "item/defence/needs-motor"));
			return 1;
		}

		new itemTypeName[ITM_MAX_NAME];

		GetItemTypeName(def_TypeData[defenceType][def_itemtype], itemTypeName);

		def_CurrentDefenceEdit[playerid] = itemId;

		StartHoldAction(playerid, CalculateVIPAdjustedTime(playerid, 6000));
	    	
		ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);

		ShowActionText(playerid, sprintf(ls(playerid, "item/defence/modifying"), itemTypeName));

		return 1;
	}

	if(toolType == item_AdvancedKeypad) {
	    if(GetItemArrayDataAtCell(itemId, def_pose) == DEFENCE_POSE_HORIZONTAL) return 0;

		if(!GetItemArrayDataAtCell(itemId, _:def_motor)) {
			ShowActionText(playerid, ls(playerid, "item/defence/needs-motor"));
			return 1;
		}

		new itemTypeName[ITM_MAX_NAME];

		GetItemTypeName(def_TypeData[defenceType][def_itemtype], itemTypeName);

		def_CurrentDefenceEdit[playerid] = itemId;

		StartHoldAction(playerid, CalculateVIPAdjustedTime(playerid, 6000));
	    	
		ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);

		ShowActionText(playerid, sprintf(ls(playerid, "item/defence/modifying"), itemTypeName));

		return 1;
	}

	return 0;
}

hook OnHoldActionUpdate(playerid, progress) {
	if(def_CurrentDefenceItem[playerid] != INVALID_ITEM_ID) {
		if(!IsItemInWorld(def_CurrentDefenceItem[playerid]))
			StopHoldAction(playerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnHoldActionFinish(playerid) {
	if(def_CurrentDefenceItem[playerid] != INVALID_ITEM_ID) {
		if(!IsItemInWorld(def_CurrentDefenceItem[playerid])) return Y_HOOKS_BREAK_RETURN_0;
        
		new
			ItemType:itemType,
			ItemType:defenceItemType,
			pose,
			itemId;

		itemType        = GetItemType(GetPlayerItem(playerid));
		defenceItemType = GetItemType(def_CurrentDefenceItem[playerid]);

		if(itemType == item_Screwdriver) pose = DEFENCE_POSE_VERTICAL;
		else if(itemType == item_Hammer) pose = DEFENCE_POSE_HORIZONTAL;
		    
		SetItemArrayDataAtCell(def_CurrentDefenceItem[playerid], pose, def_pose);
		itemId = ActivateDefenceItem(def_CurrentDefenceItem[playerid]);

		if(!IsValidItem(itemId)) {
			ChatMsg(playerid, RED, "item/defence/limit-reached");
			return Y_HOOKS_BREAK_RETURN_0;
		}

		new
			geid[GEID_LEN],
			Float:x, Float:y, Float:z,
			Float:rx, Float:ry, Float:rz;

		GetItemGEID(itemId, geid);
		GetItemPos(itemId, x, y, z);
		GetItemRot(itemId, rx, ry, rz);

		new const defenseType = def_ItemTypeDefenceType[defenceItemType];

		if(pose == DEFENCE_POSE_HORIZONTAL) {
			rx  = def_TypeData[defenseType][def_horizontalRotX];
			ry  = def_TypeData[defenseType][def_horizontalRotY];
			rz += def_TypeData[defenseType][def_horizontalRotZ];
		} else if(pose == DEFENCE_POSE_VERTICAL) {
			z  += def_TypeData[defenseType][def_placeOffsetZ];
			rx  = def_TypeData[defenseType][def_verticalRotX];
			ry  = def_TypeData[defenseType][def_verticalRotY];
			rz += def_TypeData[defenseType][def_verticalRotZ];
		}

		SetItemPos(itemId, x, y, z);
		SetItemRot(itemId, rx, ry, rz);

		log("[CONSTRUCT] %p Built defence %d (%s) (%d, %f, %f, %f, %f, %f, %f)",
			playerid, itemId, geid, GetItemTypeModel(GetItemType(itemId)), x, y, z, rx, ry, rz);

		CallLocalFunction("OnDefenceCreate", "d", itemId);
		StopBuildingDefence(playerid);

        def_TweakArrow[playerid] = CreateDynamicObject(19133, x, y, z, 0.0, 0.0, 0.0, GetItemWorld(itemId), GetItemInterior(itemId));
        
		//AttachDynamicObjectToObject(def_TweakArrow[playerid], objectid, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0);
		
		_UpdateDefenceTweakArrow(playerid, itemId, x, y, z, rx, ry, rz);
		
		TweakItem(playerid, itemId);
		
		return Y_HOOKS_BREAK_RETURN_0;
	}

	if(def_CurrentDefenceEdit[playerid] != -1) {
		new
			itemId,
			ItemType:itemType;

		itemId   = GetPlayerItem(playerid);
		itemType = GetItemType(itemId);

		if(itemType == item_Motor) {
			ShowActionText(playerid, ls(playerid, "item/defence/motor-installed"));
			SetItemArrayDataAtCell(def_CurrentDefenceEdit[playerid], true, def_motor);

			CallLocalFunction("OnDefenceModified", "d", def_CurrentDefenceEdit[playerid]);

			DestroyItem(itemId);
			ClearAnimations(playerid);
		} else if(itemType == item_Keypad) {
			ShowActionText(playerid, ls(playerid, "item/defence/keypad-installed"));
			ShowSetPassDialog_Keypad(playerid);
			SetItemArrayDataAtCell(def_CurrentDefenceEdit[playerid], 1, def_keypad);

			CallLocalFunction("OnDefenceModified", "d", def_CurrentDefenceEdit[playerid]);

			DestroyItem(itemId);
			ClearAnimations(playerid);
		} else if(itemType == item_AdvancedKeypad) {
			ShowActionText(playerid, ls(playerid, "item/defence/advanced-keypad-installed"));
			ShowSetPassDialog_KeypadAdv(playerid);
			SetItemArrayDataAtCell(def_CurrentDefenceEdit[playerid], 2, def_keypad);
			CallLocalFunction("OnDefenceModified", "d", def_CurrentDefenceEdit[playerid]);

			DestroyItem(itemId);
			ClearAnimations(playerid);
		} else if(itemType == item_Crowbar) {
			new Float:x, Float:y, Float:z;

			ShowActionText(playerid, ls(playerid, "item/defence/destroyed"));

			DeconstructDefence(def_CurrentDefenceEdit[playerid]);

			GetPlayerPos(playerid, x, y, z);

			SetItemPos(def_CurrentDefenceEdit[playerid], x, y, z - (0.96));

			ClearAnimations(playerid);
			def_CurrentDefenceEdit[playerid] = -1;
		}

		return Y_HOOKS_BREAK_RETURN_0;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeypadEnter(playerid, keypadid, code, match) {
	if(keypadid == 100) {
		if(def_CurrentDefenceEdit[playerid] != -1) {
			SetItemArrayDataAtCell(def_CurrentDefenceEdit[playerid], code, def_pass);
			CallLocalFunction("OnDefenceModified", "d", def_CurrentDefenceEdit[playerid]);
			HideKeypad(playerid);

			def_CurrentDefenceEdit[playerid] = -1;

			if(code == 0) ChatMsg(playerid, YELLOW, "item/defence/code-zero");

			return Y_HOOKS_BREAK_RETURN_1;
		}

		if(def_CurrentDefenceOpen[playerid] != -1) {
			if(code == match) {
				ShowActionText(playerid, ls(playerid, "item/defence/moving"), 3000);
				defer MoveDefence(def_CurrentDefenceOpen[playerid], playerid);
				def_CurrentDefenceOpen[playerid] = -1;
			} else {
				if(GetTickCountDifference(GetTickCount(), def_LastPassEntry[playerid]) < def_Cooldown[playerid]) {
					ShowEnterPassDialog_Keypad(playerid, 2);
					return Y_HOOKS_BREAK_RETURN_0;
				}

				if(def_PassFails[playerid] == 5) {
					def_Cooldown[playerid]  += 4000;
					def_PassFails[playerid]  = 0;
					return Y_HOOKS_BREAK_RETURN_0;
				}

				new geid[GEID_LEN];

				GetItemGEID(def_CurrentDefenceOpen[playerid], geid);

				log("[DEFFAIL] Player %p failed defence %d (%s) keypad code %d", playerid, def_CurrentDefenceOpen[playerid], geid, code);
				ShowEnterPassDialog_Keypad(playerid, 1);
				def_LastPassEntry[playerid] = GetTickCount();
				def_Cooldown[playerid] = 2000;
				def_PassFails[playerid]++;

				return Y_HOOKS_BREAK_RETURN_0;
			}

			return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}


_UpdateDefenceTweakArrow(playerid, itemId, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz) {
	new const ItemType:itemType    = GetItemType(itemId);
	new const defenseType = def_ItemTypeDefenceType[itemType];

    SetDynamicObjectPos(def_TweakArrow[playerid], x, y, z);
    
	if(GetItemArrayDataAtCell(itemId, def_pose) == DEFENCE_POSE_VERTICAL) {
		SetDynamicObjectRot(def_TweakArrow[playerid],
			rx - def_TypeData[defenseType][def_verticalRotX] + 90,
			ry - def_TypeData[defenseType][def_verticalRotY],
			rz - def_TypeData[defenseType][def_verticalRotZ]);
	} else {
		SetDynamicObjectRot(def_TweakArrow[playerid],
			rx - def_TypeData[defenseType][def_horizontalRotX],
			ry - def_TypeData[defenseType][def_horizontalRotY],
			rz - def_TypeData[defenseType][def_horizontalRotZ]);
	}
}

hook OnItemTweakUpdate(playerid, itemId, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz) {
	if(def_TweakArrow[playerid] != INVALID_OBJECT_ID)
		_UpdateDefenceTweakArrow(playerid, itemId, x, y, z, rx, ry, rz);
}

hook OnItemTweakFinish(playerid, itemId) {
	if(def_TweakArrow[playerid] == INVALID_OBJECT_ID) return Y_HOOKS_CONTINUE_RETURN_0;

	new
		Float:x, Float:y, Float:z,
		Float:rx, Float:ry, Float:rz;

	GetItemPos(itemId, x, y, z);
	GetItemRot(itemId, rx, ry, rz);
	
	CA_DestroyObject(def_Col[itemId]);
	def_Col[itemId] = CA_CreateObject(GetItemTypeModel(GetItemType(itemId)), x, y, z, rx, ry, rz, true);

	// Find the space the player has in his X axis
	// Send RayCasts so check the space
	// If he is too close to the object we just created
	// Set the players position to somewhere he doesn't touch a wall but also isn't touching our object

	DestroyDynamicObject(def_TweakArrow[playerid]);
	def_TweakArrow[playerid] = INVALID_OBJECT_ID;

	CallLocalFunction("OnDefenceModified", "d", itemId);

	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerKeypadCancel(playerid, keypadid){
	if(keypadid == 100){
		if(def_CurrentDefenceEdit[playerid] != -1){
			ShowSetPassDialog_Keypad(playerid);
			def_CurrentDefenceEdit[playerid] = -1;

			return 1;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

ShowSetPassDialog_Keypad(playerid){
	ChatMsg(playerid, YELLOW, "item/defence/set-code");

	ShowKeypad(playerid, 100);
}

ShowEnterPassDialog_Keypad(playerid, msg = 0) {
	/* if(msg == 0) ChatMsg(playerid, YELLOW, "item/defence/enter-code");
	else  */
	if(msg == 1) ChatMsg(playerid, YELLOW, "item/defence/incorrect-code");
	else if(msg == 2) ChatMsg(playerid, YELLOW, "item/defence/code-fast", MsToString(def_Cooldown[playerid] - GetTickCountDifference(GetTickCount(), def_LastPassEntry[playerid]), "%m:%s"));

	ShowKeypad(playerid, 100, GetItemArrayDataAtCell(def_CurrentDefenceOpen[playerid], def_pass));
}

ShowSetPassDialog_KeypadAdv(playerid){
	Dialog_Show(playerid, SetPassAdv, DIALOG_STYLE_INPUT, "Digite a senha", "Digite uma senha entre 4 e 8 caracteres usando os caracteres de 0 a 9, a-f.", "Confirmar", "");
	return 1;
}

Dialog:SetPassAdv(playerid, response, listitem, inputtext[]) {
	if(response) {
		new pass;

		if(!sscanf(inputtext, "x", pass) && strlen(inputtext) >= 4) {
			SetItemArrayDataAtCell(def_CurrentDefenceEdit[playerid], pass, def_pass);
			CallLocalFunction("OnDefenceModified", "d", def_CurrentDefenceEdit[playerid]);
			def_CurrentDefenceEdit[playerid] = -1;
		} else 
			ShowSetPassDialog_KeypadAdv(playerid);
	} else 
		ShowSetPassDialog_KeypadAdv(playerid);
}

ShowEnterPassDialog_KeypadAdv(playerid, msg = 0) {
	if(msg == 2) ChatMsg(playerid, YELLOW, "item/defence/code-fast", MsToString(def_Cooldown[playerid] - GetTickCountDifference(GetTickCount(), def_LastPassEntry[playerid]), "%m:%s"));

	Dialog_Show(playerid, EnterPassAdv, DIALOG_STYLE_INPUT, "Digite a senha", (msg == 1) ? ("Senha incorreta") : ("Digite a senha hexadecimal de 4 a 8 caracteres para abrir."), "Confirmar", "Cancelar");

	return 1;
}

Dialog:EnterPassAdv(playerid, response, listitem, inputtext[]) {
	if(response) {
		new pass;

		sscanf(inputtext, "x", pass);

		if(pass == GetItemArrayDataAtCell(def_CurrentDefenceOpen[playerid], def_pass) && strlen(inputtext) >= 4) {
			ShowActionText(playerid, ls(playerid, "item/defence/moving"), 3000);
			defer MoveDefence(def_CurrentDefenceOpen[playerid], playerid);
			def_CurrentDefenceOpen[playerid] = -1;
		} else {
			if(GetTickCountDifference(GetTickCount(), def_LastPassEntry[playerid]) < def_Cooldown[playerid]) {
				ShowEnterPassDialog_KeypadAdv(playerid, 2);
				return 1;
			}

			if(def_PassFails[playerid] == 5) {
				def_Cooldown[playerid] += 4000;
				def_PassFails[playerid] = 0;
				return 1;
			}

			new geid[GEID_LEN];

			GetItemGEID(def_CurrentDefenceOpen[playerid], geid);

			log("[DEFFAIL] Player %p failed defence %d (%s) keypad code %d", playerid, def_CurrentDefenceOpen[playerid], geid, pass);
			ShowEnterPassDialog_KeypadAdv(playerid, 1);
			def_LastPassEntry[playerid] = GetTickCount();
			def_Cooldown[playerid] = 2000;
			def_PassFails[playerid]++;
		}
	} else
		return 0;

	return 1;
}

timer MoveDefence[500](itemId, playerid) {
	new
		Float:px, Float:py, Float:pz,
		Float:ix, Float:iy, Float:iz;

	GetItemPos(itemId, ix, iy, iz);

	foreach(new i : Player) {
		GetPlayerPos(i, px, py, pz);

		if(Distance(px, py, pz, ix, iy, iz) < 3.0) {
			defer MoveDefence(itemId, playerid);

			return;
		}
	}

	new
	    ItemType:itemType = GetItemType(itemId),
	    objectId = GetItemObjectID(itemId),
		Float:rx, Float:ry, Float:rz;

	GetItemRot(itemId, rx, ry, rz);

	if(GetItemArrayDataAtCell(itemId, def_pose) == DEFENCE_POSE_HORIZONTAL) {
		MoveDynamicObject(objectId, ix, iy, iz, 0.9, rx, ry, rz);
        
		SetItemArrayDataAtCell(itemId, DEFENCE_POSE_VERTICAL, def_pose);
	} else {
		new const defenseType = def_ItemTypeDefenceType[itemType];

		rx  = def_TypeData[defenseType][def_horizontalRotX];
		ry  = def_TypeData[defenseType][def_horizontalRotY];
		rz += def_TypeData[defenseType][def_horizontalRotZ];
		iz -= def_TypeData[defenseType][def_placeOffsetZ];

        MoveDynamicObject(objectId, ix, iy, iz, 0.9, rx, ry, rz);

		SetItemArrayDataAtCell(itemId, DEFENCE_POSE_HORIZONTAL, def_pose);
	}
	
	CA_DestroyObject(def_Col[itemId]);
 	def_Col[itemId] = CA_CreateObject(GetItemTypeModel(GetItemType(itemId)), ix, iy, iz, rx, ry, rz, true);

	return;
}

// Update the defense label
hook OnItemHitPointsUpdate(itemId, oldvalue, newvalue) {
	new const ItemType:itemType = GetItemType(itemId);
	new const defenseType       = def_ItemTypeDefenceType[itemType];

	if(defenseType != -1) {
	    new itemTypeName[ITM_MAX_NAME];
		GetItemTypeName(def_TypeData[defenseType][def_itemtype], itemTypeName);
		SetItemLabel(itemId, sprintf("%s\n%d/%d", itemTypeName, newvalue, GetItemTypeMaxHitPoints(itemType)), 0xFFFF00FF, 5.0, false);
	}
}

hook OnItemDestroy(itemId) {
	new ItemType:itemType = GetItemType(itemId);

	if(def_ItemTypeDefenceType[itemType] != -1) { // Defense destroyed
	    CA_DestroyObject(def_Col[itemId]);

		if(GetItemHitPoints(itemId) <= 0) {
			new
				Float:x, Float:y, Float:z, 
				Float:rx, Float:ry, Float:rz;

			GetItemPos(itemId, x, y, z);
			GetItemRot(itemId, rx, ry, rz);

			log("[DEFENSE] Defence %d (%d) destroyed. Object: (%d, %f, %f, %f, %f, %f, %f)", itemId, _:itemType, GetItemTypeModel(itemType), x, y, z, rx, ry, rz);
			CallLocalFunction("OnDefenseDestroyed", "d", itemId);
		}
	}
}

/*==============================================================================

	Experimental hack detector
	
==============================================================================*/
/*
static
		def_CurrentCheckDefence[MAX_PLAYERS],
Timer:	def_AngleCheckTimer[MAX_PLAYERS],
		def_SetPosTick[MAX_PLAYERS];

hook OnPlayerEnterButtonArea(playerid, buttonid) {
	if(!IsPlayerOnAdminDuty(playerid) && IsPlayerSpawned(playerid)) {
		new
			defenceType,
			Float:angle;

		foreach(new i : def_Index) {
			if(
				(!GetDefenceMotor(i) && GetDefencePose(i) == DEFENCE_POSE_VERTICAL) ||
				(GetDefenceMotor(i) && GetDefencePose(i) == DEFENCE_POSE_VERTICAL) ) {
				defenceType = def_ItemTypeDefenceType[GetItemType(i)];

				GetItemRot(i, angle, angle, angle);

				angle = absoluteangle((angle - def_TypeData[defenceType][def_verticalRotZ]) - GetButtonAngleToPlayer(playerid, GetItemButtonID(i)));

				if(angle < 90.0 || angle > 270.0) {
					stop def_AngleCheckTimer[playerid];
					def_CurrentCheckDefence[playerid] = i;
					def_AngleCheckTimer[playerid] = repeat DefenceAngleCheck(playerid, i);
				}
			}
		}
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerLeaveButtonArea(playerid, buttonid) {
	foreach(new i : def_Index) {
		if(def_CurrentCheckDefence[playerid] == i)
			stop def_AngleCheckTimer[playerid];
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDisconnect(playerid, reason){
    stop def_AngleCheckTimer[playerid];
}

timer DefenceAngleCheck[100](playerid, itemId) {
    new
		defenceType,
		Float:angle,
		Float:x,
		Float:y,
		Float:z;
		
	GetItemPos(itemId, x, y, z);
	defenceType = def_ItemTypeDefenceType[GetItemType(itemId)];

	GetItemRot(itemId, angle, angle, angle);

	angle = absoluteangle((angle - def_TypeData[defenceType][def_verticalRotZ]) - GetButtonAngleToPlayer(playerid, GetItemButtonID(itemId)));
	
	if(120.0 < angle < 250.0) {
	    if(gettime() - def_SetPosTick[playerid] < 2000)
	        return;
	        
		AC_KickPlayer(playerid, "Airbreak (Defence)");
		stop def_AngleCheckTimer[playerid];
	}
	
	return;
}

//SetPlayerPos
ORPC:12(playerid, BitStream:bs){
    def_SetPosTick[playerid] = gettime();
	return 1;
}
*/

stock IsValidDefenceType(type) {
	if(0 <= type < def_TypeTotal) return 1;

	return 0;
}

stock GetItemTypeDefenceType(ItemType:itemType) {
	if(!IsValidItemType(itemType)) return INVALID_DEFENCE_TYPE;

	return def_ItemTypeDefenceType[itemType];
}

stock IsItemTypeDefence(ItemType:itemType) {
	if(!IsValidItemType(itemType)) return false;

	if(def_ItemTypeDefenceType[itemType] != -1) return true;

	return false;
}

forward ItemType:GetDefenceTypeItemType(defenceType);
stock ItemType:GetDefenceTypeItemType(defenceType) {
	if(!(0 <= defenceType < def_TypeTotal)) return INVALID_ITEM_TYPE;

	return def_TypeData[defenceType][def_itemtype];
}

stock GetDefenceTypeVerticalRot(defenceType, &Float:x, &Float:y, &Float:z) {
	if(!(0 <= defenceType < def_TypeTotal)) return 0;

	x = def_TypeData[defenceType][def_verticalRotX];
	y = def_TypeData[defenceType][def_verticalRotY];
	z = def_TypeData[defenceType][def_verticalRotZ];

	return 1;
}

stock GetDefenceTypeHorizontalRot(defenceType, &Float:x, &Float:y, &Float:z) {
	if(!(0 <= defenceType < def_TypeTotal)) return 0;

	x = def_TypeData[defenceType][def_horizontalRotX];
	y = def_TypeData[defenceType][def_horizontalRotY];
	z = def_TypeData[defenceType][def_horizontalRotZ];

	return 1;
}

forward Float:GetDefenceTypeOffsetZ(defenceType);
stock Float:GetDefenceTypeOffsetZ(defenceType) {
	if(!(0 <= defenceType < def_TypeTotal)) return 0.0;

	return def_TypeData[defenceType][def_placeOffsetZ];
}

stock GetDefenceType(itemId) {
	if(!IsValidItem(itemId)) return 0;

	return def_ItemTypeDefenceType[GetItemType(itemId)];
}

stock GetDefencePose(itemId) {
	return GetItemArrayDataAtCell(itemId, def_pose);
}

stock GetDefenceMotor(itemId) {
	return GetItemArrayDataAtCell(itemId, def_motor);
}

stock GetDefenceActive(itemId) {
	return GetItemArrayDataAtCell(itemId, def_active);
}

stock GetDefenceKeypad(itemId) {
	return GetItemArrayDataAtCell(itemId, def_keypad);
}

stock GetDefencePass(itemId) {
	return GetItemArrayDataAtCell(itemId, def_pass);
}