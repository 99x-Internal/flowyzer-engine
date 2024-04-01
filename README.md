# How to Install/Upgrade AirByte

1. Visit https://docs.airbyte.com/deploying-airbyte/local-deployment and follow the instructions to clone the AirByte GitHub
2. run ```./run-ab-platform.sh -d``` to download the files required files to run AirByte
3. Compare and replace the configurations in .env and docker-compose files (both docker-compose.yml and docker-compose.debug.yml). This will include version upgrades and other needed configurations.

