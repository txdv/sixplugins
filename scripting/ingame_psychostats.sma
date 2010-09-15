/* 	
	Plugin: Ingame Psychostats
	Current Version: 1.0.015
	
	Author: Nextra
	E-Mail: nextra.24@gmail.com
	
	Support-Thread: http://forums.alliedmods.net/showthread.php?t=123754
	
		AMX Mod X script.
		
		This program is free software; you can redistribute it and/or modify it
		under the terms of the GNU General Public License as published by the
		Free Software Foundation; either version 2 of the License, or (at
		your option) any later version.

		This program is distributed in the hope that it will be useful, but
		WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
		General Public License for more details.

		You should have received a copy of the GNU General Public License
		along with this program; if not, write to the Free Software Foundation,
		Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

		In addition, as a special exception, the author gives permission to
		link the code of this program with the Half-Life Game Engine ("HL
		Engine") and Modified Game Libraries ("MODs") developed by Valve,
		L.L.C ("Valve"). You must obey the GNU General Public License in all
		respects for all of the code used other than the HL Engine and MODs
		from Valve. If you modify this file, you may extend this exception
		to your version of the file, but you are not obligated to do so. If
		you do not wish to do so, delete this exception statement from your
		version.

		
	.: Description
	
		This plugin provides a feature-rich, SQL-based, ingame interface for Psychostats (www.psychostats.com).
		
	.: Features
	
		- Show Skill
		- Show Skillstats
		- Show Top X
		- Ingame menu
		- Extended whois information request for admins
		- Ingame registration for users
		- Support for all GoldSrc mods Psychostats features
		- Threaded Querying does everything in the background so it will not interfere with your gameplay
		
	.: Cvars
	
		ps_host "" 			- DB host
		ps_user "" 			- DB user
		ps_pass "" 			- DB pass
		ps_db	"" 			- DB
		ps_prefix "" 		- Table prefix
		ps_site "" 			- The site that is displayed ingame
		ps_func 			- Which functions should be enabled, add the numbers to get your configuration:
						1 - /skill, /skillme
						2 - /skilltop#, /skill15
						4 - /skillstats
						8 - /whois
						16 - connect messages
						32 - disconnect messages
		ps_ads <0|1> 		- 1 = enable, 0 = disable advertising of commands
		ps_adfreq 			- Frequency of ad messages (float!)
		ps_floodp 			- Flood protection. Delay between skill commands in seconds (float!)
		ps_allowreg <0|1>	- 1 = enable, 0 = disable possibility for users to register from within the game
		ps_hidechat <0|1>	- 1 = do, 0 = don't hide chat commands (/skillme and /whois are always hidden)
		ps_menu <0|1>		- 1 = enable, 0 = disable ingame menu
		ps_onlymenu <0|1|2>	- Controls forcing menu output for all commands. 2 = enable, 1 = enable for all except /skill, 0 = disable forcing menus
						0 - Disable forced menu output. Toplists, Player Stats and Whois will open up in an MOTD window, Skill commands will display in chat.
						1 - Force menu output for all commands except /skill. 
							On this setting, /skill will still output a chat line in addition to the menu so players can still show their rank for the bragging rights.
						2 - Force menu output for all commands. No MOTD windows will show, /skill and /skillme will output in menu-only.
						If this cvar is enabled either way, ps_menu will have no effect.
		ps_showheading		- Which headings to display when commands are used, add the numbers to get your configuration (0 = headings disabled):
						1 - Ad Heading ("This server is using Psychostats")
						2 - Rank Heading ("Your Psychostats ranking")
		ps_showversion <1|0>- 1 = show, 0 = don't show used Psychostats version

	.: Commands
	
		say or say_team:
		
		/skill
			Will print the players rank into the chat with a brief overview of stats.
		/skillme
			Does the same but will display only to the player him/herself.
		/skilltop
			Will display the top 15 players. It is possible to pass a number with it to show any other ranks from #-14 to #
		/skill15
			Will display the top 15 players.
		/skillstats
			Shows an advanced overview of the players stats. It is possible to pass a name or #userid to show the stats of any player on the server.
		/skillmenu
			Opens the menu.
			
		console:
		
		skillmenu
			Opens the menu.
			
		ps_reg USERNAME PASSWORD
			Will attempt to register the player.
	
	.: Admincommands
	
		say or say_team:
		
		/whois
			A whois request with even more stats, most used names, ip, access, onlinetime etc. It is possible to pass a name or #userid.
			
		console:
		
		ps_adnow
			Instantly display ads.
			
	.: Credits
	
		- Thanks to tramp for ps31. Ingame Psychostats started merely as an enhancement of ps31 before I made major feature implementations  and a complete rewrite
			to make Ingame Psychostats what it is today. (Original release thread: http://www.psychostats.com/forums/index.php?showtopic=17607)
		- Thanks to teame06 and all contributors for the ColorChat function.
			
	.: Notes
		
		#1 - The file ig_ps.cfg will be automatically executed if you put it into the amxmodx/configs folder. However this is not required and you can use your favorite cfg file to set up this plugin.

		#2 - I do not know which mods support this plugin to what extent. It was tested and confirmed working on CS, CZERO, DOD and TFC but the
		experience varies between different mods. If you plan to run this plugin on a different mod it is very important that you give feedback on the plugins performance. 
		If a mod does not support MOTD windows at all please let me	know aswell. I already implemented a system to force menu output over any cvar setting 
		of ps_menu/ps_menuonly and will add mods to the list that can not even open plain text MOTDs.
		
		Current list of support levels:
			
			Perfect Support:
				- Counter-Strike (HTML MOTDs, colored menus & chat)
				- Counter-Strike Condition Zero (HTML MOTDs, colored menus & chat)
			
			Limited Support:
				- Day of Defeat (HTML MOTDs, colored menus, no colored chat)
				- Team Fortress Classic (plain text MOTDs, no colored menus & chat)
				
			Poor Support:
				- Natural Selection (no MOTDs at all, only uncolored menus & chat)
				
		
		Natural Selection support level is based on tests I did for my Voiceserver Connect plugin. The show_motd native is broken for that mod.
		
		#3 - This plugin can cause a lot of database traffic depending on which features you enable and how your players use the system. If your SQL
		server is already struggling with Psychostats itself you should keep careful watch over your database load. Maybe deactivate frequently
		called features such as connect/disconnect messages or disable functions with extensive queries such as the whois lookup or the top15.
		
	.: Changelog
		
		* 1.0.000
		- Initial Release
		* 1.0.001
		- Fixed string formatting error.
		* 1.0.015
		- Added two new cvars based on user request: ps_showheading and ps_showversion
		- Some minor efficiency tweaks
		- Fixed message (MSG_ONE w/o target entity) errors that would crash the server
*/

#include <amxmodx>
#include <amxmisc>
#include <sqlx>

#pragma semicolon 1
#pragma ctrlchar '\'
#pragma dynamic 16384

new const PREFIX[] = "[PS]";

const ADMIN_LEVEL = ADMIN_BAN;

//----------------------------------------------------------------------------------------
// Do not change anything below this line if you don't know exactly what you are doing!
//----------------------------------------------------------------------------------------
new const PLUGIN[]	= "Ingame Psychostats";
new const VERSION[]	= "1.0.015";
new const AUTHOR[]	= "Nextra";

/** 
	General 
**/
const TASK_AD		= 38500;
const TASK_CONMSG	= 68500;

const ALL_KEYS = MENU_KEY_0|MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9;

new p_Host, p_User, p_Pass, p_Db, p_Pref, p_Site, p_Func, p_Ads, p_AdFreq, p_Floodp, 
	p_AllowReg, p_HideChat, p_Menu, p_OnlyMenu, p_ShowHeading, p_ShowVersion;

new g_iMaxPlayers;

new g_Site[64], g_Prefix[16], g_Version[8], g_szBuffer[1440];

new Float:g_FloodLast[33];

enum STORAGE
{
	NAME,
	AUTH,
	USER,
	PASS
};

enum _:SHOWHEADING
{
	ADSHEAD,
	RANKHEAD
};

new g_szStorage[33][STORAGE][64];

/** 
	Mod dependence
**/
enum MOD
{
	INVALID,
	CSTRIKE,
	CZERO,
	DOD,
	TFC,
	NS
};

new const g_szMods[MOD][ ] =
{
	"",
	"cstrike",
	"czero",
	"dod",
	"tfc",
	"ns"
};

new g_szGenericMsg[32], g_szColoredMsg[32], g_szGenericMsgSite[32];

new bool:g_bForceMenu;

new g_szHTMLBody[] = "<body bgcolor=#000000><font color=#FFB000><pre>", g_szWhoisSeparator[32] = "<hr>";

enum MENU_COLORS
{
	M_WHITE,
	M_GREY,
	M_YELLOW,
	M_RED,
	M_RALIGN
};

new g_Clr[MENU_COLORS][3];

/** 
	SQL
**/
new g_szQuery[1024];

enum _:FUNCTION_IDENTIFIER
{					// ps_func
	SHOW_SKILL,		//	1
	SHOW_TOP,		//	2
	SHOW_STATS,		//	4
	SHOW_WHOIS, 	//	8
	SHOW_CONMSG,	//	16
	SHOW_DISMSG,	//	32
	HANDLE_REG,
	FINISH_REG,
	HANDLE_VER
};

enum _:SQL_TYPE
{
	HANDLE_QRY,
	HANDLE_CHAT,
	HANDLE_MENU
};

new Handle:g_SqlTuple;

new bool:g_bRegistering[33];

/** 
	Menu
**/
enum _:WHOIS_MENU
{
	TARGET,
	LOCATION
};

enum _:WHOIS_LOCATION
{
	START,
	DATA,
	NAMES,
	STATS
};

new g_WhoisMenu[33][WHOIS_MENU];

