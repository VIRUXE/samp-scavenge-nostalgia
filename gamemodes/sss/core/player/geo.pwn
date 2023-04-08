#include <YSI\y_hooks>

#define MAX_COUNTRY_NAME 32
#define MAX_COUNTRY_CODE 3

#define INVALID_REQUEST_ID -1 // * Idealmente isso deveria ser colocado noutro lado, mas por enquanto fica aqui.

#define GetPlayerCountry(%1) geo[%1][GEO_COUNTRY]
#define GetPlayerCountryCode(%1) geo[%1][GEO_COUNTRY_CODE]

enum GEO_DATA {
	Request:GEO_REQUEST_ID, // Cada jogador tem uma requisicao para ele
	GEO_COUNTRY[MAX_COUNTRY_NAME],
	GEO_COUNTRY_CODE[MAX_COUNTRY_CODE]
};

static 
		RequestsClient:geo_client,
		geo[MAX_PLAYERS][GEO_DATA];

/* stock GetPlayerCountry(playerid, country[], len) {
	strcpy(country, geo[playerid][GEO_COUNTRY], len);
}

stock GetPlayerCountryCode(playerid, countryCode[], len) {
	strcpy(countryCode, geo[playerid][GEO_COUNTRY_CODE], len);
} */

stock RequestPlayerGeo(playerid) {
	new ipstring[16];
	new query[45 + sizeof(ipstring) + 1]; // length of the URL + length of the IP + null terminator

	GetPlayerIp(playerid, ipstring, sizeof(ipstring));
	
	format(query, sizeof(query), "/json/%s?fields=country,countryCode&lang=pt-BR", ipstring);

	geo[playerid][GEO_REQUEST_ID] = RequestJSON(geo_client, query, HTTP_METHOD_GET, "OnGeoResponse");

	log("[GEO][%d] Requisitando dados geograficos de '%p' (%d)", _:geo[playerid][GEO_REQUEST_ID], playerid, playerid);
}

forward OnGeoResponse(Request:id, E_HTTP_STATUS:status, Node:node);
public OnGeoResponse(Request:id, E_HTTP_STATUS:status, Node:node) {
    // Primeiro verificamos a quem pertence a requisicao.
	new playerid = INVALID_PLAYER_ID;

	foreach(new i : Player) {
		if (geo[i][GEO_REQUEST_ID] == id) {
			playerid = i;
			break;
		}
	}

	// Se nao encontramos o jogador, entao nao podemos fazer nada.
	if (playerid == INVALID_PLAYER_ID) return;

	// Remove o ID da requisicao.
	geo[playerid][GEO_REQUEST_ID] = Request:INVALID_REQUEST_ID;

	// If the request failed, then we can't do anything.
	if (status != HTTP_STATUS_OK) {
		printf("[GEO] Requisicao falhou para '%p' (%d)", playerid, playerid);
		SetPlayerLanguage(playerid, PORTUGUESE);
	} else {
		// Se chegamos aqui, a requisicao foi bem sucedida. Vamos pegar os dados.
		JsonGetString(node, "country", geo[playerid][GEO_COUNTRY]);
		JsonGetString(node, "countryCode", geo[playerid][GEO_COUNTRY_CODE]);

		if(!isempty(geo[playerid][GEO_COUNTRY_CODE]) && !isequal(geo[playerid][GEO_COUNTRY_CODE], "BR"))
			ChatMsgAdmins(1, ORANGE, " > %P"C_ORANGE" (%d) conectou-se de %s (%s)", playerid, playerid, geo[playerid][GEO_COUNTRY], geo[playerid][GEO_COUNTRY_CODE]);

		log("[GEO][%d] %p (%d) é de %s (%s)", _:id, playerid, playerid, geo[playerid][GEO_COUNTRY], geo[playerid][GEO_COUNTRY_CODE]);

		// Define o idioma do jogador de acordo com o pais
		new ip[16];
		GetPlayerIp(playerid, ip, sizeof(ip));
		new lang = isequal(ip, "127.0.0.1") ? PORTUGUESE : isequal(geo[playerid][GEO_COUNTRY_CODE], "BR") || isequal(geo[playerid][GEO_COUNTRY_CODE], "PT") ? PORTUGUESE : ENGLISH;

		SetPlayerLanguage(playerid, lang);
	}
	
	// Mostra uma mensagem de boas-vindas
	// Convem providenciar algum contexto sobre que tipo de gamemode é, antes que eles registem simplesmente para ver como é
	if(GetPlayerLanguage(playerid) == PORTUGUESE)
		Dialog_Show(playerid, WelcomeMessage, DIALOG_STYLE_MSGBOX, "Bem-vindo ao \"Scavenge and Survive\"",
		C_WHITE"Este é um servidor de sobrevivência onde você deve sobreviver e explorar o mundo.\n\
		Você é colocado num ambiente de PvP, onde tem que se defender de outros jogadores e procurar formas de abrigo, bem como manter sua saúde.\n\n\
		Deseja proseguir? Se sim terá que registrar sua conta e completar o Tutorial.",
		"Continuar", "Sair");
	else
		Dialog_Show(playerid, WelcomeMessage, DIALOG_STYLE_MSGBOX, "Welcome to \"Scavenge and Survive\"",
		C_WHITE"This is a survival server where you must survive and explore the world.\n\
		You will be pinned in a Player versus Player environment.\n\n\
		Would you like to proceed? If you do, you will be prompted to register for an account.",
		"Continue", "Exit");
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

hook OnPlayerDisconnect(playerid, reason) {
	// Reset the data.
	geo[playerid][GEO_REQUEST_ID] = Request:INVALID_REQUEST_ID;
	geo[playerid][GEO_COUNTRY][0] = '\0';
	geo[playerid][GEO_COUNTRY_CODE][0] = '\0';
}