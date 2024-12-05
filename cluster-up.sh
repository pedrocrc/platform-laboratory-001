#!/bin/bash
sed "s|PVCS_BASE_DIR|${PVCS_BASE_DIR}|g" kind.yaml > kind-effective.yaml
kind create cluster --config kind-effective.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_gatewayclasses.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_gateways.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_httproutes.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_referencegrants.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_grpcroutes.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/experimental/gateway.networking.k8s.io_tlsroutes.yaml
helm repo add cilium https://helm.cilium.io/
helm repo update
helm upgrade --install --namespace kube-system cilium cilium/cilium --version 1.16.4 \
    --namespace kube-system \
    --reuse-values \
    --set nodePort.enabled=true \
    --set l7Proxy=true \
    --set gatewayAPI.enabled=true \
    --set gatewayAPI.hostNetwork.enabled=true
kubectl create ns argocd
kubectl -n argocd create -f https://raw.githubusercontent.com/argoproj/argo-cd/refs/heads/master/manifests/install.yaml
kubectl -n argocd patch cm argocd-cmd-params-cm --type merge -p '{"data":{"server.insecure": "true"}}'
kubectl -n argocd patch cm argocd-cm --type merge -p '{"data":{"resource.exclusions": "- apiGroups:\n  - cilium.io\n  kinds:\n  - CiliumIdentity\n  clusters:\n  - \"*\""}}'
kubectl -n argocd patch cm argocd-cm --type merge -p '{"data":{"accounts.backstage": "apiKey", "accounts.backstage.enabled": "true"}}'
for file in argocd/manifests; do
    kubectl create -f $file
done
for file in argocd/applications; do
    kubectl create -f $file
done
kubectl create ns backstage
kubectl -n backstage create secret generic argocd-secret --from-literal=token=$(argocd account generate-token -a backstage)