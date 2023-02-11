forward SetPlayerInCenario(playerid);
public SetPlayerInCenario(playerid){
    RandomLoginSound(playerid);
    SetPlayerTime(playerid, 0, 0);
    SetPlayerWeather(playerid, 20);
  
    new camerapos = random(7);
    switch(camerapos){
        case 0:{
            //---------- ilha-sf ----------
            SetPlayerCameraPos(playerid, -4402.01, 438.92, 19.86);
            SetPlayerCameraLookAt(playerid, -4407.65, 440.87, 19.31);
            SetPlayerPos(playerid, -4407.65, 440.87, 19.31);
            return 1;
        }case 1:{
            //---------- dp-ls ----------
            SetPlayerCameraPos(playerid, 1568.44, -1618.81, 18.85);
            SetPlayerCameraLookAt(playerid, 1573.13, -1622.37, 17.68);
            SetPlayerPos(playerid, 1573.13, -1622.37, 17.68);
            return 1;
        }case 2:{
            //---------- ponte-docas ----------
            SetPlayerCameraPos(playerid, 2476.43, -2245.37, 39.12);
            SetPlayerCameraLookAt(playerid, 2477.57, -2251.09, 37.70);
            SetPlayerPos(playerid, 2477.57, -2251.09, 37.70);
            return 1;
        }case 3:{
            //---------- posto-cj ----------
            SetPlayerCameraPos(playerid, -1988.27, 134.76, 34.10);
            SetPlayerCameraLookAt(playerid, -1993.59, 137.42, 33.33);
            SetPlayerPos(playerid, -1993.59, 137.42, 33.33);
            return 1;
        }case 4:{
            //---------- ponte-bayside ----------
            SetPlayerCameraPos(playerid, -2702.09, 2084.70, 63.86);
            SetPlayerCameraLookAt(playerid, -2698.83, 2089.62, 62.80);
            SetPlayerPos(playerid, -2698.83, 2089.62, 62.80);
            return 1;
        }case 5:{
            //---------- ponte-bayside2 ----------
            SetPlayerCameraPos(playerid, -2303.76, 2676.05, 57.35);
            SetPlayerCameraLookAt(playerid, -2298.30, 2673.60, 56.99);
            SetPlayerPos(playerid, -2298.30, 2673.60, 56.99);
            return 1;
        }case 6:{
            //---------- hp-eq ----------
            SetPlayerCameraPos(playerid, -1519.95, 2536.79, 57.15);
            SetPlayerCameraLookAt(playerid, -1517.24, 2531.51, 56.33);
            SetPlayerPos(playerid, -1517.24, 2531.51, 56.33);
            return 1;
        }
    }
    return 1;
}

RandomLoginSound(playerid){
    new musicalogin = random(5);
	switch(musicalogin){
        case 0: PlayAudioStreamForPlayer(playerid, "https://dl.dropboxusercontent.com/s/uw3jdo6s0u9urgu/NS.mp3");
        case 1: PlayAudioStreamForPlayer(playerid, "http://dl.dropboxusercontent.com/s/b0yozgytqbvqhch/NS2.mp3");
        case 2: PlayAudioStreamForPlayer(playerid, "https://dl.dropboxusercontent.com/s/3d2s9x1ay0jgefq/NS3.mp3");
        case 3: PlayAudioStreamForPlayer(playerid, "https://dl.dropboxusercontent.com/s/eh9w2adw0vp2yvd/NS4.mp3");
        case 4: PlayAudioStreamForPlayer(playerid, "https://dl.dropboxusercontent.com/s/m0ub0mve3q8m0wi/NS5.mp3");
    }
}
