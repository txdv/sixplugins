/*=============================================================================R=E=Y=M=O=N==A=R=G=*/
/* Create By ReymonARG										  */
/* 											          */
/* Alls bugs report by MsN or Email To webmaster@djreymon.com					  */
/* 												  */
/* More Information: http://forums.alliedmods.net/showthread.php?t=75606			  */
/* 												  */
/* This is the Version 5.6 Beta of This plugins visit the web for New Versions			  */
/* 												  */
/* New Version Dedicate to AeroCs Servers.						          */
/*												  */
/* Last Mod Modificate 04/12/2008								  */
/*												  */
/*=============================================================================R=E=Y=M=O=N==A=R=G=*/

/*================================================================================================*/
/***************************** [Includes & Defines & Arays] ***************************************/
/*=============================================================================R=E=Y=M=O=N==A=R=G=*/

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <hamsandwich>

/*-------------DONT CHANGE-------------*/
#define PLUGIN "WarmUP Pro"
#define VERSION "5.6 Beta"
#define AUTHOR "ReymonARG"
/*-------------DONT CHANGE-------------*/

#define time_delay 1 

#define ITEM_HE                (1<<0) // "a" 
#define ITEM_FS                (1<<1) // "b" 
#define ITEM_SG                (1<<2) // "c" 
#define ITEM_C4                (1<<3) // "d" 

#define HIDE_MONEY				(1<<5) // Disable Hud of Money
#define SHOW_MONEY				(1<<7) // Enable Hud of Money

new num_time, sync, time_s, activadoo, respawn3d, itemsxd, RGB, cvar_x, cvar_y, mode, timeprotect, 
ganador, mostrarhud, logtofilecvar

new bool:g_is_dead[33]; 
new bool:g_can_respawn; 
new bool:g_cuchi; 
new bool:g_items;
new bool:wup_on;
new bool:g_is_connect[33];
new bool:g_is_autofile;
new bool:g_mapexist_file;
new g_ganadores[33];
new const LOGFILE[] = "warmuppro.log"
new const FILECONFIGNAME[] = "/warmuppro.cfg"
new const FILEMAPSNAME[] = "/warmuppro_maps.cfg"

#define FLAG_ALIVE (1<<0)
#define FLAG_DEAD (1<<1)
#define FLAG_DISCONNECT (1<<2)

#define FLAG_T (1<<0)
#define FLAG_CT (1<<1)

#define DEFUSER 0
#define SHIELD 2

#define CONTAIN_FLAG_OF_INDEX(%1,%2) ((%1) & (1<<(%2)))

new const g_wbox_class[] = "weaponbox"
new const g_shield_class[] = "weapon_shield"
new const g_wbox_model[] = "models/w_weaponbox.mdl"
new const g_model_prefix[] = "models/w_"

new g_max_clients
new g_max_entities

new g_pcvar_allow

/* Foawrds */
new fwd_resultado;
new wup_fwd_start;
new wup_fwd_finish;
new wup_fwd_adminenable;
new wup_fwd_admindsaible;

/* Variables for Stocks */ 
new moneymsg;
new statusiconmsg;
new saytextmsg;
new hideweaponmsg;
new teaminfomsg;

/*================================================================================================*/
/************************************* [OFFSETS FAKEMETA] *****************************************/
/*=============================================================================R=E=Y=M=O=N==A=R=G=*/

#define EXTRAOFFSET_WEAPONS		4 
#define ACTUAL_EXTRA_OFFSET		20

#define OFFSET_ARMORTYPE		112
#define OFFSET_TEAM			114
#define OFFSET_CSMONEY			115
#define OFFSET_PRIMARYWEAPON		116
#define OFFSET_LASTACTIVITY		124
#define OFFSET_INTERNALMODEL		126
#define OFFSET_NVGOGGLES		129
#define OFFSET_DEFUSE_PLANT		193
#define OFFSET_VIP			209
#define OFFSET_TK			216 
#define OFFSET_HOSTAGEKILLS		217
#define OFFSET_MAPZONE			235
#define OFFSET_ISDRIVING		350 
#define OFFSET_STATIONARY		362 
#define OFFSET_ZOOMTYPE			363

#define OFFSET_AWM_AMMO			377 
#define OFFSET_SCOUT_AMMO		378
#define OFFSET_PARA_AMMO		379
#define OFFSET_FAMAS_AMMO		380
#define OFFSET_M3_AMMO			381
#define OFFSET_USP_AMMO			382
#define OFFSET_FIVESEVEN_AMMO		383
#define OFFSET_DEAGLE_AMMO		384
#define OFFSET_P228_AMMO		385
#define OFFSET_GLOCK_AMMO		386
#define OFFSET_FLASH_AMMO		387
#define OFFSET_HE_AMMO			388
#define OFFSET_SMOKE_AMMO		389
#define OFFSET_C4_AMMO			390

#define OFFSET_CSDEATHS			444 
#define OFFSET_SHIELD			510
// "weapon_*" entities
#define OFFSET_WEAPONTYPE		43 
#define OFFSET_CLIPAMMO			51 
#define OFFSET_SILENCER_FIREMODE	74 
// "hostage_entity" entities
#define OFFSET_HOSTAGEFOLLOW		86
#define OFFSET_HOSTAGE_NEXTUSE		100
#define OFFSET_HOSTAGE_LASTUSE		483
#define OFFSET_HOSTAGEID		487
// "armoury_entity"
#define OFFSET_ARMOURY_TYPE		34 
// C4 offsets
#define OFFSET_C4_EXPLODE_TIME		100
#define OFFSET_C4_DEFUSING		0x181 

#define M4A1_SILENCED			(1<<2)
#define M4A1_ATTACHSILENCEANIM		6
#define M4A1_DETACHSILENCEANIM		13
#define USP_SILENCED			(1<<0)
#define USP_ATTACHSILENCEANIM		7
#define USP_DETACHSILENCEANIM		15

#define GLOCK_SEMIAUTOMATIC		0
#define GLOCK_BURSTMODE			2
#define FAMAS_AUTOMATIC			0
#define FAMAS_BURSTMODE			16

#define PLAYER_IS_VIP			(1<<8)

