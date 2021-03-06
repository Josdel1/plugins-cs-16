/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <fakemeta>

native surf_get_user_level(id)

#define PLUGIN "[RMS] Skin Weapons"
#define VERSION "v1"
#define AUTHOR "Boogie"

new g_maxplayers

new const Modelos[][] = {
	"models/surf_ong/Glocks/GCK_LV12.mdl",
	"models/surf_ong/Glocks/GCK_LV125.mdl",
	"models/surf_ong/Glocks/GCK_LV333.mdl",
	
	"models/surf_ong/Knifes/KNF_LV5.mdl",
	"models/surf_ong/Knifes/KNF_LV75.mdl",
	"models/surf_ong/Knifes/KNF_LV155.mdl",
	"models/surf_ong/Knifes/KNF_LV280.mdl",
	"models/surf_ong/Knifes/KNF_LV555.mdl",
	
	"models/surf_ong/Ak47/AK_LV55.mdl",
	"models/surf_ong/Ak47/AK_LV550.mdl",
	"models/surf_ong/Ak47/AK_LV800.mdl",
	
	"models/surf_ong/Deagle/DG_LV320.mdl",
	"models/surf_ong/Deagle/DG_LV180.mdl",
	"models/surf_ong/Deagle/DG_LV35.mdl",
	
	"models/surf_ong/Snipers_AWP/AW_LV40.mdl",
	"models/surf_ong/Snipers_AWP/AW_LV450.mdl",
	"models/surf_ong/Snipers_AWP/AW_LV800.mdl",
	
	"models/surf_ong/M3/M3_LV60.mdl",
	"models/surf_ong/M3/M3_LV180.mdl",
	"models/surf_ong/M3/M3_LV250.mdl",
	"models/surf_ong/M3/M3_LV380.mdl",
	"models/surf_ong/M3/M3_LV650.mdl",
	"models/surf_ong/M3/M3_LV800.mdl",
	
	"models/surf_ong/M4/M4_LV55.mdl",
	"models/surf_ong/M4/M4_LV550.mdl",
	"models/surf_ong/M4/M4_LV800.mdl",
	
	"models/surf_ong/M249/M2_LV500.mdl",
	"models/surf_ong/M249/M2_LV700.mdl",
	
	"models/surf_ong/USP/US_LV12.mdl",
	"models/surf_ong/USP/US_LV125.mdl",
	"models/surf_ong/USP/US_LV333.mdl",
	
	"models/surf_ong/XM14/XM_LV150.mdl",
	"models/surf_ong/XM14/XM_LV300.mdl",
	"models/surf_ong/XM14/XM_LV600.mdl",
	
	"models/surf_ong/HE/HE_LV200.mdl",
	"models/surf_ong/HE/HE_LV400.mdl",
	
	"models/surf_ong/TakaCT/ST_LV200.mdl",
	"models/surf_ong/TakaCT/ST_LV400.mdl",
	"models/surf_ong/TakaCT/ST_LV600.mdl",
	
	"models/surf_ong/TakaTT/ST_LV200.mdl",
	"models/surf_ong/TakaTT/ST_LV400.mdl",
	"models/surf_ong/TakaTT/ST_LV700.mdl"
}

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	RegisterHam(Ham_Item_Deploy, "weapon_glock18", "Ham_Glock", true)
	RegisterHam(Ham_Item_Deploy, "weapon_knife", "Ham_Knife", true)
	RegisterHam(Ham_Item_Deploy, "weapon_ak47", "Ham_Ak47", true)
	RegisterHam(Ham_Item_Deploy, "weapon_deagle", "Ham_Deagle", true)
	RegisterHam(Ham_Item_Deploy, "weapon_usp", "Ham_Usp", true)
	RegisterHam(Ham_Item_Deploy, "weapon_awp", "Ham_Awp", true)
	RegisterHam(Ham_Item_Deploy, "weapon_m3", "Ham_M3", true)
	RegisterHam(Ham_Item_Deploy, "weapon_xm1014", "Ham_XM1014", true)
	RegisterHam(Ham_Item_Deploy, "weapon_m4a1", "Ham_M4", true)
	RegisterHam(Ham_Item_Deploy, "weapon_m249", "Ham_M249", true)
	RegisterHam(Ham_Item_Deploy, "weapon_hegrenade", "Ham_HE", true)
	RegisterHam(Ham_Item_Deploy, "weapon_g3sg1", "Ham_TakaCT", true)
	RegisterHam(Ham_Item_Deploy, "weapon_sg550", "Ham_TakaTT", true)
	
	g_maxplayers = get_maxplayers()
}
public plugin_precache() {
	new i
	for(i = 0; i < sizeof(Modelos); i++)
		precache_model(Modelos[i])
}
public Ham_Glock(weapon_ent) 
{
	if(!pev_valid(weapon_ent))
		return
	
	// Get weapon's owner
	static owner
	owner = fm_cs_get_weapon_ent_owner(weapon_ent)
	
	// Invalid player id? (bugfix)
	if (!(1 <= owner <= g_maxplayers)) return;	
	
	// Get weapon's id
	
	new id = get_pdata_cbase( weapon_ent, 41, 4 );
    
	if(is_user_alive(id) && is_user_connected(id)) 
	{
		if(surf_get_user_level(id) >= 333)
			set_pev(id, pev_viewmodel2, "models/surf_ong/Glocks/GCK_LV333.mdl")
		else if(surf_get_user_level(id) >= 125)
			set_pev(id, pev_viewmodel2, "models/surf_ong/Glocks/GCK_LV125.mdl")
		else if(surf_get_user_level(id) >= 12)
			set_pev(id, pev_viewmodel2, "models/surf_ong/Glocks/GCK_LV12.mdl")
		else
			set_pev(id, pev_viewmodel2, "models/v_glock18.mdl")
	}
}
public Ham_Knife(weapon_ent) 
{
	if(!pev_valid(weapon_ent))
		return
	
	// Get weapon's owner
	static owner
	owner = fm_cs_get_weapon_ent_owner(weapon_ent)
	
	// Invalid player id? (bugfix)
	if (!(1 <= owner <= g_maxplayers)) return;	
	
	// Get weapon's id
	
	new id = get_pdata_cbase( weapon_ent, 41, 4 );
    
	if(is_user_alive(id) && is_user_connected(id)) 
	{
		if(surf_get_user_level(id) >= 555)
			set_pev(id, pev_viewmodel2, "models/surf_ong/Knifes/KNF_LV555.mdl")
		else if(surf_get_user_level(id) >= 280)
			set_pev(id, pev_viewmodel2, "models/surf_ong/Knifes/KNF_LV280.mdl")
		else if(surf_get_user_level(id) >= 155)
			set_pev(id, pev_viewmodel2, "models/surf_ong/Knifes/KNF_LV155.mdl")
		else if(surf_get_user_level(id) >= 75)
			set_pev(id, pev_viewmodel2, "models/surf_ong/Knifes/KNF_LV75.mdl")
		else if(surf_get_user_level(id) >= 5)
			set_pev(id, pev_viewmodel2, "models/surf_ong/Knifes/KNF_LV5.mdl")
		else
			set_pev(id, pev_viewmodel2, "models/v_knife.mdl")
	}
}
public Ham_Ak47(weapon_ent) 
{
	if(!pev_valid(weapon_ent))
		return
	
	// Get weapon's owner
	static owner
	owner = fm_cs_get_weapon_ent_owner(weapon_ent)
	
	// Invalid player id? (bugfix)
	if (!(1 <= owner <= g_maxplayers)) return;	
	
	// Get weapon's id
	
	new id = get_pdata_cbase( weapon_ent, 41, 4 );
    
	if(is_user_alive(id) && is_user_connected(id)) 
	{
		if(surf_get_user_level(id) >= 800)
			set_pev(id, pev_viewmodel2, "models/surf_ong/Ak47/AK_LV800.mdl")
		else if(surf_get_user_level(id) >= 550)
			set_pev(id, pev_viewmodel2, "models/surf_ong/Ak47/AK_LV550.mdl")
		else if(surf_get_user_level(id) >= 55)
			set_pev(id, pev_viewmodel2, "models/surf_ong/Ak47/AK_LV55.mdl")
		else
			set_pev(id, pev_viewmodel2, "models/v_ak47.mdl")
	}
}
public Ham_Deagle(weapon_ent) 
{
	if(!pev_valid(weapon_ent))
		return
	
	// Get weapon's owner
	static owner
	owner = fm_cs_get_weapon_ent_owner(weapon_ent)
	
	// Invalid player id? (bugfix)
	if (!(1 <= owner <= g_maxplayers)) return;	
	
	// Get weapon's id
	
	new id = get_pdata_cbase( weapon_ent, 41, 4 );
    
	if(is_user_alive(id) && is_user_connected(id)) 
	{
		if(surf_get_user_level(id) >= 320)
			set_pev(id, pev_viewmodel2, "models/surf_ong/Deagle/DG_LV320.mdl")
		else if(surf_get_user_level(id) >= 180)
			set_pev(id, pev_viewmodel2, "models/surf_ong/Deagle/DG_LV180.mdl")
		else if(surf_get_user_level(id) >= 35)
			set_pev(id, pev_viewmodel2, "models/surf_ong/Deagle/DG_LV35.mdl")
		else
			set_pev(id, pev_viewmodel2, "models/v_deagle.mdl")
	}
}
public Ham_Usp(weapon_ent) 
{
	if(!pev_valid(weapon_ent))
		return
	
	// Get weapon's owner
	static owner
	owner = fm_cs_get_weapon_ent_owner(weapon_ent)
	
	// Invalid player id? (bugfix)
	if (!(1 <= owner <= g_maxplayers)) return;	
	
	// Get weapon's id
	
	new id = get_pdata_cbase( weapon_ent, 41, 4 );
    
	if(is_user_alive(id) && is_user_connected(id)) 
	{
		if(surf_get_user_level(id) >= 333)
			set_pev(id, pev_viewmodel2, "models/surf_ong/USP/US_LV333.mdl")
		else if(surf_get_user_level(id) >= 125)
			set_pev(id, pev_viewmodel2, "models/surf_ong/USP/US_LV125.mdl")
		else if(surf_get_user_level(id) >= 12)
			set_pev(id, pev_viewmodel2, "models/surf_ong/USP/US_LV12.mdl")
		else
			set_pev(id, pev_viewmodel2, "models/v_usp.mdl")
	}
}
public Ham_Awp(weapon_ent) 
{
	if(!pev_valid(weapon_ent))
		return
	
	// Get weapon's owner
	static owner
	owner = fm_cs_get_weapon_ent_owner(weapon_ent)
	
	// Invalid player id? (bugfix)
	if (!(1 <= owner <= g_maxplayers)) return;	
	
	// Get weapon's id
	
	new id = get_pdata_cbase( weapon_ent, 41, 4 );
    
	if(is_user_alive(id) && is_user_connected(id)) 
	{
		if(surf_get_user_level(id) >= 800)
			set_pev(id, pev_viewmodel2, "models/surf_ong/Snipers_AWP/AW_LV800.mdl")
		else if(surf_get_user_level(id) >= 450)
			set_pev(id, pev_viewmodel2, "models/surf_ong/Snipers_AWP/AW_LV450.mdl")
		else if(surf_get_user_level(id) >= 40)
			set_pev(id, pev_viewmodel2, "models/surf_ong/Snipers_AWP/AW_LV40.mdl")
		else
			set_pev(id, pev_viewmodel2, "models/v_awp.mdl")
	}
}
public Ham_M3(weapon_ent) 
{
	if(!pev_valid(weapon_ent))
		return
	
	// Get weapon's owner
	static owner
	owner = fm_cs_get_weapon_ent_owner(weapon_ent)
	
	// Invalid player id? (bugfix)
	if (!(1 <= owner <= g_maxplayers)) return;	
	
	// Get weapon's id
	
	new id = get_pdata_cbase( weapon_ent, 41, 4 );
    
	if(is_user_alive(id) && is_user_connected(id)) 
	{
		if(surf_get_user_level(id) >= 800)
			set_pev(id, pev_viewmodel2, "models/surf_ong/M3/M3_LV800.mdl")
		else if(surf_get_user_level(id) >= 650)
			set_pev(id, pev_viewmodel2, "models/surf_ong/M3/M3_LV650.mdl")
		else if(surf_get_user_level(id) >= 380)
			set_pev(id, pev_viewmodel2, "models/surf_ong/M3/M3_LV380.mdl")
		else if(surf_get_user_level(id) >= 250)
			set_pev(id, pev_viewmodel2, "models/surf_ong/M3/M3_LV250.mdl")
		else if(surf_get_user_level(id) >= 180)
			set_pev(id, pev_viewmodel2, "models/surf_ong/M3/M3_LV180.mdl")
		else if(surf_get_user_level(id) >= 60)
			set_pev(id, pev_viewmodel2, "models/surf_ong/M3/M3_LV60.mdl")
		else
			set_pev(id, pev_viewmodel2, "models/v_m3.mdl")
	}
}
public Ham_XM1014(weapon_ent) 
{
	if(!pev_valid(weapon_ent))
		return
	
	// Get weapon's owner
	static owner
	owner = fm_cs_get_weapon_ent_owner(weapon_ent)
	
	// Invalid player id? (bugfix)
	if (!(1 <= owner <= g_maxplayers)) return;	
	
	// Get weapon's id
	
	new id = get_pdata_cbase( weapon_ent, 41, 4 );
    
	if(is_user_alive(id) && is_user_connected(id)) 
	{
		if(surf_get_user_level(id) >= 600)
			set_pev(id, pev_viewmodel2, "models/surf_ong/XM14/XM_LV600.mdl")
		else if(surf_get_user_level(id) >= 300)
			set_pev(id, pev_viewmodel2, "models/surf_ong/XM14/XM_LV300.mdl")
		else if(surf_get_user_level(id) >= 150)
			set_pev(id, pev_viewmodel2, "models/surf_ong/XM14/XM_LV150.mdl")
		else
			set_pev(id, pev_viewmodel2, "models/v_xm1014.mdl")
	}
}
public Ham_M4(weapon_ent) 
{
	if(!pev_valid(weapon_ent))
		return
	
	// Get weapon's owner
	static owner
	owner = fm_cs_get_weapon_ent_owner(weapon_ent)
	
	// Invalid player id? (bugfix)
	if (!(1 <= owner <= g_maxplayers)) return;	
	
	// Get weapon's id
	
	new id = get_pdata_cbase( weapon_ent, 41, 4 );
    
	if(is_user_alive(id) && is_user_connected(id)) 
	{
		if(surf_get_user_level(id) >= 800)
			set_pev(id, pev_viewmodel2, "models/surf_ong/M4/M4_LV800.mdl")
		else if(surf_get_user_level(id) >= 550)
			set_pev(id, pev_viewmodel2, "models/surf_ong/M4/M4_LV550.mdl")
		else if(surf_get_user_level(id) >= 55)
			set_pev(id, pev_viewmodel2, "models/surf_ong/M4/M4_LV55.mdl")
		else
			set_pev(id, pev_viewmodel2, "models/v_m4a1.mdl")
	}
}
public Ham_M249(weapon_ent) 
{
	if(!pev_valid(weapon_ent))
		return
	
	// Get weapon's owner
	static owner
	owner = fm_cs_get_weapon_ent_owner(weapon_ent)
	
	// Invalid player id? (bugfix)
	if (!(1 <= owner <= g_maxplayers)) return;	
	
	// Get weapon's id
	
	new id = get_pdata_cbase( weapon_ent, 41, 4 );
    
	if(is_user_alive(id) && is_user_connected(id)) 
	{
		if(surf_get_user_level(id) >= 700)
			set_pev(id, pev_viewmodel2, "models/surf_ong/M249/M2_LV700.mdl")
		else if(surf_get_user_level(id) >= 500)
			set_pev(id, pev_viewmodel2, "models/surf_ong/M249/M2_LV500.mdl")
		else
			set_pev(id, pev_viewmodel2, "models/v_m249.mdl")
	}
}
public Ham_HE(weapon_ent) 
{
	if(!pev_valid(weapon_ent))
		return
	
	// Get weapon's owner
	static owner
	owner = fm_cs_get_weapon_ent_owner(weapon_ent)
	
	// Invalid player id? (bugfix)
	if (!(1 <= owner <= g_maxplayers)) return;	
	
	// Get weapon's id
	
	new id = get_pdata_cbase( weapon_ent, 41, 4 );
    
	if(is_user_alive(id) && is_user_connected(id)) 
	{
		if(surf_get_user_level(id) >= 400)
			set_pev(id, pev_viewmodel2, "models/surf_ong/HE/HE_LV400.mdl")
		else if(surf_get_user_level(id) >= 200)
			set_pev(id, pev_viewmodel2, "models/surf_ong/HE/HE_LV200.mdl")
		else
			set_pev(id, pev_viewmodel2, "models/v_hegrenade.mdl")
	}
}
public Ham_TakaCT(weapon_ent) 
{
	if(!pev_valid(weapon_ent))
		return
	
	// Get weapon's owner
	static owner
	owner = fm_cs_get_weapon_ent_owner(weapon_ent)
	
	// Invalid player id? (bugfix)
	if (!(1 <= owner <= g_maxplayers)) return;	
	
	// Get weapon's id
	
	new id = get_pdata_cbase( weapon_ent, 41, 4 );
    
	if(is_user_alive(id) && is_user_connected(id)) 
	{
		if(surf_get_user_level(id) >= 600)
			set_pev(id, pev_viewmodel2, "models/surf_ong/TakaCT/ST_LV600.mdl")
		else if(surf_get_user_level(id) >= 400)
			set_pev(id, pev_viewmodel2, "models/surf_ong/TakaCT/ST_LV400.mdl")
		else if(surf_get_user_level(id) >= 200)
			set_pev(id, pev_viewmodel2, "models/surf_ong/TakaCT/ST_LV200.mdl")
		else
			set_pev(id, pev_viewmodel2, "models/v_g3sg1.mdl")
	}
}
public Ham_TakaTT(weapon_ent) 
{
	if(!pev_valid(weapon_ent))
		return
	
	// Get weapon's owner
	static owner
	owner = fm_cs_get_weapon_ent_owner(weapon_ent)
	
	// Invalid player id? (bugfix)
	if (!(1 <= owner <= g_maxplayers)) return;	
	
	// Get weapon's id
	
	new id = get_pdata_cbase( weapon_ent, 41, 4 );
    
	if(is_user_alive(id) && is_user_connected(id)) 
	{
		if(surf_get_user_level(id) >= 700)
			set_pev(id, pev_viewmodel2, "models/surf_ong/TakaTT/ST_LV700.mdl")
		else if(surf_get_user_level(id) >= 400)
			set_pev(id, pev_viewmodel2, "models/surf_ong/TakaTT/ST_LV400.mdl")
		else if(surf_get_user_level(id) >= 200)
			set_pev(id, pev_viewmodel2, "models/surf_ong/TakaTT/ST_LV200.mdl")
		else
			set_pev(id, pev_viewmodel2, "models/v_sg550.mdl")
	}
}
stock fm_cs_get_weapon_ent_owner(ent) {
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(ent) != 2)
		return -1;
	
	return get_pdata_cbase(ent, 41, 4);
}
