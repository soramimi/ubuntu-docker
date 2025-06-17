UID := `id -u`
GID := `id -g`
UNAME := `id -un`
GNAME := `id -gn`
NAME := ubuntu-${UNAME}
HOMEDIR := /home/${UNAME}
SSHPORT := 65522
PASSWORD :=


PROJHOME = $(shell realpath .)
PROJNAME = $(shell basename ${PROJHOME})


#GPUS_ALL := --gpus all

#---

SSHD =
COMMAND =
ifeq (${PASSWORD},)
	COMMAND = sleep
else
	COMMAND = sshd
	SSHD = -p ${SSHPORT}:${SSHPORT} -e SSHPORT=${SSHPORT}
endif

#---

all:

run: down
	make _run RUN="uname -a"

required:
	# sudo pacman -S nvidia-container-toolkit

build:
	cd DockerBuildFiles && docker buildx build . --build-arg UNAME=${UNAME} --build-arg GNAME=${GNAME} --build-arg UID=${UID} --build-arg GID=${GID} --build-arg HOMEDIR=${HOMEDIR} -t ${NAME}

up: home srv home/.bashrc home/.profile 
	echo ${UNAME}:${PASSWORD} >./home/.password
	echo CONTAINER_NAME=${NAME} >./home/.container.sh
	docker run ${GPUS_ALL} --name ${NAME} -d -v ./srv:/srv -v ./home:${HOMEDIR} -e UNAME=${UNAME} -e GNAME=${GNAME} -e UID=${UID} -e GID=${GID} -e HOMEDIR=${HOMEDIR} -e CONTAINER_NAME=${NAME} -e COMMAND=${COMMAND} ${SSHD} ${NAME}

_run: home home/.bashrc home/.profile 
	@echo echo --->home/._run.sh
	@echo ${RUN} >>home/._run.sh
	@echo echo --->>home/._run.sh
	echo CONTAINER_NAME=${NAME} >./home/.container.sh
	docker run --device /dev/fuse --privileged --name ${NAME} --rm -v ${PROJHOME}:/${PROJNAME} -v ./home:${HOMEDIR} -e UNAME=${UNAME} -e GNAME=${GNAME} -e UID=${UID} -e GID=${GID} -e HOMEDIR=${HOMEDIR} -e CONTAINER_NAME=${NAME} -e COMMAND=run ${NAME}
	-@rm -f home/._run.sh

home:
	-mkdir home

srv:
	-mkdir srv

home/.bashrc:
	cp DockerBuildFiles/_bashrc ./home/.bashrc

home/.profile:
	cp DockerBuildFiles/_profile ./home/.profile

down:
	-docker kill ${NAME} 2>/dev/null
	-docker rm ${NAME} 2>/dev/null

sh:
	docker exec -it ${NAME} /usr/bin/su ${UNAME}

root:
	docker exec -it ${NAME} /bin/bash

ssh:
	ssh -XC localhost -p ${SSHPORT}

