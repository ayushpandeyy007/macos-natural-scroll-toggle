#!/bin/bash
current=$(defaults read -g com.apple.swipescrolldirection 2>/dev/null)
if [ "$current" = "1" ]; then
    defaults write -g com.apple.swipescrolldirection -bool false
    MSG="Natural Scrolling: OFF"
else
    defaults write -g com.apple.swipescrolldirection -bool true
    MSG="Natural Scrolling: ON"
fi

/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

osascript -e "display notification \"$MSG\" with title \"Scroll Direction\""
