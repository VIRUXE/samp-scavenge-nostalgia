/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

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


==============================================================================*/


#include <YSI\y_hooks>

Load_TR()
{
    print("\n[OnGameModeInit] Initialising 'World/TR'...");
	CreateFuelOutlet(-1465.4766, 1868.2734, 32.8203, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(-1464.9375, 1860.5625, 32.8203, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(-1477.8516, 1867.3125, 32.8203, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(-1477.6563, 1859.7344, 32.8203, 2.0, 100.0, frandom(40.0));

	CreateFuelOutlet(-1327.0313, 2685.5938, 50.4531, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(-1327.7969, 2680.1250, 50.4531, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(-1328.5859, 2674.7109, 50.4531, 2.0, 100.0, frandom(40.0));
	CreateFuelOutlet(-1329.2031, 2669.2813, 50.4531, 2.0, 100.0, frandom(40.0));

	TR_District_Bayside();
	//SendRconCommand("hostname Scavenge And Survive - Apocalypse (Respawn 70%)");
	TR_District_Quebrados();
	//SendRconCommand("hostname Scavenge And Survive - Apocalypse (Respawn 79%)");
	TR_District_Barancas();
	//SendRconCommand("hostname Scavenge And Survive - Apocalypse (Respawn 88%)");
	TR_District_Sherman();
	//SendRconCommand("hostname Scavenge And Survive - Apocalypse (Respawn 95%)");
	TR_District_RobadaGen();
	//SendRconCommand("hostname Scavenge And Survive - Apocalypse (Respawn 99%)");

	DefineSupplyDropPos("Tierra Robada South", -720.72766, 972.52899, 11.04721);
	DefineSupplyDropPos("Tierra Robada Midland", -1484.86084, 1977.28833, 46.76990);
	DefineSupplyDropPos("Tierra Robada North Freeway", -2547.67798, 2614.91919, 59.90747);
}


TR_District_Bayside()
{
	ChatMsgAll(LBLUE, " >  Carregando regi�o do mundo: {FF8A14}'TR_District_Bayside' {1589FF}por favor, aguarde...");

	CreateStaticLootSpawn(-2560.33521, 2256.71069, 4.03032,		world_civilian, 20.0);
	CreateStaticLootSpawn(-2526.42236, 2230.25171, 3.97745,		world_civilian, 20.0);
	CreateStaticLootSpawn(-2524.90869, 2241.80249, 3.97117,		world_civilian, 20.0);
	CreateStaticLootSpawn(-2582.55981, 2307.26733, 5.99649,		world_civilian, 20.0);
	CreateStaticLootSpawn(-2619.74927, 2249.61157, 7.15421,		world_civilian, 20.0);
	CreateStaticLootSpawn(-2637.86987, 2334.30200, 7.49702,		world_civilian, 20.0);
	CreateStaticLootSpawn(-2598.33618, 2357.89038, 8.88010,		world_civilian, 20.0);
	CreateStaticLootSpawn(-2490.16113, 2358.32104, 9.10369,		world_civilian, 20.0);
	CreateStaticLootSpawn(-2479.32104, 2488.71387, 17.21367,	world_civilian, 20.0);
	CreateStaticLootSpawn(-2446.46899, 2513.36792, 14.67988,	world_civilian, 20.0);
	CreateStaticLootSpawn(-2462.86694, 2496.75024, 15.72379,	world_civilian, 20.0);
	CreateStaticLootSpawn(-2474.64990, 2449.87598, 16.31130,	world_civilian, 20.0);
	CreateStaticLootSpawn(-2469.29956, 2407.16528, 15.65823,	world_civilian, 20.0);
	CreateStaticLootSpawn(-2385.05615, 2441.33569, 8.35205,		world_civilian, 20.0);
	CreateStaticLootSpawn(-2333.02271, 2431.87329, 6.29611,		world_civilian, 20.0);
	CreateStaticLootSpawn(-2398.78931, 2404.83374, 7.91520,		world_civilian, 20.0);
	CreateStaticLootSpawn(-2423.01440, 2401.30200, 12.09972,	world_civilian, 20.0);
	CreateStaticLootSpawn(-2435.82764, 2350.67480, 3.95540,		world_civilian, 20.0);
	CreateStaticLootSpawn(-2187.87866, 2413.00732, 4.15637,		world_civilian, 20.0);

	CreateStaticLootSpawn(-2560.33521, 2256.71069, 4.03032,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2526.42236, 2230.25171, 3.97745,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2524.90869, 2241.80249, 3.97117,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2582.55981, 2307.26733, 5.99649,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2619.74927, 2249.61157, 7.15421,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2637.86987, 2334.30200, 7.49702,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2598.33618, 2357.89038, 8.88010,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2490.16113, 2358.32104, 9.10369,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2479.32104, 2488.71387, 17.21367,	world_industrial, 15.0);
	CreateStaticLootSpawn(-2446.46899, 2513.36792, 14.67988,	world_industrial, 15.0);
	CreateStaticLootSpawn(-2462.86694, 2496.75024, 15.72379,	world_industrial, 15.0);
	CreateStaticLootSpawn(-2474.64990, 2449.87598, 16.31130,	world_industrial, 15.0);
	CreateStaticLootSpawn(-2469.29956, 2407.16528, 15.65823,	world_industrial, 15.0);
	CreateStaticLootSpawn(-2385.05615, 2441.33569, 8.35205,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2333.02271, 2431.87329, 6.29611,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2398.78931, 2404.83374, 7.91520,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2423.01440, 2401.30200, 12.09972,	world_industrial, 15.0);
	CreateStaticLootSpawn(-2435.82764, 2350.67480, 3.95540,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2187.87866, 2413.00732, 4.15637,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2374.43481, 2216.36084, 3.96434,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2335.72559, 2298.06445, 3.96524,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2329.73682, 2315.89258, 2.47632,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2293.67725, 2232.15454, 3.97610,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2183.48145, 2418.57642, 3.96865,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2231.77466, 2400.19141, 1.47613,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2225.93579, 2393.84985, 1.46124,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2252.31836, 2420.18164, 1.47137,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2259.45630, 2428.16235, 1.45578,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2238.82446, 2447.77100, 1.46378,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2233.08887, 2440.96143, 1.47163,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2211.37817, 2420.07837, 1.47727,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2205.59912, 2413.41846, 1.46828,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2240.18384, 2466.76416, 3.95956,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2274.50879, 2431.53979, 3.95307,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2245.76953, 2372.29297, 3.96713,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2341.27051, 2476.00000, 3.96448,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2398.41309, 2356.26733, 3.95593,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2450.41357, 2304.93896, 3.97062,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2482.99463, 2291.23755, 3.95833,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2521.22607, 2293.64429, 3.96985,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2505.22485, 2367.41650, 3.96825,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2529.43018, 2353.90942, 3.97955,		world_industrial, 15.0);
	CreateStaticLootSpawn(-2463.07837, 2518.56689, 15.80178,	world_industrial, 15.0);

	CreateStaticLootSpawn(-2481.05078, 2282.49438, 18.11488,	world_survivor, 10.0);
	CreateStaticLootSpawn(-2499.54834, 2302.89990, 14.58998,	world_survivor, 10.0);
	CreateStaticLootSpawn(-2481.34180, 2316.34912, 15.03521,	world_survivor, 10.0);
	CreateStaticLootSpawn(-2522.76611, 2305.10547, 12.49624,	world_survivor, 10.0);
	CreateStaticLootSpawn(-2538.14404, 2303.83374, 12.49173,	world_survivor, 10.0);
}


TR_District_Quebrados()
{
	ChatMsgAll(LBLUE, " >  Carregando regi�o do mundo: {FF8A14}'TR_District_Quebrados' {1589FF}por favor, aguarde...");

	CreateStaticLootSpawn(-1603.15735, 2690.23340, 54.28019,	world_civilian, 20.0);
	CreateStaticLootSpawn(-1589.21973, 2705.65381, 55.16963,	world_civilian, 20.0);
	CreateStaticLootSpawn(-1562.90332, 2707.99878, 54.82388,	world_civilian, 20.0);
	CreateStaticLootSpawn(-1509.67725, 2697.67822, 54.82032,	world_civilian, 20.0);
	CreateStaticLootSpawn(-1482.62170, 2701.84888, 55.23552,	world_civilian, 20.0);
	CreateStaticLootSpawn(-1451.30042, 2690.63232, 55.16674,	world_civilian, 20.0);
	CreateStaticLootSpawn(-1446.15125, 2587.79541, 54.82346,	world_civilian, 20.0);
	CreateStaticLootSpawn(-1474.97388, 2562.43823, 55.16697,	world_civilian, 20.0);
	CreateStaticLootSpawn(-1479.32251, 2546.72485, 55.24495,	world_civilian, 20.0);
	CreateStaticLootSpawn(-1566.24890, 2647.57861, 54.82233,	world_civilian, 20.0);
	CreateStaticLootSpawn(-1573.01965, 2629.06665, 54.83292,	world_civilian, 20.0);
	CreateStaticLootSpawn(-1670.04419, 2589.70435, 80.35351,	world_civilian, 20.0);
	CreateStaticLootSpawn(-1662.05762, 2551.03271, 84.27365,	world_civilian, 20.0);
	CreateStaticLootSpawn(-1670.20569, 2553.19775, 84.30128,	world_civilian, 20.0);
	CreateStaticLootSpawn(-1666.45190, 2481.40820, 86.18620,	world_civilian, 20.0);

	CreateStaticLootSpawn(-1514.99573, 2568.54224, 54.82280,	world_industrial, 15.0);
	CreateStaticLootSpawn(-1515.25476, 2578.12085, 54.82317,	world_industrial, 15.0);
	CreateStaticLootSpawn(-1471.75647, 2621.21387, 57.75673,	world_industrial, 15.0);
	CreateStaticLootSpawn(-1459.71008, 2629.84399, 57.75553,	world_industrial, 15.0);
	CreateStaticLootSpawn(-1478.56006, 2640.58057, 57.77585,	world_industrial, 15.0);
	CreateStaticLootSpawn(-1484.09644, 2615.09448, 57.77431,	world_industrial, 15.0);
	CreateStaticLootSpawn(-1470.46643, 2626.93335, 54.82856,	world_industrial, 15.0);
	CreateStaticLootSpawn(-1456.86731, 2644.52148, 54.83415,	world_industrial, 15.0);
	CreateStaticLootSpawn(-1274.00061, 2723.84473, 49.25645,	world_industrial, 15.0);
	CreateStaticLootSpawn(-1321.17041, 2706.52368, 49.06358,	world_industrial, 15.0);

	CreateStaticLootSpawn(-1390.06812, 2641.60620, 54.98318,	world_police, 10.0);

	CreateStaticLootSpawn(-1514.76123, 2521.80200, 54.83961,	world_medical, 15.0);
	CreateStaticLootSpawn(-1510.41077, 2519.64673, 54.89139,	world_medical, 15.0);
	CreateStaticLootSpawn(-1519.04895, 2519.97070, 54.88930,	world_medical, 15.0);
	CreateStaticLootSpawn(-1500.28870, 2528.68286, 54.66892,	world_medical, 15.0);
	CreateStaticLootSpawn(-1528.54492, 2523.11426, 54.79468,	world_medical, 15.0);

	CreateStaticLootSpawn(-1504.42444, 2625.95996, 54.82740,	world_survivor, 10.0);
	CreateStaticLootSpawn(-1509.39148, 2612.84082, 58.56698,	world_survivor, 10.0);
	CreateStaticLootSpawn(-1444.17346, 2616.59082, 60.03917,	world_survivor, 10.0);
	CreateStaticLootSpawn(-1510.69812, 2585.29736, 60.02413,	world_survivor, 10.0);

}

TR_District_Barancas()
{
	ChatMsgAll(LBLUE, " >  Carregando regi�o do mundo: {FF8A14}'TR_District_Barancas' {1589FF}por favor, aguarde...");

	CreateStaticLootSpawn(-637.60626, 1442.92505, 12.60786,		world_civilian, 20.0);
	CreateStaticLootSpawn(-654.76465, 1446.82837, 12.60757,		world_civilian, 20.0);
	CreateStaticLootSpawn(-716.42871, 1438.43323, 17.88206,		world_civilian, 20.0);
	CreateStaticLootSpawn(-770.97913, 1449.68933, 12.91093,		world_civilian, 20.0);
	CreateStaticLootSpawn(-791.18585, 1423.66284, 12.91914,		world_civilian, 20.0);
	CreateStaticLootSpawn(-827.53320, 1450.50830, 13.01999,		world_civilian, 20.0);
	CreateStaticLootSpawn(-905.66498, 1515.38220, 25.31052,		world_civilian, 20.0);
	CreateStaticLootSpawn(-938.47705, 1425.14172, 29.42587,		world_civilian, 20.0);
	CreateStaticLootSpawn(-1051.02393, 1548.58740, 32.42755,	world_civilian, 20.0);
	CreateStaticLootSpawn(-880.96838, 1546.20618, 24.89556,		world_civilian, 20.0);
	CreateStaticLootSpawn(-857.03998, 1535.93469, 21.58257,		world_civilian, 20.0);
	CreateStaticLootSpawn(-781.17700, 1635.92273, 26.04301,		world_civilian, 20.0);
	CreateStaticLootSpawn(-828.19196, 1502.57104, 18.49405,		world_civilian, 20.0);
	CreateStaticLootSpawn(-748.38422, 1588.45947, 25.95566,		world_civilian, 20.0);

	CreateStaticLootSpawn(-733.56732, 1546.22961, 38.00749,		world_survivor, 10.0);
	CreateStaticLootSpawn(-692.57898, 1549.16516, 81.65029,		world_survivor, 10.0);
}

TR_District_Sherman()
{
	ChatMsgAll(LBLUE, " >  Carregando regi�o do mundo: {FF8A14}'TR_District_Sherman' {1589FF}por favor, aguarde...");

	CreateStaticLootSpawn(-897.95825, 1976.49341, 59.62031,		world_civilian, 20.0);
	CreateStaticLootSpawn(-895.60889, 1967.39795, 59.62622,		world_civilian, 20.0);
	CreateStaticLootSpawn(-939.20490, 2026.91345, 59.88820,		world_civilian, 20.0);
	CreateStaticLootSpawn(-895.34863, 2006.79419, 59.90656,		world_civilian, 20.0);
	CreateStaticLootSpawn(-924.01068, 2003.89404, 59.90224,		world_civilian, 20.0);
	CreateStaticLootSpawn(-794.89850, 2026.19446, 59.37967,		world_civilian, 20.0);
	CreateStaticLootSpawn(-714.41473, 2046.09729, 59.36851,		world_civilian, 20.0);
	CreateStaticLootSpawn(-616.33447, 2026.93787, 59.38301,		world_civilian, 20.0);

	CreateStaticLootSpawn(-821.93060, 1821.88074, 5.98079,		world_industrial, 15.0);
	CreateStaticLootSpawn(-808.59399, 1862.17664, 5.97852,		world_industrial, 15.0);
	CreateStaticLootSpawn(-831.33447, 1975.07141, 5.97241,		world_industrial, 15.0);
	CreateStaticLootSpawn(-592.67542, 1982.13550, 5.99131,		world_industrial, 15.0);
	CreateStaticLootSpawn(-605.13605, 1931.04871, 5.98274,		world_industrial, 15.0);
	CreateStaticLootSpawn(-618.54901, 1881.80627, 5.98871,		world_industrial, 15.0);
	CreateStaticLootSpawn(-609.70947, 1814.44824, 5.98118,		world_industrial, 15.0);
	CreateStaticLootSpawn(-651.29407, 2126.87793, 59.37933,		world_industrial, 15.0);
	CreateStaticLootSpawn(-775.04413, 2089.03101, 59.37369,		world_industrial, 15.0);

	CreateStaticLootSpawn(-832.40436, 2002.49146, 75.97985,		world_survivor, 10.0);
	CreateStaticLootSpawn(-820.91925, 1861.41223, 21.91115,		world_survivor, 10.0);
	CreateStaticLootSpawn(-828.01477, 1910.36804, 21.89612,		world_survivor, 10.0);
	CreateStaticLootSpawn(-840.93866, 1977.09570, 21.87680,		world_survivor, 10.0);
	CreateStaticLootSpawn(-755.40234, 2039.20459, 76.88585,		world_survivor, 10.0);
	CreateStaticLootSpawn(-675.10614, 2043.95508, 76.88017,		world_survivor, 10.0);
	CreateStaticLootSpawn(-597.14282, 2014.70801, 75.97655,		world_survivor, 10.0);
	CreateStaticLootSpawn(-582.33557, 1986.65576, 21.90201,		world_survivor, 10.0);
	CreateStaticLootSpawn(-588.16498, 1940.66040, 21.90247,		world_survivor, 10.0);
	CreateStaticLootSpawn(-601.43585, 1874.48242, 21.90022,		world_survivor, 10.0);
	CreateStaticLootSpawn(-903.92273, 1919.63708, 122.02664,	world_survivor, 10.0);
	CreateStaticLootSpawn(-897.47742, 1870.62500, 116.91568,	world_survivor, 10.0);
	CreateStaticLootSpawn(-837.24481, 2009.47095, 59.17081,		world_survivor, 10.0);
	CreateStaticLootSpawn(-839.95380, 2019.51074, 59.37107,		world_survivor, 10.0);
	CreateStaticLootSpawn(-881.05548, 1998.04822, 59.19070,		world_survivor, 10.0);

}

TR_District_RobadaGen()
{
	ChatMsgAll(LBLUE, " >  Carregando regi�o do mundo: {FF8A14}'TR_District_RobadaGen' {1589FF}por favor, aguarde...");

	CreateItem(item_Workbench, -1513.53040, 1978.50232, 47.35660, 0.0, 0.0, 85.37996);

	CreateStaticLootSpawn(-2084.18799, 2308.36963, 22.98837,	world_civilian, 20.0);
	CreateStaticLootSpawn(-1957.37402, 2391.17017, 48.48126,	world_civilian, 20.0);
	CreateStaticLootSpawn(-1312.63354, 2532.77979, 86.72825,	world_civilian, 20.0);
	CreateStaticLootSpawn(-1289.87146, 2510.56812, 86.01758,	world_civilian, 20.0);
	CreateStaticLootSpawn(-1333.11206, 2527.40259, 86.05123,	world_civilian, 20.0);
	CreateStaticLootSpawn(-1803.35120, 2038.16907, 8.58781,		world_civilian, 20.0);
	CreateStaticLootSpawn(-1830.81348, 2043.56677, 7.56844,		world_civilian, 20.0);
	CreateStaticLootSpawn(-1431.80713, 2173.01807, 49.02753,	world_civilian, 20.0);
	CreateStaticLootSpawn(-1497.36926, 1964.75525, 47.40289,	world_civilian, 20.0);
	CreateStaticLootSpawn(-1220.32092, 1842.07996, 40.61417,	world_civilian, 20.0);
	CreateStaticLootSpawn(-1365.47742, 2057.56055, 51.53279,	world_civilian, 20.0);
	CreateStaticLootSpawn(-692.68323, 928.51282, 12.62511,		world_civilian, 20.0);
	CreateStaticLootSpawn(-685.78192, 939.49304, 12.63766,		world_civilian, 20.0);
	CreateStaticLootSpawn(-683.28857, 942.53912, 15.82795,		world_civilian, 20.0);
	CreateStaticLootSpawn(-665.74475, 877.97656, 0.99825,		world_civilian, 20.0);

	CreateStaticLootSpawn(-1832.72266, 2059.21997, 8.70734,		world_industrial, 15.0);
	CreateStaticLootSpawn(-1512.04004, 1972.73035, 47.41776,	world_industrial, 15.0);
	CreateStaticLootSpawn(-1503.97571, 1978.29919, 47.41971,	world_industrial, 15.0);
	CreateStaticLootSpawn(-1381.84265, 2114.90283, 41.18408,	world_industrial, 15.0);
	CreateStaticLootSpawn(-1374.62378, 2108.19263, 41.18366,	world_industrial, 15.0);
	CreateStaticLootSpawn(-1227.88245, 1834.90979, 40.60062,	world_industrial, 15.0);
	CreateStaticLootSpawn(-672.89850, 961.59961, 11.12390,		world_industrial, 15.0);
	CreateStaticLootSpawn(-689.60468, 970.07257, 11.17480,		world_industrial, 15.0);
	CreateStaticLootSpawn(-657.66016, 879.13013, 0.99663,		world_industrial, 15.0);
	CreateStaticLootSpawn(-666.04785, 939.41364, 11.11209,		world_industrial, 15.0);

	CreateStaticLootSpawn(-2091.51270, 2313.77466, 24.88898,	world_survivor, 10.0);
	CreateStaticLootSpawn(-1314.31531, 2546.07446, 86.72868,	world_survivor, 10.0);
	CreateStaticLootSpawn(-1311.71777, 2512.58179, 86.03461,	world_survivor, 10.0);
	CreateStaticLootSpawn(-1317.55945, 2524.69678, 86.47644,	world_survivor, 10.0);
	CreateStaticLootSpawn(-1290.96448, 2513.11328, 86.03764,	world_survivor, 10.0);
	CreateStaticLootSpawn(-696.70526, 934.70117, 15.82476,		world_survivor, 10.0);
}
