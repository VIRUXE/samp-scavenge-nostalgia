#include <YSI\y_hooks>

#define MAX_MACHINE_TYPE (4)

static
			mach_Total,
			mach_ItemTypeMachine[ITM_MAX_TYPES] = {-1, ...},

			mach_ContainerSize[MAX_MACHINE_TYPE] = {0, ...},
			mach_ContainerMachineItem[CNT_MAX] = {INVALID_ITEM_ID, ...},
			mach_CurrentMachine[MAX_PLAYERS],
			mach_MachineInteractTick[MAX_PLAYERS],
Timer:		mach_HoldTimer[MAX_PLAYERS];

forward OnPlayerUseMachine(playerid, itemid, interactiontype);

hook OnPlayerConnect(playerid) {
	mach_CurrentMachine[playerid] = INVALID_ITEM_ID;
}

stock DefineMachineType(ItemType:itemtype, arraydata, containersize) {
	SetItemTypeMaxArrayData(itemtype, arraydata);

	mach_ItemTypeMachine[itemtype] = mach_Total;
	mach_ContainerSize[mach_Total] = containersize;

	return mach_Total++;
}

hook OnItemCreate(itemid) {
	new machinetype = mach_ItemTypeMachine[GetItemType(itemid)];

	if(machinetype == -1) return Y_HOOKS_CONTINUE_RETURN_0;

	new name[ITM_MAX_NAME];

	GetItemName(itemid, PORTUGUESE, name);

	new containerid = CreateContainer(name, mach_ContainerSize[machinetype]);

	SetItemArrayDataAtCell(itemid, containerid, 0);
	mach_ContainerMachineItem[containerid] = itemid;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerPickUpItem(playerid, itemid) {
	if(mach_ItemTypeMachine[GetItemType(itemid)] != -1) {
		_mach_PlayerUseMachine(playerid, itemid);
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerUseItemWithItem(playerid, itemid, withitemid) {
	if(mach_ItemTypeMachine[GetItemType(withitemid)] != -1) {
		_mach_PlayerUseMachine(playerid, withitemid);
		return Y_HOOKS_BREAK_RETURN_1;
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_mach_PlayerUseMachine(playerid, itemid) {
	mach_CurrentMachine[playerid] = itemid;
	mach_MachineInteractTick[playerid] = GetTickCount();

	mach_HoldTimer[playerid] = defer _mach_HoldInteract(playerid);

	return 0;
}

hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	if(RELEASED(16)) {
		if(mach_CurrentMachine[playerid] != INVALID_ITEM_ID) {
			if(GetTickCountDifference(GetTickCount(), mach_MachineInteractTick[playerid]) < 250) {
				stop mach_HoldTimer[playerid];
				_mach_TapInteract(playerid);
			}
		}
	}

	return 1;
}

_mach_TapInteract(playerid) {
	if(mach_CurrentMachine[playerid] == INVALID_ITEM_ID) return;

	CallLocalFunction("OnPlayerUseMachine", "ddd", playerid, mach_CurrentMachine[playerid], 0);

	mach_CurrentMachine[playerid] = INVALID_ITEM_ID;
}

timer _mach_HoldInteract[250](playerid) {
	if(mach_CurrentMachine[playerid] == INVALID_ITEM_ID) return;

	CallLocalFunction("OnPlayerUseMachine", "ddd", playerid, mach_CurrentMachine[playerid], 1);

	mach_CurrentMachine[playerid] = INVALID_ITEM_ID;
}

stock GetItemTypeMachineType(ItemType:itemtype) {
	if(!IsValidItemType(itemtype)) return -1;

	return mach_ItemTypeMachine[itemtype];
}

stock GetMachineTypeContainerSize(machinetype) {
	if(!(0 <= machinetype < mach_Total)) return 0;

	return mach_ContainerSize[machinetype];
}

stock GetContainerMachineItem(containerid) {
	if(!IsValidContainer(containerid)) return -1;

	return mach_ContainerMachineItem[containerid];
}

stock GetPlayerCurrentMachine(playerid) {
	if(!IsPlayerConnected(playerid)) return -1;

	return mach_CurrentMachine[playerid];
}