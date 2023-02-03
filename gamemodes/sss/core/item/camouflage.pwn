#include <YSI\y_hooks>

static	camou_CurrentlyUsing[MAX_PLAYERS];
new camou_InventoryOption[MAX_PLAYERS];
new UsingCamuflagem[MAX_PLAYERS] = 0;

hook OnPlayerDisconnect(playerid){
	UsingCamuflagem[playerid] = 0;
}

// ==============================================================================

hook OnPlayerUseItem(playerid, itemid){
	if(GetItemType(itemid) == item_Camouflage)
		StartUseCamou(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

StartUseCamou(playerid){
	ApplyAnimation(playerid, "CASINO", "DEALONE", 4.0, 1, 0, 0, 0, 0);
	StartHoldAction(playerid, 5000);
	camou_CurrentlyUsing[playerid] = 1;
	return 1;
}

hook OnHoldActionFinish(playerid, itemid){
	if(camou_CurrentlyUsing[playerid] != -1){
		StopUseCamou(playerid);
		DestroyItem(GetPlayerItem(playerid));
		return Y_HOOKS_BREAK_RETURN_1;
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

StopUseCamou(playerid){
	ClearAnimations(playerid);
	StopHoldAction(playerid);
	EquipCamou(playerid);

	SetPlayerClothesID(playerid, skin_ArmyM);
	SetPlayerClothes(playerid, GetPlayerClothesID(playerid));
	camou_CurrentlyUsing[playerid] = -1;
	return 1;
}

EquipCamou(playerid){
	SetPlayerAttachedObject(playerid, 7, 800, 1, -0.4469, 0.0180, 0.0310, 0.0000, 89.0999, 0.0000, 0.2740, 0.2820, 0.5130); // genVEG_bush07 (ID: 800)
	UsingCamuflagem[playerid] = 1;
	return 1;
}

RemoveCamou(playerid){
	UsingCamuflagem[playerid] = 0;
	return 1;
}

IsUsingCamou(playerid){
	return UsingCamuflagem[playerid];
}

hook OnPlayerDeath(playerid){
	if(IsUsingCamou(playerid))
		RemoveCamou(playerid);

	return 1;
}

// ==============================================================================

hook OnPlayerOpenInventory(playerid){  
	if(IsUsingCamou(playerid)){
		camou_InventoryOption[playerid] = AddInventoryListItem(playerid, ls(playerid, "CAMUOPT"));
		return Y_HOOKS_CONTINUE_RETURN_0;
	}
	if(camou_CurrentlyUsing[playerid] != -1)
		StopUsingCamou(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerSelectExtraItem(playerid, item){
	if(item == camou_InventoryOption[playerid]){		
		if(!IsValidItem(GetPlayerItem(playerid))){
			if(!IsUsingCamou(playerid))
				return ClosePlayerInventory(playerid, true);

			RemoveCamou(playerid);

			SetPlayerClothesID(playerid, skin_Civ0M);
			SetPlayerClothes(playerid, GetPlayerClothesID(playerid));
			RemovePlayerAttachedObject(playerid, 7);

			new itemid = CreateItem(item_Camouflage);
			GiveWorldItemToPlayer(playerid, itemid);

			ClosePlayerInventory(playerid, true);
			return Y_HOOKS_BREAK_RETURN_1;
		}else{
			ShowActionText(playerid, "Não pode pois já está segurando um item.", 3000);
			ClosePlayerInventory(playerid, true);
		}
    }
	return Y_HOOKS_CONTINUE_RETURN_0;
}

// ==============================================================================

hook OnPlayerOpenContainer(playerid, containerid){
	if(camou_CurrentlyUsing[playerid] != -1)
		StopUsingCamou(playerid);
		
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerDropItem(playerid, itemid){
	if(camou_CurrentlyUsing[playerid] != -1)
		StopUsingCamou(playerid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnItemRemovedFromPlayer(playerid, itemid){
	if(camou_CurrentlyUsing[playerid] != -1)
		StopUsingCamou(playerid);
}

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger){
	if(camou_CurrentlyUsing[playerid] != -1)
		StopUsingCamou(playerid);

	return 1;
}

StopUsingCamou(playerid){
	camou_CurrentlyUsing[playerid] = -1;
	StopHoldAction(playerid);
	ClearAnimations(playerid);
}