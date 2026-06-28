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
# dxwrapper.asi is just dxwrapper.dll under a different name (same bytes)
# and isn't needed for the d3d9.dll-based loading path the release uses.
$dxwrapperFiles = @("d3d9.dll", "dxwrapper.dll", "dxwrapper.ini")
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

    # The end-user always gets a file called Merc2Fix.asi -- the variant
    # name is conveyed by the zip filename, not the ASI inside it. This
    # keeps the install instructions identical regardless of flavor.
    $variantDir = Join-Path $Staging "Merc2Reborn-$Version-$Flavor"
    New-Item -ItemType Directory -Path $variantDir | Out-Null
    Copy-Item $dll (Join-Path $variantDir "Merc2Fix.asi")
    foreach ($f in $dxwrapperFiles) {
        Copy-Item (Join-Path $GameDir $f) $variantDir
    }

    # Only the full build ships with the Lua console IDE -- the MP-only
    # variant has no bridge for it to connect to. tools.json is the
    # companion-tool manifest that any mod manager can read to surface
    # a "Launch Tool" button on this mod's page (proposal -- see file).
    if ($Flavor -eq "full") {
        $idePath = Join-Path $Root "dist\lua_console.exe"
        if (-not (Test-Path $idePath)) {
            throw "lua_console.exe missing at $idePath -- Build-LuaConsoleExe should have produced it"
        }
        Copy-Item $idePath (Join-Path $variantDir "lua_console.exe")
        Copy-Item (Join-Path $Root "tools\tools.json") (Join-Path $variantDir "tools.json")
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
  - Lua bridge on 127.0.0.1:27050 for modding.
  - lua_console.exe : standalone Lua IDE (tabbed editor, syntax
    highlighting, output panel, bridge status indicator). Double-click
    to launch; needs the game running for the bridge to connect.
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

function Build-LuaConsoleExe {
    Write-Host ""
    Write-Host "=== Building lua_console.exe (PyInstaller) ==="
    $idePath = Join-Path $Root "dist\lua_console.exe"
    $srcPath = Join-Path $Root "tools\lua_console.py"
    if (-not (Test-Path $srcPath)) {
        throw "tools/lua_console.py missing -- can't build IDE"
    }
    # Skip rebuild if the existing .exe is newer than the source. PyInstaller
    # takes ~20s on a cold run and isn't part of the C++ build's
    # incremental story.
    if ((Test-Path $idePath) -and
        (Get-Item $idePath).LastWriteTime -gt (Get-Item $srcPath).LastWriteTime) {
        Write-Host "  (cached) $idePath up to date"
        return
    }
    # PyInstaller has to run from the repo root to find the source via the
    # relative path we pass. Output lands in $Root\dist\.
    Push-Location $Root
    try {
        $output = & py -m PyInstaller --onefile --windowed --noconfirm --name lua_console $srcPath 2>&1
        if ($LASTEXITCODE -ne 0) {
            $output | Write-Host
            throw "PyInstaller failed (exit $LASTEXITCODE)"
        }
        $output | Select-String -Pattern "ERROR|WARNING|Build complete" | Select-Object -Last 4 | ForEach-Object { Write-Host "  $_" }
    } finally {
        Pop-Location
    }
    if (-not (Test-Path $idePath)) { throw "PyInstaller didn't produce $idePath" }
    Write-Host ("  -> {0} ({1:N0} KB)" -f $idePath, ((Get-Item $idePath).Length / 1KB))
}

Build-LuaConsoleExe

Build-Variant -Suffix ""        -Defines ""                   -Flavor "full"
Build-Variant -Suffix "_MPOnly" -Defines "DISABLE_LUA_BRIDGE" -Flavor "multiplayer-only"

Write-Host ""
Write-Host "All artifacts ready. Upload these to a GitHub release:"
Get-ChildItem $Staging -Filter *.zip | ForEach-Object {
    Write-Host ("  {0,-60} {1,8:N0} KB" -f $_.FullName, ($_.Length / 1KB))
}
