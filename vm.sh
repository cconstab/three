#!/bin/bash

# VM Management Script
set -e

COMPOSE_FILE="docker-compose.vm.yml"

show_help() {
    echo "🖥️ Three-Tier Application Ubuntu VM Manager"
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  start      Start the Ubuntu VM"
    echo "  stop       Stop the Ubuntu VM"
    echo "  restart    Restart the Ubuntu VM"
    echo "  rebuild    Rebuild and restart the VM (fresh start)"
    echo "  logs       Show VM logs"
    echo "  shell      Open shell inside the VM"
    echo "  exec       Execute a command inside the VM"
    echo "  ssh        SSH into the VM as developer user"
    echo "  status     Show VM and service status"
    echo "  fix-db     Fix database connection issues"
    echo "  clean      Stop VM and remove volumes (DESTRUCTIVE)"
    echo "  help       Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 start           # Start the VM"
    echo "  $0 logs -f         # Follow logs"
    echo "  $0 shell           # Get VM shell"
    echo "  $0 exec 'ps aux'   # Execute command in VM"
    echo "  $0 ssh             # SSH as developer"
    echo "  $0 fix-db          # Fix database issues"
}

case "${1:-help}" in
    start)
        # Determine API URL
        BACKEND_IP="${2}"
        if [ -z "$BACKEND_IP" ]; then
            # Try environment variable
            if [ -n "$REACT_APP_API_URL" ]; then
                API_URL="$REACT_APP_API_URL"
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
                    echo "⚠️ Could not auto-detect IP address. Please provide it as an argument or set REACT_APP_API_URL."
                    exit 1
                fi
                API_URL="http://$DETECTED_IP:3001"
            fi
        else
            API_URL="http://$BACKEND_IP:3001"
        fi

        echo "🌐 Using API URL: $API_URL"
        echo "REACT_APP_API_URL=$API_URL" > frontend/.env
        
        # Delete old build and rebuild frontend with correct API URL
        echo "🚀 Building frontend with correct API URL..."
        rm -rf frontend/build
        export REACT_APP_API_URL="$API_URL"
        (cd frontend && npm run build)

        echo "🚀 Starting Ubuntu VM..."
        export HOST_IP=$(echo "$API_URL" | sed 's|http://||' | sed 's|:3001||')
        ./start-vm.sh
        ;;
    stop)
        echo "⏹️ Stopping Ubuntu VM..."
        docker compose -f $COMPOSE_FILE down
        echo "✅ VM stopped"
        ;;
    restart)
        echo "🔄 Restarting Ubuntu VM..."
        docker compose -f $COMPOSE_FILE down
        ./start-vm.sh
        ;;
    rebuild)
        echo "🏗️ Rebuilding Ubuntu VM (fresh start)..."
        docker compose -f $COMPOSE_FILE down -v
        docker compose -f $COMPOSE_FILE build --no-cache
        # Run the same logic as start to ensure frontend is built with correct API URL
        shift
        $0 start "$@"
        ;;
    logs)
        shift
        echo "📋 VM Logs:"
        docker compose -f $COMPOSE_FILE logs "$@"
        ;;
    shell|bash)
        echo "💻 Opening VM shell..."
        docker compose -f $COMPOSE_FILE exec ubuntu-vm bash -l
        ;;
    exec)
        shift
        echo "🔧 Executing command in VM: $*"
        docker compose -f $COMPOSE_FILE exec ubuntu-vm "$@"
        ;;
    fix-db)
        echo "🔧 Fixing database issues..."
        
        # Check if VM is running
        if ! docker compose -f docker-compose.vm.yml ps --format json | grep -q "running"; then
            echo "❌ VM is not running. Start it first with: ./vm.sh start"
            exit 1
        fi
        
        echo "📦 Setting up PostgreSQL database..."
        
        # Start PostgreSQL if it's not running
        $0 exec bash -c "sudo supervisorctl start postgresql"
        sleep 3
        
        # Create database user and database
        echo "Creating database user and database..."
        $0 exec bash -c "sudo -u postgres psql -c \"DROP USER IF EXISTS taskuser;\"" || true
        $0 exec bash -c "sudo -u postgres psql -c \"CREATE USER taskuser WITH SUPERUSER PASSWORD 'taskpass123';\""
        $0 exec bash -c "sudo -u postgres psql -c \"DROP DATABASE IF EXISTS taskmanager;\"" || true
        $0 exec bash -c "sudo -u postgres psql -c \"CREATE DATABASE taskmanager OWNER taskuser;\""
        
        # Load initial data
        echo "Loading initial database schema and data..."
        $0 exec bash -c "sudo -u postgres psql -d taskmanager -f /app/database/init.sql"
        
        # Create initialization marker
        $0 exec bash -c "touch /var/lib/postgresql/14/main/.db_initialized"
        
        # Restart backend to reconnect
        echo "Restarting backend service..."
        $0 exec bash -c "sudo supervisorctl restart backend"
        
        echo "✅ Database setup complete!"
        
        # Test the connection
        echo "🔍 Testing database connection..."
        sleep 3
        if curl -f http://localhost:3001/health >/dev/null 2>&1; then
            echo "✅ Database connection successful!"
            curl http://localhost:3001/health
            echo ""
        else
            echo "❌ Still having issues. Check logs with: $0 logs"
        fi
        ;;
    ssh)
        echo "🔐 Connecting via SSH..."
        echo "Password: developer123"
        ssh developer@localhost -p 2222
        ;;
    status)
        echo "📊 VM Status:"
        echo ""
        docker compose -f $COMPOSE_FILE ps
        echo ""
        echo "🔍 Service Status (inside VM):"
        if docker compose -f $COMPOSE_FILE exec -T ubuntu-vm supervisorctl status 2>/dev/null; then
            echo "✅ VM is running"
        else
            echo "❌ VM is not running or not ready"
        fi
        ;;
    clean)
        echo "🧹 Cleaning up VM and data..."
        read -p "This will remove all VM data. Continue? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            docker compose -f $COMPOSE_FILE down -v --remove-orphans
            docker image rm three-ubuntu-vm 2>/dev/null || true
            echo "✅ VM and data cleaned"
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