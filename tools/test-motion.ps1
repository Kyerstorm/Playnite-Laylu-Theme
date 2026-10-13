# Replays the theme's two animated parts outside Playnite and checks where they end up:
# the auto-hiding top bar (Views\TopPanel.xaml) and the trailer fade of the details page's
# title strip (Views\DetailsViewGameOverview.xaml). Both have a normal and a "reduce motion"
# variant, and the option can be switched at any moment.
#
#   powershell -STA -ExecutionPolicy Bypass -File tools\test-motion.ps1
#
# The trigger XAML is cut from the theme files, so this tests what ships. Only what Playnite
# supplies is replaced: the pointer (a property the script sets), the option (a resource the
# script changes, as ThemeModifier does) and, for the trailer, the extension's "is playing"
# value (dropped) and the ten-second delay (shortened).
#
# Opens small windows off screen for about a minute. Exits with the number of failed checks.

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

$views = Join-Path $PSScriptRoot '..\theme\Views'
$script:failed = 0

function Get-Between([string]$text, [string]$anchor, [string]$open, [string]$close) {
    $from = $text.IndexOf($open, $text.IndexOf($anchor))
    $to = $text.IndexOf($close, $from)
    if ($from -lt 0 -or $to -lt 0) { throw "Could not find $open after $anchor; the theme file has changed shape." }
    return $text.Substring($from, $to - $from)
}

function Wait([int]$milliseconds) {
    $frame = New-Object Windows.Threading.DispatcherFrame
    $timer = New-Object Windows.Threading.DispatcherTimer
    $timer.Interval = [TimeSpan]::FromMilliseconds($milliseconds)
    $timer.Add_Tick({ $frame.Continue = $false; $timer.Stop() }.GetNewClosure())
    $timer.Start()
    [Windows.Threading.Dispatcher]::PushFrame($frame)
}

function Scenario([string]$xaml, [string]$name, [scriptblock]$steps) {
    $window = [Windows.Markup.XamlReader]::Parse($xaml)
    $window.Show()
    Wait 200
    try {
        & $steps @{ Window = $window; Target = $window.FindName('Target'); Name = $name }
    } finally {
        $window.Close()
    }
}

function Set-Motion($context, [bool]$reduced) {
    $context.Window.Resources['LayluReduceMotion'] = $reduced
    Wait $script:settle
}

function Expect($context, [string]$what, $actual, [double]$wanted) {
    $ok = ($null -ne $actual) -and ([math]::Abs($actual - $wanted) -lt 0.01)
    if (-not $ok) { $script:failed++ }
    Write-Host ("{0}  {1,-30} {2,-34} {3} (want {4})" -f $(if ($ok) { 'ok  ' } else { 'FAIL' }), $context.Name, $what, $actual, $wanted)
}

$windowStart = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:sys="clr-namespace:System;assembly=mscorlib"
        Width="300" Height="120" Left="-2000" Top="0" WindowStartupLocation="Manual"
        ShowInTaskbar="False" ShowActivated="False">
  <Window.Resources>
    <sys:Boolean x:Key="True">True</sys:Boolean>
    <sys:Boolean x:Key="False">False</sys:Boolean>
    <sys:Boolean x:Key="LayluReduceMotion">False</sys:Boolean>
  </Window.Resources>
'@

# --- Top bar -------------------------------------------------------------------------------
# IsTabStop stands in for "the pointer is over the bar".

$topPanel = [IO.File]::ReadAllText((Join-Path $views 'TopPanel.xaml'))
$barTriggers = Get-Between $topPanel 'x:Name="Latch"' '<MultiTrigger>' '</ControlTemplate.Triggers>'
$barXaml = $windowStart + @"
  <ContentControl x:Name="Target" IsTabStop="False">
    <ContentControl.Template>
      <ControlTemplate TargetType="ContentControl">
        <Grid>
          <Border x:Name="Latch" Width="0" Height="0" />
          <Border x:Name="EdgeTrigger" Height="28" Tag="{DynamicResource LayluReduceMotion}" />
          <Border x:Name="PanelSurface" Height="50" VerticalAlignment="Top" Background="Gray">
            <Border.RenderTransform><TranslateTransform Y="-50" /></Border.RenderTransform>
          </Border>
        </Grid>
        <ControlTemplate.Triggers>
          <Trigger Property="IsTabStop" Value="True">
            <Setter TargetName="Latch" Property="Tag" Value="{StaticResource True}" />
          </Trigger>
          $barTriggers
        </ControlTemplate.Triggers>
      </ControlTemplate>
    </ContentControl.Template>
  </ContentControl>
</Window>
"@

$script:settle = 900
function Set-BarHover($context, [bool]$over) { $context.Target.IsTabStop = $over; Wait $script:settle }
function Expect-Bar($context, [string]$what, [bool]$open) {
    $surface = $context.Target.Template.FindName('PanelSurface', $context.Target)
    Expect $context "$what, position" $surface.RenderTransform.Y $(if ($open) { 0 } else { -50 })
    Expect $context "$what, library offset" $context.Target.MinWidth $(if ($open) { 22 } else { 0 })
}

