/*This plugin is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as
*published by Devicenull, twistedeuphoria and {NM}JRBLOODMIST and Feffe; either version 2 of the License, or (at your option) any later version.
*This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
*warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
*for more details. You should have received a copy of the GNU General Public License along with this program; if not,
*write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

Version 2.4
-Added @tsay/@csay/@chat/@psay commands
Version 2.3
-Added more irc_from_hlds_say activators
Version 2.2
-Added integration with amxbans
Version 2.1
-Added the amx_ban feature
-Added bolds to usernames
Version 2.0
-Changed the bot commands such as !ip to show in the channel.

*/

#include <amxmodx>
#include <amxmisc>
#include <engine>
#include <sockets>

#pragma dynamic 9000

#define ACCESS_IRC ADMIN_LEVEL_C
#define MAX_USERS 32

#define max(%1,%2) (%1 > %2 ? %1 : %2)

#define IRC_CMD_PUBLIC  (1<<0)
#define IRC_CMD_PRIVATE (1<<1)
#define IRC_CMD_BOTH    (IRC_CMD_PUBLIC | IRC_CMD_PRIVATE)

new server[64], port, nick[32], username[32], chan[32], error // Stuff needed to connect
new irc_socket //Connection
new temp[1024] //Put together messages with this
new curmesg //Message counter for sending
new pending[256][1024] //Messages Pending to be sent
new pings //Keep track of pings
new users[MAX_USERS][31]
new usersaccess[MAX_USERS]
new usersid[MAX_USERS]
new curuser = 0
new accessfile[201]
new loginfile[201]

// helper functions

strcpy(dest[], source[])
{
	new length = strlen(source);
	copy(dest, length, source);
	dest[length] = 0;
}

inttostrlen(integer)
{
	format(temp, 1024, "%d", integer);
	return strlen(temp);
}

fill(character, count)
{
	for (new i = 0; i < count; i++) temp[i] = character;
	temp[count] = 0;
	return temp;
}

format2(string[], ...)
{
	vformat(temp, 1024, string, 2);

	return temp;
}

stringcmp(str1[], start1, str2[], start2 = 0)
{
	if (strlen(str1) - start1 < strlen(str2) - start2) return false;
	new i = start1;
	new j = start2;
	while ((i < strlen(str1)) && (j < strlen(str2)))
	{
		if (str1[i] != str2[j]) return false;
		i++;
		j++;
	}
	return true;
}

string_first_token(str[])
{
	new unused[1];
	strtok(str, temp, 1024, unused, 0);
	return temp;
}

str_get_cvar(cvar[])
{
	get_cvar_string(cvar, temp, sizeof(temp)-1)
	return temp;
}

// irc functions

#define IRC_MSG_PRIVMSG "PRIVMSG"
#define IRC_MSG_NOTICE  "NOTICE"

irc_print(string[], ...)
{
	vformat(temp, 1024, string, 2);
	strcat(temp, "^r^n", sizeof(temp)-1);
	additem(temp);
}

public irc_msg(message_type[], target[], message[], ...)
{
	vformat(temp, sizeof(temp)-1, message, 4);
	irc_print("%s %s :%s", message_type, target, temp)
}

public irc_privmsg(target[], message[], ...)
{
	vformat(temp, sizeof(temp)-1, message, 3);
	irc_print("PRIVMSG %s :%s", target, temp)
}

public irc_notice(target[], message[], ...)
{
	vformat(temp, sizeof(temp)-1, message, 3);
	irc_print("NOTICE %s :%s", target, temp)
}

public irc_quit(message[])
{
	format(temp, sizeof(temp)-1,"QUIT :%s ^r^n", message);
	socket_send(irc_socket, temp, 0);
	socket_close(irc_socket);
	irc_socket = 0;
	set_cvar_num("irc_socket", 0);
}

public irc_pong(target[])
{
	irc_print("PONG :%s", target)
}

public irc_server_status(message_type[], target[])
{
	irc_print("%s %s :%s", message_type, target, get_server_status());
}

public irc_join(chan[])
{
	irc_print("JOIN %s", chan);
}

public irc_join_default()
{
	irc_join(str_get_cvar("irc_channel"));
}

public irc_identify()
{
	str_get_cvar("irc_identify");
	if (strlen(temp))
		irc_print("%s", temp);
}

irc_print_array(array[][], size, ...)
{
	for (new i = 0; i < size; i++)
	{
		vformat(temp, sizeof(temp)-1, array[i], 3);
		additem(temp);
	}
}

static irc_help_command_synonyms[][] = { "cmds", "info", "commands", "help" };

