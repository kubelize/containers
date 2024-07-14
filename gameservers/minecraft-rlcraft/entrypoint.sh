#!/bin/sh
echo eula=true > /home/mc/data/rlcraft_server/eula.txt
exec /usr/bin/java -Xmx8G -jar /home/mc/data/rlcraft_server/minecraft_server.jar nogui