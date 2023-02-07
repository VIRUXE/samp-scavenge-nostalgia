#include <YSI\y_hooks>

static
	bool:anticheat_Active = true,
	player_AntiCheat[MAX_PLAYERS] = 0;

hook OnGameModeInit() {
	client = RequestsClient("https://vulpecula.flaviopereira.digital/", RequestHeaders());
}

hook OnPlayerLogin(playerid)
{
    new ip[16], nick[MAX_PLAYER_NAME];

	GetPlayerIp(playerid, ip, sizeof ip);
	GetPlayerName(playerid, nick, MAX_PLAYER_NAME);

	// if(strcmp(ip, "127.0.0.1", true) == 0) return 1; // Ignore localhost

	new urlPath[24+MAX_PLAYER_NAME+16]; // 23 = strlen("nostalgia/anticheat.php?"), MAX_PLAYER_NAME = 24, 16 = ip length, plus 1 for null terminator

	format(urlPath, sizeof urlPath, "nostalgia/anticheat.php?nick=%s&ip=%s", nick, ip);

	Request(client, urlPath, HTTP_METHOD_GET, "OnGetData");

	return 1;
}

forward OnGetData(Request:id, E_HTTP_STATUS:status, data[], dataLen);
public OnGetData(Request:id, E_HTTP_STATUS:status, data[], dataLen) {
    printf("status: %d, data: '%s'", _:status, data);
}

public OnRequestFailure(Request:id, errorCode, errorMessage[], len) {
	printf("error: %d, message: '%s'", errorCode, errorMessage);
}

/* forward AnticheatBackendResponse(playerid, response_code, data[]);
public AnticheatBackendResponse(playerid, response_code, data[])
{
	if(response_code == 500) { // Server error
		if(anticheat_Active) {
			anticheat_Active = false;
			ChatMsgAdmins(1, YELLOW, "[Anti-Cheat] Servidor de anti-cheat não está respondendo!");
			log("Anti-Cheat: Servidor de anti-cheat não está respondendo!");
		}

		return 1;
	} else { // Esta respondendo corretamente
		if(!anticheat_Active) {
			anticheat_Active = true; // Se o servidor de anti-cheat voltou a responder, ativa o anticheat
			ChatMsgAdmins(1, YELLOW, "[Anti-Cheat] Servidor de anti-cheat voltou a responder!");
			log("Anti-Cheat: Servidor de anti-cheat voltou a responder!");
		}

		switch(response_code) {
			case 202: { // Anti-cheat iniciado
				player_AntiCheat[playerid] = 1;
			}
			case 403: { // Anti-cheat nao autorizado
				player_AntiCheat[playerid] = 2;
			}
			case 404: { // Anti-cheat não iniciado
				// new adminCount = GetAdminsOnline();

				// Tell all the players that this player joined without using the anti-cheat
				foreach(new p : Player) {
					if(p != playerid) ChatMsg(p, YELLOW, "[Anti-Cheat] %P (id:%d) entrou sem usar o anti-cheat!", playerid, playerid);
				}
			}
			default: { // Nao e suposto acontecer
				log("[Anti-Cheat] %s (%d) - Resposta desconhecida: %d", GetPlayerName(playerid), playerid, response_code);
			}
		}
	}

	return 1;
} */