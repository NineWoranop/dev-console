# Base image
FROM python:3.11-slim

# Set tool versions
ENV MAVEN_VERSION=3.9.6
ENV TERRAFORM_VERSION=1.6.6
ENV NODE_VERSION=20.10.0
ENV NVM_VERSION=0.39.7
ENV NVM_DIR=/usr/local/nvm
ENV DOCKER_COMPOSE_VERSION=2.20.2

# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 \
    M2_HOME=/opt/maven \
    MAVEN_HOME=/opt/maven \
    PATH=/usr/lib/jvm/java-17-openjdk-amd64/bin:/opt/maven/bin:/usr/local/bin:/aws-cli/v2/current/bin:${PATH}

# Install tools and dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    openjdk-17-jdk-headless \
    ca-certificates \
    git \
    telnet \
    net-tools \
    inetutils-ping \
    unzip \
    openssl \
    fuse-overlayfs \
    lsb-release \
    gnupg && \
    # Install Maven
    curl -fsSL https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz | tar -xz -C /opt && \
    mv /opt/apache-maven-${MAVEN_VERSION} /opt/maven && \
    # Install Terraform
    curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip && \
    unzip terraform.zip -d /usr/local/bin && rm terraform.zip && chmod +x /usr/local/bin/terraform && \
    # Install AWS CLI v2
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && ./aws/install && rm -rf awscliv2.zip aws && \
    # Install NVM and Node.js
    mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | bash && \
    . $NVM_DIR/nvm.sh && nvm install $NODE_VERSION && nvm alias default $NODE_VERSION && nvm use default && \
    # Install Docker
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && apt-get install -y --no-install-recommends docker-ce docker-ce-cli containerd.io && \
    # Install Docker Compose
    curl -L "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose && \
    # Clean up
    apt-get clean && rm -rf /var/lib/apt/lists/* /var/cache/apt/* /tmp/* /var/tmp/*

# Verify installations
RUN set -x && \
    java -version && python3 --version && mvn --version && terraform version && aws --version && \
    . $NVM_DIR/nvm.sh && node --version && npm --version && nvm --version && \
    docker --version && docker-compose --version

# Default command
CMD ["bash"]
