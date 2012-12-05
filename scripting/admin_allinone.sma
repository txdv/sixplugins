/* AMXX Mod script.
*
* (c) Copyright 2004, maintianed by BigBaller
* This file is provided as is (no warranties).
*
* ADMIN ALLINONE COMMANDS
* [2005 / 03 / 26 -- last change]
* [Plugin Count -- 18 plugins]
*
* Changelog:
*  v1.0 -- Initial build (14 in one)
*  v1.1 -- Made AMXX Compatible
*  v1.2 -- Fixed Money Command by Using DarkMoney plugin instead.
*          Also made everything [AMXX] instead of [AMX]
*  v1.3 -- Added f117bomb's NoClip and Stack Plugins
*  v1.4 -- Added Steam Weapon support thanks to Kingpin on AMXX Forums!
*          Also fixed amx_armor to allow admins to give themselfs armor! Thanks to GIR on AMXX Forums for pointing this out!
*  v1.5 -- Added #define USING_STEAM in the header. WON users only have to comment this line instead of searching the plugin.
*          Reorganized plugin, moved plugin_init() to the top of the plugin and moved around the body.
*          Added information, based on amx_show_activity cvar, gravity and rocket will now display admin actions.
*          Added a gag plugin per request, very simple and based off tcquest78's code.
*          Removed the description and examples of the commands from the plugin, uses a URL for information instead.
*  v1.5.1  Bug fix, due to reorganization amx_fire command didnt work, that has been fixed.
*  v1.6 -- Created a sv_alltalk plugin like that of the amx_gravity. Added log_amx to all the plugins.
*          This is to help combat "abusive admins".
*  v2.0 -- Skipped to version 2.0 as it hopes to be one of the final versions (if not final) of this plugin.
*          AMX MOD X Multilingual system enabled now and it gives error message in AMX MOD X Logs if
*          required modules are not running. Also updated commands list to better reflect correct usage.
*          Changed amx_weapon command to use a new flag and only that command on that flag, This means
*          in order for any admin to have access to amx_weapon they must have the FLAG T listed in the users.ini
*
*
* For command information and examples please read this post
* http://www.amxmodx.org/forums/viewtopic.php?t=602
*
* CREDITS:
* ---------------
* (in order of how they are placed in plugin)
*
* -) ADMIN HEAL v0.9.3 by f117bomb
* -) ADMIN ARMOR v1 by Rav
* -) ADMIN GODEMODE v0.9.3 by f117bomb
* -) ADMIN NO CLIP v0.9.3 by f117bomb
* -) ADMIN TELEPORT v0.9.3 by f117bomb
* -) ADMIN STACK v0.9.3 by f117bomb
* -) GIVING CLIENT WEAPONS v0.8.4 by {W`C} Bludy
* -) DARK MONEY 1.0 by DarkShadowST
* -) ADMIN ALLTALK 1.0 by BigBaller
* -) ADMIN GAG 1.0 by tcquest78
* -) ADMIN GRAVITY v0.2 by JustinHoMi
* -) ADMIN GLOW v0.9.3 by f117bomb
* -) ADMIN BURY v0.9.3 by f117bomb
* -) ADMIN DISARM v1.1 by mike_cao
* -) AMX UBER SLAP v0.9.3 by BarMan (Skullz.NET)
* -) ADMIN SLAY 2 v0.9.2 by f117bomb
* -) ADMIN FIRE v1.0.0 by f117bomb
* -) ADMIN ROCKET v1.3 by f117bomb
*/

#include <amxmodx>
#include <amxmisc>
#include <fun>
#include <cstrike>

public plugin_modules()
{
	require_module("fun")
	require_module("cstrike")
}

public plugin_init()
{
	register_plugin("AINO Commands", "2.0", "AMX(x) Community")

	register_dictionary("admin_allinone.txt")

	register_concmd("amx_heal",       "admin_heal",       ADMIN_LEVEL_A, "<authid, nick, @team or #userid> <life to give>")
	register_concmd("amx_armor",      "admin_armor",      ADMIN_LEVEL_A, "<part of nick> <amount>")
	register_concmd("amx_godmode",    "admin_godmode",    ADMIN_LEVEL_A, "<authid, nick, @team or #userid> <0=OFF 1=ON>")
	register_concmd("amx_noclip",     "admin_noclip",     ADMIN_LEVEL_A, "<authid, nick, @team or #userid> <0=OFF 1=ON>")
	register_concmd("amx_teleport",   "admin_teleport",   ADMIN_LEVEL_A, "<authid, nick, @team or #userid> [x] [y] [z]")
	register_concmd("amx_userorigin", "admin_userorigin", ADMIN_LEVEL_A, "<authid, nick, or #userid>")
	register_concmd("amx_stack",      "admin_stack",      ADMIN_LEVEL_A, "<authid, nick or #userid> [0|1|2]")
	register_concmd("amx_givemoney",  "give_money",       ADMIN_LEVEL_A, "<nick> OR <#userid> <amount>")
	register_concmd("amx_takemoney",  "take_money",       ADMIN_LEVEL_A, "<nick> OR <#userid> <amount>")
	register_concmd("amx_gag",        "amx_gag",          ADMIN_LEVEL_A, "<authid, nick or #userid> <a|b> [time]")
	register_concmd("amx_ungag",      "amx_ungag",        ADMIN_LEVEL_A, "<authid, nick or #userid>")
	register_concmd("amx_alltalk",    "admin_alltalk",    ADMIN_LEVEL_A, "1|0 to enable and disable")
	register_concmd("amx_gravity",    "admin_gravity",    ADMIN_LEVEL_A, "< gravity >")
	register_concmd("amx_glow",       "admin_glow",       ADMIN_LEVEL_B, "<authid, nick, @team or #userid> <red> <green> <blue> <alpha>")
	register_concmd("amx_bury",       "admin_bury",       ADMIN_LEVEL_B, "<authid, nick, @team or #userid>")
	register_concmd("amx_unbury",     "admin_unbury",     ADMIN_LEVEL_B, "<authid, nick, @team or #userid>")
	register_concmd("amx_disarm",     "admin_disarm",     ADMIN_LEVEL_B, "<authid, nick, @team or #userid>")
	register_concmd("amx_uberslap",   "admin_slap",       ADMIN_LEVEL_B, "<authid, nick or #userid>")
	register_concmd("amx_slay2",      "admin_slay",       ADMIN_LEVEL_B, "<authid, nick, @team or #userid> [1-lightning|2-blood|3-explode]")
	register_concmd("amx_fire",       "fire_player",      ADMIN_LEVEL_B, "<authid, nick or #userid>")
	register_concmd("amx_rocket",     "rocket_player",    ADMIN_LEVEL_B, "<authid, nick, @team or #userid>")
	register_concmd("amx_weapon",     "admin_weapon",     ADMIN_LEVEL_H, "<part of nick> or <@team> <weapon # to give > ")
	
	register_clcmd("say",               "block_gaged")
	register_clcmd("say_team",          "block_gaged")
	register_clcmd("say /gravity",      "check_gravity")
	register_clcmd("say_team /gravity", "check_gravity")

	register_cvar("amx_moneymsg", "1")
}


