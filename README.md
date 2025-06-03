# Development Console Docker Environment

This repository provides a Docker-based development environment with pre-installed common tools, allowing you to start developing quickly without manual setup.

## Included Tools

- Python 3.11 (base image)
- OpenJDK 17
- Maven 3.9.6
- Node.js 20.10.0 (via NVM 0.39.7)
- Terraform 1.6.6
- AWS CLI v2
- Git, Telnet, Net-tools, Ping

## Environment Variables

The following environment variables are pre-configured:

```bash
JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
M2_HOME=/opt/maven
MAVEN_HOME=/opt/maven
NVM_DIR=/usr/local/nvm
```

## Building the Image

To build the Docker image locally:

```bash
docker build -t dev-console -f dev-console.Dockerfile .
```

## Using the Development Environment

### Basic Usage

Start a new container with:

```bash
docker run -it dev-console
```

### Recommended Usage

To persist your work and configurations, mount your local directories and configuration files:

```bash
docker run -it \
  -v $(pwd):/workspace \
  -v $HOME/.aws:/home/devuser/.aws \
  -v $HOME/.m2:/home/devuser/.m2 \
  dev-console
```

This command:
- Mounts current directory as `/workspace` in the container
- Mounts AWS credentials for AWS CLI access
- Mounts Maven repository to avoid re-downloading dependencies

### Working Directory

The container starts with a non-root user `devuser` for security. When mounting volumes, make sure the permissions are set correctly:

```bash
# If you encounter permission issues with mounted volumes
chown -R $(id -u):$(id -g) .
```

## Troubleshooting

### Permission Issues
1. If you encounter permission errors when mounting volumes:
   ```bash
   # On your host machine
   sudo chown -R $(id -u):$(id -g) /path/to/mounted/directory
   ```

### Node.js/npm Issues
1. If Node.js commands aren't working, ensure NVM is loaded:
   ```bash
   source $NVM_DIR/nvm.sh
   ```
2. To switch Node.js versions:
   ```bash
   nvm use <version>
   ```

### Maven Dependencies
1. If Maven can't download dependencies:
   ```bash
   # Check if .m2 directory is properly mounted
   ls -la /home/devuser/.m2
   ```

## Example Use Cases

### Node.js Development
```bash
docker run -it \
  -v $(pwd):/workspace \
  -p 3000:3000 \
  dev-console bash -c "source $NVM_DIR/nvm.sh && npm start"
```

### Python Development

```bash
docker run -it -v $(pwd):/workspace dev-console python3 your_script.py
```

### Java/Maven Project

```bash
docker run -it \
  -v $(pwd):/workspace \
  -v $HOME/.m2:/home/devuser/.m2 \
  dev-console mvn clean install
```

### AWS CLI Commands

```bash
docker run -it \
  -v $HOME/.aws:/home/devuser/.aws \
  dev-console aws s3 ls
```

### Terraform Operations

```bash
docker run -it \
  -v $(pwd):/workspace \
  -v $HOME/.aws:/home/devuser/.aws \
  dev-console terraform init
```

## Security Notes

- The container runs as non-root user `devuser` for enhanced security
- Sensitive credentials should be mounted at runtime (e.g., AWS credentials)
- Avoid storing secrets in the image or in environment variables
- Use `--read-only` flag when running containers that don't need write access
- Consider using Docker secrets for sensitive data in production
- Regularly update base images and dependencies to patch security vulnerabilities
- Use environment-specific configuration files instead of hardcoding values
- When exposing ports, use `-p 127.0.0.1:3000:3000` instead of `-p 3000:3000` to limit access to localhost

## Best Practices

### Building Images
```bash
# Use build cache efficiently
docker build --no-cache -t dev-console -f dev-console.Dockerfile .

# Build with specific architecture
docker build --platform linux/amd64 -t dev-console -f dev-console.Dockerfile .
```

### Running Containers
```bash
# With resource limits
docker run -it \
  --memory=2g \
  --cpus=2 \
  -v $(pwd):/workspace \
  dev-console

# With network isolation
docker run -it \
  --network=host \
  -v $(pwd):/workspace \
  dev-console
```

### Development Workflow
- Use volume mounts for source code during development
- Consider using Docker Compose for complex multi-container setups
- Use `.dockerignore` to exclude unnecessary files from builds
- Keep containers ephemeral and stateless
