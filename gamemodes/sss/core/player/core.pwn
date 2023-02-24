/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/


#include <YSI\y_hooks>

#define DEFAULT_POS_X				(-2970.3318)
#define DEFAULT_POS_Y				(-62.1616)
#define DEFAULT_POS_Z				(5.2121)


enum E_PLAYER_DATA
{
			// Database Account Data
			ply_Password[MAX_PASSWORD_LEN],
			ply_IP,
			ply_RegisterTimestamp,
			ply_LastLogin,
			ply_TotalSpawns,
			ply_Warnings,

			// Character Data
bool:		ply_Alive,
Float:		ply_HitPoints,
Float:		ply_ArmourPoints,
Float:		ply_FoodPoints,
			ply_Clothes,
			ply_Gender,
Float:		ply_Velocity,
			ply_CreationTimestamp,

			// Internal Data
			ply_ShowHUD,
			ply_PingLimitStrikes,
			ply_stance,
			ply_JoinTick,
			ply_SpawnTick
}

static
			ply_Data[MAX_PLAYERS][E_PLAYER_DATA];


forward OnPlayerScriptUpdate(playerid);
forward OnPlayerDisconnected(playerid);
forward OnDeath(playerid, killerid, reason);

public OnPlayerRequestClass(playerid, classid)
{
	if(IsPlayerNPC(playerid)) return 1;

	SetSpawnInfo(playerid, NO_TEAM, 0, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z, 0.0, 0, 0, 0, 0, 0, 0);

	return 0;
}

static
	lang_PlayerLanguage[MAX_PLAYERS];

stock GetPlayerLanguage(playerid)
{
	if(!IsPlayerConnected(playerid))
		return -1;

	return lang_PlayerLanguage[playerid];
}

stock SetPlayerLanguage(playerid, langid)
{
	if(!IsPlayerConnected(playerid))
		return -1;

	lang_PlayerLanguage[playerid] = langid;
	return 1;
}

ShowLanguageMenu(playerid)
{
	new
		languages[MAX_LANGUAGE][MAX_LANGUAGE_NAME],
		langlist[MAX_LANGUAGE * (MAX_LANGUAGE_NAME + 1)],
		langcount;

	langcount = GetLanguageList(languages);

	for(new i; i < langcount; i++)
		format(langlist, sizeof(langlist), "%s%s\n", langlist, languages[i]);

	Dialog_Show(playerid, LanguageMenu, DIALOG_STYLE_LIST, "Idioma | Language", langlist, ""C_GREEN">", "");
}

Dialog:LanguageMenu(playerid, response, listitem, inputtext[]){
	if(response) {
		// O primeiro idioma é sempre o Português, o segundo o Inglês
		// Mas internamente o primeiro idioma é Inglês, o segundo Português

		listitem = listitem == 0 ? 1 : 0; // Aqui invertemos o valor para ficar igual ao que esta no array de idiomas

		SetPlayerLanguage(playerid, listitem);

		ChatMsgLang(playerid, YELLOW, "LANGCHANGE"); // Mostra qual o idioma que o jogador escolheu

		defer LoadAccountDelay(playerid);

		// Mostra na tela para os outros jogadores que o jogador entrou no servidor e qual o idioma escolhido. (Apenas depois de carregar a conta)
		// Mensagem personalizada para cada player no final do texto
		new lang_name[3];

		if(listitem == 0) lang_name = "EN"; else lang_name = "PT";
		
		// Mostra a entrada do jogador no chat para os outros jogadores
        new playerName[MAX_PLAYER_NAME], frase[MAX_FRASE_LEN];
		GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);
		format(frase, MAX_FRASE_LEN, "%s", dini_Get("Frases.ini", playerName));
		foreach(new i : Player) ChatMsgLang(i, WHITE, "PJOINSV", playerid, playerid, lang_name, frase);
	}
	else ShowLanguageMenu(playerid); // Player cancelled the dialog. Show it again.
}

