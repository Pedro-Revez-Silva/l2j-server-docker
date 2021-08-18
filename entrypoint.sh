#!/bin/sh

# Copyright 2004-2020 L2J Server
# L2J Server is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# L2J Server is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.

JAVA_XMS=${JAVA_XMS:-"512m"}
JAVA_XMX=${JAVA_XMX:-"2g"}
IP_ADDRESS=${IP_ADDRESS:-"127.0.0.1"}
DATABASE_USER=${DATABASE_USER:-"root"}
DATABASE_PASS=${DATABASE_PASS:-"root"}
DATABASE_ADDRESS=${DATABASE_ADDRESS:-"mariadb"}
DATABASE_PORT=${DATABASE_PORT:-"3306"}
LAN_ADDRESS=${LAN_ADDRESS:-"10.0.0.0"}
LAN_SUBNET=${LAN_SUBNET:-"10.0.0.0/8"}
RATE_XP=${RATE_XP:-"1"}
RATE_SP=${RATE_SP:-"10"}
QUEST_MULTIPLIER_XP=${QUEST_MULTIPLIER_XP:-"10"}
QUEST_MULTIPLIER_SP=${QUEST_MULTIPLIER_SP:-"10"}
QUEST_MULTIPLIER_REWARD=${QUEST_MULTIPLIER_REWARD:-"20"}
VITALITY_SYSTEM=${VITALITY_SYSTEM:-"True"}
AUTO_LEARN_SKILLS=${AUTO_LEARN_SKILLS:-"True"}
MAX_FREIGHT_SLOTS=${MAX_FREIGHT_SLOTS:-"200"}
DWARF_RECIPE_LIMIT=${DWARF_RECIPE_LIMIT:-"200"}
COMM_RECIPE_LIMIT=${COMM_RECIPE_LIMIT:-"100"}
CRAFTING_SPEED_MULTIPLIER=${CRAFTING_SPEED_MULTIPLIER:-"3"}
FREE_TELEPORTING=${FREE_TELEPORTING:-"False"}
STARTING_ADENA=${STARTING_ADENA:-"0"}
STARTING_LEVEL=${STARTING_LEVEL:-"1"}
STARTING_SP=${STARTING_SP:-"0"}
ALLOW_MANOR=${ALLOW_MANOR:-"True"}
SERVER_DEBUG=${SERVER_DEBUG:-"False"}
MAX_ONLINE_USERS=${MAX_ONLINE_USERS:-"500"}
MAX_WAREHOUSE_SLOTS_DWARF=${MAX_WAREHOUSE_SLOTS_DWARF:-"200"}
MAX_WAREHOUSE_SLOTS_NO_DWARF=${MAX_WAREHOUSE_SLOTS_NO_DWARF:-"150"}
MAX_WAREHOUSE_SLOTS_CLAN=${MAX_WAREHOUSE_SLOTS_CLAN:-"200"}
PET_XP_RATE=${PET_XP_RATE:-"1"}
ITEM_SPOIL_MULTIPLIER=${ITEM_SPOIL_MULTIPLIER:-"10"}
ITEM_DROP_MULTIPLIER=${ITEM_DROP_MULTIPLIER:-"110"}
WEIGHT_LIMIT=${WEIGHT_LIMIT:-"10"}
RUN_SPEED_BOOST=${RUN_SPEED_BOOST:-"0"}
RATE_ADENA=${RATE_ADENA:-"10"}
ADMIN_RIGHTS=${ADMIN_RIGHTS:-"True"}
COORD_SYNC=${COORD_SYNC:-"-1"}
FORCE_GEODATA=${FORCE_GEODATA:-"False"}
HELLBOUND_ACCESS=${HELLBOUND_ACCESS:-"False"}
TVT_ENABLED=${TVT_ENABLED:-"False"}
SAVE_GM_SPAWN_ON_CUSTOM=${SAVE_GM_SPAWN_ON_CUSTOM:-"False"}
CUSTOM_SPAWNLIST_TABLE=${CUSTOM_SPAWNLIST_TABLE:-"False"}
CUSTOM_NPC_DATA=${CUSTOM_NPC_DATA:-"False"}
CUSTOM_TELEPORT_TABLE=${CUSTOM_TELEPORT_TABLE:-"False"}
CUSTOM_NPC_BUFFER_TABLES=${CUSTOM_NPC_BUFFER_TABLES:-"False"}
CUSTOM_SKILLS_LOAD=${CUSTOM_SKILLS_LOAD:-"False"}
CUSTOM_ITEMS_LOAD=${CUSTOM_ITEMS_LOAD:-"False"}
CUSTOM_MULTISELL_LOAD=${CUSTOM_MULTISELL_LOAD:-"False"}
CUSTOM_BUYLIST_LOAD=${CUSTOM_BUYLIST_LOAD:-"False"}
BUFFER_SERVICE=${BUFFER_SERVICE:-"False"}
BUFFER_SERVICE_COOLDOWN=${BUFFER_SERVICE_COOLDOWN:-"60"}
BUFFER_SERVICE_MAX_LISTS=${BUFFER_SERVICE_MAX_LISTS:-"5"}
BUFFER_DEBUG=${BUFFER_DEBUG:-"False"}
BUFFER_SERVICE_VOICED=${BUFFER_SERVICE_VOICED:-"False"}
BUFFER_SERVICE_VOICED_COMMAND=${BUFFER_SERVICE_VOICED_COMMAND:-"bufferservice"}
BUFFER_SERVICE_VOICED_NAME=${BUFFER_SERVICE_VOICED_NAME:-"Voiced"}
BUFFER_SERVICE_VOICED_REQUIRED_ITEM=${BUFFER_SERVICE_VOICED_REQUIRED_ITEM:-"0"}
DISCORD_BOT_ENABLE=${DISCORD_BOT_ENABLE:-"False"}
DISCORD_BOT_PREFIX=${DISCORD_BOT_PREFIX:-"//"}
DISCORD_BOT_TOKEN=${DISCORD_BOT_TOKEN:-"NzY3Mzg5NjE"}
DISCORD_BOT_CHANNEL_ID=${DISCORD_BOT_CHANNEL_ID:-"732358666681843752"}

