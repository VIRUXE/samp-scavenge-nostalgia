//#include <YSI\y_hooks>

forward SetPlayerInCenario(playerid);
public SetPlayerInCenario(playerid)
{  
    ChatMsg(playerid, RED, " > Você foi setado em um cenário.");
    
    new camerapos = random(7);
    switch(camerapos){
        case 0:{
            //---------- ilha-sf ----------
            SetPlayerPos(playerid, -4407.65, 440.87, 19.31);
            SetPlayerCameraPos(playerid, -4402.01, 438.92, 19.86);
            SetPlayerCameraLookAt(playerid, -4407.65, 440.87, 19.31);
        }case 1:{
            //---------- dp-ls ----------
            SetPlayerPos(playerid, 1573.13, -1622.37, 17.68);
            SetPlayerCameraPos(playerid, 1568.44, -1618.81, 18.85);
            SetPlayerCameraLookAt(playerid, 1573.13, -1622.37, 17.68);
        }case 2:{
            //---------- ponte-docas ----------
            SetPlayerPos(playerid, 2477.57, -2251.09, 37.70);
            SetPlayerCameraPos(playerid, 2476.43, -2245.37, 39.12);
            SetPlayerCameraLookAt(playerid, 2477.57, -2251.09, 37.70);
        }case 3:{
            //---------- posto-cj ----------
            SetPlayerPos(playerid, -1993.59, 137.42, 33.33);
            SetPlayerCameraPos(playerid, -1988.27, 134.76, 34.10);
            SetPlayerCameraLookAt(playerid, -1993.59, 137.42, 33.33);
        }case 4:{
            //---------- ponte-bayside ----------
            SetPlayerPos(playerid, -2698.83, 2089.62, 62.80);
            SetPlayerCameraPos(playerid, -2702.09, 2084.70, 63.86);
            SetPlayerCameraLookAt(playerid, -2698.83, 2089.62, 62.80);
        }case 5:{
            //---------- ponte-bayside2 ----------
            SetPlayerPos(playerid, -2298.30, 2673.60, 56.99);
            SetPlayerCameraPos(playerid, -2303.76, 2676.05, 57.35);
            SetPlayerCameraLookAt(playerid, -2298.30, 2673.60, 56.99);
        }case 6:{
            //---------- hp-eq ----------
            SetPlayerPos(playerid, -1517.24, 2531.51, 56.33);
            SetPlayerCameraPos(playerid, -1519.95, 2536.79, 57.15);
            SetPlayerCameraLookAt(playerid, -1517.24, 2531.51, 56.33);
        }
    }

    new musicalogin = random(2);
	switch(musicalogin){
        case 0: PlayAudioStreamForPlayer(playerid, "https://dl.dropboxusercontent.com/s/uw3jdo6s0u9urgu/NS.mp3");
        case 1: PlayAudioStreamForPlayer(playerid, "http://dl.dropboxusercontent.com/s/b0yozgytqbvqhch/TWD2.mp3");
    }
    return 1;
}