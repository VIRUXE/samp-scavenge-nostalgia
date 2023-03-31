#include <YSI\y_hooks>
#include <YSI\y_timers>

#define OTP_LENGTH 6

enum E_OTP {
    otp_response_tick = 0,
    otp_code[OTP_LENGTH + 1]
};

static 
    bool:otp_mode = true,
    otp[MAX_PLAYERS][E_OTP];

timer InvalidateOTPCode[MIN(1)](playerid) {
    if(!IsPlayerConnected(playerid)) return;
    if(!otp_mode) return;
    if(isnull(otp[playerid][otp_code])) return;

    printf("[OTP] Chave unica para o jogador '%p' (%d) expirou.", playerid, playerid);    

    GenerateOTP(playerid);
    ShowOTPPrompt(playerid);
}

hook OnGameModeInit() {
    // Load Setting
    new Node:node, bool:setting;


    JSON_GetObject(Settings, "server", node);
    JSON_GetObject(node, "otp", node);
    JSON_GetBool(node, "enabled", setting);

    if(setting) {
        otp_mode = true;
        printf("[OTP] Modo de chave unica ativado");
    }

    return 1;
}

/* hook OnPlayerConnect(playerid) {
    if(otp_mode) {
        GenerateOTP(playerid);
        ShowOTPPrompt(playerid);

        return Y_HOOKS_BREAK_RETURN_1;
    }

    return Y_HOOKS_CONTINUE_RETURN_1;
} */

hook OnPlayerDisconnect(playerid, reason) {
    if(otp_mode) {
        // Remove the code from memory
        otp[playerid][otp_code][0] = EOS;
    }

    return 1;
}

hook OnRconCommand(command[]) {
    if(isequal(command, "otp")) {
        ToggleOTPMode(!otp_mode);
    }

    return 1;
}

stock bool:IsOTPModeEnabled() {
    return otp_mode;
}

stock ToggleOTPMode(bool:toggle) {
    if(toggle == otp_mode) return;

    otp_mode = !otp_mode;

    printf("[OTP] Modo de chave unica %s", otp_mode ? "ativado" : "desativado");
}

stock GenerateOTP(playerid) {
    for (new i = 0; i < OTP_LENGTH; ++i) {
        otp[playerid][otp_code][i] = random(10) + '0';
    }
    otp[playerid][otp_code][OTP_LENGTH] = EOS;

    defer InvalidateOTPCode(playerid);

    printf("[OTP] Chave unica gerada para o jogador '%p' (%d): %s", playerid, playerid, otp[playerid][otp_code]);
}

stock bool:IsPlayerWaitingOTP(playerid) {
    return !isnull(otp[playerid][otp_code]);
}

Dialog:OTPPrompt(playerid, response, listitem, inputtext[]) {
    if(IsPlayerAdmin(playerid)) return;

    new elapsed_time = GetTickCountDifference(GetTickCount(), otp[playerid][otp_response_tick]);

    // Evitar bruteforce/spam
    if(elapsed_time < SEC(1)) {
        otp[playerid][otp_response_tick] = GetTickCount();
        ShowOTPPrompt(playerid);

        return;
    }

    otp[playerid][otp_response_tick] = GetTickCount();

    if(response) {
        if(isequal(inputtext, otp[playerid][otp_code])) {
            printf("[OTP] Chave unica para o jogador '%p' (%d) validada com sucesso.", playerid, playerid);

            // Remove the code from memory
            otp[playerid][otp_code][0] = EOS;

            SetPlayerScreenFade(playerid, 0);
            _OnPlayerConnect(playerid);
        } else {
            printf("[OTP] Chave unica para o jogador '%p' (%d) invalida.", playerid, playerid);
            ShowOTPPrompt(playerid);
        }
    } else
        Kick(playerid);
}

stock ShowOTPPrompt(playerid) {
    if(!IsPlayerConnected(playerid)) return;

    Dialog_Show(playerid, OTPPrompt, DIALOG_STYLE_INPUT, "Chave Unica", "Peça a chave unica para o administrador do servidor e digite-a abaixo (tem 1 minuto):", "OK", "Cancelar");
}