//ADMIN HEAL v0.9.3 by f117bomb
//=========================================================
public admin_heal(id, level, cid) {
	if (!cmd_access(id, level, cid, 3))
		return PLUGIN_HANDLED

	new arg[32], arg2[8], name2[32]
	read_argv(1, arg, 31)
	read_argv(2, arg2, 7)
	get_user_name(id, name2, 31)
	if (arg[0] == '@') {
		new players[32], inum
		get_players(players, inum, "ae", arg[1])
		if (inum == 0) {
			console_print(id,"%L", LANG_PLAYER, "AINO_NO_CLIENTS")
			return PLUGIN_HANDLED
		}
		for (new a = 0; a < inum; ++a) {
			new user_health = get_user_health(players[a])
			set_user_health(players[a], str_to_num(arg2) + user_health)
		}
		switch (get_cvar_num("amx_show_activity")) {
			case 2: client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_HEAL_TEAM_CASE2", name2, arg[1])
			case 1: client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_HEAL_TEAM_CASE1", arg[1])
		}
		console_print(id, "%L", LANG_PLAYER, "AINO_HEAL_ALL_SUCCESS")
		log_amx("%L", LANG_SERVER, "AINO_LOG_HEAL_ALL", name2, arg[1])
	}
	else {
		new player = cmd_target(id, arg, 7)
		if (!player)
			return PLUGIN_HANDLED
		new user_health = get_user_health(player)
		set_user_health(player, str_to_num(arg2) + user_health)
		new name[32]
		get_user_name(player, name, 31)
		switch(get_cvar_num("amx_show_activity")) {
			case 2: client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_HEAL_PLAYER_CASE2", name2, name)
			case 1: client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_HEAL_PLAYER_CASE1", name)
		}
		console_print(id, "%L", LANG_PLAYER, "AINO_HEAL_PLAYER_SUCCESS", name)
		log_amx("%L", LANG_SERVER, "AINO_LOG_HEAL_PLAYER", name2, name)
	}
	return PLUGIN_HANDLED
}

//ADMIN ARMOR v1 by Rav
//=========================================================

