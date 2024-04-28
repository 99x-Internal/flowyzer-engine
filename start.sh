#!/bin/bash

set -eo pipefail

email_prompt() {
    read -p "Please provide us with your email address: " EMAIL
    while true; do
        if [ -z "$EMAIL" ]; then
            break
        fi
        read -p "Is this email correct? $EMAIL - [y/n]: " yn
        case $yn in
        [Yy]*) break ;;
        [Nn]*)
            email_prompt
            exit 1
            ;;
        esac
    done
    printf "Thank you! 🙏\n"
}

function parseFlags() {
    while (($#)); do
        case "$1" in
        --source)
            source=$2
            shift 2
            ;;
        *)
            echo "Unrecognized arg: $1"
            shift
            ;;
        esac
    done
}

main() {
    # Check if .env fle exisits, if not rename env.dev to .env
    if [ ! -f .env ]; then
        cp env.dev .env
    fi

    # Check if docker compose is running
    RUNNING=$(docker compose ps -q --status=running | wc -l)
    if [ "$RUNNING" -gt 0 ]; then
        printf "Flowyzer Engine is still running. \n"
        printf "You can stop it with the ./stop.sh command. \n"
        exit 1
    fi

    parseFlags "$@"
    if [[ -n "$source" ]]; then
        SOURCE=$source
    else
        SOURCE="unknown"
    fi
    export FAROS_START_SOURCE=$SOURCE

    # Ensure we're using the latest faros-init image
    # export FAROS_INIT_IMAGE=farosai.docker.scarf.sh/farosai/faros-ce-init:latest
    export FAROS_INIT_IMAGE=flowyzer/faros-ce-init:latest
    docker build -t flowyzer/faros-ce-init:latest .
    # docker compose pull faros-init
    # docker image ls appears to be sorted by creation date
    VERSION=$(docker image ls -q $FAROS_INIT_IMAGE | head -n 1)
    printf " Flowyzer init version $VERSION .\n"
    export FAROS_INIT_VERSION=$VERSION
    docker compose up --build --remove-orphans --detach && docker compose logs --follow faros-init
}

main "$@"
exit
