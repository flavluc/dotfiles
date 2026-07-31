#!/usr/bin/env bash
# NixOS Multi-Host Rebuild Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display usage
usage() {
    echo -e "${BLUE}Usage:${NC} $0 [COMMAND] [HOST]"
    echo ""
    echo "Commands:"
    echo "  switch    - Build and switch to the new configuration"
    echo "  test      - Build and test without making it the boot default"
    echo "  build     - Build without switching"
    echo "  check     - Check flake for errors"
    echo "  update    - Update flake inputs (flake.lock)"
    echo "  show      - Show flake outputs"
    echo ""
    echo "Hosts:"
    echo "  desktop   - Build desktop configuration"
    echo "  laptop    - Build laptop configuration"
    echo ""
    echo "Examples:"
    echo "  $0 switch desktop    # Build and switch desktop configuration"
    echo "  $0 test laptop       # Test laptop configuration"
    echo "  $0 check             # Check flake syntax"
    echo "  $0 update            # Update flake.lock"
    exit 1
}

# Check if running from correct directory
if [ ! -f "flake.nix" ]; then
    echo -e "${RED}Error:${NC} flake.nix not found. Please run this script from the dotfiles directory."
    exit 1
fi

# Parse arguments
COMMAND=$1
HOST=$2

# Commands that don't require a host
case "$COMMAND" in
    check)
        echo -e "${BLUE}Checking flake...${NC}"
        nix flake check
        echo -e "${GREEN}✓ Flake check passed!${NC}"
        exit 0
        ;;
    update)
        echo -e "${BLUE}Updating flake inputs...${NC}"
        nix flake update
        echo -e "${GREEN}✓ Flake updated!${NC}"
        echo -e "${YELLOW}Note: Run 'sudo $0 switch [HOST]' to apply updates${NC}"
        exit 0
        ;;
    show)
        nix flake show
        exit 0
        ;;
    *)
        # Commands that require a host
        if [ -z "$COMMAND" ] || [ -z "$HOST" ]; then
            usage
        fi
        ;;
esac

# Validate host
if [ "$HOST" != "desktop" ] && [ "$HOST" != "laptop" ]; then
    echo -e "${RED}Error:${NC} Invalid host. Must be 'desktop' or 'laptop'"
    usage
fi

# Check if flake.lock exists
if [ ! -f "flake.lock" ]; then
    echo -e "${YELLOW}Warning:${NC} flake.lock not found. Running 'nix flake update' first..."
    nix flake update
fi

# Preflight: catch configs that would produce an unbootable or downgraded system.
# Only meaningful when the target host IS the machine we're running on.
preflight() {
    local host=$1
    local problems=0

    if [ "$host" != "$(hostname)" ]; then
        echo -e "${YELLOW}Preflight skipped:${NC} building '$host' from '$(hostname)'"
        return 0
    fi

    # 1. Does the committed hardware config still describe THIS machine's disks?
    #    A stale hardware-configuration.nix (wrong UUIDs, missing LUKS) builds
    #    fine and then drops the machine into emergency mode on boot.
    local hw="hosts/$host/hardware-configuration.nix"
    if [ -f "$hw" ]; then
        local live repo
        live=$(nixos-generate-config --show-hardware-config 2>/dev/null \
               | grep -oE 'by-uuid/[A-Za-z0-9-]+|/dev/mapper/[A-Za-z0-9_-]+' | sort -u)
        repo=$(grep -oE 'by-uuid/[A-Za-z0-9-]+|/dev/mapper/[A-Za-z0-9_-]+' "$hw" | sort -u)
        if [ -n "$live" ] && [ "$live" != "$repo" ]; then
            echo -e "${RED}PREFLIGHT:${NC} $hw does not match this machine's disks."
            echo -e "${YELLOW}  this machine:${NC} $(echo "$live" | tr '\n' ' ')"
            echo -e "${YELLOW}  the repo says:${NC} $(echo "$repo" | tr '\n' ' ')"
            echo -e "  Regenerate with: nixos-generate-config --show-hardware-config > $hw"
            problems=1
        fi
    fi

    # 2. Would this switch move the machine to an older NixOS release?
    #    A stale flake.lock silently downgrades the whole OS, kernel included.
    local target running
    target=$(nix eval --raw ".#nixosConfigurations.$host.config.system.nixos.release" 2>/dev/null)
    running=$(nixos-version 2>/dev/null | grep -oE '^[0-9]+\.[0-9]+')
    if [ -n "$target" ] && [ -n "$running" ] && [ "$target" != "$running" ]; then
        echo -e "${RED}PREFLIGHT:${NC} release change: running ${running} -> building ${target}"
        if [ "$(printf '%s\n%s\n' "$target" "$running" | sort -V | head -1)" = "$target" ]; then
            echo -e "${RED}  This is a DOWNGRADE.${NC} Check nixpkgs branch in flake.nix and flake.lock."
        fi
        problems=1
    fi

    if [ "$problems" -ne 0 ]; then
        echo
        read -r -p "Continue anyway? [y/N] " reply
        [[ "$reply" =~ ^[Yy]$ ]] || { echo -e "${RED}Aborted.${NC}"; exit 1; }
    else
        echo -e "${GREEN}✓ Preflight passed${NC} (hardware config and release match this machine)"
    fi
}

case "$COMMAND" in
    switch|test|boot) preflight "$HOST" ;;
esac

# Execute the appropriate nixos-rebuild command
case "$COMMAND" in
    switch)
        echo -e "${BLUE}Building and switching to $HOST configuration...${NC}"
        sudo nixos-rebuild switch --flake ".#$HOST"
        echo -e "${GREEN}✓ Successfully switched to $HOST configuration!${NC}"
        ;;
    test)
        echo -e "${BLUE}Testing $HOST configuration...${NC}"
        sudo nixos-rebuild test --flake ".#$HOST"
        echo -e "${GREEN}✓ Successfully tested $HOST configuration!${NC}"
        echo -e "${YELLOW}Note: This is temporary. Reboot to return to previous config.${NC}"
        ;;
    build)
        echo -e "${BLUE}Building $HOST configuration...${NC}"
        sudo nixos-rebuild build --flake ".#$HOST"
        echo -e "${GREEN}✓ Successfully built $HOST configuration!${NC}"
        echo -e "${YELLOW}Note: Run 'sudo $0 switch $HOST' to activate.${NC}"
        ;;
    *)
        echo -e "${RED}Error:${NC} Invalid command: $COMMAND"
        usage
        ;;
esac