public OnPlayerConnect(playerid)
{
    if(IsPlayerNPC(playerid))
		return 1;

	TogglePlayerSpectating(playerid, true);
	SetTimerEx("SetPlayerInCenario", 2000, false, "d", playerid);

    ShowLanguageMenu(playerid);
    
    log("[JOIN] %p joined", playerid);
    SetPlayerColor(playerid, 0xB8B8B800);

	ResetVariables(playerid);
	ply_Data[playerid][ply_JoinTick] = GetTickCount();

 	new
		ipstring[16],
		ipbyte[4];

	GetPlayerIp(playerid, ipstring, 16);

 	sscanf(ipstring, "p<.>a<d>[4]", ipbyte);
 	
	ply_Data[playerid][ply_IP] = ((ipbyte[0] << 24) | (ipbyte[1] << 16) | (ipbyte[2] << 8) | ipbyte[3]);

	if(BanCheck(playerid))
	{
		TimeoutPlayer(playerid, "Jogador Banido.");
		return 0;
	}

//	SetPlayerBrightness(playerid, 255);

	TogglePlayerControllable(playerid, false);
	Streamer_ToggleIdleUpdate(playerid, true);
	SetSpawnInfo(playerid, NO_TEAM, 0, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z, 0.0, 0, 0, 0, 0, 0, 0);
//	SpawnPlayer(playerid);

    for(new i;i<10;i++)
		SendClientMessage(playerid, WHITE, "");

	ply_Data[playerid][ply_ShowHUD] = true;

	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(gServerRestarting)
		return 0;

	Logout(playerid);

	if(reason != 2)
		foreach(new i : Player) ChatMsgLang(i, WHITE, "PLEFTSV", playerid, playerid);
	    
	SetTimerEx("OnPlayerDisconnected", 100, false, "dd", playerid, reason);

	return 1;
}

stock GetTotalPlayers()
{
	new count = 0;

	foreach(new i : Player) count++;

	return count;
}

timer LoadAccountDelay[SEC(6)](playerid)
{
	if(!IsPlayerConnected(playerid))
	{
		log("[LoadAccountDelay] Player %d not connected any more.", playerid);
		return;
	}

	if(gServerInitialising || GetTickCountDifference(GetTickCount(), gServerInitialiseTick) < 5000)
	{
		ChatMsg(playerid, WHITE, "Servidor a iniciar, por favor aguarde...");
		defer LoadAccountDelay(playerid);
		return;
	}

	new ip[16];
	GetPlayerIp(playerid, ip, sizeof ip);
	if(strcmp(ip, "127.0.0.1", true) == 1)
	{
        if(!strcmp(GetPlayerProxyStatus(playerid), "true"))
	    	AC_KickPlayer(playerid, "Proxy/VPN");
	}
	
    for(new i;i<10;i++)
		SendClientMessage(playerid, WHITE, "");

	
	new loadresult = LoadAccount(playerid);

	if(loadresult == -1) // LoadAccount aborted, kick player.
	{
		KickPlayer(playerid, "Account load failed");
		return;
	}

	if(loadresult == 0) // Account does not exist
	{
	    DisplayRegisterPrompt(playerid);
	}

	if(loadresult == 1) // Account does exist, prompt login
	{
		DisplayLoginPrompt(playerid);
	}

	if(loadresult == 2) // Account does exist, auto login
	{
		Login(playerid);
	}

	if(loadresult == 4) // Account does exists, but is disabled
	{
		ChatMsg(playerid, YELLOW, " > Essa conta foi desativada.");
		ChatMsg(playerid, YELLOW, " > Isso pode pode ter acontecido devido a criação de 2 ou mais contas no servidor.");
		ChatMsg(playerid, YELLOW, " > Saia do servidor e logue em sua conta original ou crie outra.");
		KickPlayer(playerid, "Conta inativa", false);
	}
	
//	SpawnPlayer(playerid);

	return;
}

hook OnPlayerDisconnected(playerid)
{
	dbg("global", CORE, "[OnPlayerDisconnected] in /gamemodes/sss/core/player/core.pwn");

	ResetVariables(playerid);
}

