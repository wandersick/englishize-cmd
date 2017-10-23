@echo off

:: detech win ver
for /f "usebackq tokens=3 skip=2" %%i in (`reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentVersion`) do (
  @if %%i LSS 6.0 (
      echo.
      echo #  ERROR: Englishize Cmd only supports Windows Vista or later.
      echo.
      pause
      goto :EOF
    )
)

:: detect if system has WSH disabled unsigned scripts
:: if useWINSAFER = 1, the TrustPolicy below is ignored and use SRP for this option instead. So check if = 0.
:: if TrustPolicy = 0, allow both signed and unsigned; if = 1, warn on unsigned; if = 2, disallow unsigned.
for /f "usebackq tokens=3 skip=2" %%a in (`reg query "HKLM\SOFTWARE\Microsoft\Windows Script Host\Settings" /v UseWINSAFER 2^>nul`) do (
	@if "%%a" EQU "0" (
		@for /f "usebackq tokens=3 skip=2" %%i in (`reg query "HKLM\SOFTWARE\Microsoft\Windows Script Host\Settings" /v TrustPolicy 2^>nul`) do (
			@if "%%i" GEQ "2" (
				set noWSH=1
			)
		)
	)
)

if defined noWSH (
	echo.
	echo #  ERROR: Windows Scripting Host is disabled.
	echo.
	pause
	goto :EOF
)

:: detect if system supports "attrib"
attrib >nul 2>&1
if "%errorlevel%"=="9009" set noAttrib=1

:: detect for admin rights
if defined noAttrib goto :skipAdminCheck
attrib -h "%windir%\system32" | find /i "system32" >nul 2>&1
if %errorlevel% EQU 0 (
  cscript //NoLogo ".\Data\_elevate.vbs" "%CD%\" "%CD%\restore.bat" >nul 2>&1
  REM echo.
	REM echo #  ERROR: Admin rights required.
	REM echo.
	REM pause
	goto :EOF
)
:skipAdminCheck

:: acquire admin group account name

for /f "usebackq tokens=* delims=" %%i in (`cscript //NoLogo ".\Data\_determine_admin_group_name.vbs"`) do set adminGroupName=%%i


cls
title Englishize Cmd v1.6a
echo.
echo.
echo                            [ Englishize Cmd v1.6a ]
echo.
echo.
echo #  This script restores the command line interface back to original
echo.
echo Press any key to begin . . .
pause >nul

:: the below covers mui files under %windir%\SysWoW64 used by 32bit cmd.exe (%windir%\SysWoW64\cmd.exe)

for /f "usebackq" %%i in ("_files_to_process.txt") do (
  @for /f "usebackq" %%m in ("_lang_codes.txt") do (
	REM restores original permissions and ownership - icacls is used as cacls cannot replace F permissions with RX and disable inheritance
	REM due to redirection, one of these pairs are unrequired, but they are left here anyway to ensure all things in system32 and syswow64 are covered even without redirection
	if exist "%systemroot%\System32\%%m\%%i.mui.disabled" (
		ren "%systemroot%\System32\%%m\%%i.mui.disabled" "%%i.mui"
		if exist "%systemroot%\SysWoW64\%%m\%%i.mui.disabled" @ren "%systemroot%\SysWoW64\%%m\%%i.mui.disabled" "%%i.mui"
		icacls "%systemroot%\System32\%%m\%%i.mui" /setowner "NT Service\TrustedInstaller" /C 
		REM the below output is probably an error, hence muted to avoid confusion as redirection probably handled it
		if exist "%systemroot%\SysWoW64\%%m\%%i.mui" @icacls "%systemroot%\SysWoW64\%%m\%%i.mui" /setowner "NT Service\TrustedInstaller" /C >nul 2>&1
		icacls "%systemroot%\System32\%%m\%%i.mui" /grant:r "%adminGroupName%":^(RX^) /inheritance:d
		if exist "%systemroot%\SysWoW64\%%m\%%i.mui" @icacls "%systemroot%\SysWoW64\%%m\%%i.mui" /grant:r "%adminGroupName%":^(RX^) /inheritance:d >nul 2>&1
	)
	if exist "%systemroot%\SysWoW64\%%m\%%i.mui.disabled" (
		ren "%systemroot%\SysWoW64\%%m\%%i.mui.disabled" "%%i.mui"
		if exist "%systemroot%\System32\%%m\%%i.mui.disabled" @ren "%systemroot%\System32\%%m\%%i.mui.disabled" "%%i.mui"
		icacls "%systemroot%\SysWoW64\%%m\%%i.mui" /setowner "NT Service\TrustedInstaller" /C 
		if exist "%systemroot%\System32\%%m\%%i.mui" @icacls "%systemroot%\System32\%%m\%%i.mui" /setowner "NT Service\TrustedInstaller" /C >nul 2>&1
		icacls "%systemroot%\SysWoW64\%%m\%%i.mui" /grant:r "%adminGroupName%":^(RX^) /inheritance:d
		if exist "%systemroot%\System32\%%m\%%i.mui" @icacls "%systemroot%\System32\%%m\%%i.mui" /grant:r "%adminGroupName%":^(RX^) /inheritance:d >nul 2>&1
	)
  )
)

echo.
echo #  Completed.
echo.
echo Press any key to run test . . .
pause >nul
start "" "%comspec%" /k "help&echo.&echo #  Successful if the above is displayed in the original language.&echo.&echo #  Note it may not reflect now if the restorer was run elevated.&echo.&pause"
