#include <YSI\y_hooks>


hook OnGameModeInit()
{
	LoadTiles();
	GenerateTerrain(285645);
}
