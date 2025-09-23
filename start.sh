#!/bin/bash

# Three-Tier Task App - Quick Start Script
echo "🚀 Starting Three-Tier Task Management Application..."

# Function to detect host IP
detect_host_ip() {
    # Try to detect the primary network interface IP
    if command -v ip &> /dev/null; then
        # Linux with ip command
        HOST_IP=$(ip route get 1.1.1.1 | grep -oP 'src \K\S+' 2>/dev/null)
    elif command -v ifconfig &> /dev/null; then
        # Linux/macOS with ifconfig
        HOST_IP=$(ifconfig | grep -E 'inet.*broadcast' | grep -v 127.0.0.1 | awk '{print $2}' | head -1)
    fi
    
    # Fallback to localhost if detection fails
    if [[ -z "$HOST_IP" || "$HOST_IP" == "127.0.0.1" ]]; then
        HOST_IP="localhost"
    fi
    
    echo "🌐 Detected host IP: $HOST_IP"
}

# Function to validate hostname/IP
validate_host() {
    local host="$1"
    
    # Check if it's an IP address
    if [[ $host =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        echo "📍 Using IP address: $host"
        return 0
    # Check if it's a hostname
    elif [[ $host =~ ^[a-zA-Z0-9][a-zA-Z0-9\.-]*[a-zA-Z0-9]$ ]] || [[ $host == "localhost" ]]; then
        echo "🏷️  Using hostname: $host"
        echo "ℹ️  Note: React dev server host check is disabled for hostname support"
        return 0
    else
        echo "⚠️  Warning: '$host' may not be a valid hostname or IP"
        return 1
    fi
}

# Detect host IP if not already set
if [[ -z "$HOST_IP" ]]; then
    detect_host_ip
fi

# Validate the HOST_IP
validate_host "$HOST_IP"

# Export HOST_IP for Docker Compose
export HOST_IP

echo "🔧 Using HOST_IP: $HOST_IP"

# Check if production mode is requested
PRODUCTION_MODE=${PRODUCTION:-false}

if [[ "$PRODUCTION_MODE" == "true" ]]; then
    echo "🏭 Starting in PRODUCTION mode (static files, no host check issues)"
    COMPOSE_FILES="-f docker-compose.yml -f docker-compose.prod.yml"
else
    echo "🛠️  Starting in DEVELOPMENT mode"
    if [[ "$HOST_IP" != "localhost" && "$HOST_IP" != "127.0.0.1" ]]; then
        echo "⚠️  WARNING: Development mode with external hostname may show 'Invalid Host header'"
        echo "   For production deployment, use: PRODUCTION=true ./start.sh"
        echo "   Or access via: http://localhost:3000 (port forwarding)"
    fi
    COMPOSE_FILES="-f docker-compose.yml"
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker > /dev/null 2>&1; then
    echo "❌ Docker is not installed. Please install Docker and try again."
    exit 1
fi

# Check if Docker Compose plugin is available
if ! docker compose version > /dev/null 2>&1; then
    echo "❌ Docker Compose plugin is not available. Please install Docker Compose or update Docker."
    exit 1
fi

echo "✅ Docker and Docker Compose plugin are available"

# Create environment files if they don't exist
if [ ! -f backend/.env ]; then
    echo "📄 Creating backend environment file..."
    cp backend/.env.example backend/.env
fi

if [ ! -f frontend/.env ]; then
    echo "📄 Creating frontend environment file..."
    cp frontend/.env.example frontend/.env
fi

echo "🏗️  Building and starting services..."

# Build and start all services
docker compose $COMPOSE_FILES up --build -d

echo "⏳ Waiting for services to be ready..."

# Wait for database to be healthy
echo "🗄️  Waiting for database..."
while ! docker compose exec -T database pg_isready -U taskuser -d taskmanager > /dev/null 2>&1; do
    echo "   Database not ready yet, waiting..."
    sleep 2
done

# Wait for backend to be healthy
echo "🔧 Waiting for backend API..."
while ! curl -f http://${HOST_IP}:3001/health > /dev/null 2>&1; do
    echo "   Backend not ready yet, waiting..."
    sleep 2
done

# Wait for frontend to be ready
echo "🎨 Waiting for frontend..."
while ! curl -f http://${HOST_IP}:3000 > /dev/null 2>&1; do
    echo "   Frontend not ready yet, waiting..."
    sleep 2
done

echo ""
echo "🎉 Application is ready!"
echo ""
echo "📱 Frontend:  http://${HOST_IP}:3000"
echo "🔧 Backend:   http://${HOST_IP}:3001"
echo "🗄️  Database: ${HOST_IP}:5432"
echo ""
echo "🔍 Health Check: curl http://${HOST_IP}:3001/health"
echo "📊 API Stats:    curl http://${HOST_IP}:3001/api/stats"
echo ""
echo "📋 To view logs: docker compose logs -f"
echo "⏹️  To stop:     docker compose down"
echo ""

# Open browser (optional)
if command -v open > /dev/null 2>&1; then
    echo "🌐 Opening browser..."
    open http://${HOST_IP}:3000
elif command -v xdg-open > /dev/null 2>&1; then
    echo "🌐 Opening browser..."
    xdg-open http://${HOST_IP}:3000
fi