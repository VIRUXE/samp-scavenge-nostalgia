#include <YSI\y_hooks>


/*==============================================================================

	Setup

==============================================================================*/


#define MAX_WATER_MACHINE			(32)
#define MAX_WATER_MACHINE_ITEMS		(12)
#define MAX_WATER_MACHINE_FUEL		(80.0)
#define WATER_MACHINE_FUEL_USAGE	(3.5)


enum E_WATER_MACHINE_DATA
{
			wm_machineId,
Float:		wm_fuel,
bool:		wm_cooking,
			wm_smoke,
			wm_cookTime,
			wm_startTime
}


static
			wm_Data[MAX_WATER_MACHINE][E_WATER_MACHINE_DATA],
			wm_Total,

			wm_MachineWaterMachine[MAX_MACHINE] = {-1, ...},

			wm_CurrentWaterMachine[MAX_PLAYERS];


/*==============================================================================

	Zeroing

==============================================================================*/


hook OnPlayerConnect(playerid)
{
	

	wm_CurrentWaterMachine[playerid] = -1;
}


/*==============================================================================

	Core Functions

==============================================================================*/


stock CreateWaterMachine(Float:x, Float:y, Float:z, Float:rz)
{
	if(wm_Total == MAX_WATER_MACHINE - 1)
	{
		err("MAX_WATER_MACHINE Limit reached.");
		return 0;
	}

	wm_Data[wm_Total][wm_machineId] = CreateMachine(943, x, y, z, rz, "Máquina de Purificação", "Pressione "KEYTEXT_INTERACT" para acessar a máquima~n~Segure "KEYTEXT_INTERACT" para abrir o menu~n~Use gasolina para adicionar combustível", MAX_WATER_MACHINE_ITEMS);

	wm_MachineWaterMachine[wm_Data[wm_Total][wm_machineId]] = wm_Total;

	return wm_Total++;
}


/*==============================================================================

	Internal Functions and Hooks

==============================================================================*/


