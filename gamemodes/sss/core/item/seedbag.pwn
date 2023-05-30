#include <YSI\y_hooks>

#define MAX_SEED_TYPES	(16)


enum E_SEED_TYPE_DATA
{
			seed_name[ITM_MAX_NAME],
ItemType:	seed_itemType,
			seed_growthTime,
			seed_plantModel,
Float:		seed_plantOffset
}

enum
{
	E_SEED_BAG_AMOUNT,
	E_SEED_BAG_TYPE
}


static
	seed_Data[MAX_SEED_TYPES][E_SEED_TYPE_DATA],
	seed_Total;

hook OnItemTypeDefined(uname[])
{
	if(!strcmp(uname, "SeedBag"))
		SetItemTypeMaxArrayData(GetItemTypeFromUniqueName("SeedBag"), 2);
}

stock DefineSeedType(name[], ItemType:itemtype, growthtime, plantmodel, Float:plantoffset)
{
	if(seed_Total >= MAX_SEED_TYPES)
	{
		err("Seed type limit reached.");
		return -1;
	}

	strcat(seed_Data[seed_Total][seed_name], name, ITM_MAX_NAME);
	seed_Data[seed_Total][seed_itemType] = itemtype;
	seed_Data[seed_Total][seed_growthTime] = growthtime;
	seed_Data[seed_Total][seed_plantModel] = plantmodel;
	seed_Data[seed_Total][seed_plantOffset] = plantoffset;

	return seed_Total++;
}


hook OnItemCreate(itemid)
{


	if(GetItemType(itemid) == item_SeedBag)
	{
		if(GetItemLootIndex(itemid) != -1)
		{
			SetItemArrayDataAtCell(itemid, random(5), E_SEED_BAG_AMOUNT, 1);
			SetItemArrayDataAtCell(itemid, random(seed_Total), E_SEED_BAG_TYPE, 1);
		}
	}
}

hook OnItemNameRender(itemid, ItemType:itemtype) {
	if(itemtype == item_SeedBag) {
		new seedData[2];

		GetItemArrayData(itemid, seedData);

		SetItemNameExtra(itemid,
			seedData[E_SEED_BAG_AMOUNT] > 0 && 0 <= seedData[E_SEED_BAG_TYPE] < seed_Total ? 
			sprintf("%d, %s", seedData[E_SEED_BAG_AMOUNT], seed_Data[seedData[E_SEED_BAG_TYPE]][seed_name]) : "Vazio");
	}
}

stock IsValidSeedType(seedtype) return (0 <= seedtype < seed_Total);

// seed_name
stock GetSeedTypeName(seedtype, name[])
{
	if(!(0 <= seedtype < seed_Total)) return 0;

	name[0] = EOS;
	strcat(name, seed_Data[seedtype][seed_name], ITM_MAX_NAME);

	return 1;
}

// seed_itemType
stock ItemType:GetSeedTypeItemType(seedtype)
{
	if(!(0 <= seedtype < seed_Total))
		return INVALID_ITEM_TYPE;

	return seed_Data[seedtype][seed_itemType];
}

// seed_growthTime
stock GetSeedTypeGrowthTime(seedtype)
{
	if(!(0 <= seedtype < seed_Total))
		return 0;

	return seed_Data[seedtype][seed_growthTime];
}

// seed_plantModel
stock GetSeedTypePlantModel(seedtype)
{
	if(!(0 <= seedtype < seed_Total))
		return 0;

	return seed_Data[seedtype][seed_plantModel];
}

// seed_plantOffset
stock Float:GetSeedTypePlantOffset(seedtype)
{
	if(!(0 <= seedtype < seed_Total))
		return 0.0;

	return seed_Data[seedtype][seed_plantOffset];
}
