#include <amxmodx>
#include <engine>
#include <fun>
#include <hamsandwich>
#include <cs_player_models_api>
#include <cstrike>
#include <fakemeta_util>

native surf_get_user_exp(id)
native surf_set_user_exp(id, amount)
native surf_get_user_level(id)
native surf_set_mode(Number_Mode)
native surf_execute_teambalance()

enum (+= 100)
{
	TASK_SHOWHUD = 1000,
	TASK_FLAME,
	TASK_DRUG
};

enum
{
	GRENADE_FIRE = 0,
	GRENADE_DRUG
};

const UNIT_SECOND = (1<<12);
const FFADE_IN = 0x0000;

new const SOUND_CABEZON_PAIN[][] = { "surf_ong/gc_cabezon_pain.wav", "surf_ong/gc_cabezon_pain2.wav" };
new const SOUND_EXPLODE[] = "weapons/c4_explode1.wav";
new const SOUND_ALERT[] = "surf_ong/gc_mode_alert.wav";
new const SPRITE_RING[] = "sprites/shockwave.spr";
new const SPRITE_FLAME[] = "sprites/surf_ong/gc_flame.spr";
new const SPRITE_LASERBEAM[] = "sprites/laserbeam.spr";

#define szprefix "!y[!gOG!y]"

const OFFSET_ACTIVE_ITEM = 373
const OFFSET_LINUX = 5

new g_maxplayers
new g_started;
new bool:g_monster[33];
new bool:g_power[33];
new g_spr_ring;
new g_spr_beamfollow;
new g_spr_flame;
new g_sync;
new g_monster_name[33][32];
new g_drug[33];
new g_colors[3];
new g_drug_time[33];
new g_ZombieRandomBody

new const Modelos[][] = { "models/player/Revenant_Final/Revenant_Final.mdl" };

enum
{
	CS_WEAPONANIM_IDLE = 0,
	CS_WEAPONANIM_RELOAD,
	CS_WEAPONANIM_DRAW,
	CS_WEAPONANIM_SHOOT1,
	CS_WEAPONANIM_SHOOT2,
	CS_WEAPONANIM_SHOOT3
}

public plugin_init()
{
	register_plugin("Modo Revenant 2021", "2.0", "Boogie"); 
	
	RegisterHam(Ham_Killed, "player", "ham_PlayerKilled");
	RegisterHam(Ham_TakeDamage, "player", "ham_TakeDamage");
	RegisterHam(Ham_Spawn, "player", "ham_PlayerSpawnPost", true);
	RegisterHam(Ham_Item_PreFrame, "player", "ham_Item_Preframe", true);
	RegisterHam(Ham_Think, "grenade", "ham_ThinkGrenade");
	register_event("CurWeapon","EventCurWeapon","be","1=1")

	register_clcmd("drop", "clcmd_drop");
	
	register_event("HLTV", "round_start", "a", "1=0", "2=0");
	
	register_impulse(201, "clcmd_power");
	
	
	register_message(get_user_msgid("ScreenFade"), "message_screenfade");
	
	g_sync = CreateHudSyncObj();
	
	g_maxplayers = get_maxplayers();
}
public client_putinserver(id) {
	g_monster[id] = false
	g_power[id] = false
	g_drug[id] = 0
	g_drug_time[id] = 0
}
// Forward CmdStart
public fw_CmdStart(id, handle)
{
	new iButton = get_uc( handle, UC_Buttons );
	
	// Not alive
	if(!is_user_alive(id) || !g_monster[id])
		return FMRES_IGNORED;
	
	if(g_monster[id] && get_user_weapon(id) != CSW_KNIFE && iButton & IN_ATTACK || iButton & IN_ATTACK2)
	{
		set_uc( handle, UC_Buttons, iButton & ~IN_ATTACK );
		engclient_cmd(id, "weapon_knife");
		return FMRES_SUPERCEDE;
	}
	
	
	static weapon_ent; weapon_ent = fm_cs_get_current_weapon_ent(id)
	g_ZombieRandomBody = random_num(0,3)
	set_pev(weapon_ent, pev_body, g_ZombieRandomBody)
	
	return FMRES_IGNORED;
}

