@echo off
for /f "usebackq tokens=* delims=" %%i in (`cscript //NoLogo ".\Data\_determine_admin_group_name.vbs"`) do set lala=%%i
echo lala = "%lala%"
pause