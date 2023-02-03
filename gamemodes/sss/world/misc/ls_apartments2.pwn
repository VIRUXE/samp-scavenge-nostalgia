#include <YSI\y_hooks>

#define YELLOW						0xFFFF00FF
#define DIALOG_ID           (879)

enum
{
	ELEVATOR_STATE_IDLE,
	ELEVATOR_STATE_WAITING,
	ELEVATOR_STATE_MOVING
}

static const
	Float:ELEVATOR_SPEED	= 5.0,
	Float:DOORS_SPEED		= 5.0,
	ELEVATOR_WAIT_TIME		= 5000,

	Float:Y_DOOR_CLOSED		= -1180.535917,
	Float:Y_DOOR_R_OPENED	= -1182.135917, // Y_DOOR_CLOSED - 1.6
	Float:Y_DOOR_L_OPENED	= -1178.935917, // Y_DOOR_CLOSED + 1.6

	Float:GROUND_Z_COORD	= 20.879316,

	Float:ELEVATOR_OFFSET	= 0.059523,

	Float:X_ELEVATOR_POS	= 1181.622924,
	Float:Y_ELEVATOR_POS	= -1180.554687,

	INVALID_FLOOR			= -1;

static
	FloorNames[11][] =
	{
		"Estacionamento",
		"Térreo",
		"Primeiro andar",
		"Segundo andar",
		"Terceiro andar",
		"Quarto andar",
		"Quinto andar",
		"Sexto andar",
		"Sétimo andar",
		"Oitavo andar",
		"Nono andar"
	},
	Float:FloorZOffsets[11] =
	{
		0.0,		// Car Park
		13.604544,	// Ground Floor
		18.808519,	// First Floor = 13.604544 + 5.203975
		24.012494,	// Second Floor = 18.808519 + 5.203975
		29.216469,	// Third Floor = 24.012494 + 5.203975
		34.420444,	// Fourth Floor = 29.216469 + 5.203975
		39.624419,	// Fifth Floor = 34.420444 + 5.203975
		44.828394,	// Sixth Floor = 39.624419 + 5.203975
		50.032369,	// Seventh Floor = 44.828394 + 5.203975
		55.236344,	// Eighth Floor = 50.032369 + 5.203975
		60.440319 	// Ninth Floor = 55.236344 + 5.203975
	},
	Obj_Elevator,
	Obj_ElevatorDoors[2],
	Obj_FloorDoors[11][2],
	Text3D:Label_Elevator,
	Text3D:Label_Floors[11],
	ElevatorState,
	ElevatorFloor,
	ElevatorQueue[11],
	FloorRequestedBy[11],
	ElevatorBoostTimer;


// Public:
forward CallElevator(playerid, floorid);
forward ShowElevatorDialog(playerid);

// Private:
forward Elevator_Initialize();

forward Elevator_OpenDoors();
forward Elevator_CloseDoors();
forward Floor_OpenDoors(floorid);
forward Floor_CloseDoors(floorid);

forward Elevator_MoveToFloor(floorid);
forward Elevator_Boost(floorid);
forward Elevator_TurnToIdle();

forward ReadNextFloorInQueue();
forward RemoveFirstQueueFloor();
forward AddFloorToQueue(floorid);
forward IsFloorInQueue(floorid);
forward ResetElevatorQueue();

forward DidPlayerRequestElevator(playerid);

//forward DidPlayerRequestElevator(playerid);

forward Float:GetElevatorZCoordForFloor(floorid);
forward Float:GetDoorsZCoordForFloor(floorid);


hook OnScriptInit()
{
	ResetElevatorQueue();
	Elevator_Initialize();
}