public admin_armor(id) {
	if (!(get_user_flags(id)&ADMIN_LEVEL_A)) {
		client_print(id, print_console, "%L", LANG_PLAYER, "AINO_NO_ACCESS")
		return PLUGIN_HANDLED
	}
	if (read_argc() <2) {
		client_print(id, print_console, "%L", LANG_PLAYER, "AINO_ARMOR_USAGE")
		return PLUGIN_HANDLED
	}
	new name[32]
	new amount[33]
	read_argv(1, name, 32)
	read_argv(2, amount, 32)
	new toarmor = find_player("bl", name)
	if (toarmor) {
		if (is_user_alive(toarmor) == 0) {
			client_print(id, print_console, "%L", LANG_PLAYER, "AINO_ARMOR_DEAD", name)
			return PLUGIN_HANDLED
		}
		if (str_to_num(amount) > 100) {
			client_print(id, print_console, "%L", LANG_PLAYER, "AINO_ARMOR_OVER")
			return PLUGIN_HANDLED
		}
		set_user_armor(toarmor, str_to_num(amount))
		return PLUGIN_HANDLED
	}
	else {
		client_print(id, print_console, "%L", LANG_PLAYER, "AINO_NICK_NOTFOUND")
		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}

//ADMIN GODEMODE v0.9.3 by f117bomb
//=========================================================
public admin_godmode(id, level, cid) {
	if (!cmd_access(id, level, cid, 3))
		return PLUGIN_HANDLED
	new arg[32], arg2[8], name2[32]
	read_argv(1, arg, 31)
	read_argv(2, arg2, 7)
	get_user_name(id, name2, 31)
	if (arg[0] == '@') {
		new players[32], inum
		get_players(players, inum, "ae", arg[1])
		if (inum == 0) {
			console_print(id, "%L", LANG_PLAYER, "AINO_NO_CLIENTS")
			return PLUGIN_HANDLED
		}
		for(new a = 0; a < inum; ++a) {
			set_user_godmode(players[a], str_to_num(arg2))
		}
		switch(get_cvar_num("amx_show_activity")) {
			case 2: client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_GODMODE_TEAM_CASE2", name2, arg[1])
			case 1: client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_GODMODE_TEAM_CASE1", arg[1])
		}
		console_print(id, "%L", LANG_PLAYER, "AINO_GODMODE_ALL_SUCCESS")
		log_amx("%L", LANG_SERVER, "AINO_LOG_GODMODE_ALL", name2, arg[1])
	}
	else {
		new player = cmd_target(id, arg, 3)
		if (!player)
			return PLUGIN_HANDLED
		set_user_godmode(player, str_to_num(arg2))
		new name[32]
		get_user_name(player, name, 31)
		switch (get_cvar_num("amx_show_activity")) {
			case 2: client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_GODMODE_PLAYER_CASE2", name2, name)
			case 1: client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_GODMODE_PLAYER_CASE1", name)
		}
		console_print(id, "%L", LANG_PLAYER, "AINO_GODMODE_PLAYER_SUCCESS", name)
		log_amx("%L", LANG_SERVER, "AINO_LOG_GODMODE_PLAYER", name2, name)
	}
	return PLUGIN_HANDLED
}

//ADMIN NO CLIP v0.9.3 by f117bomb
//=========================================================

public admin_noclip(id, level, cid) {
	if (!cmd_access(id, level, cid, 3))
		return PLUGIN_HANDLED
	new arg[32], arg2[8], name2[32]
	read_argv(1, arg, 31)
	read_argv(2, arg2, 7)
	get_user_name(id, name2, 31)
	if (arg[0] == '@') {
		new players[32], inum
		get_players(players, inum, "ae", arg[1])
		if (inum == 0) {
			console_print(id, "%L", LANG_PLAYER, "AINO_NO_CLIENTS")
			return PLUGIN_HANDLED
		}
		for(new a = 0; a < inum; ++a) {
			set_user_noclip(players[a], str_to_num(arg2))
		}
		switch (get_cvar_num("amx_show_activity")) {
			case 2: client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_NOCLIP_TEAM_CASE2", name2, arg[1])
			case 1: client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_NOCLIP_TEAM_CASE1", arg[1])
		}
		console_print(id, "%L", LANG_PLAYER, "AINO_NOCLIP_ALL_SUCCESS")
		log_amx("%L", LANG_SERVER, "AINO_LOG_NOCLIP_ALL",name2,arg[1])
	}
	else {
		new player = cmd_target(id, arg, 7)
		if (!player)
			return PLUGIN_HANDLED
		set_user_noclip(player, str_to_num(arg2))
		new name[32]
		get_user_name(player, name, 31)
		switch (get_cvar_num("amx_show_activity")) {
			case 2: client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_NOCLIP_PLAYER_CASE2", name2, name)
			case 1: client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_NOCLIP_PLAYER_CASE1", name)
		}
		console_print(id, "%L", LANG_PLAYER, "AINO_NOCLIP_PLAYER_SUCCESS", name)
		log_amx("%L", LANG_SERVER, "AINO_LOG_NOCLIP_PLAYER", name2, name)
	}
	return PLUGIN_HANDLED
}

//ADMIN TELEPORT v0.9.3 by f117bomb
//=========================================================
new storedorigin[3]

public admin_teleport(id, level, cid) {
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED
	new arg[32], sx[8], sy[8], sz[8], origin[3], name2[32]
	new argc = read_argc()
	read_argv(1, arg, 31)
	get_user_name(id, name2, 31)
	if (argc > 2) {
		read_argv(2, sx, 7)
		read_argv(3, sy, 7)
		read_argv(4, sz, 7)
		origin[0] = str_to_num(sx)
		origin[1] = str_to_num(sy)
		origin[2] = str_to_num(sz)
	}
	else {
		origin = storedorigin
	}
	new player = cmd_target(id, arg, 7)
	if (!player)
		return PLUGIN_HANDLED
	set_user_origin(player, origin)
	new name[32]
	get_user_name(player, name, 31)
	switch (get_cvar_num("amx_show_activity")) {
		case 2: client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_TELE_PLAYER_CASE2", name2, name)
		case 1: client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_TELE_PLAYER_CASE1", name)
	}
	console_print(id, "%L", LANG_PLAYER, "AINO_TELE_PLAYER_SUCCESS", name, origin[0], origin[1], origin[2])
	log_amx("%L", LANG_SERVER, "AINO_LOG_TELE_PLAYER", name2, name)
	return PLUGIN_HANDLED
}

public admin_userorigin(id, level, cid) {
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED
	new arg[32], origin[3]
	read_argv(1, arg, 31)
	new player = cmd_target(id, arg, 3)
	if (!player)
		return PLUGIN_HANDLED
	get_user_origin(player, origin)
	storedorigin = origin
	new name[32]
	get_user_name(player, name, 31)
	console_print(id, "%L", LANG_PLAYER, "ADMIN_TELE_PLAYER_STORED", name, origin[0], origin[1], origin[2])
	return PLUGIN_HANDLED
}

//ADMIN STACK v0.9.3 by f117bomb
//=========================================================

public admin_stack(id, level, cid) {
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED

	new arg[32], name2[32]
	read_argv(1, arg, 31)
	get_user_name(id, name2, 31)
	new player = cmd_target(id, arg, 7)
	if (!player)
		return PLUGIN_HANDLED

	new sttype[2], name[32], origin[3], inum, players[32]
	read_argv(2, sttype, 1)
	get_user_origin(player, origin)
	get_players(players, inum, "a")

	new offsety = 36, offsetz = 96
	switch (str_to_num(sttype)) {
		case 0: offsety = 0
		case 1: offsetz = 0
	}

	for (new a = 0; a < inum; ++a) {
		if ((players[a] == player) || (get_user_flags(players[a]) & ADMIN_IMMUNITY))
			continue
		origin[2] += offsetz
		origin[1] += offsety
		set_user_origin(players[a], origin)
	}

	get_user_name(player,name,32)
	switch (get_cvar_num("amx_show_activity")) {
		case 2: client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_STACK_PLAYER_CASE2", name2, name)
		case 1: client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_STACK_PLAYER_CASE1", name)
	}
	console_print(id, "%L", LANG_PLAYER, "AINO_STACK_PLAYER_SUCCESS", name)
	log_amx("%L", LANG_SERVER, "AINO_LOG_STACK_PLAYER", name2, name)
	return PLUGIN_HANDLED
}

//GIVING CLIENT WEAPONS v0.8.4 by {W`C} Bludy
//=========================================================

public give_weapon(admin_index, victim_index, weapon_give) {
	new arg1[32]
	read_argv(1, arg1, 32)
	new team[32]
	get_user_team(victim_index, team, 32)
	new name[32]
	get_user_name(victim_index, name, 32)
	new adminname[32]
	get_user_name(admin_index, adminname, 32)

	if (equal(arg1, "@")) {
		if (equal(team,"CT")) {
			set_hudmessage(200, 50, 0, -1.0, 0.30, 0, 6.0, 6.0, 0.5, 0.15, 1)
			show_hudmessage(0, "The Counter-Terrorists Have Been Given Weapons")
			log_amx("%L", LANG_SERVER, "AINO_LOG_WEAPON_CT", adminname)
		}
		else if (equal(team,"TERRORIST")) {
			set_hudmessage(200, 50, 0, -1.0, 0.30, 0, 6.0, 6.0, 0.5, 0.15, 1)
			show_hudmessage(0, "The Terrorists Have Been Given Weapons")
			log_amx("%L", LANG_SERVER, "AINO_LOG_WEAPON_T", adminname)
		}
	}
	else {
		set_hudmessage(200, 50, 0, -1.0, 0.30, 0, 6.0, 6.0, 0.5, 0.15, 1)
		show_hudmessage(0, "%s Has Been Given A Weapon", name)
		log_amx("%L", LANG_SERVER, "AINO_LOG_WEAPON_PLAYER", adminname, name)
	}
	
//Pistols

	if (weapon_give == 11) {
		give_item(victim_index, "weapon_usp")
		give_item(victim_index, "ammo_45acp")
		give_item(victim_index, "ammo_45acp")
		give_item(victim_index, "ammo_45acp")
		give_item(victim_index, "ammo_45acp")
		give_item(victim_index, "ammo_45acp")
		give_item(victim_index, "ammo_45acp")
		give_item(victim_index, "ammo_45acp")
		give_item(victim_index, "ammo_45acp")
	}
	else if (weapon_give == 12) {
		give_item(victim_index, "weapon_glock18")
		give_item(victim_index, "ammo_9mm")
		give_item(victim_index, "ammo_9mm")
		give_item(victim_index, "ammo_9mm")
		give_item(victim_index, "ammo_9mm")
		give_item(victim_index, "ammo_9mm")
		give_item(victim_index, "ammo_9mm")
		give_item(victim_index, "ammo_9mm")
		give_item(victim_index, "ammo_9mm")
	}
	else if (weapon_give == 13) {
		give_item(victim_index, "weapon_deagle")
		give_item(victim_index, "ammo_50ae")
		give_item(victim_index, "ammo_50ae")
		give_item(victim_index, "ammo_50ae")
		give_item(victim_index, "ammo_50ae")
		give_item(victim_index, "ammo_50ae")
		give_item(victim_index, "ammo_50ae")
		give_item(victim_index, "ammo_50ae")
	}
	else if (weapon_give == 14) {
		give_item(victim_index, "weapon_p228")
		give_item(victim_index, "ammo_357sig")
		give_item(victim_index, "ammo_357sig")
		give_item(victim_index, "ammo_357sig")
		give_item(victim_index, "ammo_357sig")
		give_item(victim_index, "ammo_357sig")
		give_item(victim_index, "ammo_357sig")
	}
	else if (weapon_give == 15) {
		give_item(victim_index, "weapon_elite")
		give_item(victim_index, "ammo_9mm")
		give_item(victim_index, "ammo_9mm")
		give_item(victim_index, "ammo_9mm")
		give_item(victim_index, "ammo_9mm")
	}
	else if (weapon_give == 16) {
		give_item(victim_index, "weapon_fiveseven")
		give_item(victim_index, "ammo_57mm")
		give_item(victim_index, "ammo_57mm")
		give_item(victim_index, "ammo_57mm")
		give_item(victim_index, "ammo_57mm")
	}
//Primary weapons
//shotguns
	else if (weapon_give == 21) {
		give_item(victim_index, "weapon_m3")
	}
	else if (weapon_give == 22) {
		give_item(victim_index, "weapon_xm1014")
	}
//Smgs
	else if (weapon_give == 31) {
		give_item(victim_index, "weapon_mp5navy")
		give_item(victim_index, "ammo_9mm")
		give_item(victim_index, "ammo_9mm")
		give_item(victim_index, "ammo_9mm")
		give_item(victim_index, "ammo_9mm")
	}
	else if (weapon_give == 32) {
		give_item(victim_index, "weapon_tmp")
		give_item(victim_index, "ammo_9mm")
		give_item(victim_index, "ammo_9mm")
		give_item(victim_index, "ammo_9mm")
		give_item(victim_index, "ammo_9mm")
	}
	else if (weapon_give == 33) {
		give_item(victim_index, "weapon_p90")
		give_item(victim_index, "ammo_57mm")
		give_item(victim_index, "ammo_57mm")
		give_item(victim_index, "ammo_57mm")
		give_item(victim_index, "ammo_57mm")
	}
	else if (weapon_give == 34) {
		give_item(victim_index, "weapon_mac10")
		give_item(victim_index, "ammo_45acp")
		give_item(victim_index, "ammo_45acp")
		give_item(victim_index, "ammo_45acp")
		give_item(victim_index, "ammo_45acp")
		give_item(victim_index, "ammo_45acp")
		give_item(victim_index, "ammo_45acp")
	}
	else if (weapon_give == 35) {
		give_item(victim_index, "weapon_ump45")
		give_item(victim_index, "ammo_45acp")
		give_item(victim_index, "ammo_45acp")
		give_item(victim_index, "ammo_45acp")
		give_item(victim_index, "ammo_45acp")
		give_item(victim_index, "ammo_45acp")
		give_item(victim_index, "ammo_45acp")
	}
	//rifles
	else if (weapon_give == 40) {
		give_item(victim_index, "weapon_famas")
		give_item(victim_index, "ammo_556nato")
		give_item(victim_index, "ammo_556nato")
		give_item(victim_index, "ammo_556nato")
	}
	else if (weapon_give == 49) {
		give_item(victim_index, "weapon_galil")
		give_item(victim_index, "ammo_556nato")
		give_item(victim_index, "ammo_556nato")
		give_item(victim_index, "ammo_556nato")
	}
	else if (weapon_give == 41) {
		give_item(victim_index, "weapon_ak47")
		give_item(victim_index, "ammo_762nato")
		give_item(victim_index, "ammo_762nato")
		give_item(victim_index, "ammo_762nato")
	}
	else if (weapon_give == 42) {
		give_item(victim_index, "weapon_sg552")
		give_item(victim_index, "ammo_556nato")
		give_item(victim_index, "ammo_556nato")
		give_item(victim_index, "ammo_556nato")
	}
	else if (weapon_give == 43) {
		give_item(victim_index, "weapon_m4a1")
		give_item(victim_index, "ammo_556nato")
		give_item(victim_index, "ammo_556nato")
		give_item(victim_index, "ammo_556nato")
	}
	else if (weapon_give == 44) {
		give_item(victim_index, "weapon_aug")
		give_item(victim_index, "ammo_556nato")
		give_item(victim_index, "ammo_556nato")
		give_item(victim_index, "ammo_556nato")
	}
	else if (weapon_give == 45) {
		give_item(victim_index, "weapon_scout")
		give_item(victim_index, "ammo_762nato")
		give_item(victim_index, "ammo_762nato")
		give_item(victim_index, "ammo_762nato")
	}
	else if (weapon_give == 46) {
		give_item(victim_index, "weapon_awp")
		give_item(victim_index, "ammo_338magnum")
		give_item(victim_index, "ammo_338magnum")
		give_item(victim_index, "ammo_338magnum")
	}
	else if (weapon_give == 47) {
		give_item(victim_index, "weapon_g3sg1")
		give_item(victim_index, "ammo_762nato")
		give_item(victim_index, "ammo_762nato")
		give_item(victim_index, "ammo_762nato")
	}
	else if (weapon_give == 48) {
		give_item(victim_index, "weapon_sig550")
		give_item(victim_index, "ammo_556nato")
		give_item(victim_index, "ammo_556nato")
		give_item(victim_index, "ammo_556nato")
	}
//machine guns
	else if (weapon_give == 51) {
		give_item(victim_index, "weapon_m249")
		give_item(victim_index, "ammo_556nato")
		give_item(victim_index, "ammo_556nato")
		give_item(victim_index, "ammo_556nato")
	}
	//equipment
	else if (weapon_give == 81) {
		give_item(victim_index, "item_kevlar")
	}
	else if (weapon_give == 82) {
		give_item(victim_index, "item_assaultsuit")
	}
	else if (weapon_give == 83) {
		give_item(victim_index, "weapon_flashbang")
		give_item(victim_index, "ammo_flashbang")
		give_item(victim_index, "ammo_flashbang")
	}
	else if (weapon_give == 84) {
		give_item(victim_index, "weapon_hegrenade")
	}
	else if (weapon_give == 85) {
		give_item(victim_index, "weapon_smokegrenade")
	}
	else if (weapon_give == 86) {
		give_item(victim_index, "item_thighpack")
	}

	else if (weapon_give == 87) {
		give_item(victim_index, "weapon_shield")
	}

	else {
		client_print(admin_index, print_console, "%L", LANG_PLAYER, "AINO_WEAPON_NOWEAP")
		return PLUGIN_CONTINUE
	}

	client_print(admin_index, print_console, "%L", LANG_PLAYER, "AINO_WEAPON_PLAYER_SUCCESS", name)
	return PLUGIN_CONTINUE
}

public admin_weapon(id) {
	if (!(get_user_flags(id) & ADMIN_LEVEL_H)) {
		client_print(id, print_console, "%L", LANG_PLAYER, "AINO_NO_ACCESS")
		return PLUGIN_HANDLED
	}
	new argc = read_argc()
	if (argc < 3) {
		client_print(id, print_console, "%L", LANG_PLAYER, "AINO_WEAPON_USAGE")
		return PLUGIN_HANDLED
	}
	new arg1[32]
	new arg2[32]
	new arg3[32]
	read_argv(1, arg1, 32)
	read_argv(2, arg2, 32)
	read_argv(3, arg3, 32)


//Team
	if (equal(arg1, "@")) {
		new players[32], inum
		get_players(players, inum, "e", arg2)
		for (new i = 0; i < inum; ++i)
			give_weapon(id, players[i], str_to_num(arg3))
		if (inum)
			client_print(id, print_console, "%L", LANG_PLAYER, "AINO_WEAPON_TEAM_SUCCESS", arg2)
		else
			client_print(id, print_console, "%L", LANG_PLAYER, "AINO_NO_CLIENTS")
	}
//Index
	if (equal(arg1, "#")) {
		if (is_user_connected(str_to_num(arg2)))
			give_weapon(id, str_to_num(arg2), str_to_num(arg3))
		else
			client_print(id, print_console, "%L", LANG_PLAYER, "AINO_NO_CLIENTS")
	}
//Part of Name
	else {
		new player = find_player("lb", arg1)
		if (player)
			give_weapon(id, player, str_to_num(arg2))
		else
			client_print(id, print_console, "%L", LANG_PLAYER, "AINO_NICK_NOTFOUND")
	}
	return PLUGIN_HANDLED
}

//DARK MONEY 1.0 by DarkShadowST
//=========================================================

public give_money(id, level, cid) {
	if (!cmd_access(id, level, cid, 3)) {
		return PLUGIN_HANDLED
	}
	new arg1[32], arg2[8], name2[32]
	read_argv(1, arg1, 31)
	read_argv(2, arg2, 7)
	new adminname[32]

	new player = cmd_target(id, arg1, 2)
	if (!player)
		return PLUGIN_HANDLED

	get_user_name(player, name2, 31)

	if ((cs_get_user_money(player) + str_to_num(arg2)) > 16000) {
		cs_set_user_money(player, 16000, 1)
		if (get_cvar_num("amx_moneymsg") == 1) {
			client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_MONEY_PLAYER_SUCCESS_GIVE", name2)
			return PLUGIN_HANDLED
		}
		client_print(id, print_chat, "%L", LANG_PLAYER, "AINO_MONEY_PLAYER_SUCCESS_GIVE_CONSOLE", name2)
		return PLUGIN_HANDLED
	}
	else {
		cs_set_user_money(player, cs_get_user_money(player) + str_to_num(arg2),1)
		if (get_cvar_num("amx_moneymsg") == 1) {
			client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_MONEY_PLAYER_SUCCESS_GIVE", name2)
			return PLUGIN_HANDLED
		}
		client_print(id, print_chat, "%L", LANG_PLAYER, "AINO_MONEY_PLAYER_SUCCESS_GIVE_CONSOLE", name2)
		return PLUGIN_HANDLED
	}
	get_user_name(id, adminname, 31)
	log_amx("%L", LANG_SERVER, "AINO_LOG_MONEY_PLAYER_GIVE", adminname, name2)
	return PLUGIN_HANDLED
}
public take_money(id, level, cid) {
	if (!cmd_access(id, level, cid,3)) {
		return PLUGIN_HANDLED
	}

	new arg1[32], arg2[8], name2[32]
	read_argv(1, arg1, 31)
	read_argv(2, arg2, 7)
	new adminname[32]

	new player = cmd_target(id, arg1, 1)
	if (!player)
		return PLUGIN_HANDLED

	get_user_name(player, name2, 31)

	if ((cs_get_user_money(player) - str_to_num(arg2)) <= 0) {
		cs_set_user_money(player, 0, 1)
		if (get_cvar_num("amx_moneymsg") == 1) {
			client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_MONEY_PLAYER_SUCCESS_TAKE_ALL", name2)
			return PLUGIN_HANDLED
		}
		client_print(id, print_chat, "%L", LANG_PLAYER, "AINO_MONEY_PLAYER_SUCESSS_TAKE_CONSOLE", name2)
	}
	else {
		cs_set_user_money(player, cs_get_user_money(player) - str_to_num(arg2), 1)
		if (get_cvar_num("amx_moneymsg") == 1) {
			client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_MONEY_PLAYER_SUCCESS_TAKE", name2)
			return PLUGIN_HANDLED
		}
	}
	get_user_name(id, adminname, 31)
	log_amx("%L", LANG_SERVER, "AINO_LOG_MONEY_PLAYER_TAKE", adminname, name2)
	return PLUGIN_HANDLED
}

//ADMIN ALLTALK v1.0 by BigBaller
//=========================================================

public admin_alltalk(id, level) {
	if (!(get_user_flags(id) & level)) {
		console_print(id, "%L", LANG_PLAYER, "AINO_NO_ACCESS")
		return PLUGIN_HANDLED
	}
	if (read_argc() < 2) {
		new alltalk_cvar = get_cvar_num("sv_alltalk")
		console_print(id, "%L", LANG_PLAYER, "AINO_ALLTALK_STATUS", alltalk_cvar)
		return PLUGIN_HANDLED
	}
	new alltalk[6]
	read_argv(1, alltalk, 6)
	server_cmd("sv_alltalk %s", alltalk)
	new name[32]
	get_user_name(id, name, 31)
	switch(get_cvar_num("amx_show_activity")) {
		case 2: client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_ALLTALK_SET_CASE2", name, alltalk)
		case 1: client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_ALLTALK_SET_CASE1", alltalk)
	}
	log_amx("%L", LANG_SERVER, "AINO_LOG_ALLTALK", name, alltalk)
	return PLUGIN_HANDLED
}

//ADMIN GAG 1.0 by tcquest78
//=========================================================

new gag[33]

public block_gaged(id) {
	if (!gag[id])
		return PLUGIN_CONTINUE
	new cmd[6]
	read_argv(0, cmd, 4)
	if (cmd[3] == '_') {
		if (gag[id] & 2){
			client_print(id,print_notify, "%L", LANG_PLAYER, "AINO_GAG_STATUS")
			return PLUGIN_HANDLED
		}
	}
	else if (gag[id] & 1) {
		client_print(id,print_notify, "%L", LANG_PLAYER, "AINO_GAG_STATUS")
		return PLUGIN_HANDLED
	}
	return PLUGIN_CONTINUE
}

public amx_gag(id, level, cid) {
	if (!cmd_access(id, level, cid, 3))
		return PLUGIN_HANDLED

	new arg[32]
	read_argv(1, arg, 31)
	new player = cmd_target(id, arg, 1)
	if (!player)
		return PLUGIN_HANDLED

	new sflags[4]
	read_argv(2, sflags, 3)
	new flags = read_flags(sflags)
	if (!flags)
		return PLUGIN_HANDLED

	gag[player] = flags

	new sgagtime[8]
	read_argv(3, sgagtime, 7)
	new Float:gagtime = floatstr(sgagtime)

	new param[2]
	param[0] = player
	set_task(gagtime ? gagtime : 99999.0 ,"ungag", player, param, 1)
	
	new name[32]
	get_user_name(id, name, 31)
	log_amx("%L", LANG_SERVER, "AINO_LOG_GAG", name, player)
	return PLUGIN_HANDLED
}


public ungag(param[]) {
	new id = param[0]
	gag[id] = 0
	remove_task(id)
	return PLUGIN_HANDLED
}

public amx_ungag(id, level, cid) {
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED
	new arg[32]
	read_argv(1, arg, 31)
	new player = cmd_target(id, arg, 1)
	if (!player)
		return PLUGIN_HANDLED
	new param[2]
	param[0] = player
	ungag(param)
	
	new name[32]
	get_user_name(id,name,31)
	log_amx("%L", LANG_SERVER, "AINO_LOG_UNGAG", name, player)
	return PLUGIN_HANDLED
}

public client_disconnect(id) {
	new param[2]
	param[0] = id
	ungag(param)
	return PLUGIN_CONTINUE
}

//ADMIN GRAVITY v0.2 by JustinHoMi
//=========================================================

public admin_gravity(id, level) {
	if (!(get_user_flags(id) & level)){
		console_print(id, "%L", LANG_PLAYER, "AINO_NO_ACCESS")
		return PLUGIN_HANDLED
	}
	if (read_argc() < 2) {
		new gravity_cvar = get_cvar_num("sv_gravity")
		console_print(id, "%L", LANG_PLAYER, "AINO_GRAVITY_STATUS", gravity_cvar)
		return PLUGIN_HANDLED
	}
	new gravity[6]
	read_argv(1, gravity, 6)
	server_cmd("sv_gravity %s", gravity)
	new name[32]
	get_user_name(id, name, 31)
	switch(get_cvar_num("amx_show_activity")) {
		case 2: client_print(0, print_chat, "%L", LANG_PLAYER, "[AMXX] ADMIN %s: set gravity to %s", name, gravity)
		case 1: client_print(0, print_chat, "%L", LANG_PLAYER, "[AMXX] ADMIN: set gravity to %s", gravity)
	}
	console_print(id, "%L", LANG_PLAYER, "AINO_GRAVITY_SUCCESS", gravity)
	log_amx("%L", LANG_SERVER, "AINO_LOG_GRAVITY", name, gravity)
	return PLUGIN_HANDLED
}

public check_gravity(id){
	new gravity = get_cvar_num("sv_gravity")
	client_print(id, print_chat, "%L", LANG_PLAYER, "AINO_GRAVITY_STATUS", gravity)
	return PLUGIN_HANDLED
}


//ADMIN GLOW v0.9.3 by f117bomb
//=========================================================

public admin_glow(id, level, cid) {
	if (!cmd_access(id, level, cid, 6))
		return PLUGIN_HANDLED
	new arg[32], sred[8], sgreen[8], sblue[8], salpha[8], name2[32]
	get_user_name(id, name2, 31)
	read_argv(1, arg, 31)
	read_argv(2, sred, 7)
	read_argv(3, sgreen, 7)
	read_argv(4, sblue, 7)
	read_argv(5, salpha, 7)
	new ired = str_to_num(sred)
	new igreen = str_to_num(sgreen)
	new iblue = str_to_num(sblue)
	new ialpha = str_to_num(salpha)
	if (arg[0] == '@') {
		new players[32], inum
		get_players(players, inum, "ae", arg[1])
		if (inum == 0) {
			console_print(id, "%L", LANG_PLAYER, "AINO_NO_CLIENTS")
			return PLUGIN_HANDLED
		}
		for (new a = 0; a < inum; ++a)
			set_user_rendering(players[a], kRenderFxGlowShell,
				ired, igreen, iblue, kRenderTransAlpha, ialpha)
		switch (get_cvar_num("amx_show_activity")) {
			case 2: client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_GLOW_TEAM_CASE2", name2, arg[1])
			case 1: client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_GLOW_TEAM_CASE1", arg[1])
		}
		console_print(id, "%L", LANG_PLAYER, "AINO_GLOW_TEAM_SUCCESS")
		log_amx("%L", LANG_SERVER, "AINO_LOG_GLOW_ALL", name2, arg[1])
	}
	else {
		new player = cmd_target(id, arg, 7)
		if (!player) return PLUGIN_HANDLED
		set_user_rendering(player, kRenderFxGlowShell,
			ired, igreen, iblue, kRenderTransAlpha, ialpha)
		new name[32]
		get_user_name(player,name,31)
		switch(get_cvar_num("amx_show_activity")) {
			case 2: client_print(0, print_chat, "%L", LANG_PLAYER, "[AMXX] ADMIN %s: set glowing on %s",name2,name)
			case 1: client_print(0, print_chat, "%L", LANG_PLAYER, "[AMXX] ADMIN: set glowing on %s",name)
		}
		console_print(id, "%L", LANG_PLAYER, "[AMXX] Client ^"%s^" has set glowing",name)
		log_amx("%L", LANG_SERVER, "AINO_LOG_GLOW_PLAYER", name2, name)
	}
	return PLUGIN_HANDLED
}

//ADMIN BURY v0.9.3 by f117bomb
//=========================================================

bury_player(id,victim) {
	new name[32], iwpns[32], nwpn[32], iwpn
	get_user_name(victim, name, 31)
	get_user_weapons(victim, iwpns, iwpn)
	for (new a = 0 ; a < iwpn; ++a) {
		get_weaponname(iwpns[a], nwpn, 31)
		engclient_cmd(victim, "drop", nwpn)
	}
	engclient_cmd(victim, "weapon_knife")
	new origin[3]
	get_user_origin(victim, origin)
	origin[2] -= 30
	set_user_origin(victim, origin)
	console_print(id, "%L", LANG_PLAYER, "AINO_BURY_PLAYER_SUCCESS", name)
}


public admin_bury(id, level, cid) {
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED
	new arg[32], admin_name[32], player_name[32]
	read_argv(1, arg, 31)
	get_user_name(id, admin_name, 31)
	if (arg[0] == '@') {
		new players[32], inum
		get_players(players, inum, "ae", arg[1])
		if (inum == 0) {
			console_print(id, "%L", LANG_PLAYER, "AINO_NO_CLIENTS")
			return PLUGIN_HANDLED
		}
		for (new a = 0; a < inum; ++a) {
			if (get_user_flags(players[a]) & ADMIN_IMMUNITY) {
				get_user_name(players[a], player_name, 31)
				console_print(id, "%L", LANG_PLAYER, "AINO_IMMUNE",player_name)
				continue
			}
			bury_player(id, players[a])
		}
		switch (get_cvar_num("amx_show_activity")) {
			case 2: client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_BURY_TEAM_CASE2", admin_name, arg[1])
			case 1: client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_BURY_TEAM_CASE1", arg[1])
		}
		log_amx("%L", LANG_SERVER, "AINO_LOG_BURY_ALL", admin_name, arg[1])
	}
	else {
		new player = cmd_target(id, arg, 7)
		if (!player)
			return PLUGIN_HANDLED
		bury_player(id, player)
		get_user_name(player, player_name, 31)
		switch (get_cvar_num("amx_show_activity")) {
			case 2: client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_BURY_PLAYER_CASE2", admin_name, player_name)
			case 1: client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_BURY_PLAYER_CASE1", player_name)
		}
		log_amx("%L", LANG_SERVER, "AINO_LOG_BURY_PLAYER", admin_name, player_name)
	}
	return PLUGIN_HANDLED
}

unbury_player(id,victim) {
	new name[32], origin[3]
	get_user_name(victim, name, 31)
	get_user_origin(victim, origin)
	origin[2] += 35
	set_user_origin(victim, origin)
	console_print(id, "%L", LANG_PLAYER, "AINO_UNBURY_PLAYER_SUCCESS", name)
}

public admin_unbury(id,level,cid) {
	if (!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED
	new arg[32], player_name[32], name2[32]
	read_argv(1, arg, 31)
	get_user_name(id, name2, 31)
	if (arg[0] == '@') {
		new players[32], inum , name[32]
		get_players(players, inum, "ae", arg[1])
		if (inum == 0) {
			console_print(id, "%L", LANG_PLAYER, "AINO_NO_CLIENTS")
			return PLUGIN_HANDLED
		}
		for (new a=0; a < inum; ++a) {
			if (get_user_flags(players[a]) & ADMIN_IMMUNITY){
				get_user_name(players[a],name,31)
				console_print(id, "%L", LANG_PLAYER, "AINO_IMMUNE",name)
				continue
			}
			unbury_player(id, players[a])
		}
		switch (get_cvar_num("amx_show_activity")) {
			case 2: client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_UNBURY_TEAM_CASE2", name2, arg[1])
			case 1: client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_UNBURY_TEAM_CASE1", arg[1])
		}
		log_amx("%L", LANG_SERVER, "AINO_LOG_UNBURY_ALL", name2, arg[1])
	}
	else {
		new player = cmd_target(id, arg, 7)
		if (!player)
			return PLUGIN_HANDLED
		unbury_player(id, player)
		get_user_name(player, player_name, 31)
		switch (get_cvar_num("amx_show_activity")) {
			case 2: client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_UNBURY_PLAYER_CASE2", name2, player_name)
			case 1: client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_UNBURY_PLAYER_CASE1", player_name)
		}
		log_amx("%L", LANG_SERVER, "AINO_LOG_UNBURY_PLAYER", name2, player_name)
	}
	return PLUGIN_HANDLED
}

//ADMIN DISARM v1.1 by mike_cao
//=========================================================

disarm_player(id, victim) {
	new name[32], origin[3], name2[32]
	get_user_origin(victim, origin)
	origin[2] -= 2000
	set_user_origin(victim, origin)
	new iweapons[32], wpname[32], inum
	get_user_weapons(victim, iweapons, inum)
	for (new a = 0; a < inum; ++a) {
		get_weaponname(iweapons[a], wpname, 31)
		engclient_cmd(victim, "drop", wpname)
	}
	engclient_cmd(victim, "weapon_knife")
	origin[2] += 2005
	set_user_origin(victim, origin)
	get_user_name(victim, name, 31)
	console_print(id, "%L", LANG_PLAYER, "AINO_DISARM_PLAYER_SUCCESS", name)
	get_user_name(id, name2, 31)
	log_amx("%L", LANG_SERVER, "AINO_LOG_DISARM_PLAYER", name2, name)
}

public admin_disarm(id,level,cid) {
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED
	new arg[32]
	read_argv(1, arg, 31)
	if (arg[0] == '@') {
		new players[32], /*name[32],*/ inum
		get_players(players, inum, "ae", arg[1])
		if (inum == 0) {
			console_print(id, "%L", LANG_PLAYER, "AINO_DISARM_NOALIVE")
			return PLUGIN_HANDLED
		}
		for (new a = 0 ; a < inum; ++a) {
			disarm_player(id, players[a])
		}
	}
	else {
		new player = cmd_target(id, arg, 5)
		if (!player)
			return PLUGIN_HANDLED
		disarm_player(id, player)
	}
	return PLUGIN_HANDLED
}

//AMX UBER SLAP v0.9.3 by BarMan (Skullz.NET)
//=========================================================

public admin_slap(id, level, cid) {
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED

	new name[32], name2[32]
	new arg[32]
	read_argv(1, arg, 31)
	new player = cmd_target(id, arg, 5)
	if (!player)
		return PLUGIN_HANDLED

	new ids[2]
	ids[0] = player
	get_user_name(player, name, 32)
	udisarm_player(id, player)
	set_task(0.1, "slap_player", 0, ids, 1, "a", 100)
	set_task(11.5, "last_words", 0, ids, 1, "a", 0)
	get_user_name(id, name2, 31)
	log_amx("%L", LANG_SERVER, "AINO_LOG_UBERSLAP_PLAYER", name2, name)
	return PLUGIN_HANDLED
}

public udisarm_player(id, victim) {
	new name[32], origin[3]
	get_user_origin(victim, origin)
	origin[2] -= 2000
	set_user_origin(victim, origin)
	new iweapons[32], wpname[32], inum
	get_user_weapons(victim, iweapons, inum)
	for (new a = 0; a < inum; ++a){
		get_weaponname(iweapons[a], wpname,31)
		engclient_cmd(victim, "drop", wpname)
	}
	engclient_cmd(victim,"weapon_knife")
	origin[2] += 2005
	set_user_origin(victim, origin)
	get_user_name(victim, name, 31)
	return PLUGIN_CONTINUE
}

public last_words(ids[]) {
	client_cmd(0, "spk misc/knockedout")
	return PLUGIN_HANDLED
}

public slap_player(ids[]) {
	new id = ids[0]
	new upower = 1, nopower = 0
	if (get_user_health(id) > 1) {
		user_slap(id, upower)
	} else {
		user_slap(id, nopower)
	}
	return PLUGIN_CONTINUE
}

//ADMIN SLAY 2 v0.9.3 by f117bomb
//=========================================================

new light, s2smoke, s2white

slay_player(id,victim,type) {
	new origin[3], srco[3], name[32], name2[32]
	get_user_name(victim, name, 31)
	get_user_name(id, name2, 31)
	get_user_origin(victim, origin)
	origin[2] -= 26
	srco[0]= origin[0] + 150
	srco[1]= origin[1] + 150
	srco[2]= origin[2] + 400
	switch (type) {
		case 1: {
			lightning(srco,origin)
			emit_sound(victim,CHAN_ITEM, "ambience/thunder_clap.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
		case 2: {
			blood(origin)
			emit_sound(victim,CHAN_ITEM, "weapons/headshot2.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		}
		case 3: explode(origin)
	}
	user_kill(victim,1)
	console_print(id, "%L", LANG_PLAYER, "AINO_SLAY2_PLAYER_SUCCESS", name)
	log_amx("%L", LANG_SERVER, "AINO_LOG_SLAY2_PLAYER", name2, name)
}

public admin_slay(id, level, cid) {
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED
	new arg[32], arg2[3], type
	read_argv(1, arg, 31)
	read_argv(2, arg2, 2)
	type = str_to_num(arg2)
	if (arg[0] == '@') {
		new players[32], inum , name[32]
		get_players(players, inum, "ae", arg[1])
		if (inum == 0) {
			console_print(id, "%L", LANG_PLAYER, "AINO_NO_CLIENTS")
			return PLUGIN_HANDLED
		}
		for (new a = 0; a < inum; ++a) {
			if (get_user_flags(players[a]) & ADMIN_IMMUNITY) {
				get_user_name(players[a], name, 31)
				console_print(id, "%L", LANG_PLAYER, "AINO_IMMUNE", name)
				continue
			}
			slay_player(id, players[a], type)
		}
	}
	else {
		new player = cmd_target(id, arg, 5)
		if (!player)
			return PLUGIN_HANDLED
		slay_player(id, player, type)
	}
	return PLUGIN_HANDLED
}

explode(vec1[3]) {
	// blast circles
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY, vec1)
	write_byte( 21 )
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2] + 16)
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2] + 1936)
	write_short(s2white)
	write_byte(0) // startframe
	write_byte(0) // framerate
	write_byte(2) // life
	write_byte(16) // width
	write_byte(0) // noise
	write_byte(188) // r
	write_byte(220) // g
	write_byte(255) // b
	write_byte(255) //brightness
	write_byte(0) // speed
	message_end()
	//Explosion2
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(12)
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2])
	write_byte(188) // byte (scale in 0.1's)
	write_byte(10) // byte (framerate)
	message_end()
	//s2smoke
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY, vec1)
	write_byte(5)
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2])
	write_short(s2smoke)
	write_byte(2)
	write_byte(10)
	message_end()
}

