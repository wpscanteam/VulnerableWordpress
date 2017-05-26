# if already running
```
docker kill vulnerablewordpress
docker rm vulnerablewordpress
```

# build and run
```
docker build --rm -t wpscanteam/vulnerablewordpress .
docker run --name vulnerablewordpress -d -p 80:80 -p 3306:3306 wpscanteam/vulnerablewordpress
```

# Get a shell
```
docker exec -i -t vulnerablewordpress bash
```
