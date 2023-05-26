// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// Example Filterscript for the new LS Apartments 1 Building with Elevator
// -----------------------------------------------------------------------
// Original elevator code by Zamaroht in 2010
//
// Updated by Kye in 2011
// * Added a sound effect for the elevator starting/stopping
//
// Edited by Matite in January 2015
// * Added code to remove the existing building, add the new building and
//   edited the elevator code so it works in this new building
//
// Updated to v1.02 by Matite in February 2015
// * Added code for the new car park object and edited the elevator to
//   include the car park
//
// This script creates the new LS Apartments 1 building object, removes the
// existing GTASA building object, adds the new car park object and creates
// an elevator that can be used to travel between all levels.
//
// You can un-comment the OnPlayerCommandText callback below to enable a simple
// teleport command (/lsa) that teleports you to the LS Apartments 1 building.
//
// Warning...
// This script uses a total of:
// * 27 objects = 1 for the elevator, 2 for the elevator doors, 22 for the
//   elevator floor doors, 1 for the replacement LS Apartments 1 building
//   and 1 for the car park
// * 12 3D Text Labels = 11 on the floors and 1 in the elevator
// * 1 dialog (for the elevator - dialog ID 876)
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------


// -----------------------------------------------------------------------------
// Includes
// --------

// SA-MP include
#include <a_samp>

// For PlaySoundForPlayersInRange()
#include "../include/gl_common.inc"

// -----------------------------------------------------------------------------
// Defines
// -------

// Movement speed of the elevator
#define ELEVATOR_SPEED      (5.0)

// Movement speed of the doors
#define DOORS_SPEED         (5.0)

// Time in ms that the elevator will wait in each floor before continuing with the queue...
// be sure to give enough time for doors to open
#define ELEVATOR_WAIT_TIME  (5000)  

// Dialog ID for the LS Apartments building elevator dialog
#define DIALOG_ID           (876)

// Position defines
#define Y_DOOR_CLOSED       (-1180.535917)
#define Y_DOOR_R_OPENED     Y_DOOR_CLOSED - 1.6
#define Y_DOOR_L_OPENED     Y_DOOR_CLOSED + 1.6

#define GROUND_Z_COORD      (20.879316)

#define ELEVATOR_OFFSET     (0.059523)

#define X_ELEVATOR_POS      (1181.622924)
#define Y_ELEVATOR_POS      (-1180.554687)

// Elevator state defines
#define ELEVATOR_STATE_IDLE     (0)
#define ELEVATOR_STATE_WAITING  (1)
#define ELEVATOR_STATE_MOVING   (2)

// Invalid floor define
#define INVALID_FLOOR           (-1)

// Used for chat text messages
#define COLOR_MESSAGE_YELLOW        0xFFDD00AA

// -----------------------------------------------------------------------------
// Constants
// ---------

// Elevator floor names for the 3D text labels
static FloorNames[11][] =
{
	"Car Park",
	"Ground Floor",
	"First Floor",
	"Second Floor",
	"Third Floor",
	"Fourth Floor",
	"Fifth Floor",
	"Sixth Floor",
	"Seventh Floor",
	"Eighth Floor",
	"Ninth Floor"
};

// Elevator floor Z heights
static Float:FloorZOffsets[11] =
{
    0.0, 		// Estacionamento
    13.604544,	// Térreo
    18.808519,	// Primeiro Andar = 13.604544 + 5.203975
    24.012494,  // Segundo Andar = 18.808519 + 5.203975
    29.216469,  // Terceiro Andar = 24.012494 + 5.203975
    34.420444,  // Quarto Andar = 29.216469 + 5.203975
    39.624419,  // Quinto Andar = 34.420444 + 5.203975
    44.828394,  // Sexto Andar = 39.624419 + 5.203975
    50.032369,  // Sétimo Andar = 44.828394 + 5.203975
    55.236344,  // Oitavo Andar = 50.032369 + 5.203975
    60.440319   // Nono Andar = 55.236344 + 5.203975
};

// ---------
// Variables
// ---------

new 
	Obj_Elevator, Obj_ElevatorDoors[2], Obj_FloorDoors[11][2],
	ElevatorState,
	ElevatorFloor,  
	ElevatorQueue[11],
	FloorRequestedBy[11],
	ElevatorBoostTimer,
	Text3D:Label_Elevator, Text3D:Label_Floors[11];

