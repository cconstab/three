#!/bin/bash

# Network Diagnostic Script for Three-Tier Task App
# Use this script to troubleshoot network issues on Linux machines

echo "🔍 Three-Tier Task App - Network Diagnostic Tool"
echo "================================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
        if [ -n "$3" ]; then
            echo -e "${YELLOW}   💡 Fix: $3${NC}"
        fi
    fi
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

echo "1. 🐋 Docker System Check"
echo "------------------------"

# Check if Docker is installed
if command -v docker &> /dev/null; then
    print_status 0 "Docker is installed"
    docker --version
else
    print_status 1 "Docker is not installed" "Install Docker: https://docs.docker.com/engine/install/"
    exit 1
fi

# Check if Docker daemon is running
if docker info &> /dev/null; then
    print_status 0 "Docker daemon is running"
else
    print_status 1 "Docker daemon is not running" "Start Docker service: sudo systemctl start docker"
    exit 1
fi

# Check if Docker Compose is available
if command -v docker-compose &> /dev/null; then
    print_status 0 "Docker Compose is installed"
    docker-compose --version
elif docker compose version &> /dev/null; then
    print_status 0 "Docker Compose (plugin) is installed"
    docker compose version
else
    print_status 1 "Docker Compose is not installed" "Install Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi

echo ""
echo "2. 🔐 User Permissions Check"
echo "----------------------------"

# Check if user can run Docker without sudo
if docker ps &> /dev/null; then
    print_status 0 "User can run Docker commands"
else
    print_status 1 "User cannot run Docker without sudo" "Add user to docker group: sudo usermod -aG docker \$USER && newgrp docker"
fi

echo ""
echo "3. 🌐 Port Availability Check"
echo "-----------------------------"

check_port() {
    local port=$1
    local service=$2
    
    if netstat -tuln 2>/dev/null | grep -q ":$port "; then
        print_status 1 "Port $port is already in use" "Stop service using port $port or change $service port"
        print_info "Services using port $port:"
        lsof -i :$port 2>/dev/null || netstat -tulpn 2>/dev/null | grep ":$port "
    else
        print_status 0 "Port $port is available for $service"
    fi
}

check_port 3000 "frontend"
check_port 3001 "backend"
check_port 5432 "database"

echo ""
echo "4. 🔥 Firewall Check"
echo "-------------------"

# Check if firewall is active and might block ports
if command -v ufw &> /dev/null; then
    if ufw status | grep -q "Status: active"; then
        print_warning "UFW firewall is active"
        echo "   Current UFW rules:"
        ufw status
        print_info "If connections fail, allow ports: sudo ufw allow 3000 && sudo ufw allow 3001"
    else
        print_status 0 "UFW firewall is inactive"
    fi
elif command -v firewall-cmd &> /dev/null; then
    if firewall-cmd --state &> /dev/null; then
        print_warning "Firewalld is active"
        echo "   Current zones:"
        firewall-cmd --get-active-zones
        print_info "If connections fail, allow ports: sudo firewall-cmd --permanent --add-port=3000-3001/tcp && sudo firewall-cmd --reload"
    else
        print_status 0 "Firewalld is inactive"
    fi
elif command -v iptables &> /dev/null; then
    if iptables -L | grep -q "DROP\|REJECT"; then
        print_warning "iptables rules detected that might block traffic"
        print_info "Check iptables rules: sudo iptables -L"
    else
        print_status 0 "No blocking iptables rules detected"
    fi
fi

echo ""
echo "5. 📡 Network Connectivity Check"
echo "--------------------------------"

# Check if localhost resolves
if ping -c 1 localhost &> /dev/null; then
    print_status 0 "localhost resolves correctly"
else
    print_status 1 "localhost does not resolve" "Check /etc/hosts file for localhost entry"
fi

# Check if 127.0.0.1 is reachable
if ping -c 1 127.0.0.1 &> /dev/null; then
    print_status 0 "127.0.0.1 is reachable"
else
    print_status 1 "127.0.0.1 is not reachable" "Check network configuration"
fi

echo ""
echo "6. 🐧 SELinux Check (RHEL/CentOS/Fedora)"
echo "----------------------------------------"

