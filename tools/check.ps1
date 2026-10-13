# Checks the repository before a commit or a release. Run by tools\pack.ps1 and by CI.
#
#   1. every theme XAML file is well-formed;
#   2. Views\GridViewGameOverview.xaml is what tools\sync-grid-page.ps1 generates;
#   3. the version and the add-on Id agree across theme.yaml, installer.yaml, the add-on
#      manifest and CHANGELOG.md.
#
# Exits with 1 and lists every problem found.

$ErrorActionPreference = 'Stop'

$root = Split-Path $PSScriptRoot -Parent
$theme = Join-Path $root 'theme'
$problems = New-Object Collections.Generic.List[string]

function Get-Field([string]$file, [string]$pattern, [string]$what) {
    $match = [regex]::Match([IO.File]::ReadAllText((Join-Path $root $file)), $pattern, 'Multiline')
    if (-not $match.Success) {
        $problems.Add("${file}: no $what found")
        return $null
    }
    return $match.Groups[1].Value.Trim()
}

# 1. Well-formed XAML. Build output under obj and bin is not part of the theme.
$xamlFiles = Get-ChildItem -LiteralPath $theme -Recurse -Filter *.xaml |
    Where-Object { $_.FullName -notmatch '\\(obj|bin)\\' }
foreach ($file in $xamlFiles) {
    try {
        (New-Object Xml.XmlDocument).Load($file.FullName)
    } catch {
        $problems.Add("$($file.FullName.Substring($root.Length + 1)): not well-formed. $($_.Exception.InnerException.Message)")
    }
}
Write-Host ("{0,3} XAML files parsed" -f $xamlFiles.Count)

# 2. The generated grid page. Line endings are ignored: they depend on the checkout.
$gridPage = Join-Path $theme 'Views\GridViewGameOverview.xaml'
$before = [IO.File]::ReadAllBytes($gridPage)
& (Join-Path $PSScriptRoot 'sync-grid-page.ps1') *> $null
$utf8 = New-Object Text.UTF8Encoding($false)
$beforeText = $utf8.GetString($before).Replace("`r`n", "`n")
$afterText = [IO.File]::ReadAllText($gridPage).Replace("`r`n", "`n")
if ($beforeText -eq $afterText) {
    [IO.File]::WriteAllBytes($gridPage, $before)
    Write-Host '    grid page matches its source'
} else {
    $problems.Add('theme\Views\GridViewGameOverview.xaml was out of date with DetailsViewGameOverview.xaml. It has been regenerated; review and commit it.')
}

# 3. Version and Id
$version = Get-Field 'theme\theme.yaml' '^Version:\s*(\S+)' 'Version'
$id = Get-Field 'theme\theme.yaml' '^Id:\s*(\S+)' 'Id'
$packageVersion = Get-Field 'installer.yaml' '^\s*-\s*Version:\s*(\S+)' 'package Version'
$packageUrl = Get-Field 'installer.yaml' '^\s*PackageUrl:\s*(\S+)' 'PackageUrl'
$installerId = Get-Field 'installer.yaml' '^AddonId:\s*(\S+)' 'AddonId'
$manifestId = Get-Field 'manifests\Kyerstorm_Laylu.yaml' '^AddonId:\s*(\S+)' 'AddonId'
$changelogVersion = Get-Field 'CHANGELOG.md' '^## (\d\S*)' 'version heading'

if ($version -and $id) {
    if ($packageVersion -ne $version) {
        $problems.Add("installer.yaml: newest package is $packageVersion, theme.yaml says $version")
    }
    $expectedUrl = "/releases/download/v$version/${id}_$($version.Replace('.', '_')).pthm"
    if ($packageUrl -and -not $packageUrl.EndsWith($expectedUrl)) {
        $problems.Add("installer.yaml: PackageUrl should end with $expectedUrl")
    }
    foreach ($other in @(@('installer.yaml', $installerId), @('manifests\Kyerstorm_Laylu.yaml', $manifestId))) {
        if ($other[1] -and $other[1] -ne $id) {
            $problems.Add("$($other[0]): AddonId $($other[1]) is not the theme Id $id")
        }
    }
    if ($changelogVersion -and $changelogVersion -ne $version) {
        $problems.Add("CHANGELOG.md: newest entry is $changelogVersion, theme.yaml says $version")
    }
    Write-Host "    version $version"
}

if ($problems.Count -gt 0) {
    Write-Host ''
    foreach ($problem in $problems) { Write-Host "FAILED: $problem" }
    exit 1
}
Write-Host 'All checks passed.'
# Explicit, so a caller testing $LASTEXITCODE does not read a stale or empty value
exit 0
