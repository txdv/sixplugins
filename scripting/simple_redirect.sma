/* AMXX Mod Script
*
* Simple Redirection Plugin for AMXX
* Orginal Code by Sonic (sonic@codet.de)
* Modified and Made for AMXX by BigBaller
* Modified by Andrius Bentkus
*
*  Place following cvars in server.cfg
*
*  amx_rd_maxplayers <x>                 // begin redirection when more the x ppl connected ( 0 = redirect all players )
*  amx_rd_server <ip:port>;<ip:port>;... // redirect to this server
*
*  To Disable this plugin remove from plugins.ini
*/

#include <amxmodx>

new current_server = 0;
new server_count;

public plugin_init() {
	register_plugin("Simple Redirect", "1.0", "Andrius Bentkus");
	register_cvar("amx_srd_maxplayers", "0");
	register_cvar("amx_srd_server", "");

	server_count = count_servers();

	register_srvcmd("amx_srd_test", "amx_srd_test", 0, "test the next server");
}

public client_connect(id) {

	new srd_maxplayers = get_cvar_num("amx_srd_maxplayers");

	if (get_playersnum() >= srd_maxplayers) {
		new server[128];
		copy(server, sizeof(server) - 1, get_next_server());
		client_cmd(id,"echo ^"[AMXX] Simple Redirection -  Redirecting to %s^";connect %s", server, server);
	}

	return PLUGIN_CONTINUE
}

get_next_server()
{
	new srd_server[512];
	new sz_buffer[512];
	new sz_server[128];

	get_cvar_string("amx_srd_server", srd_server, 511);

	for (new i = 0; i < server_count; i++) {
		strtok(srd_server, sz_server, sizeof(srd_server) - 1, sz_buffer, sizeof(sz_buffer) - 1, ';');
		copy(srd_server, sizeof(srd_server), sz_buffer);

		if (current_server == i) {
			break;
		}
	}

	current_server = (current_server + 1) % server_count;

	return sz_server;
}

public amx_srd_test() {
	server_print("%s (%d of %d)", get_next_server(), current_server + 1, server_count);
}

count_servers() {
	new srd_server[512];
	new sz_buffer[512];
	new sz_server[128];

	new i = 0;

	get_cvar_string("amx_srd_server", srd_server, 511);

	while (true) {
		if (!strlen(srd_server)) {
			break;
		}

		strtok(srd_server, sz_server, sizeof(srd_server) - 1, sz_buffer, sizeof(sz_buffer) - 1, ';');
		copy(srd_server, sizeof(srd_server), sz_buffer);
		i++;
	}

	return i;
}
