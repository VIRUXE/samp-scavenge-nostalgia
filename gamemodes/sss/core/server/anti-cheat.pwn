#include <YSI\y_hooks>

static
	bool:anticheat_Active = true,
	player_AntiCheat[MAX_PLAYERS] = 0;

hook OnPlayerLogin(playerid)
{
    new ip[16], nick[MAX_PLAYER_NAME];

	GetPlayerIp(playerid, ip, sizeof ip);
	GetPlayerName(playerid, nick, MAX_PLAYER_NAME);

	// if(strcmp(ip, "127.0.0.1", true) == 0) return 1; // Ignore localhost

	new url[106];
	format(url, sizeof url, "vulpecula.flaviopereira.digital/nostalgia/anticheat.php?ip=%s&nick=%s", ip, nick);

	log(url);

	HTTP(playerid, HTTP_HEAD, url, "", "AnticheatBackendResponse"); // Send the request to the anti-cheat backend

	return 1;
}

forward AnticheatBackendResponse(playerid, response_code, data[]);
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
}