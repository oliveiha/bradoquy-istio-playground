CONTEXT=istio
NAMESPACE=randomapi

MINIKUBE_CPUS=2
MINIKUBE_MEMORY=4gb

minikube version

if [ $? -ne 0 ]
        then
            echo "minikube need to be installed. Check https://minikube.sigs.k8s.io/docs/start/"
            exit 1
    fi

#FULL setup using minikube as k8s cluster. 

minikube delete -p $CONTEXT
minikube start --memory=$MINIKUBE_MEMORY --cpus=$MINIKUBE_CPUS -p $CONTEXT --driver=docker

minikube addons -p $CONTEXT enable metrics-server

# comandos do istio aqui
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack --kube-context $CONTEXT -n monitoring --create-namespace

CONTEXT=$CONTEXT PROMETHEUS_URL="http://prometheus-kube-prometheus-prometheus.monitoring.svc:9090" NODE_SELECTOR_KEY_VALUE="kubernetes.io/hostname: $CONTEXT" ./install.sh
if [ $? -ne 0 ]
        then            
            exit 1
    fi

kubectl  --context=$CONTEXT create namespace $NAMESPACE
kubectl  --context=$CONTEXT label namespace $NAMESPACE istio-injection=enabled

#bookinfo sample
kubectl --context=$CONTEXT apply -f ./samples/application-manifest.yaml
kubectl --context=$CONTEXT apply -f ./samples/destinationrules-default.yaml
kubectl --context=$CONTEXT apply -f ./samples/virtualservice-default.yaml