irc_is_help_synonym(prefix, string[])
{
	for (new i = 0; i < sizeof(irc_help_command_synonyms); i++)
	{
		if ((prefix == 0) && equali(string, irc_help_command_synonyms[i])) return true;
		if ((strlen(string) > 0) &&
		    (prefix == string[0]) &&
				stringcmp(string, 1, irc_help_command_synonyms[i])) return true;
	}
	return false;
}

static irc_help_commands_header[][] = {
	"%s %s :IRC<->HLDS - Written by Devicenull, updated by maintained by twistedeuphoria, {NM}JRBLOODMIST, ToXedVirus ",
	"%s %s :Available commands (to use commands in channel add ! to the front of the command, otherwise private message commands to the bot):",
	"%s %s :cmds / commands / help / info - Display this help."
}

static irc_commands[][] = {
	{ IRC_CMD_PRIVATE, 2, "login" ,   "Log into HLDS<->IRC as an admin.", "username", "password" },
	{ IRC_CMD_PRIVATE, 0, "logout",   "Log out of HLDS<->IRC admin. You will automatically be logged out if you quit IRC. " },
	{ IRC_CMD_BOTH,    0, "players",  "List the users currently on the server." },
	{ IRC_CMD_BOTH,    0, "map",      "Display the currently played map." },
	{ IRC_CMD_BOTH,    0, "nextmap",  "Display the next map in the map cycle." },
	{ IRC_CMD_BOTH,    0, "timeleft", "Display the amount of time left on the current map." },
	{ IRC_CMD_BOTH,    0, "ip",       "Display the IP of the server." },
	{ IRC_CMD_BOTH,    0, "status",   "Display the status of the server." }
};

public irc_command_fits(command[], prefix)
{
	for (new i = 0; i < sizeof(irc_commands); i++)
	{
		if ((prefix == 0 && (irc_commands[i][0] & IRC_CMD_PRIVATE) &&    equali(irc_commands[i][2],    command   )) ||
		    (prefix != 0 && (irc_commands[i][0] & IRC_CMD_PUBLIC ) && stringcmp(irc_commands[i][2], 0, command, 1))) return i;
	}
	return -1;
}

static irc_help_commands_trailer[][] = {
	"%s %s :Additional commands are available while PMing the bot.  PM the bot with cmds to view them."
}

public irc_cmd_list(message_type[], target[], prefix)
{

	irc_print_array(irc_help_commands_header,  sizeof(irc_help_commands_header),  message_type, target);

	for (new i = 0; i < sizeof(irc_commands); i++) {
		// 2 is the command
		// 3 is the description
		if (equali(message_type, IRC_MSG_PRIVMSG))
			irc_print("%s %s :%s - %s", message_type,
			                            target,
															    irc_commands[i][2],
																	irc_commands[i][3 + strlen(irc_commands[i][2])]
																	);
		else
			irc_print("%s %s :%c%s - %s", message_type,
			                              target,
																		prefix,
																		irc_commands[i][2],
																		irc_commands[i][3 + strlen(irc_commands[i][2])]
																		);
	}

	if (equali(message_type, IRC_MSG_PRIVMSG))
	irc_print_array(irc_help_commands_trailer, sizeof(irc_help_commands_trailer), message_type, target);

	new adminaccess = is_irc_admin(target)
	if (adminaccess == -1) return -1;

	irc_print("%s %s :Admin commands available on the server are also available from IRC if you have sufficient access.",
						message_type, target);

	return 0;
}

public irc_cmd_players(message_type[], target[])
{
	new authid[35], uname[32], ip[51], ping, loss;
	new authid_max = 0, uname_max = 0, ip_max = 0, ping_max = 0, loss_max = 0;

	irc_print("%s %s :Begin Players List", message_type, target);

	for (new i = 0; i < 34; i++)
	{
		if (!is_user_connected(i)) continue;

		get_user_authid (i, authid, 34);
		get_user_name   (i, uname,  31);
		get_user_ip     (i, ip,     50);
		get_user_ping   (i, ping,   loss);

		authid_max = max(authid_max, strlen(authid));
		uname_max  = max(uname_max,  strlen(uname ));
		ip_max     = max(ip_max,     strlen(ip    ));

		ping_max = max(ping_max, inttostrlen(ping));
		loss_max = max(loss_max, inttostrlen(loss));
	}

	for (new i = 0; i < 34; i++)
	{
		if (!is_user_connected(i)) continue;

		get_user_authid (i, authid, 34);
		get_user_name   (i, uname,  31);
		get_user_ip     (i, ip,     50);
		get_user_ping   (i, ping,   loss);

		irc_print("%s %s :#%d %s%s %s%s %s%s %s%d %s%d", message_type, target, i,
					    authid, fill(' ', authid_max - strlen(authid)),
					    fill(' ', uname_max  - strlen(uname)),  uname,
					    fill(' ', ip_max     - strlen(ip)),     ip,
					    fill(' ', ping_max   - inttostrlen(ping)), ping,
					    fill(' ', loss_max   - inttostrlen(loss)),  loss);
	}

	irc_print("%s %s :End Players List", message_type, target)
}

