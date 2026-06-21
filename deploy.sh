#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Starting Deployment ===${NC}"

# 1. Check Docker installation
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed or not in PATH.${NC}"
    exit 1
fi

# 2. Check if Docker daemon is running
if ! docker info &> /dev/null; then
    echo -e "${RED}Error: Docker daemon is not running. Please start Docker first.${NC}"
    exit 1
fi

# 3. Determine docker compose command (compose V2 vs V1)
if docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
elif command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
else
    echo -e "${RED}Error: Docker Compose is not installed (neither 'docker compose' nor 'docker-compose' found).${NC}"
    exit 1
fi

# 4. Check if port 2080 is occupied
PORT=2080
if lsof -Pi :$PORT -sTCP:LISTEN -t &> /dev/null; then
    # Check if it's our container occupying it
    CONTAINER_ID=$(docker ps -q -f "publish=$PORT")
    if [ ! -z "$CONTAINER_ID" ]; then
        echo -e "${YELLOW}Warning: Port $PORT is already in use by docker container: $CONTAINER_ID.${NC}"
        echo -e "${YELLOW}Stopping and rebuilding...${NC}"
        $DOCKER_COMPOSE down
    else
        echo -e "${RED}Error: Port $PORT is already in use by another process. Please free port $PORT or edit docker-compose.yml.${NC}"
        exit 1
    fi
fi

# 5. Build and Deploy
echo -e "${BLUE}Building and starting container...${NC}"
if $DOCKER_COMPOSE up -d --build; then
    echo -e "${GREEN}Docker container started successfully!${NC}"
else
    echo -e "${RED}Error: Failed to start docker container.${NC}"
    exit 1
fi

# 6. Wait for health check
echo -e "${BLUE}Checking service status...${NC}"
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
    echo -e "${GREEN}Deployment Successful!${NC}"
    echo -e "${GREEN}Website is running at: http://localhost:$PORT${NC}"
    echo -e "${GREEN}===========================================${NC}"
else
    echo -e "${YELLOW}Warning: Container started but healthcheck is still pending or failing.${NC}"
    echo -e "${YELLOW}Please check container logs: docker logs peter-chang-site${NC}"
fi
