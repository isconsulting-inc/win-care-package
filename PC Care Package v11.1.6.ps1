###########################
## Administrative Rights ##
###########################


## Requests admin permissions and re-launches script with execution policy set to "bypass" to allow easier script function
write-Host "***Requesting elevated permissions***" -ForegroundColor Green -BackgroundColor Black
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

## Sets PWSH Script policy back to default of "undefined"
Set-ExecutionPolicy Undefined -Force


######################
## Define Functions ##
######################


function DrawMenu {
    ## Support function to the Menu function
    param ($menuItems, $menuPosition, $menuTitle)
    $l = $menuItems.length + 1
    cls
    $menuwidth = $menuTitle.length + 4
    write-Host "`t" -NoNewLine
    write-Host ("*" * $menuwidth) -fore Cyan -back Black
    write-Host "`t" -NoNewLine
    write-Host "* $menuTitle *" -fore Cyan -back Black
    write-Host "`t" -NoNewLine
    write-Host ("*" * $menuwidth) -fore Cyan -back Black
    write-Host ""
    write-debug "L: $l MenuItems: $menuItems MenuPosition: $menuposition"
    for ($i = 0; $i -le $l;$i++) {
        Write-Host "`t" -NoNewLine
        if ($i -eq $menuPosition) {
            Write-Host "$($menuItems[$i])" -fore Black -back Cyan
        } else {
            Write-Host "$($menuItems[$i])" -fore Cyan -back Black
        }
    }
}

function Menu {
    ## Generate a small "DOS-like" menu.
    ## Choose a menu item using up and down arrows, select by pressing ENTER
    param ([array]$menuItems, $menuTitle = "MENU")
    $vkeycode = 0
    $pos = 0
    DrawMenu $menuItems $pos $menuTitle
    While ($vkeycode -ne 13) {
        $press = $host.ui.rawui.readkey("NoEcho,IncludeKeyDown")
        $vkeycode = $press.virtualkeycode
        write-Host "$($press.character)" -NoNewLine
        If ($vkeycode -eq 38) {$pos--}
        If ($vkeycode -eq 40) {$pos++}
        if ($pos -lt 0) {$pos = 0}
        if ($pos -ge $menuItems.length) {$pos = $menuItems.length -1}
        DrawMenu $menuItems $pos $menuTitle
    }
    Write-Output $($menuItems[$pos])
}

function Uninstall-App {
## Example Usage: Uninstall-App "Dell SupportAssist"
    Write-Host "Uninstalling $($args[0])" -fore Green -back Black
    foreach($obj in Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall") {
        $dname = $obj.GetValue("DisplayName")
        if ($dname -contains $args[0]) {
            $uninstString = $obj.GetValue("UninstallString")
            foreach ($line in $uninstString) {
                $found = $line -match '(\{.+\}).*'
                If ($found) {
                    $appid = $matches[1]
                    Write-Output $appid
                    start-process "msiexec.exe" -arg "/X $appid /qb" -Wait
                }
		else {
		    Write-Host "$dname could not be uninstalled automatically." -fore Green -back Black
		}
            }
        }
	else {
            Write-Host "$($args[0]) was not found for uninstall." -fore Green -back Black
	}
    }
}

