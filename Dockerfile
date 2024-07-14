FROM flyway/flyway:10.11.0 as faros-init
USER root
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get update \
  && apt-get -y install jq nodejs postgresql-client netcat wget iputils-ping nano sudo \
  && apt-get clean
RUN adduser --disabled-password --gecos "" flyway
RUN echo 'flyway:password' | chpasswd
RUN usermod -aG sudo flyway
USER flyway
RUN mkdir -p ~/flyway/faros
WORKDIR /home/flyway/faros
COPY init/.tsconfig.json init/package.json init/package-lock.json ./
COPY init/resources ./resources
COPY init/src ./src
RUN npm ci
COPY flowyzer-schemas ./flowyzer-schemas
COPY init/scripts ./scripts
WORKDIR /home/flyway/faros/scripts
# ENTRYPOINT ["tail", "-f", "/dev/null"]
ENTRYPOINT ["./entrypoint.sh"]
