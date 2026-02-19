#!/bin/bash
# Fix WiFi adapter unavailable state and enable hotspot on Arch Linux
# For Intel Wi-Fi 6E AX211 on Acer laptops
# Uses hostapd + dnsmasq for reliable hotspot creation

SSID="${1:-linux}"
PASSWORD="${2:-12345678}"
IFACE="wlan0"
INTERNET_IFACE="enp61s0"
IP_ADDR="192.168.4.1"
DHCP_RANGE="192.168.4.2,192.168.4.20,255.255.255.0,24h"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() { echo -e "${GREEN}[✓]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root (use sudo)"
        exit 1
    fi
}

check_dependencies() {
    print_status "Checking dependencies..."
    for cmd in hostapd dnsmasq; do
        if ! command -v $cmd &>/dev/null; then
            print_error "$cmd is not installed. Install with: sudo pacman -S $cmd"
            exit 1
        fi
    done
}

cleanup() {
    print_status "Cleaning up previous hotspot configurations..."
    systemctl stop hostapd 2>/dev/null || true
    systemctl stop dnsmasq 2>/dev/null || true
    killall hostapd 2>/dev/null || true
    killall dnsmasq 2>/dev/null || true
    nmcli connection delete wifi-hotspot 2>/dev/null || true
    ip addr flush dev "$IFACE" 2>/dev/null || true
}

stop_conflicting_services() {
    print_status "Stopping conflicting services..."
    systemctl stop NetworkManager 2>/dev/null || true
    systemctl stop wpa_supplicant 2>/dev/null || true
    sleep 1
}

setup_interface() {
    print_status "Setting up WiFi interface..."
    
    # Unload and reload drivers
    ip link set "$IFACE" down 2>/dev/null || true
    modprobe -r iwlmvm 2>/dev/null || true
    modprobe -r iwlwifi 2>/dev/null || true
    modprobe -r acer_wmi 2>/dev/null || true
    sleep 1
    modprobe iwlwifi
    sleep 2
    
    # Unblock rfkill
    rfkill unblock all
    sleep 1
    
    # Bring interface down, set type, bring up
    ip link set "$IFACE" down
    sleep 1
    
    # Assign IP address
    ip addr add "$IP_ADDR/24" dev "$IFACE" 2>/dev/null || true
    ip link set "$IFACE" up
    sleep 1
}

create_hostapd_config() {
    print_status "Creating hostapd configuration..."
    cat > /tmp/hostapd.conf << EOF
interface=$IFACE
driver=nl80211
ssid=$SSID
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=$PASSWORD
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF
}

create_dnsmasq_config() {
    print_status "Creating dnsmasq configuration..."
    cat > /tmp/dnsmasq-hotspot.conf << EOF
interface=$IFACE
dhcp-range=$DHCP_RANGE
dhcp-option=3,$IP_ADDR
dhcp-option=6,8.8.8.8,8.8.4.4
server=8.8.8.8
log-queries
log-dhcp
listen-address=127.0.0.1
listen-address=$IP_ADDR
bind-interfaces
EOF
}

setup_nat() {
    print_status "Setting up NAT for internet sharing..."
    # Enable IP forwarding
    echo 1 > /proc/sys/net/ipv4/ip_forward
    
    # Setup iptables NAT
    iptables -t nat -F
    iptables -F FORWARD
    iptables -t nat -A POSTROUTING -o "$INTERNET_IFACE" -j MASQUERADE
    iptables -A FORWARD -i "$IFACE" -o "$INTERNET_IFACE" -j ACCEPT
    iptables -A FORWARD -i "$INTERNET_IFACE" -o "$IFACE" -m state --state RELATED,ESTABLISHED -j ACCEPT
}

start_services() {
    print_status "Starting dnsmasq..."
    dnsmasq -C /tmp/dnsmasq-hotspot.conf &
    sleep 1
    
    print_status "Starting hostapd..."
    hostapd /tmp/hostapd.conf &
    sleep 2
    
    # Check if hostapd started successfully
    if pgrep -x hostapd > /dev/null; then
        print_status "Hostapd started successfully!"
        return 0
    else
        print_error "Hostapd failed to start"
        return 1
    fi
}

show_info() {
    echo ""
    echo -e "${GREEN}=== Hotspot Started ===${NC}"
    echo "  SSID:     $SSID"
    echo "  Password: $PASSWORD"
    echo "  IP:       $IP_ADDR"
    echo "  Interface: $IFACE"
    echo ""
    echo "To stop the hotspot, run:"
    echo "  sudo killall hostapd dnsmasq && sudo systemctl start NetworkManager"
}

show_usage() {
    echo "Usage: $0 [SSID] [PASSWORD]"
    echo "  SSID:     Hotspot name (default: linux)"
    echo "  PASSWORD: Hotspot password, min 8 chars (default: 12345678)"
    echo ""
    echo "Examples:"
    echo "  $0                      # Uses defaults"
    echo "  $0 MyHotspot            # Custom SSID, default password"
    echo "  $0 MyHotspot secret123  # Custom SSID and password"
    echo ""
    echo "To stop: sudo killall hostapd dnsmasq && sudo systemctl start NetworkManager"
}

main() {
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        show_usage
        exit 0
    fi
    
    if [[ "$1" == "stop" ]]; then
        print_status "Stopping hotspot..."
        killall hostapd 2>/dev/null || true
        killall dnsmasq 2>/dev/null || true
        ip addr flush dev "$IFACE" 2>/dev/null || true
        systemctl start NetworkManager
        print_status "Hotspot stopped, NetworkManager restarted"
        exit 0
    fi

    echo "========================================"
    echo "  Arch Linux WiFi Hotspot (hostapd)"
    echo "  Intel Wi-Fi 6E AX211 / Acer"
    echo "========================================"
    echo ""

    check_root
    check_dependencies
    cleanup
    stop_conflicting_services
    setup_interface
    create_hostapd_config
    create_dnsmasq_config
    setup_nat
    
    if start_services; then
        show_info
    else
        print_error "Failed to start hotspot"
        echo ""
        echo "Check hostapd output for errors. Common issues:"
        echo "  - Channel not supported (try channel 1 or 6)"
        echo "  - Driver doesn't support AP mode"
        echo ""
        systemctl start NetworkManager
        exit 1
    fi
}

main "$@"
