#!/bin/bash
docker kill wordpress
docker rm wordpress
docker build --rm -t firefart/wordpress .
docker run --name wordpress -d -p 80:80 -p 3306:3306 firefart/wordpress
