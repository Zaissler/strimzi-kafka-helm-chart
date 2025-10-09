# Values reference

Key `values.yaml` parameters with descriptions and defaults.

## General
- `namespace` (string, default: `kafka`): Namespace for resources.

## kafka
- `kafka.clusterName` (string, default: `kraft-cluster`): Cluster name.
- `kafka.version` (string, default: `4.0.0`): Kafka version.
- `kafka.config` (map): KRaft configuration (e.g., `processRoles`, `controllerQuorumVoters`, etc.).

### Listeners
- `kafka.listeners.enableNodePort` (bool, default: `false`): Enable NodePort listeners.
- `kafka.listeners.externalnp.port` (int, default: `31090`) and `tls` (bool, default: `false`).
- `kafka.listeners.externaltls.port` (int, default: `31091`) and `tls` (bool, default: `true`).
- `kafka.listeners.plain.port` (int, default: `9092`) and `tls` (bool, default: `false`).
- `kafka.listeners.tls.port` (int, default: `9093`) and `tls` (bool, default: `true`).

## nodepool
- `nodepool.name` (string, default: `default`)
- `nodepool.roles` (list, default: `[broker, controller]`)
- `nodepool.replicas` (int, default: `3`)
- `nodepool.storage.type` (string, default: `persistent-claim`)
- `nodepool.storage.size` (string, default: `1Gi`)

## ingress
- `ingress.enabled` (bool, default: `false`)
- `ingress.annotations` (map)
- `ingress.hosts` (list): Hosts with paths.
- `ingress.tls` (list): Items like `{secretName, hosts[]}`.

## Examples
Enable NodePort:
```bash
helm install my-kafka ./kafka-cluster --set kafka.listeners.enableNodePort=true
```

Enable Ingress:
```bash
helm install my-kafka ./kafka-cluster \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=kafka.example.com \
  --set ingress.hosts[0].paths[0].path=/ \
  --set ingress.hosts[0].paths[0].pathType=Prefix
```

---

Read this in Russian: `kafka-cluster/VALUES_REFERENCE.md`
