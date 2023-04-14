#define MAX_TIP_SIZE 112

ptask SendTips[MIN(5)](playerid) {
    SendTip(playerid);
}

stock SendTip(playerid) {
    if(IsPlayerToolTipsOn(playerid)) {
        new Node:node, total_tips;

        JSON_GetObject(Settings, "player", node);
        JSON_GetArray(node, "tips", node);
        JSON_ArrayLength(node, total_tips);

        if(total_tips > 0) {
            new tip[MAX_TIP_SIZE];
            new lang = GetPlayerLanguage(playerid);

            JSON_ArrayObject(node, random(total_tips), node);
            JSON_GetString(node, lang == ENGLISH ? "en" : "pt", tip, sizeof(tip));

            ChatMsg(playerid, GOLD, " > %s: "C_WHITE"%s", lang == ENGLISH ? "Tip" : "Dica", tip);
        }
    }
}

ACMD:tip[5](playerid) {
    SendTip(playerid);

    return 1;
}