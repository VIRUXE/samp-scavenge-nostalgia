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
			ply_Name[MAX_PLAYER_NAME],
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
forward OnPlayerJoinScenario(playerid);

public OnPlayerRequestClass(playerid, classid)
{
	if(IsPlayerNPC(playerid)) return 1;

	SetSpawnInfo(playerid, NO_TEAM, 0, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z, 0.0, 0, 0, 0, 0, 0, 0);

	return 0;
}

Dialog:WelcomeMessage(playerid, response, listitem, inputtext[]) {
	if(response) DisplayRegisterPrompt(playerid);
	else Kick(playerid);
}

_OnPlayerConnect(playerid) {
	log("[JOIN] %p (%d) entrou.", playerid, playerid);
	SetPlayerColor(playerid, 0xB8B8B800);

	/* 
		Aparentemente essa merda é mesmo necessária, senão o spawn fica bugado.
		Idealmente o reset de varíaveis deveria ser feito no OnPlayerDisconnect, mas por alguma razão está assim.
		Não vale a pena estar a mexer nisso agora.
	 */
	ResetVariables(playerid);
	ply_Data[playerid][ply_JoinTick] = GetTickCount();

	// Obtemos o IP para verificar se o jogador esta banido ou nao
 	new ipstring[16], ipbyte[4];

	GetPlayerIp(playerid, ipstring, 16);

 	sscanf(ipstring, "p<.>a<d>[4]", ipbyte);
 	
	ply_Data[playerid][ply_IP] = ((ipbyte[0] << 24) | (ipbyte[1] << 16) | (ipbyte[2] << 8) | ipbyte[3]);

	if(BanCheck(playerid))
	{
		TimeoutPlayer(playerid, "Jogador Banido.");
		return 0;
	}

	// Limpa o chat
	for(new i;i<10;i++) SendClientMessage(playerid, WHITE, "");

	// Primeiro colocamos o jogador no mundo
 	SetSpawnInfo(playerid, NO_TEAM, 0, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z, 0.0, 0, 0, 0, 0, 0, 0);
	SpawnPlayer(playerid);

	// Depois desativamos o controle do jogador
	TogglePlayerControllable(playerid, false);
	Streamer_ToggleIdleUpdate(playerid, true);

	// Agora colocamos o jogador no cenario aleatorio. (Onde ele vai ser colocado no mapa)
	defer SetJoinScenario(playerid);


	ply_Data[playerid][ply_ShowHUD] = true;

	return 1;
}

public OnPlayerConnect(playerid)
{
	if(IsPlayerNPC(playerid)) return 0;

	SetPlayerScreenFade(playerid, 255);

	new ip[16];
	GetPlayerIp(playerid, ip, 16);

	if(IsOTPModeEnabled() && !isequal(ip, "127.0.0.1")) {
        GenerateOTP(playerid);
        ShowOTPPrompt(playerid);
	} else {
		SetPlayerScreenFade(playerid, 0);
		_OnPlayerConnect(playerid);
	}

	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(gServerRestarting) return 0;

	Logout(playerid);

	if(reason != 2) foreach(new i : Player) ChatMsgLang(i, WHITE, "PLEFTSV", playerid, playerid);
		
	SetTimerEx("OnPlayerDisconnected", 100, false, "d", playerid);

	return 1;
}

public OnPlayerDisconnected(playerid)
{
	dbg("global", CORE, "[OnPlayerDisconnected] in /gamemodes/sss/core/player/core.pwn");

	ResetVariables(playerid);
}

/* 
	Esta função é chamada quando o jogador entra num cenario, após o OnPlayerConnect.

	Esta função é chamada apenas uma vez, e é responsável por carregar a conta do jogador, ou criar uma nova conta.
 */
public OnPlayerJoinScenario(playerid) {
	new result = LoadAccount(playerid);

	// Carregamento abortado
	if(result == -1) 
		KickPlayer(playerid, "Carregamento da conta falhou. Informe um administrador no Discord.");
	// Conta nao existe
	else if(result == 0) {
		// * Um bocado gambiarra, mas pronto
		// Como é necessário esperar pela resposta da API então por enquanto vai assim
		GetPlayerGeo(playerid);
	}
	// Conta existe
	else if(result == 1) 
		DisplayLoginPrompt(playerid);
	// Conta existe mas esta desativada
	else if(result == 4) {
		ChatMsg(playerid, YELLOW, " > Essa conta foi desativada.");
		ChatMsg(playerid, YELLOW, " > Isso pode pode ter acontecido devido a criação de 2 ou mais contas no servidor.");
		ChatMsg(playerid, YELLOW, " > Saia do servidor e logue em sua conta original ou crie outra.");
		KickPlayer(playerid, "Conta inativa", false);
	}
}

