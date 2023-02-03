#include <a_samp>

#define FILTERSCRIPT

#undef 	MAX_PLAYERS
#define MAX_PLAYERS   (50)

enum eCBugPlayerInfo
{
	bool:isCrouched,
	bool:isFiring,
	iCrouchTime,
	iLastFire,
	iLastFiring,
	iLastStrafeFire
};

new CBugPlayerInfo[ MAX_PLAYERS ][ eCBugPlayerInfo ];

public OnFilterScriptInit()
{
    new iTick = GetTickCount( );

    for ( new i = 0; i < MAX_PLAYERS; i++ )
    {
        CBugPlayerInfo[ i ][ isCrouched      ] = false;
        CBugPlayerInfo[ i ][ iLastFire       ] = iTick;
        CBugPlayerInfo[ i ][ iLastStrafeFire ] = iTick;
    }

    return 1;
}

public OnPlayerConnect(playerid)
{
    new iTick = GetTickCount( );

    CBugPlayerInfo[ playerid ][ isCrouched      ] = false;
    CBugPlayerInfo[ playerid ][ isFiring        ] = false;
    CBugPlayerInfo[ playerid ][ iLastFire       ] = iTick;
    CBugPlayerInfo[ playerid ][ iLastFiring     ] = iTick;
    CBugPlayerInfo[ playerid ][ iLastStrafeFire ] = iTick;

    return 1;
}

public OnPlayerUpdate(playerid)
{
    new
             iTick = GetTickCount( ),
             iAnimationIndex = GetPlayerAnimationIndex( playerid ),
             iWeapon = GetPlayerWeapon( playerid ),
             iKeys,
             iKeysUD,
             iKeysLR
    ;

    GetPlayerKeys( playerid, iKeys, iKeysUD, iKeysLR );

    if ( ( iKeys & KEY_FIRE ) || ( ( iKeys & KEY_ACTION ) && ( iKeys & KEY_HANDBRAKE ) ) )
    {
        CBugPlayerInfo[ playerid ][ iLastFire ] = iTick;

        if ( !CBugPlayerInfo[ playerid ][ isFiring ] )
        {
            CBugPlayerInfo[ playerid ][ isFiring ] = true;

            CBugPlayerInfo[ playerid ][ iLastFiring ] = iTick;
        }
    }
    else if ( CBugPlayerInfo[ playerid ][ isFiring ] )
        CBugPlayerInfo[ playerid ][ isFiring ] = false;

    switch ( iAnimationIndex )
    {
        case 1274: // WEAPON_CROUCH
        {
            if ( !CBugPlayerInfo[ playerid ][ isCrouched ] )
            {
                CBugPlayerInfo[ playerid ][ isCrouched ] = true;

                CBugPlayerInfo[ playerid ][ iCrouchTime ] = iTick;
            }

            if ( iWeapon && ( iKeys & KEY_FIRE ) && iTick - CBugPlayerInfo[ playerid ][ iCrouchTime ] > 300 )
                ClearAnimations( playerid );
        }

        case 1160 .. 1163, 1167: // GUNMOVE_L/R/FWD/BWD, GUN_STAND
        {
            if ( ( iKeys & KEY_FIRE ) )
            {
                switch ( iWeapon )
                {
                    case
                        WEAPON_SILENCED,
                        WEAPON_DEAGLE,
                        WEAPON_SHOTGUN,
                        WEAPON_SHOTGSPA,
                        WEAPON_MP5,
                        WEAPON_M4,
                        WEAPON_AK47,
                        WEAPON_RIFLE,
                        WEAPON_SNIPER:
                    {
                        CBugPlayerInfo[ playerid ][ iLastStrafeFire ] = iTick;
                    }
                }
            }
        }

        case
            1231, // RUN_PLAYER
            1223, // RUN_ARMED
            1141, // FIGHTA_M
            478,  // FIGHTB_M
            489,  // FIGHTC_M
            500,  // FIGHTD_M
            759,  // KNIFE_PART
            27,   // BAT_PART
            1554  // SWORD_PART
            :
        {
            switch ( GetWeaponSlot( iWeapon ) )
            {
                case 0, 1, 8, 9, 10, 11, 12:
                {

                }
                default:
                {
                    if ( ( iKeys & KEY_HANDBRAKE ) && ( iKeys & KEY_ACTION ) ) {
                        ClearAnimations( playerid );
						return 2;
					}
                    else if ( CBugPlayerInfo[ playerid ][ isFiring ] && iTick - CBugPlayerInfo[ playerid ][ iLastFiring ] > 150 ) {
                        ClearAnimations( playerid );
						return 2;
					}
                }
            }
        }
    }

    if ( ( iKeys & KEY_CROUCH ) && iTick - CBugPlayerInfo[ playerid ][ iLastStrafeFire ] < 500 )
    {
        ClearAnimations( playerid );

        ApplyAnimation( playerid, "PED", "XPRESSscratch", 0.0, 1, 0, 0, 0, 500 - ( iTick - CBugPlayerInfo[ playerid ][ iLastStrafeFire ] ), 1 );

		return 2;
    }

    if ( CBugPlayerInfo[ playerid ][ isCrouched ] && iAnimationIndex != 1274 ) // WEAPON_CROUCH
        CBugPlayerInfo[ playerid ][ isCrouched ] = false;

    return 1;
}

GetWeaponSlot(weaponid)
{
	new slot;
	switch(weaponid)
	{
		case 0,1: slot = 0;
		case 2 .. 9: slot = 1;
		case 10 .. 15: slot = 10;
		case 16 .. 18, 39: slot = 8;
		case 22 .. 24: slot =2;
		case 25 .. 27: slot = 3;
		case 28, 29, 32: slot = 4;
		case 30, 31: slot = 5;
		case 33, 34: slot = 6;
		case 35 .. 38: slot = 7;
		case 40: slot = 12;
		case 41 .. 43: slot = 9;
		case 44 .. 46: slot = 11;
	}
	return slot;
}
