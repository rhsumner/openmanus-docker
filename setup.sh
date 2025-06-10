#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to open browser
open_browser() {
    sleep 5  # Give the service time to start
    if [[ "$OSTYPE" == "darwin"* ]]; then
        open "http://localhost:8000"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        xdg-open "http://localhost:8000" &>/dev/null || sensible-browser "http://localhost:8000" &>/dev/null || \
        echo -e "${YELLOW}Please open http://localhost:8000 in your browser${NC}"
    else
        echo -e "${YELLOW}Please open http://localhost:8000 in your browser${NC}"
    fi
}

# Check if Docker is new enough'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}OpenManus Web Setup Script${NC}\n"

# Function to validate API key format (basic check)
validate_api_key() {
    local key=$1
    if [[ ! $key =~ ^sk-[A-Za-z0-9]{32,}$ ]]; then
        echo -e "${YELLOW}Warning: The API key format doesn't look standard. Please verify it's correct.${NC}"
    fi
}

# Check if config exists
if [ -f "config/config.toml" ]; then
    echo -e "${YELLOW}Existing config found. Do you want to reconfigure? (y/N)${NC}"
    read -r response
    if [[ ! $response =~ ^[Yy]$ ]]; then
        echo "Keeping existing configuration."
        docker compose up --build -d
        open_browser
        exit 0
    fi
fi

# Create config directory if it doesn't exist
mkdir -p config

# Configure OpenAI settings
echo -e "\nLet's configure your OpenAI settings:"

# Get API key
echo -e "\nPlease enter your OpenAI API key:"
read -r api_key
validate_api_key "$api_key"
sed -i.bak "s/api_key = \".*\"/api_key = \"$api_key\"/" config/config.toml
rm -f config/config.toml.bak

# Ask about base URL
echo -e "\nWould you like to use a different API base URL? (Default: https://api.openai.com/v1) (y/N)"
read -r change_url
if [[ $change_url =~ ^[Yy]$ ]]; then
    echo "Enter the API base URL:"
    read -r base_url
    sed -i.bak "s|base_url = \".*\"|base_url = \"$base_url\"|" config/config.toml
    rm -f config/config.toml.bak
fi

# Ask about model
echo -e "\nWhich GPT model would you like to use? (default: gpt-4)"
echo "1) GPT-4 (default)"
echo "2) GPT-3.5-turbo"
echo "3) Other"
read -r model_choice

case $model_choice in
    1|"")
        # Default GPT-4
        sed -i.bak 's/model = ".*"/model = "gpt-4"/' config/config.toml
        ;;
    2)
        # GPT-3.5-turbo
        sed -i.bak 's/model = ".*"/model = "gpt-3.5-turbo"/' config/config.toml
        ;;
    3)
        # Custom model
        echo "Enter the model name:"
        read -r custom_model
        sed -i.bak "s/model = \".*\"/model = \"$custom_model\"/" config/config.toml
        ;;
esac
rm -f config/config.toml.bak

# Ask about temperature
echo -e "\nWould you like to adjust the temperature? (Default: 0.7) (y/N)"
read -r change_temp
if [[ $change_temp =~ ^[Yy]$ ]]; then
    echo "Enter temperature value (0.0 - 2.0):"
    read -r temp_value
    sed -i.bak "s/temperature = 0.7/temperature = $temp_value/" config/config.toml
    rm -f config/config.toml.bak
fi

# Check if Docker is installed
if ! command -v docker >/dev/null 2>&1; then
    echo -e "\n${YELLOW}Docker is not installed. Please install Docker and Docker Compose before proceeding.${NC}"
    echo "Visit https://docs.docker.com/get-docker/ for installation instructions."
    exit 1
fi

# Check if Docker is new enough to have compose command
if ! docker compose version >/dev/null 2>&1; then
    echo -e "\n${YELLOW}Your Docker version doesn't support 'docker compose'. Please update Docker to the latest version.${NC}"
    echo "Visit https://docs.docker.com/get-docker/ for installation instructions."
    exit 1
fi

echo -e "\n${GREEN}Configuration complete! Starting OpenManus Web...${NC}"

# Start the container
echo -e "\n${GREEN}Starting OpenManus Web...${NC}"
docker compose up --build -d

# Open browser
open_browser

echo -e "\n${GREEN}OpenManus Web is now running!${NC}"
echo -e "\nTo view logs: ${YELLOW}docker compose logs -f${NC}"
echo -e "To stop: ${YELLOW}docker compose down${NC}"
echo -e "To access later: ${YELLOW}http://localhost:8000${NC}"
