#include <YSI\y_hooks>

#define MAX_TRASH   (64)

static Float:Trash_Pos[MAX_TRASH][3] =
{
// 1372
	{776.828002, 	1866.160034, 	3.890630},
	{1336.339965, 	-1842.849975, 	12.664097},
	{1336.790039, 	-1816.300048, 	12.664097},
	{1466.949951, 	-1847.839965, 	12.664097},
	{1419.729980, 	-1846.550048, 	12.664097},
	{1419.699951, 	-1844.199951, 	12.664097},
	{1486.209960, 	-1848.130004, 	12.664097},
	{1468.060058, 	-1847.790039, 	12.664097},
	{1516.689941, 	-1850.050048, 	12.664097},
	{1337.699951, 	-1774.729980, 	12.664097},
	{1461.430053, 	-1489.219970, 	12.679697},
	{1538.949951, 	-1849.270019, 	12.664097},
	{1534.930053, 	-1480.989990, 	8.609377},
	{1537.930053, 	-1480.609985, 	8.609377},
	{1920.050048, 	-2122.409912, 	12.687500},
	{1920.479980, 	-2088.169921, 	12.687500},
	{-827.265991, 	498.195007, 	1357.770019},
	{-829.031005, 	498.195007, 	1357.589965},
	{1427.180053, 	1905.260009, 	9.945307},
	{1446.099975,	1917.589965, 	9.945307},
	{1666.579956, 	2034.530029, 	9.945307},
	{1666.579956, 	2056.000000, 	9.945307},
	{1659.099975, 	2084.479980, 	9.945307},
	{1666.579956, 	2109.219970, 	9.945307},
	{1659.099975, 	2124.229980, 	9.945307},
	{1659.099975, 	2159.110107, 	9.945307},
	{1659.099975, 	2161.600097, 	9.945307},
	{1066.660034, 	1997.050048, 	9.945307},
	{1577.589965, 	2161.149902, 	10.210900},
	{1577.589965, 	2119.100097, 	10.210900},
	{1577.589965, 	2091.540039, 	10.210900},

// 1334
	{-2174.860107, 	-2365.270019, 	30.796899},
	{-2136.500000, 	-2263.899902, 	30.726600},
	{ -2138.659912, -2262.199951, 	30.726600},
	{-2107.209960, 	-2423.889892, 	30.796899},
	{-2087.199951, 	-2343.100097, 	30.796899},
	{1346.270019, 	1064.079956, 	10.929697},
	{1341.349975, 	1064.079956, 	10.929697},
	{1338.800048, 	1164.160034, 	10.929697},
	{1632.020019, 	663.984008, 	10.929697},
	{1634.680053, 	663.984008, 	10.929697},
	{1635.979980, 	892.210998, 	10.929697},
	{1756.579956, 	691.164001, 	10.929697},
	{1756.579956, 	688.625000, 	10.929697},
	{1518.250000, 	971.460998, 	10.929697},
	{1518.250000, 	979.765991, 	10.929697},
	{1557.739990, 	968.312988, 	10.929697},
	{1598.630004, 	1060.660034, 	10.929697},
	{1603.010009, 	1060.660034, 	10.929697},
	{1668.050048, 	911.796997, 	10.929697},
	{1732.739990, 	967.835998, 	10.929697},
	{1745.359985, 	1049.390014, 	10.929697},
	{1680.050048, 	1168.270019, 	10.929697},
	{1680.050048, 	1164.160034, 	10.929697},
	{1734.260009, 	1249.050048, 	10.929697},

//1331
	{-2136.550048, 	-2450.590087, 	30.554700},
	{1004.809997, 	1068.069946, 	10.625000},
    {1002.559997, 	1068.069946, 	10.625000},
    {1339.079956, 	1064.079956, 	10.625000},
    {1303.219970, 	1102.719970, 	10.625000},
    {1478.130004, 	963.562988, 	10.625000},
    {1478.130004, 	967.070007, 	10.625000},
    {1557.660034, 	970.562988, 	10.625000},
    {1464.219970, 	1081.739990, 	10.625000}
};

static
	Trash_Button[MAX_TRASH],
	disable_Trash[MAX_TRASH],
	Player_Trash[MAX_PLAYERS];

hook OnGameModeInit()
{
    for(new i = 0; i < MAX_TRASH; i++)
	{
        Trash_Button[i] = CreateButton(Trash_Pos[i][0], Trash_Pos[i][1], Trash_Pos[i][2] + 0.5,
			"Pressione F para examinar a lixeira", 0, 0, 2.1, 1, "Lixeira", .testlos = false);

        disable_Trash[Trash_Button[i]] = 0;
	}
}

hook OnPlayerConnect(playerid)
{
    Player_Trash[playerid] = -1;
}


hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(oldkeys & 16)
	{
	    if(Player_Trash[playerid] != -1)
		{
			StopHoldAction(playerid);
			ClearAnimations(playerid);
			Player_Trash[playerid] = -1;
		}
	}
}

hook OnButtonPress(playerid, buttonid)
{
    for(new i = 0; i < MAX_TRASH; i++){
		if(buttonid == Trash_Button[i]){
		    if(disable_Trash[Trash_Button[i]])
			{
		        ShowActionText(playerid, "~r~Nada encontrado.");
				break;
		    }
		    StartHoldAction(playerid, 5000);
			ApplyAnimation(playerid, "BOMBER", "BOM_Plant_Loop", 4.0, 1, 0, 0, 0, 0);
			Player_Trash[playerid] = Trash_Button[i];
			PlayerPlaySound(playerid,1131,0.0,0.0,0.0);
			break;
		}
	}
	return Y_HOOKS_BREAK_RETURN_1;
}

hook OnHoldActionUpdate(playerid, progress)
{
    if(Player_Trash[playerid] != -1)
	{
	    ShowActionText(playerid, "Revistando Lixo...");

		if(random(6) == 1)
	    	PlayerPlaySound(playerid, 1131, 0.0, 0.0, 0.0);
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

hook OnHoldActionFinish(playerid)
{
	if(Player_Trash[playerid] != -1)
	{
	    if(disable_Trash[Player_Trash[playerid]])
		{
	        ShowActionText(playerid, "~r~Nada encontrado.");
	    }
	    else
	    {
			new
				Float:x,
				Float:y,
				Float:z;

			GetPlayerPos(playerid, x, y, z);

		    CreateStaticLootSpawn(x, y, z - FLOOR_OFFSET, GetLootIndexFromName("world_civilian"), 30, 4);
	    }

	    ClearAnimations(playerid);
	    Player_Trash[playerid] = -1;
	    disable_Trash[Player_Trash[playerid]] = 1;
	    
	}
	return Y_HOOKS_CONTINUE_RETURN_0;
}

