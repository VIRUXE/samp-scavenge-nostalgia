static GetAvailableCommands() {
    new output[256] = "Nenhums";

    new Node:info, Node: node, length;

    JSON_GetObject(Settings, "player", node);
    JSON_GetArray(node, "info", info);

    JSON_ArrayLength(info, length);

    if(length) output[0] = EOS;

    for(new i; i < length; ++i) {
        new cmd[4];

        JSON_ArrayObject(info, i, node);
        JSON_GetString(node, "command", cmd);

        strcat(output, sprintf("%s, ", cmd));
    }

    return output;
}

ACMD:info[1](playerid, params[]) {
    new command[4], targetId;

    if(sscanf(params, "s[4]R(0xFFFF)", command, targetId)) {
        ChatMsg(playerid, YELLOW, "Sintaxe: /i(nfo) [comando] (id/nick)");
        return ChatMsg(playerid, YELLOW, "Comandos Disponiveis: "C_WHITE"%s", GetAvailableCommands());
    }

    // printf("info(%d, %s) command: %s, player: %d", playerid, params, command, targetId);

    // Verifica se o comando existe
    new Node:info, Node: node, length;

    JSON_GetObject(Settings, "player", node);
    JSON_GetArray(node, "info", info);

    JSON_ArrayLength(info, length);

    for(new i; i < length; ++i) {
        new cmd[4];

        JSON_ArrayObject(info, i, node);
        JSON_GetString(node, "command", cmd);

        // printf("\tArray Index: %d, Node Command: %s", i, cmd);

        if(isequal(cmd, command, true)) { // Comando existe
            new content[128] = "MISSING";

            JSON_GetArray(node, "content", node);
            
            foreach(new p : Player) {
                // Obtemos o conteudo de acordo com o idioma do jogador
                JSON_ArrayObject(node, GetPlayerLanguage(p), node);
                JSON_GetNodeString(node, content);

                if(targetId != INVALID_PLAYER_ID && targetId != playerid)
                    ChatMsg(p, LBLUE, " ! Info ('%s'): %P "C_WHITE"%s", cmd, targetId, content);
                else
                    ChatMsg(p, LBLUE, " ! Info ('%s'): "C_WHITE"%s", cmd, content);
            }

            return 1;
        }
    }

    return ChatMsg(playerid, GREY, "Comando de Informação '%s' não existe.", command);
}
ACMD:i[1](playerid, params[]) return acmd_info_1(playerid, params);
