#Requires -RunAsAdministrator

Write-Host "--- Zoom 1132 Error Fix Script ---" -ForegroundColor Yellow
Write-Host "This script will create a new local user 'ZoomLocal' and a desktop shortcut to run Zoom as that user."
Write-Host "You must run this as an Administrator."
Write-Host

# Step 2: Create the user
try {
    $Password = Read-Host -AsSecureString -Prompt "Please enter a new, secure password for the 'ZoomLocal' user"
    
    Write-Host "Creating local user 'ZoomLocal'..."
    New-LocalUser "ZoomLocal" -Password $Password -FullName "ZoomLocal User" -Description "Zoom Error 1132 workaround" -ErrorAction Stop
    Add-LocalGroupMember -Group "Users" -Member "ZoomLocal" -ErrorAction Stop
    
    Write-Host "'ZoomLocal' user created successfully." -ForegroundColor Green
}
catch {
    Write-Host "Error creating user: $_" -ForegroundColor Red
    Write-Host "The user might already exist. If so, that's okay."
}

Write-Host
# Step 4: Enable Secondary Logon
try {
    Write-Host "Configuring 'Secondary Logon' service (seclogon)..."
    Set-Service -Name seclogon -StartupType Automatic -ErrorAction Stop
    Start-Service -Name seclogon -ErrorAction Stop
    
    Write-Host "'Secondary Logon' service is set to Automatic and started." -ForegroundColor Green
}
catch {
    Write-Host "Error configuring Secondary Logon service: $_" -ForegroundColor Red
}

Write-Host
# Step 5: Create the .cmd launcher
$DesktopPath = [Environment]::GetFolderPath("CommonDesktopDirectory")
$LauncherPath = Join-Path -Path $DesktopPath -ChildPath "Run Zoom as Local User.cmd"

$LauncherContent = @"
@echo off
set "ZOOM_PATH_USER=%LocalAppData%\Zoom\bin\Zoom.exe"
set "ZOOM_PATH_MACHINE=%ProgramFiles(x86)%\Zoom\bin\Zoom.exe"

echo Attempting to start Zoom as ZoomLocal...
echo Please enter the password for the 'ZoomLocal' user when prompted.

if exist "%ZOOM_PATH_USER%" (
    echo Found Zoom in user profile (AppData).
    runas /user:ZoomLocal "%ZOOM_PATH_USER%"
) else if exist "%ZOOM_PATH_MACHINE%" (
    echo Found Zoom in Program Files.
    runas /user:ZoomLocal "%ZOOM_PATH_MACHINE%"
) else (
    echo ERROR: Could not find Zoom.exe in common locations.
    pause
)
"@

try {
    Set-Content -Path $LauncherPath -Value $LauncherContent -Encoding "ASCII" -ErrorAction Stop
    Write-Host "Created 'Run Zoom as Local User.cmd' shortcut on the Public Desktop." -ForegroundColor Green
}
catch {
    Write-Host "Error creating desktop shortcut: $_" -ForegroundColor Red
}

Write-Host
Write-Host "--- SCRIPT COMPLETE ---" -ForegroundColor Yellow
Write-Host "IMPORTANT: You must now log out of Windows, log in as 'ZoomLocal' once," -ForegroundColor Cyan
Write-Host "then log out and back into your main account." -ForegroundColor Cyan
Write-Host "After that, use the new desktop shortcut to run Zoom." -ForegroundColor Cyan
Write-Host
Read-Host -Prompt "Press Enter to exit"