#define PI 3.14159265359

forward Float:GetDistancePointLine(Float:line_x,Float:line_y,Float:line_z,Float:vector_x,Float:vector_y,Float:vector_z,Float:point_x,Float:point_y,Float:point_z);
forward Float:Distance(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2);
forward Float:Distance2D(Float:x1, Float:y1, Float:x2, Float:y2);
forward Float:absoluteangle(Float:angle);

/*
	Distance between 2 points in 3D space
*/
stock Float:Distance(Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2)
	return floatsqroot((((x1-x2)*(x1-x2))+((y1-y2)*(y1-y2))+((z1-z2)*(z1-z2))));

/*
	Distance between 2 points in 2D space
*/
stock Float:Distance2D(Float:x1, Float:y1, Float:x2, Float:y2)
	return floatsqroot( ((x1-x2)*(x1-x2)) + ((y1-y2)*(y1-y2)) );

/*
	Distance from any point on a projected line to a point
*/
stock Float:GetDistancePointLine(Float:line_x,Float:line_y,Float:line_z,Float:vector_x,Float:vector_y,Float:vector_z,Float:point_x,Float:point_y,Float:point_z)
	return floatsqroot(floatpower((vector_y) * ((point_z) - (line_z)) - (vector_z) * ((point_y) - (line_y)), 2.0)+floatpower((vector_z) * ((point_x) - (line_x)) - (vector_x) * ((point_z) - (line_z)), 2.0)+floatpower((vector_x) * ((point_y) - (line_y)) - (vector_y) * ((point_x) - (line_x)), 2.0))/floatsqroot((vector_x) * (vector_x) + (vector_y) * (vector_y) + (vector_z) * (vector_z));

/*
	Angle from point to dest
*/
stock Float:GetAngleToPoint(Float:fPointX, Float:fPointY, Float:fDestX, Float:fDestY)
	return absoluteangle(-(90-(atan2((fDestY - fPointY), (fDestX - fPointX)))));

/*
	2D Projection position based on distance and angle
*/
stock GetXYFromAngle(&Float:x, &Float:y, Float:a, Float:distance)
	x+=(distance*floatsin(-a,degrees)),y+=(distance*floatcos(-a,degrees));

/*
	3D Projection position based on distance and angles
*/
stock GetXYZFromAngle(&Float:x, &Float:y, &Float:z, Float:angle, Float:elevation, Float:distance)
    x += ( distance*floatsin(angle,degrees)*floatcos(elevation,degrees) ),y += ( distance*floatcos(angle,degrees)*floatcos(elevation,degrees) ),z += ( distance*floatsin(elevation,degrees) );

/*
	Convert 3D velocity vectors to a single velocity unit (close to Km/h in SA:MP)
*/
stock Float:CalculateVelocity(Float:X, Float:Y, Float:Z)
	return (floatsqroot((X*X)+(Y*Y)+(Z*Z))*150.0);

/*
	Return a floating point random number
*/
stock Float:frandom(Float:max, Float:min = 0.0, dp = 4)
{
    new
        Float:mul = floatpower(10.0, dp),
        imin = floatround(min * mul),
        imax = floatround(max * mul);
    return float(random(imax - imin) + imin) / mul;
}

/*
	Checks if one angle is within another angle
*/
stock AngleInRangeOfAngle(Float:a1, Float:a2, Float:range)
{

	a1 -= a2;
	if((a1 < range) && (a1 > -range)) return true;

	return false;

}


/*
	Returns the absolute value of an integer
*/
stock abs(int)
{
	if(int < 0)
		return -int;

	return int;
}


/*
	Returns the absolute value of an angle
*/
stock Float:absoluteangle(Float:angle)
{
	while(angle < 0.0)angle += 360.0;
	while(angle > 360.0)angle -= 360.0;
	return angle;
}


/*
	Picks <sizeof(output)> numbers from a list ranging from 0 to <max>
*/
stock PickFromList(max, count, output[])
{
	new
		idx,
		picked[256];

	if(max > 256)
		err("PickFromList function variable 'picked' is too small to match parameter 'max'.");

	while(idx < count)
	{
		output[idx] = random(max);

		if(picked[output[idx]] == 0)
		{
			picked[output[idx]] = 1;
			idx++;
		}
	}
}


/*
	Separates the digits from a decimal value and saves them to an array
	Credits - RyDeR` (http://forum.sa-mp.com/showpost.php?s=df579e9e90d575ae4911cda03598929f&p=1277125&postcount=2168)
*/
stock GetDigits(const value, strDig[])
{
	valstr(strDig, value, true);
	
	for(new i; strDig{i} != EOS; i++)
		strDig{i} -= '0';
}


/*
	Checks if a variable is not a number
	Credits - Y_Less (http://forum.sa-mp.com/showthread.php?t=57018)
*/
stock IsNaN(Float:number)
{
    return !(number <= 0 || number > 0);
}

stock Float:random_float(Float:min, Float:max) {
    return min + (random(10001) / 10000.0) * (max - min);
}

// * Nao tem bem a ver com matematica mas que se foda
Float:fclamp(Float:value, Float:minValue, Float:maxValue) {
    if (value < minValue) return minValue;
    if (value > maxValue) return maxValue;
    return value;
}
