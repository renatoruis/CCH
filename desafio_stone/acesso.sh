#!/bin/bash
echo -e "VERIFICANDO DEPENDENCIAS\n"
command -v kubectl >/dev/null 2>&1 || { echo "Necessário instalar KUBECTL.  Saindo..." >&2; exit 1; }

CONFIGFILE="kubeconfig-stone.yaml"
URL_GOLDPINGER=$(kubectl --kubeconfig kubeconfig-stone.yaml get svc -n monitoramento goldpinger -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
SENHA_GRAFANA=$(kubectl --kubeconfig kubeconfig-stone.yaml get secret -n monitoramento grafana-admin -o jsonpath="{.data.GF_SECURITY_ADMIN_PASSWORD}" | base64 -D)

echo -e "
Para Acessaro GOLDPINGER\n
http://$URL_GOLDPINGER/ \n

=======================\n
Para Acessar o Grafana use o comando abaixo e acesse a URL no seu navegador.\n
kubectl --kubeconfig=kubeconfig-stone.yaml port-forward -n monitoramento service/grafana 3000:3000 \n
USUARIO: admin \n
SENHA: $SENHA_GRAFANA \n
URL: http://localhost:3000/login \n

=======================\n
Para Acessar o Prometheus use o comando abaixo e acesse a URL no seu navegador.\n
kubectl --kubeconfig=kubeconfig-stone.yaml port-forward -n monitoramento service/prometheus-server 9090:80 \n
URL: http://localhost:9090 \n

";