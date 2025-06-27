# Use an official Ubuntu runtime as a parent image
FROM ubuntu:22.04

# Set environment variable for the port
ENV PORT=8080

# Install dependencies and code-server
RUN apt-get update && \
    apt-get install -y curl wget gnupg software-properties-common && \
    curl -fsSL https://code-server.dev/install.sh | sh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Create a non-root user 'coder' and set it as the default user
RUN useradd -m coder && \
    mkdir -p /home/coder/.local/share/code-server && \
    chown -R coder:coder /home/coder/.local/share/code-server

# Set the working directory for the 'coder' user
WORKDIR /home/coder

# Set the user to 'coder' for subsequent commands and the CMD
USER coder

# Declare volumes for persistence.
VOLUME /home/coder/.local/share/code-server
VOLUME /home/coder/projects

# Expose the correct port
EXPOSE $PORT

# Start code-server with NO authentication (DANGEROUS for public servers!)
CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "none"]
