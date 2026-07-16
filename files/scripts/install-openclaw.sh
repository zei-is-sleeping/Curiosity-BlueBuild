#!/usr/bin/env bash
set -euo pipefail

echo "Building app from source..."

# Install build deps 
dnf install -y nodejs npm gcc-c++ make cmake python3

# Install openclaw via npm with sane ENV vars
HOME=/tmp npm install -g --prefix=/usr openclaw@latest

# Clean up
dnf remove -y gcc-c++ make cmake
dnf clean all
