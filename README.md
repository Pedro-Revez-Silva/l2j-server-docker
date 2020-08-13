# L2j Server Docker

## Requirements 

### Windows

[Install Docker Desktop for Windows](https://hub.docker.com/editions/community/docker-ce-desktop-windows)

After the installation enable the following checkbox in docker desktop > settings

`[x] Expose daemon on tcp://localhost:2375 without TLS`

### Linux

[Install docker for Centos](https://docs.docker.com/engine/install/centos/)

[Install docker for Debian](https://docs.docker.com/engine/install/debian/)

Then start the linux service

`systemctl status docker.service`

### Mac

[Install Docker Desktop for Mac](https://hub.docker.com/editions/community/docker-ce-desktop-mac)

macOS must be version 10.13 or newer, i.e. High Sierra (10.13), Mojave (10.14) or Catalina (10.15).

### Raspberry

[Installing docker and docker-compose in Raspberry](https://dev.to/rohansawant/installing-docker-and-docker-compose-on-the-raspberry-pi-in-5-simple-steps-3mgl)

Working in Raspberry Pi 4B.

## Use docker-compose.yml

After the docker installation run the following command in any Linux / Windows terminal into the l2j-server-docker folder to get your local server running

`docker-compose -f "docker-compose.yml" up -d`

Wait until the server is fully deployed and connected to 127.0.0.1 and you are ready to go.

### Logging

If you want to check the logs while the server is starting/running use a terminal with the command

`docker logs l2j-server-docker --tail 50 -f` 

### Attaching a shell to check the container files manually

Attach a shell to navigate around the server container files

`docker exec -it l2j-server-docker /bin/sh -c "[ -e /bin/bash ] && /bin/bash || /bin/sh"`

### Configurable environment variables

The default values can be modified in the docker-compose.yml file

- SERVER_IP : Your private or public server IP  (default: "127.0.0.1")
- JAVA_XMS : Initial memory allocation pool (default: "512m")
- JAVA_XMX : Maximum memory allocation pool (default: "2g")
- RATE_XP : Rates for XP Gain (default: "1")
- RATE_SP : Rates for SP Gain (default: "1")
- ADMIN_RIGHTS : Everyone has Admin rights (default: "False")
- FORCE_GEODATA: Forces geodata (default: "False")
- COORD_SYNC: Coordinates sync configuration (default: "-1")
- HELLBOUND_ACCESS: Hellbound without Quest (default: "False")
- WEIGHT_LIMIT: Increases the weight limit ratio (default: "1")
- TVT_ENABLED: Enables the Team Vs Team PvP Event (default: "False")
- SAVE_GM_SPAWN_ON_CUSTOM: Save any admin spawn (default: "False")
- CUSTOM_SPAWNLIST_TABLE: Enables the custom spawnlist folder (default: "False")
- CUSTOM_NPC_DATA:  Enables the custom NPC data (default: "False")
- CUSTOM_TELEPORT_TABLE: Enables the custom teleport table (default: "False")
- CUSTOM_NPC_BUFFER_TABLES: Enables the NPC buffer scheme tables (default: "False")
- CUSTOM_SKILLS_LOAD: Enables the custom skills data (default: "False")
- CUSTOM_ITEMS_LOAD:  Enables the custom items data (default: "False")
- CUSTOM_MULTISELL_LOAD: Enables the multisell data (default: "False")
- CUSTOM_BUYLIST_LOAD: Enables the buylist data (default: "False")

### Managing the cluster with docker-compose.yml

Deploys the cluster (the first time)

`docker-compose -f "docker-compose.yml" up -d`

Stop the cluster

`docker-compose -f "docker-compose.yml" stop`

Start the cluster

`docker-compose -f "docker-compose.yml" start`

Removes the cluster containers (It will remove all your data)

`docker-compose -f "docker-compose.yml" down`


NOTE: To have a persistent database use stop/start after the deploy with `up`. And it's always recommended for live servers to stop the gameserver in-game before stop the whole container.


## Customize your own Docker images

If you want recreate the images yourself checkout the following Dockerfiles repositories

[yobasystems/alpine-mariadb](https://github.com/yobasystems/alpine-mariadb)

[l2jserver/l2j-server-docker](https://bitbucket.org/l2jserver/l2j-server-docker)

Just rename the images, customize and use them with your own docker-compose file.

## Customize your own container

If you want to add custom code to the container, first `stop` it and run this command from the console:

`docker cp ./custom/. l2j-server-docker:/` 

Starting again the l2j-server container the changes will take effect. [Read this for more information](https://bitbucket.org/l2jserver/l2j-server-docker/src/master/custom/README.md).

## Troubleshooting

Use `down` to stop the cluster but if you are experiencing problems execute the following commands to restart all the volumes and containers

`docker volume prune`

`docker system prune -a`


# License

L2J Server is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Please read the complete [LICENSE](https://bitbucket.org/l2jserver/l2j-server-docker/src/master/LICENSE.md)