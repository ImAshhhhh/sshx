FROM debian:bookworm-slim

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    sudo \
    ca-certificates \
    bash \
    git \
    passwd \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------
# INSTALL SSHX (Official Script)
# ----------------------------------------------------
RUN curl -fsSL https://sshx.io/get | sh
# Move binary to PATH
RUN mkdir -p /usr/local/bin && \
    [ -f ~/.local/bin/sshx ] && cp ~/.local/bin/sshx /usr/local/bin/sshx || true && \
    chmod +x /usr/local/bin/sshx

# ----------------------------------------------------
# CREATE USERS
# ----------------------------------------------------
# 1. Create 'ash' user with password
RUN echo 'ash:ash_pass_123' | chpasswd \
    && groupadd -r sudo && useradd -m -s /bin/bash -G sudo ash

# 2. Set 'root' Password
RUN echo 'root:root_pass_123' | chpasswd

# 3. Fix Sudo (Even though it's blocked on Render, setup is good practice)
RUN echo 'Defaults !requiretty' > /etc/sudoers.d/disable-requiretty && \
    echo 'ash ALL=(ALL:ALL) NOPASSWD:ALL' > /etc/sudoers.d/ash && \
    chmod 0440 /etc/sudoers.d/*

# ----------------------------------------------------
# CONFIGURATION
# ----------------------------------------------------
WORKDIR /home/ash

# DO NOT USE USER ash HERE. 
# Running as root allows us to bypass the Render Kernel flag.
# ENV USER=root # Explicit set if needed, but root is default UID 0

EXPOSE 8080

# Start SSHX as ROOT to bypass 'no new privileges' restrictions
CMD ["bash", "-c", "exec /usr/local/bin/sshx server --host 0.0.0.0 --port ${PORT}"]
