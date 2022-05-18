ISTIO_VERSION=1.12.1

config_exclude_rule() {
    
    echo "Configuring rule"
    kubectl --context=$CONTEXT get crd opaRequiredLivenessProbe 

    if [ $1 -eq 0 ]
        then

            kubectl patch --context=$CONTEXT opaRequiredLivenessProbe rule-required-livenessprobe --type merge --patch-file ./setup/exclude-rule-liveness.yaml
            check_status_code

        fi
}

install_istio_operator() {
    echo "Installing Istio Operator"
    cat ./setup/istio-operator-config.yaml | sed "s/\$NODE_SELECTOR_KEY_VALUE/$NODE_SELECTOR_KEY_VALUE/" | istioctl install --context=$CONTEXT -y -f -
    check_status_code
    
}

config_prometheus() {
    echo "Configuring Prometheus"
    SERVICE_MONITOR_LABEL=$(kubectl --context=$CONTEXT get prometheus -A -o jsonpath='{.items[0].spec.podMonitorSelector.matchLabels}' | yq e -P -)
    cat ./setup/prometheus-config.yaml | sed "s/\$SERVICE_MONITOR_LABEL/$SERVICE_MONITOR_LABEL/" | kubectl --context=$CONTEXT apply -f -
    check_status_code
}

config_jaeger() {
    echo "Configuring Jaeger"
    cat ./setup/jaeger-config.yaml | sed "s/\$NODE_SELECTOR_KEY_VALUE/$NODE_SELECTOR_KEY_VALUE/"  | kubectl --context=$CONTEXT apply -f -
    check_status_code
}


config_kiali() {
    echo "Configuring Kiali"
    cat ./setup/kiali-manifest.yaml | sed "s/\$NODE_SELECTOR_KEY_VALUE/$NODE_SELECTOR_KEY_VALUE/" | sed "s/\$PROMETHEUS_URL/$PROMETHEUS_URL/" | kubectl --context=$CONTEXT apply -f -
    check_status_code
}

check_yq_installed() {
    yq -V
    if [ $? -ne 0 ]
        then
            echo "yq need to be installed. Check https://github.com/mikefarah/yq/releases"
            exit 1
    fi

}

check_kubectl_installed() {

    kubectl version
    if [ $? -ne 0 ]
        then
            echo "kubectl need to be installed. Check https://kubernetes.io/docs/tasks/tools/"
            exit 1
    fi
}

prepare_environment() {
    
    check_kubectl_installed
    check_yq_installed
    
    echo "Downloading Istio"
    curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$ISTIO_VERSION sh -
    export PATH=$PWD/istio-$ISTIO_VERSION/bin:$PATH
    check_status_code

}


check_vars() {

    

    if [ -z "$CONTEXT" ]
        then
            echo "CONTEXT cannot be null (Name of kubectl context used to access Kubernetes cluster)"
            EXITCODE="1"
    fi


    if [ -z "$NODE_SELECTOR_KEY_VALUE" ]
        then
            echo "NODE_SELECTOR_KEY_VALUE cannot be null (Key and value of labels to select correct node to place IstioOperator)"
            EXITCODE="1"
    fi

    if [ -z "$PROMETHEUS_URL" ]
        then
            echo "PROMETHEUS_URL cannot be null (Url where Prometheus service is running)"
            EXITCODE="1"
    fi

    if [ "$EXITCODE" == "1" ]
        then
            exit 1
    fi
    
}


check_status_code() {

    
    if [ $? -ne 0 ]
        then
            echo "Operation has aborted"
            exit 1
    fi
    
}




escape_vars() {
    NODE_SELECTOR_KEY_VALUE=$( echo $NODE_SELECTOR_KEY_VALUE | sed 's/\\/\\\\/g; s/\//\\\//g; s/\./\\./g; s/\:/\\\:/g; s/\-/\\\-/g' )
    PROMETHEUS_URL=$( echo $PROMETHEUS_URL | sed 's/\\/\\\\/g; s/\//\\\//g; s/\./\\./g; s/\:/\\\:/g; s/\-/\\\-/g' )
}



init() {
    
    check_vars
    escape_vars
    prepare_environment
    config_exclude_rule
    install_istio_operator
    config_prometheus
    config_jaeger
    config_kiali

}


init




