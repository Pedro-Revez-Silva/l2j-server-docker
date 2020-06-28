#!/bin/sh

# Copyright 2004-2020 L2J Server
# L2J Server is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# L2J Server is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.

JAVA_XMS=${JAVA_XMS:-"512m"}
JAVA_XMX=${JAVA_XMX:-"2g"}
SERVER_IP=${SERVER_IP:-"127.0.0.1"}
ADMIN_RIGHTS=${ADMIN_RIGHTS:-"False"}
RATES_XP=${RATE_XP:-"1"}
RATES_SP=${RATE_SP:-"1"}
HELLBOUND_ACCESS=${HELLBOUND_ACCESS:-"False"}
COORD_SYNC=${COORD_SYNC:-"-1"}
FORCE_GEODATA=${FORCE_GEODATA:-"False"}
WEIGHT_LIMIT=${WEIGHT_LIMIT:-"1"}
RUN_SPEED_BOOST=${RUN_SPEED_BOOST:-"1"}
RATE_ADENA=${RATE_ADENA:-"1"}
TVT_ENABLED=${TVT_ENABLED:-"False"}

echo "Waiting the mariadb service"
STATUS=$(nc -z mariadb 3306; echo $?)
while [ $STATUS != 0 ]
do
    sleep 3s
    STATUS=$(nc -z mariadb 3306; echo $?)
done

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

sed -i "s#WeightLimit = 1#WeightLimit = $WEIGHT_LIMIT#g" /opt/l2j/server/game/config/character.properties
sed -i "s#RunSpeedBoost = 0#RunSpeedBoost = $RUN_SPEED_BOOST#g" /opt/l2j/server/game/config/character.properties
sed -i "s#Enabled = False#Enabled = $TVT_ENABLED#g" /opt/l2j/server/game/config/tvt.properties

if [ "$FORCE_GEODATA" = "True" ]; then
    apk add git && git clone --branch master --single-branch https://git@bitbucket.org/l2jgeo/l2j_geodata.git /opt/l2j/server/geodata && apk del git
    mv -v /opt/l2j/server/geodata/geodata/* /opt/l2j/server/geodata/ && rm -rf /opt/l2j/server/geodata/geodata/
    sed -i 's#GeoDataPath = ./data/geodata#GeoDataPath = /opt/l2j/server/geodata#g' /opt/l2j/server/game/config/geodata.properties
    sed -i "s#ForceGeoData = True#ForceGeoData = $FORCE_GEODATA#g" /opt/l2j/server/game/config/geodata.properties
fi

if [ "$COORD_SYNC" != "-1" ]; then
    sed -i "s#CoordSynchronize = -1#CoordSynchronize = $COORD_SYNC#g" /opt/l2j/server/game/config/geodata.properties
fi


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

sed -i "s#jdbc:mariadb://localhost/l2jls#jdbc:mariadb://mariadb:3306/l2jls#g" /opt/l2j/server/login/config/database.properties

#Temp fix
sed -i "s#/bin/bash#/bin/sh#g" /opt/l2j/server/login/LoginServer_loop.sh
sed -i "s#/bin/bash#/bin/sh#g" /opt/l2j/server/login/startLoginServer.sh

cd /opt/l2j/server/login/
sh startLoginServer.sh

# If this option is set to True every newly created character will have access level 127. This means that every character created will have Administrator Privileges.
# Default: False
sed -i "s#EverybodyHasAdminRights = False#EverybodyHasAdminRights = $ADMIN_RIGHTS#g" /opt/l2j/server/game/config/general.properties
sed -i "s#HellboundWithoutQuest = False#HellboundWithoutQuest = $HELLBOUND_ACCESS#g" /opt/l2j/server/game/config/general.properties
 
# Experimental: 
#sed -i "s#GameServerHost = 127.0.0.1#GameServerHost = *#g" /opt/l2j/server/game/config/general.properties

sed -i "s#RateXp = 1#RateXp = $RATE_XP#g" /opt/l2j/server/game/config/rates.properties
sed -i "s#RateSp = 1#RateSp = $RATE_SP#g" /opt/l2j/server/game/config/rates.properties
sed -i "s#DropAmountMultiplierByItemId = 57,1#DropAmountMultiplierByItemId = 57,$RATE_ADENA#g" /opt/l2j/server/game/config/rates.properties

sed -i "s#jdbc:mariadb://localhost/l2jgs#jdbc:mariadb://mariadb:3306/l2jgs#g" /opt/l2j/server/game/config/database.properties

sed -i "s#gameserver address=\"127.0.0.1\"#gameserver address=\"$SERVER_IP\"#g" /opt/l2j/server/game/config/default-ipconfig.xml
if [ "$SERVER_IP" != "127.0.0.1" ]; then
	mv /opt/l2j/server/game/config/default-ipconfig.xml /opt/l2j/server/game/config/ipconfig.xml	
fi

sed -i "s#Xms512m#Xms$JAVA_XMS#g" /opt/l2j/server/game/GameServer_loop.sh
sed -i "s#Xmx2g#Xmx$JAVA_XMX#g" /opt/l2j/server/game/GameServer_loop.sh

cd /opt/l2j/server/game/
sh startGameServer.sh

#Temp
echo "Waiting the server log"
sleep 5s

tail -f /opt/l2j/server/game/logs/server.log