blood(vec1[3]) {
	//LAVASPLASH
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(10)
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2])
	message_end()
}

lightning(vec1[3], vec2[3]) {
	//Lightning
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
	write_byte(0)
	write_coord(vec1[0])
	write_coord(vec1[1])
	write_coord(vec1[2])
	write_coord(vec2[0])
	write_coord(vec2[1])
	write_coord(vec2[2])
	write_short(light)
	write_byte(1) // framestart
	write_byte(5) // framerate
	write_byte(2) // life
	write_byte(20) // width
	write_byte(30) // noise
	write_byte(200) // r, g, b
	write_byte(200) // r, g, b
	write_byte(200) // r, g, b
	write_byte(200) // brightness
	write_byte(200) // speed
	message_end()
	//Sparks
	message_begin(MSG_PVS, SVC_TEMPENTITY, vec2)
	write_byte(9)
	write_coord(vec2[0])
	write_coord(vec2[1])
	write_coord(vec2[2])
	message_end()
	//s2smoke
	message_begin(MSG_BROADCAST, SVC_TEMPENTITY, vec2)
	write_byte(5)
	write_coord(vec2[0])
	write_coord(vec2[1])
	write_coord(vec2[2])
	write_short(s2smoke)
	write_byte(10)
	write_byte(10)
	message_end()
}

