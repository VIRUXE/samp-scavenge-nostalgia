/*==============================================================================


	Southclaws' Scavenge and Survive

		Copyright (C) 2017 Barnaby "Southclaws" Keene

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


==============================================================================*/#include <YSI\y_hooks>
#include <YSI\y_va>

#define ALL_TAGS _,Float,Timer,ItemType


#define MAX_LOG_HANDLER				(128)
#define MAX_LOG_HANDLER_NAME		(32)


enum
{
	NONE2,
	CORE,
	DEEP,
	LOOP
}

enum e_DEBUG_HANDLER
{
	log_name[MAX_LOG_HANDLER_NAME],
	log_level
}

static
		log_Table[MAX_LOG_HANDLER][e_DEBUG_HANDLER],
		log_Total;


stock log(text[], {ALL_TAGS}:...)
{
	new buffer[256];
	formatex(buffer, sizeof(buffer), text, ___(1));
	print(buffer);
}

stock dbg(handler[], level, text[], {ALL_TAGS}:...)
{
	new
		idx = _debug_get_handler_index(handler),
		bt[412];
	
	if(idx == -1) {
		return;
	}

	if(!GetBacktrace(bt)) {
		print("ERROR GETTING BACKTRACE");
	}

	// todo: strip bt down to just the file it originated from

	if(level > log_Table[idx][log_level]) {
		return;
	}

	new buffer[256];
	formatex(buffer, sizeof(buffer), text, ___(3));
	print(buffer);
}

stock err(text[], {ALL_TAGS}:...)
{
	new buffer[256];
	formatex(buffer, sizeof(buffer), text, ___(1));
	print(buffer);
	PrintAmxBacktrace();
}

stock fatal(text[], {ALL_TAGS}:...)
{
	new buffer[256];
	formatex(buffer, sizeof(buffer), text, ___(1));
	print(buffer);
	PrintAmxBacktrace();

	// trigger a crash to escape the gamemode
	new File:f = fopen("nonexistentfile", io_read), _s[1];
	fread(f, _s);
	fclose(f);
}


/*==============================================================================

	Internal/utility

==============================================================================*/


_debug_get_handler_index(handler[])
{
	for(new i; i < log_Total; ++i)
	{
		if(!strcmp(handler, log_Table[i][log_name]))
			return i;
	}

	return -1;
}

stock debug_set_level(handler[], level)
{
	new idx = _debug_get_handler_index(handler);

	if(idx == -1)
	{
		log_Table[log_Total][log_level] = level;
		log_Total++;
	}
	else
	{
		log_Table[idx][log_level] = level;
	}

	return 1;
}

stock debug_conditional(handler[], level)
{
	new idx = _debug_get_handler_index(handler);

	if(idx != -1)
		return log_Table[idx][log_level] >= level;

	return 0;
}
