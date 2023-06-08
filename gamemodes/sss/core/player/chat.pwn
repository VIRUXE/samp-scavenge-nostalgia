#include <YSI\y_hooks>

// Chat modes
enum {
		CHAT_MODE_LOCAL,		// 0 - Speak to players within chatbubble distance
		CHAT_MODE_GLOBAL,		// 1 - Speak to all players
		CHAT_MODE_CLAN,			// 2 - Clan Chat
		CHAT_MODE_ADMIN			// 3 - Speak to admins
}

static
			chat_Mode[MAX_PLAYERS],
bool:		chat_Quiet[MAX_PLAYERS],
			chat_MessageStreak[MAX_PLAYERS],
			chat_LastMessageTick[MAX_PLAYERS],
			GlobalTime[MAX_PLAYERS],
			GlobalTime2 = 3,
bool:		GlobalOff = false,
PlayerText:	chatModeTextDraw;

forward OnPlayerSendChat(playerid, text[], Float:frequency);

ACMD:setglobal[2](playerid, params[]) {
	new timeOff;

	if(sscanf(params, "d", timeOff)) return ChatMsg(playerid, YELLOW, " >  Use: /setglobal [tempo] (0 para desativar)");

	if(timeOff == 0) {
	    ChatMsg(playerid, YELLOW, " > Chat Global desativado.");
	    GlobalTime2 = 0;
	    GlobalOff = true;
	} else {
	    ChatMsg(playerid, YELLOW, " > Tempo para usar o chat setado para %d segundos", timeOff);
	    GlobalOff = false;
	    GlobalTime2 = timeOff;
	}

	return 1;
}

hook OnGamemodeInit() {
    RegisterAdminCommand(STAFF_LEVEL_MODERATOR, "setglobal", "Mudar o tempo de enviar mensagem no global");
}

hook OnPlayerConnect(playerid) {
    GlobalTime[playerid] = 0;
	chat_LastMessageTick[playerid] = 0;

	chatModeTextDraw = CreatePlayerTextDraw(playerid, 5, 1.133333, "X");
	PlayerTextDrawLetterSize(playerid, chatModeTextDraw, 0.5, 2);
	PlayerTextDrawTextSize(playerid, chatModeTextDraw, 19.375, 19.833333);
	PlayerTextDrawAlignment(playerid, chatModeTextDraw, 1);
	PlayerTextDrawColor(playerid, chatModeTextDraw, 0xFFFFFFFF);
	PlayerTextDrawUseBox(playerid, chatModeTextDraw, 0);
	PlayerTextDrawBoxColor(playerid, chatModeTextDraw, 0x000000AA);
	PlayerTextDrawSetShadow(playerid, chatModeTextDraw, 0);
	PlayerTextDrawSetOutline(playerid, chatModeTextDraw, 1);
	PlayerTextDrawBackgroundColor(playerid, chatModeTextDraw, 0x000000FF);
	PlayerTextDrawFont(playerid, chatModeTextDraw, 1);
	PlayerTextDrawSetProportional(playerid, chatModeTextDraw, 1);

	return 1;
}

hook OnPlayerText(playerid, text[]) {
	if(IsPlayerMuted(playerid)) {
		if(GetPlayerMuteRemainder(playerid) == -1)
			ChatMsg(playerid, RED, "player/muted-perm");
		else
			ChatMsg(playerid, RED, "player/mute-timer", MsToString(GetPlayerMuteRemainder(playerid) * 1000, "%1h:%1m:%1s"));

		return 0;
	} else {
		if(GetTickCountDifference(GetTickCount(), chat_LastMessageTick[playerid]) < 1000) {
			chat_MessageStreak[playerid]++;

			if(chat_MessageStreak[playerid] == 3) {
				TogglePlayerMute(playerid, true, 30);
				ChatMsg(playerid, RED, "player/muted-temp");

				return 0;
			}
		} else {
			if(chat_MessageStreak[playerid] > 0)
				chat_MessageStreak[playerid]--;
		}
	}

	chat_LastMessageTick[playerid] = GetTickCount();

	if(chat_Mode[playerid] == CHAT_MODE_LOCAL) PlayerSendChat(playerid, text, 0.0);
	else if(chat_Mode[playerid] == CHAT_MODE_GLOBAL) PlayerSendChat(playerid, text, 1.0);
	else if(chat_Mode[playerid] == CHAT_MODE_ADMIN) PlayerSendChat(playerid, text, 3.0);
	else if(chat_Mode[playerid] == CHAT_MODE_CLAN) PlayerSendChat(playerid, text, 4.0);
	
	return 0;
}

