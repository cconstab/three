#!/bin/bash

# VMStack SSH Management Script
# Manages the SSH-enabled 4-tier VM stack with enhanced access capabilities

# Set script directory and environment
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Load environment variables if .env exists
if [[ -f .env ]]; then
    set -a  # automatically export all variables
    source .env
    set +a  # stop automatically exporting
fi

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Docker compose file
COMPOSE_FILE="docker-compose.vmstack-ssh.yml"

# Function to detect API URL
detect_api_url() {
    if [[ -n "${REACT_APP_API_URL}" ]]; then
        echo "${REACT_APP_API_URL}"
    else
        echo "http://localhost:3001"
    fi
}

# Function to show help
show_help() {
    echo -e "${CYAN}VMStack SSH Management Commands:${NC}"
    echo ""
    echo -e "${GREEN}Stack Management:${NC}"
    echo "  $0 start              - Start the SSH-enabled VM stack"
    echo "  $0 stop               - Stop the VM stack"
    echo "  $0 restart            - Restart the VM stack"
    echo "  $0 status             - Show stack status"
    echo "  $0 logs [service]     - Show logs (all services or specific)"
    echo "  $0 build              - Build all VM images"
    echo "  $0 rebuild            - Rebuild and restart all VMs"
    echo ""
    echo -e "${BLUE}VM Shell Access:${NC}"
    echo "  $0 shell nginx        - Access nginx-vm shell"
    echo "  $0 shell frontend     - Access frontend-vm shell"
    echo "  $0 shell backend      - Access backend-vm shell"
    echo "  $0 shell database     - Access database-vm shell"
    echo ""
    echo -e "${PURPLE}VM SSH Access:${NC}"
    echo "  $0 ssh nginx          - SSH to nginx-vm (port 2201)"
    echo "  $0 ssh frontend       - SSH to frontend-vm (port 2202)"
    echo "  $0 ssh backend        - SSH to backend-vm (port 2203)"
    echo "  $0 ssh database       - SSH to database-vm (port 2204)"
    echo ""
    echo -e "${YELLOW}VM Exec Commands:${NC}"
    echo "  $0 exec nginx [cmd]   - Execute command in nginx-vm"
    echo "  $0 exec frontend [cmd] - Execute command in frontend-vm"
    echo "  $0 exec backend [cmd] - Execute command in backend-vm"
    echo "  $0 exec database [cmd] - Execute command in database-vm"
    echo ""
    echo -e "${CYAN}Connection Information:${NC}"
    echo "  $0 info               - Show all connection details"
    echo "  $0 ports              - Show port mappings"
    echo ""
    echo -e "${RED}Examples:${NC}"
    echo "  $0 ssh backend                    # SSH to backend VM"
    echo "  $0 exec frontend 'ls -la /app'    # List files in frontend VM"
    echo "  $0 shell database                 # Interactive shell in database VM"
}

# Function to show connection info
show_info() {
    echo -e "${CYAN}VMStack SSH Connection Information:${NC}"
    echo ""
    echo -e "${GREEN}Web Access:${NC}"
    echo "  Application: http://localhost:8080"
    echo "  Frontend:    http://localhost:3000"
    echo "  Backend:     http://localhost:3001"
    echo "  Database:    localhost:5432"
    echo ""
    echo -e "${BLUE}SSH Access (user: developer, password: developer123):${NC}"
    echo "  nginx-vm:    ssh developer@localhost -p 2201"
    echo "  frontend-vm: ssh developer@localhost -p 2202"
    echo "  backend-vm:  ssh developer@localhost -p 2203"
    echo "  database-vm: ssh developer@localhost -p 2204"
    echo ""
    echo -e "${PURPLE}Root SSH Access (password: root123):${NC}"
    echo "  nginx-vm:    ssh root@localhost -p 2201"
    echo "  frontend-vm: ssh root@localhost -p 2202"
    echo "  backend-vm:  ssh root@localhost -p 2203"
    echo "  database-vm: ssh root@localhost -p 2204"
    echo ""
    echo -e "${YELLOW}Environment:${NC}"
    echo "  API URL: $(detect_api_url)"
    echo "  Compose: $COMPOSE_FILE"
}

# Function to show ports
show_ports() {
    echo -e "${CYAN}VMStack Port Mappings:${NC}"
    echo ""
    echo -e "${GREEN}Application Ports:${NC}"
    echo "  8080:80     → nginx-vm (reverse proxy)"
    echo "  8443:443    → nginx-vm (SSL)"
    echo "  3000:3000   → frontend-vm (React app)"
    echo "  3001:3001   → backend-vm (Node.js API)"
    echo "  5432:5432   → database-vm (PostgreSQL)"
    echo ""
    echo -e "${BLUE}SSH Ports:${NC}"
    echo "  2201:22     → nginx-vm SSH"
    echo "  2202:22     → frontend-vm SSH"
    echo "  2203:22     → backend-vm SSH"
    echo "  2204:22     → database-vm SSH"
}

# Function to start the stack
start_stack() {
    echo -e "${GREEN}Starting SSH-enabled VMStack...${NC}"
    docker-compose -f "$COMPOSE_FILE" up -d
    
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}VMStack started successfully!${NC}"
        echo ""
        show_info
    else
        echo -e "${RED}Failed to start VMStack${NC}"
        exit 1
    fi
}

