#include <YSI\y_hooks>

// Directory for storing player-saved vehicles
#define DIRECTORY_VEHICLE			DIRECTORY_MAIN"vehicle/"

enum
{
	VEH_CELL_TYPE,		// 00
	VEH_CELL_HEALTH,	// 01
	VEH_CELL_FUEL,		// 02
	VEH_CELL_POSX,		// 03
	VEH_CELL_POSY,		// 04
	VEH_CELL_POSZ,		// 05
	VEH_CELL_ROTZ,		// 06
	VEH_CELL_COL1,		// 07
	VEH_CELL_COL2,		// 08
	VEH_CELL_PANELS,	// 09
	VEH_CELL_DOORS,		// 10
	VEH_CELL_LIGHTS,	// 11
	VEH_CELL_TIRES,		// 12
	VEH_CELL_ARMOUR,	// 13
	VEH_CELL_KEY,		// 14
	VEH_CELL_LOCKED,	// 15
	VEH_CELL_END
}

forward OnVehicleSave(vehicleid);

hook OnScriptInit()
{
	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_VEHICLE);
}

hook OnGameModeInit()
{
	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_VEHICLE);

	new
		dir:direc = dir_open(DIRECTORY_SCRIPTFILES DIRECTORY_VEHICLE),
		item[28],
		type;

	while(dir_list(direc, item, type))
	{
		if(type == FM_FILE)
		{
			if(!(4 < strlen(item) < GEID_LEN + 5))
			{
				err("File with a bad filename length: '%s' len: %d", item, strlen(item));
				continue;
			}

			if(strfind(item, ".dat", false, 3) == -1)
			{
				err("File with invalid extension: '%s'", item);
				continue;
			}

			LoadPlayerVehicle(item);
		}
	}

	dir_close(direc);

	log("[VEHICLE] %d veículos de jogador carregados.", Iter_Count(veh_Index));
}

/*==============================================================================

	Load vehicle (individual)

==============================================================================*/


