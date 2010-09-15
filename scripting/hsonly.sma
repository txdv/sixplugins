#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN "HeadShot Only"
#define VERSION "1.2a"
#define AUTHOR "Dores"

#define USAGE	" 1 (on) or 0 (off)"

new HamHook:fw_TraceAttack;
new g_iMaxPlayers;
new p_knife, p_team[3];

_Un_RegisterHamForwards(on = 0)
{
	on ? EnableHamForward(fw_TraceAttack) : DisableHamForward(fw_TraceAttack);
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	fw_TraceAttack = RegisterHam(Ham_TraceAttack, "player", "Forward_TraceAttack");
	register_clcmd("amx_hsonly", "Cmd_ToggleHS", ADMIN_ADMIN, USAGE);
	g_iMaxPlayers = get_maxplayers();
	p_knife = register_cvar("hsonly_knife", "0");
	p_team[1] = register_cvar("hsonly_t", "1");
	p_team[2] = register_cvar("hsonly_ct", "1");
}

public Forward_TraceAttack(id, attacker, Float:dmg, Float:dir[3], tr, dmgbit)
{
	if(id != attacker && get_tr2(tr, TR_iHitgroup) != HIT_HEAD && get_pcvar_num(p_team[get_user_team(id)]))
	{
		if(1 <= attacker <= g_iMaxPlayers)
		{
			if(!get_pcvar_num(p_knife) && get_user_weapon(attacker) == CSW_KNIFE)
			{
				return HAM_IGNORED;
			}
			
			return HAM_SUPERCEDE;
		}
	}
	
	return HAM_IGNORED;
}

public Cmd_ToggleHS(id)
{
	if(read_argc() < 2)
	{
		console_print(id, USAGE);
		return PLUGIN_HANDLED;
	}
	
	static arg[2] ; read_argv(1, arg, charsmax(arg));
	static val ; val = str_to_num(arg);
	_Un_RegisterHamForwards(val);
	client_print(0, print_chat, "[AMXX] HeadShot Only mode is %s!", val ? "ON" : "OFF");
	return PLUGIN_HANDLED;
}

public client_putinserver(id)
{
	set_hudmessage(42, 255, 42, 0.11, 0.22, 0, 6.0, 12.0);
	show_hudmessage(id, "This server is using the HS Only plugin^nVersion %s", VERSION);
}
