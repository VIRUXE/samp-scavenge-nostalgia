/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/


#include <YSI\y_hooks>


#define MAX_RADIO_FREQ (300.0)
#define MIN_RADIO_FREQ (0.0)


static
	rad_InventoryItem[MAX_PLAYERS],
	rad_ViewingRadio[MAX_PLAYERS],
	rad_OldMode[MAX_PLAYERS],
	PlayerText:RadioUI_Main[MAX_PLAYERS],
	PlayerText:RadioUI_Strip[MAX_PLAYERS],
	PlayerText:RadioUI_KnobL[MAX_PLAYERS],
	PlayerText:RadioUI_KnobR[MAX_PLAYERS],
	PlayerText:RadioUI_Mode[MAX_PLAYERS],
	PlayerText:RadioUI_Freq[MAX_PLAYERS],
	PlayerText:RadioUI_Power[MAX_PLAYERS],
	PlayerText:RadioUI_Back[MAX_PLAYERS];

static Text3D: radio_Nametag[MAX_PLAYERS] = {Text3D:INVALID_3DTEXT_ID, ...};

ptask RadioNameTagUpdate[SEC(5)](playerid)
{
	if(radio_Nametag[playerid] != Text3D:INVALID_3DTEXT_ID) {
	    DestroyDynamic3DTextLabel(radio_Nametag[playerid]);
		radio_Nametag[playerid] = Text3D:INVALID_3DTEXT_ID;
	}
	
    if(GetPlayerRadioFrequency(playerid) == 0.0) return;

    if(GetPlayerRadioFrequency(playerid) == 1.0) return;

    if(GetPlayerRadioFrequency(playerid) == 2.0) return;

    if(GetPlayerRadioFrequency(playerid) == 3.0) return;
		    
    if(!IsPlayerSpawned(playerid)) return;
			
	new
		players[MAX_PLAYERS],
		maxplayers,
		name[24];
		
	GetPlayerName(playerid, name, 24);

	foreach(new i : Player){
		if(i == playerid) continue;
			
		if(!IsPlayerSpawned(i)) continue;
			
	    if(GetPlayerRadioFrequency(playerid) == GetPlayerRadioFrequency(i)) players[maxplayers++] = i;
	}

	radio_Nametag[playerid] = CreateDynamic3DTextLabelEx(
		name, CHAT_RADIO, 0.0, 0.0, 0.5, 300.0, playerid,
		.testlos = 0,
		.streamdistance = 300.0,
		.players = players,
		.maxplayers = maxplayers);
}

hook OnPlayerDisconnect(playerid, reason)
{
	DestroyDynamic3DTextLabel(radio_Nametag[playerid]);
	radio_Nametag[playerid] = Text3D:INVALID_3DTEXT_ID;
	return 1;
}

ShowRadioUI(playerid)
{
	PlayerTextDrawShow(playerid, RadioUI_Main[playerid]);
	PlayerTextDrawShow(playerid, RadioUI_Strip[playerid]);
	PlayerTextDrawShow(playerid, RadioUI_KnobL[playerid]);
	PlayerTextDrawShow(playerid, RadioUI_KnobR[playerid]);
	PlayerTextDrawShow(playerid, RadioUI_Mode[playerid]);
	PlayerTextDrawShow(playerid, RadioUI_Freq[playerid]);
	PlayerTextDrawShow(playerid, RadioUI_Power[playerid]);
	PlayerTextDrawShow(playerid, RadioUI_Back[playerid]);

	SelectTextDraw(playerid, 0xFFFFFF88);
	UpdateRadioUI(playerid);

	rad_ViewingRadio[playerid] = true;
}

HideRadioUI(playerid)
{
	PlayerTextDrawHide(playerid, RadioUI_Main[playerid]);
	PlayerTextDrawHide(playerid, RadioUI_Strip[playerid]);
	PlayerTextDrawHide(playerid, RadioUI_KnobL[playerid]);
	PlayerTextDrawHide(playerid, RadioUI_KnobR[playerid]);
	PlayerTextDrawHide(playerid, RadioUI_Mode[playerid]);
	PlayerTextDrawHide(playerid, RadioUI_Freq[playerid]);
	PlayerTextDrawHide(playerid, RadioUI_Power[playerid]);
	PlayerTextDrawHide(playerid, RadioUI_Back[playerid]);

	if(!IsPlayerInAnyVehicle(playerid)) DisplayPlayerInventory(playerid);
	else CancelSelectTextDraw(playerid);

	rad_ViewingRadio[playerid] = false;
}

