#include <a_samp>
#include <streamer>
#define FILTERSCRIPT

																																											/*
										BY: Oupier
										_______
																																											*/

new g_Object[90];
new ActorSpawn;

public OnGameModeInit()
{
    ActorSpawn = CreateActor (146, 1468.6132, -8647.6132, 4957.9248, 71.2000);
    ApplyActorAnimation(ActorSpawn, "BEACH","PARKSIT_M_LOOP", 4.0999, 1, 0, 0, 0, 0);
	
    g_Object[0] = CreateObject(19868, 1489.7927, -8645.8847, 4957.1660, 1.2999, 0.0000, 151.6000); //MeshFence1
	g_Object[1] = CreateObject(19833, 1479.9843, -8648.9277, 4957.1704, 0.0000, 0.0000, -111.5999); //Cow1
	g_Object[2] = CreateObject(616, 1465.9017, -8663.1757, 4954.3701, 0.0000, 0.0000, 82.3000); //veg_treea1
	g_Object[3] = CreateObject(19078, 1470.3499, -8660.1425, 4960.6591, -4.5000, -106.9999, 62.4000); //TheParrot1
	g_Object[4] = CreateObject(10166, 1536.0468, -8662.5527, 4954.7553, 7.2000, -9.0999, 64.1000); //p69_rocks
	SetObjectMaterial(g_Object[4], 0, 10403, "golf_sfs", "golf_grassrock", 0x00000000);
	g_Object[5] = CreateObject(19536, 1448.8787, -8658.5380, 4956.8852, 0.0000, 0.0000, 0.0000); //Plane62_5x125Grass1
	g_Object[6] = CreateObject(874, 1466.2696, -8650.7666, 4955.8452, 0.0000, 0.0000, 43.5999); //veg_procgrasspatch
	g_Object[7] = CreateObject(10166, 1475.0832, -8705.2451, 4954.3159, -9.1999, -6.5999, 31.6999); //p69_rocks
	SetObjectMaterial(g_Object[7], 0, 10403, "golf_sfs", "golf_grassrock", 0x00000000);
	g_Object[8] = CreateObject(19841, 1489.7825, -8663.0214, 4949.6767, 15.3000, 0.0000, -115.6000); //WaterFall2
	g_Object[9] = CreateObject(616, 1480.0413, -8643.8740, 4953.7114, 0.0000, 0.0000, 0.0000); //veg_treea1
	g_Object[10] = CreateObject(669, 1478.4118, -8649.1074, 4957.0942, 0.0000, 0.0000, 94.9999); //sm_veg_tree4
	g_Object[11] = CreateObject(19833, 1478.0783, -8649.8671, 4957.1704, 0.0000, 0.0000, -80.2000); //Cow1
	g_Object[12] = CreateObject(669, 1470.2841, -8660.6279, 4957.0942, 0.0000, 0.0000, 0.0000); //sm_veg_tree4
	g_Object[13] = CreateObject(19868, 1480.5364, -8641.3896, 4957.1757, 1.2999, 0.0000, 161.7000); //MeshFence1
	g_Object[14] = CreateObject(19868, 1485.2452, -8643.4257, 4957.1660, 1.2999, 0.0000, 151.6000); //MeshFence1
	g_Object[15] = CreateObject(19868, 1475.6085, -8639.7607, 4957.1757, 1.2999, 0.0000, 161.7000); //MeshFence1
	g_Object[16] = CreateObject(19868, 1470.5749, -8638.7148, 4957.1757, 1.2999, 0.0000, 174.2000); //MeshFence1
	g_Object[17] = CreateObject(19868, 1460.9965, -8641.5595, 4957.1245, 1.2999, 0.0000, -152.7000); //MeshFence1
	g_Object[18] = CreateObject(19868, 1465.7734, -8639.2070, 4957.0483, 1.2999, 0.0000, -156.2000); //MeshFence1
	g_Object[19] = CreateObject(12957, 1474.2319, -8647.4970, 4957.5971, 0.0000, 0.0000, 137.1999); //sw_pickupwreck01
	g_Object[20] = CreateObject(19868, 1457.3234, -8661.7851, 4957.1376, 1.2999, 0.0000, -48.0000); //MeshFence1
	g_Object[21] = CreateObject(19868, 1453.8211, -8649.3876, 4957.0795, 1.2999, 0.0000, -117.3000); //MeshFence1
	g_Object[22] = CreateObject(19868, 1452.6990, -8654.2802, 4957.0839, 1.2999, 0.0000, -88.5000); //MeshFence1
	g_Object[23] = CreateObject(19868, 1454.5932, -8658.7529, 4957.1376, 1.2999, 0.0000, -48.0000); //MeshFence1
	g_Object[24] = CreateObject(19868, 1470.7696, -8668.0107, 4957.1718, 1.2999, 0.0000, -4.6000); //MeshFence1
	g_Object[25] = CreateObject(19868, 1465.7540, -8666.7197, 4957.1831, 1.2999, 0.0000, -24.4000); //MeshFence1
	g_Object[26] = CreateObject(19868, 1461.0378, -8664.6279, 4957.1752, 1.2999, 0.0000, -24.3000); //MeshFence1
	g_Object[27] = CreateObject(19842, 1485.6102, -8661.0986, 4956.8896, 0.0000, 0.0000, -116.5000); //WaterFallWater1
	g_Object[28] = CreateObject(745, 1481.3702, -8667.3740, 4955.0620, 0.0000, 0.0000, 93.6999); //sm_scrub_rock5
	SetObjectMaterial(g_Object[28], 0, 16055, "des_quarry", "des_rockyfill", 0x00000000);
	SetObjectMaterial(g_Object[28], 1, 2812, "gb_dirtycrock01", "GB_platedirty01", 0x00000000);
	SetObjectMaterial(g_Object[28], 2, 10403, "golf_sfs", "golf_grassrock", 0x00000000);
	g_Object[29] = CreateObject(745, 1482.5195, -8668.4091, 4955.0620, 0.0000, 0.0000, 170.9999); //sm_scrub_rock5
	SetObjectMaterial(g_Object[29], 0, 16055, "des_quarry", "des_rockyfill", 0x00000000);
	SetObjectMaterial(g_Object[29], 1, 2812, "gb_dirtycrock01", "GB_platedirty01", 0x00000000);
	SetObjectMaterial(g_Object[29], 2, 10403, "golf_sfs", "golf_grassrock", 0x00000000);
	g_Object[30] = CreateObject(745, 1478.8311, -8666.8232, 4955.6210, 0.0000, 0.0000, 153.7999); //sm_scrub_rock5
	SetObjectMaterial(g_Object[30], 0, 16055, "des_quarry", "des_rockyfill", 0x00000000);
	SetObjectMaterial(g_Object[30], 1, 2812, "gb_dirtycrock01", "GB_platedirty01", 0x00000000);
	SetObjectMaterial(g_Object[30], 2, 10403, "golf_sfs", "golf_grassrock", 0x00000000);
	g_Object[31] = CreateObject(745, 1476.2958, -8665.4150, 4955.3227, 0.0000, 0.0000, 112.9999); //sm_scrub_rock5
	SetObjectMaterial(g_Object[31], 0, 16055, "des_quarry", "des_rockyfill", 0x00000000);
	SetObjectMaterial(g_Object[31], 1, 2812, "gb_dirtycrock01", "GB_platedirty01", 0x00000000);
	SetObjectMaterial(g_Object[31], 2, 10403, "golf_sfs", "golf_grassrock", 0x00000000);
	g_Object[32] = CreateObject(745, 1477.7001, -8665.5273, 4954.6127, 0.0000, 0.0000, 112.9999); //sm_scrub_rock5
	SetObjectMaterial(g_Object[32], 0, 16055, "des_quarry", "des_rockyfill", 0x00000000);
	SetObjectMaterial(g_Object[32], 1, 2812, "gb_dirtycrock01", "GB_platedirty01", 0x00000000);
	SetObjectMaterial(g_Object[32], 2, 10403, "golf_sfs", "golf_grassrock", 0x00000000);
	g_Object[33] = CreateObject(745, 1476.2130, -8664.3056, 4954.9218, 2.1000, -2.5999, -35.3000); //sm_scrub_rock5
	SetObjectMaterial(g_Object[33], 0, 16055, "des_quarry", "des_rockyfill", 0x00000000);
	SetObjectMaterial(g_Object[33], 1, 2812, "gb_dirtycrock01", "GB_platedirty01", 0x00000000);
	SetObjectMaterial(g_Object[33], 2, 10403, "golf_sfs", "golf_grassrock", 0x00000000);
	g_Object[34] = CreateObject(745, 1474.3975, -8663.9960, 4954.4194, 2.1000, -2.5999, 143.8999); //sm_scrub_rock5
	SetObjectMaterial(g_Object[34], 0, 16055, "des_quarry", "des_rockyfill", 0x00000000);
	SetObjectMaterial(g_Object[34], 1, 2812, "gb_dirtycrock01", "GB_platedirty01", 0x00000000);
	SetObjectMaterial(g_Object[34], 2, 10403, "golf_sfs", "golf_grassrock", 0x00000000);
	g_Object[35] = CreateObject(745, 1471.9654, -8662.9804, 4954.9086, 2.1000, -2.5999, 166.2999); //sm_scrub_rock5
	SetObjectMaterial(g_Object[35], 0, 16055, "des_quarry", "des_rockyfill", 0x00000000);
	SetObjectMaterial(g_Object[35], 1, 2812, "gb_dirtycrock01", "GB_platedirty01", 0x00000000);
	SetObjectMaterial(g_Object[35], 2, 10403, "golf_sfs", "golf_grassrock", 0x00000000);
	g_Object[36] = CreateObject(745, 1474.1937, -8664.7802, 4955.1459, 2.1000, -2.5999, 166.2999); //sm_scrub_rock5
	SetObjectMaterial(g_Object[36], 0, 16055, "des_quarry", "des_rockyfill", 0x00000000);
	SetObjectMaterial(g_Object[36], 1, 2812, "gb_dirtycrock01", "GB_platedirty01", 0x00000000);
	SetObjectMaterial(g_Object[36], 2, 10403, "golf_sfs", "golf_grassrock", 0x00000000);
	g_Object[37] = CreateObject(745, 1471.1071, -8660.8984, 4954.8422, 2.1000, -2.5999, -103.5000); //sm_scrub_rock5
	SetObjectMaterial(g_Object[37], 0, 16055, "des_quarry", "des_rockyfill", 0x00000000);
	SetObjectMaterial(g_Object[37], 1, 2812, "gb_dirtycrock01", "GB_platedirty01", 0x00000000);
	SetObjectMaterial(g_Object[37], 2, 10403, "golf_sfs", "golf_grassrock", 0x00000000);
	g_Object[38] = CreateObject(745, 1471.8315, -8657.8466, 4954.6625, 2.1000, 11.1000, 74.4999); //sm_scrub_rock5
	SetObjectMaterial(g_Object[38], 0, 16055, "des_quarry", "des_rockyfill", 0x00000000);
	SetObjectMaterial(g_Object[38], 1, 2812, "gb_dirtycrock01", "GB_platedirty01", 0x00000000);
	SetObjectMaterial(g_Object[38], 2, 10403, "golf_sfs", "golf_grassrock", 0x00000000);
	g_Object[39] = CreateObject(745, 1473.1038, -8655.7773, 4954.3779, 2.1000, 9.8000, 48.1000); //sm_scrub_rock5
	SetObjectMaterial(g_Object[39], 0, 16055, "des_quarry", "des_rockyfill", 0x00000000);
	SetObjectMaterial(g_Object[39], 1, 2812, "gb_dirtycrock01", "GB_platedirty01", 0x00000000);
	SetObjectMaterial(g_Object[39], 2, 10403, "golf_sfs", "golf_grassrock", 0x00000000);
	g_Object[40] = CreateObject(874, 1472.1000, -8668.9980, 4958.1445, 0.0000, 0.0000, 0.0000); //veg_procgrasspatch
	g_Object[41] = CreateObject(874, 1467.1077, -8668.9980, 4958.1445, 0.0000, 0.0000, 0.0000); //veg_procgrasspatch
	g_Object[42] = CreateObject(874, 1480.6982, -8640.0693, 4958.1445, 0.0000, 0.0000, 0.0000); //veg_procgrasspatch
	g_Object[43] = CreateObject(745, 1474.5910, -8653.2353, 4954.4521, -21.5999, 9.8000, 64.2000); //sm_scrub_rock5
	SetObjectMaterial(g_Object[43], 0, 16055, "des_quarry", "des_rockyfill", 0x00000000);
	SetObjectMaterial(g_Object[43], 1, 2812, "gb_dirtycrock01", "GB_platedirty01", 0x00000000);
	SetObjectMaterial(g_Object[43], 2, 10403, "golf_sfs", "golf_grassrock", 0x00000000);
	g_Object[44] = CreateObject(800, 1476.2153, -8640.8681, 4956.0605, 0.0000, 0.0000, 0.0000); //genVEG_bush07
	g_Object[45] = CreateObject(745, 1475.6445, -8651.5664, 4954.4335, -21.5999, 9.8000, -134.1999); //sm_scrub_rock5
	SetObjectMaterial(g_Object[45], 0, 16055, "des_quarry", "des_rockyfill", 0x00000000);
	SetObjectMaterial(g_Object[45], 1, 2812, "gb_dirtycrock01", "GB_platedirty01", 0x00000000);
	SetObjectMaterial(g_Object[45], 2, 10403, "golf_sfs", "golf_grassrock", 0x00000000);
	g_Object[46] = CreateObject(745, 1477.1038, -8648.9082, 4953.9545, -19.3999, 52.5000, 128.8999); //sm_scrub_rock5
	SetObjectMaterial(g_Object[46], 0, 16055, "des_quarry", "des_rockyfill", 0x00000000);
	SetObjectMaterial(g_Object[46], 1, 2812, "gb_dirtycrock01", "GB_platedirty01", 0x00000000);
	SetObjectMaterial(g_Object[46], 2, 10403, "golf_sfs", "golf_grassrock", 0x00000000);
	g_Object[47] = CreateObject(745, 1488.0811, -8653.8369, 4955.4375, -19.3999, 7.9999, 148.8999); //sm_scrub_rock5
	SetObjectMaterial(g_Object[47], 0, 16055, "des_quarry", "des_rockyfill", 0x00000000);
	SetObjectMaterial(g_Object[47], 1, 2812, "gb_dirtycrock01", "GB_platedirty01", 0x00000000);
	SetObjectMaterial(g_Object[47], 2, 10403, "golf_sfs", "golf_grassrock", 0x00000000);
	g_Object[48] = CreateObject(800, 1484.2019, -8650.9140, 4956.0605, 0.0000, 0.0000, 24.8999); //genVEG_bush07
	g_Object[49] = CreateObject(800, 1478.4626, -8666.6845, 4956.0605, 0.0000, 0.0000, -5.8000); //genVEG_bush07
	g_Object[50] = CreateObject(745, 1486.4163, -8653.0654, 4954.8076, -19.3999, 16.2999, -57.5000); //sm_scrub_rock5
	SetObjectMaterial(g_Object[50], 0, 16055, "des_quarry", "des_rockyfill", 0x00000000);
	SetObjectMaterial(g_Object[50], 1, 2812, "gb_dirtycrock01", "GB_platedirty01", 0x00000000);
	SetObjectMaterial(g_Object[50], 2, 10403, "golf_sfs", "golf_grassrock", 0x00000000);
	g_Object[51] = CreateObject(745, 1483.7093, -8651.7568, 4954.6801, -19.3999, 25.0999, -27.4000); //sm_scrub_rock5
	SetObjectMaterial(g_Object[51], 0, 16055, "des_quarry", "des_rockyfill", 0x00000000);
	SetObjectMaterial(g_Object[51], 1, 2812, "gb_dirtycrock01", "GB_platedirty01", 0x00000000);
	SetObjectMaterial(g_Object[51], 2, 10403, "golf_sfs", "golf_grassrock", 0x00000000);
	g_Object[52] = CreateObject(800, 1497.5214, -8663.0244, 4963.9750, 0.0000, 0.0000, -5.8000); //genVEG_bush07
	g_Object[53] = CreateObject(745, 1480.8822, -8649.5390, 4954.6958, -19.3999, 25.0999, 107.9999); //sm_scrub_rock5
	SetObjectMaterial(g_Object[53], 0, 16055, "des_quarry", "des_rockyfill", 0x00000000);
	SetObjectMaterial(g_Object[53], 1, 2812, "gb_dirtycrock01", "GB_platedirty01", 0x00000000);
	SetObjectMaterial(g_Object[53], 2, 10403, "golf_sfs", "golf_grassrock", 0x00000000);
	g_Object[54] = CreateObject(800, 1497.0244, -8665.4414, 4963.9750, 0.0000, 0.0000, -5.8000); //genVEG_bush07
	g_Object[55] = CreateObject(800, 1495.5560, -8667.7119, 4964.0678, 0.0000, 0.0000, -5.8000); //genVEG_bush07
	g_Object[56] = CreateObject(800, 1493.8421, -8669.6201, 4964.0678, 0.0000, 0.0000, -5.8000); //genVEG_bush07
	g_Object[57] = CreateObject(800, 1474.3353, -8662.2421, 4954.8247, 0.0000, 0.0000, 176.6001); //genVEG_bush07
	g_Object[58] = CreateObject(800, 1498.4843, -8659.5830, 4966.4316, 3.5999, -73.2999, -25.1000); //genVEG_bush07
	g_Object[59] = CreateObject(800, 1485.8585, -8652.9941, 4954.8247, 0.0000, 0.0000, -148.2998); //genVEG_bush07
	g_Object[60] = CreateObject(800, 1490.9808, -8670.3408, 4965.4687, 3.5999, -73.2999, -79.8000); //genVEG_bush07
	g_Object[61] = CreateObject(800, 1480.8616, -8667.4687, 4959.3427, 0.0000, 0.0000, -148.2998); //genVEG_bush07
	g_Object[62] = CreateObject(800, 1492.4713, -8654.2216, 4960.4912, 0.0000, 0.0000, -5.8000); //genVEG_bush07
	g_Object[63] = CreateObject(660, 1512.6662, -8671.8681, 4971.5483, 0.0000, -5.1999, 0.0000); //pinetree03
	g_Object[64] = CreateObject(800, 1493.8626, -8656.4677, 4961.3959, 0.0000, 0.0000, -5.8000); //genVEG_bush07
	g_Object[65] = CreateObject(800, 1497.6262, -8651.0156, 4963.7817, 0.0000, 0.0000, -5.8000); //genVEG_bush07
	g_Object[66] = CreateObject(800, 1482.1678, -8671.7578, 4963.7817, 0.0000, 0.0000, -5.8000); //genVEG_bush07
	g_Object[67] = CreateObject(19632, 1468.4775, -8648.5166, 4956.8134, 0.0000, 0.0000, 91.5000); //FireWood1
	g_Object[68] = CreateObject(1369, 1467.5607, -8657.1181, 4957.4428, 0.0000, 0.0000, -179.5000); //CJ_WHEELCHAIR1
	g_Object[69] = CreateObject(2926, 1472.8867, -8648.0683, 4957.4316, 0.0000, 0.0000, 72.3999); //dyno_box_A
	g_Object[70] = CreateObject(2675, 1470.9135, -8650.8320, 4956.9575, 0.0000, 0.0000, 0.0000); //PROC_RUBBISH_6
	g_Object[71] = CreateObject(2676, 1471.2032, -8645.1806, 4957.0131, 0.0000, 0.0000, 58.3000); //PROC_RUBBISH_8
	g_Object[72] = CreateObject(18633, 1472.7270, -8647.9072, 4957.5151, -0.1999, -91.0999, -18.2000); //GTASAWrench1
	g_Object[73] = CreateObject(2673, 1470.2114, -8647.7666, 4956.9750, 0.0000, 0.0000, 0.0000); //PROC_RUBBISH_5
	g_Object[74] = CreateObject(11736, 1473.0615, -8648.4531, 4957.6079, 71.7999, -9.3999, -98.7999); //MedicalSatchel1
	g_Object[75] = CreateObject(870, 1469.2838, -8657.7666, 4957.1137, 0.0000, 0.0000, 0.0000); //veg_Pflowers2wee
	g_Object[76] = CreateObject(356, 1472.4390, -8648.0566, 4957.5571, -13.0000, -1.6000, -104.7000); //m4
	g_Object[77] = CreateObject(870, 1467.7041, -8660.0029, 4957.1137, 0.0000, 0.0000, 0.0000); //veg_Pflowers2wee
	g_Object[78] = CreateObject(2677, 1466.1503, -8657.8505, 4957.2050, 0.0000, 0.0000, 0.0000); //PROC_RUBBISH_7
	g_Object[79] = CreateObject(2040, 1472.3259, -8647.8818, 4957.5659, 0.0000, 0.0000, -49.5999); //AMMO_BOX_M1
	g_Object[80] = CreateObject(805, 1463.1086, -8659.9970, 4957.8852, 0.0000, 0.0000, 0.0000); //genVEG_bush11
	g_Object[81] = CreateObject(805, 1461.3682, -8663.5458, 4957.8852, 0.0000, 0.0000, 0.0000); //genVEG_bush11
	g_Object[82] = CreateObject(805, 1473.4785, -8643.2050, 4957.8852, 0.0000, 0.0000, 0.0000); //genVEG_bush11
	g_Object[83] = CreateObject(805, 1470.0084, -8642.6582, 4957.8852, 0.0000, 0.0000, 0.0000); //genVEG_bush11
	g_Object[84] = CreateObject(874, 1486.6232, -8643.6386, 4958.1445, 0.0000, 0.0000, 0.0000); //veg_procgrasspatch
	g_Object[85] = CreateObject(874, 1460.7913, -8646.5644, 4955.8452, 0.0000, 0.0000, 43.5999); //veg_procgrasspatch
	g_Object[86] = CreateObject(874, 1465.5567, -8642.0292, 4955.8452, 0.0000, 0.0000, 43.5999); //veg_procgrasspatch
	g_Object[87] = CreateObject(874, 1457.8782, -8652.8935, 4955.8452, 0.0000, 0.0000, 34.7999); //veg_procgrasspatch
	g_Object[88] = CreateObject(874, 1459.4864, -8660.0292, 4955.8452, 0.0000, 0.0000, 116.9000); //veg_procgrasspatch
	g_Object[89] = CreateObject(19868, 1456.5947, -8645.0078, 4957.0961, 1.2999, 0.0000, -128.9000); //MeshFence1
    return 1;
}
