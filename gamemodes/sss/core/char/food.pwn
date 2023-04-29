#include <YSI\y_hooks>

#define IDLE_FOOD_RATE (0.015)

hook OnPlayerScriptUpdate(playerid)
{
    // Verifica se o jogador está em modo administrador, se não estiver "spawnado" ou se estiver em um tutorial
    if (IsPlayerOnAdminDuty(playerid) || !IsPlayerSpawned(playerid) || IsPlayerInTutorial(playerid)) return;

    // Obtem a intensidade da infecção, o índice da animação, as teclas pressionadas e o nível de comida do jogador
    new infectionIntensity = GetPlayerInfectionIntensity(playerid, 0),
        animidx = GetPlayerAnimationIndex(playerid),
        k, ud, lr,
        Float: food = GetPlayerFP(playerid);

    GetPlayerKeys(playerid, k, ud, lr);

    // Verifica e ajusta o valor da variável 'food' para garantir que esteja entre 0.0 e 100.0
    food = (food < 0.0) ? 0.0 : ((food > 100.0) ? 100.0 : food);

    // Se a comida for menor que 20.0, reduz a vida do jogador
    if (food < 20.0) SetPlayerHP(playerid, GetPlayerHP(playerid) - (20.0 - food) / 30.0);

    // Mostra um texto de ação para o jogador quando a comida estiver em um nível crítico
    if (food >= 19.8 && food <= 20.0 || food >= 9.8 && food <= 10.0)
        ShowActionText(playerid, sprintf(ls(playerid, "player/health/dieing/food"), food), 5000);

    // Reduz a comida do jogador se estiver infectado
    if (infectionIntensity) food -= IDLE_FOOD_RATE;

    // Ajusta a taxa de consumo de comida com base nas animações e ações do jogador
    switch (animidx) {
        case 43: // Sentado
            food -= IDLE_FOOD_RATE * 0.2;
        case 1159: // Agachado
            food -= IDLE_FOOD_RATE * 1.1;
        case 1195: // Pulando
            food -= IDLE_FOOD_RATE * 3.2;
        case 1231: // Correndo
            if   (k & KEY_WALK) food      -= IDLE_FOOD_RATE * 1.2;  // Andando
            else if (k & KEY_SPRINT) food -= IDLE_FOOD_RATE * 2.2;  // Correndo
            else if (k & KEY_JUMP) food   -= IDLE_FOOD_RATE * 3.2;  // Pulando
            else food                     -= IDLE_FOOD_RATE * 2.0;  // Parado
    }

    // Define o nível de embriaguez do jogador com base no nível de comida e intensidade da infecção,
    // caso não esteja sob efeito de drogas específicas.
    if (!IsPlayerUnderDrugEffect(playerid, drug_Morphine) || !IsPlayerUnderDrugEffect(playerid, drug_Air) || !IsPlayerUnderDrugEffect(playerid, drug_Adrenaline)) {
        if (food < 30.0) // Se a comida for menor que 30.0, ajusta o nível de embriaguez do jogador
			SetPlayerDrunkLevel(playerid, infectionIntensity == 0 ? 0 : 2000 + floatround((31.0 - food) * 300.0));
		else if (infectionIntensity == 0) SetPlayerDrunkLevel(playerid, 0); // Se não estiver infectado, define o nível de embriaguez como 0
	}

	SetPlayerFP(playerid, food);
}