UpdateRadioUI(playerid)
{
	new str[18];

	format(str, 18, "Frequency: %.2f", GetPlayerRadioFrequency(playerid));
	PlayerTextDrawSetString(playerid, RadioUI_Freq[playerid], str);

	if(GetPlayerChatMode(playerid) == CHAT_MODE_LOCAL)
	{
		PlayerTextDrawSetString(playerid, RadioUI_Power[playerid], "off");

		PlayerTextDrawSetString(playerid, RadioUI_Mode[playerid], rad_OldMode[playerid] == CHAT_MODE_GLOBAL ? "global" : "freq");
	}

	if(GetPlayerChatMode(playerid) == CHAT_MODE_GLOBAL)
	{
		PlayerTextDrawSetString(playerid, RadioUI_Mode[playerid], "global");
		PlayerTextDrawSetString(playerid, RadioUI_Power[playerid], "on");
	}

	if(GetPlayerChatMode(playerid) == CHAT_MODE_RADIO)
	{
		PlayerTextDrawSetString(playerid, RadioUI_Mode[playerid], "freq");
		PlayerTextDrawSetString(playerid, RadioUI_Power[playerid], "on");
	}
}

hook OnPlayerClickPlayerTD(playerid, PlayerText:playertextid)
{
	dbg("global", CORE, "[OnPlayerClickPlayerTD] in /gamemodes/sss/core/ui/radio.pwn");

	if(playertextid == RadioUI_KnobL[playerid])
	{
		if(GetPlayerRadioFrequency(playerid) - 0.5 <= MIN_RADIO_FREQ)
			SetPlayerRadioFrequency(playerid, MIN_RADIO_FREQ);
		else
			SetPlayerRadioFrequency(playerid, GetPlayerRadioFrequency(playerid) - 0.5);

		UpdateRadioUI(playerid);
	}
	if(playertextid == RadioUI_KnobR[playerid])
	{
		if(GetPlayerRadioFrequency(playerid) + 0.5 >= MAX_RADIO_FREQ)
			SetPlayerRadioFrequency(playerid, MAX_RADIO_FREQ);
		else
			SetPlayerRadioFrequency(playerid, GetPlayerRadioFrequency(playerid) + 0.5);

		UpdateRadioUI(playerid);
	}
	if(playertextid == RadioUI_Mode[playerid])
	{
		if(GetPlayerChatMode(playerid) == CHAT_MODE_GLOBAL)
			SetPlayerChatMode(playerid, CHAT_MODE_RADIO);
		else if(GetPlayerChatMode(playerid) == CHAT_MODE_RADIO)
			SetPlayerChatMode(playerid, CHAT_MODE_GLOBAL);

		UpdateRadioUI(playerid);
	}
	if(playertextid == RadioUI_Freq[playerid])
	{
		ShowFrequencyDialog(playerid);
	}
	if(playertextid == RadioUI_Power[playerid])
	{
		if(GetPlayerChatMode(playerid) == CHAT_MODE_LOCAL)
		{
			SetPlayerChatMode(playerid, rad_OldMode[playerid] == CHAT_MODE_GLOBAL ? CHAT_MODE_GLOBAL : CHAT_MODE_RADIO);
		}
		else
		{
			rad_OldMode[playerid] = GetPlayerChatMode(playerid);
			SetPlayerChatMode(playerid, CHAT_MODE_LOCAL);
		}

		UpdateRadioUI(playerid);
	}
	if(playertextid == RadioUI_Back[playerid]) HideRadioUI(playerid);

	return 1;
}

ShowFrequencyDialog(playerid)
{
	Dialog_Show(playerid, Frequency, DIALOG_STYLE_INPUT, "Frequencia", "Digite uma frequencia entre 0.0 e 300.0", "Aceitar", "Cancelar");

	return 1;
}

Dialog:Frequency(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		new Float:frequency;
		if(!sscanf(inputtext, "f", frequency))
		{
			if(MIN_RADIO_FREQ <= frequency <= MAX_RADIO_FREQ)
			{
				SetPlayerRadioFrequency(playerid, frequency);
				log("%p updated frequency to %.2f", playerid, frequency);
				UpdateRadioUI(playerid);
			}
			else ShowFrequencyDialog(playerid);
		}
		else ShowFrequencyDialog(playerid);
	}
}

