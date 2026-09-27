# Arquitectura técnica

## Objetivo

Construir una biblioteca digital comparada que pueda crecer desde un corpus pequeño hasta un repositorio extenso de textos, manuscritos, traducciones, lugares, personas, conceptos y relaciones históricas sin tener que rediseñar el modelo fundamental.

## Principios

1. Los datos están separados de la interfaz.
2. Las entidades tienen identidad estable.
3. Las relaciones son explícitas y tipadas.
4. La incertidumbre histórica se conserva en los datos.
5. La procedencia de la información es trazable.
6. Los textos, manuscritos, ediciones y traducciones no se confunden entre sí.
7. La geografía es transversal.
8. La evidencia y la interpretación son capas diferentes.
9. El contenido editorial debe poder versionarse.
10. La interfaz debe poder evolucionar sin migrar el corpus.

## Arquitectura prevista

Frontend y backend iniciales:

- Next.js
- TypeScript
- React
- PostgreSQL
- Drizzle ORM
- Tailwind CSS

Infraestructura prevista:

- GitHub para código y contenido versionable.
- PostgreSQL para relaciones y consultas.
- Vercel para despliegue de la aplicación.
- Almacenamiento de objetos para imágenes y archivos voluminosos.

No se introducen microservicios en la primera fase. La aplicación será un monolito modular con límites claros entre dominios.

## Capas

### 1. Biblioteca

Es la capa principal:

- tradiciones
- obras
- expresiones textuales
- manuscritos
- ediciones
- traducciones
- variantes

### 2. Contexto

- periodos históricos
- personas
- acontecimientos
- notas filológicas
- arqueología
- fuentes académicas

### 3. Atlas y relaciones

- lugares
- regiones históricas
- rutas
- circulación
- relaciones entre entidades
- grafos
- comparación de motivos

## Regla de dependencia

La interfaz nunca debe ser la fuente de verdad de un dato histórico.

El flujo conceptual es:

Fuente → dato estructurado → modelo de dominio → API/consulta → interfaz.

## Evolución

La arquitectura se implementará incrementalmente. Se diseñarán desde ahora los límites que necesitaremos después, pero solo se activarán las capacidades cuando exista una necesidad real.

Ejemplo: el modelo soportará variantes manuscritas antes de que exista un módulo completo de crítica textual.
