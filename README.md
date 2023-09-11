# setup_network_monitoring

Run the setup script to set up the environment:
> ./setup.sh

The setup script performs the following actions:

- Clones the icmp_ping_exporter repository and builds the Docker image.
- Creates a Docker bridge network.
- Starts Prometheus, Grafana, and icmp_ping_exporter using Docker Compose.
- Access Prometheus at port 9090 and Grafana at port 3000 after the setup is complete.
