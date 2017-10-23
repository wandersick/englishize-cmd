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
start "" "%comspec%" /k "help&echo.&echo #  Successful if the above is displayed in the original language&echo.&pause"
