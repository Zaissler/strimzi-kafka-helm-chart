# Strimzi Kafka Helm Chart (Русская версия)

Развертывание Kafka (KRaft) через Strimzi и Helm.

- Быстрый старт: `README.md`
- Справочник значений: `kafka-cluster/VALUES_REFERENCE.md`
- English: [English version](../index.md)

## Установка
```bash
helm repo add strimzi https://strimzi.io/charts/
helm repo update
helm install strimzi-operator strimzi/strimzi-kafka-operator \
  -n strimzi-system --create-namespace -f strimzi-values.yaml
helm install my-kafka ./kafka-cluster -n kafka --create-namespace
```

## Ссылки
- Исходники: `README.md`
- Безопасность: `SECURITY.md`
- Лицензия: `LICENSE`
- Вклад: `CONTRIBUTING.md`