Scenario $barXaml 'bar, normal motion' { param($c)
    Expect-Bar $c 'at start' $false
    Set-BarHover $c $true;  Expect-Bar $c 'pointer in' $true
    Set-BarHover $c $false; Expect-Bar $c 'pointer out' $false
}
Scenario $barXaml 'bar, reduced from start' { param($c)
    Set-Motion $c $true
    Set-BarHover $c $true;  Expect-Bar $c 'pointer in' $true
    Set-BarHover $c $false; Expect-Bar $c 'pointer out' $false
    Set-BarHover $c $true;  Expect-Bar $c 'pointer in again' $true
}
Scenario $barXaml 'bar, reduced while open' { param($c)
    Set-BarHover $c $true
    Set-Motion $c $true;    Expect-Bar $c 'option on' $true
    Set-BarHover $c $false; Expect-Bar $c 'pointer out' $false
    Set-BarHover $c $true;  Expect-Bar $c 'pointer in again' $true
}
Scenario $barXaml 'bar, normal while open' { param($c)
    Set-Motion $c $true
    Set-BarHover $c $true
    Set-Motion $c $false;   Expect-Bar $c 'option off' $true
    Set-BarHover $c $false; Expect-Bar $c 'pointer out' $false
    Set-BarHover $c $true;  Expect-Bar $c 'pointer in again' $true
}
Scenario $barXaml 'bar, switched while closed' { param($c)
    Set-BarHover $c $true
    Set-BarHover $c $false
    Set-Motion $c $true;    Expect-Bar $c 'option on' $false
    Set-BarHover $c $true;  Expect-Bar $c 'pointer in' $true
    Set-BarHover $c $false
    Set-Motion $c $false;   Expect-Bar $c 'option off' $false
    Set-BarHover $c $true;  Expect-Bar $c 'pointer in again' $true
}

# --- Trailer fade --------------------------------------------------------------------------
# AllowDrop stands in for "the pointer is over the strip"; the trailer is always playing.

$page = [IO.File]::ReadAllText((Join-Path $views 'DetailsViewGameOverview.xaml'))
$fadeTriggers = Get-Between $page 'x:Name="HeaderBand"' '<Style.Triggers>' '</Border.Style>'
$fadeTriggers = [regex]::Replace($fadeTriggers, '<Condition Binding="\{(PluginSettings|Binding Visibility, ElementName=LayluTrailerHero)[^>]*/>', '')
$fadeTriggers = $fadeTriggers.Replace('{Binding IsMouseOver, RelativeSource={RelativeSource Self}}', '{Binding AllowDrop, RelativeSource={RelativeSource Self}}')
$fadeTriggers = $fadeTriggers.Replace('BeginTime="0:0:10"', 'BeginTime="0:0:0.3"')
if ($fadeTriggers -match 'PluginSettings|IsMouseOver|0:0:10') { throw 'The trailer fade triggers have changed shape; update this script.' }
$fadeXaml = $windowStart + @"
  <Grid>
    <Border x:Name="LayluReduceMotionFlag" Width="0" Height="0" Tag="{DynamicResource LayluReduceMotion}" />
    <Border x:Name="Target" Background="Gray" Tag="{StaticResource True}" AllowDrop="True">
      <Border.Style>
        <Style TargetType="Border">
          $fadeTriggers
      </Border.Style>
    </Border>
  </Grid>
</Window>
"@

$script:settle = 1300
function Set-StripHover($context, [bool]$over) { $context.Target.AllowDrop = $over; Wait $script:settle }
function Expect-Strip($context, [string]$what, [bool]$dimmed) {
    Expect $context "$what, opacity" $context.Target.Opacity $(if ($dimmed) { 0.1 } else { 1 })
}

Scenario $fadeXaml 'strip, normal motion' { param($c)
    Expect-Strip $c 'at start' $false
    Set-StripHover $c $false; Expect-Strip $c 'pointer out' $true
    Set-StripHover $c $true;  Expect-Strip $c 'pointer in' $false
    Set-StripHover $c $false; Expect-Strip $c 'pointer out again' $true
}
Scenario $fadeXaml 'strip, reduced from start' { param($c)
    Set-Motion $c $true
    Set-StripHover $c $false; Expect-Strip $c 'pointer out' $true
    Set-StripHover $c $true;  Expect-Strip $c 'pointer in' $false
    Set-StripHover $c $false; Expect-Strip $c 'pointer out again' $true
}
Scenario $fadeXaml 'strip, reduced while dimmed' { param($c)
    Set-StripHover $c $false
    Set-Motion $c $true;      Expect-Strip $c 'option on' $true
    Set-StripHover $c $true;  Expect-Strip $c 'pointer in' $false
    Set-StripHover $c $false; Expect-Strip $c 'pointer out' $true
}
Scenario $fadeXaml 'strip, normal while dimmed' { param($c)
    Set-Motion $c $true
    Set-StripHover $c $false
    Set-Motion $c $false;     Expect-Strip $c 'option off' $true
    Set-StripHover $c $true;  Expect-Strip $c 'pointer in' $false
    Set-StripHover $c $false; Expect-Strip $c 'pointer out' $true
}
Scenario $fadeXaml 'strip, switched while bright' { param($c)
    Set-StripHover $c $false
    Set-StripHover $c $true
    Set-Motion $c $true;      Expect-Strip $c 'option on' $false
    Set-StripHover $c $false; Expect-Strip $c 'pointer out' $true
    Set-StripHover $c $true
    Set-Motion $c $false;     Expect-Strip $c 'option off' $false
    Set-StripHover $c $false; Expect-Strip $c 'pointer out again' $true
}

Write-Host ''
Write-Host "$script:failed failed"
exit $script:failed
