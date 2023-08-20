#include <YSI\y_hooks>


static det_LineIds[MAX_DETFIELD][8];

hook OnGamemodeInit() {
    RegisterAdminCommand(LEVEL_MODERATOR, "rdpon/rdpoff", "Ver zonas onde possu� fields nas bases (cercado com uma corda em todas as pontas)");
}

hook OnFilterScriptInit()
{


	for(new i; i < MAX_DETFIELD; i++)
	{
		det_LineIds[i] = {
			INVALID_LINE_SEGMENT_ID,
			INVALID_LINE_SEGMENT_ID,
			INVALID_LINE_SEGMENT_ID,
			INVALID_LINE_SEGMENT_ID,
			INVALID_LINE_SEGMENT_ID,
			INVALID_LINE_SEGMENT_ID,
			INVALID_LINE_SEGMENT_ID,
			INVALID_LINE_SEGMENT_ID};
	}
}

//RedrawAllDetfieldPolys()
ACMD:rdpon[2](playerid)
{
	foreach(new i : det_Index)
	{
		DestroyDetfieldPoly(i);
		CreateDetfieldPoly(i);
	}

	return 1;
}

ACMD:rdpoff[2](playerid)
{
	foreach(new i : det_Index) DestroyDetfieldPoly(i);

	return 1;
}

stock CreateDetfieldPoly(detfieldid)
{
	if(!IsValidDetectionField(detfieldid))
		return 0;

	new
		Float:points[10],
		Float:minz,
		Float:maxz;

	GetDetectionFieldPoints(detfieldid, points);
	GetDetectionFieldMinZ(detfieldid, minz);
	GetDetectionFieldMaxZ(detfieldid, maxz);

	for(new i; i < 8; i += 2)
	{
		det_LineIds[detfieldid][i + 0] = CreateLineSegment(19087, 2.46,
			points[i + 0], points[i + 1], minz,
			points[i + 2], points[i + 3], minz,
			.RotX = 90.0, .objlengthoffset = -(2.46/2));

		det_LineIds[detfieldid][i + 1] = CreateLineSegment(19087, 2.46,
			points[i + 0], points[i + 1], maxz,
			points[i + 2], points[i + 3], maxz,
			.RotX = 90.0, .objlengthoffset = -(2.46/2));
	}

	return 1;
}

stock DestroyDetfieldPoly(detfieldid)
{
	if(!IsValidDetectionField(detfieldid))
		return 0;

	for(new i; i < 8; i++)
	{
		DestroyLineSegment(det_LineIds[detfieldid][i]);
		det_LineIds[detfieldid][i] = INVALID_LINE_SEGMENT_ID;
	}

	return 1;
}
