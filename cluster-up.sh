sed "s/PVCS_BASE_DIR/${PVCS_BASE_DIR}/g" kind.yaml > kind-effective.yaml
kind create cluster --config kind-effective.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_gatewayclasses.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_gateways.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_httproutes.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_referencegrants.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/standard/gateway.networking.k8s.io_grpcroutes.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.1.0/config/crd/experimental/gateway.networking.k8s.io_tlsroutes.yaml
helm upgrade --install --namespace kube-system --repo https://helm.cilium.io cilium cilium --version 1.16.4 \
    --namespace kube-system \
    --reuse-values \
    --set nodePort.enabled=true \
    --set l7Proxy=true \
    --set gatewayAPI.enabled=true \
    --set gatewayAPI.hostNetwork.enabled=true
kubectl create ns argocd
kubectl -n argocd create -f https://raw.githubusercontent.com/argoproj/argo-cd/refs/heads/master/manifests/install.yaml
kubectl create -f argocd/applications/*.yaml