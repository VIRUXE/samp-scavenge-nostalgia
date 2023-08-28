#include <YSI\y_hooks>

static 
    DBStatement:stmt_InsertMessage,
    bool:Blocked[MAX_PLAYERS],
    CurrentConversation[MAX_PLAYERS] = {-1, ...}; // Stores the recipient's ID or -1 if not viewing any convo

hook OnGameModeInit() {
    db_query(Database, "CREATE TABLE IF NOT EXISTS private_messages (sender TEXT, recipient TEXT, message TEXT, date INTEGER DEFAULT (strftime('%s', 'now')));");

    stmt_InsertMessage = db_prepare(Database, "INSERT INTO conversation_messages (conversation_id, sender, message) VALUES (?, ?, ?);");

    // stmt_GetConversationId = db_prepare(Database, "SELECT id FROM conversations WHERE (player1 = ? AND player2 = ?) OR (player1 = ? AND player2 = ?)");
}

hook OnPlayerDisconnect(playerid) {
    Blocked[playerid] = false;
    CurrentConversation[playerid] = -1;
}

hook OnPlayerLogin(playerid) {
    new playerName[MAX_PLAYER_NAME], query[1024];

    GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);

    format(query, sizeof(query), "SELECT COUNT(*) FROM conversation_messages \
        JOIN conversations ON conversation_messages.conversation_id = conversations.id \
        WHERE (conversations.player1 = '%s' OR conversations.player2 = '%s') \
        AND ((conversations.player1 = '%s' AND conversation_messages.date > conversations.last_seen_player1) OR \
            (conversations.player2 = '%s' AND conversation_messages.date > conversations.last_seen_player2));",
        playerName, playerName, playerName, playerName
    );

    new DBResult:result = db_query(Database, query);

    if(result == DB::INVALID_RESULT) {
        log("[PM] Error on OnPlayerLogin(%p): %s", playerid, query);
        return Y_HOOKS_CONTINUE_RETURN_0;
    }

    new const newMessagesCount = db_num_rows(result);

    if(newMessagesCount) {
        db_free_result(result);
        ChatMsg(playerid, YELLOW, " > Você tem %d mensagens por lêr!", newMessagesCount);
    }

    return Y_HOOKS_CONTINUE_RETURN_1;
}

stock SendPrivateMessage(conversationId, playerId, message[]) {
    new playerName[MAX_PLAYER_NAME], otherPlayerName[MAX_PLAYER_NAME];

    GetPlayerName(playerId, playerName, MAX_PLAYER_NAME);
    
    stmt_bind_value(stmt_InsertMessage, 0, DB::TYPE_INTEGER, conversationId);
    stmt_bind_value(stmt_InsertMessage, 1, DB::TYPE_STRING, playerName);
    stmt_bind_value(stmt_InsertMessage, 2, DB::TYPE_STRING, message);

    stmt_execute(stmt_InsertMessage);

    GetOtherConversationParticipant(conversationId, playerName, otherPlayerName);

    new const otherPlayerId = GetPlayerIDFromName(otherPlayerName);

    if(otherPlayerId != INVALID_PLAYER_ID) { // The other participant is online
        if(Blocked[otherPlayerId]) return 1;

        if(CurrentConversation[otherPlayerId] == conversationId) ShowConversation(otherPlayerId, conversationId); // This will mainly "refresh" the dialog

        GameTextForPlayer(otherPlayerId, sprintf("~G~~H~ Mensagem de %s!", playerName), 3000, 1);
        
        PlayerPlaySound(otherPlayerId,5205,0.0,0.0,0.0);
    }

    PlayerPlaySound(playerId,5205,0.0,0.0,0.0);

    return 1;
}

stock GetConversationId(sender[MAX_PLAYER_NAME], recipient[MAX_PLAYER_NAME]) {
    new id = -1, query[256];

    format(query, sizeof(query), "SELECT id FROM conversations WHERE (player1 = '%s' AND player2 = '%s') OR (player1 = '%s' AND player2 = '%s');", sender, recipient, recipient, sender);

    new DBResult:result = db_query(Database, query);

    if (result == DB::INVALID_RESULT) {
        log("Error getting a conversation id for '%s' and '%s': %s", sender, recipient, query);
        return id;
    }
    
    if(db_num_rows(result)) {
        id = db_get_field_int(result, 0);
        db_free_result(result);
    } else {
        new newConversationId = db_insert(Database, sprintf("INSERT OR IGNORE INTO conversations (player1, player2) VALUES ('%s', '%s')", sender, recipient));

        if(newConversationId) id = newConversationId;
    }

    return id;
}

stock GetOtherConversationParticipant(conversationId, playerName[MAX_PLAYER_NAME], otherParticipant[MAX_PLAYER_NAME]) {
    if(conversationId == -1) return 0;

    new query[256];
    format(query, sizeof(query), "SELECT CASE WHEN player1 = '%s' THEN player2 ELSE player1 END FROM conversations WHERE id = %d;", playerName, conversationId);

    new DBResult:result = db_query(Database, query);

    if(result == DB::INVALID_RESULT || !db_num_rows(result)) return 0;

    db_get_field(result, 0, otherParticipant);
    db_free_result(result);

    return 1;
}

