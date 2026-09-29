# Convenciones de migraciones

## Principios

- Las migraciones son **forward-only**: una migración aplicada no se edita para corregir datos históricos.
- Cada cambio estructural recibe un nuevo archivo numerado.
- El nombre debe ser descriptivo: `NNNN_descripcion.sql`.
- Las migraciones deben ejecutarse dentro de una transacción cuando PostgreSQL lo permita.
- Las restricciones de integridad pertenecen al esquema, no exclusivamente al código de la aplicación.
- Las tablas de historial editorial usan `ON DELETE RESTRICT`; no se debe borrar silenciosamente una cadena de procedencia.
- Una corrección posterior se implementa mediante otra migración.
- Antes de introducir datos del corpus se debe poder levantar el esquema desde cero ejecutando todas las migraciones en orden.

## Compatibilidad

Una migración debe considerar:

1. bases nuevas;
2. bases existentes;
3. datos ya publicados;
4. referencias históricas;
5. posibilidad de rollback operativo mediante una migración posterior, no mediante edición destructiva del pasado.

## Datos de catálogo

Los valores iniciales de vocabularios controlados pueden vivir en la migración que crea su tabla. Los datos editoriales del corpus no deben mezclarse con la infraestructura.

## Pruebas

`tests/database-schema.sql` contiene pruebas de humo que deben ejecutarse contra una base desechable después de aplicar todas las migraciones.

El siguiente nivel será añadir pruebas específicas para:

- variantes textuales;
- dataciones múltiples;
- relaciones con distinta confianza;
- evidencia → interpretación → hipótesis;
- historial de revisiones y publicaciones;
- prohibición de borrar entidades referenciadas.
