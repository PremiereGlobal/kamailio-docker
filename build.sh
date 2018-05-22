#!/bin/bash

docker build -t kamailio-docker:latest .

KAM_TMP=$(docker run --rm --entrypoint="" -it kamailio-docker:latest /usr/sbin/kamailio -V | tr " " "\n")
X=($(echo $KAM_TMP | tr " " "\n"))

KAM_VER=${X[2]}

KAM_A=(${KAM_VER//./ })

docker tag rt-freeswitch:latest readytalk/kamailio-docker:${KAM_VER}
docker tag rt-freeswitch:latest readytalk/kamailio-docker:${KAM_A[0]}.${KAM_A[1]}
docker tag rt-freeswitch:latest readytalk/kamailio-docker:latest
echo "-----------------------"
echo "Saved Tag \"kamailio-docker:${KAM_VER}\""
echo "Saved Tag \"kamailio-docker:${KAM_A[0]}.${KAM_A[1]}\""
echo "Saved Tag \"kamailio-docker:latest\""
echo "-----------------------"

if [[ ${TRAVIS} && "${TRAVIS_BRANCH}" == "master" ]]; then
  docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"
  docker push readytalk/kamailio-docker:${KAM_VER}
  docker push readytalk/kamailio-docker:${KAM_A[0]}.${KAM_A[1]}
  docker push readytalk/kamailio-docker:latest
fi
