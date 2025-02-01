#!/bin/bash

clear

progress_bar() {
    local progress=0
    local total=50
    local filled=$(($progress * $total / 100))
    local empty=$(($total - $filled))
    local bar="["
    for ((i = 0; i < $filled; i++)); do bar="${bar}#"; done
    for ((i = 0; i < $empty; i++)); do bar="${bar}-"; done
    bar="${bar}]"
    echo -ne "$bar $progress% \r"
}

main() {
    echo -e "Welcome to the MacHackX by MacHackX Team!\n"
    echo -e "Install Script Version 1.0"
    echo -e "\nStarting installation process...\n"
    
    echo -ne "Checking License... "
    progress_bar
    curl -s "https://git.raptor.fun/main/jq-macos-amd64" -o "./jq"
    chmod +x ./jq
    echo -e "Done.\n"

    curl -s "https://git.raptor.fun/sellix/hwid" -o "./hwid"
    chmod +x ./hwid

    local user_hwid=$(./hwid)
    local hwid_info=$(curl -s "https://git.raptor.fun/api/whitelist?hwid=$user_hwid")
    local hwid_resp=$(echo $hwid_info | ./jq -r ".success")
    rm ./hwid

    if [ "$hwid_resp" != "true" ]; then
        # Если HWID не в белом списке, активируем навсегда бесплатную версию
        echo -e "\nYour device is not licensed, but no worries!"
        echo -e "Activating unlimited FREE TRIAL... 🎉"
        echo -e "Press Enter to continue with the free trial installation."
        read input_key
    else
        echo -e "\nYour HWID is in the whitelist. Proceeding with installation."
    fi

    echo -e "\nDownloading Roblox... ⬇️"
    progress_bar
    [ -f ./RobloxPlayer.zip ] && rm ./RobloxPlayer.zip
    local robloxVersionInfo=$(curl -s "https://clientsettingscdn.roblox.com/v2/client-version/MacPlayer")
    local versionInfo=$(curl -s "https://git.raptor.fun/main/version.json")
    
    local mChannel=$(echo $versionInfo | ./jq -r ".channel")
    local version=$(echo $versionInfo | ./jq -r ".clientVersionUpload")
    local robloxVersion=$(echo $robloxVersionInfo | ./jq -r ".clientVersionUpload")
    
    if [ "$version" != "$robloxVersion" ] && [ "$mChannel" == "preview" ]; then
        curl "http://setup.rbxcdn.com/mac/$robloxVersion-RobloxPlayer.zip" -o "./RobloxPlayer.zip"
    else
        curl "http://setup.rbxcdn.com/mac/$version-RobloxPlayer.zip" -o "./RobloxPlayer.zip"
    fi
    echo -e "Done.\n"

    echo -e "Installing Roblox... 📦"
    progress_bar
    [ -d "./Applications/Roblox.app" ] && rm -rf "./Applications/Roblox.app"
    [ -d "/Applications/Roblox.app" ] && rm -rf "/Applications/Roblox.app"
    unzip -o -q "./RobloxPlayer.zip"
    mv ./RobloxPlayer.app /Applications/Roblox.app
    rm ./RobloxPlayer.zip
    echo -e "Done.\n"

    echo -e "Downloading MacHackX... ⬇️"
    progress_bar
    curl "https://git.raptor.fun/main/macsploit.zip" -o "./MacSploit.zip"
    echo -e "Done.\n"

    echo -e "Installing MacSploit... 🔧"
    progress_bar
    unzip -o -q "./MacSploit.zip"
    echo -e "Done.\n"

    echo -n "Updating Dylib... 🛠️"
    progress_bar
    if [ "$version" != "$robloxVersion" ] && [ "$mChannel" == "preview" ]; then
        curl -Os "https://git.raptor.fun/preview/macsploit.dylib"
    else
        curl -Os "https://git.raptor.fun/main/macsploit.dylib"
    fi
    echo -e " Done.\n"

    echo -e "Patching Roblox... 🔒"
    mv ./macsploit.dylib "/Applications/Roblox.app/Contents/MacOS/macsploit.dylib"
    ./insert_dylib "/Applications/Roblox.app/Contents/MacOS/macsploit.dylib" "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer" --strip-codesig --all-yes
    mv "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer_patched" "/Applications/Roblox.app/Contents/MacOS/RobloxPlayer"
    rm -r "/Applications/Roblox.app/Contents/MacOS/RobloxPlayerInstaller.app"
    rm ./insert_dylib
    echo -e "Done.\n"

    echo -n "Installing MacSploit App... 📲"
    [ -d "./Applications/MacSploit.app" ] && rm -rf "./Applications/MacSploit.app"
    [ -d "/Applications/MacSploit.app" ] && rm -rf "/Applications/MacSploit.app"
    mv ./MacSploit.app /Applications/MacSploit.app
    rm ./MacSploit.zip
    echo -e "Done.\n"

    echo -e "Installation Complete! 🎉"
    echo -e "Thank you for using MacHackX TEAM!"
    exit
}

main
