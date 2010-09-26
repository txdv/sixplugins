// Description: a plugin which gives unlimited rockets and grenades to tfc players.
#include <amxmodx>
#include <tfcx>
#include <hamsandwich>

#pragma semicolon 1

#define m_pActiveItem 569

new g_nades;
new g_rockets;

public plugin_init()
{
	register_plugin("unlimited clips", "0.1", "Andrius Bentkus");
	register_event("CurWeapon",  "event_cur_weapon",   "be", "1=1");
	register_event("SecAmmoVal", "event_sec_ammo_val", "be");
	g_nades   = register_cvar("inf_nades",   "1");
	g_rockets = register_cvar("inf_rockets", "1");
}

public event_cur_weapon(id)
{
	new iWeapon = read_data(2);
	switch (iWeapon) {
		case TFC_WPN_RPG:
		{
			if (get_pcvar_num(g_rockets)) {
				tfc_setweaponammo(get_pdata_cbase(id, m_pActiveItem), 4);
				return PLUGIN_HANDLED;
			}
		}
	}
	return PLUGIN_CONTINUE;
}

public event_sec_ammo_val(id)
{
	if (get_pcvar_num(g_nades)) {
		tfc_setbammo(id, TFC_AMMO_NADE1, 4);
		tfc_setbammo(id, TFC_AMMO_NADE2, 4);
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}
