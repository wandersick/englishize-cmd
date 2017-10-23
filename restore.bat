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

cls
title Englishize Cmd v1.3 - by wanderSick.blogspot.com
echo.
echo.
echo                           [ Englishize Cmd v1.3 ]
echo.
echo.
echo #  This script restores the command line interface back to original
echo.
echo Press any key to begin . . .
pause >nul



for /f "usebackq" %%i in ("_files_to_process.txt") do (
  @for /f "usebackq" %%m in ("_lang_codes.txt") do (
    @if exist "%systemroot%\System32\%%m\%%i.mui.disabled" (
      ren "%systemroot%\System32\%%m\%%i.mui.disabled" "%%i.mui"
    )
  )
)


echo.
echo #  Completed.
echo.
echo Press any key to run test . . .
pause >nul
start "" "%comspec%" /k "help&echo.&echo #  Successful if the above is displayed in the original language.&echo.&echo #  Note it may not reflect now if the restorer was run elevated.&echo.&pause"
