#!/bin/bash

PROJECT_NAME=braden-istio
CLUSTER_NAME=cluster-1
gcloud container clusters get-credentials $CLUSTER_NAME --zone us-central1-a --project $PROJECT_NAME

kubectl -n kube-system create sa tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account tiller

# local repo
helm install prometheus-operator --name prometheus-operator --namespace monitoring
helm install kube-prometheus --name kube-prometheus --set rbacEnable=true --namespace monitoring

# public rep
helm repo add coreos https://s3-eu-west-1.amazonaws.com/coreos-charts/stable/
helm install coreos/prometheus-operator --name prometheus-operator --namespace monitoring
helm install coreos/kube-prometheus --name kube-prometheus --set rbacEnable=true --namespace monitoring

# no ingress right now 
# port info: https://github.com/prometheus/prometheus/wiki/Default-port-allocations
kc port-forward $(kubectl get po -n monitoring -l app=kube-prometheus-grafana  -o custom-columns=:metadata.name) 3000:3000 -n monitoring &
kc port-forward prometheus-kube-prometheus-0 9090:9090 -n monitoring &
kc port-forward alertmanager-kube-prometheus-0 9093:9093 -n monitoring &