if command -v getenforce &> /dev/null; then
    selinux_status=$(getenforce)
    if [ "$selinux_status" = "Enforcing" ]; then
        print_warning "SELinux is enforcing - might block Docker networking"
        print_info "Allow Docker in SELinux: sudo setsebool -P container_manage_cgroup on"
    elif [ "$selinux_status" = "Permissive" ]; then
        print_status 0 "SELinux is permissive"
    else
        print_status 0 "SELinux is disabled"
    fi
else
    print_info "SELinux not detected (not a RHEL-based system)"
fi

echo ""
echo "7. 📊 System Resources Check"
echo "----------------------------"

# Check available memory
total_mem=$(free -m | awk 'NR==2{printf "%.1f", $2/1024}')
available_mem=$(free -m | awk 'NR==2{printf "%.1f", $7/1024}')

if (( $(echo "$available_mem > 1.0" | bc -l) )); then
    print_status 0 "Sufficient memory available (${available_mem}GB available of ${total_mem}GB total)"
else
    print_status 1 "Low memory available (${available_mem}GB available of ${total_mem}GB total)" "Consider closing other applications"
fi

# Check disk space
disk_usage=$(df -h . | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$disk_usage" -lt 90 ]; then
    print_status 0 "Sufficient disk space (${disk_usage}% used)"
else
    print_status 1 "Low disk space (${disk_usage}% used)" "Free up disk space before running Docker containers"
fi

echo ""
echo "8. 🔧 Docker Network Check"
echo "--------------------------"

# Check if docker networks can be created
if docker network ls &> /dev/null; then
    print_status 0 "Docker networking is functional"
    
    # Check if the app network exists
    if docker network ls | grep -q "taskapp_network"; then
        print_info "taskapp_network already exists"
        docker network inspect taskapp_network --format='{{.Driver}}' | head -1
    else
        print_info "taskapp_network will be created when starting the app"
    fi
else
    print_status 1 "Docker networking is not functional" "Restart Docker daemon: sudo systemctl restart docker"
fi

echo ""
echo "9. 🌍 DNS Resolution Check"
echo "--------------------------"

# Check if external DNS works (needed for pulling images)
if nslookup docker.io &> /dev/null; then
    print_status 0 "External DNS resolution works"
else
    print_status 1 "External DNS resolution failed" "Check DNS settings in /etc/resolv.conf"
fi

echo ""
echo "10. 📋 Container Status Check"
echo "----------------------------"

if docker-compose ps &> /dev/null 2>&1; then
    echo "Current container status:"
    docker-compose ps
    
    # Check if containers are running
    if docker-compose ps | grep -q "Up"; then
        print_info "Some containers are running"
        
        # Test connectivity to running services
        echo ""
        echo "🔗 Testing service connectivity:"
        
        if curl -f -s http://localhost:3001/health &> /dev/null; then
            print_status 0 "Backend API is responding"
        else
            print_status 1 "Backend API is not responding" "Check backend logs: docker-compose logs backend"
        fi
        
        if curl -f -s http://localhost:3000 &> /dev/null; then
            print_status 0 "Frontend is responding"
        else
            print_status 1 "Frontend is not responding" "Check frontend logs: docker-compose logs frontend"
        fi
    else
        print_info "No containers are currently running"
    fi
else
    print_info "No docker-compose services found in current directory"
fi

echo ""
echo "🎯 Quick Fixes for Common Issues:"
echo "================================="
echo ""
echo "1. 🔥 Firewall blocking connections:"
echo "   Ubuntu/Debian: sudo ufw allow 3000:3001/tcp"
echo "   RHEL/CentOS:   sudo firewall-cmd --permanent --add-port=3000-3001/tcp && sudo firewall-cmd --reload"
echo ""
echo "2. 📦 Docker permission issues:"
echo "   sudo usermod -aG docker \$USER && newgrp docker"
echo ""
echo "3. 🌐 Port conflicts:"
echo "   Check what's using ports: sudo lsof -i :3000 -i :3001 -i :5432"
echo "   Kill conflicting processes: sudo kill -9 <PID>"
echo ""
echo "4. 🔧 SELinux issues (RHEL/CentOS):"
echo "   sudo setsebool -P container_manage_cgroup on"
echo ""
echo "5. 🐋 Reset Docker environment:"
echo "   docker-compose down -v && docker system prune -f"
echo ""
echo "6. 📝 View detailed logs:"
echo "   docker-compose logs -f"
echo ""

echo "✅ Diagnostic complete! Check the issues marked with ❌ above."