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
    description = "Executor de configurações para servidores de CS:GO",
    version = "1.0",
    url = "https://alfahosting.gq/plugins/csgo/configexecuter"
}

public OnPluginStart()
{
    CreateConVar("sm_executorversion", "1.0", "Mostra a versão do plugin", FCVAR_SPONLY|FCVAR_NOTIFY|FCVAR_DONTRECORD);
    RegAdminCmd("sm_executeconfigs_all", CmdReExecute, ADMFLAG_GENERIC, "Executa as configs dentro da pasta");
    PrintToServer("Plugin feito por ShutUP com amor");
}

public OnMapStart()
{
    ExecutarTodasAsConfig();
}

stock bool ExecutarTodasAsConfig()
{
    new Float:time = 0.0;
    new Handle:file = INVALID_HANDLE;    
    decl String:FileName[256], String:ConfigName[256];
    BuildPath(Path_SM, FileName, sizeof(FileName), "configexecutor/config.cfg");    
    new len;
    if(!FileExists(FileName))
    {
        LogError("Erro ao executar as configs");
        return false;
    }
    file = OpenFile(FileName, "r");
    if(file == INVALID_HANDLE)
    {
        LogError("Erro ao executar as configs");
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
    if(ExecutarTodasAsConfig())
    {
        PrintToChat(client, "[AlfaLoader] Todos as configs foram executados!");
    }
    else
    {
        PrintToChat(client, "[AlfaLoader] Um erro ocurreu ao executar todas as configs!");
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
