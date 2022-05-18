#check if pods are running

kubectl --context=$CONTEXT -n istio-system port-forward svc/kiali 20001:20001>/tmp/kiali.log &
kubectl --context=$CONTEXT -n istio-system port-forward svc/tracing 8081:80>/tmp/jaeger.log &
kubectl --context=$CONTEXT -n monitoring port-forward svc/prometheus-kube-prometheus-prometheus 9090:9090>/tmp/jaeger.log &

echo -e 'Prometheus                    \t\t http://localhost:9090' 
echo -e 'Kiali                         \t\t http://localhost:20001'
echo -e 'Jaeger                        \t\t http://localhost:8081' 