//ADMIN FIRE v1.0.0 by f117bomb
//=========================================================
new gmsgDamage,smoke,mflash
new onfire[33]

public ignite_effects(skIndex[]) {
	new kIndex = skIndex[0]
	gmsgDamage = get_user_msgid("Damage")
	
	if (is_user_alive(kIndex) && onfire[kIndex]) {
		new korigin[3]
		get_user_origin(kIndex,korigin)

		//TE_SPRITE - additive sprite, plays 1 cycle
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY)
		write_byte(17)
		write_coord(korigin[0])  // coord, coord, coord (position)
		write_coord(korigin[1])
		write_coord(korigin[2])
		write_short(mflash) // short (sprite index)
		write_byte(20) // byte (scale in 0.1's)
		write_byte(200) // byte (brightness)
		message_end()
		
		//Smoke
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY, korigin)
		write_byte(5)
		write_coord(korigin[0]) // coord coord coord (position)
		write_coord(korigin[1])
		write_coord(korigin[2])
		write_short(smoke)// short (sprite index)
		write_byte(20) // byte (scale in 0.1's)
		write_byte(15) // byte (framerate)
		message_end()

		set_task(0.2, "ignite_effects" , 0 , skIndex, 2)
	}
	else {
		if (onfire[kIndex]) {
			emit_sound(kIndex,CHAN_AUTO, "scientist/scream21.wav", 0.6, ATTN_NORM, 0, PITCH_HIGH)
			onfire[kIndex] = 0
		}
	}	
	return PLUGIN_CONTINUE
}