// -----------------
// Function Forwards
// -----------------

// Public:
forward CallElevator(playerid, floorid);    // You can use INVALID_PLAYER_ID too.
forward ShowElevatorDialog(playerid);

// Private:
forward Elevator_Initialize();
forward Elevator_Destroy();

forward Elevator_OpenDoors();
forward Elevator_CloseDoors();
forward Floor_OpenDoors(floorid);
forward Floor_CloseDoors(floorid);

forward Elevator_MoveToFloor(floorid);
forward Elevator_Boost(floorid);        	// Increases the elevator speed until it reaches 'floorid'.
forward Elevator_TurnToIdle();

forward ReadNextFloorInQueue();
forward RemoveFirstQueueFloor();
forward AddFloorToQueue(floorid);
forward IsFloorInQueue(floorid);
forward ResetElevatorQueue();

forward DidPlayerRequestElevator(playerid);

forward Float:GetElevatorZCoordForFloor(floorid);
forward Float:GetDoorsZCoordForFloor(floorid);


// ---------
// Callbacks
// ---------

public OnFilterScriptInit()
{
	ResetElevatorQueue();
	Elevator_Initialize();

	print("\n");
	print("  |---------------------------------------------------");
	print("  |--- LS Apartments 1 Filterscript");
    print("  |--  Script v1.02");
    print("  |--  5th February 2015");
	print("  |---------------------------------------------------");

	return 1;
}

public OnFilterScriptExit()
{
	Elevator_Destroy();

    print("  |--  LS Apartments 1 Elevator destroyed");
    print("  |---------------------------------------------------");

	return 1;
}

public OnObjectMoved(objectid)
{
	// Create variables
    new Float:x, Float:y, Float:z;
    
    // Loop
	for(new i; i < sizeof(Obj_FloorDoors); i ++)
	{
		if(objectid == Obj_FloorDoors[i][0])
		{
		    GetObjectPos(Obj_FloorDoors[i][0], x, y, z);

            if (y < Y_DOOR_L_OPENED - 0.5)
		    {
				Elevator_MoveToFloor(ElevatorQueue[0]);
				RemoveFirstQueueFloor();
			}
		}
	}

	if(objectid == Obj_Elevator)
	{
	    KillTimer(ElevatorBoostTimer);

	    FloorRequestedBy[ElevatorFloor] = INVALID_PLAYER_ID;

	    Elevator_OpenDoors();
	    Floor_OpenDoors(ElevatorFloor);

	    GetObjectPos(Obj_Elevator, x, y, z);
	    Label_Elevator	= Create3DTextLabel("{CCCCCC}Pressione '{FFFFFF}~k~~CONVERSATION_YES~{CCCCCC}' to use elevator", 0xCCCCCCAA, X_ELEVATOR_POS - 1.7, Y_ELEVATOR_POS - 1.75, z - 0.4, 4.0, 0, 1);

	    ElevatorState 	= ELEVATOR_STATE_WAITING;
	    SetTimer("Elevator_TurnToIdle", ELEVATOR_WAIT_TIME, 0);
	}

	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == DIALOG_ID)
    {
        if(!response)
            return 0;

        if(FloorRequestedBy[listitem] != INVALID_PLAYER_ID || IsFloorInQueue(listitem))
            GameTextForPlayer(playerid, "~r~The floor is already in the queue", 3500, 4);
		else if(DidPlayerRequestElevator(playerid))
		    GameTextForPlayer(playerid, "~r~You already requested the elevator", 3500, 4);
		else
	        CallElevator(playerid, listitem);

		return 1;
    }

	return 0;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if (!IsPlayerInAnyVehicle(playerid) && (newkeys & KEY_YES))
	{
	    new Float:pos[3];
	    GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
	    
	    // For debug
	    //printf("X = %0.2f | Y = %0.2f | Z = %0.2f", pos[0], pos[1], pos[2]);

	    if (pos[1] > (Y_ELEVATOR_POS - 1.8) && pos[1] < (Y_ELEVATOR_POS + 1.8) && pos[0] < (X_ELEVATOR_POS + 1.8) && pos[0] > (X_ELEVATOR_POS - 1.8))
	        ShowElevatorDialog(playerid);

		else
		{
		    if(pos[1] < (Y_ELEVATOR_POS - 1.81) && pos[1] > (Y_ELEVATOR_POS - 3.8) && pos[0] > (X_ELEVATOR_POS - 3.8) && pos[0] < (X_ELEVATOR_POS - 1.81))
		    {
				new i = 10;

				while(pos[2] < GetDoorsZCoordForFloor(i) + 3.5 && i > 0)
				    i --;

				if(i == 0 && pos[2] < GetDoorsZCoordForFloor(0) + 2.0)
				    i = -1;

				if (i <= 9)
				{
				    if (ElevatorState != ELEVATOR_STATE_MOVING)
				    {
				        if (ElevatorFloor == i + 1)
				        {
							GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~y~~h~LS Apartments 1 Elevator Is~n~~y~~h~Already On This Floor...~n~~w~Walk Inside It~n~~w~And Press '~k~~CONVERSATION_YES~'", 3500, 3);

	                        SendClientMessage(playerid, COLOR_MESSAGE_YELLOW, "* The LS Apartments 1 elevator is already on this floor... walk inside it and press '{FFFFFF}~k~~CONVERSATION_YES~{CCCCCC}'");

	                        return 1;
				        }
				    }

					CallElevator(playerid, i + 1);

					GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~n~~g~~h~LS Apartments 1 Elevator~n~~g~~h~Has Been Called...~n~~w~Please Wait", 3000, 3);

					new strTempString[100];
					
					if (ElevatorState == ELEVATOR_STATE_MOVING)
						format(strTempString, sizeof(strTempString), "* The LS Apartments 1 elevator has been called... it is currently moving towards the %s.", FloorNames[ElevatorFloor]);

					else
					{
					    if (ElevatorFloor == 0)
							format(strTempString, sizeof(strTempString), "* The LS Apartments 1 elevator has been called... it is currently at the %s.", FloorNames[ElevatorFloor]);

						else
							format(strTempString, sizeof(strTempString), "* The LS Apartments 1 elevator has been called... it is currently on the %s.", FloorNames[ElevatorFloor]);
					}
					
					SendClientMessage(playerid, COLOR_MESSAGE_YELLOW, strTempString);

					return 1;
				}
		    }
		}
	}

	return 1;
}

