#include <YSI_Coding\y_hooks>


#define DIRECTORY_CARMOUR	"carmour/"
#define MAX_CARMOUR			(16)
#define MAX_CARMOUR_PARTS	(64)


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
	DirectoryCheck(DIRECTORY_SCRIPTFILES DIRECTORY_CARMOUR);

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

		if(!sscanf(line, "p<(>{s[20]}p<,>dfffffp<)>f{s[4]}", model, x, y, z, rx, ry, rz)) {
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


ACMD:steamroll[3](playerid) {
	new
		vehicleId = GetPlayerVehicleID(playerid),
		objects[42];

	objects[0]= CreateObject(2937, 0.000000, 4.390404, -0.374200, 0.000000, 90.000000, 90.000000);
	objects[1]= CreateObject(2937, 0.000000, 4.471110, -0.152799, 0.000000, 100.000000, 90.000000);
	objects[2]= CreateObject(2937, 0.000000, 4.465988, -0.705200, 0.000000, 80.000000, 90.000000);
	objects[3]= CreateObject(2937, 0.000000, 4.688470, 0.320199, 0.000000, 130.000000, 90.000000);
	objects[4]= CreateObject(2937, 0.000000, 4.687227, -1.162001, 0.000000, 50.000000, 90.000000);
	objects[5]= CreateObject(3280, -0.010742, 2.643554, 0.491387, 299.998168, 0.000000, 0.000000);
	objects[6]= CreateObject(2937, 0.000000, 4.529251, 0.114999, 0.000000, 120.000000, 90.000000);
	objects[7]= CreateObject(2937, 0.000000, 4.416649, -0.694400, 0.000000, 90.000000, 90.000000);
	objects[8]= CreateObject(2937, 0.000000, 4.583421, -1.118801, 0.000000, 45.000000, 90.000000);
	objects[9]= CreateObject(2937, 0.000000, 5.043893, -1.433601, 0.000000, 15.000000, 90.000000);
	objects[10]= CreateObject(2228, 1.365761, -0.890789, 0.439335, 0.000000, 0.000000, 270.000000);
	objects[11]= CreateObject(2237, 1.405730, -1.287106, 0.989490, 0.000000, 0.000000, 90.000000);
	objects[12]= CreateObject(1650, -1.050109, 2.775264, 0.423850, 0.000000, 0.000000, 90.000000);
	objects[13]= CreateObject(3280, -0.010742, 2.643554, 0.491387, 299.998168, 0.000000, 0.000000);
	objects[14]= CreateObject(16637, -0.023021, -3.615131, -0.001335, 0.000000, 270.000000, 0.000000);
	objects[15]= CreateObject(2937, -0.282178, -5.531250, -0.233243, 0.000000, 90.000000, 90.000000);
	objects[16]= CreateObject(2937, 0.238750, -5.531250, -0.233243, 0.000000, 90.000000, 90.000000);
	objects[17]= CreateObject(2937, 0.238281, -5.531250, -0.785643, 0.000000, 90.000000, 90.000000);
	objects[18]= CreateObject(2937, -0.277918, -5.531250, -0.785643, 0.000000, 90.000000, 90.000000);
	objects[19]= CreateObject(2937, 1.517475, -4.297450, -0.785643, 0.000000, 90.000000, 0.000000);
	objects[20]= CreateObject(2937, 1.516601, -2.915673, -0.246243, 0.000000, 90.000000, 0.000000);
	objects[21]= CreateObject(2937, 1.516601, -4.296875, -0.246243, 0.000000, 90.000000, 0.000000);
	objects[22]= CreateObject(2937, 1.516601, -2.915081, -0.785643, 0.000000, 90.000000, 0.000000);
	objects[23]= CreateObject(2937, -1.573002, -4.296875, -0.246243, 0.000000, 90.000000, 0.000000);
	objects[24]= CreateObject(2937, -1.572265, -4.296875, -0.773243, 0.000000, 90.000000, 0.000000);
	objects[25]= CreateObject(2937, -1.572265, -2.975073, -0.246243, 0.000000, 90.000000, 0.000000);
	objects[26]= CreateObject(2937, -1.572265, -2.942673, -0.773243, 0.000000, 90.000000, 0.000000);
	objects[27]= CreateObject(2937, -1.572265, -4.296875, 0.316956, 0.000000, 90.000000, 0.000000);
	objects[28]= CreateObject(2937, 1.516601, -4.296875, 0.302356, 0.000000, 90.000000, 0.000000);
	objects[29]= CreateObject(2937, 1.516601, -2.915039, 0.307756, 0.000000, 90.000000, 0.000000);
	objects[30]= CreateObject(2937, -1.572265, -2.974609, 0.316956, 0.000000, 90.000000, 0.000000);
	objects[31]= CreateObject(2937, -0.369265, -1.720812, 0.316956, 0.000000, 90.000000, 270.000000);
	objects[32]= CreateObject(2937, 0.283659, -1.720703, 0.322356, 0.000000, 90.000000, 270.000000);
	objects[33]= CreateObject(2937, 0.304802, -5.542497, 0.300756, 0.000000, 90.000000, 270.000000);
	objects[34]= CreateObject(2937, -0.402112, -5.541992, 0.300756, 0.000000, 90.000000, 270.000000);
	objects[35]= CreateObject(1238, -1.255923, -2.083270, 0.362627, 0.000000, 0.000000, 0.000000);
	objects[36]= CreateObject(1238, -0.710937, -2.083007, 0.362627, 0.000000, 0.000000, 310.374755);
	objects[37]= CreateObject(2048, -0.523728, -5.608830, 0.084074, 0.000000, 0.000000, 0.000000);
	objects[38]= CreateObject(1437, 1.566547, -1.533209, -0.279983, 0.004516, 270.674926, 100.176818);
	objects[39]= CreateObject(2690, 0.718220, -1.261309, 0.787263, 0.000000, 0.000000, 0.000000);
	objects[40]= CreateObject(2057, 1.059925, -2.126123, 0.214900, 0.000000, 0.000000, 320.299987);
	objects[41]= CreateObject(2674, 0.103544, -3.772953, 0.066187, 0.000000, 0.000000, 0.000000);

	AttachObjectToVehicle(objects[0], vehicleId, 0.000000, 4.390404, -0.374200, 0.000000, 90.000000, 90.000000);
	AttachObjectToVehicle(objects[1], vehicleId, 0.000000, 4.471110, -0.152799, 0.000000, 100.000000, 90.000000);
	AttachObjectToVehicle(objects[2], vehicleId, 0.000000, 4.465988, -0.705200, 0.000000, 80.000000, 90.000000);
	AttachObjectToVehicle(objects[3], vehicleId, 0.000000, 4.688470, 0.320199, 0.000000, 130.000000, 90.000000);
	AttachObjectToVehicle(objects[4], vehicleId, 0.000000, 4.687227, -1.162001, 0.000000, 50.000000, 90.000000);
	AttachObjectToVehicle(objects[5], vehicleId, -0.010742, 2.643554, 0.491387, 299.998168, 0.000000, 0.000000);
	AttachObjectToVehicle(objects[6], vehicleId, 0.000000, 4.529251, 0.114999, 0.000000, 120.000000, 90.000000);
	AttachObjectToVehicle(objects[7], vehicleId, 0.000000, 4.416649, -0.694400, 0.000000, 90.000000, 90.000000);
	AttachObjectToVehicle(objects[8], vehicleId, 0.000000, 4.583421, -1.118801, 0.000000, 45.000000, 90.000000);
	AttachObjectToVehicle(objects[9], vehicleId, 0.000000, 5.043893, -1.433601, 0.000000, 15.000000, 90.000000);
	AttachObjectToVehicle(objects[10], vehicleId, 1.365761, -0.890789, 0.439335, 0.000000, 0.000000, 270.000000);
	AttachObjectToVehicle(objects[11], vehicleId, 1.405730, -1.287106, 0.989490, 0.000000, 0.000000, 90.000000);
	AttachObjectToVehicle(objects[12], vehicleId, -1.050109, 2.775264, 0.423850, 0.000000, 0.000000, 90.000000);
	AttachObjectToVehicle(objects[13], vehicleId, -0.010742, 2.643554, 0.491387, 299.998168, 0.000000, 0.000000);
	AttachObjectToVehicle(objects[14], vehicleId, -0.023021, -3.615131, -0.001335, 0.000000, 270.000000, 0.000000);
	AttachObjectToVehicle(objects[15], vehicleId, -0.282178, -5.531250, -0.233243, 0.000000, 90.000000, 90.000000);
	AttachObjectToVehicle(objects[16], vehicleId, 0.238750, -5.531250, -0.233243, 0.000000, 90.000000, 90.000000);
	AttachObjectToVehicle(objects[17], vehicleId, 0.238281, -5.531250, -0.785643, 0.000000, 90.000000, 90.000000);
	AttachObjectToVehicle(objects[18], vehicleId, -0.277918, -5.531250, -0.785643, 0.000000, 90.000000, 90.000000);
	AttachObjectToVehicle(objects[19], vehicleId, 1.517475, -4.297450, -0.785643, 0.000000, 90.000000, 0.000000);
	AttachObjectToVehicle(objects[20], vehicleId, 1.516601, -2.915673, -0.246243, 0.000000, 90.000000, 0.000000);
	AttachObjectToVehicle(objects[21], vehicleId, 1.516601, -4.296875, -0.246243, 0.000000, 90.000000, 0.000000);
	AttachObjectToVehicle(objects[22], vehicleId, 1.516601, -2.915081, -0.785643, 0.000000, 90.000000, 0.000000);
	AttachObjectToVehicle(objects[23], vehicleId, -1.573002, -4.296875, -0.246243, 0.000000, 90.000000, 0.000000);
	AttachObjectToVehicle(objects[24], vehicleId, -1.572265, -4.296875, -0.773243, 0.000000, 90.000000, 0.000000);
	AttachObjectToVehicle(objects[25], vehicleId, -1.572265, -2.975073, -0.246243, 0.000000, 90.000000, 0.000000);
	AttachObjectToVehicle(objects[26], vehicleId, -1.572265, -2.942673, -0.773243, 0.000000, 90.000000, 0.000000);
	AttachObjectToVehicle(objects[27], vehicleId, -1.572265, -4.296875, 0.316956, 0.000000, 90.000000, 0.000000);
	AttachObjectToVehicle(objects[28], vehicleId, 1.516601, -4.296875, 0.302356, 0.000000, 90.000000, 0.000000);
	AttachObjectToVehicle(objects[29], vehicleId, 1.516601, -2.915039, 0.307756, 0.000000, 90.000000, 0.000000);
	AttachObjectToVehicle(objects[30], vehicleId, -1.572265, -2.974609, 0.316956, 0.000000, 90.000000, 0.000000);
	AttachObjectToVehicle(objects[31], vehicleId, -0.369265, -1.720812, 0.316956, 0.000000, 90.000000, 270.000000);
	AttachObjectToVehicle(objects[32], vehicleId, 0.283659, -1.720703, 0.322356, 0.000000, 90.000000, 270.000000);
	AttachObjectToVehicle(objects[33], vehicleId, 0.304802, -5.542497, 0.300756, 0.000000, 90.000000, 270.000000);
	AttachObjectToVehicle(objects[34], vehicleId, -0.402112, -5.541992, 0.300756, 0.000000, 90.000000, 270.000000);
	AttachObjectToVehicle(objects[35], vehicleId, -1.255923, -2.083270, 0.362627, 0.000000, 0.000000, 0.000000);
	AttachObjectToVehicle(objects[36], vehicleId, -0.710937, -2.083007, 0.362627, 0.000000, 0.000000, 310.374755);
	AttachObjectToVehicle(objects[37], vehicleId, -0.523728, -5.608830, 0.084074, 0.000000, 0.000000, 0.000000);
	AttachObjectToVehicle(objects[38], vehicleId, 1.566547, -1.533209, -0.279983, 0.004516, 270.674926, 100.176818);
	AttachObjectToVehicle(objects[39], vehicleId, 0.718220, -1.261309, 0.787263, 0.000000, 0.000000, 0.000000);
	AttachObjectToVehicle(objects[40], vehicleId, 1.059925, -2.126123, 0.214900, 0.000000, 0.000000, 320.299987);
	AttachObjectToVehicle(objects[41], vehicleId, 0.103544, -3.772953, 0.066187, 0.000000, 0.000000, 0.000000);

	return 1;
}

ACMD:armourcar[3](playerid)
{
	new
		vehicleId = GetPlayerVehicleID(playerid),
		ac[40];

	ac[0]= CreateObject(2669, -0.024414, -0.427734, 1.070683, 0.000000, 0.000000, 0.000000);
	ac[1]= CreateObject(1414, 1.562428, -3.864668, 0.663436, 0.000000, 354.234985, 90.000000);
	ac[2]= CreateObject(1414, -1.596330, -3.633904, 0.663436, 0.000000, 0.000000, 271.984985);
	ac[3]= CreateObject(1414, 1.484788, -3.250230, 0.663436, 0.000000, 0.000000, 90.000000);
	ac[4]= CreateObject(1414, -1.621130, -3.019910, 0.816905, 0.000000, 7.940002, 270.000000);
	ac[5]= CreateObject(1414, -1.677827, -0.487285, 1.047109, 0.000000, 354.042602, 270.000000);
	ac[6]= CreateObject(1414, 1.561523, -0.717773, 1.047109, 0.000000, 354.226684, 90.000000);
	ac[7]= CreateObject(1411, 0.589201, -0.488340, 2.574161, 90.000000, 90.000000, 0.000000);
	ac[8]= CreateObject(1411, -0.562153, -0.320397, 2.574161, 90.000000, 270.000000, 0.000000);
	ac[9]= CreateObject(3117, -0.088453, 5.272907, -0.786405, 308.433227, 0.000000, 1.984985);
	ac[10]= CreateObject(3302, 1.773437, 0.690429, 1.461668, 0.000000, 90.000000, 0.000000);
	ac[11]= CreateObject(3302, -1.602177, 0.920749, 1.077995, 0.000000, 90.000000, 0.000000);
	ac[12]= CreateObject(2937, 1.480766, -3.327510, -0.599208, 0.000000, 90.000000, 0.000000);
	ac[13]= CreateObject(2937, 1.477468, -3.319149, -1.145082, 0.000000, 90.000000, 0.000000);
	ac[14]= CreateObject(2937, -1.485089, -3.318359, -1.145082, 0.000000, 90.000000, 0.000000);
	ac[15]= CreateObject(2937, -1.484375, -3.318359, -0.603939, 0.000000, 90.000000, 0.000000);
	ac[16]= CreateObject(1308, 1.195017, 4.500000, -0.437594, 0.000000, 90.000000, 270.000000);
	ac[17]= CreateObject(3117, -0.011156, 3.661034, 1.644372, 340.190185, 0.000000, 1.983032);
	ac[18]= CreateObject(2678, 1.620639, 4.147448, -0.031380, 0.000000, 0.000000, 95.280029);
	ac[19]= CreateObject(2678, -0.987882, 4.734310, -0.031380, 0.000000, 0.000000, 182.614746);
	ac[20]= CreateObject(2679, -1.689812, 3.456997, 1.010974, 0.000000, 69.475036, 270.660583);
	ac[21]= CreateObject(2679, 1.686523, 3.456054, 1.010974, 0.000000, 69.466552, 270.653686);
	ac[22]= CreateObject(1351, -1.584633, 1.073079, -0.132812, 180.000000, 270.000000, 90.000000);
	ac[23]= CreateObject(16637, 0.044172, -5.049048, -0.199037, 180.000000, 270.000000, 0.000000);
	ac[24]= CreateObject(3260, -0.634765, -4.083984, 2.111146, 287.859863, 90.000000, 359.994506);
	ac[25]= CreateObject(2977, -0.842920, -5.165857, -0.312221, 0.000000, 0.000000, 0.000000);
	ac[26]= CreateObject(1550, -1.016228, 1.321895, 0.246377, 0.000000, 0.000000, 0.000000);
	ac[27]= CreateObject(2358, 0.359478, 1.208222, -0.030428, 0.000000, 0.000000, 326.255004);
	ac[28]= CreateObject(935, 1.003468, -3.570256, 0.418371, 0.000000, 0.000000, 262.599975);
	ac[29]= CreateObject(3062, -1.602945, 3.111838, 0.232619, 0.000000, 359.851989, 93.707031);
	ac[30]= CreateObject(2930, -1.042576, 4.555826, 1.398194, 84.028076, 85.694458, 186.420150);
	ac[31]= CreateObject(1448, -0.890625, -4.916992, 1.319680, 82.732543, 179.994506, 179.994506);
	ac[32]= CreateObject(2040, 0.365156, 1.212317, 0.208538, 0.000000, 0.000000, 0.000000);
	ac[33]= CreateObject(2042, -0.180212, 0.805307, -0.066984, 0.000000, 0.000000, 0.000000);
	ac[34]= CreateObject(2038, 0.492876, 0.855283, -0.069754, 0.000000, 0.000000, 327.574035);
	ac[35]= CreateObject(2937, 1.430837, 2.167968, -1.104960, 0.000000, 90.000000, 0.000000);
	ac[36]= CreateObject(2937, 1.430664, 2.167968, -0.554760, 0.000000, 90.000000, 0.000000);
	ac[37]= CreateObject(2228, -0.770392, -4.619262, 0.411040, 0.000000, 0.000000, 0.000000);
	ac[38]= CreateObject(2690, -1.103289, -4.322222, 0.214525, 0.000000, 0.000000, 127.579986);
	ac[39]= CreateObject(1449, -1.624322, 3.569086, -1.054249, 9.654998, 0.000000, 274.644958);

	AttachObjectToVehicle(ac[0], vehicleId, -0.024414, -0.427734, 1.070683, 0.000000, 0.000000, 0.000000);
	AttachObjectToVehicle(ac[1], vehicleId, 1.562428, -3.864668, 0.663436, 0.000000, 354.234985, 90.000000);
	AttachObjectToVehicle(ac[2], vehicleId, -1.596330, -3.633904, 0.663436, 0.000000, 0.000000, 271.984985);
	AttachObjectToVehicle(ac[3], vehicleId, 1.484788, -3.250230, 0.663436, 0.000000, 0.000000, 90.000000);
	AttachObjectToVehicle(ac[4], vehicleId, -1.621130, -3.019910, 0.816905, 0.000000, 7.940002, 270.000000);
	AttachObjectToVehicle(ac[5], vehicleId, -1.677827, -0.487285, 1.047109, 0.000000, 354.042602, 270.000000);
	AttachObjectToVehicle(ac[6], vehicleId, 1.561523, -0.717773, 1.047109, 0.000000, 354.226684, 90.000000);
	AttachObjectToVehicle(ac[7], vehicleId, 0.589201, -0.488340, 2.574161, 90.000000, 90.000000, 0.000000);
	AttachObjectToVehicle(ac[8], vehicleId, -0.562153, -0.320397, 2.574161, 90.000000, 270.000000, 0.000000);
	AttachObjectToVehicle(ac[9], vehicleId, -0.088453, 5.272907, -0.786405, 308.433227, 0.000000, 1.984985);
	AttachObjectToVehicle(ac[10], vehicleId, 1.773437, 0.690429, 1.461668, 0.000000, 90.000000, 0.000000);
	AttachObjectToVehicle(ac[11], vehicleId, -1.602177, 0.920749, 1.077995, 0.000000, 90.000000, 0.000000);
	AttachObjectToVehicle(ac[12], vehicleId, 1.480766, -3.327510, -0.599208, 0.000000, 90.000000, 0.000000);
	AttachObjectToVehicle(ac[13], vehicleId, 1.477468, -3.319149, -1.145082, 0.000000, 90.000000, 0.000000);
	AttachObjectToVehicle(ac[14], vehicleId, -1.485089, -3.318359, -1.145082, 0.000000, 90.000000, 0.000000);
	AttachObjectToVehicle(ac[15], vehicleId, -1.484375, -3.318359, -0.603939, 0.000000, 90.000000, 0.000000);
	AttachObjectToVehicle(ac[16], vehicleId, 1.195017, 4.500000, -0.437594, 0.000000, 90.000000, 270.000000);
	AttachObjectToVehicle(ac[17], vehicleId, -0.011156, 3.661034, 1.644372, 340.190185, 0.000000, 1.983032);
	AttachObjectToVehicle(ac[18], vehicleId, 1.620639, 4.147448, -0.031380, 0.000000, 0.000000, 95.280029);
	AttachObjectToVehicle(ac[19], vehicleId, -0.987882, 4.734310, -0.031380, 0.000000, 0.000000, 182.614746);
	AttachObjectToVehicle(ac[20], vehicleId, -1.689812, 3.456997, 1.010974, 0.000000, 69.475036, 270.660583);
	AttachObjectToVehicle(ac[21], vehicleId, 1.686523, 3.456054, 1.010974, 0.000000, 69.466552, 270.653686);
	AttachObjectToVehicle(ac[22], vehicleId, -1.584633, 1.073079, -0.132812, 180.000000, 270.000000, 90.000000);
	AttachObjectToVehicle(ac[23], vehicleId, 0.044172, -5.049048, -0.199037, 180.000000, 270.000000, 0.000000);
	AttachObjectToVehicle(ac[24], vehicleId, -0.634765, -4.083984, 2.111146, 287.859863, 90.000000, 359.994506);
	AttachObjectToVehicle(ac[25], vehicleId, -0.842920, -5.165857, -0.312221, 0.000000, 0.000000, 0.000000);
	AttachObjectToVehicle(ac[26], vehicleId, -1.016228, 1.321895, 0.246377, 0.000000, 0.000000, 0.000000);
	AttachObjectToVehicle(ac[27], vehicleId, 0.359478, 1.208222, -0.030428, 0.000000, 0.000000, 326.255004);
	AttachObjectToVehicle(ac[28], vehicleId, 1.003468, -3.570256, 0.418371, 0.000000, 0.000000, 262.599975);
	AttachObjectToVehicle(ac[29], vehicleId, -1.602945, 3.111838, 0.232619, 0.000000, 359.851989, 93.707031);
	AttachObjectToVehicle(ac[30], vehicleId, -1.042576, 4.555826, 1.398194, 84.028076, 85.694458, 186.420150);
	AttachObjectToVehicle(ac[31], vehicleId, -0.890625, -4.916992, 1.319680, 82.732543, 179.994506, 179.994506);
	AttachObjectToVehicle(ac[32], vehicleId, 0.365156, 1.212317, 0.208538, 0.000000, 0.000000, 0.000000);
	AttachObjectToVehicle(ac[33], vehicleId, -0.180212, 0.805307, -0.066984, 0.000000, 0.000000, 0.000000);
	AttachObjectToVehicle(ac[34], vehicleId, 0.492876, 0.855283, -0.069754, 0.000000, 0.000000, 327.574035);
	AttachObjectToVehicle(ac[35], vehicleId, 1.430837, 2.167968, -1.104960, 0.000000, 90.000000, 0.000000);
	AttachObjectToVehicle(ac[36], vehicleId, 1.430664, 2.167968, -0.554760, 0.000000, 90.000000, 0.000000);
	AttachObjectToVehicle(ac[37], vehicleId, -0.770392, -4.619262, 0.411040, 0.000000, 0.000000, 0.000000);
	AttachObjectToVehicle(ac[38], vehicleId, -1.103289, -4.322222, 0.214525, 0.000000, 0.000000, 127.579986);
	AttachObjectToVehicle(ac[39], vehicleId, -1.624322, 3.569086, -1.054249, 9.654998, 0.000000, 274.644958);

	return 1;
}