public ignite_player(skIndex[]) {
	new kIndex = skIndex[0]

	if (is_user_alive(kIndex) && onfire[kIndex]) {
		new korigin[3]
		new players[32], inum = 0
		new pOrigin[3]
		new kHeath = get_user_health(kIndex)
		get_user_origin(kIndex, korigin)
		
		//create some damage
		set_user_health(kIndex, kHeath - 10)
		message_begin(MSG_ONE, gmsgDamage, {0,0,0}, kIndex)
		write_byte(30) // dmg_save
		write_byte(30) // dmg_take
		write_long(1 << 21) // visibleDamageBits
		write_coord(korigin[0]) // damageOrigin.x
		write_coord(korigin[1]) // damageOrigin.y
		write_coord(korigin[2]) // damageOrigin.z
		message_end()
				
		//create some sound
		emit_sound(kIndex,CHAN_ITEM, "ambience/flameburst1.wav", 0.6, ATTN_NORM, 0, PITCH_NORM)

		//Ignite Others
		get_players(players, inum, "a")
		for (new i = 0 ;i < inum; ++i) {
			get_user_origin(players[i], pOrigin)
			if (get_distance(korigin, pOrigin) < 100) {
				if (!onfire[players[i]]) {
					new spIndex[2]
					spIndex[0] = players[i]
					new pName[32], kName[32]
					get_user_name(players[i], pName,31)
					get_user_name(kIndex, kName, 31)
					emit_sound(players[i], CHAN_WEAPON, "scientist/scream07.wav", 1.0, ATTN_NORM, 0, PITCH_HIGH)
					client_print(0, 3, "%L", LANG_PLAYER, "* [AMXX] OH! NO! %s has caught %s on fire!", kName, pName)
					onfire[players[i]] = 1
					ignite_player(players[i])
					ignite_effects(players[i])
				}
			}
		}
		players[0] = 0
		pOrigin[0] = 0
		korigin[0] = 0
		
		//Call Again in 2 seconds
		set_task(2.0, "ignite_player" , 0 , skIndex, 2)
	}
	return PLUGIN_CONTINUE
}


