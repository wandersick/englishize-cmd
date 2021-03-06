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

:: UAC check
reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA | find /i "0x1">nul 2>&1
if %errorlevel% EQU 0 set UACenabled=1

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

:: set the EnglishizeDir working directory where Englishize Cmd is by %~d0%~p0 (e.g. x:\...\englishize-cmd)
set EnglishizeDir=%~d0%~p0

:: detect admin rights
if defined noAttrib goto :skipAdminCheck
attrib -h "%windir%\system32" | find /i "system32" >nul 2>&1
if %errorlevel% EQU 0 (
	REM only when no parameter is specified should the script be elevated, as any supplied parameters cannot be carried across
	if /i "%~1" NEQ "/quiet" (
		REM only when UAC is enabled can this script be elevated. Otherwise, non-stop prompting will occur.
		if "%UACenabled%" EQU "1" (
			cscript //NoLogo "%EnglishizeDir%Data\_elevate.vbs" "%EnglishizeDir%" "%EnglishizeDir%\EnglishizeCmd.bat" >nul 2>&1
			goto :EOF
		)
	) else (
		REM /quiet requires having admin rights in advance
		echo.
		echo ** Englishize Cmd requires admin rights in advance for /quiet. Please run Command Prompt as admin.
		echo.
		pause
		goto :EOF
	)
)
:skipAdminCheck

:: acquire admin group account name

for /f "usebackq tokens=* delims=" %%i in (`cscript //NoLogo "%EnglishizeDir%\Data\_determine_admin_group_name.vbs"`) do set adminGroupName=%%i

cls


title Englishize Cmd by wandersick v2.0
echo.
echo.
echo                            [ Englishize Cmd v2.0 ]
echo.
echo.
echo #  This script changes command-line interface to English.
echo.
echo #  Designed for localized non-English Windows Vista ^(Server 2008^) or above. Any languages.
echo.
echo #  Note 1. A few programs without a .mui aren't affected, e.g. xcopy
echo.
echo         2. _files_to_process.txt can be customized to cover more/fewer commands
echo.
echo         3. English MUI can be installed through Windows Update or Vistalizator
echo            to support GUI programs such as Paint.
echo.
echo         4. /quiet ^(optional^) can be specified to run Englishize Cmd in an unattended way
echo.
if /i "%~1" NEQ "/quiet" (
  echo Press any key to begin . . .
  pause >nul
)

:: the below only runs if current system is x64
:: it covers mui files under %windir%\SysWoW64 used by 32bit cmd.exe (%windir%\SysWoW64\cmd.exe)

if not defined ProgramFiles(x86) goto :notX64

for /f "usebackq" %%i in ("%EnglishizeDir%\_files_to_process.txt") do (
  @if exist "%systemroot%\SysWoW64\en-US\%%i.mui" (
    REM lang code file should not contain english language codes. (cant remove eng cos thats the line.)
    @for /f "usebackq" %%m in ("%EnglishizeDir%\_lang_codes.txt") do (
      @if exist "%systemroot%\SysWoW64\%%m\%%i.mui" (
        takeown /a /f "%systemroot%\SysWoW64\%%m\%%i.mui"
        cacls "%systemroot%\SysWoW64\%%m\%%i.mui" /E /G "%adminGroupName%":F
        ren "%systemroot%\SysWoW64\%%m\%%i.mui" "%%i.mui.disabled"
      )
    )
  )
)

:notX64

for /f "usebackq" %%i in ("%EnglishizeDir%\_files_to_process.txt") do (
  @if exist "%systemroot%\System32\en-US\%%i.mui" (
    REM lang code file should not contain english language codes. (cant remove eng cos thats the line.)
    @for /f "usebackq" %%m in ("%EnglishizeDir%\_lang_codes.txt") do (
      @if exist "%systemroot%\System32\%%m\%%i.mui" (
        takeown /a /f "%systemroot%\System32\%%m\%%i.mui"
        cacls "%systemroot%\System32\%%m\%%i.mui" /E /G "%adminGroupName%":F
        ren "%systemroot%\System32\%%m\%%i.mui" "%%i.mui.disabled"
      )
    )
  )
)


echo.
echo #  Completed. To restore, run RestoreCmd.bat
echo.

if /i "%~1" NEQ "/quiet" (
  echo Press any key to run test . . .
  pause >nul
  start "" "%comspec%" /c "help&echo.&echo #  Successful if the above is displayed in English.&echo.&echo #  Note: This window will close automatically in 10 seconds.&echo.&ping 127.0.0.1 -n 10 >nul 2>&1"
) else (
  start "" "%comspec%" /c "help&echo.&echo #  Successful if the above is displayed in English.&echo.&echo #  Note: This window will close automatically in 10 seconds.&echo.&ping 127.0.0.1 -n 10 >nul 2>&1"
)

cls
echo.
echo    Thanks for using Englishize Cmd :^)
echo.
echo    Support by visiting or buying coffee at tech.wandersick.com
echo.
ping 127.0.0.1 -n 2 >nul 2>&1
if /i "%~1" NEQ "/quiet" pause