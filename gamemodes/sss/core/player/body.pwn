#include <a_samp>
#include <streamer>

#include <YSI\y_hooks>
#include <YSI\y_iterator>

#define MAX_BODY			(2048)

static
	body_Player[MAX_BODY] = {-1, ...},
	Text3D:body_NameTag[MAX_BODY] = {Text3D:INVALID_3DTEXT_ID, ...};
	
new
   Iterator:body_Count<MAX_BODY>;

CreateBody(playerid)
{
	new id = Iter_Free(body_Count);

	if(id == -1)
	{
		err("MAX_BODY limit reached.");
		return -1;
	}

	Iter_Add(body_Count, id);
	
	new
		name[24],
		Float:x,
		Float:y,
		Float:z,
		Float:r,
		skinid;

	GetPlayerName(playerid, name, 24);
	GetPlayerPos(playerid, x, y, z);
	GetPlayerFacingAngle(playerid, r);
	skinid = GetPlayerSkin(playerid);

	body_Player[id] = CreateDynamicActor(skinid, x, y, z, r, false);
	
	body_NameTag[id] = CreateDynamic3DTextLabel(name, GetPlayerColor(playerid), x, y, z + 1.0, 10.0);
	
	return id;
}

stock DestroyBody(bodyid)
{
	if(!Iter_Contains(body_Count, bodyid))
		return 0;

	DestroyDynamicActor(body_Player[bodyid]);
	DestroyDynamic3DTextLabel(body_NameTag[bodyid]);
	
	Iter_SafeRemove(body_Count, bodyid, bodyid);

	return bodyid;
}


public OnPlayerGiveDamageDynamicActor(playerid, actorid, Float:amount, weaponid, bodypart)
{


	return 1;
}