hook OnPlayerClickTextDraw(playerid, Text:clickedid)
{
	dbg("global", CORE, "[OnPlayerClickTextDraw] in /gamemodes/sss/core/ui/radio.pwn");

	if(clickedid == Text:65535 && rad_ViewingRadio[playerid]) SelectTextDraw(playerid, 0xFFFFFF88);
}


hook OnPlayerOpenInventory(playerid)
{
	dbg("global", CORE, "[OnPlayerOpenInventory] in /gamemodes/sss/core/ui/radio.pwn");

	rad_InventoryItem[playerid] = AddInventoryListItem(playerid, "Radio");

	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnPlayerSelectExtraItem(playerid, item)
{
	dbg("global", CORE, "[OnPlayerSelectExtraItem] in /gamemodes/sss/core/ui/radio.pwn");

	if(item == rad_InventoryItem[playerid]) ShowRadioUI(playerid);}

	return Y_HOOKS_CONTINUE_RETURN_0;
}


hook OnPlayerConnect(playerid)
{
	dbg("global", CORE, "[OnPlayerConnect] in /gamemodes/sss/core/ui/radio.pwn");

	RadioUI_Main[playerid]					= CreatePlayerTextDraw(playerid, 320.000000, 200.000000, "RADIO~n~ ~n~ ~n~ ~n~ ~n~ ");
	PlayerTextDrawAlignment			(playerid, RadioUI_Main[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, RadioUI_Main[playerid], 255);
	PlayerTextDrawFont				(playerid, RadioUI_Main[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, RadioUI_Main[playerid], 0.500000, 1.499999);
	PlayerTextDrawColor				(playerid, RadioUI_Main[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, RadioUI_Main[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, RadioUI_Main[playerid], 1);
	PlayerTextDrawUseBox			(playerid, RadioUI_Main[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, RadioUI_Main[playerid], 100);
	PlayerTextDrawTextSize			(playerid, RadioUI_Main[playerid], 0.000000, 200.000000);

	RadioUI_Strip[playerid]					= CreatePlayerTextDraw(playerid, 320.000000, 220.000000, "-l-l-l-l-l-l-l-l-l-l-l-l-l-l-l-l-l-l-l-");
	PlayerTextDrawAlignment			(playerid, RadioUI_Strip[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, RadioUI_Strip[playerid], 255);
	PlayerTextDrawFont				(playerid, RadioUI_Strip[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, RadioUI_Strip[playerid], 0.300000, 1.000000);
	PlayerTextDrawColor				(playerid, RadioUI_Strip[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, RadioUI_Strip[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, RadioUI_Strip[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, RadioUI_Strip[playerid], 0);

	RadioUI_KnobL[playerid]					= CreatePlayerTextDraw(playerid, 220.000000, 203.000000, "LD_DRV:nawtxt");
	PlayerTextDrawBackgroundColor	(playerid, RadioUI_KnobL[playerid], 255);
	PlayerTextDrawFont				(playerid, RadioUI_KnobL[playerid], 4);
	PlayerTextDrawLetterSize		(playerid, RadioUI_KnobL[playerid], 0.500000, 1.000000);
	PlayerTextDrawColor				(playerid, RadioUI_KnobL[playerid], 0x780000FA);
	PlayerTextDrawSetOutline		(playerid, RadioUI_KnobL[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, RadioUI_KnobL[playerid], 1);
	PlayerTextDrawUseBox			(playerid, RadioUI_KnobL[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, RadioUI_KnobL[playerid], 255);
	PlayerTextDrawTextSize			(playerid, RadioUI_KnobL[playerid], 30.000000, 30.000000);
	PlayerTextDrawSetSelectable		(playerid, RadioUI_KnobL[playerid], true);

	RadioUI_KnobR[playerid]					= CreatePlayerTextDraw(playerid, 390.000000, 203.000000, "LD_DRV:nawtxt");
	PlayerTextDrawBackgroundColor	(playerid, RadioUI_KnobR[playerid], 255);
	PlayerTextDrawFont				(playerid, RadioUI_KnobR[playerid], 4);
	PlayerTextDrawLetterSize		(playerid, RadioUI_KnobR[playerid], 0.500000, 1.000000);
	PlayerTextDrawColor				(playerid, RadioUI_KnobR[playerid], 0x780000FA);
	PlayerTextDrawSetOutline		(playerid, RadioUI_KnobR[playerid], 1);
	PlayerTextDrawSetProportional	(playerid, RadioUI_KnobR[playerid], 1);
	PlayerTextDrawUseBox			(playerid, RadioUI_KnobR[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, RadioUI_KnobR[playerid], 255);
	PlayerTextDrawTextSize			(playerid, RadioUI_KnobR[playerid], 30.000000, 30.000000);
	PlayerTextDrawSetSelectable		(playerid, RadioUI_KnobR[playerid], true);

	RadioUI_Mode[playerid]					= CreatePlayerTextDraw(playerid, 238.000000, 251.000000, "global");
	PlayerTextDrawAlignment			(playerid, RadioUI_Mode[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, RadioUI_Mode[playerid], 255);
	PlayerTextDrawFont				(playerid, RadioUI_Mode[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, RadioUI_Mode[playerid], 0.300000, 1.499999);
	PlayerTextDrawColor				(playerid, RadioUI_Mode[playerid], 16777215);
	PlayerTextDrawSetOutline		(playerid, RadioUI_Mode[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, RadioUI_Mode[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, RadioUI_Mode[playerid], 1);
	PlayerTextDrawUseBox			(playerid, RadioUI_Mode[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, RadioUI_Mode[playerid], 255);
	PlayerTextDrawTextSize			(playerid, RadioUI_Mode[playerid], 20.000000, 30.000000);
	PlayerTextDrawSetSelectable		(playerid, RadioUI_Mode[playerid], true);

	RadioUI_Freq[playerid]					= CreatePlayerTextDraw(playerid, 320.000000, 251.000000, "Frequencia: 00.00");
	PlayerTextDrawAlignment			(playerid, RadioUI_Freq[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, RadioUI_Freq[playerid], 255);
	PlayerTextDrawFont				(playerid, RadioUI_Freq[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, RadioUI_Freq[playerid], 0.300000, 1.499999);
	PlayerTextDrawColor				(playerid, RadioUI_Freq[playerid], 16777215);
	PlayerTextDrawSetOutline		(playerid, RadioUI_Freq[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, RadioUI_Freq[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, RadioUI_Freq[playerid], 1);
	PlayerTextDrawUseBox			(playerid, RadioUI_Freq[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, RadioUI_Freq[playerid], 255);
	PlayerTextDrawTextSize			(playerid, RadioUI_Freq[playerid], 20.000000, 120.000000);
	PlayerTextDrawSetSelectable		(playerid, RadioUI_Freq[playerid], true);

	RadioUI_Power[playerid]					= CreatePlayerTextDraw(playerid, 402.000000, 251.000000, "off");
	PlayerTextDrawAlignment			(playerid, RadioUI_Power[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, RadioUI_Power[playerid], 255);
	PlayerTextDrawFont				(playerid, RadioUI_Power[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, RadioUI_Power[playerid], 0.400000, 1.499999);
	PlayerTextDrawColor				(playerid, RadioUI_Power[playerid], -16776961);
	PlayerTextDrawSetOutline		(playerid, RadioUI_Power[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, RadioUI_Power[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, RadioUI_Power[playerid], 1);
	PlayerTextDrawUseBox			(playerid, RadioUI_Power[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, RadioUI_Power[playerid], 255);
	PlayerTextDrawTextSize			(playerid, RadioUI_Power[playerid], 20.000000, 30.000000);
	PlayerTextDrawSetSelectable		(playerid, RadioUI_Power[playerid], true);

	RadioUI_Back[playerid]					= CreatePlayerTextDraw(playerid, 320.000000, 274.000000, "Fechar");
	PlayerTextDrawAlignment			(playerid, RadioUI_Back[playerid], 2);
	PlayerTextDrawBackgroundColor	(playerid, RadioUI_Back[playerid], 255);
	PlayerTextDrawFont				(playerid, RadioUI_Back[playerid], 1);
	PlayerTextDrawLetterSize		(playerid, RadioUI_Back[playerid], 0.300000, 1.499999);
	PlayerTextDrawColor				(playerid, RadioUI_Back[playerid], -1);
	PlayerTextDrawSetOutline		(playerid, RadioUI_Back[playerid], 0);
	PlayerTextDrawSetProportional	(playerid, RadioUI_Back[playerid], 1);
	PlayerTextDrawSetShadow			(playerid, RadioUI_Back[playerid], 1);
	PlayerTextDrawUseBox			(playerid, RadioUI_Back[playerid], 1);
	PlayerTextDrawBoxColor			(playerid, RadioUI_Back[playerid], 100);
	PlayerTextDrawTextSize			(playerid, RadioUI_Back[playerid], 20.000000, 200.000000);
	PlayerTextDrawSetSelectable		(playerid, RadioUI_Back[playerid], true);

	rad_ViewingRadio[playerid] = 0;
}