echo "Using environment configuration:"
printenv | sort

echo "Waiting mariadb service in $DATABASE_ADDRESS:$DATABASE_PORT"
sleep 5s

STATUS=$(nc -z $DATABASE_ADDRESS $DATABASE_PORT; echo $?)
while [ "$STATUS" != 0 ]
do
    sleep 3s
    STATUS=$(nc -z $DATABASE_ADDRESS $DATABASE_PORT; echo $?)
done

# ---------------------------------------------------------------------------
# Database Installation
# ---------------------------------------------------------------------------

DATABASE=$(mysql -h "$DATABASE_ADDRESS" -P "$DATABASE_PORT" -u "$DATABASE_USER" -p"$DATABASE_PASS" -e "SHOW DATABASES" | grep l2jls)
if [ "$DATABASE" != "l2jls" ]; then
    mysql -h $DATABASE_ADDRESS -P $DATABASE_PORT -u "$DATABASE_USER" -p"$DATABASE_PASS" -e "DROP DATABASE IF EXISTS l2jls";
    mysql -h $DATABASE_ADDRESS -P $DATABASE_PORT -u "$DATABASE_USER" -p"$DATABASE_PASS" -e "DROP DATABASE IF EXISTS l2jgs";
    
    mysql -h $DATABASE_ADDRESS -P $DATABASE_PORT -u "$DATABASE_USER" -p"$DATABASE_PASS" -e "CREATE OR REPLACE USER 'l2j'@'%' IDENTIFIED BY 'l2jserver2019';";
    mysql -h $DATABASE_ADDRESS -P $DATABASE_PORT -u "$DATABASE_USER" -p"$DATABASE_PASS" -e "GRANT ALL PRIVILEGES ON *.* TO 'l2j'@'%' IDENTIFIED BY 'l2jserver2019';";
    mysql -h $DATABASE_ADDRESS -P $DATABASE_PORT -u "$DATABASE_USER" -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES;";
    
    chmod +x /opt/l2j/server/cli/l2jcli.sh
    java -jar /opt/l2j/server/cli/l2jcli.jar db install -sql /opt/l2j/server/login/sql -u l2j -p l2jserver2019 -m FULL -t LOGIN -c -mods -url jdbc:mariadb://$DATABASE_ADDRESS:$DATABASE_PORT
    java -jar /opt/l2j/server/cli/l2jcli.jar db install -sql /opt/l2j/server/game/sql -u l2j -p l2jserver2019 -m FULL -t GAME -c -mods -url jdbc:mariadb://$DATABASE_ADDRESS:$DATABASE_PORT
    #java -jar /opt/l2j/server/cli/l2jcli.jar account create -u l2j -p l2j -a 8 -url jdbc:mariadb://mariadb:3306
fi

# ---------------------------------------------------------------------------
# Log folders
# ---------------------------------------------------------------------------

LF="/opt/l2j/server/login/log"
if test -d "$LF"; then
    echo "Login log folder server exists"
else
    mkdir $LF
fi

GF="/opt/l2j/server/game/log"
if test -d "$GF"; then
    echo "Game log folder server exists"
