#include <YSI\y_vehicledata>

stock IsVehicleUpsideDown(vehicleid)
{
	new
		Float:w,
		Float:x,
		Float:y,
		Float:z;

	GetVehicleRotationQuat(vehicleid, w, x, y, z);

	new const Float:angle = atan2(((y * z) + (w * x)) * 2.0, (w * w) - (x * x) - (y * y) + (z * z));

	return ((angle > 90.0) || (angle < -90.0));
}

stock IsVehicleInRangeOfPoint(vehicleid, Float:range, Float:x, Float:y, Float:z)
{
	new
		Float:vx,
		Float:vy,
		Float:vz;

	GetVehiclePos(vehicleid, vx, vy, vz);

	return Distance(x, y, z, vx, vy, vz) < range ? 1 : 0;
}

stock GetPlayersInVehicle(vehicleid)
{
	new amount;
	PlayerLoop(i)if(!IsPlayerConnected(i)||!IsPlayerInVehicle(i,vehicleid))amount++;
	return amount;
}

stock VehicleEngineState(v, t=-1)
{
	new e, l, a, d, bn, bt, o;

	GetVehicleParamsEx(v, e, l, a, d, bn, bt, o);

	if(t != -1)
		SetVehicleParamsEx(v, t, l, a, d, bn, bt, o);

	return e;
}

stock VehicleLightsState(v, t=-1)
{
	new e, l, a, d, bn, bt, o;

	GetVehicleParamsEx(v, e, l, a, d, bn, bt, o);

	if(t != -1)
		SetVehicleParamsEx(v, e, t, a, d, bn, bt, o);

	return l;
}

stock VehicleAlarmState(v, t=-1)
{
	new e, l, a, d, bn, bt, o;

	GetVehicleParamsEx(v, e, l, a, d, bn, bt, o);

	if(t != -1)
		SetVehicleParamsEx(v, e, l, t, d, bn, bt, o);

	return a;
}

stock VehicleDoorsState(v, t=-1)
{
	new e, l, a, d, bn, bt, o;

	GetVehicleParamsEx(v, e, l, a, d, bn, bt, o);

	if(t != -1)
		SetVehicleParamsEx(v, e, l, a, t, bn, bt, o);

	return d;
}

stock VehicleBonnetState(v, t=-1)
{
	new e, l, a, d, bn, bt, o;

	GetVehicleParamsEx(v, e, l, a, d, bn, bt, o);

	if(t != -1)
		SetVehicleParamsEx(v, e, l, a, d, t, bt, o);

	return bn;
}

stock VehicleBootState(v, t=-1)
{
	new e, l, a, d, bn, bt, o;

	GetVehicleParamsEx(v, e, l, a, d, bn, bt, o);

	if(t != -1)
		SetVehicleParamsEx(v, e, l, a, d, bn, t, o);

	return bt;
}

stock RandomNumberPlateString()
{
	new str[9];
	for(new c; c < 8; c++)
	{
		if(c<4)str[c] = 'A' + random(26);
		else if(c>4)str[c] = '0' + random(10);
		str[4] = ' ';
	}
	return str;
}

enum
{
	WHEELSFRONT_LEFT,	// 0
	WHEELSFRONT_RIGHT,	// 1
	WHEELSMID_LEFT,		// 2
	WHEELSMID_RIGHT,	// 3
	WHEELSREAR_LEFT,	// 4
	WHEELSREAR_RIGHT	// 5
}

stock GetVehicleWheelPos(vehicleid, wheel, &Float:x, &Float:y, &Float:z)
{
	new
		Float:rot,
		Float:x2,
		Float:y2,
		Float:z2,
		Float:div;

	GetVehicleZAngle(vehicleid, rot);
	GetVehiclePos(vehicleid, x2, y2, z2);

	rot = 360 - rot;

	switch(wheel)
	{
		case WHEELSFRONT_LEFT .. WHEELSFRONT_RIGHT: // Front Tyres
			GetVehicleModelInfo(GetVehicleModel(vehicleid), VEHICLE_MODEL_INFO_WHEELSFRONT, x, y, z);

		case WHEELSMID_LEFT .. WHEELSMID_RIGHT: // Middle Tyres
			GetVehicleModelInfo(GetVehicleModel(vehicleid), VEHICLE_MODEL_INFO_WHEELSMID, x, y, z);

		case WHEELSREAR_LEFT .. WHEELSREAR_RIGHT: // Rear Tyres
			GetVehicleModelInfo(GetVehicleModel(vehicleid), VEHICLE_MODEL_INFO_WHEELSREAR, x, y, z);

		default: return 0;
	}

	div = (wheel % 2) ? (x) : (-x);
	x = floatsin(rot, degrees) * y + floatcos(rot, degrees) * div + x2;
	y = floatcos(rot, degrees) * y - floatsin(rot, degrees) * div + y2;
	z += z2;

	return 1;
}

bool:IsModelOpenTopVehicle(modelid) {
    if(Vehicle_IsBike(modelid) || Vehicle_IsBoat(modelid)) return true;

    new const openTopVehicleModels[] = {
        429, // Banshee
        500, // Mesa
        439, // Stallion
        471, // Quad
        568, // Bandito
        535, // Slamvan
        558, // Uranus
        540, // Vincent
        583  // Tug
    };

    for (new i = 0; i < sizeof(openTopVehicleModels); i++)
        if (openTopVehicleModels[i] == modelid) return true;

    return false;
}

IsVehicleOpenTop(vehicleId) {
	if(!IsValidVehicle(vehicleId)) return -1;

	return IsModelOpenTopVehicle(GetVehicleModel(vehicleId)) ? 1 : 0;
}