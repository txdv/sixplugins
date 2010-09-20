#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <fakemeta>
#include <fun>
#include <cstrike>

#pragma semicolon 1
#pragma ctrlchar '\'

new g_enabled = 0,
    g_starttime,
		g_taskid,
		g_time;

new gcv_knifedm,
    gcv_knifedm_delay,
		gcv_knifedm_message;

public plugin_init()
{
	register_plugin("knifedm", "0.2", "txdv");

	gcv_knifedm         = register_cvar("knifedm",         "1");
	gcv_knifedm_delay   = register_cvar("knifedm_delay",   "40");
	gcv_knifedm_message = register_cvar("knifedm_message", "1");

	register_concmd("knifedm_start", "cmd_knifedm_start", ADMIN_IMMUNITY, "<knifedm time in seconds, 0 for indefinite, blank = knifedm_delay>");
	register_concmd("knifedm_end", "cmd_knifedm_end", ADMIN_IMMUNITY);

	RegisterHam(Ham_Spawn, "player", "fwHamPlayerSpawnPost", 1);
	register_event("TextMsg", "game_start_event", "a", "2&#Game_C");
}

public cmd_knifedm_start(client, level, cid)
{
	if (!cmd_access(client, level, cid, 0)) return PLUGIN_HANDLED;

	new len = get_pcvar_num(gcv_knifedm_delay);

	if (read_argc() > 1)
	{
		new arg[32];
		read_argv(1, arg, sizeof(arg) -1);
		len = str_to_num(arg);
	}

	new players[32];
	new player_count;

	get_players(players, player_count, "a");

	// start the counter
	start_knifedm(len);
	// and loop through all players, take everything away, send message
	for (new i = 0; i < player_count; i++) clear_player(players[i]);

	return PLUGIN_HANDLED;
}

public cmd_knifedm_end(client, level, cid)
{
	if (!cmd_access(client, level, cid, 0)) return PLUGIN_HANDLED;
	end_knifedm();
	return PLUGIN_HANDLED;
}

public game_start_event()
{
	if (get_pcvar_num(gcv_knifedm))
	{
		if (!knifedm_is_enabled()) start_knifedm(get_pcvar_num(gcv_knifedm_delay));
	}
}

public fwHamPlayerSpawnPost(id)
{
  if (knifedm_is_enabled() && is_user_alive(id) && !is_user_bot(id))
	{
		clear_player(id);
	}
}

public start_knifedm(time)
{
	if (knifedm_is_enabled() && g_time) remove_task(g_taskid);
	knifedm_enable();
	g_starttime = get_systime();
	g_time = time;
	if (g_time)
	{
		g_taskid = get_free_task_id();
		set_task(float(time), "end_knifedm", g_taskid);
	}
}

public end_knifedm()
{
	knifedm_disable();
	server_cmd("sv_restart 1");
}

public knifedm_enable()
{
	g_enabled = 1;
}

public knifedm_disable()
{
	g_enabled = 0;
}

public knifedm_is_enabled()
{
	return g_enabled;
}

public clear_player(id)
{
	strip_user_weapons(id);
	set_pdata_int(id, 116, 0);
	give_item(id, "weapon_knife");
	cs_set_user_money(id, 0);

	if (get_pcvar_num(gcv_knifedm_message))
	{
		// if the time is not indefinite
		if (g_time) send_messages(id, g_time - (get_systime() - g_starttime));
	}
}

public send_messages(id, time)
{
	new sz_buffer[8];
	format(sz_buffer, sizeof(sz_buffer) - 1, "%d", time);

	//TextMsg(77)(AllReliable, 0, 0)(byte:4, string:"#Game_will_restart_in", string:"1", string:"SECOND");
	message_begin(MSG_ONE, get_user_msgid("TextMsg"), _, id);
	write_byte(4);
	write_string("#Game_will_restart_in");
	write_string(sz_buffer);
	write_string("SECOND");
	message_end();

	//TextMsg(77)(AllReliable, 0, 0)(byte:2, string:"#Game_will_restart_in_console", string:"1", string:"SECOND");
	message_begin(MSG_ONE, get_user_msgid("TextMsg"), _, id);
	write_byte(2);
	write_string("#Game_will_restart_in_console");
	write_string(sz_buffer);
	write_string("SECOND");
	message_end();
}

public get_free_task_id()
{
	for (new i = 0;; i++) if (!task_exists(i)) return i;
}
