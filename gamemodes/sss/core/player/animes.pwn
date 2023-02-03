
CMD:animes(playerid)
{
	ChatMsg(playerid,RED,"Lista de animações -");
    ChatMsg(playerid,YELLOW," /handsup, /dance[1-4], /rap, /rap2, /rap3, /wankoff, /wank, /strip[1-7], /sexy[1-8], /bj[1-4], /cellin, /cellout, /lean, /piss, /follow");
    ChatMsg(playerid,YELLOW," /greet, /injured, /injured2, /hitch, /bitchslap, /cpr, /gsign1, /gsign2, /gsign3, /gsign4, /gsign5, /gift, /getup");
    ChatMsg(playerid,YELLOW," /chairsit, /stand, /slapped, /slapass, /drunk, /gwalk, /gwalk2, /mwalk, /fwalk, /celebrate, /celebrate2, /win, /win2");
    ChatMsg(playerid,YELLOW," /yes, /deal, /deal2, /thankyou, /invite1, /invite2, /sit, /scratch, /bomb, /getarrested, /laugh, /lookout, /robman");
    ChatMsg(playerid,YELLOW," /crossarms, /crossarms2, /crossarms3, /lay, /cover, /vomit, /eat, /wave, /crack, /crack2, /smokem, /smokef, /msit, /fsit");
    ChatMsg(playerid,YELLOW," /chat, /fucku, /taichi, /relax, /bat1, /bat2, /bat3, /bat4, /bat5, /nod, /cry1, /cry2, /chant, /carsmoke, /aim");
    ChatMsg(playerid,YELLOW," /gang1, /gang2, /gang3, /gang4, /gang5, /gang6, /gang7, /bed1, /bed2, /bed3, /bed4, /carsit, /carsit2, /stretch, /angry");
    ChatMsg(playerid,YELLOW," /kiss1, /kiss2, /kiss3, /kiss4, /kiss5, /kiss6, /kiss7, /kiss8, /exhausted, /ghand1, /ghand2, /ghand3, /ghand4, /ghand5");
    ChatMsg(playerid,YELLOW," /basket1, /basket2, /basket3, /basket4, /basket5, /basket6, /akick, /box, /cockgun");
    ChatMsg(playerid,YELLOW," /bar1, /bar2, /bar3, /bar4, /lay2, /liftup, /putdown, /die, /joint, /die2, /aim2, /benddown, /checkout");
    return 1;
}

AplicarAnime(playerid, animlib[], animname[], Float:fDelta, loop, lockx, locky, freeze, time, forcesync = 0){
	if(!IsPlayerSpawned(playerid))
	    return 1;
	    
    if(IsPlayerInAnyVehicle(playerid))
	    return 1;
	    
	if(IsPlayerKnockedOut(playerid))
	    return 1;
	    
    ApplyAnimation(playerid, animlib, animname, Float:fDelta, loop, lockx, locky, freeze, time, forcesync);
    
//    ShowActionText(playerid, "~>~ ~w~Use ~r~/stop~w~ para parar.");
    ChatMsg(playerid, RED, " ");
    ChatMsg(playerid, RED, " > Use /stop para parar a animação.");
    ChatMsg(playerid, RED, " ");
	return 1;
}
CMD:handsup(playerid)
{
	SetPlayerSpecialAction(playerid,SPECIAL_ACTION_HANDSUP);
    return 1;
}

CMD:stop(playerid)
{
	if(GetPlayerTotalVelocity(playerid) > 0.0){
	    SendClientMessage(playerid, RED, " > Você deve estar parado para usar este comando.");
	    return 1;
	}
	
    ClearAnimations(playerid);
    ShowActionText(playerid, "Animaçšo resetada.");
    ApplyAnimation(playerid, "CARRY", "crry_prtial", 2.0, 0, 0, 0, 0, 0);
    return 1;
}

CMD:dance(playerid)
{
    SetPlayerSpecialAction(playerid,SPECIAL_ACTION_DANCE1);
    return 1;
}

