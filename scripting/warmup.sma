#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <fakemeta>
#include <fun>
#include <cstrike>

#pragma semicolon 1
#pragma ctrlchar '\'

#define OFFSET_CLIPAMMO 51
#define OFFSET_LINUX_WEAPONS 4
#define fm_cs_set_weapon_ammo(%1,%2)    set_pdata_int(%1, OFFSET_CLIPAMMO, %2, OFFSET_LINUX_WEAPONS)

#define m_pActiveItem 373
#define m_rgpPlayerItems_0 376


const NOCLIP_WEAPONS = (1 << CSW_HEGRENADE) | (1 << CSW_SMOKEGRENADE) | (1 << CSW_FLASHBANG) | (1 << CSW_KNIFE ) | (1 << CSW_C4);

enum {
	ammo_338mag   = 1, //  30
	ammo_762mm,        //  90
	ammo_556mm_box,    // 200
	ammo_556mm,        //  90
	ammo_buckshot,     //  32
	ammo_45cp,         // 100
	ammo_57mm,         // 100
	ammo_50e,          //  35
	ammo_357sig,       //  52
	ammo_9mm,          // 120
	ammo_flashbang,    //   2
	ammo_hegrenade,    //   1
	ammo_smokegrenade, //   1
	ammo_c4            //   1
};

static weapon_ammo_info[] = { 0, 30, 90, 200, 90, 32, 100, 100, 35, 52, 120, 2, 1, 1, 1 };

static weapon_info[][] =
{
	{   0, 0,              0                  }, //  0
	{  13, ammo_357sig,    "weapon_p228"      }, //  1
	{   0, 0,              0                  }, //  2
	{  10, ammo_762mm,     "weapon_scout"     }, //  3
	{   0, ammo_hegrenade, "weapon_hegrenade" }, //  4
	{   7, ammo_762mm,     "weapon_xm1014"    }, //  5
	{   0, 0,              0                  }, //  6 - c4
	{  30, ammo_45cp,      "weapon_mac10"     }, //  7
	{  30, ammo_556mm,     "weapon_aug"       }, //  8
	{   0, 0,              0                  }, //  9 - smoke
	{  15, ammo_9mm,       "weapon_elite"     }, // 10
	{  20, ammo_57mm,      "weapon_fiveseven" }, // 11
	{  25, ammo_45cp,      "weapon_ump45"     }, // 12
	{  30, ammo_556mm,     "weapon_sg550"     }, // 13
	{  35, ammo_556mm,     "weapon_galil"     }, // 14
	{  25, ammo_556mm,     "weapon_famas"     }, // 15
	{  12, ammo_45cp,      "weapon_usp"       }, // 16
	{  20, ammo_9mm,       "weapon_glock18"   }, // 17
	{  10, ammo_338mag,    "weapon_awp"       }, // 18
	{  30, ammo_9mm,       "weapon_mp5navy"   }, // 19
	{ 100, ammo_556mm_box, "weapon_m249"      }, // 20
	{   8, ammo_buckshot,  "weapon_m3"        }, // 21
	{  30, ammo_556mm,     "weapon_m4a1"      }, // 22
	{  30, ammo_9mm,       "weapon_tmp"       }, // 23
	{  20, ammo_762mm,     "weapon_g3sg1"     }, // 24
	{   0, 0,              0,                 }, // 25 - flashbang
	{   7, ammo_50e,       "weapon_deagle"    }, // 26
	{  30, ammo_556mm,     "weapon_sg552"     }, // 27
	{  30, ammo_762mm,     "weapon_ak47"      }, // 28
	{   0, 0,              "weapon_knife"     }, // 29
	{  50, ammo_57mm,      "weapon_p90"       }, // 30
	{   0, 0,              0,                 }, // 31 - vest
	{   0, 0,              0,                 }  // 32 - vesthelm
};

new g_enabled = 0,
    g_starttime,
		g_taskid,
		g_time,
		g_buy = 1,
		g_armoury_invisibility = 0,
		g_weapon_settings[32],
		g_ammo_settings[16];

// Setters and getters for some variables

warmup_set(i) { g_enabled = i; }
warmup_get() { return g_enabled; }

warmup_buy_set(i) { g_buy = i; }
warmup_buy_get() { return g_buy; }

warmup_armoury_invis_set(i) { g_armoury_invisibility = i; }
warmup_armoury_invis_get() { return g_armoury_invisibility; }

// cvar global variables

new gcv_warmup,
    gcv_warmup_time,
		gcv_warmup_message,
		gcv_warmup_message_timer,
		gcv_warmup_mode,
		gcv_warmup_mode_hud,
		gcv_warmup_respawn,
		gcv_warmup_respawn_delay,
		gcv_warmup_armoury_invis,
		gcv_warmup_armoury_pick,
		gcv_warmup_weapons,
		gcv_warmup_ammo,
		gcv_warmup_weapon_drop,
		gcv_warmup_weapon_pick;

