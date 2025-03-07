UID := `id -u`
GID := `id -g`
UNAME := `id -un`
GNAME := `id -gn`
NAME := ubuntu-${UNAME}
HOMEDIR := /home/${UNAME}
SSHPORT := 65522
PASSWORD := qwe123

PROJNAME := Example
PROJHOME := `realpath ../../${PROJNAME}`

all:

run-example: down
	make _run RUN="uname -a"

required:
	# sudo pacman -S nvidia-container-toolkit

build:
	cd DockerBuildFiles && docker buildx build . --build-arg UNAME=${UNAME} --build-arg GNAME=${GNAME} --build-arg UID=${UID} --build-arg GID=${GID} --build-arg HOMEDIR=${HOMEDIR} -t ${NAME}

up: home srv home/.bashrc home/.profile 
	echo ${UNAME}:${PASSWORD} >./home/.password
	echo CONTAINER_NAME=${NAME} >./home/.container.sh
	docker run --gpus all --name ${NAME} -d --network host -v ./srv:/srv -v ./home:${HOMEDIR} -e UNAME=${UNAME} -e GNAME=${GNAME} -e UID=${UID} -e GID=${GID} -e HOMEDIR=${HOMEDIR} -e CONTAINER_NAME=${NAME} -e COMMAND=up -e SSHPORT=${SSHPORT} ${NAME}

_run: home home/.bashrc home/.profile 
	echo ${RUN} >home/run.sh
	echo CONTAINER_NAME=${NAME} >./home/.container.sh
	docker run --device /dev/fuse --privileged --name ${NAME} --rm -v ${PROJHOME}:/${PROJNAME} -v ./home:${HOMEDIR} -e UNAME=${UNAME} -e GNAME=${GNAME} -e UID=${UID} -e GID=${GID} -e HOMEDIR=${HOMEDIR} -e CONTAINER_NAME=${NAME} -e COMMAND=run ${NAME}

home:
	-mkdir home

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

