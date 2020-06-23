Before compiling Setup.exe and EnglishizeCmd_Unattended_Installer.exe, move all files within this folder (except Readme.txt) to one level above it, i.e. in the same directory as EnglishizeCmd.bat

EnglishizeCmd_7-Zip_SFX.exe should be prepared first

For details, refer to https://medium.com/wandersick/how-to-create-a-silent-installer-with-autohotkey-and-publish-it-on-chocolatey-8e3a9cf6da70

1. Setup.exe

- The compiled Setup.exe should be stored in the same directory as EnglishizeCmd.bat in order for it to execute successfully

2. EnglishizeCmd_Unattended_Installer.exe

- There is no dependency on other files. This is a standalone installer that can install EnglishizeCmd from beginning to end
