#!/bin/bash

docker build -t webcam-capture-build -f docker/BuildDockerfile .
docker run -v $(pwd)/build:/app/build webcam-capture-build
