#!/bin/bash
./steamcmd.sh +@sSteamCmdForcePlatformType windows +login anonymous +app_update 443030 +quit
# ./steamcmd.sh +@sSteamCmdForcePlatformType windows +login anonymous +workshop_download_item 440900 2791028919
export WINEARCH=win64
export WINEPREFIX=/home/steam/.wine64
xvfb-run --auto-servernum wine /home/steam/Steam/steamapps/common/'Conan Exiles Dedicated Server'/ConanSandboxServer.exe -log