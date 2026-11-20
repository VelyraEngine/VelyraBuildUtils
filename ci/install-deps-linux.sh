#!/usr/bin/env bash
# Installs everything needed to build and test a Velyra project on Ubuntu, the image of the GitHub runners (ubuntu-latest).
# Also works on a fresh machine or in a container: sudo is only used when not running as root.
set -euo pipefail

packages=(
    # Toolchain
    ca-certificates cmake ninja-build g++ git pkg-config

    # GLFW, X11 backend
    libx11-dev libxrandr-dev libxinerama-dev libxcursor-dev libxi-dev libxext-dev
    # GLFW, Wayland backend (libwayland-dev brings wayland-scanner)
    libwayland-dev libxkbcommon-dev wayland-protocols

    # OpenGL headers, and the Mesa software renderer so tests can create a context without a GPU
    libgl-dev libgl1-mesa-dri

    # nativefiledialog-extended, xdg-desktop-portal backend
    libdbus-1-dev

    # Virtual display for tests that open a window, see build-and-test.sh
    xvfb xauth
)

sudo=""
if [[ "$(id -u)" -ne 0 ]]; then
    sudo="sudo"
fi

$sudo apt-get update
DEBIAN_FRONTEND=noninteractive $sudo apt-get install -y --no-install-recommends "${packages[@]}"
