/*
Attachment Fix
Jelly23
*/

#if ! defined PAWNRAKNET_INC_
	#error You must have Pawn.Raknet include in order to use this one.
#endif

/*Enumerator*/
enum _J_Attachments
{
	_J_ModelID,
	_J_Bone,
	Float:_J_OffsetX,
	Float:_J_OffsetY,
	Float:_J_OffsetZ,
	Float:_J_RotX,
	Float:_J_RotY,
	Float:_J_RotZ,
	Float:_J_ScaleX,
	Float:_J_ScaleY,
	Float:_J_ScaleZ,
	_J_MaterialColor1,
	_J_MaterialColor2
}

/*Macros*/
#if ! defined HOLDING
    #define HOLDING(%0) ((newkeys & (%0)) == (%0))
#endif

#if ! defined RELEASED
	#define RELEASED(%0) (((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))
#endif

/*Variables*/
static 
	_J_AttachmentsEnum[MAX_PLAYERS][MAX_PLAYER_ATTACHED_OBJECTS][_J_Attachments],
	bool:_J_AimedWithValidWeap[MAX_PLAYERS];
	

/*Callbacks*/
public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)
	{
		if(HOLDING(128))
		{
			switch(GetPlayerWeapon(playerid))
			{
				case 34..36, 43:
				{					
					_J_AimedWithValidWeap[playerid] = true;
					for(new i = 0; i < MAX_PLAYER_ATTACHED_OBJECTS; i++)
					{
						if(IsPlayerAttachedObjectSlotUsed(playerid, i))
						{
							new BitStream:bs = BS_New();
							
							BS_WriteValue(
								bs, 
								PR_UINT16, playerid, 
								PR_UINT32, i,
								PR_BOOL, 0
							);  

							PR_SendRPC(bs, playerid, 113, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED);
							BS_Delete(bs);
						}
					}
				}
			}
		}
		
		else if(RELEASED(128))
		{
			if(_J_AimedWithValidWeap[playerid])
			{				
				_J_AimedWithValidWeap[playerid] = false;
				for(new i = 0; i < MAX_PLAYER_ATTACHED_OBJECTS; i++)
				{
					if(IsPlayerAttachedObjectSlotUsed(playerid, i))
					{
						new BitStream:bs = BS_New();
						
						BS_WriteValue(
							bs, 
							PR_UINT16, playerid, 
							PR_UINT32, i,
							PR_BOOL, 1,
							PR_UINT32, _J_AttachmentsEnum[playerid][i][_J_ModelID],
							PR_UINT32, _J_AttachmentsEnum[playerid][i][_J_Bone],
							PR_FLOAT, _J_AttachmentsEnum[playerid][i][_J_OffsetX],
							PR_FLOAT, _J_AttachmentsEnum[playerid][i][_J_OffsetY],
							PR_FLOAT, _J_AttachmentsEnum[playerid][i][_J_OffsetZ],
							PR_FLOAT, _J_AttachmentsEnum[playerid][i][_J_RotX],
							PR_FLOAT, _J_AttachmentsEnum[playerid][i][_J_RotY],
							PR_FLOAT, _J_AttachmentsEnum[playerid][i][_J_RotZ],
							PR_FLOAT, _J_AttachmentsEnum[playerid][i][_J_ScaleX],
							PR_FLOAT, _J_AttachmentsEnum[playerid][i][_J_ScaleY],
							PR_FLOAT, _J_AttachmentsEnum[playerid][i][_J_ScaleZ],
							PR_UINT32, _J_AttachmentsEnum[playerid][i][_J_MaterialColor1],
							PR_UINT32, _J_AttachmentsEnum[playerid][i][_J_MaterialColor2]
						);  

						PR_SendRPC(bs, playerid, 113, PR_LOW_PRIORITY, PR_RELIABLE_ORDERED); 
						BS_Delete(bs);							
					}
				}
			}
		}
	}
	#if defined J_OnPlayerKeyStateChange
		return J_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
	#else
		return 1;
	#endif
}

public OnPlayerConnect(playerid)
{
	if(!IsPlayerNPC(playerid))
	{
		_J_AimedWithValidWeap[playerid] = false;
	}
	#if defined J_OnPlayerConnect
		return J_OnPlayerConnect(playerid);
	#else
		return 1;
	#endif
}

