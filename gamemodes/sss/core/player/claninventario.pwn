#include <YSI\y_hooks>

#define MAX_PLAYER_FRIENDS  (3)

new
		frd_InventoryOption[MAX_PLAYERS],
		frd_PlayerFriend[MAX_PLAYERS][MAX_PLAYER_FRIENDS][MAX_PLAYER_NAME],
		frd_SelectRemove[MAX_PLAYERS],
bool:	frd_Invited[MAX_PLAYERS][MAX_PLAYERS],
Text3D:	frd_Tag[MAX_PLAYERS] = {Text3D:INVALID_3DTEXT_ID, ...};

/*==============================================================================

	Internal

==============================================================================*/

hook OnPlayerConnect(playerid)
{
    foreach(new i : Player)
    {
        frd_Invited[playerid][i] = false;
        frd_Invited[i][playerid] = false;
    }
}

hook OnPlayerDisconnect(playerid, reason)
{
	DestroyDynamic3DTextLabel(frd_Tag[playerid]);
	frd_Tag[playerid] = Text3D:INVALID_3DTEXT_ID;

	foreach(new i : Player)
    {
		if(IsPlayerAllyForPlayer(playerid, i))
        	RemovePlayerMapIcon(i, playerid);
    }
	return 1;
}

hook OnPlayerOpenInventory(playerid){
	frd_InventoryOption[playerid] = AddInventoryListItem(playerid, ls(playerid, "FRDOPTION"));
	return Y_HOOKS_CONTINUE_RETURN_0;
}

stock ShowFriendDialog(playerid){
	new str[ (MAX_PLAYER_NAME * MAX_PLAYER_FRIENDS) + 27];

    strcat(str, ls(playerid, "FRDADD"));
    strcat(str, "\n \n");

	for(new i = 0; i < MAX_PLAYER_FRIENDS; i++){
	    strcat(str, sprintf("%d. ", i + 1));
	    strcat(str, frd_PlayerFriend[playerid][i]);
		strcat(str, "\n");
	}

	Dialog_Show(playerid, Friend_Dialog, DIALOG_STYLE_LIST, ls(playerid, "FRDDIALOG"), str, ls(playerid, "FRDSELECT"), ls(playerid, "FRDCANCEL"));
}

hook OnPlayerSelectExtraItem(playerid, item){
	if(item == frd_InventoryOption[playerid])
        ShowFriendDialog(playerid);
	return Y_HOOKS_CONTINUE_RETURN_0;
}

Dialog:Friend_Dialog(playerid, response, listitem, inputtext[]){
	if(response){
	    // Add/Remove Friend
		if(listitem == 0){
			new
				str[ (MAX_PLAYER_NAME * MAX_PLAYERS) + 2],
				name[MAX_PLAYER_NAME],
				bool:isfriend;
			
			for(new i = 0; i < MAX_PLAYERS; i++)
			{
				if(!IsPlayerConnected(i))
				{
				    strcat(str, " \n");
				}
				else
				{
					GetPlayerName(i, name, MAX_PLAYER_NAME);

                    isfriend = false;

                    for(new f = 0; f < MAX_PLAYER_FRIENDS; f++){
						if(!strcmp(frd_PlayerFriend[playerid][f], name) && !isnull(frd_PlayerFriend[playerid][f])){
						    isfriend = true;
						    break;
						}
					}

					if(isfriend)
					    strcat(str, " ");
					else
				    	strcat(str, name);
				    	
					strcat(str, "\n");
				}
			}
			
		    Dialog_Show(playerid, Friend_Add, DIALOG_STYLE_LIST, ls(playerid, "FRDADD"), str, ls(playerid, "FRDSELECT"), ls(playerid, "FRDCANCEL"));
		}
		else if(listitem == 1)
            ShowFriendDialog(playerid);
		
		// Remove Friend
		else{
		    frd_SelectRemove[playerid] = listitem - 2;
		    Dialog_Show(playerid, Friend_Remove, DIALOG_STYLE_MSGBOX, frd_PlayerFriend[playerid][listitem - 2], ls(playerid, "FRDREMOVE"), ls(playerid, "FRDREMOVEY"), ls(playerid, "FRDREMOVEN"));
		}
	}
	else DisplayPlayerInventory(playerid);
}

