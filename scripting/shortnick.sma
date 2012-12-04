#include <amxmodx>

public plugin_init()
{
	register_plugin("shortnick", "0.1", "Andrius Bentkus");
	register_message(get_user_msgid("SayText"), "message_SayText");
}

handle(name[32], id)
{
	if (strlen(name) > 1) {
		return;
	}
	client_cmd(id, "disconnect");
}

public message_SayText() {
	if (get_msg_args() != 4) {
		return PLUGIN_CONTINUE;
	}

	new buffer[21];
	get_msg_arg_string(2, buffer, 20);
	if (!equal(buffer, "#Cstrike_Name_Change")) {
		return PLUGIN_CONTINUE;
	}

	new id = get_msg_arg_int(1), name[32];
	get_msg_arg_string(4, name, 31);
	handle(name, id);
	return PLUGIN_HANDLED
}

public client_connect(id)
{
	new name[32];
	get_user_name(id, name, 31);
	handle(name, id);
}