stock GetConversationLastSeen(conversationId, playerName[MAX_PLAYER_NAME]) {
    if(conversationId == -1) return 0;

    new query[256];

    format(query, sizeof(query), 
        "SELECT CASE \
            WHEN player1 = '%s' THEN last_seen_player2 \
            ELSE last_seen_player1 \
        END as other_last_seen \
        FROM conversations \
        WHERE id = %d;", 
    playerName, conversationId);

    new DBResult:result = db_query(Database, query);

    if(result == DB::INVALID_RESULT) {
        log("[PM] Error on GetConversationLastSeen(%d, %s): %s", conversationId, playerName, query);
        return 0;
    }

    if(!db_num_rows(result)) return 0;

    return db_get_field_int(result);
}

stock SetConversationLastSeen(conversationId, playerName[MAX_PLAYER_NAME]) {
    new query[512];

    format(query, sizeof(query), "UPDATE conversations \
                SET last_seen_player1 = CASE WHEN player1 = '%s' THEN strftime('%%s', 'now') ELSE last_seen_player1 END, \
                    last_seen_player2 = CASE WHEN player2 = '%s' THEN strftime('%%s', 'now') ELSE last_seen_player2 END \
                WHERE id = %d", playerName, playerName, conversationId);

    db_query(Database, query);
}

stock ShowConversation(playerId, conversationId) {
    if(conversationId == -1) return 0;

    new playerName[MAX_PLAYER_NAME], otherParticipant[MAX_PLAYER_NAME];

    GetPlayerName(playerId, playerName, sizeof(playerName));
    GetOtherConversationParticipant(conversationId, playerName, otherParticipant);

    new dialogText[2048];
    new query[512];
    
    CurrentConversation[playerId] = conversationId;

    format(query, sizeof(query), "SELECT sender, message, strftime('%%Y-%%m-%%d %%H:%%M:%%S', date, 'unixepoch') FROM conversation_messages WHERE conversation_id = %d ORDER BY date ASC LIMIT 20;", conversationId);

    new DBResult:result = db_query(Database, query);

    if (result == DB::INVALID_RESULT) {
        log("Error showing conversation %d for %p: %s", conversationId, playerId, query);
        return -1;
    }

    if(db_num_rows(result)) {
        dialogText = sprintf("'%s' viu pela última vez ás: %d\n", otherParticipant, GetConversationLastSeen(conversationId, otherParticipant));

        do {
            new sender[MAX_PLAYER_NAME + 1], message[128], date[64];

            db_get_field(result, 0, sender);
            db_get_field(result, 1, message);
            db_get_field(result, 2, date);

            format(dialogText, sizeof(dialogText), "%s\n{FFFFFF}%s%s%s{FFFFFF}: %s", dialogText, date, isequal(sender, playerName) ? C_BLUE : C_GREY, sender, message);
        } while(db_next_row(result));

        db_free_result(result);

        SetConversationLastSeen(conversationId, playerName);
    } else
        dialogText = "Conversa sem registros anteriores. Comece agora.";

    new otherPlayer[MAX_PLAYER_NAME];

    GetOtherConversationParticipant(conversationId, playerName, otherPlayer);

    Dialog_Show(playerId, ShowConversation, DIALOG_STYLE_INPUT, sprintf("Conversa com '%s'%s:", otherPlayer, GetPlayerIDFromName(otherPlayer) != INVALID_PLAYER_ID ? "{FFFFFF} (Online)" : ""), dialogText, "Enviar", "Cancelar");

    return 1;
}

Dialog:ShowConversation(playerid, response, listitem, inputtext[]) {
	if(response) {
        if(!isempty(inputtext)) {
            SendPrivateMessage(CurrentConversation[playerid], playerid, inputtext);
            // SendClientMessage(playerid, YELLOW, " > Esse jogador não se encontra online. Ele poderá ver a mensagem quando entrar no servidor.");
        }

        // Always show the conversation again
        ShowConversation(playerid, CurrentConversation[playerid]);
	} else
        CurrentConversation[playerid] = -1;
}

