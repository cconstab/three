# 🐧 Quick Linux Deployment Guide

This guide will help you deploy the Three-Tier Task App on a Linux machine with a non-localhost IP address.

## 🚀 Quick Setup

### Option 1: Automatic IP Detection (Recommended)
```bash
# Clone and setup
git clone <your-repo-url>
cd three

# The start script will automatically detect your IP
./start.sh
```

### Option 2: Manual IP Configuration
```bash
# Set your server's IP address
export HOST_IP=192.168.1.100  # Replace with your actual IP

# Start the application
./start.sh
```

### Option 3: Using Environment File
```bash
# Copy the Linux template
cp .env.linux .env

# Edit the .env file and set your IP
nano .env
# Change: HOST_IP=localhost
# To:     HOST_IP=192.168.1.100

# Start the application
./start.sh
```

## 🔍 Find Your IP Address

```bash
# Method 1: Using ip command (most Linux)
ip route get 1.1.1.1 | grep -oP 'src \K\S+'

# Method 2: Using ifconfig
ifconfig | grep -E 'inet.*broadcast' | grep -v 127.0.0.1 | awk '{print $2}'

# Method 3: Using hostname
hostname -I | awk '{print $1}'
```

## 🌐 Access Your Application

After successful deployment:
- **Frontend**: `http://YOUR-IP:3000`
- **Backend API**: `http://YOUR-IP:3001`
- **Health Check**: `curl http://YOUR-IP:3001/health`

## 🔧 Troubleshooting

If you get connection errors:

1. **Run the diagnostic script**:
   ```bash
   ./diagnose-network.sh
   ```

2. **Check if HOST_IP is set**:
   ```bash
   echo $HOST_IP
   ```

3. **Verify the services are using the correct IP**:
   ```bash
   docker-compose logs | grep "HOST_IP\|REACT_APP_API_URL"
   ```

4. **Test connectivity**:
   ```bash
   curl http://$HOST_IP:3001/health
   curl http://$HOST_IP:3000
   ```

## 🔒 Firewall Configuration

### Ubuntu/Debian:
```bash
sudo ufw allow 3000:3001/tcp
sudo ufw status
```

### RHEL/CentOS/Fedora:
```bash
sudo firewall-cmd --permanent --add-port=3000-3001/tcp
sudo firewall-cmd --reload
sudo firewall-cmd --list-ports
```

## 🐋 Docker Commands

```bash
# Check container status
docker-compose ps

# View logs
docker-compose logs -f

# Restart with new IP
export HOST_IP=new-ip-address
docker-compose down
docker-compose up -d

# Clean restart
docker-compose down -v
docker-compose up --build -d
```

## ⚠️ Common Issues

### 1. CORS Errors
The backend automatically allows your HOST_IP. If you still get CORS errors:
```bash
# Check backend logs for CORS configuration
docker-compose logs backend | grep "CORS enabled"
```

### 2. Connection Refused
```bash
# Check if services are listening on the right interface
docker-compose exec backend netstat -tlnp
docker-compose exec frontend netstat -tlnp
```

### 3. IP Detection Failed
```bash
# Manually set the IP
export HOST_IP=192.168.1.100
docker-compose down && docker-compose up -d
```

## 🎯 One-Line Commands

```bash
# Quick deploy with auto IP detection
curl -sSL your-repo-url/start.sh | bash

# Deploy with specific IP
HOST_IP=192.168.1.100 ./start.sh

# Reset and redeploy
docker-compose down -v && ./start.sh
```

## 📱 Mobile/Remote Access

To access from other devices on your network:
1. Ensure your HOST_IP is set to your actual network IP (not localhost)
2. Configure firewall to allow incoming connections on ports 3000-3001
3. Access from other devices using: `http://YOUR-SERVER-IP:3000`

## 🔍 Verification

After deployment, verify everything works:
```bash
# Health check
curl http://$HOST_IP:3001/health

# API test
curl http://$HOST_IP:3001/api/stats

# Frontend test
curl -I http://$HOST_IP:3000
```

You should see successful responses from all endpoints.