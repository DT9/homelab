#!/bin/bash

TINKERBELL_IP="10.144.0.100"
TIMEOUT=5

echo "=== Testing Tinkerbell External Ports on $TINKERBELL_IP ==="
echo

# Function to test TCP port
test_tcp_port() {
    local port=$1
    local service=$2
    echo -n "Testing TCP port $port ($service): "
    if timeout $TIMEOUT nc -z $TINKERBELL_IP $port 2>/dev/null; then
        echo "✅ OPEN"
    else
        echo "❌ CLOSED/FILTERED"
    fi
}

# Function to test UDP port
test_udp_port() {
    local port=$1
    local service=$2
    echo -n "Testing UDP port $port ($service): "
    if timeout $TIMEOUT nc -u -z $TINKERBELL_IP $port 2>/dev/null; then
        echo "✅ OPEN"
    else
        echo "❌ CLOSED/FILTERED"
    fi
}

# Function to test HTTP endpoint
test_http_endpoint() {
    local port=$1
    local service=$2
    echo -n "Testing HTTP on port $port ($service): "
    local response=$(curl -s -w "%{http_code}" --max-time $TIMEOUT http://$TINKERBELL_IP:$port/ 2>/dev/null)
    local http_code="${response: -3}"
    
    if [[ "$http_code" =~ ^[0-9]{3}$ ]]; then
        echo "✅ HTTP $http_code"
    else
        echo "❌ NO RESPONSE"
    fi
}

echo "--- Tinkerbell Service Ports ---"

# UDP Ports
test_udp_port 67 "DHCP Server"
test_udp_port 69 "TFTP Server" 
test_udp_port 514 "Syslog Server"

echo

# TCP Ports
test_tcp_port 7171 "Smee API (iPXE/Workflow)"
test_tcp_port 7172 "Tootles API (Template/Workflow)"
test_tcp_port 42113 "Additional Service"
test_tcp_port 2222 "SSH/Management"

echo

# HTTP API Tests
test_http_endpoint 7171 "Smee API"
test_http_endpoint 7172 "Tootles API"

echo
echo "--- HookOS Service Ports ---"

# HookOS TCP Port
test_tcp_port 7173 "HookOS API"
test_http_endpoint 7173 "HookOS API"

echo
echo "=== Port Test Summary ==="
echo "Tested external IP: $TINKERBELL_IP"
echo "Connection timeout: ${TIMEOUT}s"
echo
echo "Expected open ports:"
echo "  UDP: 67 (DHCP), 69 (TFTP), 514 (Syslog)"
echo "  TCP: 7171 (Smee), 7172 (Tootles), 7173 (HookOS), 42113, 2222"
echo
echo "Note: UDP tests may show false negatives due to stateless nature"
echo "HTTP 404 responses indicate the service is running but endpoint doesn't exist (normal)"