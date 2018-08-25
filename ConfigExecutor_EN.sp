/*************************************************************************
*                                                                        *
*                      AlfaLoader - Config Executor                      * 
*                            Author: ShutUP                              *
*                             Version: 1.0                               *
*                                                                        *
**************************************************************************/

#include <sourcemod>

public Plugin myinfo = 
{
    name = "[SM] AlfaLoader",
    author = "ShutUP",
    description = "Config Executer for CSGO Servers",
    version = "1.0",
    url = "https://alfahosting.gq/plugins/csgo/configexecuter"
}

public OnPluginStart()
{
    CreateConVar("sm_executorversion", "1.0", "Show the version of the plugin", FCVAR_SPONLY|FCVAR_NOTIFY|FCVAR_DONTRECORD);
    RegAdminCmd("sm_executeconfigs_all", CmdReExecute, ADMFLAG_GENERIC, "Execute the config files insile the folder");
    PrintToServer("Plugin maked by ShutUP with love");
}

public OnMapStart()
{
    ExecuteAllConfigs();
}

stock bool ExecuteAllConfigs()
{
    new Float:time = 0.0;
    new Handle:file = INVALID_HANDLE;    
    decl String:FileName[256], String:ConfigName[256];
    BuildPath(Path_SM, FileName, sizeof(FileName), "configexecutor/config.cfg");    
    new len;
    if(!FileExists(FileName))
    {
        LogError("Error loading the config files");
        return false;
    }
    file = OpenFile(FileName, "r");
    if(file == INVALID_HANDLE)
    {
        LogError("Error loading the config files");
        return false;
    }
    
    while(ReadFileLine(file, ConfigName, sizeof(ConfigName)))
    {
        len = strlen(ConfigName);
        if (ConfigName[len-1] == 'n')
        {
            ConfigName[--len] = '0';
        }
        if(StrEqual(ConfigName, ""))
        {
            continue;
        }
        time+=0.1;
        new Handle:pack = CreateDataPack();
        WritePackString(pack, ConfigName);
        CreateTimer(time, ExecuteConfig, pack, TIMER_FLAG_NO_MAPCHANGE);
        if(IsEndOfFile(file))
        {
            break;
        }
    }
    CloseHandle(file);
    return true;
}

public Action CmdReExecute(client, args)
{
    if(ExecuteAllConfigs())
    {
        PrintToChat(client, "[AlfaLoader] All configs are been executed!");
    }
    else
    {
        PrintToChat(client, "[AlfaLoader] An error ocurred while executing the files!");
    }
    return Plugin_Handled;
}

public Action ExecuteConfig(Handle timer, Handle pack)
{
    ResetPack(pack);
    decl String:config[256];
    ReadPackString(pack, config, sizeof(config));
    ServerCommand("exec sourcemod/%s", config);
}  
