/* 
*  AMX Mod X Script 
*
*  F4RR3LLs Auto Demo Recorder
*
*  Credits: Pr4yer
*
*/

#include <amxmodx>
#include <amxmisc>

new const PLAGIN[] = "Auto Demo Recorder"
new const VERSIYA[] = "2.1"
new const AVTORG[] = "F4RR3LL"

new
	gpc_cvar1,
	gpc_cvar2,
	gpc_cvar3,
	gpc_cvar4

new idofmenu[] = "idofmenu"

enum ChatColor
{
	CHATCOLOR_NORMAL = 1,
	CHATCOLOR_GREEN,
	CHATCOLOR_TEAM_COLOR,
	CHATCOLOR_GREY,
	CHATCOLOR_RED,
	CHATCOLOR_BLUE,
}

new g_TeamName[][] = 
{
	"",
	"TERRORIST",
	"CT",
	"SPECTATOR"
}

new g_msgSayText
new g_msgTeamInfo

new LOGNAME[128]
new MapName[32]

public plugin_init()
{
	register_plugin(PLAGIN, VERSIYA, AVTORG)
	
	register_clcmd("say /autorec", "pokajika", ADMIN_ALL, "- show autorecinfo.txt")
	register_clcmd("say_team /autorec", "pokajika", ADMIN_ALL, "- show autorecinfo.txt")
	
	register_menucmd(register_menuid(idofmenu), MENU_KEY_1|MENU_KEY_2, "showMenu")
	
	gpc_cvar1 = register_cvar("adr_cvar1", "180")
	
	gpc_cvar2 = register_cvar("adr_cvar2", "DarkTower.su")
	
	gpc_cvar3 = register_cvar("adr_cvar3", "300")
	
	gpc_cvar4 = register_cvar("adr_cvar4", "1")
	
	g_msgSayText = get_user_msgid("SayText")
	g_msgTeamInfo = get_user_msgid("TeamInfo")
}

new monthyear[12]

public plugin_cfg()
{
	set_task(get_pcvar_float(gpc_cvar3), "adverd", 41, "", 0, "b")
	
	get_mapname(MapName, sizeof MapName -1)
	
	
	const LEN = 128
	
	new logsdir[LEN]
	get_localinfo("amxx_logs", logsdir, LEN -1)
	
	new papka[LEN]
	format(papka, LEN -1, "recorded_demos")
	
	new direxists[LEN]
	formatex(direxists, LEN -1, "/%s/%s", logsdir, papka)
	if(!dir_exists(direxists))
		mkdir(direxists)
	
	get_time("%d-%m-%Y", monthyear, sizeof monthyear -1)
	
	new fail[LEN]
	formatex(fail, LEN -1, "%s.txt", monthyear)
	
	formatex(LOGNAME, LEN -1, "%s/%s", direxists, fail)
	
	if(!file_exists(LOGNAME))
		write_file(LOGNAME, "")
}

public pokajika(id)
{
	show_motd(id, "autorecinfo.txt", "Auto Demo Recorder")
}

public client_authorized(id)
{
	client_cmd(id, "stop")
}

public adverd()
{
	static pl[32], n, p, i
	get_players(pl, n)
	for(i=0;i<n;i++)
	{
		p = pl[i]
		
		colorChat(p, CHATCOLOR_GREY, "^x04[INFO]^x03 --------------------------------------------")
		colorChat(p, CHATCOLOR_RED, "^x04[INFO]^x03 For viewing of informatexion on automatic")
		colorChat(p, CHATCOLOR_RED, "^x04[INFO]^x03 record demo, say in chat^x04 /autorec")
		colorChat(p, CHATCOLOR_GREY, "^x04[INFO]^x03 --------------------------------------------")
	}
}

new bool:najalknopky[33] = { false, ... }

public client_putinserver(id)
{
	if(!is_user_bot(id) && !is_user_hltv(id))
	{
		if(get_pcvar_num(gpc_cvar1) < 15)
			set_pcvar_num(gpc_cvar1, 15)
		
		najalknopky[id] = false
		
		remove_task(id+500)
		set_task(get_pcvar_float(gpc_cvar1), "prerecDEMO", id+500)
	}
}

public checkKnopka(id)
{
	id -= 500
	
	if(!is_user_connected(id))
		return
	
	if(!najalknopky[id])
		recDEMO(id, 0)
}

public prerecDEMO(id)
{
	id -= 500
	
	if(!is_user_connected(id))
		return
	
	if(get_pcvar_num(gpc_cvar4))
	{
		new menuwka[256], len = formatex(menuwka, sizeof menuwka -1, "     \yServer will record record demo on you.^n")
		len += formatex(menuwka[len], sizeof menuwka -1 -len, "     Are you accept this?^n^n")
		len += formatex(menuwka[len], sizeof menuwka -1 -len, "     \w1. \rYes.^n")
		len += formatex(menuwka[len], sizeof menuwka -1 -len, "     \w2. \rNo, you will be kicked.")
		
		show_menu(id, (MENU_KEY_1|MENU_KEY_2), menuwka, 10, idofmenu)
		set_task(11.0, "checkKnopka", id+500)
	}
	else
	{
		recDEMO(id, 0)
	}
}

