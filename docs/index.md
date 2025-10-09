# Strimzi Kafka Helm Chart

Deploy a Kafka (KRaft) cluster using Strimzi via Helm.

- Quick start: see `README.en.md`
- Values reference: `kafka-cluster/VALUES_REFERENCE.en.md`
- Russian docs: [Русская версия](./ru/index.md)

## Install
```bash
helm repo add strimzi https://strimzi.io/charts/
helm repo update
helm install strimzi-operator strimzi/strimzi-kafka-operator \
  -n strimzi-system --create-namespace -f strimzi-values.yaml
helm install my-kafka ./kafka-cluster -n kafka --create-namespace
```

## Links
- Source: `README.en.md`
- Security: `SECURITY.md`
- License: `LICENSE`
- Contributing: `CONTRIBUTING.md`