hook OnObjectMoved(objectid)
{


	new Float:x, Float:y, Float:z;

	// Check if the object that moved was one of the elevator floor doors
	// Todo: improve with inverse indexing/tagging
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
		Label_Elevator	= Create3DTextLabel("{CCCCCC}Pressione '{FFFFFF}~k~~CONVERSATION_YES~{CCCCCC}' para usar o elevador", 0xCCCCCCAA, X_ELEVATOR_POS - 1.7, Y_ELEVATOR_POS - 1.75, z - 0.4, 4.0, 0, 1);

		ElevatorState 	= ELEVATOR_STATE_WAITING;
		SetTimer("Elevator_TurnToIdle", ELEVATOR_WAIT_TIME, 0);
	}

	return 1;
}
/* TODO: Do buttons instead of reinventing-wheel-button-detection
hook OnButtonPress(playerid, buttonid)
{
	return Y_HOOKS_CONTINUE_RETURN_0;
}
*/
hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{


	if (!IsPlayerInAnyVehicle(playerid) && (newkeys & KEY_YES))
	{
		new Float:pos[3];
		GetPlayerPos(playerid, pos[0], pos[1], pos[2]);

		if (pos[1] > (Y_ELEVATOR_POS - 1.8) && pos[1] < (Y_ELEVATOR_POS + 1.8) && pos[0] < (X_ELEVATOR_POS + 1.8) && pos[0] > (X_ELEVATOR_POS - 1.8))
		{
			ShowElevatorDialog(playerid);
		}
		else
		{
			if(pos[1] < (Y_ELEVATOR_POS - 1.81) && pos[1] > (Y_ELEVATOR_POS - 3.8) && pos[0] > (X_ELEVATOR_POS - 3.8) && pos[0] < (X_ELEVATOR_POS - 1.81))
			{
				new i = 10;

				// Loop
				while(pos[2] < GetDoorsZCoordForFloor(i) + 3.5 && i > 0)
					i --;

				if(i == 0 && pos[2] < GetDoorsZCoordForFloor(0) + 2.0)
					i = -1;

				if (i <= 9)
				{
					// Check if the elevator is not moving (idle or waiting)
					if (ElevatorState != ELEVATOR_STATE_MOVING)
					{
						// Check if the elevator is already on the floor it was called from
						if (ElevatorFloor == i + 1)
						{
							// Display gametext message to the player
							GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~y~~h~O elevador ~n~~y~~h~Ja esta neste andar...~n~~w~entre dentro~n~~w~E Pressione '~k~~CONVERSATION_YES~'", 3500, 3);

							// Display chat text message to the player
							SendClientMessage(playerid, YELLOW, "* O elevador já está neste andar ... entre e pressione '{FFFFFF}~k~~CONVERSATION_YES~{CCCCCC}'");

							// Exit here (return 1 so this callback is processed in other scripts)
							return 1;
						}
					}

					// Call function to call the elevator to the floor
					CallElevator(playerid, i + 1);

					// Display gametext message to the player
					GameTextForPlayer(playerid, "~n~~n~~n~~n~~n~~n~~n~~n~~g~~h~O elevador~n~~g~~h~Foi chamado...~n~~w~Por favor aguarde", 3000, 3);

					// Create variable for formatted message
					new strTempString[100];

					// Check if the elevator is moving
					if (ElevatorState == ELEVATOR_STATE_MOVING)
					{
						// Format chat text message
						format(strTempString, sizeof(strTempString), "* O elevador foi chamado... atualmente está se movendo em direção ao %s.", FloorNames[ElevatorFloor]);
					}
					else
					{
						// Check if the floor is the car park
						if (ElevatorFloor == 0)
						{
							// Format chat text message
							format(strTempString, sizeof(strTempString), "* O elevador foi chamado... atualmente está no %s.", FloorNames[ElevatorFloor]);
						}
						else
						{
							// Format chat text message
							format(strTempString, sizeof(strTempString), "* O elevador foi chamado... atualmente está no %s.", FloorNames[ElevatorFloor]);
						}
					}

					// Display formatted chat text message to the player
					SendClientMessage(playerid, YELLOW, strTempString);

					// Exit here (return 1 so this callback is processed in other scripts)
					return 1;
				}
			}
		}
	}

	// Exit here (return 1 so this callback is processed in other scripts)
	return 1;
}

