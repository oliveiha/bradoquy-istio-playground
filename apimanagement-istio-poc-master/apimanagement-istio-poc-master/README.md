# Service Mesh - Istio

Guia para instalação do _service mesh_ Istio em cluster único.

## Pré requisitos

* Cluster Kubernetes com suporte a _sidecar_
* Definição das variáveis de ambiente 
* Bash para execução dos comandos (em ambiente Windows, recomendamos a execução através de [WSL](https://docs.microsoft.com/en-us/windows/wsl/install) )
* ```kubectl``` para executar os comandos no ```Kubernetes```. [Clique aqui para executar os passos de instalação](https://kubernetes.io/docs/tasks/tools/#kubectl)
* ```yq``` para fazer a conversão de JSON para YAML dentro do ```install.sh``` [Clique aqui para executar a instalação do yq](https://github.com/mikefarah/yq/releases)

> Versões mais antigas do Openshift não suportam a injeção de _sidecar_ que é necessário para orquestração do _service mesh_.

## Instalando o service mesh no seu cluster
Para facilitar a instalação do Istio no seu cluster, você pode utilizar o _script_ ```install.sh``` informando os parâmetros obrigatórios

Parâmetro|Descrição
-|-
CONTEXT|Nome do contexto a ser usado pelo comando ```kubectl``` para executar os comandos no seu cluster. Ex: ```akspriv-cluster-env-admin```
NODE_SELECTOR_KEY_VALUE|Chave-valor do label usado para identificar o conjunto de nós a ser utilizado pelo IstioOperator. Ex.:
PROMETHEUS_URL|Url do serviço Prometheus que será utilizando para armazenar as métricas do _service mesh_.

Exemplo de execução de comando:
```bash
CONTEXT="akspriv-cluster-env-admin" NODE_SELECTOR_KEY_VALUE="app: tools" PROMETHEUS_URL="http://url-do-prometheus:9090" ./install.sh
```
Esta procedimento irá instalar:
* **Kiali**: Responsável pela visualização e gestão da malha de serviços. Veja mais detalhes na [documentação oficial](https://kiali.io/docs/features/wizards/)
* **Jaeger**: Responsável pelo tracing das chamadas. Veja mais detalhes na [documentação oficial](https://www.jaegertracing.io/)

> A configuração deste tutorial instala o Jaeger usando a memória como Storage Provider. Para usar em produção é recomendado utilizar o Elastic Search (ELK) como Storage Provider.

> Para usar o Elastic Search como provider basta alterar a variável ```SPAN_STORAGE_TYPE: badger``` para ```SPAN_STORAGE_TYPE=elasticsearch``` e adicionar o endereço do Elastic Search na variável ```ES_SERVER_URLS``` na tag ```Env```.

## Ativando o Istio na sua aplicação

### Variáveis de ambiente
Configure as variáveis de ambiente para que os próximos passos funcionem corretamente.

Nome|Valor
-|-
$NAMESPACE| _Namespace_ da sua aplicação. Ex.: ```NAMESPACE=default```

## Antes de instalar
* Revise as configurações que estão no arquivo [istio-operator-config.yaml](./istio-operator-config.yaml)


### Ativando o Istio no namespace da sua aplicação

```bash
kubectl label namespace $NAMESPACE istio-injection=enabled
```

> Você deve fazer isso em todos os ```namespaces``` das aplicações que estiver no _service mesh_

### Reiniciar a sua aplicação
Após configurado o _namespace_ da sua aplicação, é necessário fazer o _rollout_ dos _pods_ para que o _sidecar_ do _proxy_ do Istio comece a funcionar. Execute o seguinte comando:
 ```bash
 kubectl rollout restart -n $NAMESPACE deploy
 ``` 

Após reiniciado, sua aplicação deverá ter pelo menos dois _containers_, sendo um o ```istio-proxy``` e o outro o container da sua aplicação

**Exemplo**
```
NAME                              READY   STATUS    RESTARTS   AGE
details-v1-5dcdbcf76b-wdk8z       2/2     Running   0          55s
productpage-v1-78b4b49554-kf2k7   2/2     Running   0          55s
ratings-v1-7cc96fcd66-8zcrk       2/2     Running   0          53s
reviews-v1-768b79557d-hlgs5       2/2     Running   0          53s
reviews-v2-7fc47d7fdb-vvw7k       2/2     Running   0          53s
reviews-v3-7c4cbb98fd-5bwdp       2/2     Running   0          53s
```
