#include <YSI\y_hooks>

#define PLOTPOLE_AREA_IDENTIFIER	(2817)

enum e_PLOT_POLE_DATA {
	E_PLOTPOLE_AREA,
	E_PLOTPOLE_OBJ1,
	E_PLOTPOLE_OBJ2,
	E_PLOTPOLE_OBJ3
}

hook OnItemTypeDefined(uname[]) {
	if(!strcmp(uname, "PlotPole"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("PlotPole"), e_PLOT_POLE_DATA);
}

hook OnItemCreateInWorld(itemid) {
	if(GetItemType(itemid) == item_PlotPole) {
		new
			data[e_PLOT_POLE_DATA],
			Float:x, Float:y, Float:z, Float:rz,
			areadata[2];

		GetItemPos(itemid, x, y, z);
		GetItemRot(itemid, rz, rz, rz);

		areadata[0] = PLOTPOLE_AREA_IDENTIFIER;
		areadata[1] = itemid;

		data[E_PLOTPOLE_AREA] = CreateDynamicSphere(x, y, z, 20.0, GetItemWorld(itemid), GetItemInterior(itemid));
		data[E_PLOTPOLE_OBJ1] = CreateDynamicObject(1719, x + (0.09200 * floatsin(-rz, degrees)), y + (0.09200 * floatcos(-rz, degrees)), z + 0.52270, 0.00000, 90.00000, rz + 90.0);
		data[E_PLOTPOLE_OBJ2] = CreateDynamicObject(19816, x - (0.08000 * floatsin(-rz, degrees)), y - (0.08000 * floatcos(-rz, degrees)), z + 0.50000, 0.00000, 0.00000, rz);
		data[E_PLOTPOLE_OBJ3] = CreateDynamicObject(19293, x, y, z + 1.3073, 0.00000, 0.00000, rz);

		Streamer_SetArrayData(STREAMER_TYPE_AREA, data[E_PLOTPOLE_AREA], E_STREAMER_EXTRA_ID, areadata);
		SetItemArrayData(itemid, data, e_PLOT_POLE_DATA);
	}
}

hook OnItemDestroy(itemid) {
	if(GetItemType(itemid) == item_PlotPole) {
		new data[e_PLOT_POLE_DATA];
		GetItemArrayData(itemid, data);
		DestroyDynamicArea(data[E_PLOTPOLE_AREA]);
		DestroyDynamicObject(data[E_PLOTPOLE_OBJ1]);
		DestroyDynamicObject(data[E_PLOTPOLE_OBJ2]);
		DestroyDynamicObject(data[E_PLOTPOLE_OBJ3]);
	}
}

hook OnPlayerPickUpItem(playerid, itemid) {
	if(GetItemType(itemid) == item_PlotPole) return Y_HOOKS_BREAK_RETURN_1;

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerEnterDynArea(playerid, areaid) {
	new data[2];

	Streamer_GetArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, data);

	if(data[0] != PLOTPOLE_AREA_IDENTIFIER) return Y_HOOKS_CONTINUE_RETURN_0;

	if(IsValidItem(data[1])) {
		if(GetItemType(data[1]) == item_PlotPole) {
			new geid[GEID_LEN];
			GetItemGEID(data[1], geid);
			ShowActionText(playerid, sprintf(ls(playerid, "item/plotpole/inserted"), geid), 5000);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerLeaveDynArea(playerid, areaid) {
	new data[2];

	Streamer_GetArrayData(STREAMER_TYPE_AREA, areaid, E_STREAMER_EXTRA_ID, data);

	if(data[0] != PLOTPOLE_AREA_IDENTIFIER) return Y_HOOKS_CONTINUE_RETURN_0;

	if(IsValidItem(data[1])) {
		if(GetItemType(data[1]) == item_PlotPole) {
			new geid[GEID_LEN];
			GetItemGEID(data[1], geid);
			ShowActionText(playerid, sprintf(ls(playerid, "item/plotpole/inserted-left"), geid), 5000);
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

stock IsPlayerInPlotPoleArea(playerid) {
	if(!IsPlayerConnected(playerid)) return false;

	// Todo: implement Streamer_GetPlayerAreas + loop
	return false;
}

stock IsItemInPlotPoleArea(itemid) {
	new Float:x, Float:y, Float:z;

	GetItemPos(itemid, x, y, z);

	return IsPointInPlotPoleArea(x, y, z);
}

stock IsPointInPlotPoleArea(Float:x, Float:y, Float:z) {
	new
		areas[64],
		areacount,
		data[2];

	areacount = GetDynamicAreasForPoint(x, y, z, areas);

	for(new i; i < sizeof(areas) && i < areacount; ++i) {
		Streamer_GetArrayData(STREAMER_TYPE_AREA, areas[i], E_STREAMER_EXTRA_ID, data, 2);

		if(data[0] == PLOTPOLE_AREA_IDENTIFIER) {
			if(GetItemType(data[1]) == item_PlotPole) return true;
		}
	}

	return false;
}