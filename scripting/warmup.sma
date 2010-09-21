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

new gcv_warmup,
    gcv_warmup_time,
		gcv_warmup_message,
		gcv_warmup_knifeonly,
		gcv_warmup_dm,
		gcv_warmup_dm_time;

public plugin_init()
{
	register_plugin("warmup", "0.3", "Andrius Bentkus");

	gcv_warmup           = register_cvar("warmup",           "1"  );
	gcv_warmup_time      = register_cvar("warmup_time",      "40" );
	gcv_warmup_message   = register_cvar("warmup_message",   "1"  );
	gcv_warmup_knifeonly = register_cvar("warmup_knifeonly", "0"  );
	gcv_warmup_dm        = register_cvar("warmup_dm",        "0"  );
	gcv_warmup_dm_time   = register_cvar("warmup_dm_time",   "0.2");

	register_concmd("warmup_start", "cmd_warmup_start", ADMIN_IMMUNITY, "<warmup time in seconds, 0 for indefinite, blank = warmup_delay>");
	register_concmd("warmup_end", "cmd_warmup_end", ADMIN_IMMUNITY);

	register_event("TextMsg", "game_start_event", "a", "2&#Game_C");
	RegisterHam(Ham_Spawn, "player", "forward_ham_player_spawn_post", 1);
	RegisterHam(Ham_Killed, "player", "forward_ham_player_killed_pre", 0);
}

public cmd_warmup_start(client, level, cid)
{
	if (!cmd_access(client, level, cid, 0)) return PLUGIN_HANDLED;

	new len = get_pcvar_num(gcv_warmup_time);

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
	start_warmup(len);
	// and loop through all players, take everything away, send message
	for (new i = 0; i < player_count; i++) clear_player(players[i]);

	return PLUGIN_HANDLED;
}

public cmd_warmup_end(client, level, cid)
{
	if (!cmd_access(client, level, cid, 0)) return PLUGIN_HANDLED;
	end_warmup();
	return PLUGIN_HANDLED;
}

public game_start_event()
{
	if (get_pcvar_num(gcv_warmup))
	{
		if (!warmup_is_enabled()) start_warmup(get_pcvar_num(gcv_warmup_time));
	}
}

public forward_ham_player_killed_pre(victim)
{
	if (get_pcvar_num(gcv_warmup_dm))
	{
		set_task(get_pcvar_float(gcv_warmup_dm_time), "respawn_player", victim);
	}
}

public respawn_player(id)
{
	ExecuteHam(Ham_CS_RoundRespawn, id);
}

public forward_ham_player_spawn_post(id)
{
  if (warmup_is_enabled() && is_user_alive(id) && !is_user_bot(id))
	{
		clear_player(id);
	}
}

public start_warmup(time)
{
	if (warmup_is_enabled() && g_time) remove_task(g_taskid);
	warmup_enable();
	g_starttime = get_systime();
	g_time = time;
	if (g_time)
	{
		g_taskid = get_free_task_id();
		set_task(float(time), "end_warmup", g_taskid);
	}
}

public end_warmup()
{
	warmup_disable();
	server_cmd("sv_restart 1");
}

warmup_enable()
{
	g_enabled = 1;
}

warmup_disable()
{
	g_enabled = 0;
}

warmup_is_enabled()
{
	return g_enabled;
}

clear_player(id)
{
	if (get_pcvar_num(gcv_warmup_knifeonly))
	{
		strip_user_weapons(id);
		set_pdata_int(id, 116, 0);
		give_item(id, "weapon_knife");
		cs_set_user_money(id, 0);
	}

	if (get_pcvar_num(gcv_warmup_message))
	{
		// if the time is not indefinite
		if (g_time) send_messages(id, g_time - (get_systime() - g_starttime));
	}
}

send_messages(id, time)
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

get_free_task_id()
{
	for (new i = 0;; i++) if (!task_exists(i)) return i;
}
