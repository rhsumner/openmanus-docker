# OpenManus Web - Docker Setup

This directory contains Docker configuration for running OpenManus Web in a containerized environment. The application supports both OpenAI's API and custom API endpoints that are compatible with the OpenAI API format.

## Project Structure

```
.
├── docker-compose.yml    # Docker Compose configuration
├── Dockerfile           # Container build instructions
├── README.md           # This documentation
├── setup.sh            # Interactive setup script
└── config/
    └── config.toml     # Application configuration
```

## Prerequisites

- Docker
- Docker Compose

## Quick Start

1. Clone this repository:
```bash
git clone https://github.com/YunQiAI/OpenManusWeb.git
cd OpenManusWeb
```

2. Run the setup script:
```bash
./setup.sh
```

The setup script will:
- Check for Docker and Docker Compose installation
- Create or update the configuration file (only if requested)
- Prompt for:
  - OpenAI API key
  - API base URL (optional, defaults to OpenAI's API)
  - Model selection (GPT-4, GPT-3.5-turbo, or custom)
  - Temperature (optional)
- Build and start the container
- Open the web interface in your default browser

## Manual Configuration

If you prefer to configure manually:

1. Create the config directory and file:
```bash
mkdir -p config
touch config/config.toml
```

2. Edit `config/config.toml` with your settings:
```toml
[llm.default]
api_key = "your-api-key"
model = "gpt-4"  # or your preferred model
base_url = "https://api.openai.com/v1"  # or your custom API endpoint
api_type = "openai"
temperature = 0.7
max_tokens = 2000

[web]
host = "0.0.0.0"
port = 8000
debug = false

[logging]
level = "INFO"
```

3. Build and start the container:
```bash
docker compose up --build -d
```

## Usage

Once running, access the web interface at:
```
http://localhost:8000
```

## Common Commands

- View logs:
```bash
docker compose logs -f
```

- Stop the service:
```bash
docker compose down
```

- Restart the service:
```bash
docker compose restart
```

- Update configuration:
```bash
# Edit the config file
nano config/config.toml

# Restart the service to apply changes
docker compose restart
```

## Configuration Options

The `config/config.toml` file supports the following sections and options:

[llm.default]
- `api_key`: Your API key for the language model service
- `model`: The model to use (default: "gpt-4")
- `base_url`: API endpoint URL (default: "https://api.openai.com/v1")
- `api_type`: Type of API to use (default: "openai")
- `api_version`: Required for Azure OpenAI (optional)
- `temperature`: Model temperature (default: 0.7)
- `max_tokens`: Maximum tokens per request (default: 2000)

[web]
- `host`: Host to bind to (default: "0.0.0.0")
- `port`: Port to listen on (default: 8000)
- `debug`: Enable debug mode (default: false)

[logging]
- `level`: Log level (default: "INFO")
- `format`: Log format string

## Troubleshooting

1. If the container fails to start:
   - Check the logs: `docker compose logs -f`
   - Verify your API key in `config/config.toml`
   - If using a custom API endpoint, verify it's accessible
   - Ensure ports are not in use

2. If you can't access the web interface:
   - Check if the container is running: `docker ps`
   - Verify the port mapping in `docker-compose.yml`
   - Check your firewall settings
   - For macOS/Linux users, check if the browser opens automatically
   - Try accessing http://localhost:8000 manually

3. If you're using a custom API endpoint:
   - Verify the endpoint is accessible from your host: `curl -i your-api-endpoint/v1/models`
   - Check if the endpoint is reachable from the container:
     ```bash
     # Get container ID
     docker compose ps
     # Test API connection from container
     docker compose exec web curl -i your-api-endpoint/v1/models
     ```
   - Verify your API key and model settings in `config/config.toml`

4. For other issues:
   - Try rebuilding: `docker compose up --build -d`
   - Check the application logs inside the container
   - Try running setup again: `./setup.sh`

## Contributing

Feel free to open issues or submit pull requests if you find any problems or have suggestions for improvements.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