else
    mkdir $GF
fi

#Temp fix
#sed -i "s#/bin/bash#/bin/sh#g" /opt/l2j/server/login/LoginServer_loop.sh
#sed -i "s#/bin/bash#/bin/sh#g" /opt/l2j/server/login/startLoginServer.sh

# ---------------------------------------------------------------------------
# General
# ---------------------------------------------------------------------------

# If this option is set to True every newly created character will have access level 127. This means that every character created will have Administrator Privileges.
# Default: False

# ---------------------------------------------------------------------------
# Character
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Geodata
# ---------------------------------------------------------------------------

if [ "$FORCE_GEODATA" = "True" ]; then
    apk add git && git clone --branch master --single-branch https://git@bitbucket.org/l2jgeo/l2j_geodata.git /opt/l2j/server/geodata && apk del git
    mv -v /opt/l2j/server/geodata/geodata/* /opt/l2j/server/geodata/ && rm -rf /opt/l2j/server/geodata/geodata/
    sed -i 's#GeoDataPath = ./data/geodata#GeoDataPath = /opt/l2j/server/geodata#g' /opt/l2j/server/game/config/geodata.properties
    sed -i "s#ForceGeoData = True#ForceGeoData = $FORCE_GEODATA#g" /opt/l2j/server/game/config/geodata.properties
fi

if [ "$COORD_SYNC" != "-1" ]; then
    sed -i "s#CoordSynchronize = -1#CoordSynchronize = $COORD_SYNC#g" /opt/l2j/server/game/config/geodata.properties
fi

# ---------------------------------------------------------------------------
# Custom Components
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Rates
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Vitaliy System
# ---------------------------------------------------------------------------

sed -i "s#Enabled = True#Enabled = $VITALITY_SYSTEM#g" /opt/l2j/server/game/config/vitality.properties

# ---------------------------------------------------------------------------
# Buffer Service
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Discord Properties
# ---------------------------------------------------------------------------

sed -i "s#BotEnable = False#BotEnable=$DISCORD_BOT_ENABLE#g" /opt/l2j/server/game/config/discord.properties
sed -i "s#BotPrefix = //#BotPrefix = $DISCORD_BOT_PREFIX#g" /opt/l2j/server/game/config/discord.properties
sed -i "s#BotToken = NzY3Mzg5NjE#BotToken=$DISCORD_BOT_TOKEN#g" /opt/l2j/server/game/config/discord.properties
sed -i "s#ConsoleLogChannelId = 732358666681843752#ConsoleLogChannelId=$DISCORD_BOT_CHANNEL_ID#g" /opt/l2j/server/game/config/discord.properties

# ---------------------------------------------------------------------------
# Server Properties
# ---------------------------------------------------------------------------

sed -i "s#MaxOnlineUsers = 500#MaxOnlineUsers = $MAX_ONLINE_USERS#g" /opt/l2j/server/game/config/server.properties

# ---------------------------------------------------------------------------
# Database
# ---------------------------------------------------------------------------

sed -i "s#jdbc:mariadb://localhost/l2jls#jdbc:mariadb://mariadb:3306/l2jls#g" /opt/l2j/server/login/config/database.properties
sed -i "s#jdbc:mariadb://localhost/l2jgs#jdbc:mariadb://mariadb:3306/l2jgs#g" /opt/l2j/server/game/config/database.properties

# ---------------------------------------------------------------------------
# Networking
# ---------------------------------------------------------------------------

cp /opt/l2j/server/game/config/default-ipconfig.xml /opt/l2j/server/game/config/ipconfig.xml
sed -i "s#gameserver address=\"127.0.0.1\"#gameserver address=\"$IP_ADDRESS\"#g" /opt/l2j/server/game/config/ipconfig.xml
sed -i "s#define subnet=\"10.0.0.0/8\" address=\"10.0.0.0\"#define subnet=\"$LAN_SUBNET\" address=\"$LAN_ADDRESS\"#g" /opt/l2j/server/game/config/ipconfig.xml

# ---------------------------------------------------------------------------
# Login and Gameserver start
# ---------------------------------------------------------------------------

cd /opt/l2j/server/login/
sh startLoginServer.sh

sed -i "s#Xms512m#Xms$JAVA_XMS#g" /opt/l2j/server/game/GameServer_loop.sh
sed -i "s#Xmx2g#Xmx$JAVA_XMX#g" /opt/l2j/server/game/GameServer_loop.sh

cd /opt/l2j/server/game/
sh startGameServer.sh

#Temp
echo "Waiting the server log"

sleep 5s

tail -f /opt/l2j/server/game/logs/server.log