function RegSetUser {
    ## Disable start menu suggestions
        reg add "$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /T REG_DWORD /V "SystemPaneSuggestionsEnabled" /D 0 /F
    ## Disable lockscreen suggestions, rotating pictures
        reg add "$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /T REG_DWORD /V "SoftLandingEnabled" /D 0 /F
    ## Disables preinstalled apps; Minecraft, Twitter, etc. - W10 Enterprise only
        reg add "$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /T REG_DWORD /V "PreInstalledAppsEnabled" /D 0 /F
        reg add "$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /T REG_DWORD /V "PreInstalledAppsEverEnabled" /D 0 /F
        reg add "$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /T REG_DWORD /V "OEMPreInstalledAppsEnabled" /D 0 /F
    ## Stops MS from quietly installing apps
        reg add "$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /T REG_DWORD /V "SilentInstalledAppsEnabled" /D 0 /F
        reg add "$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /T REG_DWORD /V "ContentDeliveryAllowed" /D 0 /F
        reg add "$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /T REG_DWORD /V "SubscribedContentEnabled" /D 0 /F
    ## Disable ads in File Explorer
        reg add "$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /T REG_DWORD /V "ShowSyncProviderNotifications" /D 0 /F

    ## Don't let apps share and sync non-explicitly paired wireless devices over uPnP
        reg add "$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\DeviceAccess\Global\LooselyCoupled" /T REG_SZ /V "Value" /D DENY /F
    
    ## Don't ask for feedback
        reg add "$reglocation\SOFTWARE\Microsoft\Siuf\Rules" /T REG_DWORD /V "NumberOfSIUFInPeriod" /D 0 /F
        reg add "$reglocation\SOFTWARE\Microsoft\Siuf\Rules" /T REG_DWORD /V "PeriodInNanoSeconds" /D 0 /F
    
    ## Privacy settings
        reg add "$reglocation\SOFTWARE\Microsoft\Personalization\Settings" /T REG_DWORD /V "AcceptedPrivacyPolicy" /D 0 /F
        reg add "$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Language" /T REG_DWORD /V "Enabled" /D 0 /F
        reg add "$reglocation\SOFTWARE\Microsoft\InputPersonalization" /T REG_DWORD /V "RestrictImplicitTextCollection" /D 1 /F
        reg add "$reglocation\SOFTWARE\Microsoft\InputPersonalization" /T REG_DWORD /V "RestrictImplicitInkCollection" /D 1 /F
        reg add "$reglocation\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" /T REG_DWORD /V "HarvestContacts" /D 0 /F
        reg add "$reglocation\SOFTWARE\Microsoft\Input\TIPC" /T REG_DWORD /V "Enabled" /D 0 /F

    ## Disables "Learn More About This Picture" icon on desktop
        reg add "$reglocation\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /T REG_DWORD /V "{2cc5ca98-6485-489a-920e-b3e88a6ccce3}" /D 1 /F
 
    ## Disable Bing search user settings
        reg add "$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /T REG_DWORD /V "BingSearchEnabled" /D 0 /F
        reg add "$reglocation\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /T REG_DWORD /V "DeviceHistoryEnabled" /D 0 /F
}

function loaddefaulthive {
    ## Loads "Default" user profile
        reg load "$reglocation" c:\users\default\ntuser.dat
}

function unloaddefaulthive {
    ## Unloads "Default" user profile
        [gc]::collect()
        reg unload "$reglocation"
}


#########################
## Begin Menu Sequence ##
#########################

## Reserved space for setting environment variables via menu sequence.
##
## Menu Usage Example: 
## $activatemenu = "No","Yes"
## $activate = Menu $activatemenu "Activate Windows?" -ForegroundColor Cyan -BackgroundColor Black -NoNewline
##
## if ($activate -match "Yes") {
##    Do This
## }


#########################
## Management Settings ##
#########################


## Rename Computer
write-Host "Input new computer name (press enter to skip):" -ForegroundColor Cyan -BackgroundColor Black -NoNewline
write-Host " " -NoNewline
$newComputerName = Read-Host
if ($newComputerName -notlike $env:computername) {
    write-Host "***Renaming computer***" -ForegroundColor Green -BackgroundColor Black
    Rename-Computer -NewName $newComputerName
}
else {
    write-Host "That's already the name of this computer!" -ForegroundColor Green -BackgroundColor Black
    Start-Sleep -S 2
}

