#!/bin/bash

# Get script absolute path
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPOS_DIR="$SCRIPT_DIR/data/repos"

# Clone or update icmp_ping_exporter repo
ICMP_REPO_NAME="icmp_ping_exporter"
ICMP_IMAGE_TAG="latest"

ICMP_REPO_URL="https://github.com/SebaViana/icmp_ping_exporter.git"
ICMP_RELEASE_VER="v1.0.0"

mkdir -p "$REPOS_DIR"  # Ensure the repos directory exists

cd "$REPOS_DIR" || exit
if [ -d "$ICMP_REPO_NAME" ]; then
    echo "Repository directory '$ICMP_REPO_NAME' already exists."
    cd "$ICMP_REPO_NAME" || exit
    CURRENT_TAG="$(git describe --tags)"
    if [ "$CURRENT_TAG" = "$ICMP_RELEASE_VER" ]; then
        echo "Repository is already at release version '$ICMP_RELEASE_VER'."
    else
        echo "Updating repository '$ICMP_REPO_NAME' to release version '$ICMP_RELEASE_VER'..."
        git fetch --tags
        git checkout "$ICMP_RELEASE_VER"
        if [ $? -eq 0 ]; then
            echo "Repository updated to release version '$ICMP_RELEASE_VER' successfully."
        else
            echo "Failed to update the repository to release version '$ICMP_RELEASE_VER'."
            exit 1
        fi
    fi
else
    git clone -b "$ICMP_RELEASE_VER" "$ICMP_REPO_URL" "$ICMP_REPO_NAME"
    if [ $? -eq 0 ]; then
        echo "Repository '$ICMP_REPO_NAME' cloned successfully."
    else
        echo "Failed to clone the repository '$ICMP_REPO_NAME'."
        exit 1
    fi
fi

# Build Docker image for icmp_ping_exporter
cd "$REPOS_DIR/$ICMP_REPO_NAME" || exit

docker build -t "$ICMP_REPO_NAME:$ICMP_IMAGE_TAG" .

if [ $? -eq 0 ]; then
    echo "Docker image '$ICMP_REPO_NAME:$ICMP_IMAGE_TAG' built successfully."
else
    echo "Failed to build the Docker image for '$ICMP_REPO_NAME'."
    exit 1
fi

# Clone or update speedtest_exporter repo
SPEEDTEST_REPO_NAME="speedtest_exporter"
SPEEDTEST_IMAGE_TAG="latest"

SPEEDTEST_REPO_URL="https://github.com/SebaViana/speedtest_exporter.git"

if [ -d "$SPEEDTEST_REPO_NAME" ]; then
    echo "Repository directory '$SPEEDTEST_REPO_NAME' already exists."
    cd "$REPOS_DIR" || exit
else
    git clone "$SPEEDTEST_REPO_URL" "$REPOS_DIR/$SPEEDTEST_REPO_NAME"
    if [ $? -eq 0 ]; then
        echo "Repository '$SPEEDTEST_REPO_NAME' cloned successfully."
    else
        echo "Failed to clone the repository '$SPEEDTEST_REPO_NAME'."
        exit 1
    fi
fi

# Build Docker image for speedtest_exporter
cd "$REPOS_DIR/$SPEEDTEST_REPO_NAME" || exit

docker build -t "$SPEEDTEST_REPO_NAME:$SPEEDTEST_IMAGE_TAG" .

if [ $? -eq 0 ]; then
    echo "Docker image '$SPEEDTEST_REPO_NAME:$SPEEDTEST_IMAGE_TAG' built successfully."
else
    echo "Failed to build the Docker image for '$SPEEDTEST_REPO_NAME'."
    exit 1
fi

# Run Ansible playbook, it runs also Docker Compose
cd "$SCRIPT_DIR"
ansible-playbook main.yml
