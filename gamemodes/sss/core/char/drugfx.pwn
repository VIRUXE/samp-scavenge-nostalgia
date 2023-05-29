#include <YSI\y_hooks>


hook OnPlayerScriptUpdate(playerid)
{
	if(!IsPlayerNPC(playerid))
	{
		if(IsPlayerUnderDrugEffect(playerid, drug_Lsd))
		{
			hour = 22;
			minute = 3;
			weather = 33;
//			SetPlayerTime(playerid, hour, minute);
//			SetPlayerWeather(playerid, weather);
			SetTimeForPlayer(playerid, hour, minute);
			SetWeatherForPlayer(playerid, weather);
		}
		else if(IsPlayerUnderDrugEffect(playerid, drug_Heroin))
		{
			hour = 22;
			minute = 30;
			weather = 33;
//			SetPlayerTime(playerid, hour, minute);
//			SetPlayerWeather(playerid, weather);
			SetTimeForPlayer(playerid, hour, minute);
			SetWeatherForPlayer(playerid, weather);
		}

		if(IsPlayerUnderDrugEffect(playerid, drug_Air))
		{
			SetPlayerDrunkLevel(playerid, 100000);

			if(random(100) < 50) HealPlayer(playerid, -1.0);
		}

		if(IsPlayerUnderDrugEffect(playerid, drug_Adrenaline)) 
			HealPlayer(playerid, 0.01);

		if(IsPlayerUnderDrugEffect(playerid, drug_Air))
		{
			SetPlayerDrunkLevel(playerid, 100000);

			if(random(100) < 50)
				HealPlayer(playerid, -1.0);
		}

		if(IsPlayerUnderDrugEffect(playerid, drug_Adrenaline))
			HealPlayer(playerid, 0.01);
	}
}