public irc_cmd_login(message_type[], name[], command[], prefix)
{
	new usern[32], pass[32], extra[32];

	parse(command, extra, sizeof(extra)-1,
	               usern, sizeof(usern)-1,
								 pass,  sizeof(pass) -1);

	new retstr[512],
	    irir = 0, a = 0,
			bool:userexists = false;

	while (read_file(accessfile, irir, retstr, sizeof(retstr)-1, a))
	{
		irir++
		// # is the ommiting character for strings
		if (retstr[0] == '#') continue;
		new fuser[32], fpass[32], faccess[32], fid[32];

		parse(retstr, fuser,   sizeof(fuser)   -1,
		              fpass,   sizeof(fpass)   -1,
									faccess, sizeof(faccess) -1,
									fid,     sizeof(fid)     -1);

		server_print(fuser);

		if (!equali(usern, fuser))
			continue;

		userexists = true;

		if (!equali(pass,fpass))
		{
			irc_privmsg(name, "Invalid username/password combo: %s/%s.", usern, pass);
			return;
		}

		new fidnum = str_to_num(fid);
		new bool:there = false;
		for (new inum=0; inum < MAX_USERS; inum++)
		{
			if (usersid[inum] == fidnum) there = true;
		}

		if (there)
		{
			irc_privmsg(name, "User %s is already logged in.", usern);
			return;
		}

		copy(users[curuser], 30, name)
		usersaccess[curuser] = read_flags(faccess);
		usersid[curuser] = fidnum:
		curuser++;
		irc_privmsg(name, "You successfully logged in as %s.", usern);

		new writestr[128];
		format(writestr, sizeof(writestr)-1, "^"%s^" ^"%s^" ^"%s^"", name, faccess, fid);

		new nextline = 0;
		new rstr[201], fnum, b;
		while (read_file(loginfile, fnum, rstr, sizeof(rstr)-1, b))
		{
			if (b <= 0)
			{
				nextline = fnum;
				break;
			}
			fnum++;
		}
		if (!nextline)
			write_file(loginfile, writestr);
		else
			write_file(loginfile, writestr, nextline);
	}

	if (!userexists)
	{
		irc_privmsg(name, "No admin accounts exist with username ^"%s^"", usern);
	}
}

public irc_cmd_logout(message_type[], name[])
{
	irc_admin_logout(name, 1)
}

public irc_cmd_ip(message_type[], target[])
{
	new ip[51];
	get_user_ip(0, ip, 50);
	irc_print("%s %s :Server IP: %s", message_type, target, ip);
}

public irc_cmd_timeleft(message_type[], target[])
{
	new timeleft[26];
	get_cvar_string("amx_timeleft", timeleft, 25);
	irc_print("%s %s :Time left: %s", message_type, target, timeleft);
}

public irc_cmd_nextmap(message_type[], target[])
{
	new nextmap[51];
	get_cvar_string("amx_nextmap", nextmap, 50);
	irc_print("%s %s :next map: %s", message_type, target, nextmap);
}

public irc_cmd_map(message_type[], target[])
{
	new mapname[51];
	get_mapname(mapname, 50);
	irc_print("%s %s :Current map: %s", message_type, target, mapname);
}

public irc_cmd_status(message_type[], target[])
{
	irc_print("%s %s :%s", message_type, target, get_server_status());
}

irc_handle_commands(name[], command[], priv)
{
	new prefix = (priv ? 0 : '@');

	// quick check if it fits
	if ((prefix != 0) && (strlen(command) > 0) && command[0] != prefix) return;

	new message_type[8];
	strcpy(message_type, (priv ? IRC_MSG_PRIVMSG : IRC_MSG_NOTICE));

	if (irc_is_help_synonym(prefix, command))
	{
		irc_cmd_list(message_type, name, prefix);
		return;
	}

	//new index = irc_command_fits(command, prefix);
	new index = irc_command_fits(string_first_token(command), prefix);
	if (index != -1)
	{
		callfunc_begin(format2("irc_cmd_%s", irc_commands[index][2]));
		callfunc_push_str(message_type);
		callfunc_push_str(name);
		callfunc_push_str(command);
		callfunc_push_int(prefix);
		callfunc_end();
	} else irc_method_missing(name, command, priv);
}

