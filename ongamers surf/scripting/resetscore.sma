#include <amxmodx>
#include <cstrike>
#include <fun>

public plugin_init()
{
	register_plugin("Reset Score", "1.0", "Silenttt")
	
	register_clcmd("say /resetscore", "reset_score")
	register_clcmd("say /restartscore", "reset_score")
	register_clcmd("say /rs", "reset_score")
	register_clcmd("say resetscore", "reset_score")
	register_clcmd("say restartscore", "reset_score")
	register_clcmd("say rs", "reset_score")
	register_clcmd("say_team /resetscore", "reset_score")
	register_clcmd("say_team /restartscore", "reset_score")
	register_clcmd("say_team /rs", "reset_score")
	register_clcmd("say_team resetscore", "reset_score")
	register_clcmd("say_team restartscore", "reset_score")
	register_clcmd("say_team rs", "reset_score")
}

public reset_score(id)
{
	cs_set_user_deaths(id, 0)
	set_user_frags(id, 0)
	cs_set_user_deaths(id, 0)
	set_user_frags(id, 0)
	
	new name[64]
	get_user_name(id, name, 63)
	chatcolor(0, "!t[!gOG!t]!y JAJA!g %s!t TOD@ CAGA@ !gREINICIO SU SCORE.", name)
	
	return PLUGIN_HANDLED
}
stock chatcolor(id, const input[], any:...) 
{
	new count = 1, players[32]; 
	static msg[191]; 
	vformat(msg, 190, input, 3); 
     
	replace_all(msg, 190, "!g", "^4"); // Verde
	replace_all(msg, 190, "!y", "^1"); // Default
	replace_all(msg, 190, "!t", "^3"); // Color del Equipo 
     
	if (id) players[0] = id; else get_players(players, count, "ch"); { 
		for (new i = 0; i < count; i++)  { 
			if (is_user_connected(players[i])) { 
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i]); 
				write_byte(players[i]); 
				write_string(msg); 
				message_end(); 
			} 
		} 
	} 
} 
