//////////////////////////////////////////////////////////////////
// Grenade Smoke Color By HSFighter / www.hsfighter.net
//////////////////////////////////////////////////////////////////
#include <sourcemod>
#include <sdktools>
#pragma semicolon 1
#pragma newdecls required
#define PLUGIN_VERSION "1.4.0"
#define LIGHT_LIFETIME 20.0

#undef REQUIRE_PLUGIN
#include <updater>
#define UPDATE_URL "http://update.hsfighter.net/sourcemod/grenadesmokecolor/grenadesmokecolor.txt"

ConVar g_Enabled, g_Mode, g_Color, g_TColor, g_CTColor;
ArrayList g_Lights;

public Plugin myinfo =
{
    name = "Grenade Smoke Color",
    author = "HSFighter",
    description = "Adds colored light to grenade smoke",
    version = PLUGIN_VERSION,
    url = "http://www.hsfighter.net"
};

public void OnPluginStart()
{
    g_Lights = new ArrayList();
    CreateConVar("sm_grenadesmokecolor_version", PLUGIN_VERSION, "Grenade Smoke Color Version", FCVAR_SPONLY | FCVAR_REPLICATED | FCVAR_NOTIFY | FCVAR_DONTRECORD);
    g_Enabled = CreateConVar("sm_grenadesmokecolor_enable", "1", "Enable/Disable Plugin", FCVAR_NONE, true, 0.0, true, 1.0);
    g_TColor = CreateConVar("sm_grenadesmokecolor_t_color", "255 0 0", "Terrorist smoke RGB color (0-255)");
    g_CTColor = CreateConVar("sm_grenadesmokecolor_ct_color", "0 0 255", "Counter-terrorist smoke RGB color (0-255)");
    g_Color = CreateConVar("sm_grenadesmokecolor_color", "225 255 0", "Default smoke RGB color (0-255)");
    g_Mode = CreateConVar("sm_grenadesmokecolor_mode", "0", "0 = Team, 1 = Random, 2 = Changing colors, 3 = Defined color", FCVAR_NONE, true, 0.0, true, 3.0);
    g_Enabled.AddChangeHook(OnEnabledChanged);
    HookEvent("smokegrenade_detonate", OnSmokeDetonate);
    AutoExecConfig(true, "plugin.grenadesmokecolor");
    if (LibraryExists("updater")) Updater_AddPlugin(UPDATE_URL);
}

public void OnLibraryAdded(const char[] name)
{
    if (StrEqual(name, "updater")) Updater_AddPlugin(UPDATE_URL);
}

public void OnMapEnd()
{
    ClearLights();
}

public void OnPluginEnd()
{
    ClearLights();
    delete g_Lights;
}

public void OnEnabledChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
    if (!g_Enabled.BoolValue) ClearLights();
}