enum _:PLAYERSELECTION_INFORMATION
{
	POSITION,
	TYPE,
	PLAYERS[33]
};

new g_PlayerSelectionMenu[33][PLAYERSELECTION_INFORMATION], bool:g_bBackToMainMenu[33];

/** 
	Commands
**/
enum COMMANDS
{
	CMD_SKILL,
	CMD_SKILLME,
	CMD_SKILLTOP,
	CMD_SKILL15,
	CMD_SKILLSTATS,
	CMD_SKILLMENU,
	SPERATOR_ADMIN_COMMANDS,
	A_CMD_WHOIS
};

new const g_szCommands[ COMMANDS ][ ] =
{
	"/skill",
	"/skillme",
	"/skilltop",
	"/skill15",
	"/skillstats",
	"/skillmenu",
	"",
	"/whois"
};

// COLORCHAT.sma
new g_msgid_TeamInfo, g_msgid_SayText;

enum Color
{
	RED = 1,	// Red
	BLUE,		// Blue
	GREY,		// grey
	YELLOW,		// Yellow
	GREEN,		// Green Color
	TEAM_COLOR	// Red, grey, blue
};

new TeamName[ ][ ] = 
{
	"",
	"TERRORIST",
	"CT",
	"SPECTATOR"
};

new bool:g_bIsBot[33], bool:g_bIsHLTV[33];
//-------------------------------------------------

#define check_bit(%1,%2) ( %1 & (1<<%2) )
#define is_bot(%1) g_bIsBot[%1]
#define is_hltv(%1) g_bIsHLTV[%1]

public plugin_init( )
{
	register_plugin( PLUGIN, VERSION, AUTHOR );
	
	register_cvar( "igps_version", VERSION, FCVAR_SERVER|FCVAR_SPONLY );

	g_msgid_TeamInfo	= get_user_msgid( "TeamInfo" ),
	g_msgid_SayText		= get_user_msgid( "SayText"	);
	
	register_clcmd( "say"		, "HANDLE_say" );
	register_clcmd( "say_team"	, "HANDLE_say" );
	register_clcmd( "ps_reg"	, "PREPARE_reg"	, -1			, "username password"			);
	register_clcmd( "ps_adnow"	, "SHOW_ad"		, ADMIN_LEVEL	, "- instantly show PS ads"		);
	register_clcmd( "skillmenu"	, "MENU_cmd"	, -1			, "- show psychostats menu"		);
	
	register_menu( "MENU_main"				, ALL_KEYS, "MENU_handle_main"		);
	register_menu( "MENU_skill"				, ALL_KEYS, "MENU_handle_skill"		);
	register_menu( "MENU_stats"				, ALL_KEYS, "MENU_handle_stats"		);
	register_menu( "MENU_top"				, ALL_KEYS, "MENU_handle_top"		);
	register_menu( "MENU_whois"				, ALL_KEYS, "MENU_handle_whois"		);
	register_menu( "MENU_playerselection"	, ALL_KEYS, "MENU_handle_player"	);
	
	p_Host			= register_cvar( "ps_host"			, "", FCVAR_PROTECTED	),
	p_User			= register_cvar( "ps_user"			, "", FCVAR_PROTECTED	),
	p_Pass			= register_cvar( "ps_pass"			, "", FCVAR_PROTECTED	),
	p_Db			= register_cvar( "ps_db"			, "", FCVAR_PROTECTED	),
	p_Pref			= register_cvar( "ps_prefix"		, "", FCVAR_PROTECTED	),
	p_Site			= register_cvar( "ps_site"			, "" 					),
	p_Func			= register_cvar( "ps_func"			, "31" 					),
	p_Ads			= register_cvar( "ps_ads"			, "1" 					),
	p_AdFreq		= register_cvar( "ps_adfreq"		, "120.0" 				),
	p_Floodp		= register_cvar( "ps_floodp"		, "3.0" 				),
	p_AllowReg		= register_cvar( "ps_allowreg"		, "0" 					),
	p_HideChat		= register_cvar( "ps_hidechat"		, "0" 					),
	p_Menu			= register_cvar( "ps_menu"			, "1"					),
	p_OnlyMenu 		= register_cvar( "ps_onlymenu"		, "0" 					),
	p_ShowHeading	= register_cvar( "ps_showheading"	, "3"					),
	p_ShowVersion	= register_cvar( "ps_showversion"	, "1"					);
	
	register_dictionary( "ingame_psychostats.txt" );
	register_dictionary( "common.txt" );
	register_dictionary( "statsx.txt" );
	
	g_iMaxPlayers = get_maxplayers( );
	
	plugin_mod( );
}


public plugin_mod( )
{
	new MOD:iMod = get_mod( );
	
	if( iMod == CSTRIKE || iMod == CZERO )
	{
		formatex( g_szGenericMsg, charsmax(g_szGenericMsg), "%s \x01%%L", PREFIX );
		formatex( g_szColoredMsg, charsmax(g_szColoredMsg), "\x04 %s \x03%%L", PREFIX );
		formatex( g_szGenericMsgSite, charsmax(g_szGenericMsg), "%s \x01%%L \x03[%%s]", PREFIX );
		
		state colorchat;
	}
	else
	{
		if( iMod != DOD )
		{
			if( iMod == INVALID )
			{
				log_amx( "[IG-PS] This mod is not tested or officially supported. Please provide feedback so it can be added to supported and tested list." );
			}
			else if( iMod == NS )
			{
				g_bForceMenu = true;
			}
			
			g_szHTMLBody[0] = '\0';
			copy( g_szWhoisSeparator, charsmax(g_szWhoisSeparator), "\n----------\n" );
		}
		
		formatex( g_szGenericMsg, charsmax(g_szGenericMsg), "%s %%L", PREFIX );
		formatex( g_szColoredMsg, charsmax(g_szColoredMsg), "%s %%L", PREFIX );
		formatex( g_szGenericMsgSite, charsmax(g_szGenericMsgSite), "%s %%L [%%s]", PREFIX );
		
		state nocolorchat;
	}
	
	if( iMod == CSTRIKE || iMod == CZERO || iMod == DOD )
	{
		copy( g_Clr[M_WHITE]	, charsmax(g_Clr[]), "\\w" );
		copy( g_Clr[M_GREY]		, charsmax(g_Clr[]), "\\d" );
		copy( g_Clr[M_YELLOW]	, charsmax(g_Clr[]), "\\y" );
		copy( g_Clr[M_RED]		, charsmax(g_Clr[]), "\\r" );
		copy( g_Clr[M_RALIGN]	, charsmax(g_Clr[]), "\\R" );
	}
}


public plugin_cfg( )
{	
	new szFile[256];
	get_configsdir( szFile, charsmax(szFile) );
	add( szFile, charsmax(szFile), "/ig_ps.cfg" );
	
	if( file_exists( szFile ) )
	{
		server_cmd( "exec %s", szFile );
		server_exec( );
	}
	
	set_task( get_pcvar_float( p_AdFreq ), "SHOW_ad", TASK_AD );
	
	get_pcvar_string( p_Site, g_Site, charsmax(g_Site) );
	
	new szHost[32], szUser[32], szPass[32], szDb[32];
	
	get_pcvar_string( p_Host, szHost, charsmax(szHost)	);
	get_pcvar_string( p_User, szUser, charsmax(szUser)	);
	get_pcvar_string( p_Pass, szPass, charsmax(szPass)	);
	get_pcvar_string( p_Db	, szDb	, charsmax(szDb)	);
	
	get_pcvar_string( p_Pref, g_Prefix, charsmax(g_Prefix) );
	
	g_SqlTuple = SQL_MakeDbTuple( szHost, szUser, szPass, szDb );
	
	if( get_pcvar_num( p_ShowVersion ) )
		PREPARE_ver( );
}


public PREPARE_ver( )
{
	new data[2];
	data[0] = HANDLE_QRY,
	data[1] = HANDLE_VER;
	
	formatex( g_szQuery, charsmax(g_szQuery), 
		"SELECT `value` \
		FROM `%sconfig` \
		WHERE `var` = 'version';", 
	g_Prefix );
	
	SQL_ThreadQuery( g_SqlTuple, "HANDLE_sql", g_szQuery, data, sizeof data );
}


public HANDLE_ver( Handle:Query )
{
	if( SQL_NumResults( Query ) )
		SQL_ReadResult( Query, 0, g_Version, charsmax(g_Version) );
}


public cmd_ad( id, level, cid )
{
	if( cmd_access( id, level, cid, 1 ) )
	{
		remove_task( TASK_AD );
	
		SHOW_ad( );
	}
	
	return PLUGIN_HANDLED;
}

