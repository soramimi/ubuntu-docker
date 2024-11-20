UID := `id -u`
GID := `id -g`
UNAME := `id -un`
GNAME := `id -gn`
NAME := ubuntu-${UNAME}
HOMEDIR := /home/${UNAME}
SSHPORT := 65522
PASSWORD :=

all:

build:
	cd DockerBuildFiles && docker buildx build . --build-arg UNAME=${UNAME} --build-arg GNAME=${GNAME} --build-arg UID=${UID} --build-arg GID=${GID} --build-arg HOMEDIR=${HOMEDIR} -t ${NAME}

up: home opt srv home/.bashrc home/.profile 
	echo ${UNAME}:${PASSWORD} >./home/.password
	echo CONTAINER_NAME=${NAME} >./home/.container.sh
	docker run --name ${NAME} -d -p ${SSHPORT}:${SSHPORT} -v ./opt:/opt -v ./srv:/srv -v ./home:${HOMEDIR} -e UNAME=${UNAME} -e GNAME=${GNAME} -e UID=${UID} -e GID=${GID} -e HOMEDIR=${HOMEDIR} -e CONTAINER_NAME=${NAME} -e SSHPORT=${SSHPORT} ${NAME}
	
home:
	-mkdir home

opt:
	-mkdir opt

srv:
	-mkdir srv

home/.bashrc:
	cp DockerBuildFiles/_bashrc ./home/.bashrc

home/.profile:
	cp DockerBuildFiles/_profile ./home/.profile

down:
	-docker kill ${NAME}
	-docker rm ${NAME}

sh:
	docker exec -it ${NAME} /usr/bin/su ${UNAME}

root:
	docker exec -it ${NAME} /bin/bash

ssh:
	ssh -XC localhost -p ${SSHPORT}

