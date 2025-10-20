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

## ⚙️ Configuration

### Ready-to-use Profiles
The chart includes ready configurations for different scenarios:

- `kafka-cluster/values.yaml` — base configuration (Dual-Role)
- `kafka-cluster/values-single-node.yaml` — for local development
- `kafka-cluster/values-dual-role.yaml` — for staging environments
- `kafka-cluster/values-separated-persistent.yaml` — for production with persistent storage
- `kafka-cluster/values-separated-ephemeral.yaml` — for testing with ephemeral storage

### Key Parameters

| Parameter | Description | Default Value |
|-----------|-------------|---------------|
| `deploymentMode` | Deployment mode | `dual-role` |
| `namespace` | Kubernetes namespace | `dev` |
| `kafka.clusterName` | Kafka cluster name | `kraft-cluster` |
| `kafka.version` | Kafka version | `4.0.0` |
| `kafka.replication.*` | Replication factors | Automatic |
| `kafka.listeners.enableNodePort` | Enable NodePort | `true` |
| `nodepool.replicas` | Number of nodes | `3` |
| `nodepool.storage.type` | Storage type | `persistent-claim` |
| `nodepool.storage.size` | Storage size | `1Gi` |
| `ingress.enabled` | Enable Ingress | `false` |

### Full Documentation
- Detailed description of all parameters: `kafka-cluster/VALUES_REFERENCE.en.md`
- Russian version: `kafka-cluster/VALUES_REFERENCE.md`
- Migration guide: `MIGRATION.md` ([Русская версия](MIGRATION.ru.md))
- Changelog: `CHANGELOG.md` ([Русская версия](CHANGELOG.ru.md))

## 📚 Documentation

### In English
- **Parameters Reference**: [VALUES_REFERENCE.en.md](kafka-cluster/VALUES_REFERENCE.en.md)
- **Migration Guide**: [MIGRATION.en.md](MIGRATION.en.md)
- **Changelog**: [CHANGELOG.en.md](CHANGELOG.en.md)

### На русском языке
- **Справочник параметров**: [VALUES_REFERENCE.md](kafka-cluster/VALUES_REFERENCE.md)
- **Руководство по миграции**: [MIGRATION.md](MIGRATION.md)
- **История изменений**: [CHANGELOG.md](CHANGELOG.md)

## Contributing and templates
- See `CONTRIBUTING.md` for contribution rules and testing.
- Issue and PR templates: `.github/`.
- Code of Conduct: `CODE_OF_CONDUCT.md`.

## Security
Report vulnerabilities per `SECURITY.md` (do not open public issues).

## License
Apache-2.0. See `LICENSE`.

---

Read this in Russian: [README.md](README.md)
