#!/bin/bash

# Lightweight WiFi Rofi Menu Script
# Requires: nmcli, rofi

# Function to show notification
notify() {
    if command -v notify-send &> /dev/null; then
        notify-send "WiFi" "$1"
    fi
}

# Check if NetworkManager is running
if ! systemctl is-active --quiet NetworkManager; then
    notify "NetworkManager is not running!"
    exit 1
fi

# Turn on WiFi if it's off
nmcli radio wifi on

# Perform scan (advanced scan by default)
nmcli device wifi rescan &>/dev/null

# Get current connection
CONNECTED_SSID=$(nmcli -t -f active,ssid dev wifi | grep '^yes:' | cut -d: -f2)

# Build menu
MENU=""

# Add action buttons
MENU="${MENU}🔍 Connect to Hidden Network\n"
MENU="${MENU}🔄 Refresh Networks\n"
if [ -n "$CONNECTED_SSID" ]; then
    MENU="${MENU}🔌 Disconnect from $CONNECTED_SSID\n"
fi
MENU="${MENU}─────────────────\n"

# Get networks and add to menu
while IFS=':' read -r ssid security signal freq; do
    # Skip empty or hidden SSIDs
    [ -z "$ssid" ] || [ "$ssid" = "--" ] && continue
    
    # Determine security icon
    if [ -z "$security" ] || [ "$security" = "--" ]; then
        ICON=""
    else
        ICON=""
    fi
    
    # Determine band
    BAND=""
    if [ -n "$freq" ] && [ "$freq" != "--" ]; then
        if [ "$freq" -gt 4000 ] 2>/dev/null; then
            BAND=" 5G"
        else
            BAND=" 2.4G"
        fi
    fi
    
    # Add connection indicator
    INDICATOR=""
    [ "$ssid" = "$CONNECTED_SSID" ] && INDICATOR=" ✓"
    
    MENU="${MENU}${ICON}  ${ssid}  [${signal}%${BAND}]${INDICATOR}\n"
    
done < <(nmcli -t -f SSID,SECURITY,SIGNAL,FREQ device wifi list | tail -n +2)

# Show menu
SELECTED=$(echo -e "$MENU" | sed '/^$/d' | rofi -dmenu -p "WiFi Manager" -i \
    -theme-str 'window {width: 400px;}' \
    -theme-str 'element {padding: 6px;}' \
    -no-custom)

# Handle selection
if [ -z "$SELECTED" ]; then
    exit 0
fi

# Parse selection
case "$SELECTED" in
    "🔌 Disconnect"*)
        notify "Disconnecting..."
        if nmcli connection down "$CONNECTED_SSID" &>/dev/null; then
            notify "Disconnected from $CONNECTED_SSID"
        else
            notify "Failed to disconnect"
        fi
        ;;
    "🔄 Refresh Networks")
        exec "$0"  # Restart script
        ;;
    "🔍 Connect to Hidden Network")
        HIDDEN_SSID=$(rofi -dmenu -p "Hidden Network SSID" -lines 0 \
            -theme-str 'window {width: 350px;}')
        
        if [ -n "$HIDDEN_SSID" ]; then
            PASSWORD=$(rofi -dmenu -password -p "Password for $HIDDEN_SSID" -lines 0 \
                -theme-str 'window {width: 350px;}')
            
            notify "Connecting to $HIDDEN_SSID..."
            if [ -n "$PASSWORD" ]; then
                nmcli device wifi connect "$HIDDEN_SSID" password "$PASSWORD" hidden yes &>/dev/null
            else
                nmcli device wifi connect "$HIDDEN_SSID" hidden yes &>/dev/null
            fi
            
            if [ $? -eq 0 ]; then
                notify "Connected to $HIDDEN_SSID"
            else
                notify "Failed to connect to $HIDDEN_SSID"
            fi
        fi
        ;;
    "────────────────────────")
        # Ignore separator
        ;;
    *)
        # Extract SSID from network selection
        SSID=$(echo "$SELECTED" | sed -E 's/^[]  //; s/  \[.*$//')
        
        if [ -z "$SSID" ]; then
            notify "Could not determine network name"
            exit 1
        fi
        
        # Check if network needs password
        NEEDS_PASSWORD=false
        if echo "$SELECTED" | grep -q ""; then
            NEEDS_PASSWORD=true
        fi
        
        # Try connecting with saved credentials first
        if nmcli connection show "$SSID" &>/dev/null; then
            notify "Connecting to $SSID..."
            if nmcli connection up "$SSID" &>/dev/null; then
                notify "Connected to $SSID"
                exit 0
            elif [ "$NEEDS_PASSWORD" = true ]; then
                # Saved credentials failed, delete and prompt for new password
                nmcli connection delete "$SSID" &>/dev/null
            fi
        fi
        
        # Connect to new network or retry with new password
        if [ "$NEEDS_PASSWORD" = true ]; then
            PASSWORD=$(rofi -dmenu -password -p "Password for $SSID" -lines 0 \
                -theme-str 'window {width: 350px;}')
            
            if [ -z "$PASSWORD" ]; then
                notify "No password entered"
                exit 0
            fi
            
            notify "Connecting to $SSID..."
            if nmcli device wifi connect "$SSID" password "$PASSWORD" &>/dev/null; then
                notify "Connected to $SSID"
            else
                notify "Failed to connect to $SSID"
            fi
        else
            # Open network
            notify "Connecting to $SSID..."
            if nmcli device wifi connect "$SSID" &>/dev/null; then
                notify "Connected to $SSID"
            else
                notify "Failed to connect to $SSID"
            fi
        fi
        ;;
esac