# Function to stop the stack
stop_stack() {
    echo -e "${YELLOW}Stopping VMStack...${NC}"
    docker-compose -f "$COMPOSE_FILE" down
    echo -e "${GREEN}VMStack stopped${NC}"
}

# Function to restart the stack
restart_stack() {
    echo -e "${YELLOW}Restarting VMStack...${NC}"
    docker-compose -f "$COMPOSE_FILE" restart
    echo -e "${GREEN}VMStack restarted${NC}"
}

# Function to show status
show_status() {
    echo -e "${CYAN}VMStack Status:${NC}"
    docker-compose -f "$COMPOSE_FILE" ps
}

# Function to show logs
show_logs() {
    local service="$1"
    if [[ -n "$service" ]]; then
        echo -e "${CYAN}Showing logs for $service-vm...${NC}"
        docker-compose -f "$COMPOSE_FILE" logs -f "$service-vm"
    else
        echo -e "${CYAN}Showing logs for all VMs...${NC}"
        docker-compose -f "$COMPOSE_FILE" logs -f
    fi
}

# Function to build images
build_images() {
    echo -e "${GREEN}Building VMStack images...${NC}"
    docker-compose -f "$COMPOSE_FILE" build
}

# Function to rebuild and restart
rebuild_stack() {
    echo -e "${YELLOW}Rebuilding and restarting VMStack...${NC}"
    docker-compose -f "$COMPOSE_FILE" down
    docker-compose -f "$COMPOSE_FILE" build --no-cache
    docker-compose -f "$COMPOSE_FILE" up -d
    echo -e "${GREEN}VMStack rebuilt and restarted${NC}"
}

# Function to access VM shell
vm_shell() {
    local vm="$1"
    local container_name
    
    case "$vm" in
        "nginx"|"proxy")
            container_name="nginx-vm"
            ;;
        "frontend"|"react"|"ui")
            container_name="frontend-vm"
            ;;
        "backend"|"api"|"server")
            container_name="backend-vm"
            ;;
        "database"|"db"|"postgres")
            container_name="database-vm"
            ;;
        *)
            echo -e "${RED}Unknown VM: $vm${NC}"
            echo -e "${YELLOW}Available VMs: nginx, frontend, backend, database${NC}"
            exit 1
            ;;
    esac
    
    echo -e "${GREEN}Accessing $container_name shell...${NC}"
    docker exec -it "$container_name" /bin/bash
}

# Function to SSH to VM
vm_ssh() {
    local vm="$1"
    local port
    
    case "$vm" in
        "nginx"|"proxy")
            port="2201"
            ;;
        "frontend"|"react"|"ui")
            port="2202"
            ;;
        "backend"|"api"|"server")
            port="2203"
            ;;
        "database"|"db"|"postgres")
            port="2204"
            ;;
        *)
            echo -e "${RED}Unknown VM: $vm${NC}"
            echo -e "${YELLOW}Available VMs: nginx, frontend, backend, database${NC}"
            exit 1
            ;;
    esac
    
    echo -e "${GREEN}SSH to $vm-vm on port $port...${NC}"
    echo -e "${YELLOW}Username: developer, Password: developer123${NC}"
    ssh developer@localhost -p "$port"
}

# Function to execute command in VM
vm_exec() {
    local vm="$1"
    shift
    local cmd="$*"
    local container_name
    
    case "$vm" in
        "nginx"|"proxy")
            container_name="nginx-vm"
            ;;
        "frontend"|"react"|"ui")
            container_name="frontend-vm"
            ;;
        "backend"|"api"|"server")
            container_name="backend-vm"
            ;;
        "database"|"db"|"postgres")
            container_name="database-vm"
            ;;
        *)
            echo -e "${RED}Unknown VM: $vm${NC}"
            echo -e "${YELLOW}Available VMs: nginx, frontend, backend, database${NC}"
            exit 1
            ;;
    esac
    
    if [[ -z "$cmd" ]]; then
        echo -e "${RED}No command specified${NC}"
        echo -e "${YELLOW}Usage: $0 exec $vm 'command'${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Executing in $container_name: $cmd${NC}"
    docker exec -it "$container_name" bash -c "$cmd"
}

# Main command handling
case "$1" in
    "start")
        start_stack
        ;;
    "stop")
        stop_stack
        ;;
    "restart")
        restart_stack
        ;;
    "status")
        show_status
        ;;
    "logs")
        show_logs "$2"
        ;;
    "build")
        build_images
        ;;
    "rebuild")
        rebuild_stack
        ;;
    "shell")
        if [[ -z "$2" ]]; then
            echo -e "${RED}VM name required${NC}"
            echo -e "${YELLOW}Usage: $0 shell <nginx|frontend|backend|database>${NC}"
            exit 1
        fi
        vm_shell "$2"
        ;;
    "ssh")
        if [[ -z "$2" ]]; then
            echo -e "${RED}VM name required${NC}"
            echo -e "${YELLOW}Usage: $0 ssh <nginx|frontend|backend|database>${NC}"
            exit 1
        fi
        vm_ssh "$2"
        ;;
    "exec")
        if [[ -z "$2" ]]; then
            echo -e "${RED}VM name required${NC}"
            echo -e "${YELLOW}Usage: $0 exec <nginx|frontend|backend|database> 'command'${NC}"
            exit 1
        fi
        vm_exec "$2" "${@:3}"
        ;;
    "info")
        show_info
        ;;
    "ports")
        show_ports
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    "")
        show_help
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