CMD:dance2(playerid)
{
    SetPlayerSpecialAction(playerid,SPECIAL_ACTION_DANCE2);
    return 1;
}

CMD:dance3(playerid)
{
    SetPlayerSpecialAction(playerid,SPECIAL_ACTION_DANCE3);
    return 1;
}

CMD:dance4(playerid)
{
    SetPlayerSpecialAction(playerid,SPECIAL_ACTION_DANCE4);
    return 1;
}
CMD:rap(playerid)
{
    AplicarAnime(playerid,"RAPPING","RAP_A_Loop",4.0,1,1,1,1,0);
    return 1;
}

CMD:rap2(playerid)
{
    AplicarAnime(playerid,"RAPPING","RAP_B_Loop",4.0,1,1,1,1,0);
    return 1;
}

CMD:rap3(playerid)
{
    AplicarAnime(playerid,"RAPPING","RAP_C_Loop",4.0,1,1,1,1,0);
    return 1;
}

CMD:wankoff(playerid)
{
    AplicarAnime(playerid,"PAULNMAC","wank_in",4.0,1,1,1,1,0);
    return 1;
}

CMD:wank(playerid)
{
    AplicarAnime(playerid,"PAULNMAC","wank_loop",4.0,1,1,1,1,0);
    return 1;
}

CMD:strip(playerid)
{
    AplicarAnime(playerid,"STRIP","strip_A",4.0,1,1,1,1,0);
    return 1;
}

CMD:strip2(playerid)
{
    AplicarAnime(playerid,"STRIP","strip_B",4.0,1,1,1,1,0);
    return 1;
}

CMD:strip3(playerid)
{
    AplicarAnime(playerid,"STRIP","strip_C",4.0,1,1,1,1,0);
    return 1;
}

CMD:strip4(playerid)
{
    AplicarAnime(playerid,"STRIP","strip_D",4.0,1,1,1,1,0);
    return 1;
}

CMD:strip5(playerid)
{
    AplicarAnime(playerid,"STRIP","strip_E",4.0,1,1,1,1,0);
    return 1;
}

CMD:strip6(playerid)
{
    AplicarAnime(playerid,"STRIP","strip_F",4.0,1,1,1,1,0);
    return 1;
}

CMD:strip7(playerid)
{
    AplicarAnime(playerid,"STRIP","strip_G",4.0,1,1,1,1,0);
    return 1;
}

CMD:sexy(playerid)
{
    AplicarAnime(playerid,"SNM","SPANKING_IDLEW",4.1,0,1,1,1,1);
    return 1;
}

CMD:sexy2(playerid)
{
    AplicarAnime(playerid,"SNM","SPANKING_IDLEP",4.1,0,1,1,1,1);
    return 1;
}

CMD:sexy3(playerid)
{
    AplicarAnime(playerid,"SNM","SPANKINGW",4.1,0,1,1,1,1);
    return 1;
}

CMD:sexy4(playerid)
{
    AplicarAnime(playerid,"SNM","SPANKINGP",4.1,0,1,1,1,1);
    return 1;
}

CMD:sexy5(playerid)
{
    AplicarAnime(playerid,"SNM","SPANKEDW",4.1,0,1,1,1,1);
    return 1;
}

CMD:sexy6(playerid)
{
    AplicarAnime(playerid,"SNM","SPANKEDP",4.1,0,1,1,1,1);
    return 1;
}

CMD:sexy7(playerid)
{
    AplicarAnime(playerid,"SNM","SPANKING_ENDW",4.1,0,1,1,1,1);
    return 1;
}

CMD:sexy8(playerid)
{
    AplicarAnime(playerid,"SNM","SPANKING_ENDP",4.1,0,1,1,1,1);
    return 1;
}

CMD:bj(playerid)
{
    AplicarAnime(playerid,"BLOWJOBZ","BJ_COUCH_START_P",4.1,0,1,1,1,1);
    return 1;
}

CMD:bj2(playerid)
{
    AplicarAnime(playerid,"BLOWJOBZ","BJ_COUCH_START_W",4.1,0,1,1,1,1);
    return 1;
}

