# Builds the .pthm package into dist\ with Playnite's Toolbox.
#
#   powershell -ExecutionPolicy Bypass -File tools\pack.ps1
#   powershell -ExecutionPolicy Bypass -File tools\pack.ps1 -Toolbox 'D:\Playnite\Toolbox.exe'
#
# Runs tools\check.ps1 first. Only files tracked by git are packaged, from a copy in the temp
# folder, so build output (theme\obj) and stray files never reach a release.
#
# Toolbox removes its folder argument from every file name, so that argument has to be an
# absolute path: with a relative "theme", thememodifier.yaml is packaged as modifier.yaml
# and ThemeModifier stops finding the settings. That is what went wrong in 1.0.

param(
    [string]$Toolbox = $(if ($env:PLAYNITE_TOOLBOX) { $env:PLAYNITE_TOOLBOX } else { 'C:\Games\Playnite\Toolbox.exe' }),
    [string]$OutDir
)

$ErrorActionPreference = 'Stop'

$root = Split-Path $PSScriptRoot -Parent
if (-not $OutDir) { $OutDir = Join-Path $root 'dist' }

if (-not (Test-Path -LiteralPath $Toolbox)) {
    throw "Toolbox.exe not found at $Toolbox. Pass -Toolbox or set PLAYNITE_TOOLBOX."
}

& (Join-Path $PSScriptRoot 'check.ps1')
if ($LASTEXITCODE -ne 0) { throw 'Checks failed; nothing was packaged.' }

$staging = Join-Path ([IO.Path]::GetTempPath()) ("laylu-pack-" + [guid]::NewGuid().ToString('N'))
$stagedTheme = Join-Path $staging 'theme'
try {
    $tracked = & git -C $root ls-files -- theme
    if ($LASTEXITCODE -ne 0 -or -not $tracked) { throw 'git ls-files returned no theme files.' }
    foreach ($relative in $tracked) {
        $destination = Join-Path $staging $relative
        New-Item -ItemType Directory -Force -Path (Split-Path $destination -Parent) | Out-Null
        Copy-Item -LiteralPath (Join-Path $root $relative) -Destination $destination
    }

    New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
    $OutDir = (Resolve-Path -LiteralPath $OutDir).Path
    & $Toolbox pack $stagedTheme $OutDir
    if ($LASTEXITCODE -ne 0) { throw "Toolbox pack failed with exit code $LASTEXITCODE." }
} finally {
    if (Test-Path -LiteralPath $staging) { Remove-Item -LiteralPath $staging -Recurse -Force }
}

# The package must be the one installer.yaml points at, and must hold the settings file by name
$themeYaml = [IO.File]::ReadAllText((Join-Path $root 'theme\theme.yaml'))
$version = [regex]::Match($themeYaml, '(?m)^Version:\s*(\S+)').Groups[1].Value
$id = [regex]::Match($themeYaml, '(?m)^Id:\s*(\S+)').Groups[1].Value
$package = Join-Path $OutDir ("{0}_{1}.pthm" -f $id, $version.Replace('.', '_'))
if (-not (Test-Path -LiteralPath $package)) { throw "Expected package not found: $package" }

Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [IO.Compression.ZipFile]::OpenRead($package)
try {
    $names = $zip.Entries | ForEach-Object { $_.FullName }
} finally {
    $zip.Dispose()
}
foreach ($required in 'theme.yaml', 'thememodifier.yaml') {
    if ($names -notcontains $required) { throw "$required is missing from the package." }
}

Write-Host ("Packaged {0} files: {1}" -f $names.Count, $package)
