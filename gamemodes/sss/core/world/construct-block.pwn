#include <YSI\y_hooks>

#define MAX_BLOCK_ZONES (2)

static Float:block_Zone[MAX_BLOCK_ZONES][4] =
	{
		{15.0, 256.6457, 4297.8452, 7.2358},
		{20.0, 0, 0, 0}
	},
	block_Zone1[MAX_PLAYERS];

stock IsPlayerInBlockZone(playerid, &Float:d, &Float:x, &Float:y, &Float:z)
{
	new index = random(sizeof(block_Zone));

	while(index == block_Zone1[playerid])
		index = random(sizeof(block_Zone));

	d = block_Zone[index][0];
	x = block_Zone[index][1];
	y = block_Zone[index][2];
	z = block_Zone[index][3];

	block_Zone1[playerid] = index;

    if(IsPlayerInRangeOfPoint(playerid, d, x, y, z))
	{
		ChatMsg(playerid, RED, " >  Você está em uma zona bloqueada!");
        return 1;
    }
    return 0;
}