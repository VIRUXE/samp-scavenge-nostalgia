#include <YSI\y_hooks>

// ChangeVehicleColor(vehicleid, color1, color2);

hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "Spray"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("Spray"), 1);
}

hook OnItemCreate(itemid){
	if(GetItemLootIndex(itemid) != -1){
		if(GetItemType(itemid) == item_SprayPaint){
			SetItemExtraData(itemid, random(10));
		}
	}
}

hook OnItemNameRender(itemid, ItemType:itemtype){
	if(itemtype == item_SprayPaint)	{
		new
			amount = GetItemExtraData(itemid),
			str[11];

		format(str, sizeof(str), "(%s)", SprayColor[amount]);
		ConvertEncoding(str);

		SetItemNameExtra(itemid, str);
	}
}
