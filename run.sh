docker rm -f $(docker ps -a -q)
docker rmi swift-todos
docker build -t swift-todos . 
docker run --name swift-todos -p 8090:8090 -d -t swift-todos