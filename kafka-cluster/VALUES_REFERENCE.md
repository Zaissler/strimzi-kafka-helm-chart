# Документация значений (values)

Полная документация параметров Helm чарта для развертывания Kafka кластера с поддержкой различных сценариев.

## Содержание
- [Режимы развертывания](#режимы-развертывания)
- [Общие параметры](#общие-параметры)
- [Конфигурация Kafka](#конфигурация-kafka)
- [Конфигурация Node Pools](#конфигурация-node-pools)
- [EntityOperator](#entityoperator)
- [Ingress](#ingress)
- [Примеры использования](#примеры-использования)

---

## Режимы развертывания

Чарт поддерживает три режима развертывания, настраиваемых через параметр `deploymentMode`:

### 1. `single-node` - Одноузловой кластер
- **Описание**: Один узел с обеими ролями (broker + controller)
- **Использование**: Локальная разработка, тестирование
- **Факторы репликации**: Автоматически устанавливаются в 1
- **Пример**: `values-single-node.yaml`

### 2. `dual-role` - Dual-role кластер (по умолчанию)
- **Описание**: Несколько узлов, каждый выполняет обе роли (broker + controller)
- **Использование**: Staging окружения, средние кластеры
- **Факторы репликации**: Настраиваемые (обычно 3)
- **Пример**: `values-dual-role.yaml`

### 3. `separated-roles` - Раздельные роли
- **Описание**: Отдельные пулы узлов для broker и controller
- **Использование**: Production окружения, высокая нагрузка
- **Факторы репликации**: Настраиваемые (обычно 3)
- **Пример**: `values-separated-persistent.yaml`, `values-separated-ephemeral.yaml`

---

## Общие параметры

### `namespace`
- **Тип**: string
- **По умолчанию**: `dev`
- **Описание**: Kubernetes namespace для развертывания ресурсов

### `deploymentMode`
- **Тип**: string
- **По умолчанию**: `dual-role`
- **Допустимые значения**: `single-node`, `dual-role`, `separated-roles`
- **Описание**: Режим развертывания кластера

---

## Конфигурация Kafka

### `kafka.clusterName`
- **Тип**: string
- **По умолчанию**: `kraft-cluster`
- **Описание**: Имя Kafka кластера

### `kafka.version`
- **Тип**: string
- **По умолчанию**: `4.0.0`
- **Описание**: Версия Kafka

### `kafka.metadataVersion`
- **Тип**: string
- **По умолчанию**: `4.0-IV0`
- **Описание**: Версия метаданных для KRaft режима

### Репликация (`kafka.replication`)

Все параметры репликации автоматически адаптируются под `deploymentMode`:
- Для `single-node`: все значения = 1
- Для `dual-role` и `separated-roles`: используются указанные значения

#### `kafka.replication.offsetsTopicReplicationFactor`
- **Тип**: int
- **По умолчанию**: 3
- **Описание**: Фактор репликации для __consumer_offsets топика

#### `kafka.replication.transactionStateLogReplicationFactor`
- **Тип**: int
- **По умолчанию**: 3
- **Описание**: Фактор репликации для transaction state log

#### `kafka.replication.transactionStateLogMinIsr`
- **Тип**: int
- **По умолчанию**: 2
- **Описание**: Минимальный ISR для transaction state log

#### `kafka.replication.defaultReplicationFactor`
- **Тип**: int
- **По умолчанию**: 3
- **Описание**: Фактор репликации по умолчанию для топиков

#### `kafka.replication.minInsyncReplicas`
- **Тип**: int
- **По умолчанию**: 2
- **Описание**: Минимальное количество синхронных реплик

### Дополнительная конфигурация (`kafka.config`)
- **Тип**: map
- **Описание**: Дополнительные параметры конфигурации Kafka
- **Пример**:
  ```yaml
  kafka:
    config:
      auto.create.topics.enable: true
      log.retention.hours: 168
      compression.type: producer
  ```

### Слушатели (`kafka.listeners`)

#### `kafka.listeners.enableNodePort`
- **Тип**: bool
- **По умолчанию**: `true`
- **Описание**: Включает внешние NodePort слушатели

#### `kafka.listeners.externalnp`
- `port` (int, default: `31090`): Порт для external NodePort без TLS
- `tls` (bool, default: `false`): Включить TLS

#### `kafka.listeners.externaltls`
- `port` (int, default: `31091`): Порт для external NodePort с TLS
- `tls` (bool, default: `true`): Включить TLS

#### `kafka.listeners.plain`
- `port` (int, default: `9092`): Порт для internal слушателя без TLS
- `tls` (bool, default: `false`): Включить TLS

#### `kafka.listeners.tls`
- `port` (int, default: `9093`): Порт для internal слушателя с TLS
- `tls` (bool, default: `true`): Включить TLS

---

## Конфигурация Node Pools

### Для режимов `single-node` и `dual-role`

Используется секция `nodepool` (единственный пул):

#### `nodepool.name`
- **Тип**: string
- **По умолчанию**: `dual-role`
- **Описание**: Имя node pool

#### `nodepool.roles`
- **Тип**: list
- **По умолчанию**: `[broker, controller]`
- **Описание**: Роли узлов в пуле

#### `nodepool.replicas`
- **Тип**: int
- **По умолчанию**: 3 (для dual-role), 1 (для single-node)
- **Описание**: Количество реплик

#### `nodepool.storage.type`
- **Тип**: string
- **По умолчанию**: `persistent-claim`
- **Допустимые значения**: `persistent-claim`, `ephemeral`, `jbod`
- **Описание**: Тип хранилища

#### `nodepool.storage.size`
- **Тип**: string
- **По умолчанию**: `1Gi`
- **Описание**: Размер хранилища (для persistent-claim)

#### `nodepool.storage.deleteClaim`
- **Тип**: bool
- **По умолчанию**: `false`
- **Описание**: Удалять ли PVC при удалении пула

### Для режима `separated-roles`

Используется секция `nodepools` (множественные пулы):

#### `nodepools.controller`
Конфигурация пула controller узлов:
- `enabled` (bool, default: `true`): Включить controller пул
- `name` (string, default: `controller`): Имя пула
- `replicas` (int, default: `3`): Количество реплик
- `roles` (list, default: `[controller]`): Роли узлов
- `storage.type` (string, default: `persistent-claim`): Тип хранилища
- `storage.size` (string, default: `100Gi`): Размер хранилища
- `storage.deleteClaim` (bool, default: `false`): Удалять ли PVC

#### `nodepools.broker`
Конфигурация пула broker узлов:
- `enabled` (bool, default: `true`): Включить broker пул
- `name` (string, default: `broker`): Имя пула
- `replicas` (int, default: `3`): Количество реплик
- `roles` (list, default: `[broker]`): Роли узлов
- `storage.type` (string, default: `persistent-claim`): Тип хранилища
- `storage.size` (string, default: `100Gi`): Размер хранилища
- `storage.deleteClaim` (bool, default: `false`): Удалять ли PVC

---

## EntityOperator

Управление топиками и пользователями Kafka.

### `entityOperator.enabled`
- **Тип**: bool
- **По умолчанию**: `true`
- **Описание**: Включить EntityOperator

### `entityOperator.topicOperator.enabled`
- **Тип**: bool
- **По умолчанию**: `true`
- **Описание**: Включить Topic Operator

### `entityOperator.userOperator.enabled`
- **Тип**: bool
- **По умолчанию**: `true`
- **Описание**: Включить User Operator

---

## Ingress

### `ingress.enabled`
- **Тип**: bool
- **По умолчанию**: `false`
- **Описание**: Включить Ingress

### `ingress.annotations`
- **Тип**: map
- **Описание**: Аннотации для Ingress ресурса

### `ingress.hosts`
- **Тип**: list
- **Описание**: Список хостов с путями

### `ingress.tls`
- **Тип**: list
- **Описание**: TLS конфигурация

---

## Примеры использования

### Single-Node (разработка)
```bash
helm install kafka-dev ./kafka-cluster \
  -f values-single-node.yaml \
  -n dev --create-namespace
```

### Dual-Role (staging)
```bash
helm install kafka-staging ./kafka-cluster \
  -f values-dual-role.yaml \
  -n staging --create-namespace
```

### Separated-Roles с Persistent Storage (production)
```bash
helm install kafka-prod ./kafka-cluster \
  -f values-separated-persistent.yaml \
  -n prod --create-namespace
```

### Separated-Roles с Ephemeral Storage (тестирование)
```bash
helm install kafka-test ./kafka-cluster \
  -f values-separated-ephemeral.yaml \
  -n test --create-namespace
```

### Переопределение отдельных параметров
```bash
# Изменить режим развертывания
helm install kafka ./kafka-cluster \
  --set deploymentMode=single-node \
  -n dev --create-namespace

# Включить NodePort
helm install kafka ./kafka-cluster \
  --set kafka.listeners.enableNodePort=true \
  -n dev --create-namespace

# Изменить размер хранилища
helm install kafka ./kafka-cluster \
  --set nodepool.storage.size=50Gi \
  -n dev --create-namespace

# Включить Ingress
helm install kafka ./kafka-cluster \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=kafka.example.com \
  -n dev --create-namespace
```

### Проверка развертывания
```bash
# Проверить статус подов
kubectl get pods -n <namespace> -l strimzi.io/cluster=<clusterName>

# Проверить сервисы
kubectl get svc -n <namespace>

# Проверить Kafka ресурс
kubectl get kafka -n <namespace>

# Проверить KafkaNodePool ресурсы
kubectl get kafkanodepool -n <namespace>
```
