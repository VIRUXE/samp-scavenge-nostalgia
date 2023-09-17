#include <YSI\y_hooks>

/* hook OnGamemodeInit() {
    
} */

hook OnGameModeExit() {
    db_close(Sessions);
}

stock CheckPlayerSession(playerid) {
    new 
        isAdmin = IsPlayerAdmin(playerid),
        serial[MAX_GPCI_LEN],
        open,
        query[256];

    if(!isAdmin) {
        gpci(playerid, serial, MAX_GPCI_LEN);

        format(query, sizeof(query), "SELECT COUNT(*) FROM sessions WHERE player_name = '%s' AND gpci = '%s' AND logged_out IS NULL AND strftime('%%s', 'now') - strftime('%%s', last_active) <= 60", GetPlayerNameEx(playerid), serial);
        new DBResult:result = db_query(Sessions, query);
        
        if(result != DB_INVALID_RESULT) {
            open = db_get_field_int(result);
            db_free_result(result);
        } else
            printf("Database error: %s", query);
    }

    if(open || isAdmin) {
        // SetPlayerScreenFade(playerid, FADE_OUT, 255, 10, 1);
        Login(playerid);
    } else {
        Dialog_Show(playerid, Session, DIALOG_STYLE_MSGBOX, "Launcher", 
        C_RED"Você não tem sessão aberta no Launcher!\n\n"\
        C_WHITE"O que tem que fazer:\n\n\
        \t"C_GOLD"1º"C_WHITE" Abrir o nosso Launcher (baixe em http://scavengenostalgia.fun)\n\n\t"C_GOLD"2º"C_WHITE" Efetuar Login com a sua conta de Jogo\n\n\t"C_GOLD"3º"C_WHITE" Escolhar a opção 'Jogar'\n\n\t"C_GOLD"4º"C_WHITE" Assim que esteja autorizado, apertar o botão 'Entrar'\n\n"\
        C_LGREEN"Nota: O seu jogo tem que estar 100% limpo para conseguir logar. Se tiver dúvidas fale no #bate-papo no Discord.", 
        "Entrar", "Sair");
    }
}

Dialog:Session(playerid, response, listitem, inputtext[]) {
    if(response) CheckPlayerSession(playerid); else Kick(playerid);
}