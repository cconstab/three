# 🚀 Three-Tier Task Management Application

A beautiful, modern task management application demonstrating a complete three-tier architecture using Docker Compose.

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Frontend Tier  │◄──►│ Application Tier│◄──►│   Data Tier     │
│                 │    │                 │    │                 │
│ React + Tailwind│    │ Node.js/Express │    │   PostgreSQL    │
│     Port 3000   │    │     Port 3001   │    │    Port 5432    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

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

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose plugin installed
- Git (to clone the repository)
- For Linux server deployment: Network access to ports 3000-3001

**Note**: For deployment on Linux servers (non-localhost), the application automatically detects and configures the host IP address for remote access.

### 1. Clone and Start
```bash
git clone <repository-url>
cd three
./start.sh
```

### 2. Access the Application

#### Local Development (localhost)
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:3001
- **Database**: localhost:5432

#### Linux Server Deployment (remote access)
The start script automatically detects your server's IP address. For manual configuration:

```bash
# Option 1: Auto-detect IP (recommended for development)
./start.sh

# Option 2: Set specific IP for development
export HOST_IP=192.168.1.100  # Replace with your server IP
./start.sh

# Option 3: Production mode (recommended for remote access)
export HOST_IP=192.168.1.100
PRODUCTION=true ./start.sh

# Option 4: Use hostname (development mode only)
export HOST_IP=myserver.local  # May show "Invalid Host header" warning
./start.sh

# Option 5: Use environment file
cp .env.linux .env
# Edit .env and set HOST_IP=your-server-ip-or-hostname
./start.sh
```

**Important Security Note**: 
- **Development mode**: Uses React dev server, may show "Invalid Host header" with external hostnames
- **Production mode**: Uses nginx with static files, no host header issues, better security

**Access URLs will be displayed based on your configuration:**
- **Frontend**: http://YOUR-IP-OR-HOSTNAME:3000
- **Backend API**: http://YOUR-IP-OR-HOSTNAME:3001
- **Database**: YOUR-IP-OR-HOSTNAME:5432

### 3. Find Your Server IP
```bash
# Linux - using ip command
ip route get 1.1.1.1 | grep -oP 'src \K\S+'

# Linux/macOS - using ifconfig
ifconfig | grep -E 'inet.*broadcast' | grep -v 127.0.0.1 | awk '{print $2}' | head -1

# Linux only - using hostname
hostname -I | awk '{print $1}'
```

### 4. API Health Check

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