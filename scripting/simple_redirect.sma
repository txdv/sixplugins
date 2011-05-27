/* AMXX Mod Script
*
* Simple Redirection Plugin for AMXX
* Orginal Code by Sonic (sonic@codet.de)
* Modified and Made for AMXX by BigBaller
*
*  Place following cvars in server.cfg
*
*  amx_rd_maxplayers <x>             // - begin redirection when more the x ppl connected ( 0 = redirect all players )
*  amx_rd_server <ip>                // - redirect to this server
*  amx_rd_serverport <port>          // - redirect server port
*  amx_rd_serverpw <password>        // - password for the amx_rd_server (if needed)
*
*
*  To Disable this plugin set amx_rd_maxppl to 33 or remove from plugins.ini
*/

#include <amxmodx>

public plugin_init() {
	register_plugin("Simple Redirect","1.0", "BigBaller");
	register_cvar("amx_rd_maxplayers", "0");

	register_cvar("amx_rd_server", "");
	register_cvar("amx_rd_serverport", "");
	register_cvar("amx_rd_serverpw", "");
}

public client_connect(id){
	new rd_maxplayers = get_cvar_num("amx_rd_maxplayers");
	new rd_serverport = get_cvar_num("amx_rd_serverport");
	new rd_server[64], rd_serverpw[32];

	get_cvar_string("amx_rd_server", rd_server, 63);
	get_cvar_string("amx_rd_serverpw", rd_serverpw, 31)

	if ( get_playersnum() >= rd_maxplayers) {
		if ( !equal(rd_serverpw,"") )
			client_cmd(id,"echo ^"[AMXX] Simple Redirection - Set Password to %s^";password %s",rd_serverpw,rd_serverpw)
		client_cmd(id,"echo ^"[AMXX] Simple Redirection -  Redirecting to %s:%d^";connect %s:%d",rd_server,rd_serverport,rd_server,rd_serverport)
	}
	return PLUGIN_CONTINUE
}