CMD:bj3(playerid)
{
    AplicarAnime(playerid,"BLOWJOBZ","BJ_COUCH_LOOP_P",4.1,0,1,1,1,1);
    return 1;
}

CMD:bj4(playerid)
{
    AplicarAnime(playerid,"BLOWJOBZ","BJ_COUCH_LOOP_W",4.1,0,1,1,1,1);
    return 1;
}

CMD:cellin(playerid)
{
    SetPlayerSpecialAction(playerid,SPECIAL_ACTION_USECELLPHONE);
    return 1;
}

CMD:cellout(playerid)
{
    SetPlayerSpecialAction(playerid,SPECIAL_ACTION_STOPUSECELLPHONE);
    return 1;
}

CMD:lean(playerid)
{
    AplicarAnime(playerid,"GANGS","leanIDLE", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:piss(playerid)
{
    SetPlayerSpecialAction(playerid, 68);
    return 1;
}

CMD:follow(playerid)
{
    AplicarAnime(playerid,"WUZI","Wuzi_follow",4.0,0,0,0,0,0);
    return 1;
}

CMD:greet(playerid)
{
    AplicarAnime(playerid,"WUZI","Wuzi_Greet_Wuzi",4.0,0,0,0,0,0);
    return 1;
}

CMD:stand(playerid)
{
    AplicarAnime(playerid,"WUZI","Wuzi_stand_loop", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:injured2(playerid)
{
    AplicarAnime(playerid,"SWAT","gnstwall_injurd", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:hitch(playerid)
{
    AplicarAnime(playerid,"MISC","Hiker_Pose", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:bitchslap(playerid)
{
    AplicarAnime(playerid,"MISC","bitchslap",4.0,0,0,0,0,0);
    return 1;
}

CMD:cpr(playerid)
{
    AplicarAnime(playerid,"MEDIC","CPR", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:gsign1(playerid)
{
    AplicarAnime(playerid,"GHANDS","gsign1",4.0,0,1,1,1,1);
    return 1;
}

CMD:gsign2(playerid)
{
    AplicarAnime(playerid,"GHANDS","gsign2",4.0,0,1,1,1,1);
    return 1;
}

CMD:gsign3(playerid)
{
    AplicarAnime(playerid,"GHANDS","gsign3",4.0,0,1,1,1,1);
    return 1;
}

CMD:gsign4(playerid)
{
    AplicarAnime(playerid,"GHANDS","gsign4",4.0,0,1,1,1,1);
    return 1;
}

CMD:gsign5(playerid)
{
    AplicarAnime(playerid,"GHANDS","gsign5",4.0,0,1,1,1,1);
    return 1;
}

CMD:gift(playerid)
{
    AplicarAnime(playerid,"KISSING","gift_give",4.0,0,0,0,0,0);
    return 1;
}

CMD:chairsit(playerid)
{
    AplicarAnime(playerid,"PED","SEAT_idle", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:injured(playerid) {

    AplicarAnime(playerid,"SWEET","Sweet_injuredloop", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:slapped(playerid)
{
    AplicarAnime(playerid,"SWEET","ho_ass_slapped",4.0,0,0,0,0,0);
    return 1;
}

CMD:slapass(playerid)
{
    AplicarAnime(playerid,"SWEET","sweet_ass_slap",4.0,0,0,0,0,0);
    return 1;
}

CMD:drunk(playerid)
{
    AplicarAnime(playerid,"PED","WALK_DRUNK",4.1,1,1,1,1,1);
    return 1;
}

CMD:skate(playerid)
{
    AplicarAnime(playerid,"SKATE","skate_run",4.1,1,1,1,1,1);
    return 1;
}

CMD:gwalk(playerid) {
    AplicarAnime(playerid,"PED","WALK_gang1",4.1,1,1,1,1,1);
    return 1;
}

CMD:gwalk2(playerid)
{
    AplicarAnime(playerid,"PED","WALK_gang2",4.1,1,1,1,1,1);
    return 1;
}

CMD:limp(playerid)
{
    AplicarAnime(playerid,"PED","WALK_old",4.1,1,1,1,1,1);
    return 1;
}

CMD:eatsit(playerid)
{
    AplicarAnime(playerid,"FOOD","FF_Sit_Loop", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:celebrate(playerid)
{
    AplicarAnime(playerid,"benchpress","gym_bp_celebrate", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:win(playerid)
{
    AplicarAnime(playerid,"CASINO","cards_win", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:win2(playerid)
{
    AplicarAnime(playerid,"CASINO","Roulette_win", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:yes(playerid)
{
    AplicarAnime(playerid,"CLOTHES","CLO_Buy", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:deal2(playerid)
{
    AplicarAnime(playerid,"DEALER","DRUGS_BUY", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:thankyou(playerid)
{
    AplicarAnime(playerid,"FOOD","SHP_Thank", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:invite1(playerid)
{
    AplicarAnime(playerid,"GANGS","Invite_Yes",4.1,0,1,1,1,1);
    return 1;
}

CMD:invite2(playerid)
{
    AplicarAnime(playerid,"GANGS","Invite_No",4.1,0,1,1,1,1);
    return 1;
}

CMD:celebrate2(playerid)
{
    AplicarAnime(playerid,"GYMNASIUM","gym_tread_celebrate", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:sit(playerid)
{
    AplicarAnime(playerid,"INT_OFFICE","OFF_Sit_Type_Loop", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:scratch(playerid)
{
    AplicarAnime(playerid,"MISC","Scratchballs_01", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:bomb(playerid)
{
    ClearAnimations(playerid);
    AplicarAnime(playerid, "BOMBER", "BOM_Plant", 4.0, 0, 0, 0, 0, 0); // Place Bomb
    return 1;
}

CMD:getarrested(playerid)
{
    AplicarAnime(playerid,"ped", "ARRESTgun", 4.0, 0, 1, 1, 1, -1); // Gun Arrest
    return 1;
}

CMD:laugh(playerid)
{
    AplicarAnime(playerid, "RAPPING", "Laugh_01", 4.0, 0, 0, 0, 0, 0); // Laugh
    return 1;
}

CMD:lookout(playerid)
{
    AplicarAnime(playerid, "SHOP", "ROB_Shifty", 4.0, 0, 0, 0, 0, 0); // Rob Lookout
    return 1;
}

CMD:robman(playerid)
{
    AplicarAnime(playerid, "SHOP", "ROB_Loop_Threat", 4.0, 1, 0, 0, 0, 0); // Rob
    return 1;
}

CMD:crossarms(playerid)
{
    AplicarAnime(playerid, "COP_AMBIENT", "Coplook_loop", 4.0, 0, 1, 1, 1, -1); // Arms crossed
    return 1;
}

CMD:crossarms2(playerid)
{
    AplicarAnime(playerid, "DEALER", "DEALER_IDLE", 4.0, 0, 1, 1, 1, -1); // Arms crossed 2
    return 1;
}

CMD:crossarms3(playerid)
{
    AplicarAnime(playerid, "DEALER", "DEALER_IDLE_01", 4.0, 0, 1, 1, 1, -1); // Arms crossed 3
    return 1;
}

CMD:lay(playerid)
{
    AplicarAnime(playerid,"BEACH", "bather", 4.0, 1, 0, 0, 0, 0); // Lay down
    return 1;
}

CMD:vomit(playerid)
{
    AplicarAnime(playerid, "FOOD", "EAT_Vomit_P", 3.0, 0, 0, 0, 0, 0); // Vomit
    return 1;
}

CMD:eat(playerid){
    AplicarAnime(playerid, "FOOD", "EAT_Burger", 3.0, 0, 0, 0, 0, 0); // Eat Burger
    return 1;
}

CMD:wave(playerid){
    AplicarAnime(playerid, "ON_LOOKERS", "wave_loop", 4.0, 1, 0, 0, 0, 0); // Wave
    return 1;
}

CMD:deal(playerid){
    AplicarAnime(playerid, "DEALER", "DEALER_DEAL", 3.0, 0, 0, 0, 0, 0); // Deal Drugs
    return 1;
}

CMD:crack(playerid) {
    AplicarAnime(playerid, "CRACK", "crckdeth2", 4.0, 1, 0, 0, 0, 0); // Dieing of Crack
    return 1;
}

CMD:smokem(playerid){
    AplicarAnime(playerid,"SMOKING", "M_smklean_loop", 4.0, 1, 0, 0, 0, 0); // Smoke
    return 1;
}

CMD:smokef(playerid){
    AplicarAnime(playerid, "SMOKING", "F_smklean_loop", 4.0, 1, 0, 0, 0, 0); // Female Smoking
    return 1;
}

CMD:msit(playerid){
    AplicarAnime(playerid,"BEACH", "ParkSit_M_loop", 4.0, 1, 0, 0, 0, 0); // Male Sit
    return 1;
}

CMD:fsit(playerid){
    AplicarAnime(playerid,"BEACH", "ParkSit_W_loop", 4.0, 1, 0, 0, 0, 0); // Female Sit
    return 1;
}

CMD:chat(playerid) {
    AplicarAnime(playerid,"PED","IDLE_CHAT",4.1,1,1,1,1,1);
    return 1;
}

CMD:fucku(playerid)
{
    AplicarAnime(playerid,"PED","fucku",4.0,0,0,0,0,0);
    return 1;
}

CMD:taichi(playerid)
{
    AplicarAnime(playerid,"PARK","Tai_Chi_Loop", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:relax(playerid)
{
    AplicarAnime(playerid,"BEACH","Lay_Bac_Loop", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:bat1(playerid)
{
    AplicarAnime(playerid,"BASEBALL","Bat_IDLE", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:bat2(playerid)
{
    AplicarAnime(playerid,"BASEBALL","Bat_M", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:bat3(playerid)
{
    AplicarAnime(playerid,"BASEBALL","BAT_PART", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:bat4(playerid)
{
    AplicarAnime(playerid,"CRACK","Bbalbat_Idle_01", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:bat5(playerid)
{
    AplicarAnime(playerid,"CRACK","Bbalbat_Idle_02", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:nod(playerid)
{
    AplicarAnime(playerid,"COP_AMBIENT","Coplook_nod",4.0,0,0,0,0,0);
    return 1;
}

CMD:gang1(playerid)
{
    AplicarAnime(playerid,"GANGS","hndshkaa",4.0,0,0,0,0,0);
    return 1;
}

CMD:gang2(playerid)
{
    AplicarAnime(playerid,"GANGS","hndshkba",4.0,0,0,0,0,0);
    return 1;
}

CMD:gang3(playerid)
{
    AplicarAnime(playerid,"GANGS","hndshkca",4.0,0,0,0,0,0);
    return 1;
}

CMD:gang4(playerid)
{
    AplicarAnime(playerid,"GANGS","hndshkcb",4.0,0,0,0,0,0);
    return 1;
}

CMD:gang5(playerid)
{
    AplicarAnime(playerid,"GANGS","hndshkda",4.0,0,0,0,0,0);
    return 1;
}

CMD:gang6(playerid)
{
    AplicarAnime(playerid,"GANGS","hndshkea",4.0,0,0,0,0,0);
    return 1;
}

CMD:gang7(playerid)
{
    AplicarAnime(playerid,"GANGS","hndshkfa",4.0,0,0,0,0,0);
    return 1;
}

CMD:cry1(playerid)
{
    AplicarAnime(playerid,"GRAVEYARD","mrnF_loop", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:cry2(playerid)
{
    AplicarAnime(playerid,"GRAVEYARD","mrnM_loop", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:bed1(playerid)
{
    AplicarAnime(playerid,"INT_HOUSE","BED_In_L",4.1,0,1,1,1,1);
    return 1;
}

CMD:bed2(playerid)
{
    AplicarAnime(playerid,"INT_HOUSE","BED_In_R",4.1,0,1,1,1,1);
    return 1;
}

CMD:bed3(playerid)
{
    AplicarAnime(playerid,"INT_HOUSE","BED_Loop_L", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:bed4(playerid)
{
    AplicarAnime(playerid,"INT_HOUSE","BED_Loop_R", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:kiss2(playerid)
{
    AplicarAnime(playerid,"BD_FIRE","Grlfrd_Kiss_03",4.0,0,0,0,0,0);
    return 1;
}

CMD:kiss3(playerid)
{

    AplicarAnime(playerid,"KISSING","Grlfrd_Kiss_01",4.0,0,0,0,0,0);
    return 1;
}

CMD:kiss4(playerid)
{
    AplicarAnime(playerid,"KISSING","Grlfrd_Kiss_02",4.0,0,0,0,0,0);
    return 1;
}

CMD:kiss5(playerid)
{
    AplicarAnime(playerid,"KISSING","Grlfrd_Kiss_03",4.0,0,0,0,0,0);
    return 1;
}

CMD:kiss6(playerid)
{
    AplicarAnime(playerid,"KISSING","Playa_Kiss_01",4.0,0,0,0,0,0);
    return 1;
}

CMD:kiss7(playerid)
{
    AplicarAnime(playerid,"KISSING","Playa_Kiss_02",4.0,0,0,0,0,0);
    return 1;
}

CMD:kiss8(playerid)
{
    AplicarAnime(playerid,"KISSING","Playa_Kiss_03",4.0,0,0,0,0,0);
    return 1;
}

CMD:carsit(playerid)
{
    AplicarAnime(playerid,"CAR","Tap_hand", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:carsit2(playerid)
{
    AplicarAnime(playerid,"LOWRIDER","Sit_relaxed", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:fwalk(playerid)
{
    AplicarAnime(playerid,"ped","WOMAN_walksexy",4.1,1,1,1,1,1);
    return 1;
}

CMD:mwalk(playerid)
{
    AplicarAnime(playerid,"ped","WALK_player",4.1,1,1,1,1,1);
    return 1;
}

CMD:stretch(playerid)
{
    AplicarAnime(playerid,"PLAYIDLES","stretch",4.0,0,0,0,0,0);
    return 1;
}

CMD:chant(playerid)
{
    AplicarAnime(playerid,"RIOT","RIOT_CHANT", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:angry(playerid)
{
    AplicarAnime(playerid,"RIOT","RIOT_ANGRY",4.0,0,0,0,0,0);
    return 1;
}

CMD:crack2(playerid)
{
    AplicarAnime(playerid, "CRACK", "crckidle2", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:ghand1(playerid)
{
    AplicarAnime(playerid,"GHANDS","gsign1LH",4.0,0,1,1,1,1);
    return 1;
}

CMD:ghand2(playerid)
{
    AplicarAnime(playerid,"GHANDS","gsign2LH",4.0,0,1,1,1,1);
    return 1;
}
CMD:ghand3(playerid)
{
    AplicarAnime(playerid,"GHANDS","gsign3LH",4.0,0,1,1,1,1);
    return 1;
}

CMD:ghand4(playerid)
{
    AplicarAnime(playerid,"GHANDS","gsign4LH",4.0,0,1,1,1,1);
    return 1;
}

CMD:ghand5(playerid)
{
    AplicarAnime(playerid,"GHANDS","gsign5LH",4.0,0,1,1,1,1);
    return 1;
}

CMD:exhausted(playerid)
{
    AplicarAnime(playerid,"FAT","IDLE_tired", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:carsmoke(playerid)
{
    AplicarAnime(playerid,"PED","Smoke_in_car", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:aim(playerid)
{
    AplicarAnime(playerid,"PED","gang_gunstand", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:getup(playerid)
{
    AplicarAnime(playerid,"PED","getup",4.0,0,0,0,0,0);
    return 1;
}

CMD:basket1(playerid)
{
    AplicarAnime(playerid,"BSKTBALL","BBALL_def_loop", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:basket2(playerid)
{
    AplicarAnime(playerid,"BSKTBALL","BBALL_idleloop", 4.0, 1, 0, 0, 0, 0);
    return 1;
}

CMD:basket3(playerid)
{
    AplicarAnime(playerid,"BSKTBALL","BBALL_pickup",4.0,0,0,0,0,0);
    return 1;
}

CMD:basket4(playerid)
{
    AplicarAnime(playerid,"BSKTBALL","BBALL_Jump_Shot",4.0,0,0,0,0,0);
    return 1;
}

CMD:basket5(playerid)
{
    AplicarAnime(playerid,"BSKTBALL","BBALL_Dnk",4.1,0,1,1,1,1);
    return 1;
}

CMD:basket6(playerid)
{
    AplicarAnime(playerid,"BSKTBALL","BBALL_run",4.1,1,1,1,1,1);
    return 1;
}

CMD:akick(playerid)
{
    AplicarAnime(playerid,"FIGHT_E","FightKick",4.0,0,0,0,0,0);
    return 1;
}

CMD:box(playerid)
{
    AplicarAnime(playerid,"GYMNASIUM","gym_shadowbox",4.1,1,1,1,1,1);
    return 1;
}

CMD:cockgun(playerid)
{
    AplicarAnime(playerid, "SILENCED", "Silence_reload", 3.0, 0, 0, 0, 0, 0);
    return 1;
}

CMD:bar1(playerid)
{
    AplicarAnime(playerid, "BAR", "Barcustom_get", 3.0, 0, 0, 0, 0, 0);
    return 1;
}

CMD:bar2(playerid)
{
    AplicarAnime(playerid, "BAR", "Barcustom_order", 3.0, 0, 0, 0, 0, 0);
    return 1;
}

CMD:bar3(playerid)
{
    AplicarAnime(playerid, "BAR", "Barserve_give", 3.0, 0, 0, 0, 0, 0);
    return 1;
}

CMD:bar4(playerid)
{
    AplicarAnime(playerid, "BAR", "Barserve_glass", 3.0, 0, 0, 0, 0, 0);
    return 1;
}

CMD:lay2(playerid)
{
    AplicarAnime(playerid,"BEACH", "SitnWait_loop_W", 4.0, 1, 0, 0, 0, 0); // Lay down
    return 1;
}

CMD:liftup(playerid)
{
    AplicarAnime(playerid, "CARRY", "liftup", 3.0, 0, 0, 0, 0, 0);
    return 1;
}

CMD:putdown(playerid)
{
    AplicarAnime(playerid, "CARRY", "putdwn", 3.0, 0, 0, 0, 0, 0);
    return 1;
}

CMD:joint(playerid)
{
    AplicarAnime(playerid,"GANGS","smkcig_prtl",4.0,0,1,1,1,1);
    return 1;
}

CMD:die(playerid)
{
    AplicarAnime(playerid,"KNIFE","KILL_Knife_Ped_Die",4.1,0,1,1,1,1);
    return 1;
}

CMD:shakehead(playerid)
{
    AplicarAnime(playerid, "MISC", "plyr_shkhead", 3.0, 0, 0, 0, 0, 0);
    return 1;
}

CMD:die2(playerid)
{
    AplicarAnime(playerid, "PARACHUTE", "FALL_skyDive_DIE", 4.0, 0, 1, 1, 1, -1);
    return 1;
}

CMD:aim2(playerid)
{
    AplicarAnime(playerid, "SHOP", "SHP_Gun_Aim", 4.0, 0, 1, 1, 1, -1);
    return 1;
}

CMD:benddown(playerid)
{
    AplicarAnime(playerid, "BAR", "Barserve_bottle", 4.0, 0, 0, 0, 0, 0);
    return 1;
}

CMD:checkout(playerid)
{
    AplicarAnime(playerid, "GRAFFITI", "graffiti_Chkout", 4.0, 0, 0, 0, 0, 0);
    return 1;
}
