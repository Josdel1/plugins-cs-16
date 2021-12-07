#include <amxmodx>
#include <engine>

native surf_get_mejora_djump(id)

new jumpnum[33] = 0
new bool:dojump[33] = false
new cvar_maxjumps

public plugin_init() {
	register_plugin("[RMS] MultiJump","1.1","twistedeuphoria")
	cvar_maxjumps = register_cvar("ctf_maxjumps_general", "1")
}

public client_putinserver(id) {
	jumpnum[id] = 0
	dojump[id] = false
}

public client_disconnected(id) {
	jumpnum[id] = 0
	dojump[id] = false
}

public client_PreThink(id) {
	if(!is_user_alive(id) || !is_user_connected(id) || !surf_get_mejora_djump(id)) return PLUGIN_CONTINUE
	
	new nbut = get_user_button(id)
	new obut = get_user_oldbutton(id)
	
	if((nbut & IN_JUMP) && !(get_entity_flags(id) & FL_ONGROUND) && !(obut & IN_JUMP))
	{
		if(jumpnum[id] < get_pcvar_num(cvar_maxjumps))
		{
			dojump[id] = true
			jumpnum[id]++
			return PLUGIN_CONTINUE
		}
	}
	if((nbut & IN_JUMP) && (get_entity_flags(id) & FL_ONGROUND))
	{
		jumpnum[id] = 0
		return PLUGIN_CONTINUE
	}
	
	return PLUGIN_CONTINUE
}

public client_PostThink(id)
{
	if(!is_user_alive(id) || !is_user_connected(id) || !surf_get_mejora_djump(id)) return PLUGIN_CONTINUE
	
	if(dojump[id] == true)
	{
		new Float:velocity[3]	
		entity_get_vector(id,EV_VEC_velocity,velocity)
		velocity[2] = random_float(265.0,285.0)
		entity_set_vector(id,EV_VEC_velocity,velocity)
		dojump[id] = false
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}	