public SHOW_ad( )
{
	get_pcvar_string( p_Site, g_Site, charsmax(g_Site) );
	
	if( get_pcvar_num( p_Ads ) )
	{	
		new szCommands[92], szAdminCommands[92], iLen, iLenA,
			iFunc = get_pcvar_num( p_Func ), iAllowReg = get_pcvar_num( p_AllowReg ), 
			bool:bShowHeading = bool:check_bit( get_pcvar_num( p_ShowHeading ), ADSHEAD ), iShowVersion = get_pcvar_num( p_ShowVersion ); 
		
		if( check_bit( iFunc, SHOW_SKILL ) )
		{
			iLen += formatex( szCommands[iLen], charsmax(szCommands) - iLen, "  %s", g_szCommands[CMD_SKILL] );
			iLen += formatex( szCommands[iLen], charsmax(szCommands) - iLen, "  %s", g_szCommands[CMD_SKILLME] );
		}
		
		if( check_bit( iFunc, SHOW_TOP ) )
		{
			iLen += formatex( szCommands[iLen], charsmax(szCommands) - iLen, "  %s", g_szCommands[CMD_SKILL15] );
			iLen += formatex( szCommands[iLen], charsmax(szCommands) - iLen, "  %s", g_szCommands[CMD_SKILLTOP] );
		}
		
		if( check_bit( iFunc, SHOW_STATS ) )
			iLen += formatex( szCommands[iLen], charsmax(szCommands) - iLen, "  %s", g_szCommands[CMD_SKILLSTATS] );
			
		if( get_pcvar_num( p_Menu ) || get_pcvar_num( p_OnlyMenu ) || g_bForceMenu )
			iLen += formatex( szCommands[iLen], charsmax(szCommands) - iLen, "  %s", g_szCommands[CMD_SKILLMENU] );
		
		if( check_bit( iFunc, SHOW_WHOIS ) )
			iLenA += formatex( szAdminCommands[iLenA], charsmax(szAdminCommands) - iLenA, "  %s", g_szCommands[A_CMD_WHOIS] );
		
		for( new id = 1; id <= g_iMaxPlayers; id++ )
		{
			if( !is_user_connected( id ) || is_bot( id ) )
				continue;
			
			if( bShowHeading )
				ColorChat( id, GREEN, g_szGenericMsgSite, id, "PS_ADSHEAD", ( iShowVersion ? g_Version : "" ), g_Site );
			
			if( iAllowReg ) 
				ColorChat( id, GREEN, g_szGenericMsg, id, "PS_ADSREG" );
			
			if( iLen )
				ColorChat( id, GREEN, g_szGenericMsg, id, "PS_ADSCMDS", szCommands, ( get_user_flags( id ) & ADMIN_LEVEL ) ? szAdminCommands : "" );
			else if( iLenA && ( get_user_flags( id ) & ADMIN_LEVEL ) )
				ColorChat( id, GREEN, g_szGenericMsg, id, "PS_ADSCMDS", "", szAdminCommands );
		}
	}

	set_task( get_pcvar_float( p_AdFreq ), "SHOW_ad", TASK_AD );
}


public HANDLE_say( const id )
{
	if( !id || !is_user_connected( id ) )
		return PLUGIN_CONTINUE;
	
	static szSaid[64], iFunc;
	
	read_args( szSaid, charsmax(szSaid) );
	remove_quotes( szSaid );
		
	if( szSaid[0] != '/' )
		return PLUGIN_CONTINUE;
	
	trim( szSaid );
	
	iFunc = get_pcvar_num( p_Func );
	
	new bool:bContinue = get_pcvar_num( p_HideChat ) ? false : true,
		bool:bCmdDisabled, 
		bool:bCmdFound = true;
		
	new	Float:fFloodp = get_pcvar_float( p_Floodp ), Float:fTime = get_gametime( ),
		bool:bFlood = ( g_FloodLast[id] > fTime - fFloodp ) ? true : false;
		
	new	iUseMenu = clamp( get_pcvar_num( p_OnlyMenu ), ( g_bForceMenu ? 1 : 0 ), 2 ),
		bool:bUseMenu = iUseMenu ? true : false;

	
	if( equali( szSaid, g_szCommands[CMD_SKILL] ) )
	{
		if( check_bit( iFunc, SHOW_SKILL ) )
		{
			if( !bFlood )
				PREPARE_skill( id, 0, iUseMenu );
		}
		else
			bCmdDisabled = true;
	}
	else if( equali( szSaid, g_szCommands[CMD_SKILLME] ) )
	{
		if( check_bit( iFunc, SHOW_SKILL ) )
		{
			if( !bFlood )
				PREPARE_skill( id, 1, iUseMenu );
				
			bContinue = false;
		}
		else
			bCmdDisabled = true;
	}
	else if( equali( szSaid, g_szCommands[CMD_SKILL15] ) || equali( szSaid, g_szCommands[CMD_SKILLTOP] ) )
	{
		if( check_bit( iFunc, SHOW_TOP ) )
		{
			if( !bFlood )
				PREPARE_top( id, bUseMenu ? 10 : 15, bUseMenu );
		}
		else
			bCmdDisabled = true;
	}
	else if( equali( szSaid, g_szCommands[CMD_SKILLTOP], strlen( g_szCommands[CMD_SKILLTOP] ) ) )
	{
		if( check_bit( iFunc, SHOW_TOP ) )
		{
			if( !bFlood )
			{
				new iNum = GET_num( szSaid, charsmax(szSaid), g_szCommands[CMD_SKILLTOP], bUseMenu ? 10 : 15 );
				
				bContinue = ( iNum == -1 ) ? false : true;
				
				PREPARE_top( id, iNum, bUseMenu);
			}
		}
		else
			bCmdDisabled = true;
	}
	else if( equali( szSaid, g_szCommands[CMD_SKILLSTATS], strlen( g_szCommands[CMD_SKILLSTATS] ) ) )
	{
		if( check_bit( iFunc, SHOW_STATS ) )
		{
			if( !bFlood )
			{
				new iTarget = GET_target( id, szSaid, charsmax(szSaid), g_szCommands[CMD_SKILLSTATS] );
				
				bContinue = ( !iTarget ) ? false : true;
				
				PREPARE_stats( id, iTarget, bUseMenu );
			}
		}
		else
			bCmdDisabled = true;
	}
	else if( equali( szSaid, g_szCommands[CMD_SKILLMENU], strlen( g_szCommands[CMD_SKILLMENU] ) ) )
	{
		if( get_pcvar_num( p_Menu ) || bUseMenu || g_bForceMenu )
		{
			if( !bFlood )
				MENU_main( id );
		}
		else
			bCmdDisabled = true;
	}
	else if( equali( szSaid, g_szCommands[A_CMD_WHOIS], strlen( g_szCommands[A_CMD_WHOIS] ) ) && get_user_flags( id ) & ADMIN_LEVEL )
	{
		bFlood = false,
		bContinue = false;
		
		if( check_bit( iFunc, SHOW_WHOIS ) )
		{
			new iTarget = GET_target( id, szSaid, charsmax(szSaid), g_szCommands[A_CMD_WHOIS] );
				
			PREPARE_whois( id, iTarget, bUseMenu );
		}
		else
			bCmdDisabled = true;
	}
	else
	{
		bCmdFound = false,
		bContinue = true;
	}
	
	if( bCmdFound )
	{
		if( bCmdDisabled )
		{
			bContinue = false;
			ColorChat( id, GREEN, g_szGenericMsg, id, "PS_CMDDISABLED" );
		}
		else
		{
			if( !bFlood )
				g_FloodLast[id] = fTime;
			else
			{
				bContinue = false;
				ColorChat( id, GREEN, g_szGenericMsg, id, "PS_FLOODING", fFloodp );
			}
		}
	}
	
	return bContinue ? PLUGIN_CONTINUE : PLUGIN_HANDLED;
}



GET_num( szSaid[], const iLen, const szCmd[], const iMin = 0 )
{
	replace( szSaid, iLen, szCmd, "" );
	trim( szSaid );
	return is_str_num( szSaid ) ? max( str_to_num( szSaid ), iMin ) : -1;
}


GET_target( const id, szSaid[], const iLen, const szCmd[] )
{
	replace( szSaid, iLen, szCmd, "" );
	trim( szSaid );
	return ( strlen( szSaid ) == 0 ) ? id : cmd_target( id, szSaid, 2 );
}


public MENU_cmd( const id )
{
	if( id && is_user_connected( id ) )
	{
		if( !get_pcvar_num( p_Menu ) && !get_pcvar_num( p_OnlyMenu ) && !g_bForceMenu )
			ColorChat( id, GREEN, g_szGenericMsg, id, "PS_CMDDISABLED" );
		else
			MENU_main( id );
	}
	
	return PLUGIN_HANDLED;
}


public MENU_main( const id )
{
	new iFunc = get_pcvar_num( p_Func ), 
		xKeys = MENU_KEY_0;
	
	if( check_bit( iFunc, SHOW_SKILL ) )
		xKeys |= MENU_KEY_1;
	if( check_bit( iFunc, SHOW_TOP ) )
		xKeys |= MENU_KEY_2;
	if( check_bit( iFunc, SHOW_STATS ) )
		xKeys |= MENU_KEY_3;

	new i,
		iLen = formatex( g_szBuffer, charsmax(g_szBuffer), "%sIngame Psychostats Menu\n\n", g_Clr[M_YELLOW] );
	
	iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "%s\t%d. %sSkill\n", g_Clr[M_RED], ++i, check_bit( iFunc, SHOW_SKILL ) ? g_Clr[M_WHITE] : g_Clr[M_GREY] );
	iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "%s\t%d. %sSkilltop\n", g_Clr[M_RED], ++i, check_bit( iFunc, SHOW_TOP ) ? g_Clr[M_WHITE] : g_Clr[M_GREY] );
	iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "%s\t%d. %sSkillstats\n", g_Clr[M_RED], ++i, check_bit( iFunc, SHOW_STATS ) ? g_Clr[M_WHITE] : g_Clr[M_GREY] );
	
	if( get_user_flags( id ) & ADMIN_LEVEL )
	{
		if( check_bit( iFunc, SHOW_WHOIS ) )
			xKeys |= MENU_KEY_4;
			
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\n%s\t%d. %sWhois\n", g_Clr[M_RED], ++i, check_bit( iFunc, SHOW_WHOIS ) ? g_Clr[M_WHITE] : g_Clr[M_GREY] );
	}
	
	iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\n%s\t0. %s%L", g_Clr[M_RED], g_Clr[M_WHITE], id, "EXIT" );
	
	show_menu( id, xKeys, g_szBuffer, -1, "MENU_main" );
	
	return PLUGIN_HANDLED;
}


public MENU_handle_main( const id, const iKey )
{
	switch( iKey + 1 )
	{
		case 1: PREPARE_skill( id, 0, 2, true );
		case 2: PREPARE_top( id, 10, true, true );
		case 3: MENU_playerselection( id, 0, SHOW_STATS );
		case 4: MENU_playerselection( id, 0, SHOW_WHOIS );
		case 10: {}
		default: MENU_main( id );
	}
	
	return PLUGIN_HANDLED;
}