public OnPlayerEditAttachedObject(playerid, response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ)
{
    if(response)
    {
        _J_AttachmentsEnum[playerid][index][_J_ModelID] = modelid;
	
		_J_AttachmentsEnum[playerid][index][_J_Bone] = boneid;
		
		_J_AttachmentsEnum[playerid][index][_J_OffsetX] = fOffsetX;
		_J_AttachmentsEnum[playerid][index][_J_OffsetY] = fOffsetY;
		_J_AttachmentsEnum[playerid][index][_J_OffsetZ] = fOffsetZ;
		
		_J_AttachmentsEnum[playerid][index][_J_RotX] = fRotX;
		_J_AttachmentsEnum[playerid][index][_J_RotY] = fRotY;
		_J_AttachmentsEnum[playerid][index][_J_RotZ] = fRotZ;
		
		_J_AttachmentsEnum[playerid][index][_J_ScaleX] = fScaleX;
		_J_AttachmentsEnum[playerid][index][_J_ScaleY] = fScaleY;
		_J_AttachmentsEnum[playerid][index][_J_ScaleZ] = fScaleZ;
    }
	#if defined J_OnPlayerEditAttachedObject
		return J_OnPlayerEditAttachedObject(playerid, response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ);
	#else
		return 1;
	#endif
}


/*Functions*/
stock J_SetPlayerAttachedObject(playerid, index, modelid, bone, Float:fOffsetX = 0.0, Float:fOffsetY = 0.0, Float:fOffsetZ = 0.0, Float:fRotX = 0.0, Float:fRotY = 0.0, Float:fRotZ = 0.0, Float:fScaleX = 1.0, Float:fScaleY = 1.0, Float:fScaleZ = 1.0, materialcolor1 = 0, materialcolor2 = 0)
{
    _J_AttachmentsEnum[playerid][index][_J_ModelID] = modelid;
	
	_J_AttachmentsEnum[playerid][index][_J_Bone] = bone;
	
	_J_AttachmentsEnum[playerid][index][_J_OffsetX] = fOffsetX;
	_J_AttachmentsEnum[playerid][index][_J_OffsetY] = fOffsetY;
	_J_AttachmentsEnum[playerid][index][_J_OffsetZ] = fOffsetZ;
	
	_J_AttachmentsEnum[playerid][index][_J_RotX] = fRotX;
	_J_AttachmentsEnum[playerid][index][_J_RotY] = fRotY;
	_J_AttachmentsEnum[playerid][index][_J_RotZ] = fRotZ;
	
	_J_AttachmentsEnum[playerid][index][_J_ScaleX] = fScaleX;
	_J_AttachmentsEnum[playerid][index][_J_ScaleY] = fScaleY;
	_J_AttachmentsEnum[playerid][index][_J_ScaleZ] = fScaleZ;
	
	_J_AttachmentsEnum[playerid][index][_J_MaterialColor1] = materialcolor1;
	_J_AttachmentsEnum[playerid][index][_J_MaterialColor2] = materialcolor2;
	
    return SetPlayerAttachedObject(playerid, index, modelid, bone, fOffsetX, fOffsetY, fOffsetZ, fRotX, fRotY, fRotZ, fScaleX, fScaleY, fScaleZ, materialcolor1, materialcolor2);
}

/*Hooks*/
#if defined _ALS_SetPlayerAttachedObject
#undef SetPlayerAttachedObject
#else
#define _ALS_SetPlayerAttachedObject
#endif
 
#define SetPlayerAttachedObject J_SetPlayerAttachedObject

#if defined _ALS_OnPlayerKeyStateChange
#undef OnPlayerKeyStateChange
#else
#define _ALS_OnPlayerKeyStateChange
#endif
#define OnPlayerKeyStateChange J_OnPlayerKeyStateChange

#if defined J_OnPlayerKeyStateChange
forward J_OnPlayerKeyStateChange(playerid, newkeys, oldkeys);
#endif

#if defined _ALS_OnPlayerConnect
#undef OnPlayerConnect
#else
#define _ALS_OnPlayerConnect
#endif
#define OnPlayerConnect J_OnPlayerConnect

#if defined J_OnPlayerConnect
forward J_OnPlayerConnect(playerid);
#endif

#if defined _ALS_OnPlayerEditAttachedObject
#undef OnPlayerEditAttachedObject
#else
#define _ALS_OnPlayerEditAttachedObject
#endif
#define OnPlayerEditAttachedObject J_OnPlayerEditAttachedObject

#if defined J_OnPlayerEditAttachedObject
forward J_OnPlayerEditAttachedObject(playerid, response, index, modelid, boneid, Float:fOffsetX, Float:fOffsetY, Float:fOffsetZ, Float:fRotX, Float:fRotY, Float:fRotZ, Float:fScaleX, Float:fScaleY, Float:fScaleZ);
#endif