ResetVariables(playerid)
{
	ply_Data[playerid][ply_Name][0]				= EOS;
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

	for(new i; i < 10; i++) RemovePlayerAttachedObject(playerid, i);

	// log("[INFO] Variaveis resetadas para o jogador %d.", playerid);
}

ptask PlayerUpdateFast[100](playerid)
{
	new ping = GetPlayerPing(playerid);

	if(ping > gPingLimit && GetPlayerAdminLevel(playerid) == 0)
	{
		if(GetTickCountDifference(GetTickCount(), ply_Data[playerid][ply_JoinTick]) > SEC(10)) // Ignorar o ping dos primeiros 10 segundos
		{
			ply_Data[playerid][ply_PingLimitStrikes]++;

			// Remover o jogador se o ping continuar alto, após 3 segundos
			if(ply_Data[playerid][ply_PingLimitStrikes] == 30) // 30*100 = 3000ms = 3s
			{
				TimeoutPlayer(playerid, sprintf("Ping muito alto: %d/%d. Normalize o mesmo e volte dentro de 1 minuto.", ping, gPingLimit), MIN(1));

				ply_Data[playerid][ply_PingLimitStrikes] = 0;

				return;
			}
		}
	}
	else if(ply_Data[playerid][ply_PingLimitStrikes]) // Resetar o contador de strikes do ping
		ply_Data[playerid][ply_PingLimitStrikes] = 0;

	/*if(NetStats_MessagesRecvPerSecond(playerid) > 200)
	{
		ChatMsgAdmins(3, YELLOW, " >  %p sending %d messages per second.", playerid, NetStats_MessagesRecvPerSecond(playerid));
		return;
	}*/

	if(!IsPlayerSpawned(playerid)) return;

	if(IsPlayerInAnyVehicle(playerid)) PlayerVehicleUpdate(playerid);

	PlayerBagUpdate(playerid);

	return;
}

ptask PlayerUpdateSlow[SEC(1)](playerid) CallLocalFunction("OnPlayerScriptUpdate", "d", playerid);

public OnPlayerRequestSpawn(playerid)
{
	if(IsPlayerNPC(playerid)) return 1;

	SetSpawnInfo(playerid, NO_TEAM, 0, DEFAULT_POS_X, DEFAULT_POS_Y, DEFAULT_POS_Z, 0.0, 0, 0, 0, 0, 0, 0);

	return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	if(clickedid == Text:65535)
	{
		if(IsPlayerDead(playerid) && !IsPlayerSpawned(playerid)) SelectTextDraw(playerid, 0xFFFFFF88);
	}

	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(IsPlayerNPC(playerid)) return 1;

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
		static str[8], Float:vx, Float:vy, Float:vz;

		GetVehicleVelocity(GetPlayerLastVehicle(playerid), vx, vy, vz);
		ply_Data[playerid][ply_Velocity] = floatsqroot( (vx*vx)+(vy*vy)+(vz*vz) ) * 150.0;
		format(str, 32, "%.0fkm/h", ply_Data[playerid][ply_Velocity]);
		//SetPlayerVehicleSpeedUI(playerid, str);
	}
	else
	{
		static Float:vx, Float:vy, Float:vz;

		GetPlayerVelocity(playerid, vx, vy, vz);
		ply_Data[playerid][ply_Velocity] = floatsqroot( (vx*vx)+(vy*vy)+(vz*vz) ) * 150.0;
	}

	if(ply_Data[playerid][ply_Alive])
	{
		if(IsPlayerOnAdminDuty(playerid)) ply_Data[playerid][ply_HitPoints] = 250.0;

		SetPlayerHealth(playerid, ply_Data[playerid][ply_HitPoints]);
		SetPlayerArmour(playerid, ply_Data[playerid][ply_ArmourPoints]);
	}
	else SetPlayerHealth(playerid, 100.0);

	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(IsPlayerKnockedOut(playerid)) return 0;
		
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

	if(IsPlayerKnockedOut(playerid)) CancelPlayerMovement(playerid);

	if(GetPlayerSurfingVehicleID(playerid) == vehicleid) CancelPlayerMovement(playerid);

	if(ispassenger)
	{
		new driverid = -1;

		foreach(new i : Player)
			if(IsPlayerInVehicle(i, vehicleid) && GetPlayerState(i) == PLAYER_STATE_DRIVER) driverid = i;

		if(driverid == -1) CancelPlayerMovement(playerid);
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
	if(!IsPlayerConnected(playerid)) return 0;

	string[0] = EOS;
	strcat(string, ply_Data[playerid][ply_Password]);

	return 1;
}