#define PLAYER_IN_BUYZONE		(1<<0)

#define TEAM_UNASSIGNED			0
#define TEAM_T				1
#define TEAM_CT				2
#define TEAM_SPECTATOR			3

#define CAN_PLANT_BOMB			(1<<8) 
#define HAS_DEFUSE_KIT			(1<<16) 

#define DEFUSER_COLOUR_R		0
#define DEFUSER_COLOUR_G		160
#define DEFUSER_COLOUR_B		0

#define HAS_NVGOGGLES			(1<<0)
#define HAS_SHIELD     			(1<<24) 

#define SCOREATTRIB_NOTHING		0
#define SCOREATTRIB_DEAD		1
#define SCOREATTRIB_BOMB		2 
#define SCOREATTRIB_VIP			4 

#define CS_FIRST_ZOOM			0x28
#define CS_SECOND_AWP_ZOOM		0xA
#define CS_SECOND_NONAWP_ZOOM		0xF
#define CS_AUGSG552_ZOOM		0x37
#define CS_NO_ZOOM			0x5A


/*------------------------------------------------------------------------------------------------*/

enum CS_Internal_Models 
{
	CS_DONTCHANGE = 0,
	CS_CT_URBAN = 1,
	CS_T_TERROR = 2,
	CS_T_LEET = 3,
	CS_T_ARCTIC = 4,
	CS_CT_GSG9 = 5,
	CS_CT_GIGN = 6,
	CS_CT_SAS = 7,
	CS_T_GUERILLA = 8,
	CS_CT_VIP = 9,
	CZ_T_MILITIA = 10,
	CZ_CT_SPETSNAZ = 11
};

enum CsTeams 
{
	CS_TEAM_UNASSIGNED = 0,
	CS_TEAM_T = 1,
	CS_TEAM_CT = 2,
	CS_TEAM_SPECTATOR = 3
};


enum CsArmorType 
{
	CS_ARMOR_NONE = 0, 
	CS_ARMOR_KEVLAR = 1, 
	CS_ARMOR_VESTHELM = 2 
};

/*================================================================================================*/
/***************************************** [Stocks] ***********************************************/
/*=============================================================================R=E=Y=M=O=N==A=R=G=*/

#define fm_create_entity(%1) engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, %1))

stock fm_strip_user_weapons(index) {
	new ent = fm_create_entity("player_weaponstrip")
	if (!pev_valid(ent))
		return 0

	dllfunc(DLLFunc_Spawn, ent)
	dllfunc(DLLFunc_Use, ent, index)
	engfunc(EngFunc_RemoveEntity, ent)

	return 1
}

stock fm_give_item(index, const item[]) {
	if (!equal(item, "weapon_", 7) && !equal(item, "ammo_", 5) && !equal(item, "item_", 5) && !equal(item, "tf_weapon_", 10))
		return 0

	new ent = fm_create_entity(item)
	if (!pev_valid(ent))
		return 0

	new Float:origin[3]
	pev(index, pev_origin, origin)
	set_pev(ent, pev_origin, origin)
	set_pev(ent, pev_spawnflags, pev(ent, pev_spawnflags) | SF_NORESPAWN)
	dllfunc(DLLFunc_Spawn, ent)

	new save = pev(ent, pev_solid)
	dllfunc(DLLFunc_Touch, ent, index)
	if (pev(ent, pev_solid) != save)
		return ent

	engfunc(EngFunc_RemoveEntity, ent)

	return -1
}

stock fm_set_rendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16) {
	new Float:RenderColor[3];
	RenderColor[0] = float(r);
	RenderColor[1] = float(g);
	RenderColor[2] = float(b);

	set_pev(entity, pev_renderfx, fx);
	set_pev(entity, pev_rendercolor, RenderColor);
	set_pev(entity, pev_rendermode, render);
	set_pev(entity, pev_renderamt, float(amount));

	return 1;
}

stock fm_set_user_godmode(index, godmode = 0) {
	set_pev(index, pev_takedamage, godmode == 1 ? DAMAGE_NO : DAMAGE_AIM);

	return 1;
}

stock fm_set_user_money(index, money, flash = 1)
{
	set_pdata_int(index, OFFSET_CSMONEY, money);
	
	message_begin(MSG_ONE, moneymsg, {0,0,0}, index);
	write_long(money);
	write_byte(flash ? 1 : 0);
	message_end();
}

stock fm_set_user_plant(id, plant = 1, showbombicon = 1)
{
	new plantskill = get_pdata_int(id, OFFSET_DEFUSE_PLANT);

	if(plant)
	{
		plantskill |= CAN_PLANT_BOMB;
		set_pdata_int(id, OFFSET_DEFUSE_PLANT, plantskill);
		
		if(showbombicon)
		{
			message_begin(MSG_ONE, statusiconmsg, _, id);
			write_byte(1);
			write_string("c4");
			write_byte(DEFUSER_COLOUR_R);
			write_byte(DEFUSER_COLOUR_G);
			write_byte(DEFUSER_COLOUR_B);
			message_end();
		}
	}
	else
	{
		plantskill &= ~CAN_PLANT_BOMB;
		set_pdata_int(id, OFFSET_DEFUSE_PLANT, plantskill);
		message_begin(MSG_ONE, statusiconmsg, _, id);
		write_byte(0);
		write_string("c4");
		message_end();
	}
}

stock fm_set_user_defuse(id, defusekit = 1, r = DEFUSER_COLOUR_R, g = DEFUSER_COLOUR_G, b = DEFUSER_COLOUR_B, icon[] = "defuser", flash = 0)
{
	new defuse = get_pdata_int(id, OFFSET_DEFUSE_PLANT);

	if(defusekit)
	{
		new colour[3] = {DEFUSER_COLOUR_R, DEFUSER_COLOUR_G, DEFUSER_COLOUR_B}
		if(r != -1) colour[0] = r;
		if(g != -1) colour[1] = g;
		if(b != -1) colour[2] = b;
    
    		set_pev(id, pev_body, 1);

		defuse |= HAS_DEFUSE_KIT;
		set_pdata_int(id, OFFSET_DEFUSE_PLANT, defuse);
		
		message_begin(MSG_ONE, statusiconmsg, _, id);
		write_byte((flash == 1) ? 2 : 1);
		write_string(icon[0] ? icon : "defuser");
		write_byte(colour[0]);
		write_byte(colour[1]);
		write_byte(colour[2]);
		message_end();
	}

	else
	{
		defuse &= ~HAS_DEFUSE_KIT;
		set_pdata_int(id, OFFSET_DEFUSE_PLANT, defuse);
		message_begin(MSG_ONE, statusiconmsg, _, id);
		write_byte(0);
		write_string("defuser");
		message_end();
		
		set_pev(id, pev_body, 0);
	}
}

