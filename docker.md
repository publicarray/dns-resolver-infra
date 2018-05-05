# Docker Swarm Setup

```sh
brew install docker-machine docker-machine-driver-vultr # https://github.com/janeczku/docker-machine-vultr
docker-machine create -d vultr --vultr-region-id 19 --vultr-plan-id 201 --vultr-api-key "$VTOKEN" --vultr-ssh-key-id xxxxxxxxxxxxxx --vultr-ipv6 rancher-node
# docker-machine create --driver digitalocean --digitalocean-access-token $DOTOKEN machine-name
eval "$(docker-machine env rancher-node)" # for fish: eval (docker-machine env rancher-node)
docker-machine ls
# docker-machine ssh rancher-node
docker swarm init --advertise-addr node_ip_address_from_docker-machine_ls
# docker swarm join --token your_swarm_token manager_node_ip_address:2377
docker node ls

echo "email@example.com"| docker secret create CF_Email -
echo "xxxxxxxxxxxxxx" | docker secret create CF_Key -

docker stack deploy --compose-file=docker-compose.yml dns-server
docker ps -a

# Some useful commands
docker logs xxxxxxxxxxxxxx
docker exec -it xxxxxxxxxxxxxx sh
docker exec -it xxxxxxxxxxxxxx /entrypoint.sh provider-info # for dnscrypt-wrapper
docker stack rm dns-server # when things go wrong and you need to start form a blank slate
```

## Local development

```sh
docker-machine create -d virtualbox local
eval "$(docker-machine env local)" # for fish: eval (docker-machine env local)
```
