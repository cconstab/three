# 🚀 Three-Tier Task Management Application

A beautiful, modern task management application demonstrating a complete three-tier architecture using Docker Compose.

**🎯 New to this project? Start here:** **[Deployment Guide →](DEPLOYMENT-GUIDE.md)** - Choose between VM Stack (production), SSH VM Stack (VM development), or Single VM (quick development).

## 📖 Quick Navigation

| I want to... | Go to |
|---------------|-------|
| **Get running fast** | [⚡ Super Quick Start](#-super-quick-start) |
| **Choose deployment type** | [🚀 Deployment Options](#-deployment-options) |
| **Production setup** | [🏗️ VM Stack Guide →](VMSTACK-QUICKSTART.md) |
| **SSH access to containers** | [🔐 SSH VM Stack Guide →](VMSTACK-SSH-README.md) |
| **Development setup** | [📦 Single VM option](#-option-3-single-vm-quick-development) |
| **See what I'll get** | [🎉 What You Get](#-what-you-get) |
| **Compare all options** | [📊 Detailed Comparison →](DEPLOYMENT-GUIDE.md) |
| **Troubleshoot issues** | [Linux Troubleshooting →](LINUX_TROUBLESHOOTING.md) |

## 🏗️ Architecture

### **Complete Architecture (VM Stack)**
```
┌──────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Reverse Proxy  │────│  Frontend Tier  │◄──►│ Application Tier│◄──►│   Data Tier     │
│                  │    │                 │    │                 │    │                 │
│ Nginx Load Bal.  │    │ React + Tailwind│    │ Node.js/Express │    │   PostgreSQL    │
│    Port 8080     │    │     Port 3000   │    │     Port 3001   │    │    Port 5432    │
└──────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
         │                                                                      
    Internet Access                            Internal Network Only             
```

### **Simple Architecture (Single VM)**
```
┌───────────────────────────────────────────────────────────────────────────────┐
│                            Ubuntu VM Container                                │
│  ┌─────────────┐  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐ │
│  │    Nginx    │  │  Frontend Tier  │  │ Application Tier│  │   Data Tier     │ │
│  │ Reverse     │──│                 │──│                 │──│                 │ │
│  │ Proxy       │  │ React + Tailwind│  │ Node.js/Express │  │   PostgreSQL    │ │
│  │ Port 80     │  │     Port 3000   │  │     Port 3001   │  │    Port 5432    │ │
│  └─────────────┘  └─────────────────┘  └─────────────────┘  └─────────────────┘ │
└───────────────────────────────────────────────────────────────────────────────┘
```

### **Reverse Proxy Tier (Nginx)**
- **Technology**: Nginx high-performance web server
- **Function**: Load balancing, SSL termination, reverse proxy
- **Security**: Single external entry point, internal network isolation
- **Configuration**: Custom nginx.conf with API routing to `/api`
- **Ports**: 8080 (external) or 3000 (single VM)

### **Presentation Tier (Frontend)**
- **Technology**: React 18 with modern hooks
- **Styling**: Tailwind CSS with custom animations
- **UI Components**: Beautiful, responsive design with Framer Motion animations
- **Features**: Real-time task management, drag-and-drop interface, responsive design

### **Application Tier (Backend)**
- **Technology**: Node.js with Express.js
- **API**: RESTful API with comprehensive endpoints
- **Security**: Helmet, CORS, rate limiting
- **Health Checks**: Built-in health monitoring

### **Data Tier (Database)**
- **Technology**: PostgreSQL 15
- **Features**: ACID compliance, indexing, triggers
- **Sample Data**: Pre-loaded with realistic tasks
- **Performance**: Optimized queries and proper indexing

## ✨ Features

- 📝 **Task Management**: Create, edit, delete, and organize tasks
- 🎨 **Beautiful UI**: Modern design with smooth animations
- 📊 **Dashboard Analytics**: Real-time statistics and progress tracking
- 🏷️ **Priority System**: Low, medium, high priority levels
- 📅 **Due Dates**: Set and track task deadlines
- 🔄 **Status Tracking**: Pending, In Progress, Completed states
- 📱 **Responsive**: Works perfectly on all devices
- ⚡ **Real-time Updates**: Instant UI updates
- 🔍 **Filtering**: Filter tasks by status and priority

## ⚡ **Super Quick Start**

**Get running in 30 seconds with any of these options:**

```bash
# 🏗️ PRODUCTION (4-tier architecture)
git clone <repository-url> && cd three && cp .env.linux .env
# Edit HOST_IP and EXTERNAL_PORT in .env, then:
./vmstack.sh start

# 🔐 SSH VM STACK (SSH access to each container)  
git clone <repository-url> && cd three && cp .env.linux .env
# Edit HOST_IP and EXTERNAL_PORT in .env, then:
./vmstack-ssh.sh start

# 📦 DEVELOPMENT (all-in-one container)
git clone <repository-url> && cd three && ./start.sh
```

**🎯 Choose your path based on your needs → [Detailed Options Below ↓](#🚀-deployment-options)**

---

## 🚀 Deployment Options

**3 deployment approaches** to choose from based on your needs:

| 🎯 **Option** | 📊 **Best For** | 🏛️ **Architecture** | 🔑 **Access** |
|-------------|---------------|-------------------|---------------|
| 🏗️ **VM Stack** | Production | 4-Tier Containers | Shell Access |
| 🔐 **SSH VM Stack** | VM Development | 4-Tier + SSH | Traditional SSH |
| 📦 **Single VM** | Quick Dev/Demo | All-in-One | Shell Access |

---

## 🏗️ **Option 1: VM Stack (Production Ready)**

**✨ RECOMMENDED for production deployments and scalable architectures**

### 🏛️ **Architecture**
```
Internet → Nginx (Reverse Proxy) → Frontend → Backend → Database
 (8080)         ↓                   (3000)    (3001)    (5432)
         Single Entry Point    Internal Network Only
```

### 🎯 **Key Features**
- 🛡️ **Enhanced Security** - Only nginx container exposed externally
- 📈 **Scalable Design** - Independent container services  
- 🏭 **Production Ready** - Reverse proxy with load balancing
- ⚙️ **Port Flexibility** - Configurable via .env file
- 💻 **Container Access** - Shell access to individual services

### 🚀 **Quick Start**
```bash
git clone <repository-url>
cd three
cp .env.linux .env              # Copy environment template
# Edit HOST_IP and EXTERNAL_PORT in .env file
./vmstack.sh start              # Start 4-tier stack
```

### 📊 **Perfect For**
- Production servers and deployments
- Security-focused environments  
- Multi-environment setups (dev/staging/prod)
- Avoiding port conflicts on host machine
- Teams requiring service isolation

### 📖 **Documentation**
- **[Complete VM Stack Guide →](VMSTACK-QUICKSTART.md)**
- **[Environment Configuration →](.env.linux)** (copy to .env)

---

## 🔐 **Option 2: SSH-Enabled VM Stack (VM Development)**

**✨ BEST for developers who want traditional VM-like SSH access**

### 🏛️ **Architecture**
```
Internet → Nginx VM → Frontend VM → Backend VM → Database VM
 (8080)      :2201       :2202        :2203        :2204
   ↓         ↓SSH        ↓SSH         ↓SSH         ↓SSH
Reverse    developer/   developer/   developer/   developer/
Proxy      root123      root123      root123      root123
```

### 🎯 **Key Features**  
- 🔑 **Traditional SSH** - SSH login to each container like VMs
- 🛠️ **Development Tools** - vim, htop, curl, wget pre-installed
- 👤 **User Accounts** - developer/root with sudo privileges
- 🖥️ **VM Experience** - Traditional VM feel with container benefits
- 🏗️ **Production Architecture** - Same scalable 4-tier design

### 🚀 **Quick Start**
```bash
git clone <repository-url>
cd three
cp .env.linux .env              # Copy environment template  
# Edit HOST_IP and EXTERNAL_PORT in .env file
./vmstack-ssh.sh start          # Start SSH-enabled stack
```

### 🔑 **SSH Access**
```bash
# SSH to any container (password: developer123)
./vmstack-ssh.sh ssh nginx      # Reverse proxy container
./vmstack-ssh.sh ssh frontend   # React app container  
./vmstack-ssh.sh ssh backend    # Node.js API container
./vmstack-ssh.sh ssh database   # PostgreSQL container

# Or direct SSH access
ssh developer@localhost -p 2203  # Backend container example
```

### 📊 **Perfect For**
- Traditional VM-style development workflows
- Container debugging and troubleshooting
- Learning containerized architectures hands-on
- Teams transitioning from VMs to containers
- Full development environment in each service

### 📖 **Documentation**
- **[Complete SSH VM Stack Guide →](VMSTACK-SSH-README.md)**
- **[SSH Access & Debugging →](VMSTACK-SSH-README.md#ssh-access)**

---

## 📦 **Option 3: Single VM (Quick Development)**

**✨ BEST for rapid development, demos, and learning**

### 🏛️ **Architecture**
```
Internet → Ubuntu VM Container (Port 3000)
           ├── Nginx (Reverse Proxy)
           ├── React Frontend
           ├── Node.js Backend  
           └── PostgreSQL Database
```

### 🎯 **Key Features**
- ⚡ **Simple Setup** - Everything runs in one container
- 🏃 **Fast Iteration** - Quick development and testing cycle
- 💾 **Resource Efficient** - Lower memory and CPU overhead
- 🔍 **Easy Debugging** - All services accessible in one place
- 🎮 **Zero Configuration** - Works immediately out of the box

### 🚀 **Quick Start**
```bash
git clone <repository-url>
cd three
./start.sh                      # Start all-in-one container
```

### 📊 **Perfect For**
- Learning and experimentation
- Quick demos and prototypes  
- Local development environments
- Resource-constrained systems
- Getting started quickly

---

## 🤔 **Decision Matrix: Which Option Should I Choose?**

### 🏗️ **VM Stack (4-Tier) - RECOMMENDED for Production**

**Separate containers for enhanced security and scalability**

```
Internet → Nginx → Frontend → Backend → Database
           ↓
    Single entry point  Internal network only
```

**Features:**
- ✅ Enhanced security (only nginx externally accessible)
- ✅ Scalable architecture (separate containers per service)
- ✅ Production-ready reverse proxy
- ✅ Configurable external ports
- ✅ Individual VM shell access

**Quick Start:**
```bash
git clone <repository-url>
cd three
cp .env.linux .env
# Edit HOST_IP and EXTERNAL_PORT in .env
./vmstack.sh start
```

📖 **[Complete VMSTACK Quick Start Guide →](VMSTACK-QUICKSTART.md)**

---

### � **SSH-Enabled VM Stack - BEST for VM-like Development**

**4-Tier architecture with SSH access to every container**

```
Internet → Nginx VM → Frontend VM → Backend VM → Database VM
    ↓         ↓           ↓            ↓           ↓
  Port 8080  SSH:2201   SSH:2202   SSH:2203   SSH:2204
```

**Features:**
- ✅ Traditional SSH access to each container
- ✅ Full development tools (vim, htop, curl, wget)
- ✅ User accounts with sudo privileges
- ✅ Production architecture with development flexibility
- ✅ Individual container debugging capabilities

**Quick Start:**
```bash
git clone <repository-url>
cd three
cp .env.linux .env
# Edit HOST_IP and EXTERNAL_PORT in .env
./vmstack-ssh.sh start
```

**SSH Access:**
```bash
# SSH to any VM (password: developer123)
./vmstack-ssh.sh ssh backend
./vmstack-ssh.sh ssh frontend  
./vmstack-ssh.sh ssh database
./vmstack-ssh.sh ssh nginx
```

📖 **[Complete SSH VMStack Guide →](VMSTACK-SSH-README.md)**

---

### �📦 **Single VM (All-in-One) - BEST for Development**

**Everything in one container for fast development**

```
Internet → Ubuntu VM (All services inside)
           ├── Nginx
           ├── React Frontend  
           ├── Node.js Backend
           └── PostgreSQL Database
```

**Features:**
- ✅ Simple setup (everything in one place)
- ✅ Fast development iteration
- ✅ Lower resource overhead
- ✅ Easy debugging and testing

**Quick Start:**
```bash
git clone <repository-url>
cd three
./start.sh
```

---

| **Your Situation** | **Recommended Option** | **Why This Choice** |
|-------------------|----------------------|-------------------|
| **🏭 Production deployment** | 🏗️ VM Stack | Security isolation, scalability, monitoring |
| **🔧 Need SSH access to containers** | 🔐 SSH VM Stack | Traditional VM development experience |
| **🐛 Debugging containerized services** | 🔐 SSH VM Stack | SSH into individual containers |
| **⚡ Quick development/testing** | 📦 Single VM | Fastest setup, all services together |
| **📚 Learning Docker concepts** | 📦 Single VM | Simpler to understand initially |
| **🚫 Port conflicts on dev machine** | 🏗️ VM Stack | Configurable external ports |
| **👥 Multiple developers on team** | 🏗️ VM Stack | Better service isolation |
| **🔄 CI/CD pipelines** | 🏗️ VM Stack | Production-like environment |
| **🖥️ Want VM-like experience** | 🔐 SSH VM Stack | Traditional SSH workflow |

## 📚 **Command Reference**

### 🏗️ **VM Stack Commands**
```bash
./vmstack.sh start              # Start all services
./vmstack.sh stop               # Stop all services  
./vmstack.sh restart            # Restart all services
./vmstack.sh status             # Show service status
./vmstack.sh shell <service>    # Access container shell
# Services: nginx, frontend, backend, database
```

### 🔐 **SSH VM Stack Commands**  
```bash
./vmstack-ssh.sh start          # Start SSH-enabled services
./vmstack-ssh.sh stop           # Stop all services
./vmstack-ssh.sh restart        # Restart all services
./vmstack-ssh.sh status         # Show service status
./vmstack-ssh.sh ssh <service>  # SSH into container
./vmstack-ssh.sh shell <service> # Direct container access
# Services: nginx, frontend, backend, database
```

### 📦 **Single VM Commands**
```bash
./start.sh                      # Start single container
./vm.sh stop                    # Stop container
./vm.sh shell                   # Access container shell
```

## 📖 **Comprehensive Documentation**

- **[📊 Detailed Architecture Comparison →](DEPLOYMENT-GUIDE.md)**
- **[🏗️ VM Stack Complete Guide →](VMSTACK-QUICKSTART.md)**  
- **[🔐 SSH VM Stack Complete Guide →](VMSTACK-SSH-README.md)**
- **[⚙️ Environment Configuration →](.env.linux)** (template file)

## ⚡ Super Quick Start

**Want to get running in 30 seconds?**

```bash
# For development (everything in one container)
git clone <repository-url> && cd three && ./start.sh

# For production (4-tier architecture)
git clone <repository-url> && cd three && cp .env.linux .env
# Edit .env with your HOST_IP, then:
./vmstack.sh start
```

## 📋 Prerequisites

- **Docker** and **Docker Compose** installed
- **Git** for cloning the repository
- **Network access** to your configured external port

## 🎯 Access Your Application

### VM Stack (Production)
After running `./vmstack.sh start`:
- **Web App**: `http://your-host:your-port` (configured in .env)
- **API**: `http://your-host:your-port/api`
- **Health Check**: `http://your-host:your-port/health`

### Single VM (Development)
After running `./start.sh`:
- **Frontend**: `http://localhost:3000`
- **Backend API**: `http://localhost:3001`
- **Database**: `localhost:5432`

## 🛠️ Management Commands

### VM Stack Commands
```bash
./vmstack.sh start     # Start all containers
./vmstack.sh stop      # Stop all containers
./vmstack.sh restart   # Restart all containers
./vmstack.sh rebuild   # Fresh rebuild
./vmstack.sh status    # Show container status
./vmstack.sh logs      # View logs
./vmstack.sh shell <vm> # Access VM shell
```

### Single VM Commands
```bash
./vm.sh start          # Start the VM
./vm.sh stop           # Stop the VM
./vm.sh restart        # Restart the VM
./vm.sh shell          # Access VM shell
./vm.sh logs           # View logs
```

## 📖 Detailed Documentation

- **[VMSTACK-QUICKSTART.md](VMSTACK-QUICKSTART.md)** - Complete 4-tier VM setup guide
- **[DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md)** - Choose the right deployment approach
- **[LINUX_DEPLOYMENT.md](LINUX_DEPLOYMENT.md)** - Production deployment details
- **[LINUX_TROUBLESHOOTING.md](LINUX_TROUBLESHOOTING.md)** - Common issues and solutions

## 🔧 Configuration Options

### Port Configuration (VM Stack)
Set in your `.env` file:
```bash
HOST_IP=your-server-ip-or-hostname
EXTERNAL_PORT=8080  # Change if 3000 conflicts
```

### Environment Variables
```bash
# Database settings
POSTGRES_DB=taskmanager
POSTGRES_USER=taskuser
POSTGRES_PASSWORD=taskpass123

# Application
NODE_ENV=production

# Linux/macOS - using ifconfig
ifconfig | grep -E 'inet.*broadcast' | grep -v 127.0.0.1 | awk '{print $2}' | head -1

## 🎉 What You Get

After deployment, you'll have a **fully functional task management application** with:

### 🎨 **Application Features**
- ✅ Create, edit, delete tasks with rich details
- ✅ Priority levels (Low, Medium, High) with color coding
- ✅ Status tracking (Pending, In Progress, Completed)
- ✅ Due date management with calendar integration
- ✅ Real-time statistics dashboard
- ✅ Responsive design for all devices
- ✅ Beautiful animations and transitions

### 🛠️ **Technical Stack**
- **Frontend**: React 18 + Tailwind CSS + Framer Motion
- **Backend**: Node.js + Express + PostgreSQL
- **Deployment**: Docker + Docker Compose
- **Production**: Nginx reverse proxy + health monitoring

### 🔗 **Access Methods** (depending on your deployment choice)

| **🏗️ VM Stack** | **🔐 SSH VM Stack** | **📦 Single VM** |
|---------------|------------------|-----------------|
| Web: `http://your-host:port` | Web: `http://your-host:port` | Web: `http://localhost:3000` |
| Shell: `./vmstack.sh shell <service>` | SSH: `./vmstack-ssh.sh ssh <service>` | Shell: `./vm.sh shell` |
| API: `/api` (reverse proxy) | SSH Direct: `ssh developer@localhost -p 220X` | API: `/api` (internal proxy) |

---

## 🛠️ Development Setup

### Local Development (without Docker)

#### Backend Setup
```bash
cd backend
npm install
cp .env.example .env
# Edit .env with your database credentials
npm run dev
```

#### Frontend Setup
```bash
cd frontend
npm install
cp .env.example .env
# Edit .env with your API URL
npm start
```

#### Database Setup
```bash
# Install PostgreSQL locally
# Create database and user as specified in docker-compose.yml
# Run the init.sql script
```

## 📁 Project Structure

```
three-tier-app/
├── docker-compose.yml          # Multi-service orchestration
├── README.md                   # This file
│
├── frontend/                   # React Application (Presentation Tier)
│   ├── src/
│   │   ├── components/         # React components
│   │   ├── services/          # API service layer
│   │   └── App.js             # Main application
│   ├── Dockerfile             # Frontend container
│   └── package.json           # Dependencies
│
├── backend/                    # Node.js API (Application Tier)
│   ├── server.js              # Express server
│   ├── healthcheck.js         # Health monitoring
│   ├── Dockerfile             # Backend container
│   └── package.json           # Dependencies
│
└── database/                   # PostgreSQL (Data Tier)
    └── init.sql               # Database schema and sample data
```

## 🔧 API Endpoints

### Task Management
- `GET /api/tasks` - Get all tasks (with optional filtering)
- `GET /api/tasks/:id` - Get single task
- `POST /api/tasks` - Create new task
- `PUT /api/tasks/:id` - Update task
- `DELETE /api/tasks/:id` - Delete task

### Statistics
- `GET /api/stats` - Get task statistics

### System
- `GET /health` - Health check endpoint

### Example API Usage
```bash
# Get all tasks
curl http://localhost:3001/api/tasks

# Create a new task
curl -X POST http://localhost:3001/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "title": "My New Task",
    "description": "Task description",
    "priority": "high",
    "due_date": "2025-10-01"
  }'

# Get statistics
curl http://localhost:3001/api/stats
```

## 🐳 Docker Commands

```bash
# Start all services
docker compose up -d

# View logs
docker compose logs -f

# Stop all services
docker compose down

# Rebuild and start
docker compose up --build

# Remove everything (including volumes)
docker compose down -v --remove-orphans
```

## 🔧 Configuration

### Environment Variables

#### Root Directory (.env) - For Linux/Remote Deployment
```env
# Host IP Configuration - Set to your server's IP for remote access
HOST_IP=192.168.1.100  # Replace with your actual server IP

# Alternative: Let docker-compose use individual variables
# REACT_APP_API_URL=http://192.168.1.100:3001
# FRONTEND_URL=http://192.168.1.100:3000

# Database Configuration
POSTGRES_DB=taskmanager
POSTGRES_USER=taskuser
POSTGRES_PASSWORD=taskpass123

NODE_ENV=production
```

#### Backend (.env)
```env
NODE_ENV=production
PORT=3001
DB_HOST=database
DB_PORT=5432
DB_NAME=taskmanager
DB_USER=taskuser
DB_PASSWORD=taskpass123

# CORS Configuration (automatically handled by HOST_IP)
FRONTEND_URL=http://localhost:3000
```

#### Frontend (.env)
```env
# API URL (automatically set by docker-compose using HOST_IP)
REACT_APP_API_URL=http://localhost:3001
```

### 🐧 Linux Server Deployment

#### Automatic IP Detection (Recommended)
The start script automatically detects your server's IP address:
```bash
# Development mode (may have host header issues with external access)
./start.sh

# Production mode (recommended for remote access)
PRODUCTION=true ./start.sh
```

#### Manual IP Configuration
For manual control or when auto-detection fails:

**Method 1: Environment Variable**
```bash
# Development mode
export HOST_IP=192.168.1.100  # Your server's IP
./start.sh

# Production mode (recommended)
export HOST_IP=192.168.1.100
PRODUCTION=true ./start.sh
```

**Method 2: Environment File**
```bash
cp .env.linux .env
nano .env  # Set HOST_IP=your-server-ip
PRODUCTION=true ./start.sh  # Use production mode for remote access
```

#### Firewall Configuration
Ensure ports are accessible:

**Ubuntu/Debian:**
```bash
sudo ufw allow 3000:3001/tcp
sudo ufw status
```

**RHEL/CentOS/Fedora:**
```bash
sudo firewall-cmd --permanent --add-port=3000-3001/tcp
sudo firewall-cmd --reload
```

#### Remote Access
After deployment with correct HOST_IP:
- **Frontend**: `http://YOUR-SERVER-IP:3000`
- **Backend**: `http://YOUR-SERVER-IP:3001`
- **Health Check**: `curl http://YOUR-SERVER-IP:3001/health`

📖 **Detailed Guide**: See [LINUX_DEPLOYMENT.md](LINUX_DEPLOYMENT.md) for comprehensive setup instructions.

## 📊 Database Schema

### Tasks Table
```sql
CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'pending',
    priority VARCHAR(10) DEFAULT 'medium',
    due_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

## 🚦 Testing

### Backend API Testing
```bash
# Health check
curl http://localhost:3001/health

# Test API endpoints
curl http://localhost:3001/api/tasks
curl http://localhost:3001/api/stats
```

### Frontend Testing
- Open http://localhost:3000
- Test task creation, editing, deletion
- Verify responsive design on different screen sizes

## 🔍 Troubleshooting

### Network Issues on Linux
If you're experiencing network errors on a clean Linux machine, see our comprehensive troubleshooting guide:

📖 **[Linux Troubleshooting Guide](LINUX_TROUBLESHOOTING.md)**

### Quick Diagnostic
Run our network diagnostic script to identify common issues:
```bash
./diagnose-network.sh
```

### Common Solutions

#### 1. **Host IP Configuration Issues**
```bash
# Check current HOST_IP
echo $HOST_IP

# Auto-detect your IP
ip route get 1.1.1.1 | grep -oP 'src \K\S+'

# Set manually for remote access
export HOST_IP=192.168.1.100  # Your server IP
docker compose down && docker compose up -d
```

#### 2. **CORS/Connection Errors**
- **Firewall blocking ports**: `sudo ufw allow 3000:3001/tcp` (Ubuntu) or `sudo firewall-cmd --permanent --add-port=3000-3001/tcp` (RHEL)
- **Docker permission issues**: `sudo usermod -aG docker $USER && newgrp docker`
- **SELinux blocking (RHEL)**: `sudo setsebool -P container_manage_cgroup on`

#### 3. **Port Conflicts**
```bash
# Check if ports are in use
sudo lsof -i :3000 -i :3001 -i :5432

# Kill conflicting processes
sudo fuser -k 3000/tcp
sudo fuser -k 3001/tcp
```

#### 4. **Database Connection Issues**
   ```bash
   # Check database logs
   docker compose logs database
   
   # Connect to database directly
   docker compose exec database psql -U taskuser -d taskmanager
   ```

3. **Frontend build issues**
   ```bash
   # Clear node modules and reinstall
   cd frontend
   rm -rf node_modules package-lock.json
   npm install
   ```

4. **Backend API issues**
   ```bash
   # Check backend logs
   docker compose logs backend
   
   # Restart backend service
   docker compose restart backend
   ```

## 🚀 Production Deployment

### Docker Production Build
```bash
# Build for production
docker compose -f docker-compose.yml -f docker-compose.prod.yml up --build
```

### Environment Considerations
- Use environment-specific database credentials
- Enable HTTPS for production
- Set up proper logging and monitoring
- Configure backup strategies
- Use container orchestration (Kubernetes) for scalability

## 🎯 Features Demonstrated

- **Three-Tier Architecture**: Clear separation of concerns
- **Containerization**: Full Docker Compose setup
- **Modern Frontend**: React with Hooks and modern patterns
- **RESTful API**: Comprehensive Express.js backend
- **Database Design**: Proper PostgreSQL schema with relationships
- **Security**: CORS, rate limiting, input validation
- **User Experience**: Beautiful, responsive UI with animations
- **DevOps**: Health checks, logging, graceful shutdowns

## � Troubleshooting

### Network Issues on Linux
If you're experiencing network errors on a clean Linux machine, see our comprehensive troubleshooting guide:

📖 **[Linux Troubleshooting Guide](LINUX_TROUBLESHOOTING.md)**

### Quick Diagnostic
Run our network diagnostic script to identify common issues:
```bash
./diagnose-network.sh
```

### Common Solutions
- **Firewall blocking ports**: `sudo ufw allow 3000:3001/tcp` (Ubuntu) or `sudo firewall-cmd --permanent --add-port=3000-3001/tcp` (RHEL)
- **Docker permission issues**: `sudo usermod -aG docker $USER && newgrp docker`
- **Port conflicts**: `sudo lsof -i :3000 -i :3001 -i :5432`
- **SELinux blocking (RHEL)**: `sudo setsebool -P container_manage_cgroup on`

## �🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## � Quick Reference

### HOST_IP Configuration Commands
```bash
# Auto-detect and start
./start.sh

# Manual IP configuration
export HOST_IP=192.168.1.100 && ./start.sh

# Using environment file
cp .env.linux .env && nano .env && ./start.sh

# Find your IP address
ip route get 1.1.1.1 | grep -oP 'src \K\S+'
```

### Useful Commands
```bash
# Network diagnostic
./diagnose-network.sh

# View logs
docker compose logs -f

# Restart with new IP
docker compose down && export HOST_IP=new-ip && docker compose up -d

# Health check
curl http://$HOST_IP:3001/health
```

## �🙋‍♂️ Support

If you encounter any issues or have questions:
1. **First**: Run `./diagnose-network.sh` to identify common issues
2. **Check**: [Linux Troubleshooting Guide](LINUX_TROUBLESHOOTING.md) for detailed solutions
3. Review Docker and application logs: `docker compose logs -f`
4. Ensure all prerequisites are installed
5. Verify port availability: `sudo lsof -i :3000 -i :3001 -i :5432`

---

**Built with ❤️ to demonstrate modern three-tier architecture patterns**