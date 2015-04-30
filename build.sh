#!/bin/bash
docker kill vulnerablewordpress
docker rm vulnerablewordpress
docker build --rm -t wpscan/vulnerablewordpress .
docker run --name vulnerablewordpress -d -p 80:80 -p 3306:3306 wpscan/vulnerablewordpress
