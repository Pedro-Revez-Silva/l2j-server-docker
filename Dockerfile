# Copyright 2004-2020 L2J Server
# L2J Server is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# L2J Server is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/. 

FROM alpine:latest

COPY entry-point.sh /entry-point.sh

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk

RUN apk update \ 
    && apk --no-cache add openjdk11-jdk maven mariadb-client openjdk11-jre unzip git \
    && mkdir -p /opt/l2j/target && cd /opt/l2j/target/ \
    && git clone --branch master --single-branch https://git@bitbucket.org/l2jserver/l2j-server-cli.git cli \
    && git clone --branch master --single-branch https://git@bitbucket.org/l2jserver/l2j-server-login.git login \
    && git clone --branch develop --single-branch https://git@bitbucket.org/l2jserver/l2j-server-game.git game \
    && git clone --branch develop --single-branch https://git@bitbucket.org/l2jserver/l2j-server-datapack.git datapack \
    && cd /opt/l2j/target/cli && mvn install \
    && cd /opt/l2j/target/login && mvn install \
    && cd /opt/l2j/target/game && mvn install \
    && cd /opt/l2j/target/datapack && mvn install \
    && mkdir /opt/l2j/server \
    && unzip /opt/l2j/target/cli/target/*.zip -d /opt/l2j/server/cli \
    && unzip /opt/l2j/target/login/target/*.zip -d /opt/l2j/server/login \
    && unzip /opt/l2j/target/game/target/*.zip -d /opt/l2j/server/game \
    && unzip /opt/l2j/target/datapack/target/*.zip -d /opt/l2j/server/game \
    && rm -rf /opt/l2j/target/ && apk del maven git unzip \
    && chmod +x /opt/l2j/server/cli/*.sh /opt/l2j/server/game/*.sh /opt/l2j/server/login/*.sh /entry-point.sh

WORKDIR /opt/l2j/server

EXPOSE 7777 2106

ENTRYPOINT [ "/entry-point.sh" ]

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD [ "time" ]