LoadPlayerVehicle(filename[])
{
	// TODO: move this directory formatting to the load loop.
	new
		filepath[64],
		data[VEH_CELL_END],
		length,
		geid[GEID_LEN];

	filepath = DIRECTORY_VEHICLE;
	strcat(filepath, filename);

	length = modio_read(filepath, _T<A,C,T,V>, 1, data, false, false);

	if(length < 0)
	{
		err("modio error %d in '%s'.", length, filename);
		modio_finalise_read(modio_getsession_read(filepath));
		return 0;
	}

	if(length == 1)
	{
		if(data[0] == 0)
		{
			dbg("gamemodes/sss/core/vehicle/player-vehicle.pwn", 1, "Vehicle set to inactive (file: %s)", filename);
			modio_finalise_read(modio_getsession_read(filepath));
			return 0;
		}
	}

	length = modio_read(filepath, _T<D,A,T,A>, sizeof(data), data, false, false);

	if(length == 0)
	{
		modio_finalise_read(modio_getsession_read(filepath));
		err("modio_read returned length of 0.");
		return 0;
	}

	if(!IsValidVehicleType(data[VEH_CELL_TYPE]))
	{
		err("Removing vehicle file '%s' invalid vehicle type '%d'.", filename, data[VEH_CELL_TYPE]);
		fremove(filepath);
		modio_finalise_read(modio_getsession_read(filepath));
		return 0;
	}

	new vehiclename[MAX_VEHICLE_TYPE_NAME];
	GetVehicleTypeName(data[VEH_CELL_TYPE], vehiclename);

	if(Float:data[VEH_CELL_HEALTH] < 255.5)
	{
		err("Removing vehicle file: '%s' (%s) due to low health.", filename, vehiclename);
		fremove(filepath);
		modio_finalise_read(modio_getsession_read(filepath));
		return 0;
	}

	new category = GetVehicleTypeCategory(data[VEH_CELL_TYPE]);

	if(category != VEHICLE_CATEGORY_BOAT)
	{
		if(!IsPointInMapBounds(Float:data[VEH_CELL_POSX], Float:data[VEH_CELL_POSY], Float:data[VEH_CELL_POSZ]))
		{
			if(category == VEHICLE_CATEGORY_HELICOPTER || category == VEHICLE_CATEGORY_PLANE) data[VEH_CELL_POSZ] = _:(Float:data[VEH_CELL_POSZ] + 10.0);
			else
			{
				err("Removing vehicle file: %s (%s) because it's out of the map bounds.", filename, vehiclename);
				fremove(filepath);
				modio_finalise_read(modio_getsession_read(filepath));
				return 0;
			}
		}
	}

	modio_read(filepath, _T<G,E,I,D>, sizeof(geid), geid, false, false);

	new vehicleid = CreateWorldVehicle(
		data[VEH_CELL_TYPE],
		Float:data[VEH_CELL_POSX],
		Float:data[VEH_CELL_POSY],
		Float:data[VEH_CELL_POSZ],
		Float:data[VEH_CELL_ROTZ],
		data[VEH_CELL_COL1],
		data[VEH_CELL_COL2],
		_,
		geid);

	if(!IsValidVehicle(vehicleid))
	{
		err("Created vehicle returned invalid ID (%d)", vehicleid);
		modio_finalise_read(modio_getsession_read(filepath));
		return 0;
	}

	SetVehicleSpawnPoint(vehicleid,
		Float:data[VEH_CELL_POSX],
		Float:data[VEH_CELL_POSY],
		Float:data[VEH_CELL_POSZ],
		Float:data[VEH_CELL_ROTZ]);

	Iter_Add(veh_Index, vehicleid);

	if(Float:data[VEH_CELL_HEALTH] > 990.0) data[VEH_CELL_HEALTH] = _:990.0;

	SetVehicleHP(vehicleid, Float:data[VEH_CELL_HEALTH]);
	SetVehicleFuel(vehicleid, Float:data[VEH_CELL_FUEL]);
	SetVehicleDamageData(vehicleid, data[VEH_CELL_PANELS], data[VEH_CELL_DOORS], data[VEH_CELL_LIGHTS], data[VEH_CELL_TIRES]);
	SetVehicleColours(vehicleid, data[VEH_CELL_COL1], data[VEH_CELL_COL2]);
	SetVehicleKey(vehicleid, data[VEH_CELL_KEY]);

	SetVehicleExternalLock(vehicleid, E_LOCK_STATE:data[VEH_CELL_LOCKED]);

	new
		containerid,
		trunksize;

	trunksize = GetVehicleTypeTrunkSize(data[VEH_CELL_TYPE]);

	length = modio_read(filepath, _T<T,D,A,T>, sizeof(data), data, false, false);

	/*if(length > 0)
	{
		new
			trailerid,
			trailertrunksize,
			trailername[MAX_VEHICLE_TYPE_NAME],
			trailergeid[GEID_LEN];

		GetVehicleTypeName(data[VEH_CELL_TYPE], trailername);

		modio_read(filepath, _T<T,G,E,I>, sizeof(trailergeid), trailergeid, false, false);

		trailerid = CreateWorldVehicle(
			data[VEH_CELL_TYPE],
			Float:data[VEH_CELL_POSX],
			Float:data[VEH_CELL_POSY],
			Float:data[VEH_CELL_POSZ],
			Float:data[VEH_CELL_ROTZ],
			data[VEH_CELL_COL1],
			data[VEH_CELL_COL2],
			_,
			trailergeid);

		trailertrunksize = GetVehicleTypeTrunkSize(data[VEH_CELL_TYPE]);

		SetVehicleTrailer(vehicleid, trailerid);

		SetVehicleSpawnPoint(trailerid,
			Float:data[VEH_CELL_POSX],
			Float:data[VEH_CELL_POSY],
			Float:data[VEH_CELL_POSZ],
			Float:data[VEH_CELL_ROTZ]);

		Iter_Add(veh_Index, trailerid);

		SetVehicleHealth(trailerid, Float:data[VEH_CELL_HEALTH]);
		SetVehicleFuel(trailerid, Float:data[VEH_CELL_FUEL]);
		SetVehicleDamageData(trailerid, data[VEH_CELL_PANELS], data[VEH_CELL_DOORS], data[VEH_CELL_LIGHTS], data[VEH_CELL_TIRES]);
		SetVehicleKey(trailerid, data[VEH_CELL_KEY]);

		SetVehicleExternalLock(trailerid, E_LOCK_STATE:data[VEH_CELL_LOCKED]);

		new itemcount;

		if(trailertrunksize > 0)
		{
			new
				ItemType:itemtype,
				itemid;

			length = modio_read(filepath, _T<T,T,R,N>, ITEM_SERIALIZER_RAW_SIZE, itm_arr_Serialized, false, false);
		
			if(!DeserialiseItems(itm_arr_Serialized, length, false))
			{
				itemcount = GetStoredItemCount();

				containerid = GetVehicleContainer(trailerid);

				for(new i; i < itemcount; i++)
				{
					itemtype = GetStoredItemType(i);

					if(itemtype == INVALID_ITEM_TYPE)
						break;

					if(itemtype == ItemType:0)
						break;

					itemid = CreateItem(itemtype);

					if(!IsItemTypeSafebox(itemtype) && !IsItemTypeBag(itemtype))
						SetItemArrayDataFromStored(itemid, i);

					AddItemToContainer(containerid, itemid);
				}

				ClearSerializer();
			}
		}
	}*/

	new itemcount;

	if(trunksize > 0)
	{
		dbg("gamemodes/sss/core/vehicle/player-vehicle.pwn", 1, "[LoadPlayerVehicle] trunk size: %d", trunksize);

		new
			ItemType:itemtype,
			itemid;

		length = modio_read(filepath, _T<T,R,N,K>, ITEM_SERIALIZER_RAW_SIZE, itm_arr_Serialized, true);

		if(!DeserialiseItems(itm_arr_Serialized, length, false))
		{
			itemcount = GetStoredItemCount();

			containerid = GetVehicleContainer(vehicleid);

			dbg("gamemodes/sss/core/vehicle/player-vehicle.pwn", 1, "[LoadPlayerVehicle] modio read length:%d items:%d", length, itemcount);

			for(new i; i < itemcount; i++)
			{
				itemtype = GetStoredItemType(i);

				dbg("gamemodes/sss/core/vehicle/player-vehicle.pwn", 2, "[LoadPlayerVehicle] item %d/%d type:%d", i, itemcount, _:itemtype);

				if(itemtype == INVALID_ITEM_TYPE) break;

				if(itemtype == ItemType:0) break;

				itemid = CreateItem(itemtype);
				dbg("gamemodes/sss/core/vehicle/player-vehicle.pwn", 2, "[LoadPlayerVehicle] created item:%d container:%d", itemid, containerid);

				if(!IsItemTypeSafebox(itemtype) && !IsItemTypeBag(itemtype)) SetItemArrayDataFromStored(itemid, i);

				AddItemToContainer(containerid, itemid);
			}

			ClearSerializer();
		}
	}
	return 1;
}

