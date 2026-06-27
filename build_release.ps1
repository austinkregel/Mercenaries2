#requires -Version 5.1
<#
.SYNOPSIS
    Build both Merc2Fix variants (full + multiplayer-only) and package
    each into a release-ready zip with the dxwrapper loader bundle.

.DESCRIPTION
    Produces two artifacts under release-staging/ :

      Merc2Reborn-<version>-full.zip
          Merc2Fix.asi             (with Lua bridge)
          d3d9.dll                 (dxwrapper)
          dxwrapper.dll
          dxwrapper.asi
          dxwrapper.ini
          INSTALL.txt

      Merc2Reborn-<version>-multiplayer-only.zip
          Merc2Fix.asi             (Lua bridge compiled out)
          d3d9.dll                 (dxwrapper)
          dxwrapper.dll
          dxwrapper.asi
          dxwrapper.ini
          INSTALL.txt

    The multiplayer-only build defines DISABLE_LUA_BRIDGE which skips
    the Lua bridge init entirely, so users on exe versions whose RVAs
    don't match the verified archive.org build won't risk a CTD.

.PARAMETER Version
    Version label baked into the zip names. Default: v1.0.0.

.PARAMETER MSBuildPath
    Optional explicit path to MSBuild.exe. If omitted, vswhere is used
    to locate the latest VS install with MSBuild.

.PARAMETER GameDir
    Where to source the dxwrapper bundle from. Default:
    C:\Games\Mercenaries 2 World in Flames

.EXAMPLE
    pwsh ./build_release.ps1 -Version v1.0.0
#>
param(
    [string]$Version     = "v1.0.0",
    [string]$MSBuildPath = $null,
    [string]$GameDir     = "C:\Games\Mercenaries 2 World in Flames"
)

$ErrorActionPreference = "Stop"
$Root      = $PSScriptRoot
$Project   = Join-Path $Root "Merc2Fix\Merc2Fix.vcxproj"
# MSBuild on the vcxproj directly drops output in <project>\Release\,
# not <solution>\Release\ like Visual Studio's IDE does. We probe both
# below so this script works under either layout.
$ReleaseOutCandidates = @(
    (Join-Path $Root "Merc2Fix\Release"),
    (Join-Path $Root "Release")
)
$Staging   = Join-Path $Root "release-staging"

# --- locate MSBuild --------------------------------------------------------
if (-not $MSBuildPath) {
    $vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
    if (Test-Path $vswhere) {
        $vsInstall = & $vswhere -latest -products * -requires Microsoft.Component.MSBuild -property installationPath
        if ($vsInstall) {
            $MSBuildPath = Join-Path $vsInstall "MSBuild\Current\Bin\MSBuild.exe"
        }
    }
}
if (-not $MSBuildPath -or -not (Test-Path $MSBuildPath)) {
    throw "Couldn't locate MSBuild.exe. Pass -MSBuildPath C:\path\to\MSBuild.exe"
}
Write-Host "MSBuild: $MSBuildPath"
Write-Host "Version: $Version"

# --- staging dir -----------------------------------------------------------
if (Test-Path $Staging) { Remove-Item -Recurse -Force $Staging }
New-Item -ItemType Directory -Path $Staging | Out-Null

# --- dxwrapper bundle source check -----------------------------------------
$dxwrapperFiles = @("d3d9.dll", "dxwrapper.dll", "dxwrapper.asi", "dxwrapper.ini")
foreach ($f in $dxwrapperFiles) {
    $src = Join-Path $GameDir $f
    if (-not (Test-Path $src)) {
        throw "Missing dxwrapper bundle file: $src (set -GameDir or copy it in)"
    }
}

function Build-Variant {
    param(
        # Suffix and Defines are intentionally allowed to be empty
        # (full build uses no suffix and no extra defines).
        [Parameter(Mandatory)] [AllowEmptyString()] [string]$Suffix,
        [Parameter(Mandatory)] [AllowEmptyString()] [string]$Defines,
        [Parameter(Mandatory)] [ValidateNotNullOrEmpty()] [string]$Flavor
    )

    Write-Host ""
    Write-Host "=== Building $Flavor (suffix='$Suffix' defines='$Defines') ==="

    & $MSBuildPath $Project `
        /t:Rebuild `
        /p:Configuration=Release `
        /p:Platform=Win32 `
        /p:NameSuffix=$Suffix `
        /p:ExtraDefines=$Defines `
        /p:SkipDeploy=true `
        /v:minimal
    if ($LASTEXITCODE -ne 0) { throw "Build failed for $Flavor (exit $LASTEXITCODE)" }

    $dll = $null
    foreach ($cand in $ReleaseOutCandidates) {
        $maybe = Join-Path $cand "Merc2Fix$Suffix.dll"
        if (Test-Path $maybe) { $dll = $maybe; break }
    }
    if (-not $dll) {
        $tried = ($ReleaseOutCandidates | ForEach-Object { Join-Path $_ "Merc2Fix$Suffix.dll" }) -join "; "
        throw "Expected build output missing. Tried: $tried"
    }

    # The end-user always gets a file called Merc2Fix.asi — the variant
    # name is conveyed by the zip filename, not the ASI inside it. This
    # keeps the install instructions identical regardless of flavor.
    $variantDir = Join-Path $Staging "Merc2Reborn-$Version-$Flavor"
    New-Item -ItemType Directory -Path $variantDir | Out-Null
    Copy-Item $dll (Join-Path $variantDir "Merc2Fix.asi")
    foreach ($f in $dxwrapperFiles) {
        Copy-Item (Join-Path $GameDir $f) $variantDir
    }

    $installNote = @"
Merc2Reborn $Version ($Flavor)
================================

Install:
  1. Copy ALL files in this folder into your Mercenaries 2 install
     directory (the folder that contains Mercenaries2.exe).
  2. Launch the game normally.

That's it. No MLoader required.

What you get:
"@
    if ($Flavor -eq "full") {
        $installNote += @"

  - Online multiplayer (matchmaking + UDP relay, no port forwarding).
  - Lua bridge on 127.0.0.1:27050 for modding (REPL via
    tools/lua_repl.py in the source repo).
"@
    } else {
        $installNote += @"

  - Online multiplayer (matchmaking + UDP relay, no port forwarding).
  - NO Lua bridge. Use this build if the full build crashes your game
    on launch (the bridge's address table is derived from one specific
    exe build and may not match yours).
"@
    }
    $installNote += @"


Source, troubleshooting, and updates:
  https://github.com/loganw234/Mercenaries2
"@
    $installNote | Out-File -Encoding ASCII (Join-Path $variantDir "INSTALL.txt")

    $zip = Join-Path $Staging "Merc2Reborn-$Version-$Flavor.zip"
    if (Test-Path $zip) { Remove-Item -Force $zip }
    Compress-Archive -Path (Join-Path $variantDir "*") -DestinationPath $zip
    Write-Host "  -> $zip"
}

Build-Variant -Suffix ""        -Defines ""                   -Flavor "full"
Build-Variant -Suffix "_MPOnly" -Defines "DISABLE_LUA_BRIDGE" -Flavor "multiplayer-only"

Write-Host ""
Write-Host "All artifacts ready. Upload these to a GitHub release:"
Get-ChildItem $Staging -Filter *.zip | ForEach-Object {
    Write-Host ("  {0,-60} {1,8:N0} KB" -f $_.FullName, ($_.Length / 1KB))
}
