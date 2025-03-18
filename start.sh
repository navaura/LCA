#!/bin/bash

# Configuration
ZIP_FILE="local_cloud_api.zip"
TARGET_DIR="local_cloud_api"
CONFIG_FILE=".setup_complete"
RUN_ON_STARTUP_FILE=".run_on_startup"

# Function to detect OS and set virtual environment commands
setup_environment_variables() {
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo "Detected Windows"
        VENV_CMD="python -m venv venv"
        ACTIVATE_CMD="source venv/Scripts/activate"
        PYTHON_CMD="python"
    elif [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$OSTYPE" == "darwin"* ]]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo "Detected macOS"
        else
            echo "Detected Linux"
        fi
        VENV_CMD="python3 -m venv venv"
        ACTIVATE_CMD="source venv/bin/activate"
        PYTHON_CMD="python3"
    else
        echo "Unsupported OS: $OSTYPE"
        exit 1
    fi
}

# Function to ensure we're in the target directory
ensure_target_directory() {
    # Store the script's directory
    SCRIPT_DIR="$(pwd)"
    
    # Check if we're already in the target directory
    if [[ "$(basename "$(pwd)")" != "$TARGET_DIR" ]]; then
        echo "Navigating to $TARGET_DIR directory..."
        # Check if target directory exists
        if [[ -d "$TARGET_DIR" ]]; then
            cd "$TARGET_DIR" || exit 1
        else
            echo "Target directory doesn't exist yet"
        fi
    fi
}

# Function to perform first-time setup
perform_setup() {
    echo "First time setup detected!"
    
    # Go back to script directory if needed
    cd "$SCRIPT_DIR" || exit 1
    
    # Extract the ZIP file
    echo "Extracting $ZIP_FILE..."
    if [[ -f "$ZIP_FILE" ]]; then
        unzip -o "$ZIP_FILE" -d "$TARGET_DIR"
        cd "$TARGET_DIR" || exit 1
    else
        echo "Error: $ZIP_FILE not found!"
        exit 1
    fi
    
    # Create virtual environment
    echo "Creating virtual environment..."
    $VENV_CMD
    
    # Activate virtual environment
    echo "Activating virtual environment..."
    $ACTIVATE_CMD
    
    # Install dependencies
    echo "Installing dependencies..."
    pip install --upgrade pip
    pip install uvicorn fastapi python-multipart bcrypt psutil
    
    # Mark setup as complete
    touch "$CONFIG_FILE"
    
    echo "Setup complete!"
    
    # Ask about startup
    read -p "Would you like to set this application to run at startup? (y/n): " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        setup_startup
        touch "$RUN_ON_STARTUP_FILE"
        echo "Application set to run at startup."
    else
        echo "Application will not run at startup."
        if [[ -f "$RUN_ON_STARTUP_FILE" ]]; then
            rm "$RUN_ON_STARTUP_FILE"
        fi
    fi
}

# Function to setup startup based on OS
setup_startup() {
    if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        # Windows - create a .bat file in the Startup folder
        SCRIPT_PATH=$(realpath "$0")
        STARTUP_DIR="$APPDATA/Microsoft/Windows/Start Menu/Programs/Startup"
        echo "Creating startup entry in $STARTUP_DIR"
        echo "@echo off
cd $(dirname "$SCRIPT_PATH")
bash \"$SCRIPT_PATH\" --startup" > "$STARTUP_DIR/run_local_cloud_api.bat"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux - create a .desktop file
        SCRIPT_PATH=$(realpath "$0")
        mkdir -p ~/.config/autostart
        echo "[Desktop Entry]
Type=Application
Name=Local Cloud API
Exec=bash \"$SCRIPT_PATH\" --startup
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true" > ~/.config/autostart/local-cloud-api.desktop
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS - create a launch agent
        SCRIPT_PATH=$(realpath "$0")
        mkdir -p ~/Library/LaunchAgents
        echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
<dict>
    <key>Label</key>
    <string>com.user.localcloudapi</string>
    <key>ProgramArguments</key>
    <array>
        <string>bash</string>
        <string>$SCRIPT_PATH</string>
        <string>--startup</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>" > ~/Library/LaunchAgents/com.user.localcloudapi.plist
    fi
}

# Function to toggle startup setting
toggle_startup() {
    if [[ -f "$RUN_ON_STARTUP_FILE" ]]; then
        echo "Removing application from startup..."
        if [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
            rm "$APPDATA/Microsoft/Windows/Start Menu/Programs/Startup/run_local_cloud_api.bat"
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            rm ~/.config/autostart/local-cloud-api.desktop
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            rm ~/Library/LaunchAgents/com.user.localcloudapi.plist
        fi
        rm "$RUN_ON_STARTUP_FILE"
        echo "Application will no longer run at startup."
    else
        setup_startup
        touch "$RUN_ON_STARTUP_FILE"
        echo "Application set to run at startup."
    fi
}

# Function to run the application
run_application() {
    # Make sure we're in the target directory
    ensure_target_directory
    
    echo "Activating virtual environment..."
    $ACTIVATE_CMD
    echo "Starting application..."
    $PYTHON_CMD app.py
}

# Main function
main() {
    # Store the script's directory
    SCRIPT_DIR="$(pwd)"
    
    setup_environment_variables

    # Check if this is a startup launch
    IS_STARTUP=0
    for arg in "$@"; do
        if [[ "$arg" == "--startup" ]]; then
            IS_STARTUP=1
            break
        fi
    done

    # Ensure we're in the correct directory for checking config file
    ensure_target_directory
    
    # Show menu if not a startup launch and setup is complete
    if [[ $IS_STARTUP -eq 0 && -f "$CONFIG_FILE" ]]; then
        echo "=== Local Cloud API Management ==="
        echo "1. Run the application"
        echo "2. Toggle startup setting"
        echo "3. Reinstall/repair installation"
        echo "4. Exit"
        read -p "Choose an option: " menu_choice
        
        case $menu_choice in
            1)
                run_application
                ;;
            2)
                toggle_startup
                ;;
            3)
                echo "Performing reinstallation..."
                # Go back to script directory
                cd "$SCRIPT_DIR" || exit 1
                rm -f "$TARGET_DIR/$CONFIG_FILE"
                perform_setup
                run_application
                ;;
            4)
                echo "Exiting..."
                exit 0
                ;;
            *)
                echo "Invalid option. Running application..."
                run_application
                ;;
        esac
    elif [[ ! -f "$CONFIG_FILE" ]]; then
        # First-time setup - return to script directory first
        cd "$SCRIPT_DIR" || exit 1
        perform_setup
        run_application
    else
        # Startup launch or default action after setup
        run_application
    fi
}

# Execute main function
main "$@"
