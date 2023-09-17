#include <YSI\y_hooks>

static
	Request:ac_requests[MAX_PLAYERS],
	bool:ac_active = true,
	player_AntiCheat[MAX_PLAYERS] = 0;

hook OnPlayerLogin(playerid) {
    new ip[16];

	GetPlayerIp(playerid, ip, sizeof ip);

	// if(strcmp(ip, "127.0.0.1", true) == 0) return 1; // Ignore localhost

	ac_requests[playerid] = Request(Requests, sprintf("anticheat.php?nick=%s&ip=%s", GetPlayerNameEx(playerid), ip), HTTP_METHOD_GET, "OnGetData");

	return 1;
}

forward OnGetData(Request:id, E_HTTP_STATUS:status, data[], dataLen);
public OnGetData(Request:id, E_HTTP_STATUS:status, data[], dataLen) {
	// log("OnGetData: %d, %d, %s, %d", _:id, _:status, data, dataLen);

	new playerid = INVALID_PLAYER_ID;

	// Find the playerid that made this request
	foreach(new i : Player) {
		if(ac_requests[i] == id) {
			playerid = i;
			break;
		}
	}

    if(status == HTTP_STATUS_SERVER_ERROR) { // Server error
		if(ac_active) {
			ac_active = false;
			ChatMsgAdmins(1, YELLOW, "[Anti-Cheat] Servidor de anti-cheat n�o est� respondendo!");
			log("[ANTICHEAT]: Servidor de anti-cheat n�o est� respondendo!");
		}
	} else { // Esta respondendo corretamente
		if(!ac_active) {
			ac_active = true; // Se o servidor de anti-cheat voltou a responder, ativa o anticheat
			ChatMsgAdmins(1, YELLOW, "[Anti-Cheat] Servidor de anti-cheat voltou a responder!");
			log("[ANTICHEAT]: Servidor de anti-cheat voltou a responder!");
		}

		switch(status) {
			case HTTP_STATUS_ACCEPTED: { // Anti-cheat iniciado
				player_AntiCheat[playerid] = 1;
			}
			case HTTP_STATUS_FORBIDDEN: { // Anti-cheat nao autorizado
				player_AntiCheat[playerid] = 2;

				foreach(new p : Player) {
					if(p != playerid) ChatMsg(p, YELLOW, "[Anti-Cheat] %P (%d)"C_YELLOW" nao esta autorizado a entrar!", playerid, playerid);
				}

				log("[ANTICHEAT] Nao autorizado: %s (%d)", GetPlayerNameEx(playerid), playerid);
			}
			case HTTP_STATUS_NOT_FOUND: { // Anti-cheat n�o iniciado
				// new adminCount = GetAdminsOnline();

				// Tell all the players that this player joined without using the anti-cheat
				foreach(new p : Player) {
					if(p != playerid) ChatMsg(p, YELLOW, "[Anti-Cheat] %P (%d)"C_YELLOW" entrou sem usar o anti-cheat!", playerid, playerid);
				}

				log("[ANTICHEAT] Nao iniciado: %s (%d)", GetPlayerNameEx(playerid), playerid);
			}
			default: { // Nao e suposto acontecer
				log("[ANTICHEAT] %s (%d) - Resposta desconhecida: %d", GetPlayerNameEx(playerid), playerid, _:status);
			}
		}
	}

	// Free the request
	ac_requests[playerid] = Request:0;
}

public OnRequestFailure(Request:id, errorCode, errorMessage[], len) {
	printf("error: %d, message: '%s'", errorCode, errorMessage);
}

/* forward AnticheatBackendResponse(playerid, response_code, data[]);
public AnticheatBackendResponse(playerid, response_code, data[])
{
	if(response_code == 500) { // Server error
		if(ac_active) {
			ac_active = false;
			ChatMsgAdmins(1, YELLOW, "[Anti-Cheat] Servidor de anti-cheat n�o est� respondendo!");
			log("[ANTICHEAT]: Servidor de anti-cheat n�o est� respondendo!");
		}

		return 1;
	} else { // Esta respondendo corretamente
		if(!ac_active) {
			ac_active = true; // Se o servidor de anti-cheat voltou a responder, ativa o anticheat
			ChatMsgAdmins(1, YELLOW, "[Anti-Cheat] Servidor de anti-cheat voltou a responder!");
			log("[ANTICHEAT]: Servidor de anti-cheat voltou a responder!");
		}

		switch(response_code) {
			case 202: { // Anti-cheat iniciado
				player_AntiCheat[playerid] = 1;
			}
			case 403: { // Anti-cheat nao autorizado
				player_AntiCheat[playerid] = 2;
			}
			case 404: { // Anti-cheat n�o iniciado
				// new adminCount = GetAdminsOnline();

				// Tell all the players that this player joined without using the anti-cheat
				foreach(new p : Player) {
					if(p != playerid) ChatMsg(p, YELLOW, "[Anti-Cheat] %P (id:%d) entrou sem usar o anti-cheat!", playerid, playerid);
				}
			}
			default: { // Nao e suposto acontecer
				log("[ANTICHEAT] %s (%d) - Resposta desconhecida: %d", GetPlayerName(playerid), playerid, response_code);
			}
		}
	}

	return 1;
} */