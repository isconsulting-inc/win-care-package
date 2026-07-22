# Windows 11 PC Care Package

## Scope
This script is intended to automate a large portion of the Windows 11 setup process and remove much of the bloat that comes out of the box.


> [!Caution]  
> **Use with caution**  
> This script is tested and working as of 2026-07-22 with no breaking changes to the latest version of Windows 11 but holds no guarantee that will remain the case with future updates.
>   
> This is not intended for in-use systems and is focused solely for new setups where data loss and reloading is of minimal consequence.  


## Currently Planned Additions
- [x] Test function of script
- [x] Add standard application installs utilizing WinGet
- [ ] Add multiple choice menu for refining app install scope
- [ ] Add ODT support for standalone MSOffice installations with a selector at start

---

## Usage
1. Open an elevated PowerShell session and run `Set-ExecutionPolicy Bypass` to allow the script to run.
2. Run the script either through the same session, or right-click and "Run with PowerShell". The script will automatically return the execution policy to `undefined` after running.

---

## What This Script Does
🛡️ Administrative Elevation
- Checks for admin rights and relaunches with elevation if needed.

🧠 Registry & Profile Setup
- Loads and modifies the Default user hive to apply settings to future profiles.
- Defines RegSetUser function to adjust registry settings for current and default users.

🖥️ System Management
- Renames the computer based on user input.
- Creates/updates a local admin user, sets password, ensures it never expires.
- Disables automatic reboot on BSOD.

📁 File Explorer Settings
- Removes "- Shortcut" suffix from new shortcuts.
- Enables file extensions visibility and menu bar in Explorer.
- Sets Explorer launch view to “This PC”.

🔋 Power Settings
- Disables hibernation, standby/sleep on AC power, and Fast Boot.
- Sets lid-close actions for the active power profile to do nothing on AC and sleep on battery.

🧹 System Cleanup & Debloat
- Disables “consumer features” and silent app installs.
- Removes most built-in apps for all users (preserving only essentials like Calculator, Terminal, Notepad, Photos, Paint, etc.).
- Disables:
	- Xbox DVR
 	- Featured software installs
	- Suggested apps
	- Spotlight content
    - Desktop Spotlight
	- Delivery Optimization
	- Advertising ID
	- Feedback prompts
    - Taskbar "Widgets"

🔐 Privacy & Telemetry Hardening
- Disables:
	- Telemetry
	- Diagnostics tracking services
	- SmartGlass
	- Device sync & history
	- Bing search
	- Implicit data collection (typing, inking)
	- CEIP (Customer Experience Improvement Program)
	- Application Compatibility tracking
	- UPNP device pairing
	- Advertising ID
	- Do Not Track is enabled for Microsoft Edge

🧰 Service Management
- Stops and disables:
	- DiagTrack, DmwApPushService, Xbox services, Distributed Link Tracking, WMPNetworkSvc

🌐 Remote Access
- Enables Remote Desktop and relevant firewall rules.
- Enforces user authentication for RDP.

🕒 Other System Configurations
- Sets system timezone to Eastern Standard Time (EST).
- Enables F8 Boot Menu (legacy boot options).
- Sets PowerShell script execution policy back to Undefined prior to exiting.

⬇️ Application Installs
- Installs Adobe Acrobat DC, Google Chrome, Firefox, and Office 365 Apps

✅ Final Prompts and Reminders
- ASCII art outro with reminders to:
	- Run updates
	- Install LoB apps
	- Set startup/recovery options
	- Restart the computer
