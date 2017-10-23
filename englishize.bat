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
  cscript //NoLogo ".\Data\_elevate.vbs" "%CD%\" "%CD%\englishize.bat" >nul 2>&1
  REM echo.
	REM echo #  ERROR: Admin rights required.
	REM echo.
	REM pause
	goto :EOF
)
:skipAdminCheck

cls


title Englishize Cmd v1.4a
echo.
echo.
echo                           [ Englishize Cmd v1.4a ]
echo.
echo.
echo #  This script changes command line interface to English.
echo.
echo #  For localized non-English Windows 7/Vista. Most languages are supported.
echo.
echo #  Note 1. A few programs without a .mui aren't affected, e.g. xcopy
echo.
echo         2. _files_to_process.txt can be customized to cover more/less commands
echo.
echo         3. English MUI can be installed through Windows Update or Vistalizator
echo            to support more programs such as GUI Paint.
echo.
echo Press any key to begin . . .
pause >nul

for /f "usebackq" %%i in ("_files_to_process.txt") do (
  @if exist "%systemroot%\System32\en-US\%%i.mui" (
    REM lang code file should not contain english language codes. (cant remove eng cos thats the line.)
    @for /f "usebackq" %%m in ("_lang_codes.txt") do (
      @if exist "%systemroot%\System32\%%m\%%i.mui" (
        takeown /a /f "%systemroot%\System32\%%m\%%i.mui"
        cacls "%systemroot%\System32\%%m\%%i.mui" /E /G administrators:F
        ren "%systemroot%\System32\%%m\%%i.mui" "%%i.mui.disabled"
      )
    )
  )
)

echo.
echo #  Completed. To restore, run restore.bat
echo.
echo Press any key to run test . . .
pause >nul
start "" "%comspec%" /k "help&echo.&echo #  Successful if the above is displayed in English.&echo.&pause"
