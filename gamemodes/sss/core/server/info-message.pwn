#include <YSI\y_hooks>

new MsgAuto;

task SendAutoMessage[MIN(5)]() { 
	foreach(new i : Player) ChatMsg(i, GREEN, "%s", ls(i, sprintf("AUTOMSG%d", MsgAuto)));
	    
    MsgAuto++;
	if(MsgAuto >= 7) MsgAuto = 0;
}