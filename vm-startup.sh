#!/bin/bash
set -e

echo "🚀 Starting Three-Tier Application VM..."

# Set HOST_IP if not provided
if [ -z "$HOST_IP" ]; then
    HOST_IP="localhost"
fi

echo "🌐 Using HOST_IP: $HOST_IP"

# Update backend environment with HOST_IP
export HOST_IP=$HOST_IP
export FRONTEND_URL="http://$HOST_IP:3000"
export REACT_APP_API_URL="http://$HOST_IP:3001"

# Build frontend with correct API URL
echo "🏗️ Building frontend with API URL: $REACT_APP_API_URL"
cd /app/frontend
npm run build
cd /app

# Copy built frontend to nginx directory
echo "📋 Copying frontend build to nginx directory..."
cp -r /app/frontend/build/* /var/www/html/

# Ensure PostgreSQL directories exist with correct permissions
mkdir -p /var/lib/postgresql/14/main
mkdir -p /var/log/postgresql
chown -R postgres:postgres /var/lib/postgresql
chown -R postgres:postgres /var/log/postgresql

# Check if this is first run (no database initialized)
FIRST_RUN=false
if [ ! -f /var/lib/postgresql/14/main/.db_initialized ]; then
    FIRST_RUN=true
    echo "📦 First run detected - initializing PostgreSQL database..."
    
    # Clear any existing data directory contents for fresh initialization
    rm -rf /var/lib/postgresql/14/main/*
    
    # Initialize PostgreSQL cluster
    su - postgres -c "/usr/lib/postgresql/14/bin/initdb -D /var/lib/postgresql/14/main"
    
    # Copy configuration files from system location to data directory
    cp /etc/postgresql/14/main/postgresql.conf /var/lib/postgresql/14/main/
    cp /etc/postgresql/14/main/pg_hba.conf /var/lib/postgresql/14/main/
    cp /etc/postgresql/14/main/pg_ident.conf /var/lib/postgresql/14/main/
    chown postgres:postgres /var/lib/postgresql/14/main/*.conf
    
    # Create conf.d directory if it doesn't exist
    mkdir -p /var/lib/postgresql/14/main/conf.d
    chown postgres:postgres /var/lib/postgresql/14/main/conf.d
    
    # Configure PostgreSQL for remote connections in a separate config file
    cat > /var/lib/postgresql/14/main/conf.d/custom.conf << EOF
listen_addresses = '*'
port = 5432
EOF
    chown postgres:postgres /var/lib/postgresql/14/main/conf.d/custom.conf
    
    # Add remote access to pg_hba.conf
    echo "host all all all md5" >> /var/lib/postgresql/14/main/pg_hba.conf
fi

# Start supervisor to manage all services
echo "🔄 Starting all services..."
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf &
SUPERVISOR_PID=$!

# If this is first run, set up database after PostgreSQL starts
if [ "$FIRST_RUN" = true ]; then
    echo "⏳ Waiting for PostgreSQL to start..."
    
    # Wait for PostgreSQL to be ready
    for i in {1..30}; do
        if su - postgres -c "psql -l" >/dev/null 2>&1; then
            echo "✅ PostgreSQL is ready!"
            break
        fi
        echo "   Waiting for PostgreSQL... ($i/30)"
        sleep 2
    done
    
    echo "👤 Creating database user and database..."
    # Create user and database
    su - postgres -c "psql -c \"CREATE USER taskuser WITH SUPERUSER PASSWORD 'taskpass123';\""
    su - postgres -c "psql -c \"CREATE DATABASE taskmanager OWNER taskuser;\""
    
    # Load initial data
    if [ -f /app/database/init.sql ]; then
        echo "📊 Loading initial data..."
        su - postgres -c "psql -d taskmanager -f /app/database/init.sql"
    fi
    
    echo "✅ Database initialization complete!"
    
    # Create a marker file to indicate database is initialized
    touch /var/lib/postgresql/14/main/.db_initialized
else
    echo "♻️  Using existing database..."
    
    # Ensure configuration files exist in data directory
    if [ ! -f /var/lib/postgresql/14/main/postgresql.conf ]; then
        echo "🔧 Copying missing configuration files..."
        cp /etc/postgresql/14/main/postgresql.conf /var/lib/postgresql/14/main/
        cp /etc/postgresql/14/main/pg_hba.conf /var/lib/postgresql/14/main/
        cp /etc/postgresql/14/main/pg_ident.conf /var/lib/postgresql/14/main/
        chown postgres:postgres /var/lib/postgresql/14/main/*.conf
        
        # Create conf.d directory and custom config
        mkdir -p /var/lib/postgresql/14/main/conf.d
        chown postgres:postgres /var/lib/postgresql/14/main/conf.d
        
        cat > /var/lib/postgresql/14/main/conf.d/custom.conf << EOF
listen_addresses = '*'
port = 5432
EOF
        chown postgres:postgres /var/lib/postgresql/14/main/conf.d/custom.conf
    fi
fi

# Wait for supervisor to finish
wait $SUPERVISOR_PID