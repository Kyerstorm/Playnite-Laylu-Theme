# Changelog

The newest numbered entry must match `Version` in `theme/theme.yaml`; `tools/check.ps1` enforces it.

## 1.1.1

Released 2026-10-20.

### Added

- A place at the top of the game details for the Pokémon team strip from PokeTeams, an unreleased generic plugin. It shows only when PokeTeams is installed and has a team for the game, so nothing changes without it

### Fixed

- Playnite crashed on startup when the top bar auto-hide option was switched off, from ThemeModifier or by editing the theme. With the option off the top bar now stays open as intended

## 1.1

Released 2026-10-13.

### Added

- Sidebar button that clears all filters and the active filter preset. It appears only while a filter is active
- Three accent presets documented in the README: Ember, Aurora and Orchid

### Changed

- Reduce motion now also covers the trailer fade: the title strip and logo dim and return without fading
- The glow around covers follows the Accent setting; it used to stay off-white

### Fixed

- The top bar disappeared for good when Reduce motion was switched on while Playnite was running, and came back only after a restart

## 1.0.1

Released 2026-10-07.

- New Laylu logo for the window and tray icons
- Fixed the package so ThemeModifier finds the theme settings (1.0 shipped `thememodifier.yaml` under the wrong name)

## 1.0

Released 2026-10-06.

- First release: a dark, cinematic Desktop theme for Playnite 10 (Theme API 2.10.0)
