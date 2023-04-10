/*  [CS:GO] Advanced-Reports: Sets a random health value on respawn.
 *
 *  Copyright (C) 2021 Mr.Timid // timidexempt@gmail.com
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */
 
#include <sourcemod>
#include <sdktools>
#include <timid>
#include <debug>

#define PREFIX "\x08[\x10Random-Health\x08]"

ConVar gCvRandomHealth;
ConVar gCvEnabled;

int gHealth;
int gRandomHealth;
int gRand;
int clFlag[MAXPLAYERS + 1];

bool gEnabled;

public Plugin myinfo = 
{
	name = "Random-Health/On-Spawn (VIP & Admins)", 
	author = PLUGIN_AUTHOR, 
	description = "Set a random health, 10% chance", 
	version = "4.2.1", 
	url = "https://steamcommunity.com/id/MrTimid/"
}

public OnPluginStart()
{
	/* Hook events */
	HookEvent("player_spawn", Event_PlayerSpawn);
	
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
		PrintToChatAll(" %s \x02%N \x04%got lucky and receved \x02%i \x04extra health.", PREFIX, client, gRandomHealth);
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