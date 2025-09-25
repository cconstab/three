#!/bin/bash

# VM Stack Management Script - 4-Tier Architecture
set -e

# Load environment variables from .env file if it exists
if [ -f .env ]; then
    echo "📄 Loading configuration from .env file..."
    set -a  # automatically export all variables
    source .env
    set +a  # disable auto-export
else
    echo "⚠️  No .env file found, using defaults"
fi

COMPOSE_FILE="docker-compose.vmstack.yml"

show_help() {
    echo "🏗️ Three-Tier Application VM Stack Manager (4 VMs)"
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  start      Start all VM containers"
    echo "  stop       Stop all VM containers"
    echo "  restart    Restart all VM containers"
    echo "  rebuild    Rebuild and restart all VMs (fresh start)"
    echo "  logs       Show logs from all VMs"
    echo "  status     Show status of all VMs"
    echo "  shell      Open shell in specified VM"
    echo "  clean      Stop VMs and remove volumes (DESTRUCTIVE)"
    echo "  help       Show this help message"
    echo ""
    echo "VM Containers:"
    echo "  nginx      - Reverse proxy and static file server"
    echo "  frontend   - React development server"
    echo "  backend    - Node.js API server"
    echo "  database   - PostgreSQL database"
    echo ""
    echo "Examples:"
    echo "  $0 start                    # Start all VMs"
    echo "  $0 logs -f                  # Follow logs from all VMs"
    echo "  $0 shell nginx              # Get shell in nginx VM"
    echo "  $0 shell backend            # Get shell in backend VM"
}

detect_api_url() {
    # Try environment variable first
    if [ -n "$REACT_APP_API_URL" ]; then
        API_URL="$REACT_APP_API_URL"
    # Then try .env file
    elif [ -f ".env" ] && grep -q "REACT_APP_API_URL" .env; then
        API_URL=$(grep "REACT_APP_API_URL" .env | cut -d'=' -f2)
        echo "📄 Using API URL from .env file: $API_URL"
    else
        # Cross-platform IP detection
        if [[ "$(uname)" == "Linux" ]]; then
            DETECTED_IP=$(hostname -I | awk '{print $1}')
        elif [[ "$(uname)" == "Darwin" ]]; then
            DETECTED_IP=$(ipconfig getifaddr en0)
            if [ -z "$DETECTED_IP" ]; then
                DETECTED_IP=$(ipconfig getifaddr en1)
            fi
        else
            DETECTED_IP=""
        fi
        if [ -z "$DETECTED_IP" ]; then
            echo "⚠️ Could not auto-detect IP address. Please set REACT_APP_API_URL in .env file."
            exit 1
        fi
        API_URL="http://$DETECTED_IP:3000"
    fi
    
    # Extract HOST_IP from API_URL
    HOST_IP=$(echo "$API_URL" | sed 's|http://||' | sed 's|:.*||')
    export HOST_IP
    export REACT_APP_API_URL="$API_URL"
    export FRONTEND_URL="$API_URL"
}

case "${1:-help}" in
    start)
        detect_api_url
        echo "🌐 Using Host IP: $HOST_IP"
        echo "🌐 API URL: $API_URL"
        echo "🚀 Starting VM Stack (4 containers)..."
        
        # Start services in order
        docker compose -f $COMPOSE_FILE up -d database
        echo "⏳ Waiting for database to be ready..."
        sleep 5
        
        docker compose -f $COMPOSE_FILE up -d backend
        echo "⏳ Waiting for backend to be ready..."
        sleep 3
        
        docker compose -f $COMPOSE_FILE up -d frontend
        echo "⏳ Waiting for frontend to be ready..."
        sleep 3
        
        docker compose -f $COMPOSE_FILE up -d nginx
        echo "⏳ Waiting for nginx to be ready..."
        sleep 2
        
        # Get configuration from environment or defaults
        HOST_IP=${HOST_IP:-localhost}
        EXTERNAL_PORT=${EXTERNAL_PORT:-3000}
        
        echo ""
        echo "🎉 VM Stack is ready!"
        echo ""
        echo "📱 Access Points:"
        echo "  Web App:       http://$HOST_IP:$EXTERNAL_PORT"
        echo "  API (proxy):   http://$HOST_IP:$EXTERNAL_PORT/api"
        echo "  Health Check:  http://$HOST_IP:$EXTERNAL_PORT/health"
        echo ""
        echo "🔒 Internal Services (not externally accessible):"
        echo "  Backend VM:    backend-vm:3001"
        echo "  Frontend VM:   frontend-vm:3000"
        echo "  Database VM:   database-vm:5432"
        echo ""
        echo "🔍 Health Checks:"
        echo "  curl http://$HOST_IP:$EXTERNAL_PORT/health"
        echo "  curl http://$HOST_IP:$EXTERNAL_PORT/api/stats"
        echo ""
        ;;
    stop)
        echo "⏹️ Stopping VM Stack..."
        docker compose -f $COMPOSE_FILE down
        echo "✅ VM Stack stopped"
        ;;
    restart)
        echo "🔄 Restarting VM Stack..."
        docker compose -f $COMPOSE_FILE down
        $0 start
        ;;
    rebuild)
        echo "🏗️ Rebuilding VM Stack (fresh start)..."
        docker compose -f $COMPOSE_FILE down -v
        docker compose -f $COMPOSE_FILE build --no-cache
        $0 start
        ;;
    logs)
        shift
        echo "📋 VM Stack Logs:"
        docker compose -f $COMPOSE_FILE logs "$@"
        ;;
    shell)
        if [ -z "$2" ]; then
            echo "❌ Please specify which VM to shell into:"
            echo "  nginx, frontend, backend, database"
            exit 1
        fi
        echo "💻 Opening shell in $2 VM..."
        docker compose -f $COMPOSE_FILE exec "$2" /bin/bash
        ;;
    status)
        echo "📊 VM Stack Status:"
        echo ""
        docker compose -f $COMPOSE_FILE ps
        ;;
    clean)
        echo "🧹 Cleaning up VM Stack and data..."
        read -p "This will remove all VM data. Continue? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker compose -f $COMPOSE_FILE down -v --remove-orphans
            echo "✅ VM Stack and data cleaned"
        else
            echo "❌ Cancelled"
        fi
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "❌ Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