public showMenu(id, key)
{
	key++
	
	switch(key)
	{
		case 1: recDEMO(id, 0)
		case 2: recDEMO(id, 1)
	}
}

public recDEMO(id, mode)
{
	static nickname[32], ip[16], stim[35]
	get_user_name(id, nickname, sizeof nickname -1)
	get_user_ip(id, ip, sizeof ip -1, 1)
	get_user_authid(id, stim, sizeof stim -1)
	
	if(mode == 1)
	{
		najalknopky[id] = false
		
		remove_task(id+500)
		
		log_to_file(LOGNAME, "[Player: %s][SteamID: %s - IP: %s] [Demoname: Player was kicked]", nickname, stim, ip)
		
		server_cmd("kick #%d  You can't game at this server, without recording demo.", get_user_userid(id))
		
		return
	}
	
	najalknopky[id] = true
	
	static hostname[64], vremia[9], hash[34], demoname[350], neyznavod[32]
	
	get_cvar_string("hostname", hostname, sizeof hostname -1)
	get_time("%H:%M:%S", vremia, sizeof vremia -1)
	get_pcvar_string(gpc_cvar2, neyznavod, sizeof neyznavod -1)
	md5(demoname, hash)
	
	
	formatex(demoname, sizeof demoname -1, "%s_%s_%s_%s_%s_%s_%s_MD5-%s.dem", neyznavod, hostname, nickname, ip, MapName, vremia, monthyear, hash)
	while(replace(demoname, sizeof demoname -1, "/", "-")) {}
	while(replace(demoname, sizeof demoname -1, "\", "-")) {}
	while(replace(demoname, sizeof demoname -1, ":", "-")) {}
	while(replace(demoname, sizeof demoname -1, "*", "-")) {}
	while(replace(demoname, sizeof demoname -1, "?", "-")) {}
	while(replace(demoname, sizeof demoname -1, "<", "-")) {}
	while(replace(demoname, sizeof demoname -1, ">", "-")) {}
	while(replace(demoname, sizeof demoname -1, "|", "-")) {}
	while(replace(demoname, sizeof demoname -1, " ", "_")) {}
	
	client_cmd(id, "stop;wait;wait;record ^"%s.a^"", demoname)
	
	set_hudmessage(255, 0, 0, 0.02, 0.18, 0, 6.0, 5.0)
	show_hudmessage(id, "Beside you to write demo!^n^n%s", demoname)
	
	if(equal(stim, "VALVE_ID_LAN")
	|| equal(stim, "VALVE_ID_PENDING")
	|| equal(stim, "STEAM_666:88:666")
	|| equal(stim, "WWW.DARKTOWER.SU")
	|| equal(stim, "STEAM_ID_PENDING")
	|| equal(stim, "STEAM_ID_LAN") )
		stim = "UNKNOWN"
	
	log_to_file(LOGNAME, "[Player: %s][SteamID: %s - IP: %s] [Demoname: %s]", nickname, stim, ip, demoname)
}

colorChat(id, ChatColor:color, const msg[], {Float,Sql,Result,_}:...)
{
	new team, index, MSG_Type
	new bool:teamChanged = false
	static message[192]
	
	switch(color)
	{
		case CHATCOLOR_NORMAL:
		{
			message[0] = 0x01
		}
		case CHATCOLOR_GREEN:
		{
			message[0] = 0x04
		}
		default:
		{
			message[0] = 0x03
		}
	}
	
	vformat(message[1], 190, msg, 4)
	
	if(id == 0)
	{
		index = findAnyPlayer()
		MSG_Type = MSG_ALL
	}
	else
	{
		index = id
		MSG_Type = MSG_ONE
	}
	
	if(index != 0)
	{
		team = get_user_team(index)
		
		if(color == CHATCOLOR_RED && team != 1)
		{
			messageTeamInfo(index, MSG_Type, g_TeamName[1])
			teamChanged = true
		}
		else if(color == CHATCOLOR_BLUE && team != 2)
		{
			messageTeamInfo(index, MSG_Type, g_TeamName[2])
			teamChanged = true
		}
		else if(color == CHATCOLOR_GREY && team != 0)
		{
			messageTeamInfo(index, MSG_Type, g_TeamName[0])
			teamChanged = true
		}
		
		messageSayText(index, MSG_Type, message)
		
		if(teamChanged)
		{
			messageTeamInfo(index, MSG_Type, g_TeamName[team])
		}
	}
}

messageSayText(id, type, message[])
{
	message_begin(type, g_msgSayText, _, id)
	write_byte(id)		
	write_string(message)
	message_end()
}
	
messageTeamInfo(id, type, team[])
{
	message_begin(type, g_msgTeamInfo, _, id)
	write_byte(id)
	write_string(team)
	message_end()
}
	
findAnyPlayer()
{
	static players[32], inum, pid
	
	get_players(players, inum, "ch")
	
	for (new a = 0 ;a < inum; a++)
	{
		pid = players[a]
		
		if(is_user_connected(pid))
			return pid
	}
	
	return 0
}
