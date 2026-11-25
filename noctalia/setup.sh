#!/usr/bin/env bash
# Noctalia Configuration Setup Script
# Helps install and manage Noctalia config with all waybar features

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Paths
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
NOCTALIA_CONFIG="$CONFIG_HOME/noctalia"
NOCTALIA_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/noctalia"

# Functions
print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

check_noctalia_installed() {
    if ! command -v noctalia &> /dev/null; then
        print_error "Noctalia is not installed"
        print_info "Install from: https://noctalia.dev or your package manager"
        return 1
    fi
    print_success "Noctalia found: $(noctalia --version)"
    return 0
}

install_config() {
    print_info "Installing Noctalia configuration..."
    
    # Create config directory
    mkdir -p "$NOCTALIA_CONFIG"
    mkdir -p "$NOCTALIA_CONFIG/plugins"
    
    # Copy main config files
    cp "$SCRIPT_DIR/config.toml" "$NOCTALIA_CONFIG/"
    cp "$SCRIPT_DIR/theme.toml" "$NOCTALIA_CONFIG/"
    print_success "Copied main config files"
    
    # Copy plugin configs
    cp "$SCRIPT_DIR/plugins/"*.toml "$NOCTALIA_CONFIG/plugins/"
    print_success "Copied plugin configurations"
    
    # Backup existing config if present
    if [ -f "$NOCTALIA_CONFIG/config.toml.bak" ]; then
        rm "$NOCTALIA_CONFIG/config.toml.bak"
    fi
    
    print_success "Configuration installed to: $NOCTALIA_CONFIG"
}

show_config_location() {
    print_info "Noctalia config location: $NOCTALIA_CONFIG"
    print_info "Files:"
    ls -lah "$NOCTALIA_CONFIG"
    echo ""
    ls -lah "$NOCTALIA_CONFIG/plugins/"
}

show_logs() {
    if [ -f "/tmp/noctalia.log" ]; then
        print_info "Recent Noctalia logs:"
        tail -f /tmp/noctalia.log
    else
        print_warning "No log file found at /tmp/noctalia.log"
    fi
}

reload_config() {
    print_info "Reloading Noctalia configuration..."
    if command -v noctalia &> /dev/null; then
        noctalia --reload 2>/dev/null || print_warning "Could not send reload signal"
        print_success "Reload signal sent"
    else
        print_error "Noctalia not found"
    fi
}

clear_cache() {
    print_info "Clearing Noctalia cache..."
    if [ -d "$NOCTALIA_CACHE" ]; then
        rm -rf "$NOCTALIA_CACHE"/*
        print_success "Cache cleared"
    else
        print_warning "Cache directory not found"
    fi
}

validate_config() {
    print_info "Validating configuration files..."
    
    if [ ! -f "$NOCTALIA_CONFIG/config.toml" ]; then
        print_error "config.toml not found"
        return 1
    fi
    print_success "config.toml found"
    
    if [ ! -f "$NOCTALIA_CONFIG/theme.toml" ]; then
        print_error "theme.toml not found"
        return 1
    fi
    print_success "theme.toml found"
    
    local plugin_count=$(ls "$NOCTALIA_CONFIG/plugins/"*.toml 2>/dev/null | wc -l)
    if [ "$plugin_count" -eq 0 ]; then
        print_error "No plugin configurations found"
        return 1
    fi
    print_success "Found $plugin_count plugin configurations"
    
    return 0
}

show_help() {
    cat << EOF
${BLUE}Noctalia Configuration Setup${NC}

Usage: ./setup.sh [COMMAND]

Commands:
  install         Install/update Noctalia configuration
  status          Show config location and files
  logs            Show Noctalia logs (tail -f)
  reload          Reload Noctalia configuration
  clear-cache     Clear Noctalia cache
  validate        Validate configuration files
  help            Show this help message

Examples:
  ./setup.sh install      # Install the configuration
  ./setup.sh status       # Check installation status
  ./setup.sh reload       # Reload after changes
  ./setup.sh validate     # Verify configuration

For more information, see README.md in this directory.
EOF
}

# Main
main() {
    print_info "Noctalia Configuration Setup v1.0"
    echo ""
    
    # Check if Noctalia is installed (for most commands)
    if [ "${1:-install}" != "help" ]; then
        check_noctalia_installed || true
        echo ""
    fi
    
    case "${1:-install}" in
        install)
            install_config
            validate_config && print_success "Configuration validated"
            show_config_location
            ;;
        status)
            show_config_location
            validate_config
            ;;
        logs)
            show_logs
            ;;
        reload)
            reload_config
            ;;
        clear-cache)
            clear_cache
            ;;
        validate)
            validate_config
            ;;
        help)
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

main "$@"