_SaveVehicle(vehicleid)
{
	if(CallLocalFunction("OnVehicleSave", "d", vehicleid))
	{
		printf("[_SaveVehicle] OnVehicleSave returned non-zero [%d]", vehicleid);
		return 0;
	}

	new
		filename[GEID_LEN + 22],
		session,
		vehiclename[MAX_VEHICLE_TYPE_NAME],
		active[1],
		data[VEH_CELL_END],
		geid[GEID_LEN];

	format(filename, sizeof(filename), DIRECTORY_VEHICLE"%s.dat", GetVehicleGEID(vehicleid));

	session = modio_getsession_write(filename);

	if(session != -1) modio_close_session_write(session);

	active[0] = !IsVehicleDead(vehicleid);
	modio_push(filename, _T<A,C,T,V>, 1, active);

	GetVehicleTypeName(GetVehicleType(vehicleid), vehiclename);

	data[VEH_CELL_TYPE] = GetVehicleType(vehicleid);

	GetVehicleHealth(vehicleid, Float:data[1]);

	data[VEH_CELL_FUEL] = _:GetVehicleFuel(vehicleid);
	GetVehiclePos(vehicleid, Float:data[VEH_CELL_POSX], Float:data[VEH_CELL_POSY], Float:data[VEH_CELL_POSZ]);
	GetVehicleZAngle(vehicleid, Float:data[VEH_CELL_ROTZ]);
	GetVehicleColours(vehicleid, data[VEH_CELL_COL1], data[VEH_CELL_COL2]);
	GetVehicleDamageStatus(vehicleid, data[VEH_CELL_PANELS], data[VEH_CELL_DOORS], data[VEH_CELL_LIGHTS], data[VEH_CELL_TIRES]);
	data[VEH_CELL_KEY] = GetVehicleKey(vehicleid);

	if(!IsVehicleOccupied(vehicleid)) data[VEH_CELL_LOCKED] = _:GetVehicleLockState(vehicleid);

	modio_push(filename, _T<D,A,T,A>, VEH_CELL_END, data);

	geid = GetVehicleGEID(vehicleid);
	modio_push(filename, _T<G,E,I,D>, GEID_LEN, geid);

	// Now do trailers with the same modio parameters

	new trailerid = GetVehicleTrailerID(vehicleid);

	if(IsValidVehicle(trailerid))
	{
		new
			containerid = GetVehicleContainer(trailerid),
			trailergeid[GEID_LEN];

		data[VEH_CELL_TYPE] = GetVehicleType(trailerid);
		GetVehicleHealth(trailerid, Float:data[VEH_CELL_HEALTH]);
		data[VEH_CELL_FUEL] = _:0.0;
		GetVehiclePos(trailerid, Float:data[VEH_CELL_POSX], Float:data[VEH_CELL_POSY], Float:data[VEH_CELL_POSZ]);
		GetVehicleZAngle(trailerid, Float:data[VEH_CELL_ROTZ]);
		GetVehicleColours(trailerid, data[VEH_CELL_COL1], data[VEH_CELL_COL2]);
		GetVehicleDamageStatus(trailerid, data[VEH_CELL_PANELS], data[VEH_CELL_DOORS], data[VEH_CELL_LIGHTS], data[VEH_CELL_TIRES]);
		data[VEH_CELL_KEY] = GetVehicleKey(trailerid);
		data[VEH_CELL_LOCKED] = _:GetVehicleLockState(trailerid);

		// TDAT = Trailer Data
		modio_push(filename, _T<T,D,A,T>, VEH_CELL_END, data);

		// TGEI = Trailer GEID
		trailergeid = GetVehicleGEID(trailerid);
		modio_push(filename, _T<T,G,E,I>, GEID_LEN, trailergeid);

		new itemcount;

		if(IsValidContainer(containerid))
		{
			new items[64];

			for(new i, j = GetContainerSize(containerid); i < j; i++)
			{
				items[i] = GetContainerSlotItem(containerid, i);

				if(!IsValidItem(items[i])) break;

				itemcount++;
			}

			if(!SerialiseItems(items, itemcount))
			{
				// TTRN = Trailer Trunk
				modio_push(filename, _T<T,T,R,N>, GetSerialisedSize(), itm_arr_Serialized);
				ClearSerializer();
			}
		}

		GetVehicleTypeName(GetVehicleType(trailerid), vehiclename);
	}

	new containerid = GetVehicleContainer(vehicleid);

	if(!IsValidContainer(containerid))
	{
		modio_close_session_write(modio_getsession_write(filename));
		return 1;
	}

	new
		items[64],
		itemcount;

	for(new i, j = GetContainerSize(containerid); i < j; i++)
	{
		items[i] = GetContainerSlotItem(containerid, i);

		if(!IsValidItem(items[i])) break;

		itemcount++;
	}

	if(!SerialiseItems(items, itemcount))
	{
		modio_push(filename, _T<T,R,N,K>, GetSerialisedSize(), itm_arr_Serialized);
		ClearSerializer();
	}

	if(active[0])
	{
		log("[VEHICLE][SAVE] Veículo %s (%s; %d) - Fechado: %s com %d itens -> %.2f, %.2f, %.2f",
			geid, vehiclename, vehicleid, (_:GetVehicleLockState(vehicleid) ? "Sim" : "Não"), itemcount, Float:data[VEH_CELL_POSX], Float:data[VEH_CELL_POSY], Float:data[VEH_CELL_POSZ]);
	}
	else log("[VEHICLE][DELETE] Removendo veículo de jogador: %d.", vehicleid);
	
	return 1;
}


