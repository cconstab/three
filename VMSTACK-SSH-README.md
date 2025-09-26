# VMStack SSH - Full VM Experience

SSH-enabled version of the VMStack architecture providing traditional VM-like access to each container with SSH daemon, user accounts, and complete shell environments.

## Quick Start

```bash
# Clone and navigate
git clone <repository>
cd three

# Start SSH-enabled VM stack
./vmstack-ssh.sh start

# SSH to any VM (password: developer123)
./vmstack-ssh.sh ssh backend
./vmstack-ssh.sh ssh frontend
./vmstack-ssh.sh ssh database
./vmstack-ssh.sh ssh nginx
```

## Architecture Overview

The SSH-enabled VMStack provides a 4-tier architecture where each container functions as a complete virtual machine:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   nginx-vm      │    │  frontend-vm    │    │  backend-vm     │    │  database-vm    │
│                 │    │                 │    │                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │nginx+ssh    │ │    │ │react+ssh    │ │    │ │node.js+ssh  │ │    │ │postgres+ssh │ │
│ │port 2201    │ │    │ │port 2202    │ │    │ │port 2203    │ │    │ │port 2204    │ │
│ └─────────────┘ │    │ └─────────────┘ │    │ └─────────────┘ │    │ └─────────────┘ │
│                 │    │                 │    │                 │    │                 │
│ reverse proxy   │◄───┤ static files    │    │ REST API        │    │ data storage    │
│ load balancer   │    │ nginx server    │    │ business logic  │    │ persistence     │
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │                       │
         │                       │                       │                       │
    Port 8080                Port 3000              Port 3001              Port 5432
```

## VM Access Methods

### 1. SSH Access (Traditional VM Experience)
Each VM runs an SSH daemon with user accounts:

```bash
# SSH to any VM
ssh developer@localhost -p 2201  # nginx-vm
ssh developer@localhost -p 2202  # frontend-vm  
ssh developer@localhost -p 2203  # backend-vm
ssh developer@localhost -p 2204  # database-vm

# Or use the management script
./vmstack-ssh.sh ssh nginx
./vmstack-ssh.sh ssh frontend
./vmstack-ssh.sh ssh backend
./vmstack-ssh.sh ssh database
```

**Default Credentials:**
- **User:** `developer` / **Password:** `developer123`
- **Root:** `root` / **Password:** `root123`

### 2. Docker Shell Access
Direct container shell access for debugging:

```bash
./vmstack-ssh.sh shell nginx      # Direct container shell
./vmstack-ssh.sh shell frontend   # Direct container shell
./vmstack-ssh.sh shell backend    # Direct container shell
./vmstack-ssh.sh shell database   # Direct container shell
```

### 3. Command Execution
Execute commands in VMs without interactive sessions:

```bash
./vmstack-ssh.sh exec backend 'ps aux'
./vmstack-ssh.sh exec frontend 'ls -la /usr/share/nginx/html'
./vmstack-ssh.sh exec database 'psql -U taskuser -d taskdb -c "SELECT version();"'
./vmstack-ssh.sh exec nginx 'nginx -t'
```

## VM Details

### nginx-vm (Reverse Proxy)
- **Base:** nginx:alpine + SSH
- **Ports:** 8080:80, 8443:443, 2201:22
- **Function:** Load balancer and reverse proxy
- **SSH Access:** `ssh developer@localhost -p 2201`
- **Tools:** nginx, curl, wget, vim, htop

### frontend-vm (React Application)  
- **Base:** nginx:alpine + SSH (serves pre-built React)
- **Ports:** 3000:3000, 2202:22
- **Function:** Static file server for React production build
- **SSH Access:** `ssh developer@localhost -p 2202`
- **Content:** `/usr/share/nginx/html` (React build files)
- **Tools:** nginx, curl, wget, vim, htop

### backend-vm (API Server)
- **Base:** node:18-alpine + SSH
- **Ports:** 3001:3001, 2203:22  
- **Function:** REST API and business logic
- **SSH Access:** `ssh developer@localhost -p 2203`
- **Work Dir:** `/app`
- **Tools:** node, npm, curl, wget, vim, htop

### database-vm (PostgreSQL)
- **Base:** postgres:15-alpine + SSH
- **Ports:** 5432:5432, 2204:22
- **Function:** Data persistence and storage
- **SSH Access:** `ssh developer@localhost -p 2204`
- **Database:** taskdb (user: taskuser)
- **Tools:** psql, pg_dump, curl, wget, vim, htop

## Management Commands

### Stack Operations
```bash
./vmstack-ssh.sh start              # Start all VMs
./vmstack-ssh.sh stop               # Stop all VMs
./vmstack-ssh.sh restart            # Restart all VMs
./vmstack-ssh.sh status             # Show VM status
./vmstack-ssh.sh build              # Build VM images
./vmstack-ssh.sh rebuild            # Rebuild and restart
```

### Monitoring & Logs
```bash
./vmstack-ssh.sh logs               # All VM logs
./vmstack-ssh.sh logs backend       # Specific VM logs
./vmstack-ssh.sh info               # Connection information
./vmstack-ssh.sh ports              # Port mappings
```

## Configuration

### Environment Variables
Create `.env` file for customization:

```bash
# Database Configuration
DB_NAME=taskdb
DB_USER=taskuser
DB_PASSWORD=taskpass

