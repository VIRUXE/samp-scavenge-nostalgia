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


#define MAX_SIGN_TEXT (128)


static CurrentSignItem[MAX_PLAYERS];


hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "Sign"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("Sign"), MAX_SIGN_TEXT);
}

hook OnItemArrayDataChanged(itemid)
{
	if(GetItemType(itemid) == item_Sign)
	{
		new data[MAX_SIGN_TEXT];
		GetItemArrayData(itemid, data);
		_sign_UpdateText(itemid, data);
	}
}

_sign_UpdateText(itemid, text[])
{
	new objectid = GetItemObjectID(itemid);

	strreplace(text, "\\", "\n", .maxlength = MAX_SIGN_TEXT);
	strcat(text, "\n\n\n", MAX_SIGN_TEXT);

	SetDynamicObjectMaterialText(objectid, 0, text, OBJECT_MATERIAL_SIZE_512x512, "Arial", 72, 1, -16777216, -1, 1);
}

hook OnPlayerUseItem(playerid, itemid)
{
	dbg("global", CORE, "[OnPlayerUseItem] in /gamemodes/sss/core/item/sign.pwn");

	if(GetItemType(itemid) == item_Sign)
	{
		if(IsItemInWorld(itemid))
		{
			CancelPlayerMovement(playerid);
			CurrentSignItem[playerid] = itemid;

			Dialog_Show(playerid, SignEdit, DIALOG_STYLE_INPUT, ls(playerid, "item/sign/sign-title"), ls(playerid, "item/sign/sign-text"), ls(playerid, "common/confirm"), ls(playerid,"common/close"));
		}
	}

	return Y_HOOKS_CONTINUE_RETURN_0;
}

Dialog:SignEdit(playerid, response, listitem, inputtext[])
{
	if(response)
	{
		if(!isnull(inputtext) && IsValidItem(CurrentSignItem[playerid]))
			SetItemArrayData(CurrentSignItem[playerid], inputtext, strlen(inputtext));
	}
}
