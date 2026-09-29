
## Estado de implementación

El esquema v1.1 ya tiene una implementación PostgreSQL inicial en `db/migrations/0001_initial_schema.sql`, seguida por el parche de integridad `0002_schema_integrity_patch.sql`. Las migraciones son forward-only; las pruebas de humo viven en `tests/database-schema.sql`. El corpus todavía no forma parte de la base.
