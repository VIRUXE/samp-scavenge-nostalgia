#include <YSI\y_hooks>


static note_CurrentItem[MAX_PLAYERS] = {INVALID_ITEM_ID, ...};


hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "Note"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("Note"), 256);
}

hook OnPlayerUseItem(playerid, itemid)
{


	if(GetItemType(itemid) == item_Note)
	{
		_ShowNoteDialog(playerid, itemid);
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

_ShowNoteDialog(playerid, itemid)
{
	new string[256];

	GetItemArrayData(itemid, string);
	note_CurrentItem[playerid] = itemid;

	if(strlen(string))
		Dialog_Show(playerid, Note, DIALOG_STYLE_MSGBOX, "Papel", string, "Fechar", "Rasgar");

	else
		Dialog_Show(playerid, NoteSet, DIALOG_STYLE_INPUT, "Papel", "Write a message onto the note:", "Fechar", "Cancelar");

	return 1;
}

Dialog:Note(playerid, response, listitem, inputtext[])
{
	if(!response)
	{
		DestroyItem(note_CurrentItem[playerid]);
		note_CurrentItem[playerid] = INVALID_ITEM_ID;
	}
}

Dialog:NoteSet(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		SetItemArrayData(note_CurrentItem[playerid], inputtext, strlen(inputtext));
		note_CurrentItem[playerid] = INVALID_ITEM_ID;
	}
}

hook OnItemNameRender(itemid, ItemType:itemtype)
{


	if(itemtype == item_Note)
	{
		new
			string[256],
			len;

		GetItemArrayData(itemid, string);
		len = strlen(string);

		if(len == 0) {
			SetItemNameExtra(itemid, "Vazio");
		}
		else if(len > 8)
		{
			strins(string, "(...)", 8);
			string[13] = EOS;

			SetItemNameExtra(itemid, string);
		}
	}
}
