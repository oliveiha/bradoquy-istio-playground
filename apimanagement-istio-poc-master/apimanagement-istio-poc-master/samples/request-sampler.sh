if [ -z "$CONTEXT" ]
    then
        CONTEXT="istio"
fi


if [ -z "$NAMESPACE" ]
    then
        NAMESPACE="randomapi"
fi


if [ $CANARY_HEADER  ]
    then
        CANARY_HEADER=" -H '$CANARY_HEADER'"
        echo "Using canary header"
    fi

COMMAND="while true; do curl -w ' - status: %{response_code}'  -s http://randomapi/request$CANARY_HEADER>/dev/stdout;echo; sleep 0.5; done"
echo "Command: $COMMAND"

echo "Removing old pod..."
kubectl --context=$CONTEXT -n $NAMESPACE delete --force=true --ignore-not-found=true pod curl-bash>/dev/null
kubectl --context=$CONTEXT -n $NAMESPACE run curl-bash --force=true --image=nginx --labels='app=curl-sampler' -- bash -c "$COMMAND"

echo "Waiting for pod ready..."
while true 
    do 
        phase=$(kubectl --context=$CONTEXT -n $NAMESPACE get pod curl-bash -o jsonpath={.status.phase})
        

        if [ "$phase" == "Running" ]
            then
                break                
            fi
    done


echo "Logs..."
kubectl --context=$CONTEXT -n $NAMESPACE logs curl-bash -f 