irc_method_missing(name[], command[], priv)
{
	new adminaccess = is_irc_admin(name)
	if (adminaccess != -1) do_command(name, adminaccess, command, (priv ? IRC_MSG_PRIVMSG : IRC_MSG_NOTICE));
}

// info formatting functions

public get_server_status()
{
	str_get_cvar("irc_msg_startup");

	if (strlen(temp) > 0)
	{
		new mapname[32],
		    serverip[35],
		    servername[100],
		    playerstr[3],
				maxplayerstr[3];

		get_mapname (mapname, sizeof(mapname)-1);

		get_user_ip  (0, serverip,   sizeof(serverip)-1);
		get_user_name(0, servername, sizeof(servername)-1);

		num_to_str(get_playersnum(1), playerstr,    sizeof(playerstr)-1);
		num_to_str(get_maxplayers(),  maxplayerstr, sizeof(maxplayerstr)-1);

		replace(temp, sizeof(temp)-1, "$maxplayers", maxplayerstr);
		replace(temp, sizeof(temp)-1, "$curplayers", playerstr   );
		replace(temp, sizeof(temp)-1, "$map",        mapname     );
		replace(temp, sizeof(temp)-1, "$ip",         serverip    );
		replace(temp, sizeof(temp)-1, "$servername", servername  );

	}
	return temp;
}

// main functions

public plugin_init()
{
	register_plugin("HLDS<->IRC","2.7","devicenull")

	register_dictionary("admincmd.txt");
	register_dictionary("common.txt"  );
	register_dictionary("pausecfg.txt");

	// Cvars
	register_cvar("irc_server",   "");
	register_cvar("irc_nick",     "");
	register_cvar("irc_username", "");
	register_cvar("irc_port",     "");
	register_cvar("irc_channel",  "");


	register_cvar("irc_prefix",     "1");
	register_cvar("irc_show_joins", "1");
	register_cvar("irc_show_team",  "1");
	register_cvar("irc_joindelay", "10");
	register_cvar("irc_identify",   "0");
	register_cvar("irc_debug",      "0");

	register_cvar("irc_ident", "", FCVAR_PROTECTED&FCVAR_UNLOGGED);

	register_cvar("irc_map_change","1")
	register_cvar("irc_to_hlds_say_auto","1")
	register_cvar("irc_to_hlds_say_activator","!hlds")

	register_cvar("irc_hlds_activator", "");


	//Various Messages
	register_cvar("irc_msg_srvjoin", " $name ($steamid) has joined the server");
	register_cvar("irc_msg_srvpart", " $name ($steamid) has left the server");
	register_cvar("irc_msg_startup", " $servername  - $ip Current Map: $map $curplayers / $maxplayers players");

	register_cvar("irc_msg_usecolors", "1");

	register_cvar("irc_socket","0",FCVAR_PROTECTED&FCVAR_UNLOGGED)

	// Commands
	register_concmd("irc","parseirc",0," Type ^"irc help^" for help");


	register_clcmd("say","cmd_say")
	register_clcmd("say_team","cmd_say_team")

	set_task(1.0, "IRC_Init");
}

public IRC_Init()
{
	server_print "HLDS <-> IRC is connecting"
	set_task(1.0,"irc_datacheck",_,_,_,"b")
	set_task(0.5,"sendnext",_,_,_,"b")

	if (!get_cvar_num("irc_socket"))
		set_task(get_cvar_float("irc_joindelay"), "irc_connect")
	else
		irc_socket = get_cvar_num("irc_socket")

	get_cvar_string("irc_server",server,64)
	get_cvar_string("irc_nick",nick,32)
	get_cvar_string("irc_channel",chan,32)
	get_cvar_string("irc_username",username,32)
	port = get_cvar_num("irc_port")

	if (irc_socket > 0)
		irc_server_status(IRC_MSG_PRIVMSG, chan);

	new directory[128];
	get_configsdir(directory, sizeof(directory)-1);
	format(accessfile, sizeof(accessfile)-1, "%s/ircadmins.ini", directory);
	admin_file_create();

	get_datadir(directory, sizeof(directory)-1);
	format(loginfile, sizeof(loginfile)-1, "%s/ircloggedin.list", directory);

	admin_check()
}

public admin_file_create()
{
	if(!file_exists(accessfile))
	{
		write_file(accessfile, "# ^"username^" ^"password^" ^"flags^" ^"unique id^"");
		write_file(accessfile, "# Access level uses the same levels as users.ini. The unique id is a unique number to identify each admin.");
		write_file(accessfile, "# ^"test^" ^"test^" ^"abcdefghijklmnopqrstu^" ^"1337^"");
	}
}

