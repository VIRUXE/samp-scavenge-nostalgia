#include <YSI\y_hooks>


// Chat modes
enum
{
		CHAT_MODE_LOCAL,		// 0 - Speak to players within chatbubble distance
		CHAT_MODE_GLOBAL,		// 1 - Speak to all players
		CHAT_MODE_CLAN,			// 2 - Clan Chat
		CHAT_MODE_ADMIN			// 3 - Speak to admins
}


new
		chat_Mode[MAX_PLAYERS],
bool:	chat_Quiet[MAX_PLAYERS],
		chat_MessageStreak[MAX_PLAYERS],
		chat_LastMessageTick[MAX_PLAYERS],
		GlobalTime[MAX_PLAYERS],
		GlobalTime2 = 3,
bool:	GlobalOff = false;

forward OnPlayerSendChat(playerid, text[], Float:frequency);

ACMD:setglobal[2](playerid, params[])
{
	new timeOff;

	if(sscanf(params, "d", timeOff)) return ChatMsg(playerid, YELLOW, " >  Use: /setglobal [tempo] (0 para desativar)");

	if(timeOff == 0)
	{
	    ChatMsg(playerid, YELLOW, " > Chat Global desativado.");
	    GlobalTime2 = 0;
	    GlobalOff = true;
	}
	else
	{
	    ChatMsg(playerid, YELLOW, " > Tempo para usar o chat setado para %d segundos", timeOff);
	    GlobalOff = false;
	    GlobalTime2 = timeOff;
	}

	return 1;
}

hook OnPlayerConnect(playerid)
{
	dbg("global", CORE, "[OnPlayerConnect] in /gamemodes/sss/core/player/chat.pwn");

    GlobalTime[playerid] = 0;
	chat_LastMessageTick[playerid] = 0;

	return 1;
}

