export IMAGE=$1
docker-compose -f docker-compose.yaml up --detach
echo "Docker-compose file executed"