public admin_check()
{
	if(!file_exists(loginfile))
	{
		write_file(loginfile, "HLDS<->IRC Log file")
	}
	else
	{
		new retstr[201], a, inum = 0
		while(read_file(loginfile,inum,retstr,200,a) != 0)
		{
			inum++
			if(retstr[0] == '"')
			{
				new usern[31], accesslevel[31], accessid[31]
				parse(retstr,usern,30,accesslevel,30,accessid,30)
				copy(users[curuser], 30, usern)
				usersaccess[curuser] = read_flags(accesslevel)
				usersid[curuser] = str_to_num(accessid)
				curuser++
			}
		}
	}
}

public irc_connect()
{
	get_cvar_string("irc_server",   server,   sizeof(server)   -1);
	get_cvar_string("irc_nick",     nick,     sizeof(nick)     -1);
	get_cvar_string("irc_channel",  chan,     sizeof(chan)     -1);
	get_cvar_string("irc_username", username, sizeof(username) -1);

	port = get_cvar_num("irc_port");

	irc_socket = socket_open(server, port, SOCKET_TCP, error);

	switch (error)
	{
		case 1: { log_amx("[IRC] Error creating socket to %s:%i",server, port); return -1; }
		case 2: { log_amx("[IRC] Error resolving hostname %s", server);         return -2; }
		case 3:	{ log_amx("[IRC] Couldn't connect to %s:%i", server, port);     return -3; }
	}

	pings = 0;

	set_cvar_num("irc_socket", irc_socket);

	irc_print("NICK %s^r^nUSER %s 0 * :HLDS Bot", nick, username);
	pings = 2;

	server_print("[IRC] Connected sucessfully");
	irc_join_default();
	irc_identify();
	irc_server_status(IRC_MSG_PRIVMSG, chan);

	return irc_socket
}

public irc_datacheck()
{
	if (socket_change(irc_socket,1))
	{
		new rdata[1024] //, data[1024]
		socket_recv(irc_socket,rdata,1024)
		copyc(rdata,1024,rdata,10)
		irc_dataparse(rdata)
		copy(temp,1024,rdata[strlen(rdata)+1])
		if (containi(temp,"^r"))
		{
			irc_dataparse(rdata[strlen(rdata)+1])
		}
	}
}

static irc_numeric_events[][] = {
	{ 403, "No such channel" },
	{ 405, "Can't join any more channels" },
	{ 432, "Invalid characters in nickname" },
	{ 433, "Nickname in use" },
	{ 437, "Can't change nick, we are in a channel we are banned from" },
	{ 471, "Limit on channel reached, remove +l and try again" },
	{ 473, "Channel is +i, invite us in and try again" },
	{ 474, "We are banned from that channel" },
	{ 475, "Channel is +k and we don't have the key!" },
	{ 482, "Can't set modes when we aren't op" }
}

