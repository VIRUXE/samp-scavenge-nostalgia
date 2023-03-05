#include <YSI\y_hooks>

#define MAX_COUNTRY_NAME 32
#define MAX_COUNTRY_CODE 3

#define INVALID_REQUEST_ID -1 // * Idealmente isso deveria ser colocado noutro lado, mas por enquanto fica aqui.

enum GEO_DATA {
	Request:GEO_REQUEST_ID, // Cada jogador tem uma requisicao para ele
	GEO_COUNTRY[MAX_COUNTRY_NAME],
	GEO_COUNTRY_CODE[MAX_COUNTRY_CODE]
};

static 
		RequestsClient:geo_client,
		geo[MAX_PLAYERS][GEO_DATA];

forward OnGeoResponse(Request:id, E_HTTP_STATUS:status, Node:node);
public OnGeoResponse(Request:id, E_HTTP_STATUS:status, Node:node) {
    // First get who this request belongs to.
	new playerid = INVALID_PLAYER_ID;

	foreach(new i : Player) {
		if (geo[i][GEO_REQUEST_ID] == id) {
			playerid = i;
			break;
		}
	}

	// If we didn't find the player, then we can't do anything.
	if (playerid == INVALID_PLAYER_ID) return;

	// Reset the request ID.
	geo[playerid][GEO_REQUEST_ID] = Request:INVALID_REQUEST_ID;

	// If the request failed, then we can't do anything.
	if (status != HTTP_STATUS_OK) return;

	// Se chegamos aqui, a requisicao foi bem sucedida. Vamos pegar os dados.
    JsonGetString(node, "country", geo[playerid][GEO_COUNTRY]);
	JsonGetString(node, "countryCode", geo[playerid][GEO_COUNTRY_CODE]);

	log("[GEO][%d] %p (%d) é de %s (%s)", _:id, playerid, playerid, geo[playerid][GEO_COUNTRY], geo[playerid][GEO_COUNTRY_CODE]);
}

hook OnRequestFailure(Request:id, errorCode, errorMessage[], len) {
	// First get who this request belongs to.
	new playerid = INVALID_PLAYER_ID;

	foreach(new i : Player) {
		if (geo[i][GEO_REQUEST_ID] == id) {
			playerid = i;
			break;
		}
	}

	// If we didn't find the player, then we can't do anything.
	if (playerid == INVALID_PLAYER_ID) return; // It means that the request was not made by this script.

	log("[GEO][%d] Requisicao falhou para '%p' (%d)", _:id, playerid, playerid);

	// Reset the request ID.
	geo[playerid][GEO_REQUEST_ID] = Request:INVALID_REQUEST_ID;
}

hook OnGameModeInit() {
	geo_client = RequestsClient("http://ip-api.com", RequestHeaders());
}

hook OnPlayerConnect(playerid) {
	// Get the player's IP.
	new address[254]; // 254 is the maximum length of an IPv6 address.
	GetPlayerIp(playerid, address, 16);

	if(isequal(address, "127.0.0.1")) address = "sv.scavengenostalgia.fun";

	// Request the data.
	new query[45 + sizeof(address) + 1]; // length of the URL + length of the IP + null terminator
	format(query, sizeof(query), "/json/%s?fields=country,countryCode&lang=pt-BR", address);

	geo[playerid][GEO_REQUEST_ID] = RequestJSON(geo_client, query, HTTP_METHOD_GET, "OnGeoResponse");

	log("[GEO][%d] Requisitando dados geograficos de '%p' (%d)", _:geo[playerid][GEO_REQUEST_ID], playerid, playerid);
}

hook OnPlayerDisconnect(playerid, reason) {
	// Reset the data.
	geo[playerid][GEO_REQUEST_ID] = Request:INVALID_REQUEST_ID;
	geo[playerid][GEO_COUNTRY][0] = '\0';
	geo[playerid][GEO_COUNTRY_CODE][0] = '\0';
}