#include <YSI\y_hooks>
#include <YSI\y_timers>

#define MAX_VOTEKICK_REASON 144 // Tamanho m�ximo do motivo da vota��o.
#define MAX_VOTING_TIME 60 // Tempo m�ximo da vota��o, em segundos.

enum {
    VOTE_NULL = -1,
    VOTE_NO   = 0,
    VOTE_YES  = 1
}

static
    votekick_start  = 0,
    votekick_player = INVALID_PLAYER_ID,
    votekick_reason[MAX_VOTEKICK_REASON],
    votekick_votes[MAX_PLAYERS] = {VOTE_NULL, ...},
    Timer:votekick_timer;

timer VoteKickTimer[SEC(10)]() {
    if(!IsPlayerConnected(votekick_player)) EndVoting(); // Se o jogador que est� sendo votado desconectar, a vota��o � cancelada.

    if (GetTickCount() - votekick_start >= SEC(MAX_VOTING_TIME)) { // Se o tempo m�ximo da vota��o for atingido, a vota��o � cancelada.
        ChatMsgAll(WHITE, "O tempo m�ximo da vota��o foi atingido. O jogador %P n�o foi expulso.", votekick_player);
        
        EndVoting();
    } else {
        ChatMsgAll(WHITE, "A vota��o para expulsar o jogador %P est� em andamento. Motivo: %s", votekick_player, votekick_reason);
        ChatMsgAll(WHITE, "Use /vote [sim/n�o] para votar.");
    }
}

hook OnPlayerDisconnect(playerid, reason) {
    if(votekick_player == playerid) EndVoting(); // Se o jogador que est� sendo votado desconectar, a vota��o � cancelada.
}

static EndVoting() {
    stop votekick_timer;

    log("[VOTEKICK] Vota��o cancelada para expulsar %p (%d). Motivo: %s", votekick_player, votekick_player, votekick_reason);

    votekick_start  = 0;
    votekick_player = INVALID_PLAYER_ID;
    votekick_reason = "";
    
    for(new i = 0; i < MAX_PLAYERS; i++) votekick_votes[i] = VOTE_NULL;
}

static CountVotes(vote_type) {
    if(vote_type != VOTE_YES && vote_type != VOTE_NO) return -1;

    new count = 0;

    for(new i = 0; i < MAX_PLAYERS; i++) if(votekick_votes[i] == vote_type) count++;

    return count;
}

CMD:votekick(playerid, params[]) {
    if(votekick_player != INVALID_PLAYER_ID) return SendClientMessage(playerid, RED, "J� existe uma vota��o em andamento.");

    new targetId, reason[MAX_VOTEKICK_REASON];

    if(sscanf(params, "rs[114]", targetId, reason)) return SendClientMessage(playerid, RED, "Use: /votekick [id/nick] [motivo]");

    if(targetId == INVALID_PLAYER_ID) return SendClientMessage(playerid, RED, "Jogador n�o encontrado.");

    if(targetId == playerid) return SendClientMessage(playerid, RED, "Voc� n�o pode votar contra si mesmo.");

    if(GetPlayerAdminLevel(targetId)) return SendClientMessage(playerid, RED, "Voc� n�o pode votar contra um administrador.");   

    votekick_start           = GetTickCount();
    votekick_player          = targetId;
    votekick_reason          = reason;
    votekick_votes[playerid] = VOTE_YES; // O jogador que iniciou a vota��o j� vota sim.

    votekick_timer = defer VoteKickTimer();

    ChatMsgAll(YELLOW, "Vote Kick: O jogador %P"C_YELLOW" iniciou uma vota��o para expulsar o jogador %P"C_YELLOW". Motivo: "C_WHITE"%s", playerid, targetId, reason);
    ChatMsgAll(WHITE, "Vote Kick: Use /vote [sim/n�o] para votar.");

    log("[VOTEKICK] %p (%d) iniciou uma vota��o para expulsar %p (%d). Motivo: %s", playerid, playerid, targetId, targetId, reason);

    return 1;
}

CMD:vote(playerid, params[]) {
    if(votekick_player == INVALID_PLAYER_ID) return SendClientMessage(playerid, RED, "N�o existe nenhuma vota��o em andamento.");

    if(votekick_player == playerid) return SendClientMessage(playerid, RED, "Voc� n�o pode votar contra si mesmo.");

    if(votekick_votes[playerid] != VOTE_NULL) return SendClientMessage(playerid, RED, "Voc� j� votou.");

    if(isequal(params, "sim", true)) {
        votekick_votes[playerid] = VOTE_YES;

        ChatMsgAll(GREEN, "Vote Kick: O jogador %P"C_GREEN" votou SIM.", playerid);

        log("[VOTEKICK] Vote Kick: %p (%d) votou SIM (%d/%d), para expulsar %p (%d). Motivo: %s", playerid, playerid, CountVotes(VOTE_YES), CountVotes(VOTE_NO), votekick_player, votekick_player, votekick_reason);
    } else if(isequal(params, "n�o", true)) {
        votekick_votes[playerid] = VOTE_NO;

        ChatMsgAll(RED, "Vote Kick: O jogador %P"C_RED" votou N�O.", playerid);

        log("[VOTEKICK] %p (%d) votou N�O (%d/%d), para expulsar %p (%d). Motivo: %s", playerid, playerid, CountVotes(VOTE_NO), CountVotes(VOTE_YES), votekick_player, votekick_player, votekick_reason);
    } else
        return SendClientMessage(playerid, RED, "Use: /vote [sim/n�o]");

    new players = Iter_Count(Player);

    if(CountVotes(VOTE_YES) >= players / 2) { // Se a metade dos jogadores votarem sim, o jogador � expulso.
        ChatMsgAll(GREEN, "Vote Kick: A vota��o foi aprovada. O jogador %P"C_GREEN" foi expulso.", votekick_player);

        TimeoutPlayer(votekick_player, sprintf("Vote Kick: %s", votekick_reason));
        // KickPlayer(votekick_player, votekick_reason, true);

        log("[VOTEKICK] %p (%d) foi expulso por %p (%d). Motivo: %s", votekick_player, playerid, votekick_reason);
        
        EndVoting();
    } else if(CountVotes(VOTE_NO) >= players / 2) { // Se a metade dos jogadores votarem n�o, a vota��o � cancelada.
        ChatMsgAll(RED, "A vota��o foi reprovada. O jogador %P"C_RED" n�o foi expulso.", votekick_player);

        log("[VOTEKICK] %p (%d) n�o foi expulso por %p (%d). Motivo: %s", votekick_player, playerid, votekick_reason);
        
        EndVoting();
    }

    return 1;
}