/*==============================================================================

	Internal functions and hooks

==============================================================================*/


hook OnPlayerStateChange(playerid, newstate, oldstate)
{
    new vehiclename[MAX_VEHICLE_TYPE_NAME];
    
	if(newstate == PLAYER_STATE_DRIVER)
	{
		GetVehicleTypeName(GetVehicleType(GetPlayerVehicleID(playerid)), vehiclename);
		ShowActionText(playerid, sprintf(GetLanguageString(GetPlayerLanguage(playerid), "common/empty"), vehiclename), 5000);
		_SaveVehicle(GetPlayerVehicleID(playerid));
	}

	if(oldstate == PLAYER_STATE_DRIVER)
	{
		if(GetTickCountDifference(GetTickCount(), GetPlayerVehicleEnterTick(playerid)) > 1000)
		{
		    GetVehicleTypeName(GetVehicleType(GetPlayerLastVehicle(playerid)), vehiclename);
			ShowActionText(playerid, sprintf(GetLanguageString(GetPlayerLanguage(playerid), "common/empty"), vehiclename), 5000);
			_SaveVehicle(GetPlayerLastVehicle(playerid));
		}
	}

	return 1;
}

hook OnVehicleDestroyed(vehicleid)
{
	_SaveVehicle(vehicleid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

/*==============================================================================

	Interface

==============================================================================*/


stock SaveVehicle(vehicleid)
{
	_SaveVehicle(vehicleid);

	return 1;
}
