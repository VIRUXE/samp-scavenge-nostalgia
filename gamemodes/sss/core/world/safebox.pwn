
/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2017 Barnaby "Southclaws" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/#include <YSI\y_hooks>

#define MAX_SAFEBOX_TYPE	(12)
#define MAX_SAFEBOX_NAME	(32)


enum E_SAFEBOX_TYPE_DATA
{
ItemType:	box_itemtype,
			box_size,
			box_display,
			box_animate
}

static
			box_TypeData[MAX_SAFEBOX_TYPE][E_SAFEBOX_TYPE_DATA],
			box_TypeTotal,
			box_ItemTypeBoxType[ITM_MAX_TYPES] = {-1, ...},
			box_ContainerSafebox[CNT_MAX] = {INVALID_ITEM_ID, ...};

static
			box_CurrentBoxItem[MAX_PLAYERS];


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnPlayerConnect(playerid)
{
	

	box_CurrentBoxItem[playerid] = INVALID_ITEM_ID;
}


/*==============================================================================

	Core

==============================================================================*/


DefineSafeboxType(ItemType:itemtype, size, displayonuse = true, animateonuse = true)
{
	if(box_TypeTotal == MAX_SAFEBOX_TYPE)
		return -1;

	SetItemTypeMaxArrayData(itemtype, 1);

	box_TypeData[box_TypeTotal][box_itemtype]	= itemtype;
	box_TypeData[box_TypeTotal][box_size]		= size;
	box_TypeData[box_TypeTotal][box_display]	= displayonuse;
	box_TypeData[box_TypeTotal][box_animate]	= animateonuse;

	box_ItemTypeBoxType[itemtype] = box_TypeTotal;

	return box_TypeTotal++;
}


/*==============================================================================

	Internal

==============================================================================*/


hook OnItemCreate(itemid)
{


	new ItemType:itemtype = GetItemType(itemid);

	if(box_ItemTypeBoxType[itemtype] != -1)
	{
		if(itemtype == box_TypeData[box_ItemTypeBoxType[itemtype]][box_itemtype])
		{
			new
				name[ITM_MAX_NAME],
				containerid;

			GetItemTypeName(itemtype, name);

			containerid = CreateContainer(name, box_TypeData[box_ItemTypeBoxType[itemtype]][box_size]);

			box_ContainerSafebox[containerid] = itemid;

			SetItemArrayDataSize(itemid, 1);
			SetItemArrayDataAtCell(itemid, containerid, 0);
		}
	}
}

