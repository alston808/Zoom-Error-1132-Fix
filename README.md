# Zoom Error 1132 Fix

[![Windows](https://img.shields.io/badge/platform-Windows-blue.svg)](https://github.com/topics/windows)
[![PowerShell](https://img.shields.io/badge/shell-PowerShell-blue.svg)](https://github.com/topics/powershell)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

A comprehensive solution to bypass Zoom Error 1132 on Windows systems by running Zoom under a fresh local user account.

## 🚨 Problem

Zoom Error 1132 typically occurs when joining meetings and can prevent users from connecting. This error often relates to corrupted user profiles or registry issues that affect Zoom's functionality.

## ✅ Solution

This project provides both automated and manual methods to create a workaround by:
- Creating a dedicated local Windows user account (`ZoomLocal`)
- Configuring the Secondary Logon service
- Running Zoom under the fresh user profile to bypass corrupted settings

## 📁 Project Structure

```
Zoom Error 1132 Fix/
├── windows/
│   ├── CreateZoomUser.ps1    # Automated PowerShell script
│   └── index.html           # Detailed manual instructions & web interface
└── README.md               # This file
```

## 🚀 Quick Start

### Option 1: Automated Script (Recommended)

1. **Download** the `CreateZoomUser.ps1` script
2. **Right-click** and run as Administrator in PowerShell
3. **Follow** the on-screen prompts to create a password for the new user
4. **Complete** the manual initialization steps (logout/login cycle)
5. **Use** the desktop shortcut to launch Zoom

### Option 2: Manual Steps

Open `windows/index.html` in your browser for detailed step-by-step instructions with copy-paste code blocks.

## 📋 Prerequisites

- **Windows 10 or 11**
- **Administrator privileges** (required for user creation and service configuration)
- **PowerShell** (included with Windows)
- **Zoom client** installed (but signed out)

## 🔧 How It Works

The solution works by creating an isolated Windows user profile that doesn't contain the corrupted settings causing Error 1132:

1. **Fresh User Account**: Creates a new local user `ZoomLocal` with clean profile
2. **Service Configuration**: Ensures Secondary Logon service is running
3. **Profile Initialization**: Forces Windows to create and set up the new profile
4. **Isolated Execution**: Runs Zoom under the clean user context

## 📖 Detailed Instructions

### Automated Method

```powershell
# Run as Administrator
.\windows\CreateZoomUser.ps1
```

The script will:
- Prompt for a secure password for the new user
- Create the `ZoomLocal` user account
- Configure the Secondary Logon service
- Create a desktop shortcut for easy Zoom launching

### Manual Method

1. **Update & Sign Out of Zoom**
   - Open Zoom → Profile → Help → Check for Updates
   - Profile → Sign Out

2. **Create New User** (run in Admin PowerShell):
   ```powershell
   $Password = Read-Host -AsSecureString -Prompt "Enter password"
   New-LocalUser "ZoomLocal" -Password $Password -FullName "ZoomLocal User"
   Add-LocalGroupMember -Group "Users" -Member "ZoomLocal"
   ```

3. **Initialize Profile** (manual):
   - Sign out of your main account
   - Log in as `ZoomLocal` user (once)
   - Sign out and return to main account

4. **Enable Secondary Logon** (Admin PowerShell):
   ```powershell
   Set-Service -Name seclogon -StartupType Automatic
   Start-Service -Name seclogon
   ```

5. **Create Launcher** (`RunZoom.cmd` on desktop):
   ```batch
   @echo off
   set "ZOOM_PATH_USER=%LocalAppData%\Zoom\bin\Zoom.exe"
   set "ZOOM_PATH_MACHINE=%ProgramFiles(x86)%\Zoom\bin\Zoom.exe"

   if exist "%ZOOM_PATH_USER%" (
       runas /user:ZoomLocal "%ZOOM_PATH_USER%"
   ) else if exist "%ZOOM_PATH_MACHINE%" (
       runas /user:ZoomLocal "%ZOOM_PATH_MACHINE%"
   ) else (
       echo ERROR: Could not find Zoom.exe
       pause
   )
   ```

6. **Join Meetings**:
   - Double-click the desktop shortcut
   - Enter the `ZoomLocal` password when prompted
   - Click "Join a Meeting" (don't sign in)
   - Enter meeting ID

## 🛠️ Advanced Cleanup

If the basic fix doesn't work, try these additional steps:

### Remove Registry Hooks
```batch
reg delete "HKEY_CLASSES_ROOT\ZoomPhoneCall" /f
reg delete "HKEY_CLASSES_ROOT\ZoomPhoneSMS" /f
```

### Clean Reinstall
1. Uninstall Zoom via Settings → Apps
2. Download fresh installer from [zoom.us/download](https://zoom.us/download)
3. Install and test again

## 🔒 Security Notes

- The `ZoomLocal` account is a standard user account
- It only has access to run Zoom and basic Windows functions
- The password is required each time you launch Zoom
- Consider this account as temporary - you can remove it after the issue is resolved

## 🐛 Troubleshooting

### Script won't run
- Ensure you're running PowerShell as Administrator
- Check execution policy: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

### User creation fails
- The user might already exist (that's okay)
- Try a different username if needed

### Zoom still shows Error 1132
- Ensure you signed out of Zoom in your main account
- Verify the profile initialization was completed
- Try the advanced cleanup steps

### Can't find Zoom.exe
- The script checks common installation paths
- If Zoom is installed elsewhere, modify the batch file accordingly

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Test on multiple Windows versions
4. Submit a pull request with detailed description

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

This is a workaround for a known Zoom issue. Use at your own risk. The solution creates an additional user account on your system. Always ensure you have backups and understand the changes being made to your system.

## 📞 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review the detailed HTML guide in `windows/index.html`
3. Search existing GitHub issues
4. Create a new issue with your Windows version and error details

---

**Note**: This solution is specific to Windows systems. For other platforms, search for platform-specific solutions or contact Zoom support.
