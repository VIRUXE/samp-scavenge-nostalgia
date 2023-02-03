#include <a_samp>
#include <HeartAC>

/*native Float:xGetSpeed(playerid);
native xGetWeaponModel(weaponid);
native xGetWeaponSlot(weaponid);
native Float:xGetPointDistToPoint(Float:x1, Float:y1, Float:x2, Float:y2);
native xPlayerName(playerid);
native xGetPlayerFPS(playerid);*/

stock xGetPlayerAFK(playerid)
{
    if(GetPVarInt(playerid,"AFK") == 1)
        return true;
    return false;
}
/*----------------------------------------------------------------------------*/

stock Xs_ACc_GivePlayerMoney(playerid, money)
	return CallRemoteFunction("Xs_AC_GivePlayerMoney", "id",playerid, money);
/*----------------------------------------------------------------------------*/

stock Xs_ACc_ResetPlayerMoney(playerid)
	return CallRemoteFunction("Xs_AC_ResetPlayerMoney", "i",playerid);
/*----------------------------------------------------------------------------*/

stock Xs_ACc_GetPlayerMoney(playerid)
	return CallRemoteFunction("Xs_AC_GetPlayerMoney", "i",playerid);
/*----------------------------------------------------------------------------*/

stock Xs_ACc_GivePlayerWeapon(playerid,Weapon,ammo)
	return CallRemoteFunction("Xs_AC_GivePlayerWeapon", "idd",playerid,Weapon,ammo);
/*----------------------------------------------------------------------------*/

stock Xs_ACc_SetPlayerAmmo(playerid,weaponslot,ammo)
	return CallRemoteFunction("Xs_AC_SetPlayerAmmo", "idd",playerid,weaponslot,ammo);
/*----------------------------------------------------------------------------*/

stock Xs_ACc_ResetPlayerWeapons(playerid)
	return CallRemoteFunction("Xs_AC_ResetPlayerWeapons", "i",playerid);
/*----------------------------------------------------------------------------*/

stock Xs_ACc_SetPlayerPos(playerid, Float:ix, Float:iy, Float:iz)
	return CallRemoteFunction("Xs_AC_SetPlayerPos", "ifff",playerid, Float:ix,Float:iy, Float:iz);

/*----------------------------------------------------------------------------*/

stock Xs_ACc_SetVehiclePos(playerid, Float:ix, Float:iy, Float:iz)
	return CallRemoteFunction("Xs_AC_SetVehiclePos", "ifff",playerid, Float:ix,Float:iy, Float:iz);
/*----------------------------------------------------------------------------*/

stock Xs_ACc_PutPlayerInVehicle(playerid,vehicleid, seatid)
	return CallRemoteFunction("Xs_AC_PutPlayerInVehicle", "idd",playerid,vehicleid,seatid);
/*----------------------------------------------------------------------------*/

stock Xs_ACc_TogglePlayerSpectating(playerid, toggle)
	return CallRemoteFunction("Xs_AC_TogglePlayerSpectating", "id",playerid, toggle);
/*----------------------------------------------------------------------------*/

stock Xs_ACc_TogglePlayerControllable(playerid, toggle)
	return CallRemoteFunction("Xs_AC_TogglePlayerControllable", "id",playerid, toggle);
/*----------------------------------------------------------------------------*/

stock Xs_ACc_SetPlayerHealth(playerid,Float:health)
	return CallRemoteFunction("Xs_AC_SetPlayerHealth", "if",playerid,Float:health);
/*----------------------------------------------------------------------------*/

stock Xs_ACc_SetPlayerArmour(playerid,Float:armour)
	return CallRemoteFunction("Xs_AC_SetPlayerArmour", "if",playerid,Float:armour);
/*----------------------------------------------------------------------------*/

stock Xs_ACc_AddStaticPickup(model,type,Float:X,Float:Y,Float:Z,virtualworld=0)
	return CallRemoteFunction("xAddStaticPickup","idfffd",model,type,X,Y,Z,virtualworld);
/*----------------------------------------------------------------------------*/

stock Xs_ACc_CreatePickup(model,type,Float:X,Float:Y,Float:Z,virtualworld=0)
	return CallRemoteFunction("xCreatePickup","idfffd",model,type,X,Y,Z,virtualworld);
/*----------------------------------------------------------------------------*/

