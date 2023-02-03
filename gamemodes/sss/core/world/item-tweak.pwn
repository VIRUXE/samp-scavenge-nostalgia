#include <YSI\y_hooks>

forward OnItemTweakUpdate(playerid, itemid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz);
forward OnItemTweakFinish(playerid, itemid);

static
		twk_Item[MAX_PLAYERS] = {INVALID_ITEM_ID, ...},
Float:	twk_pPos[MAX_PLAYERS][3],
		twk_MoveTick[MAX_PLAYERS];

hook OnPlayerConnect(playerid)
	twk_Item[playerid] = INVALID_ITEM_ID;
	
hook OnPlayerDisconnect(playerid, reason)
	TweakFinalise(playerid);

stock TweakItem(playerid, itemid){
	if(twk_Item[playerid] != INVALID_ITEM_ID)
		return 0;
	
	GetPlayerPos(playerid, twk_pPos[playerid][0], twk_pPos[playerid][1], twk_pPos[playerid][2]);
	
    EditDynamicObject(playerid, GetItemObjectID(itemid));
    
    twk_Item[playerid] = itemid;

	return 1;
}

stock TweakFinalise(playerid){
	if(twk_Item[playerid] != INVALID_ITEM_ID){
	    TweakResetItemPos(playerid);
        CallLocalFunction("OnItemTweakFinish", "dd", playerid, twk_Item[playerid]);
   		twk_Item[playerid] = INVALID_ITEM_ID;
//   		ShowHelpTip(playerid, "_");
   		CancelEdit(playerid);
//		HideHelpTip(playerid);
    }
    return 1;
}

// Anti Bug
hook OnPlayerUpdate(playerid){
    if(twk_Item[playerid] != INVALID_ITEM_ID){
    	if(GetTickCountDifference(GetTickCount(), twk_MoveTick[playerid]) > 2000)
			GetPlayerPos(playerid, twk_pPos[playerid][0], twk_pPos[playerid][1], twk_pPos[playerid][2]);
	}
	return 1;
}

// Corrigir posição do objeto
hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys){
	if( (newkeys & KEY_WALK) && twk_Item[playerid] != INVALID_ITEM_ID){
	    TweakResetItemPos(playerid);
	}
	return 1;
}

TweakResetItemPos(playerid){
    if(twk_Item[playerid] != INVALID_ITEM_ID){
	    new
			Float:x, Float:y, Float:z,
			Float:rx, Float:ry, Float:rz;

	    GetItemPos(twk_Item[playerid], x, y, z);
	    GetItemRot(twk_Item[playerid], rx, ry, rz);

	    SetItemPos(twk_Item[playerid], x, y, z);
	    SetItemRot(twk_Item[playerid], rx, ry, rz);
	    
	    CallLocalFunction("OnItemTweakUpdate", "ddffffff", playerid, twk_Item[playerid], x, y, z, rx, ry, rz);
    }
	return 1;
}

public OnPlayerEditDynamicObject(playerid, objectid, response, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz){
    twk_MoveTick[playerid] = GetTickCount();
    
	if(GetItemObjectID(twk_Item[playerid]) != objectid)
	    return 1;
	    
    new Float:ix, Float:iy, Float:iz;
	GetItemPos(twk_Item[playerid], ix, iy, iz);
	
    if(response == EDIT_RESPONSE_FINAL){
        if(Distance(x, y, z, ix, iy, iz) > 10.0){
            GetItemPos(twk_Item[playerid], x, y, z);
	    	GetItemRot(twk_Item[playerid], rx, ry, rz);
            ChatMsg(playerid, RED, " > Você moveu o item longe demais e a posição foi resetada.");
        }
	    SetItemPos(twk_Item[playerid], x, y, z);
	    SetItemRot(twk_Item[playerid], rx, ry, rz);
	    TweakFinalise(playerid);
	}
	else if(response == EDIT_RESPONSE_CANCEL){
     	GetItemPos(twk_Item[playerid], x, y, z);
	    GetItemRot(twk_Item[playerid], rx, ry, rz);

        SetItemPos(twk_Item[playerid], x, y, z);
	    SetItemRot(twk_Item[playerid], rx, ry, rz);
		ChatMsg(playerid, RED, " > Edição cancelada.");
		TweakFinalise(playerid);
	}
	else if(response == EDIT_RESPONSE_UPDATE){
	    CallLocalFunction("OnItemTweakUpdate", "ddffffff", playerid, twk_Item[playerid], x, y, z, rx, ry, rz);
   			
	    if(GetPlayerDistanceFromPoint(playerid, x, y, z) < 6.0){
		    SetPlayerVelocity(playerid, 0.0, 0.0, 0.0);
		    SetPlayerPos(playerid, twk_pPos[playerid][0], twk_pPos[playerid][1], twk_pPos[playerid][2]);
	    }
	    
		/*if(Distance(x, y, z, ix, iy, iz) > 8.0)
		    ShowHelpTip(playerid, "~r~Voce moveu muito longe do local de origem.");
		else
		    ShowHelpTip(playerid, "~y~Use a tecla ALT para voltar o objeto a sua posição original\
			~n~~y~Use ESPACO para mover a câmera~n~~y~~h~Esta proibido grifar a base de outros jogadores.");*/
	    
	}
	return 1;
}

stock twk_ItemPlayer(playerid)
	return twk_Item[playerid];
