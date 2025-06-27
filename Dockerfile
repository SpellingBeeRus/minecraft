# Use an official Ubuntu runtime as a parent image
FROM ubuntu:22.04

# Set environment variable for the port
ENV PORT=8080

# Install dependencies and code-server
# Combine commands to reduce image layers and clean up
RUN apt-get update && \
    apt-get install -y curl wget gnupg software-properties-common && \
    curl -fsSL https://code-server.dev/install.sh | sh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create a non-root user 'coder' and set it as the default user
# This is a good security practice. code-server runs well as non-root.
RUN useradd -m coder && \
    # Ensure the data directory for code-server is owned by 'coder'
    # The install.sh script places data in ~/.local/share/code-server,
    # which for root is /root/.local/share/code-server.
    # We want it in /home/coder/.local/share/code-server for the 'coder' user.
    # So, we'll create it and set permissions.
    mkdir -p /home/coder/.local/share/code-server && \
    chown -R coder:coder /home/coder/.local/share/code-server

# Set the working directory for the 'coder' user
WORKDIR /home/coder

# Set the user to 'coder' for subsequent commands and the CMD
USER coder

# Declare volumes for persistence.
# These are the paths *inside* the container that you will map to your host.
# /home/coder/.local/share/code-server for code-server's own data (settings, extensions)
# /home/coder/projects for your actual code projects
VOLUME /home/coder/.local/share/code-server
VOLUME /home/coder/projects

# Expose the correct port
EXPOSE $PORT

# Start code-server (listen on all interfaces)
# IMPORTANT: Do NOT use --auth none on a public server!
# Use --auth password to set a password, or omit it to use a config file.
CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "password"]
# If you prefer to manage authentication via a config file (e.g., ~/.config/code-server/config.yaml),
# you can just use:
# CMD ["code-server", "--bind-addr", "0.0.0.0:8080"]