ResetVariables(playerid)
{
	ply_Data[playerid][ply_Password][0]			= EOS;
	ply_Data[playerid][ply_IP]					= 0;
	ply_Data[playerid][ply_Warnings]			= 0;

	ply_Data[playerid][ply_Alive]				= false;
	ply_Data[playerid][ply_HitPoints]			= 100.0;
	ply_Data[playerid][ply_ArmourPoints]		= 0.0;
	ply_Data[playerid][ply_FoodPoints]			= 80.0;
	ply_Data[playerid][ply_Clothes]				= 0;
	ply_Data[playerid][ply_Gender]				= 0;
	ply_Data[playerid][ply_Velocity]			= 0.0;

	ply_Data[playerid][ply_PingLimitStrikes]	= 0;
	ply_Data[playerid][ply_stance]				= 0;
	ply_Data[playerid][ply_JoinTick]			= 0;
	ply_Data[playerid][ply_SpawnTick]			= 0;

/*	SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL,			100);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SAWNOFF_SHOTGUN,	100);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI,		100);
	
	SetPlayerSkillLevel(playerid, WEAPONSKILL_M4, 				999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_AK47, 			999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SPAS12_SHOTGUN, 	999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SHOTGUN, 			999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_DESERT_EAGLE, 	999);*/

	for(new i; i < 10; i++)
		RemovePlayerAttachedObject(playerid, i);
}

ptask PlayerUpdateFast[100](playerid)
{
	new pinglimit = (Iter_Count(Player) > 10) ? (gPingLimit) : (gPingLimit + 100);

	if(GetPlayerPing(playerid) > pinglimit && GetPlayerAdminLevel(playerid) == 0)
	{
		if(GetTickCountDifference(GetTickCount(), ply_Data[playerid][ply_JoinTick]) > 10000)
		{
			ply_Data[playerid][ply_PingLimitStrikes]++;

			if(ply_Data[playerid][ply_PingLimitStrikes] == 30)
			{
				KickPlayer(playerid, sprintf("Ping muito alto: %d limite: %d.", GetPlayerPing(playerid), pinglimit));

				ply_Data[playerid][ply_PingLimitStrikes] = 0;

				return;
			}
		}
	}
	else
	{
		ply_Data[playerid][ply_PingLimitStrikes] = 0;
	}

	/*if(NetStats_MessagesRecvPerSecond(playerid) > 200)
	{
		ChatMsgAdmins(3, YELLOW, " >  %p sending %d messages per second.", playerid, NetStats_MessagesRecvPerSecond(playerid));
		return;
	}*/

	if(!IsPlayerSpawned(playerid))
		return;

	if(IsPlayerInAnyVehicle(playerid))
		PlayerVehicleUpdate(playerid);

	PlayerBagUpdate(playerid);


/*	new
		hour,
		minute;

	gettime(hour, minute);
	
	SetPlayerTime(playerid, hour, minute);*/

	return;
}

ptask PlayerUpdateSlow[SEC(1)](playerid)
{
	CallLocalFunction("OnPlayerScriptUpdate", "d", playerid);
}

public OnPlayerRequestSpawn(playerid)
{
	if(IsPlayerNPC(playerid))return 1;
	SetSpawnInfo(playerid, NO_TEAM, 0, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z, 0.0, 0, 0, 0, 0, 0, 0);

	return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(clickedid == Text:65535)
	{
		if(IsPlayerDead(playerid) && !IsPlayerSpawned(playerid))
		{
			SelectTextDraw(playerid, 0xFFFFFF88);
		}
	}

	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(IsPlayerNPC(playerid))
		return 1;

	if(IsPlayerOnAdminDuty(playerid))
	{
		SetPlayerPos(playerid, 0.0, 0.0, 3.0);
		return 1;
	}

//	SetPlayerPos(playerid, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z);
    
	ply_Data[playerid][ply_SpawnTick] = GetTickCount();

	SetAllWeaponSkills(playerid, 500);
	SetPlayerTeam(playerid, 0);
	ResetPlayerMoney(playerid);

	PlayerPlaySound(playerid, 1186, 0.0, 0.0, 0.0);
	PreloadPlayerAnims(playerid);
	Streamer_Update(playerid);
	
	SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL,			100);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SAWNOFF_SHOTGUN,	100);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI,		100);

	SetPlayerSkillLevel(playerid, WEAPONSKILL_M4, 				999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_AK47, 			999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SPAS12_SHOTGUN, 	999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_SHOTGUN, 			999);
	SetPlayerSkillLevel(playerid, WEAPONSKILL_DESERT_EAGLE, 	999);

	return 1;
}

