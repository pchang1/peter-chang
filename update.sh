#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Starting Update ===${NC}"

# Check Docker installation
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed.${NC}"
    exit 1
fi

# Determine docker compose command
if docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
elif command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
else
    echo -e "${RED}Error: Docker Compose is not installed.${NC}"
    exit 1
fi

# Git pull if it's a git repository
if [ -d .git ] && command -v git &> /dev/null; then
    echo -e "${BLUE}Checking for updates in Git repository...${NC}"
    
    # Fetch latest changes
    git fetch origin 2>/dev/null
    
    # Check if there are updates
    LOCAL=$(git rev-parse HEAD)
    REMOTE=$(git rev-parse @{u} 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        echo -e "${YELLOW}Warning: No upstream tracking branch configured. Skipping git pull.${NC}"
    elif [ "$LOCAL" = "$REMOTE" ]; then
        echo -e "${GREEN}Code is already up-to-date with remote.${NC}"
    else
        echo -e "${YELLOW}New updates found. Pulling latest code...${NC}"
        # Check if working directory is clean
        if ! git diff-index --quiet HEAD --; then
            echo -e "${YELLOW}Warning: You have uncommitted local changes. Stashing them...${NC}"
            git stash
            git pull
            git stash pop
        else
            git pull
        fi
    fi
else
    echo -e "${YELLOW}Note: Not a git repository or git command not found. Skipping git pull.${NC}"
fi

# Rebuild and restart service
echo -e "${BLUE}Rebuilding and restarting container...${NC}"
if $DOCKER_COMPOSE up -d --build --force-recreate; then
    echo -e "${GREEN}Container updated and restarted successfully!${NC}"
else
    echo -e "${RED}Error: Failed to update container.${NC}"
    exit 1
fi

# Wait for health check
echo -e "${BLUE}Checking service status...${NC}"
PORT=2080
max_retries=10
retry_count=0
success=false

while [ $retry_count -lt $max_retries ]; do
    STATUS=$(docker inspect --format='{{.State.Status}}' peter-chang-site 2>/dev/null)
    HEALTH=$(docker inspect --format='{{.State.Health.Status}}' peter-chang-site 2>/dev/null)
    
    if [ "$STATUS" = "running" ]; then
        if [ "$HEALTH" = "healthy" ] || [ -z "$HEALTH" ]; then
            success=true
            break
        fi
    fi
    
    echo -n "."
    sleep 2
    retry_count=$((retry_count + 1))
done

echo ""

if [ "$success" = true ]; then
    echo -e "${GREEN}===========================================${NC}"
    echo -e "${GREEN}Update and Deployment Successful!${NC}"
    echo -e "${GREEN}Website is running at: http://localhost:$PORT${NC}"
    echo -e "${GREEN}===========================================${NC}"
else
    echo -e "${YELLOW}Warning: Container restarted but healthcheck is still pending or failing.${NC}"
    echo -e "${YELLOW}Please check container logs: docker logs peter-chang-site${NC}"
fi