public EventCurWeapon(id)
{
	if(!is_user_alive(id) || !g_monster[id]) return PLUGIN_HANDLED;
	
	if(get_user_weapon(id) != CSW_KNIFE) engclient_cmd(id, "weapon_knife")
	
	set_pev(id, pev_viewmodel2, "models/surf_ong/v_revenant_final.mdl")
	set_pev(id, pev_weaponmodel2, "")
	
	return PLUGIN_CONTINUE;
}
public plugin_natives()
{
	register_native("surf_get_user_zombie", "native_get_user_zombie", 1);
	register_native("surf_set_user_zombie", "native_set_user_zombie", 1);
	register_native("surf_init_event_zombie", "clcmd_gc", 1)
	register_native("surf_end_event_zombie", "clcmd_gcoff", 1)
}

public native_get_user_zombie(id)
{
	if (!is_user_connected(id))
	{
		log_error(AMX_ERR_NATIVE, "[RMS] Invalid player id (%d)", id);
		return -1;
	}

	return g_monster[id];
}
public native_set_user_zombie(id, bool:amount)
{
	if (!is_user_connected(id)) {
		log_error(AMX_ERR_NATIVE, "[RMS] Invalid player id (%d)", id);
		return false;
	}
	
	g_monster[id] = amount;
	return true;
}
public clcmd_gc(Id_Target)
{
	if(Id_Target == 0) {
		static iPlayersnum, Random
		iPlayersnum = fnGetAlive()
		Random = fnGetRandomAlive(random_num(1, iPlayersnum))
		
		g_monster[Random] = true;
		CheckMode();
	}
	
	return PLUGIN_HANDLED;
}

public clcmd_gcoff(id)
{
	if (!g_started)
		return PLUGIN_HANDLED;
	
	static name[32];
	get_user_name(id, name, charsmax(name));
	
	RemoveTask();
	
	if(id == 0)
		chat_color(0, "%s !yHa Finalizado el !gMODO REVENANT!y.", szprefix)
	else
		chat_color(0, "%s !g%s!y Ha Finalizado el !gMODO REVENANT!y.", szprefix, name);
	
	return PLUGIN_HANDLED;
}
public plugin_precache()
{
	g_spr_ring = precache_model(SPRITE_RING);
	g_spr_beamfollow = precache_model(SPRITE_LASERBEAM);
	g_spr_flame = precache_model(SPRITE_FLAME);
	precache_model("models/surf_ong/v_revenant_final.mdl")
	
	static i;
	
	for (i = 0; i < sizeof(SOUND_CABEZON_PAIN); i++)
		precache_sound(SOUND_CABEZON_PAIN[i]);
	
	precache_sound(SOUND_ALERT);
	
	for(i = 0; i < sizeof(Modelos); i++)
		precache_model(Modelos[i])
		
	register_forward(FM_CmdStart, "fw_CmdStart");
	register_forward(FM_EmitSound, "fw_EmitSound");
	register_forward(FM_SetModel, "fw_SetModel");
	register_forward(FM_ClientKill, "fw_ClientKill");
	
}


public round_start()
{
	set_cvar_num("mp_round_infinite", 0)
	set_cvar_num("mp_forcerespawn", 0)
	
	if (g_started)
	{
		g_started = false;
		RemoveTask();
	}
}

public client_disconnected(id)
{
	if (!g_started) return;
	
	remove_task(id + TASK_SHOWHUD);
	remove_task(id + TASK_FLAME);
}

public clcmd_drop(id)
{
	if (!g_started) return PLUGIN_CONTINUE;
	
	if (g_monster[id]) return PLUGIN_CONTINUE;
	
	client_print(id, print_center, "¡ NO PODÉS TIRAR TU ARMA !");
	return PLUGIN_HANDLED;
}

public RemoveTask()
{
	static id;
	set_lights("m");
	g_started = false;
	ClearSyncHud(0, g_sync);
	
	set_cvar_num("iatb_active", 1)
	set_cvar_num("iatb_admins_immunity", 0)
	set_cvar_num("mp_round_infinite", 0)
	set_cvar_num("mp_forcerespawn", 0) 
			
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (!is_user_connected(id)) continue;
			
		remove_task(id + TASK_SHOWHUD);
		remove_task(id + TASK_FLAME);
		remove_task(id + TASK_DRUG);
		
		set_user_rendering(id)
		
		if(g_monster[id]) user_silentkill(id)
		
		g_drug[id] = 0;
		g_monster[id] = false
	}
	
	surf_set_mode(0)	
	clcmd_gcoff(0)
	surf_execute_teambalance()
}

