# Migration Guide

## Upgrading from 0.1.0 to 0.2.0

### Overview

Version 0.2.0 introduces multiple deployment modes and restructured configuration. The chart is **backward compatible** with version 0.1.0, but we recommend reviewing the new features and considering migration to one of the new deployment modes.

### What's Changed

1. **New `deploymentMode` parameter**: Automatically determines cluster topology
2. **Restructured `values.yaml`**: More organized and feature-rich
3. **Automatic replication factor calculation**: Adapts based on deployment mode
4. **New configuration profiles**: Ready-to-use examples for different scenarios

### Backward Compatibility

Your existing `values.yaml` will continue to work! The chart automatically detects the configuration style:

- If `deploymentMode` is not set and you have `nodepool.replicas=1` → `single-node` mode
- If `deploymentMode` is not set and you have both broker and controller roles → `dual-role` mode
- If you configure `nodepools` (plural) → `separated-roles` mode

### Migration Steps

#### Option 1: Keep Existing Configuration (Recommended for existing deployments)

No changes needed! Your existing values will work as-is:

```bash
# Your existing installation continues to work
helm upgrade my-kafka ./kafka-cluster -f my-old-values.yaml
```

#### Option 2: Migrate to New Configuration Format

**Step 1: Determine your current deployment pattern**

Check your current `values.yaml`:
- 1 replica → Migrate to `single-node`
- Multiple replicas with both roles → Migrate to `dual-role`
- Separate controller and broker pools → Already `separated-roles`

**Step 2: Choose the appropriate profile**

```bash
# For development (1 node)
cp kafka-cluster/values-single-node.yaml my-values.yaml

# For staging (3 dual-role nodes)
cp kafka-cluster/values-dual-role.yaml my-values.yaml

# For production (separated roles)
cp kafka-cluster/values-separated-persistent.yaml my-values.yaml
```

**Step 3: Customize your profile**

Edit `my-values.yaml` to match your specific requirements:
- Update `namespace`
- Update `kafka.clusterName`
- Adjust storage sizes
- Configure listeners as needed

**Step 4: Test with dry-run**

```bash
helm template my-kafka ./kafka-cluster -f my-values.yaml > rendered.yaml
# Review rendered.yaml to ensure correctness
```

**Step 5: Perform upgrade**

```bash
helm upgrade my-kafka ./kafka-cluster -f my-values.yaml
```

### Key Configuration Changes

#### Before (0.1.0)
```yaml
nodepool:
  name: default
  roles:
    - broker
    - controller
  replicas: 3
  storage:
    type: persistent-claim
    size: 1Gi
```

#### After (0.2.0 - Recommended)
```yaml
deploymentMode: dual-role  # Explicitly set mode

kafka:
  replication:
    defaultReplicationFactor: 3
    minInsyncReplicas: 2
    # Other replication settings...

nodepool:
  name: dual-role
  roles:
    - broker
    - controller
  replicas: 3
  storage:
    type: persistent-claim
    size: 1Gi
    deleteClaim: false
```

### New Features You Can Adopt

#### 1. Automatic Replication Factor Management

The chart now automatically calculates replication factors based on your deployment mode:

```yaml
# For single-node, all factors automatically set to 1
deploymentMode: single-node

# For dual-role or separated-roles, use configured values
kafka:
  replication:
    offsetsTopicReplicationFactor: 3
    transactionStateLogReplicationFactor: 3
    transactionStateLogMinIsr: 2
    defaultReplicationFactor: 3
    minInsyncReplicas: 2
```

#### 2. Storage Flexibility

New support for different storage types:

```yaml
nodepool:
  storage:
    type: persistent-claim  # or ephemeral, or jbod
    size: 100Gi
    deleteClaim: false
```

#### 3. Entity Operator Control

Fine-grained control over EntityOperator:

```yaml
entityOperator:
  enabled: true
  topicOperator:
    enabled: true
  userOperator:
    enabled: true
```

### Switching Between Deployment Modes

⚠️ **Warning**: Changing deployment modes on an existing cluster requires careful planning!

#### From Single-Node to Dual-Role

1. **Backup your data** (if persistent storage)
2. Scale up:
   ```bash
   helm upgrade my-kafka ./kafka-cluster \
     --set deploymentMode=dual-role \
     --set nodepool.replicas=3
   ```
3. Wait for new pods to join the cluster
4. Verify cluster health

#### From Dual-Role to Separated-Roles

1. **Plan for downtime** or rolling migration
2. Create new values file with `deploymentMode: separated-roles`
3. Deploy with new configuration:
   ```bash
   helm upgrade my-kafka ./kafka-cluster -f values-separated-roles.yaml
   ```
4. Monitor the transition carefully

### Troubleshooting

#### Issue: Replication factors don't match expectations

**Solution**: Check your `deploymentMode` setting. In `single-node` mode, all replication factors are forced to 1.

#### Issue: NodePools not created as expected

**Solution**: Verify that:
- For `dual-role`/`single-node`: Use `nodepool` (singular)
- For `separated-roles`: Use `nodepools` (plural) with `controller` and `broker` sections

#### Issue: Helm upgrade fails with validation errors

**Solution**: 
1. Check Helm template output: `helm template my-kafka ./kafka-cluster -f my-values.yaml`
2. Ensure all required fields are present
3. Verify your Strimzi Operator version is 0.48.0+

### Getting Help

- Review full documentation: `kafka-cluster/VALUES_REFERENCE.md`
- Check examples: `kafka-cluster/values-*.yaml` files
- Open an issue on GitHub with your configuration and error messages

### Rollback

If you encounter issues, you can rollback to the previous version:

```bash
helm rollback my-kafka
```

---

Читать на русском: [MIGRATION.md](MIGRATION.md)
