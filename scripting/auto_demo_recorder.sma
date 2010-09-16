/*
*  AMX Mod X Script
*
*  F4RR3LLs Auto Demo Recorder
*
*  Credits: Pr4yer
*
*/

//#pragma semicolon 1

#include <amxmodx>
#include <amxmisc>

new
	gpc_startrecordtime,
	gpc_demoprefix,
	gpc_info,
	gpc_infotime,
	gpc_menu;

new idofmenu[] = "idofmenu";

enum ChatColor
{
	CHATCOLOR_NORMAL = 1,
	CHATCOLOR_GREEN,
	CHATCOLOR_TEAM_COLOR,
	CHATCOLOR_GREY,
	CHATCOLOR_RED,
	CHATCOLOR_BLUE,
};

new g_TeamName[][] =
{
	"",
	"TERRORIST",
	"CT",
	"SPECTATOR"
};

new g_msgSayText;
new g_msgTeamInfo;

new LOGNAME[128];
new MapName[32];

new const g_invalid_chars[] =  { '/', '\', ':', '*', '?', '<', '>', '|', ' ' };

public plugin_init()
{
	register_plugin("Auto Demo Recorder", "2.2", "F4RR3LL, txdv");

	register_menucmd(register_menuid(idofmenu), MENU_KEY_1|MENU_KEY_2, "showMenu");

	gpc_startrecordtime = register_cvar("adr_startrecordtime"	, "180" );
	gpc_demoprefix      = register_cvar("adr_demoprefix"			, "demo");
	gpc_info			      = register_cvar("adr_info"						, "1"		);
	gpc_infotime	      = register_cvar("adr_demoprefix"			, "600"	);
	gpc_menu            = register_cvar("adr_menu"						, "1"   );

	g_msgSayText = get_user_msgid("SayText");
	g_msgTeamInfo = get_user_msgid("TeamInfo");
}

new monthyear[12];

public plugin_cfg()
{
	set_task(get_pcvar_float(gpc_info), "adverd", 41, "", 0, "b");

	get_mapname(MapName, sizeof MapName -1);


	const LEN = 128;

	new logsdir[LEN];
	get_localinfo("amxx_logs", logsdir, LEN -1);

	new papka[LEN];
	format(papka, LEN -1, "recorded_demos");

	new direxists[LEN];
	formatex(direxists, LEN -1, "/%s/%s", logsdir, papka);
	if(!dir_exists(direxists))
		mkdir(direxists);

	get_time("%d-%m-%Y", monthyear, sizeof monthyear -1);

	new fail[LEN];
	formatex(fail, LEN -1, "%s.txt", monthyear);

	formatex(LOGNAME, LEN -1, "%s/%s", direxists, fail);

	if(!file_exists(LOGNAME))
		write_file(LOGNAME, "");
}

public client_authorized(id)
{
	client_cmd(id, "stop");
}

public showInfo()
{
	static pl[32], n, p, i;
	get_players(pl, n);
	for(i=0;i<n;i++)
	{
		p = pl[i];
		colorChat(p, CHATCOLOR_RED, "^x04[INFO]^x03 A demo is being recorded in your cstrike directory while you are playing");
	}
}

new bool:najalknopky[33] = { false, ... };

public client_putinserver(id)
{
	if(!is_user_bot(id) && !is_user_hltv(id))
	{
		najalknopky[id] = false;

		remove_task(id+500);
		set_task(get_pcvar_float(gpc_startrecordtime), "prerecDEMO", id+500);
	}
}

public checkKnopka(id)
{
	id -= 500;

	if(!is_user_connected(id))
		return;

	if(!najalknopky[id])
		recordDemo(id, 0);
}

public prerecDEMO(id)
{
	id -= 500;

	if(!is_user_connected(id))
		return;

	if(get_pcvar_num(gpc_menu))
	{
		new menu_text[256], len;
		len =  formatex(menu_text,      sizeof(menu_text) -1,			 "     \yThis server forces you to record a demo on your computer^n");
		len += formatex(menu_text[len], sizeof(menu_text) -1 -len, "     \vYou can either accept this, or leave^n^n");
		len += formatex(menu_text[len], sizeof(menu_text) -1 -len, "     \w1. \rYes, I accept it, I want to stay.^n");
		len += formatex(menu_text[len], sizeof(menu_text) -1 -len, "     \w2. \rNo, I don't like being forced to record, I will leave.");

		show_menu(id, (MENU_KEY_1|MENU_KEY_2), menu_text, 10, idofmenu);
		set_task(11.0, "checkKnopka", id+500);
	}
	else
	{
		recordDemo(id, 0);
	}
}

public showMenu(id, key)
{
	if ((0 <= key) || (key <= 1)) recordDemo(id, key);
}

public recordDemo(id, mode)
{
	static nickname[32], ip[16], stim[35];
	get_user_name(id, nickname, sizeof nickname -1);
	get_user_ip(id, ip, sizeof ip -1, 1);
	get_user_authid(id, stim, sizeof stim -1);

	if(mode == 1)
	{
		najalknopky[id] = false;

		remove_task(id+500);

		log_to_file(LOGNAME, "[Player: %s][SteamID: %s - IP: %s] [Demoname: Player was kicked]", nickname, stim, ip);

		server_cmd("kick #%d  You can't game at this server, without recording demo.", get_user_userid(id));

		return;
	}

	najalknopky[id] = true;

	static hostname[64], vremia[9], hash[34], demoname[350], neyznavod[32];

	get_cvar_string("hostname", hostname, sizeof hostname -1);
	get_time("%H:%M:%S", vremia, sizeof vremia -1);
	get_pcvar_string(gpc_infotime, neyznavod, sizeof neyznavod -1);
	md5(demoname, hash);


	formatex(demoname, sizeof demoname -1, "%s_%s_%s_%s_%s_%s_%s_MD5-%s.dem", neyznavod, hostname, nickname, ip, MapName, vremia, monthyear, hash);
	new i = 0;
	// go through all the invalid chars and themove them from our demo string
	while (i < sizeof(g_invalid_chars))
		while(replace(demoname, sizeof(demoname) -1, g_invalid_chars[i], "-")) { }

	client_cmd(id, "stop;wait;wait;record ^"%s.a^"", demoname);

	set_hudmessage(255, 0, 0, 0.02, 0.18, 0, 6.0, 5.0);
	show_hudmessage(id, "Beside you to write demo!^n^n%s", demoname);

	log_to_file(LOGNAME, "[Player: %s][SteamID: %s - IP: %s] [Demoname: %s]", nickname, stim, ip, demoname);
}

// colorChat implemention from now on

colorChat(id, ChatColor:color, const msg[], {Float,Sql,Result,_}:...)
{
	new team, index, MSG_Type;
	new bool:teamChanged = false;
	static message[192];

	switch(color)
	{
		case CHATCOLOR_NORMAL:
		{
			message[0] = 0x01;
		}
		case CHATCOLOR_GREEN:
		{
			message[0] = 0x04;
		}
		default:
		{
			message[0] = 0x03;
		}
	}

	vformat(message[1], 190, msg, 4);

	if(id == 0)
	{
		index = findAnyPlayer();
		MSG_Type = MSG_ALL;
	}
	else
	{
		index = id;
		MSG_Type = MSG_ONE;
	}

	if(index != 0)
	{
		team = get_user_team(index);

		if(color == CHATCOLOR_RED && team != 1)
		{
			messageTeamInfo(index, MSG_Type, g_TeamName[1]);
			teamChanged = true;
		}
		else if(color == CHATCOLOR_BLUE && team != 2)
		{
			messageTeamInfo(index, MSG_Type, g_TeamName[2]);
			teamChanged = true;
		}
		else if(color == CHATCOLOR_GREY && team != 0)
		{
			messageTeamInfo(index, MSG_Type, g_TeamName[0]);
			teamChanged = true;
		}

		messageSayText(index, MSG_Type, message);

		if(teamChanged)
		{
			messageTeamInfo(index, MSG_Type, g_TeamName[team]);
		}
	}
}

messageSayText(id, type, message[])
{
	message_begin(type, g_msgSayText, _, id);
	write_byte(id);
	write_string(message);
	message_end();
}

messageTeamInfo(id, type, team[])
{
	message_begin(type, g_msgTeamInfo, _, id);
	write_byte(id);
	write_string(team);
	message_end();
}

findAnyPlayer()
{
	static players[32], inum, pid;

	get_players(players, inum, "ch");

	for (new a = 0 ;a < inum; a++)
	{
		pid = players[a];

		if(is_user_connected(pid))
			return pid;
	}

	return 0;
}
