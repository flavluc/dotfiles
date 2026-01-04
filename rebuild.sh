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
