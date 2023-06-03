#include <YSI\y_hooks>

// Directory for storing player-saved vehicles
#define DIRECTORY_VEHICLE			DIRECTORY_MAIN"vehicle/"

enum {
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

hook OnScriptInit() {
	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_VEHICLE);
}

hook OnGameModeInit() {
	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_VEHICLE);

	new
		dir:direc = dir_open(DIRECTORY_SCRIPTFILES DIRECTORY_VEHICLE),
		item[28],
		type;

	while(dir_list(direc, item, type)) {
		if(type == FM_FILE) {
			if(!(4 < strlen(item) < GEID_LEN + 5)) {
				err("File with a bad fileName length: '%s' len: %d", item, strlen(item));
				continue;
			}

			if(strfind(item, ".dat", false, 3) == -1) {
				err("File with invalid extension: '%s'", item);
				continue;
			}

			LoadPlayerVehicle(item);
		}
	}

	dir_close(direc);

	log("[VEHICLE] %d Veículos de jogador carregados.", Iter_Count(veh_Index));
}

LoadPlayerVehicle(fileName[]) {
	// TODO: move this directory formatting to the load loop.
	new
		filePath[64],
		data[VEH_CELL_END],
		length,
		geid[GEID_LEN];

	filePath = DIRECTORY_VEHICLE;
	strcat(filePath, fileName);

	length = modio_read(filePath, _T<A,C,T,V>, 1, data, false, false);

	if(length < 0) {
		err("modio error %d in '%s'.", length, fileName);
		modio_finalise_read(modio_getsession_read(filePath));
		return 0;
	}

	if(length == 1) {
		if(data[0] == 0) {
			modio_finalise_read(modio_getsession_read(filePath));
			return 0;
		}
	}

	length = modio_read(filePath, _T<D,A,T,A>, sizeof(data), data, false, false);

	if(length == 0) {
		modio_finalise_read(modio_getsession_read(filePath));
		err("modio_read returned length of 0.");
		return 0;
	}

	if(!IsValidVehicleType(data[VEH_CELL_TYPE])) {
		err("Removing vehicle file '%s' invalid vehicle type '%d'.", fileName, data[VEH_CELL_TYPE]);
		fremove(filePath);
		modio_finalise_read(modio_getsession_read(filePath));
		return 0;
	}

	new vehicleName[MAX_VEHICLE_TYPE_NAME];
	GetVehicleTypeName(data[VEH_CELL_TYPE], vehicleName);

	if(Float:data[VEH_CELL_HEALTH] < 255.5) {
		err("Removing vehicle file: '%s' (%s) due to low health.", fileName, vehicleName);
		fremove(filePath);
		modio_finalise_read(modio_getsession_read(filePath));
		return 0;
	}

	new category = GetVehicleTypeCategory(data[VEH_CELL_TYPE]);

	if(category != VEHICLE_CATEGORY_BOAT) {
		if(!IsPointInMapBounds(Float:data[VEH_CELL_POSX], Float:data[VEH_CELL_POSY], Float:data[VEH_CELL_POSZ])) {
			if(category == VEHICLE_CATEGORY_HELICOPTER || category == VEHICLE_CATEGORY_PLANE) 
				data[VEH_CELL_POSZ] = _:(Float:data[VEH_CELL_POSZ] + 10.0);
			else {
				err("Removing vehicle file: %s (%s) because it's out of the map bounds.", fileName, vehicleName);
				fremove(filePath);
				modio_finalise_read(modio_getsession_read(filePath));
				return 0;
			}
		}
	}

	modio_read(filePath, _T<G,E,I,D>, sizeof(geid), geid, false, false);

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

	if(!IsValidVehicle(vehicleid)) {
		err("Created vehicle returned invalid ID (%d)", vehicleid);
		modio_finalise_read(modio_getsession_read(filePath));
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
		containerId,
		trunkSize;

	trunkSize = GetVehicleTypeTrunkSize(data[VEH_CELL_TYPE]);

	length = modio_read(filePath, _T<T,D,A,T>, sizeof(data), data, false, false);

	/*if(length > 0) {
		new
			trailerId,
			trailertrunksize,
			trailername[MAX_VEHICLE_TYPE_NAME],
			trailergeid[GEID_LEN];

		GetVehicleTypeName(data[VEH_CELL_TYPE], trailername);

		modio_read(filePath, _T<T,G,E,I>, sizeof(trailergeid), trailergeid, false, false);

		trailerId = CreateWorldVehicle(
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

		SetVehicleTrailer(vehicleid, trailerId);

		SetVehicleSpawnPoint(trailerId,
			Float:data[VEH_CELL_POSX],
			Float:data[VEH_CELL_POSY],
			Float:data[VEH_CELL_POSZ],
			Float:data[VEH_CELL_ROTZ]);

		Iter_Add(veh_Index, trailerId);

		SetVehicleHealth(trailerId, Float:data[VEH_CELL_HEALTH]);
		SetVehicleFuel(trailerId, Float:data[VEH_CELL_FUEL]);
		SetVehicleDamageData(trailerId, data[VEH_CELL_PANELS], data[VEH_CELL_DOORS], data[VEH_CELL_LIGHTS], data[VEH_CELL_TIRES]);
		SetVehicleKey(trailerId, data[VEH_CELL_KEY]);

		SetVehicleExternalLock(trailerId, E_LOCK_STATE:data[VEH_CELL_LOCKED]);

		new itemCount;

		if(trailertrunksize > 0) {
			new
				ItemType:itemType,
				itemId;

			length = modio_read(filePath, _T<T,T,R,N>, ITEM_SERIALIZER_RAW_SIZE, itm_arr_Serialized, false, false);
		
			if(!DeserialiseItems(itm_arr_Serialized, length, false)) {
				itemCount = GetStoredItemCount();

				containerId = GetVehicleContainer(trailerId);

				for(new i; i < itemCount; i++)
				{
					itemType = GetStoredItemType(i);

					if(itemType == INVALID_ITEM_TYPE)
						break;

					if(itemType == ItemType:0)
						break;

					itemId = CreateItem(itemType);

					if(!IsItemTypeSafebox(itemType) && !IsItemTypeBag(itemType))
						SetItemArrayDataFromStored(itemId, i);

					AddItemToContainer(containerId, itemId);
				}

				ClearSerializer();
			}
		}
	}*/

	new itemCount;

	if(trunkSize > 0) {
		new
			ItemType:itemType,
			itemId;

		length = modio_read(filePath, _T<T,R,N,K>, ITEM_SERIALIZER_RAW_SIZE, itm_arr_Serialized, true);

		if(!DeserialiseItems(itm_arr_Serialized, length, false)) {
			itemCount = GetStoredItemCount();

			containerId = GetVehicleContainer(vehicleid);

			for(new i; i < itemCount; i++) {
				itemType = GetStoredItemType(i);

				if(itemType == INVALID_ITEM_TYPE) break;

				if(itemType == ItemType:0) break;

				itemId = CreateItem(itemType);

				if(!IsItemTypeSafebox(itemType) && !IsItemTypeBag(itemType)) SetItemArrayDataFromStored(itemId, i);

				AddItemToContainer(containerId, itemId);
			}

			ClearSerializer();
		}
	}
	return 1;
}

_SaveVehicle(vehicleid) {
	if(CallLocalFunction("OnVehicleSave", "d", vehicleid)) {
		printf("[_SaveVehicle] OnVehicleSave returned non-zero [%d]", vehicleid);
		return 0;
	}

	new
		fileName[GEID_LEN + 22],
		session,
		vehicleName[MAX_VEHICLE_TYPE_NAME],
		active[1],
		data[VEH_CELL_END],
		geid[GEID_LEN];

	format(fileName, sizeof(fileName), DIRECTORY_VEHICLE"%s.dat", GetVehicleGEID(vehicleid));

	session = modio_getsession_write(fileName);

	if(session != -1) modio_close_session_write(session);

	active[0] = !IsVehicleDead(vehicleid);
	modio_push(fileName, _T<A,C,T,V>, 1, active);

	GetVehicleTypeName(GetVehicleType(vehicleid), vehicleName);

	data[VEH_CELL_TYPE] = GetVehicleType(vehicleid);

	GetVehicleHealth(vehicleid, Float:data[1]);

	data[VEH_CELL_FUEL] = _:GetVehicleFuel(vehicleid);
	GetVehiclePos(vehicleid, Float:data[VEH_CELL_POSX], Float:data[VEH_CELL_POSY], Float:data[VEH_CELL_POSZ]);
	GetVehicleZAngle(vehicleid, Float:data[VEH_CELL_ROTZ]);
	GetVehicleColours(vehicleid, data[VEH_CELL_COL1], data[VEH_CELL_COL2]);
	GetVehicleDamageStatus(vehicleid, data[VEH_CELL_PANELS], data[VEH_CELL_DOORS], data[VEH_CELL_LIGHTS], data[VEH_CELL_TIRES]);
	data[VEH_CELL_KEY] = GetVehicleKey(vehicleid);

	if(!IsVehicleOccupied(vehicleid)) data[VEH_CELL_LOCKED] = _:GetVehicleLockState(vehicleid);

	modio_push(fileName, _T<D,A,T,A>, VEH_CELL_END, data);

	geid = GetVehicleGEID(vehicleid);
	modio_push(fileName, _T<G,E,I,D>, GEID_LEN, geid);

	// Now do trailers with the same modio parameters

	new trailerId = GetVehicleTrailerID(vehicleid);

	if(IsValidVehicle(trailerId)) {
		new
			containerId = GetVehicleContainer(trailerId),
			trailergeid[GEID_LEN];

		data[VEH_CELL_TYPE] = GetVehicleType(trailerId);
		GetVehicleHealth(trailerId, Float:data[VEH_CELL_HEALTH]);
		data[VEH_CELL_FUEL] = _:0.0;
		GetVehiclePos(trailerId, Float:data[VEH_CELL_POSX], Float:data[VEH_CELL_POSY], Float:data[VEH_CELL_POSZ]);
		GetVehicleZAngle(trailerId, Float:data[VEH_CELL_ROTZ]);
		GetVehicleColours(trailerId, data[VEH_CELL_COL1], data[VEH_CELL_COL2]);
		GetVehicleDamageStatus(trailerId, data[VEH_CELL_PANELS], data[VEH_CELL_DOORS], data[VEH_CELL_LIGHTS], data[VEH_CELL_TIRES]);
		data[VEH_CELL_KEY] = GetVehicleKey(trailerId);
		data[VEH_CELL_LOCKED] = _:GetVehicleLockState(trailerId);

		// TDAT = Trailer Data
		modio_push(fileName, _T<T,D,A,T>, VEH_CELL_END, data);

		// TGEI = Trailer GEID
		trailergeid = GetVehicleGEID(trailerId);
		modio_push(fileName, _T<T,G,E,I>, GEID_LEN, trailergeid);

		new itemCount;

		if(IsValidContainer(containerId)) {
			new items[64];

			for(new i, j = GetContainerSize(containerId); i < j; i++) {
				items[i] = GetContainerSlotItem(containerId, i);

				if(!IsValidItem(items[i])) break;

				itemCount++;
			}

			if(!SerialiseItems(items, itemCount)) {
				// TTRN = Trailer Trunk
				modio_push(fileName, _T<T,T,R,N>, GetSerialisedSize(), itm_arr_Serialized);
				ClearSerializer();
			}
		}

		GetVehicleTypeName(GetVehicleType(trailerId), vehicleName);
	}

	new containerId = GetVehicleContainer(vehicleid);

	if(!IsValidContainer(containerId)) {
		modio_close_session_write(modio_getsession_write(fileName));
		return 1;
	}

	new
		items[64],
		itemCount;

	for(new i, j = GetContainerSize(containerId); i < j; i++) {
		items[i] = GetContainerSlotItem(containerId, i);

		if(!IsValidItem(items[i])) break;

		itemCount++;
	}

	if(!SerialiseItems(items, itemCount)) {
		modio_push(fileName, _T<T,R,N,K>, GetSerialisedSize(), itm_arr_Serialized);
		ClearSerializer();
	}

	if(active[0]) {
		log("[VEHICLE][SAVE] Veículo %s (%s; %d) - Fechado: %s com %d itens -> %.2f, %.2f, %.2f",
			geid, vehicleName, vehicleid, (_:GetVehicleLockState(vehicleid) ? "Sim" : "Não"), itemCount, Float:data[VEH_CELL_POSX], Float:data[VEH_CELL_POSY], Float:data[VEH_CELL_POSZ]);
	}
	else log("[VEHICLE][DELETE] Removendo Veículo de jogador: %d.", vehicleid);
	
	return 1;
}

hook OnPlayerStateChange(playerid, newstate, oldstate) {
    new vehicleName[MAX_VEHICLE_TYPE_NAME];
    
	if(newstate == PLAYER_STATE_DRIVER) {
		GetVehicleTypeName(GetVehicleType(GetPlayerVehicleID(playerid)), vehicleName);
		ShowActionText(playerid, sprintf(ls(playerid, "vehicle/saved"), vehicleName), 5000);
		_SaveVehicle(GetPlayerVehicleID(playerid));
	}

	if(oldstate == PLAYER_STATE_DRIVER) {
		if(GetTickCountDifference(GetTickCount(), GetPlayerVehicleEnterTick(playerid)) > 1000) {
		    GetVehicleTypeName(GetVehicleType(GetPlayerLastVehicle(playerid)), vehicleName);
			ShowActionText(playerid, sprintf(ls(playerid, "vehicle/saved"), vehicleName), 5000);
			_SaveVehicle(GetPlayerLastVehicle(playerid));
		}
	}

	return 1;
}

hook OnVehicleDestroyed(vehicleid) {
	_SaveVehicle(vehicleid);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

stock SaveVehicle(vehicleid) {
	_SaveVehicle(vehicleid);

	return 1;
}