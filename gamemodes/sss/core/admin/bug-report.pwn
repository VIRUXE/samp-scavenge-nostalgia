static Request:bugReport[MAX_PLAYERS];

CMD:bug(playerid)
{
	Dialog_Show(playerid, BugReport, DIALOG_STYLE_INPUT, "Reportar um BUG", ls(playerid, "server/bugs/bug-description"), ls(playerid, "common/confirm"), ls(playerid, "common/cancel"));
    
	return 1;
}

Dialog:BugReport(playerid, response, listitem, inputtext[])
{
	if(response) {
		new RequestsClient:discord = RequestsClient("https://discord.com/api/webhooks/1101824410073169971/MmpCkoUsjl-fRK700WGC0rd6zLj9eGSVyyan1TkULKb_bWDCjosnF4cG3R1pVLozJR6B");

		bugReport[playerid] = RequestJSON(
			discord,
			"",            
			HTTP_METHOD_POST, 
			"OnSubmitBugReport",    
			JsonObject(
				"content", JsonString(sprintf("`%p` reportou um bug: %s", GetPlayerNameEx(playerid), inputtext))
			)
		);

		printf("[BUGREPORT] '%p' reportou um bug: %s", playerid, inputtext);
	}

	return 1;
}

forward OnSubmitBugReport(Request:id, E_HTTP_STATUS:status, Node:node);
public OnSubmitBugReport(Request:id, E_HTTP_STATUS:status, Node:node) {
	new playerid = INVALID_PLAYER_ID;

	foreach(new i : Player) {
		if(bugReport[i] == id) {
			playerid = i;
			break;
		}
	}

	if(playerid == INVALID_PLAYER_ID) return;

	bugReport[playerid] = Request:INVALID_REQUEST_ID;

	ChatMsg(playerid, YELLOW, status == HTTP_STATUS_NO_CONTENT ? "server/bugs/submitted" : "server/bugs/failed");
} 