make delete_gocd_clients

docker image prune --all
docker network prune
docker volume prune

docker exec -it gocd_server find /godata/artifacts/pipelines/ -mmin +2880 -type f 
