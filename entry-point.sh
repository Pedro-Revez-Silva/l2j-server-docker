#!/bin/sh

# Copyright 2004-2020 L2J Server
# L2J Server is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# L2J Server is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.

JAVA_XMS=${JAVA_XMS:-"512m"}
JAVA_XMX=${JAVA_XMX:-"2g"}
IP_ADDRESS=${IP_ADDRESS:-"127.0.0.1"}
LAN_SUBNET=${LAN_SUBNET:-"10.0.0.0/8"}
LAN_ADDRESS=${LAN_ADDRESS:-"10.0.0.0"}
RATES_XP=${RATE_XP:-"1"}
RATES_SP=${RATE_SP:-"1"}
WEIGHT_LIMIT=${WEIGHT_LIMIT:-"1"}
RUN_SPEED_BOOST=${RUN_SPEED_BOOST:-"1"}
RATE_ADENA=${RATE_ADENA:-"1"}
ADMIN_RIGHTS=${ADMIN_RIGHTS:-"False"}
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

echo "Waiting the mariadb service"

STATUS=$(nc -z mariadb 3306; echo $?)
while [ $STATUS != 0 ]
do
    sleep 3s
    STATUS=$(nc -z mariadb 3306; echo $?)
done

# ---------------------------------------------------------------------------
# Database Installation
# ---------------------------------------------------------------------------

DATABASE=`mysql -h mariadb -P 3306 -u root -proot -e "SHOW DATABASES" | grep l2jls`
if [ "$DATABASE" != "l2jls" ]; then
    mysql -h mariadb -P 3306 -u root -proot -e "DROP DATABASE IF EXISTS l2jls";
    mysql -h mariadb -P 3306 -u root -proot -e "DROP DATABASE IF EXISTS l2jgs";
    
    mysql -h mariadb -P 3306 -u root -proot -e "CREATE OR REPLACE USER 'l2j'@'%' IDENTIFIED BY 'l2jserver2019';";
    mysql -h mariadb -P 3306 -u root -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'l2j'@'%' IDENTIFIED BY 'l2jserver2019';";
    mysql -h mariadb -P 3306 -u root -proot -e "FLUSH PRIVILEGES;";
    
    chmod +x /opt/l2j/server/cli/l2jcli.sh
    java -jar /opt/l2j/server/cli/l2jcli.jar db install -sql /opt/l2j/server/login/sql -u l2j -p l2jserver2019 -m FULL -t LOGIN -c -mods -url jdbc:mariadb://mariadb:3306
    java -jar /opt/l2j/server/cli/l2jcli.jar db install -sql /opt/l2j/server/game/sql -u l2j -p l2jserver2019 -m FULL -t GAME -c -mods -url jdbc:mariadb://mariadb:3306
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
sed -i "s#/bin/bash#/bin/sh#g" /opt/l2j/server/login/LoginServer_loop.sh
sed -i "s#/bin/bash#/bin/sh#g" /opt/l2j/server/login/startLoginServer.sh

# ---------------------------------------------------------------------------
# General
# ---------------------------------------------------------------------------

# If this option is set to True every newly created character will have access level 127. This means that every character created will have Administrator Privileges.
# Default: False
sed -i "s#EverybodyHasAdminRights = False#EverybodyHasAdminRights = $ADMIN_RIGHTS#g" /opt/l2j/server/game/config/general.properties
sed -i "s#HellboundWithoutQuest = False#HellboundWithoutQuest = $HELLBOUND_ACCESS#g" /opt/l2j/server/game/config/general.properties

# ---------------------------------------------------------------------------
# Character
# ---------------------------------------------------------------------------
sed -i "s#WeightLimit = 1#WeightLimit = $WEIGHT_LIMIT#g" /opt/l2j/server/game/config/character.properties
sed -i "s#RunSpeedBoost = 0#RunSpeedBoost = $RUN_SPEED_BOOST#g" /opt/l2j/server/game/config/character.properties

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

