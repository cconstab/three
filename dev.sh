#!/bin/bash

# Development helper script
echo "🛠️  Task App Development Helper"
echo ""

show_help() {
    echo "Usage: ./dev.sh [command]"
    echo ""
    echo "Commands:"
    echo "  start     - Start all services"
    echo "  stop      - Stop all services"
    echo "  restart   - Restart all services"
    echo "  logs      - Show logs for all services"
    echo "  backend   - Show backend logs only"
    echo "  frontend  - Show frontend logs only"
    echo "  database  - Show database logs only"
    echo "  clean     - Stop and remove all containers and volumes"
    echo "  shell     - Open shell in backend container"
    echo "  db        - Connect to database"
    echo "  test      - Run API tests"
    echo "  status    - Show service status"
    echo "  help      - Show this help"
}

case "$1" in
    "start")
        echo "🚀 Starting services..."
        docker compose up -d
        ;;
    "stop")
        echo "⏹️  Stopping services..."
        docker compose down
        ;;
    "restart")
        echo "🔄 Restarting services..."
        docker compose down
        docker compose up -d
        ;;
    "logs")
        echo "📋 Showing all logs..."
        docker compose logs -f
        ;;
    "backend")
        echo "📋 Showing backend logs..."
        docker compose logs -f backend
        ;;
    "frontend")
        echo "📋 Showing frontend logs..."
        docker compose logs -f frontend
        ;;
    "database")
        echo "📋 Showing database logs..."
        docker compose logs -f database
        ;;
    "clean")
        echo "🧹 Cleaning up..."
        docker compose down -v --remove-orphans
        docker system prune -f
        ;;
    "shell")
        echo "🐚 Opening backend shell..."
        docker compose exec backend /bin/sh
        ;;
    "db")
        echo "🗄️  Connecting to database..."
        docker compose exec database psql -U taskuser -d taskmanager
        ;;
    "test")
        echo "🧪 Running API tests..."
        echo "Health check:"
        curl -s http://localhost:3001/health | jq .
        echo ""
        echo "API Stats:"
        curl -s http://localhost:3001/api/stats | jq .
        echo ""
        echo "Sample tasks:"
        curl -s http://localhost:3001/api/tasks | jq '.data[:3]'
        ;;
    "status")
        echo "📊 Service Status:"
        docker compose ps
        echo ""
        echo "🔍 Health Checks:"
        echo -n "Backend: "
        if curl -f -s http://localhost:3001/health > /dev/null; then
            echo "✅ Healthy"
        else
            echo "❌ Unhealthy"
        fi
        echo -n "Frontend: "
        if curl -f -s http://localhost:3000 > /dev/null; then
            echo "✅ Healthy"
        else
            echo "❌ Unhealthy"
        fi
        echo -n "Database: "
        if docker compose exec -T database pg_isready -U taskuser -d taskmanager > /dev/null 2>&1; then
            echo "✅ Healthy"
        else
            echo "❌ Unhealthy"
        fi
        ;;
    "help"|"")
        show_help
        ;;
    *)
        echo "❌ Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac