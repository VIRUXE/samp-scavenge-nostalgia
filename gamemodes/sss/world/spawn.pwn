#define MAX_SPAWNS (19)
#define MAX_SPAWNS_VIP (26)

static
	Float:spawn_List[MAX_SPAWNS][4] =
	{
		{-2923.4396,	-70.4305,		0.7973,		269.0305},
		{-2914.9213,	-902.9458,		0.5190,		339.3433},
		{-2804.5021,	-2296.2153,		0.7071,		249.8544},
		{-228.7865,		-1719.8090,		1.1083,		34.9733},
		{-325.7897,		-467.2996,		1.9922,		48.1126},
		{-71.3649,		-577.1849,		1.3816,		351.6495},
		{161.5016,		157.5428,		1.1178,		187.3177},
		{2012.8952,		-38.5986,		1.2391,		4.8748},
		{2117.7065,		183.7778,		1.0822,		74.3911},
		{-1886.1279,	2160.1945,		1.4039,		335.7922},
		{-434.6048,		867.6434,		1.4236,		318.3918},
		{-638.7510,		1286.1458,		1.4520,		110.0257},
	    {174.0262,      -1884.6802,     1.5247,     354.5727},
    	{2940.9158,     -2051.8633,     3.5480,     88.2143},
    	{835.9419,      -1870.6193,     6.4525,     359.4775},
    	{1379.3698,     -283.4602,      1.0509,     194.2455},
        {-2958.2080,    1208.1550,      2.3131,     225.9419},
        {302.0441,      617.5668,       6.4133,     357.2603},
        {2776.3047,     595.1189,       2.2804,     351.4703}
	},
	spawn_Last[MAX_PLAYERS];

// Spawn dos VIPs
static
	Float:spawn_ListVIP[MAX_SPAWNS_VIP][4] = {					   
		{-2923.4396,	-70.4305,		0.7973,		269.0305},
		{-2914.9213,	-902.9458,		0.5190,		339.3433},
		{-2804.5021,	-2296.2153,		0.7071,		249.8544},
		{-228.7865,		-1719.8090,		1.1083,		34.9733},
		{-325.7897,		-467.2996,		1.9922,		48.1126},
		{-71.3649,		-577.1849,		1.3816,		351.6495},
		{161.5016,		157.5428,		1.1178,		187.3177},
		{2012.8952,		-38.5986,		1.2391,		4.8748},
		{2117.7065,		183.7778,		1.0822,		74.3911},
		{-1886.1279,	2160.1945,		1.4039,		335.7922},
		{-434.6048,		867.6434,		1.4236,		318.3918},
		{-638.7510,		1286.1458,		1.4520,		110.0257},
	    {174.0262,      -1884.6802,     1.5247,     354.5727},
    	{2940.9158,     -2051.8633,     3.5480,     88.2143},
    	{835.9419,      -1870.6193,     6.4525,     359.4775},
    	{1379.3698,     -283.4602,      1.0509,     194.2455},
        {-2958.2080,    1208.1550,      2.3131,     225.9419},
        {302.0441,      617.5668,       6.4133,     357.2603},
        {2776.3047,     595.1189,       2.2804,     351.4703},
		{-2134.3933, 	172.5120, 		42.2500, 	309.1142},
    	{2460.6790, 	1434.5192, 		14.9421, 	176.9331},
    	{1359.3881, 	197.3184, 		23.2270, 	66.2469},
        {706.7275, 		-515.5671, 		19.8363, 	94.0321},
        {-731.9795, 	1538.7351, 		40.4195, 	264.8237},
        {-1528.7079, 	2589.3174, 		60.7727, 	295.9770},
		{1777.2689, 	-1369.4200, 	21.0938, 	359.2900}
	},
	spawn_LastVIP[MAX_PLAYERS];

GetUniqueSpawnPoint(playerid, Float:array[][], arraySize, &Float:x, &Float:y, &Float:z, &Float:r, lastSpawn[]) {
    new index = random(arraySize);

    while(index == lastSpawn[playerid]) index = random(arraySize);

    x = array[index][0];
    y = array[index][1];
    z = array[index][2];
    r = array[index][3];

    lastSpawn[playerid] = index;
}

/* GenerateSpawnPoint(playerid, &Float:x, &Float:y, &Float:z, &Float:r) {
    if(GetPlayerVipTier(playerid)) {
        new index = random(sizeof(spawn_ListVIP));

		while(index == spawn_LastVIP[playerid]) index = random(sizeof(spawn_ListVIP));

		x = spawn_ListVIP[index][0];
		y = spawn_ListVIP[index][1];
		z = spawn_ListVIP[index][2];
		r = spawn_ListVIP[index][3];

		spawn_LastVIP[playerid] = index;

    } else {
        new index = random(sizeof(spawn_List));

		while(index == spawn_Last[playerid]) index = random(sizeof(spawn_List));

		x = spawn_List[index][0];
		y = spawn_List[index][1];
		z = spawn_List[index][2];
		r = spawn_List[index][3];

		spawn_Last[playerid] = index;
    }
} */

GenerateSpawnPoint(playerid, &Float:x, &Float:y, &Float:z, &Float:r) {
    new attempts = 0;

    do {
        if(GetPlayerVipTier(playerid))
            GetUniqueSpawnPoint(playerid, spawn_ListVIP, MAX_SPAWNS_VIP, x, y, z, r, spawn_LastVIP);
        else
            GetUniqueSpawnPoint(playerid, spawn_List, MAX_SPAWNS, x, y, z, r, spawn_Last);
        
        attempts++;
        if(attempts > 10) {
            // Too many attempts, pick a random point within the map's boundary
			log("[SPAWN] GenerateSpawnPoint: 10 attempts in radiation.");
            RandomSpawnOutsideRadiation(x, y, z);
            return;
        }
    } while(IsPointInRadiation(x, y));
}

RandomSpawnOutsideRadiation(&Float:x, &Float:y, &Float:z) {
    do {
        x = random_float(-MAP_SIZE, MAP_SIZE);  // Assuming the map is centered around (0,0)
        y = random_float(-MAP_SIZE, MAP_SIZE);
    } while(IsPointInRadiation(x, y));

	CA_FindZ_For2DCoord(x,y, z);
}