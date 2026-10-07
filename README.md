# SourceMod - Grenade Smoke Color

SourceMod plugin that adds colored dynamic lighting to smoke grenades in Counter-Strike: Source.
Current version: **1.4.0**. 

## Changelog

See [CHANGELOG.md](CHANGELOG.md).

## Features

- Team colors: red for terrorists and blue for counter-terrorists by default.
- Random colors, changing rainbow colors, or a defined RGB color.
- Independent color animation for each smoke grenade.
- Supports grenades thrown by bots; missing throwers use the default color in team mode.
- Lights last 20 seconds and are removed when the plugin is disabled, unloaded, or the map ends.
- Optional Updater integration.

The effect lights the area around the smoke; it does not replace the smoke texture. Visual results depend on the game and client rendering settings.

## Requirements

- Counter-Strike: Source with [SourceMod](https://www.sourcemod.net/downloads.php) and SDK Tools.
- `scripting/include/updater.inc` is bundled for compilation. The [Updater plugin](https://forums.alliedmods.net/showthread.php?p=1570806) is optional at runtime.

Compiled with SourceMod 1.12.0.7253 without errors or warnings. Version 1.4.0 has not yet been tested on a game server.

**Day of Defeat: Source and Counter-Strike: Global Offensive are not supported.** Stamm integration was removed in version 1.2.

## Installation

Copy `plugins/grenadesmokecolor.smx` to `addons/sourcemod/plugins/`. Load it with `sm plugins load grenadesmokecolor` or change the map.
The configuration is generated at `cfg/sourcemod/plugin.grenadesmokecolor.cfg`.
## Updating

Replace the SMX and run `sm plugins reload grenadesmokecolor`, or change the map.
If you need to regenerate the configuration, back up `cfg/sourcemod/plugin.grenadesmokecolor.cfg`, remove it, and reload the plugin. Reapply your custom settings to the newly generated file.

## Configuration

| ConVar | Default | Description |
| --- | --- | --- |
| `sm_grenadesmokecolor_version` | `1.4.0` | Plugin version |
| `sm_grenadesmokecolor_enable` | `1` | Enable or disable the plugin |
| `sm_grenadesmokecolor_mode` | `0` | 0 = team, 1 = random, 2 = changing colors, 3 = defined color |
| `sm_grenadesmokecolor_t_color` | `255 0 0` | Terrorist RGB color |
| `sm_grenadesmokecolor_ct_color` | `0 0 255` | Counter-terrorist RGB color |
| `sm_grenadesmokecolor_color` | `225 255 0` | Defined and fallback RGB color |

RGB values are separated by spaces. Channels outside 0–255 are clamped; malformed input falls back to `225 255 0`.
Mode and color settings apply to new grenades. Disabling the plugin removes existing lights immediately.
There are no player or admin commands.

## Build

Run from this repository directory. The shared compiler and standard includes in this workspace are three directories above. For a standalone checkout, replace those paths with your SourceMod installation path.

Linux:

```sh
mkdir -p plugins
../../../spcomp64 scripting/grenadesmokecolor.sp -iscripting/include -i../../../include -oplugins/grenadesmokecolor.smx
```

Windows CMD:

```bat
if not exist plugins mkdir plugins
../../../spcomp64.exe scripting/grenadesmokecolor.sp -iscripting/include -i../../../include -oplugins/grenadesmokecolor.smx
```

## Repository structure

```text
scripting/
├── grenadesmokecolor.sp
└── include/
    └── updater.inc
```

Compiled binaries and backups are excluded from Git. A release ZIP contains `plugins/grenadesmokecolor.smx` and `scripting/`; extract it into `addons/sourcemod/`.

## Special thanks

- [[DeathTV] Sid 6.7](https://forums.alliedmods.net/member.php?u=31319)
- [Bacardi](https://forums.alliedmods.net/member.php?u=67162)
- [RedSword](https://forums.alliedmods.net/member.php?u=10216)
- [Peace-Maker](https://forums.alliedmods.net/member.php?u=41418)

## Author and source notices

HSFighter — http://www.hsfighter.net

The plugin source does not currently declare a license. The bundled Updater include retains its existing notices.
The existing optional update endpoint is `http://update.hsfighter.net/sourcemod/grenadesmokecolor/grenadesmokecolor.txt`.
