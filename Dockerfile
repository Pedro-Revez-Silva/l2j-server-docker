# Copyright 2004-2020 L2J Server
# L2J Server is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# L2J Server is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/. 

FROM alpine:latest

COPY entry-point.sh /entry-point.sh

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk

RUN apk update \ 
    && apk --no-cache add openjdk11-jdk maven mariadb-client openjdk11-jre unzip git \
    && mkdir -p /opt/l2j/server && mkdir -p /opt/l2j/target && cd /opt/l2j/target/ \
    && git clone --branch master --single-branch https://git@bitbucket.org/l2jserver/l2j-server-cli.git cli \
    && git clone --branch master --single-branch https://git@bitbucket.org/l2jserver/l2j-server-login.git login \
    && git clone --branch develop --single-branch https://git@bitbucket.org/l2jserver/l2j-server-game.git game \
    && git clone --branch develop --single-branch https://git@bitbucket.org/l2jserver/l2j-server-datapack.git datapack \
    && cd /opt/l2j/target/cli && mvn install \
    && cd /opt/l2j/target/login && mvn install \
    && cd /opt/l2j/target/game && mvn install \
    && cd /opt/l2j/target/datapack && mvn install \
    && unzip /opt/l2j/target/cli/target/*.zip -d /opt/l2j/server/cli \
    && unzip /opt/l2j/target/login/target/*.zip -d /opt/l2j/server/login \
    && unzip /opt/l2j/target/game/target/*.zip -d /opt/l2j/server/game \
    && unzip /opt/l2j/target/datapack/target/*.zip -d /opt/l2j/server/game \
    && rm -rf /opt/l2j/target/ && apk del maven git \
    && chmod +x /opt/l2j/server/cli/*.sh /opt/l2j/server/game/*.sh /opt/l2j/server/login/*.sh /entry-point.sh

WORKDIR /opt/l2j/server

ENV JAVA_XMS "512m"
ENV JAVA_XMX "2g"
ENV IP_ADDRESS "127.0.0.1"
ENV DATABASE_ADDRESS "mariadb"
ENV DATABASE_PORT "3306"
ENV DATABASE_USER "root"
ENV DATABASE_PASS "root"
ENV LAN_ADDRESS "10.0.0.0"
ENV LAN_SUBNET "10.0.0.0/8"
ENV RATES_XP "1"
ENV RATES_SP "1"
ENV QUEST_MULTIPLIER_XP "1"
ENV QUEST_MULTIPLIER_SP "1"
ENV QUEST_MULTIPLIER_REWARD "1"
ENV WEIGHT_LIMIT "1"
ENV AUTO_LEARN_SKILLS "False"
ENV MAX_FREIGHT_SLOTS "200"
ENV DWARF_RECIPE_LIMIT "50"
ENV COMM_RECIPE_LIMIT "50"
ENV CRAFTING_SPEED_MULTIPLIER "1"
ENV FREE_TELEPORTING "False"
ENV STARTING_ADENA "0"
ENV STARTING_LEVEL "1"
ENV STARTING_SP "0"
ENV ALLOW_MANOR "True"
ENV SERVER_DEBUG "False"
ENV MAX_ONLINE_USERS "500"
ENV MAX_WAREHOUSE_SLOTS_DWARF "120"
ENV MAX_WAREHOUSE_SLOTS_NO_DWARF "100"
ENV MAX_WAREHOUSE_SLOTS_CLAN "200"
ENV PET_XP_RATE "1"
ENV RUN_SPEED_BOOST "1"
ENV RATE_ADENA "1"
ENV ADMIN_RIGHTS "False"
ENV COORD_SYNC "-1"
ENV FORCE_GEODATA "False"
ENV HELLBOUND_ACCESS "False"
ENV TVT_ENABLED "False"
ENV SAVE_GM_SPAWN_ON_CUSTOM "False"
ENV CUSTOM_SPAWNLIST_TABLE "False"
ENV CUSTOM_NPC_DATA "False"
ENV CUSTOM_TELEPORT_TABLE "False"
ENV CUSTOM_NPC_BUFFER_TABLES "False"
ENV CUSTOM_SKILLS_LOAD "False"
ENV CUSTOM_ITEMS_LOAD "False"
ENV CUSTOM_MULTISELL_LOAD "False"
ENV CUSTOM_BUYLIST_LOAD "False"
ENV VITALITY_SYSTEM "True"

EXPOSE 7777 2106

ENTRYPOINT [ "/entry-point.sh" ]