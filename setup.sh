#!/bin/bash

# Get script absolute path
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA_DIR="$SCRIPT_DIR/data"

# Clone or update repo
REPO_NAME="icmp_ping_exporter"
IMAGE_TAG="latest"

REPO_URL="https://github.com/SebaViana/icmp_ping_exporter.git"
RELEASE_VER="v1.0.0"

cd "$DATA_DIR" || exit
if [ -d "$REPO_NAME" ]; then
    echo "Repository directory '$REPO_NAME' already exists."
    cd "$REPO_NAME" || exit
    CURRENT_TAG="$(git describe --tags)"
    if [ "$CURRENT_TAG" = "$RELEASE_VER" ]; then
        echo "Repository is already at release version '$RELEASE_VER'."
    else
        echo "Updating repository to release version '$RELEASE_VER'..."
        git fetch --tags
        git checkout "$RELEASE_VER"
        if [ $? -eq 0 ]; then
            echo "Repository updated to release version '$RELEASE_VER' successfully."
        else
            echo "Failed to update the repository to release version '$RELEASE_VER'."
            exit 1
        fi
    fi
else
    git clone -b "$RELEASE_VER" "$REPO_URL" "$REPO_NAME"
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
