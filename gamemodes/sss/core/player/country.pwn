/*==============================================================================


	Southclaw's Scavenge and Survive

		Copyright (C) 2016 Barnaby "Southclaw" Keene

		This program is free software: you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation, either version 3 of the License, or (at your
		option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
		See the GNU General Public License for more details.

		You should have received a copy of the GNU General Public License along
		with this program.  If not, see <http://www.gnu.org/licenses/>.


==============================================================================*/


#include <YSI\y_hooks>

hook OnPlayerConnect(playerid)
{
    new ip[16], string[59];
	GetPlayerIp(playerid, ip, sizeof ip);
	format(string, sizeof string, "www.shroomery.org/ythan/proxycheck.php?ip=%s", ip);
	HTTP(playerid, HTTP_GET, string, "", "MyHttpResponse");
}

forward MyHttpResponse(playerid, response_code, data[]);
public MyHttpResponse(playerid, response_code, data[])
{
	new ip[16];
	GetPlayerIp(playerid, ip, sizeof ip);

	if(strcmp(ip, "127.0.0.1", true) == 0)
		return 1;

	if(response_code == 200)
	{
		if(data[0] == 'Y')
		{
		    if(GetAdminsOnline() == 0)
				AntiCheaterKick(playerid, "Proxy/VPN ip alterado");

			else ChatMsgAdmins(1, YELLOW, "[Anti-Proxy/VPN] %P (id:%d) Provevelmente está usando proxy ou VPN, ip alterado!", playerid, playerid);

		if(data[0] == 'X')
			printf("WRONG IP FORMAT");

		else printf("The request failed! The response code was: %d", response_code);
	}
	return 1;
}

stock GetPlayerCountryDataAsString(playerid, output[], len = sizeof(output))
{
	if(!IsPlayerConnected(playerid))
		return 0;

    new
        country[90],
        city[90],
		isp[90];

    GetPlayerCountry(playerid, country, 90);
    GetPlayerCity(playerid, city, 90);
    GetPlayerISP(playerid, isp, 90);
    
	format(output, len, "\
		Pais: '%s'\n\
		Cidade: '%s'\n\
		ISP: '%s'",
		country,
		city,
		isp);

	return 1;
}

stock GetPlayerCachedHostname(playerid, output[], len = sizeof(output))
{
	if(!IsPlayerConnected(playerid))
		return 0;

    new ip[16];
    GetPlayerIp(playerid, ip, 16);
    
	output[0] = EOS;
	strcat(output, ip, len);

	return 1;
}

stock GetPlayerCachedCountryCode(playerid, output[], len = sizeof(output))
{
	if(!IsPlayerConnected(playerid))
		return 0;

	output[0] = EOS;
	strcat(output, "BR", len);

	return 1;
}

stock GetPlayerCachedCountryName(playerid, output[], len = sizeof(output))
{
	if(!IsPlayerConnected(playerid))
		return 0;

    new str[90];
    GetPlayerCountry(playerid, str, 90);

	output[0] = EOS;
	strcat(output, str, len);

	return 1;
}

stock GetPlayerCachedRegion(playerid, output[], len = sizeof(output))
{
	if(!IsPlayerConnected(playerid))
		return 0;

    new str[90];
    GetPlayerCity(playerid, str, 90);

	output[0] = EOS;
	strcat(output, str, len);

	return 1;
}

stock GetPlayerCachedISP(playerid, output[], len = sizeof(output))
{
	if(!IsPlayerConnected(playerid))
		return 0;

	new str[90];
    GetPlayerISP(playerid, str, 90);
    
	output[0] = EOS;
	strcat(output, str, len);

	return 1;
}

stock IsPlayerUsingProxy(playerid)
{
	if(!IsPlayerConnected(playerid))
		return 0;

	return false;
}
