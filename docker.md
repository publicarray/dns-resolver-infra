# Docker Machine

https://docs.docker.com/machine/drivers/

https://github.com/docker/docker.github.io/blob/master/machine/AVAILABLE_DRIVER_PLUGINS.md

## Vultr / Docker

```sh
brew install docker docker-machine docker-machine-driver-vultr # https://github.com/janeczku/docker-machine-vultr

docker-machine create -d vultr --vultr-region-id 19 --vultr-plan-id 201 --vultr-api-key "$VTOKEN" --vultr-ssh-key-id xxxxxxxxxxxxxx --vultr-ipv6 rancher-node

# docker-machine create -d digitalocean --digitalocean-region sfo1 --digitalocean-size 1gb --digitalocean-ssh-user xxxxxx --digitalocean-image rancheros --digitalocean-access-token $DOTOKEN rancher-node
```

## Google Cloud Platform

```sh
brew install docker docker-machine
brew cask intall google-cloud-sdk

gcloud auth login
gcloud auth application-default login # (should only be used temporarily)
gcloud compute images list --uri # for machine-image

docker-machine create -d google --google-project dns-infra-xxxxxxx --google-zone australia-southeast1-a --google-machine-type f1-micro --google-tags doh,dnscrypt,g-node --google-machine-image https://www.googleapis.com/compute/v1/projects/centos-cloud/global/images/centos-7-v20180507 g-node
# use "--google-preemptible" for testing

# https://rancher.com/docs/os/v1.1/en/running-rancheros/cloud/gce/
# https://cloud.google.com/sdk/gcloud/reference/compute/instances/create
#gcloud compute instances create g-node  --zone australia-southeast1-a --machine-type f1-micro --image xxxxxxxxxxxxxx

gcloud compute ssh g-node
docker-machine ssh g-node

eval "$(docker-machine env g-node)" # for fish: eval (docker-machine env g-node)
```
For logging I suggest you follow: https://cloud.google.com/community/tutorials/docker-gcplogs-driver

# Docker Swarm Setup

```sh
eval "$(docker-machine env rancher-node)" # for fish: eval (docker-machine env rancher-node)
docker-machine ls

docker swarm init --advertise-addr node_ip_address_from_docker-machine_ls
# docker swarm join --token your_swarm_token manager_node_ip_address:2377
docker node ls

 echo "email@example.com" | docker secret create CF_Email -
 echo "xxxxxxxxxxxxxx" | docker secret create CF_Key -

docker stack deploy --compose-file=docker-compose.yml dns-server
docker ps -a

# Some useful commands
docker-machine ssh rancher-node
docker-machine ip rancher-node
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
