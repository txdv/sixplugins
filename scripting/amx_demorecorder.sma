/****************************************/
/*                                      */
/*	Auto Demo Recorder                  */
/*	by IzI                              */
/*  feat ToXedVirus (2010)              */
/*					                            */
/****************************************/

#include <amxmodx>
#pragma semicolon 1

new g_invalid_chars[] =  { '/', '\', ':', '*', '?', '<', '>', '|', ' ' };

new gcv_demo,
	  gcv_demo_mode,
		gcv_demo_steamid,
		gcv_demo_start_time,
		gcv_demo_name,
		gcv_demo_prefix;

public plugin_init()
{
	register_plugin("Auto Demo Recorder", "1.5", "IzI");

	gcv_demo						= register_cvar("amx_demo",					"1");
	gcv_demo_mode				= register_cvar("amx_demo_mode",		"0");
	gcv_demo_steamid		= register_cvar("amx_demo_steamid",	"0");
	// Minimum start time is 15 and is automatically set to if lesser.
	// I recommend to use the default settings
	gcv_demo_start_time	=	register_cvar("amx_demo_start_time",	"15");
	gcv_demo_name				= register_cvar("amx_demo_name",		"Autorecorded demo");
	gcv_demo_prefix			= register_cvar("amx_demo_prefix",	"AMXX");

	// load languages
	register_dictionary("demorecorder.txt");
}

public client_putinserver( id )
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
	if(!is_user_connected(id) || get_pcvar_num(gcv_demo) != 1)
		return;

	// Getting time, client SteamID, server's name, server's ip with port.
	new szSName[128], szINamePrefix[64], szTimedata[9];
	new iUseIN = get_pcvar_num(gcv_demo_steamid);
	new iDMod = get_pcvar_num(gcv_demo_mode);
	get_pcvar_string( gcv_demo_prefix, szINamePrefix, 63 );
	get_time ( "%H:%M:%S", szTimedata, 8 );

	switch( iDMod ) {
		case 0: get_pcvar_string( gcv_demo_name, szSName, 127 );
		case 1: get_user_ip( 0, szSName, 127, 0 );
		case 2: get_user_name( 0, szSName, 127 );
	}

	if( iUseIN ) {
		new szCID[32];
		get_user_authid( id, szCID, 31 );
		format( szSName, 127, "[%s]%s", szCID, szSName );
	}

	// Replacing signs.
	new i = 0;
	while (i < sizeof(g_invalid_chars))
	{
		replace_all(szSName, 127, g_invalid_chars[i], "-");
		i++;
	}

	// Displaying messages.
	client_cmd( id, "stop; record ^"%s^"", szSName );
	client_print( id, print_chat, "[%s] %L ^"%s.dem^"", szINamePrefix, LANG_PLAYER, "RECORDINGIN", szSName );
	client_print( id, print_chat, "[%s] %L", szINamePrefix, LANG_PLAYER, "RECORDINGAT", szTimedata );
}