public client_authorized( id )
{	
	get_user_authid( id, g_szStorage[id][AUTH], charsmax(g_szStorage[][]) );
		
	if( check_bit( get_pcvar_num( p_Func ), SHOW_CONMSG ) )
		set_task( 5.0, "PREPARE_conmsg", TASK_CONMSG + id );
}


public PREPARE_conmsg( id )
{
	if( id >= TASK_CONMSG )
		id -= TASK_CONMSG;

	if( !is_user_connected( id ) )
		return;
		
	new data[3];
	data[0] = HANDLE_CHAT,
	data[1] = SHOW_CONMSG,
	data[2] = id;
	
	formatex( g_szQuery, charsmax(g_szQuery), 
		"SELECT `skill`, `rank` \
		FROM `%splr` \
		WHERE `uniqueid` = '%s';", 
	g_Prefix, g_szStorage[id][AUTH] );
	
	SQL_ThreadQuery( g_SqlTuple, "HANDLE_sql", g_szQuery, data, sizeof data );
}


public SHOW_conmsg( Handle:Query, const id )
{
	if( !is_user_connected( id ) )
		return;

	if( SQL_NumResults( Query ) )
	{
		new Float:fSkill, iRank;
		
		get_user_name( id, g_szStorage[id][NAME], charsmax(g_szStorage[][]) );
		
		SQL_ReadResult( Query, 0, fSkill );
		iRank = SQL_ReadResult( Query, 1 );

		ColorChat( 0, BLUE, g_szColoredMsg, LANG_PLAYER, "PS_JOINMSG", g_szStorage[id][NAME], g_szStorage[id][AUTH], fSkill, iRank );
	}
}


public client_disconnect( id )
{
	is_bot( id ) = is_hltv( id ) = false;
	
	if( check_bit( get_pcvar_num( p_Func ), SHOW_DISMSG ) )
	{
		get_user_name( id, g_szStorage[id][NAME], charsmax(g_szStorage[][]) );
		
		PREPARE_dismsg( id );
	}
}


public PREPARE_dismsg( const id )
{
	new data[3];
	data[0] = HANDLE_CHAT,
	data[1] = SHOW_DISMSG,
	data[2] = id;
	
	HANDLE_escape( g_szStorage[id][NAME], charsmax(g_szStorage[][]) );
	
	formatex( g_szQuery, charsmax(g_szQuery), 
		"SELECT `skill`, `rank`, '%s' AS `name`, `uniqueid` \
		FROM `%splr` \
		WHERE `uniqueid` = '%s';", 
	g_szStorage[id][NAME], g_Prefix, g_szStorage[id][AUTH] );
	
	SQL_ThreadQuery( g_SqlTuple, "HANDLE_sql", g_szQuery, data, sizeof data );
}


public SHOW_dismsg( Handle:Query )
{	
	if( SQL_NumResults( Query ) )
	{
		new Float:fSkill, iRank, szName[33], szAuth[33];
		
		SQL_ReadResult( Query, 0, fSkill );
		iRank = SQL_ReadResult( Query, 1 );
		SQL_ReadResult( Query, 2, szName, charsmax(szName)	);
		SQL_ReadResult( Query, 3, szAuth, charsmax(szAuth) 	);
		
		ColorChat( 0, RED, g_szColoredMsg, LANG_PLAYER, "PS_DISCMSG", szName, szAuth, fSkill, iRank );
	}
}


PREPARE_skill( const id, const iSelf, const iMenu = 0, const bool:bBackToMainMenu = false )
{
	if( iMenu )
		g_bBackToMainMenu[id] = bBackToMainMenu;
	
	new data[5];
	data[0] = HANDLE_QRY,
	data[1] = SHOW_SKILL,
	data[2] = id,
	data[3] = iSelf,
	data[4] = iMenu;
	
	formatex( g_szQuery, charsmax(g_szQuery), 
		"SELECT `a`.`skill`, `a`.`rank`, `b`.`kills`, `b`.`deaths`, \
		( SELECT COUNT( * ) FROM `%splr` WHERE `allowrank` = '1' ) AS `count` \
		FROM `%splr` AS `a`, `%sc_plr_data` AS `b` \
		WHERE `a`.`uniqueid` = '%s' AND `a`.`plrid` = `b`.`plrid`;",
	g_Prefix, g_Prefix, g_Prefix, g_szStorage[id][AUTH] );
		
	SQL_ThreadQuery( g_SqlTuple, "HANDLE_sql", g_szQuery, data, sizeof data );
}


public HYBRID_skill( Handle:Query, const id, const iSelf, const iMenu )
{	
	if( !is_user_connected( id ) )
		return;
	
	if( SQL_NumResults( Query ) )
	{
		new Float:fSkill, iRank, iRanked, iKills, iDeaths;
		
		SQL_ReadResult( Query, 0, fSkill );
		iRank 	= SQL_ReadResult( Query, 1 ),
		iKills 	= SQL_ReadResult( Query, 2 ),
		iDeaths = SQL_ReadResult( Query, 3 ),
		iRanked = SQL_ReadResult( Query, 4 );
		
		if( iMenu < 2 )
		{
			if( !iMenu )
			{
				if( check_bit( get_pcvar_num( p_ShowHeading ), RANKHEAD ) )
					ColorChat( id, GREEN, g_szGenericMsgSite, id, "PS_RANKHEAD", ( get_pcvar_num( p_ShowVersion ) ? g_Version : "" ), g_Site );
			
				if( iSelf )
					ColorChat( id, GREEN, g_szGenericMsg, id, "PS_RANKME", iRank, iRanked, fSkill, iKills, iDeaths );
			}
			
			if( !iSelf )
			{
				new isAlive = is_user_alive( id );
				
				get_user_name( id, g_szStorage[id][NAME], charsmax(g_szStorage[][]) );
				
				for( new i = 1; i <= g_iMaxPlayers; i++ )
				{
					if( !is_user_connected( i ) )
						continue;
					
					if( isAlive || isAlive == is_user_alive( i ) || get_user_team( i ) == 3 )
						ColorChat( i, GREEN, g_szGenericMsg, i, "PS_RANKALL", g_szStorage[id][NAME], iRank, iRanked, fSkill, iKills, iDeaths );
				}
			}
		}
		
		if( iMenu )
		{			
			new iLen = formatex( g_szBuffer, charsmax(g_szBuffer), "%sSkill\n%s\n", g_Clr[M_YELLOW], g_Clr[M_WHITE] );
			
			iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\t%L: %d\n"	, id, "PS_RANK", iRank );
			iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\t%L: %d\n"	, id, "PS_TOTALPLAYERS", iRanked );
			iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\t%L: %.0f\n"	, id, "PS_POINTS", fSkill );
			iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\t%L: %d\n"	, id, "KILLS", iKills );
			iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\t%L: %d\n"	, id, "DEATHS", iDeaths );

			show_menu( id, ALL_KEYS, g_szBuffer, -1, "MENU_skill" );
		}
	}
}


public MENU_handle_skill( const id, const iKey )
{
	if( g_bBackToMainMenu[id] )
		MENU_main( id );
	
	return PLUGIN_HANDLED;
}


PREPARE_stats( const id, const iTarget, const bool:bMenu = false, const bool:bBackToMainMenu = false )
{
	if( !is_user_connected( id ) )
		return;
	else if( !iTarget )
	{
		ColorChat( id, GREEN, g_szGenericMsg, id, "PS_NOPLAYER" );
		return;
	}
	
	g_bBackToMainMenu[id] = bBackToMainMenu;
	
	new data[4];
	data[0] = ( bMenu ) ? HANDLE_MENU : HANDLE_CHAT,
	data[1] = SHOW_STATS,
	data[2] = id,
	data[3] = iTarget;
	
	formatex( g_szQuery, charsmax(g_szQuery), 
		"SELECT `a`.`skill`, `a`.`rank`, `b`.`kills`, `b`.`headshotkills`, `b`.`deaths`, `b`.`shots`, `b`.`hits`, `b`.`damage`, `b`.`accuracy`, \
		( SELECT COUNT( * ) FROM `%splr` WHERE `allowrank` = '1' ) AS `count` \
		FROM `%splr` AS `a`, `%sc_plr_data` AS `b` \
		WHERE `a`.`uniqueid` = '%s' AND `b`.`plrid` = `a`.`plrid`;",
	g_Prefix, g_Prefix, g_Prefix, g_szStorage[iTarget][AUTH] );
	
	SQL_ThreadQuery( g_SqlTuple, "HANDLE_sql", g_szQuery, data, sizeof data );
}


