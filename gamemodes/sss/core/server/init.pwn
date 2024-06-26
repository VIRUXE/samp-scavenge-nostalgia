#include <YSI\y_hooks>


/*==============================================================================

	Everything global is declared, defined and initialised here. This ensures
	that all entity definitions are not null before other scripts initialise.
	Called AFTER OnGameModeInit_Setup and BEFORE other OnScriptInit hooks.

==============================================================================*/

// SKINS/CLOTHES
new stock
	skin_Civ0M,  //60,		"Civilian",			0, 1.0,		true, true);
	skin_Civ1M,  //170,		"Civilian",			0, 1.0,		true, true);
	skin_Civ2M,  //250,		"Civilian",			0, 1.0,		true, true);
	skin_Civ3M,  //188,		"Civilian",			0, 1.0,		true, true);
	skin_Civ4M,  //206,		"Civilian",			0, 1.0,		true, true);
	skin_Civ5M,  //44,		"Civilian",			0, 1.0,		true, true);
	skin_Civ6M,  //289,		"Civilian",			0, 1.0,		false, false);
	skin_Civ7M,  //25,		"Civilian",			0, 1.0,		true, true);
	skin_Civ8M,  //45,		"Civilian",			0, 1.0,		true, true);
	skin_Civ9M,  //59,		"Civilian",			0, 1.0,		true, true);
	skin_Civ10M,  //97,		"Civilian",			0, 1.0,		true, true);
	skin_Civ11M,  //98,		"Civilian",			0, 1.0,		true, true);
	skin_Civ12M,  //119,	"Civilian",			0, 1.0,		true, true);
	skin_Civ13M,  //121,	"Civilian",			0, 1.0,		true, true);
	skin_Civ14M,  //124,	"Civilian",			0, 1.0,		true, true);
	skin_Civ15M,  //154,	"Civilian",			0, 1.0,		true, true); //
	skin_Civ16M,  //162,	"Civilian",			0, 1.0,		true, true);
	skin_Civ17M,  //184,	"Civilian",			0, 1.0,		true, true);
	skin_Civ18M,  //208,	"Civilian",			0, 1.0,		true, true);
	skin_Civ19M,  //210,	"Civilian",			0, 1.0,		true, true);
	skin_Civ20M,  //268,	"Civilian",			0, 1.0,		true, true);

	// male special
	skin_MechM,  //50,		"Mechanic",			0, 0.6,		true, true);
	skin_BikeM,  //254,		"Biker",			0, 0.3,		true, true);
	skin_PoliM,  //283,		"Cop",				0, 0.3,		false, false);
	skin_ArmyM,  //287,		"Military",			0, 0.2,		false, true);
	skin_SwatM,  //285,		"S.W.A.T.",			0, 0.1,		false, false);
	skin_TriaM,  //294,		"Triad",			0, 0.2,		false, false);
	skin_ClawM,  //101,		"Southclaw",		0, 0.1,		true, true);
	skin_FreeM,  //156,		"Morgan Freeman",	0, 0.01,	true, true);
	skin_police,  //300,	"Policial",			0, 0.5,		true, true);
	skin_12	,  //22,		"12",				0, 0.3,		true, true);
	skin_medico,  //70,		"M�dico",			0, 0.5,		true, true);

	// female civilian
	skin_Civ0F,  //192,		"Civilian",			1, 1.0,		true, true);
	skin_Civ1F,  //93,		"Civilian",			1, 1.0,		true, true);
	skin_Civ2F,  //233,		"Civilian",			1, 1.0,		true, true);
	skin_Civ3F,  //193,		"Civilian",			1, 1.0,		true, true);
	skin_Civ4F,  //90,		"Civilian",			1, 1.0,		false, false);
	skin_Civ5F,  //190,		"Civilian",			1, 1.0,		false, false);
	skin_Civ6F,  //195,		"Civilian",			1, 1.0,		true, true);
	skin_Civ7F,  //41,		"Civilian",			1, 1.0,		false, false);
	skin_Civ8F,  //56,		"Civilian",			1, 1.0,		true, true);
	skin_Civ9F,  //69,		"Civilian",			1, 1.0,		true, true);
	skin_Civ10F,  //76,		"Civilian",			1, 1.0,		true, true);
	skin_Civ11F,  //91,		"Civilian",			1, 1.0,		true, true);
	skin_Civ12F,  //138,	"Civilian",			1, 1.0,		true, true);
	skin_Civ13F,  //150,	"Civilian",			1, 1.0,		true, true);
	skin_Civ14F,  //169,	"Civilian",			1, 1.0,		true, true);
	skin_Civ15F,  //216,	"Civilian",			1, 1.0,		true, true);

	// female special
	skin_IndiF,  //131,		"Indian",			1, 0.6,		true, true);
	skin_Cnt0F,  //157,		"Country",			1, 0.7,		false, false);
	skin_Cnt1F,  //201,		"Country",			1, 0.7,		false, false);
	skin_GangF,  //298,		"Country",			1, 0.6,		false, false);
	skin_ArmyF,  //191,		"Military",			1, 0.2,		true, true);
	skin_BusiF;

// ITEM ATTACK ANIMATION HANDLES
new
	anim_Blunt,
	anim_Stab,
	anim_Heavy;

// DRUG TYPES
new
	drug_Antibiotic,
	drug_Painkill,
	drug_Lsd,
	drug_Air,
	drug_Morphine,
	drug_Adrenaline,
	drug_Heroin,
	drug_DTPA;

// AMMO CALIBRES
new
	calibre_9mm,
	calibre_50cae,
	calibre_12g,
	calibre_556,
	calibre_357,
	calibre_762,
	calibre_rpg,
	calibre_fuel,
	calibre_film,
	calibre_50bmg,
	calibre_308;

// LIQUID TYPES
new stock
	liquid_Water,
	liquid_PurifiedWater,
	liquid_SaltWater,
	liquid_Milk,
	liquid_Orange,
	liquid_Apple,
	liquid_Whiskey,
	liquid_WineRed,
	liquid_WineWhite,
	liquid_Champagne,
	liquid_Ethanol,
	liquid_Turpentine,
	liquid_HydroAcid,
	liquid_CarbonatedWater,
	liquid_Lemon,
	liquid_Sugar,
	liquid_Petrol,
	liquid_Diesel,
	liquid_Oil,
	liquid_BakingSoda,
	liquid_ProteinPowder,
	liquid_IronPowder,
	liquid_IronOxide,
	liquid_CopperOxide,
	liquid_Magnesium,
	liquid_StrongWhiskey,
	liquid_Fun,
	liquid_Lemonade,
	liquid_Orangeade,
	liquid_Thermite,
	liquid_StrongThermite;

// TREE CATEGORIES
new stock
	tree_Desert,
	tree_DarkForest,
	tree_LightForest,
	tree_GrassPlanes;

// ITEM TYPES
new stock
// 00
ItemType:		item_NULL			= INVALID_ITEM_TYPE,
ItemType:		item_Knuckles		= INVALID_ITEM_TYPE,
ItemType:		item_GolfClub		= INVALID_ITEM_TYPE,
ItemType:		item_Baton			= INVALID_ITEM_TYPE,
ItemType:		item_Knife			= INVALID_ITEM_TYPE,
ItemType:		item_Bat			= INVALID_ITEM_TYPE,
ItemType:		item_Spade			= INVALID_ITEM_TYPE,
ItemType:		item_PoolCue		= INVALID_ITEM_TYPE,
ItemType:		item_Sword			= INVALID_ITEM_TYPE,
ItemType:		item_Chainsaw		= INVALID_ITEM_TYPE,
// 10
ItemType:		item_Dildo1			= INVALID_ITEM_TYPE,
ItemType:		item_Dildo2			= INVALID_ITEM_TYPE,
ItemType:		item_Dildo3			= INVALID_ITEM_TYPE,
ItemType:		item_Dildo4			= INVALID_ITEM_TYPE,
ItemType:		item_Flowers		= INVALID_ITEM_TYPE,
ItemType:		item_WalkingCane	= INVALID_ITEM_TYPE,
ItemType:		item_Grenade		= INVALID_ITEM_TYPE,
ItemType:		item_Teargas		= INVALID_ITEM_TYPE,
ItemType:		item_Molotov		= INVALID_ITEM_TYPE,
ItemType:		item_NULL2			= INVALID_ITEM_TYPE,
// 20
ItemType:		item_NULL3			= INVALID_ITEM_TYPE,
ItemType:		item_NULL4			= INVALID_ITEM_TYPE,
ItemType:		item_M9Pistol		= INVALID_ITEM_TYPE,
ItemType:		item_M9PistolSD		= INVALID_ITEM_TYPE,
ItemType:		item_DesertEagle	= INVALID_ITEM_TYPE,
ItemType:		item_PumpShotgun	= INVALID_ITEM_TYPE,
ItemType:		item_Sawnoff		= INVALID_ITEM_TYPE,
ItemType:		item_Spas12			= INVALID_ITEM_TYPE,
ItemType:		item_Mac10			= INVALID_ITEM_TYPE,
ItemType:		item_MP5			= INVALID_ITEM_TYPE,
// 30
ItemType:		item_WASR3Rifle		= INVALID_ITEM_TYPE,
ItemType:		item_M16Rifle		= INVALID_ITEM_TYPE,
ItemType:		item_Tec9			= INVALID_ITEM_TYPE,
ItemType:		item_SemiAutoRifle	= INVALID_ITEM_TYPE,
ItemType:		item_SniperRifle	= INVALID_ITEM_TYPE,
ItemType:		item_RocketLauncher	= INVALID_ITEM_TYPE,
ItemType:		item_Heatseeker		= INVALID_ITEM_TYPE,
ItemType:		item_Flamer			= INVALID_ITEM_TYPE,
ItemType:		item_Minigun		= INVALID_ITEM_TYPE,
ItemType:		item_RemoteBomb		= INVALID_ITEM_TYPE,
// 40
ItemType:		item_Detonator		= INVALID_ITEM_TYPE,
ItemType:		item_SprayPaint		= INVALID_ITEM_TYPE,
ItemType:		item_Extinguisher	= INVALID_ITEM_TYPE,
ItemType:		item_Camera			= INVALID_ITEM_TYPE,
ItemType:		item_NightVision	= INVALID_ITEM_TYPE,
ItemType:		item_ThermalVision	= INVALID_ITEM_TYPE,
ItemType:		item_Parachute		= INVALID_ITEM_TYPE,
ItemType:		item_Medkit			= INVALID_ITEM_TYPE,
ItemType:		item_HardDrive		= INVALID_ITEM_TYPE,
ItemType:		item_Key			= INVALID_ITEM_TYPE,
// 50
ItemType:		item_FireworkBox	= INVALID_ITEM_TYPE,
ItemType:		item_FireLighter	= INVALID_ITEM_TYPE,
ItemType:		item_Timer			= INVALID_ITEM_TYPE,
ItemType:		item_Explosive		= INVALID_ITEM_TYPE,
ItemType:		item_TntTimebomb	= INVALID_ITEM_TYPE,
ItemType:		item_Battery		= INVALID_ITEM_TYPE,
ItemType:		item_Fusebox		= INVALID_ITEM_TYPE,
ItemType:		item_Bottle			= INVALID_ITEM_TYPE,
ItemType:		item_Sign			= INVALID_ITEM_TYPE,
ItemType:		item_Armour			= INVALID_ITEM_TYPE,
// 60
ItemType:		item_Bandage		= INVALID_ITEM_TYPE,
ItemType:		item_FishRod		= INVALID_ITEM_TYPE,
ItemType:		item_Wrench			= INVALID_ITEM_TYPE,
ItemType:		item_Crowbar		= INVALID_ITEM_TYPE,
ItemType:		item_Hammer			= INVALID_ITEM_TYPE,
ItemType:		item_Shield			= INVALID_ITEM_TYPE,
ItemType:		item_Flashlight		= INVALID_ITEM_TYPE,
ItemType:		item_StunGun		= INVALID_ITEM_TYPE,
ItemType:		item_LaserPoint		= INVALID_ITEM_TYPE,
ItemType:		item_Screwdriver	= INVALID_ITEM_TYPE,
// 70
ItemType:		item_MobilePhone	= INVALID_ITEM_TYPE,
ItemType:		item_Pager			= INVALID_ITEM_TYPE,
ItemType:		item_Rake			= INVALID_ITEM_TYPE,
ItemType:		item_HotDog			= INVALID_ITEM_TYPE,
ItemType:		item_EasterEgg		= INVALID_ITEM_TYPE,
ItemType:		item_Cane			= INVALID_ITEM_TYPE,
ItemType:		item_HandCuffs		= INVALID_ITEM_TYPE,
ItemType:		item_Bucket			= INVALID_ITEM_TYPE,
ItemType:		item_GasMask		= INVALID_ITEM_TYPE,
ItemType:		item_Flag			= INVALID_ITEM_TYPE,
// 80
ItemType:		item_DoctorBag		= INVALID_ITEM_TYPE,
ItemType:		item_Backpack		= INVALID_ITEM_TYPE,
ItemType:		item_Satchel		= INVALID_ITEM_TYPE,
ItemType:		item_Wheel			= INVALID_ITEM_TYPE,
ItemType:		item_MotionSense	= INVALID_ITEM_TYPE,
ItemType:		item_Accelerometer	= INVALID_ITEM_TYPE,
ItemType:		item_TntProxMine	= INVALID_ITEM_TYPE,
ItemType:		item_IedBomb		= INVALID_ITEM_TYPE,
ItemType:		item_Pizza			= INVALID_ITEM_TYPE,
ItemType:		item_Burger			= INVALID_ITEM_TYPE,
// 90
ItemType:		item_BurgerBox		= INVALID_ITEM_TYPE,
ItemType:		item_Taco			= INVALID_ITEM_TYPE,
ItemType:		item_GasCan			= INVALID_ITEM_TYPE,
ItemType:		item_MaskGreen		= INVALID_ITEM_TYPE,
ItemType:		item_HelmArmy		= INVALID_ITEM_TYPE,
ItemType:		item_HelmMoto		= INVALID_ITEM_TYPE,
ItemType:		item_MediumBox		= INVALID_ITEM_TYPE,
ItemType:		item_SmallBox		= INVALID_ITEM_TYPE,
ItemType:		item_LargeBox		= INVALID_ITEM_TYPE,
ItemType:		item_HockeyMask		= INVALID_ITEM_TYPE,
ItemType:		item_Meat			= INVALID_ITEM_TYPE,
// 100
ItemType:		item_DeadLeg		= INVALID_ITEM_TYPE,
ItemType:		item_Torso			= INVALID_ITEM_TYPE,
ItemType:		item_LongPlank		= INVALID_ITEM_TYPE,
ItemType:		item_GreenGloop		= INVALID_ITEM_TYPE,
ItemType:		item_Capsule		= INVALID_ITEM_TYPE,
ItemType:		item_RadioPole		= INVALID_ITEM_TYPE,
ItemType:		item_SignShot		= INVALID_ITEM_TYPE,
ItemType:		item_Mailbox		= INVALID_ITEM_TYPE,
ItemType:		item_Pumpkin		= INVALID_ITEM_TYPE,
ItemType:		item_Nailbat		= INVALID_ITEM_TYPE,
// 110
ItemType:		item_ZorroMask		= INVALID_ITEM_TYPE,
ItemType:		item_Barbecue		= INVALID_ITEM_TYPE,
ItemType:		item_Headlight		= INVALID_ITEM_TYPE,
ItemType:		item_Pills			= INVALID_ITEM_TYPE,
ItemType:		item_AutoInjec		= INVALID_ITEM_TYPE,
ItemType:		item_BurgerBag		= INVALID_ITEM_TYPE,
ItemType:		item_CanDrink		= INVALID_ITEM_TYPE,
ItemType:		item_Detergent		= INVALID_ITEM_TYPE,
ItemType:		item_Dice			= INVALID_ITEM_TYPE,
ItemType:		item_Dynamite		= INVALID_ITEM_TYPE,
ItemType:		item_Flare			= INVALID_ITEM_TYPE,
ItemType:		item_TntPhoneBomb	= INVALID_ITEM_TYPE,
ItemType:		item_ParaBag		= INVALID_ITEM_TYPE,
ItemType:		item_Keypad			= INVALID_ITEM_TYPE,
ItemType:		item_TentPack		= INVALID_ITEM_TYPE,
ItemType:		item_Campfire		= INVALID_ITEM_TYPE,
ItemType:		item_CowboyHat		= INVALID_ITEM_TYPE,
ItemType:		item_TruckCap		= INVALID_ITEM_TYPE,
ItemType:		item_BoaterHat		= INVALID_ITEM_TYPE,
ItemType:		item_BowlerHat		= INVALID_ITEM_TYPE,
// 140
ItemType:		item_PoliceCap		= INVALID_ITEM_TYPE,
ItemType:		item_TopHat			= INVALID_ITEM_TYPE,
ItemType:		item_Ammo9mm		= INVALID_ITEM_TYPE,
ItemType:		item_Ammo50			= INVALID_ITEM_TYPE,
ItemType:		item_AmmoBuck		= INVALID_ITEM_TYPE,
ItemType:		item_Ammo556		= INVALID_ITEM_TYPE,
ItemType:		item_Ammo357		= INVALID_ITEM_TYPE,
ItemType:		item_AmmoRocket		= INVALID_ITEM_TYPE,
ItemType:		item_MolotovEmpty	= INVALID_ITEM_TYPE,
ItemType:		item_Money			= INVALID_ITEM_TYPE,
// 150
ItemType:		item_PowerSupply	= INVALID_ITEM_TYPE,
ItemType:		item_StorageUnit	= INVALID_ITEM_TYPE,
ItemType:		item_Fluctuator		= INVALID_ITEM_TYPE,
ItemType:		item_IoUnit			= INVALID_ITEM_TYPE,
ItemType:		item_FluxCap		= INVALID_ITEM_TYPE,
ItemType:		item_DataInterface	= INVALID_ITEM_TYPE,
ItemType:		item_HackDevice		= INVALID_ITEM_TYPE,
ItemType:		item_PlantPot		= INVALID_ITEM_TYPE,
ItemType:		item_HerpDerp		= INVALID_ITEM_TYPE,
ItemType:		item_Parrot			= INVALID_ITEM_TYPE,
// 160
ItemType:		item_TntTripMine	= INVALID_ITEM_TYPE,
ItemType:		item_IedTimebomb	= INVALID_ITEM_TYPE,
ItemType:		item_IedProxMine	= INVALID_ITEM_TYPE,
ItemType:		item_IedTripMine	= INVALID_ITEM_TYPE,
ItemType:		item_IedPhoneBomb	= INVALID_ITEM_TYPE,
ItemType:		item_EmpTimebomb	= INVALID_ITEM_TYPE,
ItemType:		item_EmpProxMine	= INVALID_ITEM_TYPE,
ItemType:		item_EmpTripMine	= INVALID_ITEM_TYPE,
ItemType:		item_EmpPhoneBomb	= INVALID_ITEM_TYPE,
ItemType:		item_Gyroscope		= INVALID_ITEM_TYPE,
// 170
ItemType:		item_Motor			= INVALID_ITEM_TYPE,
ItemType:		item_StarterMotor	= INVALID_ITEM_TYPE,
ItemType:		item_FlareGun		= INVALID_ITEM_TYPE,
ItemType:		item_PetrolBomb		= INVALID_ITEM_TYPE,
ItemType:		item_CodePart		= INVALID_ITEM_TYPE,
ItemType:		item_LargeBackpack	= INVALID_ITEM_TYPE,
ItemType:		item_LocksmithKit	= INVALID_ITEM_TYPE,
ItemType:		item_XmasHat		= INVALID_ITEM_TYPE,
ItemType:		item_VehicleWeapon	= INVALID_ITEM_TYPE,
ItemType:		item_AdvancedKeypad	= INVALID_ITEM_TYPE,
// 180
ItemType:		item_Ammo9mmFMJ		= INVALID_ITEM_TYPE,
ItemType:		item_AmmoFlechette	= INVALID_ITEM_TYPE,
ItemType:		item_AmmoHomeBuck	= INVALID_ITEM_TYPE,
ItemType:		item_Ammo556Tracer	= INVALID_ITEM_TYPE,
ItemType:		item_Ammo556HP		= INVALID_ITEM_TYPE,
ItemType:		item_Ammo357Tracer	= INVALID_ITEM_TYPE,
ItemType:		item_Ammo762		= INVALID_ITEM_TYPE,
ItemType:		item_AK47Rifle		= INVALID_ITEM_TYPE,
ItemType:		item_M77RMRifle		= INVALID_ITEM_TYPE,
ItemType:		item_DogsBreath		= INVALID_ITEM_TYPE,
// 190
ItemType:		item_Ammo50BMG		= INVALID_ITEM_TYPE,
ItemType:		item_Ammo308		= INVALID_ITEM_TYPE,
ItemType:		item_Model70Rifle	= INVALID_ITEM_TYPE,
ItemType:		item_LenKnocksRifle	= INVALID_ITEM_TYPE,
ItemType:		item_Daypack		= INVALID_ITEM_TYPE,
ItemType:		item_MediumBag		= INVALID_ITEM_TYPE,
ItemType:		item_Rucksack		= INVALID_ITEM_TYPE,
ItemType:		item_SeedBag		= INVALID_ITEM_TYPE,
ItemType:		item_Note			= INVALID_ITEM_TYPE,
ItemType:		item_Tomato			= INVALID_ITEM_TYPE,
// 200
ItemType:		item_HeartShapedBox	= INVALID_ITEM_TYPE,
ItemType:		item_AntiSepBandage	= INVALID_ITEM_TYPE,
ItemType:		item_WoodLog		= INVALID_ITEM_TYPE,
ItemType:		item_Sledgehammer	= INVALID_ITEM_TYPE,
ItemType:		item_RawFish		= INVALID_ITEM_TYPE,
ItemType:		item_Spanner		= INVALID_ITEM_TYPE,
ItemType:		item_Suitcase		= INVALID_ITEM_TYPE,
ItemType:		item_OilCan			= INVALID_ITEM_TYPE,
ItemType:		item_RadioBox		= INVALID_ITEM_TYPE,
ItemType:		item_BigSword		= INVALID_ITEM_TYPE,
// 210
ItemType:		item_Microphone		= INVALID_ITEM_TYPE,
ItemType:		item_Spatula		= INVALID_ITEM_TYPE,
ItemType:		item_Pan			= INVALID_ITEM_TYPE,
ItemType:		item_Knife2			= INVALID_ITEM_TYPE,
ItemType:		item_Meat2			= INVALID_ITEM_TYPE,
ItemType:		item_FryingPan		= INVALID_ITEM_TYPE,
ItemType:		item_PizzaOnly		= INVALID_ITEM_TYPE,
ItemType:		item_BreadLoaf		= INVALID_ITEM_TYPE,
ItemType:		item_Banana			= INVALID_ITEM_TYPE,
ItemType:		item_Orange			= INVALID_ITEM_TYPE,
// 220
ItemType:		item_WheelLock		= INVALID_ITEM_TYPE,
ItemType:		item_RedApple		= INVALID_ITEM_TYPE,
ItemType:		item_Lemon			= INVALID_ITEM_TYPE,
ItemType:		item_PisschBox		= INVALID_ITEM_TYPE,
ItemType:		item_PizzaBox		= INVALID_ITEM_TYPE,
ItemType:		item_MilkBottle		= INVALID_ITEM_TYPE,
ItemType:		item_MilkCarton		= INVALID_ITEM_TYPE,
ItemType:		item_IceCream		= INVALID_ITEM_TYPE,
ItemType:		item_FishyFingers	= INVALID_ITEM_TYPE,
ItemType:		item_IceCreamBars	= INVALID_ITEM_TYPE,
// 230
ItemType:		item_AppleJuice		= INVALID_ITEM_TYPE,
ItemType:		item_OrangeJuice	= INVALID_ITEM_TYPE,
ItemType:		item_Cereal1		= INVALID_ITEM_TYPE,
ItemType:		item_Cereal2		= INVALID_ITEM_TYPE,
ItemType:		item_WrappedMeat	= INVALID_ITEM_TYPE,
ItemType:		item_Beanie			= INVALID_ITEM_TYPE,
ItemType:		item_StrawHat		= INVALID_ITEM_TYPE,
ItemType:		item_WitchesHat		= INVALID_ITEM_TYPE,
ItemType:		item_WeddingCake	= INVALID_ITEM_TYPE,
ItemType:		item_CaptainsCap	= INVALID_ITEM_TYPE,
// 240
ItemType:		item_SwatHelmet		= INVALID_ITEM_TYPE,
ItemType:		item_PizzaHat		= INVALID_ITEM_TYPE,
ItemType:		item_PussyMask		= INVALID_ITEM_TYPE,
ItemType:		item_BoxingGloves	= INVALID_ITEM_TYPE,
ItemType:		item_Briquettes		= INVALID_ITEM_TYPE,
ItemType:		item_MaskRed		= INVALID_ITEM_TYPE,
ItemType:		item_Cross			= INVALID_ITEM_TYPE,
ItemType:		item_RedPanel		= INVALID_ITEM_TYPE,
ItemType:		item_Fork			= INVALID_ITEM_TYPE,
ItemType:		item_Knife3			= INVALID_ITEM_TYPE,
// 250
ItemType:		item_Ketchup		= INVALID_ITEM_TYPE,
ItemType:		item_Mustard		= INVALID_ITEM_TYPE,
ItemType:		item_Boot			= INVALID_ITEM_TYPE,
ItemType:		item_Doormat		= INVALID_ITEM_TYPE,
ItemType:		item_CakeSlice		= INVALID_ITEM_TYPE,
ItemType:		item_Holdall		= INVALID_ITEM_TYPE,
ItemType:		item_GrnApple		= INVALID_ITEM_TYPE,
ItemType:		item_Wine1			= INVALID_ITEM_TYPE,
ItemType:		item_Wine2			= INVALID_ITEM_TYPE,
ItemType:		item_Wine3			= INVALID_ITEM_TYPE,
// 260
ItemType:		item_Whisky			= INVALID_ITEM_TYPE,
ItemType:		item_Champagne		= INVALID_ITEM_TYPE,
ItemType:		item_Ham			= INVALID_ITEM_TYPE,
ItemType:		item_Steak			= INVALID_ITEM_TYPE,
ItemType:		item_Bread			= INVALID_ITEM_TYPE,
ItemType:		item_Broom			= INVALID_ITEM_TYPE,
ItemType:		item_Keycard		= INVALID_ITEM_TYPE,
ItemType:		item_BurntLog		= INVALID_ITEM_TYPE,
ItemType:		item_Padlock		= INVALID_ITEM_TYPE,
ItemType:		item_OilDrum		= INVALID_ITEM_TYPE,
// 270
ItemType:		item_Canister		= INVALID_ITEM_TYPE,
ItemType:		item_ScrapMetal		= INVALID_ITEM_TYPE,
ItemType:		item_RefinedMetal	= INVALID_ITEM_TYPE,
ItemType:		item_Locator		= INVALID_ITEM_TYPE,
ItemType:		item_PlotPole		= INVALID_ITEM_TYPE,
ItemType:		item_ScrapMachine	= INVALID_ITEM_TYPE,
ItemType:		item_RefineMachine	= INVALID_ITEM_TYPE,
ItemType:		item_WaterMachine	= INVALID_ITEM_TYPE,
ItemType:		item_Workbench		= INVALID_ITEM_TYPE,
ItemType:		item_Radio			= INVALID_ITEM_TYPE,
// 280
ItemType:		item_Locker			= INVALID_ITEM_TYPE,
ItemType:		item_GearBox		= INVALID_ITEM_TYPE,
ItemType:		item_ToolBox		= INVALID_ITEM_TYPE,
ItemType:		item_LockBreaker	= INVALID_ITEM_TYPE,
ItemType:		item_PoliceHelm		= INVALID_ITEM_TYPE,
ItemType:		item_ControlBox		= INVALID_ITEM_TYPE,
ItemType:		item_Computer		= INVALID_ITEM_TYPE,
ItemType:		item_TallFrame		= INVALID_ITEM_TYPE,
ItemType:		item_RemoteControl	= INVALID_ITEM_TYPE,
// 290
ItemType:		item_Desk			= INVALID_ITEM_TYPE,
ItemType:		item_Table			= INVALID_ITEM_TYPE,
ItemType:		item_GunCase		= INVALID_ITEM_TYPE,
ItemType:		item_Cupboard		= INVALID_ITEM_TYPE,
ItemType:		item_Barstool		= INVALID_ITEM_TYPE,
ItemType:		item_SmallTable		= INVALID_ITEM_TYPE,
ItemType:		item_BandanaBlue	= INVALID_ITEM_TYPE,
ItemType:		item_BandanaGrey	= INVALID_ITEM_TYPE,
ItemType:		item_BandanaWhite	= INVALID_ITEM_TYPE,
ItemType:		item_BandanaPattern	= INVALID_ITEM_TYPE,