# API Configuration  
REACT_APP_API_URL=http://localhost:3001

# SSH Configuration (built into images)
SSH_USER=developer
SSH_PASSWORD=developer123
```

### Port Mappings
- **8080** → nginx-vm (main application)
- **3000** → frontend-vm (direct React access)
- **3001** → backend-vm (API access)
- **5432** → database-vm (PostgreSQL)
- **2201** → nginx-vm SSH
- **2202** → frontend-vm SSH  
- **2203** → backend-vm SSH
- **2204** → database-vm SSH

## Development Workflow

### 1. Start Development Environment
```bash
./vmstack-ssh.sh start
./vmstack-ssh.sh info  # Get connection details
```

### 2. SSH into VMs for Development
```bash
# Backend development
./vmstack-ssh.sh ssh backend
cd /app
npm install  # Install new packages
npm test     # Run tests
tail -f /var/log/* # Check logs

# Frontend development  
./vmstack-ssh.sh ssh frontend
cd /usr/share/nginx/html
ls -la       # Check build files
nginx -t     # Test nginx config

# Database operations
./vmstack-ssh.sh ssh database  
psql -U taskuser -d taskdb
\dt          # List tables
SELECT * FROM tasks LIMIT 10;
```

### 3. Monitor and Debug
```bash
# Check VM health
./vmstack-ssh.sh status

# View logs
./vmstack-ssh.sh logs backend

# Execute diagnostic commands
./vmstack-ssh.sh exec nginx 'curl -I http://frontend-vm:3000'
./vmstack-ssh.sh exec backend 'curl -I http://database-vm:5432'
```

## Security Considerations

### SSH Security
- Change default passwords in production
- Use SSH keys instead of passwords
- Disable root login in production
- Configure firewall rules

### Production Hardening
```bash
# Custom user passwords (modify Dockerfiles)
RUN echo "developer:$(openssl rand -base64 32)" | chpasswd
RUN echo "root:$(openssl rand -base64 32)" | chpasswd

# SSH key authentication (add to Dockerfiles)
COPY authorized_keys /home/developer/.ssh/authorized_keys
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
```

## Troubleshooting

### SSH Connection Issues
```bash
# Check SSH service in VM
./vmstack-ssh.sh exec backend 'ps aux | grep sshd'

# Test SSH connectivity
telnet localhost 2203

# Restart SSH service
./vmstack-ssh.sh exec backend '/usr/sbin/sshd'
```

### Container Issues
```bash
# Check container status
docker ps

# Restart specific VM
docker compose -f docker-compose.vmstack-ssh.yml restart backend-vm

# Check VM logs
docker logs backend-vm
```

### Port Conflicts
```bash
# Check port usage
netstat -tulpn | grep :2203

# Kill processes using ports
lsof -ti:2203 | xargs kill -9
```

## Comparison with Other Deployments

| Feature | vmstack-ssh.sh | vmstack.sh | vm.sh | docker-compose.yml |
|---------|---------------|------------|-------|-------------------|
| SSH Access | ✅ All VMs | ❌ None | ✅ Single VM | ❌ None |
| User Accounts | ✅ Full | ❌ None | ✅ Full | ❌ None |
| Shell Tools | ✅ Complete | ✅ Basic | ✅ Complete | ✅ Basic |
| Architecture | 4-tier | 4-tier | All-in-one | 3-tier |
| Scalability | ✅ High | ✅ High | ❌ Limited | ✅ Medium |
| Resource Usage | High | Medium | Low | Medium |
| VM-like Experience | ✅ Full | ❌ Limited | ✅ Full | ❌ None |

## Files Structure

```
three/
├── vmstack-ssh.sh                    # Main management script
├── docker-compose.vmstack-ssh.yml    # SSH-enabled compose file
├── vmstack-nginx.conf                # Reverse proxy configuration
├── Dockerfile.nginx-ssh              # nginx + SSH
├── Dockerfile.postgres-ssh           # PostgreSQL + SSH
├── frontend/
│   └── Dockerfile.prod.ssh           # React + nginx + SSH
├── backend/
│   └── Dockerfile.ssh                # Node.js + SSH
└── VMSTACK-SSH-README.md            # This documentation
```

This SSH-enabled VMStack provides the full virtual machine experience with traditional SSH access, user accounts, and complete development environments while maintaining the scalability and isolation benefits of containerization.
