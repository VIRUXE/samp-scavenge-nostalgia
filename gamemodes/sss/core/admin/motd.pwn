#include <YSI\y_hooks>

forward OnPlayerAcceptMotd(playerid);

#define MAX_MOTD_LEN 512

static 
    randomButton[MAX_PLAYERS],
    responseTick[MAX_PLAYERS],
    newMotd[MAX_MOTD_LEN];

GetMotd(playerid) {
    new Node:node, tmp[MAX_MOTD_LEN];

    JSON_GetObject(Settings, "server", node);
    JSON_GetArray(node, "motd", node);
	JSON_ArrayObject(node, GetPlayerLanguage(playerid), node);
	JSON_GetNodeString(node, tmp);

    return tmp;
}

ShowMotd(playerid) {
    randomButton[playerid] = random(2);

    new motd[MAX_MOTD_LEN];

    motd = GetMotd(playerid);

    if(responseTick[playerid] > 0 && GetTickCountDifference(GetTickCount(), responseTick[playerid]) < SEC(5))
        strcat(motd, GetPlayerLanguage(playerid) ? C_RED"\n\nYou need to read the entire message before accepting!" : C_RED"\n\nTem que ler a mensagem inteira antes de aceitar!");

    Dialog_Show(playerid, ShowMotd, DIALOG_STYLE_MSGBOX, 
        ls(playerid, "server/motd"), 
        motd, 
        ls(playerid, randomButton[playerid] ? "common/accept" : "common/cancel"), 
        ls(playerid, randomButton[playerid] ? "common/cancel" : "common/accept")
    );

    responseTick[playerid] = GetTickCount();

    return 1;
}

SetPortugueseMotd(playerid) {
    Dialog_Show(playerid, SetPortugueseMotd, DIALOG_STYLE_INPUT, 
        "Mensagem do Dia, em Português:", 
        sprintf("Escreva a mensagem do dia, em Português, no máximo até %d caractéres:", MAX_MOTD_LEN), 
        "Confirmar", "Cancelar"
    );

    return 1;
}

SetEnglishMotd(playerid) {
    Dialog_Show(playerid, SetEnglishMotd, DIALOG_STYLE_INPUT, 
        "Mensagem do Dia, em Inglês:", 
        sprintf("Essa é a mensagem em Português:\n\t%s\n\nAgora escreva a mensagem do dia em Inglês, no máximo até %d caractéres:", newMotd, MAX_MOTD_LEN),
        "Confirmar", "Cancelar"
    );
}

public OnPlayerAcceptMotd(playerid) {
}

Dialog:ShowMotd(playerid, response, listitem, inputtext[]) {
    if(response) {
        if(!randomButton[playerid]) ShowMotd(playerid); else {
            if(!GetPlayerAdminLevel(playerid) && GetTickCountDifference(GetTickCount(), responseTick[playerid]) < SEC(3))
                ShowMotd(playerid);
            else 
                CallLocalFunction("OnPlayerAcceptMotd", "d", playerid);
        }
    } else {
        if(randomButton[playerid]) ShowMotd(playerid); else {
            if(!GetPlayerAdminLevel(playerid) && GetTickCountDifference(GetTickCount(), responseTick[playerid]) < SEC(3))
                ShowMotd(playerid);
            else 
                CallLocalFunction("OnPlayerAcceptMotd", "d", playerid);
        }
    }
}

Dialog:SetPortugueseMotd(playerid, response, listitem, inputtext[]) {
    if(response) {
        if(strlen(inputtext) > MAX_MOTD_LEN) {
            ChatMsg(playerid, RED, "MOTD demasiado comprido");
            SetPortugueseMotd(playerid);
        } else {
            strcpy(newMotd, inputtext);

            SetEnglishMotd(playerid);
        }
    }
}

Dialog:SetEnglishMotd(playerid, response, listitem, inputtext[]) {
    if(response) {
        if(strlen(inputtext) > MAX_MOTD_LEN) {
            ChatMsg(playerid, RED, "MOTD demasiado comprido");
            SetEnglishMotd(playerid);
        } else {
            // Salvar no "settings.json"
            new Node:server;
            JSON_GetObject(Settings, "server", server);
            JSON_SetArray(server, "motd", JSON_Array(JSON_String(newMotd), JSON_String(inputtext)));
            JSON_SetObject(Settings, "server", server);

            JSON_SaveFile("settings.json", Settings, true);

            ChatMsgAdmins(1, GREEN, " > %P "C_GREEN"definiu a mensagem do dia.", playerid);
        }
    }
}

// Para mostrar a mensagem do dia para algum jogador
ACMD:motd[1](playerid, params[]) {
    new targetId = INVALID_PLAYER_ID;

    sscanf(params, "r", targetId);

    if(targetId == INVALID_PLAYER_ID) return CMD_INVALID_PLAYER;
    
    return ShowMotd(targetId);
}

ACMD:setmotd[2](playerid, params[]) return SetPortugueseMotd(playerid);

hook OnGamemodeInit() {
    RegisterAdminCommand(STAFF_LEVEL_MODERATOR, "setmotd", "Mudar as notícias do servidor");
}

hook OnPlayerDisconnect(playerid) {
    responseTick[playerid] = 0;
}