ItemType:		item_GlobalRadio	= INVALID_ITEM_TYPE,
ItemType:		item_Bed			= INVALID_ITEM_TYPE,
ItemType:		item_Clothes		= INVALID_ITEM_TYPE,
ItemType:		item_DiaboMask		= INVALID_ITEM_TYPE,

ItemType:		item_CluckinBellHat1 = INVALID_ITEM_TYPE,
ItemType:		item_Balaclava		 = INVALID_ITEM_TYPE,
ItemType:		item_fire_hat1		 = INVALID_ITEM_TYPE,
ItemType:		item_fire_hat2		 = INVALID_ITEM_TYPE,
ItemType:		item_headphones04	 = INVALID_ITEM_TYPE,
ItemType:		item_ArmyHelmet2	 = INVALID_ITEM_TYPE,
ItemType:		item_CapBack5		= INVALID_ITEM_TYPE,
ItemType:		item_CapBack4		= INVALID_ITEM_TYPE,
ItemType:		item_CapBack3		= INVALID_ITEM_TYPE,
ItemType:		item_CapBack2		= INVALID_ITEM_TYPE,
ItemType:		item_CapBack1		= INVALID_ITEM_TYPE,

ItemType:		item_MetPanel		= INVALID_ITEM_TYPE,
ItemType:		item_MetalGate1		= INVALID_ITEM_TYPE,
ItemType:		item_MetalGate2		= INVALID_ITEM_TYPE,
ItemType:		item_CrateDoor		= INVALID_ITEM_TYPE,
ItemType:		item_CorPanel		= INVALID_ITEM_TYPE,
ItemType:		item_ShipDoor		= INVALID_ITEM_TYPE,
ItemType:		item_InsulDoor		= INVALID_ITEM_TYPE,
ItemType:		item_InsulPanel		= INVALID_ITEM_TYPE,
ItemType:		item_WoodPanel		= INVALID_ITEM_TYPE,
ItemType:		item_MetalFrame		= INVALID_ITEM_TYPE,
ItemType:		item_MetalStand		= INVALID_ITEM_TYPE,
ItemType:		item_MetalBlin		= INVALID_ITEM_TYPE,
ItemType:		item_GarageDoor		= INVALID_ITEM_TYPE,
//ItemType:		item_DupleDoor		= INVALID_ITEM_TYPE,
ItemType:		item_DupleDoor		= INVALID_ITEM_TYPE,
ItemType:		item_DoorBlin		= INVALID_ITEM_TYPE,
ItemType:		item_PortaCofre		= INVALID_ITEM_TYPE,

ItemType:		item_SupplyDrop      = INVALID_ITEM_TYPE,
ItemType:		item_Camouflage      = INVALID_ITEM_TYPE,
ItemType:		item_Map             = INVALID_ITEM_TYPE,
ItemType:		item_GeigerCounter	 = INVALID_ITEM_TYPE;


// VEHICLE TYPES
new stock
	veht_Bobcat,
	veht_Rustler,
	veht_Maverick,
	veht_Comet,
	veht_MountBike,
	veht_Wayfarer,
	veht_Sabre,
	veht_Rhino,
	veht_Barracks,
	veht_Patriot,
	veht_Boxville,
	veht_DFT30,
	veht_Flatbed,
	veht_Rumpo,
	veht_Yankee,
	veht_Yosemite,
	veht_Dinghy,
	veht_Coastguard,
	veht_Launch,
	veht_Reefer,
	veht_Tropic,
	veht_Sentinel,
	veht_Regina,
	veht_Tampa,
	veht_Clover,
	veht_Sultan,
	veht_Huntley,
	veht_Mesa,
	veht_Sandking,
	veht_Bandito,
	veht_Ambulance,
	veht_Faggio,
	veht_Sanchez,
	veht_Freeway,
	veht_Police1,
	veht_Police2,
	veht_Police3,
	veht_Ranger,
	veht_Enforcer,
	veht_FbiTruck,
	veht_Seasparr,
	veht_Blista,
	veht_HPV1000,
	veht_Squalo,
	veht_Marquis,
	veht_Tug,
	veht_BfInject,
	veht_Trailer,
	veht_Steamroll,
	veht_APC30,
	veht_Moonbeam,
	veht_Duneride,
	veht_Doomride,
	veht_Walton,
	veht_Rancher,
	veht_Sadler,
	veht_Journey,
	veht_Bloodring,
	veht_Linerunner,
	veht_Articulat1,
	veht_Firetruck,
	veht_Baggage,
	veht_DavidSabre,
	veht_Truckfort,
	veht_Roadpain,
	veht_Vortex;

new stock
	veht_Burrito,
	veht_Landstalker,
	veht_Bravura,
	veht_Perennial,
	veht_Trashmaster,
	veht_Stretch,
	veht_Manana,
	veht_Voodoo,
	veht_Mule,
	veht_Leviathan,
	veht_Esperanto,
	veht_Taxi,
	veht_Washington,
	veht_MrWhoopee,
	veht_Premier,
	veht_Securicar,
	veht_Banshee,
	veht_Predator,
	veht_Bus,
	veht_Hotknife,
	veht_Monster,
	veht_Pizzaboy,
	veht_PCJ,
	veht_Quad,
	veht_ZR,
	veht_SANNews,
	veht_FBI,
	veht_Hotring,
	veht_Police,
	veht_Super,
	veht_Hustler,
	veht_Phoenix,
	veht_NRG,
	veht_Cabbie,
	veht_Turismo,
	veht_Infernus;

// VEHICLE GROUPS
new stock
	vgroup_Civilian,
	vgroup_Industrial,
	vgroup_Medical,
	vgroup_Police,
	vgroup_Military,
	vgroup_Unique;