public clcmd_power(id)
{
	if (!g_started)
		return PLUGIN_CONTINUE;
	
	if (!g_monster[id])
		return PLUGIN_CONTINUE;
	
	if (!g_power[id])
	{
		chat_color(id, "%s !yTu poder se esta cargando!", szprefix);
		return PLUGIN_HANDLED;
	}

	CreatePower(id);
	return PLUGIN_HANDLED;
}

public CreatePower(id)
{	
	static originF[3];
	get_user_origin(id, originF, 0);
	
	message_begin(MSG_PVS, SVC_TEMPENTITY, originF, 0);
	write_byte(TE_BEAMCYLINDER);
	write_coord(originF[0]);
	write_coord(originF[1]);
	write_coord(originF[2]);
	write_coord(originF[0] + 550);
	write_coord(originF[1]);
	write_coord(originF[2] + 400);
	write_short(g_spr_ring);
	write_byte(0);
	write_byte(0);
	write_byte(4);
	write_byte(60);
	write_byte(0);
	write_byte(200);
	write_byte(0);
	write_byte(0);
	write_byte(200);
	write_byte(0);
	message_end();
	
	static i;
	
	for (i = 1; i <= g_maxplayers; i++)
	{		
		if (!is_user_alive(i))
			continue;
		
		if (g_monster[i])
			continue;
		
		if (entity_range(i, id) <= 400)
			ExecuteHamB(Ham_Killed, i, id, 2);
	}
	
	static ServerIP[32];
	get_user_authid(id, ServerIP, charsmax(ServerIP));
	
	message_begin(MSG_BROADCAST, get_user_msgid("ScreenFade"));
	write_short(UNIT_SECOND * 7);
	write_short(UNIT_SECOND);
	write_short(FFADE_IN);
	write_byte(random_num(20,250));
	write_byte(random_num(20,250));
	write_byte(random_num(20,250));
	write_byte(random_num(120, 180));
	message_end();
		
	message_begin(MSG_BROADCAST, get_user_msgid("ScreenShake"));
	write_short(UNIT_SECOND * 150);
	write_short(UNIT_SECOND * 10);
	write_short(UNIT_SECOND * 120);
	message_end();
	
	g_power[id] = false;
	set_task(20.0, "AlertExplode", id);
	
	client_cmd(id, "spk ^"%s^"", SOUND_EXPLODE)
	
	set_rendering(id, kRenderFxGlowShell, random_num(20, 250), random_num(20, 250), random_num(20, 250), kRenderNormal, 5);
}
public CheckMode()
{
	g_started = true;
	
	static id;
	
	for( new i = 1; i <= g_maxplayers; i++ )
	{
		if( !is_user_connected( i )|| is_user_bot(i))
			continue;
				
		
	}
		
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (!is_user_connected(id))
			continue;
		
		static CsTeams:team;
		team = cs_get_user_team(id);
		
		if (team == CS_TEAM_SPECTATOR || team == CS_TEAM_UNASSIGNED)
			continue;
		
		if (g_monster[id])
		{
			makemonster(id);
			continue;
		}
		else {
			if( cs_get_user_team( id ) == CS_TEAM_T)
				cs_set_user_team(id, CS_TEAM_CT );
		}
	}
}

public makemonster(id)
{
	if (!is_user_connected(id) || !is_user_alive(id)) return;
	
	set_user_health(id, 30000000);
	set_user_gravity(id, 2.0);
	
	strip_user_weapons(id);
	
	cs_set_user_team(id, CS_TEAM_T);
	give_item(id, "weapon_knife");
	
	set_rendering(id, kRenderFxGlowShell, random_num(20,255), random_num(20,255), random_num(20,255), kRenderNormal, 5);
	
	set_lights("c");
	set_task(20.0, "AlertExplode", id);
	get_user_name(id, g_monster_name[id], charsmax(g_monster_name[]));
	
	cs_set_player_model(id, "Revenant_Final");
	
	if(task_exists(id+TASK_SHOWHUD)) remove_task(id+TASK_SHOWHUD)
	
	set_task(1.0, "ShowHUD", id + TASK_SHOWHUD, _, _, "b");
	
	new iEnt = fm_find_ent_by_owner(-1, "rms_tablesurf", id)
	if(iEnt > 0) engfunc(EngFunc_RemoveEntity, iEnt)
	
	client_cmd(id, "spk ^"%s^"", SOUND_ALERT)
}

