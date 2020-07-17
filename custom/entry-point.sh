#!/bin/sh

# Copyright 2004-2020 L2J Server
# L2J Server is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# L2J Server is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/. 

# This file will override the install entry-point after running 
# `docker cp custom/. l2j-server-docker:/.`
# Check the README.md file for more information

echo "Welcome Again to L2J Server (2004-2020)"

cd /opt/l2j/server/login/
sh startLoginServer.sh

cd /opt/l2j/server/game/
sh startGameServer.sh

sleep 5s	

tail -f /opt/l2j/server/game/log/stdout.log