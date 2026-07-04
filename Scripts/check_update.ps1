param(
    [string]$LocalVersion,
    [string]$InstallDir,
    [string]$GameDir
)

$Owner   = "Heawikk"
$Repo    = "OutlastMP"
$ApiUrl  = "https://api.github.com/repos/$Owner/$Repo/releases/latest"
$Headers = @{ "User-Agent" = "OutlastMM-Updater" }

Write-Host ""
Write-Host "  Checking for updates..."

try {
    $release = Invoke-RestMethod -Uri $ApiUrl -Headers $Headers -TimeoutSec 10
} catch {
    Write-Host ""
    if ($_.Exception.Response.StatusCode.value__ -eq 404) {
        Write-Host "  No releases found on GitHub yet." -ForegroundColor Gray
    } else {
        Write-Host "  Could not reach GitHub. Check your internet connection." -ForegroundColor Red
        Write-Host "  $($_.Exception.Message)"
    }
    exit 0
}

$tagName = $release.tag_name -replace '^v', ''

try {
    $localVer  = [System.Version]$LocalVersion
    $remoteVer = [System.Version]$tagName
} catch {
    Write-Host ""
    Write-Host "  Could not parse version numbers ('$LocalVersion' vs '$tagName')." -ForegroundColor Red
    exit 1
}

if ($remoteVer -le $localVer) {
    Write-Host ""
    Write-Host "  Already up to date. Version: $LocalVersion" -ForegroundColor Green
    exit 0
}

Write-Host ""
Write-Host "  New version available: $tagName" -ForegroundColor Yellow
Write-Host "  Your version:          $LocalVersion" -ForegroundColor Gray

if ($release.body) {
    Write-Host ""
    Write-Host "  Release notes:"
    $release.body -split "`n" | Select-Object -First 10 | ForEach-Object {
        Write-Host "    $_"
    }
}

$asset = $release.assets | Where-Object { $_.name -like "*.zip" } | Select-Object -First 1

Write-Host ""
if ($asset) {
    $sizeMB = [math]::Round($asset.size / 1MB, 1)
    Write-Host "  Download: $($asset.name) ($sizeMB MB)"
} else {
    Write-Host "  No ZIP asset found in release. Open release page to download manually."
    Write-Host "  $($release.html_url)"
    Write-Host ""
    $open = Read-Host "  Open in browser? (y/n)"
    if ($open -ieq 'y') { Start-Process $release.html_url }
    exit 0
}

Write-Host ""
$choice = Read-Host "  Download and install update? (y/n)"
if ($choice -ine 'y') {
    Write-Host ""
    Write-Host "  Update skipped."
    exit 0
}

$tempZip = Join-Path $env:TEMP "OutlastMP_update.zip"
$tempDir = Join-Path $env:TEMP "OutlastMP_update"

Write-Host ""
Write-Host "  Downloading..." -NoNewline
try {
    Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $tempZip -Headers $Headers
    Write-Host " done." -ForegroundColor Green
} catch {
    Write-Host " FAILED." -ForegroundColor Red
    Write-Host "  $($_.Exception.Message)"
    exit 1
}

Write-Host "  Extracting..." -NoNewline
if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
Expand-Archive -Path $tempZip -DestinationPath $tempDir -Force
Write-Host " done." -ForegroundColor Green

# If ZIP has a single root folder, use it as source; otherwise use tempDir directly
$topItems = Get-ChildItem -Path $tempDir
if ($topItems.Count -eq 1 -and $topItems[0].PSIsContainer) {
    $sourceDir = $topItems[0].FullName
} else {
    $sourceDir = $tempDir
}

Write-Host "  Installing..." -NoNewline

$installDirClean = $InstallDir.TrimEnd('\', '"')
$skipped = @()
$copied  = 0

Get-ChildItem -Path $sourceDir -Recurse -File | ForEach-Object {
    $relPath = $_.FullName.Substring($sourceDir.Length).TrimStart('\')

    # Never overwrite user config
    if ($relPath -eq "config.ini") {
        $skipped += $relPath
        return
    }

    $dest    = Join-Path $installDirClean $relPath
    $destDir = Split-Path $dest
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }
    Copy-Item $_.FullName -Destination $dest -Force
    $copied++
}

Write-Host " done. ($copied files)" -ForegroundColor Green

if ($skipped.Count -gt 0) {
    Write-Host "  Preserved (user files): $($skipped -join ', ')" -ForegroundColor Gray
}

Remove-Item $tempZip  -Force -ErrorAction SilentlyContinue
Remove-Item $tempDir  -Recurse -Force -ErrorAction SilentlyContinue

# Copy Multiplayer.u to the game directory if known
$GameDir = $GameDir.TrimEnd('\', '"')
if ($GameDir -and (Test-Path $GameDir)) {
    $modU   = Join-Path $installDirClean "OLGame\CookedPCConsole\OLMP\Multiplayer.u"
    $gameU  = Join-Path $GameDir "OLGame\CookedPCConsole\OLMP\Multiplayer.u"
    if (Test-Path $modU) {
        $gameUDir = Split-Path $gameU
        if (-not (Test-Path $gameUDir)) { New-Item -ItemType Directory -Path $gameUDir -Force | Out-Null }
        Copy-Item $modU -Destination $gameU -Force
        Write-Host "  Multiplayer.u copied to game directory." -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "  Update to v$tagName applied successfully!" -ForegroundColor Green
Write-Host "  Please restart omm.bat."