public fire_player(id, level, cid) {
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED
	
	new arg[32]
	read_argv(1, arg, 31)

	new victim = cmd_target(id, arg, 7)
	if (!victim)
		return PLUGIN_HANDLED

	new skIndex[2]
	skIndex[0] = victim
	new name[32]
	get_user_name(victim,name,31)
	
	onfire[victim] = 1
	ignite_effects(skIndex)
	ignite_player(skIndex)

	new adminname[32]
	get_user_name(id, adminname, 31)
	switch (get_cvar_num("amx_show_activity")) {
		case 2: client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_FIRE_PLAYER_CASE2", adminname, name)
		case 1: client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_FIRE_PLAYER_CASE1", name)
	}
	console_print(id, "%L", LANG_PLAYER, "AINO_FIRE_PLAYER_SUCCESS", name)
	log_amx("%L", LANG_SERVER, "AINO_LOG_FIRE_PLAYER", adminname, name)
	return PLUGIN_HANDLED
}

//ADMIN ROCKET v1.3 by f117bomb
//=========================================================
new m_blueflare2, rmflash, rgmsgDamage, white, rsmoke, rocket_z[33]

public rocket_liftoff(svictim[]) {
	new victim = svictim[0]

	set_user_gravity(victim, -0.50)
	client_cmd(victim,"+jump;wait;wait;-jump")
	emit_sound(victim, CHAN_VOICE, "weapons/rocket1.wav", 1.0, 0.5, 0, PITCH_NORM)
	rocket_effects(svictim)

	return PLUGIN_CONTINUE
}