public OnScriptInit() {
    //DisableInteriorEnterExits();
    
	UsePlayerPedAnims();
	EnableStuntBonusForAll(false);
	ManualVehicleEngineAndLights();
	AllowInteriorWeapons(true);

// ITEM TYPE DEFINITIONS
// 00
	item_NULL			= DefineItemType("NULL", "", "NULL",				0,		1, .maxhitpoints = 0);
	item_Knuckles		= DefineItemType("Espanador", "", "Knuckles",			331,	1,	90.0, .maxhitpoints = 1);
	item_GolfClub		= DefineItemType("Taco de Golf", "", "GolfClub",			333,	3,	90.0, .maxhitpoints = 3);
	item_Baton			= DefineItemType("Bast�o", "", "Baton",			334,	2,	90.0, .maxhitpoints = 2);
	item_Knife			= DefineItemType("Faca de Combate", "", "Knife",			335,	1,	90.0, .maxhitpoints = 1);
	item_Bat			= DefineItemType("Bast�o de Beisebol", "", "Bat",				336,	3,	90.0, .maxhitpoints = 3);
	item_Spade			= DefineItemType("P�", "", "Spade",			337,	3,	90.0, .maxhitpoints = 3);
	item_PoolCue		= DefineItemType("Taco de Sinuca", "", "PoolCue",			338,	4,	90.0, .maxhitpoints = 4);
	item_Sword			= DefineItemType("Espada", "", "Sword",			339,	4,	90.0, .maxhitpoints = 4);
	item_Chainsaw		= DefineItemType("Serra El�trica", "", "Chainsaw",			341,	5,	90.0, .maxhitpoints = 5);
// 10
	item_Dildo1			= DefineItemType("Dildo", "", "Dildo1",			321,	1,	90.0, .maxhitpoints = 1);
	item_Dildo2			= DefineItemType("Dildo", "", "Dildo2",			322,	1,	90.0, .maxhitpoints = 1);
	item_Dildo3			= DefineItemType("Dildo", "", "Dildo3",			323,	1,	90.0, .maxhitpoints = 1);
	item_Dildo4			= DefineItemType("Dildo", "", "Dildo4",			324,	1,	90.0, .maxhitpoints = 1);
	item_Flowers		= DefineItemType("Flores", "", "Flowers",			325,	2,	90.0, .maxhitpoints = 2);
	item_WalkingCane	= DefineItemType("Bengala", "", "WalkingCane",		326,	3,	90.0, .maxhitpoints = 3);
	item_Grenade		= DefineItemType("Granada", "", "Grenade",			342,	2,	90.0, .maxhitpoints = 2);
	item_Teargas		= DefineItemType("G�s Lacrimog�neo", "", "Teargas",			343,	2,	90.0, .maxhitpoints = 2);
	item_Molotov		= DefineItemType("Molotov", "", "Molotov",			344,	2,	90.0, .maxhitpoints = 2);
	item_NULL2			= DefineItemType("<null>", "", "NULL2",			000,	1,	90.0, .maxhitpoints = 1);
// 20
	item_NULL3			= DefineItemType("<null>", "", "NULL3",			000,	1,	90.0, .maxhitpoints = 1);
	item_NULL4			= DefineItemType("<null>", "", "NULL4",			000,	1,	90.0, .maxhitpoints = 1);
	item_M9Pistol		= DefineItemType("M9", "", "M9Pistol",			346,	1,	90.0, .maxhitpoints = 1);
	item_M9PistolSD		= DefineItemType("M9 SD", "", "M9PistolSD",		347,	1,	90.0, .maxhitpoints = 1);
	item_DesertEagle	= DefineItemType("Desert Eagle", "", "DesertEagle",		348,	1,	90.0, .maxhitpoints = 1);
	item_PumpShotgun	= DefineItemType("Shotgun", "", "PumpShotgun",		349,	3,	90.0, .maxhitpoints = 3);
	item_Sawnoff		= DefineItemType("Sawnoff", "", "Sawnoff",			350,	2,	90.0, .maxhitpoints = 2);
	item_Spas12			= DefineItemType("Spas 12", "", "Spas12",			351,	4,	90.0, .maxhitpoints = 4);
	item_Mac10			= DefineItemType("Mac 10", "", "Mac10",			352,	2,	90.0, .maxhitpoints = 2);
	item_MP5			= DefineItemType("MP5", "", "MP5",				353,	4,	90.0, .maxhitpoints = 4);
// 30
	item_WASR3Rifle		= DefineItemType("WASR-3", "", "WASR3Rifle",		355,	5,	90.0, .maxhitpoints = 5);
	item_M16Rifle		= DefineItemType("M16", "", "M16Rifle",			356,	5,	90.0, .maxhitpoints = 5);
	item_Tec9			= DefineItemType("Tec 9", "", "Tec9",				372,	2,	90.0, .maxhitpoints = 2);
	item_SemiAutoRifle	= DefineItemType("Rifle", "", "SemiAutoRifle",	357,	5,	90.0, .maxhitpoints = 5);
	item_SniperRifle	= DefineItemType("Sniper", "", "SniperRifle",		358,	5,	90.0, .maxhitpoints = 5);
	item_RocketLauncher	= DefineItemType("RPG", "", "RocketLauncher",	359,	6,	90.0, .maxhitpoints = 6);
	item_Heatseeker		= DefineItemType("Heatseeker", "", "Heatseeker",		360,	6,	90.0, .maxhitpoints = 6);
	item_Flamer			= DefineItemType("Flamer", "", "Flamer",			361,	7,	90.0, .maxhitpoints = 7);
	item_Minigun		= DefineItemType("Minigun", "", "Minigun",			362,	7,	90.0, .maxhitpoints = 7);
	item_RemoteBomb		= DefineItemType("Remote Bomb", "", "RemoteBomb",		363,	2,	90.0, .maxhitpoints = 2);
// 40
	item_Detonator		= DefineItemType("Detonator", "", "Detonator",		364,	2,	90.0, .maxhitpoints = 2);
	item_SprayPaint		= DefineItemType("Tinta Spray", "", "SprayPaint",		365,	1,	90.0, .maxhitpoints = 1);
	item_Extinguisher	= DefineItemType("Extintor", "", "Extinguisher",		366,	4,	90.0, .maxhitpoints = 4);
	item_Camera			= DefineItemType("Camera", "", "Camera",			367,	2,	90.0, .maxhitpoints = 2);
	item_NightVision	= DefineItemType("Vis�o Noturna", "", "NightVision",		368,	2,	90.0, .maxhitpoints = 2);
	item_ThermalVision	= DefineItemType("Vis�o T�rmica", "", "ThermalVision",	369,	2,	90.0, .maxhitpoints = 2);
	item_Parachute		= DefineItemType("Paraquedas", "", "Parachute",		371,	6,	90.0, 0.0, 0.0,			0.0,	0.350542, 0.017385, 0.060469, 0.000000, 260.845062, 0.000000, .maxhitpoints = 6);
	item_Medkit			= DefineItemType("Kit M�dico", "", "Medkit",			11736,	1,	0.0, 0.0, 0.0,			0.004,	0.197999, 0.038000, 0.021000,  79.700012, 0.000000, 90.899978, .maxhitpoints = 1);
	item_HardDrive		= DefineItemType("Disco R�gido", "", "HardDrive",		328,	1,	90.0, 0.0, 0.0,			0.0,	.maxhitpoints = 1);
	item_Key			= DefineItemType("Chave", "", "Key",				11746,	1,	90.0, 0.0, 0.0,			0.08,	.maxhitpoints = 1);
// 50
	item_FireworkBox	= DefineItemType("Fogos de Artif�cio", "", "FireworkBox",		2039,	2,	0.0, 0.0, 0.0,			0.0,	0.096996, 0.044811, 0.035688, 4.759557, 255.625167, 0.000000, .maxhitpoints = 2);
	item_FireLighter	= DefineItemType("Isqueiro", "", "FireLighter",		19998,	1,	0.0, 0.0, 0.0,			0.0,	.maxhitpoints = 1);
	item_Timer			= DefineItemType("Temporizador", "", "Timer",			2922,	2,	90.0, 0.0, 0.0,			0.0,	0.231612, 0.050027, 0.017069, 0.000000, 343.020019, 180.000000, .maxhitpoints = 2);
	item_Explosive		= DefineItemType("TNT", "", "Explosive",		1576,	2,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000, .maxhitpoints = 2);
	item_TntTimebomb	= DefineItemType("TNT Cron�metrada", "", "TntTimebomb",		1252,	2,	270.0, 0.0, 0.0,		0.0,	.maxhitpoints = 2);
	item_Battery		= DefineItemType("Bateria", "", "Battery",			1579,	2,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000, .maxhitpoints = 2);
	item_Fusebox		= DefineItemType("Caixa de Fusiveis", "", "Fusebox",			328,	2,	90.0, 0.0, 0.0,			0.0,	.maxhitpoints = 2);
	item_Bottle			= DefineItemType("Garrafa", "", "Bottle",			1543,	1,	0.0, 0.0, 0.0,			0.0,	0.060376, 0.032063, -0.204802, 0.000000, 0.000000, 0.000000, .maxhitpoints = 1);
	item_Sign			= DefineItemType("Placa", "", "Sign",				19471,	6,	0.0, 0.0, 270.0,		0.0,	.longpickup = true, .maxhitpoints = 6);
	item_Armour			= DefineItemType("Colete", "", "Armour",			19515,	4,	90.0, 0.0, 0.0,			0.0,	0.300333, -0.090105, 0.000000, 0.000000, 0.000000, 180.000000, .maxhitpoints = 4);
// 60
	item_Bandage		= DefineItemType("Bandagem Suja", "", "Bandage",			11747,	2,	90.0, 0.0, 0.0,			0.0,	0.076999, 0.059000, 0.000000,  2.799999, -5.600000, 0.000000, .maxhitpoints = 2);
	item_FishRod		= DefineItemType("Vara de Pesca", "", "FishRod",			18632,	6,	90.0, 0.0, 0.0,			0.0,	0.091496, 0.019614, 0.000000, 185.619995, 354.958374, 0.000000, .maxhitpoints = 6);
	item_Wrench			= DefineItemType("Chave de Roda", "", "Wrench",			18633,	2,	0.0, 90.0, 0.0,			0.0,	0.084695, -0.009181, 0.152275, 98.865089, 270.085449, 0.000000, .maxhitpoints = 2);
	item_Crowbar		= DefineItemType("P� de Cabra", "", "Crowbar",			18634,	2,	0.0, 90.0, 0.0,			0.0,	0.066177, 0.011153, 0.038410, 97.289527, 270.962554, 1.114514, .maxhitpoints = 2);
	item_Hammer			= DefineItemType("Martelo", "", "Hammer",			18635,	1,	270.0, 0.0, 0.0,		0.01,	0.000000, -0.008230, 0.000000, 6.428617, 0.000000, 0.000000, .maxhitpoints = 2);
	item_Shield			= DefineItemType("Escudo", "", "Shield",			18637,	8,	0.0, 0.0, 0.0,			0.0,	-0.262389, 0.016478, -0.151046, 103.597534, 6.474381, 38.321765, .maxhitpoints = 8);
	item_Flashlight		= DefineItemType("Lanterna", "", "Flashlight",		18641,	2,	90.0, 0.0, 0.0,			0.0,	0.061910, 0.022700, 0.039052, 190.938354, 0.000000, 0.000000, .maxhitpoints = 2);
	item_StunGun		= DefineItemType("Arma de Choque", "", "StunGun",			18642,	1,	90.0, 0.0, 0.0,			0.0,	0.079878, 0.014009, 0.029525, 180.000000, 0.000000, 0.000000, .maxhitpoints = 1);
	item_LaserPoint		= DefineItemType("Ponteiro Laser", "", "LaserPoint",		18643,	1,	0.0, 0.0, 90.0,			0.0,	0.066244, 0.010838, -0.000024, 6.443027, 287.441467, 0.000000, .maxhitpoints = 1);
	item_Screwdriver	= DefineItemType("Chave de Fenda", "", "Screwdriver",		18644,	1,	90.0, 0.0, 0.0,			0.0,	0.099341, 0.021018, 0.009145, 193.644195, 0.000000, 0.000000, .maxhitpoints = 1);
// 70
	item_MobilePhone	= DefineItemType("Celular", "", "MobilePhone",		18865,	1,	0.0, 0.0, 0.0,			0.0,	0.103904, -0.003697, -0.015173, 94.655189, 184.031860, 0.000000, .maxhitpoints = 1);
	item_Pager			= DefineItemType("Pager", "", "Pager",			18875,	1,	0.0, 0.0, 0.0,			0.0,	0.097277, 0.027625, 0.013023, 90.819244, 191.427993, 0.000000, .maxhitpoints = 1);
	item_Rake			= DefineItemType("Ancinho", "", "Rake",				18890,	6,	90.0, 0.0, 0.0,			0.0,	-0.002599, 0.003984, 0.026356, 190.231231, 0.222518, 271.565185, .maxhitpoints = 6);
	item_HotDog			= DefineItemType("Hotdog", "", "HotDog",			19346,	1,	0.0, 0.0, 0.0,			0.0,	0.088718, 0.035828, 0.008570, 272.851745, 354.704772, 9.342185, .maxhitpoints = 1);
	item_EasterEgg		= DefineItemType("Easter Egg", "", "EasterEgg",		19345,	3,	0.0, 0.0, 0.0,			0.0,	0.000000, 0.000000, 0.000000, 0.000000, 90.000000, 0.000000, .maxhitpoints = 3);
	item_Cane			= DefineItemType("Cano", "", "Cane",				19348,	3,	270.0, 0.0, 0.0,		0.0,	0.041865, 0.022883, -0.079726, 4.967216, 10.411237, 0.000000, .maxhitpoints = 3);
 	item_HandCuffs		= DefineItemType("Algemas", "", "HandCuffs",		19418,	1,	270.0, 0.0, 0.0,		0.0,	0.077635, 0.011612, 0.000000, 0.000000, 90.000000, 0.000000, .maxhitpoints = 1);
	item_Bucket			= DefineItemType("Balde", "", "Bucket",			19468,	2,	0.0, 0.0, 0.0,			0.0,	0.293691, -0.074108, 0.020810, 148.961685, 280.067260, 151.782791, .maxhitpoints = 2);
	item_GasMask		= DefineItemType("M�scara de G�s", "", "GasMask",			19472,	1,	180.0, 0.0, 0.0,		0.0,	0.062216, 0.055396, 0.001138, 90.000000, 0.000000, 180.000000, .maxhitpoints = 1);
	item_Flag			= DefineItemType("Bandeira", "", "Flag",				2993,	3,	0.0, 0.0, 0.0,			0.0,	0.045789, 0.026306, -0.078802, 8.777217, 0.272155, 0.000000, .maxhitpoints = 3);
// 80
	item_DoctorBag		= DefineItemType("Mala de Doutor", "", "DoctorBag",		11738,	3,	0.0, 0.0, 0.0,			0.0046,	0.265000, 0.029000, 0.041000,  0.000000, -99.100021, 0.000000, .maxhitpoints = 3);
	item_Backpack		= DefineItemType("Mochila M�dia", "", "Backpack",			3026,	4,	270.0, 0.0, 90.0,		0.0,	0.470918, 0.150153, 0.055384, 181.319580, 7.513789, 163.436065, .longpickup = true, .maxhitpoints = 4);
	item_Satchel		= DefineItemType("Mochila Pequena", "", "Satchel",			363,	2,	270.0, 0.0, 0.0,		0.0,	0.052853, 0.034967, -0.177413, 0.000000, 261.397491, 349.759826, .longpickup = true, .maxhitpoints = 2);
	item_Wheel			= DefineItemType("Pneu", "", "Wheel",			1079,	5,	0.0, 0.0, 90.0,			0.436,	-0.098016, 0.356168, -0.309851, 258.455596, 346.618103, 354.313049, true, .maxhitpoints = 5);
	item_MotionSense	= DefineItemType("Sensor de Movimento", "", "MotionSense",		327,	1,	0.0, 0.0, 0.0,			0.0,	0.008151, 0.012682, -0.050635, 0.000000, 0.000000, 0.000000, .maxhitpoints = 1);
	item_Accelerometer	= DefineItemType("Aceler�metro", "", "Accelerometer",	327,	1,	0.0, 0.0, 0.0,			0.0,	0.008151, 0.012682, -0.050635, 0.000000, 0.000000, 0.000000, .maxhitpoints = 1);
	item_TntProxMine	= DefineItemType("TNT de Proximidade", "", "TntProxMine",		1576,	2,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000, .maxhitpoints = 2);
	item_IedBomb		= DefineItemType("IED", "", "IedBomb",			2033,	2,	0.0, 0.0, 0.0,			0.0,	0.100000, 0.055999, 0.000000,  -86.099967, -112.099975, 100.099891, .maxhitpoints = 2);
	item_Pizza			= DefineItemType("Pizza", "", "Pizza",			1582,	2,	0.0, 0.0, 0.0,			0.0,	0.320344, 0.064041, 0.168296, 92.941909, 358.492523, 14.915378, .maxhitpoints = 2);
	item_Burger			= DefineItemType("Hamburger", "", "Burger",			2703,	1,	-76.0, 257.0, -11.0,	0.0,	0.066739, 0.041782, 0.026828, 3.703052, 3.163064, 6.946474, .maxhitpoints = 1);
// 90
	item_BurgerBox		= DefineItemType("Hamburger", "", "BurgerBox",		2768,	1,	0.0, 0.0, 0.0,			0.0,	0.107883, 0.093265, 0.029676, 91.010627, 7.522015, 0.000000, .maxhitpoints = 1);
	item_Taco			= DefineItemType("Taco", "", "Taco",				2769,	1,	0.0, 0.0, 0.0,			0.0,	0.069803, 0.057707, 0.039241, 0.000000, 78.877342, 0.000000, .maxhitpoints = 1);
	item_GasCan			= DefineItemType("Gal�o de Gasolina", "", "GasCan",			1650	,	3,	0.0, 0.0, 0.0,			0.27,	0.143402, 0.027548, 0.063652, 0.000000, 253.648208, 0.000000, .maxhitpoints = 3);
	item_MaskGreen		= DefineItemType("M�scara de H�quei", "", "HockeyMaskGreen",	19038,	1,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741, .maxhitpoints = 1);
	item_HelmArmy		= DefineItemType("Capacete do Ex�rcito", "", "HelmArmy",			19106,	2,	345.0, 270.0, 0.0,		0.045,	0.184999, -0.007999, 0.046999, 94.199989, 22.700027, 4.799994, .maxhitpoints = 2);
	item_HelmMoto		= DefineItemType("Capacete", "", "HelmMoto",			18645,	2,	345.0, 270.0, 0.0,		0.045,	0.184999, -0.007999, 0.046999, 94.199989, 22.700027, 4.799994, .maxhitpoints = 2);
	item_MediumBox		= DefineItemType("Caixa M�dia", "", "MediumBox",		3014,	5,	0.0, 0.0, 0.0,			0.1844,	-0.027872, 0.145617, -0.246524, 243.789840, 347.397491, 349.931610, true, .longpickup = true, .maxhitpoints = 5);
	item_SmallBox		= DefineItemType("Caixa Pequena", "", "SmallBox",			2969,	4,	0.0, 0.0, 0.0,			0.0,	0.114177, 0.089762, -0.173014, 247.160079, 354.746368, 79.219100, true, .longpickup = true, .maxhitpoints = 4);
	item_LargeBox		= DefineItemType("Caixa Grande", "", "LargeBox",			1271,	6,	0.0, 0.0, 0.0,			0.3112,	0.050000, 0.334999, -0.327000,  -23.900018, -10.200002, 11.799987, true, .longpickup = true, .maxhitpoints = 6);
	item_HockeyMask		= DefineItemType("M�scara de H�quei", "", "HockeyMask",		19036,	1,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741, .maxhitpoints = 1);
	item_Meat			= DefineItemType("Carne", "", "Meat",				2804,	3,	0.0, 0.0, 0.0,			0.0,	-0.051398, 0.017334, 0.189188, 270.495391, 353.340423, 167.069869, .maxhitpoints = 3);

// 100
	item_DeadLeg		= DefineItemType("Perna", "", "DeadLeg",			2905,	4,	0.0, 0.0, 0.0,			0.0,	0.147815, 0.052444, -0.164205, 253.163970, 358.857666, 167.069869, true, .maxhitpoints = 4);
	item_Torso			= DefineItemType("Corpo", "", "Torso",			2907,	6,	0.0, 0.0, 270.0,		0.0,	0.087207, 0.093263, -0.280867, 253.355865, 355.971557, 175.203552, true, .longpickup = true, .maxhitpoints = 6);
	item_LongPlank		= DefineItemType("Prancha", "", "LongPlank",		2937,	9,	0.0, 0.0, 0.0,			0.0,	0.141491, 0.002142, -0.190920, 248.561920, 350.667724, 175.203552, true, .maxhitpoints = 9);
	item_GreenGloop		= DefineItemType("Gloop Verde", "", "GreenGloop",		2976,	3,	0.0, 0.0, 0.0,			0.0,	0.063387, 0.013771, -0.595982, 341.793945, 352.972686, 226.892105, true, .maxhitpoints = 3);
	item_Capsule		= DefineItemType("C�psula", "", "Capsule",			3082,	3,	0.0, 0.0, 0.0,			0.0,	0.096439, 0.034642, -0.313377, 341.793945, 348.492706, 240.265777, true, .longpickup = true, .maxhitpoints = 3);
	item_RadioPole		= DefineItemType("Receptor", "", "RadioPole",		3221,	3,	0.0, 0.0, 0.0,			0.0,	0.081356, 0.034642, -0.167247, 0.000000, 0.000000, 240.265777, .maxhitpoints = 3);
	item_SignShot		= DefineItemType("Placa", "", "SignShot",			3265,	3,	0.0, 0.0, 0.0,			0.0,	0.081356, 0.034642, -0.167247, 0.000000, 0.000000, 240.265777, .maxhitpoints = 3);
	item_Mailbox		= DefineItemType("Caixa de Correio", "", "Mailbox",			3407,	3,	0.0, 0.0, 0.0,			0.0,	0.081356, 0.034642, -0.167247, 0.000000, 0.000000, 240.265777, .maxhitpoints = 3);
	item_Pumpkin		= DefineItemType("Ab�bora", "", "Pumpkin",			19320,	5,	0.0, 0.0, 0.0,			0.3,	0.105948, 0.279332, -0.253927, 246.858016, 0.000000, 0.000000, true, .maxhitpoints = 5);
	item_Nailbat		= DefineItemType("Bast�o com Prego", "", "Nailbat",			2045,	3,	0.0, 0.0, 0.0,			0.071999, -0.025000, 0.315999, 99.899986, 0.000000, 0.199999, .maxhitpoints = 3);
// 110
	item_ZorroMask		= DefineItemType("M�scara de Zorro", "", "ZorroMask",		18974,	1,	0.0, 0.0, 0.0,			0.0,	0.193932, 0.050861, 0.017257, 90.000000, 0.000000, 0.000000, .maxhitpoints = 1);
	item_Barbecue		= DefineItemType("Churrasqueira", "", "Barbecue",			19831,	6,	0.0, 0.0, 0.0,			-0.0313,0.321000, -0.611000, 0.084999,  66.000007, -163.699981, 80.899917, true, .maxhitpoints = 6);
	item_Headlight		= DefineItemType("Farol", "", "Headlight",		19280,	1,	90.0, 0.0, 0.0,			0.0,	0.107282, 0.051477, 0.023807, 0.000000, 259.073913, 351.287475, .maxhitpoints = 1);
	item_Pills			= DefineItemType("Comprimidos", "", "Pills",			2709,	1,	0.0, 0.0, 0.0,			0.09,	0.044038, 0.082106, 0.000000, 0.000000, 0.000000, 0.000000, .maxhitpoints = 1);
	item_AutoInjec		= DefineItemType("Injetor", "", "AutoInjec",		2711,	1,	90.0, 0.0, 0.0,			0.028,	0.145485, 0.020127, 0.034870, 0.000000, 260.512817, 349.967254, .maxhitpoints = 1);
	item_BurgerBag		= DefineItemType("Hamburger", "", "BurgerBag",		2663,	2,	0.0, 0.0, 0.0,			0.205,	0.320356, 0.042146, 0.049817, 0.000000, 260.512817, 349.967254, .maxhitpoints = 2);
	item_CanDrink		= DefineItemType("Lata", "", "CanDrink",			2601,	1,	0.0, 0.0, 0.0,			0.054,	0.064848, 0.059404, 0.017578, 0.000000, 359.136199, 30.178396, .maxhitpoints = 1);
	item_Detergent		= DefineItemType("Detergente", "", "Detergent",		1644,	1,	0.0, 0.0, 0.0,			0.1,	0.081913, 0.047686, -0.026389, 95.526962, 0.546049, 358.890563, .maxhitpoints = 1);
	item_Dice			= DefineItemType("Dado", "", "Dice",				1851,	5,	0.0, 0.0, 0.0,			0.136,	0.031958, 0.131180, -0.214385, 69.012298, 16.103448, 10.308629, true, .maxhitpoints = 5);
	item_Dynamite		= DefineItemType("Dinamite", "", "Dynamite",			1654,	2,									.maxhitpoints = 2);
// 130
	item_Flare			= DefineItemType("Flare", "", "Flare",			345,	2,									.maxhitpoints = 2);
	item_TntPhoneBomb	= DefineItemType("TNT com Telefone", "", "TntPhoneBomb",		1576,	2,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000, .maxhitpoints = 2);
	item_ParaBag		= DefineItemType("Mochila de Paraquedas", "", "ParaBag",			371,	6,	90.0, 0.0, 0.0,			0.0,	0.350542, 0.017385, 0.060469, 0.000000, 260.845062, 0.000000, .longpickup = true, .maxhitpoints = 6);
	item_Keypad			= DefineItemType("Teclado", "", "Keypad",			19273,	2,	270.0, 0.0, 0.0,		0.0,	0.198234, 0.101531, 0.095477, 0.000000, 343.020019, 0.000000, .maxhitpoints = 2);
	item_TentPack		= DefineItemType("Tenda", "", "TentPack",			1279,	6,	0.0, 0.0, 0.0,			0.0,	0.106261, 0.004634, -0.144552, 246.614654, 345.892211, 258.267395, true, .maxhitpoints = 6);
	item_Campfire		= DefineItemType("Fogueira", "", "Campfire",			19632,	5,	0.0, 0.0, 0.0,			0.0,	0.106261, 0.004634, -0.144552, 246.614654, 345.892211, 258.267395, true, .maxhitpoints = 5);
	item_CowboyHat		= DefineItemType("Chap�u de Caub�i", "", "CowboyHat",		18962,	1,	0.0, 270.0, 0.0,		0.0427,	0.232999, 0.032000, 0.016000, 0.000000, 2.700027, -67.300010, .maxhitpoints = 1);
	item_TruckCap		= DefineItemType("Bon� Caminhoneiro", "", "TruckCap",			18961,	1,	0.0, 0.0, 0.0,			0.01,	0.225000, 0.034000, 0.014000, 81.799942, 7.699998, 179.999954, .maxhitpoints = 1);
	item_BoaterHat		= DefineItemType("Chap�u do Barqueiro", "", "BoaterHat",		18946,	1,	-12.18, 268.14, 0.0,	0.318,	0.225000, 0.034000, 0.014000, 81.799942, 7.699998, 179.999954, .maxhitpoints = 1);
	item_BowlerHat		= DefineItemType("Chap�u Preto", "", "BowlerHat",		18947,	1,	-12.18, 268.14, 0.0,	0.01,	0.225000, 0.034000, 0.014000, 81.799942, 7.699998, 179.999954, .maxhitpoints = 1);
//140
	item_PoliceCap		= DefineItemType("Bon� Policial", "", "PoliceCap",		18636,	1,	0.0, 0.0, 0.0,			0.05,	0.225000, 0.034000, 0.014000, 81.799942, 7.699998, 179.999954, .maxhitpoints = 1);
	item_TopHat			= DefineItemType("Cartola", "", "TopHat",			19352,	2,	0.0, 0.0, 0.0,			-0.023,	0.225000, 0.034000, 0.014000, 81.799942, 7.699998, 179.999954, .maxhitpoints = 2);
	item_Ammo9mm		= DefineItemType("Muni��o 9mm", "", "Ammo9mm",			2037,	2,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741, .maxhitpoints = 2);
	item_Ammo50			= DefineItemType("Muni��o .50", "", "Ammo50",			2037,	2,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741, .maxhitpoints = 2);
	item_AmmoBuck		= DefineItemType("Muni��o de Shotgun", "", "AmmoBuck",			2038,	2,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741, .maxhitpoints = 2);
	item_Ammo556		= DefineItemType("Muni��o 5.56", "", "Ammo556",			2040,	3,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741, .maxhitpoints = 3);
	item_Ammo357		= DefineItemType("Muni��o .357", "", "Ammo357",			2039,	2,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741, .maxhitpoints = 2);
	item_AmmoRocket		= DefineItemType("Rockets", "", "AmmoRocket",		3016,	4,	0.0, 0.0, 0.0,			0.0,	0.081998, 0.081005, -0.195033, 247.160079, 336.014343, 347.379638, true, .maxhitpoints = 4);
	item_MolotovEmpty	= DefineItemType("Molotov Vazio", "", "MolotovEmpty",		344,	1,	-4.0, 0.0, 0.0,			0.1728,	0.000000, -0.004999, 0.000000,  0.000000, 0.000000, 0.000000, .maxhitpoints = 1);
	item_Money			= DefineItemType("Pre-War Money", "", "Money",			1212,	1,	0.0, 0.0, 0.0,			0.0,	0.133999, 0.022000, 0.018000,  -90.700004, -11.199998, -101.600013, .maxhitpoints = 1);
// 150
	item_PowerSupply	= DefineItemType("Fonte de Energia", "", "PowerSupply",		3016,	1,	0.0, 0.0, 0.0,			0.0,	0.255000, -0.054000, 0.032000, -87.499984, -7.599999, -7.999998, .maxhitpoints = 1);
	item_StorageUnit	= DefineItemType("Unidade de Armazenamento", "", "StorageUnit",		328,	1,	0.0, 0.0, 0.0,			0.0,	.maxhitpoints = 1);
	item_Fluctuator		= DefineItemType("Unidade Flutuante", "", "Fluctuator",		343,	1,	0.0, 0.0, 0.0,			0.0,	.maxhitpoints = 1);
	item_IoUnit			= DefineItemType("Unidade I/O", "", "IoUnit",			19273,	1,	270.0, 0.0, 0.0,		0.0,	0.198234, 0.101531, 0.095477, 0.000000, 343.020019, 0.000000, .maxhitpoints = 1);
	item_FluxCap		= DefineItemType("Capacitor de Fluxo", "", "FluxCap",			343,	1,	0.0, 0.0, 0.0,			0.0,	.maxhitpoints = 1);
	item_DataInterface	= DefineItemType("Interface de Dados", "", "DataInterface",	19273,	1,	270.0, 0.0, 0.0,		0.0,	0.198234, 0.101531, 0.095477, 0.000000, 343.020019, 0.000000, .maxhitpoints = 1);
	item_HackDevice		= DefineItemType("Hack Interface", "", "HackDevice",		364,	1,	0.0, 0.0, 0.0,			0.0,	0.134000, 0.080000, -0.037000,  84.299949, 3.399998, 9.400002, .maxhitpoints = 1);
	item_PlantPot		= DefineItemType("Vaso", "", "PlantPot",			2203,	4,	0.0, 0.0, 0.0,			0.138,	-0.027872, 0.145617, -0.246524, 243.789840, 347.397491, 349.931610, true, .longpickup = true, .maxhitpoints = 4);
	item_HerpDerp		= DefineItemType("Unidade Derp", "", "HerpDerp",			19513,	1,	0.0, 0.0, 0.0,			0.0,	0.103904, -0.003697, -0.015173, 94.655189, 184.031860, 0.000000, .maxhitpoints = 1);
	item_Parrot			= DefineItemType("Papagaio", "", "Parrot",			19078,	2,	0.0, 0.0, 0.0,			0.0,	0.131000, 0.021000, 0.005999,  -86.000091, 6.700000, -106.300018, .maxhitpoints = 2);
// 160
	item_TntTripMine	= DefineItemType("Trip Mine TNT", "", "TntTripMine",		1576,	2,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000, .maxhitpoints = 1);
	item_IedTimebomb	= DefineItemType("IED Cron�metrada", "", "IedTimebomb",		2033,	2,	0.0, 0.0, 0.0,			0.0,	0.100000, 0.055999, 0.000000,  -86.099967, -112.099975, 100.099891, .maxhitpoints = 1);
	item_IedProxMine	= DefineItemType("IED de Proximidade", "", "IedProxMine",		2033,	2,	0.0, 0.0, 0.0,			0.0,	0.100000, 0.055999, 0.000000,  -86.099967, -112.099975, 100.099891, .maxhitpoints = 1);
	item_IedTripMine	= DefineItemType("Trip Mine IED", "", "IedTripMine",		2033,	2,	0.0, 0.0, 0.0,			0.0,	0.100000, 0.055999, 0.000000,  -86.099967, -112.099975, 100.099891, .maxhitpoints = 1);
	item_IedPhoneBomb	= DefineItemType("Telefone remoto IED", "", "IedPhoneBomb",		2033,	2,	0.0, 0.0, 0.0,			0.0,	0.100000, 0.055999, 0.000000,  -86.099967, -112.099975, 100.099891, .maxhitpoints = 1);
	item_EmpTimebomb	= DefineItemType("EMP Cron�metrada", "", "EmpTimebomb",		343,	2,	0.0, 0.0, 0.0,			0.0,	.maxhitpoints = 1);
	item_EmpProxMine	= DefineItemType("EMP de Proximidade", "", "EmpProxMine",		343,	2,	0.0, 0.0, 0.0,			0.0,	.maxhitpoints = 1);
	item_EmpTripMine	= DefineItemType("Trip Mine EMP", "", "EmpTripMine",		343,	2,	0.0, 0.0, 0.0,			0.0,	.maxhitpoints = 1);
	item_EmpPhoneBomb	= DefineItemType("Telefone Remoto EMP", "", "EmpPhoneBomb",		343,	2,	0.0, 0.0, 0.0,			0.0,	.maxhitpoints = 1);
	item_Gyroscope		= DefineItemType("Unidade de Girosc�pio", "", "Gyroscope",		1945,	1,	0.0, 0.0, 0.0,			0.0,	0.180000, 0.085000, 0.009000,  -86.099967, -112.099975, 92.699890, .maxhitpoints = 1);
// 170
	item_Motor			= DefineItemType("Motor", "", "Motor",			2006,	2,	0.0, 0.0, 0.0,			0.0,	0.129999, 0.087999, 0.009000,  -86.099967, -112.099975, 92.699890, .maxhitpoints = 2);
	item_StarterMotor	= DefineItemType("Motor de Arranque", "", "StarterMotor",		2006,	2,	0.0, 0.0, 0.0,			0.0,	0.129999, 0.087999, 0.009000,  -86.099967, -112.099975, 92.699890, .maxhitpoints = 2);
	item_FlareGun		= DefineItemType("FlareGun", "", "FlareGun",			2034,	2,	0.0, 0.0, 0.0,			0.0,	0.176000, 0.020000, 0.039999,  89.199989, -0.900000, 1.099991, .maxhitpoints = 2);
	item_PetrolBomb		= DefineItemType("Bomba de Gasolina", "", "PetrolBomb",		1650,	3,	0.0, 0.0, 0.0,			0.27,	0.143402, 0.027548, 0.063652, 0.000000, 253.648208, 0.000000, .maxhitpoints = 3);
	item_CodePart		= DefineItemType("Code", "", "CodePart",			1898,	1,	90.0, 0.0, 0.0,			0.02,	0.086999, 0.017999, 0.075999,  0.000000, 0.000000, 100.700019, .maxhitpoints = 1);
	item_LargeBackpack	= DefineItemType("Mochila Grande", "", "LargeBackpack",	3026,	5,	270.0, 0.0, 90.0,		0.0,	0.470918, 0.150153, 0.055384, 181.319580, 7.513789, 163.436065, false, 0xFFF4A460, .longpickup = true, .maxhitpoints = 5);
	item_LocksmithKit	= DefineItemType("Kit Chaveiro", "", "LocksmithKit",		1210,	3,	0.0, 0.0, 90.0,			0.0,	0.285915, 0.078406, -0.009429, 0.000000, 270.000000, 0.000000, false, 0xFFF4A460, .maxhitpoints = 3);
	item_XmasHat		= DefineItemType("Gorro", "", "XmasHat",			19066,	1,	0.0, 0.0, 0.0,			0.0,	0.135000, -0.018001, -0.002000,  90.000000, 174.500061, 9.600001, .maxhitpoints = 1);
	item_VehicleWeapon	= DefineItemType("VEHICLE_WEAPON", "", "VehicleWeapon",	356,	99,	90.0,							.maxhitpoints = 99);
	item_AdvancedKeypad	= DefineItemType("Teclado Avan�ado", "", "AdvancedKeypad",	19273,	2,	270.0, 0.0, 0.0,		0.0,	0.198234, 0.101531, 0.095477, 0.000000, 343.020019, 0.000000, .maxhitpoints = 2);
// 180
	item_Ammo9mmFMJ		= DefineItemType("Muni��o 9mm", "", "Ammo9mmFMJ",		2037,	2,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741, .maxhitpoints = 2);
	item_AmmoFlechette	= DefineItemType("Muni��o de Shotgun", "", "AmmoFlechette",	2038,	2,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741, .maxhitpoints = 2);
	item_AmmoHomeBuck	= DefineItemType("Muni��o de Shotgun", "", "AmmoHomeBuck",		2038,	2,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741, .maxhitpoints = 2);
	item_Ammo556Tracer	= DefineItemType("Muni��o 5.56", "", "Ammo556Tracer",	2040,	3,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741, .maxhitpoints = 3);
	item_Ammo556HP		= DefineItemType("Muni��o 5.56", "", "Ammo556HP",		2040,	3,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741, .maxhitpoints = 3);
	item_Ammo357Tracer	= DefineItemType("Muni��o .357", "", "Ammo357Tracer",	2039,	2,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741, .maxhitpoints = 2);
	item_Ammo762		= DefineItemType("Muni��o 7.62", "", "Ammo762",			2040,	3,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741, .maxhitpoints = 3);
	item_AK47Rifle		= DefineItemType("AK-47", "", "AK47Rifle",		355,	5,	90.0,							.maxhitpoints = 5);
	item_M77RMRifle		= DefineItemType("M77-RM", "", "M77RMRifle",		357,	5,	90.0,							.maxhitpoints = 5);
	item_DogsBreath		= DefineItemType("Dog's Breath", "", "DogsBreath",		2034,	2,	0.0, 0.0, 0.0,			0.0,	0.176000, 0.020000, 0.039999,  89.199989, -0.900000, 1.099991, .maxhitpoints = 2);
// 190
	item_Ammo50BMG		= DefineItemType("Muni��o .50", "", "Ammo50BMG",		2037,	2,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741, .maxhitpoints = 2);
	item_Ammo308		= DefineItemType("Muni��o .308", "", "Ammo308",			2039,	1,	0.0, 0.0, 0.0,			0.082,	0.221075, 0.067746, 0.037494, 87.375968, 305.182189, 5.691741, .maxhitpoints = 1);
	item_Model70Rifle	= DefineItemType("Model 70", "", "Model70Rifle",		358,	5,	90.0,							.maxhitpoints = 5);
	item_LenKnocksRifle	= DefineItemType("Barret", "", "LenKnocksRifle",	358,	5,	90.0,							.maxhitpoints = 5);
	item_Daypack		= DefineItemType("Daypack", "", "Daypack",			363,	3,	270.0, 0.0, 0.0,		0.0,	0.052853, 0.034967, -0.177413, 0.000000, 261.397491, 349.759826, .longpickup = true, .maxhitpoints = 3);
	item_MediumBag		= DefineItemType("Mochila Larga", "", "MediumBag",		3026,	4,	270.0, 0.0, 90.0,		0.0,	0.470918, 0.150153, 0.055384, 181.319580, 7.513789, 163.436065, false, 0xFFFFFF00, .longpickup = true, .maxhitpoints = 4);
	item_Rucksack		= DefineItemType("Mochila de Acampamento", "", "Rucksack",			19559,	5,	91.0, -4.0, 0.0,		0.16,	0.350542, 0.017385, 0.060469, 0.000000, 260.845062, 0.000000, .longpickup = true, .maxhitpoints = 5);
	item_SeedBag		= DefineItemType("Saco de Sementes", "", "SeedBag",			2663,	2,	0.0, 0.0, 0.0,			0.205,	0.320356, 0.042146, 0.049817, 0.000000, 260.512817, 349.967254, false, 0xFFF4A460, .maxhitpoints = 2);
	item_Note			= DefineItemType("Nota", "", "Note",				2953,	1,	0.0, 0.0, 0.0,			0.0,	0.083999, 0.022000, -0.013000,  -82.300018, -14.900006, -83.200042, false, 0xCAFFFFFF, .maxhitpoints = 1);
	item_Tomato			= DefineItemType("Tomate", "", "Tomato",			19577,	1,	170.0, 0.0, 0.0,		0.03,	0.054000, 0.055999, 0.013999, 0.000000, 0.000003, 0.000003, .maxhitpoints = 1);
// 200
	item_HeartShapedBox	= DefineItemType("Mochila Cora��o", "", "HeartShapedBox",	1240,	1,	90.0, 0.0, 0.0,			-0.02,	0.171999, 0.077999, -0.016999,  0.000000, 0.000000, 10.200000, .longpickup = true, .maxhitpoints = 1);
	item_AntiSepBandage	= DefineItemType("Bandagem", "", "AntiSepBandage",	11748,	2,	0.0, 0.0, 0.0,			0.01,	0.072000, 0.041999, 0.000000,  90.299995, 1.500011, 103.599960, .maxhitpoints = 2);
	item_WoodLog		= DefineItemType("Madeiras", "", "WoodLog",			19793,	1,	0.0, 0.0, 0.0,			0.000,	0.034999, 0.018998, -0.150000,  -74.199989, -110.000022, -54.900020, .maxhitpoints = 1);
	item_Sledgehammer	= DefineItemType("Marreta", "", "Sledgehammer",		19631,	6,	0.0, 90.0, 0.0,			0.000,	0.075000, -0.004000, 0.269000,  -84.600021, -70.899993, 0.000000, .maxhitpoints = 7);
	item_RawFish		= DefineItemType("Peixe", "", "RawFish",			19630,	3,	0.0, 0.0, 0.0,			0.000,	0.047000, 0.021999, 0.083000,  -84.299980, -75.299972, 103.100028, .maxhitpoints = 9);
	item_Spanner		= DefineItemType("Chave Inglesa", "", "Spanner",			19627,	1,	0.0, 0.0, 0.0,			0.000,	0.073000, 0.022000, 0.035000,  -84.299980, -75.299972, 103.100028, .maxhitpoints = 1);
	item_Suitcase		= DefineItemType("Mala de Viagem", "", "Suitcase",			19624,	4,	0.0, 0.0, 0.0,			0.371,	0.086000, 0.022000, 0.022000,  -84.299980, -75.299972, 103.100028, .longpickup = true, .maxhitpoints = 4);
	item_OilCan			= DefineItemType("Lata de �leo", "", "OilCan",			19621,	2,	0.0, 0.0, 0.0,			0.060,	0.075999, 0.022000, 0.011000,  7.800007, -11.899963, 81.800025, .maxhitpoints = 2);
	item_RadioBox		= DefineItemType("Pequeno Amp�re", "", "RadioBox",			19612,	8,	0.0, 0.0, 0.0,			-0.020,	-0.090000, 0.132999, -0.202000,  63.499916, 108.599983, 95.499877, .maxhitpoints = 8);
	item_BigSword		= DefineItemType("Espada Grande", "", "BigSword",			19590,	3,	0.0, 90.0, 0.0,			-0.019,	0.069000, 0.030999, 0.012000,  53.499919, -99.100090, 146.499862, .maxhitpoints = 3);
// 210
	item_Microphone		= DefineItemType("Microfone", "", "Microphone",		19610,	1,	0.0, 0.0, 0.0,			0.000,	0.078000, 0.030999, 0.012000,  53.499919, -99.100090, -46.300144, .maxhitpoints = 1);
	item_Spatula		= DefineItemType("Esp�tula", "", "Spatula",			19586,	1,	0.0, 0.0, 0.0,			0.000,	0.078000, 0.030999, 0.012000,  53.499919, -99.100090, 150.899887, .maxhitpoints = 1);
	item_Pan			= DefineItemType("Panela", "", "Pan",				19584,	2,	0.0, 0.0, 0.0,			0.100,	0.078000, 0.030999, 0.012000,  39.499954, -77.500083, 128.299819, .maxhitpoints = 2);
	item_Knife2			= DefineItemType("Faca de Cozinha", "", "Knife2",			19583,	1,	0.0, 0.0, 0.0,			0.000,	0.085999, 0.024999, 0.000000,  -94.000007, 179.299957, 0.599997, .maxhitpoints = 1);
	item_Meat2			= DefineItemType("Carne", "", "Meat2",			19582,	1,	0.0, 0.0, 0.0,			0.000,	0.044000, 0.017999, 0.099000,  90.099960, 7.200009, 1.799715, .maxhitpoints = 1);
	item_FryingPan		= DefineItemType("Frigideira", "", "FryingPan",		19581,	2,	0.0, 0.0, 0.0,			-0.028,	0.078000, 0.017999, 0.025000,  -29.900056, -88.800018, 59.299705, .maxhitpoints = 2);
	item_PizzaOnly		= DefineItemType("Pizza", "", "PizzaOnly",		19580,	3,	0.0, 0.0, 0.0,			0.000,	0.078000, 0.017999, 0.025000,  -29.900056, -88.800018, 59.299705, .maxhitpoints = 3);
	item_BreadLoaf		= DefineItemType("Fatia de P�o", "", "BreadLoaf",		19579,	2,	0.0, 0.0, 0.0,			0.000,	0.232000, 0.053998, 0.047000,  83.599945, -56.300045, 100.099731, .maxhitpoints = 2);
	item_Banana			= DefineItemType("Banana", "", "Banana",			19578,	1,	0.0, 0.0, 0.0,			0.000,	0.059000, 0.017998, 0.026000,  86.399932, -161.300003, 83.699714, .maxhitpoints = 1);
	item_Orange			= DefineItemType("Laranja", "", "Orange",			19574,	1,	0.0, 0.0, 0.0,			0.000,	0.078000, 0.040998, 0.009000,  86.399932, -161.300003, 83.699714, .maxhitpoints = 1);
// 220
	item_WheelLock		= DefineItemType("Corrente", "", "WheelLock",		2680,	1,	0.0, 0.0, 0.0,			0.000,	0.215000, -0.037999, 0.059000,  -48.999996, -110.599960, -54.000000, .maxhitpoints = 1);
	item_RedApple		= DefineItemType("Ma�� Vermelha", "", "RedApple",			19575,	1,	170.0, 0.0, 0.0,		0.03,	0.100000, 0.039000, 0.018000,  4.400032, -2.300116, 138.699905, .maxhitpoints = 1);
	item_Lemon			= DefineItemType("Lim�o", "", "Lemon",			19574,	1,	170.0, 0.0, 0.0,		0.03,	0.000003, 0.000003, 0.000003, 0.000000, 0.000003, 0.000003, .maxhitpoints = 1);
	item_PisschBox		= DefineItemType("Caixa Pissh", "", "PisschBox",		19572,	2,	0.0, 0.0, 0.0,			0.0363,	-0.001000, -0.043999, -0.167999,  -110.499992, -12.499979, 83.099990, .maxhitpoints = 2);
	item_PizzaBox		= DefineItemType("Caixa de Pizza", "", "PizzaBox",			19571,	3,	90.0, 0.0, 0.0,			0.0,	0.263000, 0.057999, -0.184000,  0.000000, 0.000000, 0.000000, .maxhitpoints = 3);
	item_MilkBottle		= DefineItemType("Garrafa de Leite", "", "MilkBottle",		19570,	1,	0.0, 0.0, 0.0,			0.0199,	0.069000, 0.043999, -0.276000,  0.000000, 0.000000, 0.000000, .maxhitpoints = 1);
	item_MilkCarton		= DefineItemType("Caixa de Leite", "", "MilkCarton",		19569,	1,	0.0, 0.0, 0.0,			0.0298,	0.128000, 0.083999, -0.129000,  0.000000, 0.000000, 0.000000, .maxhitpoints = 1);
	item_IceCream		= DefineItemType("Sorvete", "", "IceCream",			19568,	1,	0.0, 0.0, 0.0,			0.0308,	0.233000, 0.152999, 0.056999,  95.200012, -3.199998, 11.200000, .maxhitpoints = 1);
	item_FishyFingers	= DefineItemType("Dedos de peixe", "", "FishyFingers",		19566,	1,	-91.0, 0.0, 0.0,		-0.009,	0.272000, 0.000999, 0.164999,  -161.999969, 8.400005, -1.699998, .maxhitpoints = 1);
	item_IceCreamBars	= DefineItemType("Bares de sorvete", "", "IceCreamBars",		19565,	1,	-90.0, 0.0, 0.0,		-0.01,	0.272000, 0.000999, 0.180999,  -161.999969, 8.400005, -1.699998, .maxhitpoints = 1);
// 230
	item_AppleJuice		= DefineItemType("Suco de Ma��", "", "AppleJuice",		19564,	1,	0.0, 0.0, 0.0,			0.039,	0.099000, 0.009999, 0.145999,  -161.999969, 8.400005, -1.699998, .maxhitpoints = 1);
	item_OrangeJuice	= DefineItemType("Suco de Laranja", "", "OrangeJuice",		19563,	1,	0.0, 0.0, 0.0,			0.026,	0.177000, 0.088999, -0.118000,  -161.999969, -165.499984, -1.699998, .maxhitpoints = 1);
	item_Cereal1		= DefineItemType("Cereal", "", "Cereal1",			19562,	1,	0.0, 0.0, 0.0,			0.022,	0.245000, 0.123999, -0.175000,  -161.999969, -165.499984, -1.699998, .maxhitpoints = 1);
	item_Cereal2		= DefineItemType("Cereal", "", "Cereal2",			19561,	1,	0.0, 0.0, 0.0,			0.022,	0.245000, 0.123999, -0.175000,  -161.999969, -165.499984, -1.699998, .maxhitpoints = 1);
	item_WrappedMeat	= DefineItemType("Carne Embrulhada", "", "WrappedMeat",		19560,	1,	0.0, 0.0, 0.0,			0.0,	0.223000, 0.052999, 0.064999,  -70.300064, 165.600082, 10.500000, .maxhitpoints = 1);
	item_Beanie			= DefineItemType("Gorro", "", "Beanie",			19554,	1,	-25.0, -91.0, -91.0,	0.0,	0.138000, 0.046000, 0.000000,  -107.600021, 174.399978, 0.000000, .maxhitpoints = 1);
	item_StrawHat		= DefineItemType("Chap�u de palha", "", "StrawHat",			19553,	1,	0.0, -105.0, 0.0,		-0.039,	0.210999, 0.018000, 0.053999,  -107.600021, 81.099998, 0.000000, .maxhitpoints = 1);
	item_WitchesHat		= DefineItemType("Chap�u das Bruxas", "", "WitchesHat",		19528,	1,	0.0, -84.0, 0.0,		0.0,	0.290000, 0.018000, 0.053999,  -107.600021, 102.500000, 0.000000, .maxhitpoints = 1);
	item_WeddingCake	= DefineItemType("Bolo de Casamento", "", "WeddingCake",		19525,	1,	0.0, 0.0, 0.0,			0.036,	0.076999, 0.032000, -0.126000,  -179.400054, -175.200042, -2.499999, .maxhitpoints = 1);
	item_CaptainsCap	= DefineItemType("Bon� do Capit�o", "", "CaptainsCap",		19520,	1,	0.0, -91.0, 11.0,		0.0,	0.157999, 0.043000, 0.020999,  76.099891, -100.200050, -2.499999, .maxhitpoints = 1);
// 240
	item_SwatHelmet		= DefineItemType("Capacete da SWAT", "", "SwatHelmet",		19514,	1,	-22.0, -98.0, 2.0,		0.0,	0.186999, 0.043000, 0.029999,  76.099891, -68.100074, -2.499999, .maxhitpoints = 1);
	item_PizzaHat		= DefineItemType("Chap�u de Pizzaiolo", "", "PizzaHat",			19558,	1,	2.0, -93.0, 0.0,		0.0,	0.186999, 0.043000, 0.012999,  9.900009, -175.300125, -94.199996, .maxhitpoints = 1);
	item_PussyMask		= DefineItemType("M�scara de Bichano", "", "PussyMask",		19557,	1,	0.0, 265.0, 0.0,		-0.059,	0.146999, -0.009999, 0.012999,  5.600010, -84.900131, -109.300079, .maxhitpoints = 1);
	item_BoxingGloves	= DefineItemType("Luvas de Boxe", "", "BoxingGloves",		19556,	1,	-91.0, 0.0, 0.0,		0.0,	0.146999, 0.011000, 0.028000,  8.100008, -100.500106, -17.300100, .maxhitpoints = 1);
	item_Briquettes		= DefineItemType("Briquetes", "", "Briquettes",		19573,	1,	0.0, 0.0, 0.0,			0.036,	0.616000, -0.044999, 0.120000,  8.100008, -100.500106, 6.299896, .maxhitpoints = 1);
	item_MaskRed		= DefineItemType("M�scara de H�quei", "", "RedMask",			19037,	1,	-76.0, 0.0, 0.0,		0.0,	0.371000, -0.044999, 0.040000,  8.100008, -100.500106, 6.299896, .maxhitpoints = 1);
	item_Cross			= DefineItemType("Cruz", "", "Cross",			11712,	1,	0.0, 90.0, 90.0,		0.0,	0.087000, 0.037000, 0.061000,  8.100008, -1.800116, 6.299896, .maxhitpoints = 1);
	item_RedPanel		= DefineItemType("Painel Vermelho", "", "RedPanel",			11713,	5,	0.0, -90.0, 90.0,		0.0,	0.001000, 0.268000, -0.258999,  -20.299985, -2.300116, 17.399898, true, .maxhitpoints = 5);
	item_Fork			= DefineItemType("Garfo", "", "Fork",				11715,	1,	0.0, 0.0, 0.0,			0.0,	0.086000, 0.039000, 0.068000,  88.800025, -2.300116, 1.699898, .maxhitpoints = 1);
	item_Knife3			= DefineItemType("Faca", "", "Knife3",			11716,	1,	0.0, 0.0, 0.0,			0.0,	0.067000, 0.006999, 0.064999,  -74.700141, 164.000076, -165.100036, .maxhitpoints = 1);
// 250
	item_Ketchup		= DefineItemType("Ketchup", "", "Ketchup",			11722,	1,	0.0, 0.0, 0.0,			-0.1,	0.100000, 0.077000, 0.041000,  4.400032, -2.300116, 138.699905, .maxhitpoints = 1);
	item_Mustard		= DefineItemType("Mostarda", "", "Mustard",			11723,	1,	0.0, 0.0, 0.0,			-0.1,	0.100000, 0.077000, 0.041000,  4.400032, -2.300116, 138.699905, .maxhitpoints = 1);
	item_Boot			= DefineItemType("Bota", "", "Boot",				11735,	2,	0.0, 0.0, 0.0,			0.02,	0.193000, 0.030000, -0.266999,  -4.899966, -6.200114, 84.699867, .maxhitpoints = 2);
	item_Doormat		= DefineItemType("Capacho", "", "Doormat",			11737,	3,	0.0, 0.0, 0.0,			0.02,	0.441000, 0.027000, 0.017999,  96.300025, -2.500113, 97.699829, .maxhitpoints = 3);
	item_CakeSlice		= DefineItemType("Fatia de bolo", "", "CakeSlice",		11742,	1,	0.0, 0.0, 0.0,			0.026,	0.107000, 0.052000, 0.017999,  96.300025, -87.400100, 7.399830, .maxhitpoints = 1);
	item_Holdall		= DefineItemType("Bolsa de Viagem", "", "Holdall",			11745,	4,	0.0, 0.0, 0.0,			0.113,	-0.015999, 0.150000, -0.187000,  74.200035, -161.400177, -6.000168, true, .longpickup = true, .maxhitpoints = 4);
	item_GrnApple		= DefineItemType("Ma�� Verde", "", "GrnApple",			19576,	1,	0.0, 0.0, 0.0,			0.03,	0.107000, 0.039000, 0.014999,  -168.799911, -161.400177, -0.400169, .maxhitpoints = 1);
	item_Wine1			= DefineItemType("Vinho", "", "Wine1",			19820,	1,	0.0, 0.0, 0.0,			0.0,	0.169000, 0.053000, -0.506999,  -178.499954, -170.700210, -10.200168, .maxhitpoints = 1);
	item_Wine2			= DefineItemType("Vinho", "", "Wine2",			19821,	1,	0.0, 0.0, 0.0,			0.0,	0.169000, 0.053000, -0.506999,  -178.499954, -170.700210, -10.200168, .maxhitpoints = 1);
	item_Wine3			= DefineItemType("Vinho", "", "Wine3",			19822,	1,	0.0, 0.0, 0.0,			0.0,	0.169000, 0.053000, -0.423999,  -178.499954, -170.700210, -10.200168, .maxhitpoints = 1);
// 260
	item_Whisky			= DefineItemType("U�sque", "", "Whisky",			19823,	1,	0.0, 0.0, 0.0,			0.0,	0.132000, 0.041000, -0.286999,  -178.499954, -170.700210, -10.200168, .maxhitpoints = 1);
	item_Champagne		= DefineItemType("Champanhe", "", "Champagne",		19824,	1,	0.0, 0.0, 0.0,			0.0,	0.132000, 0.041000, -0.346999,  -178.499954, -170.700210, -10.200168, .maxhitpoints = 1);
	item_Ham			= DefineItemType("Presunto", "", "Ham",				19847,	1,	0.0, 0.0, 0.0,			0.0,	0.085000, 0.024000, 0.044000,  -77.199935, -167.100173, 15.799836, .maxhitpoints = 1);
	item_Steak			= DefineItemType("Bife", "", "Steak",			19882,	1,	0.0, 0.0, 0.0,			-0.02,	0.148000, 0.024000, 0.044000,  -77.199935, -167.100173, 15.799836, .maxhitpoints = 1);
	item_Bread			= DefineItemType("P�o", "", "Bread",			19883,	1,	0.0, 0.0, 0.0,			-0.02,	0.148000, 0.024000, 0.026000,  -77.199935, 174.499786, 15.799836, .maxhitpoints = 1);
	item_Broom			= DefineItemType("Vassoura", "", "Broom",			19622,	4,	91.5, 0.0, 0.0,			0.0,	0.051000, -0.024999, 0.358000,  11.400080, 174.499786, 18.599828, .maxhitpoints = 4);
	item_Keycard		= DefineItemType("Cart�o de Acesso", "", "Keycard",			19792,	1,	0.0, 0.0, 0.0,			0.0,	0.081000, 0.039000, 0.014000,  95.100082, 174.499786, 83.799827, .maxhitpoints = 1);
	item_BurntLog		= DefineItemType("Madeiras Queimadas", "", "BurntLog",			19793,	3,	0.0, 0.0, 0.0,			0.046,	0.079000, 0.039000, -0.194999,  73.600059, -175.100250, 83.199836, true, 0xFF000000, .maxhitpoints = 3);
	item_Padlock		= DefineItemType("Cadeado", "", "Padlock",			19804,	1,	90.0, 0.0, 0.0,			-0.016,	0.160000, 0.035000, 0.019000,  75.900054, -91.200210, 85.499847, .maxhitpoints = 1);
	item_OilDrum		= DefineItemType("Tambor de �leo", "", "OilDrum",			19812,	5,	0.0, 0.0, 0.0,			0.468,	0.053000, 0.480999, -0.340999,  -109.899971, -10.700182, 98.799865, true, .maxhitpoints = 5);
// 270
	item_Canister		= DefineItemType("Vasilha", "", "Canister",			19816,	5,	0.0, 0.0, 0.0,			0.218,	0.081000, 0.032999, -0.195999,  164.900070, 8.099815, 96.199882, true, .maxhitpoints = 5);
	item_ScrapMetal		= DefineItemType("Ferro Velho", "", "ScrapMetal",		19941,	1,	0.0, 0.0, 0.0,			0.218,	0.110999, 0.031000, 0.031999,  -101.400001, 3.700001, -97.499969, false, 0xFF4D2525, .maxhitpoints = 1);
	item_RefinedMetal	= DefineItemType("Metal Refinado", "", "RefinedMetal",		19941,	1,	0.0, 0.0, 0.0,			0.218,	0.110999, 0.031000, 0.031999,  -101.400001, 3.700001, -97.499969, false, 0xFFE35454, .maxhitpoints = 1);
	item_Locator		= DefineItemType("Localizador", "", "Locator",			2967,	1,	0.0, 0.0, 0.0,			0.0,	0.095999, 0.064999, 0.000000, -1.300025, -67.899948, -92.999908, .maxhitpoints = 1);
	item_PlotPole		= DefineItemType("P�lo", "", "PlotPole",			3221,	3,	0.0, 0.0, 0.0,			0.0,	0.081356, 0.034642, -0.167247, 0.000000, 0.000000, 240.265777, .maxhitpoints = 3);
	item_ScrapMachine	= DefineItemType("M�quina de Sucata", "", "ScrapMachine",		920,	12,	0.0, 0.0, 0.0,			0.4344,	.maxhitpoints = 12);
	item_RefineMachine	= DefineItemType("M�quina de Refina��o", "", "RefineMachine",	943,	12,	0.0, 0.0, 0.0,			0.7208,	.maxhitpoints = 12);
	item_WaterMachine	= DefineItemType("Purificador de �gua", "", "WaterMachine",		958,	12,	0.0, 0.0, 0.0,			0.8195,	.maxhitpoints = 12);
	item_Workbench		= DefineItemType("Mesa de Trabalho", "", "Workbench",		936,	12,	0.0, 0.0, 0.0,			0.4434,	.longpickup = true, .maxhitpoints = 12);
	item_Radio			= DefineItemType("Radio", "", "Radio",			2966,	1,	0.0, 0.0, 0.0,			0.0,	0.073999, 0.066999, -0.057000,  101.699996, -151.699951, 0.000000, .maxhitpoints = 1);
// 280
	item_Locker			= DefineItemType("Arm�rio", "", "Locker",			11729,	12,	0.0, 0.0, 0.0,			0.0,	.longpickup = true,	.maxhitpoints = 10);
	item_GearBox		= DefineItemType("Caixinha", "", "GearBox",			19918,	5,	0.0, 0.0, 0.0,			-0.0361,0.073999, -0.039000, -0.169000,  73.400024, -173.499984, 80.899993, .longpickup = true, .maxhitpoints = 4);
	item_ToolBox		= DefineItemType("Caixa de Ferramentas", "", "ToolBox",			19921,	7,	0.0, 0.0, 0.0,			0.0541,	-0.209000, 0.052999, -0.231000,  73.400024, -173.499984, 80.899993, true, .longpickup = true, .maxhitpoints = 8);
	item_LockBreaker	= DefineItemType("Gazua Eletr�nica", "", "LockBreaker",		1952,	2,	0.0, 0.0, 0.0,			0.001,	0.098000, 0.039999, 0.085000,  -94.900032, -177.600021, 18.499980, .maxhitpoints = 2);
	item_PoliceHelm		= DefineItemType("Capacete de Policial", "", "PoliceHelm",		19200,	1,	0.0, 0.0, 0.0,			0.05,	0.173000, -0.010000, -0.020000,  -90.299995, 0.000000, 0.000000, .maxhitpoints = 1);
	item_ControlBox		= DefineItemType("Caixa de Controle", "", "ControlBox",		1958,	2,	0.0, 0.0, 0.0,			0.0211);
	item_Computer		= DefineItemType("Computador", "", "Computer",			1719,	2,	0.0, 0.0, 0.0,			0.0251);
	item_TallFrame		= DefineItemType("Estrutura de Metal", "", "TallFrame",		3025,	14,	0.0, 180.0, 0.0,		0.0);
	item_RemoteControl	= DefineItemType("Controlador IR", "", "RemoteControl",	19920,	1,	4.0, 0.0, 0.0,			-0.0200);
// 290
	item_Desk			= DefineItemType("Escrivaninha", "", "Desk",				2180,	14,	0.0, 0.0, 0.0,			-0.0320, .maxhitpoints = 14, .longpickup = true);
	item_Table			= DefineItemType("Mesa", "", "Table",			2115,	14,	0.0, 0.0, 0.0,			-0.0280, .maxhitpoints = 14, .longpickup = true);
	item_GunCase		= DefineItemType("Caixa de Madeira", "", "GunCase",			2046,	12,	0.0, 0.0, 0.0,			0.5, .maxhitpoints = 12, .longpickup = true);
	item_Cupboard		= DefineItemType("Arm�rio", "", "Cupboard",			19932,	12,	0.0, 0.0, 90.0,			0.0, .maxhitpoints = 12, .longpickup = true);
	item_Barstool		= DefineItemType("Tamborete", "", "Barstool",			1805,	8,	0.0, 0.0, 0.0,			0.22, .maxhitpoints = 8, .longpickup = true);
	item_SmallTable		= DefineItemType("Mesa Pequena", "", "SmallTable",		2346,	10,	0.0, 0.0, 0.0,			-0.03, .maxhitpoints = 10, .longpickup = true);
	item_BandanaBlue	= DefineItemType("Bandana", "", "BandanaBl",		18917,	1,	0.0, 0.0, 0.0,			0.0,	0.095999, 0.064999, 0.000000, -1.300025, -67.899948, -92.999908);
	item_BandanaGrey	= DefineItemType("Bandana", "", "BandanaGr",		18918,	1,	0.0, 0.0, 0.0,			0.0,	0.095999, 0.064999, 0.000000, -1.300025, -67.899948, -92.999908);
	item_BandanaWhite	= DefineItemType("Bandana", "", "BandanaWh",		18919,	1,	0.0, 0.0, 0.0,			0.0,	0.095999, 0.064999, 0.000000, -1.300025, -67.899948, -92.999908);
	item_BandanaPattern	= DefineItemType("Bandana", "", "BandanaPat",		18920,	1,	0.0, 0.0, 0.0,			0.0,	0.095999, 0.064999, 0.000000, -1.300025, -67.899948, -92.999908);
	item_Bed			= DefineItemType("Cama", "", "Bed",				1800,	12, 0.0, 0.0, 0.0, 0.0,    	0.0, 0.0, 0.0,     0.0, 0.0, 0.0, .longpickup = true, .maxhitpoints = 10);
    item_Clothes		= DefineItemType("Roupas", "", "Clothes",			2891,	2,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000, .maxhitpoints = 2);
    item_DiaboMask		= DefineItemType("M�scara do Diabo", "", "DiaboMask",		11704,	1,	180.0, 0.0, 0.0,		0.0,	0.062216, 0.055396, 0.001138, 90.000000, 0.000000, 180.000000, .maxhitpoints = 1);
    item_CluckinBellHat1 = DefineItemType("M�scara de Galinha", "", "CluckinBellHat1",	19137,	1,	180.0, 0.0, 0.0,		0.0,	0.062216, 0.055396, 0.001138, 90.000000, 0.000000, 180.000000, .maxhitpoints = 1);
    item_Balaclava		= DefineItemType("M�scara de Assaltante", "", "Balaclava",		19801,	1,	180.0, 0.0, 0.0,		0.0,	0.062216, 0.055396, 0.001138, 90.000000, 0.000000, 180.000000, .maxhitpoints = 1);
    item_fire_hat1		= DefineItemType("Chap�u de Bombeiro", "", "fire_hat1",		19330,	1,	180.0, 0.0, 0.0,		0.0,	0.062216, 0.055396, 0.001138, 90.000000, 0.000000, 180.000000, .maxhitpoints = 1);
    item_fire_hat2		= DefineItemType("Chap�u de Bombeiro", "", "fire_hat2",		19331,	1,	180.0, 0.0, 0.0,		0.0,	0.062216, 0.055396, 0.001138, 90.000000, 0.000000, 180.000000, .maxhitpoints = 1);
    item_headphones04	= DefineItemType("Fone de Ouvido", "", "headphones04",		19424,	1,	180.0, 0.0, 0.0,		0.0,	0.062216, 0.055396, 0.001138, 90.000000, 0.000000, 180.000000, .maxhitpoints = 1);
    item_ArmyHelmet2	= DefineItemType("Capacete do Ex�rcito", "", "ArmyHelmet2",		19102,	1,	180.0, 0.0, 0.0,		0.0,	0.062216, 0.055396, 0.001138, 90.000000, 0.000000, 180.000000, .maxhitpoints = 1);
    item_CapBack5		= DefineItemType("Bon�", "", "CapBack5",			18943,	1,	180.0, 0.0, 0.0,		0.0,	0.062216, 0.055396, 0.001138, 90.000000, 0.000000, 180.000000, .maxhitpoints = 1);
    item_CapBack4		= DefineItemType("Bon�", "", "CapBack4",			18942,	1,	180.0, 0.0, 0.0,		0.0,	0.062216, 0.055396, 0.001138, 90.000000, 0.000000, 180.000000, .maxhitpoints = 1);
    item_CapBack3		= DefineItemType("Bon�", "", "CapBack3",			18941,	1,	180.0, 0.0, 0.0,		0.0,	0.062216, 0.055396, 0.001138, 90.000000, 0.000000, 180.000000, .maxhitpoints = 1);
    item_CapBack2		= DefineItemType("Bon�", "", "CapBack2",			18940,	1,	180.0, 0.0, 0.0,		0.0,	0.062216, 0.055396, 0.001138, 90.000000, 0.000000, 180.000000, .maxhitpoints = 1);
	item_CapBack1		= DefineItemType("Bon�", "", "CapBack1",			18939,	1,	180.0, 0.0, 0.0,		0.0,	0.062216, 0.055396, 0.001138, 90.000000, 0.000000, 180.000000, .maxhitpoints = 1);

    item_MetalBlin		= DefineItemType("Metal Blindado", "", "MetalBlin",		2929,	14, 90.0, 0.0, 0.0,			0.0,	-0.365094, 1.004213, -0.665850, 	337.887634, 172.861953, 68.495330, true, .buttonz = FLOOR_OFFSET / 2, .maxhitpoints = 15);
	item_DoorBlin		= DefineItemType("Porta Blindada", "", "DoorBlin",			19795,	13,	0.0, 90.0, 180.0,		0.0,	0.134831, -0.039784, -0.298796,		337.887634, 172.861953, 162.198867, true, .buttonz = FLOOR_OFFSET / 2, .maxhitpoints = 14);
    item_PortaCofre     = DefineItemType("Porta de Cofre", "", "PortaCofre",       19799,  10, 90.0, 90.0, 180.0,		0.0,	-0.365094, 1.004213, -0.665850, 	337.887634, 172.861953, 68.495330, true, .buttonz = FLOOR_OFFSET / 2, .maxhitpoints = 13);
	item_GarageDoor		= DefineItemType("Port�o de Garagem", "", "GarageDoor",		2957,	12,	90.0, 0.0, 0.0,			0.0,	-0.365094, 1.004213, -0.665850, 	337.887634, 172.861953, 68.495330, true, .buttonz = FLOOR_OFFSET / 2, .maxhitpoints = 12);
//	item_DupleDoor		= DefineItemType("Porta Dupla", "", "DupleDoor",		18553,	10,	0.0, 90.0, 90.0,		0.0,	-0.087715, 0.483874, -0.309397, 	338.887634, 172.861953, 162.198867, true, .buttonz = FLOOR_OFFSET / 2, .maxhitpoints = 11);
    item_DupleDoor		= DefineItemType("Porta Dupla", "", "DupleDoor",		11714,	10,	0.0, 90.0, 90.0,		0.0,	-0.087715, 0.483874, -0.309397, 	338.887634, 172.861953, 162.198867, true, .buttonz = FLOOR_OFFSET / 2, .maxhitpoints = 11);
	item_ShipDoor		= DefineItemType("Porta de Navio", "", "ShipDoor",			2944,	7,	180.0, 90.0, 0.0,		0.0,	0.134831, -0.039784, -0.298796, 	337.887634, 172.861953, 162.198867, true, .buttonz = FLOOR_OFFSET / 2, .maxhitpoints = 9);
    item_CorPanel		= DefineItemType("Metal Corrugado", "", "CorPanel",			2904,	8,	90.0, 90.0, 0.0,		0.0,	-0.365094, 1.004213, -0.665850, 	337.887634, 172.861953, 68.495330, true, .buttonz = FLOOR_OFFSET / 2, .maxhitpoints = 8);
    item_InsulPanel		= DefineItemType("Painel Isolado", "", "InsulPanel",		19371,	10,	0.0, 90.0, 0.0,			0.0,	-0.087715, 0.5, -0.49, 				337.887634, 172.861953, 162.198867, true, .buttonz = FLOOR_OFFSET / 2, .maxhitpoints = 8);
	item_WoodPanel		= DefineItemType("Rampa de Madeira", "", "WoodPanel",		5153,	10,	360.0, 23.537, 0.0,		0.0,	-0.342762, 0.908910,-0.453703, 		296.326019, 46.126548, 226.118209, true, .buttonz = FLOOR_OFFSET / 2, .maxhitpoints = 8);
	item_MetalGate2		= DefineItemType("Grade Grande", "", "MetalGate2",		19870,	12,	270.0, 0.0, 0.0,		0.0,	0.087177, -0.1, -0.299014,  		-19.439863, -10.153647, 105.119079, true, .buttonz = FLOOR_OFFSET / 2, .maxhitpoints = 8);
	item_InsulDoor		= DefineItemType("Entrada Isolada", "", "InsulDoor",		19398,	9,	0.0, 90.0, 0.0,			0.0,	-0.087715, 0.483874, 1.109397, 		337.887634, 172.861953, 162.198867, true, .buttonz = FLOOR_OFFSET / 2, .maxhitpoints = 7);
	item_MetPanel		= DefineItemType("Painel de Metal", "", "MetPanel",			1965,	7,	0.0, 90.0, 0.0,			0.0,	0.070050, 0.008440, -0.180277, 		338.515014, 349.801025, 33.250347, true, .buttonz = FLOOR_OFFSET / 2, .maxhitpoints = 6);
	item_CrateDoor		= DefineItemType("Porta de Container", "", "CrateDoor",		3062,	7,	90.0, 90.0, 0.0,		0.0,	0.150177, -0.097238, -0.299014,  	-19.439863, -10.153647, 105.119079, true, .buttonz = FLOOR_OFFSET / 3, .maxhitpoints = 6);
	item_MetalGate1		= DefineItemType("Grade", "", "MetalGate1",		19303,	7,	270.0, 0.0, 0.0,		0.0,	0.057177, 0.073761, -0.299014,  	-19.439863, -10.153647, 105.119079, true, .buttonz = FLOOR_OFFSET / 2, .maxhitpoints = 5);
	item_MetalFrame		= DefineItemType("Peda�o de Metal", "", "MetalFrame",		19843,	5,	0.0, 0.0, 0.0,			0.0,	-0.093000, 0.414000, -0.347999,  	77.500022, 105.500022, 80.100013, true, .buttonz = FLOOR_OFFSET / 2, .maxhitpoints = 4);
    item_MetalStand		= DefineItemType("Metal Pequeno", "", "MetalStand",		2978,	5,	0.0, 0.0, 0.0,			0.0,	-0.106182, 0.534724, -0.363847, 	278.598419, 68.350570, 57.954662, true, .buttonz = FLOOR_OFFSET / 2, .longpickup = true, .maxhitpoints = 4);

	item_SupplyDrop		= DefineItemType("Sinalizador", "", "SupplyDrop",		2034,	2,	0.0, 0.0, 0.0,			0.0,	0.176000, 0.020000, 0.039999,  89.199989, -0.900000, 1.099991, .maxhitpoints = 2);
	item_Camouflage		= DefineItemType("Camuflagem", "", "Camouflage",		1578,	2,	0.0, 0.0, 0.0,			0.0,	0.269091, 0.166367, 0.000000, 90.000000, 0.000000, 0.000000, .maxhitpoints = 2);
	item_Map			= DefineItemType("Mapa", "", "Map",				19167,	1,	0.0, 0.0, 0.0,			0.05,	0.062216, 0.055396, 0.001138, 90.000000, 0.000000, 180.000000, .maxhitpoints = 1);
	item_GeigerCounter  = DefineItemType("Contador Geiger", "", "GeigerCounter",	18871,	1,	0.0, 0.0, 0.0,			0.0,	0.103904, -0.003697, -0.015173, 94.655189, 184.031860, 0.000000, .buttonz = FLOOR_OFFSET / 2, .maxhitpoints = 1);

	// SETTING ITEM TYPE SCRAP VALUE
	SetItemTypeScrapValue(item_Knuckles,		1);
	SetItemTypeScrapValue(item_GolfClub,		2);
	SetItemTypeScrapValue(item_Knife,			1);
	SetItemTypeScrapValue(item_Spade,			2);
	SetItemTypeScrapValue(item_Sword,			3);
	SetItemTypeScrapValue(item_Chainsaw,		5);
	SetItemTypeScrapValue(item_Extinguisher,	4);
	SetItemTypeScrapValue(item_Camera,			1);
	SetItemTypeScrapValue(item_HardDrive,		1);
	SetItemTypeScrapValue(item_Key,				1);
	SetItemTypeScrapValue(item_FireLighter,		1);
	SetItemTypeScrapValue(item_Timer,			1);
	SetItemTypeScrapValue(item_Battery,			1);
	SetItemTypeScrapValue(item_Fusebox,			1);
	SetItemTypeScrapValue(item_Armour,			3);
	SetItemTypeScrapValue(item_FishRod,			1);
	SetItemTypeScrapValue(item_Wrench,			1);
	SetItemTypeScrapValue(item_Crowbar,			1);
	SetItemTypeScrapValue(item_Hammer,			1);
	SetItemTypeScrapValue(item_Flashlight,		1);
	SetItemTypeScrapValue(item_StunGun,			1);
	SetItemTypeScrapValue(item_LaserPoint,		1);
	SetItemTypeScrapValue(item_Screwdriver,		1);
	SetItemTypeScrapValue(item_MobilePhone,		1);
	SetItemTypeScrapValue(item_Pager,			1);
	SetItemTypeScrapValue(item_Rake,			1);
	SetItemTypeScrapValue(item_HandCuffs,		1);
	SetItemTypeScrapValue(item_Bucket,			2);
	SetItemTypeScrapValue(item_GasMask,			1);
	SetItemTypeScrapValue(item_MotionSense,		1);
	SetItemTypeScrapValue(item_Accelerometer,	1);
	SetItemTypeScrapValue(item_GasCan,			2);
	SetItemTypeScrapValue(item_Capsule,			2);
	SetItemTypeScrapValue(item_RadioPole,		2);
	SetItemTypeScrapValue(item_SignShot,		2);
	SetItemTypeScrapValue(item_Mailbox,			2);
	SetItemTypeScrapValue(item_Barbecue,		6);
	SetItemTypeScrapValue(item_Headlight,		1);
	SetItemTypeScrapValue(item_MetPanel, 		3);
	SetItemTypeScrapValue(item_MetalGate1, 		4);
	SetItemTypeScrapValue(item_CrateDoor, 		4);
	SetItemTypeScrapValue(item_CorPanel,		9);
	SetItemTypeScrapValue(item_ShipDoor, 		12);
	SetItemTypeScrapValue(item_Keypad,			1);
	SetItemTypeScrapValue(item_Ammo9mm,			1);
	SetItemTypeScrapValue(item_Ammo50,			1);
	SetItemTypeScrapValue(item_AmmoBuck,		1);
	SetItemTypeScrapValue(item_Ammo556,			1);
	SetItemTypeScrapValue(item_Ammo357,			1);
	SetItemTypeScrapValue(item_AmmoRocket,		1);
	SetItemTypeScrapValue(item_PowerSupply,		1);
	SetItemTypeScrapValue(item_StorageUnit,		1);
	SetItemTypeScrapValue(item_Fluctuator,		1);
	SetItemTypeScrapValue(item_IoUnit,			1);
	SetItemTypeScrapValue(item_FluxCap,			1);
	SetItemTypeScrapValue(item_DataInterface,	1);
	SetItemTypeScrapValue(item_HackDevice,		1);
	SetItemTypeScrapValue(item_HerpDerp,		1);
	SetItemTypeScrapValue(item_Gyroscope,		1);
	SetItemTypeScrapValue(item_Motor,			1);
	SetItemTypeScrapValue(item_StarterMotor,	1);
	SetItemTypeScrapValue(item_FlareGun,		1);
	SetItemTypeScrapValue(item_LocksmithKit,	2);
	SetItemTypeScrapValue(item_AdvancedKeypad,	1);
	SetItemTypeScrapValue(item_Ammo9mmFMJ,		1);
	SetItemTypeScrapValue(item_AmmoFlechette,	1);
	SetItemTypeScrapValue(item_AmmoHomeBuck,	1);
	SetItemTypeScrapValue(item_Ammo556Tracer,	1);
	SetItemTypeScrapValue(item_Ammo556HP,		1);
	SetItemTypeScrapValue(item_Ammo357Tracer,	1);
	SetItemTypeScrapValue(item_Ammo762,			1);
	SetItemTypeScrapValue(item_Ammo50BMG,		1);
	SetItemTypeScrapValue(item_Ammo308,			1);
	SetItemTypeScrapValue(item_Sledgehammer,	1);
	SetItemTypeScrapValue(item_Spanner,			1);
	SetItemTypeScrapValue(item_OilCan,			2);
	SetItemTypeScrapValue(item_BigSword,		1);
	SetItemTypeScrapValue(item_Spatula,			1);
	SetItemTypeScrapValue(item_Pan,				1);
	SetItemTypeScrapValue(item_Knife2,			1);
	SetItemTypeScrapValue(item_FryingPan,		1);
	SetItemTypeScrapValue(item_WheelLock,		1);
	SetItemTypeScrapValue(item_RedPanel,		2);
	SetItemTypeScrapValue(item_Fork,			1);
	SetItemTypeScrapValue(item_Knife3,			1);
	SetItemTypeScrapValue(item_Padlock,			1);
	SetItemTypeScrapValue(item_OilDrum,			8);
	SetItemTypeScrapValue(item_Canister,		3);
	SetItemTypeScrapValue(item_Locator,			1);
	SetItemTypeScrapValue(item_Radio,			1);
	SetItemTypeScrapValue(item_Locker,			12);
	SetItemTypeScrapValue(item_GearBox,			5);
	SetItemTypeScrapValue(item_ToolBox,			8);
	SetItemTypeScrapValue(item_MetalFrame,		16);
	SetItemTypeScrapValue(item_LockBreaker,		1);
	SetItemTypeScrapValue(item_ControlBox,		2);
	SetItemTypeScrapValue(item_Computer,		2);
	SetItemTypeScrapValue(item_TallFrame,		8);
	SetItemTypeScrapValue(item_RemoteControl,	1);


	// SETTING HOLSTERABLE ITEMS
	SetItemTypeHolsterable(item_Baton,			8, 0.061868, 0.008748, 0.136682, 254.874801, 0.318417, 0.176398, 300,	"PED",		"PHONE_IN");
	SetItemTypeHolsterable(item_Sword,			1, 0.123097, -0.129424, -0.139251, 0.000000, 301.455871, 0.000000, 600, "GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_M9Pistol,		8, 0.061868, 0.008748, 0.136682, 254.874801, 0.318417, 0.176398, 300,	"PED",		"PHONE_IN");
	SetItemTypeHolsterable(item_M9PistolSD,		8, 0.061868, 0.008748, 0.136682, 254.874801, 0.318417, 0.176398, 300,	"PED",		"PHONE_IN");
	SetItemTypeHolsterable(item_DesertEagle,	8, 0.061868, 0.008748, 0.136682, 254.874801, 0.318417, 0.176398, 300,	"PED",		"PHONE_IN");
	SetItemTypeHolsterable(item_PumpShotgun,	1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_Sawnoff,		8, 0.061868, 0.008748, 0.136682, 254.874801, 0.318417, 0.176398, 300,	"PED",		"PHONE_IN");
	SetItemTypeHolsterable(item_Spas12,			1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_Mac10,			8, 0.061868, 0.008748, 0.136682, 254.874801, 0.318417, 0.176398, 300,	"PED",		"PHONE_IN");
	SetItemTypeHolsterable(item_MP5,			1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_WASR3Rifle,		1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_M16Rifle,		1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_Tec9,			8, 0.061868, 0.008748, 0.136682, 254.874801, 0.318417, 0.176398, 300,	"PED",		"PHONE_IN");
	SetItemTypeHolsterable(item_SemiAutoRifle,	1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_SniperRifle,	1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_RocketLauncher,	1, 0.181966, -0.238397, -0.094830, 252.7912, 353.8938, 357.5294, 800,	"GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_Heatseeker,		1, 0.181966, -0.238397, -0.094830, 252.7912, 353.8938, 357.5294, 800,	"GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_AK47Rifle,		1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_M77RMRifle,		1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_DogsBreath,		8, 0.176000, -0.005000, 0.062999, -14.499991, -0.900000, 1.099991, 300,	"PED",		"PHONE_IN");
	SetItemTypeHolsterable(item_StunGun,		8, 0.061868, 0.008748, 0.136682, 254.874801, 0.318417, 0.176398, 300,	"PED",		"PHONE_IN");
	SetItemTypeHolsterable(item_Shield,			1, 0.027000, -0.039999, 0.170000, 270.0000, -171.0000, 90.0000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_Mailbox,		1, 0.457000, -0.094999, -0.465000,  2.099999, -42.600, -94.500, 800,	"GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_Model70Rifle,	1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");
	SetItemTypeHolsterable(item_LenKnocksRifle,	1, 0.214089, -0.126031, 0.114131, 0.000000, 159.522552, 0.000000, 800,	"GOGGLES",	"GOGGLES_PUT_ON");

	// AMMO TYPE DEFINITIONS
	//									name		bleedrate
	calibre_9mm		= DefineAmmoCalibre("9mm",		0.25);
	calibre_50cae	= DefineAmmoCalibre(".50",		0.73);
	calibre_12g		= DefineAmmoCalibre("12 Gauge",	0.31);
	calibre_556		= DefineAmmoCalibre("5.56mm",	0.19);
	calibre_357		= DefineAmmoCalibre(".357",		0.36);
	calibre_762		= DefineAmmoCalibre("7.62",		0.32);
	calibre_rpg		= DefineAmmoCalibre("RPG",		0.0);
	calibre_fuel	= DefineAmmoCalibre("Combust�vel",		0.0);
	calibre_film	= DefineAmmoCalibre("Filme",		0.0);
	calibre_50bmg	= DefineAmmoCalibre(".50",		0.63);
	calibre_308		= DefineAmmoCalibre(".308",		0.43);
	

	// ANIMATION SET DEFINITIONS
	anim_Blunt		= DefineAnimSet();
	anim_Stab		= DefineAnimSet();
	anim_Heavy		= DefineAnimSet();

	//							animidx
	AddAnimToSet(anim_Blunt,	26);
	AddAnimToSet(anim_Blunt,	17);
	AddAnimToSet(anim_Blunt,	18);
	AddAnimToSet(anim_Blunt,	19);
	AddAnimToSet(anim_Stab,		751);
	AddAnimToSet(anim_Heavy,	19);
	AddAnimToSet(anim_Heavy,	20);


	/*
		WEAPON TYPE DEFINITIONS

		baseweapon - GTA weapon ID used for this weapon class. This is the
		GTA weapon that the player will be given when using the item. When this
		value is 0, it indicates the weapon is a custom type that doesn't use a
		GTA weapon as a template.

		calibre - a calibre from the defined calibres above. The calibre
		determines the base bleedrate of the rounds fired from the weapon. Melee
		weapons use the muzzle velocity parameter in the function with bleedrate
		and magsize with knockout chance multiplier.

		muzzvelocity - the simulated initial velocity of the round after being
		fired. This value simulates the muzzle velocity of the weapon which
		affects how much the bullet's velocity is affected by distance. A higher
		muzzle velocity results in rounds that can travel quite far without
		losing velocity and thus energy (which affects the resulting bleedrate
		and knockout chance).

		magsize - maximum amount of rounds in a magazine. This value must be
		below the max for that base weapon since client side weapon mag sizes
		can't be altered. Melee weapons use this field to store the knockout
		probability in floating point form.

		maxmags - total amount of reserve magazines held by the user.

		animset - currently only used by melee weapons, dictates the set of
		animations used for attacking with the weapon.
	*/

	//					itemtype				baseweapon					calibre			bleedrate		koprob	n/a		animset
	DefineItemTypeWeapon(item_Wrench,			0,							-1,				0.03,			_:1.20,	0,		anim_Blunt);
	DefineItemTypeWeapon(item_Crowbar,			0,							-1,				0.06,			_:1.25,	0,		anim_Blunt);
	DefineItemTypeWeapon(item_Hammer,			0,							-1,				0.05,			_:1.30,	0,		anim_Blunt);
	DefineItemTypeWeapon(item_Rake,				0,							-1,				0.17,			_:1.30,	0,		anim_Heavy);
	DefineItemTypeWeapon(item_Cane,				0,							-1,				0.08,			_:1.25,	0,		anim_Blunt);
	DefineItemTypeWeapon(item_StunGun,			0,							-1,				0.0,			0,		0,		anim_Stab);
	DefineItemTypeWeapon(item_Screwdriver,		0,							-1,				0.20,			0,		0,		anim_Stab);
	DefineItemTypeWeapon(item_Mailbox,			0,							-1,				0.0,			_:1.40,	0,		anim_Heavy);
	DefineItemTypeWeapon(item_Sledgehammer,		0,							-1,				0.03,			_:2.9,	0,		anim_Heavy);
	DefineItemTypeWeapon(item_BigSword,			0,							-1,				0.30,			_:0.15,	0,		anim_Heavy);
	DefineItemTypeWeapon(item_Spatula,			0,							-1,				0.03,			0,		0,		anim_Blunt);
	DefineItemTypeWeapon(item_Pan,				0,							-1,				0.03,			_:1.05,	0,		anim_Blunt);
	DefineItemTypeWeapon(item_Knife2,			0,							-1,				0.29,			0,		0,		anim_Stab);
	DefineItemTypeWeapon(item_FryingPan,		0,							-1,				0.04,			_:1.06,	0,		anim_Blunt);
	DefineItemTypeWeapon(item_Fork,				0,							-1,				0.17,			0,		0,		anim_Stab);
	DefineItemTypeWeapon(item_Broom,			0,							-1,				0.11,			_:1.1,	0,		anim_Heavy);
	//					itemtype				baseweapon					calibre			bleedrate		koprob	n/a		animset
	DefineItemTypeWeapon(item_Knuckles,			WEAPON_BRASSKNUCKLE,		-1,				0.05,			20,		0);
	DefineItemTypeWeapon(item_GolfClub,			WEAPON_GOLFCLUB,			-1,				0.07,			35,		0);
	DefineItemTypeWeapon(item_Baton,			WEAPON_NITESTICK,			-1,				0.03,			24,		0);
	DefineItemTypeWeapon(item_Knife,			WEAPON_KNIFE,				-1,				0.30,			14,		0);
	DefineItemTypeWeapon(item_Bat,				WEAPON_BAT,					-1,				0.09,			35,		0);
	DefineItemTypeWeapon(item_Spade,			WEAPON_SHOVEL,				-1,				0.21,			40,		0);
	DefineItemTypeWeapon(item_PoolCue,			WEAPON_POOLSTICK,			-1,				0.08,			37,		0);
	DefineItemTypeWeapon(item_Sword,			WEAPON_KATANA,				-1,				0.35,			15,		0);
	DefineItemTypeWeapon(item_Chainsaw,			WEAPON_CHAINSAW,			liquid_Petrol,	0.93,			100,	1,		-1,				WEAPON_FLAG_ASSISTED_FIRE | WEAPON_FLAG_LIQUID_AMMO);
	DefineItemTypeWeapon(item_Dildo1,			WEAPON_DILDO,				-1,				0.01,			0,		0);
	DefineItemTypeWeapon(item_Dildo2,			WEAPON_DILDO2,				-1,				0.01,			0,		0);
	DefineItemTypeWeapon(item_Dildo3,			WEAPON_VIBRATOR,			-1,				0.01,			0,		0);
	DefineItemTypeWeapon(item_Dildo4,			WEAPON_VIBRATOR2,			-1,				0.01,			0,		0);
	DefineItemTypeWeapon(item_Flowers,			WEAPON_FLOWER,				-1,				0.01,			0,		0);
	DefineItemTypeWeapon(item_WalkingCane,		WEAPON_CANE,				-1,				0.06,			24,		0);
	DefineItemTypeWeapon(item_Grenade,			WEAPON_GRENADE,				-1,				0.0,			0,		0);
	DefineItemTypeWeapon(item_Teargas,			WEAPON_TEARGAS,				-1,				0.0,			0,		0);
	DefineItemTypeWeapon(item_Molotov,			WEAPON_MOLTOV,				-1,				0.0,			0,		0);
	//					itemtype				baseweapon					calibre			muzzvelocity	magsize	maxmags		animset
	DefineItemTypeWeapon(item_M9Pistol,			WEAPON_COLT45,				calibre_9mm,	330.0,			10,		1);
	DefineItemTypeWeapon(item_M9PistolSD,		WEAPON_SILENCED,			calibre_9mm,	295.0,			10,		1);
	DefineItemTypeWeapon(item_DesertEagle,		WEAPON_DEAGLE,				calibre_357,	420.0,			7,		2);
	DefineItemTypeWeapon(item_PumpShotgun,		WEAPON_SHOTGUN,				calibre_12g,	475.0,			6,		1);
	DefineItemTypeWeapon(item_Sawnoff,			WEAPON_SAWEDOFF,			calibre_12g,	265.0,			2,		6);
	DefineItemTypeWeapon(item_Spas12,			WEAPON_SHOTGSPA,			calibre_12g,	480.0,			6,		1);
	DefineItemTypeWeapon(item_Mac10,			WEAPON_UZI,					calibre_9mm,	376.0,			32,		1);
	DefineItemTypeWeapon(item_MP5,				WEAPON_MP5,					calibre_9mm,	400.0,			30,		1);
	DefineItemTypeWeapon(item_WASR3Rifle,		WEAPON_AK47,				calibre_556,	943.0,			30,		1);
	DefineItemTypeWeapon(item_M16Rifle,			WEAPON_M4,					calibre_556,	948.0,			30,		1);
	DefineItemTypeWeapon(item_Tec9,				WEAPON_TEC9,				calibre_9mm,	360.0,			36,		1);
	DefineItemTypeWeapon(item_SemiAutoRifle,	WEAPON_RIFLE,				calibre_357,	829.0,			5,		1);
	DefineItemTypeWeapon(item_SniperRifle,		WEAPON_SNIPER,				calibre_357,	864.0,			5,		1);
	DefineItemTypeWeapon(item_RocketLauncher,	WEAPON_ROCKETLAUNCHER,		calibre_rpg,	0.0,			1,		0,		-1,				WEAPON_FLAG_ASSISTED_FIRE_ONCE | WEAPON_FLAG_ONLY_FIRE_AIMED);
	DefineItemTypeWeapon(item_Heatseeker,		WEAPON_HEATSEEKER,			calibre_rpg,	0.0,			1,		0,		-1,				WEAPON_FLAG_ASSISTED_FIRE_ONCE | WEAPON_FLAG_ONLY_FIRE_AIMED);
	DefineItemTypeWeapon(item_Flamer,			WEAPON_FLAMETHROWER,		liquid_Petrol,	0.0,			100,	10,		-1,				WEAPON_FLAG_ASSISTED_FIRE | WEAPON_FLAG_LIQUID_AMMO);
	DefineItemTypeWeapon(item_Minigun,			WEAPON_MINIGUN,				calibre_556,	853.0,			100,	1);
	DefineItemTypeWeapon(item_RemoteBomb,		WEAPON_SATCHEL,				-1,				0.0,			1,		1);
	DefineItemTypeWeapon(item_Detonator,		WEAPON_BOMB,				-1,				0.0,			1,		1);
	DefineItemTypeWeapon(item_SprayPaint,		WEAPON_SPRAYCAN,			-1,				0.0,			100,	0,		-1,				WEAPON_FLAG_ASSISTED_FIRE);
	DefineItemTypeWeapon(item_Extinguisher,		WEAPON_FIREEXTINGUISHER,	-1,				0.0,			100,	0,		-1,				WEAPON_FLAG_ASSISTED_FIRE);
	DefineItemTypeWeapon(item_Camera,			WEAPON_CAMERA,				calibre_film,	1337.0,			24,		4);
	DefineItemTypeWeapon(item_VehicleWeapon,	WEAPON_M4,					calibre_556,	750.0,			0,		1);
	DefineItemTypeWeapon(item_AK47Rifle,		WEAPON_AK47,				calibre_762,	715.0,			30,		1);
	DefineItemTypeWeapon(item_M77RMRifle,		WEAPON_RIFLE,				calibre_357,	823.0,			1,		9);
	DefineItemTypeWeapon(item_DogsBreath,		WEAPON_DEAGLE,				calibre_50bmg,	888.8,			1,		9);
	DefineItemTypeWeapon(item_Model70Rifle,		WEAPON_SNIPER,				calibre_308,	860.6,			1,		9);
	DefineItemTypeWeapon(item_LenKnocksRifle,	WEAPON_SNIPER,				calibre_50bmg,	938.5,			1,		4);

    //DefineItemTypeWeapon(item_NightVision,		44,				-1,				0.0,			0,		0);
    //DefineItemTypeWeapon(item_ThermalVision,	45,				-1,				0.0,			0,		0);
    
	/*
		AMMO TYPE DEFINITIONS

		name - the additional name given to the ammunition item. This is used to
		format the full item name or weapon name which includes the amount of
		ammo loaded into the weapon or ammo container, the calibre and this name
		which corresponds to the type or behaviour of the ammo. This can refer
		to the jacket type, contained substance or any other firearm term.

		bld - bleedrate multiplier for ammo type. After the base bleedrate for
		a bullet has been calculated using the distance, calibre bleedrate and
		bullet velocity, this value is multiplied against that bleedrate. This
		allows different ammunition types of the same calibre to inflict
		different bleed rates.

		ko - knockout chance multiplier for ammo type. When PlayerInflictWound
		is called, a knockout chance multiplier is sent, the default is 1.0
		resulting no chance in the chance to get knocked out. This value allows
		different ammunition types of the same calibre to affect the chance of a
		target being knocked out by a shot.

		pen - armour and material penetration for ammo type. Unique only to ammo
		types and not calibres, this value changes how the ammunition treats
		targets wearing armour. The base value is 0.0 which is no bleedrate and
		a value of 1.0 results in the round completely ignoring armour. Any
		values above this will just multiply the resulting bleedrate more.

		size - maximum size for the ammo tin item. When ammunition spawns in the
		world, this value is used as a capacity limit for how much ammunition
		may spawn inside the ammo item. It also acts as a limit for transferring
		ammo to the item.
	*/
	//					itemtype				name				calibre			bld		ko		pen		size
	DefineItemTypeAmmo(item_Ammo9mm,			"Ponta Oca",		calibre_9mm,	1.0,	1.0,	0.2,	20);
	DefineItemTypeAmmo(item_Ammo50,				"Action Express",	calibre_50cae,	1.0,	1.5,	0.9,	28);
	DefineItemTypeAmmo(item_AmmoBuck,			"No. 1",			calibre_12g,	1.3,	1.4,	0.6,	24);
	DefineItemTypeAmmo(item_Ammo556,			"FMJ",				calibre_556,	1.1,	1.2,	0.8,	30);
	DefineItemTypeAmmo(item_Ammo357,			"FMJ",				calibre_357,	1.2,	1.1,	0.9,	10);
	DefineItemTypeAmmo(item_AmmoRocket,			"RPG",				calibre_rpg,	1.0,	1.0,	1.0,	1);
	DefineItemTypeAmmo(item_GasCan,				"Gasolina",			calibre_fuel,	0.0,	0.0,	0.0,	20);
	DefineItemTypeAmmo(item_Ammo9mmFMJ,			"FMJ",				calibre_9mm,	1.2,	0.5,	0.8,	20);
	DefineItemTypeAmmo(item_AmmoFlechette,		"Flechette",		calibre_12g,	1.0,	0.6,	0.2,	8);
	DefineItemTypeAmmo(item_AmmoHomeBuck,		"Improvisado",		calibre_12g,	1.2,	0.8,	0.4,	14);
	DefineItemTypeAmmo(item_Ammo556Tracer,		"Tra�ante",			calibre_556,	0.9,	1.1,	0.5,	30);
	DefineItemTypeAmmo(item_Ammo556HP,			"Ponta Oca",		calibre_556,	1.3,	1.6,	0.4,	30);
	DefineItemTypeAmmo(item_Ammo357Tracer,		"Tra�ante",			calibre_357,	1.2,	1.1,	0.6,	10);
	DefineItemTypeAmmo(item_Ammo762,			"FMJ",				calibre_762,	1.3,	1.1,	0.9,	30);
	DefineItemTypeAmmo(item_Ammo50BMG,			"BMG",				calibre_50bmg,	1.8,	1.8,	1.0,	16);
	DefineItemTypeAmmo(item_Ammo308,			"FMJ",				calibre_308,	1.2,	1.1,	0.8,	10);


	// EXPLOSIVE ITEM TYPE DEFINITIONS
	DefineExplosiveItem(item_TntTimebomb,	TIMED,		EXP_MEDIUM);
	DefineExplosiveItem(item_TntTripMine,	MOTION,		EXP_MEDIUM);
	DefineExplosiveItem(item_TntProxMine,	PROXIMITY,	EXP_MEDIUM);
	DefineExplosiveItem(item_TntPhoneBomb,	RADIO,		EXP_MEDIUM);
	DefineExplosiveItem(item_IedTimebomb,	TIMED,		EXP_SMALL);
	DefineExplosiveItem(item_IedTripMine,	MOTION,		EXP_SMALL);
	DefineExplosiveItem(item_IedProxMine,	PROXIMITY,	EXP_SMALL);
	DefineExplosiveItem(item_IedPhoneBomb,	RADIO,		EXP_SMALL);
	DefineExplosiveItem(item_EmpTimebomb,	TIMED,		EXP_EMP);
	DefineExplosiveItem(item_EmpTripMine,	MOTION,		EXP_EMP);
	DefineExplosiveItem(item_EmpProxMine,	PROXIMITY,	EXP_EMP);
	DefineExplosiveItem(item_EmpPhoneBomb,	RADIO,		EXP_EMP);
	DefineExplosiveItem(item_PetrolBomb,	TIMED,		EXP_INCEN);
	DefineExplosiveItem(item_Dynamite,		TIMED,		EXP_LARGE);
	SetRadioExplosiveTriggerItem(item_MobilePhone);

	// FOOD ITEM TYPE DEFINITIONS
	// Function Signature: DefineFoodItem(ItemType:itemType, maxBites, Float:biteValue, canCook, canRawInfect, destroyOnEnd) {
	DefineFoodItem(item_HotDog,			4, 18.00,	1, 0, 1);
	DefineFoodItem(item_Pizza,			6, 18.30,	1, 0, 0);
	DefineFoodItem(item_Burger,			4, 16.25,	1, 1, 1);
	DefineFoodItem(item_BurgerBox,		4, 16.25,	1, 0, 0);
	DefineFoodItem(item_Taco,			4, 13.75,	1, 0, 1);
	DefineFoodItem(item_BurgerBag,		4, 17.50,	1, 0, 0);
	DefineFoodItem(item_Meat,			8, 18.12,	1, 1, 1);
	DefineFoodItem(item_Tomato,			3, 3.0,		1, 0, 1);
	DefineFoodItem(item_RawFish,		4, 4.5,		1, 1, 1);
	DefineFoodItem(item_Meat2,			6, 16.7,	1, 1, 1);
	DefineFoodItem(item_PizzaOnly,		6, 18.5,	1, 0, 1);
	DefineFoodItem(item_BreadLoaf,		10, 6.32,	1, 0, 1);
	DefineFoodItem(item_Banana,			3, 5.5,		0, 0, 1);
	DefineFoodItem(item_Orange,			4, 4.5,		0, 0, 1);
	DefineFoodItem(item_RedApple,		4, 4.5,		0, 0, 1);
	DefineFoodItem(item_Lemon,			4, 4.0,		0, 0, 1);
	DefineFoodItem(item_PizzaBox,		6, 16.5,	1, 0, 0);
	DefineFoodItem(item_IceCream,		12, 4.1,	0, 0, 0);
	DefineFoodItem(item_FishyFingers,	10, 6.3,	1, 0, 0);
	DefineFoodItem(item_IceCreamBars,	12, 3.9,	0, 0, 0);
	DefineFoodItem(item_Cereal1,		6, 2.2,		0, 0, 0);
	DefineFoodItem(item_Cereal2,		6, 2.2,		0, 0, 0);
	DefineFoodItem(item_WrappedMeat,	4, 6.7,		1, 1, 1);
	DefineFoodItem(item_CakeSlice,		1, 2.5,		1, 0, 1);
	DefineFoodItem(item_GrnApple,		4, 4.5,		0, 0, 1);
	DefineFoodItem(item_Ham,			6, 6.12,	1, 1, 1);
	DefineFoodItem(item_Steak,			4, 6.49,	1, 1, 1);
	DefineFoodItem(item_Bread,			5, 2.34,	1, 0, 1);

	// DEFENSIVE ITEM TYPE DEFINITIONS
	DefineDefenceItem(item_MetalBlin, 	0.0, 0.0, 0.0,		90.0, 0.0, 0.0,  	1.72882, true); // 10
	DefineDefenceItem(item_DoorBlin,	0.0, 0.0, 90.0,		0.0, 90.0, 0.0,		1.62882, true); // 6
    DefineDefenceItem(item_PortaCofre,  0.0, 180.0, 0.0,  	90.0, 90.0, 180.0,  1.40865, true); // 6
	DefineDefenceItem(item_GarageDoor, 	0.0, 0.0, 0.0,		90.0, 0.0, 0.0,  	1.62882, true); // 8
	DefineDefenceItem(item_DupleDoor, 	0.0, 0.0, 90.0,		0.0, 90.0, 90.0,  	1.26817, true); // 8
	DefineDefenceItem(item_ShipDoor,	90.0, 90.0, 0.0,	180.0, 90.0, 0.0,	1.39421, true); // 9
	DefineDefenceItem(item_InsulDoor,	0.0, 0.0, 90.0,		0.0, 90.0, 0.0,		1.72882, false); // 6
	DefineDefenceItem(item_InsulPanel,	0.0, 0.0, 90.0,		0.0, 90.0, 0.0,		1.71953, true); // 6
	DefineDefenceItem(item_WoodPanel,	90.0, 0.0, 23.537,	360.0, 23.537, 0.0,	1.0161,  true);  // 6
	DefineDefenceItem(item_CorPanel,	0.0, 90.0, 0.0,		90.0, 90.0, 0.0,	1.21428, true); // 6
	DefineDefenceItem(item_MetPanel,	90.0, 90.0, 0.0,	0.0, 90.0, 0.0,		0.02708, true); // 5
	DefineDefenceItem(item_MetalGate1,	0.0, 0.0, 0.0,		270.0, 0.0, 0.0,	1.20759, true); // 4
	DefineDefenceItem(item_CrateDoor,	0.0, 90.0, 0.0,		90.0, 90.0, 0.0,	1.52665, true); // 5
	DefineDefenceItem(item_MetalGate2,	0.0, 0.0, 0.0,		270.0, 0.0, 0.0, 	1.72882, true); // 5
	DefineDefenceItem(item_MetalFrame,	90.0, 0.0, 0.0,		0.0, 0.0, 0.0,		0.48333, false); // 5
	DefineDefenceItem(item_MetalStand,	90.0, 0.0, 0.0,		0.0, 0.0, 0.0,		0.48333, false); // 5

	// SAFEBOX ITEM TYPE DEFINITIONS
	DefineSafeboxType(item_MediumBox,		12);
	DefineSafeboxType(item_SmallBox,		10);
	DefineSafeboxType(item_LargeBox,		14);
	DefineSafeboxType(item_Capsule,			2);
	DefineSafeboxType(item_Suitcase,		6);
	DefineSafeboxType(item_Holdall,			6);
	DefineSafeboxType(item_Workbench,		8, false);
	DefineSafeboxType(item_Locker,			45, .animateonuse = false);
	DefineSafeboxType(item_GearBox,			5);
	DefineSafeboxType(item_ToolBox,			8);
	DefineSafeboxType(item_GunCase,			5, false, false);
	DefineSafeboxType(item_Cupboard,		5, false, false);

	// DEFINED IN core/item/bags
	// BAG ITEM TYPE DEFINITIONS
	/*DefineBagType("Mochila",				item_Backpack,		11, -0.110900, -0.073500, 0.000000, 0.000000, 0.000000, 0.000000, 1.000000, 1.000000, 1.000000);
	DefineBagType("Mochila Pequena",		item_Satchel,		7, 0.241894, -0.160918, 0.181463, 0.000000, 90.000000, 0.000000, 1.000000, 1.000000, 1.000000);
	DefineBagType("Mochila Paraquedas",		item_ParaBag,		10, 0.039470, -0.088898, -0.009887, 0.000000, 90.000000, 0.000000, 1.000000, 1.000000, 1.000000);
	DefineBagType("Mochila Grande",			item_LargeBackpack,	14, -0.2209, -0.073500, 0.000000, 0.000000, 0.000000, 0.000000, 1.2000000, 1.300000, 1.100000);
	DefineBagType("Mochilinha",				item_Daypack,		8, 0.347999, -0.129999, 0.208000,  0.000000, 90.000000, 0.000000,  1.147999, 1.133999, 1.084000);
	DefineBagType("Mochila M�dia",			item_MediumBag,		12, -0.206900, -0.061500, -0.007000,  0.000000, 0.000000, 0.000000,  1.153999, 1.103999, 1.076999);
	DefineBagType("Mochila de Acampamento",	item_Rucksack,		13, 0.039469, -0.117898, -0.009886,  0.000000, 90.000000, 0.000000,  1.265999, 1.236999, 1.189000);
	DefineBagType("Mochila do Amor",		item_HeartShapedBox,6, 0.121852, -0.110032, -0.009413,  0.000000, 90.000000, 0.000000, 1.000000, 1.000000, 1.000000);
	*/
	
	// SEED TYPE DEFINITIONS
	DefineSeedType("Tomate", item_Tomato,	4, 631, 0.90649);
	DefineSeedType("Ma��", item_RedApple,	5, 802, 0.72044);
	DefineSeedType("Ma��", item_GrnApple,	5, 802, 0.72044);
	DefineSeedType("Banana", item_Banana,	6, 804, 1.31168);
	DefineSeedType("Lim�o", item_Lemon,		5, 810, 0.72044);
	DefineSeedType("Laranja", item_Orange,	5, 810, 0.72044);
	
	// Unused seed types will be given uses in future
	DefineSeedType("Desconhecido", INVALID_ITEM_TYPE, 0, 692, 0.31308); // wide greyish bush
	DefineSeedType("Desconhecido", INVALID_ITEM_TYPE, 0, 728, 0.34546); // huge bush!
	DefineSeedType("Desconhecido", INVALID_ITEM_TYPE, 0, 801, 0.21290); // large fern
	DefineSeedType("Desconhecido", INVALID_ITEM_TYPE, 0, 857, 0.50507); // big leaves
	DefineSeedType("Desconhecido", INVALID_ITEM_TYPE, 0, 861, -0.12961); // tall bush style
	DefineSeedType("Desconhecido", INVALID_ITEM_TYPE, 0, 863, 0.33455); // cacti or (756, 0.34550) or (757, 0.34550)
	DefineSeedType("Desconhecido", INVALID_ITEM_TYPE, 0, 2194, 0.25344); // tiny cactus
	DefineSeedType("Desconhecido", INVALID_ITEM_TYPE, 0, 2238, 0.58121); // lava lamp

	// MACHINE TYPE DEFINITIONS
	DefineMachineType(item_ScrapMachine, 6, 12);
	DefineMachineType(item_RefineMachine, 6, 12);
	DefineMachineType(item_WaterMachine, 6, 12);

	// FURNITURE TYPE DEFINITIONS
	DefineItemTypeFurniture(item_Desk,			0.0, 0.0, 0.80, 0.0, 0.0, 0.0);
	DefineItemTypeFurniture(item_Table,			0.0, 0.0, 0.80, 0.0, 0.0, 0.0);
	DefineItemTypeFurniture(item_GunCase,		0.0, 0.0, 0.25, -90, -90, 0.0);
	DefineItemTypeFurniture(item_Cupboard,		0.0, 0.0, 0.35, -90, -90, 0.0);
	DefineItemTypeFurniture(item_Barstool,		0.0, 0.0, 0.48, 0.0, 0.0, 0.0);
	DefineItemTypeFurniture(item_SmallTable,	0.0, 0.0, 0.45, 0.0, 0.0, 0.0);

	// CRAFTING SET DEFINITIONS
	// items created by hand
	DefineItemCraftSet(item_ParaBag, item_Knife, true, item_Parachute, false);
	DefineItemCraftSet(item_MolotovEmpty, item_Bottle, false, item_Bandage, false);
	DefineItemCraftSet(item_Bandage, item_Knife, true, item_Clothes, false);
	DefineItemCraftSet(item_WheelLock, item_WheelLock, false, item_LocksmithKit, false);
//	DefineItemCraftSet(item_Bottle, item_Bottle, true, item_Bottle, true);

	// items created by using a tool item on them in the world
	//SetCraftSetConstructible(30000, item_Hammer, DefineItemCraftSet(item_Workbench, item_RefinedMetal, false, item_RefinedMetal, false, item_WoodLog, false, item_WoodLog, false, item_WoodLog, false, item_WoodLog, false), item_Crowbar, 25000);
	SetCraftSetConstructible(5000, item_FireLighter, DefineItemCraftSet(item_Campfire, item_WoodLog, false, item_WoodLog, false, item_WoodLog, false), .tweak = false);
	SetCraftSetConstructible(20000, item_Screwdriver, DefineItemCraftSet(item_PlotPole, item_Canister, false, item_RadioPole, false, item_Fluctuator, false, item_PowerSupply, false), item_Crowbar, 30000, .tweak = false);
	SetCraftSetConstructible(30000, item_Screwdriver, DefineItemCraftSet(item_ScrapMachine, item_Canister, false, item_Motor, false, item_Fluctuator, false, item_PowerSupply, false), item_Crowbar, 25000, .tweak = true);
	SetCraftSetConstructible(30000, item_Screwdriver, DefineItemCraftSet(item_RefineMachine, item_MetalFrame, false, item_Motor, false, item_Fluctuator, false, item_PowerSupply, false), item_Crowbar, 25000, .tweak = true);
	SetCraftSetConstructible(30000, item_Screwdriver, DefineItemCraftSet(item_WaterMachine, item_Canister, false, item_Motor, false, item_Bucket, false, item_PowerSupply, false), item_Crowbar, 25000, .tweak = true);
	SetCraftSetConstructible(30000, item_Sledgehammer, DefineItemCraftSet(item_Locker, item_MetalStand, false, item_WoodLog, false, item_MetPanel, false), item_Crowbar, 25000, .tweak = true);
	SetCraftSetConstructible(30000, item_Sledgehammer, DefineItemCraftSet(item_Bed, item_MetPanel, false, item_WoodLog, false, item_WoodLog, false, item_RefinedMetal, false), item_Crowbar, 25000, .tweak = true);
	SetCraftSetConstructible(26500, item_Screwdriver, DefineItemCraftSet(item_Desk, item_RefinedMetal, false, item_WoodLog, false, item_WoodLog, false, item_WoodLog, false), item_Crowbar, 25000, .tweak = true);
	SetCraftSetConstructible(28500, item_Screwdriver, DefineItemCraftSet(item_Table, item_RefinedMetal, false, item_WoodLog, false, item_WoodLog, false, item_WoodLog, false, item_WoodLog, false), item_Crowbar, 25000, .tweak = true);
	SetCraftSetConstructible(22500, item_Screwdriver, DefineItemCraftSet(item_Barstool, item_RefinedMetal, false, item_WoodLog, false, item_WoodLog, false), item_Crowbar, 22000, .tweak = true);
	SetCraftSetConstructible(22500, item_Screwdriver, DefineItemCraftSet(item_SmallTable, item_WoodLog, false, item_WoodLog, false, item_WoodLog, false, item_WoodLog, false), item_Crowbar, 22000, .tweak = true);
	SetCraftSetConstructible(18500, item_Screwdriver, DefineItemCraftSet(item_Key, item_Key, false, item_Key, true, item_Motor, false), .tweak = false);

	//SetCraftSetConstructible(30000, item_Sledgehammer, DefineItemCraftSet(item_MetalBlin, item_MetalFrame, false, item_CorPanel, false, item_InsulPanel, false, item_RefinedMetal, false), .tweak = false);
	SetCraftSetConstructible(30000, item_Sledgehammer, DefineItemCraftSet(item_MetalGate2, item_MetalGate1, false, item_MetalGate1, false, item_MetalGate1, false), .tweak = false);
	SetCraftSetConstructible(30000, item_Sledgehammer, DefineItemCraftSet(item_DupleDoor, item_MetPanel, false, item_CrateDoor, false), .tweak = false);

	// items created with a workbench
	SetCraftSetConstructible(16000, item_Screwdriver, DefineItemCraftSet(item_IedBomb, item_FireworkBox, false, item_PowerSupply, false), .tweak = false);
	SetCraftSetConstructible(15000, item_Screwdriver, DefineItemCraftSet(item_TntTimebomb, item_Explosive, false, item_Timer, false), .tweak = false);
	SetCraftSetConstructible(15000, item_Screwdriver, DefineItemCraftSet(item_TntTripMine, item_Explosive, false, item_Accelerometer, false), .tweak = false);
	SetCraftSetConstructible(15000, item_Screwdriver, DefineItemCraftSet(item_TntProxMine, item_Explosive, false, item_MotionSense, false), .tweak = false);
	SetCraftSetConstructible(15000, item_Screwdriver, DefineItemCraftSet(item_TntPhoneBomb, item_Explosive, false, item_MobilePhone, false), .tweak = false);
	SetCraftSetConstructible(12000, item_Screwdriver, DefineItemCraftSet(item_IedTimebomb, item_IedBomb, false, item_Timer, false), .tweak = false);
	SetCraftSetConstructible(12000, item_Screwdriver, DefineItemCraftSet(item_IedTripMine, item_IedBomb, false, item_Accelerometer, false), .tweak = false);
	SetCraftSetConstructible(12000, item_Screwdriver, DefineItemCraftSet(item_IedProxMine, item_IedBomb, false, item_MotionSense, false), .tweak = false);
	SetCraftSetConstructible(12000, item_Screwdriver, DefineItemCraftSet(item_IedPhoneBomb, item_IedBomb, false, item_MobilePhone, false), .tweak = false);
	SetCraftSetConstructible(18000, item_Screwdriver, DefineItemCraftSet(item_EmpTimebomb, item_Fluctuator, false, item_Timer, false), .tweak = false);
	SetCraftSetConstructible(18000, item_Screwdriver, DefineItemCraftSet(item_EmpTripMine, item_Fluctuator, false, item_Accelerometer, false), .tweak = false);
	SetCraftSetConstructible(18000, item_Screwdriver, DefineItemCraftSet(item_EmpProxMine, item_Fluctuator, false, item_MotionSense, false), .tweak = false);
	SetCraftSetConstructible(18000, item_Screwdriver, DefineItemCraftSet(item_EmpPhoneBomb, item_Fluctuator, false, item_MobilePhone, false), .tweak = false);
	SetCraftSetConstructible(12000, item_Screwdriver, DefineItemCraftSet(item_PowerSupply, item_Battery, false, item_Fusebox, false), .tweak = false);
	SetCraftSetConstructible(12000, item_Screwdriver, DefineItemCraftSet(item_StorageUnit, item_Timer, false, item_HardDrive, false), .tweak = false);
	SetCraftSetConstructible(12000, item_Screwdriver, DefineItemCraftSet(item_Fluctuator, item_StunGun, false, item_RadioPole, false), .tweak = false);
	SetCraftSetConstructible(18000, item_Screwdriver, DefineItemCraftSet(item_IoUnit, item_MobilePhone, false, item_Keypad, false), .tweak = false);
	SetCraftSetConstructible(18000, item_Screwdriver, DefineItemCraftSet(item_FluxCap, item_PowerSupply, false, item_Fluctuator, false), .tweak = false);
	SetCraftSetConstructible(18000, item_Screwdriver, DefineItemCraftSet(item_DataInterface, item_StorageUnit, false, item_IoUnit, false), .tweak = false);
	SetCraftSetConstructible(18000, item_Screwdriver, DefineItemCraftSet(item_HackDevice, item_FluxCap, false, item_DataInterface, false), .tweak = false);
	SetCraftSetConstructible(12000, item_Screwdriver, DefineItemCraftSet(item_Motor, item_PowerSupply, false, item_Timer, false), .tweak = false);
	SetCraftSetConstructible(12500, item_Screwdriver, DefineItemCraftSet(item_LocksmithKit, item_Key, false, item_Motor, false), .tweak = false);
	SetCraftSetConstructible(15000, item_Screwdriver, DefineItemCraftSet(item_StarterMotor, item_Motor, false, item_Fluctuator, false), .tweak = false);
	SetCraftSetConstructible(18000, item_Screwdriver, DefineItemCraftSet(item_AdvancedKeypad, item_IoUnit, false, item_PowerSupply, false), .tweak = false);
	SetCraftSetConstructible(16000, item_Screwdriver, DefineItemCraftSet(item_Locator, item_MobilePhone, false, item_RadioPole, false, item_DataInterface, false, item_PowerSupply, false), .tweak = false);
	SetCraftSetConstructible(30000, item_Hammer, DefineItemCraftSet(item_MetalFrame, item_RefinedMetal, false, item_RefinedMetal, false, item_RefinedMetal, false, item_RefinedMetal, false), .tweak = false);
	SetCraftSetConstructible(25000, item_Hammer, DefineItemCraftSet(item_Canister, item_MetalFrame, false, item_RefinedMetal, false, item_RefinedMetal, false), .tweak = false);
	SetCraftSetConstructible(45000, item_Screwdriver, DefineItemCraftSet(item_LockBreaker, item_LocksmithKit, false, item_FluxCap, false, item_RefinedMetal, false, item_RefinedMetal, false, item_PowerSupply, false), .tweak = false);


    // SUPPLY DROP TYPE DEFINITIONS
    
	DefineSupplyDropType("Alimenta��o e Medicina",		"airdrop_food_medical",			900,	600,	3);
	DefineSupplyDropType("Armas de Baixo Grau", 		"airdrop_low_weapons",			2400,	1200,	4);
	DefineSupplyDropType("Armas Militares", 			"airdrop_military_weapons",		4200,	1800,	6);
	DefineSupplyDropType("Suprimentos Industriais", 	"airdrop_industrial",			2000,	900,	5);
	DefineSupplyDropType("Explosivos", 					"airdrop_ordnance",				10800,	10800,	8);
	

	// SKIN DEFINITIONS
	
	// male civilian
	skin_Civ0M	= DefineClothesType(60,		"Skin:60",			0, 1.0,		true, true);
	skin_Civ1M	= DefineClothesType(170,	"Skin:170",			0, 1.0,		true, true);
	skin_Civ2M	= DefineClothesType(250,	"Skin:250",			0, 1.0,		true, true);
	skin_Civ3M	= DefineClothesType(188,	"Skin:188",			0, 1.0,		true, true);
	skin_Civ4M	= DefineClothesType(206,	"Skin:206",			0, 1.0,		true, true);
	skin_Civ5M	= DefineClothesType(44,		"Skin:44",			0, 1.0,		true, true);
	skin_Civ6M	= DefineClothesType(289,	"Skin:289",			0, 1.0,		false, false);
	skin_Civ7M	= DefineClothesType(25,		"Skin:25",			0, 1.0,		true, true);
	skin_Civ8M	= DefineClothesType(45,		"Skin:45",			0, 1.0,		true, true);
	skin_Civ9M	= DefineClothesType(59,		"Skin:59",			0, 1.0,		true, true);
	skin_Civ10M	= DefineClothesType(97,		"Skin:97",			0, 1.0,		true, true);
	skin_Civ11M	= DefineClothesType(98,		"Skin:98",			0, 1.0,		true, true);
	skin_Civ12M	= DefineClothesType(119,	"Skin:119",			0, 1.0,		true, true);
	skin_Civ13M	= DefineClothesType(121,	"Skin:121",			0, 1.0,		true, true);
	skin_Civ14M	= DefineClothesType(124,	"Skin:124",			0, 1.0,		true, true);
	skin_Civ15M	= DefineClothesType(154,	"Skin:154",			0, 1.0,		true, true);
	skin_Civ16M	= DefineClothesType(162,	"Skin:162",			0, 1.0,		true, true);
	skin_Civ17M	= DefineClothesType(184,	"Skin:184",			0, 1.0,		true, true);
	skin_Civ18M	= DefineClothesType(208,	"Skin:208",			0, 1.0,		true, true);
	skin_Civ19M	= DefineClothesType(210,	"Skin:210",			0, 1.0,		true, true);
	skin_Civ20M	= DefineClothesType(268,	"Skin:268",			0, 1.0,		true, true);

	// 21 - 1male special
	skin_MechM	= DefineClothesType(50,		"Skin:50",			0, 0.6,		true, true);
	skin_BikeM	= DefineClothesType(254,	"Skin:254",			0, 0.3,		true, true);
	skin_PoliM	= DefineClothesType(283,	"Skin:283",			0, 0.3,		false, false);
	skin_ArmyM	= DefineClothesType(287,	"Skin:287",			0, 0.2,		false, true);
	skin_SwatM	= DefineClothesType(285,	"Skin:285",			0, 0.1,		false, false);
	skin_TriaM	= DefineClothesType(294,	"Skin:294",			0, 0.2,		false, false);
	skin_ClawM	= DefineClothesType(101,	"Skin:101",			0, 0.1,		true, true);
	skin_FreeM	= DefineClothesType(156,	"Skin:156",			0, 0.01,	true, true);
	skin_police	= DefineClothesType(300,	"Skin:300",			0, 0.5,		true, true);
	skin_12		= DefineClothesType(22,		"Skin:22",			0, 0.3,		true, true);
	skin_medico	= DefineClothesType(70,		"Skin:70",			0, 0.5,		true, true);

	// 31 - female civilian
	skin_Civ0F	= DefineClothesType(192,	"Skin:192",			1, 1.0,		true, true);
	skin_Civ1F	= DefineClothesType(93,		"Skin:93",			1, 1.0,		true, true);
	skin_Civ2F	= DefineClothesType(233,	"Skin:233",			1, 1.0,		true, true);
	skin_Civ3F	= DefineClothesType(193,	"Skin:193",			1, 1.0,		true, true);
	skin_Civ4F	= DefineClothesType(90,		"Skin:90",			1, 1.0,		false, false);
	skin_Civ5F	= DefineClothesType(190,	"Skin:190",			1, 1.0,		false, false);
	skin_Civ6F	= DefineClothesType(195,	"Skin:195",			1, 1.0,		true, true);
	skin_Civ7F	= DefineClothesType(41,		"Skin:41",			1, 1.0,		false, false);
	skin_Civ8F	= DefineClothesType(56,		"Skin:56",			1, 1.0,		true, true);
	skin_Civ9F	= DefineClothesType(69,		"Skin:69",			1, 1.0,		true, true);
	skin_Civ10F	= DefineClothesType(76,		"Skin:76",			1, 1.0,		true, true);
	skin_Civ11F	= DefineClothesType(91,		"Skin:91",			1, 1.0,		true, true);
	skin_Civ12F	= DefineClothesType(138,	"Skin:138",			1, 1.0,		true, true);
	skin_Civ13F	= DefineClothesType(150,	"Skin:150",			1, 1.0,		true, true);
	skin_Civ14F	= DefineClothesType(169,	"Skin:169",			1, 1.0,		true, true);
	skin_Civ15F	= DefineClothesType(216,	"Skin:216",			1, 1.0,		true, true);

	// 47 - female special
	skin_IndiF	= DefineClothesType(131,	"Skin:131",			1, 0.6,		true, true);
	skin_Cnt0F	= DefineClothesType(157,	"Skin:157",			1, 0.7,		false, false);
	skin_Cnt1F	= DefineClothesType(201,	"Skin:201",			1, 0.7,		false, false);
	skin_GangF	= DefineClothesType(298,	"Skin:298",			1, 0.6,		false, false);
	skin_ArmyF	= DefineClothesType(191,	"Skin:191",			1, 0.2,		true, true);
	skin_BusiF	= DefineClothesType(141,	"Skin:141",			1, 0.1,		true, true);
	
	// DRUG TYPE DEFINITIONS
	drug_Antibiotic	= DefineDrugType("Antibi�tico",	300000);
	drug_Painkill	= DefineDrugType("Analg�sico",	300000);
	drug_Lsd		= DefineDrugType("LSD",			300000);
	drug_Air		= DefineDrugType("AR",			300000);
	drug_Morphine	= DefineDrugType("Morfina",		300000);
	drug_Adrenaline	= DefineDrugType("Adrenalina",	300000);
	drug_Heroin		= DefineDrugType("Hero�na",		300000);
	drug_DTPA		= DefineDrugType("�cido DTPA",	300000);


	// LIQUID TYPE DEFINITIONS
	liquid_Water			= DefineLiquidType("�gua",					0.5);
	liquid_SaltWater		= DefineLiquidType("�gua Salgada",			-1.0);
	liquid_PurifiedWater	= DefineLiquidType("�gua Purificada",		1.5);
	liquid_Milk				= DefineLiquidType("Leite",					2.1);
	liquid_Orange			= DefineLiquidType("Suco de Laranja",		1.0);
	liquid_Apple			= DefineLiquidType("Suco de Ma��",			1.0);
	liquid_Whiskey			= DefineLiquidType("U�sque",				0.1);
	liquid_WineRed			= DefineLiquidType("Vinho Tinto",			0.4);
	liquid_WineWhite		= DefineLiquidType("Vinho Branco",			0.4);
	liquid_Champagne		= DefineLiquidType("Champanhe",				0.2);
	liquid_Ethanol			= DefineLiquidType("Etanol",				-44.1);
	liquid_Turpentine		= DefineLiquidType("Terebintina",			-101.0);
	liquid_HydroAcid		= DefineLiquidType("�cido Clor�drico",		-101.0);
	liquid_CarbonatedWater	= DefineLiquidType("�gua com G�s",			0.1);
	liquid_Lemon			= DefineLiquidType("Suco de Lim�o",			2.1);
	liquid_Sugar			= DefineLiquidType("A�ucar",				0.8);
	liquid_Petrol			= DefineLiquidType("Gasolina",				-8.0);
	liquid_Diesel			= DefineLiquidType("Diesel",				-8.0);
	liquid_Oil				= DefineLiquidType("�leo",					-8.0);
	liquid_BakingSoda		= DefineLiquidType("Bicarbonato de S�dio",	0.1);
	liquid_ProteinPowder	= DefineLiquidType("Prote�na em P�",		4.5);
	liquid_IronPowder		= DefineLiquidType("P� de Ferro",			0.0);
	liquid_IronOxide		= DefineLiquidType("�xido de Ferro",		-5.0);
	liquid_CopperOxide		= DefineLiquidType("�xido de Cobre",		-5.0);
	liquid_Magnesium		= DefineLiquidType("Magn�sio",				0.0);
	liquid_StrongWhiskey	= DefineLiquidType("Whisky Forte",			-5.0,	liquid_Whiskey, liquid_Ethanol);
	liquid_Fun				= DefineLiquidType("Divers�o",				-7.0,	liquid_Ethanol, liquid_Turpentine, liquid_HydroAcid);
	liquid_Lemonade			= DefineLiquidType("Limonada",				2.1,	liquid_CarbonatedWater, liquid_Lemon, liquid_Sugar);
	liquid_Orangeade		= DefineLiquidType("Laranjada",				2.5,	liquid_CarbonatedWater, liquid_Orange, liquid_Sugar);
	liquid_Thermite			= DefineLiquidType("Thermite Mix I",		-101.0,	liquid_IronPowder, liquid_IronOxide, liquid_Magnesium);
	liquid_StrongThermite	= DefineLiquidType("Thermite Mix II",		-101.0,	liquid_IronPowder, liquid_IronOxide, liquid_Magnesium, liquid_CopperOxide);


	// LIQUID CONTAINER ITEM TYPE DEFINITIONS
	DefineLiquidContainerItem(item_Detergent,		0.33,	true,	liquid_Turpentine, 1);
	DefineLiquidContainerItem(item_Bottle,			0.5,	false,	liquid_Water, 100, liquid_Orange, 50, liquid_CarbonatedWater, 25, liquid_Lemon, 25, liquid_Lemonade, 30, liquid_Orangeade, 30);
	DefineLiquidContainerItem(item_CanDrink,		0.33,	false,	liquid_Water, 100, liquid_Orange, 50, liquid_CarbonatedWater, 25, liquid_Lemon, 25, liquid_Lemonade, 30, liquid_Orangeade, 30);
	DefineLiquidContainerItem(item_MilkBottle,		0.57,	false,	liquid_Milk, 100);
	DefineLiquidContainerItem(item_MilkCarton,		1.0,	true,	liquid_Milk, 100);
	DefineLiquidContainerItem(item_AppleJuice,		1.0,	true,	liquid_Apple, 100);
	DefineLiquidContainerItem(item_OrangeJuice,		1.0,	true,	liquid_Orange, 100);
	DefineLiquidContainerItem(item_Wine1,			0.75,	false,	liquid_WineRed, 100);
	DefineLiquidContainerItem(item_Wine2,			0.75,	false,	liquid_WineWhite, 100);
	DefineLiquidContainerItem(item_Wine3,			0.75,	false,	liquid_WineRed, 100);
	DefineLiquidContainerItem(item_Whisky,			1.5,	false,	liquid_Whiskey, 100);
	DefineLiquidContainerItem(item_Champagne,		1.5,	false,	liquid_Champagne, 100);
	DefineLiquidContainerItem(item_GasCan,			20.0,	true,	liquid_Petrol, 100);
	DefineLiquidContainerItem(item_OilCan,			16.0,	true,	liquid_Oil, 100);
	DefineLiquidContainerItem(item_Ketchup,			0.5,	true);
	DefineLiquidContainerItem(item_Mustard,			0.5,	true);


 	// TREE SPECIES DEFINITIONS
	tree_Desert				= DefineTreeCategory("Deserto");
	tree_DarkForest			= DefineTreeCategory("Floresta Negra");
	tree_LightForest		= DefineTreeCategory("Floresta Clara");
	tree_GrassPlanes		= DefineTreeCategory("Gramado");

	DefineTreeSpecies(664, 5.0, 2500.0, 80.0, 25, tree_DarkForest, FALL_TYPE_ROTATE, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(670, 5.0, 2400.0, 80.0, 26, tree_DarkForest, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog, 2.0);
	DefineTreeSpecies(685, 2.0, 1600.0, 96.0, 14, tree_DarkForest, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(686, 2.0, 1600.0, 96.0, 14, tree_DarkForest, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(687, 2.0, 1800.0, 96.0, 15, tree_DarkForest, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(693, 5.0, 2800.0, 72.0, 30, tree_DarkForest, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog, 2.0);
	DefineTreeSpecies(696, 5.0, 2600.0, 72.0, 30, tree_DarkForest, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog, 2.0);
	DefineTreeSpecies(697, 5.0, 2600.0, 80.0, 30, tree_DarkForest, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog, 2.0);
	DefineTreeSpecies(704, 5.0, 2600.0, 80.0, 30, tree_DarkForest, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(719, 5.0, 2600.0, 80.0, 30, tree_DarkForest, FALL_TYPE_ROTATE, item_Chainsaw, item_WoodLog, -1.4);
	DefineTreeSpecies(720, 5.0, 2600.0, 72.0, 30, tree_DarkForest, FALL_TYPE_ROTATE, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(721, 6.0, 3000.0, 72.0, 38, tree_DarkForest, FALL_TYPE_ROTATE, item_Chainsaw, item_WoodLog, -3.2);
	DefineTreeSpecies(722, 5.0, 2600.0, 88.0, 28, tree_DarkForest, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog, -2.2);
	DefineTreeSpecies(723, 5.0, 2500.0, 88.0, 28, tree_DarkForest, FALL_TYPE_ROTATE, item_Chainsaw, item_WoodLog, 6.0);
	DefineTreeSpecies(724, 5.0, 2600.0, 72.0, 30, tree_DarkForest, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(725, 5.0, 2600.0, 72.0, 30, tree_DarkForest, FALL_TYPE_ROTATE, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(881, 1.0, 600.0, 100.0, 7, tree_DarkForest, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);

	DefineTreeSpecies(615, 2.0, 1200.0, 90.0, 15, tree_LightForest, FALL_TYPE_ROTATE, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(617, 2.0, 900.0, 90.0, 10, tree_LightForest, FALL_TYPE_ROTATE, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(654, 2.0, 1000.0, 90.0, 12, tree_LightForest, FALL_TYPE_ROTATE, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(655, 2.0, 800.0, 90.0, 8, tree_LightForest, FALL_TYPE_ROTATE, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(656, 2.5, 1100.0, 90.0, 16, tree_LightForest, FALL_TYPE_ROTATE, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(657, 2.0, 750.0, 90.0, 8, tree_LightForest, FALL_TYPE_ROTATE, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(658, 2.0, 1200.0, 90.0, 14, tree_LightForest, FALL_TYPE_ROTATE, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(661, 2.0, 850.0, 90.0, 12, tree_LightForest, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(726, 2.0, 1700.0, 90.0, 16, tree_LightForest, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(727, 2.0, 900.0, 90.0, 14, tree_LightForest, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(729, 2.0, 900.0, 90.0, 14, tree_LightForest, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(730, 2.0, 1100.0, 90.0, 15, tree_LightForest, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(731, 3.0, 1200.0, 80.0, 24, tree_LightForest, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(732, 1.5, 800.0, 90.0, 9, tree_LightForest, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(733, 2.0, 1000.0, 90.0, 15, tree_LightForest, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(734, 2.0, 1000.0, 90.0, 15, tree_LightForest, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(735, 2.0, 1200.0, 80.0, 24, tree_LightForest, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(763, 1.5, 800.0, 90.0, 8, tree_LightForest, FALL_TYPE_ROTATE, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(764, 2.0, 1000.0, 90.0, 12, tree_LightForest, FALL_TYPE_ROTATE, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(765, 1.5, 700.0, 120.0, 6, tree_LightForest, FALL_TYPE_ROTATE, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(766, 1.5, 800.0, 120.0, 8, tree_LightForest, FALL_TYPE_ROTATE, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(770, 1.5, 800.0, 112.0, 8, tree_LightForest, FALL_TYPE_ROTATE, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(771, 2.0, 1000.0, 100.0, 14, tree_LightForest, FALL_TYPE_ROTATE, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(779, 1.5, 700.0, 120.0, 6, tree_LightForest, FALL_TYPE_ROTATE, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(882, 2.0, 700.0, 100.0, 8, tree_LightForest, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(883, 2.0, 600.0, 100.0, 8, tree_LightForest, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(884, 2.0, 600.0, 100.0, 6, tree_LightForest, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(885, 2.0, 650.0, 100.0, 6, tree_LightForest, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);

	DefineTreeSpecies(629, 1.0, 400.0, 25.0, 3, tree_Desert, FALL_TYPE_ROTATE, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(674, 1.0, 500.0, 100.0, 3, tree_Desert, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(676, 1.0, 400.0, 100.0, 2, tree_Desert, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(680, 1.0, 500.0, 100.0, 3, tree_Desert, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(681, 1.0, 400.0, 100.0, 2, tree_Desert, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(773, 1.0, 650.0, 120.0, 8, tree_Desert, FALL_TYPE_ROTATE, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(891, 1.0, 400.0, 120.0, 5, tree_Desert, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(904, 1.0, 300.0, 100.0, 3, tree_Desert, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(650, 1.0, 600.0, 112.0, 1, tree_Desert, FALL_TYPE_ZDROP, item_Knife, item_CakeSlice);
	DefineTreeSpecies(651, 1.0, 600.0, 112.0, 1, tree_Desert, FALL_TYPE_ROTATE, item_Knife, item_CakeSlice);

	DefineTreeSpecies(669, 2.5, 1200.0, 100.0, 14, tree_GrassPlanes, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(671, 1.5, 600.0, 100.0, 8, tree_GrassPlanes, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(672, 2.5, 1200.0, 100.0, 10, tree_GrassPlanes, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(691, 3.5, 1200.0, 100.0, 12, tree_GrassPlanes, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(703, 3.5, 1200.0, 100.0, 12, tree_GrassPlanes, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(705, 3.5, 1950.0, 100.0, 20, tree_GrassPlanes, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(706, 3.5, 1500.0, 60.0, 22, tree_GrassPlanes, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(707, 3.5, 1500.0, 60.0, 22, tree_GrassPlanes, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(708, 2.5, 1350.0, 80.0, 18, tree_GrassPlanes, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(767, 2.0, 1200.0, 100.0, 15, tree_GrassPlanes, FALL_TYPE_ROTATE, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(768, 2.0, 1200.0, 100.0, 15, tree_GrassPlanes, FALL_TYPE_ROTATE, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(769, 2.0, 1200.0, 100.0, 15, tree_GrassPlanes, FALL_TYPE_ROTATE, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(772, 1.5, 1000.0, 100.0, 12, tree_GrassPlanes, FALL_TYPE_ROTATE, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(774, 1.5, 1000.0, 100.0, 12, tree_GrassPlanes, FALL_TYPE_ROTATE, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(775, 1.5, 800.0, 100.0, 8, tree_GrassPlanes, FALL_TYPE_ROTATE, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(776, 1.5, 800.0, 100.0, 9, tree_GrassPlanes, FALL_TYPE_ROTATE, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(777, 1.5, 1100.0, 100.0, 14, tree_GrassPlanes, FALL_TYPE_ROTATE, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(778, 1.5, 800.0, 100.0, 8, tree_GrassPlanes, FALL_TYPE_ROTATE, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(780, 1.5, 800.0, 100.0, 8, tree_GrassPlanes, FALL_TYPE_ROTATE, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(781, 1.0, 650.0, 100.0, 4, tree_GrassPlanes, FALL_TYPE_ROTATE, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(782, 1.5, 800.0, 100.0, 6, tree_GrassPlanes, FALL_TYPE_ROTATE, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(886, 1.0, 800.0, 100.0, 5, tree_GrassPlanes, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(887, 1.5, 800.0, 100.0, 6, tree_GrassPlanes, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);
	DefineTreeSpecies(888, 1.0, 600.0, 100.0, 4, tree_GrassPlanes, FALL_TYPE_ZDROP, item_Chainsaw, item_WoodLog);

	/*
		VEHICLE GROUP AND TYPE DEFINITIONS

		Groups:
			Civilian:	Regular vehicles, most common and found around cities and towns.
			Industrial:	Work vehicles found in industrial areas, factories and docks.
			Medical:	Medical vehicles that contain medical items, found at hospitals.
			Police:		Police vehicles with weapons in, found at police stations or on streets.
			Military:	Military vehicles found at army/navy bases with lots of weapons in.
			Unique:		Special vehicles that don't fit in to above groups.

		Categories:
			Car:		Regular cars, not including minivans, SUVs, etc.
			Truck:		Anything larger than a car, from minivans to vans and trucks.
			Motorbike:	Motorbikes, not including pushbikes.
			Pushbike:	Pushbikes such as mountain bike and BMX.
			Helicopter:	All helicopters, not including Hydra.
			Plane:		All planes, including sea-planes, sea-helicopters and Hydra.
			Boat:		Water vehicles including Vortex but not including sea-planes and sea-helicopters.
			Train:		Train vehicles locked to traintrack movement.

		Sizes:
			Note: sizes are only relative to the vehicle category. For example, a large bike is still smaller than a small truck.
			Small:		Anything smaller than the average.
			Medium:		The average size of most vehicles in this range.
			Large:		Any exceptions that are larger. For cars, vehicles that are too large will just be moved to Truck category since some car spawns are in tight spots.
	*/
	
	vgroup_Civilian		= DefineVehicleSpawnGroup("Civilian");
	vgroup_Industrial	= DefineVehicleSpawnGroup("Industrial");
	vgroup_Medical		= DefineVehicleSpawnGroup("Medical");
	vgroup_Police		= DefineVehicleSpawnGroup("Police");
	vgroup_Military		= DefineVehicleSpawnGroup("Military");
	vgroup_Unique		= DefineVehicleSpawnGroup("Unique");

// 00
//										model name	 			group			 	category						size					maxfuel	fuelcons	lootindex				trunksize	spawnchance	flags
	veht_Bobcat		= DefineVehicleType(422, "Bobcat",			vgroup_Civilian,	VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_MEDIUM,	60.0,		16.0,	"vehicle_industrial",		40,		20.0);
	veht_Rustler	= DefineVehicleType(476, "Rustler",			vgroup_Civilian,	VEHICLE_CATEGORY_PLANE,			VEHICLE_SIZE_MEDIUM,	88.0,		19.0,	"vehicle_civilian",			15,		0.8);
	veht_Maverick	= DefineVehicleType(487, "Maverick",		vgroup_Civilian,	VEHICLE_CATEGORY_HELICOPTER,	VEHICLE_SIZE_LARGE,		240.0,		76.0,	"vehicle_civilian",			80,		5.0);
	veht_Comet		= DefineVehicleType(480, "Comet",			vgroup_Civilian,	VEHICLE_CATEGORY_CAR,			VEHICLE_SIZE_MEDIUM,	50.0,		12.0,	"vehicle_civilian",			20,		8.0);
	veht_MountBike	= DefineVehicleType(510, "Mountain Bike",	vgroup_Civilian,	VEHICLE_CATEGORY_PUSHBIKE,		VEHICLE_SIZE_SMALL,		0.0,		0.0,	"vehicle_civilian",			2,		8.0,	VEHICLE_FLAG_NOT_LOCKABLE | VEHICLE_FLAG_NO_ENGINE);
	veht_Wayfarer	= DefineVehicleType(586, "Wayfarer",		vgroup_Civilian,	VEHICLE_CATEGORY_MOTORBIKE,		VEHICLE_SIZE_SMALL,		47.0,		8.0,	"world_survivor",			15,		10.0,	VEHICLE_FLAG_NOT_LOCKABLE);
	veht_Sabre		= DefineVehicleType(475, "Sabre",			vgroup_Civilian,	VEHICLE_CATEGORY_CAR,			VEHICLE_SIZE_MEDIUM,	60.0,		14.9,	"vehicle_civilian",			24,		17.0);
	veht_Rhino		= DefineVehicleType(432, "Rhino",			vgroup_Military,	VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_LARGE,		1900.0,		392.0,	"vehicle_military",			12,		0.01);
	veht_Barracks	= DefineVehicleType(433, "Barracks",		vgroup_Military,	VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_LARGE,		200.0,		77.0,	"vehicle_military",			100,	3.0);
	veht_Patriot	= DefineVehicleType(470, "Patriot",			vgroup_Military,	VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_MEDIUM,	94.0,		26.0,	"vehicle_military",			50,		22.0);
// 10
	veht_Boxville	= DefineVehicleType(498, "Boxville",		vgroup_Industrial,	VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_MEDIUM,	75.0,		19.0,	"vehicle_industrial",		70,		55.0);
	veht_DFT30		= DefineVehicleType(578, "DFT-30",			vgroup_Industrial,	VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_LARGE,		60.0,		13.0,	"vehicle_industrial",		0,		35.0,	VEHICLE_FLAG_CAN_SURF);
	veht_Flatbed	= DefineVehicleType(455, "Flatbed",			vgroup_Industrial,	VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_LARGE,		70.0,		69.0,	"vehicle_industrial",		140,	8.0);
	veht_Rumpo		= DefineVehicleType(440, "Rumpo",			vgroup_Industrial,	VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_MEDIUM,	55.0,		19.0,	"vehicle_industrial",		80,		45.0);
	veht_Yankee		= DefineVehicleType(456, "Yankee",			vgroup_Industrial,	VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_MEDIUM,	60.0,		45.0,	"vehicle_industrial",		80,		40.0);
	veht_Yosemite	= DefineVehicleType(554, "Yosemite",		vgroup_Civilian,	VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_MEDIUM,	60.0,		13.0,	"vehicle_industrial",		44,		50.0);
	veht_Dinghy		= DefineVehicleType(473, "Dinghy",			vgroup_Civilian,	VEHICLE_CATEGORY_BOAT,			VEHICLE_SIZE_SMALL,		81.0,		22.0,	"vehicle_civilian",			10,		64.0,	VEHICLE_FLAG_NOT_LOCKABLE | VEHICLE_FLAG_CAN_SURF);
	veht_Coastguard	= DefineVehicleType(472, "Coastguard",		vgroup_Police,		VEHICLE_CATEGORY_BOAT,			VEHICLE_SIZE_MEDIUM,	120.0,		28.0,	"vehicle_industrial",		24,		35.0,	VEHICLE_FLAG_NOT_LOCKABLE | VEHICLE_FLAG_CAN_SURF);
	veht_Launch		= DefineVehicleType(595, "Launch",			vgroup_Military,	VEHICLE_CATEGORY_BOAT,			VEHICLE_SIZE_MEDIUM,	213.0,		23.0,	"vehicle_military",			26,		40.0,	VEHICLE_FLAG_NOT_LOCKABLE | VEHICLE_FLAG_CAN_SURF);
	veht_Reefer		= DefineVehicleType(453, "Reefer",			vgroup_Civilian,	VEHICLE_CATEGORY_BOAT,			VEHICLE_SIZE_MEDIUM,	245.0,		34.0,	"vehicle_civilian",			48,		60.0,	VEHICLE_FLAG_NOT_LOCKABLE | VEHICLE_FLAG_CAN_SURF);
// 20
	veht_Tropic		= DefineVehicleType(454, "Tropic",			vgroup_Civilian,	VEHICLE_CATEGORY_BOAT,			VEHICLE_SIZE_LARGE,		260.0,		36.0,	"vehicle_civilian",			44,		55.0,	VEHICLE_FLAG_NOT_LOCKABLE | VEHICLE_FLAG_CAN_SURF);
	veht_Sentinel	= DefineVehicleType(405, "Sentinel",		vgroup_Civilian,	VEHICLE_CATEGORY_CAR,			VEHICLE_SIZE_MEDIUM,	58.8,		21.4,	"vehicle_civilian",			42,		78.0);
	veht_Regina		= DefineVehicleType(479, "Regina",			vgroup_Civilian,	VEHICLE_CATEGORY_CAR,			VEHICLE_SIZE_MEDIUM,	74.0,		28.0,	"vehicle_civilian",			48,		75.0);
	veht_Tampa		= DefineVehicleType(549, "Tampa",			vgroup_Civilian,	VEHICLE_CATEGORY_CAR,			VEHICLE_SIZE_MEDIUM,	58.0,		25.0,	"vehicle_civilian",			38,		64.0);
	veht_Clover		= DefineVehicleType(542, "Clover",			vgroup_Civilian,	VEHICLE_CATEGORY_CAR,			VEHICLE_SIZE_MEDIUM,	62.0,		26.5,	"vehicle_civilian",			34,		75.0);
	veht_Sultan		= DefineVehicleType(560, "Sultan",			vgroup_Civilian,	VEHICLE_CATEGORY_CAR,			VEHICLE_SIZE_MEDIUM,	65.0,		15.0,	"vehicle_civilian",			40,		15.0);
	veht_Huntley	= DefineVehicleType(579, "Huntley",			vgroup_Civilian,	VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_MEDIUM,	70.0,		24.6,	"vehicle_civilian",			50,		57.0);
	veht_Mesa		= DefineVehicleType(500, "Mesa",			vgroup_Civilian,	VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_MEDIUM,	77.0,		22.0,	"vehicle_civilian",			48,		25.0);
	veht_Sandking	= DefineVehicleType(495, "Sandking",		vgroup_Unique,		VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_MEDIUM,	120.0,		26.0,	"vehicle_civilian",			46,		3.5);
	veht_Bandito	= DefineVehicleType(568, "Bandito",			vgroup_Unique,		VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_MEDIUM,	48.0,		12.0,	"world_survivor",			15,		3.0,	VEHICLE_FLAG_NOT_LOCKABLE);
// 30
	veht_Ambulance	= DefineVehicleType(416, "Ambulancia",		vgroup_Medical,		VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_MEDIUM,	80.0,		23.6,	"world_medical",			70,		30.0);
	veht_Faggio		= DefineVehicleType(462, "Faggio",			vgroup_Civilian,	VEHICLE_CATEGORY_MOTORBIKE,		VEHICLE_SIZE_SMALL,		8.0,		4.0,	"vehicle_civilian",			10,		45.0,	VEHICLE_FLAG_NOT_LOCKABLE);
	veht_Sanchez	= DefineVehicleType(468, "Sanchez",			vgroup_Civilian,	VEHICLE_CATEGORY_MOTORBIKE,		VEHICLE_SIZE_SMALL,		10.0,		6.0,	"vehicle_civilian",			8,		15.0,	VEHICLE_FLAG_NOT_LOCKABLE);
	veht_Freeway	= DefineVehicleType(463, "Freeway",			vgroup_Civilian,	VEHICLE_CATEGORY_MOTORBIKE,		VEHICLE_SIZE_SMALL,		19.0,		4.0,	"world_survivor",			15,		8.0,	VEHICLE_FLAG_NOT_LOCKABLE);
	veht_Police1	= DefineVehicleType(596, "Police Car",		vgroup_Police,		VEHICLE_CATEGORY_CAR,			VEHICLE_SIZE_MEDIUM,	78.0,		12.5,	"vehicle_police",			42,		80.0);
	veht_Police2	= DefineVehicleType(597, "Police Car",		vgroup_Police,		VEHICLE_CATEGORY_CAR,			VEHICLE_SIZE_MEDIUM,	70.0,		13.0,	"vehicle_police",			42,		80.0);
	veht_Police3	= DefineVehicleType(598, "Police Car",		vgroup_Police,		VEHICLE_CATEGORY_CAR,			VEHICLE_SIZE_MEDIUM,	75.0,		12.0,	"vehicle_police",			42,		80.0);
	veht_Ranger		= DefineVehicleType(599, "Ranger",			vgroup_Police,		VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_MEDIUM,	110.0,		15.0,	"vehicle_police",			48,		30.0);
	veht_Enforcer	= DefineVehicleType(427, "Enforcer",		vgroup_Police,		VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_LARGE,		90.0,		36.0,	"vehicle_police",			64,		10.0);
	veht_FbiTruck	= DefineVehicleType(528, "FBI Truck",		vgroup_Police,		VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_MEDIUM,	80.0,		13.0,	"vehicle_police",			45,		3.0);
// 40
	veht_Seasparr	= DefineVehicleType(447, "Seasparrow",		vgroup_Civilian,	VEHICLE_CATEGORY_HELICOPTER,	VEHICLE_SIZE_MEDIUM,	96.0,		46.0,	"vehicle_civilian",			60,		0.40);
	veht_Blista		= DefineVehicleType(496, "Blista Compact",	vgroup_Civilian,	VEHICLE_CATEGORY_CAR,			VEHICLE_SIZE_MEDIUM,	40.0,		14.4,	"vehicle_civilian",			38,		68.0);
	veht_HPV1000	= DefineVehicleType(523, "HPV1000",			vgroup_Police,		VEHICLE_CATEGORY_MOTORBIKE,		VEHICLE_SIZE_SMALL,		60.0,		13.0,	"vehicle_police",			15,		45.0,	VEHICLE_FLAG_NOT_LOCKABLE);
	veht_Squalo		= DefineVehicleType(446, "Squalo",			vgroup_Civilian,	VEHICLE_CATEGORY_BOAT,			VEHICLE_SIZE_MEDIUM,	50.0,		31.0,	"vehicle_civilian",			28,		20.0,	VEHICLE_FLAG_NOT_LOCKABLE | VEHICLE_FLAG_CAN_SURF);
	veht_Marquis	= DefineVehicleType(484, "Marquis",			vgroup_Civilian,	VEHICLE_CATEGORY_BOAT,			VEHICLE_SIZE_LARGE,		900.0,		67.0,	"vehicle_civilian",			100,	50.0,	VEHICLE_FLAG_NOT_LOCKABLE | VEHICLE_FLAG_CAN_SURF);
	veht_Tug		= DefineVehicleType(583, "Tug",				vgroup_Industrial,	VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_SMALL,		10.0,		4.0,	"vehicle_industrial",		8,		10.0);
	veht_BfInject	= DefineVehicleType(424, "BF Injection",	vgroup_Civilian,	VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_MEDIUM,	40.0,		8.0,	"vehicle_civilian",			24,		15.0,	VEHICLE_FLAG_NOT_LOCKABLE);
	veht_Trailer	= DefineVehicleType(611, "Trailer",			vgroup_Industrial,	VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_SMALL,		0.0,		0.0,	"vehicle_industrial",		50,		30.0,	VEHICLE_FLAG_TRAILER);
	veht_Steamroll	= DefineVehicleType(578, "Steamroller",		vgroup_Unique,		VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_LARGE,		60.0,		13.0,	"world_survivor",			0,		0.1,	VEHICLE_FLAG_CAN_SURF);
	veht_APC30		= DefineVehicleType(578, "APC-30",			vgroup_Unique,		VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_LARGE,		60.0,		13.0,	"world_survivor",			0,		0.1,	VEHICLE_FLAG_CAN_SURF);
// 50
	veht_Moonbeam	= DefineVehicleType(418, "Moonbeam",		vgroup_Civilian,	VEHICLE_CATEGORY_CAR,			VEHICLE_SIZE_LARGE,		60.0,		18.0,	"vehicle_civilian",			65,		30.0);
	veht_Duneride	= DefineVehicleType(573, "Duneride",		vgroup_Civilian,	VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_LARGE,		180.0,		11.0,	"vehicle_civilian",			85,		10.0);
	veht_Doomride	= DefineVehicleType(573, "Doomride",		vgroup_Unique,		VEHICLE_CATEGORY_CAR,			VEHICLE_SIZE_LARGE,		180.0,		8.0,	"world_survivor",			80,		0.5);
	veht_Walton		= DefineVehicleType(478, "Walton",			vgroup_Civilian,	VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_MEDIUM,	60.0,		26.0,	"vehicle_civilian",			46,		40.0);
	veht_Rancher	= DefineVehicleType(489, "Rancher",			vgroup_Civilian,	VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_MEDIUM,	110.0,		16.0,	"vehicle_civilian",			52,		44.0);
	veht_Sadler		= DefineVehicleType(543, "Sadler",			vgroup_Civilian,	VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_MEDIUM,	60.0,		13.0,	"vehicle_civilian",			40,		70.0);
	veht_Journey	= DefineVehicleType(508, "Journey",			vgroup_Civilian,	VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_LARGE,		60.0,		13.0,	"vehicle_civilian",			76,		30.0);
	veht_Bloodring	= DefineVehicleType(504, "Bloodring Banger",vgroup_Unique,		VEHICLE_CATEGORY_CAR,			VEHICLE_SIZE_MEDIUM,	65.0,		13.0,	"vehicle_civilian",			32,		0.5);
	veht_Linerunner	= DefineVehicleType(403, "Linerunner",		vgroup_Industrial,	VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_LARGE,		120.0,		60.0,	"vehicle_industrial",		12,		5.0,	VEHICLE_FLAG_CAN_SURF);
	veht_Articulat1	= DefineVehicleType(591, "Articulated",		vgroup_Industrial,	VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_LARGE,		0.0,		0.0,	"vehicle_industrial",		100,	1.0,	VEHICLE_FLAG_TRAILER | VEHICLE_FLAG_CAN_SURF);
// 60
	veht_Firetruck	= DefineVehicleType(407, "Firetruck",		vgroup_Medical,		VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_LARGE,		115.0,		31.5,	"vehicle_industrial",		65,		0.5);
	veht_Baggage	= DefineVehicleType(485, "Baggage",			vgroup_Industrial,	VEHICLE_CATEGORY_CAR,			VEHICLE_SIZE_SMALL,		14.5,		9.5,	"vehicle_industrial",		8,		35.5,	VEHICLE_FLAG_NOT_LOCKABLE | VEHICLE_FLAG_CAN_SURF);
	veht_DavidSabre	= DefineVehicleType(475, "Scimitar",		vgroup_Unique,		VEHICLE_CATEGORY_CAR,			VEHICLE_SIZE_MEDIUM,	56.0,		37.2,	"world_survivor",			24,		3.3);
	veht_Truckfort	= DefineVehicleType(403, "Truckfort",		vgroup_Unique,		VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_MEDIUM,	265.0,		24.5,	"world_survivor",			76,		1.1);
	veht_Roadpain	= DefineVehicleType(515, "Roadpain",		vgroup_Unique,		VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_MEDIUM,	210.0,		19.2,	"world_survivor",			0,		1.4);
	veht_Vortex		= DefineVehicleType(539, "Vortex",			vgroup_Unique,		VEHICLE_CATEGORY_BOAT,			VEHICLE_SIZE_SMALL,		45.0,		11.6,	"vehicle_civilian",			4,		5.1);

    veht_Burrito    = DefineVehicleType(482, "Burrito",         vgroup_Industrial,  VEHICLE_CATEGORY_TRUCK,         VEHICLE_SIZE_MEDIUM,    65.0,       15.0,   "vehicle_industrial",     	90,     20.0);
	veht_Landstalker= DefineVehicleType(400, "Landstalker",		vgroup_Civilian,	VEHICLE_CATEGORY_CAR,			VEHICLE_SIZE_MEDIUM,	65.0,		20.0,	"vehicle_civilian",			65,	    30.0);
	veht_Bravura	= DefineVehicleType(401, "Bravura",		    vgroup_Industrial,	VEHICLE_CATEGORY_CAR,			VEHICLE_SIZE_SMALL,		50.0,		15.0,	"vehicle_industrial",		50,	    40.0);
	veht_Perennial	= DefineVehicleType(404, "Perennial",		vgroup_Industrial,	VEHICLE_CATEGORY_CAR,			VEHICLE_SIZE_MEDIUM,	65.0,		20.0,	"vehicle_industrial",		65,	    45.0);
	veht_Trashmaster= DefineVehicleType(408, "Trashmaster",		vgroup_Industrial,	VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_LARGE,		70.0,	    20.0,	"vehicle_industrial",		80,	    40.0);
	veht_Stretch	= DefineVehicleType(409, "Stretch",		    vgroup_Civilian,	VEHICLE_CATEGORY_CAR,			VEHICLE_SIZE_LARGE,		50.0,		15.0,	"vehicle_civilian",			45,	    30.0);
	veht_Manana	    = DefineVehicleType(410, "Manana",		    vgroup_Industrial,	VEHICLE_CATEGORY_CAR,			VEHICLE_SIZE_SMALL,		30.0,		8.0,	"vehicle_industrial",		35,	    50.0);
	veht_Voodoo	    = DefineVehicleType(412, "Voodoo",		    vgroup_Industrial,	VEHICLE_CATEGORY_CAR,			VEHICLE_SIZE_MEDIUM,	50.0,		10.0,	"vehicle_industrial",		60,	    40.0);
	veht_Mule	    = DefineVehicleType(414, "Mule",		    vgroup_Industrial,	VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_MEDIUM,	65.0,		25.0,	"vehicle_industrial",		85,	    40.0);
	veht_Leviathan	= DefineVehicleType(417, "Leviathan",		vgroup_Civilian,	VEHICLE_CATEGORY_HELICOPTER,	VEHICLE_SIZE_LARGE,		180.0,		20.0,	"vehicle_civilian",			130,	5.0);
//   70
	veht_Esperanto	= DefineVehicleType(419, "Esperanto",		vgroup_Industrial,	VEHICLE_CATEGORY_CAR,			VEHICLE_SIZE_LARGE,		45.0,		10.0,	"vehicle_industrial",		60,	    40.0);
	veht_Taxi   	= DefineVehicleType(420, "Taxi",		    vgroup_Industrial,	VEHICLE_CATEGORY_CAR,			VEHICLE_SIZE_MEDIUM,	45.0,		10.0,	"vehicle_industrial",		50,	    35.0);
	veht_Cabbie   	= DefineVehicleType(438, "Cabbie",		    vgroup_Industrial,	VEHICLE_CATEGORY_CAR,			VEHICLE_SIZE_MEDIUM,	45.0,		10.0,	"vehicle_industrial",		50,	    35.0);
	veht_Washington	= DefineVehicleType(421, "Washington",		vgroup_Industrial,	VEHICLE_CATEGORY_CAR,			VEHICLE_SIZE_LARGE,		60.0,		15.0,	"vehicle_industrial",		50,	    35.0);
	veht_MrWhoopee	= DefineVehicleType(423, "Mr. Whoopee",		vgroup_Industrial,	VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_LARGE,		100.0,		20.0,	"vehicle_industrial",		70,	    30.0);
	veht_Premier	= DefineVehicleType(426, "Premier",		    vgroup_Industrial,	VEHICLE_CATEGORY_CAR,			VEHICLE_SIZE_MEDIUM,    65.0,		20.0,	"vehicle_industrial",		50,	    30.0);
	veht_Securicar	= DefineVehicleType(428, "Securicar",		vgroup_Industrial,	VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_LARGE,		70.0,		20.0,	"vehicle_industrial",		80,	    30.0);
	veht_Banshee	= DefineVehicleType(429, "Banshee",	     	vgroup_Civilian,	VEHICLE_CATEGORY_CAR,			VEHICLE_SIZE_SMALL,		50.0,		20.0,	"vehicle_civilian",			50,	    20.0);
	veht_Predator	= DefineVehicleType(430, "Predator",		vgroup_Industrial,	VEHICLE_CATEGORY_BOAT,			VEHICLE_SIZE_MEDIUM,	50.0,		15.0,	"vehicle_industrial",		40,	    40.0);
	veht_Bus	    = DefineVehicleType(431, "BUS",		        vgroup_Civilian,	VEHICLE_CATEGORY_CAR,			VEHICLE_SIZE_LARGE,		100.0,		25.0,	"vehicle_civilian",			80,	    30.0);
	veht_Hotknife	= DefineVehicleType(434, "Hotknife",		vgroup_Industrial,	VEHICLE_CATEGORY_CAR,			VEHICLE_SIZE_SMALL,		50.0,		10.0,	"vehicle_industrial",		45,	    20.0);
// 80
	veht_Monster	= DefineVehicleType(444, "Monster",		    vgroup_Industrial,	VEHICLE_CATEGORY_TRUCK,			VEHICLE_SIZE_LARGE,		80.0,		30.0,	"vehicle_industrial",		80,	    10.0);
	veht_Pizzaboy	= DefineVehicleType(448, "Pizzaboy",		vgroup_Industrial,	VEHICLE_CATEGORY_MOTORBIKE,	    VEHICLE_SIZE_SMALL,		30.0,		10.0,	"vehicle_industrial",		14,	    60.0);
	veht_PCJ	    = DefineVehicleType(461, "PCJ-600",		    vgroup_Industrial,	VEHICLE_CATEGORY_MOTORBIKE,	    VEHICLE_SIZE_SMALL,		30.0,		15.0,	"vehicle_industrial",		14,	    30.0);
	veht_Quad	    = DefineVehicleType(471, "Quad",		    vgroup_Industrial,	VEHICLE_CATEGORY_MOTORBIKE,		VEHICLE_SIZE_SMALL,		30.0,		10.0,	"vehicle_industrial",		14,	    25.0);
	veht_ZR     	= DefineVehicleType(477, "ZR-350",	     	vgroup_Civilian,	VEHICLE_CATEGORY_CAR,	        VEHICLE_SIZE_SMALL,		60.0,		20.0,	"vehicle_civilian",			40,	    20.0);
	veht_SANNews	= DefineVehicleType(488, "San News Maverick",vgroup_Industrial,	VEHICLE_CATEGORY_HELICOPTER,	VEHICLE_SIZE_LARGE,		80.0,		20.0,	"vehicle_industrial",		100,	10.0);
	veht_FBI	    = DefineVehicleType(490, "FBI Rancher",		vgroup_Police,	    VEHICLE_CATEGORY_CAR,			VEHICLE_SIZE_MEDIUM,	80.0,		20.0,	"vehicle_police",		    80,	    20.0);
	veht_Hotring	= DefineVehicleType(494, "Hotring Racer",	vgroup_Civilian,	VEHICLE_CATEGORY_CAR,			VEHICLE_SIZE_MEDIUM,	80.0,		30.0,	"vehicle_civilian",			50,	    5.0);
	veht_Police	    = DefineVehicleType(497, "Police Maverick",	vgroup_Police,	    VEHICLE_CATEGORY_HELICOPTER,	VEHICLE_SIZE_LARGE,		100.0,		20.0,	"vehicle_police",		    100,	10.0);
	veht_Super	    = DefineVehicleType(506, "Super GT",		vgroup_Civilian,	VEHICLE_CATEGORY_CAR,			VEHICLE_SIZE_SMALL,		45.0,		20.0,	"vehicle_civilian",		    45,	    10.0);
	veht_Turismo    = DefineVehicleType(451, "Turismo",			vgroup_Unique,	    VEHICLE_CATEGORY_CAR,			VEHICLE_SIZE_SMALL,		45.0,		30.0,	"vehicle_civilian",		    45,	    5.0);
// 90
	veht_Phoenix 	= DefineVehicleType(603, "Phoenix", 		vgroup_Industrial,	VEHICLE_CATEGORY_CAR, 		    VEHICLE_SIZE_LARGE,  	50.0,  		7.0, 	"vehicle_industrial", 		70, 	13.0);
	veht_Hustler    = DefineVehicleType(603, "Hustler",  		vgroup_Industrial, 	VEHICLE_CATEGORY_CAR,  			VEHICLE_SIZE_LARGE,  	50.0,  		6.0, 	"vehicle_industrial",  		65,	    13.0);
	veht_NRG 		= DefineVehicleType(522, "NRG",		        vgroup_Industrial,	VEHICLE_CATEGORY_MOTORBIKE,	    VEHICLE_SIZE_SMALL,		30.0,		15.0,	"vehicle_industrial",		14,	    10.0);
	veht_Infernus   = DefineVehicleType(411, "Infernus",		vgroup_Unique,	    VEHICLE_CATEGORY_CAR,			VEHICLE_SIZE_SMALL,		45.0,		30.0,	"vehicle_civilian",		    45,	    15.0);

	// SETTING VEHICLES TO PULL TRAILERS
	SetVehicleTypeTrailerHitch(veht_Bobcat,		VEHICLE_SIZE_SMALL);
	SetVehicleTypeTrailerHitch(veht_Patriot,	VEHICLE_SIZE_SMALL);
	SetVehicleTypeTrailerHitch(veht_Yosemite,	VEHICLE_SIZE_SMALL);
	SetVehicleTypeTrailerHitch(veht_Sentinel,	VEHICLE_SIZE_SMALL);
	SetVehicleTypeTrailerHitch(veht_Regina,		VEHICLE_SIZE_SMALL);
	SetVehicleTypeTrailerHitch(veht_Tampa,	 	VEHICLE_SIZE_SMALL);
	SetVehicleTypeTrailerHitch(veht_Clover,		VEHICLE_SIZE_SMALL);
	SetVehicleTypeTrailerHitch(veht_Huntley,	VEHICLE_SIZE_SMALL);
	SetVehicleTypeTrailerHitch(veht_Mesa,		VEHICLE_SIZE_SMALL);
	SetVehicleTypeTrailerHitch(veht_Blista,		VEHICLE_SIZE_SMALL);
	SetVehicleTypeTrailerHitch(veht_Linerunner, VEHICLE_SIZE_LARGE);

	return 1;
}