hook OnPlayerLogin(playerid) {
	SetChatModeLetter(playerid);
	PlayerTextDrawShow(playerid, chatModeTextDraw);
}

SetChatModeLetter(playerid) {
	new letter[2] = "L";

	switch(chat_Mode[playerid]) {
		case CHAT_MODE_GLOBAL: letter = "G";
		case CHAT_MODE_CLAN:   letter = "C";
		case CHAT_MODE_ADMIN:  letter = "A";
	}

	PlayerTextDrawSetString(playerid, chatModeTextDraw, letter);
}

PlayerSendChat(playerid, chat[], Float:frequency) {
	if(!IsPlayerLoggedIn(playerid)) return 0;

	if(IsPlayerInTutorial(playerid)) {
		ChatMsg(playerid, RED, "player/chat/in-tutorial");
		return 0;
	}

	if(GetTickCountDifference(GetTickCount(), GetPlayerServerJoinTick(playerid)) < 1000) return 0;

	if(strlen(chat) < 1) return 0;
	    
	if(CallLocalFunction("OnPlayerSendChat", "dsf", playerid, chat, frequency)) return 0;

    if(!IsPlayerSpawned(playerid)) return 0;

	new line1[256], line2[128];

	if(frequency == 0.0) {
		log("[CHAT][LOCAL] [%p]: %s", playerid, chat);

		new Float:x, Float:y, Float:z;

		GetPlayerPos(playerid, x, y, z);

		format(line1, 256, "[L][%s] %C%p (%d)"C_WHITE": %s",
			IsPlayerSpectating(playerid) ? "SPECTATE" : (GetPlayerLanguage(playerid) == PORTUGUESE ? "PT" : "EN"),
			IsPlayerOnAdminDuty(playerid) ? GetAdminRankColour(GetPlayerAdminLevel(playerid)) : GetPlayerColor(playerid),
			playerid,
			playerid,
			TagScan(chat));

		TruncateChatMessage(line1, line2);

		foreach(new i : Player) {
			if(IsPlayerInRangeOfPoint(i, 40.0, x, y, z) && !IsPlayerInTutorial(i)) {
				SendClientMessage(i, CHAT_LOCAL, line1);

				if(!isnull(line2)) SendClientMessage(i, CHAT_LOCAL, line2);
			}
		}

		//SetPlayerChatBubble(playerid, TagScan(chat), WHITE, 40.0, 10000);

		return 1;
	} else if(frequency == 1.0) {
 		if(GlobalOff) return ChatMsg(playerid, RED, " > Chat global desativado.");

	    if(GlobalTime[playerid] != 0 && !GetPlayerAdminLevel(playerid)) return ChatMsg(playerid, RED, " > Você pode usar o chat global novamente em %d segundo%s.", GlobalTime[playerid], GlobalTime[playerid] > 1 ? "s" : "");

	    GlobalTime[playerid] = GlobalTime2;
		defer GlobalTimer(playerid);
		
		log("[CHAT][GLOBAL] [%p]: %s", playerid, chat);

		format(line1, 256, "[GLOBAL][%s] %C%p (%d)"C_WHITE": %s",
			GetPlayerLanguage(playerid) == 0 ? "PT" : "EN",
			IsPlayerOnAdminDuty(playerid) ? GetAdminRankColour(GetPlayerAdminLevel(playerid)) : GetPlayerColor(playerid),
			playerid,
			playerid,
			TagScan(chat, true));

		TruncateChatMessage(line1, line2);

		foreach(new i : Player) {
			if(chat_Quiet[i]) continue;

			if(IsPlayerInTutorial(i)) continue;
			    
			SendClientMessage(i, WHITE, line1);

			if(!isnull(line2)) SendClientMessage(i, WHITE, line2);
		}

		//SetPlayerChatBubble(playerid, TagScan(chat), WHITE, 40.0, 10000);

		return 1;
	} else if(frequency == 2.0) {
		log("[CHAT][LOCALME] [%p]: %s", playerid, chat);

		new Float:x, Float:y, Float:z;

		GetPlayerPos(playerid, x, y, z);

		format(line1, 256, "[LOCAL] %P %s", playerid, TagScan(chat));

		TruncateChatMessage(line1, line2);

		foreach(new i : Player) {
			if(IsPlayerInRangeOfPoint(i, 40.0, x, y, z) && !IsPlayerInTutorial(i)) {
				SendClientMessage(i, CHAT_LOCAL, line1);

				if(!isnull(line2)) SendClientMessage(i, CHAT_LOCAL, line2);
			}
		}

		//SetPlayerChatBubble(playerid, TagScan(chat), CHAT_LOCAL, 40.0, 10000);

		return 1;
	} else if(frequency == 3.0) {
		log("[CHAT][ADMIN] [%p]: %s", playerid, chat);

		format(line1, 256, "%C[ADMIN] %P (%d)"C_WHITE": %s",
			GetAdminRankColour(GetPlayerAdminLevel(playerid)),
			playerid,
			playerid,
			TagScan(chat));

		TruncateChatMessage(line1, line2);

		foreach(new i : Player) {
			if(GetPlayerAdminLevel(i) > 0) {
				SendClientMessage(i, CHAT_LOCAL, line1);

				if(!isnull(line2)) SendClientMessage(i, CHAT_LOCAL, line2);
			}
		}

		return 1;
	} else {
		/* log("[CHAT][CLAN] [%.2f] [%p]: %s", frequency, playerid, chat);

		format(line1, 256, "[CLAN] (%d) %P"C_WHITE": %s", playerid, playerid, TagScan(chat));

		TruncateChatMessage(line1, line2);

		foreach(new i : Player)
		{
		    if(!IsPlayerAllyForPlayer(playerid, i) && i != playerid) continue;
				
			SendClientMessage(i, CHAT_CLAN, line1);

			if(!isnull(line2)) SendClientMessage(i, CHAT_CLAN, line2);
		} */

		//SetPlayerChatBubble(playerid, TagScan(chat), WHITE, 40.0, 10000);

		return 1;
	}
}

