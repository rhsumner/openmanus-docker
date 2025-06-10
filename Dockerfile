FROM python:3.12-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Clone the repository
RUN git clone https://github.com/YunQiAI/OpenManusWeb.git .

# Create virtual environment and install dependencies
RUN python -m venv .venv \
    && . .venv/bin/activate \
    && pip install --no-cache-dir -r requirements.txt

# Create config directory and copy configuration
RUN mkdir -p /app/config
COPY config/config.toml /app/config/config.toml

# Expose the default port
EXPOSE 8000

# Start the application
CMD [".venv/bin/uvicorn", "app.web.app:app", "--host", "0.0.0.0", "--port", "8000"]
