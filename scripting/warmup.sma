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
		g_time,
		g_buy = 1;

// Setters and getters for some variables

warmup_enable() { g_enabled = 1; }
warmup_disable() { g_enabled = 0; }
warmup_is_enabled() { return g_enabled; }

warmup_buy_enable() { g_buy = 1; }
warmup_buy_disable() { g_buy = 0; }
warmup_buy_is_enabled() { return g_buy; }

// cvar global variables

new gcv_warmup,
    gcv_warmup_time,
		gcv_warmup_message,
		gcv_warmup_knifeonly,
		gcv_warmup_knifeonly_hud;

public plugin_init()
{
	register_plugin("warmup", "0.3", "Andrius Bentkus");

	gcv_warmup               = register_cvar("warmup",               "1" );
	gcv_warmup_time          = register_cvar("warmup_time",          "40");
	gcv_warmup_message       = register_cvar("warmup_message",       "1" );
	gcv_warmup_knifeonly     = register_cvar("warmup_knifeonly",     "0" );
	gcv_warmup_knifeonly_hud = register_cvar("warmup_knifeonly_hud", "1" );

	register_concmd("warmup_start", "cmd_warmup_start", ADMIN_IMMUNITY, "<warmup time in seconds, 0 for indefinite, blank = warmup_delay>");
	register_concmd("warmup_end",   "cmd_warmup_end",   ADMIN_IMMUNITY);

	RegisterHam(Ham_Spawn, "player", "forward_ham_player_spawn_post", 1);
	register_event("TextMsg", "game_start_event", "a", "2&#Game_C");
	register_message(get_user_msgid("StatusIcon"), "msg_status_icon");
}

// commands

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
	for (new i = 0; i < player_count; i++) handle_player(players[i]);

	return PLUGIN_HANDLED;
}

public cmd_warmup_end(client, level, cid)
{
	if (!cmd_access(client, level, cid, 0)) return PLUGIN_HANDLED;
	end_warmup();
	return PLUGIN_HANDLED;
}

// events, hooks, forwards

public game_start_event()
{
	if (get_pcvar_num(gcv_warmup))
	{
		if (!warmup_is_enabled()) start_warmup(get_pcvar_num(gcv_warmup_time));
	}
}

public forward_ham_player_spawn_post(id)
{
  if (warmup_is_enabled() && is_user_alive(id) && !is_user_bot(id))
	{
		handle_player(id);
	}
}

public msg_status_icon(msgid, msgdest, id)
{
	// Thanks to grimvh2
	// Site: http://forums.alliedmods.net/showpost.php?p=1281450
	if (!warmup_buy_is_enabled())
	{
		static sz_msg[8];
		get_msg_arg_string(2, sz_msg, 7);
		if (equal(sz_msg, "buyzone") && get_msg_arg_int(1))
		{
			set_pdata_int(id, 235, get_pdata_int(id, 235) & ~(1 << 0));
			return PLUGIN_HANDLED;
		}
		return PLUGIN_CONTINUE;
	}
	return PLUGIN_CONTINUE;
}

// custom commands

public start_warmup(time)
{
	if (warmup_is_enabled() && g_time) remove_task(g_taskid);
	warmup_enable();
	g_starttime = get_systime();
	g_time = time;

	if (get_pcvar_num(gcv_warmup_knifeonly)) warmup_buy_disable();

	if (g_time)
	{
		g_taskid = get_free_task_id();
		set_task(float(time), "end_warmup", g_taskid);
	}
}

public end_warmup()
{
	warmup_disable();
	warmup_buy_enable();
	server_cmd("sv_restart 1");
}

handle_player(id)
{
	//if (get_pcvar_num(gcv_warmup_knifeonly))
	if (!warmup_buy_is_enabled())
	{
		strip_user_weapons(id);
		set_pdata_int(id, 116, 0);
		give_item(id, "weapon_knife");
		if (!get_pcvar_num(gcv_warmup_knifeonly_hud)) send_hud_message(id, 0);
	}

	if (get_pcvar_num(gcv_warmup_message))
	{
		// if the time is not indefinite, send a message to inform the player
		if (g_time) send_restart_messages(id, g_time - (get_systime() - g_starttime));
	}
}

send_restart_messages(id, time)
{
	new sz_buffer[8];
	format(sz_buffer, sizeof(sz_buffer) - 1, "%d", time);

	//TextMsg(77)(AllReliable, 0, 0)(byte:4, string:"#Game_will_restart_in", string:"1", string:"SECOND");
	message_begin(id ? MSG_ONE : MSG_ALL, get_user_msgid("TextMsg"), _, id);
	write_byte(4);
	write_string("#Game_will_restart_in");
	write_string(sz_buffer);
	write_string("SECOND");
	message_end();

	//TextMsg(77)(AllReliable, 0, 0)(byte:2, string:"#Game_will_restart_in_console", string:"1", string:"SECOND");
	message_begin(id ? MSG_ONE : MSG_ALL, get_user_msgid("TextMsg"), _, id);
	write_byte(2);
	write_string("#Game_will_restart_in_console");
	write_string(sz_buffer);
	write_string("SECOND");
	message_end();
}

send_hud_message(id, hide)
{
	message_begin(id ? MSG_ONE : MSG_ALL, get_user_msgid("HideWeapon"), _, id);
	write_byte(hide ? (1<<7) : (1<<5));
	message_end();
}

get_free_task_id()
{
	for (new i = 0;; i++) if (!task_exists(i)) return i;
	// to get rid of the warning by the compilers
	return 0;
}
