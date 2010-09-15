/* AMX Mod script.
*
* (c) Copyright 2004, kaboomkazoom
* (c) Copyright 2010, Andrius Bentkus
*
* This file is provided as is (no warranties)
*
* Simple Swear Replacement filter 1.5
* Replaces the chat message containing any
* swear word with a replacement line from
* replacements.ini
*
* So anyone who swears will himself be insulted.
*
* Whenever any message is replaced, then the original
* message containing Swears will be shown to all the
* Admins (So the Admins know what was said).
*
* Admin messages are not replaced. So they can Swear ;)
*
* Uses swearwords.ini, regexswear.ini and replacements.ini files.
* Put these files in the AMX Config Directory.
* Other swear files can also be used.
*
* swearregex.ini contains regex keywoards which
* are matched against an entire set of words
*
* You can also add Swear Words and Replacement
* Lines to the files in between the game whenever
* you want.
*
*
*
* Console Commands
* ~~~~~~~~~~~~~~~~
*
* amx_addswear < swear word >			-	Use this Command in game to add the
*							swear word in swearwords.ini and start
*							blocking that word from that moment on.
*
* amx_addreplacement < replacement line >	-	Use this command in game to add a new
*							replacement line in replacements.ini
*
*
*
*
* P.S. If the number of swear words or replacement
* lines exceeds 150 or 50 respectively then change
* the values of MAX_WORDS and MAX_REPLACE
*
*
*/


#include <amxmodx>
#include <amxmisc>
#include <regex>

// max number of words in swear list and max number of lines in replace list
#define MAX_WORDS 150
#define MAX_REPLACE 50
#define MAX_REGEX 10

#define MAX_REGEX_ERROR_SIZE 128

// global variables for storing the swear list and replace list and their respective number of lines
new g_regexSwear[MAX_REGEX][100]
new g_swearWords[MAX_WORDS][20]
new g_replaceLines[MAX_REPLACE][192]

new g_regexNum
new g_swearNum
new g_replaceNum

public plugin_init()
{
	register_plugin ( "Swear Replacement", "1.5", "kaboomkazoom")
	register_clcmd ( "say", "swearcheck" )
	register_clcmd ( "say_team", "swearcheck" )
	
	register_concmd ( "amx_addswear", "add_swear", ADMIN_LEVEL_A , "< swear word to add >" )
	register_concmd ( "amx_addreplacement", "add_replacement", ADMIN_LEVEL_A , "< replacement line to add >" )
	
	register_concmd ( "amx_listswear", "list_swear", ADMIN_LEVEL_A, "")
	
	readList()
}

checkFile(file[64])
{
	if ( !file_exists(file) )
	{
		server_print ( "==========================================================" )
		server_print ( "[Swear Replacement] %s file not found", file )
		server_print ( "==========================================================" )
		return false
	}
	return true
}
readList()
{
	new Configsdir[64]
	new swear_file[64], replace_file[64], regex_file[64]
	get_configsdir( Configsdir, 63 )
	format(swear_file, 63, "%s/swearwords.ini", Configsdir )
	format(replace_file, 63, "%s/replacements.ini", Configsdir )
	format(regex_file, 64, "%s/regexswear.ini", Configsdir)


	if ( !checkFile(swear_file)) return
	if ( !checkFile(replace_file)) return
	if ( !checkFile(regex_file)) return

	new len, i=0
	while( i < MAX_WORDS && read_file( swear_file, i , g_swearWords[g_swearNum], 19, len ) )
	{
		i++
		if( g_swearWords[g_swearNum][0] == ';' || len == 0 )
			continue
		g_swearNum++
	}

	i=0
	while( i < MAX_REPLACE && read_file( replace_file, i , g_replaceLines[g_replaceNum], 191, len ) )
	{
		i++
		if( g_replaceLines[g_replaceNum][0] == ';' || len == 0 )
			continue
		g_replaceNum++
	}
	i=0
	while( i < MAX_REGEX && read_file( regex_file, i , g_regexSwear[g_regexNum], 191, len ) )
	{
		i++
		if( g_regexSwear[g_regexNum][0] == ';' || len == 0 )
			continue
		g_regexNum++
	}

	server_print ( "======================================================" )
	server_print ( "[Swear Replacement] loaded %d Swear words", g_swearNum )
	server_print ( "[Swear Replacement] loaded %d Regex Swear words", g_regexNum )
	server_print ( "[Swear Replacement] loaded %d Replacement Lines", g_replaceNum )
	server_print ( "======================================================" )

}

containsBadWord(said[192])
{
	new i = 0

	while ( i < g_regexNum)
	{
		new num, error[MAX_REGEX_ERROR_SIZE]
		new Regex:re = regex_match(said, g_regexSwear[i], num, error, MAX_REGEX_ERROR_SIZE-1)
		if (re >= REGEX_OK) return true
		i++
	}

	i = 0

	while ( i < g_swearNum )
	{
		if (containi( said, g_swearWords[i++] ) != -1) return true
	}
	return false
}

