#include <YSI\y_hooks>

Load_Novos()
{
    print("\n[OnGameModeInit] Initialising 'World/Novos'...");

	MapasNovos_Ilhas();
	MapasNovos_LS();
	MapasNovos_LV();
	MapasNovos_SF();

//	DefineSupplyDropPos("Tierra Robada South", -720.72766, 972.52899, 11.04721);
}


MapasNovos_Ilhas()
{
	ChatMsgAll(LBLUE, " >  Carregando regi�o do mundo: {FF8A14}'Mapas Novos - Ilhas' {1589FF}por favor, aguarde...");

// ILHA SF

	CreateStaticLootSpawn(-4425.3447, 460.5740,	22.7710 - FLOOR_OFFSET,	 	GetLootIndexFromName("world_military"), 20, 3);
	CreateStaticLootSpawn(-4512.9307, 469.8408,	22.7110 - FLOOR_OFFSET,	 	GetLootIndexFromName("world_military"), 20, 3);
	CreateStaticLootSpawn(-4396.7983, 523.4403,	3.0859 - FLOOR_OFFSET,		GetLootIndexFromName("world_industrial"), 20, 3);
	CreateStaticLootSpawn(-4396.4702, 511.5734,	3.0614 - FLOOR_OFFSET, 		GetLootIndexFromName("world_industrial"), 20, 3);
	CreateStaticLootSpawn(-4369.2139, 507.5604,3.0642 - FLOOR_OFFSET, 		GetLootIndexFromName("world_industrial"), 20, 3);
	CreateStaticLootSpawn(-4368.4800, 521.0472, 3.0918 - FLOOR_OFFSET, 		GetLootIndexFromName("world_industrial"), 20, 3);
	CreateStaticLootSpawn(-4465.1074, 436.9501, 10.8027 - FLOOR_OFFSET, 	GetLootIndexFromName("world_industrial"), 20, 3);
	CreateStaticLootSpawn(-4410.8540, 442.5615, 10.8520 - FLOOR_OFFSET,	 	GetLootIndexFromName("world_industrial"), 20, 3);
	CreateStaticLootSpawn(-4354.0732, 493.8794, 5.7737 - FLOOR_OFFSET,		GetLootIndexFromName("world_civilian"), 20, 3);
	CreateStaticLootSpawn(-4354.2578, 498.4086, 5.7437 - FLOOR_OFFSET, 		GetLootIndexFromName("world_civilian"), 20, 3);
	CreateStaticLootSpawn(-4502.8062, 536.3905, 2.6462 - FLOOR_OFFSET, 		GetLootIndexFromName("world_civilian"), 20, 3);
	CreateStaticLootSpawn(-4548.1973, 528.2358, 10.7196 - FLOOR_OFFSET,	 	GetLootIndexFromName("world_civilian"), 20, 3);
	CreateStaticLootSpawn(-4541.3320, 526.2934, 10.7196 - FLOOR_OFFSET,		GetLootIndexFromName("world_civilian"), 20, 3);
	CreateStaticLootSpawn(-4409.5850, 442.3405, 18.2439 - FLOOR_OFFSET,		GetLootIndexFromName("world_survivor"), 20, 3);
	CreateStaticLootSpawn(-4410.8896, 440.9623, 14.1439 - FLOOR_OFFSET,		GetLootIndexFromName("world_survivor"), 20, 3);

// ILHA LV

	CreateStaticLootSpawn(258.2236 ,4292.7227, 7.3132 - FLOOR_OFFSET, 		GetLootIndexFromName("world_survivor"), 20, 3);
	CreateStaticLootSpawn(256.5936, 4331.7617, 2.4708 - FLOOR_OFFSET,		GetLootIndexFromName("world_civilian"), 20, 3);

// ILHA LS

	CreateStaticLootSpawn(4479.7085, -1708.5898, 7.2346 - FLOOR_OFFSET, 	GetLootIndexFromName("world_military"), 20, 3);
	CreateStaticLootSpawn(4496.0098, -1709.1809, 6.6759 - FLOOR_OFFSET,		GetLootIndexFromName("world_military"), 20, 3);
	CreateStaticLootSpawn(4606.2061, -1628.6632, 10.6546 - FLOOR_OFFSET, 	GetLootIndexFromName("world_military"), 20, 3);
	CreateStaticLootSpawn(4479.7407, -1719.5300, 6.8561 - FLOOR_OFFSET,		GetLootIndexFromName("world_industrial"), 20, 3);
	CreateStaticLootSpawn(4498.3086, -1712.9963, 6.7606 - FLOOR_OFFSET, 	GetLootIndexFromName("world_industrial"), 20, 3);
	CreateStaticLootSpawn(4482.9546, -1736.3346, 4.5707 - FLOOR_OFFSET,		GetLootIndexFromName("world_industrial"), 20, 3);
	CreateStaticLootSpawn(4622.9160, -1646.0157, 7.0727 - FLOOR_OFFSET, 	GetLootIndexFromName("world_industrial"), 20, 3);
	CreateStaticLootSpawn(4651.7568, -1639.8040, 6.1447 - FLOOR_OFFSET,		GetLootIndexFromName("world_industrial"), 20, 3);
	CreateStaticLootSpawn(4514.8950, -1559.9926, 6.9311 - FLOOR_OFFSET, 	GetLootIndexFromName("world_industrial"), 20, 3);
	CreateStaticLootSpawn(4562.4268, -1519.0768, 2.1752 - FLOOR_OFFSET,		GetLootIndexFromName("world_industrial"), 20, 3);
	CreateStaticLootSpawn(4637.3726, -1613.9160, 7.7569 - FLOOR_OFFSET,		GetLootIndexFromName("world_civilian"), 20, 3);
	CreateStaticLootSpawn(4622.7583, -1612.6600, 10.6546 - FLOOR_OFFSET, 	GetLootIndexFromName("world_civilian"), 20, 3);
	CreateStaticLootSpawn(4605.6294, -1627.7588, 19.0545 - FLOOR_OFFSET,	GetLootIndexFromName("world_civilian"), 20, 3);
	CreateStaticLootSpawn(4479.4263, -1536.5809, 4.4867 - FLOOR_OFFSET, 	GetLootIndexFromName("world_civilian"), 20, 3);
	CreateStaticLootSpawn(4488.1694, -1536.6487, 5.6018 - FLOOR_OFFSET,		GetLootIndexFromName("world_civilian"), 20, 3);
	CreateStaticLootSpawn(4505.1133, -1546.2498, 7.7314 - FLOOR_OFFSET, 	GetLootIndexFromName("world_civilian"), 20, 3);
	CreateStaticLootSpawn(4514.2451, -1552.8290, 7.3591 - FLOOR_OFFSET,		GetLootIndexFromName("world_civilian"), 20, 3);
	CreateStaticLootSpawn(4535.7783, -1534.2539, 3.8522 - FLOOR_OFFSET, 	GetLootIndexFromName("world_military"), 20, 3);
	CreateStaticLootSpawn(4462.8931, -1733.2615, 14.4024 - FLOOR_OFFSET,	GetLootIndexFromName("world_military"), 20, 3);
}


MapasNovos_LS()
{
	ChatMsgAll(LBLUE, " >  Carregando regi�o do mundo: {FF8A14}'Mapas Novos - LS' {1589FF}por favor, aguarde...");

//	CreateStaticLootSpawn(-1603.15735, 2690.23340, 54.28019,	GetLootIndexFromName("world_civilian"), 20.0);
}

MapasNovos_LV()
{
	ChatMsgAll(LBLUE, " >  Carregando regi�o do mundo: {FF8A14}'Mapas Novos - LV' {1589FF}por favor, aguarde...");

//	CreateStaticLootSpawn(-692.57898, 1549.16516, 81.65029,		GetLootIndexFromName("world_survivor"), 10.0);
}

MapasNovos_SF()
{
	ChatMsgAll(LBLUE, " >  Carregando regi�o do mundo: {FF8A14}'Mapas Novos - SF' {1589FF}por favor, aguarde...");

//	CreateStaticLootSpawn(-881.05548, 1998.04822, 59.19070,		GetLootIndexFromName("world_survivor"), 10.0);

}

