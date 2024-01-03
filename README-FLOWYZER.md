# Development of Flowyzer init docker image

This docker image is responsible in creating the faros database schema and running migrartions. 

```sh
docker build . -t flowyzer/faros-ce-init:latest
```

Stop the faros environment.

`./stop.sh`

Remove the docker containers.

`docker compose down`

If you want to create the database from scratch delete the docker volume `airbyte_db`

And then start it:

`./start.sh`

The `start.sh` script is modified to use the local `flowyzer/faros-ce-init` at initialization. 