stock SetPlayerPassHash(playerid, string[MAX_PASSWORD_LEN])
{
	if(!IsPlayerConnected(playerid)) return 0;

	ply_Data[playerid][ply_Password] = string;

	return 1;
}

// ply_IP
stock GetPlayerIpAsInt(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;

	return ply_Data[playerid][ply_IP];
}

// ply_RegisterTimestamp
stock GetPlayerRegTimestamp(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;

	return ply_Data[playerid][ply_RegisterTimestamp];
}

stock SetPlayerRegTimestamp(playerid, timestamp)
{
	if(!IsPlayerConnected(playerid)) return 0;

	ply_Data[playerid][ply_RegisterTimestamp] = timestamp;

	return 1;
}

// ply_LastLogin
stock GetPlayerLastLogin(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;

	return ply_Data[playerid][ply_LastLogin];
}

stock SetPlayerLastLogin(playerid, timestamp)
{
	if(!IsPlayerConnected(playerid)) return 0;

	ply_Data[playerid][ply_LastLogin] = timestamp;

	return 1;
}

// ply_TotalSpawns
stock GetPlayerTotalSpawns(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;

	return ply_Data[playerid][ply_TotalSpawns];
}

stock SetPlayerTotalSpawns(playerid, amount)
{
	if(!IsPlayerConnected(playerid)) return 0;

	ply_Data[playerid][ply_TotalSpawns] = amount;

	return 1;
}

// ply_Warnings
stock GetPlayerWarnings(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;

	return ply_Data[playerid][ply_Warnings];
}

stock SetPlayerWarnings(playerid, timestamp)
{
	if(!IsPlayerConnected(playerid)) return 0;

	ply_Data[playerid][ply_Warnings] = timestamp;

	return 1;
}

// ply_Alive
stock IsPlayerAlive(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;

	return ply_Data[playerid][ply_Alive];
}

stock SetPlayerAliveState(playerid, bool:st)
{
	if(!IsPlayerConnected(playerid)) return 0;

	ply_Data[playerid][ply_Alive] = st;

	return 1;
}

// ply_ShowHUD
stock IsPlayerHudOn(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;

	return ply_Data[playerid][ply_ShowHUD];
}

/* 
	TODO: Refatorar essa merda. Esta dividido
 */
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
	if(!IsPlayerConnected(playerid)) return 0;

	if(hp > 100.0) hp = 100.0;

	ply_Data[playerid][ply_HitPoints] = hp;

	return 1;
}

// ply_ArmourPoints
forward Float:GetPlayerAP(playerid);
stock Float:GetPlayerAP(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0.0;

	return ply_Data[playerid][ply_ArmourPoints];
}

stock SetPlayerAP(playerid, Float:amount)
{
	if(!IsPlayerConnected(playerid)) return 0;

	ply_Data[playerid][ply_ArmourPoints] = amount;

	return 1;
}

// ply_FoodPoints
forward Float:GetPlayerFP(playerid);
stock Float:GetPlayerFP(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0.0;

	return ply_Data[playerid][ply_FoodPoints];
}

stock SetPlayerFP(playerid, Float:food)
{
	if(!IsPlayerConnected(playerid)) return 0;

	ply_Data[playerid][ply_FoodPoints] = food;

	return 1;
}

// ply_Clothes
stock GetPlayerClothesID(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;

	return ply_Data[playerid][ply_Clothes];
}

stock SetPlayerClothesID(playerid, id)
{
	if(!IsPlayerConnected(playerid)) return 0;

	ply_Data[playerid][ply_Clothes] = id;

	return 1;
}

// ply_Gender
stock GetPlayerGender(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;

	return ply_Data[playerid][ply_Gender];
}

