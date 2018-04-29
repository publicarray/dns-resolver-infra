Getting Started

```sh
minikube delete
minikube start
kubectl create -f cloudflare-secret.yml
# kubectl get secrets
# kubectl get secret cloudflare -o yaml

kubectl create -f acme-init-job.yml
kubectl create -f dnscrypt-wrapper/dnscrypt-init-job.yml

kubectl create -f nsd/nsd-srv.yml
kubectl create -f unbound/unbound-srv.yml
kubectl create -f doh-proxy/doh-proxy-srv.yml
kubectl create -f haproxy/haproxy-srv.yml
kubectl create -f dnscrypt-wrapper/dnscrypt-srv.yml

kubectl create -f nsd/nsd-deployment.yml
kubectl create -f unbound/unbound-deployment.yml
kubectl create -f doh-proxy/doh-proxy-deployment.yml
kubectl create -f haproxy/haproxy-deployment.yml
kubectl create -f dnscrypt-wrapper/dnscrypt-deployment.yml
```

Workflow

```sh
kubectl delete job/acme-init
kubectl create -f acme-init-job.yml
kubectl logs job/acme-init
kubectl get jobs
kubectl describe job/acme-init
```

Dashboard

```sh
kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
# or
minikube dashboard
```

Debugging

```sh
kubectl get nodes
kubectl get jobs
kubectl get deployments
kubectl get services
kubectl get pods -o wide
kubectl get all -l app=dns-server

## SSH into the container/pod
#export POD_NAME=$(kubectl get pods -o go-template --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')
kubectl get pods
kubectl logs job/dnscrypt-init
kubectl exec -ti $POD_NAME sh

## SSH into a new neighbouring container/pod
kubectl run busybox -it --image=busybox --restart=Never --rm
kubectl run alpine -it --image=alpine --restart=Never --rm

minikube ssh

kubectl logs deployment/nsd
kubectl describe deployment/nsd
```

Build docker images

```sh
docker build -t publicarray/nsd nsd/
docker build -t publicarray/unbound unbound/
docker build -t publicarray/doh-proxy doh-proxy/
docker build -t publicarray/haproxy haproxy/
docker build -t publicarray/dnscrypt-wrapper dnscrypt-wrapper/
docker images
docker push publicarray/unbound

docker run --rm --name myunbound -it publicarray/unbound sh
docker run -p 5300:53/udp -v (pwd)/unbound/unbound.conf:/etc/unbound/unbound.conf:ro --name myunbound publicarray/unbound
docker run -p 4430:443/udp -p 4430:443/tcp --name=dnscrypt-server dnscrypt init -N example.com -E 127.0.0.1:4430
docker start dnscrypt-server

docker rm dnscrypt-server --force
```