// ------------------------ Functions ------------------------
Elevator_Initialize()
{
	// Create the elevator and elevator door objects
	Obj_Elevator 			= CreateObject(18755, X_ELEVATOR_POS, Y_ELEVATOR_POS, GROUND_Z_COORD + ELEVATOR_OFFSET, 0.000000, 0.000000, 0.000000);
	Obj_ElevatorDoors[0] 	= CreateObject(18757, X_ELEVATOR_POS, Y_ELEVATOR_POS, GROUND_Z_COORD + ELEVATOR_OFFSET, 0.000000, 0.000000, 0.000000);
	Obj_ElevatorDoors[1] 	= CreateObject(18756, X_ELEVATOR_POS, Y_ELEVATOR_POS, GROUND_Z_COORD + ELEVATOR_OFFSET, 0.000000, 0.000000, 0.000000);

	// Create the 3D text label for inside the elevator
	Label_Elevator = Create3DTextLabel("{CCCCCC}Pressione '{FFFFFF}~k~~CONVERSATION_YES~{CCCCCC}' para usar o elevador", 0xCCCCCCAA, X_ELEVATOR_POS - 1.7, Y_ELEVATOR_POS - 1.75, GROUND_Z_COORD - 0.4, 4.0, 0, 1);

	// Create variables
	new string[128], Float:z;

	// Loop
	for (new i; i < sizeof(Obj_FloorDoors); i ++)
	{
		// Create elevator floor door objects
		Obj_FloorDoors[i][0] 	= CreateObject(18757, X_ELEVATOR_POS - 0.245, Y_ELEVATOR_POS, GetDoorsZCoordForFloor(i), 0.000000, 0.000000, 0.000000);
		Obj_FloorDoors[i][1] 	= CreateObject(18756, X_ELEVATOR_POS - 0.245, Y_ELEVATOR_POS, GetDoorsZCoordForFloor(i), 0.000000, 0.000000, 0.000000);

		// Format string for the floor 3D text label
		format(string, sizeof(string), "{CCCCCC}[%s]\n{CCCCCC}Pressione '{FFFFFF}~k~~CONVERSATION_YES~{CCCCCC}' para chamar", FloorNames[i]);

		// Get label Z position
		z = GetDoorsZCoordForFloor(i);

		// Create floor label
		Label_Floors[i] = Create3DTextLabel(string, 0xCCCCCCAA, X_ELEVATOR_POS - 2.5, Y_ELEVATOR_POS - 2.5, z - 0.2, 10.5, 0, 1);
	}

	// Open the car park floor doors and the elevator doors
	Floor_OpenDoors(0);
	Elevator_OpenDoors();

	// Exit here
	return 1;
}

Elevator_OpenDoors()
{
	// Opens the elevator's doors.

	new Float:x, Float:y, Float:z;

	GetObjectPos(Obj_ElevatorDoors[0], x, y, z);
	MoveObject(Obj_ElevatorDoors[0], x, Y_DOOR_L_OPENED, z, DOORS_SPEED);
	MoveObject(Obj_ElevatorDoors[1], x, Y_DOOR_R_OPENED, z, DOORS_SPEED);

	return 1;
}

Elevator_CloseDoors()
{
	// Closes the elevator's doors.

	if(ElevatorState == ELEVATOR_STATE_MOVING)
		return 0;

	new Float:x, Float:y, Float:z;

	GetObjectPos(Obj_ElevatorDoors[0], x, y, z);
	MoveObject(Obj_ElevatorDoors[0], x, Y_DOOR_CLOSED, z, DOORS_SPEED);
	MoveObject(Obj_ElevatorDoors[1], x, Y_DOOR_CLOSED, z, DOORS_SPEED);

	return 1;
}

Floor_OpenDoors(floorid)
{
	// Opens the doors at the specified floor.

	MoveObject(Obj_FloorDoors[floorid][0], X_ELEVATOR_POS - 0.245, Y_DOOR_L_OPENED, GetDoorsZCoordForFloor(floorid), DOORS_SPEED);
	MoveObject(Obj_FloorDoors[floorid][1], X_ELEVATOR_POS - 0.245, Y_DOOR_R_OPENED, GetDoorsZCoordForFloor(floorid), DOORS_SPEED);

	return 1;
}

Floor_CloseDoors(floorid)
{
	// Closes the doors at the specified floor.

	MoveObject(Obj_FloorDoors[floorid][0], X_ELEVATOR_POS - 0.245, Y_ELEVATOR_POS, GetDoorsZCoordForFloor(floorid), DOORS_SPEED);
	MoveObject(Obj_FloorDoors[floorid][1], X_ELEVATOR_POS - 0.245, Y_ELEVATOR_POS, GetDoorsZCoordForFloor(floorid), DOORS_SPEED);

	return 1;
}

Elevator_MoveToFloor(floorid)
{
	// Moves the elevator to specified floor (doors are meant to be already closed).

	ElevatorState = ELEVATOR_STATE_MOVING;
	ElevatorFloor = floorid;

	// Move the elevator slowly, to give time to clients to sync the object surfing. Then, boost it up:
	MoveObject(Obj_Elevator, X_ELEVATOR_POS, Y_ELEVATOR_POS, GetElevatorZCoordForFloor(floorid), 0.25);
	MoveObject(Obj_ElevatorDoors[0], X_ELEVATOR_POS, Y_ELEVATOR_POS, GetDoorsZCoordForFloor(floorid), 0.25);
	MoveObject(Obj_ElevatorDoors[1], X_ELEVATOR_POS, Y_ELEVATOR_POS, GetDoorsZCoordForFloor(floorid), 0.25);
	Delete3DTextLabel(Label_Elevator);

	ElevatorBoostTimer = SetTimerEx("Elevator_Boost", 2000, 0, "i", floorid);

	return 1;
}

