# 🖥️ Ubuntu VM Mode - Three-Tier Application

This configuration creates a Docker container that simulates a full Ubuntu VM with the complete three-tier application stack pre-installed and running.

## 🚀 Quick Start

```bash
# Start the Ubuntu VM with the application
./start-vm.sh

# Or manually with specific HOST_IP
export HOST_IP=192.168.1.100
./start-vm.sh
```

## 🌐 Access Points

Once running, you can access:

- **Frontend**: http://your-ip:3000
- **Backend API**: http://your-ip:3001  
- **SSH Access**: `ssh developer@your-ip -p 2222`
- **Root SSH**: `ssh root@your-ip -p 2222`
- **PostgreSQL**: your-ip:5432

## 🔐 Default Credentials

- **SSH User**: `developer` / `developer123`
- **SSH Root**: `root` / `root123`
- **Database**: `taskuser` / `taskpass123`

## 📋 VM Management

### SSH into the VM
```bash
# As developer user
ssh developer@localhost -p 2222

# As root user  
ssh root@localhost -p 2222

# Or use Docker exec
docker compose -f docker-compose.vm.yml exec ubuntu-vm bash
```

### Service Management (inside VM)
```bash
# Check all services status
sudo supervisorctl status

# Restart individual services
sudo supervisorctl restart backend
sudo supervisorctl restart nginx
sudo supervisorctl restart postgresql

# View service logs
tail -f /var/log/backend.out.log
tail -f /var/log/nginx.out.log
tail -f /var/log/postgresql.out.log
```

### Application Management
```bash
# Check application health
curl http://localhost:3001/health

# View API endpoints
curl http://localhost:3001/api/tasks
curl http://localhost:3001/api/stats

# Access database
psql -U taskuser -d taskmanager -h localhost
```

## 🔧 Docker Management

### Container Control
```bash
# View VM logs
docker compose -f docker-compose.vm.yml logs -f

# Stop the VM
docker compose -f docker-compose.vm.yml down

# Rebuild VM (fresh start)
docker compose -f docker-compose.vm.yml down -v
docker compose -f docker-compose.vm.yml up --build -d

# Get VM shell directly
docker compose -f docker-compose.vm.yml exec ubuntu-vm bash
```

### Persistent Data
- PostgreSQL data: `vm_data` volume
- Application logs: `vm_logs` volume

## 🏗️ What's Inside the VM

The Ubuntu container includes:

### **System Services**
- **SSH Server** (port 22) - Remote access
- **PostgreSQL 14** (port 5432) - Database server
- **Nginx** (port 3000) - Frontend web server
- **Node.js Backend** (port 3001) - API server
- **Supervisor** - Process management

### **Development Tools**
- Git, Vim, Nano, Htop
- Node.js 18.x & npm
- PostgreSQL client tools
- Network utilities (ping, telnet, netstat)

### **Application Stack**
- **Frontend**: React app built for production, served by Nginx
- **Backend**: Node.js/Express API server
- **Database**: PostgreSQL with pre-loaded sample data

## 🔍 Troubleshooting

### Check Service Status
```bash
# Inside the VM
sudo supervisorctl status

# Expected output:
# postgresql    RUNNING   pid 123, uptime 0:05:00
# backend       RUNNING   pid 124, uptime 0:05:00  
# nginx         RUNNING   pid 125, uptime 0:05:00
# sshd          RUNNING   pid 126, uptime 0:05:00
```

### View Service Logs
```bash
# Backend logs
tail -f /var/log/backend.out.log

# Nginx logs  
tail -f /var/log/nginx.out.log

# PostgreSQL logs
tail -f /var/log/postgresql.out.log

# SSH logs
tail -f /var/log/sshd.out.log
```

### Restart Services
```bash
# Restart individual service
sudo supervisorctl restart backend

# Restart all services
sudo supervisorctl restart all

# Stop and start
sudo supervisorctl stop backend
sudo supervisorctl start backend
```

### Network Issues
```bash
# Check port binding inside VM
netstat -tlnp

# Test local connections
curl http://localhost:3001/health
curl http://localhost:3000

# Check firewall (if applicable)
ufw status
```

## 🎯 Use Cases

This VM mode is perfect for:

- **Development Environment**: Full isolated development stack
- **Testing**: Test deployment scenarios without affecting host
- **Learning**: Explore Linux system administration
- **Demos**: Portable demonstration environment
- **CI/CD**: Consistent testing environment
- **Training**: Safe environment for experimenting

## ⚡ Performance Notes

- **CPU**: Shares host CPU resources
- **Memory**: Uses ~512MB-1GB RAM depending on load
- **Storage**: Persistent volumes for data
- **Network**: Bridge network with port forwarding

## 🔒 Security Notes

- **SSH**: Enabled with password authentication (development only)
- **Firewall**: Container isolation provides security boundary
- **Passwords**: Default passwords should be changed for production
- **Network**: Only specified ports are exposed to host

---

**Enjoy your containerized Ubuntu development environment!** 🎉