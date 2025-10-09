# Strimzi Kafka Helm Chart

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Helm Chart](https://img.shields.io/badge/Helm-Chart-blue)](https://helm.sh)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.25%2B-blue)](https://kubernetes.io)

A Helm chart to deploy a Kafka (KRaft) cluster using Strimzi Kafka Operator (0.48.0).

## Features
- Support for `KRaft` and `KafkaNodePool`
- Optional `NodePort` and `Ingress`
- Configuration via `values.yaml`
- Install hints in `templates/NOTES.txt`

## Requirements
- Kubernetes 1.25+
- Helm 3.x
- Strimzi Kafka Operator 0.48.0 installed

Install the operator (example):
```bash
helm repo add strimzi https://strimzi.io/charts/
helm repo update
helm install strimzi-operator strimzi/strimzi-kafka-operator \
  -n strimzi-system --create-namespace \
  -f strimzi-values.yaml
```

## Chart installation
Install with defaults:
```bash
helm install my-kafka ./kafka-cluster -n kafka --create-namespace
```

Enable Ingress:
```bash
helm install my-kafka ./kafka-cluster -n kafka \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=kafka.example.com \
  --set ingress.hosts[0].paths[0].path=/ \
  --set ingress.hosts[0].paths[0].pathType=Prefix
```

Enable NodePort:
```bash
helm install my-kafka ./kafka-cluster -n kafka \
  --set kafka.listeners.enableNodePort=true
```

Render without install:
```bash
helm template my-kafka ./kafka-cluster -f kafka-cluster/values.yaml
```

## Status checks
```bash
kubectl get pods -n kafka -l strimzi.io/cluster=kraft-cluster
kubectl get svc -n kafka kraft-cluster-kafka-brokers
```

## Configuration
- All parameters are described in `kafka-cluster/values.yaml` and the reference: `kafka-cluster/VALUES_REFERENCE.en.md`.
- Key values:
  - `namespace` — Kubernetes namespace
  - `kafka.clusterName` — cluster name
  - `kafka.version` — Kafka version
  - `kafka.listeners.enableNodePort` — enable NodePort
  - `ingress.enabled` — enable Ingress

## Contributing and templates
- See `CONTRIBUTING.md` for contribution rules and testing.
- Issue and PR templates: `.github/`.
- Code of Conduct: `CODE_OF_CONDUCT.md`.

## Security
Report vulnerabilities per `SECURITY.md` (do not open public issues).

## License
Apache-2.0. See `LICENSE`.

---

Read this in Russian: `README.md`
