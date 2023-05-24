#include <YSI\y_hooks>

#define MAX_MASK_ITEMS	(25)

enum E_MASK_SKIN_DATA {
Float:		mask_offsetX,
Float:		mask_offsetY,
Float:		mask_offsetZ,
Float:		mask_rotX,
Float:		mask_rotY,
Float:		mask_rotZ,
Float:		mask_scaleX,
Float:		mask_scaleY,
Float:		mask_scaleZ
}


static
ItemType:	mask_ItemType[MAX_MASK_ITEMS],
			mask_Data[MAX_MASK_ITEMS][MAX_SKINS][E_MASK_SKIN_DATA],
			mask_Total,
			mask_ItemTypeMask[ITM_MAX_TYPES] = {-1, ...},
			mask_CurrentMaskItem[MAX_PLAYERS];

DefineMaskItem(ItemType:itemType) {
	mask_ItemType[mask_Total] = itemType;
	mask_ItemTypeMask[itemType] = mask_Total;

	return mask_Total++;
}

SetMaskOffsetsForSkin(maskId, skinId, Float:offsetx, Float:offsety, Float:offsetz, Float:rotx, Float:roty, Float:rotz, Float:scalex, Float:scaley, Float:scalez) {
	if(!(0 <= maskId < mask_Total)) return 0;

	mask_Data[maskId][skinId][mask_offsetX] = offsetx;
	mask_Data[maskId][skinId][mask_offsetY] = offsety;
	mask_Data[maskId][skinId][mask_offsetZ] = offsetz;
	mask_Data[maskId][skinId][mask_rotX]    = rotx;
	mask_Data[maskId][skinId][mask_rotY]    = roty;
	mask_Data[maskId][skinId][mask_rotZ]    = rotz;
	mask_Data[maskId][skinId][mask_scaleX]  = scalex;
	mask_Data[maskId][skinId][mask_scaleY]  = scaley;
	mask_Data[maskId][skinId][mask_scaleZ]  = scalez;

	return 1;
}

SetPlayerMaskItem(playerId, itemId) {
	if(!IsValidItem(itemId)) return 0;

	new ItemType:itemType = GetItemType(itemId);

	if(!IsValidItemType(itemType)) return 0;

	new maskId = mask_ItemTypeMask[itemType];

	if(maskId == -1) return 0;

	new skinId = GetPlayerClothes(playerId); 
	if(!GetClothesMaskStatus(skinId)) return 0;

    skinId = GetPlayerSkin(playerId);
    
	SetPlayerAttachedObject(
		playerId, ATTACHSLOT_FACE, GetItemTypeModel(itemType), 2,
		mask_Data[maskId][skinId][mask_offsetX], mask_Data[maskId][skinId][mask_offsetY], mask_Data[maskId][skinId][mask_offsetZ],
		mask_Data[maskId][skinId][mask_rotX], mask_Data[maskId][skinId][mask_rotY], mask_Data[maskId][skinId][mask_rotZ],
		mask_Data[maskId][skinId][mask_scaleX], mask_Data[maskId][skinId][mask_scaleY], mask_Data[maskId][skinId][mask_scaleZ]);

	if(mask_CurrentMaskItem[playerId] == itemId) return 1;
	    
	RemoveItemFromWorld(itemId);
	RemoveCurrentItem(GetItemHolder(itemId));

	if(IsValidItem(mask_CurrentMaskItem[playerId])) GiveWorldItemToPlayer(playerId, mask_CurrentMaskItem[playerId]);

	mask_CurrentMaskItem[playerId] = itemId;

	return 1;
}

RemovePlayerMaskItem(playerId) {
	RemovePlayerAttachedObject(playerId, ATTACHSLOT_FACE);
	mask_CurrentMaskItem[playerId] = -1;

	return mask_CurrentMaskItem[playerId];
}

stock IsValidMask(maskId) {
	if(!(0 <= maskId < mask_Total)) return 0;

	return 1;
}

forward ItemType:GetItemTypeFromMask(maskId);
stock ItemType:GetItemTypeFromMask(maskId) {
	if(!(0 <= maskId < mask_Total)) return INVALID_ITEM_TYPE;

	return mask_ItemType[maskId];
}

GetMaskFromItem(ItemType:itemType) {
	if(!IsValidItemType(itemType)) return -1;

	return mask_ItemTypeMask[itemType];
}

GetPlayerMaskItem(playerId) {
	if(!IsPlayerConnected(playerId)) return INVALID_ITEM_ID;

	return mask_CurrentMaskItem[playerId];
}

hook OnPlayerConnect(playerId) mask_CurrentMaskItem[playerId] = -1;

hook OnPlayerUseItem(playerId, itemId) {
	sprintf("[MASKS] OnPlayerUseItem(%p, %d)", playerId, itemId);

	if(SetPlayerMaskItem(playerId, itemId)) CancelPlayerMovement(playerId);

	return Y_HOOKS_CONTINUE_RETURN_0;
}