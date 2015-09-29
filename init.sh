#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
MACHINE_EXISTS=$((docker-machine ls | grep "^default" >> /dev/null) && echo 1 || echo 0)


# Clone all the code
if [ ! -d "./codebases" ]; then
    mkdir codebases
fi

if [ ! -d "./codebases/api" ]; then
    git clone git@github.com:hegrec/immodispo-api.git ./codebases/api
    cd codebases/api
    npm install
    cd ../..
fi

if [ ! -d "./codebases/crawl" ]; then
    git clone git@github.com:hegrec/immodispo-crawl.git ./codebases/crawl
    cd codebases/crawl
    npm install
    cd ../..
fi

if [ ! -d "./codebases/web" ]; then
    git clone git@github.com:hegrec/immodispo-web.git ./codebases/web
    cd codebases/web
    npm install
    cd ../..
fi

if [ $MACHINE_EXISTS -eq 0 ]; then
    echo "Creating docker machine"
    docker-machine create --driver virtualbox default
fi

eval "$(docker-machine env default)"

DOCKER_VM_IP=$(docker-machine ip default)

#Add the immown.dev lookup to hosts file
echo "Editing hosts file to add immown.dev, requires sudo permission"
HOST_SET=$((sudo cat /etc/hosts | grep immown.dev >>/dev/null) && echo 1 || echo 0)

if [ $HOST_SET -eq 0 ]; then

    echo $DOCKER_VM_IP immown.dev | sudo tee -a /etc/hosts
    echo $DOCKER_VM_IP cdn.immown.dev | sudo tee -a /etc/hosts

fi

# Boot all the services from docker-compose.yml
docker-compose up -d --force-recreate

while :
do
    MYSQL_ONLINE=$((echo > /dev/tcp/immown.dev/3306) > /dev/null 2>&1 \
        && echo 1 || echo 0)

    if [ $MYSQL_ONLINE -eq 1 ]; then
        break
    fi

    echo "MySQL not online yet. Waiting..."
    sleep 5

done

# Run a mysql client container to connect to the mysql-server container and install the schema
docker run -it --link immown-mysql --rm -v ${DIR}/codebases/api/install:/install mysql:5.7 \
sh -c 'exec mysql immodispo < /install/install.sql -h "192.168.99.100" -P 3306 -uimmodispo -padmin123'

echo "Immown stack fully bootstrapped. Checkout the web app at http://immown.dev and the API at http://immown.dev:3001"
