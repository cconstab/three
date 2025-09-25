# 🚀 Quick Start Guide - VM Stack (4-Tier Architecture)

Get the Three-Tier Task Management Application running in minutes with separate containers for each service.

## 📋 Prerequisites

- **Docker** and **Docker Compose** installed
- **Git** for cloning the repository
- Network access to your configured external port (default: 3000, configurable)

## ⚡ Quick Start (3 Steps)

### 1. Clone the Repository
```bash
git clone <repository-url>
cd three
```

### 2. Configure Environment
```bash
# Copy the environment template
cp .env.linux .env

# Edit the configuration
nano .env  # or use your preferred editor
```

**Required Changes in `.env`:**
```bash
# Set your server's IP address or hostname
HOST_IP=your-server-ip-or-hostname

# Optional: Change port if 3000 conflicts with other services
EXTERNAL_PORT=8080
```

**Examples:**
```bash
HOST_IP=192.168.1.100     # Local IP address
HOST_IP=myserver.local    # Local hostname
HOST_IP=server.domain.com # Domain name
HOST_IP=10.0.0.50        # Internal network IP
```

### 3. Build and Start
```bash
# Build and start all VMs
./vmstack.sh start
```

## 🎉 Access Your Application

After startup, you'll see:
```
🎉 VM Stack is ready!

📱 Access Points:
  Web App:       http://your-host:your-port
  API (proxy):   http://your-host:your-port/api
  Health Check:  http://your-host:your-port/health

💻 VM Shell Access:
  ./vmstack.sh shell nginx     # Nginx reverse proxy VM
  ./vmstack.sh shell frontend  # React frontend VM
  ./vmstack.sh shell backend   # Node.js API VM
  ./vmstack.sh shell database  # PostgreSQL database VM
```

## 🛠️ Management Commands

| Command | Description |
|---------|-------------|
| `./vmstack.sh start` | Start all VM containers |
| `./vmstack.sh stop` | Stop all VM containers |
| `./vmstack.sh restart` | Restart all VM containers |
| `./vmstack.sh rebuild` | Rebuild and restart (fresh start) |
| `./vmstack.sh status` | Show container status |
| `./vmstack.sh logs` | View logs from all VMs |
| `./vmstack.sh logs -f` | Follow logs in real-time |

## 🔧 VM Access Commands

### Interactive Shell Access
```bash
./vmstack.sh shell nginx      # Access nginx reverse proxy
./vmstack.sh shell frontend   # Access React frontend container
./vmstack.sh shell backend    # Access Node.js API container
./vmstack.sh shell database   # Access PostgreSQL database
```

### Execute Specific Commands
```bash
./vmstack.sh exec backend 'npm list'                    # List Node.js packages
./vmstack.sh exec database 'psql -U taskuser taskmanager' # Connect to database
./vmstack.sh exec nginx 'nginx -t'                      # Test nginx config
./vmstack.sh exec frontend 'ls -la /usr/share/nginx/html' # List frontend files
```

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Nginx VM      │◄──►│  Frontend VM    │    │  Backend VM     │◄──►│  Database VM    │
│                 │    │                 │    │                 │    │                 │
│ Reverse Proxy   │    │ React App       │    │ Node.js/Express │    │   PostgreSQL    │
│ Port: External  │    │ Port: 3000      │    │ Port: 3001      │    │   Port: 5432    │
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
```

**Security Model:**
- Only nginx VM is externally accessible (single entry point)
- All other VMs communicate internally via Docker network
- Frontend, backend, and database are not directly accessible from outside

## ⚙️ Configuration Options

### Port Configuration
```bash
# Default port (may conflict with other services)
EXTERNAL_PORT=3000

# Alternative ports to avoid conflicts
EXTERNAL_PORT=8080  # Popular alternative
EXTERNAL_PORT=5000  # Another common choice
EXTERNAL_PORT=4000  # Development alternative
```

### Advanced Configuration
```bash
# Database settings (usually no changes needed)
POSTGRES_DB=taskmanager
POSTGRES_USER=taskuser
POSTGRES_PASSWORD=taskpass123

# Environment
NODE_ENV=production
```

## 🔍 Health Checks

```bash
# Check application health
curl http://your-host:your-port/health

# Check API stats
curl http://your-host:your-port/api/stats

# View container status
./vmstack.sh status
```

## 🧹 Cleanup

```bash
# Stop VMs (preserves data)
./vmstack.sh stop

# Complete cleanup (removes all data - DESTRUCTIVE)
./vmstack.sh clean
```

## 🆘 Troubleshooting

### Common Issues

**Port conflicts:**
```bash
# Change EXTERNAL_PORT in .env file
EXTERNAL_PORT=8080
./vmstack.sh rebuild
```

**Permission issues:**
```bash
# Make script executable
chmod +x vmstack.sh
```

**Container won't start:**
```bash
# Check container status and logs
./vmstack.sh status
./vmstack.sh logs
```

**Network errors:**
```bash
# Verify your HOST_IP is correct
ping your-configured-host-ip

# Check if containers can communicate
./vmstack.sh exec backend 'curl -s database-vm:5432 || echo "DB not reachable"'
```

## 📚 Next Steps

- **Production Deployment**: See [LINUX_DEPLOYMENT.md](LINUX_DEPLOYMENT.md) for detailed production setup
- **Development**: Use the single-VM setup with `./vm.sh` for development
- **Customization**: Modify `docker-compose.vmstack.yml` for advanced configurations

---

**🎯 That's it! Your 4-tier VM stack should now be running and accessible.**