public AlertExplode(id)
{
	if (!g_started)
		return;
	
	g_power[id] = true;
	set_rendering(id, kRenderFxGlowShell, random_num(20,255), random_num(20,255), random_num(20,255), kRenderNormal, 5);
		
	chat_color(id, "%s !yTU HABILIDAD SE HA CARGADO, PARA USARLA PRESIONA !y[!g T !y]", szprefix);
}
public ShowHUD(id)
{
	if (!g_started)
		return;
	
	id -= TASK_SHOWHUD;
	
	static happy[40];
	
	switch(g_power[id]) 
	{
		case 0:
			happy = "SIN HABILIDAD!";	
		case 1:
			happy = "HABILIDAD LISTA!";
	}
	
	set_pev(id, pev_skin, random_num(0,3))
	
	set_hudmessage(255, 255, 0, 0.02, 0.23, 2, 0.0, 1.1, 0.0, 0.0, 2);
	ShowSyncHudMsg(0, g_sync, "REVENANT: %s^nHEALTH: %d^n%s", g_monster_name[id], get_user_health(id), happy);
}
public ham_PlayerKilled(victim, attacker, shouldgib)
{
	if (!is_user_connected(attacker))
		return HAM_IGNORED;
	
	if (victim == attacker)
		return HAM_IGNORED;
	
	if (!g_started)
		return HAM_IGNORED;
	
	if(g_monster[victim]) {
		RemoveTask()
		g_monster[victim] = false
	}
	
	if (g_monster[attacker])
		return HAM_IGNORED;
	
	if (task_exists(victim + TASK_FLAME))
		remove_task(victim + TASK_FLAME);
	
	if (task_exists(victim + TASK_DRUG))
		remove_task(victim + TASK_DRUG);
	
	new szName[32];
	get_user_name(attacker, szName, charsmax(szName));
		
	set_dhudmessage(200, 0, 0, -1.0, 0.40, 2, 0.0, 4.0, 0.02, 0.01 );
	show_dhudmessage(0, "%s ANIQUILO LA PLAGA A TIEMPO !!!", szName);
	
	surf_set_user_exp(attacker, surf_get_user_exp(attacker) + 10000)
	
	return HAM_IGNORED;
}

public ham_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	if (!g_started)
		return HAM_IGNORED;
	
	if (!is_user_connected(attacker) || victim == attacker)
		return HAM_IGNORED;
	
	if (g_monster[attacker] && get_user_weapon(attacker) == CSW_KNIFE)
	{
		damage *= 100.0;
		SetHamParamFloat(4, damage);
	}
	else if(!g_monster[attacker])
	{
		damage *= 25.0;
		SetHamParamFloat(4, damage);
	}
	
	if(g_monster[victim])
	{
		set_hudmessage(random_num(20,255), random_num(20,255), random_num(20,255), -1.0, 0.40, 1, 4.5, 4.5, 0.01, 0.01, 2);
		ShowSyncHudMsg(attacker, g_sync, "DMG HECHO: %d", floatround(damage));
	}
	
	return HAM_IGNORED;
}

public ham_PlayerSpawnPost(id)
{
	if(!is_user_connected(id)) return HAM_IGNORED;
	
	g_monster[id] = false
	
	cs_reset_player_model(id)
	
	return HAM_IGNORED;
}

public ham_Item_Preframe(id)
{
	if (!g_started)
		return HAM_IGNORED;
	
	if (!is_user_connected(id) || !is_user_alive(id))
		return HAM_IGNORED;
	
	if (g_monster[id])
	{
		set_user_maxspeed(id, 700.0);
		return HAM_IGNORED;
	}
	
	return HAM_IGNORED;
}

public ham_ThinkGrenade(ent)
{
	if (!g_started)
		return HAM_IGNORED;
	
	if (!is_valid_ent(ent))
		return HAM_IGNORED;
	
	if (entity_get_float(ent, EV_FL_dmgtime) > get_gametime())
		return HAM_IGNORED;
	
	switch(entity_get_int(ent, EV_INT_flTimeStepSound))
	{
		case GRENADE_FIRE: grenade_explode(ent, GRENADE_FIRE);
		case GRENADE_DRUG: grenade_explode(ent, GRENADE_DRUG);
	}
	
	remove_entity(ent);
	return HAM_SUPERCEDE;
}