public irc_dataparse(rdata[])
{
	if (!strlen(rdata))
		return 0;

	//If there is data
	new arg1[128],arg1len,arg2[128] ,arg2len, arg3[128]
	copyc(arg1,128,rdata,32)
	arg1len = strlen(arg1)
	copyc(arg2,128,rdata[arg1len+1],32)
	arg2len = strlen(arg2)
	copyc(arg3,128,rdata[arg1len+arg2len+2],32)
	new numeric_event = str_to_num(arg2);
	switch (numeric_event)
	{
		// Numeric Events - http://www.faqs.org/rfcs/rfc1459.html
		case 001:
		{
			server_print("[IRC] Connected sucessfully");
			irc_join_default();
			set_cvar_num("irc_socket", irc_socket);
			irc_identify();
			irc_server_status(IRC_MSG_PRIVMSG, chan);
			return 0;
		}
		// Following events occure after successful connection
		case 513:
		{
			server_print("[IRC] Error: Registration failed, try again later");
			irc_quit("");
			return 0;
		}
		// events with message, but no action
		default:
		{
			for (new i = 0; i < sizeof(irc_numeric_events); i++)
			{
				if (irc_numeric_events[i][0] == numeric_event)
				{
					server_print("[IRC] Error: %s", irc_numeric_events[i][1]);
					return 0;
				}
			}
		}
	}

	if (get_cvar_num("irc_debug"))
		server_print("[IRC]<- %s", rdata);


	if( contain(rdata, "^r^nPING :") > -1 )
	{
		new arg2[33];
		copy(arg2, 32, rdata[contain(rdata, "^r^nPING :")])
		replace_all(arg2, 32, "^r^nPING :", "");
		replace_all(arg2, 32, "^r^n", "");
		irc_pong(arg2);
		pings++
		return 0
	}
	else if (equali(arg1,"PING"))
	{
		irc_pong(arg2);
		pings++
		return 0
	}
	else if (equali(arg2,IRC_MSG_PRIVMSG))
	{
		// Username!Ident@Host PRIVMSG Destination :Message
		new user[32], message[768], frmt[256]
		new arg123len
		copyc(user,32,arg1[1],33) //Get the username out of arg1
		arg123len = strlen(arg1) + 1 + strlen(arg2) + 1 + strlen(arg3) + 1
		copy(message,768,rdata[arg123len])
		copyc(message,768,message,13)
		new truemessage[768]
		copy(truemessage,768,message[1])
		if(equali(arg3,chan))
		{
			//channel_commands(user, truemessage)
			irc_handle_commands(user, truemessage, 0);
		}
		else {
			//private_commands(user, truemessage)
			irc_handle_commands(user, truemessage, 1);
		}
		if(is_irc_admin(user) != -1)
			admin_commands(user, truemessage)
		if (equali(arg3,chan))
		{
			new firstword[128]
			copyc(firstword,128,message[1],44)
			// Its a message that should go to the server
			if (get_cvar_num("irc_prefix"))
				format(frmt,256,"%s@%s <%s> %s",chan,server,user,message[1])
			else
				format(frmt,256,"*IRC* <%s> %s",user,message[1])
			if(!get_cvar_num("irc_to_hlds_say_auto"))
			{
				new activator[26]
				get_cvar_string("irc_to_hlds_say_activator",activator,25)
				if(containi(frmt,activator) == -1)
					return 0
				else
				{
					replace(frmt,256,activator,"")
				}
			}
			client_print(0,print_chat,"%s",frmt)
			return 0
		}
	}
	else if(equali(arg2,"NICK"))
	{
		new oldname[31], newname[31], tempname[32]
		copy(newname,30,arg3[1])
		copyc(tempname,31,arg1,33)
		copy(oldname,30,tempname[1])
		trim(oldname)
		trim(newname)
		for(new inum=0;inum<MAX_USERS;inum++)
		{
			if(equali(users[inum],oldname))
			{
				copy(users[inum],30,newname)
				new retstr[201], jnum, a
				while(read_file(loginfile,jnum,retstr,200,a) != 0)
				{
					new usern[31], uaccess[31], fid[31]
					parse(retstr,usern,30,uaccess,30,fid,30)
					if(equali(usern,oldname))
					{
						replace(retstr,200,oldname,newname)
						write_file(loginfile,retstr,jnum)
					}
					jnum++
				}
			}
		}
	}
	else if(equali(arg2,"QUIT"))
	{
		new leavename[31], tempname[32]
		copyc(tempname,31,arg1,33)
		copy(leavename,30,tempname[1])
		irc_admin_logout(leavename,0)
	}
	else if (equali(arg1,"ERROR"))
	{
		irc_quit("");
		server_print("[IRC] Disconnected, trying to reconnect")
		set_task(Float:60,"irc_connect")
	}
	return 0;
}
public additem(item[])
{
	if(curmesg <= 255)
	{
		copy(pending[curmesg],1024,item)
		curmesg++
	}
	else
	{
		new quicksend[201]
		format(quicksend,200,"PRIVMSG %s :IRC message overflow, clearing stack.^r^n",chan)
		socket_send(irc_socket,quicksend,0)
		log_amx("IRC Message Stack Overflow...Clearing...")
		for(new inum=0;inum<256;inum++)
		{
			copy(pending[inum],1024,"")
		}
		curmesg = 0
	}
	return 0
}

public sendnext()
{
	if (curmesg >= 1)
	{
		remove_quotes(pending[0])
		socket_send(irc_socket,pending[0],0)
		if (get_cvar_num("irc_debug"))
			server_print("[IRC]-> %s", pending[0]);
		for (new i=0;i<=curmesg;i++)
		{
			copy(pending[i],1024,pending[i+1])
		}
		curmesg--
	}
}

static cmd_irc_commands[][] = {
	{ "connect",	  "Connects the bot to the server and channel selected by the cvars." },
	{ "disconnect", "Disconnects the bot from the active server." },
	{ "say",        "Prints some text in the channel selected by the cvar" },
	{ "join",       "Attempts to join the default channel" },
	{ "stats",      "Reports the status of the bot" },
	{ "help",       "Prints this help message" },
	{ "identify",   "Sends the bot identification string to the server" }
}

public cmd_irc_connect(id)
{
	irc_connect();
	console_print(id,"[IRC] Attempting to connect")
}

public cmd_irc_disconnect(id)
{
	irc_quit("");
	console_print(id,"[IRC] Disconnecting")
}

public cmd_irc_say(id)
{
	new msg[1024];
	read_args(msg, sizeof(msg)-1);
	// ommit "say "
	// strlen("say ") == 4
	irc_privmsg(chan, msg[4]);
}

