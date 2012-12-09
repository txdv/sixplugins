#include <amxmodx>

#pragma semicolon 1
#pragma ctrlchar '\'

#define MAX_PLAYERS 32
#define MAX_PINGS   12

new g_player_tasks[MAX_PLAYERS];
new g_player_pings[MAX_PLAYERS][MAX_PINGS];
new g_player_count[MAX_PLAYERS];

new gcv_hpk_ping;
new gcv_hpk_time;
new gcv_hpk_min;
new gcv_hpk_night;

public plugin_init()
{
	register_plugin("High Ping Kicker", "0.1", "Andrius Bentkus");

	gcv_hpk_ping  = register_cvar("hpk_ping",   "250");
	gcv_hpk_time  = register_cvar("hpk_time",  "10.0");
	gcv_hpk_min   = register_cvar("hpk_min",      "5");
	gcv_hpk_night = register_cvar("hpk_night", "0_10");

	register_concmd("hpk_pings", "hpk_pings", ADMIN_ADMIN, "lists the average ping rate of all players");
}

public client_putinserver(id)
{
	if (is_user_bot(id))
		return PLUGIN_CONTINUE;

	g_player_tasks[id] = get_free_task_id();
	g_player_count[id] = 0;

	new param[1];
	param[0] = id;
	set_task(get_pcvar_float(gcv_hpk_time), "ping_check", g_player_tasks[id], param, 1, "b");
	return PLUGIN_CONTINUE;
}

public client_disconnect(id)
{
	remove_task(g_player_tasks[id]);
}

public ping_check(param[])
{
	new id = param[0];
	new flags = get_user_flags(id);

	if ((flags & ADMIN_IMMUNITY) ||
			(flags & ADMIN_ADMIN)    ||
			(flags & ADMIN_RESERVATION))
		{

		remove_task(g_player_tasks[id]);
		client_print(id, print_chat, "[HPK] Ping checking disabled due to immunity.");
		return;
	}

	new ping, loss;
	get_user_ping(id, ping, loss);

	if (g_player_count[id] < MAX_PINGS) {
		g_player_pings[id][g_player_count[id]] = ping;
		g_player_count[id]++;
	} else {
		for (new i = 0; i < MAX_PINGS - 1; i++) {
			g_player_pings[id][i] = g_player_pings[id][i + 1];
		}
		g_player_pings[id][MAX_PINGS - 1] = ping;
	}

	if (get_pcvar_num(gcv_hpk_min) >= g_player_count[id]) {
		return;
	}

	if (night_time()) {
		return;
	}

	new average = average_ping(id);
	if (average > get_pcvar_num(gcv_hpk_ping)) {
		kick_player(id);
	}
}

average_ping(id)
{
	new sum = 0;
	new count = g_player_count[id];

	if (!count) {
		return 0;
	}

	for (new i = 0; i < count; i++) {
		sum += g_player_pings[id][i];
	}
	new Float:average = float(sum)/float(count);
	return floatround(average);
}

kick_player(id)
{
	new name[32];
	get_user_name(id, name, 31);
	new uid = get_user_userid(id);
	server_cmd("kick #%d \"high ping\"", uid);
	client_print(0, print_chat, "[HPK] %s was disconnected due to high ping!", name);
}


parse_int(src[], start, end)
{
	new val = 0;
	for (new i = start; i < end; i++) {
		val *= 10;
		val += src[i] - '0';
	}
	return val;
}

hours()
{
	new hour[3];
	get_time("%H", hour, 2);
	return str_to_num(hour);
}

find(src[], start, end, ch)
{
	for (new i = start; i < end; i++) {
		if (src[i] == ch) {
			return i;
		}
	}
	return -1;
}

night_time()
{
	new tmp[32];
	get_pcvar_string(gcv_hpk_night, tmp, sizeof(tmp) - 1);
	new length = strlen(tmp);
	new dem = find(tmp, 0, length, '_');
	new start = parse_int(tmp, 0, dem);
	new end = parse_int(tmp, dem + 1, length);
	new now = hours();
	return (now >= start) && (now <= end);
}

public hpk_pings(id)
{
	new players[32], count;
	new authid[32], name[32];
	new cl_on_server[64];
	get_players(players, count);

	format(cl_on_server, 63, "%L", id, "CLIENTS_ON_SERVER");
	console_print(id, "\n%s:\n #  %-16.15s %-20s %-8s %-6s %-s",
	              cl_on_server, "nick", "authid", "userid", "count", "ping");

	for (new i = 0; i < count; i++) {
		new pid = players[i];
		get_user_authid(pid, authid, 31);
		get_user_name  (pid, name,   31);
		console_print(id, "%2d  %-16.15s %-20s #%-7d %-6d %-6d", pid, name, authid,
		              get_user_userid(pid), g_player_count[pid], average_ping(pid));
	}
	return PLUGIN_HANDLED;
}

get_free_task_id()
{
	for (new i = 1;; i++) {
		if (!task_exists(i)) return i;
	}
	return 1;
}

