# Laylu: theme specification

Version 0.1 of the specification, 2026-10-05. Decision history and evidence are in `discovery.md`; decision numbers (D-nnn) refer to it.

Target: Playnite 10.62, Desktop mode, Theme API 2.10.0. Theme Id `Laylu_8766de46-0b2f-4c87-9538-b591f5c6a239`.

Evidence labels used below:

- **Verified**: seen in the Laylu skeleton (a copy of Playnite's Default theme) or confirmed by running.
- **Reference**: seen in another theme's XAML. The name exists; behaviour with the installed extension version is untested.
- **Unverified**: not yet found anywhere. Must be resolved in roadmap phase 0.

---

## A. Design brief

### Concept

A library you stand in. The grid is a shelf of large, bare covers on black. The selected game's details are always beside it. Opening a game's full page is the cinematic moment: a trailer or artwork fills the header and the interface steps back.

### Philosophy

1. Information density first, then aesthetics, then speed of use (D-007).
2. Dense library, cinematic details page (D-014).
3. Original, polished and familiar. Not modelled on another launcher, not experimental (D-006, D-010).
4. Colour belongs to the artwork. The interface itself has no hue by default (D-018).
5. Everything optional degrades silently. A missing extension leaves no gap and no message (D-059).

### Target experience

The author first, on a 4K OLED at 150% scaling (2560x1440 layout units), window maximised, about 750 games. Published later for others, down to 1920x1080 at 100% (D-005, D-031, D-072).

### Colour system

Proposed starting values. They are to be tuned on the real screen in roadmap phase 1; contrast figures are approximate.

| Token | Value | Use |
|---|---|---|
| Base | `#FF000000` | Window, grid background |
| Surface 1 | `#FF0B0B0C` | Sidebar, details panel |
| Surface 2 | `#FF141416` | Cards within panels, inputs, tab strip |
| Surface 3 | `#FF1D1D20` | Hover and pressed states |
| Text | `#FFE8E4DC` | Body and titles (about 16:1 on Base) |
| Text muted | `#FF9A968E` | Labels, secondary values (about 7:1) |
| Text faint | `#FF66635D` | Disabled and decorative only (about 3.4:1; never body text) |
| Accent | same as Text | Selection bar, outline, glow, focus |
| Success / Warning / Error | `#FF5FB37A` / `#FFD9A441` / `#FFD9655B` | Status, always paired with an icon or label |

- Separation is by tone step only. No border lines (D-017).
- Glass appears once: behind the title and stats strip in the details header (D-020, D-054).
- No shadows. Glow is used on the selected card and a running game only (D-021).
- User-changeable: accent, surfaces, text (D-019).
- Documented alternative accents: Ember `#FFE0A040`, Aurora `#FF3CC8C0`, Orchid `#FFB48CF0` (D-070).

### Typography

- Segoe UI. Sizes come from Playnite's own font-size resources so its font settings apply (D-021, D-070).
- Compact density. Spacing on a 4-unit scale: 4, 8, 12, 16, 24.
- Icons: IcoFont, which ships with Playnite (**Verified**: `FontIcoFont` in `GlobalResources.xaml`).

### Shape and motion

- Corners 4 to 6 units. Cover rounding can be switched off (D-021, D-037).
- State changes are instant or fade in about 150 ms. One "reduce motion" switch removes all animation (D-067).
- Only opacity and position are animated.

---

## B. Feature specification

Priorities: P0 essential, P1 first release, P2 enhancement, P3 later.

| ID | Feature | Behaviour | Priority | Depends on | Accepted when |
|---|---|---|---|---|---|
| F-01 | OLED colour system | Tokens in section A applied to every control and window | P0 | none | No grey or default-blue surface visible in any view or dialog |
| F-02 | Icon-rail sidebar | 56 units wide, always visible; accent bar marks the selected item; tooltip names each icon | P0 | none | All plugin sidebar items appear and open; selection is visible without colour |
| F-03 | Auto-hiding top bar | Hidden by default; slides over the library after a short pause at the top edge; stays while pointer or keyboard focus is inside it | P0 | none | Search can be typed without the bar closing; covers do not move when it opens |
| F-04 | Window buttons | Minimise, maximise, close always visible top-right | P0 | none | Window can be closed with the top bar hidden |
| F-05 | Sidebar quick controls | Filter toggle and grid/details/list switch at the bottom of the rail | P1 | Filter: **Verified** `Settings FilterPanelVisible`. View: **Reference** `Settings ViewSettings.GamesViewType` | Both work with the top bar hidden |
| F-06 | Grid cards | 2:3 covers, about 5 per row at the design size, medium spacing, no text or markers by default | P0 | none | Scrolling 750 games stays smooth |
| F-07 | Card states | Hover: glow and brighten. Selected: glow plus solid outline. Not installed: dimmed. Running: glow | P0 | none | Each state distinguishable with glow switched off |
| F-08 | Card play button | Play or install button appears on the hovered card | P1 | **Verified** `PART_ButtonPlay` in Default's card template | Starts or installs the game |
| F-09 | Optional card extras | Favourite mark; name under cover. Both off by default | P2 | ThemeModifier | Each toggles independently |
| F-10 | Missing cover | Black card showing the game's name | P1 | none | No broken or default image shown |
| F-11 | Group headers | One compact line with a count | P1 | **Verified** `Items.Count` in Default's group styles | Count matches the group |
| F-12 | Grid details panel | Right side, about a third of the window, always open, condensed version of F-14 | P0 | Forcing it open is **Unverified** | Panel shows for every selected game |
| F-13 | Details view list | Rows of icon and name with installed and favourite marks | P1 | none | Marks align; rows stay one line |
| F-14 | Cinematic details page | Hero, title, action row, stats strip, link bar, tabs | P0 | See section D | Page reads correctly for a game with full metadata and one with almost none |
| F-15 | Trailer hero | Muted trailer when one exists, else artwork fading to black, else a black band | P1 | Extra Metadata Loader. **Reference** `IsAnyVideoAvailable` | All three cases render without gaps |
| F-16 | Trailer overlay fade | Logo and stats strip fade out a few seconds into playback | P2 | **Reference** `ExtraMetadataLoader` `IsVideoPlaying` | Overlay returns when playback stops |
| F-17 | Logo title | Game logo when available, text otherwise | P1 | **Reference** `IsLogoAvailable` | Never both, never neither |
| F-18 | Stats strip | Playtime, time to beat, ratings, achievements (unlocked/total), players online | P1 | Native; HowLongToBeat; Playnite Achievements; Steam News and Players Viewer | Each cell hides when its source is missing; strip closes up |
| F-19 | Ratings out of 10 | Scores shown as a number out of 10; falls back to out of 100 | P1 | **Verified** `MathConverter` exists; its parameter syntax is **Unverified** | One format used consistently |
| F-20 | Details tabs | Overview, Media, Achievements, Activity, DLC, Related, News, Reviews, Notes; collapsible sections inside; a tab with nothing to show is hidden | P1 | Extensions in section C | No tab opens onto an empty panel |
| F-21 | Metadata fields | Metadata Utilities controls when installed, native fields otherwise. Tags, features, series, age rating, region, source, version, install folder sit in a "more" section | P1 | Metadata Utilities optional | Fields render with and without the extension |
| F-22 | Description | Collapsed to a few lines with "show more" | P1 | none | Long descriptions do not push the tabs off screen |
| F-23 | In-place editing | Favourite, completion status, user rating | P1 | ThemeExtras | Controls absent, not broken, without ThemeExtras |
| F-24 | Link bar | Icons under the action row | P1 | ThemeExtras for icons; native links otherwise | Links open |
| F-25 | Filter panel | Docked, on demand, compact; saved presets listed at the top | P1 | **Verified** `FilterPreset` in Default | Presets apply in one click |
| F-26 | Filter-active marker | Small marker visible while the library is filtered and the top bar is hidden | P2 | **Unverified**: no such value found | Dropped if the value does not exist |
| F-27 | Notification dot | Dot visible while notifications are unread | P2 | **Unverified**: no theme in the survey binds to a count | Dropped if the value does not exist |
| F-28 | Global search | Centred spotlight-style box over a dimmed library | P1 | none | Keyboard-only use works |
| F-29 | List view, Explorer panel | Light restyle to match | P2 | none | No unstyled default control visible |
| F-30 | Theme settings | See section E | P1 | ThemeModifier | Theme looks finished with ThemeModifier absent |
| F-31 | Performance mode | One switch turns off glass, glow and rounded corners | P1 | ThemeModifier | Measurably fewer effects; layout unchanged |
| F-32 | Keyboard focus | Visible outline on every focusable element | P0 | none | Tab key can reach and show every control |

Rejected or deferred: per-game colour; light mode; markers for installed state and completion on cards; library count summary; "no games match" message; price data; dashboards and extra pages; SuccessStory; extensions the author does not have installed; integration with the author's own plugins.

---

## C. Extension compatibility matrix

Every row is **Not yet verified** against the installed version until it is built and tested; that is the classification for the whole table. The "Evidence" column says what is known. Fallback for every row: that part of the page is hidden.

| Extension (installed version) | Integration location | Required functionality | Guard (addon Id) | Evidence |
|---|---|---|---|---|
| Extra Metadata Loader 1.87 | Hero, title | Video control, logo control, `IsAnyVideoAvailable`, `IsLogoAvailable`, `IsVideoPlaying` | `ExtraMetadataLoader_705fdbca-e1fc-4004-b839-1d040b8b4429` | Reference: Apocrypha, Dune Rev, Harmony |
| ThemeModifier 3.0.2 | Settings | Reads `thememodifier.yaml` | `playnite-thememodifier-plugin` | Reference: Apocrypha's `thememodifier.yaml` |
| ThemeExtras 1.4.4 | Action row, link bar | Favourite, completion status, user rating, link icons | `felixkmh_Extras_Plugin` | Reference: survey control list |
| HowLongToBeat 3.13 | Stats strip, Activity tab | `HasData`, `MainStoryFormat` and siblings | `playnite-howlongtobeat-plugin` | Reference: Dune Rev, Harmony |
| Playnite Achievements 4.0.1 | Stats strip, Achievements tab | `ModernTheme.UnlockedCount`, `ModernTheme.AchievementCount`, list and stats controls | `PlayniteAchievements` | Reference: Dune Rev |
| GameActivity 3.6 | Activity tab | `HasData`, chart controls | `playnite-gameactivity-plugin` | Reference: three themes |
| Screenshot Utilities 0.9.1 | Media tab | Viewer control, `IsViewerControlVisible` | `ScreenshotUtilities_485d682f-73e9-4d54-b16f-b8dd49e88f90` | Reference: Apocrypha only |
| Metadata Utilities 1.9.0 | Metadata fields | Prefix item controls | `MetadataUtilities_485ab5f0-bfb1-4c17-93cc-20d8338673be` | Reference: Apocrypha |
| Steam News and Players Viewer 1.39 | Stats strip, News tab | Players control, news control. No raw player count found | `NewsViewer_15e03ffe-90f6-4e8e-bd4d-94514777481d` | Reference: only `ReviewsAvailable` is read as a value |
| Steam Reviews Viewer 2.60 | Reviews tab | Reviews control, `IsControlVisible` | `Review_Viewer_ca24e37a-76d9-49bf-89ab-d3cba4a54bd1` | Reference: Apocrypha, Harmony |
| CheckDlc 1.4.1 | DLC tab | `HasData`, list controls | `playnite-checkdlc-plugin` | Reference: three themes |
| Game Relations 1.10 | Related tab | Four controls and their `...ControlSettings.IsVisible` | `GameRelations_a4c15d63-9ab4-4d96-9a0c-8f9b35d43a1f` | Reference: Apocrypha, Harmony |
| PlayNotes 1.10 | Notes tab | Notes control, `IsControlVisible` | `PlayNotes_4208657d-4f78-42d2-968f-39f24de275e1` | Reference: Apocrypha, Harmony |
| PlayerActivities, Playnite Sounds Mod, ImageRotater | none in first release | | | Deferred (P3) |
| Theme Options | none | | | Rejected |
| SuccessStory, ScreenshotsVisualizer, DuplicateHider, BackgroundChanger, Library Management, SystemChecker, CheckLocalizations | none in first release | | | Not installed; cannot be tested |

Consequence for F-18: players online is hosted as the extension's own control, so that one cell may not match the rest of the strip.

---

## D. Page specification

### Shell

```
+----+---------------------------------------------------------+
|    | (top bar: hidden; slides over on top-edge hover)   _ [] X|
| S  +--------------------------------------+------------------+
| i  |                                      |                  |
| d  |   Library content                    |  Details panel   |
| e  |   (grid, details list, or table)     |  (grid view)     |
|    |                                      |                  |
| ⚙  |                                      |                  |
+----+--------------------------------------+------------------+
```

- Sidebar: 56 units, Surface 1. Plugin items from Playnite at the top, quick controls at the bottom.
- Top bar: one compact row. Left to right: view and sort menus, filter presets, extension buttons, search (right, compact).
- Filter panel docks at the right edge of the library content when opened.
- Responsive: below about 1,700 units of window width the details panel narrows to its minimum before the grid loses a column. At 1920x1080 the grid shows about 3 to 4 covers per row beside the panel.

### Grid view

- Background Base. Covers at Playnite's configured aspect ratio and zoom; the design size is five across.
- Card: cover only. Optional favourite mark (top-right) and name line (below).
- Hover: glow, slight brighten, play button fades in bottom-centre.
- Selected: accent outline and glow.
- Empty and error states: missing cover becomes a Surface 2 card with the name. No "no games" message.

### Details panel (grid view)

Condensed page, top to bottom: artwork band with title (logo or text), action row (play, in-place editing), stats strip, link bar, collapsed description, primary metadata, "more" section, then the same tabs as the full page. No cover image here.

### Details view

- Left: game list, rows of icon, name, installed and favourite marks.
- Right: the full cinematic page.

### Cinematic details page

1. **Hero.** Full width. Trailer, or artwork fading into Base, or a black band. Glass band at its lower edge carrying title and stats strip.
2. **Action row.** Play button, favourite, completion status, user rating.
3. **Stats strip.** Up to five cells; absent cells close up.
4. **Link bar.**
5. **Body.** Cover (this view only), description, primary metadata, "more" section.
6. **Tabs.** Overview first; others in the agreed order, each hidden when it has nothing to show.

Long titles: one line, trimmed, full title in a tooltip.

### Filter panel, search, notifications

- Filter panel: saved presets at the top, then compact filter groups.
- Global search: centred box, library dimmed behind it.
- Notifications: Playnite's panel restyled; dot subject to F-27.

---

## E. Theme settings

All settings need ThemeModifier. Without it, the defaults below apply. Key names are proposals for theme-owned resources in `Constants.xaml`.

| Group | Setting | Type | Default |
|---|---|---|---|
| Colours | Accent | colour | Text colour |
| Colours | Surface (panels) | colour | `#FF0B0B0C` |
| Colours | Surface raised | colour | `#FF141416` |
| Colours | Text | colour | `#FFE8E4DC` |
| Colours | Text muted | colour | `#FF9A968E` |
| General | Reduce motion | on/off | off |
| General | Performance mode | on/off | off |
| General | Auto-hide top bar | on/off | on |
| Grid | Rounded covers | on/off | on |
| Grid | Play button on hover | on/off | on |
| Grid | Hover glow | on/off | on |
| Grid | Favourite mark | on/off | off |
| Details | Use logo for title | on/off | on |
| Details | Fade overlay during trailer | on/off | on |


That is 14 options. Per-tab switches were dropped (D-076); tabs hide themselves when empty.

Three things are controlled by Playnite's own settings, which Laylu honours instead of duplicating (D-080): names under covers (`ShowNamesUnderCovers`), dimming uninstalled games (`DarkenUninstalledGamesGrid`) and details panel width (`GrdiDetailsWitdh`). The agreed defaults for these (no names, dimmed, one third) are therefore set in Playnite's settings, not by the theme.

Font size is not a theme setting; it follows Playnite's own.

---

## F. Technical architecture

### Structure

```
Laylu\                      repository root
  discovery.md, specification.md
  theme\                    linked from C:\Games\Playnite\Themes\Desktop\Laylu
    theme.yaml
    thememodifier.yaml      to be added
    Constants.xaml          all tokens and feature flags
    Common.xaml, Media.xaml
    DefaultControls\, CustomControls\, DerivedStyles\, Views\, Images\
    App.xaml, GlobalResources.xaml, LocSource.xaml, Theme.csproj, Theme.sln   design-time only; never edited
```

### Rules

1. **Tokens in one place.** Every colour, size, radius and flag is a resource in `Constants.xaml`, referenced with `DynamicResource`. No literal colours in views.
2. **No new dictionary files until proven.** Whether Playnite loads a theme file that Default does not have is **Unverified**. Shared styles go in `Constants.xaml` or `Common.xaml` until that is tested.
3. **`PART_` names are never renamed or removed.**
4. **Every extension element is guarded.** A hosted control gets a `PluginStatus` visibility guard with the addon Id from section C. Every `PluginSettings` binding has a `FallbackValue`.
5. **Feature flags are booleans in `Constants.xaml`**, listed in `thememodifier.yaml`, read by triggers. This is how Apocrypha does it (**Reference**).
6. **Reduce motion and performance mode** are flags that every storyboard and effect checks.
7. **No copied XAML from other themes.** KNARZnite and others are read for extension slot names only (D-023).

### Performance

- Card template: no drop-shadow effect per card, no nested scaling, no video. Glow on hover and selection only, so at most two cards carry an effect.
- Virtualisation in the grid and lists is left intact.
- Glass is one element in the header.
- Rounded covers are the costliest card feature; performance mode turns them off.

### Packaging

- Before a release, files identical to Default are removed so users get upstream fixes. What `Toolbox pack` does about this is **Unverified**.
- Fonts cannot ship in a theme; Segoe UI and IcoFont need none.

---

## G. Implementation roadmap

Each phase ends with screenshots from the author (D-074) and a check of `playnite.log` for XAML errors.

| # | Phase | Scope | Accepted when | Main risk |
|---|---|---|---|---|
| 0 | Verification | Resolve the Unverified items in section H; create `thememodifier.yaml`; confirm one flag and one colour change through ThemeModifier | Each item marked possible or dropped | An item proves impossible in a theme |
| 1 | Colour and base controls | `Constants.xaml` tokens; `Common.xaml`; `DefaultControls` (buttons, inputs, menus, scrollbars, tabs, tooltips); focus outline | F-01, F-32 in every view and dialog | Tone steps too close to tell apart on the real panel |
| 2 | Shell | Sidebar rail, window buttons, auto-hiding top bar, quick controls | F-02 to F-05 | Top bar closing while in use |
| 3 | Grid | Cards, states, play button, group headers, missing cover | F-06 to F-08, F-10, F-11 | Scroll performance with rounding and glow |
| 4 | Grid details panel | Condensed page with native data only | F-12, F-21 (native), F-22 | Forcing the panel open |
| 5 | Cinematic page | Hero, title, action row, native stats, tabs with Overview | F-14, F-13, F-20 (structure) | Layout with almost no metadata |
| 6 | Extensions, P0 and P1 | Extra Metadata Loader, ThemeExtras, HowLongToBeat, Playnite Achievements, GameActivity, Screenshot Utilities, Metadata Utilities | F-15 to F-19, F-21, F-23, F-24; each tested with the extension disabled | A value name no longer exists in the installed version |
| 7 | Extensions, P2 | News, Reviews, DLC, Related, Notes tabs; players online | F-18 complete, F-20 complete | Extension controls clashing with the palette |
| 8 | Remaining views | Filter panel, Explorer, List view, search, notifications, settings and other dialogs | F-25, F-28, F-29 | Volume of small controls |
| 9 | Settings and modes | All of section E; reduce motion; performance mode; optional card extras | F-09, F-30, F-31 | Combinations of switches |
| 10 | Release | 1920x1080 at 100% pass; remove unchanged files; README with palettes; MIT licence; `.pthm`; GitHub; later the add-on database | Installs cleanly on a Playnite with no extensions | Packaging contents |

The author's first build target (D-075) is phases 1 to 3.

---

## H. Outstanding questions

### Phase 0 results (2026-10-05)

"Source" means read from Playnite's GitHub source (master branch). "In-app test" refers to the temporary test panel in `Views\GridViewGameOverview.xaml`.

| Item | Result | Evidence | Still to confirm |
|---|---|---|---|
| Force the grid details panel open (F-12) | Not possible. Playnite binds the panel's visibility in code to its own setting `GridViewSideBarVisible` | Source: `LibraryGridView.cs` | Design change: the theme removes the close button and offers a reopen control bound to that setting |
| Extra dictionary files | Not loaded. Playnite loads only files that also exist in Default | Source: `Themes.cs`, `ApplyTheme` | none; architecture rule 2 stands permanently |
| Ratings out of 10 (F-19) | Expected to work. `MathConverter` is the Hex Innovation converter; its parameter is an expression in `x` | Skeleton `GlobalResources.xaml`; `Game.CommunityScore` read by FusionX, Nova X, Mythos | In-app test line 1 |
| Filter-active marker (F-26) | Expected to work. `FilterSettings.IsActive` exists and raises change notifications | Source: `FilterSettings.cs` | In-app test line 2 |
| Notification dot (F-27) | Expected to work. `Api Notifications.Count` is read by Harmony, FusionX, Neon and Standard X; the SDK has `INotificationsAPI.Count` | Reference themes; SDK 6.17.0 reflection | In-app test line 3 (whether it updates live) |
| View switch from the sidebar (F-05) | Expected to work. Commands `SwitchGridViewCommand`, `SwitchDetailsViewCommand`, `SwitchListViewCommand` exist on the main view model | Source: `TopPanel.cs` | In-app test line 6 |
| Filter toggle from the sidebar (F-05) | Readable; writing it from a theme is untested | Skeleton `Views\Library.xaml` | In-app test line 5 |
| `thememodifier.yaml` with ThemeModifier 3.0.2 | Test file created with one switch and one colour | none yet | In-app test: ThemeModifier settings |
| Top bar staying open on keyboard focus (F-03) | Standard WPF; untested | none | Phase 2 |
| What `Toolbox pack` includes | Not checked | none | Phase 10 |

### In-app test, first run (2026-10-05, author's screenshot and answers)

| Line | Result |
|---|---|
| 1. Score out of 10 | **Confirmed.** Showed 9.5 for a community score of 95 |
| 2. Filter active | **Confirmed.** Showed True while a filter was applied |
| 3. Notifications | **Confirmed.** Showed 4, matching Playnite's bell |
| 4. Side panel setting | **Confirmed.** Showed True |
| 5. Filter tick box | Failed first as written: the `Settings` markup binds one-way by default (source: `BindingExtension.cs`, `Mode = BindingMode.OneWay`). **Confirmed** on retest with `Mode=TwoWay` |
| 6. Switch to Details view | **Confirmed** |
| 7. Toggle filter panel | **Confirmed.** `MainViewModel ToggleFilterPanelCommand` (source: `DesktopAppViewModel_Commands.cs`) |
| ThemeModifier 3.0.2 | **Confirmed.** `thememodifier.yaml` in Apocrypha's format is picked up; a boolean switch and a brush both apply live, no restart |

**Phase 0 closed 2026-10-05.** The test panel, its two keys and the test `thememodifier.yaml` were removed; the theme is byte-identical to Default again except `theme.yaml`. Two items remain open by design: top bar staying open on keyboard focus (phase 2) and what `Toolbox pack` includes (phase 10).

Rule for all later phases: any `Settings` binding that must write a value needs `Mode=TwoWay`; prefer a `MainViewModel` command where one exists.

Also found in source: `ShowGameSideBarCommand` exists, so the control that reopens the grid details panel (F-12) has a command to call; and `OpenFilterPanelCommand`, `CloseFilterPanelCommand`, `ClearFiltersCommand`, `ToggleExplorerPanelCommand`.

### Decided 2026-10-05

1. **Duplicate settings dropped** (D-080). See section E.
2. **Completion-status colours** (D-081). Playing `#FF6FA8DC`, Completed `#FF5FB37A`, Paused `#FFD9A441`, Dropped `#FFD9655B`, each with an icon and its label. Other statuses use Text muted.
3. **Sidebar on the left edge only** for the first release (D-082). The other three positions Playnite offers are to be handled before publishing.

Confirmed by the author on 2026-10-05: no light mode; off-white text; the top bar slides over content; the window is normally maximised.
