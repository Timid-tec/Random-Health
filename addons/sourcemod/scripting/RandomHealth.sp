#include <sourcemod>
#include <sdktools>
#include <timid>
#include <debug>

#define prefix "\x10[BRUTALCI]"

ConVar gCvRandomHealth;

int gHealth;
int gRandomHealth;
int gRand;
int clFlag[MAXPLAYERS + 1];

#pragma semicolon 1

public Plugin myinfo = 
{
	name = "Random-Health/On-Spawn (VIP & Admins)", 
	author = PLUGIN_AUTHOR, 
	description = "Set a random health, 10% chance", 
	version = "1.0.0", 
	url = "https://steamcommunity.com/id/MrTimid/"
}

public OnPluginStart()
{
	/* Hook events */
	HookEvent("player_spawn", Event_PlayerSpawn);
	
	CreateConVar("sm_random_health_version", PLUGIN_VERSION, "Random Health Version", FCVAR_SPONLY | FCVAR_REPLICATED);
	gCvRandomHealth = CreateConVar("sm_randomhealth_rhealth", "5", "Sets how much random health is given to admins/vips (def 5)");
	gCvRandomHealth.AddChangeHook(OnCVarChanged);
	
	
	gRandomHealth = gCvRandomHealth.IntValue;
	
	/* Debug Log */
	BuildLogFilePath();
}

public void OnCVarChanged(ConVar convar, char[] oldValue, char[] newValue)
{
	if (convar == gCvRandomHealth)
	{
		gRandomHealth = gCvRandomHealth.IntValue;
	}
}

public Action Event_PlayerSpawn(Handle event, char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	gHealth = GetEntProp(client, Prop_Data, "m_iHealth");
	if (!IsValidClient(client))
		return Plugin_Continue;
	
	gRand = GetRandomInt(0, 100);
	
	#if _DEBUG >= 1
	LogDebug(false, "RandomChance - (%i)", gRand);
	#endif
	
	if (gRand < 10 && checkClFlag(client))
	{
		SetPlayerHealth(client);
		PrintToChatAll(" %s \x04%N got lucky and receved %i extra health.", prefix, client, gRandomHealth);
	}
	
	return Plugin_Continue;
}


public void SetPlayerHealth(client)
{
	int setHealth = gHealth + gRandomHealth;
	
	SetEntProp(client, Prop_Data, "m_iMaxHealth", setHealth);
	SetEntityHealth(client, setHealth);
	
	#if _DEBUG >= 2
	LogDebug(false, "SetPlayerHealth - (%N, %i + %i = %i)", client, gHealth, gRandomHealth, setHealth);
	#endif
}

stock bool checkClFlag(int client)
{
	clFlag[client] = GetUserFlagBits(client);
	if (IsValidClient(client) && GetClientTeam(client) <= 3)/* checks if he isn't spec */
	{
		if (clFlag[client] & (ADMFLAG_GENERIC | ADMFLAG_CUSTOM1 | ADMFLAG_CHEATS | ADMFLAG_ROOT))
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	return true;
} 