#!/bin/bash
clear

docker-compose up -d --force-recreate --build

clear


# Wait Rabbit to be running!
check=0;
while [ $check -eq 0 ]
do
    check=$(curl -sL -w "%{http_code}" -I http://localhost:15672 -o /dev/null);
    echo $check;
    echo "Wait RabbitMQ to be running...";
    sleep 2;
    clear
done

clear

echo -e "
DONE: We are ready!
FRONT:      http://localhost:8000
PHPMYADMIN: http://localhost:8100/phpmyadmin (User: hello Pass: hello)
RABBIT UI:  http://localhost:15672 (User: rabbitmq Pass: rabbitmq)
"