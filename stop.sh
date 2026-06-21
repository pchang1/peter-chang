#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Stopping Service ===${NC}"

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

# Stop and remove containers, networks, images, and volumes
echo -e "${BLUE}Stopping and removing container...${NC}"
if $DOCKER_COMPOSE down; then
    echo -e "${GREEN}===========================================${NC}"
    echo -e "${GREEN}Service stopped and container removed successfully!${NC}"
    echo -e "${GREEN}===========================================${NC}"
else
    echo -e "${RED}Error: Failed to stop service.${NC}"
    exit 1
fi
