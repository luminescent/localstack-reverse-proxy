#!/bin/bash

docker container prune -f
docker network prune -f

docker-compose up