; Package an application (e.g. EnglishizeCmd) in 7-Zip SFX, self-extracting archive (FYI: the EnglishizeCmd download already comes with an SFX)
; Place it in the location specified below, e.g. C:\az-autohotkey-silent-setup\EnglishizeCmd_7-Zip_SFX.exe
FileInstall, C:\az-autohotkey-silent-setup\EnglishizeCmd_7-Zip_SFX.exe, %A_ScriptDir%\EnglishizeCmd_7-Zip_SFX.exe, 1

; Silently extract EnglishizeCmd from the SFX file into the current directory
RunWait, %A_ScriptDir%\EnglishizeCmd_7-Zip_SFX.exe -o"%A_ScriptDir%" -y

; Run silent setup command: Setup.exe /programfiles /unattendaz=1
; For EnglishizeCmd, this command will install EnglishizeCmd to All Users (/programfiles) and silently (/unattendedaz=1)
; as well as uninstalling in case an EnglishizeCmd copy is found in the target location (built into the logic of Setup.exe of EnglishizeCmd)
RunWait, %A_ScriptDir%\EnglishizeCmd\Setup.exe /programfiles /unattendaz=1

; Clean up temporary files used during setup shortly after setup finishes installation
Sleep, 100
FileDelete, %A_ScriptDir%\EnglishizeCmd_7-Zip_SFX.exe
FileRemoveDir, %A_ScriptDir%\EnglishizeCmd, 1
