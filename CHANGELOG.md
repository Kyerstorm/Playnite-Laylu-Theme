# Changelog

The newest numbered entry must match `Version` in `theme/theme.yaml`; `tools/check.ps1` enforces it.

## Unreleased

- New sidebar button that clears all filters, shown only while a filter is active
- The glow around covers now follows the Accent setting; it used to stay off-white
- Three accent presets documented in the README: Ember, Aurora and Orchid
- Fixed the top bar disappearing for good when Reduce motion is switched on while Playnite is running. It came back only after a restart
- Reduce motion now also covers the trailer fade: the title strip and logo dim and return without fading

## 1.0.1

Released 2026-10-07.

- New Laylu logo for the window and tray icons
- Fixed the package so ThemeModifier finds the theme settings (1.0 shipped `thememodifier.yaml` under the wrong name)

## 1.0

Released 2026-10-06.

- First release: a dark, cinematic Desktop theme for Playnite 10 (Theme API 2.10.0)