## Local admin user definition
write-Host "Input local administrator username:" -ForegroundColor Cyan -BackgroundColor Black -NoNewline
write-Host " " -NoNewline
$Username = Read-Host
write-Host "Please input desired password for local user $Username" -ForegroundColor Cyan -BackgroundColor Black -NoNewline
write-Host ":" -ForegroundColor Cyan -BackgroundColor Black -NoNewline
write-Host " " -NoNewline
$SecurePassword = Read-Host -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
$Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
write-Host "Please confirm password:" -ForegroundColor Cyan -BackgroundColor Black -NoNewline
write-Host " " -NoNewline
$SecurePassword2 = Read-Host -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword2)
$Password2 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
cls
while ($Password -notlike $Password2) {
    write-Host "Those passwords didn't match. Please try again." -ForegroundColor Green -BackgroundColor Black
    write-Host "Please input desired password for local user $Username" -ForegroundColor Cyan -BackgroundColor Black -NoNewline
    write-Host ":" -ForegroundColor Cyan -BackgroundColor Black -NoNewline
    write-Host " " -NoNewline
    $SecurePassword = Read-Host -AsSecureString
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
    $Password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    write-Host "Please confirm password:" -ForegroundColor Cyan -BackgroundColor Black -NoNewline
    write-Host " " -NoNewline
    $SecurePassword2 = Read-Host -AsSecureString
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword2)
    $Password2 = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
    cls
}

## Creates local ISCAdmin and sets password to never expire
$group = "Administrators"
$adsi = [ADSI]"WinNT://$env:COMPUTERNAME"
$existing = $adsi.Children | where {$_.SchemaClassName -eq 'user' -and $_.Name -eq $Username }
if ($existing -eq $null) {
    write-Host "***Creating local user $Username***" -ForegroundColor Green -BackgroundColor Black
    & NET USER $Username $Password /add /y /expires:never

    write-Host "***Adding local user $Username to $group***" -ForegroundColor Green -BackgroundColor Black -NoNewline
    & NET LOCALGROUP $group $Username /add
}
else {
    write-Host "***Setting password for existing local user $Username***" -ForegroundColor Green -BackgroundColor Black
    $existing.SetPassword($Password)
}

write-Host "***Setting password for $Username to never expire***" -ForegroundColor Green -BackgroundColor Black
	Set-LocalUser -Name $Username -PasswordNeverExpires $true

## Sets PC to not auto-reboot on crash
write-Host "***Setting policy for no auto-reboot on BSOD***" -ForegroundColor Green -BackgroundColor Black
	reg add "HKLM\SYSTEM\CurrentControlSet\Control\CrashControl" /t REG_DWORD /v AutoReboot /d 0 /f


#######################
## Explorer Settings ##
#######################


write-Host "***Cutting '- Shortcut' from new shortcuts***" -ForegroundColor Green -BackgroundColor Black
    New-Item -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ -Name NamingTemplates -Force
    New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\NamingTemplates -Name "ShortcutNameTemplate" -PropertyType "String" -Value '%s.lnk'

write-Host "***Showing file extensions and menus in Windows Explorer***" -ForegroundColor Green -BackgroundColor Black
    $key = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    Set-ItemProperty $key HideFileExt 0
    Set-ItemProperty $key ShowMenus 1
    Stop-Process -processname explorer

write-Host "***Changing default Explorer view to 'This PC'***" -ForegroundColor Green -BackgroundColor Black
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Type DWord -Value 1


####################
## Power Settings ##
####################


write-Host "***Disabling hibernate***" -ForegroundColor Green -BackgroundColor Black
    Start-Process 'powercfg.exe' -Verb runAs -ArgumentList '/h off'

write-Host "***Setting Standby/Sleep Timeouts***" -ForegroundColor Green -BackgroundColor Black
    powercfg -change -standby-timeout-ac 0
	powercfg -change -monitor-timeout-ac 15
    powercfg -change -standby-timeout-dc 30
	powercfg -change -monitor-timeout-dc 15

