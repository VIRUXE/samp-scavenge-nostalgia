stock isalphabetic(chr) return 'a' <= chr <= 'z' || 'A' <= chr <= 'Z' ? 1 : 0;

stock isalphanumeric(chr) return 'a' <= chr <= 'z' || 'A' <= chr <= 'Z' || '0' <= chr <= '9' ? 1 : 0;

isstringalphanumeric(str[]) { // * Que nome de merda
	for (new i = 0; i < strlen(str); i++)
		if (!isalphanumeric(str[i]))
			return 0;

	return 1;
}

FormatSpecifier<'T'>(output[], timestamp)
{
	strcat(output, TimestampToDateTime(timestamp, "%A %b %d %Y at %X"));
}

FormatSpecifier<'M'>(output[], millisecond)
{
	strcat(output, MsToString(millisecond, "%h:%m:%s.%d"));
}

stock atos(a[], size, s[], len = sizeof(s)) // array to string
{
	s[0] = '[';

	for(new i; i < size; i++)
	{
		if(i != 0) strcat(s, ", ", len);

		format(s, len, "%s%d", s, a[i]);
	}

	s[strlen(s)] = ']';
}

stock atosr(a[], size = sizeof(a)) // array to string (return)
{
	new s[256];
	atos(a, size, s);
	
	return s;
}

strsplit(const str[], const delim[], strSplit[][32], &count) {
	new i, j, k, len, delimLen, found;

	len = strlen(str);
	delimLen = strlen(delim);

	count = 0;

	for(i = 0; i < len; i++) {
		found = 0;

		for(j = 0; j < delimLen; j++) {
			if(str[i] == delim[j]) {
				found = 1;
				break;
			}
		}

		if(found) {
			strSplit[count][k] = '\0';
			count++;
			k = 0;
		} else {
			strSplit[count][k] = str[i];
			k++;
		}
	}

	strSplit[count][k] = '\0';
	count++;
}

booltostr(bool:b) { // * Gambiarra do crl
	new result[] = "false";

	if(b) result = "true";

	return result;
}