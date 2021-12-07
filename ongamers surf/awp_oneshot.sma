
 #include <amxmodx>
 #include <fakemeta>
 #include <cstrike>

 new cv_awp_clip, gmsgCurWeapon, weapon[33], awp_clip[33], awp_bpammo[33];

 public plugin_init()
 {
	register_plugin("AWP One Shot","0.11","Avalanche");

	register_event("CurWeapon","event_curweapon","b");
	register_event("AmmoX","event_ammox","b");

	gmsgCurWeapon = get_user_msgid("CurWeapon");
	cv_awp_clip = register_cvar("awp_clip","1");

	register_forward(FM_CmdStart,"fw_cmdstart",1);
 }

 // reset values
 public client_putinserver(id)
 {
	weapon[id] = 0;
	awp_clip[id] = 0;
	awp_bpammo[id] = 0;
 }

 // restrict clip ammo
 public event_curweapon(id)
 {
	new status = read_data(1);

	if(status) weapon[id] = read_data(2);

	// using AWP
	if(read_data(2) == CSW_AWP)
	{
		// current weapon
		if(status)
		{
			// save clip information
			new old_awp_clip = awp_clip[id];
			awp_clip[id] = read_data(3);

			new max_clip = get_pcvar_num(cv_awp_clip);

			// plugin enabled and must restrict ammo
			if(max_clip && awp_clip[id] > max_clip)
			{
				new wEnt = get_weapon_ent(id,CSW_AWP);
				if(pev_valid(wEnt)) cs_set_weapon_ammo(wEnt,max_clip);

				// update HUD
				message_begin(MSG_ONE,gmsgCurWeapon,_,id);
				write_byte(1);
				write_byte(CSW_AWP);
				write_byte(max_clip);
				message_end();

				// don't steal ammo from the player
				if(awp_bpammo[id] && awp_clip[id] > old_awp_clip)
					cs_set_user_bpammo(id,CSW_AWP,awp_bpammo[id]-max_clip+old_awp_clip);

				awp_clip[id] = max_clip;
			}
		}
		else awp_clip[id] = 999;
	}
	else if(status) awp_clip[id] = 999;
 }

 // delayed record bpammo information
 public event_ammox(id)
 {
	// awp ammo type is 1
	if(read_data(1) == 1)
	{
		static parms[2];
		parms[0] = id;
		parms[1] = read_data(2);

		set_task(0.1,"record_ammo",id,parms,2);
	}
 }

 // delay, because ammox is called right before curweapon
 public record_ammo(parms[])
 {
	awp_bpammo[parms[0]] = parms[1];
 }

 // block reload based on new clip size
 public fw_cmdstart(player,uc_handle,random_seed)
 {
	new max_clip = get_pcvar_num(cv_awp_clip);

	if(weapon[player] == CSW_AWP && max_clip && awp_clip[player] >= max_clip)
	{
		set_uc(uc_handle,UC_Buttons,get_uc(uc_handle,UC_Buttons) & ~IN_RELOAD);
		return FMRES_HANDLED;
	}

	return FMRES_IGNORED;
 }

 // find a player's weapon entity
 stock get_weapon_ent(id,wpnid=0,wpnName[]="")
 {
	// who knows what wpnName will be
	static newName[32];

	// need to find the name
	if(wpnid) get_weaponname(wpnid,newName,31);

	// go with what we were told
	else formatex(newName,31,"%s",wpnName);

	// prefix it if we need to
	if(!equal(newName,"weapon_",7))
		format(newName,31,"weapon_%s",newName);

	new ent;
	while((ent = engfunc(EngFunc_FindEntityByString,ent,"classname",newName)) && pev(ent,pev_owner) != id) {}

	return ent;
 }