stock fm_set_user_bpammo(index, weapon, amount)
{
	new offset;
	
	switch(weapon)
	{
		case CSW_AWP: offset = OFFSET_AWM_AMMO;
		case CSW_SCOUT,CSW_AK47,CSW_G3SG1: offset = OFFSET_SCOUT_AMMO;
		case CSW_M249: offset = OFFSET_PARA_AMMO;
		case CSW_M4A1,CSW_FAMAS,CSW_AUG,CSW_SG550,CSW_GALI,CSW_SG552: offset = OFFSET_FAMAS_AMMO;
		case CSW_M3,CSW_XM1014: offset = OFFSET_M3_AMMO;
		case CSW_USP,CSW_UMP45,CSW_MAC10: offset = OFFSET_USP_AMMO;
		case CSW_FIVESEVEN,CSW_P90: offset = OFFSET_FIVESEVEN_AMMO;
		case CSW_DEAGLE: offset = OFFSET_DEAGLE_AMMO;
		case CSW_P228: offset = OFFSET_P228_AMMO;
		case CSW_GLOCK18,CSW_MP5NAVY,CSW_TMP,CSW_ELITE: offset = OFFSET_GLOCK_AMMO;
		case CSW_FLASHBANG: offset = OFFSET_FLASH_AMMO;
		case CSW_HEGRENADE: offset = OFFSET_HE_AMMO;
		case CSW_SMOKEGRENADE: offset = OFFSET_SMOKE_AMMO;
		case CSW_C4: offset = OFFSET_C4_AMMO;

		default:
		{
			new invalidMsg[20 + 7];
			formatex(invalidMsg,20 + 6,"Invalid weapon id %d",weapon);
			set_fail_state(invalidMsg);
			
			return 0;
		}
	}
	
	set_pdata_int(index,offset,amount);
	
	return 1;
}

/*-----------------------------------------GET----------------------------------------------------*/

stock CsTeams:fm_get_user_team(id, &{CS_Internal_Models,_}:model = CS_DONTCHANGE)
{
	model = CS_Internal_Models:get_pdata_int(id, OFFSET_INTERNALMODEL);

	return CsTeams:get_pdata_int(id, OFFSET_TEAM);
}

stock fm_get_weapon_id(weapon_id)
{
	if(is_linux_server())
	{
		#undef EXTRAOFFSET_WEAPONS
		#define EXTRAOFFSET_WEAPONS 4
	}
	else
	{
		#undef EXTRAOFFSET_WEAPONS
		#define EXTRAOFFSET_WEAPONS	0
	}
	
	return get_pdata_int(weapon_id, OFFSET_WEAPONTYPE, EXTRAOFFSET_WEAPONS)
}

stock fm_get_user_plant(id)
{
	if(get_pdata_int(id, OFFSET_DEFUSE_PLANT) & CAN_PLANT_BOMB)
		return 1;
		
	return 0;
}

stock fm_get_user_defuse(id)
{
	if(get_pdata_int(id, OFFSET_DEFUSE_PLANT) & HAS_DEFUSE_KIT)
		return 1;

	return 0;
}

/*------------------------------------------------------------------------------------------------*/
new const g_weapon_names[][] =
{
	"", // Null random 1 to X  This is 0
	"weapon_p228",
	"weapon_scout",
	"weapon_xm1014",
	"weapon_mac10",
	"weapon_aug",
	"weapon_elite",
	"weapon_fiveseven",
	"weapon_ump45",
	"weapon_sg550",
	"weapon_galil",
	"weapon_famas",
	"weapon_usp",
	"weapon_glock18",
	"weapon_awp",
	"weapon_mp5navy",
	"weapon_m249",
	"weapon_m3",
	"weapon_m4a1",
	"weapon_tmp",
	"weapon_g3sg1",
	"weapon_deagle",
	"weapon_sg552",
	"weapon_ak47",
	"weapon_p90"
};

/*-------------------------------------------*/
/*-----------WARMPUP GIVE WEAPON-------------*/
/*-------------------------------------------*/
stock wup_give_weapon(index, weapon[], balas)
{
	fm_give_item(index, weapon);
	new wpnid = get_weaponid(weapon)
	fm_set_user_bpammo(index, wpnid, balas)
}
/*-------------------------------------------*/
/*-----------WARMPUP GIVE WEAPON-------------*/
/*-------------------------------------------*/


/*================================================================================================*/
/*************************************** [Color Chat] *********************************************/
/*=============================================================================R=E=Y=M=O=N==A=R=G=*/


enum Color
{
	NORMAL = 1, // clients scr_concolor cvar color
	GREEN, // Green Color
	TEAM_COLOR, // Red, grey, blue
	GREY, // grey
	RED, // Red
	BLUE, // Blue
}

new TeamName[][] = 
{
	"",
	"TERRORIST",
	"CT",
	"SPECTATOR"
}

ColorChat(id, Color:type, const msg[], {Float,Sql,Result,_}:...)
{
	new message[256];

	switch(type)
	{
		case NORMAL: // clients scr_concolor cvar color
		{
			message[0] = 0x01;
		}
		case GREEN: // Green
		{
			message[0] = 0x04;
		}
		default: // White, Red, Blue
		{
			message[0] = 0x03;
		}
	}

	vformat(message[1], 251, msg, 4);

	// Make sure message is not longer than 192 character. Will crash the server.
	message[192] = '^0';

	new team, ColorChange, index, MSG_Type;
	
	if(id)
	{
		MSG_Type = MSG_ONE;
		index = id;
	} else {
		index = FindPlayer();
		MSG_Type = MSG_ALL;
	}
	
	team = get_user_team(index);
	ColorChange = ColorSelection(index, MSG_Type, type);

	ShowColorMessage(index, MSG_Type, message);
		
	if(ColorChange)
	{
		Team_Info(index, MSG_Type, TeamName[team]);
	}
}

