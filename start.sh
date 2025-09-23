#!/bin/bash

# Three-Tier Task App - Quick Start Script
echo "🚀 Starting Three-Tier Task Management Application..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker-compose > /dev/null 2>&1; then
    echo "❌ Docker Compose is not installed. Please install it and try again."
    exit 1
fi

echo "✅ Docker and Docker Compose are available"

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
docker-compose up --build -d

echo "⏳ Waiting for services to be ready..."

# Wait for database to be healthy
echo "🗄️  Waiting for database..."
while ! docker-compose exec -T database pg_isready -U taskuser -d taskmanager > /dev/null 2>&1; do
    echo "   Database not ready yet, waiting..."
    sleep 2
done

# Wait for backend to be healthy
echo "🔧 Waiting for backend API..."
while ! curl -f http://localhost:3001/health > /dev/null 2>&1; do
    echo "   Backend not ready yet, waiting..."
    sleep 2
done

# Wait for frontend to be ready
echo "🎨 Waiting for frontend..."
while ! curl -f http://localhost:3000 > /dev/null 2>&1; do
    echo "   Frontend not ready yet, waiting..."
    sleep 2
done

echo ""
echo "🎉 Application is ready!"
echo ""
echo "📱 Frontend:  http://localhost:3000"
echo "🔧 Backend:   http://localhost:3001"
echo "🗄️  Database: localhost:5432"
echo ""
echo "🔍 Health Check: curl http://localhost:3001/health"
echo "📊 API Stats:    curl http://localhost:3001/api/stats"
echo ""
echo "📋 To view logs: docker-compose logs -f"
echo "⏹️  To stop:     docker-compose down"
echo ""

# Open browser (optional)
if command -v open > /dev/null 2>&1; then
    echo "🌐 Opening browser..."
    open http://localhost:3000
elif command -v xdg-open > /dev/null 2>&1; then
    echo "🌐 Opening browser..."
    xdg-open http://localhost:3000
fi