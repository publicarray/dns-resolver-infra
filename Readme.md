Getting Started

```sh
minikube delete
minikube start
kubectl create -f cloudflare-secret.yml
# kubectl get secrets
# kubectl get secret cloudflare -o yaml


kubectl create -f acme-init-job.yml
kubectl create -f kube/dnscrypt-init-job.yml
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

```
kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
```
