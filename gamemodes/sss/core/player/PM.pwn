#include <YSI\y_hooks>

new bool:PmBlock[MAX_PLAYERS];

hook OnPlayerConnect(playerid)
{
	PmBlock[playerid] = false;
}

CMD:pm(playerid, params[])
{
	if(!IsPlayerSpawned(playerid)) return 1;
	new
		giveplayerid = -1,
		menssagem[300],
		string[300],
		playername[24],
		giveplayername[24];
	
    if(sscanf(params, "ds[300]", giveplayerid, menssagem)) return SendClientMessage(playerid, RED, "[PM]: Use /pm [id] [mensagem]");

    GetPlayerName(playerid, playername, sizeof(playername));
    GetPlayerName(giveplayerid, giveplayername, sizeof(giveplayername));


    if(IsPlayerConnected(giveplayerid))
	{
	    GetPlayerName(playerid, playername, sizeof(playername));
	    GetPlayerName(giveplayerid, giveplayername, sizeof(giveplayername));
        if(PmBlock[playerid])
		{
            format(string,sizeof(string),"[PM]: Você não pode enviar uma menssagem pois usou /blockpm!");
            SendClientMessage(playerid, RED, string);
            return 1;
        }
        if(PmBlock[giveplayerid])
		{
            format(string,sizeof(string),"[PM]: Você não pode enviar uma menssagem para %s pois ele está com o PM Bloqueado!", giveplayername);
            SendClientMessage(playerid, RED, string);
            return 1;
        }
        if(!strlen(menssagem))
		{
            SendClientMessage(playerid, RED, "[PM]: Uso Correto: /pm [id do player] [menssagem]");
            return 1;
        }
        format(string,sizeof(string),"[PM PARA %s(id:%d)]: {00AA00}%s", giveplayername, giveplayerid, menssagem);
        SendClientMessage(playerid, RED, string);
        
        format(string,sizeof(string),"[PM DE %s(id:%d)]: {00AA00}%s", playername, playerid, menssagem);
        SendClientMessage(giveplayerid,0x555555AA,string);
        
        GameTextForPlayer(giveplayerid, "~G~~H~ MENSAGEM RECEBIDA!", 3000, 1);
        
        PlayerPlaySound(giveplayerid,5205,0.0,0.0,0.0);
    	PlayerPlaySound(playerid,5205,0.0,0.0,0.0);

    }
    else
	{
        format(string, sizeof(string), "[PM]: O ID %d não está online.", giveplayerid);
        SendClientMessage(playerid, RED, string);
    }
    return 1;
}
	
CMD:blockpm(playerid)
{
    if(!PmBlock[playerid])
	{
        SendClientMessage(playerid, 0xFF80808B, "[PM]: Mensagens bloqueadas!");
        PmBlock[playerid] = true;
    }
    else
	{
        SendClientMessage(playerid, 0xFF80808B, "[PM]: Mensagens desbloqueadas!");
        PmBlock[playerid] = false;
        return 1;
    }
    return 1;
}