public SHOW_stats( Handle:Query, const id, const iTarget )
{
	if( !is_user_connected( id ) )
		return;
	else if( !is_user_connected( iTarget ) )
	{
		ColorChat( id, GREEN, g_szGenericMsg, id, "PS_DISCONNECTED" );
		return;
	}
		
	if( SQL_NumResults( Query ) )
	{
		new Float:fSkill, iRank, iRanked, iKills, iHS, iDeaths, iShots, iHits, iDamage, fAcc;
		
		SQL_ReadResult( Query, 0, fSkill );
		iRank 	= SQL_ReadResult( Query, 1 ),
		iKills 	= SQL_ReadResult( Query, 2 ),
		iHS 	= SQL_ReadResult( Query, 3 ),
		iDeaths = SQL_ReadResult( Query, 4 ),
		iShots 	= SQL_ReadResult( Query, 5 ),
		iHits 	= SQL_ReadResult( Query, 6 ),
		iDamage = SQL_ReadResult( Query, 7 );
		SQL_ReadResult( Query, 8, fAcc );
		iRanked = SQL_ReadResult( Query, 9 );
		
		new szHeader[64], iLen;
		get_user_name( iTarget, g_szStorage[iTarget][NAME], charsmax(g_szStorage[][]) );

		if( id == iTarget )
			iLen += formatex( g_szBuffer, charsmax(g_szBuffer), "%s%L\n", g_szHTMLBody, id, "PS_STATME", iRank, iRanked );
		else			
			iLen += formatex( g_szBuffer, charsmax(g_szBuffer), "%s%L\n", g_szHTMLBody, id, "PS_STATALL", g_szStorage[iTarget][NAME], iRank, iRanked );
		
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "%L: %.0f\n\n"	, id, "PS_POINTS", fSkill );
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "%L: %d (HS: %d)\n", id, "KILLS", iKills, iHS );
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "%L: %d\n"		, id, "DEATHS", iDeaths );
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "%L/%L: %.3f\n", id, "KILLS", id, "DEATHS", ( iKills / float( iDeaths ) ) );
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "%L: %d\n"		, id, "SHOTS", iShots );
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "%L: %d\n"		, id, "HITS", iHits );
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "%L: %d\n"		, id, "DAMAGE", iDamage );
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "%L: %.3f%%\n"	, id, "PS_ACCURACY", fAcc );
		
		formatex( szHeader, charsmax(szHeader), "Skillstats - %s", g_szStorage[iTarget][NAME] );
		
		show_motd( id, g_szBuffer, szHeader );
	}
}


public MENU_stats( Handle:Query, const id, const iTarget )
{
	if( !is_user_connected( id ) )
		return;
	else if( !is_user_connected( iTarget ) )
	{
		ColorChat( id, GREEN, g_szGenericMsg, id, "PS_DISCONNECTED" );
		return;
	}
		
	if( SQL_NumResults( Query ) )
	{
		new Float:fSkill, iRank, iRanked, iKills, iHS, iDeaths, iShots, iHits, iDamage, fAcc, iLen;
		
		SQL_ReadResult( Query, 0, fSkill );
		iRank 	= SQL_ReadResult( Query, 1 ),
		iKills 	= SQL_ReadResult( Query, 2 ),
		iHS 	= SQL_ReadResult( Query, 3 ),
		iDeaths = SQL_ReadResult( Query, 4 ),
		iShots 	= SQL_ReadResult( Query, 5 ),
		iHits 	= SQL_ReadResult( Query, 6 ),
		iDamage = SQL_ReadResult( Query, 7 );
		SQL_ReadResult( Query, 8, fAcc );
		iRanked = SQL_ReadResult( Query, 9 );
		
		get_user_name( iTarget, g_szStorage[iTarget][NAME], charsmax(g_szStorage[][]) );
		
		iLen += formatex( g_szBuffer, charsmax(g_szBuffer), "%s%L - %s\n%s\n", g_Clr[M_YELLOW], id, "PS_PLAYERSTATS", g_szStorage[iTarget][NAME], g_Clr[M_WHITE] );
		
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\t%L: %d\n"		, id, "PS_RANK", iRank );
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\t%L: %d\n"		, id, "PS_TOTALPLAYERS", iRanked );
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\t%L: %.0f\n"		, id, "PS_POINTS", fSkill	);
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\t%L: %d (HS: %d)\n", id, "KILLS", iKills, iHS );
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\t%L: %d\n"		, id, "DEATHS", iDeaths );
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\t%L/%L: %.3f\n"	, id, "KILLS", id, "DEATHS", ( iKills / float(iDeaths) ) );
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\t%L: %d\n"		, id, "SHOTS", iShots );
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\t%L: %d\n"		, id, "HITS", iHits );
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\t%L: %d\n"		, id, "DAMAGE", iDamage );
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\t%L: %.3f%%\n"	, id, "PS_ACCURACY", fAcc );

		show_menu( id, ALL_KEYS, g_szBuffer, -1, "MENU_stats" );
	}
}


public MENU_handle_stats( const id, const iKey )
{
	if( g_bBackToMainMenu[id] )
		MENU_main( id );
	
	return PLUGIN_HANDLED;
}


PREPARE_top( const id, const iNum, const bool:bMenu = false, const bool:bBackToMainMenu = false )
{
	if( !is_user_connected( id ) )
		return;
	else if( iNum == -1 )
	{
		ColorChat( id, GREEN, g_szGenericMsg, id, "PS_INVALID" );
		return;
	}
	
	g_bBackToMainMenu[id] = bBackToMainMenu;
	
	new data[4];
	data[0] = ( bMenu ? HANDLE_MENU : HANDLE_CHAT ),
	data[1] = SHOW_TOP,
	data[2] = id,
	data[3] = iNum;
	
	if( bMenu )
	{
		formatex( g_szQuery, charsmax(g_szQuery),
			"SELECT `a`.`name`, `b`.`skill` \
			FROM `%splr_profile` AS `a`, `%splr` AS `b` \
			WHERE `a`.`uniqueid` = `b`.`uniqueid` \
			ORDER BY `b`.`skill` DESC LIMIT %d, 10;",
		g_Prefix, g_Prefix, iNum - 10 );
	}
	else
	{
		formatex( g_szQuery, charsmax(g_szQuery), 
			"SELECT `a`.`name`, `b`.`skill`, `c`.`kills`, `c`.`deaths`, \
			`c`.`headshotkills`, `c`.`accuracy` \
			FROM `%splr_profile` AS `a`, `%splr` AS `b`, `%sc_plr_data` AS `c` \
			WHERE `a`.`uniqueid` = `b`.`uniqueid` AND `b`.`plrid` = `c`.`plrid` \
			ORDER BY `b`.`skill` DESC LIMIT %d, 15;",
		g_Prefix, g_Prefix, g_Prefix, iNum - 15 );
	}
	
	SQL_ThreadQuery( g_SqlTuple, "HANDLE_sql", g_szQuery, data, sizeof data );
}


public SHOW_top( Handle:Query, const id, const iNum )
{
	if( !is_user_connected( id ) )
		return;
	
	if( SQL_NumResults( Query ) )
	{
		new Float:fSkill, iKills, iHS, iDeaths, Float:fAcc, iLen, iRank = iNum - 14;
		new	szName[16], szKills[16], szDeaths[16], szAcc[16], szPoints[16], szKpd[32], szHeader[32];
		
		formatex( szName	, charsmax(szName)	, "%L", id, "PS_NAME"	);
		formatex( szKills	, charsmax(szKills)	, "%L", id, "KILLS"		);
		formatex( szDeaths	, charsmax(szDeaths), "%L", id, "DEATHS"	);
		formatex( szAcc		, charsmax(szAcc)	, "%L", id, "ACC"		);
		formatex( szPoints	, charsmax(szPoints), "%L", id, "PS_POINTS" );
		
		ucfirst( szKills );
		ucfirst( szAcc );
		
		formatex( szKpd		, charsmax(szKpd)	, "%c/%c"	, szKills[0], szDeaths[0] );
		
		iLen = copy( g_szBuffer, charsmax(g_szBuffer), g_szHTMLBody );
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "%6s %-22.22s %-7s %-7s %-7s %-7s %-7s %-s\n", "#", szName, szPoints, szKills, szDeaths, "HS", szKpd, szAcc );
		
		do
		{
			SQL_ReadResult( Query, 0, g_szStorage[id][NAME], charsmax(g_szStorage[][]) );
			SQL_ReadResult( Query, 1, fSkill );
			iKills 	= SQL_ReadResult( Query, 2 ),
			iDeaths = SQL_ReadResult( Query, 3 ),
			iHS 	= SQL_ReadResult( Query, 4 ),
			SQL_ReadResult( Query, 5, fAcc 	);
			
			iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "%-6d %-22.22s %-7.0f %-7d %-7d %-7d %-7.2f %-.2f%%\n", iRank++, g_szStorage[id][NAME], fSkill, iKills, iDeaths, iHS, ( iKills / float( iDeaths ) ), fAcc );
			
			SQL_NextRow( Query );
		}
		while( SQL_MoreResults( Query ) );
		
		ColorChat( id, GREEN, g_szGenericMsg, id, "PS_TOP", iNum );
		formatex( szHeader, charsmax(szHeader), "Top %d - %d", iNum - 14, iNum );
		
		show_motd( id, g_szBuffer, szHeader );
	}
	
}


public MENU_top( Handle:Query, const id, const iNum )
{
	if( !is_user_connected( id ) )
		return;
		
	if( SQL_NumResults( Query ) )
	{
		new Float:fSkill, iRank = iNum - 9;
		new	szName[16], szPoints[16];
		
		formatex( szName	, charsmax(szName)	, "%L", id, "PS_NAME"	);
		formatex( szPoints	, charsmax(szPoints), "%L", id, "PS_POINTS" );
		
		new iLen = formatex( g_szBuffer, charsmax(g_szBuffer), "%sTop %d - %d\n\n", g_Clr[M_YELLOW], iNum - 9, iNum );
		
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "%s\t%-9s %-8s %-22.22s\n", g_Clr[M_RED], "#", szPoints, szName );
		
		do
		{
			SQL_ReadResult( Query, 0, g_szStorage[id][NAME], charsmax(g_szStorage[][]) );
			SQL_ReadResult( Query, 1, fSkill );
			
			iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "%s\t%-7d %s %-7.0f %-22.22s\n", g_Clr[M_RED], iRank++, g_Clr[M_WHITE], fSkill, g_szStorage[id][NAME] );
			
			SQL_NextRow( Query );
		}
		while( SQL_MoreResults( Query ) );

		show_menu( id, ALL_KEYS, g_szBuffer, -1, "MENU_top" );
	}
}


public MENU_handle_top( const id, const iKey )
{
	if( g_bBackToMainMenu[id] )
		MENU_main( id );
	
	return PLUGIN_HANDLED;
}


