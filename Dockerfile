# 1. Use Debian base
FROM debian:bookworm-slim

# 2. Install dependencies (curl for script, sudo for user)
RUN apt-get update && apt-get install -y \
    curl \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# 3. Install sshx using the official script
RUN curl -sSf https://sshx.io/get | sh

# 4. Add user 'ash' with sudo privileges and no password requirement
RUN useradd -m -s /bin/bash ash && \
    usermod -aG sudo ash && \
    echo "ash ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# 5. Switch to user 'ash'
USER ash
WORKDIR /home/ash

# 6. Run sshx
# This starts the client, which connects to sshx.io and prints a link to the logs.
CMD ["sshx"]
