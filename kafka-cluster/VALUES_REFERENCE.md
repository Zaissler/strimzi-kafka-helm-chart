# Документация значений (values)

Ниже — ключевые параметры `values.yaml` с описанием и дефолтами.

## Общие
- `namespace` (string, default: `kafka`): Namespace для ресурсов.

## kafka
- `kafka.clusterName` (string, default: `kraft-cluster`): Имя кластера.
- `kafka.version` (string, default: `4.0.0`): Версия Kafka.
- `kafka.config` (map): Секция KRaft-конфигурации (например, `processRoles`, `controllerQuorumVoters`, и т.д.).

### Слушатели (listeners)
- `kafka.listeners.enableNodePort` (bool, default: `false`): Включает NodePort слушатели.
- `kafka.listeners.externalnp.port` (int, default: `31090`) и `tls` (bool, default: `false`).
- `kafka.listeners.externaltls.port` (int, default: `31091`) и `tls` (bool, default: `true`).
- `kafka.listeners.plain.port` (int, default: `9092`) и `tls` (bool, default: `false`).
- `kafka.listeners.tls.port` (int, default: `9093`) и `tls` (bool, default: `true`).

## nodepool
- `nodepool.name` (string, default: `default`)
- `nodepool.roles` (list, default: `[broker, controller]`)
- `nodepool.replicas` (int, default: `3`)
- `nodepool.storage.type` (string, default: `persistent-claim`)
- `nodepool.storage.size` (string, default: `1Gi`)

## ingress
- `ingress.enabled` (bool, default: `false`)
- `ingress.annotations` (map)
- `ingress.hosts` (list): Список хостов с путями.
- `ingress.tls` (list): Записи вида `{secretName, hosts[]}`.

## Примеры
Включить NodePort:

```bash
helm install my-kafka ./kafka-cluster --set kafka.listeners.enableNodePort=true
```

Включить Ingress:

```bash
helm install my-kafka ./kafka-cluster \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=kafka.example.com \
  --set ingress.hosts[0].paths[0].path=/ \
  --set ingress.hosts[0].paths[0].pathType=Prefix
```
