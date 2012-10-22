#include <amxmod>

#define MINIMAL_SCORE -2

new msgid;

public plugin_init()
{
  register_plugin("Negative Score Kicker", "1.0", "Andrius Bentkus");
  msgid = get_user_msgid("ScoreInfo");
  register_message(msgid, "msg_ScoreInfo");
  return PLUGIN_CONTINUE;
}

kickPlayer(id)
{
    new name[32];
    get_user_name(id, name, sizeof(name) - 1);
    client_cmd(id, "echo ^"Sorry but you don't have a high enough score^"; disconnect");
    client_print(0, print_chat, "%s was disconnected due to having a negative score!", name);
    return PLUGIN_CONTINUE;
}

public msg_ScoreInfo( )
{
  new id     = get_msg_arg_int(1);
  new score  = get_msg_arg_int(2);
  if (score <= MINIMAL_SCORE) {
    kickPlayer(id);
  }
  return PLUGIN_CONTINUE;
}
