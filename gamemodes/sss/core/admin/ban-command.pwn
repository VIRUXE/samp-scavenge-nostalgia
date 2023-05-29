#include <YSI\y_hooks>

static
	ban_CurrentName[MAX_PLAYERS][MAX_PLAYER_NAME], // Store the name in case the player quits mid-ban
	ban_CurrentReason[MAX_PLAYERS][MAX_BAN_REASON],
	ban_CurrentDuration[MAX_PLAYERS];

hook OnPlayerConnect(playerid) {
	

	ResetBanVariables(playerid);
}

BanAndEnterInfo(playerid, name[MAX_PLAYER_NAME]) {
	BanPlayerByName(name, "Não informado", playerid, 0);
	FormatBanReasonDialog(playerid);

	ban_CurrentName[playerid] = name;
}

ResetBanVariables(playerid) {
	ban_CurrentName[playerid][0]   = EOS;
	ban_CurrentReason[playerid][0] = EOS;
	ban_CurrentDuration[playerid]  = 0;
}

FormatBanReasonDialog(playerid) {
	Dialog_Show(playerid, BanReason, DIALOG_STYLE_INPUT, "Insira o motivo do banimento", "Digite o motivo do banimento abaixo. O limite de caracteres é 128. ApÃ³s essa tela, Você definirÃ¡ a duração do banimento.", "Continuar", "Cancelar");
}

Dialog:BanReason(playerid, response, listitem, inputtext[]) {
	if(response) {
		ban_CurrentReason[playerid][0] = EOS;
		strcat(ban_CurrentReason[playerid], inputtext);

		FormatBanDurationDialog(playerid);
	} else
		ResetBanVariables(playerid);
}

FormatBanDurationDialog(playerid) {
	Dialog_Show(playerid, BanDuration, DIALOG_STYLE_INPUT, "Insira a duração do banimento", "Enter the ban duration below. You can type a number then one of either: 'days', 'weeks' or 'months'. Type 'forever' for perma-ban.", "Continuar", "Voltar");
}

Dialog:BanDuration(playerid, response, listitem, inputtext[]) {
	if(response) {
		if(!strcmp(inputtext, "forever", true)) {
			ban_CurrentDuration[playerid] = 0;
			FinaliseBan(playerid);
			return 1;
		}

		new duration = GetDurationFromString(inputtext);

		if(duration == -1)
			FormatBanDurationDialog(playerid);
		else {
			ban_CurrentDuration[playerid] = duration;
			FinaliseBan(playerid);
		}
	}
	else
		FormatBanReasonDialog(playerid);

	return 0;
}

FinaliseBan(playerid) {
	if(isnull(ban_CurrentName[playerid])) {
		ChatMsg(playerid, RED, " >  Ocorreu um erro: 'ban_CurrentName' está vazio.");
		return 0;
	}

	if(!UpdateBanInfo(ban_CurrentName[playerid], ban_CurrentReason[playerid], ban_CurrentDuration[playerid])) {
		ChatMsg(playerid, RED, " >  Ocorreu um erro: 'UpdateBanInfo' retornou 0.");
		return 0;
	}

	ChatMsg(playerid, YELLOW, " >  Você baniu "C_BLUE"%s", ban_CurrentName[playerid]);

	log("[BAN] %p baniu %s motivo: %s", playerid, ban_CurrentName[playerid], ban_CurrentReason[playerid]);

	return 1;
}