grenade_explode(ent, type)
{
	if (!g_started)
		return;
	
	static victim, Float:originF[3];
	victim = -1;
	
	entity_get_vector(ent, EV_VEC_origin, originF);
	
	switch(type)
	{
		case GRENADE_FIRE:
		{	
			CreateBlast(originF, 0);	
			
			while ((victim = find_ent_in_sphere(victim, originF, 400.0)) != 0)
			{
				if (!is_user_connected(victim) || !is_user_alive(victim))
					continue;
			
				if (!g_monster[victim])
					continue;
					
				set_task(0.3, "FireMonster", victim + TASK_FLAME, _, _, "b");
				set_task(7.5, "RemoveFireMonster", victim);
			}
		}
		case GRENADE_DRUG:
		{	
			CreateBlast(originF, 1);
			
			while ((victim = find_ent_in_sphere(victim, originF, 400.0)) != 0)
			{
				if (!is_user_connected(victim) || !is_user_alive(victim))
					continue;
					
				if (!g_monster[victim])
					continue;
					
				if (task_exists(victim + TASK_DRUG))
					continue;
					
				
				g_drug_time[victim] += 5;
				static Float:TaskTime;

				switch(random_num(0, 3))
				{
					case 0: TaskTime = 1.0;
					case 1: TaskTime = 1.5;
					case 2: TaskTime = 2.0;
				}
					
				
				set_task(TaskTime, "DrugMonster", victim + TASK_DRUG, _, _, "b");
				//strip_user_weapons(victim);
			}
		}
	}
}

CreateBlast(Float:originF[3], colors)
{
	if (!g_started)
		return;
	
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0);
	write_byte(TE_BEAMCYLINDER);
	engfunc(EngFunc_WriteCoord, originF[0]);
	engfunc(EngFunc_WriteCoord, originF[1]);
	engfunc(EngFunc_WriteCoord, originF[2]);
	engfunc(EngFunc_WriteCoord, originF[0]);
	engfunc(EngFunc_WriteCoord, originF[1]);
	engfunc(EngFunc_WriteCoord, originF[2] + 400);
	write_short(g_spr_ring);
	write_byte(0);
	write_byte(0);
	write_byte(4);
	write_byte(60);
	write_byte(0);
	write_byte((colors) ? g_colors[0] : 255);
	write_byte((colors) ? g_colors[1] : 0);
	write_byte((colors) ? g_colors[2] : 0);
	write_byte(200);
	write_byte(0);
	message_end();
}

public DrugMonster(id)
{
	if (!g_started)
		return;
	
	id -= TASK_DRUG;
	
	if (!is_user_alive(id))
		return;
	
	if (g_drug_time[id] < 1)
	{
		g_drug_time[id] = 0;
		remove_task(id + TASK_DRUG);
		
		if (!user_has_weapon(id, CSW_KNIFE))
			give_item(id, "weapon_knife");
		
		return;
	}
	
	static Float:originF[3];
	originF[0] = random_float(-10.0, 150.0);
	originF[1] = random_float(20.0, 200.0);
	originF[2] = random_float(30.0, 250.0);
	
	message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), _, id);
	write_short(UNIT_SECOND);
	write_short(0);
	write_short(FFADE_IN);
	write_byte(255);
	write_byte(0);
	write_byte(0);
	write_byte(200);
	message_end();
	
	static Float:TaskTime;
	
	switch(random_num(0, 3))
	{
		case 0: TaskTime = 2.5;
		case 1: TaskTime = 3.0;
		case 2: TaskTime = 4.0;
		case 3: TaskTime = 4.5;
	}
	
	set_task(TaskTime, "DrugMonster", id);
	
	entity_set_vector(id, EV_VEC_punchangle, originF);
	
	g_drug_time[id]--;
}

public FireMonster(id)
{
	if (!g_started)
		return;
	
	id -= TASK_FLAME;
	
	static originF[3], health, damage;
	get_user_origin(id, originF, 0);
	
	health = get_user_health(id);
	damage = random_num(500, 2500)
	
	set_user_health(id, health - damage);
	
	message_begin(MSG_PVS, SVC_TEMPENTITY, originF, 0);
	write_byte(TE_SPRITE);
	write_coord(originF[0]);
	write_coord(originF[1]);
	write_coord(originF[2]);
	write_short(g_spr_flame);
	write_byte(random_num(8, 15));
	write_byte(200);
	message_end();
}

public RemoveFireMonster(id)
{
	if (!g_started)
		return;
	
	if (task_exists(id + TASK_FLAME))
		remove_task(id + TASK_FLAME);		
}

