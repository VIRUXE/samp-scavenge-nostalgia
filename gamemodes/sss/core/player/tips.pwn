#define MAX_TIP_SIZE 112

ptask SendTips[MIN(15)](playerid) {
    SendTip(playerid);
}

stock SendTip(playerid) {
    new Node:node, total_tips;

    JSON_GetObject(Settings, "player", node);
    JSON_GetArray(node, "tips", node);
    JSON_ArrayLength(node, total_tips);

    if(total_tips > 0) {
        new tip[MAX_TIP_SIZE];
        new lang = GetPlayerLanguage(playerid);

        JSON_ArrayObject(node, random(total_tips), node);
        JSON_ArrayObject(node, lang == PORTUGUESE ? 0 : 1, node);
        JSON_GetNodeString(node, tip);

        ChatMsg(playerid, LBLUE, " > %s: "C_WHITE"%s", lang == PORTUGUESE ? "Dica" : "Tip", tip);
    }
}

CMD:tip(playerid) {
    SendTip(playerid);

    return 1;
}

CMD:tips(playerid) cmd_tip(playerid);
CMD:dica(playerid) cmd_tip(playerid);