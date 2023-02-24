#define MAX_VOTEKICK_REASON 144 // Tamanho máximo do motivo da votação.
#define MAX_VOTING_TIME 60 // Tempo máximo da votação, em segundos.

enum {
    VOTE_NULL = -1,
    VOTE_NO   = 0,
    VOTE_YES  = 1
};

static
    votekick_start  = 0,
    votekick_player = INVALID_PLAYER_ID,
    votekick_reason[MAX_VOTEKICK_REASON],
    votekick_votes[MAX_PLAYERS];

timer VoteKickTimer[SEC(10)]() {
    if(votekick_player == INVALID_PLAYER_ID) return; // Se não houver votação em andamento, o timer é cancelado.

    if (GetTickCount() - votekick_start >= SEC(MAX_VOTING_TIME)) { // Se o tempo máximo da votação for atingido, a votação é cancelada.
        ChatMsgAll(WHITE, "O tempo máximo da votação foi atingido. O jogador %P não foi expulso.", votekick_player);
        
        ResetVoting();
    } else {
        ChatMsgAll(WHITE, "A votação para expulsar o jogador %P está em andamento. Motivo: %s", votekick_player, votekick_reason);
        ChatMsgAll(WHITE, "Use /vote [sim/não] para votar.");
    }

    return;
}

ResetVoting() {
    votekick_start  = 0;
    votekick_player = INVALID_PLAYER_ID;
    votekick_reason = "";
    
    for(new i = 0; i < MAX_PLAYERS; i++) votekick_votes[i] = VOTE_NULL;
}

CountVotes(vote_type) {
    if(vote_type != VOTE_YES && vote_type != VOTE_NO) return -1;

    new count = 0;

    for(new i = 0; i < MAX_PLAYERS; i++) if(votekick_votes[i] == vote_type) count++;

    return count;
}

CMD:votekick(playerid, params[]) {
    if(votekick_player != INVALID_PLAYER_ID) return ChatMsg(playerid, RED, "Já existe uma votação em andamento.");

    new targetId = INVALID_PLAYER_ID, reason[MAX_VOTEKICK_REASON];

    if(!sscanf(params, "us", targetId, reason)) return ChatMsg(playerid, RED, "Use: /votekick [Nick/Id] [Motivo]");

    if(targetId == playerid) return ChatMsg(playerid, RED, "Você não pode votar contra si mesmo.");

    if(!IsPlayerConnected(targetId)) return ChatMsg(playerid, RED, "Jogador não encontrado.");

    if(GetPlayerAdminLevel(targetId)) return ChatMsg(playerid, RED, "Você não pode votar contra um administrador.");   

    votekick_start           = GetTickCount();
    votekick_player          = targetId;
    votekick_reason          = reason;
    votekick_votes[playerid] = VOTE_YES; // O jogador que iniciou a votação já vota sim.

    defer VoteKickTimer();

    ChatMsgAll(WHITE, "O jogador %P iniciou uma votação para expulsar o jogador %P. Motivo: %s", playerid, targetId, reason);
    ChatMsgAll(WHITE, "Use /vote [sim/não] para votar.");

    return 1;
}

CMD:vote(playerid, params[]) {
    if(votekick_player == INVALID_PLAYER_ID) return ChatMsg(playerid, RED, "Não existe nenhuma votação em andamento.");

    if(votekick_votes[playerid] != -1) return ChatMsg(playerid, RED, "Você já votou.");

    if(isequal(params, "sim", true)) {
        votekick_votes[playerid] = VOTE_YES;

        ChatMsgAll(WHITE, "O jogador %P votou SIM.", playerid);

        log("[VOTEKICK] %p (%d) votou SIM (%d/%d), para expulsar %p (%d). Motivo: %s", playerid, playerid, CountVotes(VOTE_YES), CountVotes(VOTE_NO), votekick_player, votekick_player, votekick_reason);
    } else if(isequal(params, "não", true)) {
        votekick_votes[playerid] = VOTE_NO;

        ChatMsgAll(WHITE, "O jogador %P votou NÃO.", playerid);

        log("[VOTEKICK] %p (%d) votou NÃO (%d/%d), para expulsar %p (%d). Motivo: %s", playerid, playerid, CountVotes(VOTE_NO), CountVotes(VOTE_YES), votekick_player, votekick_player, votekick_reason);
    } else {
        return ChatMsg(playerid, RED, "Use: /vote [sim/não]");
    }

    new players = Iter_Count(Player);

    if(CountVotes(VOTE_YES) >= players / 2) { // Se a metade dos jogadores votarem sim, o jogador é expulso.
        ChatMsgAll(WHITE, "A votação foi aprovada. O jogador %P foi expulso.", votekick_player);

        KickPlayer(votekick_player, votekick_reason, true);

        log("[VOTEKICK] %p (%d) foi expulso por %p (%d). Motivo: %s", votekick_player, playerid, votekick_reason);
        
        ResetVoting();
    } else if(CountVotes(VOTE_NO) >= players / 2) { // Se a metade dos jogadores votarem não, a votação é cancelada.
        ChatMsgAll(WHITE, "A votação foi reprovada. O jogador %P não foi expulso.", votekick_player);

        log("[VOTEKICK] %p (%d) não foi expulso por %p (%d). Motivo: %s", votekick_player, playerid, votekick_reason);
        
        ResetVoting();
    }

    return 1;
}