Dialog:Friend_Add(playerid, response, listitem, inputtext[])
{
	if(response){
	    if(playerid == listitem || frd_Invited[playerid][listitem] || frd_Invited[listitem][playerid]){
		    ShowFriendDialog(playerid);
		    return 1;
		}

		new
			name[MAX_PLAYER_NAME],
			friend_count;

	    GetPlayerName(listitem, name, MAX_PLAYER_NAME);

	    for(new i = 0; i < MAX_PLAYER_FRIENDS; i++)
		{
			if(!strcmp(frd_PlayerFriend[playerid][i], name) && !isnull(frd_PlayerFriend[playerid][i])){
			    ShowFriendDialog(playerid);
			    return 1;
			}

			if(strlen(frd_PlayerFriend[playerid][i]) >= 3)
				friend_count ++;
		}

		if(friend_count >= MAX_PLAYER_FRIENDS){
		    Dialog_Show(playerid, Friend_Invited, DIALOG_STYLE_MSGBOX, name, ls(playerid, "FRDMAX"), "<", "");
		    return 1;
		}

		frd_Invited[playerid][listitem] = true;

	    ChatMsg(listitem, YELLOW, "FRDACCPT", playerid, playerid);

	    Dialog_Show(playerid, Friend_Invited, DIALOG_STYLE_MSGBOX, name, ls(playerid, "FRDINVITED"), "<", "");
	}
	else
	    ShowFriendDialog(playerid);

	return 1;
}

CMD:accept(playerid, params[])
{
	if(!IsPlayerSpawned(playerid)) return 1;
	
	if(strlen(params) < 1)
        return ChatMsg(playerid, RED, "FRDACCCMD");

	new id = strval(params);

	if(!IsPlayerConnected(id))
	    return ChatMsg(playerid, RED, "FRDCMDOFF");
	    
	if(!frd_Invited[id][playerid])
	    return ChatMsg(playerid, RED, "FRDNOTINV");

	new
		name[MAX_PLAYER_NAME];

    GetPlayerName(id, name, MAX_PLAYER_NAME);
	
    for(new i = 0; i < MAX_PLAYER_FRIENDS; i++)
    {
		if(strlen(frd_PlayerFriend[playerid][i]) < 3)
		{
			frd_PlayerFriend[playerid][i][0] = EOS;
    		strcat(frd_PlayerFriend[playerid][i], name, MAX_PLAYER_NAME);
    		break;
		}
	}
	
    GetPlayerName(playerid, name, MAX_PLAYER_NAME);
    
    for(new i = 0; i < MAX_PLAYER_FRIENDS; i++)
    {
		if(strlen(frd_PlayerFriend[id][i]) < 3)
		{
  			frd_PlayerFriend[id][i][0] = EOS;
    		strcat(frd_PlayerFriend[id][i], name, MAX_PLAYER_NAME);
    		break;
		}
	}
    
    ShowPlayerDialog(playerid, 10008, DIALOG_STYLE_MSGBOX, ls(playerid, "FRDADD"), ls(playerid, "FRDNEW"), "X", "");
    ShowPlayerDialog(id, 10008, DIALOG_STYLE_MSGBOX, ls(id, "FRDADD"), ls(id, "FRDNEW"), "X", "");
    
    ClanNameTagUpdate(playerid);
    ClanNameTagUpdate(id);
    
    frd_Invited[id][playerid] = false;
    frd_Invited[playerid][id] = false;
	return 1;
}

CMD:aceitar(playerid, params[])
	return cmd_accept(playerid, params);

CMD:aceptar(playerid, params[])
	return cmd_accept(playerid, params);

CMD:terima(playerid, params[])
	return cmd_accept(playerid, params);
	
CMD:accepter(playerid, params[])
	return cmd_accept(playerid, params);
	
CMD:accepta(playerid, params[])
	return cmd_accept(playerid, params);
	
Dialog:Friend_Invited(playerid, response, listitem, inputtext[])
    if(response) ShowFriendDialog(playerid);
    
