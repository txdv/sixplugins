#include <amxmodx>
#include <amxmisc>
#include <sqlx>

#pragma semicolon 1
#pragma ctrlchar '\'

#define PLUGIN "Private message"
#define VERSION "0.1"
#define AUTHOR "Andrius Bentkus"

#define MESSAGE_SOUND "buttons/bell1.wav"
#define read_sargv(%1,%2) read_argv(%1, %2, sizeof(%2) -1)

new g_MsgTutor, g_MsgTutClose;
new Handle:g_sqltuple, Handle:g_sqlcon;
new g_psprefix[10];

new gcv_hostname,
    gcv_username,
    gcv_password,
    gcv_database,
    gcv_prefix;

static czero_files[][] = {
	// the borders
	"gfx/career/round_corner_nw.tga",
	"gfx/career/round_corner_se.tga",
	"gfx/career/round_corner_ne.tga",
	"gfx/career/round_corner_sw.tga",
	// the icons
	"gfx/career/icon_i.tga",
	"gfx/career/icon_skulls.tga",
	// the resource files neede to set it up propperly
	"resource/UI/tutortextwindow.res",
	"resource/tutorscheme.res"
};

// a struct to handle
// weather a current player is showing a message or not
// basically what it is a resource manager:
// if the value is 1, you can't touch this player with message questions
// if it the value is 0, you can set it to 1 and do your stuff,
// no one will interfare
static message[32];

public plugin_precache()
{
	precache_sound(MESSAGE_SOUND);

	for (new i = 0; i < sizeof(czero_files); i++)
	{
		precache_generic(czero_files[i]);
	}
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR);

	g_MsgTutor    = get_user_msgid("TutorText");
	g_MsgTutClose = get_user_msgid("TutorClose");

	register_srvcmd("cmd_tutor_text",  "cmd_tutor_text" );
	register_srvcmd("cmd_tutor_close", "cmd_tutor_close");

	// the resource is taken by all at the begining, only players connect they get the resources
	for (new i = 0; i < sizeof(message); i++) message[i] = 1;
	set_task(2.0, "message_check_task");

	gcv_hostname = register_cvar("pm_hostname", "127.0.0.1");
	gcv_username = register_cvar("pm_username", "");
	gcv_password = register_cvar("pm_password", "");
	gcv_database = register_cvar("pm_database", "");
	gcv_prefix = register_cvar("pm_prefix", "ps_");
}

public plugin_cfg()
{
	new hostname[32],
	    username[32],
	    password[32],
	    database[32];

	server_exec();

	get_pcvar_string(gcv_hostname, hostname, sizeof(hostname) -1);
	get_pcvar_string(gcv_username, username, sizeof(username) -1);
	get_pcvar_string(gcv_password, password, sizeof(password) -1);
	get_pcvar_string(gcv_database, database, sizeof(database) -1);
	get_pcvar_string(gcv_prefix, g_psprefix, sizeof(g_psprefix) -1);

	g_sqltuple = SQL_MakeDbTuple(hostname, username, password, database);

	new errcode;
	new err[512];

	g_sqlcon = SQL_Connect(g_sqltuple, errcode, err, sizeof(err) -1);
	if (errcode)
	{
		server_print("Couldn't connect to the database: %s", err);
	}
}

public plugin_end()
{
	SQL_FreeHandle(g_sqltuple);
	SQL_FreeHandle(g_sqlcon);
}

// TODO: client_authorized can be invoked AFTER client_putinserver
public client_putinserver(id)
{
	new cache[512];
	new authid[32];
	new dataid[1];
	dataid[0] = id;
	get_user_authid(id, authid, sizeof(authid) -1);

	formatex(cache, sizeof(cache) -1, "SELECT id FROM loads WHERE uniqueid = '%s'", authid);
	//log_amx("load query: %s", cache);
	SQL_ThreadQuery(g_sqltuple, "handle_load", cache, dataid, 1);
}

public handle_load(failstate, Handle:query, error[], errorcode, dataid[])
{
	new id = dataid[0];
	if (failstate)
	{
		log_amx("SQL Error: %s (%d)", error, errorcode);
		return PLUGIN_HANDLED;
	}

	if (!SQL_MoreResults(query))
	{
		new authid[32];
		get_user_authid(id, authid, sizeof(authid) -1);

		if (strlen(authid) > 0) // the user still exists
		{
			new cache[512];
			formatex(cache, sizeof(cache) -1, "INSERT INTO loads (uniqueid, loaddate) VALUES ('%s', NOW())", authid);
			//log_amx("load query: %s", cache);
			SQL_ThreadQuery(g_sqltuple, "handle_load_missing", cache);
		}
	}
	else
	{
		// we can let the messaging system take this one into accout
		message[id] = 0;
	}
	return PLUGIN_HANDLED;
}

public handle_load_missing(failstate, Handle:query, error[], errorcode, dataid[])
{
	new id = dataid[0];
	if (failstate)
	{
		log_amx("SQL Error: %s (%d)", error, errorcode);
		return PLUGIN_HANDLED;
	}
	client_cmd(id, "_restart");
	return PLUGIN_HANDLED;
}