timer GlobalTimer[1500](playerid) { // Tempo para liberar o global
	if(GlobalTime[playerid] != 0) {
	    GlobalTime[playerid] --;
	    defer GlobalTimer(playerid);
    }
}

GetPlayerChatMode(playerid) {
	if(!IsPlayerConnected(playerid)) return 0;

	return chat_Mode[playerid];
}

SetPlayerChatMode(playerid, chatmode) {
	if(!IsPlayerConnected(playerid)) return 0;

	if(chatmode == chat_Mode[playerid]) return 0;

	chat_Mode[playerid] = chatmode;

	SetChatModeLetter(playerid);

	return 1;
}

IsPlayerGlobalQuiet(playerid) {
	if(!IsPlayerConnected(playerid)) return 0;

	return chat_Quiet[playerid];
}

CMD:g(playerid, params[]) {
	if(IsPlayerMuted(playerid)) {
		if(GetPlayerMuteRemainder(playerid) == -1)
			ChatMsg(playerid, RED, "player/muted-perm");
		else
			ChatMsg(playerid, RED, "player/mute-timer", MsToString(GetPlayerMuteRemainder(playerid) * 1000, "%1h:%1m:%1s"));

		return 7;
	}

	if(isnull(params)) {
		if(!SetPlayerChatMode(playerid, CHAT_MODE_GLOBAL)) ChatMsg(playerid, GREY, "player/chat/mode/already");
		ChatMsg(playerid, WHITE, "player/radio/global");
	} else {
		PlayerSendChat(playerid, params, 1.0);

		if(chat_Mode[playerid] == CHAT_MODE_GLOBAL) ChatMsg(playerid, GREY, "player/chat/mode/already-tip");
	}

	return 7;
}

