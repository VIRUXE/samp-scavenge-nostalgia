#!/bin/bash

# Check if the script is running as root
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root"
    exit 1
fi

# Update the system and install EPEL-release
echo "Updating system and installing EPEL-release..."
yum update -y
yum install -y epel-release

# Install required packages
echo "Installing required packages..."
yum install -y p7zip python3 httpd php gcc gcc-c++ cmake make screen glibc.i686 libstdc++.i686

# Create the user 'samp' and ask the user to set a password
echo "Creating user 'samp'..."
useradd -m samp
echo "Please enter a password for the new user 'samp'"
passwd samp

# Get the current SELinux mode
current_mode=$(sestatus | grep -i "Current mode" | awk '{print $3}')

# Check if the current mode is not permissive
if [ "$current_mode" != "permissive" ]; then
    # Modify the SELinux configuration file
    sed -i 's/^SELINUX=.*/SELINUX=permissive/' /etc/selinux/config

    # Print the new SELinux configuration
    echo "Updated SELinux configuration:"
    cat /etc/selinux/config

    # Reboot the system to apply the changes
    echo "Rebooting the system to apply the changes. Press Ctrl+C within 5 seconds to cancel."
    sleep 5
    reboot
else
    echo "SELinux is already in Permissive mode. No changes were made."
fi