stock SetPlayerGender(playerid, gender)
{
	if(!IsPlayerConnected(playerid)) return 0;

	ply_Data[playerid][ply_Gender] = gender;

	return 1;
}

// ply_Velocity
forward Float:GetPlayerTotalVelocity(playerid);
Float:GetPlayerTotalVelocity(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0.0;

	return ply_Data[playerid][ply_Velocity];
}

// ply_CreationTimestamp
stock GetPlayerCreationTimestamp(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;

	return ply_Data[playerid][ply_CreationTimestamp];
}

stock SetPlayerCreationTimestamp(playerid, timestamp)
{
	if(!IsPlayerConnected(playerid)) return 0;

	ply_Data[playerid][ply_CreationTimestamp] = timestamp;

	return 1;
}

// ply_PingLimitStrikes
// ply_stance
stock GetPlayerStance(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;

	return ply_Data[playerid][ply_stance];
}

stock SetPlayerStance(playerid, stance)
{
	if(!IsPlayerConnected(playerid)) return 0;

	ply_Data[playerid][ply_stance] = stance;

	return 1;
}

// ply_JoinTick
stock GetPlayerServerJoinTick(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;

	return ply_Data[playerid][ply_JoinTick];
}

// ply_SpawnTick
stock GetPlayerSpawnTick(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;

	return ply_Data[playerid][ply_SpawnTick];
}

timer SetJoinScenario[20](playerid) {
	new Float:scenarios[][3][3] = {
		// SetPlayerCameraPos, SetPlayerCameraLookAt, SetPlayerPos
		{{-4402.01, 438.92, 19.86},  {-4407.65, 440.87, 19.31},  {-4407.65, 440.87, 19.31}},  // Ilha de San Fierro
		{{1568.44, -1618.81, 18.85}, {1573.13, -1622.37, 17.68}, {1573.13, -1622.37, 17.68}}, // DP Los Santos
		{{2476.43, -2245.37, 39.12}, {2477.57, -2251.09, 37.70}, {2477.57, -2251.09, 37.70}}, // Ponte das Docas
		{{-1988.27, 134.76, 34.10},  {-1993.59, 137.42, 33.33},  {-1993.59, 137.42, 33.33}},  // Posto de Gasolina CJ
		{{-2702.09, 2084.70, 63.86}, {-2698.83, 2089.62, 62.80}, {-2698.83, 2089.62, 62.80}}, // Ponte Bayside
		{{-2303.76, 2676.05, 57.35}, {-2298.30, 2673.60, 56.99}, {-2298.30, 2673.60, 56.99}}, // Ponte Bayside 2
		{{-1519.95, 2536.79, 57.15}, {-1517.24, 2531.51, 56.33}, {-1517.24, 2531.51, 56.33}}  // Hospital de East Los Santos
	};

	new sounds[][] = {
		"uw3jdo6s0u9urgu/NS.mp3",
		"b0yozgytqbvqhch/NS2.mp3",
		"3d2s9x1ay0jgefq/NS3.mp3",
		"eh9w2adw0vp2yvd/NS4.mp3",
		"m0ub0mve3q8m0wi/NS5.mp3"
	};

	new soundURL[1 + 36 + 23]; // 1 for null terminator, 36 for "https://dl.dropboxusercontent.com/s/", and 23 for the longest sound name
	format(soundURL, sizeof(soundURL), "https://dl.dropboxusercontent.com/s/%s", sounds[random(sizeof(sounds) - 1)]);

	PlayAudioStreamForPlayer(playerid, soundURL);

	SetPlayerTime(playerid, 0, 0);
	SetPlayerWeather(playerid, 20);
  
	new scenario = random(sizeof(scenarios) - 1);
	SetPlayerCameraPos(playerid, scenarios[scenario][0][0], scenarios[scenario][0][1], scenarios[scenario][0][2]);
	SetPlayerCameraLookAt(playerid, scenarios[scenario][1][0], scenarios[scenario][1][1], scenarios[scenario][1][2]);
	SetPlayerPos(playerid, scenarios[scenario][2][0], scenarios[scenario][2][1], scenarios[scenario][2][2] - 100);

	// log("[JOIN] %p (%d) foi para o cenário %d", playerid, playerid, scenario);

	CallLocalFunction("OnPlayerJoinScenario", "i", playerid);
}