ShowColorMessage(id, type, message[])
{
	message_begin(type, saytextmsg, _, id);
	write_byte(id)		
	write_string(message);
	message_end();	
}

Team_Info(id, type, team[])
{
	message_begin(type, teaminfomsg, _, id);
	write_byte(id);
	write_string(team);
	message_end();

	return 1;
}

ColorSelection(index, type, Color:Type)
{
	switch(Type)
	{
		case RED:
		{
			return Team_Info(index, type, TeamName[1]);
		}
		case BLUE:
		{
			return Team_Info(index, type, TeamName[2]);
		}
		case GREY:
		{
			return Team_Info(index, type, TeamName[0]);
		}
	}

	return 0;
}

FindPlayer()
{
	new i = -1;

	while(i <= get_maxplayers())
	{
		if(is_user_connected(++i))
			return i;
	}

	return -1;
}

/*================================================================================================*/
/**************************************** [Registers] *********************************************/
/*=============================================================================R=E=Y=M=O=N==A=R=G=*/

public plugin_init()  
{ 
	register_plugin(PLUGIN, VERSION, AUTHOR) 
	register_cvar("wup_version", VERSION, FCVAR_SERVER | FCVAR_SPONLY) 
	register_cvar("wup_author", AUTHOR, FCVAR_SERVER | FCVAR_SPONLY) 

	register_event("TextMsg","autostartrr","a","2&#Game_C"); 
	RegisterHam(Ham_Killed, "player", "FwdPlayerDeath", 1); 
	RegisterHam(Ham_Spawn, "player", "FwdPlayerSpawn", 1); 
	register_event("CurWeapon", "check_change", "be", "1=1");
	
	register_forward(FM_SetModel, "forward_set_model");
    
	g_pcvar_allow = register_cvar("wup_drop", "");
	logtofilecvar = register_cvar("wup_logtofile", "1");
	
	g_max_clients = global_get(glb_maxClients);
	g_max_entities = global_get(glb_maxEntities);
	
	sync = CreateHudSyncObj(); 
	register_dictionary( "warmuppro.txt" ); 
	register_dictionary( "common.txt" );
	
	if( get_pcvar_num(logtofilecvar) == 1 )
	{
		new mapita[64]
		get_mapname(mapita, 63)
		log_to_file(LOGFILE, "<----------: Map %s :----------->", mapita)
	}
	
	register_concmd("wup_disable","admin_exec1",ADMIN_BAN,"Stop the WarmUP")
	register_concmd("wup_enable","admin_exec2",ADMIN_BAN,"Start a new WarmUP")
	
	hideweaponmsg = get_user_msgid( "HideWeapon" );
	moneymsg = get_user_msgid( "Money" );
	statusiconmsg = get_user_msgid( "StatusIcon" );
	saytextmsg = get_user_msgid( "SayText" );
	teaminfomsg = get_user_msgid( "TeamInfo" );
	
	/*    CVARS   */
	activadoo = register_cvar("wup_autostart", "") 
	respawn3d = register_cvar("wup_respawn", "1") 
	itemsxd = register_cvar("wup_items", "abcd") 
	mode = register_cvar("wup_mode", "1") 
	num_time = register_cvar("wup_time","120") 
	RGB = register_cvar("wup_color", "255255255") 
	cvar_x = register_cvar("wup_setx", "-1.0") 
	cvar_y = register_cvar("wup_sety", "0.28") 
	timeprotect = register_cvar("wup_protecttime", "3")
	/*    5.0 News Cvars   */
	ganador = register_cvar("wup_winner", "1")
	mostrarhud = register_cvar("wup_showhud", "1")
	
	wup_fwd_start = CreateMultiForward("wup_startwarmup", ET_IGNORE);
	wup_fwd_finish = CreateMultiForward("wup_finishwarmup", ET_IGNORE);
	wup_fwd_adminenable = CreateMultiForward("wup_adminenable", ET_IGNORE, FP_CELL);
	wup_fwd_admindsaible = CreateMultiForward("wup_adminidsable", ET_IGNORE, FP_CELL);
} 

/*================================================================================================*/
/************************************ [Register Natives] ******************************************/
/*=============================================================================R=E=Y=M=O=N==A=R=G=*/

public plugin_natives()
{
	register_native("is_warmup_enable", "native_is_warmup_enable", 1);
	register_native("wup_timeleft", "native_wup_timeleft", 1);
	register_native("wup_get_user_kills", "native_wup_get_user_kills", 1);
}

/*================================================================================================*/
/*********************************** [File Config Cvars] ******************************************/
/*=============================================================================R=E=Y=M=O=N==A=R=G=*/