write-Host "***Setting Lid Close Actions***" -ForegroundColor Green -BackgroundColor Black
    $powerSchemeOutput = powercfg /getactivescheme
    $guidMatch = $powerSchemeOutput | Select-String -Pattern 'GUID:\s+([A-F0-9\-]+)'
    if ($guidMatch) {
        $guid = $guidMatch.Matches[0].Groups[1].Value.Trim()
        powercfg /SETACVALUEINDEX $guid SUB_BUTTONS LIDACTION 3
        powercfg /SETDCVALUEINDEX $guid SUB_BUTTONS LIDACTION 1
        powercfg /S $guid
    }
    else {
        write-Host "Failed to extract valid GUID from active power scheme. Lid actions not set." -ForegroundColor Red -BackgroundColor Black
    }

write-Host "***Disabling Fast-Boot***" -ForegroundColor Green -BackgroundColor Black
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /t REG_DWORD /v "HiberbootEnabled" /d 0 /f


##################
## Junk Cleanup ##
##################


## Disable "Consumer features" and silent install of apps
write-Host "***Setting up the advertising dumpster***" -ForegroundColor Green -BackgroundColor Black
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /t REG_DWORD /v "DisableWindowsConsumerFeatures" /d 1 /f #pre-anniversary update
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /t REG_DWORD /v "SilentInstalledAppsEnabled" /d 0 /f #post-anniversary update

## Removes most "junk apps" and prevents all from being installed on new profiles (exclusions listed)
write-Host "***Taking out the trash***" -ForegroundColor Green -BackgroundColor Black
    Get-AppxPackage -AllUsers | where-object {
	    $_.Name -notmatch "ShellExperienceHost|CloudExperienceHost|Search|StartMenuExperienceHost|VCLibs|AppResolverUX|AAD.BrokerPlugin|NET.Native|AccountsControl|CredDialogHost|PrintDialog|CallingShellApp|FilePicker|Apprep.ChxApp|NarratorQuick-Start|XGpuEjectDialog|Store|Dell|HP|Notepad|Terminal|heic|hevc|webp|Camera|Calculator|Photos|SoundRecorder|Paint|Calendar|Winget|QuickAssist|VP9|windowscommunicationsapps"
    } | Remove-AppxPackage -erroraction silentlycontinue
    Get-AppxProvisionedPackage -online | where-object {
	    $_.PackageName -notmatch "ShellExperienceHost|CloudExperienceHost|Search|StartMenuExperienceHost|VCLibs|AppResolverUX|AAD.BrokerPlugin|NET.Native|AccountsControl|CredDialogHost|PrintDialog|CallingShellApp|FilePicker|Apprep.ChxApp|NarratorQuick-Start|XGpuEjectDialog|Store|Dell|HP|Notepad|Terminal|HEIF|heic|hevc|webp|Camera|Calculator|Photos|SoundRecorder|Paint|Calendar|Winget|QuickAssist|VP9|windowscommunicationsapps"
	} | Remove-AppxProvisionedPackage -online -erroraction silentlycontinue

write-Host "***Disabling 'Featured Software'***" -ForegroundColor Green -BackgroundColor Black
    reg add	"HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /T REG_DWORD /V "EnableFeaturedSoftware" /D 0 /F

write-Host "***Disabling Xbox DVR***" -ForegroundColor Green -BackgroundColor Black
    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR")) {
	    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Type DWord -Value 0

write-Host "***Disabling 'Widgets' Feature***" -ForegroundColor Green -BackgroundColor Black
    If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh")) {
	    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" | Out-Null
    }
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests" -Type DWord -Value 0


##################
## System Setup ##
##################


write-Host "***Setting registry for current and default user, and policies for local machine***"  -ForegroundColor Green -BackgroundColor Black
    $reglocation = "HKCU"
    regsetuser
    $reglocation = "HKLM\AllProfile"
    loaddefaulthive; regsetuser; unloaddefaulthive
    $reglocation = $null

write-Host "***Disabling Diagnostics Tracking Services, Xbox Services, Distributed Link Tracking, and WMP Network Sharing***" -ForegroundColor Green -BackgroundColor Black
    Get-Service Diagtrack,DmwApPushService,XblAuthManager,XblGameSave,XboxNetApiSvc,WMPNetworkSvc | stop-service -passthru | set-service -startuptype disabled