public OnPlayerUpdate(playerid)
{
	if(IsPlayerInAnyVehicle(playerid))
	{
		static
			str[8],
			Float:vx,
			Float:vy,
			Float:vz;

		GetVehicleVelocity(GetPlayerLastVehicle(playerid), vx, vy, vz);
		ply_Data[playerid][ply_Velocity] = floatsqroot( (vx*vx)+(vy*vy)+(vz*vz) ) * 150.0;
		format(str, 32, "%.0fkm/h", ply_Data[playerid][ply_Velocity]);
		//SetPlayerVehicleSpeedUI(playerid, str);
	}
	else
	{
		static
			Float:vx,
			Float:vy,
			Float:vz;

		GetPlayerVelocity(playerid, vx, vy, vz);
		ply_Data[playerid][ply_Velocity] = floatsqroot( (vx*vx)+(vy*vy)+(vz*vz) ) * 150.0;
	}

	if(ply_Data[playerid][ply_Alive])
	{
		if(IsPlayerOnAdminDuty(playerid))
			ply_Data[playerid][ply_HitPoints] = 250.0;

		SetPlayerHealth(playerid, ply_Data[playerid][ply_HitPoints]);
		SetPlayerArmour(playerid, ply_Data[playerid][ply_ArmourPoints]);
	}
	else
	{
		SetPlayerHealth(playerid, 100.0);
	}

	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsPlayerKnockedOut(playerid))
		return 0;
	    
	return 1;
}

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
	dbg("global", CORE, "[OnPlayerStateChange] in /gamemodes/sss/core/player/core.pwn");

	if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
	{
		ShowPlayerDialog(playerid, -1, DIALOG_STYLE_MSGBOX, " ", " ", " ", " ");
		HidePlayerGear(playerid);
	}

	return 1;
}

hook OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	dbg("global", CORE, "[OnPlayerEnterVehicle] in /gamemodes/sss/core/player/core.pwn");

	if(IsPlayerKnockedOut(playerid))
		CancelPlayerMovement(playerid);

	if(GetPlayerSurfingVehicleID(playerid) == vehicleid)
		CancelPlayerMovement(playerid);

	if(ispassenger)
	{
		new driverid = -1;

		foreach(new i : Player)
		{
			if(IsPlayerInVehicle(i, vehicleid))
			{
				if(GetPlayerState(i) == PLAYER_STATE_DRIVER)
				{
					driverid = i;
				}
			}
		}

		if(driverid == -1)
			CancelPlayerMovement(playerid);
	}

	return 1;
}

KillPlayer(playerid, killerid, deathreason)
{
	CallLocalFunction("OnDeath", "ddd", playerid, killerid, deathreason);
}

// ply_Password
stock GetPlayerPassHash(playerid, string[MAX_PASSWORD_LEN])
{
	if(!IsPlayerConnected(playerid))
		return 0;

	string[0] = EOS;
	strcat(string, ply_Data[playerid][ply_Password]);

	return 1;
}

stock SetPlayerPassHash(playerid, string[MAX_PASSWORD_LEN])
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_Password] = string;

	return 1;
}

// ply_IP
stock GetPlayerIpAsInt(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return ply_Data[playerid][ply_IP];
}

// ply_RegisterTimestamp
stock GetPlayerRegTimestamp(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return ply_Data[playerid][ply_RegisterTimestamp];
}

stock SetPlayerRegTimestamp(playerid, timestamp)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_RegisterTimestamp] = timestamp;

	return 1;
}