PREPARE_whois( const id, const iTarget, const bool:bMenu = false, const bool:bBackToMainMenu = false )
{
	g_bBackToMainMenu[id] = bBackToMainMenu;
	g_WhoisMenu[id][TARGET] = iTarget;
	
	if( !is_user_connected( id ) )
		return;	
	else if( !iTarget )
	{
		ColorChat( id, GREEN, g_szGenericMsg, id, "PS_NOPLAYER" );
		return;
	}
	else if( bMenu && g_WhoisMenu[id][LOCATION] == START )
	{
		MENU_whois( Empty_Handle, id, iTarget );
		return;
	}

	new data[4];
	data[0] = ( bMenu ? HANDLE_MENU : HANDLE_CHAT ),
	data[1] = SHOW_WHOIS,
	data[2] = id,
	data[3] = iTarget;
	
	if( !bMenu )
	{
		formatex( g_szQuery, charsmax(g_szQuery), 
			"SELECT `a`.`skill`, `a`.`prevskill`, FROM_UNIXTIME( `a`.`firstseen`, '%%m/%%d/%%Y  %%H:%%d:%%S' ) AS `firstseen`, `a`.`rank`, `a`.`prevrank`, \
			`b`.`kills`, `b`.`headshotkills`, `b`.`ffkills`, `b`.`deaths`, `b`.`connections`, `b`.`accuracy`, \
			SEC_TO_TIME( `b`.`onlinetime` ) AS `onlinetime`, `c`.`name` \
			FROM `%splr` AS `a`, `%sc_plr_data` AS `b`, `%splr_ids_name` AS `c` \
			WHERE `a`.`uniqueid` = '%s' AND `b`.`plrid` = `a`.`plrid` AND `c`.`plrid` = `a`.`plrid` \
			ORDER BY `c`.`totaluses` DESC \
			LIMIT 5;",
		g_Prefix, g_Prefix, g_Prefix, g_szStorage[iTarget][AUTH] );
	}
	else
	{
		switch( g_WhoisMenu[id][LOCATION] )
		{
			case DATA:
			{
				formatex( g_szQuery, charsmax(g_szQuery), 
					"SELECT FROM_UNIXTIME( `a`.`firstseen`, '%%d.%%m.%%Y  %%H:%%d:%%S' ) AS `firstseen`, \
					SEC_TO_TIME( `b`.`onlinetime` ) AS `onlinetime`, `b`.`connections` \
					FROM `%splr` AS `a`, `%sc_plr_data` AS `b` \
					WHERE `a`.`uniqueid` = '%s' AND `b`.`plrid` = `a`.`plrid`;", 
				g_Prefix, g_Prefix, g_szStorage[iTarget][AUTH] );
			}
			case NAMES:
			{
				formatex( g_szQuery, charsmax(g_szQuery), 
					"SELECT `name` \
					FROM `%splr_ids_name` AS `a` \
					WHERE `a`.`plrid` = ( SELECT `plrid` FROM `%splr` WHERE `uniqueid` = '%s' ) \
					ORDER BY `a`.`totaluses` DESC \
					LIMIT 5;", 
				g_Prefix, g_Prefix, g_szStorage[iTarget][AUTH] );
			}
			case STATS:
			{
				formatex( g_szQuery, charsmax(g_szQuery), 
					"SELECT `a`.`skill`, `a`.`prevskill`, `a`.`rank`, `a`.`prevrank`, \
					`b`.`kills`, `b`.`headshotkills`, `b`.`ffkills`, `b`.`deaths`, `b`.`shots`, `b`.`hits`, `b`.`damage`, `b`.`accuracy`, \
					( SELECT COUNT( * ) FROM `%splr` WHERE `allowrank` = '1' ) \
					FROM `%splr` AS `a`, `%sc_plr_data` AS `b` \
					WHERE `a`.`uniqueid` = '%s' AND `b`.`plrid` = `a`.`plrid`;", 
				g_Prefix, g_Prefix, g_Prefix, g_szStorage[iTarget][AUTH] );
			}
		}
	}

	SQL_ThreadQuery( g_SqlTuple, "HANDLE_sql", g_szQuery, data, sizeof data );
}

public SHOW_whois( Handle:Query, const id, const iTarget )
{
	if( !is_user_connected( id ) )
		return;
	else if( !is_user_connected( iTarget ) )
	{
		ColorChat( id, GREEN, g_szGenericMsg, id, "PS_DISCONNECTED" );
		return;
	}
	
	if( SQL_NumResults( Query ) )
	{
		new Float:fSkill, Float:fPrevSkill, iRank, iPrevRank, iKills, iHS, iFFKills, iDeaths, Float:fAcc, iCon;
			
		new szIP[24], szFlags[24], szFirst[24], szOnline[24], 
			szNames[256], szHeader[64];
		
		SQL_ReadResult( Query, 0, fSkill );
		SQL_ReadResult( Query, 1, fPrevSkill );
		SQL_ReadResult( Query, 2, szFirst, charsmax(szFirst) );
		iRank 		= SQL_ReadResult( Query, 3 ),
		iPrevRank 	= SQL_ReadResult( Query, 4 );
		iKills 		= SQL_ReadResult( Query, 5 ),
		iHS 		= SQL_ReadResult( Query, 6 ),
		iFFKills 	= SQL_ReadResult( Query, 7 ),
		iDeaths 	= SQL_ReadResult( Query, 8 ),
		iCon 		= SQL_ReadResult( Query, 9 );
		SQL_ReadResult( Query, 10, fAcc );
		SQL_ReadResult( Query, 11, szOnline, charsmax(szOnline)	);
		
		new iNum, iLen;
		
		do
		{
			iNum++;
			
			SQL_ReadResult( Query, 12, g_szStorage[id][NAME], charsmax(g_szStorage[][]) );
			
			iLen += formatex( szNames[iLen], charsmax(szNames) - iLen, "%s\n", g_szStorage[id][NAME] );
			
			SQL_NextRow( Query );
		}
		while( SQL_MoreResults( Query ) );
		
		
		get_user_ip( iTarget, szIP, charsmax(szIP), 1 ); 
		get_flags( get_user_flags( iTarget ), szFlags, charsmax(szFlags) );
		get_user_name( iTarget, g_szStorage[iTarget][NAME], charsmax(g_szStorage[][]) );

		
		iLen = copy( g_szBuffer, charsmax(g_szBuffer), g_szHTMLBody );
		
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "%L:%s", id, "PS_PLAYERDATA", g_szWhoisSeparator );
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "%L: %s | SteamID: %s\n", id, "PS_NAME", g_szStorage[iTarget][NAME], g_szStorage[iTarget][AUTH] );
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "IP: %s | %L: %s\n\n", szIP, id, "PS_ACCESS", szFlags );
		
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "%d %L:%s", iNum, id, "PS_MOSTUSEDNAMES", g_szWhoisSeparator );
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "%s\n", szNames );
		
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "%L:%s", id, "PS_PLAYERSTATS", g_szWhoisSeparator );
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "%L: %d | %L: %d\n", id, "PS_RANK", iRank, id, "PS_PREVRANK", iPrevRank );
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "%L: %.0f | %L: %.0f\n", id, "PS_POINTS", fSkill, id, "PS_PREVPOINTS", fPrevSkill );
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "%L: %d | %L: %d | %L/%L: %.3f\n", id, "KILLS", iKills, id, "DEATHS", iDeaths, id, "KILLS", id, "DEATHS", ( iKills / float(iDeaths) ) );
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "%L: %.3f%% | HS: %d | %L: %d\n", id, "PS_ACCURACY", fAcc, iHS, id, "PS_FFKILLS", iFFKills );
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "%L: %s\n", id, "PS_FIRSTCONNECT", szFirst );
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "%L: %d | %L: %s", id, "PS_CONNECTIONS", iCon, id, "PS_ONLINETIME", szOnline );

		formatex( szHeader, charsmax(szHeader), "Whois Lookup - %s", g_szStorage[iTarget][NAME] );
		
		show_motd( id, g_szBuffer, szHeader );
	}
}

