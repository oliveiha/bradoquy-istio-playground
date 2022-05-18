DRAFT

```bash
cat << EOF | istioctl install -y -f -
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  profile: default
  hub: harbor01.viavarejo.com.br/apimanagement/istio
  tag: 1.12.1
  components:
    ingressGateways:
    - name: istio-ingressgateway
      enabled: true
      k8s:
        hpaSpec:
            minReplicas: 1
            maxReplicas: 20
        nodeSelector:
            $NODE_SELECTOR
        resources:
            requests:
              cpu: 10m
              memory: 40Mi
            limits:
              cpu: "1"
              memory: 1Gi
        readinessProbe:
            timeoutSeconds: 1
        service:
            type: ClusterIP
    pilot:
      k8s:
        hpaSpec:
            minReplicas: 1
            maxReplicas: 20
        nodeSelector:
            $NODE_SELECTOR
        resources:
            requests:
              cpu: 50m
              memory: 50Mi
            limits:
              cpu: 500m
              memory: 512Mi
        readinessProbe:
            timeoutSeconds: 3
  meshConfig:
    enablePrometheusMerge: true
    accessLogFile: /dev/stdout
    accessLogEncoding: JSON
    enableTracing: true
    defaultConfig:
      proxyMetadata:
        # Enable basic DNS proxying
        ISTIO_META_DNS_CAPTURE: "true"
        # Enable automatic address allocation, optional
        ISTIO_META_DNS_AUTO_ALLOCATE: "true"     
EOF
```