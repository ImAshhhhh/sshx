FROM debian:bookworm-slim

# 1. Install curl, sudo, python3 (for the web server), and whois (for passwords)
RUN apt-get update && apt-get install -y \
    curl \
    sudo \
    python3 \
    whois \
    && rm -rf /var/lib/apt/lists/*

# 2. Install sshx
RUN curl -sSf https://sshx.io/get | sh

# 3. Configure Users and Sudo
# - Set root password to 'ash'
# - Create user 'ash' with password 'ash'
# - Add ash to sudo group
# - Fix PAM configuration so sudo works in Docker
RUN echo "root:ash" | chpasswd && \
    useradd -m -s /bin/bash -G sudo,root ash && \
    echo "ash:ash" | chpasswd && \
    sed -i 's/^# %sudo/%sudo/' /etc/sudoers && \
    echo "ash ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

# 4. Switch to user ash
USER ash
WORKDIR /home/ash

# 5. Set the Port environment variable
ENV PORT=8080

# 6. Start the dummy web server (Background) AND sshx (Foreground)
# This keeps Render happy (Port 8080 open) AND gives you the terminal link
CMD python3 -m http.server $PORT --bind 0.0.0.0 & sshx
