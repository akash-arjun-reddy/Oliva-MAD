#!/usr/bin/env python3
"""
Simple script to get your current IP address
Run this script to see your current IP address
"""

import socket
import subprocess
import sys
import platform

def get_local_ip():
    """Get the local IP address of this machine"""
    try:
        # Create a socket to get local IP
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        local_ip = s.getsockname()[0]
        s.close()
        return local_ip
    except Exception as e:
        print(f"Error getting local IP: {e}")
        return None

def get_all_ips():
    """Get all IP addresses on this machine"""
    ips = []
    try:
        # Get all network interfaces
        if platform.system() == "Windows":
            result = subprocess.run(['ipconfig'], capture_output=True, text=True)
            lines = result.stdout.split('\n')
            for line in lines:
                if 'IPv4' in line and '192.168.' in line:
                    ip = line.split(':')[-1].strip()
                    if ip:
                        ips.append(ip)
        else:
            result = subprocess.run(['hostname', '-I'], capture_output=True, text=True)
            ips = result.stdout.strip().split()
    except Exception as e:
        print(f"Error getting all IPs: {e}")
    
    return ips

def main():
    print("🔍 Finding your IP addresses...")
    print("=" * 50)
    
    # Get local IP
    local_ip = get_local_ip()
    if local_ip:
        print(f"📍 Local IP: {local_ip}")
    else:
        print("❌ Could not determine local IP")
    
    print()
    
    # Get all IPs
    all_ips = get_all_ips()
    if all_ips:
        print("📋 All detected IP addresses:")
        for ip in all_ips:
            print(f"  - {ip}")
    else:
        print("❌ Could not get all IP addresses")
    
    print()
    print("💡 For your Flutter app, use the IP that starts with 192.168.x.x")
    print("🚀 Make sure your backend is running on port 8000")
    print("🔧 Backend should be accessible at: http://YOUR_IP:8000")

if __name__ == "__main__":
    main() 