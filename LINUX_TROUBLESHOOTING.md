# 🐧 Linux Deployment Troubleshooting Guide

This guide addresses common network errors encountered when running the Three-Tier Task Management Application on clean Linux machines.

## 🚨 Common Network Errors and Solutions

### 1. **Connection Refused Errors**

**Symptoms:**
```
Error: connect ECONNREFUSED 127.0.0.1:3001
Failed to fetch from http://localhost:3001/api/tasks
```

**Causes & Solutions:**

#### A. Firewall Blocking Ports
**Ubuntu/Debian:**
```bash
# Check firewall status
sudo ufw status

# Allow required ports
sudo ufw allow 3000/tcp
sudo ufw allow 3001/tcp
sudo ufw allow 5432/tcp

# Or allow port range
sudo ufw allow 3000:5432/tcp
```

**RHEL/CentOS/Fedora:**
```bash
# Check firewall status
sudo firewall-cmd --state
sudo firewall-cmd --list-all

# Allow ports permanently
sudo firewall-cmd --permanent --add-port=3000/tcp
sudo firewall-cmd --permanent --add-port=3001/tcp
sudo firewall-cmd --permanent --add-port=5432/tcp
sudo firewall-cmd --reload
```

#### B. SELinux Blocking Docker (RHEL-based systems)
```bash
# Check SELinux status
getenforce

# If enforcing, allow Docker containers
sudo setsebool -P container_manage_cgroup on
sudo setsebool -P container_connect_any on

# Or temporarily disable for testing
sudo setenforce 0
```

#### C. Docker Permission Issues
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Apply group changes without logout
newgrp docker

# Test Docker access
docker ps
```

### 2. **Port Already in Use Errors**

**Symptoms:**
```
Error starting userland proxy: listen tcp4 0.0.0.0:3000: bind: address already in use
```

**Solutions:**
```bash
# Find what's using the port
sudo lsof -i :3000
sudo lsof -i :3001
sudo lsof -i :5432

# Kill the process using the port
sudo kill -9 <PID>

# Or find and kill by port
sudo fuser -k 3000/tcp
sudo fuser -k 3001/tcp
```

### 3. **DNS Resolution Issues**

**Symptoms:**
```
getaddrinfo ENOTFOUND localhost
```

**Solutions:**
```bash
# Check /etc/hosts file
cat /etc/hosts

# Ensure localhost entries exist
echo "127.0.0.1 localhost" | sudo tee -a /etc/hosts
echo "::1 localhost" | sudo tee -a /etc/hosts

# Test resolution
ping localhost
nslookup localhost
```

### 4. **Container Network Issues**

**Symptoms:**
```
Error response from daemon: network not found
```

**Solutions:**
```bash
# Clean up Docker networks
docker network prune -f

# Remove specific network if stuck
docker network rm taskapp_network

# Restart Docker daemon
sudo systemctl restart docker

# Recreate containers
docker-compose down -v
docker-compose up --build
```

## 🔧 Environment-Specific Configurations

### Production Environment Variables

Create these files for production deployment:

**backend/.env.production:**
```env
NODE_ENV=production
PORT=3001
DB_HOST=database
DB_PORT=5432
DB_NAME=taskmanager
DB_USER=taskuser
DB_PASSWORD=your_secure_password_here
FRONTEND_URL=http://your-domain.com:3000
```

**frontend/.env.production:**
```env
REACT_APP_API_URL=http://your-server-ip:3001
HOST=0.0.0.0
PORT=3000
```

### Docker Compose Override for Linux

Create `docker-compose.override.yml`:
```yaml
services:
  frontend:
    environment:
      - HOST=0.0.0.0
    extra_hosts:
      - "host.docker.internal:host-gateway"
  
  backend:
    environment:
      - HOST=0.0.0.0
    extra_hosts:
      - "host.docker.internal:host-gateway"
```

## 🚀 Quick Start for Linux

### 1. Run Network Diagnostic
```bash
# Make diagnostic script executable
chmod +x diagnose-network.sh

# Run diagnostic
./diagnose-network.sh
```

### 2. Clean Start Process
```bash
# Ensure Docker is running
sudo systemctl start docker
sudo systemctl enable docker

# Clean previous containers
docker-compose down -v
docker system prune -f

# Check ports are free
sudo lsof -i :3000 -i :3001 -i :5432

# Start application
./start.sh
```

### 3. Verify Services
```bash
# Check container status
docker-compose ps

# Test backend health
curl http://localhost:3001/health

# Test frontend
curl http://localhost:3000

# View logs if issues persist
docker-compose logs -f
```

## 🔍 Advanced Debugging

### Network Inspection
```bash
# Inspect Docker network
docker network ls
docker network inspect taskapp_network

# Check container networking
docker-compose exec backend ip addr
docker-compose exec frontend ip addr

# Test internal connectivity
docker-compose exec frontend curl http://backend:3001/health
```

### Service Debugging
```bash
# Backend debugging
docker-compose exec backend npm run debug

# Database connectivity test
docker-compose exec backend node -e "
const { Pool } = require('pg');
const pool = new Pool({
  host: 'database',
  port: 5432,
  database: 'taskmanager',
  user: 'taskuser',
  password: 'taskpass123'
});
pool.query('SELECT NOW()').then(res => console.log('DB OK:', res.rows[0])).catch(console.error);
"
```

### Log Analysis
```bash
# Comprehensive logs
docker-compose logs --tail=100 -f

# Service-specific logs
docker-compose logs backend
docker-compose logs frontend
docker-compose logs database

# System logs
journalctl -u docker.service --tail=50
```

## 🐛 Common Linux Distribution Issues

### Ubuntu/Debian Specific
```bash
# Update package list
sudo apt update

# Install required packages
sudo apt install curl netcat-openbsd

# If AppArmor is blocking Docker
sudo aa-status
sudo systemctl reload apparmor
```

### RHEL/CentOS/Fedora Specific
```bash
# Install required packages
sudo dnf install curl nc

# Docker storage driver issues
sudo systemctl stop docker
sudo rm -rf /var/lib/docker
sudo systemctl start docker
```

### Arch Linux Specific
```bash
# Install Docker
sudo pacman -S docker docker-compose

# Enable Docker service
sudo systemctl enable docker.service
sudo systemctl start docker.service
```

## 🆘 Emergency Recovery

If nothing works, try this complete reset:

```bash
# Stop all containers
docker-compose down -v

# Remove all Docker data
docker system prune -a -f
docker volume prune -f

# Reset network
sudo systemctl restart docker

# Disable firewall temporarily for testing
sudo ufw disable  # Ubuntu
# OR
sudo systemctl stop firewalld  # RHEL

# Start fresh
./start.sh
```

## 📞 Getting Help

If you're still experiencing issues:

1. Run the diagnostic script: `./diagnose-network.sh`
2. Check logs: `docker-compose logs -f`
3. Verify system requirements
4. Create an issue with the diagnostic output

## 🔗 Useful Resources

- [Docker Installation Guide](https://docs.docker.com/engine/install/)
- [Docker Post-Installation Steps](https://docs.docker.com/engine/install/linux-postinstall/)
- [UFW Documentation](https://help.ubuntu.com/community/UFW)
- [Firewalld Documentation](https://firewalld.org/documentation/)
- [SELinux and Docker](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux_atomic_host/7/html/container_security_guide/docker_selinux_security_policy)