public plugin_cfg()
{
	new filename[64], filename2[64]
	get_configsdir(filename, 63);
	get_configsdir(filename2, 63);
	add(filename, 63, FILECONFIGNAME);
	add(filename2, 63, FILEMAPSNAME);
	
	if(file_exists(filename))
	{
		server_cmd("exec ^"%s^"",filename)
		
		if( get_pcvar_num(logtofilecvar) == 1 )
			log_to_file(LOGFILE, "Correct Exec: %s", filename)
	}
	else
	{
		if( get_pcvar_num(logtofilecvar) == 1 )
			log_to_file(LOGFILE, "Create Cvar Files")
		
		new mensajito[256]
		formatex(mensajito, 255, "; File location: $moddir/%s", filename)
		write_file(filename,"; WarmUP Configuration File")
		write_file(filename,mensajito)
		write_file(filename,";")
		write_file(filename,";/////////WARMUP PRO FILE\\\\\\\\\\;")
		write_file(filename,";/////////WARMUP PRO FILE\\\\\\\\\\;")
		write_file(filename,";")
		write_file(filename,";")
		write_file(filename,";Enable the WarmUP when the GameStart")
		write_file(filename,"wup_autostart 1")
		write_file(filename,";")
		write_file(filename,";")
		write_file(filename,";Enable the respawn is a player die in the WarmUP")
		write_file(filename,"wup_respawn 1")
		write_file(filename,";")
		write_file(filename,";")
		write_file(filename,";Items to give to a player in the respawn")
		write_file(filename,";A) Give HE B) Give FB C) Give SG")
		write_file(filename,";D) Give C4 to Terrorist And Defuse to CT.")
		write_file(filename,"wup_items ^"abcd^"")
		write_file(filename,";")
		write_file(filename,";")
		write_file(filename,";0) Normal Rounds  1) Weapon Chance  2) Knife")
		write_file(filename,"wup_mode 1")
		write_file(filename,";")
		write_file(filename,";")
		write_file(filename,";Set the during of the warmUP.")
		write_file(filename,"wup_time 120")
		write_file(filename,";")
		write_file(filename,";")
		write_file(filename,";Color of the Hud that show time remending.")
		write_file(filename,"wup_color ^"255255255^"")
		write_file(filename,";")
		write_file(filename,";")
		write_file(filename,";X Position of the hud")
		write_file(filename,"wup_setx ^"-1.0^"")
		write_file(filename,";")
		write_file(filename,";")
		write_file(filename,";Y Position of the hud")
		write_file(filename,"wup_sety ^"0.28^"")
		write_file(filename,";")
		write_file(filename,";")
		write_file(filename,";Set Time of SpawnProtection  0 = Disable")
		write_file(filename,"wup_protectime 3")
		write_file(filename,";")
		write_file(filename,";")
		write_file(filename,"; Show a Msg with the winner of the WarmUP")
		write_file(filename,"wup_winner ^"1^"")
		write_file(filename,";")
		write_file(filename,";")
		write_file(filename,"; Show Hud Wit htime remending")
		write_file(filename,"wup_showhud ^"1^"")
		write_file(filename,";")
		write_file(filename,";")
		write_file(filename,"; Enable Logs of the plugin")
		write_file(filename,"wup_logtofile ^"1^"")
		write_file(filename,";")
		write_file(filename,";")
		write_file(filename,";This plis dont change :D ")
		write_file(filename,"wup_drop ^"^" // This Dont change")
		write_file(filename,";")
		write_file(filename,";")
		write_file(filename,";")
		write_file(filename,";")
		write_file(filename,";/////////WARMUP PRO FILE\\\\\\\\\\;")
		write_file(filename,";/////////WARMUP PRO FILE\\\\\\\\\\;")
		write_file(filename,"echo WarmUP 5.6 Pro Cvars Enable.")
		write_file(filename,"echo WarmUP 5.6 Pro Create by ReymonARG")
		write_file(filename,";/////////WARMUP PRO FILE\\\\\\\\\\;")
		write_file(filename,";/////////WARMUP PRO FILE\\\\\\\\\\;")
		
		server_cmd("exec %s",filename)
	}
	
	if( !file_exists(filename2) )
	{
		if( get_pcvar_num(logtofilecvar) == 1 )
			log_to_file(LOGFILE, "Create Maps Configuration File")
		
		new mensajelol[256]
		formatex(mensajelol, 255, "; File location: $moddir/%s", filename2)
		write_file(filename2,"; WarmUP Mpas Configuration File")
		write_file(filename2,mensajelol)
		write_file(filename2,";")
		write_file(filename2,"; With this File you can Change the AutoStart of all yours maps")
		write_file(filename2,";")
		write_file(filename2,"; Example:  <mapname> <status>")
		write_file(filename2,"; ^"de_nuke^" ^"0^"")
		write_file(filename2,";")
		write_file(filename2,"; Prefix Example: <Prefix> <status> <P>")
		write_file(filename2,"; ^"cs_^" ^"0^" ^"P^"")
		write_file(filename2,";")
		write_file(filename2,"^"kz_^" ^"0^" ^"P^"")
	}
	
	enableordisable()
	
}

public enableordisable()
{
	new readdata[128],txtlen, filenamelala[64]
	new parsedmap[64], onoroff[32], prefixs[32]
	new mapitas[64]
	
	get_configsdir(filenamelala,63)
	add(filenamelala, 63, FILEMAPSNAME)
		
	new fsize = file_size(filenamelala,1)
	get_mapname(mapitas,63)
	g_mapexist_file = false;
	g_is_autofile = false;
	
	for (new line=0;line<=fsize;line++)
	{
		read_file(filenamelala,line,readdata,127,txtlen)
		parse(readdata,parsedmap,63,onoroff,31, prefixs, 31)
	
		new estaon = str_to_num(onoroff);
	
		if( equal(mapitas,parsedmap) || containi(prefixs, "P") != -1 && containi(mapitas, parsedmap) != -1 )
		{
			g_mapexist_file = true;
			g_is_autofile = estaon ? true : false
			
			if( get_pcvar_num(logtofilecvar) == 1 )
				log_to_file(LOGFILE, "WarmUP Pro: %s by File", estaon ? "ON" : "OFF")
			
			break;
		}
	}
}

/*================================================================================================*/
/********************************** [Srting Flags A B C D] ****************************************/
/*=============================================================================R=E=Y=M=O=N==A=R=G=*/

public get_item_flags() 
{ 
	new sFlags[24] 
	get_pcvar_string(itemsxd,sFlags,23) 
	return read_flags(sFlags) 
} 

/*================================================================================================*/
/************************************* [No Weapon Drop] *******************************************/
/*=============================================================================R=E=Y=M=O=N==A=R=G=*/

