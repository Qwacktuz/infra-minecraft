# Project Overview

This project provides the infrastructure and configuration to run a Minecraft server using a GitOps approach. The infrastructure is defined using OpenTofu and deployed on Hetzner Cloud. The Minecraft server and its supporting services are run as Docker containers using Docker Compose.

The key features of this project are:

*   **Infrastructure as Code:** The entire infrastructure is managed using OpenTofu, making it easy to reproduce and manage.
*   **GitOps:** The project is designed to be managed through Git, with changes to the infrastructure and application configuration being applied automatically.
*   **Security:** The project uses Tailscale for secure networking and runs Docker in rootless mode to minimize the attack surface.
*   **Monitoring:** The project includes a comprehensive monitoring stack with Prometheus for metrics, Loki for logs, and Grafana for visualization.
*   **Backups:** The project uses Restic and Rclone to take regular backups of the Minecraft world and store them in a Cloudflare R2 bucket.

## Building and Running

The project is divided into two main parts: the infrastructure and the application.

### Infrastructure

The infrastructure is defined in the `tofu` directory and is managed using OpenTofu. To deploy the infrastructure, you will need to have OpenTofu installed and configured with your Hetzner Cloud API token.

```bash
# Initialize OpenTofu
tofu -C tofu init

# Plan the infrastructure changes
tofu -C tofu plan

# Apply the infrastructure changes
tofu -C tofu apply
```

### Application

The application is defined in the `app` directory and is managed using Docker Compose. To run the application, you will need to have Docker and Docker Compose installed on the server.

```bash
# Start the application
docker compose -f app/compose.yml up -d

# Stop the application
docker compose -f app/compose.yml down
```

## Development Conventions

*   **Infrastructure:** All infrastructure changes should be made in the `tofu` directory and applied using OpenTofu.
*   **Application:** All application changes should be made in the `app` directory and applied using Docker Compose.
*   **Secrets:** Secrets are managed using environment variables. The `README.md` file notes that this could be improved by using a more secure method like Docker secrets or sops.
*   **Monitoring:** The project uses Prometheus, Loki, and Grafana for monitoring. The configuration for these services can be found in the `app` directory.
*   **Backups:** The project uses Restic and Rclone for backups. The backup configuration can be found in the `app/compose.yml` file.
