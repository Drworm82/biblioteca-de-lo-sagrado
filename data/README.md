# Datos

Esta carpeta contiene datos estructurados del proyecto.

## Dominios

- traditions/
- works/
- textual-witnesses/
- manuscripts/
- editions/
- translations/
- languages/
- people/
- places/
- periods/
- concepts/
- relations/
- sources/
- claims/
- evidence/

## Regla

Los identificadores deben ser estables. Los nombres visibles pueden cambiar.

Los datos históricos definitivos se incorporarán después de validar el esquema.

## Formatos

JSON será el formato inicial para datos pequeños y versionables.

PostgreSQL será la fuente de consulta relacional cuando se incorpore la capa de aplicación.

No se debe duplicar manualmente el mismo dato en varios archivos si puede derivarse mediante una relación.
