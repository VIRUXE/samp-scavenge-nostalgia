enum {
	CMD_INVALID,
	CMD_VALID,
	CMD_CANT_USE,
	CMD_CANT_USE_ON,
	CMD_INVALID_PLAYER,
	CMD_NOT_ADMIN,
	CMD_NOT_DUTY
};

public OnPlayerCommandText(playerid, cmdtext[]) {
	new
		cmd[30],
		params[127],
		cmdfunction[64],
		result = CMD_VALID;

	sscanf(cmdtext, "s[30]s[127]", cmd, params);

	for (new i, j = strlen(cmd); i < j; i++) cmd[i] = tolower(cmd[i]);

	format(cmdfunction, 64, "cmd_%s", cmd[1]); // Format the standard command function name

	if(funcidx(cmdfunction) == -1) { // If it doesn't exist, all hope is not lost! It might be defined as an admin command which has the admin level after the command name
		new
			iLvl  = GetPlayerAdminLevel(playerid),   // The player's admin level
			iLoop = 5;                               // The highest admin level

		while(iLoop > 0) { // Loop backwards through admin levels, from 5 to 1
			format(cmdfunction, 64, "acmd_%s_%d", cmd[1], iLoop); // format the function to include the admin variable

			// if this function exists, break the loop, at this point iLoop can never be worth 0
			if(funcidx(cmdfunction) != -1) break; 

			iLoop--; // otherwise just advance to the next iteration, iLoop can become 0 here and thus break the loop at the next iteration
		}

		// If iLoop was 0 after the loop that means it above completed it's last itteration and never found an existing function

		if(iLoop == 0) result = CMD_INVALID;

		// If the players level was below where the loop found the existing function,
		// that means the number in the function is higher than the player id
		// Give a 'not high enough admin level' error

		if(iLvl < iLoop) result = CMD_NOT_ADMIN;
	}

	if(result == CMD_VALID) result = CallLocalFunction(cmdfunction, "is", playerid, isnull(params) ? "\1" : params);

/*
	Return values for commands.

	Instead of writing these messages on the commands themselves, I can just
	write them here and return different values on the commands.
*/

	// Only log successful commands
	// If a command returns 7, don't log it.

	if(0 < result < 7) log("[COMMAND][%p (%d)]: %s", playerid, playerid, cmdtext);

	if		(result == CMD_INVALID) 		ChatMsg(playerid, ORANGE, "server/command/unknown"); // invalid command
	else if	(result == CMD_VALID) return 1; // valid command, do nothing.
	else if	(result == CMD_CANT_USE) 		ChatMsg(playerid, ORANGE, "server/command/cant-use"); // cant use command
	else if	(result == CMD_CANT_USE_ON) 	ChatMsg(playerid, RED, "server/commandcant-use-player"); // cant use command on that player
	else if	(result == CMD_INVALID_PLAYER) 	ChatMsg(playerid, RED, "server/command/invalid-player"); // invalid player
	else if	(result == CMD_NOT_ADMIN) 		ChatMsg(playerid, RED, "server/command/no-permission"); // not high enough admin level
	else if	(result == CMD_NOT_DUTY) 		ChatMsg(playerid, RED, "server/command/need-duty"); // only usable in duty

	return 1;
}

public OnRconLoginAttempt(ip[], password[], success) {
	if(!success) {
		new ipstring[16];

		log("[RCON] Failed login by %s password: %s", ip, password);

		foreach(new i : Player) {
			GetPlayerIp(i, ipstring, sizeof(ipstring));

			if(!strcmp(ip, ipstring, true))
				ChatMsgAdmins(1, YELLOW, " >  Failed login by %p password: %s", i, password);
		}
	}

	return 1;
}