Dialog:Friend_Remove(playerid, response, listitem, inputtext[]){
	if(response){
	    new
			name[MAX_PLAYER_NAME];

	    foreach(new i : Player)
		{
	        if(i == playerid)
	            continue;
	            
      		GetPlayerName(i, name, MAX_PLAYER_NAME);

		    if(!strcmp(frd_PlayerFriend[playerid][frd_SelectRemove[playerid]], name) && !isnull(frd_PlayerFriend[playerid][frd_SelectRemove[playerid]]))
		    {
		        ChatMsg(i, YELLOW, "FRDRMINFOR", playerid);
		        GetPlayerName(playerid, name, MAX_PLAYER_NAME);
		        for(new f = 0; f < MAX_PLAYER_FRIENDS; f++)
		        {
		            if(!strcmp(frd_PlayerFriend[i][f], name) && !isnull(frd_PlayerFriend[i][f]))
		            {
		        		frd_PlayerFriend[i][f][0] = EOS;
					}
		        }
		        
		        ClanNameTagUpdate(i);
			}
		}
		
		ChatMsg(playerid, YELLOW, "FRDRMINFO", frd_PlayerFriend[playerid][frd_SelectRemove[playerid]]);

		frd_PlayerFriend[playerid][frd_SelectRemove[playerid]][0] = EOS;

  		ClanNameTagUpdate(playerid);
	}

	ShowFriendDialog(playerid);
}


ptask ClanNameTagUpdate_t[SEC(5)](playerid)
{
    ClanNameTagUpdate(playerid);
}

ClanNameTagUpdate(playerid)
{
	if(PlayerMapCheck(playerid))
	{
		if(frd_Tag[playerid] != Text3D:INVALID_3DTEXT_ID)
		{
			DestroyDynamic3DTextLabel(frd_Tag[playerid]);
			frd_Tag[playerid] = Text3D:INVALID_3DTEXT_ID;
		}

		new
			players[MAX_PLAYERS],
			maxplayers,
			name[24];

		GetPlayerName(playerid, name, 24);

		foreach(new i : Player)
		{
			if(IsPlayerAllyForPlayer(playerid, i))
			{
				players[maxplayers++] = i;
			}
		}

		frd_Tag[playerid] = CreateDynamic3DTextLabelEx(
			name, CHAT_CLAN, 0.0, 0.0, 0.5, 300.0, playerid,
			.testlos = 0,
			.streamdistance = 300.0,
			.players = players,
			.maxplayers = maxplayers);
	}
}

ptask UpdatePlayerClanGPS[500](playerid)
{
	if(PlayerMapCheck(playerid))
	{
		foreach(new i : Player)
		{
			new
				BitStream:bs = BS_New();

			if(IsPlayerAllyForPlayer(playerid, i) && !IsPlayerOnAdminDuty(i))
			{
				BS_WriteValue(bs, PR_UINT16, playerid, PR_UINT32, 0x00FF0000);

				new
					Float:x,
					Float:y,
					Float:z;

				GetPlayerPos(i, x, y, z);
				SetPlayerMapIcon(playerid, i, x, y, z, 62, 0, MAPICON_GLOBAL);
			}
			else
			{
				BS_WriteValue(bs, PR_UINT16, playerid, PR_UINT32, GetPlayerColor(playerid));
				RemovePlayerMapIcon(playerid, i);
			}

			PR_SendRPC(bs, i, 72); // SetPlayerColor
			BS_Delete(bs);
		}
	}
}

/*==============================================================================

	Functions

==============================================================================*/

stock IsPlayerAllyForPlayer(playerid, allyid)
{
	if(!IsPlayerConnected(playerid))
	    return 0;

    if(!IsPlayerConnected(allyid))
	    return 0;

	if(playerid == allyid)
	    return 0;

	new name[MAX_PLAYER_NAME];

    for(new i = 0; i < MAX_PLAYER_FRIENDS; i++)
    {
        GetPlayerName(allyid, name, MAX_PLAYER_NAME);
		if(!strcmp(frd_PlayerFriend[playerid][i], name) && !isnull(frd_PlayerFriend[playerid][i]))
		{
		    GetPlayerName(playerid, name, MAX_PLAYER_NAME);
		    for(new f = 0; f < MAX_PLAYER_FRIENDS; f++)
		    {
				if(!strcmp(frd_PlayerFriend[allyid][f], name) && !isnull(frd_PlayerFriend[allyid][f]))
				{
		    		return 1;
		    	}
			}
		}
    }
    
	return 0;
}

stock SetPlayerFriend(playerid, id, name[])
{
	if(id >= MAX_PLAYER_FRIENDS)
	    return 0;
	    
    frd_PlayerFriend[playerid][id][0] = EOS;
    strcat(frd_PlayerFriend[playerid][id], name, MAX_PLAYER_NAME);
    return 1;
}

stock GetPlayerFriend(playerid, id, name[]){
    if(id >= MAX_PLAYER_FRIENDS)
	    return 0;
	    
	format(name, MAX_PLAYER_NAME, frd_PlayerFriend[playerid][id]);
	return 1;
}
