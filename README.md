# Development Console Docker Environment

This repository provides a Docker-based development environment with pre-installed common tools, allowing you to start developing quickly without manual setup.

## Included Tools

- Python 3.11 (base image)
- OpenJDK 17
- Maven 3.9.6
- Terraform 1.6.6
- AWS CLI v2
- Git, Telnet, Net-tools, Ping

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

## Example Use Cases

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
