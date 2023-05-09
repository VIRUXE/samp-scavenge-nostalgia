#include <YSI\y_hooks>

static
		autosave_Block[ITM_MAX],
		autosave_Max,
bool:	autosave_Active;


hook OnScriptInit() {
	defer AutoSave();
}

timer AutoSave[MIN(1) + SEC(10)]() {
	new const players = Iter_Count(Player);

	printf("[AUTO-SAVE] Players %d", players);
	
	if(Iter_Count(Player) == 0) {
		defer AutoSave();
		return;
	}

	if(gServerUptime > gServerMaxUptime - 40) return; // don't save during shutdown

	AutoSave_Player();

	return;
}

AutoSave_Player() {
	new idx;

	foreach(new i : Player) {
		autosave_Block[idx] = i;
		idx++;
	}
	autosave_Max = idx;

	defer Player_BlockSaveTime(0);
}

timer Player_BlockSaveTime[300](index) {
	autosave_Active = true;

	if(gServerUptime > gServerMaxUptime - 40) return;

	new i;

	for(i = index; i < index + 1 && i < autosave_Max; i++) {
		if(!IsPlayerConnected(autosave_Block[i])) continue;

		SavePlayerData(autosave_Block[i]);
	}

	if(i < autosave_Max)
		defer Player_BlockSaveTime(i);
	else
		defer AutoSave();

	autosave_Active = false;

	return;
}

stock IsAutoSaving() return autosave_Active;