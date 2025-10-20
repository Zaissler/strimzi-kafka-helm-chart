# Strimzi Kafka Helm Chart

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Helm Chart](https://img.shields.io/badge/Helm-Chart-blue)](https://helm.sh)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.25%2B-blue)](https://kubernetes.io)

[Read in English](README.en.md)

Helm-чарт для развертывания кластера Kafka (KRaft) с помощью Strimzi Kafka Operator (0.48.0).

## Возможности
- Поддержка `KRaft` и `KafkaNodePool`
- Опциональные `NodePort` и `Ingress`
- Управление параметрами через `values.yaml`
- Подсказки установки в `templates/NOTES.txt`

## Требования
- Kubernetes 1.25+
- Helm 3.x
- Установленный Strimzi Kafka Operator 0.48.0

Установка оператора (пример):
```bash
helm repo add strimzi https://strimzi.io/charts/
helm repo update
helm install strimzi-operator strimzi/strimzi-kafka-operator \
  -n strimzi-system --create-namespace \
  -f strimzi-values.yaml
```

## Установка чарта
Установить чарт со значениями по умолчанию:
```bash
helm install my-kafka ./kafka-cluster -n kafka --create-namespace
```

Включить Ingress:
```bash
helm install my-kafka ./kafka-cluster -n kafka \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=kafka.example.com \
  --set ingress.hosts[0].paths[0].path=/ \
  --set ingress.hosts[0].paths[0].pathType=Prefix
```

Включить NodePort:
```bash
helm install my-kafka ./kafka-cluster -n kafka \
  --set kafka.listeners.enableNodePort=true
```

Рендер без установки:
```bash
helm template my-kafka ./kafka-cluster -f kafka-cluster/values.yaml
```

## Проверка статуса
```bash
kubectl get pods -n kafka -l strimzi.io/cluster=kraft-cluster
kubectl get svc -n kafka kraft-cluster-kafka-brokers
```

## ⚙️ Конфигурация

### Готовые профили
Чарт включает готовые конфигурации для разных сценариев:

- `kafka-cluster/values.yaml` — базовая конфигурация (Dual-Role)
- `kafka-cluster/values-single-node.yaml` — для локальной разработки
- `kafka-cluster/values-dual-role.yaml` — для staging окружений
- `kafka-cluster/values-separated-persistent.yaml` — для production с persistent storage
- `kafka-cluster/values-separated-ephemeral.yaml` — для тестирования с ephemeral storage

### Основные параметры

| Параметр | Описание | Значение по умолчанию |
|----------|----------|-----------------------|
| `deploymentMode` | Режим развертывания | `dual-role` |
| `namespace` | Kubernetes namespace | `dev` |
| `kafka.clusterName` | Имя Kafka кластера | `kraft-cluster` |
| `kafka.version` | Версия Kafka | `4.0.0` |
| `kafka.replication.*` | Факторы репликации | Автоматически |
| `kafka.listeners.enableNodePort` | Включение NodePort | `true` |
| `nodepool.replicas` | Количество узлов | `3` |
| `nodepool.storage.type` | Тип хранилища | `persistent-claim` |
| `nodepool.storage.size` | Размер хранилища | `1Gi` |
| `ingress.enabled` | Включение Ingress | `false` |

### Полная документация
- Детальное описание всех параметров: `kafka-cluster/VALUES_REFERENCE.md`
- Английская версия: `kafka-cluster/VALUES_REFERENCE.en.md`

## 📚 Документация

### На русском языке
- **Справочник параметров**: [VALUES_REFERENCE.md](kafka-cluster/VALUES_REFERENCE.md)
- **Руководство по миграции**: [MIGRATION.md](MIGRATION.md)
- **История изменений**: [CHANGELOG.md](CHANGELOG.md)

### In English
- **Parameters Reference**: [VALUES_REFERENCE.en.md](kafka-cluster/VALUES_REFERENCE.en.md)
- **Migration Guide**: [MIGRATION.en.md](MIGRATION.en.md)
- **Changelog**: [CHANGELOG.en.md](CHANGELOG.en.md)

## Вклад и шаблоны
- См. `CONTRIBUTING.md` для правил участия и тестирования.
- Шаблоны issues и PR: каталог `.github/`.
- Кодекс поведения: `CODE_OF_CONDUCT.md`.

## Безопасность
Сообщения об уязвимостях — по инструкции в `SECURITY.md` (не создавайте публичные issue).

## Лицензия
Проект распространяется по лицензии Apache-2.0. См. `LICENSE`.

