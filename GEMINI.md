# Gemini Project: Minecraft SMP Infrastructure

This document provides a comprehensive overview of the Minecraft SMP project for the Gemini CLI.

## Project Overview

This project manages a Minecraft server using an Infrastructure as Code (IaC) approach. It automates the provisioning of a server on Hetzner Cloud and the deployment of a multi-container Docker application.

The key technologies and components are:

*   **Infrastructure as Code:** [OpenTofu](https://opentofu.org/) (a fork of Terraform) is used to define and manage the cloud infrastructure. The configuration is in the `tofu/` directory.
*   **Cloud Provider:** [Hetzner Cloud](https://www.hetzner.com/cloud) is the cloud provider used to host the server.
*   **Configuration Management:** [cloud-init](https://cloud-init.io/) is used for initial server setup, including user creation, package installation, and security configuration.
*   **Containerization:** [Docker](https://www.docker.com/) is used to containerize the Minecraft server and its supporting services. The Docker Compose configuration is in `app/compose.yml`.
*   **Application:** A [Fabric](https://fabricmc.net/) Minecraft server with several mods, managed by the `itzg/minecraft-server` Docker image.
*   **Backups:** The `itzg/mc-backup` Docker image is used with [Restic](https://restic.net/) to create and store encrypted, incremental backups to a [Cloudflare R2](https://www.cloudflare.com/products/r2/) bucket.
*   **Monitoring & Logging:** A comprehensive monitoring and logging stack is included, featuring [Prometheus](https://prometheus.io/), [Grafana](https://grafana.com/), [Loki](https://grafana.com/oss/loki/), and [Grafana Alloy](https://grafana.com/oss/alloy/).
*   **Security:** The project uses [Tailscale](https://tailscale.com/) to create a secure network between the server and the administrator. Rootless Docker is also used to enhance security.
*   **Management:** [Portainer](https://www.portainer.io/) is included for easy management of the Docker environment.

## Building and Running

### Prerequisites

*   [OpenTofu](https://opentofu.org/docs/intro/install/) (or Terraform)
*   [Hetzner Cloud API Token](https://docs.hetzner.com/cloud/api/getting-started/generating-api-token/)
*   [Tailscale Auth Key](https://tailscale.com/kb/1085/auth-keys/)
*   [Cloudflare R2 credentials](https://developers.cloudflare.com/r2/api/s3/tokens/)
*   An SSH key pair

### Infrastructure Deployment

1.  Navigate to the `tofu/` directory.
2.  Create a `terraform.tfvars` file with the required variables (e.g., `hcloud_token`, `ssh_public_key`, `tailscale_auth_key`, etc.). See `variables.tf` for the full list.
3.  Initialize OpenTofu: `tofu init`
4.  Apply the configuration: `tofu apply`

This will provision the server and run the `cloud-init` script to set up the environment.

### Application Deployment

1.  SSH into the newly created server.
2.  Navigate to the `app/` directory.
3.  Create a `.env` file with the required environment variables (e.g., `RCON_PASSWORD`, `RESTIC_PASSWORD`, `R2_ACCESS_KEY_ID`, etc.). See `app/compose.yml` for the full list.
4.  Start the application: `docker compose up -d`

### Backup and Restore

*   **Backups:** Backups are created automatically every 6 hours by the `backup` service.
*   **Restore:** To restore a backup, run the `./scripts/restore-backup.sh` script in the `app/` directory.

## Development Conventions

*   **Infrastructure:** All infrastructure changes should be made in the `tofu/` directory and applied with OpenTofu.
*   **Application:** Application configuration and services are defined in `app/compose.yml`.
*   **Secrets:** Secrets are managed through environment variables. For a production environment, it is recommended to use a more secure method like Docker secrets or a secret management tool.
*   **Modifications:** The Minecraft server can be customized by modifying the `MODRINTH_PROJECTS` environment variable in `app/compose.yml`.
*   **Backups:** The backup schedule and retention policy can be configured in `app/compose.yml`.
