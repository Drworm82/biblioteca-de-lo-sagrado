# Arquitectura técnica

## Objetivo

Construir una biblioteca digital comparada de textos sagrados y religiosos que pueda crecer desde un corpus pequeño hasta un repositorio extenso de textos, manuscritos, traducciones, fuentes, lugares, personas, conceptos y relaciones históricas.

La arquitectura debe preservar la independencia entre:

- datos;
- dominio histórico/filológico;
- contenido editorial;
- interfaz;
- infraestructura.

## Principios

1. Los datos están separados de la interfaz.
2. Las entidades tienen identificadores estables.
3. Las relaciones son explícitas y tipadas.
4. La incertidumbre histórica se conserva.
5. La procedencia de la información es trazable.
6. Work, TextualWitness, Manuscript, Edition y Translation nunca se confunden.
7. La geografía es transversal.
8. Evidence, Claim, Interpretation y Hypothesis son capas distintas.
9. El contenido editorial puede versionarse.
10. Las contribuciones externas requieren revisión antes de publicación.
11. La interfaz no debe convertirse en la fuente de verdad del dato.
12. El modelo debe poder evolucionar sin rehacer el corpus.

## Arquitectura de dominio

### Registro de entidades

Un Entity Registry proporciona identidad estable para las entidades que participan en el grafo.

Las tablas de dominio conservan los atributos específicos.

### Biblioteca

Capa principal:

- Tradition
- Work
- TextualWitness
- Manuscript
- Edition
- Translation
- TextualUnit
- TextualVariant
- Language
- Script

### Contexto

- Person
- PersonWorkRole
- Place
- PlaceName
- Period
- DatingAssertion
- Source
- SourceLocation
- Evidence
- Claim
- Interpretation
- Hypothesis
- Concept

### Atlas y relaciones

- Relations
- lugares;
- regiones históricas;
- rutas;
- circulación;
- contactos;
- influencias;
- reinterpretaciones;
- sincretismos;
- cronología.

Toda relación histórica importante debe poder enlazar con fuentes y evidencia.

## Flujo conceptual

`Fuente → dato estructurado → modelo de dominio → consulta/API → interfaz`

Para afirmaciones interpretativas:

`Fuente → Evidence → Claim → Interpretation/Hypothesis → consulta/API → interfaz`

Para contenido colaborativo:

`Usuario → Contribution → Review → Revision → Publication`

## Arquitectura de contenido colaborativo

El contenido publicado no debe editarse directamente por usuarios externos.

Flujo:

`Usuario registrado`
→ `propuesta`
→ `revisión`
→ `aprobación`
→ `revisión publicada`

La aplicación debe conservar el historial completo.

Inicialmente:

- usuarios registrados pueden proponer;
- colaboradores pueden aportar contenido;
- editores pueden revisar;
- administrador puede aprobar.

La autorización debe ser una capacidad del dominio, no una decisión exclusiva de la interfaz.

## Capas de aplicación

### Biblioteca

Consulta y lectura de:

- obras;
- testimonios;
- manuscritos;
- ediciones;
- traducciones;
- unidades textuales.

### Contexto

Consulta de:

- personas;
- lugares;
- períodos;
- fuentes;
- evidencia;
- afirmaciones;
- interpretaciones.

### Atlas / Relaciones

Consulta de:

- mapas;
- líneas temporales;
- grafos;
- relaciones entre entidades;
- circulación;
- contactos;
- posibles influencias.

### Editorial

Gestión de:

- contribuciones;
- revisiones;
- revisores;
- decisiones;
- publicaciones;
- historial.

## Stack previsto

Frontend y backend inicial:

- Next.js
- TypeScript
- React
- Tailwind CSS

Persistencia:

- PostgreSQL
- Drizzle ORM

Infraestructura prevista:

- GitHub
- Vercel
- almacenamiento de objetos para imágenes, facsímiles y archivos voluminosos.

No introducir microservicios en la primera fase. La aplicación será un monolito modular con límites claros entre dominios.

## Regla de evolución

No implementar una capacidad solamente porque puede resultar útil en el futuro.

Primero se modelan los límites que sabemos que necesitaremos; después se activan las capacidades cuando exista una necesidad real.

Ejemplos:

- PostGIS cuando las consultas geográficas lo requieran.
- variantes textuales avanzadas cuando exista un corpus que las necesite.
- búsqueda especializada cuando el volumen lo justifique.
- almacenamiento documental/facsímil cuando el corpus lo requiera.

## Regla editorial

La interfaz nunca debe presentar una hipótesis como un hecho simplemente porque sea la interpretación más visible.

La UI debe conservar las diferencias entre:

- evidencia;
- afirmación;
- interpretación;
- hipótesis;
- tradición religiosa;
- afirmación popular no demostrada.

## Principio rector

> Primero el texto; después su contexto; finalmente sus relaciones.

La arquitectura técnica existe para conservar esa distinción, no para ocultarla.
