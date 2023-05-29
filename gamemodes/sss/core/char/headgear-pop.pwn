#include <YSI\y_hooks>


hook OnPlayerGiveDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{


	if(bodypart == BODY_PART_HEAD)
	{
		if(IsValidItem(GetPlayerHatItem(playerid)))
			PopHat(playerid);

		if(IsValidItem(GetPlayerMaskItem(playerid)))
			PopMask(playerid);
	}

	return 1;
}

PopHat(playerid)
{
	new
		itemid,
		ItemType:itemtype,
		Float:x,
		Float:y,
		Float:z,
		Float:r,
		objectid;

	itemid = RemovePlayerHatItem(playerid);
	itemtype = GetItemType(itemid);
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	objectid = CreateDynamicObject(GetItemTypeModel(itemtype), x, y, z + 0.8, 0.0, 0.0, r);
	MoveDynamicObject(objectid, x, y, z - FLOOR_OFFSET, 5.0, 0.0, 0.0, r + 360.0);
	defer pop_DropHat(objectid, itemid, x, y, z, r);
}

PopMask(playerid)
{
	new
		itemid,
		ItemType:itemtype,
		Float:x,
		Float:y,
		Float:z,
		Float:r,
		objectid;

	itemid = RemovePlayerMaskItem(playerid);
	itemtype = GetItemType(itemid);
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);

	objectid = CreateDynamicObject(GetItemTypeModel(itemtype), x, y, z + 0.8, 0.0, 0.0, r);
	MoveDynamicObject(objectid, x, y, z - FLOOR_OFFSET, 5.0, 0.0, 0.0, r + 360.0);
	defer pop_DropMask(objectid, itemid, x, y, z, r);
}


timer pop_DropHat[500](o, it, Float:x, Float:y, Float:z, Float:r)
{
	DestroyDynamicObject(o);
	CreateItemInWorld(it, x, y, z - FLOOR_OFFSET, 0.0, 0.0, r);
}

timer pop_DropMask[500](o, it, Float:x, Float:y, Float:z, Float:r)
{
	DestroyDynamicObject(o);
	CreateItemInWorld(it, x, y, z - FLOOR_OFFSET, 0.0, 0.0, r);
}

CMD:pophat(playerid)
{
	PopHat(playerid);
	return 1;
}

CMD:popmask(playerid)
{
	PopMask(playerid);
	return 1;
}