public void OnSmokeDetonate(Event event, const char[] name, bool dontBroadcast)
{
    if (!g_Enabled.BoolValue) return;

    // The detonation event already gives the smoke location; no fragile entity-position comparison is needed.
    float origin[3];
    origin[0] = event.GetFloat("x");
    origin[1] = event.GetFloat("y");
    origin[2] = event.GetFloat("z");

    int mode = g_Mode.IntValue;
    float hue = GetRandomFloat(0.0, 359.0);
    char color[64];
    if (mode == 1 || mode == 2)
    {
        HueToColor(hue, color, sizeof(color));
    }
    else
    {
        ConVar selected = g_Color;
        if (mode == 0)
        {
            int client = GetClientOfUserId(event.GetInt("userid"));
            if (client > 0 && client <= MaxClients && IsClientInGame(client))
            {
                int team = GetClientTeam(client);
                if (team == 2) selected = g_TColor;
                else if (team == 3) selected = g_CTColor;
            }
        }
        ReadColor(selected, color, sizeof(color));
    }

    int light = CreateEntityByName("light_dynamic");
    if (light == -1) return;
    DispatchKeyValue(light, "_light", color);
    DispatchKeyValue(light, "angles", "-90 0 0");
    DispatchKeyValue(light, "pitch", "-90");
    DispatchKeyValue(light, "distance", "256");
    DispatchKeyValue(light, "spotlight_radius", "96");
    DispatchKeyValue(light, "brightness", "3");
    DispatchKeyValue(light, "style", "6");
    DispatchKeyValue(light, "spawnflags", "1");
    if (!DispatchSpawn(light))
    {
        AcceptEntityInput(light, "Kill");
        return;
    }
    TeleportEntity(light, origin, NULL_VECTOR, NULL_VECTOR);
    AcceptEntityInput(light, "TurnOn");

    int ref = EntIndexToEntRef(light);
    g_Lights.Push(ref);
    DataPack pack;
    CreateDataTimer(0.15, UpdateLight, pack, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
    pack.WriteCell(ref);
    pack.WriteCell(mode);
    pack.WriteFloat(hue);
    pack.WriteFloat(GetGameTime());
}

public Action UpdateLight(Handle timer, DataPack pack)
{
    pack.Reset();
    int ref = pack.ReadCell();
    int mode = pack.ReadCell();
    float hue = pack.ReadFloat();
    float started = pack.ReadFloat();
    int light = EntRefToEntIndex(ref);
    if (light == INVALID_ENT_REFERENCE)
    {
        ForgetLight(ref);
        return Plugin_Stop;
    }
    float elapsed = GetGameTime() - started;
    if (!g_Enabled.BoolValue || elapsed >= LIGHT_LIFETIME)
    {
        AcceptEntityInput(light, "Kill");
        ForgetLight(ref);
        return Plugin_Stop;
    }
    if (mode == 2)
    {
        char color[64];
        HueToColor(hue + elapsed * 20.0, color, sizeof(color));
        DispatchKeyValue(light, "_light", color);
    }
    return Plugin_Continue;
}

void ForgetLight(int ref)
{
    int index = g_Lights.FindValue(ref);
    if (index != -1) g_Lights.Erase(index);
}

void ClearLights()
{
    if (g_Lights == null) return;
    for (int i = 0; i < g_Lights.Length; i++)
    {
        int light = EntRefToEntIndex(g_Lights.Get(i));
        if (light != INVALID_ENT_REFERENCE) AcceptEntityInput(light, "Kill");
    }
    g_Lights.Clear();
}

void ReadColor(ConVar convar, char[] output, int maxlen)
{
    char input[64], parts[3][16];
    convar.GetString(input, sizeof(input));
    TrimString(input);
    // Collapse repeated spaces so normal RGB input remains easy to edit.
    while (ReplaceString(input, sizeof(input), "  ", " ") > 0) {}
    ReplaceString(input, sizeof(input), "\t", " ");
    while (ReplaceString(input, sizeof(input), "  ", " ") > 0) {}
    int rgb[3];
    bool valid = ExplodeString(input, " ", parts, sizeof(parts), sizeof(parts[])) == 3;
    for (int i = 0; i < 3 && valid; i++)
    {
        int consumed = StringToIntEx(parts[i], rgb[i]);
        if (consumed == 0 || consumed != strlen(parts[i])) valid = false;
        if (rgb[i] < 0) rgb[i] = 0;
        else if (rgb[i] > 255) rgb[i] = 255;
    }
    if (!valid)
    {
        rgb[0] = 225;
        rgb[1] = 255;
        rgb[2] = 0;
    }
    Format(output, maxlen, "%d %d %d", rgb[0], rgb[1], rgb[2]);
}

void HueToColor(float hue, char[] output, int maxlen)
{
    hue -= float(RoundToFloor(hue / 360.0)) * 360.0;
    float sector = hue / 60.0;
    int index = RoundToFloor(sector);
    float fraction = sector - float(index);
    float r, g, b;
    switch (index)
    {
        case 0: { r = 1.0; g = fraction; b = 0.0; }
        case 1: { r = 1.0 - fraction; g = 1.0; b = 0.0; }
        case 2: { r = 0.0; g = 1.0; b = fraction; }
        case 3: { r = 0.0; g = 1.0 - fraction; b = 1.0; }
        case 4: { r = fraction; g = 0.0; b = 1.0; }
        default: { r = 1.0; g = 0.0; b = 1.0 - fraction; }
    }
    Format(output, maxlen, "%d %d %d", RoundFloat(r * 255.0), RoundFloat(g * 255.0), RoundFloat(b * 255.0));
}
