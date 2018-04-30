#!/bin/sh

set -x

minikube delete
minikube start
# Enable DNS service: https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/
# kubectl --namespace=kube-system scale deployment kube-dns --replicas=1

kubectl create -f cloudflare-secret.yml

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


kubectl get nodes
kubectl get jobs
kubectl get deployments
kubectl get services
kubectl get pods -o wide
kubectl get all -l app=dns-server

minikube ip
kubectl get services
kubectl logs job/dnscrypt-init
