#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <fun>
#include <cstrike>

new g_enabled = 0;

new gcv_knifedm,
    gcv_knifedm_delay;

public plugin_init()
{
	register_plugin("knifedm", "0.1", "txdv");

	gcv_knifedm       = register_cvar("knifedm",       "1");
	gcv_knifedm_delay = register_cvar("knifedm_delay", "40.0");

	RegisterHam(Ham_Spawn, "player", "fwHamPlayerSpawnPost", 1);
	register_event("TextMsg","start","a","2&#Game_C");
}

public start()
{
	if (get_pcvar_num(gcv_knifedm))
	{
		g_enabled = 1;
		set_task(get_pcvar_float(gcv_knifedm_delay), "start_game")
	}
}

public start_game()
{
	g_enabled = 0;
	server_cmd("sv_restart 1")
}

public fwHamPlayerSpawnPost(id) {
  if (g_enabled && is_user_alive(id) && !is_user_bot(id)) {
		strip_user_weapons(id);
		set_pdata_int(id, 116, 0);
		give_item(id, "weapon_knife");
		cs_set_user_money(id, 0);
	}
}