public rocket_effects(svictim[]) {
	new victim = svictim[0]

	if (is_user_alive(victim)) {
		new vorigin[3]
		get_user_origin(victim,vorigin)

		message_begin(MSG_ONE, rgmsgDamage, {0,0,0}, victim)
		write_byte(30) // dmg_save
		write_byte(30) // dmg_take
		write_long(1 << 16) // visibleDamageBits
		write_coord(vorigin[0]) // damageOrigin.x
		write_coord(vorigin[1]) // damageOrigin.y
		write_coord(vorigin[2]) // damageOrigin.z
		message_end()

		if (rocket_z[victim] == vorigin[2])
			rocket_explode(svictim)

		rocket_z[victim] = vorigin[2]

		//Draw Trail and effects

		//TE_SPRITETRAIL - line of moving glow sprites with gravity, fadeout, and collisions
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(15)
		write_coord(vorigin[0]) // coord, coord, coord (start)
		write_coord(vorigin[1])
		write_coord(vorigin[2])
		write_coord(vorigin[0]) // coord, coord, coord (end)
		write_coord(vorigin[1])
		write_coord(vorigin[2] - 30)
		write_short(m_blueflare2 ) // short (sprite index)
		write_byte(5) // byte (count)
		write_byte(1) // byte (life in 0.1's)
		write_byte(1)  // byte (scale in 0.1's)
		write_byte(10) // byte (velocity along vector in 10's)
		write_byte(5)  // byte (randomness of velocity in 10's)
		message_end()

		//TE_SPRITE - additive sprite, plays 1 cycle
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(17)
		write_coord(vorigin[0])  // coord, coord, coord (position)
		write_coord(vorigin[1])
		write_coord(vorigin[2] - 30)
		write_short(rmflash) // short (sprite index)
		write_byte(15) // byte (scale in 0.1's)
		write_byte(255) // byte (brightness)
		message_end()

		set_task(0.2, "rocket_effects" , 0 , svictim, 2)
	}

	return PLUGIN_CONTINUE
}

public rocket_explode(svictim[]) {
	new victim = svictim[0]

	if (is_user_alive(victim)) { /*If user is alive create effects and user_kill */
		new vec1[3]
		get_user_origin(victim, vec1)

		// blast circles
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY, vec1)
		write_byte(21)
		write_coord(vec1[0])
		write_coord(vec1[1])
		write_coord(vec1[2] - 10)
		write_coord(vec1[0])
		write_coord(vec1[1])
		write_coord(vec1[2] + 1910)
		write_short(white)
		write_byte(0) // startframe
		write_byte(0) // framerate
		write_byte(2) // life
		write_byte(16) // width
		write_byte(0) // noise
		write_byte(188) // r
		write_byte(220) // g
		write_byte(255) // b
		write_byte(255) //brightness
		write_byte(0) // speed
		message_end()

		//Explosion2
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(12)
		write_coord(vec1[0])
		write_coord(vec1[1])
		write_coord(vec1[2])
		write_byte(188) // byte (scale in 0.1's)
		write_byte(10) // byte (framerate)
		message_end()

		//rsmoke
		message_begin(MSG_BROADCAST, SVC_TEMPENTITY, vec1)
		write_byte(5)
		write_coord(vec1[0])
		write_coord(vec1[1])
		write_coord(vec1[2])
		write_short(rsmoke)
		write_byte(2)
		write_byte(10)
		message_end()

		user_kill(victim, 1)
	}


	//stop_sound
	emit_sound(victim, CHAN_VOICE, "weapons/rocket1.wav", 0.0, 0.0, (1<<5), PITCH_NORM)

	set_user_maxspeed(victim, 1.0)
	set_user_gravity(victim, 1.00)

	return PLUGIN_CONTINUE
}


public rocket_player(id, level, cid) {
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED
	new arg[32], arg2[3]
	read_argv(1, arg, 31)
	read_argv(2, arg2, 2)
	if (arg[0] == '@') {
		new players[32], inum, name[32]
		get_players(players, inum, "ae", arg[1])
		if (inum == 0) {
			console_print(id, "%L", LANG_PLAYER, "AINO_NO_CLIENTS")
			return PLUGIN_HANDLED
		}
		for (new a = 0; a < inum; ++a) {
			if (get_user_flags(players[a]) & ADMIN_IMMUNITY) {
				get_user_name(players[a], name, 31)
				console_print(id, "%L", LANG_PLAYER, "AINO_IMMUNE",name)
				continue
			}
			new sPlayer[2]
			sPlayer[0] = players[a]
			emit_sound(players[a], CHAN_WEAPON, "weapons/rocketfire1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
			set_user_maxspeed(players[a], 0.01)
			set_task(1.2, "rocket_liftoff" , 0 , sPlayer, 2)
		}
	}
	else {
		new player = cmd_target(id, arg, 5)
		if (!player)
			return PLUGIN_HANDLED
		new sPlayer[2]
		sPlayer[0] = player
		emit_sound(player, CHAN_WEAPON ,"weapons/rocketfire1.wav", 1.0, ATTN_NORM, 0, PITCH_NORM)
		set_user_maxspeed(player, 0.01)
		set_task(1.2, "rocket_liftoff", 0, sPlayer, 2)

		new playername[32]
		get_user_name(player, playername, 31)
		new name[32]
		get_user_name(id,name,31)
		switch (get_cvar_num("amx_show_activity")) {
			case 2: client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_ROCKET_PLAYER_CASE2", name, playername)
			case 1: client_print(0, print_chat, "%L", LANG_PLAYER, "AINO_ROCKET_PLAYER_CASE1", playername)
		}
		console_print(id, "%L", LANG_PLAYER, "AINO_ROCKET_PLAYER_SUCCESS", playername)
		log_amx("%L", LANG_SERVER, "AINO_LOG_ROCKET_PLAYER", name, playername)
	}
	rgmsgDamage = get_user_msgid("Damage")
	return PLUGIN_HANDLED
}

public plugin_precache() {
	mflash = precache_model("sprites/muzzleflash.spr")
	smoke = precache_model("sprites/steam1.spr")
	rmflash = precache_model("sprites/muzzleflash.spr")
	m_blueflare2 = precache_model("sprites/blueflare2.spr")
	rsmoke = precache_model("sprites/steam1.spr")
	white = precache_model("sprites/white.spr")
	light = precache_model("sprites/lgtning.spr")
	s2smoke = precache_model("sprites/steam1.spr")
	s2white = precache_model("sprites/white.spr")

	precache_sound("ambience/thunder_clap.wav")
	precache_sound("weapons/headshot2.wav")
	precache_sound("ambience/flameburst1.wav")
	precache_sound("scientist/scream21.wav")
	precache_sound("scientist/scream07.wav")
	precache_sound("weapons/rocketfire1.wav")
	precache_sound("weapons/rocket1.wav")
	return PLUGIN_CONTINUE
}
