# Руководство по миграции

## Обновление с версии 0.1.0 до 0.2.0

### Обзор

Версия 0.2.0 вводит множественные режимы развертывания и реструктурированную конфигурацию. Чарт **обратно совместим** с версией 0.1.0, но мы рекомендуем ознакомиться с новыми возможностями и рассмотреть миграцию на один из новых режимов развертывания.

### Что изменилось

1. **Новый параметр `deploymentMode`**: Автоматически определяет топологию кластера
2. **Реструктурированный `values.yaml`**: Более организованная и функциональная структура
3. **Автоматический расчет факторов репликации**: Адаптируется в зависимости от режима развертывания
4. **Новые конфигурационные профили**: Готовые к использованию примеры для различных сценариев

### Обратная совместимость

Ваш существующий `values.yaml` продолжит работать! Чарт автоматически определяет стиль конфигурации:

- Если `deploymentMode` не задан и у вас `nodepool.replicas=1` → режим `single-node`
- Если `deploymentMode` не задан и у вас обе роли broker и controller → режим `dual-role`
- Если вы настраиваете `nodepools` (множественное число) → режим `separated-roles`

### Шаги миграции

#### Вариант 1: Сохранить существующую конфигурацию (Рекомендуется для существующих развертываний)

Никаких изменений не требуется! Ваши существующие values будут работать как есть:

```bash
# Ваша существующая установка продолжит работать
helm upgrade my-kafka ./kafka-cluster -f my-old-values.yaml
```

#### Вариант 2: Мигрировать на новый формат конфигурации

**Шаг 1: Определите ваш текущий паттерн развертывания**

Проверьте ваш текущий `values.yaml`:
- 1 реплика → Мигрировать на `single-node`
- Несколько реплик с обеими ролями → Мигрировать на `dual-role`
- Отдельные пулы controller и broker → Уже `separated-roles`

**Шаг 2: Выберите подходящий профиль**

```bash
# Для разработки (1 узел)
cp kafka-cluster/values-single-node.yaml my-values.yaml

# Для staging (3 dual-role узла)
cp kafka-cluster/values-dual-role.yaml my-values.yaml

# Для production (разделенные роли)
cp kafka-cluster/values-separated-persistent.yaml my-values.yaml
```

**Шаг 3: Настройте ваш профиль**

Отредактируйте `my-values.yaml` для соответствия вашим требованиям:
- Обновите `namespace`
- Обновите `kafka.clusterName`
- Настройте размеры хранилища
- Настройте listeners по необходимости

**Шаг 4: Тестирование с dry-run**

```bash
helm template my-kafka ./kafka-cluster -f my-values.yaml > rendered.yaml
# Проверьте rendered.yaml для корректности
```

**Шаг 5: Выполните обновление**

```bash
helm upgrade my-kafka ./kafka-cluster -f my-values.yaml
```

### Ключевые изменения конфигурации

#### До (0.1.0)
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

#### После (0.2.0 - Рекомендуется)
```yaml
deploymentMode: dual-role  # Явно указываем режим

kafka:
  replication:
    defaultReplicationFactor: 3
    minInsyncReplicas: 2
    # Другие настройки репликации...

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

### Новые возможности, которые вы можете использовать

#### 1. Автоматическое управление факторами репликации

Чарт теперь автоматически рассчитывает факторы репликации на основе вашего режима развертывания:

```yaml
# Для single-node все факторы автоматически устанавливаются в 1
deploymentMode: single-node

# Для dual-role или separated-roles используются настроенные значения
kafka:
  replication:
    offsetsTopicReplicationFactor: 3
    transactionStateLogReplicationFactor: 3
    transactionStateLogMinIsr: 2
    defaultReplicationFactor: 3
    minInsyncReplicas: 2
```

#### 2. Гибкость хранилища

Новая поддержка различных типов хранилища:

```yaml
nodepool:
  storage:
    type: persistent-claim  # или ephemeral, или jbod
    size: 100Gi
    deleteClaim: false
```

#### 3. Управление Entity Operator

Детальное управление EntityOperator:

```yaml
entityOperator:
  enabled: true
  topicOperator:
    enabled: true
  userOperator:
    enabled: true
```

### Переключение между режимами развертывания

⚠️ **Внимание**: Изменение режимов развертывания на существующем кластере требует тщательного планирования!

#### Из Single-Node в Dual-Role

1. **Создайте резервную копию данных** (если используется persistent storage)
2. Масштабируйте:
   ```bash
   helm upgrade my-kafka ./kafka-cluster \
     --set deploymentMode=dual-role \
     --set nodepool.replicas=3
   ```
3. Дождитесь присоединения новых подов к кластеру
4. Проверьте здоровье кластера

#### Из Dual-Role в Separated-Roles

1. **Запланируйте простой** или rolling миграцию
2. Создайте новый values файл с `deploymentMode: separated-roles`
3. Разверните с новой конфигурацией:
   ```bash
   helm upgrade my-kafka ./kafka-cluster -f values-separated-roles.yaml
   ```
4. Тщательно следите за переходом

### Устранение неполадок

#### Проблема: Факторы репликации не соответствуют ожиданиям

**Решение**: Проверьте настройку `deploymentMode`. В режиме `single-node` все факторы репликации принудительно устанавливаются в 1.

#### Проблема: NodePools не создаются как ожидается

**Решение**: Убедитесь, что:
- Для `dual-role`/`single-node`: Используйте `nodepool` (единственное число)
- Для `separated-roles`: Используйте `nodepools` (множественное число) с секциями `controller` и `broker`

#### Проблема: Helm upgrade завершается с ошибками валидации

**Решение**: 
1. Проверьте вывод Helm template: `helm template my-kafka ./kafka-cluster -f my-values.yaml`
2. Убедитесь, что все обязательные поля присутствуют
3. Проверьте, что версия Strimzi Operator 0.48.0+

### Получение помощи

- Просмотрите полную документацию: `kafka-cluster/VALUES_REFERENCE.md`
- Проверьте примеры: файлы `kafka-cluster/values-*.yaml`
- Откройте issue на GitHub с вашей конфигурацией и сообщениями об ошибках

### Откат

Если вы столкнулись с проблемами, вы можете откатиться к предыдущей версии:

```bash
helm rollback my-kafka
```

---

Read this in English: [MIGRATION.en.md](MIGRATION.en.md)