write-Host "***Enabling RDP Access***" -ForegroundColor Green -BackgroundColor Black
    set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -Value 0
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
    set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 1 

write-Host "***Setting Time Zone to EST***" -ForegroundColor Green -BackgroundColor Black
    tzutil.exe /s "Eastern Standard Time"
	w32tm /resync /force

write-Host "***Setting Privacy Options***" -ForegroundColor Green -BackgroundColor Black			
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\SmartGlass\UserAuthPolicy" /t REG_DWORD /v "Enabled" /d 0 /f
    reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\System" /t REG_DWORD /v "AllowExperimentation" /d 0 /f
    reg add	"HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" /T REG_DWORD /V "DoNotTrack" /D 1 /F
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /t REG_DWORD /v "Enabled" /d 0 /f
    reg add "HKCU\SOFTWARE\Microsoft\Input\TIPC" /t REG_DWORD /v "Enabled" /d 0  /f
    reg add "HKCU\Control Panel\International\User Profile" /t REG_DWORD /v "HttpAcceptLanguageOptOut" /d 1 /f
    reg add "HKCU\SOFTWARE\Microsoft\Personalization\Settings" /t REG_DWORD /v "AcceptedPrivacyPolicy" /d 0 /f
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Language" /t REG_DWORD /v "Enabled" /d 0 /f
    reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization" /t REG_DWORD /v "RestrictImplicitTextCollection" /d 1 /f
    reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization" /t REG_DWORD /v "RestrictImplicitInkCollection" /d 1 /f
    reg add "HKCU\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" /t REG_DWORD /v "HarvestContacts" /d 0 /f
    reg add "HKCU\SOFTWARE\Microsoft\Siuf\Rules" /t REG_DWORD /v "NumberOfSIUFInPeriod" /d 0 /f

write-Host "***Stopping and Disabling Diagnostics Tracking Services***" -ForegroundColor Green -BackgroundColor Black
    get-service Diagtrack,DmwApPushService,XblAuthManager,XblGameSave,XboxNetApiSvc,TrkWks,WMPNetworkSvc | stop-service -passthru | set-service -startuptype disabled

write-Host "***Disabling Advertising ID***" -ForegroundColor Green -BackgroundColor Black
    If (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo")) {
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" | Out-Null
    }
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 0

write-Host "***Disabling Suggested Apps, Feedback, and Lockscreen Spotlight***" -ForegroundColor Green -BackgroundColor Black
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\" /t REG_DWORD /v "SystemPaneSuggestionsEnabled" /d 0 /f
    reg add "HKCU\Software\Microsoft\CurrentVersion\ContentDeliveryManager\SoftLandingEnabled" /t REG_DWORD /v "SoftLandingEnabled" /d 0 /f
    reg add "HKCU\Software\Microsoft\CurrentVersion\ContentDeliveryManager\" /t REG_DWORD /v "RotatingLockScreenEnable" /d 0 /f

write-Host "***Disabling Delivery Optimization***" -ForegroundColor Green -BackgroundColor Black
    reg add	"HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" /t REG_DWORD /v "DODownloadMode" /d 0 /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /t REG_DWORD /v "DownloadMode" /d 0 /f
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization" /t REG_DWORD /v "SystemSettingsDownloadMode" /d 3 /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" /t REG_DWORD /v "DODownloadMode" /d 0 /f	
    
write-Host "***Disabling Telemetry***" -ForegroundColor Green -BackgroundColor Black
    reg add "HKLM\Software\Policies\Microsoft\Windows\DataCollection" /t REG_DWORD /v "AllowTelemetry" /d 0 /f
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /t REG_DWORD /v "AITEnable" /d 0 /f
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata" /t REG_DWORD /v "PreventDeviceMetadataFromNetwork" /d 1 /f
    reg add "HKLM\SOFTWARE\Policies\Microsoft\MRT" /t REG_DWORD /v "DontOfferThroughWUAU" /d 1 /f
    reg add "HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows" /t REG_DWORD /v "CEIPEnable" /d 0 /f
    reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat" /t REG_DWORD /v "DisableUAR" /d 1 /f