hook OnPlayerUseMachine(playerid, machineid, interactiontype)
{


	if(wm_MachineWaterMachine[machineid] != -1)
	{

		if(wm_Data[wm_MachineWaterMachine[machineid]][wm_machineId] == machineid)
		{
			_wm_PlayerUseWaterMachine(playerid, wm_MachineWaterMachine[machineid], interactiontype);
		}
		else
		{
			err("WaterMachine bi-directional link error. wm_MachineWaterMachine wm_machineId = %d machineid = %d");
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_wm_PlayerUseWaterMachine(playerid, watermachineid, interactiontype)
{


	if(wm_Data[watermachineid][wm_cooking])
	{
		ShowActionText(playerid, sprintf(ls(playerid, "item/machines/refinement/processing"), MsToString(wm_Data[watermachineid][wm_cookTime] - GetTickCountDifference(GetTickCount(), wm_Data[watermachineid][wm_startTime]), "%m minutos %s segundos")), 8000);
		return 0;
	}

	if(interactiontype == 0)
	{
		DisplayContainerInventory(playerid, GetMachineContainerID(wm_Data[watermachineid][wm_machineId]));
		return 0;
	}

	wm_CurrentWaterMachine[playerid] = watermachineid;

	new
		ItemType:itemtype = GetItemType(GetPlayerItem(playerid));

	if(GetItemTypeLiquidContainerType(itemtype) != -1)
	{
		if(GetLiquidItemLiquidType(GetPlayerItem(playerid)) == liquid_Petrol)
		{
			StartHoldAction(playerid, floatround(MAX_WATER_MACHINE_FUEL * 1000), floatround(wm_Data[watermachineid][wm_fuel] * 1000));
			return 0;
		}
	}

	Dialog_Show(playerid, WaterMachine, DIALOG_STYLE_MSGBOX, "Máquina de Purificação", sprintf("Pressione 'Iniciar' para ativar a máquina de purificação.\n\n"C_GREEN"Quantidade de Combustível: "C_WHITE"%.1f", wm_Data[watermachineid][wm_fuel]), "Iniciar", "Cancelar");

	return 0;
}

Dialog:WaterMachine(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new ret = _wm_StartCooking(watermachineid);

		if(ret == 0)
			ShowActionText(playerid, ls(playerid, "item/machines/refinement/no-items"), 5000);

		else if(ret == -1)
			ShowActionText(playerid, ls(playerid, "item/machines/refinement/server-restart"), 6000);

		else if(ret == -2)
			ShowActionText(playerid, sprintf(ls(playerid, "item/machines/refinement/not-enough-fuel"), WATER_MACHINE_FUEL_USAGE), 6000);

		else
			ShowActionText(playerid, sprintf(ls(playerid, "item/machines/refinement/cook-time"), MsToString(ret, "%m minutos %s segundos")), 6000);

		wm_CurrentWaterMachine[playerid] = -1;
	}
}

hook OnItemAddToContainer(containerid, itemid, playerid)
{


	if(playerid != INVALID_PLAYER_ID)
	{
		new machineid = GetContainerMachineID(containerid);

		if(machineid != INVALID_MACHINE_ID)
		{
			if(wm_MachineWaterMachine[machineid] != -1)
			{
				if(GetItemType(itemid) != item_ScrapMetal)
					return 1;
			}
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnHoldActionUpdate(playerid, progress)
{


	if(wm_CurrentWaterMachine[playerid] != -1)
	{


		new itemid = GetPlayerItem(playerid);

		if(GetItemTypeLiquidContainerType(GetItemType(itemid)) != -1)
		{
			if(GetLiquidItemLiquidType(itemid) != liquid_Petrol)
			{

				StopHoldAction(playerid);
				wm_CurrentWaterMachine[playerid] = -1;
				return Y_HOOKS_BREAK_RETURN_1;
			}
		}

		new
			Float:fuel = GetLiquidItemLiquidAmount(itemid),
			Float:transfer;

		if(fuel <= 0.0)
		{

			StopHoldAction(playerid);
			wm_CurrentWaterMachine[playerid] = -1;
			HideActionText(playerid);
		}
		else
		{

			transfer = (fuel - 1.1 < 0.0) ? fuel : 1.1;
			SetLiquidItemLiquidAmount(itemid, fuel - transfer);
			wm_Data[wm_CurrentWaterMachine[playerid]][wm_fuel] += 1.1;
			ShowActionText(playerid, ls(playerid, "item/machines/refinement/refueling"));
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_wm_StartCooking(watermachineid)
{

	new itemcount;

	for(new j = GetContainerSize(GetMachineContainerID(wm_Data[watermachineid][wm_machineId])); itemcount < j; itemcount++)
	{
		if(!IsContainerSlotUsed(GetMachineContainerID(wm_Data[watermachineid][wm_machineId]), itemcount))
			break;
	}

	if(itemcount == 0)
		return 0;

	// cook time = 60 seconds per item plus random 20 seconds
	new cooktime = (itemcount * 60) + random(20);


	// if there's not enough time left, don't allow a new cook to start.
	if(gServerUptime >= gServerMaxUptime - (cooktime * 1.5))
		return -1;

	if(wm_Data[watermachineid][wm_fuel] < WATER_MACHINE_FUEL_USAGE * itemcount)
		return -2;

	new
		Float:x,
		Float:y,
		Float:z;

	GetMachinePos(wm_Data[watermachineid][wm_machineId], x, y, z);

	cooktime *= 1000; // convert to ms


	wm_Data[watermachineid][wm_cooking] = true;
	DestroyDynamicObject(wm_Data[watermachineid][wm_smoke]);
	wm_Data[watermachineid][wm_smoke] = CreateDynamicObject(18726, x, y, z - 1.0, 0.0, 0.0, 0.0);
	wm_Data[watermachineid][wm_cookTime] = cooktime;
	wm_Data[watermachineid][wm_startTime] = GetTickCount();

	defer _wm_FinishCooking(watermachineid, cooktime);

	return cooktime;
}

timer _wm_FinishCooking[cooktime](watermachineid, cooktime)
{
#pragma unused cooktime

	new
		itemid,
		containerid = GetMachineContainerID(wm_Data[watermachineid][wm_machineId]),
		itemcount;

	for(new i = GetContainerItemCount(containerid) - 1; i > -1; i--)
	{
		itemid = GetContainerSlotItem(containerid, i);



		wm_Data[watermachineid][wm_fuel] -= WATER_MACHINE_FUEL_USAGE;

		DestroyItem(itemid);
		itemcount++;
	}

	for(new i; i < itemcount; i++)
	{
		itemid = CreateItem(item_Bottle);
		AddItemToContainer(containerid, itemid);
	}

	DestroyDynamicObject(wm_Data[watermachineid][wm_smoke]);
	wm_Data[watermachineid][wm_cooking] = false;
	wm_Data[watermachineid][wm_smoke] = INVALID_OBJECT_ID;
}