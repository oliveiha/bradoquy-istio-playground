# Exemplos

Os arquivos de exemplo ajudam a compreender e testar as configurações do _service mesh_. 

O projeto de exemplo é composto por um serviço que possui a versão em produção e a versão canário (_canary release_). O arquivo padrão [virtualservice-default.yaml](./virtualservice-default.yaml) é responsável por aplicar o roteamento básico entre estes dois serviços, fazendo um _load balance_ sem se preocupar para qual dos dois serviços a requisição está sendo enviada.

No entanto, outras configurações podem ser testadas com os arquivos que estão nesta mesma estrutura. Dentro de cada arquivo há uma breve descrição do que esta sendo aplicado.

## Instalando o ambiente de exemplo
Na pasta raíz do projeto há um arquivo chamado [install-demo.sh](../install-demo.sh) que pode ser executado para criar todo o ambiente. Para executá-lo é necessário:

* Docker - (https://docs.docker.com/get-docker/)
* Minikube - (https://minikube.sigs.k8s.io/docs/start/)
* Veja também os requisitos do [instalador padrão](../readme.md).

> Por padrão, uma máquina do Minikube é criada com 4GB de memáoria e 2 cpus. Mas estes parametros podem ser ajustados de acordo com a sua necessidade alterando as variáveis ```MINIKUBE_MEMORY``` e ```MINIKUBE_CPUS``` no arquivo [install-demo.sh](../install-demo.sh)

Para executar a instalação do ambiente de demonstração execute na pasta raíz do projeto:

```bash
./install-demo.sh
```

Ao instalar, será criada uma máquina no Minikube com o nome de ```istio``` e a aplicação de demonstração será criada no namespace ```randomapi```.

## Entendendo a ```randomapi```
A ```randomapi``` é um serviço com um único endpoint ```/request``` responsável por gerar requisições _mock_ e aleatórias. A versão v2 que está sendo executada neste exemplo, por padrão gera um número de falhas aleatórias. Estas configurações podem ser alteradas diretamente no ```configMap``` destas aplicações ```plan-config-v1``` e ```plan-config-v2```.

Para mais informações sobre a ```randomapi``` veja https://github.com/viavarejo-internal/apimanagement-random-api/blob/master/readme.md. 

## Fazendo chamadas por dentro do mesh
Para fazer execuções diretamente no _service mesh_ você pode utilizar o _script_ ```request-sampler.sh```. Ele irá criar um ```pod``` dentro _service mesh_ e ficará fazendo chamadas a ```randomapi```. Sendo assim, é possível criar cargas de requisições e testar as diferente configurações. Ao executá-lo, ele ficará verificando os _logs_ deste ```pod```. Este script usa o padrão do nome de máquina e _namespace_ criados pelo instalador de demonstração, porém é possível alterar as variáveis de ambiente no início do arquivo. 

Este arquivo pode ser executado de duas formas:

### Normal
```bash
./request-sampler.sh
```
### Com o header para rotear para canary
Desta forma você consegue testar o roteamento por header

```bash
CANARY_HEADER='x-use-canary:true' ./request-sampler.sh
```

## Aplicando as configurações
Para aplicar as configurações basta executar o comando ```kubectl apply -f arquivo.yaml```. Recomendamos setar variáveis de ambiente e executar o comando desta forma, para garantir a execução no ambiente correto.

Exemplo:

```bash
CONTEXT=istio #considerando o padrão do instalador install-demo.sh
NAMESPACE=randomapi #considerando o padrão do instalador install-demo.sh

kubectl --context=$CONTEXT --namespace=$NAMESPACE apply -f ./virtualservice-default.yaml
```

> Uma vez declaradas as variáveis de ambiente na sessão do terminal, basta reutilizá-las nas próximas chamadas

## Fazendo o port-forward
Este exemplo instala Jaeger, Kiali e Prometheus, para acessá-los utiize o arquivo [port-forward-services.sh](./port-forward-services.sh). 

```bash
./port-forward-services.sh
```
```
Prometheus                               http://localhost:9090
Kiali                                    http://localhost:20001
Jaeger                                   http://localhost:8081

```



