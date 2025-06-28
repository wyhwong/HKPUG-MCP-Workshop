FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl gnupg ca-certificates git sudo wget libatomic1 procps htop zip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_22.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y nodejs && \
    npm install -g npm@latest

# Create a non-root user
RUN useradd -ms /bin/bash coder && \
    echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd

RUN chmod -R 777 /usr && \
    chmod 4755 /usr/bin/sudo

# Download and install VS Code CLI (Linux x64 CLI is most compatible)
RUN curl -L "https://update.code.visualstudio.com/1.100.1/cli-linux-x64/stable" -o vscode-cli.tar.gz && \
    tar -xzf vscode-cli.tar.gz && \
    rm vscode-cli.tar.gz && \
    mv code /usr/local/bin/vscode 

USER coder
WORKDIR /home/coder

RUN setsid vscode serve-web --host 127.0.0.1 --port 9999 --accept-server-license-terms --without-connection-token & \
    sleep 5 && \
    curl -s http://127.0.0.1:9999 > /dev/null && \
    sleep 30 && \
    pkill -f "vscode serve-web" || true

RUN rm -rf /home/coder/.vscode-server/.cache

WORKDIR /app

RUN git clone https://github.com/wyhwong/JUN2025-MCP-Workshop.git

WORKDIR /home/coder

EXPOSE 8000

CMD ["vscode", "serve-web", "--host=0.0.0.0", "--port=8000", "--without-connection-token", "--accept-server-license-terms"]