// ------------------------ Functions ------------------------
stock Elevator_Initialize()
{
	Obj_Elevator 			= CreateObject(18755, X_ELEVATOR_POS, Y_ELEVATOR_POS, GROUND_Z_COORD + ELEVATOR_OFFSET, 0.000000, 0.000000, 0.000000);
	Obj_ElevatorDoors[0] 	= CreateObject(18757, X_ELEVATOR_POS, Y_ELEVATOR_POS, GROUND_Z_COORD + ELEVATOR_OFFSET, 0.000000, 0.000000, 0.000000);
	Obj_ElevatorDoors[1] 	= CreateObject(18756, X_ELEVATOR_POS, Y_ELEVATOR_POS, GROUND_Z_COORD + ELEVATOR_OFFSET, 0.000000, 0.000000, 0.000000);

	Label_Elevator = Create3DTextLabel("{CCCCCC}Press '{FFFFFF}~k~~CONVERSATION_YES~{CCCCCC}' to use elevator", 0xCCCCCCAA, X_ELEVATOR_POS - 1.7, Y_ELEVATOR_POS - 1.75, GROUND_Z_COORD - 0.4, 4.0, 0, 1);

	new string[128], Float:z;

	for (new i; i < sizeof(Obj_FloorDoors); i ++)
	{
	    Obj_FloorDoors[i][0] 	= CreateObject(18757, X_ELEVATOR_POS - 0.245, Y_ELEVATOR_POS, GetDoorsZCoordForFloor(i), 0.000000, 0.000000, 0.000000);
		Obj_FloorDoors[i][1] 	= CreateObject(18756, X_ELEVATOR_POS - 0.245, Y_ELEVATOR_POS, GetDoorsZCoordForFloor(i), 0.000000, 0.000000, 0.000000);

		format(string, sizeof(string), "{CCCCCC}[%s]\n{CCCCCC}Pressione {FFFFFF}~k~~CONVERSATION_YES~{CCCCCC}' to call", FloorNames[i]);

		z = GetDoorsZCoordForFloor(i);

		Label_Floors[i] = Create3DTextLabel(string, 0xCCCCCCAA, X_ELEVATOR_POS - 2.5, Y_ELEVATOR_POS - 2.5, z - 0.2, 10.5, 0, 1);
	}

	Floor_OpenDoors(0);
	Elevator_OpenDoors();

	return 1;
}

