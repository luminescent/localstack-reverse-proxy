#!/bin/bash

docker container prune -f
docker network prune -f

sudo rm -rf /tmp/localstack/* 

docker-compose up