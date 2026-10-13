# Changelog

The newest numbered entry must match `Version` in `theme/theme.yaml`; `tools/check.ps1` enforces it.

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