// ply_LastLogin
stock GetPlayerLastLogin(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return ply_Data[playerid][ply_LastLogin];
}

stock SetPlayerLastLogin(playerid, timestamp)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_LastLogin] = timestamp;

	return 1;
}

// ply_TotalSpawns
stock GetPlayerTotalSpawns(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return ply_Data[playerid][ply_TotalSpawns];
}

stock SetPlayerTotalSpawns(playerid, amount)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_TotalSpawns] = amount;

	return 1;
}

// ply_Warnings
stock GetPlayerWarnings(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return ply_Data[playerid][ply_Warnings];
}

stock SetPlayerWarnings(playerid, timestamp)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_Warnings] = timestamp;

	return 1;
}

// ply_Alive
stock IsPlayerAlive(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return ply_Data[playerid][ply_Alive];
}

stock SetPlayerAliveState(playerid, bool:st)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_Alive] = st;

	return 1;
}

// ply_ShowHUD
stock IsPlayerHudOn(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;

	return ply_Data[playerid][ply_ShowHUD];
}

stock TogglePlayerHUD(playerid, bool:toggle)
{
	if(!IsPlayerConnected(playerid)) return 0;

	if(toggle) { // Mostrar Textdraws de Restart
		TextDrawShowForPlayer(playerid, RestartCount);
		TextDrawShowForPlayer(playerid, ClockRestart);
	} else { // Esconder Textdraws de Restart
		TextDrawHideForPlayer(playerid, RestartCount);
		TextDrawHideForPlayer(playerid, ClockRestart);
	}

	ply_Data[playerid][ply_ShowHUD] = toggle;

	return 1;
}

// ply_HitPoints
forward Float:GetPlayerHP(playerid);
stock Float:GetPlayerHP(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0.0;

	return ply_Data[playerid][ply_HitPoints];
}

stock SetPlayerHP(playerid, Float:hp)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	if(hp > 100.0)
		hp = 100.0;

	ply_Data[playerid][ply_HitPoints] = hp;

	return 1;
}

// ply_ArmourPoints
forward Float:GetPlayerAP(playerid);
stock Float:GetPlayerAP(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0.0;

	return ply_Data[playerid][ply_ArmourPoints];
}

stock SetPlayerAP(playerid, Float:amount)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_ArmourPoints] = amount;

	return 1;
}

// ply_FoodPoints
forward Float:GetPlayerFP(playerid);
stock Float:GetPlayerFP(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0.0;

	return ply_Data[playerid][ply_FoodPoints];
}

stock SetPlayerFP(playerid, Float:food)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_FoodPoints] = food;

	return 1;
}

// ply_Clothes
stock GetPlayerClothesID(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return ply_Data[playerid][ply_Clothes];
}

stock SetPlayerClothesID(playerid, id)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_Clothes] = id;

	return 1;
}

// ply_Gender
stock GetPlayerGender(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return ply_Data[playerid][ply_Gender];
}

stock SetPlayerGender(playerid, gender)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_Gender] = gender;

	return 1;
}

// ply_Velocity
forward Float:GetPlayerTotalVelocity(playerid);
Float:GetPlayerTotalVelocity(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0.0;

	return ply_Data[playerid][ply_Velocity];
}

// ply_CreationTimestamp
stock GetPlayerCreationTimestamp(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return ply_Data[playerid][ply_CreationTimestamp];
}

stock SetPlayerCreationTimestamp(playerid, timestamp)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_CreationTimestamp] = timestamp;

	return 1;
}

// ply_PingLimitStrikes
// ply_stance
stock GetPlayerStance(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return ply_Data[playerid][ply_stance];
}

stock SetPlayerStance(playerid, stance)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	ply_Data[playerid][ply_stance] = stance;

	return 1;
}

// ply_JoinTick
stock GetPlayerServerJoinTick(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return ply_Data[playerid][ply_JoinTick];
}

// ply_SpawnTick
stock GetPlayerSpawnTick(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return ply_Data[playerid][ply_SpawnTick];
}