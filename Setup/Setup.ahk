; (c) Copyright 2009-2020 EnglishizeCmd installer by wandersick (originally AeroZoom installer) | https://tech.wandersick.com

; Return Codes:
;
; 0: Successful [un]installation
; 1: User cancelled
; 2: Installation failed
; 3: EnglishizeCmd is running and cannot be terminated. Uninstallation cancelled
; 4: Component check failed
; 5: Show help message

; Parameters:
;
; /programfiles
;     for installing into `C:\Program Files (x86)` (or `C:\Program Files` for 32-bit OS) instead of current user profile
;
; /unattendAZ=1
;     for an unattended installation
;     If it detects EnglishizeCmd is already installed, the setup will perform an uninstallation instead
;
; /unattendAZ=2 or any other values
;     an uninstallation dialog box will also be prompted

#SingleInstance Force
#NoTrayIcon

verAZ = 2.0
	
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Missing component check
IfNotExist, %A_WorkingDir%\Data
{
	Msgbox, 262192, EnglishizeCmd, Missing essential components.`n`nPlease download the legitimate version from tech.wandersick.com.
	ExitApp, 4
}

targetDir=%localappdata%
If %1% {
	Loop, %0%  ; For each parameter
	{
		param := %A_Index%  ; Retrieve A_Index variable contents
		If (param="/unattendAZ=1")
			unattendAZ=1
		Else if (param="/unattendAZ=2")
			unattendAZ=2
		Else if (param="/programfiles")
		{
			targetDir=%programfiles%
			setupAllUsers=1
		}
		Else
		{
			Msgbox, 262192, EnglishizeCmd Setup, Supported parameters:`n`n - Unattended setup : /unattendAZ=1`n - Install for all users : /programfiles`n`nFor example: Setup.exe /programfiles /unattendaz=1`n`nNote:`n - If setup finds a copy in the target location, uninstallation will be carried out instead.`n - If you install into Program Files folder, be sure you're running it with administrator rights.
			ExitApp, 5
		}
	}
}

; Check path to _choiceMulti.bat
IfExist, %A_WorkingDir%\Data\_choiceMulti.bat
	TaskPath=%A_WorkingDir%

; Install / Uninstall
regKey=SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\EnglishizeCmd
IfNotExist, %targetDir%\wandersick\EnglishizeCmd\Englishize.bat
{
	IfNotEqual, unattendAZ, 1
	{
		MsgBox, 262180, EnglishizeCmd Installer , Install EnglishizeCmd in the following location?`n`n%targetDir%\wandersick\EnglishizeCmd`n`nNote:`n - For portable use, just run Englishize.bat. Setup is unneeded.`n - To install silently or to all users, run Setup.exe /? to see how.`n - To remove a copy that was installed to all users, run Setup.exe /programfiles
		IfMsgBox No
		{
			ExitApp, 1
		}
	}
	; Terminate running EnglishizeCmd executables
	Gosub, KillProcess
	; Remove existing directory
	FileRemoveDir, %targetDir%\wandersick\EnglishizeCmd\Image, 1
	FileRemoveDir, %targetDir%\wandersick\EnglishizeCmd\.github, 1
	FileRemoveDir, %targetDir%\wandersick\EnglishizeCmd\Setup, 1
	FileRemoveDir, %targetDir%\wandersick\EnglishizeCmd\Data, 1
	FileRemoveDir, %targetDir%\wandersick\EnglishizeCmd, 1
	; Copy EnglishizeCmd to %targetDir%
	FileCreateDir, %targetDir%\wandersick\EnglishizeCmd
	FileCopyDir, %A_WorkingDir%, %targetDir%\wandersick\EnglishizeCmd, 1
	; For running 'EnglishizeCmd' in Run prompt
	if A_IsAdmin ; unnecessary
	{
		; Limitation: Run prompt does not have a current-user way, so both types of installation (current-user/all-users) would write to the same registry area
		RegWrite, REG_SZ, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\EnglishizeCmd.exe,, %targetDir%\wandersick\EnglishizeCmd\Englishize.bat
	}
	
	; For setting system-wide PATH environmental variable so that 'EnglishizeCmd' can be run in Command Prompt or PowerShell
	if setupAllUsers
	{
		; EnvGet, envVarPath, Path
		RegRead, envVarPath, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment, Path
		envVarPathNew = %envVarPath%;%targetDir%\wandersick\EnglishizeCmd\
		RegWrite, REG_EXPAND_SZ, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment, Path, %envVarPathNew%
		Sleep, 1000
		; Broadcast WM_SETTINGCHANGE message for the updated PATH to take effect
		EnvUpdate
	} else {
		; EnvGet, envVarPath, Path
		RegRead, envVarPath, HKEY_CURRENT_USER\Environment, Path
		envVarPathNew = %envVarPath%;%targetDir%\wandersick\EnglishizeCmd\
		RegWrite, REG_SZ, HKEY_CURRENT_USER\Environment, Path, %envVarPathNew%
		Sleep, 1000
		; Broadcast WM_SETTINGCHANGE message for the updated PATH to take effect
		EnvUpdate
	}

	IfExist, %targetDir%\wandersick\EnglishizeCmd\Englishize.bat
	{
		; Create shortcut to Start Menu (All Users)
		If setupAllUsers
		{
			FileCreateShortcut, %targetDir%\wandersick\EnglishizeCmd\Englishize.bat, %A_ProgramsCommon%\EnglishizeCmd.lnk, %targetDir%\wandersick\EnglishizeCmd\,, Englishize command-line tools with a click,%targetDir%\wandersick\EnglishizeCmd\Data\EnglishizeCmd-icon.ico,
			FileCreateShortcut, %targetDir%\wandersick\EnglishizeCmd\Englishize.bat, %A_DesktopCommon%\EnglishizeCmd.lnk, %targetDir%\wandersick\EnglishizeCmd\,, Englishize command-line tools with a click,%targetDir%\wandersick\EnglishizeCmd\Data\EnglishizeCmd-icon.ico,
		}
		; Create shortcut to Start Menu (Current User)
		Else
		{
			FileCreateShortcut, %targetDir%\wandersick\EnglishizeCmd\Englishize.bat, %A_Programs%\EnglishizeCmd.lnk, %targetDir%\wandersick\EnglishizeCmd\,, Englishize command-line tools with a click,%targetDir%\wandersick\EnglishizeCmd\Data\EnglishizeCmd-icon.ico,
			FileCreateShortcut, %targetDir%\wandersick\EnglishizeCmd\Englishize.bat, %A_Desktop%\EnglishizeCmd.lnk, %targetDir%\wandersick\EnglishizeCmd\,, Englishize command-line tools with a click,%targetDir%\wandersick\EnglishizeCmd\Data\EnglishizeCmd-icon.ico,
		}
	}
	IfExist, %targetDir%\wandersick\EnglishizeCmd\Restore.bat
	{
		; Create shortcut to Start Menu (All Users)
		If setupAllUsers
		{
			FileCreateShortcut, %targetDir%\wandersick\EnglishizeCmd\Restore.bat, %A_ProgramsCommon%\RestoreCmd.lnk, %targetDir%\wandersick\EnglishizeCmd\,, Restore Englishized command-line tools to original language,%targetDir%\wandersick\EnglishizeCmd\Data\RestoreCmd-icon.ico,
			FileCreateShortcut, %targetDir%\wandersick\EnglishizeCmd\Restore.bat, %A_DesktopCommon%\RestoreCmd.lnk, %targetDir%\wandersick\EnglishizeCmd\,, Restore Englishized command-line tools to original language,%targetDir%\wandersick\EnglishizeCmd\Data\RestoreCmd-icon.ico,
		}
		; Create shortcut to Start Menu (Current User)
		Else
		{
			FileCreateShortcut, %targetDir%\wandersick\EnglishizeCmd\Restore.bat, %A_Programs%\RestoreCmd.lnk, %targetDir%\wandersick\EnglishizeCmd\,, Restore Englishized command-line tools to original language,%targetDir%\wandersick\EnglishizeCmd\Data\RestoreCmd-icon.ico,
			FileCreateShortcut, %targetDir%\wandersick\EnglishizeCmd\Restore.bat, %A_Desktop%\RestoreCmd.lnk, %targetDir%\wandersick\EnglishizeCmd\,, Restore Englishized command-line tools to original language,%targetDir%\wandersick\EnglishizeCmd\Data\RestoreCmd-icon.ico,
		}
	}
	; if a shortcut is in startup, re-create it to ensure its not linked to the portable version's path
	IfExist, %A_Startup%\*EnglishizeCmd*.*
	{
		FileSetAttrib, -R, %A_Startup%\*EnglishizeCmd*.*
		FileDelete, %A_Startup%\*EnglishizeCmd*.*
	}
	if A_IsAdmin
	{
		IfExist, %A_StartupCommon%\*EnglishizeCmd*.* ; this is unnecessary as EnglishizeCmd wont put shortcuts in all users startup but it will be checked too 
		{
			FileSetAttrib, -R, %A_StartupCommon%\*EnglishizeCmd*.*
			FileDelete, %A_StartupCommon%\*EnglishizeCmd*.*
		}
	}

	; Write uninstallation entries to registry 
	; Icon from Crystal Clear icon set (utilities-run.ico and utilities-session_properties.ico) by artist Everaldo Coelho licensed under GNU LGPL
	RegWrite, REG_SZ, HKEY_CURRENT_USER, %regKey%, DisplayIcon, %targetDir%\wandersick\EnglishizeCmd\Data\EnglishizeCmd-icon.ico,0
	RegWrite, REG_SZ, HKEY_CURRENT_USER, %regKey%, DisplayName, EnglishizeCmd %verAZ%
	RegWrite, REG_SZ, HKEY_CURRENT_USER, %regKey%, InstallDate, %A_YYYY%%A_MM%%A_DD%
	RegWrite, REG_SZ, HKEY_CURRENT_USER, %regKey%, HelpLink, https://tech.wandersick.com
	RegWrite, REG_SZ, HKEY_CURRENT_USER, %regKey%, URLInfoAbout, https://tech.wandersick.com
	
	; ******************************************************************************************
	
	If setupAllUsers ; if EnglishizeCmd was installed for all users
		RegWrite, REG_SZ, HKEY_CURRENT_USER, %regKey%, UninstallString, %targetDir%\wandersick\EnglishizeCmd\setup.exe /unattendAZ=2 /programfiles
	Else ; if EnglishizeCmd was installed for current user
		RegWrite, REG_SZ, HKEY_CURRENT_USER, %regKey%, UninstallString, %targetDir%\wandersick\EnglishizeCmd\setup.exe /unattendAZ=2
	RegWrite, REG_SZ, HKEY_CURRENT_USER, %regKey%, InstallLocation, %targetDir%\wandersick\EnglishizeCmd
	RegWrite, REG_SZ, HKEY_CURRENT_USER, %regKey%, DisplayVersion, %verAZ%
	RegWrite, REG_SZ, HKEY_CURRENT_USER, %regKey%, Publisher, a wandersick
	
	; Calculate folder size
	EstimatedSize = 0
	Loop, %targetDir%\wandersick\EnglishizeCmd\*.*, , 1
	EstimatedSize += %A_LoopFileSize%
	EstimatedSize /= 1024
	RegWrite, REG_DWORD, HKEY_CURRENT_USER, %regKey%, EstimatedSize, %EstimatedSize%
	IfExist, %targetDir%\wandersick\EnglishizeCmd\Englishize.bat
	{
		IfEqual, unattendAZ, 1
		{
			ExitApp, 0
		}	
		Msgbox, 262144, EnglishizeCmd, Successfully installed.`n`nAccess the uninstaller in 'Control Panel\Programs and Features' or run Setup.exe again. ; 262144 = Always on top
	} else {
		IfEqual, unattendAZ, 1
		{
			ExitApp, 2
		}
		Msgbox, 262192, EnglishizeCmd, Installation failed.`n`nPlease ensure this folder is accessible:`n`n%targetDir%\wandersick\EnglishizeCmd
	}
} else {
	; if unattend switch is on, skip the check since user must be running the uninstaller from control panel
	; not from EnglishizeCmd program
	IfNotEqual, unattendAZ, 1
	{
		MsgBox, 262180, EnglishizeCmd Uninstaller , Uninstall EnglishizeCmd and delete its perferences from the following location?`n`n%targetDir%\wandersick\EnglishizeCmd
		IfMsgBox No
		{
			ExitApp, 1
		}
	}
	; Terminate running EnglishizeCmd executables
	Gosub, KillProcess
	IfNotEqual, unattendAZ, 1
	{
		Msgbox, 262208, In case EnglishizeCmd is running..., Please make sure EnglishizeCmd has exited before uninstalling
	}
	; ExitApp, 3
	; Begin uninstalling
	; Remove startup shortcuts
	IfExist, %A_Startup%\*EnglishizeCmd*.*
	{
		FileSetAttrib, -R, %A_Startup%\*EnglishizeCmd*.*
		FileDelete, %A_Startup%\*EnglishizeCmd*.*
	}
	if A_IsAdmin ; Unnecessary as stated above
	{
		IfExist, %A_StartupCommon%\*EnglishizeCmd*.*
		{
			FileSetAttrib, -R, %A_StartupCommon%\*EnglishizeCmd*.*
			FileDelete, %A_StartupCommon%\*EnglishizeCmd*.*
		}
	}

	; Remove registry keys
	RegDelete, HKEY_CURRENT_USER, %regKey%
	RegDelete, HKEY_CURRENT_USER, Software\wandersick\EnglishizeCmd

	; For removing the ability to run 'EnglishizeCmd' in Run prompt
	if A_IsAdmin ; Unnecessary
	{
		RegDelete, HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\EnglishizeCmd.exe
	}

	; For removing 'EnglishizeCmd' from environmental variable including a semicolon
	if setupAllUsers
	{
		targetDirToRemove1=;%targetDir%\wandersick\EnglishizeCmd\
		targetDirToRemove2=;%targetDir%\wandersick\EnglishizeCmd
		; In case this is at the top of the PATH list
		targetDirToRemove3=%targetDir%\wandersick\EnglishizeCmd\;
		targetDirToRemove4=%targetDir%\wandersick\EnglishizeCmd;
		; EnvGet, envVarPath, Path
		RegRead, envVarPath, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment, Path
		envVarPathNewTemp1 := StrReplace(envVarPath, targetDirToRemove1)
		envVarPathNewTemp2 := StrReplace(envVarPathNewTemp1, targetDirToRemove2)
		envVarPathNewTemp3 := StrReplace(envVarPathNewTemp2, targetDirToRemove3)
		envVarPathNew := StrReplace(envVarPathNewTemp3, targetDirToRemove4)
		RegWrite, REG_EXPAND_SZ, HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment, Path, %envVarPathNew%
		Sleep, 1000
		; Broadcast WM_SETTINGCHANGE message for the updated PATH to take effect
		EnvUpdate
	} else {
		targetDirToRemove1=;%targetDir%\wandersick\EnglishizeCmd\
		targetDirToRemove2=;%targetDir%\wandersick\EnglishizeCmd
		; In case this is at the top of the PATH list
		targetDirToRemove3=%targetDir%\wandersick\EnglishizeCmd\;
		targetDirToRemove4=%targetDir%\wandersick\EnglishizeCmd;
		; EnvGet, envVarPath, Path
		RegRead, envVarPath, HKEY_CURRENT_USER\Environment, Path
		envVarPathNewTemp1 := StrReplace(envVarPath, targetDirToRemove1)
		envVarPathNewTemp2 := StrReplace(envVarPathNewTemp1, targetDirToRemove2)
		envVarPathNewTemp3 := StrReplace(envVarPathNewTemp2, targetDirToRemove3)
		envVarPathNew := StrReplace(envVarPathNewTemp3, targetDirToRemove4)
		RegWrite, REG_SZ, HKEY_CURRENT_USER\Environment, Path, %envVarPathNew%
		Sleep, 1000
		; Broadcast WM_SETTINGCHANGE message for the updated PATH to take effect
		EnvUpdate
	}

	;FileMove, %targetDir%\wandersick\EnglishizeCmd\Data\uninstall.bat, %temp%, 1 ; prevent deletion of this as it will be used
	FileSetAttrib, -R, %A_Programs%\EnglishizeCmd.lnk 
	FileSetAttrib, -R, %A_Programs%\RestoreCmd.lnk 
	FileDelete, %A_Programs%\EnglishizeCmd.lnk ; normally this is the only shortcut that has to be deleted
	FileDelete, %A_Programs%\RestoreCmd.lnk
	FileSetAttrib, -R, %A_ProgramsCommon%\EnglishizeCmd.lnk
	FileSetAttrib, -R, %A_ProgramsCommon%\RestoreCmd.lnk
	FileDelete, %A_ProgramsCommon%\EnglishizeCmd.lnk
	FileDelete, %A_ProgramsCommon%\RestoreCmd.lnk
	FileSetAttrib, -R, %A_Desktop%\EnglishizeCmd.lnk
	FileSetAttrib, -R, %A_Desktop%\RestoreCmd.lnk
	FileDelete, %A_Desktop%\EnglishizeCmd.lnk
	FileDelete, %A_Desktop%\RestoreCmd.lnk
	FileSetAttrib, -R, %A_DesktopCommon%\EnglishizeCmd.lnk
	FileSetAttrib, -R, %A_DesktopCommon%\RestoreCmd.lnk
	FileDelete, %A_DesktopCommon%\EnglishizeCmd.lnk
	FileDelete, %A_DesktopCommon%\RestoreCmd.lnk
	FileSetAttrib, -R, %targetDir%\wandersick\EnglishizeCmd\*.*
	FileRemoveDir, %targetDir%\wandersick\EnglishizeCmd\Data, 1
	FileRemoveDir, %targetDir%\wandersick\EnglishizeCmd\.github, 1
	FileRemoveDir, %targetDir%\wandersick\EnglishizeCmd\Setup, 1
	FileRemoveDir, %targetDir%\wandersick\EnglishizeCmd, 1

	IfNotEqual, unattendAZ, 1
	{
		Msgbox, 262144, EnglishizeCmd, Successfully uninstalled`n`nSetup will now delete itself in 3 seconds,3
	}
	; Remove directory content including Setup.exe that is currently running after 3 seconds using ping in a minimized Command Prompt
	Run, cmd /c start /min ping 127.0.0.1 -n 3 >nul & rd /s /q "%targetDir%\wandersick\EnglishizeCmd"
}

ExitApp, 0
return

KillProcess: ; may not work for RunAsInvoker for Administrators accounts with UAC on. RunAsHighest will solve that, while letting Standard user accounts install to the correct profile.
; Closing cmd.exe may affect uninstaller, although it could be in use by EnglishizeCmd. User has to make sure EnglishizeCmd has exited before uninstalling
; Process, Close, cmd.exe
return

