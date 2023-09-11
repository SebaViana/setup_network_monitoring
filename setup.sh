#!/bin/bash

# Get script absolute path
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA_DIR="$SCRIPT_DIR/data"

# Clone or update repo
REPO_NAME="icmp_ping_exporter"
IMAGE_TAG="latest"

REPO_URL="https://github.com/SebaViana/icmp_ping_exporter.git"

cd "$DATA_DIR" || exit
if [ -d "$REPO_NAME" ]; then
    echo "Repository directory '$REPO_NAME' already exists. Updating..."
    cd "$REPO_NAME" || exit
    git pull
    if [ $? -eq 0 ]; then
        echo "Repository updated successfully."
    else
        echo "Failed to update the repository."
        exit 1
    fi
else
    git clone "$REPO_URL" "$REPO_NAME"
    if [ $? -eq 0 ]; then
        echo "Repository cloned successfully."
    else
        echo "Failed to clone the repository."
        exit 1
    fi
fi

# Build Docker image
cd "$DATA_DIR/$REPO_NAME" || exit

docker build -t "$REPO_NAME:$IMAGE_TAG" .

if [ $? -eq 0 ]; then
    echo "Docker image '$REPO_NAME:$IMAGE_TAG' built successfully."
else
    echo "Failed to build the Docker image."
    exit 1
fi

# Run Ansible playbook, it runs also Docker Compose
cd $SCRIPT_DIR
ansible-playbook main.yml