public fw_EmitSound(id, channel, const sample[], Float:volume, Float:attnorm, flags, pitch)
{
	if (!g_started)
		return FMRES_IGNORED;
	
	if (!is_user_alive(id) || !g_monster[id])
		return FMRES_IGNORED;
	
	if (equal(sample[7], "bhit", 4))
	{
		client_cmd(id, "spk ^"%s^"", SOUND_CABEZON_PAIN[random_num(0, sizeof(SOUND_CABEZON_PAIN) - 1)])
		return FMRES_SUPERCEDE;
	}
	
	return FMRES_IGNORED;
}

public fw_SetModel(ent, const model[])
{
	if (!g_started)
		return FMRES_IGNORED;
	
	static classname[32], id;
	entity_get_string(ent, EV_SZ_classname, classname, charsmax(classname));
	id = entity_get_edict(ent, EV_ENT_owner);
	
	if (equal(classname, "weaponbox"))
	{
		entity_set_float(ent, EV_FL_nextthink, get_gametime() + 0.01); 
		return FMRES_IGNORED;
	}
	
	if (equal(model[7], "w_he", 4))
	{
		set_rendering(ent, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 25);
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_BEAMFOLLOW);
		write_short(ent);
		write_short(g_spr_beamfollow);
		write_byte(10);
		write_byte(10);
		write_byte(255);
		write_byte(0);
		write_byte(0);
		write_byte(200);
		message_end();
		
		entity_set_int(ent, EV_INT_flTimeStepSound, GRENADE_FIRE);
	}
	else if (g_drug[id] >= 1 && equal(model[7], "w_sm", 4))
	{
		g_colors[0] = g_colors[1] = g_colors[2] = random_num(10, 255);
		
		set_rendering(ent, kRenderFxGlowShell, g_colors[0], g_colors[1], g_colors[2], kRenderNormal, 25);
		
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
		write_byte(TE_BEAMFOLLOW);
		write_short(ent);
		write_short(g_spr_beamfollow);
		write_byte(10);
		write_byte(10);
		write_byte(g_colors[0]);
		write_byte(g_colors[1]);
		write_byte(g_colors[2]);
		write_byte(200);
		message_end();
		
		entity_set_int(ent, EV_INT_flTimeStepSound, GRENADE_DRUG);
	}
	
	return FMRES_IGNORED;
}

public fw_ClientKill(id)
{
	if (!g_started) return FMRES_IGNORED;
	
	console_print(id, "NO PODES SUICIDARTE");
	return FMRES_SUPERCEDE;
}

public message_screenfade(msgent, dest, id)
{
	if (!g_started) return PLUGIN_CONTINUE;
	
	if (get_msg_arg_int(4) == 255 && get_msg_arg_int(5) == 255 && get_msg_arg_int(6) == 255 && !g_monster[id])
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

stock chat_color(id, const input[], any:...)
{
	static msg[191];
	vformat(msg, 190, input, 3);
	
	replace_all(msg, 190, "!g", "^4");
	replace_all(msg, 190, "!t", "^3");
	replace_all(msg, 190, "!y", "^1");
	
	message_begin((id) ? MSG_ONE_UNRELIABLE : MSG_BROADCAST, get_user_msgid("SayText"), .player = id);
	write_byte((id) ? id : 33);
	write_string(msg);
	message_end();
}

stock ClientCmd ( id, Command [ ], any:... ) 
{ 
	message_begin ( MSG_ONE_UNRELIABLE, SVC_DIRECTOR, _, id );
    	write_byte ( strlen ( Command ) + 2 );
    	write_byte ( 10 ); 
	write_string ( Command ); 
    	message_end ( ); 
}
fnGetAlive()
{
	static iAlive, id
	iAlive = 0
    
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (is_user_alive(id))
			iAlive++
	}
    
	return iAlive;
}

fnGetRandomAlive(n)
{
	static iRandomAliveT, id
	iRandomAliveT = 0
    
	for (id = 1; id <= g_maxplayers; id++)
	{
		if (is_user_connected(id))
		{            
			if (is_user_alive(id))
				iRandomAliveT++
		}
        
		if (iRandomAliveT == n)
			return id;
	}
    
	return -1;
}
stock fm_cs_get_current_weapon_ent(id) { // Get User Current Weapon Entity
	if(pev_valid(id) != 2) return -1; // Prevent server crash if entity's private data not initalized

	return get_pdata_cbase(id, OFFSET_ACTIVE_ITEM, OFFSET_LINUX);
}