public MENU_whois( Handle:Query, const id, const iTarget )
{
	if( !is_user_connected( id ) )
		return;
	else if( !is_user_connected( iTarget ) )
	{
		ColorChat( id, GREEN, g_szGenericMsg, id, "PS_DISCONNECTED" );
		return;
	}
	
	get_user_name( iTarget, g_szStorage[iTarget][NAME], charsmax(g_szStorage[][]) );
	
	switch( g_WhoisMenu[id][LOCATION] )
	{
		case START:
		{
			new iLen = formatex( g_szBuffer, charsmax(g_szBuffer), "%sWhois Lookup - %s\n\n", g_Clr[M_YELLOW], g_szStorage[iTarget][NAME] );
			
			iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "%s\t1. %s%L\n", g_Clr[M_RED], g_Clr[M_WHITE], id, "PS_PLAYERDATA" );
			iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "%s\t2. %s%L\n", g_Clr[M_RED], g_Clr[M_WHITE], id, "PS_MOSTUSEDNAMES" );
			iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "%s\t3. %s%L\n", g_Clr[M_RED], g_Clr[M_WHITE], id, "PS_PLAYERSTATS" );
			iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\n%s\t0. %s%L", g_Clr[M_RED], g_Clr[M_WHITE], id, g_bBackToMainMenu[id] ? "BACK" : "EXIT" );
			
			new xKeys = MENU_KEY_0|MENU_KEY_1|MENU_KEY_2|MENU_KEY_3;
			show_menu( id, xKeys, g_szBuffer, -1, "MENU_whois" );
		}
		case DATA:
		{		
			if( SQL_NumResults( Query ) )
			{
				new szFirst[24], szOnline[24], szFlags[24], szIP[24], iConnections;

				new iLen = formatex( g_szBuffer, charsmax(g_szBuffer), "%s%L - %s\n%s\n", g_Clr[M_YELLOW], id, "PS_PLAYERDATA", g_szStorage[iTarget][NAME], g_Clr[M_WHITE] );				

				get_user_ip( iTarget, szIP, charsmax(szIP), 1 ); 
				get_flags( get_user_flags( iTarget ), szFlags, charsmax(szFlags) );

				SQL_ReadResult( Query, 0, szFirst, charsmax(szFirst) );
				SQL_ReadResult( Query, 1, szOnline, charsmax(szOnline) );
				iConnections = SQL_ReadResult( Query, 2 );

				iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\tSteamID: %s\n", g_szStorage[iTarget][AUTH] );
				iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\tIP: %s\n", szIP );
				iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\t%L: %s\n", id, "PS_ACCESS", szFlags );
				iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\t%L: %s\n", id, "PS_FIRSTCONNECT", szFirst );
				iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\t%L: %d\n", id, "PS_CONNECTIONS", iConnections );
				iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\t%L: %s\n", id, "PS_ONLINETIME", szOnline );

				show_menu( id, ALL_KEYS, g_szBuffer, -1, "MENU_whois" );
			}
		}
		case NAMES:
		{
			if( SQL_NumResults( Query ) )
			{
				new iLen = formatex( g_szBuffer, charsmax(g_szBuffer), "%s%L - %s\n%s\n", g_Clr[M_YELLOW], id, "PS_MOSTUSEDNAMES", g_szStorage[iTarget][NAME], g_Clr[M_WHITE] );

				do
				{			
					SQL_ReadResult( Query, 0, g_szStorage[id][NAME], charsmax(g_szStorage[][]) );
					
					iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\t%s\n", g_szStorage[id][NAME] );
					
					SQL_NextRow( Query );
				}
				while( SQL_MoreResults( Query ) );

				show_menu( id, ALL_KEYS, g_szBuffer, -1, "MENU_whois" );
			}
		}
		case STATS:
		{
			if( SQL_NumResults( Query ) )
			{
				new Float:fSkill, Float:fPrevSkill, iRank, iPrevRank, iRanked, iKills, iHS, iFFKills, 
					iDeaths, iShots, iHits, iDamage, Float:fAcc;
					
				new iLen = formatex( g_szBuffer, charsmax(g_szBuffer), "%s%L - %s\n%s\n", g_Clr[M_YELLOW], id, "PS_PLAYERSTATS", g_szStorage[iTarget][NAME], g_Clr[M_WHITE] );
				
				SQL_ReadResult( Query, 0, fSkill );
				SQL_ReadResult( Query, 1, fPrevSkill );
				iRank 		= SQL_ReadResult( Query, 2	),
				iPrevRank 	= SQL_ReadResult( Query, 3	),
				iKills 		= SQL_ReadResult( Query, 4	),
				iHS 		= SQL_ReadResult( Query, 5	),
				iFFKills 	= SQL_ReadResult( Query, 6	),
				iDeaths 	= SQL_ReadResult( Query, 7	),
				iShots 		= SQL_ReadResult( Query, 8	),
				iHits 		= SQL_ReadResult( Query, 9	),
				iDamage 	= SQL_ReadResult( Query, 10	),
				SQL_ReadResult( Query, 11, fAcc	);
				iRanked		= SQL_ReadResult( Query, 12 );
				

				iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\t%L: %d\n"		, id, "PS_RANK", iRank );
				iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\t%L: %d\n"		, id, "PS_PREVRANK", iPrevRank );
				iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\t%L: %d\n"		, id, "PS_TOTALPLAYERS", iRanked );
				iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\t%L: %.0f\n"		, id, "PS_POINTS", fSkill	);
				iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\t%L: %.0f\n"		, id, "PS_PREVPOINTS", fPrevSkill );
				iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\t%L: %d (HS: %d)\n", id, "KILLS", iKills, iHS );
				iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\t%L: %d\n"		, id, "DEATHS", iDeaths );
				iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\t%L/%L: %.3f\n"	, id, "KILLS", id, "DEATHS", ( iKills / float(iDeaths) ) );
				iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\t%L: %d\n"		, id, "PS_FFKILLS", iFFKills );
				iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\t%L: %d\n"		, id, "SHOTS", iShots );
				iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\t%L: %d\n"		, id, "HITS", iHits );
				iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\t%L: %d\n"		, id, "DAMAGE", iDamage );
				iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\t%L: %.3f%%\n"	, id, "PS_ACCURACY", fAcc );
				
				show_menu( id, ALL_KEYS, g_szBuffer, -1, "MENU_whois" );
			}
		}
	}
}


public MENU_handle_whois( const id, const iKey )
{
	if( g_WhoisMenu[id][LOCATION] == START )
	{
		switch( iKey + 1 )
		{
			case 10:
			{
				if( g_bBackToMainMenu[id] )
				{
					MENU_main( id );
				}
				
				return PLUGIN_HANDLED;
			}
			case 1:	g_WhoisMenu[id][LOCATION] = DATA;
			case 2: g_WhoisMenu[id][LOCATION] = NAMES;
			case 3: g_WhoisMenu[id][LOCATION] = STATS;
		}
		
		PREPARE_whois( id, g_WhoisMenu[id][TARGET], true, g_bBackToMainMenu[id] );
	}
	else
	{
		g_WhoisMenu[id][LOCATION] = START;
		MENU_whois(	Empty_Handle, id, g_WhoisMenu[id][TARGET] );
	}
		
	return PLUGIN_HANDLED;
}


public MENU_playerselection( const id, const iMenuPos, const iType )
{
	if( iMenuPos < 0 )
	{
		MENU_main( id );
		return;
	}
	
	new i, iStart, iEnd, iTarget;
	
	g_PlayerSelectionMenu[id][POSITION] = iMenuPos,
	g_PlayerSelectionMenu[id][TYPE] 	= iType;
	
	new iPlayerNum = 0;
	
	g_PlayerSelectionMenu[id][PLAYERS][iPlayerNum++] = id;
	
	for( i = 1; i <= g_iMaxPlayers; i++ )
	{
		if( !is_user_connected( i ) || i == id || is_hltv( i ) )
			continue;
	
		g_PlayerSelectionMenu[id][PLAYERS][iPlayerNum++] = i;
	}
	
	iStart = iMenuPos * 8;
	if( iStart >= iPlayerNum )
		iStart = iMenuPos;

	iEnd = min( iStart + 8, iPlayerNum );
	
	new	iPosNum = 0, xKeys = MENU_KEY_0;
	
	new iLen = formatex( g_szBuffer, charsmax(g_szBuffer), "%sPlayer Select %s%d/%d\n\n", g_Clr[M_YELLOW], g_Clr[M_RALIGN], iMenuPos + 1, ( iPlayerNum ? ( iPlayerNum / 8 + ( ( iPlayerNum % 8 ) ? 1 : 0 ) ) : 1 ) );
	
	i = iStart;
	
	for( i = iStart; i < iEnd; i++ )
	{			
		xKeys |= (1<<iPosNum++),
		iTarget = g_PlayerSelectionMenu[id][PLAYERS][i];

		get_user_name( iTarget, g_szStorage[iTarget][NAME], charsmax(g_szStorage[][]) );
		
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "%s\t%d. %s%s\n", g_Clr[M_RED], iPosNum, ( iTarget == id ) ? g_Clr[M_YELLOW] : g_Clr[M_WHITE], g_szStorage[iTarget][NAME] );
	}
	
	if( iEnd == iPlayerNum )
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\n%s\t9. %s%L\n", g_Clr[M_RED], g_Clr[M_GREY], id, "MORE" );
	else
	{
		xKeys |= MENU_KEY_9;
		iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "\n%s\t9. %s%L\n", g_Clr[M_RED], g_Clr[M_WHITE], id, "MORE" );
	}
	
	iLen += formatex( g_szBuffer[iLen], charsmax(g_szBuffer) - iLen, "%s\t0. %s%L", g_Clr[M_RED], g_Clr[M_WHITE], id, iMenuPos ? "BACK" : "EXIT" );

	show_menu( id, xKeys, g_szBuffer, -1, "MENU_playerselection" );
}


public MENU_handle_player( const id, const iKey )
{
	if( !is_user_connected( id ) )
		return PLUGIN_HANDLED;
		
	switch( iKey + 1 )
	{
		case 10	: MENU_playerselection( id, g_PlayerSelectionMenu[id][POSITION] - 1, g_PlayerSelectionMenu[id][TYPE] );
		case 9	: MENU_playerselection( id, g_PlayerSelectionMenu[id][POSITION] + 1, g_PlayerSelectionMenu[id][TYPE] );
		default	:
		{
			new iTarget = g_PlayerSelectionMenu[id][PLAYERS][g_PlayerSelectionMenu[id][POSITION] * 8 + iKey];
			
			if( is_user_connected( iTarget ) )
			{
				switch( g_PlayerSelectionMenu[id][TYPE] )
				{
					case SHOW_STATS: PREPARE_stats( id, iTarget, true, true );
					case SHOW_WHOIS: 
					{
						g_WhoisMenu[id][LOCATION] = START;
						PREPARE_whois( id, iTarget, true, true );
					}
				}
			}
			else
				ColorChat( id, GREEN, g_szGenericMsg, id, "PS_DISCONNECTED" );
		}	
	}

	return PLUGIN_HANDLED;
}