public plugin_init()
{
	register_plugin("warmup", "0.4", "Andrius Bentkus");

	gcv_warmup               = register_cvar("warmup",               "1"  );
	gcv_warmup_time          = register_cvar("warmup_time",          "40" );
	gcv_warmup_message       = register_cvar("warmup_message",       "1"  );
	gcv_warmup_message_timer = register_cvar("warmup_message_timer", "0"  );
	gcv_warmup_mode          = register_cvar("warmup_mode",          "0"  );
	gcv_warmup_mode_hud      = register_cvar("warmup_mode_hud",      "0"  );
	gcv_warmup_respawn       = register_cvar("warmup_respawn",       "0"  );
	gcv_warmup_respawn_delay = register_cvar("warmup_respawn_delay", "0.2");
	gcv_warmup_armoury_invis = register_cvar("warmup_armoury_invis", "0"  );
	gcv_warmup_armoury_pick  = register_cvar("warmup_armoury_pick",  "1"  );
	gcv_warmup_weapon_drop   = register_cvar("warmup_weapon_drop",   "1"  );
	gcv_warmup_weapon_pick   = register_cvar("warmup_weapon_pick",   "1"  );

	// knife only: 000000000000000000000000000001000
	// knife + ak: 000000000000000000000000000021000
	gcv_warmup_weapons = register_cvar("warmup_weapons", "000000000000000000000000000001000");
	gcv_warmup_ammo = register_cvar("warmup_ammo", "000000000000000");

	register_concmd("warmup_start", "cmd_warmup_start", ADMIN_IMMUNITY, "<warmup time in seconds, 0 for indefinite, blank = warmup_delay>");
	register_concmd("warmup_end",   "cmd_warmup_end",   ADMIN_IMMUNITY);

	register_clcmd("drop", "client_command_drop");

	register_event("TextMsg", "game_start_event", "a", "2&#Game_C");
	register_event("HLTV", "new_round_event", "a", "1=0", "2=0");

	register_message(get_user_msgid("StatusIcon"), "msg_status_icon_message");
	register_message(get_user_msgid("CurWeapon"),  "current_weapon_message" );
	register_message(get_user_msgid("AmmoX"),      "ammox_message"          );

	RegisterHam(Ham_Touch, "weaponbox", "forwad_ham_touch_weaponbox_post", 1);
	RegisterHam(Ham_Touch, "armoury_entity", "forward_ham_touch_armoury_post", 1);
	RegisterHam(Ham_Spawn, "player", "forward_ham_player_spawn_post", 1);
	RegisterHam(Ham_Killed, "player", "forward_ham_player_killed_pre", 0);
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

public client_command_drop(id)
{
	if (warmup_get() && !get_pcvar_num(gcv_warmup_weapon_drop)) return PLUGIN_HANDLED;
	return PLUGIN_CONTINUE;
}

// events, hooks, forwards

public game_start_event()
{
	if (get_pcvar_num(gcv_warmup))
	{
		if (!warmup_get()) start_warmup(get_pcvar_num(gcv_warmup_time));
	}
}

new g_forward_start_frame_id;
public new_round_event()
{
	if (warmup_get() && warmup_armoury_invis_get())
		g_forward_start_frame_id = register_forward(FM_StartFrame, "forward_start_frame");
}

public forward_start_frame()
{
	unregister_forward(FM_StartFrame, g_forward_start_frame_id);
	set_armoury_invisibility(true, true, false);
}

public current_weapon_message(msgid, msgdest, id)
{
	if (!warmup_get()) return PLUGIN_CONTINUE;
	new active = get_msg_arg_int(1);
	new weapon_id = get_msg_arg_int(2);
	if (g_weapon_settings[weapon_id] < 2) return PLUGIN_CONTINUE;
	new clip_ammo = get_msg_arg_int(3);

	new max_clip_ammo = weapon_info[weapon_id][0];
	if (active && !(NOCLIP_WEAPONS & (1 << weapon_id)) && (clip_ammo != max_clip_ammo))
	{
		fm_cs_set_weapon_ammo(get_pdata_cbase(id, m_pActiveItem) , weapon_info[weapon_id][0]);
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}

public ammox_message(msgid, msgdest, id)
{
	if (!warmup_get()) return PLUGIN_CONTINUE;
	new ammo_id = get_msg_arg_int(1);
	new ammount = get_msg_arg_int(2);
	if (!g_ammo_settings[ammo_id]) return PLUGIN_CONTINUE;
	if (ammount < weapon_ammo_info[ammo_id]) {
		set_pdata_int(id, m_rgpPlayerItems_0 + ammo_id, weapon_ammo_info[ammo_id], 5);
		return PLUGIN_HANDLED;
	}
	return PLUGIN_CONTINUE;
}


public forwad_ham_touch_weaponbox_post(victim)
{
	if (warmup_get() && !get_pcvar_num(gcv_warmup_weapon_pick)) return PLUGIN_HANDLED;
	return PLUGIN_CONTINUE;
}

public forward_ham_touch_armoury_post(victim)
{
	if (warmup_get() && !get_pcvar_num(gcv_warmup_armoury_pick)) return PLUGIN_HANDLED;
	return PLUGIN_CONTINUE;
}

public forward_ham_player_killed_pre(victim)
{
	if (warmup_get() && get_pcvar_num(gcv_warmup_respawn))
	{
		set_task(get_pcvar_float(gcv_warmup_respawn_delay), "respawn_player", victim);
	}
	return PLUGIN_CONTINUE;
}

public respawn_player(id)
{
	ExecuteHam(Ham_CS_RoundRespawn, id);
}

public forward_ham_player_spawn_post(id)
{
	if (warmup_get() && is_user_alive(id) && !is_user_bot(id)) handle_player(id);
	return PLUGIN_CONTINUE;
}

public msg_status_icon_message(msgid, msgdest, id)
{
	// Thanks to grimvh2
	// Site: http://forums.alliedmods.net/showpost.php?p=1281450
	if (!warmup_buy_get())
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

new message_timer_task_id = 0;
public start_warmup(time)
{
	if (warmup_get() && g_time) remove_task(g_taskid);
	load_weapon_settings();

	if (message_timer_task_id) {
		remove_task(message_timer_task_id);
		message_timer_task_id = 0;
	}

	warmup_set(true);
	g_starttime = get_systime();
	g_time = time;

	warmup_buy_set(!get_pcvar_num(gcv_warmup_mode));
	warmup_armoury_invis_set(get_pcvar_num(gcv_warmup_armoury_invis));

	set_armoury_invisibility(warmup_armoury_invis_get());

	if (g_time)
	{
		g_taskid = get_free_task_id();
		set_task(float(time), "end_warmup", g_taskid);

		if (get_pcvar_num(gcv_warmup_message_timer))
		{
			message_timer_task_id = get_free_task_id();
			set_task(1.0, "message_timer_task", message_timer_task_id, _, _, "b");
		}
	}
}

public message_timer_task()
{
	new time = g_time - (get_systime() - g_starttime);

	if (time > 0) send_restart_messages(0, time);
	else {
		remove_task(message_timer_task_id);
		message_timer_task_id = 0;
	}
}

public end_warmup()
{
	warmup_set(false);
	warmup_buy_set(true);

	if (warmup_armoury_invis_get()) {

		set_armoury_invisibility(false, false, true);
		warmup_armoury_invis_set(false);

	}
	server_cmd("sv_restart 1");
}

load_weapon_settings()
{
	new sz_weapons[33];
	get_pcvar_string(gcv_warmup_weapons, sz_weapons, sizeof(sz_weapons) -1);

	// get the weapon settings
	for (new i = 0; i < strlen(sz_weapons); i++)
		g_weapon_settings[i] = (sz_weapons[i] - '0') % 3;

	// fill rest with 0
	for (new i = strlen(sz_weapons); i < 32; i++) g_weapon_settings[i] = 0;

	get_pcvar_string(gcv_warmup_ammo, sz_weapons, 16);
	for (new i =0; i < strlen(sz_weapons); i++)
		g_ammo_settings[i] = (sz_weapons[i] - '0') % 2;

	for (new i = strlen(sz_weapons); i < 16; i++) g_ammo_settings[i] = 0;
}

handle_player(id)
{
	if (!warmup_buy_get()) {

		strip_user_weapons(id);
		set_pdata_int(id, 116, 0);

		for (new i = 0; i < sizeof(g_weapon_settings); i++) {
			if (g_weapon_settings[i]) {
				give_item(id, weapon_info[i][2]);
				new ammo_id = weapon_info[i][1];
				cs_set_user_bpammo(id, i, weapon_ammo_info[ammo_id]);
			}
		}

		if (!get_pcvar_num(gcv_warmup_mode_hud)) send_hud_message(id, 0);
	}

	if (get_pcvar_num(gcv_warmup_message)) {
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
	write_string(time > 1 ? "seconds" : "SECOND");
	message_end();

	//TextMsg(77)(AllReliable, 0, 0)(byte:2, string:"#Game_will_restart_in_console", string:"1", string:"SECOND");
	message_begin(id ? MSG_ONE : MSG_ALL, get_user_msgid("TextMsg"), _, id);
	write_byte(2);
	write_string("#Game_will_restart_in_console");
	write_string(sz_buffer);
	write_string(time > 1 ? "seconds" : "SECOND");
	message_end();
}

send_hud_message(id, hide)
{
	message_begin(id ? MSG_ONE : MSG_ALL, get_user_msgid("HideWeapon"), _, id);
	write_byte(hide ? (1<<7) : (1<<5));
	message_end();
}

set_armoury_invisibility(val, visibility = true, touch = true)
{
  static ent = FM_NULLENT;
  while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "armoury_entity")))
	{
    if (val) {
      if (visibility) set_pev(ent, pev_effects, pev(ent, pev_effects) | EF_NODRAW);
      if (touch) set_pev(ent, pev_solid, SOLID_NOT);
    } else {
      if (visibility) set_pev(ent, pev_effects, pev(ent, pev_effects) & ~EF_NODRAW);
      if (touch) set_pev(ent, pev_solid, SOLID_TRIGGER);
    }
  }
}

get_free_task_id()
{
	// 0 is usefull for statements
	for (new i = 1;; i++) if (!task_exists(i)) return i;
	// to get rid of the warning by the compilers
	return 1;
}
