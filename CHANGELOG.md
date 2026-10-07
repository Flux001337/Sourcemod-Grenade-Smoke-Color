# Changelog

Legend: `!` Fix · `+` Addition · `*` Change · `-` Removal

## 1.4.0

- Use detonation-event coordinates directly instead of exact smoke-entity position comparisons.
- Give each grenade its own color animation, independent of other grenades.
- Support bot throwers and provide a default color when the thrower or team is unavailable.
- Clamp RGB channels to 0–255 and fall back to the default color for malformed input.
- Initialize changing-color lights with a valid color immediately.
- Remove created lights when disabled, unloaded, or the map ends.
- Correct the light angles key and remove the unsupported shadow input.
- Modernize SourcePawn syntax and remove unused code.

## 1.3.4 (29.12.2013)

- `!` Fix errors.

## 1.3 (03.07.2013)

- `*` Optimize the code.
- `!` Fix errors.
- `+` Add Updater support.

## 1.2 (30.01.2013)

- `-` Remove Stamm plugin support.
- `-` Remove Day of Defeat: Source code.
- `*` Incorporate improvements from RedSword.

## 1.1 (17.12.2011)

- `!` Fix VIP verification in the Stamm version only.
- `!` Correct the reversed random and changing-color modes (`sm_grenadesmokecolor_mode` 1 and 2).

## 1.0 (15.12.2011)

- Initial release.