static cache[1024];
public message_check_task(id)
{
	cache[0] = 0; // make the string empty
	new precache[512];

	// AND (uniqueid = '..' OR uniqueid = '..' ....)
	new first = 1;
	for (new id = 0; id < sizeof(message); id++)
	{
		if (!message[id])
		{
			new authid[32];
			get_user_authid(id, authid, sizeof(authid) -1);
			if (first)
			{
				formatex(precache, sizeof(precache)-1, "target = '%s'", authid);
				first = 0;
			}
			else
				formatex(precache, sizeof(precache)-1, "%s OR target = '%s'", cache, authid);
		}
	}
	if (!first)
	{
		// there was at least one playa, let's make an sql call

		formatex(cache, sizeof(cache) -1, "SELECT *, (SELECT name FROM %splr_profile WHERE uniqueid = t1.sender) as name FROM messages t1 INNER JOIN (SELECT target, min(id) as id from messages WHERE showdate IS NULL AND (%s) GROUP BY target) t2 ON t1.id = t2.id", g_psprefix, precache);

		//log_amx("query: %s", cache);
		SQL_ThreadQuery(g_sqltuple, "message_check_sql", cache);
	}
	else
		set_task(2.0, "message_check_task");
	return PLUGIN_HANDLED;
}

public message_check_sql(failstate, Handle:query, error[], errorcode)
{
	if (failstate)
	{
		log_amx("SQL Error: %s (%d)", error, errorcode);
		return PLUGIN_HANDLED;
	}

	new precache[512];

	new first = 1;
	if (SQL_MoreResults(query))
	{
		while (SQL_MoreResults(query))
		{
			new Float:duration;
			new authid[32];

			new msgid = SQL_ReadResult(query, 0);
			SQL_ReadResult(query, 2, authid, sizeof(authid) -1);
			new type = SQL_ReadResult(query, 3);
			SQL_ReadResult(query, 4, cache, sizeof(cache) -1);
			SQL_ReadResult(query, 5, duration);

			new id = find_player("c", authid);

			if (first)
			{
				formatex(precache, sizeof(precache) -1, "%d", msgid);
				first = 0;
			}
			else
				formatex(precache, sizeof(precache) -1, "%s, %d", cache, msgid);

			// take the resource
			message[id] = 1;
			tutor_text(id, type, cache);

			new args[1];
			args[0] = id;
			set_task(duration, "message_duration_task", _, args, 1);

			SQL_NextRow(query);
		}

		formatex(cache, sizeof(cache) -1, "UPDATE messages SET showdate = NOW() WHERE id IN (%s)", precache);

		SQL_ThreadQuery(g_sqltuple, "message_showdate_update", cache);

		set_task(2.0, "message_check_task");
	}
	else
		set_task(2.0, "message_check_task");
	return PLUGIN_HANDLED;
}

public message_duration_task(args[])
{
	new id = args[0];
	tutor_close(id);
	// now everyone can use this again
	message[id] = 0;
}

public message_showdate_update(failstate, Handle:query, error[], errorcode)
{
	if (failstate)
	{
		log_amx("SQL Error: %s (%d)", error, errorcode);
		return PLUGIN_HANDLED;
	}
	return PLUGIN_HANDLED;
}

public cmd_tutor_text()
{
	if (read_argc() < 4)
	{
		server_print("cmd_tutor_text <#id or nick> <color> <message>");
		return PLUGIN_HANDLED;
	}
	new text[256];

	read_sargv(1, text);
	new player = cmd_target(0, text, CMDTARGET_ALLOW_SELF | CMDTARGET_NO_BOTS);
	if (!player)
	{
		server_print("Couldn't find target player");
		return PLUGIN_HANDLED;
	}

	read_sargv(2, text);
	new color = str_to_num(text);

	read_sargv(3, text);

	replace_all(text, sizeof(text), "^n", "\n");
	tutor_text(player, color, text);
	return PLUGIN_HANDLED;
}

public cmd_tutor_close()
{
	if (read_argc() < 2)
	{
		server_print("cmd_tutor_text <#id or nick> <color> <message>");
		return PLUGIN_HANDLED;
	}

	new text[256];
	read_sargv(1, text);

	new player = cmd_target(0, text, CMDTARGET_ALLOW_SELF | CMDTARGET_NO_BOTS);

	if (!player)
	{
		server_print("Couldn't find target player");
		return PLUGIN_HANDLED;
	}

	tutor_close(player);
	return PLUGIN_HANDLED;
}

stock tutor_text(id, color, text[])
{
	message_begin((id == 0 ? MSG_ALL : MSG_ONE), g_MsgTutor, _, id);

	write_string(text);

	write_byte (0);
	write_short(0);
	write_short(0);
	write_short(1 << color);

	message_end();
}

stock tutor_close(id)
{
	message_begin((id == 0? MSG_ALL : MSG_ONE), g_MsgTutClose, _, id);
	message_end();
}
