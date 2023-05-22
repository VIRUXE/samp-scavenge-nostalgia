#include <YSI\y_hooks>
#include <YSI\y_timers>

#define DEFAULT_FADE_INTERVAL 50
#define MAX_FADE_QUEUE 10

enum {
	FADE_IN, // Clarear
	FADE_OUT // Escurecer
}

static enum E_FADE_EVENT {
	fade_type,
	fade_level,
	fade_interval,
	fade_step
}

static
PlayerText:	FadeUI[MAX_PLAYERS] = {PlayerText:INVALID_TEXT_DRAW, ...},
			FadeLevel[MAX_PLAYERS],
Timer:		FadeTimer[MAX_PLAYERS],
bool:		IsFading[MAX_PLAYERS];

forward OnScreenFadeFinish(playerid, type, level);
public OnScreenFadeFinish(playerid, type, level) {

	printf("[SCREENFADE] OnScreenFadeFinish(%p, %d, %d) stopped fading (%s)", playerid, type, level, type ? "OUT" : "IN");
}

/* 
	 0  - Tela limpa
	255 - Tela preta
*/
SetPlayerScreenFade(playerid, type, level, interval = DEFAULT_FADE_INTERVAL, step = 4) {
	if(!IsPlayerConnected(playerid) || IsFading[playerid]) return 0;
		
	if(level > 255) level    = 255;
	else if(level < 0) level = 0;

	printf("[SCREENFADE] SetPlayerScreenFade(%p, %d, %d, %d, %d) FadeLevel: %d", playerid, type, level, interval, step, FadeLevel[playerid]);

	IsFading[playerid] = true;

	UpdateFade(playerid, type, level, step);
	FadeTimer[playerid] = repeat UpdateFade[interval](playerid, type, level, step);

	return 1;
}

GetPlayerScreenFade(playerid) return FadeLevel[playerid];

timer UpdateFade[DEFAULT_FADE_INTERVAL](playerid, type, level, step) {
	// printf("[SCREENFADE] UpdateFade(%d, %d, %d, %d) -> FadeLevel: %d", playerid, type, level, step, FadeLevel[playerid]);

	switch (type) {
        case FADE_IN: { // Clarear
			if (FadeLevel[playerid] > level) {
                FadeLevel[playerid] -= step;

                if (FadeLevel[playerid] < level) FadeLevel[playerid] = level;
            } else {
				IsFading[playerid] = false;
				stop FadeTimer[playerid];

				CallLocalFunction("OnScreenFadeFinish", "ddd", playerid, type, level);
			}
        }
        case FADE_OUT: { // Escurecer
            if (FadeLevel[playerid] < level) {
                FadeLevel[playerid] += step;

                if (FadeLevel[playerid] > level) FadeLevel[playerid] = level;
            } else {
				IsFading[playerid] = false;
				stop FadeTimer[playerid];

				CallLocalFunction("OnScreenFadeFinish", "ddd", playerid, type, level);
			}
        }
    }

    PlayerTextDrawBoxColor(playerid, FadeUI[playerid], FadeLevel[playerid]);
	PlayerTextDrawShow(playerid, FadeUI[playerid]);
}

hook OnPlayerConnect(playerid) {
	FadeLevel[playerid] = 255; // 

	FadeUI[playerid]			=CreatePlayerTextDraw(playerid, 0.000000, 0.000000, "_");
	PlayerTextDrawBackgroundColor	(playerid, FadeUI[playerid], 255);
	PlayerTextDrawFont				(playerid, FadeUI[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, FadeUI[playerid], 0.500000, 50.000000);
	PlayerTextDrawColor				(playerid, FadeUI[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, FadeUI[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, FadeUI[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, FadeUI[playerid], 1);
	PlayerTextDrawUseBox			(playerid, FadeUI[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, FadeUI[playerid], FadeLevel[playerid]);
	PlayerTextDrawTextSize			(playerid, FadeUI[playerid], 640.000000, 0.000000);

	PlayerTextDrawShow(playerid, FadeUI[playerid]);
}

ACMD:fade[5](playerid, params[]) {
	new type, level, interval, step;

	sscanf(params, "dddd", type, level, interval, step);

	SetPlayerScreenFade(playerid, type, level, interval, step);

	return 1;
}

/* ptask FadeUpdate[100](playerid) {
	// if(IsPlayerSleeping(playerid)) return;
	    
	new const Float:hp = GetPlayerHP(playerid);

	if(FadeLevel[playerid] > 0) {
		printf("[SCREENFADE] FadeUpdate(%p) -> FadeLevel: %d", playerid, FadeLevel[playerid]);

		PlayerTextDrawBoxColor(playerid, FadeUI[playerid], FadeLevel[playerid]);
		PlayerTextDrawShow(playerid, FadeUI[playerid]);

		FadeLevel[playerid] -= 4;

		if(FadeLevel[playerid] < 0) FadeLevel[playerid] = 0;

		if(hp <= 40.0) {
			if(FadeLevel[playerid] <= floatround((40.0 - hp) * 4.4)) 
				FadeLevel[playerid] = 0;
		}

		return;
	}

	if(hp >= 40.0) {
		if(IsPlayerSpawned(playerid)) PlayerTextDrawBoxColor(playerid, FadeUI[playerid], 0);

		return;
	}

	if(IsPlayerUnderDrugEffect(playerid, drug_Painkill)) PlayerTextDrawHide(playerid, FadeUI[playerid]);
	else if(IsPlayerUnderDrugEffect(playerid, drug_Adrenaline)) PlayerTextDrawHide(playerid, FadeUI[playerid]);
	else {
		PlayerTextDrawBoxColor(playerid, FadeUI[playerid], floatround((40.0 - hp) * 4.4));
		PlayerTextDrawShow(playerid, FadeUI[playerid]);

		// ! Essa merda nem tem nada a ver com esse arquivo
		if(!IsPlayerKnockedOut(playerid)) {
			if(GetTickCountDifference(GetTickCount(), GetPlayerKnockOutTick(playerid)) > 5000 * hp) {
				if(GetPlayerBleedRate(playerid) > 0.0) {
					if(frandom(40.0) < (50.0 - hp))
						KnockOutPlayer(playerid, floatround(2000 * (50.0 - hp) + frandom(200 * (50.0 - hp))));
				} else {
					if(frandom(40.0) < (40.0 - hp))
						KnockOutPlayer(playerid, floatround(2000 * (40.0 - hp) + frandom(200 * (40.0 - hp))));
				}
			}
		}
	}

	return;
} */