## Enables old F8 boot options
write-Host "***Enabling F8 boot menu options***" -ForegroundColor Green -BackgroundColor Black
    bcdedit /set `{current`} bootmenupolicy Legacy | Out-Null


##########################
## Applications Install ##
##########################

## Installs latest version of WinGet package manager and updates sources
write-Host "***Installing/Updating WinGet***" -ForegroundColor Green -BackgroundColor Black
Invoke-RestMethod -uri https://aka.ms/getwinget -OutFile ".\winget.msixbundle"
Add-AppxPackage -path ".\winget.msixbundle"
Remove-Item -path ".\winget.msixbundle"
winget source update

## Install applications through winget
## Define apps to install with ID, name, and version if applicable
## To add an app to the list, use "winget search appName" or reference https://winget.run
$appsToInstall = @(
    @{ Id = "Microsoft.DotNet.DesktopRuntime.8"; Name = ".NET Desktop Runtime 8"; Version = "8.0.17" },
    @{ Id = "Adobe.Acrobat.Reader.64-bit"; Name = "Adobe Acrobat" },
    @{ Id = "Google.Chrome"; Name = "Google Chrome" },
    @{ Id = "Mozilla.Firefox"; Name = "Mozilla Firefox" },
    @{ Id = "Microsoft.Office"; Name = "Microsoft Office 365" },
    @{ Id = "Piriform.Recuva"; Name = "Piriform Recuva" }
)

## Iterate through apps and install
foreach ($app in $appsToInstall) {
    # Check for any in-progress MSI installs and wait up to 5 minutes to complete if found (mitigates .NET async installer issues)
    try {
        $m = [Threading.Mutex]::OpenExisting("Global\_MSIExecute")
        $null = $m.WaitOne(300000)
        try { $m.ReleaseMutex() } catch {}
        $m.Dispose()
    } catch [Threading.WaitHandleCannotBeOpenedException] {}

    # Begin installation
    write-Host "***Installing $($app.Name)***" -ForegroundColor Green -BackgroundColor Black

    $installArgs = @(
        "install",
        "--id", $app.Id,
        "--silent",
        "--accept-package-agreements",
        "--accept-source-agreements"
    )

    # Add version parameter if specified
    if ($app.Version) {
        $installArgs += "--version", $app.Version
    }

    & winget $installArgs
    Start-Sleep -Seconds 3
}

############################
## Applications Uninstall ##
############################


## Uninstall applications using the "Uninstall-App" function -- Currently non-functional. Commented out for now until the function is reworked.
## Uninstall-App "Dell SupportAssist"


###################
## End of Script ##
###################


write-Host "           _____________                                     " -ForegroundColor Green -BackgroundColor Black
write-Host "          /  _/ __/ ___/                                     " -ForegroundColor Green -BackgroundColor Black
write-Host "         _/ /_\ \/ /__/                                      " -ForegroundColor Green -BackgroundColor Black
write-Host "        /___/___/\___/Business Computer Solutions            " -ForegroundColor Green -BackgroundColor Black
write-Host "                                                             " -ForegroundColor Black -BackgroundColor Black
write-Host "      Don't forget to run updates and install LOB apps       " -ForegroundColor Cyan -BackgroundColor Black
write-Host "      Startup and Recovery options also need to be set.      " -ForegroundColor Cyan -BackgroundColor Black
write-Host "      Please finish any running installations and restart.   " -ForegroundColor Cyan -BackgroundColor Black
write-Host "            *******(Press any key to exit)*******            " -ForegroundColor White -BackgroundColor Black -NoNewline

$key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
sysdm.cpl /,3
Exit
