#include <YSI\y_hooks>

#define MAX_DEFENCE_ITEM		(17)
#define MAX_DEFENCE				(8000)
#define INVALID_DEFENCE_ID		(-1)
#define INVALID_DEFENCE_TYPE	(-1)


enum
{
	DEFENCE_POSE_HORIZONTAL,
	DEFENCE_POSE_VERTICAL
}

enum E_DEFENCE_ITEM_DATA
{
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

enum e_DEFENCE_DATA
{
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


forward OnDefenceCreate(itemid);
forward OnDefenceDestroy(itemid);
forward OnDefenceModified(itemid);
forward OnDefenceMove(itemid);

hook OnGameModeExit(){
    foreach(new i : def_Index){
		if(IsItemTypeDefence(GetItemType(i))){
			if(GetItemArrayDataAtCell(i, def_active)){
				CA_DestroyObject(def_Col[i]);
			}
		}
    }
}

stock CreateDefence(itemid){
	new Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz;
	GetItemPos(itemid, x, y, z);
	GetItemRot(itemid, rx, ry, rz);
    def_Col[itemid] = CA_CreateObject(GetItemTypeModel(GetItemType(itemid)), x, y, z, rx, ry, rz, true);
}


/*==============================================================================

	Zeroing

==============================================================================*/

public OnPlayerShootDynamicObject(playerid, weaponid, STREAMER_TAG_OBJECT:objectid, Float:x, Float:y, Float:z){

	return 1;
}

hook OnPlayerConnect(playerid)
{
	def_CurrentDefenceItem[playerid] = INVALID_ITEM_ID;
	def_CurrentDefenceEdit[playerid] = -1;
	def_CurrentDefenceOpen[playerid] = -1;
	def_LastPassEntry[playerid] = 0;
	def_Cooldown[playerid] = 2000;
	def_PassFails[playerid] = 0;
}


/*==============================================================================

	Core

==============================================================================*/


stock DefineDefenceItem(ItemType:itemtype, Float:v_rx, Float:v_ry, Float:v_rz, Float:h_rx, Float:h_ry, Float:h_rz, Float:zoffset, bool:movable)
{
	SetItemTypeMaxArrayData(itemtype, e_DEFENCE_DATA);

	def_TypeData[def_TypeTotal][def_itemtype] = itemtype;
	def_TypeData[def_TypeTotal][def_verticalRotX] = v_rx;
	def_TypeData[def_TypeTotal][def_verticalRotY] = v_ry;
	def_TypeData[def_TypeTotal][def_verticalRotZ] = v_rz;
	def_TypeData[def_TypeTotal][def_horizontalRotX] = h_rx;
	def_TypeData[def_TypeTotal][def_horizontalRotY] = h_ry;
	def_TypeData[def_TypeTotal][def_horizontalRotZ] = h_rz;
	def_TypeData[def_TypeTotal][def_placeOffsetZ] = zoffset;
	def_TypeData[def_TypeTotal][def_movable] = movable;

	def_ItemTypeDefenceType[itemtype] = def_TypeTotal;

	return def_TypeTotal++;
}

ActivateDefenceItem(itemid)
{
    Iter_Add(def_Index, itemid);
    
	new ItemType:itemtype = GetItemType(itemid);

	if(!IsValidItemType(itemtype))
	{
		err("Attempted to create defence from item with invalid type (%d)", _:itemtype);
		return INVALID_ITEM_ID;
	}

	new defencetype = def_ItemTypeDefenceType[itemtype];

	if(defencetype == INVALID_DEFENCE_TYPE)
	{
		err("Attempted to create defence from item that is not a defence type (%d)", _:itemtype);
		return INVALID_ITEM_ID;
	}

    SetItemArrayDataAtCell(itemid, DEFENCE_POSE_VERTICAL, def_pose);
    
	new
		itemtypename[ITM_MAX_NAME],
		itemdata[e_DEFENCE_DATA];

	GetItemTypeName(def_TypeData[defencetype][def_itemtype], itemtypename);
	GetItemArrayData(itemid, itemdata);

	itemdata[def_active] = true;

	SetItemArrayData(itemid, itemdata, e_DEFENCE_DATA);

    SetButtonSize(GetItemButtonID(itemid), 2.2);

    SetItemLabel(itemid, sprintf("%s\n%d/%d", itemtypename, GetItemHitPoints(itemid), GetItemTypeMaxHitPoints(itemtype)), 0xFFFF00FF, 5.0, false);
    

	return itemid;
}

DeconstructDefence(itemid)
{
    Iter_Remove(def_Index, itemid);
    
	new
		Float:x,
		Float:y,
		Float:z,
		ItemType:itemtype,
		itemdata[e_DEFENCE_DATA];

	GetItemPos(itemid, x, y, z);
	itemtype = GetItemType(itemid);
	GetItemArrayData(itemid, itemdata);

	if(itemdata[def_motor])
	{
		if(itemdata[def_pose] == DEFENCE_POSE_VERTICAL)
			z -= def_TypeData[def_ItemTypeDefenceType[itemtype]][def_placeOffsetZ];
	}
	else
	{
		if(itemdata[def_pose] == DEFENCE_POSE_VERTICAL)
			z -= def_TypeData[def_ItemTypeDefenceType[itemtype]][def_placeOffsetZ];
	}

    new itemtypename[ITM_MAX_NAME];

	GetItemTypeName(def_TypeData[def_ItemTypeDefenceType[itemtype]][def_itemtype], itemtypename);

    SetItemLabel(itemid, sprintf("%s", itemtypename), 0xFFFF00FF);

	SetItemPos(itemid, x, y, z);
	SetItemRot(itemid, 0.0, 0.0, 0.0, true);

	SetItemArrayDataAtCell(itemid, 0, def_keypad);
	SetItemArrayDataAtCell(itemid, 0, def_motor);
	SetItemArrayDataAtCell(itemid, 0, def_pose);
	
	CA_DestroyObject(def_Col[itemid]);
	CallLocalFunction("OnDefenceDestroy", "d", itemid);
}

// Quando o jogador larga uma defesa
hook OnPlayerDroppedItem(playerid, itemid) {
    new const ItemType:itemType = GetItemType(itemid);
    
    if(def_ItemTypeDefenceType[itemType] != INVALID_DEFENCE_TYPE) {
		new Float:x, Float:y, Float:z;
		GetItemPos(itemid, x, y, z);

		new Float:hitX, Float:hitY, Float:hitZ;
		new objectId = CA_RayCastLine(x, y, z, x, y, z - 2.0, hitX, hitY, hitZ);

		if(objectId && objectId != WATER_OBJECT) {
			SetItemPos(itemid, hitX, hitY, hitZ);
		}
	}
}

hook OnPlayerPickUpItem(playerid, itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(def_ItemTypeDefenceType[itemtype] != INVALID_DEFENCE_TYPE)
	{
		if(GetItemArrayDataAtCell(itemid, def_active))
		{
			_InteractDefence(playerid, itemid);
			return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return 1;
}

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{
	new ItemType:withitemtype = GetItemType(withitemid);

	if(def_ItemTypeDefenceType[withitemtype] != INVALID_DEFENCE_TYPE)
	{
		if(GetItemArrayDataAtCell(withitemid, def_active))
		{
			if(!_InteractDefenceWithItem(playerid, withitemid, itemid))
   				_InteractDefence(playerid, withitemid);
		}
		else
		{
			new ItemType:itemtype = GetItemType(itemid);

			if(itemtype == item_Hammer || itemtype == item_Screwdriver)
				StartBuildingDefence(playerid, withitemid);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(oldkeys & 16)
		StopBuildingDefence(playerid);
}

StartBuildingDefence(playerid, itemid)
{
	if(GetPlayerInterior(playerid) != 0) return ChatMsg(playerid, RED, " > Você não pode construir aqui.");

	// Zonas do mapa em que não se pode construir
	new const Float:blockedZones[][4] = {
		// [radius, x, y, z]
		{40.0, 2000.7017, -2139.0505, 13.5537}, // Comerciante Los Santos
		{180.0, 4547.9453, -1642.1956, -0.2185}, // Ilha Los Santos
		{150.0, -1951.6232, 678.3726, 46.5625}, // Casa Branca San Fierro
		{150.0, -1471.0057, 392.3958, 30.0859}, // Navio 69 San Fierro
		{150.0, -4474.6050, 476.7611, 10.7196}, // Ilha San Fierro
		{200.0, 2609.5820, 2749.2007, 26.9102} // K.A.C.C Las Venturas
	};

	for(new i = 0; i < sizeof(blockedZones); i++)
	{
		if(IsPlayerInRangeOfPoint(playerid, blockedZones[i][0], blockedZones[i][1], blockedZones[i][2], blockedZones[i][3]))
			return ChatMsg(playerid, RED, " > Você não pode construir aqui.");
	}

	new itemtypename[ITM_MAX_NAME];

	GetItemTypeName(GetItemType(itemid), itemtypename);

	def_CurrentDefenceItem[playerid] = itemid;
	
	StartHoldAction(playerid, IsPlayerVip(playerid) ? 4000 : 8000);
	
	ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
	ShowActionText(playerid, sprintf(ls(playerid, "item/defence/building"), itemtypename));



	return 1;
}

StopBuildingDefence(playerid)
{
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

_InteractDefence(playerid, itemid)
{
    if(GetItemType(GetPlayerItem(playerid)) == item_Crowbar) return 0;
        
    if(GetItemTypeExplosiveType(GetItemType(GetPlayerItem(playerid))) != INVALID_EXPLOSIVE_TYPE) return 0;
        
	new data[e_DEFENCE_DATA];

	GetItemArrayData(itemid, data);

	if(data[def_motor])
	{
		if(data[def_keypad] == 1)
		{
			if(data[def_pass] == 0)
			{
				if(def_CurrentDefenceEdit[playerid] != -1)
				{
					HideKeypad(playerid);
					Dialog_Close(playerid);
				}

				def_CurrentDefenceEdit[playerid] = itemid;
				ShowSetPassDialog_Keypad(playerid);
			}
			else
			{
				if(def_CurrentDefenceOpen[playerid] != -1)
				{
					HideKeypad(playerid);
					Dialog_Close(playerid);
				}

				def_CurrentDefenceOpen[playerid] = itemid;

				ShowEnterPassDialog_Keypad(playerid);
				CancelPlayerMovement(playerid);
			}
		}
		else if(data[def_keypad] == 2)
		{
			if(data[def_pass] == 0)
			{
				if(def_CurrentDefenceEdit[playerid] != -1)
				{
					HideKeypad(playerid);
					Dialog_Close(playerid);
				}

				def_CurrentDefenceEdit[playerid] = itemid;
				ShowSetPassDialog_KeypadAdv(playerid);
			}
			else
			{
				if(def_CurrentDefenceOpen[playerid] != -1)
				{
					HideKeypad(playerid);
					Dialog_Close(playerid);
				}

				def_CurrentDefenceOpen[playerid] = itemid;

				ShowEnterPassDialog_KeypadAdv(playerid);
				CancelPlayerMovement(playerid);
			}
		}
		else
		{
			ShowActionText(playerid, ls(playerid, "item/defence/moving"), 3000);
			defer MoveDefence(itemid, playerid);
		}
	}
	return 1;
}

_InteractDefenceWithItem(playerid, itemid, tool)
{
	new
		defencetype,
		ItemType:tooltype,
		Float:angle;

	defencetype = def_ItemTypeDefenceType[GetItemType(itemid)];
	tooltype = GetItemType(tool);
	GetItemRot(itemid, angle, angle, angle);

	angle = absoluteangle((angle - def_TypeData[defencetype][def_verticalRotZ]) - GetButtonAngleToPlayer(playerid, GetItemButtonID(itemid)));

	// ensures the player can only perform these actions on the back-side.
	if(!(90.0 < angle < 270.0))
	    return 0;
		
	new
	    Float:x,
	    Float:y,
	    Float:z,
	    Float:ix,
	    Float:iy,
	    Float:iz;
	    
	GetPlayerPos(playerid, x, y, z);
	GetItemPos(itemid, ix, iy, iz);

	if(Distance(x, y, z, ix, iy, iz) > 1.5) return 0;
	    
	if(tooltype == item_Crowbar)
	{
		new itemtypename[ITM_MAX_NAME];

		GetItemTypeName(def_TypeData[defencetype][def_itemtype], itemtypename);

		def_CurrentDefenceEdit[playerid] = itemid;
		StartHoldAction(playerid, 8000);
		
		if(IsPlayerVip(playerid))
	    	StartHoldAction(playerid, 5000);
		else
	    	StartHoldAction(playerid, 8000);
	    
		ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);
		ShowActionText(playerid, sprintf(ls(playerid, "item/defence/removing"), itemtypename));

		return 1;
	}

	if(tooltype == item_Motor)
	{
	    if(!def_TypeData[defencetype][def_movable])
		{
			ShowActionText(playerid, ls(playerid, "item/defence/not-movable"));
			return 1;
		}
		
	    if(GetItemArrayDataAtCell(itemid, def_pose) == DEFENCE_POSE_HORIZONTAL) return 1;

		new itemtypename[ITM_MAX_NAME];

		GetItemTypeName(def_TypeData[defencetype][def_itemtype], itemtypename);

		def_CurrentDefenceEdit[playerid] = itemid;
		
		StartHoldAction(playerid, IsPlayerVip(playerid) ? 3000 : 6000);
	    	
		ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);

		ShowActionText(playerid, sprintf(ls(playerid, "item/defence/modifying"), itemtypename));

		return 1;
	}

	if(tooltype == item_Keypad)
	{
        if(GetItemArrayDataAtCell(itemid, def_pose) == DEFENCE_POSE_HORIZONTAL) return 0;

		if(!GetItemArrayDataAtCell(itemid, _:def_motor))
		{
			ShowActionText(playerid, ls(playerid, "item/defence/needs-motor"));
			return 1;
		}

		new itemtypename[ITM_MAX_NAME];

		GetItemTypeName(def_TypeData[defencetype][def_itemtype], itemtypename);

		def_CurrentDefenceEdit[playerid] = itemid;

		StartHoldAction(playerid, IsPlayerVip(playerid) ? 3000 : 6000);
	    	
		ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);

		ShowActionText(playerid, sprintf(ls(playerid, "item/defence/modifying"), itemtypename));

		return 1;
	}

	if(tooltype == item_AdvancedKeypad)
	{
	    if(GetItemArrayDataAtCell(itemid, def_pose) == DEFENCE_POSE_HORIZONTAL) return 0;

		if(!GetItemArrayDataAtCell(itemid, _:def_motor))
		{
			ShowActionText(playerid, ls(playerid, "item/defence/needs-motor"));
			return 1;
		}

		new itemtypename[ITM_MAX_NAME];

		GetItemTypeName(def_TypeData[defencetype][def_itemtype], itemtypename);

		def_CurrentDefenceEdit[playerid] = itemid;

		StartHoldAction(playerid, IsPlayerVip(playerid) ? 3000 : 6000);
	    	
		ApplyAnimation(playerid, "COP_AMBIENT", "COPBROWSE_LOOP", 4.0, 1, 0, 0, 0, 0);

		ShowActionText(playerid, sprintf(ls(playerid, "item/defence/modifying"), itemtypename));

		return 1;
	}

	return 0;
}

hook OnHoldActionUpdate(playerid, progress)
{
	if(def_CurrentDefenceItem[playerid] != INVALID_ITEM_ID)
	{
		if(!IsItemInWorld(def_CurrentDefenceItem[playerid]))
			StopHoldAction(playerid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnHoldActionFinish(playerid)
{
	if(def_CurrentDefenceItem[playerid] != INVALID_ITEM_ID)
	{
		if(!IsItemInWorld(def_CurrentDefenceItem[playerid])) return Y_HOOKS_BREAK_RETURN_0;
        
		new
			ItemType:itemtype,
			ItemType:defenceitemtype,
			pose,
			itemid;

		itemtype        = GetItemType(GetPlayerItem(playerid));
		defenceitemtype = GetItemType(def_CurrentDefenceItem[playerid]);

		if(itemtype == item_Screwdriver) pose = DEFENCE_POSE_VERTICAL;
		else if(itemtype == item_Hammer) pose = DEFENCE_POSE_HORIZONTAL;
		    
		SetItemArrayDataAtCell(def_CurrentDefenceItem[playerid], pose, def_pose);
		itemid = ActivateDefenceItem(def_CurrentDefenceItem[playerid]);

		if(!IsValidItem(itemid))
		{
			ChatMsg(playerid, RED, "item/defence/limit-reached");
			return Y_HOOKS_BREAK_RETURN_0;
		}

		new
			geid[GEID_LEN],
			Float:x,
			Float:y,
			Float:z,
			Float:rx,
			Float:ry,
			Float:rz;

		GetItemGEID(itemid, geid);
		GetItemPos(itemid, x, y, z);
		GetItemRot(itemid, rx, ry, rz);

		if(pose == DEFENCE_POSE_HORIZONTAL)
		{
			rx = def_TypeData[def_ItemTypeDefenceType[defenceitemtype]][def_horizontalRotX];
			ry = def_TypeData[def_ItemTypeDefenceType[defenceitemtype]][def_horizontalRotY];
			rz += def_TypeData[def_ItemTypeDefenceType[defenceitemtype]][def_horizontalRotZ];
		}
		else if(pose == DEFENCE_POSE_VERTICAL)
		{
			z += def_TypeData[def_ItemTypeDefenceType[defenceitemtype]][def_placeOffsetZ];
			rx = def_TypeData[def_ItemTypeDefenceType[defenceitemtype]][def_verticalRotX];
			ry = def_TypeData[def_ItemTypeDefenceType[defenceitemtype]][def_verticalRotY];
			rz += def_TypeData[def_ItemTypeDefenceType[defenceitemtype]][def_verticalRotZ];
		}

		SetItemPos(itemid, x, y, z);
		SetItemRot(itemid, rx, ry, rz);

		log("[CONSTRUCT] %p Built defence %d (%s) (%d, %f, %f, %f, %f, %f, %f)",
			playerid, itemid, geid, GetItemTypeModel(GetItemType(itemid)), x, y, z, rx, ry, rz);

		CallLocalFunction("OnDefenceCreate", "d", itemid);
		StopBuildingDefence(playerid);

        def_TweakArrow[playerid] = CreateDynamicObject(19133, x, y, z, 0.0, 0.0, 0.0, GetItemWorld(itemid), GetItemInterior(itemid));
        
		//AttachDynamicObjectToObject(def_TweakArrow[playerid], objectid, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0);
		
		_UpdateDefenceTweakArrow(playerid, itemid, x, y, z, rx, ry, rz);
		
		TweakItem(playerid, itemid);
		
		return Y_HOOKS_BREAK_RETURN_0;
	}

	if(def_CurrentDefenceEdit[playerid] != -1)
	{
		new
			itemid,
			ItemType:itemtype;

		itemid = GetPlayerItem(playerid);
		itemtype = GetItemType(itemid);

		if(itemtype == item_Motor)
		{
			ShowActionText(playerid, ls(playerid, "item/defence/motor-installed"));
			SetItemArrayDataAtCell(def_CurrentDefenceEdit[playerid], true, def_motor);

			CallLocalFunction("OnDefenceModified", "d", def_CurrentDefenceEdit[playerid]);

			DestroyItem(itemid);
			ClearAnimations(playerid);
		}

		if(itemtype == item_Keypad)
		{
			ShowActionText(playerid, ls(playerid, "item/defence/keypad-installed"));
			ShowSetPassDialog_Keypad(playerid);
			SetItemArrayDataAtCell(def_CurrentDefenceEdit[playerid], 1, def_keypad);

			CallLocalFunction("OnDefenceModified", "d", def_CurrentDefenceEdit[playerid]);

			DestroyItem(itemid);
			ClearAnimations(playerid);
		}

		if(itemtype == item_AdvancedKeypad)
		{
			ShowActionText(playerid, ls(playerid, "item/defence/advanced-keypad-installed"));
			ShowSetPassDialog_KeypadAdv(playerid);
			SetItemArrayDataAtCell(def_CurrentDefenceEdit[playerid], 2, def_keypad);
			CallLocalFunction("OnDefenceModified", "d", def_CurrentDefenceEdit[playerid]);

			DestroyItem(itemid);
			ClearAnimations(playerid);
		}

		if(itemtype == item_Crowbar)
		{
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

hook OnPlayerKeypadEnter(playerid, keypadid, code, match)
{
	if(keypadid == 100)
	{
		if(def_CurrentDefenceEdit[playerid] != -1)
		{
			SetItemArrayDataAtCell(def_CurrentDefenceEdit[playerid], code, def_pass);
			CallLocalFunction("OnDefenceModified", "d", def_CurrentDefenceEdit[playerid]);
			HideKeypad(playerid);

			def_CurrentDefenceEdit[playerid] = -1;

			if(code == 0)
				ChatMsg(playerid, YELLOW, "item/defence/code-zero");

			return Y_HOOKS_BREAK_RETURN_1;
		}

		if(def_CurrentDefenceOpen[playerid] != -1)
		{
			if(code == match)
			{
				ShowActionText(playerid, ls(playerid, "item/defence/moving"), 3000);
				defer MoveDefence(def_CurrentDefenceOpen[playerid], playerid);
				def_CurrentDefenceOpen[playerid] = -1;
			}
			else
			{
				if(GetTickCountDifference(GetTickCount(), def_LastPassEntry[playerid]) < def_Cooldown[playerid])
				{
					ShowEnterPassDialog_Keypad(playerid, 2);
					return Y_HOOKS_BREAK_RETURN_0;
				}

				if(def_PassFails[playerid] == 5)
				{
					def_Cooldown[playerid] += 4000;
					def_PassFails[playerid] = 0;
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


_UpdateDefenceTweakArrow(playerid, itemid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
    SetDynamicObjectPos(def_TweakArrow[playerid], x, y, z);
    
	if(GetItemArrayDataAtCell(itemid, def_pose) == DEFENCE_POSE_VERTICAL)
	{
		SetDynamicObjectRot(def_TweakArrow[playerid],
			rx - def_TypeData[def_ItemTypeDefenceType[GetItemType(itemid)]][def_verticalRotX] + 90,
			ry - def_TypeData[def_ItemTypeDefenceType[GetItemType(itemid)]][def_verticalRotY],
			rz - def_TypeData[def_ItemTypeDefenceType[GetItemType(itemid)]][def_verticalRotZ]);
	}
	else
	{
		SetDynamicObjectRot(def_TweakArrow[playerid],
			rx - def_TypeData[def_ItemTypeDefenceType[GetItemType(itemid)]][def_horizontalRotX],
			ry - def_TypeData[def_ItemTypeDefenceType[GetItemType(itemid)]][def_horizontalRotY],
			rz - def_TypeData[def_ItemTypeDefenceType[GetItemType(itemid)]][def_horizontalRotZ]);
	}
}

hook OnItemTweakUpdate(playerid, itemid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz)
{
	if(def_TweakArrow[playerid] != INVALID_OBJECT_ID)
		_UpdateDefenceTweakArrow(playerid, itemid, x, y, z, rx, ry, rz);
}

hook OnItemTweakFinish(playerid, itemid)
{
	if(def_TweakArrow[playerid] != INVALID_OBJECT_ID)
	{
	    new
			Float:x,
			Float:y,
			Float:z,
			Float:rx,
			Float:ry,
			Float:rz;

		GetItemPos(itemid, x, y, z);
		GetItemRot(itemid, rx, ry, rz);
		
		CA_DestroyObject(def_Col[itemid]);
		def_Col[itemid] = CA_CreateObject(GetItemTypeModel(GetItemType(itemid)), x, y, z, rx, ry, rz, true);

		DestroyDynamicObject(def_TweakArrow[playerid]);
		def_TweakArrow[playerid] = INVALID_OBJECT_ID;
		CallLocalFunction("OnDefenceModified", "d", itemid);
	}
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

ShowEnterPassDialog_Keypad(playerid, msg = 0)
{
	if(msg == 0) ChatMsg(playerid, YELLOW, "item/defence/enter-code");
	else if(msg == 1) ChatMsg(playerid, YELLOW, "item/defence/incorrect-code");
	else if(msg == 2) ChatMsg(playerid, YELLOW, "item/defence/code-fast", MsToString(def_Cooldown[playerid] - GetTickCountDifference(GetTickCount(), def_LastPassEntry[playerid]), "%m:%s"));

	ShowKeypad(playerid, 100, GetItemArrayDataAtCell(def_CurrentDefenceOpen[playerid], def_pass));
}

ShowSetPassDialog_KeypadAdv(playerid){
	Dialog_Show(playerid, SetPassAdv, DIALOG_STYLE_INPUT, "Digite a senha", "Digite uma senha entre 4 e 8 caracteres usando os caracteres de 0 a 9, a-f.", "Confirmar", "");
	return 1;
}

Dialog:SetPassAdv(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new pass;

		if(!sscanf(inputtext, "x", pass) && strlen(inputtext) >= 4)
		{
			SetItemArrayDataAtCell(def_CurrentDefenceEdit[playerid], pass, def_pass);
			CallLocalFunction("OnDefenceModified", "d", def_CurrentDefenceEdit[playerid]);
			def_CurrentDefenceEdit[playerid] = -1;
		}
		else ShowSetPassDialog_KeypadAdv(playerid);
	}
	else ShowSetPassDialog_KeypadAdv(playerid);
}

ShowEnterPassDialog_KeypadAdv(playerid, msg = 0)
{
	if(msg == 2) ChatMsg(playerid, YELLOW, "item/defence/code-fast", MsToString(def_Cooldown[playerid] - GetTickCountDifference(GetTickCount(), def_LastPassEntry[playerid]), "%m:%s"));

	Dialog_Show(playerid, EnterPassAdv, DIALOG_STYLE_INPUT, "Digite a senha", (msg == 1) ? ("Senha incorreta") : ("Digite a senha hexadecimal de 4 a 8 caracteres para abrir."), "Confirmar", "Cancelar");

	return 1;
}

Dialog:EnterPassAdv(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new pass;

		sscanf(inputtext, "x", pass);

		if(pass == GetItemArrayDataAtCell(def_CurrentDefenceOpen[playerid], def_pass) && strlen(inputtext) >= 4)
		{
			ShowActionText(playerid, ls(playerid, "item/defence/moving"), 3000);
			defer MoveDefence(def_CurrentDefenceOpen[playerid], playerid);
			def_CurrentDefenceOpen[playerid] = -1;
		}
		else
		{
			if(GetTickCountDifference(GetTickCount(), def_LastPassEntry[playerid]) < def_Cooldown[playerid])
			{
				ShowEnterPassDialog_KeypadAdv(playerid, 2);
				return 1;
			}

			if(def_PassFails[playerid] == 5)
			{
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
	}
	else return 0;

	return 1;
}

timer MoveDefence[500](itemid, playerid)
{
	new
		Float:px,
		Float:py,
		Float:pz,
		Float:ix,
		Float:iy,
		Float:iz;

	GetItemPos(itemid, ix, iy, iz);

	foreach(new i : Player)
	{
		GetPlayerPos(i, px, py, pz);

		if(Distance(px, py, pz, ix, iy, iz) < 3.0)
		{
			defer MoveDefence(itemid, playerid);

			return;
		}
	}

	new
	    ItemType:itemtype = GetItemType(itemid),
	    objectid = GetItemObjectID(itemid),
		Float:rx,
		Float:ry,
		Float:rz;

	GetItemRot(itemid, rx, ry, rz);

	if(GetItemArrayDataAtCell(itemid, def_pose) == DEFENCE_POSE_HORIZONTAL)
	{
		MoveDynamicObject(objectid, ix, iy, iz, 0.9, rx, ry, rz);
        
		SetItemArrayDataAtCell(itemid, DEFENCE_POSE_VERTICAL, def_pose);
	}
	else
	{
		rx = def_TypeData[def_ItemTypeDefenceType[itemtype]][def_horizontalRotX];
		ry = def_TypeData[def_ItemTypeDefenceType[itemtype]][def_horizontalRotY];
		rz += def_TypeData[def_ItemTypeDefenceType[itemtype]][def_horizontalRotZ];
		iz -= def_TypeData[def_ItemTypeDefenceType[itemtype]][def_placeOffsetZ];

        MoveDynamicObject(objectid, ix, iy, iz, 0.9, rx, ry, rz);

		SetItemArrayDataAtCell(itemid, DEFENCE_POSE_HORIZONTAL, def_pose);
	}
	
	CA_DestroyObject(def_Col[itemid]);
 	def_Col[itemid] = CA_CreateObject(GetItemTypeModel(GetItemType(itemid)), ix, iy, iz, rx, ry, rz, true);

	return;
}

hook OnItemHitPointsUpdate(itemid, oldvalue, newvalue)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(def_ItemTypeDefenceType[itemtype] != -1) {
	    new itemtypename[ITM_MAX_NAME];
		GetItemTypeName(def_TypeData[def_ItemTypeDefenceType[itemtype]][def_itemtype], itemtypename);
		SetItemLabel(itemid, sprintf("%s\n%d/%d", itemtypename, newvalue, GetItemTypeMaxHitPoints(itemtype)), 0xFFFF00FF, 5.0, false);

	}
}

hook OnItemDestroy(itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(def_ItemTypeDefenceType[itemtype] != -1)
	{
	    CA_DestroyObject(def_Col[itemid]);
		if(GetItemHitPoints(itemid) <= 0)
		{
			new
				Float:x,
				Float:y,
				Float:z,
				Float:rx,
				Float:ry,
				Float:rz;

			GetItemPos(itemid, x, y, z);
			GetItemRot(itemid, rx, ry, rz);

			log("[DESTRUCTION] Defence %d (%d) Object: (%d, %f, %f, %f, %f, %f, %f)", itemid, _:itemtype, GetItemTypeModel(itemtype), x, y, z, rx, ry, rz);
			CallLocalFunction("OnDefenceDestroy", "d", itemid);
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

hook OnPlayerEnterButtonArea(playerid, buttonid)
{
	if(!IsPlayerOnAdminDuty(playerid) && IsPlayerSpawned(playerid))
	{
		new
			defencetype,
			Float:angle;

		foreach(new i : def_Index)
		{
			if(
				(!GetDefenceMotor(i) && GetDefencePose(i) == DEFENCE_POSE_VERTICAL) ||
				(GetDefenceMotor(i) && GetDefencePose(i) == DEFENCE_POSE_VERTICAL) )
			{
				defencetype = def_ItemTypeDefenceType[GetItemType(i)];

				GetItemRot(i, angle, angle, angle);

				angle = absoluteangle((angle - def_TypeData[defencetype][def_verticalRotZ]) - GetButtonAngleToPlayer(playerid, GetItemButtonID(i)));

				if(angle < 90.0 || angle > 270.0)
				{
					stop def_AngleCheckTimer[playerid];
					def_CurrentCheckDefence[playerid] = i;
					def_AngleCheckTimer[playerid] = repeat DefenceAngleCheck(playerid, i);
				}
			}
		}
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerLeaveButtonArea(playerid, buttonid)
{
	foreach(new i : def_Index)
	{
		if(def_CurrentCheckDefence[playerid] == i)
			stop def_AngleCheckTimer[playerid];
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDisconnect(playerid, reason){
    stop def_AngleCheckTimer[playerid];
}

timer DefenceAngleCheck[100](playerid, itemid)
{
    new
		defencetype,
		Float:angle,
		Float:x,
		Float:y,
		Float:z;
		
	GetItemPos(itemid, x, y, z);
	defencetype = def_ItemTypeDefenceType[GetItemType(itemid)];

	GetItemRot(itemid, angle, angle, angle);

	angle = absoluteangle((angle - def_TypeData[defencetype][def_verticalRotZ]) - GetButtonAngleToPlayer(playerid, GetItemButtonID(itemid)));
	
	if(120.0 < angle < 250.0)
	{
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

/*==============================================================================

	Interface functions

==============================================================================*/


stock IsValidDefenceType(type)
{
	if(0 <= type < def_TypeTotal)
		return 1;

	return 0;
}

stock GetItemTypeDefenceType(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return INVALID_DEFENCE_TYPE;

	return def_ItemTypeDefenceType[itemtype];
}

stock IsItemTypeDefence(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return false;

	if(def_ItemTypeDefenceType[itemtype] != -1)
		return true;

	return false;
}

// def_itemtype
forward ItemType:GetDefenceTypeItemType(defencetype);
stock ItemType:GetDefenceTypeItemType(defencetype)
{
	if(!(0 <= defencetype < def_TypeTotal))
		return INVALID_ITEM_TYPE;

	return def_TypeData[defencetype][def_itemtype];
}

// def_verticalRotX
// def_verticalRotY
// def_verticalRotZ
stock GetDefenceTypeVerticalRot(defencetype, &Float:x, &Float:y, &Float:z)
{
	if(!(0 <= defencetype < def_TypeTotal))
		return 0;

	x = def_TypeData[defencetype][def_verticalRotX];
	y = def_TypeData[defencetype][def_verticalRotY];
	z = def_TypeData[defencetype][def_verticalRotZ];

	return 1;
}

// def_horizontalRotX
// def_horizontalRotY
// def_horizontalRotZ
stock GetDefenceTypeHorizontalRot(defencetype, &Float:x, &Float:y, &Float:z)
{
	if(!(0 <= defencetype < def_TypeTotal))
		return 0;

	x = def_TypeData[defencetype][def_horizontalRotX];
	y = def_TypeData[defencetype][def_horizontalRotY];
	z = def_TypeData[defencetype][def_horizontalRotZ];

	return 1;
}

// def_placeOffsetZ
forward Float:GetDefenceTypeOffsetZ(defencetype);
stock Float:GetDefenceTypeOffsetZ(defencetype)
{
	if(!(0 <= defencetype < def_TypeTotal))
		return 0.0;

	return def_TypeData[defencetype][def_placeOffsetZ];
}

// def_type
stock GetDefenceType(itemid)
{
	if(!IsValidItem(itemid))
		return 0;

	return def_ItemTypeDefenceType[GetItemType(itemid)];
}

// def_pose
stock GetDefencePose(itemid)
{
	return GetItemArrayDataAtCell(itemid, def_pose);
}

// def_motor
stock GetDefenceMotor(itemid)
{
	return GetItemArrayDataAtCell(itemid, def_motor);
}

//def_active
stock GetDefenceActive(itemid)
{
	return GetItemArrayDataAtCell(itemid, def_active);
}

// def_keypad
stock GetDefenceKeypad(itemid)
{
	return GetItemArrayDataAtCell(itemid, def_keypad);
}

// def_pass
stock GetDefencePass(itemid)
{
	return GetItemArrayDataAtCell(itemid, def_pass);
}