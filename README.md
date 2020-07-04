# Englishize Cmd – Change Non-English Command Line Interface to English Fast

There often comes a need to use built-in command-line tools in English in non-English Windows, as they are localized to another language which can be difficult for admins who only speak English. &#39;Englishize Cmd&#39; employs a different technique to &#39;englishize&#39; CLI tools with a click.

 ![](https://farm5.static.flickr.com/4041/4481192203_2374fa34da_o.png "Bilingual command prompt: Upper has Englishize Cmd applied (changed to English); lower has it restored (to original language).")

**Figure 1.** Bilingual command prompt: Upper has Englishize Cmd applied (changed to English); lower has it restored (to original language).

**[2019-05-13] Update:** As reported by a German user (thanks), some en-US files (e.g. ipconfig.exe.mui) are not included in the German release of Windows 10 since 1809. This doesn't seem to affect other countries or regions. For details and workarounds, refer to <a href="https://tech.wandersick.com/p/change-non-english-command-line.html?showComment=1557634972460#c6596996191145251864" target="_blank">this comment</a>.

## List of Features

1. Toggles between English and non-English for many Windows commands
2. For English system admins who manages Windows PCs of other languages
3. No need to log off; settings are applied immediately
4. Comes with a restorer. Apply or restore is as simple as a click or typing `EnglishizeCmd` and `RestoreCmd` commands
5. Better character compatibility than changing DOS codepage
6. Many languages and executables are supported. Customizable
7. Ensure the outputs which your scripts catch are always in English
8. Administrator rights are required. It asks for rights to elevates itself (Does not elevate over network mapped drives)
9. Supports from Windows Vista/7 to 10 (or Windows Server 2008 to 2019)
10. Portable by default. Optional installer enables `EnglishizeCmd` and `RestoreCmd` commands globally (in Command Prompt and Run prompt. For PowerShell, the commands would be `EnglishizeCmd.bat` and `RestoreCmd.bat`)

## Background

Occasionally, there comes a need to use built-in command-line tools in English in non-English Windows, as they are localized to another language which can be difficult to use for system administrators who only speak English. There are a number of workarounds focusing around entering "chcp 437", which is the English codepage, prior to running a command. Or, creating a shortcut to cmd.exe and setting in its properties the "Current Codepage" setting to 437.

 ![](https://farm5.static.flickr.com/4009/4481192207_1788a2deeb_o.png "437 = English codepage")

**Figure 2.** 437 = English codepage

Unfortunately, both methods could make non-English characters non-displayable (becoming questions marks ???? as shown in the picture below). In addition, the former method requires typing "chcp 437" every time (although it can be configured to automatically do so in "HKLM\SOFTWARE\Microsoft\Command Processor\AutoRun" registry key), while the latter is limited to shortcuts. So I thought it would be useful to share this method which employs a different technique.

 ![](https://farm5.static.flickr.com/4049/4481192209_3793b90255_o.png "Changing codepage turns non-English characters into question marks")

**Figure 3.** Changing codepage turns non-English characters into question marks

For command line programs, Non-English versions of Windows Vista and later actually ship with both English and non-English MUIs (Multilingual User Interface). That means if we cannot get used to command line interface being localized and shown in non-English (e.g. Chinese Taiwan, i.e. zh-TW), in some simpler way we must be able to set it to English without totally switching to a English user account in Regional Options then reboot the PC. (BTW, non-Ultimate/non-Enterprise editions of Windows does not officially allow installing MUI).

## Concept (Temporary Language File Renaming)

Invertigation using Sysinternals Process Monitor reveals that, whenever Windows fails to locate a .exe.mui file in any zh-TW directory, it falls back to locating the .exe.mui in en-US. Comes the concept of Englishize Cmd: Why not temporarily rename the .mui file in zh-TW to something else so that it just falls back to using the one in en-US? Now it has been confirmed the technique works, except that it is a lot of work deciding which system files can be renamed, unprotecting those files as they are protected by WRP (Windows Resource Protection), renaming every single command-line executable... Comes "Englishize Cmd" for this. "Englishize Cmd" is a simple customizable program (batch script) written to automate this tiresome process so that changing back and forth from English to non-English is easier.

 ![](https://farm5.static.flickr.com/4012/4481192211_7cc7fed95d_o.png "Upper: EnglishizeCmd.bat; lower: RestoreCmd.bat")

**Figure 4.** Upper: EnglishizeCmd.bat; lower: RestoreCmd.bat

### **Instructions**

"Englishize Cmd" comes with 4 files:

1. "EnglishizeCmd.bat" for changing command line tools from non-English to English.
2. "RestoreCmd.bat" to restore everything back to original language, including original permissions and ownerships.

      ![](https://farm3.static.flickr.com/2778/4481192213_2c1270d219_o.png "Left: _files_to_process.txt; right: _lang_codes.txt. Note not all executables exist. (e.g. Cd.exe)")

      **Figure 5.** Left: \_files\_to\_process.txt; right: \_lang\_codes.txt. Note not all executables exist. (e.g. Cd.exe)

3. "_lang_codes.txt" is a modifiable list containing all non-English language codes. It includes most languages but in case your language is not there, add it and "Englishize Cmd" will support it.
4. "_files_to_process.txt" is a modifiable list of file names of command-line executables that will be affected in the change. All commands in Windows Vista, 7 and 8.1 should be covered (although it contains much more commands than there actually are, it doesn't matter because it has no effect on commands that don't exist.) If you decide some commands are better left localized rather than being changed to English, remove them from this list before running "EnglishizeCmd.bat". Also, although the list covers command-line executables, you can add GUI – Graphical User Interface - programs such as Paint - mspaint.exe and lots of others to "_files_to_process.txt". There is a limitation here though. Windows comes with both English and non-English .mui files for command-line programs only; by default .mui for GUI programs don't exist in en-US folder until users install the English MUI through Windows Update) or some third-party tool (for non-Ultimate/Enterprise Windows users).

      ![](https://farm3.static.flickr.com/2780/4481192215_78a05a8a8a_o.png "Interestingly, there is a point where both languages are shown while processing EnglishizeCmd.bat.")

      **Figure 6.** Interestingly, there is a point where both languages are shown while processing EnglishizeCmd.bat

## Video Demonstrating Englishize Cmd

<a href="http://www.youtube.com/watch?feature=player_embedded&v=bnHCJ0tSvXg
" target="_blank"><img src="http://img.youtube.com/vi/bnHCJ0tSvXg/0.jpg" 
alt="Englishize Cmd on YouTube" width="240" height="180" border="10" /></a>

(Tip: Turn on captions to understand better)

## Safety Design

Englishize Cmd has been designed with safety in mind; it does not allow a .mui to be disabled when its en-US counterpart is not found, in order to prevent from causing system problems. On the other hand, 'RestoreCmd.bat' restores original permission and ownership information in addition to renaming language files back to original file names. It is recommended to run 'RestoreCmd.bat' after use to fall back to original configuration at once. Next time, when it is desired to use Englishize Cmd, simply repeat the procedure of running 'EnglishizeCmd.bat' and 'RestoreCmd.bat' again.

## Word of Mouth

Below are some of the kind comments left by users of the script. (Thanks!)

- "You provide a really great script. It saved my life because we here at school need the English commands in cmd with German OS language in Windows 10."
- "It's a very useful app. Thanks."

## Release History

| Ver | Date | MD5 | Changes |
| --- | --- | --- | --- |
| 2.0 | 20200705 | Refer to [GitHub Releases](https://github.com/wandersick/englishize-cmd/releases) | - Added the option to install (and uninstall) Englishize Cmd into system for ease of use, alongside existing portable option, adding to Run prompt and PATH environmental variable to enable the `EnglishizeCmd` and `RestoreCmd` command anywhere for ease of use.<br>- Fix (remove) EnableLUA debug message displayed during UAC elevation.<br>- Improved elevation mechanism so that it supports Run prompt.<br>- Append 'Cmd' to commands, i.e. 'EngishizeCmd' and 'RestoreCmd'. |
| 1.7a | 20140513 | c0b89ec00a51403db6afc650cc4dba16 | - A quick fix to patch the recently updated restoration script which launched incorrect batch script during elevation |
| 1.7 | 20140511 | 6ae00a4461d0946d38f442e279c416fe | - Fixes non-stop prompting when run as standard user w/o UAC. |
| 1.6a | 20140105 | 72a3fe23d386d400f0b6d7d31b0562d7 | - A quick fix to improve the last version. |
| 1.6 | 20140105 | 0f45d9df16c9597a58804103fc0b492e | 1. Fixed bug in some non-English localized versions of Windows where 'Administrators' group account is named something else. Thanks Markus (echalone).<br>2. Confirmed working in Windows 8.1. |
| 1.5 | 20130215 | 8f6a103cad75167408f7dce43460eff9 | 1. Support for mui files under %systemroot%\syswow64.<br>2. Restoration script now restores original permissions and ownership (TrustedInstaller).<br>3. Confirmed working in Windows 8. Updated with new CLI tools. |
| 1.4a | 20120408 | 6793d377acd497643a9c762d3fed6c81 | - Fixed "_lang_codes.txt". It should not contain any en-XX languages; otherwise, even English is disabled. |
| 1.4 | 20120407 | dc458d3e02d72956a61021bb0d90c2ff | - Improved "_lang_codes.txt" so that all system languages are supported. (Please report if your locale is not included) |
| 1.3 | 20100428 | 2312bb99d93915a7645237dbb1de2191 | - Now asks for elevation automatically<br>- Added check for Windows version
| 1.2 | 20100420 | b25aa93e43577b3209f4aa57d9966e60 | - Documentation and coding improvements
| 1.1 | 20100416 | d4082b73326963ecf17f4801106bc371 | - Added check for admin rights
| 1.0 | 20100401 | d8f0e80c6c6fc9f03629aab911f102ee | - First public release