CMD:l(playerid, params[]) {
	if(isnull(params)) {
		if(!SetPlayerChatMode(playerid, CHAT_MODE_LOCAL)) ChatMsg(playerid, GREY, "player/chat/mode/already");
		ChatMsg(playerid, WHITE, "player/radio/local");
	} else {
		PlayerSendChat(playerid, params, 0.0);

		if(chat_Mode[playerid] == CHAT_MODE_LOCAL) ChatMsg(playerid, GREY, "player/chat/mode/already-tip");
	}

	return 7;
}

CMD:c(playerid, params[]) {
	if(isnull(params)) {
		if(SetPlayerChatMode(playerid, CHAT_MODE_CLAN)) ChatMsg(playerid, GREY, "player/chat/mode/already");
		ChatMsg(playerid, WHITE, "player/radio/freq", 4.0);
	} else {
		PlayerSendChat(playerid, params, 4.0);

		if(chat_Mode[playerid] == CHAT_MODE_CLAN) ChatMsg(playerid, GREY, "player/chat/mode/already-tip");
	}

	return 7;
}

CMD:me(playerid, params[]) {
	PlayerSendChat(playerid, params, 2.0);

	return 1;
}

CMD:globaloff(playerid, params[]) {
	chat_Quiet[playerid] = !chat_Quiet[playerid];

	return ChatMsg(playerid, WHITE, chat_Quiet[playerid] ? "player/radio/global-quiet" : "player/radio/global-quiet-off");
}

ACMD:a[1](playerid, params[]) {
	if(isnull(params)) {
		SetPlayerChatMode(playerid, CHAT_MODE_ADMIN);
		ChatMsg(playerid, WHITE, "player/radio/admin");
	} else {
		PlayerSendChat(playerid, params, 3.0);

		if(chat_Mode[playerid] == CHAT_MODE_ADMIN) ChatMsg(playerid, GREY, "player/chat/mode/already-tip");
	}

	return 7;
}

ACMD:setchatmode[1](playerid, params[]) {
	new const sintaxe[] = "> Sintaxe: /setchatmode [jogador] [local/global/clan]";
	new targetId, mode[7];

	if(sscanf(params, "rs[7]", targetId, mode)) return SendClientMessage(playerid, YELLOW, sintaxe);
	
	if(isequal(params, "local")) {
		SetPlayerChatMode(playerid, CHAT_MODE_LOCAL);
		ChatMsg(playerid, YELLOW, "> Modo de Chat de %p alterado para Local", targetId);
		ChatMsg(targetId, YELLOW, "> Modo de Chat alterado para Local, por %P", targetId, playerid);
	} else if(isequal(params, "global")) {
		SetPlayerChatMode(playerid, CHAT_MODE_GLOBAL);
		ChatMsg(playerid, YELLOW, "> Modo de Chat de %p alterado para Global", targetId);
		ChatMsg(targetId, YELLOW, "> Modo de Chat alterado para Global, por %P", targetId, playerid);
	} else if(isequal(params, "clan")) {
		SetPlayerChatMode(playerid, CHAT_MODE_CLAN);
		ChatMsg(playerid, YELLOW, "> Modo de Chat de %p alterado para Clan", targetId);
		ChatMsg(targetId, YELLOW, "> Modo de Chat alterado para Clan, por %P", targetId, playerid);
	} else
		SendClientMessage(playerid, YELLOW, sintaxe);

	return 1;
}