public cmd_irc_join(id)
{
	irc_join_default()
	console_print(id,"[IRC] Attempting to join %s",chan)
}

public cmd_irc_stats(id)
{
		console_print(id, "[IRC] Status:");
		console_print(id, "[IRC] cvar port %i, irc_socket %i", get_cvar_num("irc_socket"), irc_socket);
		console_print(id, "[IRC] internal vars: nick: %s, username: %s, chan: %s, server: %s, port: %i",
		                  nick, username, chan, server, port);
		console_print(id, "[IRC] Ping counter at %i, message counter at %i", pings, curmesg);
}

public cmd_irc_help(id)
{
	server_print("[IRC] #irc subcommand - description");

	for (new i = 0; i < sizeof(cmd_irc_commands); i++)
	{
		new arg2 = strlen(cmd_irc_commands[i][0]);
		console_print(id, "[IRC] irc %s - %s", cmd_irc_commands[i][0], cmd_irc_commands[i][arg2+1]);
	}
}

public cmd_irc_identify(id)
{
	irc_identify()
	console_print(id,"[IRC] Identifying")
}

public parseirc(id)
{
	if (!(get_user_flags(id)&ACCESS_IRC))
	{
		console_print(id, "[IRC] Access Denied");
		return PLUGIN_HANDLED;
	}
	new subcommand[32];
	read_argv(1, subcommand, sizeof(subcommand) -1);

	for (new i = 0; i < sizeof(cmd_irc_commands); i++)
	{
		if (equali(subcommand, cmd_irc_commands[i][0]))
		{
			callfunc_begin(format2("cmd_irc_%s", cmd_irc_commands[i][0]));
			callfunc_push_int(id);
			callfunc_end();
			return PLUGIN_HANDLED;
		}
	}
	console_print(id, "[IRC] Error: Uknown command");
	cmd_irc_help(id);
	return PLUGIN_HANDLED;
}

public parsemessage(id, input[], msg[])
{
	// Replaces $name $steamid $team $teamn $message with the right things
	new name[32], authid[32], team[32], teamn, teamnstr[32], ctime, hrs, csec, flags[32], times[128];

	get_user_name  (id, name,   sizeof(name)   -1);
	get_user_authid(id, authid, sizeof(authid) -1);
	get_user_team  (id, team,   sizeof(team)   -1);

	get_flags(get_user_flags(id), flags, sizeof(flags) -1);

	ctime = get_user_time(id);
	hrs = floatround(float(ctime/60));
	csec = ctime-(hrs*60);
	format(times,128,"[%i:%i]", hrs, csec);
	teamn = entity_get_int(id, EV_INT_team);
	num_to_str(teamn,teamnstr, sizeof(teamnstr) -1);
	copy(temp, strlen(input), input);
	remove_quotes(msg);

	replace(temp, sizeof(temp)-1, "$name",      name    );
	replace(temp, sizeof(temp)-1, "$steamid",   authid  );
	replace(temp, sizeof(temp)-1, "$teamn",     teamnstr);
	replace(temp, sizeof(temp)-1, "$team",      team    );
	replace(temp, sizeof(temp)-1, "$message",   msg     );
	replace(temp, sizeof(temp)-1, "$connected", times   );
	replace(temp, sizeof(temp)-1, "$access",    flags   );

	remove_quotes(temp);
	return temp;
}

public cmd_say(id)
{
	return cmd_say_base(id, 1);
}

public cmd_say_team(id)
{
	return cmd_say_base(id, 0);
}

static irc_team_colors[][] = { { "00" }, { "04" }, { "12" }, { "00" } };
static irc_team_strings[][] = { { "Spectator" }, { "Terrorist "}, { "Counter-Terrorist" }, { "Spectator" } };

cmd_say_base(id, pub)
{
	if (!irc_socket)
		return PLUGIN_CONTINUE;

	new msg[1024];

	read_args(msg, sizeof(msg)-1);
	remove_quotes(msg);

	if(!strlen(msg))
		return PLUGIN_CONTINUE;

	new name[32];
	get_user_name(id, name, sizeof(name)-1);
	if (containi(msg,"/admin") != -1)
	{
		replace(msg, sizeof(msg)-1, "/admin", ""); // remove the /admin command
		irc_privmsg(chan, "Admin request by %s. %s", name, msg);
		client_print(id, print_chat, "Your admin request was sent to the channel.");
		return PLUGIN_HANDLED;
	}
	else if (strlen(str_get_cvar("irc_hlds_activator")) > 0)
	{
		if (containi(msg, temp) == -1)
			return PLUGIN_CONTINUE;
		else
			replace(msg, sizeof(msg), temp, "");
	}

	new payload[1024];
	payload[0] = 0;

	if (!is_user_alive(id))
		strcat(payload, "*DEAD* ", sizeof(payload)-1);

	new modname[50];
	get_modname(modname, sizeof(modname)-1);

	if (equali(modname, "cstrike"))
	{
		if (!pub)
		{
			formatex(payload, sizeof(payload)-1, "%s(%s) ", payload,
																											irc_team_strings[get_user_team(id)]);
		}
		if (get_cvar_num("irc_msg_usecolors"))
			strcat(payload, irc_team_colors[get_user_team(id)], sizeof(payload)-1);

		formatex(payload, sizeof(payload)-1, "%s%s: %s", payload, name, msg);
	}
	else
		formatex(payload, sizeof(payload)-1, "%s%s: %s", payload, name, msg);


	irc_privmsg(chan, "<HLDS> %s", payload);
	return PLUGIN_CONTINUE;
}

