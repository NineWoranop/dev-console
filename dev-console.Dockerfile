# Base image
FROM python:3.11-slim

# Set tool versions
ENV MAVEN_VERSION=3.9.6
ENV TERRAFORM_VERSION=1.6.6

# Set environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 \
    M2_HOME=/opt/maven \
    MAVEN_HOME=/opt/maven \
    PATH=/usr/lib/jvm/java-17-openjdk-amd64/bin:/opt/maven/bin:/usr/local/bin:/aws-cli/v2/current/bin:${PATH}

# Install required tools and dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    openjdk-17-jdk-headless \
    ca-certificates \
    git \
    telnet \
    net-tools \
    inetutils-ping \
    unzip \
    # Install Maven
    && curl -fsSL https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz -o maven.tar.gz \
    && tar -xzf maven.tar.gz -C /opt \
    && mv /opt/apache-maven-${MAVEN_VERSION} /opt/maven \
    && rm maven.tar.gz \
    # Install Terraform
    && curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip \
    && unzip terraform.zip -d /usr/local/bin \
    && rm terraform.zip \
    && chmod +x /usr/local/bin/terraform \
    # Install AWS CLI v2
    && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws \
    # Clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# Create non-root user
RUN useradd -m -s /bin/bash devuser \
    && chown -R devuser:devuser /opt/maven

# Verify installations
RUN set -x \
    && java -version \
    && python3 --version \
    && mvn --version \
    && terraform version \
    && aws --version

USER devuser

# Default command
CMD ["bash"]
