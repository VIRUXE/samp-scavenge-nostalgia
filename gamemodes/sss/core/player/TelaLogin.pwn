forward SetPlayerInCenario(playerid);
public SetPlayerInCenario(playerid) {
    new Float:scenarios[][3][3] = {
        // SetPlayerCameraPos, SetPlayerCameraLookAt, SetPlayerPos
        {{-4402.01, 438.92, 19.86}, {-4407.65, 440.87, 19.31}, {-4407.65, 440.87, 19.31}}, // Ilha de San Fierro
        {{1568.44, -1618.81, 18.85}, {1573.13, -1622.37, 17.68}, {1573.13, -1622.37, 17.68}}, // DP Los Santos
        {{2476.43, -2245.37, 39.12}, {2477.57, -2251.09, 37.70}, {2477.57, -2251.09, 37.70}}, // Ponte das Docas
        {{-1993.59, 137.42, 33.33}, {-1993.59, 137.42, 33.33}, {-1993.59, 137.42, 33.33}}, // Posto de Gasolina CJ
        {{-2698.83, 2089.62, 62.80}, {-2698.83, 2089.62, 62.80}, {-2698.83, 2089.62, 62.80}}, // Ponte Bayside
        {{-2298.30, 2673.60, 56.99}, {-2298.30, 2673.60, 56.99}, {-2298.30, 2673.60, 56.99}}, // Ponte Bayside 2
        {{-1517.24, 2531.51, 56.33}, {-1517.24, 2531.51, 56.33}, {-1517.24, 2531.51, 56.33}} // Hospital de East Los Santos


    };
    RandomLoginSound(playerid);
    SetPlayerTime(playerid, 0, 0);
    SetPlayerWeather(playerid, 20);
  
    new scenario = random(sizeof(scenarios) - 1);
    SetPlayerCameraPos(playerid, scenarios[scenario][0][0], scenarios[scenario][0][1], scenarios[scenario][0][2]);
    SetPlayerCameraLookAt(playerid, scenarios[scenario][1][0], scenarios[scenario][1][1], scenarios[scenario][1][2]);
    SetPlayerPos(playerid, scenarios[scenario][2][0], scenarios[scenario][2][1], scenarios[scenario][2][2]);

    return 1;
}

RandomLoginSound(playerid){
    new sounds[][] = {
        "uw3jdo6s0u9urgu/NS.mp3",
        "b0yozgytqbvqhch/NS2.mp3",
        "3d2s9x1ay0jgefq/NS3.mp3",
        "eh9w2adw0vp2yvd/NS4.mp3",
        "m0ub0mve3q8m0wi/NS5.mp3"
    };

    new soundURL[1 + 36 + 23]; // 1 for null terminator, 36 for "https://dl.dropboxusercontent.com/s/", and 23 for the longest sound name
    format(soundURL, sizeof(soundURL), "https://dl.dropboxusercontent.com/s/%s", sounds[random(sizeof(sounds) - 1)]);

    PlayAudioStreamForPlayer(playerid, soundURL);
}
