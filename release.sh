#!/bin/bash

docker build -t garden-build -f docker/BuildDockerfile .
docker run -v $(pwd)/build:/app/build garden-build