hook OnItemDestroy(itemid)
{


	new ItemType:itemtype = GetItemType(itemid);

	if(box_ItemTypeBoxType[itemtype] != -1)
	{
		if(itemtype == box_TypeData[box_ItemTypeBoxType[itemtype]][box_itemtype])
		{
			new containerid = GetItemArrayDataAtCell(itemid, 0);

			DestroyContainer(containerid);
			box_ContainerSafebox[containerid] = INVALID_ITEM_ID;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}


/*==============================================================================

	Player interaction

==============================================================================*/
/*
hook OnPlayerPickUpItem(playerid, itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(box_ItemTypeBoxType[itemtype] != -1)
	{
		new Float:x, Float:y, Float:z;
	    for(new i; i < ITM_MAX; i++)
		{
		    if(!IsValidItem(i)) continue;
	        GetItemPos(i, x, y, z);
	        if(GetPlayerDistanceFromPoint(playerid, x, y, z) < 20.0){
			    if(IsValidTent(GetTentID(i))){
					if(!CheckPlayerTent(playerid, i)) return Y_HOOKS_BREAK_RETURN_1;
			    }
			    else if(IsItemTypeDefence(GetItemType(i)) && GetDefenceActive(i)){
			        if(!CheckPlayerDefence(playerid, i)) return Y_HOOKS_BREAK_RETURN_1;
			    }
		    }
		}
		new name[25];
		GetItemName(itemid, name);
    	SetItemLabel(itemid, sprintf("%s", name));
	}

	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnPlayerDropItem(playerid, itemid)
{
	new ItemType:itemtype = GetItemType(itemid);

	if(box_ItemTypeBoxType[itemtype] != -1)
	{
	    new name[25];
		GetItemName(itemid, name);
		
        new Float:x, Float:y, Float:z;
	    for(new i; i < ITM_MAX; i++)
		{
		    if(!IsValidItem(i)) continue;
	        GetItemPos(i, x, y, z);
	        if(GetPlayerDistanceFromPoint(playerid, x, y, z) < 20.0){
			    if(IsValidTent(GetTentID(i))){
					if(CheckPlayerTent(playerid, i)) {
					    ChatMsg(playerid, GREEN, " > Você dropou um item proximo de uma tenda e ele foi protegido.");
						SetItemLabel(itemid, sprintf("%s", name), GREEN);
					}
					else {
					    ChatMsg(playerid, RED, " > Você não pode dropar esse item aqui.");
					    return Y_HOOKS_BREAK_RETURN_1;
					}
			    }
			    else if(IsItemTypeDefence(GetItemType(i)) && GetDefenceActive(i)){
			        if(CheckPlayerDefence(playerid, i)){
			            ChatMsg(playerid, GREEN, " > Você dropou um item proximo de uma defesa e ele foi protegido.");
						SetItemLabel(itemid, sprintf("%s", name), GREEN);
					}
					else {
					    ChatMsg(playerid, RED, " > Você não pode dropar esse item aqui.");
					    return Y_HOOKS_BREAK_RETURN_1;
					}
			    }
		    }
		}
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}
*/
hook OnPlayerUseItem(playerid, itemid)
{


	new ItemType:itemtype = GetItemType(itemid);

	if(box_ItemTypeBoxType[itemtype] != -1)
	{
		if(IsValidContainer(GetPlayerCurrentContainer(playerid)))
			return Y_HOOKS_CONTINUE_RETURN_0;

		if(IsItemInWorld(itemid))
		{
			if(_DisplaySafeboxDialog(playerid, itemid, box_TypeData[box_ItemTypeBoxType[itemtype]][box_animate]))
				return Y_HOOKS_BREAK_RETURN_1;
		}

		else
		{
			if(_DisplaySafeboxDialog(playerid, itemid, false))
				return Y_HOOKS_BREAK_RETURN_1;
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid)
{


	new ItemType:itemtype = GetItemType(withitemid);

	if(box_ItemTypeBoxType[itemtype] != -1)
	{
		if(_DisplaySafeboxDialog(playerid, withitemid, box_TypeData[box_ItemTypeBoxType[itemtype]][box_animate]))
			return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_DisplaySafeboxDialog(playerid, itemid, animation)
{
	if(!box_TypeData[box_ItemTypeBoxType[GetItemType(itemid)]][box_display])
		return 0;

	if(GetItemType(itemid) == item_Locker && GetItemType(GetPlayerItem(playerid)) == item_Crowbar)
	    return 0;

    if( (gServerMaxUptime - gServerUptime) < 61 && !gServerRestarting){
        ChatMsg(playerid, RED, " > Servidor vai reiniciar em instantes, Você não pode fazer isto agora.");
        return Y_HOOKS_BREAK_RETURN_1;
    }
            
	/*new Float:x, Float:y, Float:z;
    for(new i; i < ITM_MAX; i++)
	{
 		if(!IsValidItem(i)) continue;
        GetItemPos(i, x, y, z);
        if(GetPlayerDistanceFromPoint(playerid, x, y, z) < 20.0){
		    if(IsValidTent(GetTentID(i))){
				if(!CheckPlayerTent(playerid, i)) {
				    ChatMsg(playerid, RED, "");
					ChatMsg(playerid, RED, " > Você não tem permissÃ£o nesta caixa.");
			        ChatMsg(playerid, RED, " > Chame um admin para liberÃ¡-la pra Você usando "C_YELLOW"/Relatorio");
					PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
					ChatMsg(playerid, RED, "");
					return 0;
				}
		    }
		    else if(IsItemTypeDefence(GetItemType(i)) && GetDefenceActive(i)){
		        if(!CheckPlayerDefence(playerid, i)){
	             	ChatMsg(playerid, RED, "");
					ChatMsg(playerid, RED, " > Você não tem permissÃ£o nesta caixa.");
			        ChatMsg(playerid, RED, " > Chame um admin para liberÃ¡-la pra Você usando "C_YELLOW"/Relatorio");
					PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);
					ChatMsg(playerid, RED, "");
					return 0;
				}
		    }
	    }
	}*/
	
	DisplayContainerInventory(playerid, GetItemArrayDataAtCell(itemid, 0));
	box_CurrentBoxItem[playerid] = itemid;

	if(animation)
		ApplyAnimation(playerid, "BOMBER", "BOM_PLANT_IN", 4.0, 0, 0, 0, 1, 0);

	else
		CancelPlayerMovement(playerid);

	return 1;
}

stock GetPlayerCurrentBoxItem(playerid)
{
	return box_CurrentBoxItem[playerid];
}

hook OnPlayerCloseContainer(playerid, containerid)
{
	if(IsValidItem(box_CurrentBoxItem[playerid]))
	{
		CancelPlayerMovement(playerid);
		box_CurrentBoxItem[playerid] = INVALID_ITEM_ID;
	}
}


/*==============================================================================

	Interface

==============================================================================*/


stock IsItemTypeSafebox(ItemType:itemtype)
{
	if(!IsValidItemType(itemtype))
		return 0;

	if(box_ItemTypeBoxType[itemtype] != -1)
		return 1;

	return 0;
}

stock GetContainerSafeboxItem(containerid)
{
	if(!IsValidContainer(containerid))
		return INVALID_ITEM_ID;

	return box_ContainerSafebox[containerid];
}

stock IsItemTypeExtraDataDependent(ItemType:itemtype)
{
	if(IsItemTypeBag(itemtype))
		return 1;

	if(box_ItemTypeBoxType[itemtype] != -1)
		return 1;

	if(itemtype == item_Campfire)
		return 1;

	if(itemtype == item_Barbecue)
		return 1;

	if(itemtype == item_TentPack)
		return 1;

	return 0;
}
