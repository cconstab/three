#!/bin/bash

# Three-Tier Application Ubuntu VM Launcher
set -e

echo "🚀 Three-Tier Task Management Application - Ubuntu VM Mode"
echo "============================================================"

# Function to detect host IP
detect_host_ip() {
    local detected_ip=""
    
    # Try different methods to detect IP
    if command -v ip >/dev/null 2>&1; then
        # Linux with ip command - handle potential pipe errors
        detected_ip=$(ip route get 1.1.1.1 2>/dev/null | grep -oE 'src [0-9.]+' | awk '{print $2}' | head -1 2>/dev/null || echo "")
    fi
    
    if [[ -z "$detected_ip" ]] && command -v ifconfig >/dev/null 2>&1; then
        # Linux/macOS with ifconfig - handle potential pipe errors
        detected_ip=$(ifconfig 2>/dev/null | grep -E 'inet.*broadcast' | grep -v 127.0.0.1 | awk '{print $2}' | head -1 2>/dev/null || echo "")
    fi
    
    # Fallback to localhost if detection fails
    if [[ -z "$detected_ip" || "$detected_ip" == "127.0.0.1" ]]; then
        HOST_IP="localhost"
    else
        HOST_IP="$detected_ip"
    fi
    
    echo "🌐 Detected host IP: $HOST_IP"
}

# Check if HOST_IP is already set
if [[ -z "$HOST_IP" ]]; then
    detect_host_ip
fi

export HOST_IP

echo "🔧 Using HOST_IP: $HOST_IP"
echo "🏗️ Building and starting Ubuntu VM with full application stack..."

# Check if docker compose is available
if ! command -v docker >/dev/null 2>&1; then
    echo "❌ Docker is not installed or not in PATH"
    exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
    echo "❌ Docker Compose plugin is not available"
    exit 1
fi

# Build and start the VM
echo "📦 Building VM image..."
if ! docker compose -f docker-compose.vm.yml build --quiet; then
    echo "❌ Failed to build VM image"
    exit 1
fi

echo "🚀 Starting VM container..."
if ! docker compose -f docker-compose.vm.yml up -d; then
    echo "❌ Failed to start VM container"
    exit 1
fi

echo ""
echo "⏳ Waiting for services to start..."
sleep 10

# Wait for health check
echo "🔍 Checking service health..."
for i in {1..30}; do
    # Check if container is running first
    if ! docker compose -f docker-compose.vm.yml ps --format json | grep -q "running"; then
        echo "   Container not running yet, waiting... (${i}/30)"
        sleep 2
        continue
    fi
    
    # Try health check
    if docker compose -f docker-compose.vm.yml exec -T ubuntu-vm timeout 5 curl -f http://localhost:3001/health >/dev/null 2>&1; then
        echo "✅ Services are healthy!"
        break
    fi
    echo "   Services not ready yet, waiting... (${i}/30)"
    sleep 2
done

echo ""
echo "🎉 Ubuntu VM with Three-Tier Application is ready!"
echo ""
echo "📱 Access Points:"
echo "  Web App:       http://$HOST_IP:3000"
echo "  API (proxy):   http://$HOST_IP:3000/api"
echo "  Health:        http://$HOST_IP:3000/health"
echo "  SSH Access:    ssh developer@$HOST_IP -p 2222"
echo "  Root SSH:      ssh root@$HOST_IP -p 2222"
echo "  PostgreSQL:    $HOST_IP:5432"
echo ""
echo "🔐 Credentials:"
echo "  SSH User:      developer / developer123"
echo "  SSH Root:      root / root123"
echo "  Database:      taskuser / taskpass123"
echo ""
echo "🔍 Health Checks:"
echo "  curl http://$HOST_IP:3000/health"
echo "  curl http://$HOST_IP:3000/api/stats"
echo ""
echo "📋 Management Commands:"
echo "  View logs:     docker compose -f docker-compose.vm.yml logs -f"
echo "  SSH into VM:   ssh developer@$HOST_IP -p 2222"
echo "  Stop VM:       docker compose -f docker-compose.vm.yml down"
echo "  VM shell:      docker compose -f docker-compose.vm.yml exec ubuntu-vm bash"
echo ""
echo "🔧 Inside the VM, you can:"
echo "  - Check services: sudo supervisorctl status"
echo "  - View app logs: tail -f /var/log/backend.out.log"
echo "  - Restart services: sudo supervisorctl restart backend"
echo "  - Access database: psql -U taskuser -d taskmanager -h localhost"
echo ""

# Try to open browser if on macOS/Linux with GUI
if command -v open &> /dev/null; then
    echo "🌐 Opening browser..."
    open "http://$HOST_IP:3000" 2>/dev/null || true
elif command -v xdg-open &> /dev/null; then
    echo "🌐 Opening browser..."
    xdg-open "http://$HOST_IP:3000" 2>/dev/null || true
fi