hook OnPlayerText(playerid, text[])
{
	dbg("global", CORE, "[OnPlayerText] in /gamemodes/sss/core/player/chat.pwn");

	if(IsPlayerMuted(playerid))
	{
		if(GetPlayerMuteRemainder(playerid) == -1)
			ChatMsgLang(playerid, RED, "MUTEDPERMAN");
		else
			ChatMsgLang(playerid, RED, "MUTEDTIMERM", MsToString(GetPlayerMuteRemainder(playerid) * 1000, "%1h:%1m:%1s"));

		return 0;
	}
	else
	{
		if(GetTickCountDifference(GetTickCount(), chat_LastMessageTick[playerid]) < 1000)
		{
			chat_MessageStreak[playerid]++;
			if(chat_MessageStreak[playerid] == 3)
			{
				TogglePlayerMute(playerid, true, 30);
				ChatMsgLang(playerid, RED, "MUTEDFLOODM");

				return 0;
			}
		}
		else
		{
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

PlayerSendChat(playerid, chat[], Float:frequency)
{
	if(!IsPlayerLoggedIn(playerid)) return 0;

	if(GetTickCountDifference(GetTickCount(), GetPlayerServerJoinTick(playerid)) < 1000) return 0;

	if(strlen(chat) < 1) return 0;
	    
	if(CallLocalFunction("OnPlayerSendChat", "dsf", playerid, chat, frequency)) return 0;

    if(!IsPlayerSpawned(playerid)) return 0;

	new line1[256], line2[128];

	if(frequency == 0.0)
	{
		log("[CHAT][LOCAL] [%p]: %s", playerid, chat);

		new Float:x, Float:y, Float:z;

		GetPlayerPos(playerid, x, y, z);

		format(line1, 256, "[L][%s] (%d) %P"C_WHITE": %s",
			GetPlayerLanguage(playerid) == 0 ? "PT" : "EN",
			playerid,
			playerid,
			TagScan(chat));

		TruncateChatMessage(line1, line2);

		foreach(new i : Player)
		{
			if(IsPlayerInRangeOfPoint(i, 40.0, x, y, z) && !IsPlayerInTutorial(i))
			{
				SendClientMessage(i, CHAT_LOCAL, line1);

				if(!isnull(line2)) SendClientMessage(i, CHAT_LOCAL, line2);
			}
		}

		//SetPlayerChatBubble(playerid, TagScan(chat), WHITE, 40.0, 10000);

		return 1;
	} else if(frequency == 1.0) {
 		if(GlobalOff) return ChatMsg(playerid, RED, " > Chat global desativado.");

	    if(GlobalTime[playerid] != 0) return ChatMsg(playerid, RED, " > Você pode usar o chat global novamente em %d segundos.", GlobalTime[playerid]);

	    GlobalTime[playerid] = GlobalTime2;
		defer GlobalTimer(playerid);
		
		log("[CHAT][GLOBAL] [%p]: %s", playerid, chat);

		format(line1, 256, "[GLOBAL][%s] (%d) %P"C_WHITE": %s",
			GetPlayerLanguage(playerid) == 0 ? "PT" : "EN",
			playerid,
			playerid,
			TagScan(chat));

		TruncateChatMessage(line1, line2);

		foreach(new i : Player)
		{
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

		foreach(new i : Player)
		{
			if(IsPlayerInRangeOfPoint(i, 40.0, x, y, z) && !IsPlayerInTutorial(i))
			{
				SendClientMessage(i, CHAT_LOCAL, line1);

				if(!isnull(line2)) SendClientMessage(i, CHAT_LOCAL, line2);
			}
		}

		//SetPlayerChatBubble(playerid, TagScan(chat), CHAT_LOCAL, 40.0, 10000);

		return 1;
	}
	else if(frequency == 3.0)
	{
		log("[CHAT][ADMIN] [%p]: %s", playerid, chat);

		format(line1, 256, "%C[Admin] (%d) %P"C_WHITE": %s",
			GetAdminRankColour(GetPlayerAdminLevel(playerid)),
			playerid,
			playerid,
			TagScan(chat));

		TruncateChatMessage(line1, line2);

		foreach(new i : Player)
		{
			if(GetPlayerAdminLevel(i) > 0)
			{
				SendClientMessage(i, CHAT_LOCAL, line1);

				if(!isnull(line2)) SendClientMessage(i, CHAT_LOCAL, line2);
			}
		}

		return 1;
	}
	else
	{
		log("[CHAT][CLAN] [%.2f] [%p]: %s", frequency, playerid, chat);

		format(line1, 256, "[CLAN] (%d) %P"C_WHITE": %s", playerid, playerid, TagScan(chat));

		TruncateChatMessage(line1, line2);

		foreach(new i : Player)
		{
		    if(!IsPlayerAllyForPlayer(playerid, i) && i != playerid) continue;
				
			SendClientMessage(i, CHAT_CLAN, line1);

			if(!isnull(line2)) SendClientMessage(i, CHAT_CLAN, line2);
		}

		//SetPlayerChatBubble(playerid, TagScan(chat), WHITE, 40.0, 10000);

		return 1;
	}
}

timer GlobalTimer[1500](playerid) // Tempo para liberar o global
{
	if(GlobalTime[playerid] != 0)
	{
	    GlobalTime[playerid] --;
	    defer GlobalTimer(playerid);
    }
}


stock GetPlayerChatMode(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;

	return chat_Mode[playerid];
}

stock SetPlayerChatMode(playerid, chatmode)
{
	if(!IsPlayerConnected(playerid)) return 0;

	chat_Mode[playerid] = chatmode;

	return 1;
}

stock IsPlayerGlobalQuiet(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;

	return chat_Quiet[playerid];
}

CMD:g(playerid, params[])
{
	if(IsPlayerMuted(playerid))
	{
		if(GetPlayerMuteRemainder(playerid) == -1)
			ChatMsgLang(playerid, RED, "MUTEDPERMAN");
		else
			ChatMsgLang(playerid, RED, "MUTEDTIMERM", MsToString(GetPlayerMuteRemainder(playerid) * 1000, "%1h:%1m:%1s"));

		return 7;
	}

	if(isnull(params))
	{
		SetPlayerChatMode(playerid, CHAT_MODE_GLOBAL);
		ChatMsgLang(playerid, WHITE, "RADIOGLOBAL");
	}
	else PlayerSendChat(playerid, params, 1.0);

	return 7;
}

CMD:l(playerid, params[])
{
	if(isnull(params))
	{
		SetPlayerChatMode(playerid, CHAT_MODE_LOCAL);
		ChatMsgLang(playerid, WHITE, "RADIOLOCAL");
	}
	else PlayerSendChat(playerid, params, 0.0);

	return 7;
}

CMD:me(playerid, params[])
{
	PlayerSendChat(playerid, params, 2.0);

	return 1;
}

CMD:c(playerid, params[])
{
	if(isnull(params))
	{
		SetPlayerChatMode(playerid, CHAT_MODE_CLAN);
		ChatMsgLang(playerid, WHITE, "RADIOFREQUN", 4.0);
	}
	else PlayerSendChat(playerid, params, 4.0);

	return 7;
}

CMD:globaloff(playerid, params[])
{
	chat_Quiet[playerid] = !chat_Quiet[playerid];

	return ChatMsgLang(playerid, WHITE, chat_Quiet[playerid] ? "RADIOQUIET0" : "RADIOQUIET1");
}

ACMD:a[1](playerid, params[])
{
	if(isnull(params))
	{
		SetPlayerChatMode(playerid, CHAT_MODE_ADMIN);
		ChatMsgLang(playerid, WHITE, "RADIOADMINC");
	}
	else PlayerSendChat(playerid, params, 3.0);

	return 7;
}
