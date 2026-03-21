#!/bin/bash

echo " Installing Resume Builder..."

# Define variables
APP_NAME="resume_builder"
DISPLAY_NAME="Resume Builder"
INSTALL_DIR="$HOME/.local/share/ResumeBuilder"
DESKTOP_DIR="$HOME/.local/share/applications"
EXEC_PATH="$INSTALL_DIR/$APP_NAME"
ICON_PATH="$INSTALL_DIR/data/flutter_assets/assets/icon.png"

# 1. Clean up old installation if it exists for clean updates
rm -rf "$INSTALL_DIR"

# 2. Create the directories
mkdir -p "$INSTALL_DIR"
mkdir -p "$DESKTOP_DIR"

# 3. Copy all files from the extracted folder into the install directory
cp -r ./* "$INSTALL_DIR/"

# 4. Make the main binary executable
chmod +x "$EXEC_PATH"

# 5. Generate the .desktop shortcut file dynamically
cat <<EOF > "$DESKTOP_DIR/resume_builder.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=$DISPLAY_NAME
Comment=A cross-platform, offline resume builder
Exec=$EXEC_PATH
Icon=$ICON_PATH
Terminal=false
Categories=Office;Utility;
EOF

# 6. Make the shortcut executable
chmod +x "$DESKTOP_DIR/resume_builder.desktop"

# 7. Refresh the Linux application menu
update-desktop-database "$DESKTOP_DIR" &> /dev/null || true

echo " Installation complete! You can now launch '$DISPLAY_NAME' from your application menu."