public forward_set_model(ent, const model[]) 
{
	
	if( wup_on && get_pcvar_num(mode) == 1 || wup_on && get_pcvar_num(mode) == 2)
	{
		if (!pev_valid(ent) || !equali(model, g_model_prefix, sizeof g_model_prefix - 1) || equali(model, g_wbox_model))
			return FMRES_IGNORED
		
		new id = pev(ent, pev_owner)
		if (!(1 <= id <= g_max_clients))
			return FMRES_IGNORED
		
		new weapon
		static class[32]
		pev(ent, pev_classname, class, sizeof class - 1)
		if (equal(class, g_shield_class))
			weapon = SHIELD
		else if (!equal(class, g_wbox_class))
			return FMRES_IGNORED
		
		new cvar_state = 7
		new cvar_teams = 3
		new cvar_allow = get_pcvar_num(g_pcvar_allow)
		if (cvar_state <= 0 || cvar_teams <= 0)
			return FMRES_IGNORED
		
		new state_, team
		if (!is_user_connected(id)) {
			state_ = FLAG_DISCONNECT
			team = FLAG_T // on disconnect only T can drop weapon (the bomb only)
		}
		else if (!is_user_alive(id))
			state_ = FLAG_DEAD
		else
			state_ = FLAG_ALIVE
		
		if (!(cvar_state & state_))
			return FMRES_IGNORED
		
		if (state_ != FLAG_DISCONNECT) 
		{
			new CsTeams:equipo = fm_get_user_team(id)
			switch( equipo ) 
			{
				case CS_TEAM_T: 
				{
					team = FLAG_T
				}
				
				case CS_TEAM_CT:
				{
					team = FLAG_CT
				}
			}
		}
		
		if (!(cvar_teams & team))
			return FMRES_IGNORED
		
		if (weapon == SHIELD) 
		{
			if (!CONTAIN_FLAG_OF_INDEX(cvar_allow, SHIELD)) 
			{
				set_pev(ent, pev_effects, EF_NODRAW)
				set_task(0.1, "task_remove_shield", ent) // we even can't use nextthink, that will not work
			}
		
			return FMRES_IGNORED
		}
		
		for (new i = g_max_clients + 1; i < g_max_entities; ++i) 
		{
			if (!pev_valid(i) || ent != pev(i, pev_owner))
				continue
		
			if (!CONTAIN_FLAG_OF_INDEX(cvar_allow, fm_get_weapon_id(i)))
				dllfunc(DLLFunc_Think, ent)
			
			return FMRES_IGNORED
		}
		
	}
	return FMRES_IGNORED
}

public task_remove_shield(ent) 
{
	if(wup_on && get_pcvar_num(mode) == 1 || wup_on && get_pcvar_num(mode) == 2)
	{
		dllfunc(DLLFunc_Think, ent)
	}
}

/*================================================================================================*/
/************************************ [Respawn Player] ********************************************/
/*=============================================================================R=E=Y=M=O=N==A=R=G=*/

public TaskCheckAlive(plr) 
{ 
	if( !g_can_respawn ) 
	{ 
		return;
	} 
     
	new CsTeams:team = fm_get_user_team(plr); 
	if( team == CS_TEAM_UNASSIGNED || team == CS_TEAM_SPECTATOR ) 
	{ 
		set_task(1.0, "TaskCheckAlive", plr); 
         
		return; 
	} 
     
	if( g_is_dead[plr] ) 
	{ 
		ExecuteHamB(Ham_CS_RoundRespawn, plr); 
	} 
} 

/*================================================================================================*/
/********************************** [Connect  & Desconnect] ***************************************/
/*=============================================================================R=E=Y=M=O=N==A=R=G=*/

public client_putinserver(plr) 
{ 
	if( wup_on ) 
	{ 
		set_task(2.0, "connectrespawn", plr); 
		g_is_connect[plr] = true;
		g_ganadores[plr] = 0;
	}     
} 

public connectrespawn(plr)
{	
	if( !wup_on )
		return;
		
	if( is_user_alive(plr) )
		return;
	
	new CsTeams:team = fm_get_user_team(plr); 
	if( team == CS_TEAM_UNASSIGNED || team == CS_TEAM_SPECTATOR ) 
	{ 
		set_task(1.0, "connectrespawn", plr); 
         
		return;
	} 
     
	if( g_is_connect[plr] ) 
	{ 
		ExecuteHamB(Ham_CS_RoundRespawn, plr); 
		g_is_connect[plr] = false;
	}
}

public client_disconnect(plr) 
{ 
	remove_task(plr); 
	g_ganadores[plr] = 0;
} 

/*================================================================================================*/
/************************************** [Player Death] ********************************************/
/*=============================================================================R=E=Y=M=O=N==A=R=G=*/

public FwdPlayerDeath(plr, idattacker) 
{ 
	g_is_dead[plr] = true; 
     
	if(get_pcvar_num(respawn3d) == 1) 
	{ 
		set_task(2.0, "TaskCheckAlive", plr); 
	} 
	
	if( wup_on && get_pcvar_num(ganador) == 1 && fm_get_user_team(plr) != fm_get_user_team(idattacker) && is_user_connected(idattacker) )
	{
		g_ganadores[idattacker]++;
	}
	else if( wup_on && get_pcvar_num(ganador) == 1 && fm_get_user_team(plr) == fm_get_user_team(idattacker) && is_user_connected(idattacker) )
	{
		g_ganadores[idattacker]--;
	}
		
	
	if(wup_on && get_pcvar_num(mode) == 1 || wup_on && get_pcvar_num(mode) == 2)
	{
		if (!(7 & FLAG_DEAD) || !(3 & FLAG_CT) || !fm_get_user_defuse(plr))
			return
			
		if (CONTAIN_FLAG_OF_INDEX(get_pcvar_num(g_pcvar_allow), DEFUSER))
			return
			
		fm_set_user_defuse(plr, 0)
		set_pev(plr, pev_body, 0) // backward compatibility
	}
}

/*================================================================================================*/
/*************************************** [Player Spawn] *******************************************/
/*=============================================================================R=E=Y=M=O=N==A=R=G=*/
	
public FwdPlayerSpawn(plr) 
{
	if( is_user_alive(plr)) 
	{ 
		g_is_dead[plr] = false; 
		
		if( g_can_respawn && wup_on && get_pcvar_num(timeprotect) != 0 )
		{
			set_task(0.1, "wup_protect", plr)
		}
		
		if( wup_on && get_pcvar_num(mode) == 1 || wup_on && get_pcvar_num(mode) == 2)
		{
			fm_set_user_money(plr, 0)
			HideMoney(plr)
		}
		
		if(wup_on && get_pcvar_num(mode) == 1)
		{
			new rand = random_num(1,sizeof(g_weapon_names) -1);
			fm_strip_user_weapons(plr)
			fm_give_item(plr, "weapon_knife")
			wup_give_weapon(plr, g_weapon_names[rand], 250)
			set_task(0.1, "giveitems", plr)
		}
	} 
} 

