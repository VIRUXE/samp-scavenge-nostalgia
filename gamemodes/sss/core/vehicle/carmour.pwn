#include <YSI_Coding\y_hooks>

#define MAX_CARMOUR			16
#define MAX_CARMOUR_PARTS	64

static enum E_ARMOUR_DATA {
			arm_vehicleType,
			arm_objCount
}


static enum E_ARMOUR_LIST_DATA {
			arm_model,
Float:		arm_posX,
Float:		arm_posY,
Float:		arm_posZ,
Float:		arm_rotX,
Float:		arm_rotY,
Float:		arm_rotZ
}


static
			arm_Data[MAX_CARMOUR][E_ARMOUR_DATA],
			arm_Objects[MAX_CARMOUR][MAX_CARMOUR_PARTS][E_ARMOUR_LIST_DATA],
   Iterator:arm_Index<MAX_CARMOUR>,
			arm_VehicleTypeCarmour[MAX_VEHICLE_TYPE] = {-1, ...};


hook OnGameModeInit() {
	new dir:carmourDir = dir_open("./scriptfiles/carmour");

	if(carmourDir == dir:0) {
		err("Erro lendo a diretoria do Carmour");
		return Y_HOOKS_CONTINUE_RETURN_0;
	}

	new entry[64], type;

	while(dir_list(carmourDir, entry, type)) {
		if(type != FM_FILE) continue;

		printf("[CARMOUR] Lendo \"%s\"...", entry);
		LoadOffsetsFromFile(entry);
	}

	dir_close(carmourDir);

	return Y_HOOKS_CONTINUE_RETURN_1;
}

hook OnVehicleCreated(vehicleId) {
	new vehicleType = GetVehicleType(vehicleId);

	if(arm_VehicleTypeCarmour[vehicleType] != -1) ApplyArmourToVehicle(vehicleId, arm_VehicleTypeCarmour[vehicleType]);

	return Y_HOOKS_CONTINUE_RETURN_0;
}

LoadOffsetsFromFile(fileName[]) {
	new filePath[64] = "carmour/";
	new const vehicleType = GetVehicleTypeFromName(fileName);

	strcat(filePath, fileName);

	if(!IsValidVehicleType(vehicleType)) {
		err("Vehicle type from name '%s' is invalid", fileName);
		return -1;
	}

	new
		id = Iter_Free(arm_Index), 
		listIndex;

	if(id == ITER_NONE) {
		err("[LoadOffsetsFromFile] id == ITER_NONE");
		return 0;
	}

	if(!fexist(filePath)) {
		err("[LoadOffsetsFromFile] File not found: '%s'", filePath);
		return 0;
	}

	new File:file = fopen(filePath, io_read);
	new line[128];

	while(fread(file, line)) {
		new model, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz;

		if(!sscanf(line, "p<,>dffffff", model, x, y, z, rx, ry, rz)) {
			if(listIndex >= MAX_CARMOUR_PARTS - 1) {
				err("Object limit reached while loading '%s'", fileName);
				break;
			}

			arm_Objects[id][listIndex][arm_model] = model;
			arm_Objects[id][listIndex][arm_posX]  = x;
			arm_Objects[id][listIndex][arm_posY]  = y;
			arm_Objects[id][listIndex][arm_posZ]  = z;
			arm_Objects[id][listIndex][arm_rotX]  = rx;
			arm_Objects[id][listIndex][arm_rotY]  = ry;
			arm_Objects[id][listIndex][arm_rotZ]  = rz;

			listIndex++;
		} else {
			printf("[CARMOUR] (%s) linha invalida: %s", fileName, line);
		}
	}

	fclose(file);

	arm_Data[id][arm_objCount]          = listIndex;
	arm_Data[id][arm_vehicleType]       = vehicleType;
	arm_VehicleTypeCarmour[vehicleType] = id;

	Iter_Add(arm_Index, id);

	return id;
}

ApplyArmourToVehicle(vehicleId, armourId) {
	if(!IsValidVehicle(vehicleId)) {
		err("Invalid vehicle ID (%d) passed to function.", vehicleId);
		return 0;
	}

	new vehicleType = GetVehicleType(vehicleId);

	if(vehicleType != arm_Data[armourId][arm_vehicleType]) {
		err("Vehicle type (%d) does not match carmour vehicle type (%d).", vehicleType, arm_Data[armourId][arm_vehicleType]);
		return 0;
	}

	for(new i; i < arm_Data[armourId][arm_objCount]; i++) {
		new objectId = CreateDynamicObject(arm_Objects[armourId][i][arm_model], 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);

		AttachDynamicObjectToVehicle(objectId, vehicleId,
			arm_Objects[armourId][i][arm_posX], arm_Objects[armourId][i][arm_posY], arm_Objects[armourId][i][arm_posZ],
			arm_Objects[armourId][i][arm_rotX], arm_Objects[armourId][i][arm_rotY], arm_Objects[armourId][i][arm_rotZ]);
	}

	return 1;
}