# What is that folder?

This folder is an utility to copy resources after the l2j-server container is *created*.

The folder matchs the root container directory so the entry-point.sh can be also modified. It was intended for testing NPCs and custom scripts and improve the entry-point.sh without rebuild the image. 

You can modify the clean distributed files, like the script java files or any XML (overriding the  XML file with the modified one). **The files must to be in the same hierachy folder to be overrided.**

## Usage

Build the docker-compose. Join the /custom/ folder and execute:

`docker cp . l2j-server-docker:/.`

Starting again the l2j-server container the changes will take effect.

If a file exists it will be replaced, at the moment isn't doing any backup so take caution with this. You can copy the original file from the [data repository](https://bitbucket.org/l2jserver/l2j-server-datapack/src/develop/src/main/resources/data) to get again the working file.

It can be used also for testing the script files but be sure to add them to the script.cfg following the same package structure defined in [datapack script folder](https://bitbucket.org/l2jserver/l2j-server-datapack/src/develop/src/main/java/com/l2jserver/datapack/)

# License

L2J Server is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

Please read the complete [LICENSE](https://bitbucket.org/l2jserver/l2j-server-docker/src/master/LICENSE.md)