public swearcheck(id)
{
	if ( (get_user_flags(id)&ADMIN_LEVEL_A) || !id )
		return PLUGIN_CONTINUE

	new said[192], saidcleaned[192]
	read_args ( said, 191 )
	read_args(saidcleaned, 191)

	string_cleaner ( saidcleaned )

	if (containsBadWord(said) || containsBadWord(saidcleaned))
	{
		new j, playercount, players[32], user_name[32], random_replace = random ( g_replaceNum )
		get_user_name ( id, user_name, 31 )
		get_players ( players, playercount, "c" )

		for ( j = 0 ; j < playercount ; j++)
		{
			if ( get_user_flags(players[j])&ADMIN_LEVEL_A )
				client_print( players[j], print_chat, "[Swear Replacement] %s : %s",user_name, said )
		}

		copy ( said, 191, g_replaceLines[random_replace] )
		new cmd[10]
		read_argv ( 0, cmd, 9)
		engclient_cmd ( id ,cmd ,said )
		return PLUGIN_HANDLED
	}
	else return PLUGIN_CONTINUE
}


public list_swear(id)
{
	if ( ( !(get_user_flags(id)&ADMIN_LEVEL_A) && id ) )
	{
		client_print ( id, print_console, "[Swear Replacement] Access Denied" )
		return PLUGIN_HANDLED
	}

	client_print( id, print_console, "[Swear Replacement] Listing all Swear words" )

	new i = 0
	while( i < MAX_REPLACE && i < g_swearNum )
	{
		client_print(id, print_console, "%i. %s", i, g_swearWords[i])
		i++
	}
	return PLUGIN_HANDLED
}

public add_swear(id)
{
	if ( ( !(get_user_flags(id)&ADMIN_LEVEL_A) && id ) )
	{
		client_print ( id, print_console, "[Swear Replacement] Access Denied" )
		return PLUGIN_HANDLED
	}

	if ( read_argc() == 1 )
	{
		client_print ( id, print_console, "[Swear Replacement] Arguments not provided" )
		return PLUGIN_HANDLED
	}

	new Configsdir[64]
	new swear_file[64]
	get_configsdir( Configsdir, 63 )
	format ( swear_file, 63, "%s/swearwords.ini", Configsdir )

	read_args ( g_swearWords[g_swearNum], 19 )
	write_file( swear_file, "" )
	write_file( swear_file, g_swearWords[g_swearNum] )
	g_swearNum++

	id ? client_print ( id, print_console, "[Swear Replacement] Swear word added to List" ) : server_print ( "[Swear Replacement] Swear word added to file" )

	return PLUGIN_HANDLED
}

public add_replacement(id)
{
	if ( ( !(get_user_flags(id)&ADMIN_LEVEL_A) && id ) )
	{
		client_print ( id, print_console, "[Swear Replacement] Access Denied" )
		return PLUGIN_HANDLED
	}

	if ( read_argc() == 1 )
	{
		client_print ( id, print_console, "[Swear Replacement] Arguments not provided" )
		return PLUGIN_HANDLED
	}

	new Configsdir[64]
	new replace_file[64]
	get_configsdir( Configsdir, 63 )
	format ( replace_file, 63, "%s/replacements.ini", Configsdir )

	read_args ( g_replaceLines[g_replaceNum], 191 )
	write_file( replace_file, "" )
	write_file( replace_file, g_replaceLines[g_replaceNum] )
	g_replaceNum++

	id ? client_print ( id, print_console, "[Swear Replacement] Replacement Line added to List" ) : server_print ( "[Swear Replacement] Replacement Line added to file" )

	return PLUGIN_HANDLED
}


string_cleaner( str[] )
{
	new len = strlen ( str )

	while ( contain ( str, " " ) != -1 )
		replace ( str, len, " ", "" )

	while ( contain ( str, "." ) != -1 )
		replace ( str, len, ".", "" )


	while ( contain ( str, "," ) != -1 )
		replace ( str, len, ",", "" )
}

leet_cleaner( str[] )
{
	new i, len = strlen ( str )

	len = strlen ( str )
	while ( contain ( str, "|<" ) != -1 )
		replace ( str, len, "|<", "k" )

	len = strlen ( str )
	while ( contain ( str, "|>" ) != -1 )
		replace ( str, len, "|>", "p" )

	len = strlen ( str )
	while ( contain ( str, "()" ) != -1 )
		replace ( str, len, "()", "o" )

	len = strlen ( str )
	while ( contain ( str, "[]" ) != -1 )
		replace ( str, len, "[]", "o" )

	len = strlen ( str )
	while ( contain ( str, "{}" ) != -1 )
		replace ( str, len, "{}", "o" )

	len = strlen ( str )
	for ( i = 0 ; i < len ; i++ )
	{
		if ( str[i] == '@' )
			str[i] = 'a'

		if ( str[i] == '$' )
			str[i] = 's'

		if ( str[i] == '0' )
			str[i] = 'o'

		if ( str[i] == '7' )
			str[i] = 't'

		if ( str[i] == '3' )
			str[i] = 'e'

		if ( str[i] == '5' )
			str[i] = 's'

		if ( str[i] == '<' )
			str[i] = 'c'

		if ( str[i] == '3' )
			str[i] = 'e'

	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1033\\ f0\\ fs16 \n\\ par }
*/