stock Elevator_Destroy()
{
	DestroyObject(Obj_Elevator);
	DestroyObject(Obj_ElevatorDoors[0]);
	DestroyObject(Obj_ElevatorDoors[1]);
	Delete3DTextLabel(Label_Elevator);

	for(new i; i < sizeof(Obj_FloorDoors); i ++)
	{
	    DestroyObject(Obj_FloorDoors[i][0]);
		DestroyObject(Obj_FloorDoors[i][1]);
		Delete3DTextLabel(Label_Floors[i]);
	}

	return 1;
}

stock Elevator_OpenDoors()
{
	new Float:x, Float:y, Float:z;

	GetObjectPos(Obj_ElevatorDoors[0], x, y, z);
	MoveObject(Obj_ElevatorDoors[0], x, Y_DOOR_L_OPENED, z, DOORS_SPEED);
	MoveObject(Obj_ElevatorDoors[1], x, Y_DOOR_R_OPENED, z, DOORS_SPEED);

	return 1;
}

stock Elevator_CloseDoors()
{
    if(ElevatorState == ELEVATOR_STATE_MOVING)
	    return 0;

    new Float:x, Float:y, Float:z;

	GetObjectPos(Obj_ElevatorDoors[0], x, y, z);
	MoveObject(Obj_ElevatorDoors[0], x, Y_DOOR_CLOSED, z, DOORS_SPEED);
	MoveObject(Obj_ElevatorDoors[1], x, Y_DOOR_CLOSED, z, DOORS_SPEED);

	return 1;
}

stock Floor_OpenDoors(floorid)
{
    MoveObject(Obj_FloorDoors[floorid][0], X_ELEVATOR_POS - 0.245, Y_DOOR_L_OPENED, GetDoorsZCoordForFloor(floorid), DOORS_SPEED);
	MoveObject(Obj_FloorDoors[floorid][1], X_ELEVATOR_POS - 0.245, Y_DOOR_R_OPENED, GetDoorsZCoordForFloor(floorid), DOORS_SPEED);
	
	PlaySoundForPlayersInRange(6401, 50.0, X_ELEVATOR_POS, Y_ELEVATOR_POS, GetDoorsZCoordForFloor(floorid) + 5.0);

	return 1;
}

stock Floor_CloseDoors(floorid)
{
    MoveObject(Obj_FloorDoors[floorid][0], X_ELEVATOR_POS - 0.245, Y_ELEVATOR_POS, GetDoorsZCoordForFloor(floorid), DOORS_SPEED);
	MoveObject(Obj_FloorDoors[floorid][1], X_ELEVATOR_POS - 0.245, Y_ELEVATOR_POS, GetDoorsZCoordForFloor(floorid), DOORS_SPEED);
	
	PlaySoundForPlayersInRange(6401, 50.0, X_ELEVATOR_POS, Y_ELEVATOR_POS, GetDoorsZCoordForFloor(floorid) + 5.0);

	return 1;
}

stock Elevator_MoveToFloor(floorid)
{
	ElevatorState = ELEVATOR_STATE_MOVING;
	ElevatorFloor = floorid;

	MoveObject(Obj_Elevator, X_ELEVATOR_POS, Y_ELEVATOR_POS, GetElevatorZCoordForFloor(floorid), 0.25);
    MoveObject(Obj_ElevatorDoors[0], X_ELEVATOR_POS, Y_ELEVATOR_POS, GetDoorsZCoordForFloor(floorid), 0.25);
    MoveObject(Obj_ElevatorDoors[1], X_ELEVATOR_POS, Y_ELEVATOR_POS, GetDoorsZCoordForFloor(floorid), 0.25);
    Delete3DTextLabel(Label_Elevator);

	ElevatorBoostTimer = SetTimerEx("Elevator_Boost", 2000, 0, "i", floorid);

	return 1;
}

