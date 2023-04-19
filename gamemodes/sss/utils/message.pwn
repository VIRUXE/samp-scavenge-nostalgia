#include <YSI\y_va>


static formatBuffer[244];

#define SendClientMessageToAll msg_SendClientMessageToAll

// Override SendClientMessageToAll to use our own function
stock msg_SendClientMessageToAll(colour, string[])
{
	foreach(new i: Player)
	{
		if(IsPlayerInTutorial(i)) continue; // don't send messages to players in tutorial
		if(!IsPlayerLoggedIn(i)) continue; // don't send messages to players who aren't logged in

		ChatMsgFlat(i, colour, string);
	}
	
	return 1;
}


/*==============================================================================

	Main Chat Functions

==============================================================================*/


stock ChatMsg(playerid, colour, fmat[], {Float,_}:...)
{
	format(formatBuffer, sizeof(formatBuffer), strfind(fmat, "/") != -1 ? ls(playerid, fmat) : fmat, ___(3));
	ChatMsgFlat(playerid, colour, formatBuffer);

	return 1;
}

stock ChatMsgAllEx(playerid, colour, fmat[], {Float,_}:...)
{
	foreach(new i: Player) {
	    if(i == playerid) continue;

		format(formatBuffer, sizeof(formatBuffer), fmat, ___(3));
		ChatMsgFlat(i, colour, formatBuffer);
	}

	return 1;
}

stock ChatMsgAll(colour, fmat[], {Float,_}:...)
{
	format(formatBuffer, sizeof(formatBuffer), fmat, ___(2));
	ChatMsgAllFlat(colour, formatBuffer);

	return 1;
}

stock ChatMsgAdmins(level, colour, fmat[], {Float,_}:...)
{
	format(formatBuffer, sizeof(formatBuffer), fmat, ___(3));
	ChatMsgAdminsFlat(level, colour, formatBuffer);

	return 1;
}


/*==============================================================================

	"Flat" Message with no formatting, never actually needs to be used in-code.

==============================================================================*/


stock ChatMsgFlat(playerid, colour, string[])
{
	if(strlen(string) > 127) {
		new
			string2[128],
			splitpos;

		for(new c = 128; c > 0; c--) {
			if(string[c] == ' ' || string[c] ==  ',' || string[c] ==  '.') {
				splitpos = c;
				break;
			}
		}

		strcat(string2, string[splitpos]);
		string[splitpos] = EOS;
		
		SendClientMessage(playerid, colour, string);
		SendClientMessage(playerid, colour, string2);
	} else
		SendClientMessage(playerid, colour, string);
	
	return 1;
}

stock ChatMsgAllFlat(colour, string[])
{
	if(strlen(string) > 127) {
		new
			string2[128],
			splitpos;

		for(new c = 128; c>0; c--) {
			if(string[c] == ' ' || string[c] ==  ',' || string[c] ==  '.') {
				splitpos = c;
				break;
			}
		}

		strcat(string2, string[splitpos]);
		string[splitpos] = EOS;

		SendClientMessageToAll(colour, string);
		SendClientMessageToAll(colour, string2);
	} else
		SendClientMessageToAll(colour, string);

	return 1;
}