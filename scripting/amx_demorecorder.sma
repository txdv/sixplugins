/****************************************/
/*                                      */
/*      Auto Demo Recorder              */
/*      by IzI                          */
/*      feat ToXedVirus (2010)          */
/*                                      */
/****************************************/

#pragma semicolon 1

#include <amxmodx>
#include <amxmisc>

#define get_pcvar_string2(%1,%2) get_pcvar_string(%1, %2, sizeof(%2) -1)
#define get_cvar_string2(%1,%2) get_cvar_string(%1, %2, sizeof(%2) -1)

new g_invalid_chars[] =  { '/', '\', ':', '*', '?', '<', '>', '|', ' ' };

new gcv_demo,
    gcv_demo_start_time,
    gcv_demo_msg,
    gcv_demo_msg_prefix,
    gcv_demo_prefix,
    gcv_demo_log,
		gcv_demo_admin_immunity;

public plugin_init()
{
	register_plugin("Auto Demo Recorder", "1.5.1", "IzI");

	// Minimum start time is 15 and is automatically set to if lesser.
	// I recommend to use the default settings
	gcv_demo_start_time     =	register_cvar("amx_demo_start_time",  "15");
	gcv_demo                = register_cvar("amx_demo",                   "1");
	gcv_demo_msg            = register_cvar("amx_demo_msg",               "1");
	gcv_demo_msg_prefix     = register_cvar("amx_demo_msg_prefix",        "AMXX");
	gcv_demo_prefix         = register_cvar("amx_demo_prefix",            "AMXX");
	gcv_demo_log            = register_cvar("amx_demo_log",               "1");
	gcv_demo_admin_immunity = register_cvar("amx_demo_admin_immunity",    "0");

	// load languages
	register_dictionary("demorecorder.txt");
}

public client_putinserver(id)
{
	if (get_pcvar_num(gcv_demo)) {
		new Float:delay = get_pcvar_float(gcv_demo_start_time);
		if (delay < 5)
			set_pcvar_float(gcv_demo_start_time, (delay = 5.0));

		set_task(delay, "Record", id);
	}
}

public Record(id)
{
	if(!is_user_connected(id) || !get_pcvar_num(gcv_demo))
		return;

	if (get_pcvar_num(gcv_demo_admin_immunity) && is_user_admin(id))
		return;

	new sz_demoname    [256],
	    sz_demo_prefix [64],
	    sz_hostname    [64],
	    sz_nickname    [32],
	    sz_authid      [32],
	    sz_mapname     [64],
	    sz_time        [9],
	    sz_date        [11];

	get_pcvar_string2(gcv_demo_prefix, sz_demo_prefix);
	get_cvar_string2("hostname", sz_hostname);
	get_user_name(id, sz_nickname, sizeof(sz_nickname) -1);
	get_user_authid(id, sz_authid, sizeof(sz_authid) -1);
	get_mapname(sz_mapname, sizeof(sz_mapname) -1);
	get_time("%H:%M:%S", sz_time, sizeof(sz_time) -1);
	get_time("%d-%m-%Y", sz_date, sizeof(sz_date) -1);


	formatex(sz_demoname, sizeof(sz_demoname) -1, "%s_%s_%s_%s_%s_%s_%s",
	         sz_demo_prefix,
	         sz_hostname,
	         sz_nickname,
	         sz_authid,
	         sz_mapname,
	         sz_time,
	         sz_date);

	// Replacing signs.
	new i = 0;
	while (i < sizeof(g_invalid_chars))
	{
		replace_all(sz_demoname, 127, g_invalid_chars[i], "-");
		i++;
	}

	// Displaying messages.
	if (get_pcvar_num(gcv_demo_msg)) {
		new sz_demo_msg_prefix[64];
		get_pcvar_string2(gcv_demo_msg_prefix, sz_demo_msg_prefix);

		client_cmd(id, "stop; record ^"%s^"", sz_demoname);
		client_print(id, print_chat, "[%s] %L ^"%s.dem^"", sz_demo_msg_prefix, LANG_PLAYER, "RECORDINGIN", sz_demoname);
		client_print(id, print_chat, "[%s] %L"           , sz_demo_msg_prefix, LANG_PLAYER, "RECORDINGAT", sz_time);
	}

	if (get_pcvar_num(gcv_demo_log)) {
		log_amx("^"%s<%d><%s><>^" started recording demo named ^"%s.dem^"", sz_nickname, get_user_userid(id), sz_authid, sz_demoname);
	}
}
