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
- Docker and Docker Compose installed
- Git (to clone the repository)

### 1. Clone and Run
```bash
# Clone the repository
git clone <your-repo-url>
cd three-tier-task-app

# Start all services
docker-compose up --build
```

### 2. Access the Application
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:3001
- **Database**: localhost:5432

### 3. API Health Check
```bash
curl http://localhost:3001/health
```

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
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down

# Rebuild and start
docker-compose up --build

# Remove everything (including volumes)
docker-compose down -v --remove-orphans
```

## 🔧 Configuration

### Environment Variables

#### Backend (.env)
```env
NODE_ENV=production
PORT=3001
DB_HOST=database
DB_PORT=5432
DB_NAME=taskmanager
DB_USER=taskuser
DB_PASSWORD=taskpass123
```

#### Frontend (.env)
```env
REACT_APP_API_URL=http://localhost:3001
```

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

### Common Issues

1. **Port conflicts**
   ```bash
   # Check if ports are in use
   lsof -i :3000
   lsof -i :3001
   lsof -i :5432
   ```

2. **Database connection issues**
   ```bash
   # Check database logs
   docker-compose logs database
   
   # Connect to database directly
   docker-compose exec database psql -U taskuser -d taskmanager
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
   docker-compose logs backend
   
   # Restart backend service
   docker-compose restart backend
   ```

## 🚀 Production Deployment

### Docker Production Build
```bash
# Build for production
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up --build
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

## 🙋‍♂️ Support

If you encounter any issues or have questions:
1. **First**: Run `./diagnose-network.sh` to identify common issues
2. **Check**: [Linux Troubleshooting Guide](LINUX_TROUBLESHOOTING.md) for detailed solutions
3. Review Docker and application logs: `docker-compose logs -f`
4. Ensure all prerequisites are installed
5. Verify port availability: `sudo lsof -i :3000 -i :3001 -i :5432`

---

**Built with ❤️ to demonstrate modern three-tier architecture patterns**