public Elevator_Boost(floorid)
{
	StopObject(Obj_Elevator);
	StopObject(Obj_ElevatorDoors[0]);
	StopObject(Obj_ElevatorDoors[1]);
	
	MoveObject(Obj_Elevator, X_ELEVATOR_POS, Y_ELEVATOR_POS, GetElevatorZCoordForFloor(floorid), ELEVATOR_SPEED);
    MoveObject(Obj_ElevatorDoors[0], X_ELEVATOR_POS, Y_ELEVATOR_POS, GetDoorsZCoordForFloor(floorid), ELEVATOR_SPEED);
    MoveObject(Obj_ElevatorDoors[1], X_ELEVATOR_POS, Y_ELEVATOR_POS, GetDoorsZCoordForFloor(floorid), ELEVATOR_SPEED);

	return 1;
}

public Elevator_TurnToIdle()
{
	ElevatorState = ELEVATOR_STATE_IDLE;
	ReadNextFloorInQueue();

	return 1;
}

stock RemoveFirstQueueFloor()
{
	for(new i; i < sizeof(ElevatorQueue) - 1; i ++)
	    ElevatorQueue[i] = ElevatorQueue[i + 1];

	ElevatorQueue[sizeof(ElevatorQueue) - 1] = INVALID_FLOOR;

	return 1;
}

stock AddFloorToQueue(floorid)
{
	new slot = -1;
	for(new i; i < sizeof(ElevatorQueue); i ++)
	{
	    if(ElevatorQueue[i] == INVALID_FLOOR)
	    {
	        slot = i;
	        break;
	    }
	}

	if(slot != -1)
	{
	    ElevatorQueue[slot] = floorid;

	    if(ElevatorState == ELEVATOR_STATE_IDLE)
	        ReadNextFloorInQueue();

	    return 1;
	}

	return 0;
}

stock ResetElevatorQueue()
{
	for(new i; i < sizeof(ElevatorQueue); i ++)
	{
	    ElevatorQueue[i] 	= INVALID_FLOOR;
	    FloorRequestedBy[i] = INVALID_PLAYER_ID;
	}

	return 1;
}

stock IsFloorInQueue(floorid)
{
	for(new i; i < sizeof(ElevatorQueue); i ++)
	    if(ElevatorQueue[i] == floorid)
	        return 1;

	return 0;
}

stock ReadNextFloorInQueue()
{
	if(ElevatorState != ELEVATOR_STATE_IDLE || ElevatorQueue[0] == INVALID_FLOOR)
	    return 0;

	Elevator_CloseDoors();
	Floor_CloseDoors(ElevatorFloor);

	return 1;
}

stock DidPlayerRequestElevator(playerid)
{
	for(new i; i < sizeof(FloorRequestedBy); i ++)
	    if(FloorRequestedBy[i] == playerid)
	        return 1;

	return 0;
}

stock ShowElevatorDialog(playerid)
{
	new string[512];
	for(new i; i < sizeof(ElevatorQueue); i ++)
	{
	    if(FloorRequestedBy[i] != INVALID_PLAYER_ID)
	        strcat(string, "{FF0000}");

	    strcat(string, FloorNames[i]);
	    strcat(string, "\n");
	}

	ShowPlayerDialog(playerid, DIALOG_ID, DIALOG_STYLE_LIST, "Elevador:", string, "{33AA33}>", "{E85454}X");

	return 1;
}

stock CallElevator(playerid, floorid)
{
	if(FloorRequestedBy[floorid] != INVALID_PLAYER_ID || IsFloorInQueue(floorid))
	    return 0;

	FloorRequestedBy[floorid] = playerid;
	AddFloorToQueue(floorid);

	return 1;
}

stock Float:GetElevatorZCoordForFloor(floorid)
    return (GROUND_Z_COORD + FloorZOffsets[floorid] + ELEVATOR_OFFSET);

stock Float:GetDoorsZCoordForFloor(floorid)
	return (GROUND_Z_COORD + FloorZOffsets[floorid] + ELEVATOR_OFFSET);
