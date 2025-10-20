# Changelog

All notable changes to this project will be documented in this file.

## [0.2.0] - 2025-10-20

### ✨ Added
- **Multiple Deployment Modes**: Support for three deployment scenarios
  - `single-node`: Single node for development (1 replica, replication factor = 1)
  - `dual-role`: Dual-role nodes for staging (3 replicas, broker + controller)
  - `separated-roles`: Separated controller and broker pools for production
- **Flexible Storage Configuration**: Support for persistent, ephemeral, and JBOD storage types
- **Automatic Replication Factor Configuration**: Replication factors automatically adapt based on deployment mode
- **Ready-to-use Configuration Profiles**:
  - `values-single-node.yaml` for local development
  - `values-dual-role.yaml` for staging environments
  - `values-separated-persistent.yaml` for production with persistent storage
  - `values-separated-ephemeral.yaml` for testing with ephemeral storage
- **Helper Templates**: Added `_helpers.tpl` with utility functions for dynamic configuration
- **Enhanced NOTES.txt**: Detailed deployment information with mode-specific guidance
- **Comprehensive Documentation**: Updated `VALUES_REFERENCE.md` with full parameter documentation

### 🔧 Changed
- **values.yaml**: Restructured to support multiple deployment modes
- **node-pool.yaml**: Made dynamic to support all deployment scenarios
- **kafka-kraft.yaml**: Enhanced with automatic replication factor calculation
- **README.md**: Updated with deployment mode examples and quick start guide

### 📚 Documentation
- Complete parameter reference in `VALUES_REFERENCE.md`
- English documentation in `VALUES_REFERENCE.en.md`
- Usage examples for each deployment scenario
- Migration guide between deployment modes

## [0.1.0] - Initial Release

### Added
- Basic Kafka KRaft cluster deployment
- Support for KafkaNodePool
- Optional NodePort and Ingress
- Basic configuration management via values.yaml

---

Читать на русском: [CHANGELOG.md](CHANGELOG.md)
