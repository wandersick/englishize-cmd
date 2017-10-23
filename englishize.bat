@echo off

:: detect if system supports "attrib"
attrib >nul 2>&1
if "%errorlevel%"=="9009" set noAttrib=1

:: detect for admin rights
if defined noAttrib goto :skipAdminCheck
attrib -h "%windir%\system32" | find /i "system32" >nul 2>&1
if %errorlevel% EQU 0 (
  echo.
	echo :: ERROR: Admin rights required.
	echo.
	pause
	goto :EOF
)
:skipAdminCheck

cls



title Englishize Cmd v1.1 - by wanderSick.blogspot.com
echo.
echo.
echo                           [ Englishize Cmd v1.1 ]
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
start "" "%comspec%" /k "help&echo.&echo #  Successful if the above is displayed in English&echo.&pause"
