#include <sourcemod>
#include <sdktools>
#include <timid>
#include <debug>

#define prefix "[Random-Health]"

ConVar gCvRandomHealth;
ConVar gCvEnabled;

int gHealth;
int gRandomHealth;
int gRand;
int clFlag[MAXPLAYERS + 1];


bool gEnabled;

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
	
	CreateConVar("sm_random_health_version", PLUGIN_VERSION, "Spawn Protection Version", FCVAR_SPONLY | FCVAR_REPLICATED);
	gCvRandomHealth = CreateConVar("sm_health_value", "11", "Set how much random health is given to (i) player. (def, 14)");
	gCvRandomHealth.AddChangeHook(OnCVarChanged);
	gCvEnabled = CreateConVar("sm_health_enabled", "1", "Enables the random health chance. (def, 1)");
	gCvEnabled.AddChangeHook(OnCVarChanged);
	
	/* Int Values */
	gRandomHealth = gCvEnabled.IntValue;
	
	/* Bool Values */
	gEnabled = gCvEnabled.BoolValue;
	
	/* Debug Log */
	BuildLogFilePath();
}

public void OnCVarChanged(ConVar convar, char[] oldValue, char[] newValue)
{
	if (convar == gCvRandomHealth)
	{
		gRandomHealth = gCvRandomHealth.IntValue;
	}
	if (convar == gCvEnabled)
	{
		gEnabled = gCvEnabled.BoolValue;
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
	
	if (gRand < 10 && checkClFlag(client) && gEnabled)
	{
		SetPlayerHealth(client);
		PrintToChatAll(" %s \x02%N \x04%got lucky and receved \x02%i \x04extra health.", prefix, client, gRandomHealth);
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