public client_putinserver(id)
{
	if (irc_socket > 0 && get_cvar_num("irc_show_joins") == 1)
	{
		str_get_cvar("irc_msg_srvjoin");

		if (strlen(temp) == 0)
			return 0;

		irc_privmsg(chan, parsemessage(id, temp, ""));
	}
	return 0
}

public client_disconnect(id)
{
	if (irc_socket > 0 && get_cvar_num("irc_show_joins") == 1)
	{
		str_get_cvar("irc_msg_srvpart");

		if (strlen(temp) == 0)
			return 0;

		irc_privmsg(chan, parsemessage(id, temp, ""));
	}
	return 0
}

public is_irc_admin(name[])
{
	new adminnum = -1
	for(new inum=0;inum<MAX_USERS;inum++)
	{
		if(equali(users[inum],name))
			adminnum = inum
	}
	if(adminnum > -1)
		return usersaccess[adminnum]
	return -1
}

public irc_admin_logout(adminname[], report)
{
	new adminnum = 0, bool:there = false;

	for (new inum=0;inum < MAX_USERS; inum++)
	{
		if (equali(users[inum],adminname))
		{
			there = true;
			adminnum = inum;
		}
	}

	if (!there)
	{
		irc_privmsg(adminname, "You are not logged in as an admin.");
		return PLUGIN_CONTINUE;
	}

	for (new inum = adminnum; inum < MAX_USERS; inum++)
	{
		if(strlen(users[inum+1]) > 0)
		{
			copy(users[inum], 30, users[inum+1]);
			usersaccess[inum] = usersaccess[inum+1];
			usersid[inum] = usersid[inum+1];
		}
		else
		{
			copy(users[inum], 30, "");
			usersaccess[inum] = -1;
			usersid[inum] = -1;
			break;
		}
	}

	new retstr[256], fnum, a;
	while (read_file(loginfile, fnum, retstr, sizeof(retstr)-1, a))
	{
		new fuser[32], faccess[32], fid[32];
		parse(retstr, fuser,   sizeof(fuser)   -1,
		              faccess, sizeof(faccess) -1,
									fid,     sizeof(fid)     -1);

		if (equali(fuser,adminname))
			write_file(loginfile, "", fnum)

		fnum++
	}

	if (report)
		irc_privmsg(adminname, "You have logged out.");

	return PLUGIN_CONTINUE;
}

public admin_commands(name[],command[])
{
	//Replace with a command lookup and stuff, not a list of commands using containi
	//new uaccess = is_irc_admin(name)
	return PLUGIN_CONTINUE
}

public do_command(name[], adminaccess, commandstr[], msg_type[])
{
	new command[64], parameters[64];

	strbreak(commandstr, command,    sizeof(command),
	                     parameters, sizeof(parameters));

	replace(command, sizeof(command)-1, "@", "");

	if (equali(command,"amx_rcon") && (adminaccess & ADMIN_RCON))
	{
		server_cmd("%s", parameters);
		irc_msg(msg_type, name, "Command successful!");
	}

	// with adminacccess we specify what commands to get
	new maxconcmds = get_concmdsnum(adminaccess, -1);
	new rcommand[64], rinfo[64], rflags;

	for (new i = 0; i <= maxconcmds ; i++)
	{
		// last option: 0 server commands, + player commands, - all commands
		get_concmd(i, rcommand, sizeof(rcommand) -1,
		              rflags,
									rinfo,    sizeof(rinfo)    -1,
									adminaccess,
									-1);

		if (!strlen(rcommand)) break;

		if (equali(command,rcommand))
		{
			irc_msg(msg_type, name, "Command successful!");
			server_cmd("%s %s", command, parameters);
			return PLUGIN_HANDLED;
		}
	}
	irc_msg(msg_type, name, "No such command.");
	return PLUGIN_HANDLED;
}
