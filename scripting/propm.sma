/* Professional Private Message */
/* --------------- */
/* Create by Thizk */
/* --------------- */
/* Commands        */
/* --------------- */
/* Usage : 
{ 
	"!",".","&","/","%","=","¡","'","pm"
}
*/
/* --------------- */
/* Example : */
/* Say in Chat ! <Name> <Message> */
/* --------------- */
/* --------------- */
/* Description 	   */
/* --------------- */
/* The message appears with the style of counter strike condition zero */
/* --------------- */
/*  Images	   */
/* --------------- */
/* http://a.imagehost.org/download/0664/propm */
/* --------------- */
/* Changelog */
/* --------------- */
/*

	Version 1.1
               *Fixed Sound Dir
	
	Version 1.2
               *Fixed Host_Error: WriteDest_Parm: not a client
	       
	Version 1.3.1
               *Add Simple Spam Blocker
	       *Add Usage Commands
	       
        Version 1.3.2
               *Add Simple Spam Blocker V2 Changes:
			Add Websites Block And Max Numbers to put 4 
			And Block Point "," Max to put 2
	       *Add Change <message> <user#id> to <user#id> <message>
			
*/


#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

#define PLUGIN "Professional Private Message"
#define VERSION "1.3.2"
#define AUTHOR "Thizk"

#define TASK_TUT 1111
#define PROPM_SOUND "buttons/bell1.wav"

/* Start Simple Spam Blocker */
enum
{
	WebSites = 0,
	Numbers = 1,
	Point = 3,
	Max
}

new const Domains[] = 
{
	".net",
	".com",
	".org",
	".es",
	".com.ar",
	".ru",
	".tl",
	".tk",
	".us"
}
/* End Simple Spam Blocker */

/* Tutor Text Colors */
enum
{
	RED = 1,
	BLUE,
	YELLOW,
	GREEN
}

/* Tutor Text Msg*/
new g_MsgTutor,g_MsgTutClose


public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	g_MsgTutor = get_user_msgid("TutorText")
	g_MsgTutClose = get_user_msgid("TutorClose")
	
	register_cvar("amx_pmversion",VERSION,FCVAR_SPONLY|FCVAR_SERVER)
	register_clcmd("say", "send_chat", 0, "<user#id> <message>  - user sends a message to another user.");
	register_clcmd("say_team", "send_chat", 0, "<user#id> <message>  - user sends a message to another user.");
}

public plugin_precache()
{
	precache_sound(PROPM_SOUND)
}

public send_chat(id, level, cid)
{
	if (!cmd_access(id, level, cid, 2))
		return PLUGIN_HANDLED
		
		
	new szMsg[256],left[92],right[92]
	
	read_args(szMsg, 255)
	remove_quotes(szMsg)
	strtok(szMsg,left,91,right,91)
	
	new const zsCmds[] = 
	{ 
		"!",".",
		"&","/",
		"%","=","¡","'",
		"pm"
	}
	
	for(new i = 0;i < sizeof(zsCmds);i++)
	{
	
		if(equali(left,zsCmds[i]))
		{
			new sts[256], target[256], message[256]
			strtok(szMsg,sts,255,szMsg,255)
			strtok(szMsg,target,255,message,255)
	    
			new sendername[32], plr ,targetname[32]
			get_user_name(id, sendername, 31)
			get_user_name(plr,targetname,31)
			
			// Invalid User Id 
			plr = find_player("bhl", target)
			if (plr == 0) 
			{ 
				client_print(id, print_chat, "[ProPM] Sorry, unable to find player with that name.")
				return PLUGIN_HANDLED;
			}
			
			// Cannot Send Message To you itself
			plr = find_player("bhl",sendername)
			if (plr == 1 )
			{
				
				client_print(id,print_chat,"[ProPM] You cannot send the message")
				return PLUGIN_HANDLED;
			}
	
			// Logs File 
			new basedir[64]
			get_basedir(basedir, 63)
			
			new LOG_FILE[164]
			format(LOG_FILE, 163, "%s/logs/pmlog.log", basedir)
			
			new log[256];
			format(log,255,"From %s: to %s - Message:%s",sendername,targetname,message)
			write_file(LOG_FILE,log);
			
			/* Start Simple Spam Blocker Code By ReymonArg Modified for my */
			
			new count[Max]
			for( new i = 0; i < strlen(message) ; i++)
			{
				switch(message[i])
				{
					case '0', '1', '2', '3', '4', '5', '6', '7', '8', '9' : count[Numbers]++
					case 'w': count[WebSites]++
					case '.' : count[Point]++
				}
			}
			
			for(new w = 0; w < charsmax(Domains); w++)
			{
				if(count[Numbers] >= 4 || count[WebSites] >= 3 && containi(message,Domains[w]) || count[Point] >= 3) 
				{
					client_print(id,print_chat,"[ProPM] You Cannot Put Any More Than 4 Numbers And Cannot Spend Any Web Page")
					return PLUGIN_HANDLED;
				}
			}
			/* End Simple Spam Blocker */
				
			new Text[192],Textplr[192]
			
			formatex(Text,191,"Message Sent To: %s",targetname)
			
			MakeTutor(id,Text,GREEN,5.0)
			
			formatex(Textplr,191,"From: %s | Message: %s  ", sendername,message)
			
			MakeTutor(plr,Textplr,YELLOW,25.0)
			
			emit_sound(plr, CHAN_AUTO, PROPM_SOUND, VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
			
			return PLUGIN_HANDLED
		}

	}
	
	return PLUGIN_CONTINUE
	
}	
MakeTutor(id,Text[],Color,Float:Time = 0.0) 
{
	
	message_begin(MSG_ONE_UNRELIABLE,g_MsgTutor,_,id)
	write_string(Text)
	write_byte(0)
	write_short(0)
	write_short(0)
	write_short(1<<Color)
	message_end()
	
	if(Time != 0.0) 
	{
		
		set_task(Time,"RemoveTutor",id + TASK_TUT)
	}
}
public RemoveTutor(taskID) 
{
	new id = taskID - TASK_TUT
	
	message_begin(MSG_ALL,g_MsgTutClose,_,id)
	message_end()
}