/*================================================================================================*/
/************************************ [Spawn Protection] ******************************************/
/*=============================================================================R=E=Y=M=O=N==A=R=G=*/

public wup_protect(plr)
{
	new Float:ProtecTime = get_pcvar_float(timeprotect)
	if( wup_on && get_pcvar_num(timeprotect) != 0 )
	{
		if(get_user_team(plr) == 1)
		{
			fm_set_rendering(plr, kRenderFxGlowShell, 255, 0, 0, kRenderNormal, 26)
			fm_set_user_godmode(plr, 1)
		}
		
		if(get_user_team(plr) == 2)
		{
			fm_set_rendering(plr, kRenderFxGlowShell, 0, 0, 255, kRenderNormal, 26)
			fm_set_user_godmode(plr, 1)
		}
		
		set_task(ProtecTime, "desprotect", plr)
	}
}

public desprotect(plr)
{
	fm_set_rendering(plr, kRenderFxGlowShell, 0, 0, 0, kRenderNormal, 26)
	fm_set_user_godmode(plr, 0)
}

/*================================================================================================*/
/*************************************** [Give Items] *********************************************/
/*=============================================================================R=E=Y=M=O=N==A=R=G=*/
	

public giveitems(plr)
{
	new iFlags = get_item_flags() 
	new CsTeams:team = fm_get_user_team(plr); 
	if( g_items ) 
	{ 
		if (iFlags&ITEM_HE) 
		{ 
			fm_give_item(plr,"weapon_hegrenade") 
		} 
             
		if(iFlags&ITEM_FS) 
		{ 
			fm_give_item(plr,"weapon_flashbang") 
		} 
             
		if(iFlags&ITEM_SG) 
		{ 
			fm_give_item(plr,"weapon_smokegrenade") 
		} 
             
		if( team == CS_TEAM_CT && iFlags&ITEM_C4 ) 
		{ 
			fm_give_item(plr, "item_thighpack") 
		} 
             
		if( team == CS_TEAM_T && iFlags&ITEM_C4 ) 
		{ 
			fm_give_item(plr, "weapon_c4") 
			fm_set_user_plant(plr, 1, 1)
		} 
	}
}

/*================================================================================================*/
/********************************* [Remove Players Weapons] ***************************************/
/*=============================================================================R=E=Y=M=O=N==A=R=G=*/

public check_change(plr) 
{ 
	if(get_pcvar_num(mode) == 2)
	{ 
		if( g_cuchi )
		{ 
			new wpnid = read_data(2) 
			if( !(wpnid == CSW_KNIFE || wpnid == CSW_HEGRENADE || wpnid == CSW_FLASHBANG || wpnid == CSW_SMOKEGRENADE || wpnid == CSW_C4) ) 
			{ 
				set_task(0.1, "remove", plr); 
				fm_set_user_money(plr, 0);  
				HideMoney(plr)
			} 
		} 
	}
} 


public remove(plr) 
{ 
	fm_strip_user_weapons(plr) 
	fm_give_item(plr,"weapon_knife")
	fm_set_user_money(plr, 0);
	set_task(0.1, "giveitems", plr)
} 

/*================================================================================================*/
/******************************** [Remove Huds From Players] **************************************/
/*=============================================================================R=E=Y=M=O=N==A=R=G=*/

public HideMoney(plr)
{
	if( wup_on && get_pcvar_num(mode) == 1 || wup_on && get_pcvar_num(mode) == 2)
	{
		message_begin( MSG_ONE, hideweaponmsg, _, plr );
		write_byte( HIDE_MONEY );
		message_end();
	}
	
	if( !(wup_on) || get_pcvar_num(mode) == 0)
	{
		message_begin( MSG_ONE, hideweaponmsg, _, plr );
		write_byte( SHOW_MONEY );
		message_end();
	}
}

/*================================================================================================*/
/************************************ [Admins Commands] *******************************************/
/*=============================================================================R=E=Y=M=O=N==A=R=G=*/

public admin_exec1(plr, level)
{	
	if(!access(plr, level))
	{
		client_print(plr, print_console, "%L", plr, "NO_ACC_COM")
		return PLUGIN_HANDLED
	}
	
	set_cvar_float("sv_restartround",1.0);
	batata()
	g_can_respawn = false; 
	g_cuchi = false; 
	g_items = false; 
	wup_on = false; 
	remove_task(plr); 
	new name[32]
	get_user_name(plr, name, 31)
	
	if( get_pcvar_num(logtofilecvar) == 1 )
		log_to_file(LOGFILE, "ADMIN: %s Disable WarmUP", name);
		
	
	client_print(plr, print_console, "[WUP] WarmUP Pro DISABLED")
	ColorChat(0, GREEN,"^x04[WUP] ADMIN:^x03 %s^x04 Set WarmUP Pro DISABLE", name)
	ExecuteForward(wup_fwd_admindsaible, fwd_resultado, plr);
	
	return PLUGIN_HANDLED
}
	
public admin_exec2(plr, level)
{
	if(!access(plr, level))
	{
		client_print(plr, print_console, "%L", plr, "NO_ACC_COM")
		return PLUGIN_HANDLED
	}
	
	if( wup_on )
		return PLUGIN_HANDLED
	
	time_s = get_pcvar_num(num_time) 
	set_task(float(time_delay),"restart_time") 
	
	batata()
	set_cvar_float("sv_restartround",1.0);
	g_can_respawn = true; 
	g_cuchi = true; 
	g_items = true; 
	wup_on = true;
	new iFlags = get_item_flags()
	if( !(iFlags&ITEM_C4) )
	{
		set_pcvar_num(g_pcvar_allow, 64)
	}
	
	new name[32]
	get_user_name(plr, name, 31)
	
	if( get_pcvar_num(logtofilecvar) == 1 )
		log_to_file(LOGFILE, "ADMIN: %s Start a New WarmUP", name);
		
	
	client_print(plr, print_console, "[WUP] WarmUP Pro Enable")
	ColorChat(0, GREEN,"^x04[WUP] ADMIN:^x03 %s^x04 Set WarmUP Pro Enable", name)
	ExecuteForward(wup_fwd_adminenable, fwd_resultado, plr);
		
	return PLUGIN_HANDLED
}