public Elevator_Boost(floorid)
{
	// Increases the elevator's speed until it reaches 'floorid'
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

RemoveFirstQueueFloor()
{
	// Removes the data in ElevatorQueue[0], and reorders the queue accordingly.

	for(new i; i < sizeof(ElevatorQueue) - 1; i ++)
		ElevatorQueue[i] = ElevatorQueue[i + 1];

	ElevatorQueue[sizeof(ElevatorQueue) - 1] = INVALID_FLOOR;

	return 1;
}

AddFloorToQueue(floorid)
{
	// Adds 'floorid' at the end of the queue.

	// Scan for the first empty space:
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

		// If needed, move the elevator.
		if(ElevatorState == ELEVATOR_STATE_IDLE)
			ReadNextFloorInQueue();

		return 1;
	}

	return 0;
}

ResetElevatorQueue()
{
	// Resets the queue.

	for(new i; i < sizeof(ElevatorQueue); i ++)
	{
		ElevatorQueue[i] 	= INVALID_FLOOR;
		FloorRequestedBy[i] = INVALID_PLAYER_ID;
	}

	return 1;
}

IsFloorInQueue(floorid)
{
	// Checks if the specified floor is currently part of the queue.

	for(new i; i < sizeof(ElevatorQueue); i ++)
		if(ElevatorQueue[i] == floorid)
			return 1;

	return 0;
}

ReadNextFloorInQueue()
{
	// Reads the next floor in the queue, closes doors, and goes to it.

	if(ElevatorState != ELEVATOR_STATE_IDLE || ElevatorQueue[0] == INVALID_FLOOR)
		return 0;

	Elevator_CloseDoors();
	Floor_CloseDoors(ElevatorFloor);

	return 1;
}

/*DidPlayerRequestElevator(playerid)
{
	for(new i; i < sizeof(FloorRequestedBy); i ++)
		if(FloorRequestedBy[i] == playerid)
			return 1;

	return 0;
} */

ShowElevatorDialog(playerid)
{
	new string[512];
	for(new i; i < sizeof(ElevatorQueue); i ++)
	{
		if(FloorRequestedBy[i] != INVALID_PLAYER_ID)
			strcat(string, "{FF0000}");

		strcat(string, FloorNames[i]);
		strcat(string, "\n");
	}

	ShowPlayerDialog(playerid, DIALOG_ID, DIALOG_STYLE_LIST, "Elevador", string, "Confirmar", "Cancelar");

	return 1;
}

/*Dialog:LsAptsElevatoR(playerid, response, listitem, inputtext[])
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
} */

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(dialogid == DIALOG_ID)
    {
        if(!response)
            return 0;

        if(FloorRequestedBy[listitem] != INVALID_PLAYER_ID || IsFloorInQueue(listitem))
            GameTextForPlayer(playerid, "~r~O andar ja esta na fila", 3500, 4);
		else if(DidPlayerRequestElevator(playerid))
		    GameTextForPlayer(playerid, "~r~Voce ja solicitou o elevador", 3500, 4);
		else
	        CallElevator(playerid, listitem);

		return 1;
    }

	return 0;
}

CallElevator(playerid, floorid)
{
	// Calls the elevator (also used with the elevator dialog).

	if(FloorRequestedBy[floorid] != INVALID_PLAYER_ID || IsFloorInQueue(floorid))
		return 0;

	FloorRequestedBy[floorid] = playerid;
	AddFloorToQueue(floorid);

	return 1;
}

Float:GetElevatorZCoordForFloor(floorid)
{
	// Return Z height value plus a small offset
	return (GROUND_Z_COORD + FloorZOffsets[floorid] + ELEVATOR_OFFSET);
}

Float:GetDoorsZCoordForFloor(floorid)
{
	// Return Z height value plus a small offset
	return (GROUND_Z_COORD + FloorZOffsets[floorid] + ELEVATOR_OFFSET);
}

stock DidPlayerRequestElevator(playerid)
{
	for(new i; i < sizeof(FloorRequestedBy); i ++)
	    if(FloorRequestedBy[i] == playerid)
	        return 1;

	return 0;
}