stock Xs_ACc_AddPlayerClass(modelid,Float:spawn_x,Float:spawn_y,Float:spawn_z,Float:z_angle,weapon1,weapon1_ammo,weapon2,weapon2_ammo,weapon3,weapon3_ammo)
	return CallRemoteFunction("xAddPlayerClass","iffffdddddd",modelid,spawn_x,spawn_y,spawn_z,z_angle,weapon1,weapon1_ammo,weapon2,weapon2_ammo,weapon3,weapon3_ammo);
/*----------------------------------------------------------------------------*/

stock Xs_ACc_AddPlayerClassEx(teamid,modelid,Float:spawn_x,Float:spawn_y,Float:spawn_z,Float:z_angle,weapon1,weapon1_ammo,weapon2,weapon2_ammo,weapon3,weapon3_ammo)
	return CallRemoteFunction("xAddPlayerClassEx","idffffdddddd",teamid,modelid,spawn_x,spawn_y,spawn_z,z_angle,weapon1,weapon1_ammo,weapon2,weapon2_ammo,weapon3,weapon3_ammo);
/*----------------------------------------------------------------------------*/

stock
Xs_ACc_SetSpawnInfo(playerid,team,skin,Float:x,Float:y,Float:z,Float:rotation,weapon1,weapon1_ammo,weapon2,weapon2_ammo,weapon3,weapon3_ammo)
	return CallRemoteFunction("xSetSpawnInfo","iiiffffdddddd",playerid,team,skin,x,y,z,rotation,weapon1,weapon1_ammo,weapon2,weapon2_ammo,weapon3,weapon3_ammo);
/*----------------------------------------------------------------------------*/

stock Xs_ACc_DestroyPickup(pickupid)
	return CallRemoteFunction("xDestroyPickup","d",pickupid);
/*----------------------------------------------------------------------------*/

stock Xs_ACc_SetVehicleHealth(playerid,Float:health)
	return CallRemoteFunction("Xs_AC_SetVehicleHealth", "if",playerid,Float:health);
/*----------------------------------------------------------------------------*/

stock Xs_ACc_RepairVehicle(playerid)
	return CallRemoteFunction("Xs_AC_RepairVehicle", "i",playerid);
/*----------------------------------------------------------------------------*/

stock Xs_ACc_DestroyVehicle(vehicleid)
	return CallRemoteFunction("Xs_AC_DestroyVehicle", "i",vehicleid);
/*----------------------------------------------------------------------------*/

stock Xs_ACc_AddVehicleComponent(vehicleid,componentid)
	return CallRemoteFunction("Xs_AC_AddVehicleComponent","id",vehicleid,componentid);
/*----------------------------------------------------------------------------*/

stock Xs_ACc_RemoveVehicleComponent(vehicleid,componentid)
	return CallRemoteFunction("Xs_AC_RemoveVehicleComponent", "id",vehicleid,componentid);
/*----------------------------------------------------------------------------*/


#define GivePlayerMoney          Xs_ACc_GivePlayerMoney
#define ResetPlayerMoney         Xs_ACc_ResetPlayerMoney
#define GetPlayerMoney           Xs_ACc_GetPlayerMoney
#define GivePlayerWeapon         Xs_ACc_GivePlayerWeapon
#define SetPlayerAmmo            Xs_ACc_SetPlayerAmmo
#define ResetPlayerWeapons       Xs_ACc_ResetPlayerWeapons
#define SetPlayerPos             Xs_ACc_SetPlayerPos
#define SetVehiclePos            Xs_ACc_SetVehiclePos
#define PutPlayerInVehicle       Xs_ACc_PutPlayerInVehicle
#define TogglePlayerSpectating   Xs_ACc_TogglePlayerSpectating
#define TogglePlayerControllable Xs_ACc_TogglePlayerControllable
#define SetPlayerHealth          Xs_ACc_SetPlayerHealth
#define SetPlayerArmour          Xs_ACc_SetPlayerArmour
#define DestroyPickup            Xs_ACc_DestroyPickup
#define CreatePickup             Xs_ACc_CreatePickup
#define AddStaticPickup          Xs_ACc_AddStaticPickup
#define SetVehicleHealth         Xs_ACc_SetVehicleHealth
#define RepairVehicle            Xs_ACc_RepairVehicle
#define AddPlayerClass           Xs_ACc_AddPlayerClass
#define AddPlayerClassEx         Xs_ACc_AddPlayerClassEx
#define SetSpawnInfo             Xs_ACc_SetSpawnInfo
#define RemoveVehicleComponent   Xs_ACc_RemoveVehicleComponent
#define AddVehicleComponent      Xs_ACc_AddVehicleComponent
#define DestroyVehicle           Xs_ACc_DestroyVehicle

