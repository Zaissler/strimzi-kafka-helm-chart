# Kafka Helm Chart

Helm chart для развертывания Kafka кластера на базе Strimzi Kafka Operator версии 0.48.0.

# Инструкция по развертыванию Strimzi Kafka с KRaft и доступом через NodePort

## Требования
- Kubernetes кластер с доступом к `kubectl`
- Strimzi Kafka Operator версии 0.48.0
- Longhorn CSI установлен и настроен (в качестве StorageClass)

---

## 1. Установка
```bash
helm repo add strimzi https://strimzi.io/charts/
helm repo update
helm install strimzi-operator strimzi/strimzi-kafka-operator -n strimzi-system --create-namespace
```

## Особенности

- Поддержка Kafka KRaft кластера с nodepool
- Опциональный nodePort и Ingress
- Управляемые параметры через values.yaml
- Удобный NOTES.txt с инструкциями по подключению и проверке

## Требования

- Kubernetes 1.25+
- Strimzi Kafka Operator 0.48.0 установлен и настроен
- Helm 3.x

## Установка

Установите чарт со значениями по умолчанию:

```bash
helm install my-kafka ./kafka-chart
```


Для включения Ingress:

```bash
helm install my-kafka ./kafka-chart --set ingress.enabled=true --set ingress.hosts.host=kafka.example.com
```

Для включения nodePort:

```bash
helm install my-kafka ./kafka-chart --set kafka.listeners.enableNodePort=true
```


## Проверка статуса

```bash
kubectl get pods -n kafka -l strimzi.io/cluster=kraft-cluster
kubectl get svc -n kafka kraft-cluster-kafka-brokers
```

## Конфигурация

Все параметры доступны в `values.yaml`. Основные:

- `namespace` — namespace Kubernetes
- `kafka.clusterName` — имя Kafka кластера
- `kafka.version` — версия Kafka
- `kafka.listeners.enableNodePort` — включение nodePort
- `ingress.enabled` — включение Ingress и др.

