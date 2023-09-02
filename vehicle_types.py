import re
import json

# Provided vehicle data
vehicle_data = """
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
"""

# Find all matches
matches = re.findall(r"DefineVehicleType\((.*?)\);", vehicle_data)

# Initialize an empty dictionary to hold the JSON data
json_data = {}

# Process each match
for match in matches:
    # Split the parameters by comma and strip extra spaces
    params = [param.strip() for param in match.split(",")]
    
    # Extract each parameter value
    model_id     = int(params[0])
    name         = params[1].strip('"')
    group        = params[2]
    category     = params[3]
    size         = params[4]
    max_fuel     = float(params[5])
    fuel_cons    = float(params[6])
    loot_index   = params[7].strip('"')
    trunk_size   = int(params[8])
    spawn_chance = float(params[9])
    flags        = params[10] if len(params) > 10 else None

    # Create a dictionary for the current vehicle
    vehicle_info = {
        "name"       : name,
        "group"      : group,
        "category"   : category,
        "size"       : size,
        "maxFuel"    : max_fuel,
        "fuelCons"   : fuel_cons,
        "lootIndex"  : loot_index,
        "trunkSize"  : trunk_size,
        "spawnChance": spawn_chance,
        "flags"      : flags
    }
    
    # Add the dictionary to the main JSON data dictionary using model_id as key
    json_data[model_id] = vehicle_info

# Convert the dictionary to a JSON string
json_str = json.dumps(json_data, indent=4)

with open('vehicle_data.json', "w") as f: f.write(json_str)