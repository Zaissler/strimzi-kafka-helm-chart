# Values Documentation

Complete documentation of Helm chart parameters for deploying Kafka cluster with support for various scenarios.

## Table of Contents
- [Deployment Modes](#deployment-modes)
- [General Parameters](#general-parameters)
- [Kafka Configuration](#kafka-configuration)
- [Node Pools Configuration](#node-pools-configuration)
- [EntityOperator](#entityoperator)
- [Ingress](#ingress)
- [Usage Examples](#usage-examples)

---

## Deployment Modes

The chart supports three deployment modes, configured via the `deploymentMode` parameter:

### 1. `single-node` - Single Node Cluster
- **Description**: One node with both roles (broker + controller)
- **Use case**: Local development, testing
- **Replication factors**: Automatically set to 1
- **Example**: `values-single-node.yaml`

### 2. `dual-role` - Dual-role Cluster (default)
- **Description**: Multiple nodes, each performs both roles (broker + controller)
- **Use case**: Staging environments, medium clusters
- **Replication factors**: Configurable (typically 3)
- **Example**: `values-dual-role.yaml`

### 3. `separated-roles` - Separated Roles
- **Description**: Separate node pools for broker and controller
- **Use case**: Production environments, high load
- **Replication factors**: Configurable (typically 3)
- **Example**: `values-separated-persistent.yaml`, `values-separated-ephemeral.yaml`

---

## General Parameters

### `namespace`
- **Type**: string
- **Default**: `dev`
- **Description**: Kubernetes namespace for deploying resources

### `deploymentMode`
- **Type**: string
- **Default**: `dual-role`
- **Allowed values**: `single-node`, `dual-role`, `separated-roles`
- **Description**: Cluster deployment mode

---

## JMX Monitoring

### `jmx.enabled`
- **Type**: bool
- **Default**: `false`
- **Description**: Enable JMX Prometheus Exporter for Kafka metrics export

When JMX is enabled, a ConfigMap is created with metric export rules, including:
- Broker metrics (throughput, latency, partition stats)
- Consumer/producer group metrics
- Topic metrics
- JVM metrics (memory, GC, threads)
- Operational metrics

Usage example:
```yaml
jmx:
  enabled: true
```

---

## Kafka Configuration

### `kafka.clusterName`
- **Type**: string
- **Default**: `kraft-cluster`
- **Description**: Kafka cluster name

### `kafka.version`
- **Type**: string
- **Default**: `4.0.0`
- **Description**: Kafka version

### `kafka.metadataVersion`
- **Type**: string
- **Default**: `4.0-IV0`
- **Description**: Metadata version for KRaft mode

### Replication (`kafka.replication`)

All replication parameters automatically adapt to `deploymentMode`:
- For `single-node`: all values = 1
- For `dual-role` and `separated-roles`: use specified values

#### `kafka.replication.offsetsTopicReplicationFactor`
- **Type**: int
- **Default**: 3
- **Description**: Replication factor for __consumer_offsets topic

#### `kafka.replication.transactionStateLogReplicationFactor`
- **Type**: int
- **Default**: 3
- **Description**: Replication factor for transaction state log

#### `kafka.replication.transactionStateLogMinIsr`
- **Type**: int
- **Default**: 2
- **Description**: Minimum ISR for transaction state log

#### `kafka.replication.defaultReplicationFactor`
- **Type**: int
- **Default**: 3
- **Description**: Default replication factor for topics

#### `kafka.replication.minInsyncReplicas`
- **Type**: int
- **Default**: 2
- **Description**: Minimum number of in-sync replicas

### Additional Configuration (`kafka.config`)
- **Type**: map
- **Description**: Additional Kafka configuration parameters
- **Example**:
  ```yaml
  kafka:
    config:
      auto.create.topics.enable: true
      log.retention.hours: 168
      compression.type: producer
  ```

### Listeners (`kafka.listeners`)

#### `kafka.listeners.enableNodePort`
- **Type**: bool
- **Default**: `true`
- **Description**: Enable external NodePort listeners

#### `kafka.listeners.externalnp`
- `port` (int, default: `31090`): Port for external NodePort without TLS
- `tls` (bool, default: `false`): Enable TLS

#### `kafka.listeners.externaltls`
- `port` (int, default: `31091`): Port for external NodePort with TLS
- `tls` (bool, default: `true`): Enable TLS

#### `kafka.listeners.plain`
- `port` (int, default: `9092`): Port for internal listener without TLS
- `tls` (bool, default: `false`): Enable TLS

#### `kafka.listeners.tls`
- `port` (int, default: `9093`): Port for internal listener with TLS
- `tls` (bool, default: `true`): Enable TLS

---

## Node Pools Configuration

### For `single-node` and `dual-role` modes

Use the `nodepool` section (single pool):

#### `nodepool.name`
- **Type**: string
- **Default**: `dual-role`
- **Description**: Node pool name

#### `nodepool.roles`
- **Type**: list
- **Default**: `[broker, controller]`
- **Description**: Node roles in the pool

#### `nodepool.replicas`
- **Type**: int
- **Default**: 3 (for dual-role), 1 (for single-node)
- **Description**: Number of replicas

#### `nodepool.storage.type`
- **Type**: string
- **Default**: `persistent-claim`
- **Allowed values**: `persistent-claim`, `ephemeral`, `jbod`
- **Description**: Storage type

#### `nodepool.storage.size`
- **Type**: string
- **Default**: `1Gi`
- **Description**: Storage size (for persistent-claim)

#### `nodepool.storage.deleteClaim`
- **Type**: bool
- **Default**: `false`
- **Description**: Delete PVC when removing the pool

### For `separated-roles` mode

Use the `nodepools` section (multiple pools):

#### `nodepools.controller`
Controller node pool configuration:
- `enabled` (bool, default: `true`): Enable controller pool
- `name` (string, default: `controller`): Pool name
- `replicas` (int, default: `3`): Number of replicas
- `roles` (list, default: `[controller]`): Node roles
- `storage.type` (string, default: `persistent-claim`): Storage type
- `storage.size` (string, default: `100Gi`): Storage size
- `storage.deleteClaim` (bool, default: `false`): Delete PVC

#### `nodepools.broker`
Broker node pool configuration:
- `enabled` (bool, default: `true`): Enable broker pool
- `name` (string, default: `broker`): Pool name
- `replicas` (int, default: `3`): Number of replicas
- `roles` (list, default: `[broker]`): Node roles
- `storage.type` (string, default: `persistent-claim`): Storage type
- `storage.size` (string, default: `100Gi`): Storage size
- `storage.deleteClaim` (bool, default: `false`): Delete PVC

---

## EntityOperator

Management of Kafka topics and users.

### `entityOperator.enabled`
- **Type**: bool
- **Default**: `true`
- **Description**: Enable EntityOperator

### `entityOperator.topicOperator.enabled`
- **Type**: bool
- **Default**: `true`
- **Description**: Enable Topic Operator

### `entityOperator.userOperator.enabled`
- **Type**: bool
- **Default**: `true`
- **Description**: Enable User Operator

---

## Ingress

### `ingress.enabled`
- **Type**: bool
- **Default**: `false`
- **Description**: Enable Ingress

### `ingress.annotations`
- **Type**: map
- **Description**: Annotations for Ingress resource

### `ingress.hosts`
- **Type**: list
- **Description**: List of hosts with paths

### `ingress.tls`
- **Type**: list
- **Description**: TLS configuration

---

## Usage Examples

### Single-Node (development)
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

### Separated-Roles with Persistent Storage (production)
```bash
helm install kafka-prod ./kafka-cluster \
  -f values-separated-persistent.yaml \
  -n prod --create-namespace
```

### Separated-Roles with Ephemeral Storage (testing)
```bash
helm install kafka-test ./kafka-cluster \
  -f values-separated-ephemeral.yaml \
  -n test --create-namespace
```

### Kafka with JMX Monitoring
```bash
helm install kafka-monitoring ./kafka-cluster \
  -f values-jmx.yaml \
  -n monitoring --create-namespace
```

### Override individual parameters
```bash
# Change deployment mode
helm install kafka ./kafka-cluster \
  --set deploymentMode=single-node \
  -n dev --create-namespace

# Enable NodePort
helm install kafka ./kafka-cluster \
  --set kafka.listeners.enableNodePort=true \
  -n dev --create-namespace

# Change storage size
helm install kafka ./kafka-cluster \
  --set nodepool.storage.size=50Gi \
  -n dev --create-namespace

# Enable Ingress
helm install kafka ./kafka-cluster \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=kafka.example.com \
  -n dev --create-namespace

# Enable JMX monitoring
helm install kafka ./kafka-cluster \
  --set jmx.enabled=true \
  -n dev --create-namespace
```

### Verify deployment
```bash
# Check pod status
kubectl get pods -n <namespace> -l strimzi.io/cluster=<clusterName>

# Check services
kubectl get svc -n <namespace>

# Check Kafka resource
kubectl get kafka -n <namespace>

# Check KafkaNodePool resources
kubectl get kafkanodepool -n <namespace>
```

---

Read this in Russian: [VALUES_REFERENCE.md](VALUES_REFERENCE.md)
