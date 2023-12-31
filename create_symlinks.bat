:: -------------------  HOW TO USE ------------------------
:: To make it works set variables in "User Config" category
:: (defined below) with values actual for your environment.
:: P.S. don't move script file, it should be in the root dir
::
::  1. Run script
::  2. Verify all is fine
::      2.1 SymLinks created
::      2.2 steam's "game" & "content" dirs are not empty
::  3. Remove "game_backup" and "content_backup"
::  4. Done!


:: --------- Algorithm (brief description) -------------
::  1. Validations
::      It will be explained in the end
::      Take a look on the following steps first 
::
::  2. COPY local stuff to steam dir
::      2.1 "game"  ->   steam\...\game\dota_addons\your_mod_name\
::      2.1 "game"  ->   steam\...\content\dota_addons\your_mod_name\
::
::  3. RENAME local stuff
::      3.1 "game"     ->   "game_backup"
::      3.2 "content"  ->   "content_backup"
::
::  4. CREATE SymLinks
::      4.1 "game"  ->   steam\...\game\dota_addons\your_mod_name\
::      4.2 "game"  ->   steam\...\content\dota_addons\your_mod_name\
::
::  
::  1. Validations:
::      If any validation fails then execution stops (setps 2,3,4+ will not run)
::      P.S. corresponding error messages will be printed to console
::      
::      1.0 Verify that some Config variables are actually changed
::      1.1 Verify that local "game" exists
::      1.2 Verify that local "game" is not SymLink
::      1.3 Verify that local "content" exists
::      1.4 Verify that local "content" is not SymLink
::      1.5 Verify that STEAM's \game\dota_addons\your_mod_name\ is NOT exist
::      1.6 Verify that STEAM's \content\dota_addons\your_mod_name\ is NOT exist
::
::
:: Script has been tested on Windows 10 64-bit. 
:: Other onfigurations are not guaranteed to work ¯\_(ツ)_/¯::
::--------------------------------------------------------------------------------


:: ============================== User Config ========================================
:: ============================== CHANGE THIS ========================================
@echo off
:: Don't add QUOTES for root path. It'll be added later
set PATH_DOTA2_MODS_ROOT=D:\Games\SteamLibrary\steamapps\common\dota 2 beta\
:: Would be used as steam's addon root dir: ...\dota_addons\pepega_addon_123\
set MOD_DIR_NAME=pepega_addon_123

:: ======================     Autogenerated Config      ===============================
:: ====================== YOU DON'T NEED TO CHANGE THIS ===============================
set WORKING_DIR=%~dp0
set GAME_DIR_NAME=game
set CONTENT_DIR_NAME=content

set PATH_STEAM_GAME="%PATH_DOTA2_MODS_ROOT%%GAME_DIR_NAME%\dota_addons\%MOD_DIR_NAME%"
set PATH_STEAM_CONTENT="%PATH_DOTA2_MODS_ROOT%%CONTENT_DIR_NAME%\dota_addons\%MOD_DIR_NAME%"

:: Google: "delayed vs immediate variables expansion in batch scripts"
setlocal enabledelayedexpansion

:: ============================ Validation ============================================
set HasErrors=0

:: Check that some Config variables are actually changed
if NOT exist "%PATH_DOTA2_MODS_ROOT%" (
  echo:
  echo Error: "%PATH_DOTA2_MODS_ROOT%" is not exists!
  echo Have you configured PATH_DOTA2_MODS_ROOT variable?
  set HasErrors=1
)

if "%MOD_DIR_NAME%"=="pepega_addon_123" (  
  echo:
  echo Seems like you have not configured MOD_DIR_NAME variable!
  set HasErrors=1
)

:: Check SymLinks already exists
:: basicaly it checks "DOS/Windows File Attributes" e.g. "d-------l--"
if exist %GAME_DIR_NAME% (
    for %%i in ("%GAME_DIR_NAME%") do (
        set dirAttributes=%%~ai

        @REM There is no "ContainSubstring" feature out of the box
        @REM Batch scripts allows to create string with replaced "substring"
        @REM So create new var with replaced "desired substring" and compare it to old var
        set str=!dirAttributes:l=-!
        if NOT "!str!"=="!dirAttributes!" (
            echo Error: %GAME_DIR_NAME% dir is a SymLink already
            set HasErrors=1
        )
    )
) else ( 
    echo:
    echo Error: dir "%GAME_DIR_NAME%" is not exist
    set HasErrors=1
)

if exist %CONTENT_DIR_NAME% (
    for %%i in ("%CONTENT_DIR_NAME%") do (
        set dirAttributes=%%~ai

        @REM There is no "ContainSubstring" feature out of the box
        @REM Batch scripts allows to create string with replaced "substring"
        @REM So create new var with replaced "desired substring" and compare it to old var
        set str=!dirAttributes:l=-!
        if NOT "!str!"=="!dirAttributes!" (
            Error: echo %CONTENT_DIR_NAME% dir is a SymLink already
            set HasErrors=1
        )
    )
) else ( 
    echo:
    echo Error: dir "%CONTENT_DIR_NAME%" is not exist
    set HasErrors=1
)

:: Check "game" dir is not exist in "steam mods dir"
if exist %PATH_STEAM_GAME%\ (
  echo:
  echo Error: %PATH_STEAM_GAME% already exists!
  set HasErrors=1
)

:: Check "content" dir is not exist in "steam mods dir"
if exist %PATH_STEAM_CONTENT%\ (
  echo:
  echo Error: %PATH_STEAM_CONTENT% already exists!
  set HasErrors=1
)

:: Abort execution if there are any errors
if NOT %HasErrors% == 0 (
    echo:
    pause
    exit /b
)


:: =================== Copy local "game" and "content" to corresponding STEAM's /dota_addons/ dirs ==============
:: /E	    Copy subdirectories, including the empty ones.
:: /MOVE	Move files and dirs (delete from the source after copying).
:: /NFL /NDL /NJH /NJS /NP - disable logs (spam to console)
call ROBOCOPY "%WORKING_DIR%%GAME_DIR_NAME%\\" %PATH_STEAM_GAME% /E /NFL /NDL /NJH /NJS /NP
call ROBOCOPY "%WORKING_DIR%%CONTENT_DIR_NAME%\\" %PATH_STEAM_CONTENT% /E /NFL /NDL /NJH /NJS /NP
:: TODO: handle errors from ROBOCOPY?


:: ========= Rename copied dirs (instead of removing). Just in case something goes wrong =================
ren %GAME_DIR_NAME% %GAME_DIR_NAME%_backup
ren %CONTENT_DIR_NAME% %CONTENT_DIR_NAME%_backup
:: TODO: expose "Rename" vs "Delete" to User? e.g. ask for action in console like classic "(y/n)" does


:: =============================  Create SymLinks ==================================
mklink /j %GAME_DIR_NAME% %PATH_STEAM_GAME%
mklink /j %CONTENT_DIR_NAME% %PATH_STEAM_CONTENT%

echo:
echo Done
pause

@echo on