/*================================================================================================*/
/****************************** [Exec Time And Clean Arrays] **************************************/
/*=============================================================================R=E=Y=M=O=N==A=R=G=*/

public autostartrr(plr) 
{ 	
	if( g_mapexist_file && !g_is_autofile )
	{
		g_can_respawn = false;
		g_cuchi = false; 
		g_items = false; 
		wup_on = false;	
		remove_task(plr); 
		
		return;
	}
	
	if(get_pcvar_num(activadoo) == 0) 
	{ 
		if( g_mapexist_file && g_is_autofile )
		{
			//do nothing
		}
		else
		{
			g_can_respawn = false;
			g_cuchi = false; 
			g_items = false; 
			wup_on = false;
			
			if( get_pcvar_num(logtofilecvar) == 1 )
				log_to_file(LOGFILE, "WarmUP AutoStart Off")
			
			remove_task(plr); 
		}
	} 
	
	if(get_pcvar_num(activadoo) == 1 || g_mapexist_file && g_is_autofile)
	{ 
		time_s = get_pcvar_num(num_time) 
		set_task(float(time_delay),"restart_time")
		ExecuteForward(wup_fwd_start, fwd_resultado)
		//g_ganadores[0] = 0;
		wup_on = true;
		g_can_respawn = true; 
		g_cuchi = true; 
		g_items = true; 
		
		if( get_pcvar_num(logtofilecvar) == 1 )
			log_to_file(LOGFILE, "WarmUP AutoStart On");
			
		
		new iFlags = get_item_flags()
		if( !(iFlags&ITEM_C4) )
		{
			set_pcvar_num(g_pcvar_allow, 64)
		}
	} 
} 

/*================================================================================================*/
/*********************************** [Show Time & Restart] ****************************************/
/*=============================================================================R=E=Y=M=O=N==A=R=G=*/

public restart_time() 
{ 
	new color[10] 
	new r
	new g
	new b
	get_pcvar_string(RGB, color, 9) 
	new c = str_to_num(color) 
	r = c / 1000000 
	c %= 1000000  
	g = c / 1000 
	b = c % 1000 
     
	if(wup_on && time_s >= 0) 
	{  
		ClearSyncHud(0, sync)
		
		if(time_s < 1) 
		{ 
			set_cvar_float("sv_restartround",2.0);
			g_can_respawn = false; 
			g_cuchi = false; 
			g_items = false; 
		}
		
		if(time_s == 0)
		{
			wup_on = false;
			
			if( get_pcvar_num(logtofilecvar) == 1 )
				log_to_file(LOGFILE, "WarmUP Finish")
			
			ExecuteForward(wup_fwd_finish, fwd_resultado)
			
			if( get_pcvar_num(ganador) == 1 )
				darresultado()
		}
		
		if( get_pcvar_num(mostrarhud) == 1 )
		{
			set_hudmessage( r, g, b, get_pcvar_float(cvar_x), get_pcvar_float(cvar_y), 1, 6.0, 6.0); 
			ShowSyncHudMsg(0, sync, "%L", LANG_PLAYER, "MP_DISPLAY", time_s);
		}
		
		--time_s; 
		set_task(1.0,"restart_time")
	}
} 

/*================================================================================================*/
/************************************** [Winner Info] *********************************************/
/*=============================================================================R=E=Y=M=O=N==A=R=G=*/

public darresultado()
{
	new resultadofinal = 0
	new name[32]
	new mensajes[256]
	new bool:g_muchos
	mensajes[0] = 0;
	name[0] = 0;
	g_muchos = false;
	resultadofinal = 0
	
	for(new i = 1; i <= 32 ; i++)
	{
	
		if( g_ganadores[i] == resultadofinal )
		{
			g_muchos = true;
			get_user_name(i, name, 31)
			
			formatex(mensajes, 255, "%s, %s", mensajes, name)
		}
		
		if( g_ganadores[i] > resultadofinal )
		{
			name[0] = 0;
			mensajes[0] = 0;
			g_muchos = false;
			resultadofinal = g_ganadores[i]
			get_user_name(i, name, 31)
			formatex(mensajes, 255, "%s", name)
		}
	}
	
	if( resultadofinal >= 1 )
	{
		if( !g_muchos )
		{
			ColorChat(0, GREEN, "^x04[WUP] The winner is:^x03 %s^x04 with^x03 %d^x04 Flags", name, resultadofinal)
			
			if( get_pcvar_num(logtofilecvar) == 1 )
				log_to_file(LOGFILE, "The Winner of WarmUP was: %s with %d Flags", name, resultadofinal)
			
		}
		else if( g_muchos )
		{
			ColorChat(0, GREEN, "^x04[WUP] ^x03%s ^x04 Win the WarmUP Rounds with^x03 %d^x04 Flags", mensajes, resultadofinal)
			
			if( get_pcvar_num(logtofilecvar) == 1 )
				log_to_file(LOGFILE, "%s Win the WarmUP Rounds with %d Flags", mensajes, resultadofinal)
			
		}
	}
	
	if( resultadofinal == 0 )
	{
		ColorChat(0, GREEN, "[WUP] NoBody won the WarmUP Round")
		
		if( get_pcvar_num(logtofilecvar) == 1 )
			log_to_file(LOGFILE, "NoBody won the WarmUP Round")
		
	}
	
	batata()
		
}


public batata()
{
	for(new i = 0; i <= 32 ; i++)
	{
		g_ganadores[i] = 0;
	}
}

/*================================================================================================*/
/***************************************** [Navites] **********************************************/
/*=============================================================================R=E=Y=M=O=N==A=R=G=*/

public native_is_warmup_enable()
{
	return wup_on;
}

public native_wup_timeleft()
{
	return time_s;
}

public native_wup_get_user_kills(id)
{
	return g_ganadores[id];
}

/*================================================================================================*/
/********************************** [Create By ReymonARG] *****************************************/
/*=============================================================================R=E=Y=M=O=N==A=R=G=*/
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang11274\\ f0\\ fs16 \n\\ par }
*/