sed -i "s#Enabled = False#Enabled = $TVT_ENABLED#g" /opt/l2j/server/game/config/tvt.properties
sed -i "s#CustomSpawnlistTable = False#CustomSpawnlistTable = $CUSTOM_SPAWNLIST_TABLE#g" /opt/l2j/server/game/config/general.properties
sed -i "s#SaveGmSpawnOnCustom = False#SaveGmSpawnOnCustom = $SAVE_GM_SPAWN_ON_CUSTOM#g" /opt/l2j/server/game/config/general.properties
sed -i "s#CustomNpcData = False#CustomNpcData = $CUSTOM_NPC_DATA#g" /opt/l2j/server/game/config/general.properties
sed -i "s#CustomTeleportTable = False#CustomTeleportTable = $CUSTOM_TELEPORT_TABLE#g" /opt/l2j/server/game/config/general.properties
sed -i "s#CustomNpcBufferTables = False#CustomNpcBufferTables = $CUSTOM_NPC_BUFFER_TABLES#g" /opt/l2j/server/game/config/general.properties
sed -i "s#CustomSkillsLoad = False#CustomSkillsLoad = $CUSTOM_SKILLS_LOAD#g" /opt/l2j/server/game/config/general.properties
sed -i "s#CustomItemsLoad = False#CustomItemsLoad = $CUSTOM_ITEMS_LOAD#g" /opt/l2j/server/game/config/general.properties
sed -i "s#CustomMultisellLoad = False#CustomMultisellLoad = $CUSTOM_MULTISELL_LOAD#g" /opt/l2j/server/game/config/general.properties
sed -i "s#CustomBuyListLoad = False#CustomBuyListLoad = $CUSTOM_BUYLIST_LOAD#g" /opt/l2j/server/game/config/general.properties

# ---------------------------------------------------------------------------
# Rates
# ---------------------------------------------------------------------------

sed -i "s#RateXp = 1#RateXp = $RATE_XP#g" /opt/l2j/server/game/config/rates.properties
sed -i "s#RateSp = 1#RateSp = $RATE_SP#g" /opt/l2j/server/game/config/rates.properties
sed -i "s#DropAmountMultiplierByItemId = 57,1#DropAmountMultiplierByItemId = 57,$RATE_ADENA#g" /opt/l2j/server/game/config/rates.properties

# ---------------------------------------------------------------------------
# Database
# ---------------------------------------------------------------------------

sed -i "s#jdbc:mariadb://localhost/l2jls#jdbc:mariadb://mariadb:3306/l2jls#g" /opt/l2j/server/login/config/database.properties
sed -i "s#jdbc:mariadb://localhost/l2jgs#jdbc:mariadb://mariadb:3306/l2jgs#g" /opt/l2j/server/game/config/database.properties

# ---------------------------------------------------------------------------
# Networking
# ---------------------------------------------------------------------------


DIC="/opt/l2j/server/game/config/default-ipconfig.xml"
if test -d "$DIC"; then
    if [ "$IP_ADDRESS" != "127.0.0.1" ]; then
        sed -i "s#gameserver address=\"127.0.0.1\"#gameserver address=\"$IP_ADDRESS\"#g" /opt/l2j/server/game/config/default-ipconfig.xml
    fi
    if [ "$LAN_SUBNET" != "10.0.0.0/8" ]; then+
        sed -i "s#define subnet=\"10.0.0.0/8\" address==\"10.0.0.0\"#define subnet=\"$LAN_SUBNET\" address==\"$LAN_ADDRESS\"#g" /opt/l2j/server/game/config/default-ipconfig.xml
    fi
    echo "default-ipconfig.xml file exists, moving default-ipconfig.xml to ipconfig.xml"
    mv /opt/l2j/server/game/config/default-ipconfig.xml /opt/l2j/server/game/config/ipconfig.xml
fi

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
