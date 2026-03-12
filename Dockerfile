FROM debian:bookworm-slim

# Install essential tools (bash, sudo, curl)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    sudo \
    ca-certificates \
    bash \
    wget \
    openssh-client \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------
# INSTALL SSHX (Official Script)
# ----------------------------------------------------
RUN mkdir -p ~/.local/bin
# Download and run the official installer script
# It places binaries in ~/.local/bin or /usr/local/bin
RUN curl -fsSL https://sshx.io/get | sh
# Ensure binary is in PATH
RUN if [ -f /root/.local/bin/sshx ]; then cp /root/.local/bin/sshx /usr/local/bin/sshx; chmod +x /usr/local/bin/sshx; fi

# ----------------------------------------------------
# FIX SUDO & CREATE USER 'ASH'
# ----------------------------------------------------
# 1. Add 'ash' user and give them sudo group membership
RUN groupadd -r sudo && useradd -m -s /bin/bash -G sudo ash

# 2. Disable 'requiretty' (Fixes common sudo errors inside Docker)
RUN echo 'Defaults !requiretty' > /etc/sudoers.d/disable-requiretty && \
    chmod 0440 /etc/sudoers.d/disable-requiretty

# 3. Give 'ash' FULL SUDO Access
# Using NOPASSWD makes it seamless for 'sshx' connections
RUN echo 'ash ALL=(ALL:ALL) NOPASSWD:ALL' > /etc/sudoers.d/ash && \
    chmod 0440 /etc/sudoers.d/ash

# 4. (Optional) Set ROOT PASSWORD 
# IMPORTANT: Only do this if you know the risks. 
# Default here is 'ash_root_pass_123'. Change it!
RUN echo 'root:ash_root_pass_123' | chpasswd

# ----------------------------------------------------
# CONFIGURE RUNTIME
# ----------------------------------------------------
WORKDIR /home/ash
USER ash

# Export the PORT variable Render provides
# Defaults to 8080 if Render isn't providing one yet
ENV PORT=8080

# Bind to 0.0.0.0 so Render can forward traffic
# Keep it alive by continuously running the server
EXPOSE 8080

# START SSHX SERVER
CMD ["bash", "-c", "exec /usr/local/bin/sshx server --host 0.0.0.0 --port ${PORT}"]