public PREPARE_reg( id, level, cid )
{
	enum
	{
		USERNAME,
		PASSWORD,
		ERRMAX
	};
	
	static const szErrorMessages[ ERRMAX ][ ] =
	{
		"PS_REGUSERINV",
		"PS_REGPASSINV"
	};
	
	if( !get_pcvar_num( p_AllowReg ) )
	{
		console_print( id, "%L\n", id, "PS_REGDISABLED" );
		return PLUGIN_HANDLED;
	}
	else if( g_bRegistering[id] )
	{
		console_print( id, "%L\n", id, "PS_REGPROCESS" );
		return PLUGIN_HANDLED;
	}
	else if( !cmd_access( id, level, cid, 3 ) )
	{
		console_print( id, "%L\n", id, "PS_REGMISSDATA" );
		return PLUGIN_HANDLED;
	}
	else if( read_argc( ) > 3 )
	{
		console_print( id, "%L\n", id, "PS_REGTOOMUCH" );
		return PLUGIN_HANDLED;
	}
	
	new iErrors;
	
	read_argv( 1, g_szStorage[id][USER], charsmax(g_szStorage[][]) );
	read_argv( 2, g_szStorage[id][PASS], charsmax(g_szStorage[][]) );
	
	new iLenUser = strlen( g_szStorage[id][USER] ),
		iLenPass = strlen( g_szStorage[id][PASS] );
	
	if( iLenUser < 3 || iLenUser > 32 )
		iErrors |= (1<<USERNAME);
	
	if( iLenPass < 3 || iLenPass > 32 )
		iErrors |= (1<<PASSWORD);
	
	if( !iErrors )
	{
		HANDLE_escape( g_szStorage[id][USER], charsmax(g_szStorage[][]) );
		
		new data[3];
		data[0] = HANDLE_QRY,
		data[1] = HANDLE_REG,
		data[2] = id;
		
		formatex( g_szQuery, charsmax(g_szQuery), 
			"SELECT `userid`, \
			( SELECT `userid` FROM `%splr_profile` WHERE `uniqueid` = '%s' ) IS NOT NULL AS `registered`, \
			( SELECT `username` FROM `%suser` WHERE `username` = '%s' ) IS NULL AS `username`, \
			( SELECT `allowrank` FROM `%splr` WHERE `uniqueid` = '%s' ) AS `allowrank` \
			FROM `%suser` \
			ORDER BY `userid` \
			DESC LIMIT 1;",
		g_Prefix, g_szStorage[id][AUTH], g_Prefix, g_szStorage[id][USER], g_Prefix, g_szStorage[id][AUTH], g_Prefix );
		
		SQL_ThreadQuery( g_SqlTuple, "HANDLE_sql", g_szQuery, data, sizeof data );

		g_bRegistering[id] = true;
	}
	else
	{
		console_print( id, "%L", id, "PS_REGINV" );
		for( new i = 0; i < ERRMAX; i++ )
		{
			if( check_bit( iErrors, i ) )
				console_print( id, "- %L", id, szErrorMessages[i] );
		}
		console_print( id, " " );
	}
	
	return PLUGIN_HANDLED;
}


public HANDLE_reg( Handle:Query, const id )
{
	enum
	{
		REGISTERED,
		USERNAME,
		UNRANKED,
		ERRMAX
	};
	
	static const szErrorMessages[ ERRMAX ][ ] =
	{
		"PS_REGALREADY",
		"PS_REGUSERNA",
		"PS_REGNOTRANKED"
	};
	
	if( !is_user_connected( id ) )
	{	
		g_bRegistering[id] = false;
		return;
	}
		
	if( SQL_NumResults( Query ) )
	{
		new iErrors,
			bool:isRegistered 	= ( SQL_ReadResult( Query, 1 ) ) ? true : false,
			bool:isAvailable	= ( SQL_ReadResult( Query, 2 ) ) ? true : false,
			bool:isRanked		= ( SQL_ReadResult( Query, 3 ) ) ? true : false;

		if( isRegistered )
			iErrors |= (1<<REGISTERED);	
			
		if( !isAvailable )
			iErrors |= (1<<USERNAME);
			
		if( !isRanked )
			iErrors |= (1<<UNRANKED);
			
		if( !iErrors )
		{
			new newUserId = SQL_ReadResult( Query, 0 ) + 1;
			
			new data[3];
			data[0] = HANDLE_QRY,
			data[1] = FINISH_REG,
			data[2] = id;
			
			HANDLE_escape( g_szStorage[id][PASS], charsmax(g_szStorage[][]) );
			
			formatex( g_szQuery, charsmax(g_szQuery), 
				"INSERT INTO `%suser` \
				( `userid`, `username`, `password`, `session_last`, `session_login_key`, `lastvisit`, `accesslevel`, `confirmed` ) \
				VALUES ( '%d', '%s', MD5('%s'), '0', 'NULL', '0', '2', '1' ); \
				UPDATE `%splr_profile` SET `userid` = %d WHERE `uniqueid` = '%s'",
			g_Prefix, newUserId, g_szStorage[id][USER], g_szStorage[id][PASS], g_Prefix, newUserId, g_szStorage[id][AUTH] );
			
			SQL_ThreadQuery( g_SqlTuple, "HANDLE_sql", g_szQuery, data, sizeof data );
		}
		else
		{
			console_print( id, "%L", id, "PS_REGNEGATIVE" );
			
			for( new i = 0; i < ERRMAX; i++ )
			{
				if( check_bit( iErrors, i ) )
					console_print( id, "- %L", id, szErrorMessages[i] );
			}
			
			console_print( id, " " );
		}
	}
	
	g_bRegistering[id] = false;
}


public FINISH_reg( const id )
	console_print( id, "%L\n", id, "PS_REGPOSITIVE", g_Site );


public HANDLE_sql( FailState, Handle:Query, Error[], Errorcode, Data[], Size, Float:QueueTime )
{
	if( FailState )
	{
		SQL_GetQueryString( Query, g_szQuery, charsmax(g_szQuery) );
		
		log_amx( "[IG-PS] Error: (%d) %s", Errorcode, Error );
		log_amx( "[IG-PS] Query: %s", g_szQuery );
		
		return pause( "a" );
	}
	
	// log_amx( "[IG-PS] QueueTime: %f. Func: %d.", QueueTime, Data[0] );
	
	new iType = Data[0], iFunc = Data[1];
	
	if( iType == HANDLE_CHAT )
	{
		switch( iFunc )
		{
			case SHOW_TOP	: SHOW_top		( Query, Data[2], Data[3]	);
			case SHOW_STATS	: SHOW_stats	( Query, Data[2], Data[3]	);
			case SHOW_WHOIS	: SHOW_whois	( Query, Data[2], Data[3]	);
			case SHOW_CONMSG: SHOW_conmsg	( Query, Data[2] 			);
			case SHOW_DISMSG: SHOW_dismsg	( Query						);
		}
	}
	else if( iType == HANDLE_MENU )
	{
		switch( iFunc )
		{
			case SHOW_TOP	: MENU_top		( Query, Data[2], Data[3] );
			case SHOW_STATS	: MENU_stats	( Query, Data[2], Data[3] );
			case SHOW_WHOIS	: MENU_whois	( Query, Data[2], Data[3] );
		}
	}
	else
	{
		switch( iFunc )
		{
			case SHOW_SKILL	: HYBRID_skill	( Query, Data[2], Data[3], Data[4]	);
			case FINISH_REG	: FINISH_reg	( Data[2]							);
			case HANDLE_VER : HANDLE_ver	( Query								);
			case HANDLE_REG	: HANDLE_reg	( Query, Data[2]					);
		}
	}
	
	return PLUGIN_CONTINUE;
}


HANDLE_escape( s_Input[], const iLen )
{
	replace_all( s_Input, iLen, "\\", "\\\\"	); 
	replace_all( s_Input, iLen, "'"	, "\\'"		);
}


public plugin_end( )
	SQL_FreeHandle( g_SqlTuple );
	

MOD:get_mod( )
{
	new szMod[32];
	get_modname( szMod, charsmax(szMod) );
	
	for( new MOD:i = CSTRIKE; i < MOD; i++ )
	{
		if( equal( szMod, g_szMods[i] ) )
			return i;
	}
	
	return INVALID;
}

// COLORCHAT.sma
public client_connect( id )
{
	if( is_user_hltv( id ) )
		is_hltv( id ) = true;
	else if( is_user_bot( id ) )
		is_bot( id ) = true;
}	

public ColorChat( id, Color:type, const msg[], any:... ) <nocolorchat>
{
	static message[256];
	vformat( message, charsmax(message), msg, 4 );
	
	client_print( id, print_chat, message );
}

public ColorChat( id, Color:type, const msg[], any:...) <colorchat>
{
	if( get_playersnum( ) < 1 ) 
		return;
	
	static message[256];

	switch( type )
	{
		case YELLOW: // Yellow
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

	vformat( message[1], charsmax(message) - 4, msg, 4 );

	// Make sure message is not longer than 192 character. Will crash the server.
	message[192] = '\0';

	new team, ColorChange, index, MSG_Type;
	
	if( !id )
	{
		index = FindPlayer( );
		MSG_Type = MSG_ALL;
	} 
	else
	{
		MSG_Type = MSG_ONE;
		index = id;
	}
	
	team = get_user_team( index );	
	ColorChange = ColorSelection( index, MSG_Type, type );

	ShowColorMessage( index, MSG_Type, message );
		
	if( ColorChange )
	{
		Team_Info( index, MSG_Type, TeamName[team] );
	}
}

ShowColorMessage( const id, const type, const message[] )
{
	message_begin( type, g_msgid_SayText, _, id );
	write_byte( id );		
	write_string( message );
	message_end( );	
}

Team_Info( const id, const type, const team[] )
{
	message_begin( type, g_msgid_TeamInfo, _, id );
	write_byte( id );
	write_string( team );
	message_end( );

	return 1;
}

ColorSelection( const index, const type, const Color:Type )
{
	switch(Type)
	{
		case RED:
		{
			return Team_Info( index, type, TeamName[1] );
		}
		case BLUE:
		{
			return Team_Info( index, type, TeamName[2] );
		}
		case GREY:
		{
			return Team_Info( index, type, TeamName[0] );
		}
	}

	return 0;
}

FindPlayer( )
{
	new i = -1;

	while( i <= g_iMaxPlayers )
	{
		if( is_user_connected( ++i ) )
		{
			return i;
		}
	}

	return -1;
}