stock ShowConversationList(playerId) {
    new playerName[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerId, playerName, sizeof(playerName));

    new dialogitems[4096] = "";
    new query[1024];

    format(query, sizeof(query), "SELECT rowid, \
            CASE \
                WHEN c.player1 = '%s' THEN c.player2 \
                ELSE c.player1 \
            END as other_party, \
            datetime(MAX(cm.date), 'unixepoch') as date \
        FROM conversations c \
        JOIN conversation_messages cm ON c.id = cm.conversation_id \
        WHERE c.player1 = '%s' OR c.player2 = '%s' \
        GROUP BY c.id \
        ORDER BY date DESC;",
        playerName, playerName, playerName);

    new DBResult:result = db_query(Database, query);

    if (result == DB::INVALID_RESULT) {
        log("Error getting conversation list for '%s': %s", playerName, query);
        return -1;
    }

    new const numRows = db_num_rows(result);

    if(!numRows)
        return 0;
    else {
        do {
            new participantName[MAX_PLAYER_NAME], date[64];
            
            db_get_field(result, 1, participantName);
            db_get_field(result, 2, date);
            
            strcat(dialogitems, sprintf("%s (%s)", participantName, date));
            if(db_get_field_int(result) != numRows) strcat(dialogitems, "\n");
        } while(db_next_row(result));
    }

    db_free_result(result);

    Dialog_Show(playerId, ShowConversation, DIALOG_STYLE_LIST, "Conversas Privadas", dialogitems, "Select", "Cancel");

    return 1;
}

Dialog:ShowConversationList(playerid, response, listitem, inputtext[]) {
	if(response) {
        // ShowConversation(playerid, listitem);
	}
}

CMD:pm(playerid, params[]) {
    // if(!IsPlayerLoggedIn(playerid)) return CMD_CANT_USE;
    if(Blocked[playerid]) return SendClientMessage(playerid, RED, " > Você não pode enviar uma mensagem pois usou /blockpm!");

	new targetId, message[300];

    if(sscanf(params, "rS()[300]", targetId, message)) return ShowPlayerDialog(playerid, DIALOG_MESSAGE, DIALOG_STYLE_MSGBOX, "Mensagens Privadas:", 
        "Existem várias formas de utilizar o '/pm'.\n\n\
        Se quiser manter uma conversa com um jogador pode executar apenas '/pm [jogador]' onde abrirá o dialog.\n\
        Se quiser enviar uma mensagem rápida (sem abrir dialog) pode executar '/pm [jogador] mensagem'\n\n\
        Se desejar bloquear execute '/blockpm'\n\n\
        Notas:\n\
        - Onde tem '[jogador]' significa que é obrigatório especificar o jogador.\n\
        \tIsso pode ser de très formas. Pelo id, pelo nome completo, ou nome parcial (sim, apenas algumas letras do nome).\n\
        \tNo entanto, se o jogador estiver Offline, você tem que escrever o nome dele exatamente como utilizado.\n\
        - Se estiver em conversa (dialog aberto) com um jogador e o mesmo enviar uma mensagem para você...\n\
        \t... Você recebe logo essa mensagem no seu dialog, pois ele atualiza direto.\n\n\
        - Se desejar ver todas as suas conversas execute '/pms'", 
        "Ok", ""
    );

    new playerName[MAX_PLAYER_NAME];

    GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);

    if(targetId == INVALID_PLAYER_ID) { // Provided player is offline so we check if the account exists and go from there
        new output[1][MAX_PLAYER_NAME];

        strexplode(output, params, " ");

        // log("[PM] strexplode: %s", output[0]);

        if(!IsValidUsername(output[0])) return SendClientMessage(playerid, YELLOW, " > Esse nome de jogador não é válido.");

        if(AccountExists(output[0])) { // Player account actually exists so we can open a conversation
            new conversationId = GetConversationId(playerName, output[0]);

            if(!isempty(message)) // Direct message
                SendPrivateMessage(conversationId, playerid, message); // If a message was typed already we send that
            else {
                CurrentConversation[playerid] = conversationId;
                ShowConversation(playerid, conversationId);
            }
        } else
            return CMD_INVALID_PLAYER;
    } else { // Player provided a valid player id
        if(targetId == playerid) return SendClientMessage(playerid, RED, " > Você não pode enviar uma mensagem para Você mesmo!");
        if(Blocked[targetId]) return ChatMsg(playerid, RED, " > Você não pode enviar uma mensagem para %P"C_RED" pois ele está com o PM Bloqueado!", targetId);

        new conversationId = GetConversationId(playerName, GetPlayerNameEx(targetId));

        if(!isempty(message)) { // Direct message
            ChatMsg(targetId, BROWN, "[PRIVADO] %P"C_WHITE": %s", playerid, message);
            SendPrivateMessage(conversationId, playerid, message); // If a message was typed already we send that
        } else {
            CurrentConversation[playerid] = conversationId;
            ShowConversation(playerid, conversationId);
        }
    }

    return 1;
}

CMD:pms(playerid) {
    if(!ShowConversationList(playerid)) return SendClientMessage(playerid, YELLOW, "Não existem conversas. Comece uma utilizando '/pm [id/nick] (mensagem)' (Coloque o nick se o jogador estiver Offline)");

    return 1;
}
	
CMD:blockpm(playerid) {
    Blocked[playerid] = !Blocked[playerid];
    
    return ChatMsg(playerid, RED, " > Mensagens privadas %sbloqueadas!", !Blocked[playerid] ? "des" : "");
}
