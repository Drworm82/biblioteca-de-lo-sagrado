
## 28. Variantes textuales

Las variantes no se modelan como una modificación del Work ni como una simple nota editorial. Se representan mediante:

`TextualUnit → TextualVariant → TextualVariantReading`

Una variante identifica un punto concreto del texto donde existe una diferencia documentada o discutida. Cada reading identifica el testimonio que conserva esa lectura y puede conservar su unidad textual correspondiente.

Esto permite representar, por ejemplo, dos manuscritos con lecturas diferentes sin convertir una lectura posterior en el texto “verdadero”. La selección de una lectura para una edición queda separada del registro de las lecturas observadas.

## 29. Datación y cronología

Los valores enteros de año utilizan por defecto **numeración astronómica**: 1 a.C. = 0, 2 a.C. = -1, etc. Cuando una datación es relativa o no puede expresarse de forma calendárica, se declara mediante `chronology_basis`.

Cada DatingAssertion sigue siendo independiente: distintas propuestas académicas pueden coexistir con métodos, fuentes y niveles de confianza diferentes.

## 30. Integridad del versionado

Una revisión sólo puede apuntar mediante `previous_revision_id` a otra revisión de la **misma entidad**. La base de datos impide una cadena de revisiones cruzada entre entidades.

Una Publication sigue apuntando a una revisión concreta mediante una FK compuesta, por lo que una publicación histórica puede reconstruirse sin depender del estado actual del registro.

## 31. Cadena de evidencia

La estructura permite mantener separadas las capas:

`Evidence → Claim → Interpretation → Hypothesis`

Cada capa puede tener sus propias fuentes, localizadores, autor/atribución y confianza. Una hipótesis no sustituye la evidencia que la motivó y una interpretación no convierte automáticamente una observación en hecho.

## 32. Estado de estabilidad del recipiente

Con la migración 0003 quedan cubiertas las cuatro capas estructurales pendientes:

- variantes textuales;
- dataciones con convención explícita;
- cadena de evidencia, claims, interpretaciones e hipótesis;
- versionado editorial con linaje e historial protegidos.

El siguiente trabajo ya puede centrarse en validación con casos reales y en el corpus, sin que eso implique rediseñar estas capas fundamentales.



## 33. Acontecimientos históricos y cronología unificada

Los acontecimientos históricos se modelan como entidades propias mediante `historical_events`. Esto permite distinguir un acontecimiento de una obra, un testimonio o una evidencia arqueológica, aunque todos puedan aparecer en la misma cronología.

La línea temporal unificada puede reunir:

- obras y corpus;
- evidencias registradas;
- acontecimientos históricos.

La datación continúa en `dating_assertions`, por lo que una entrada puede conservar varias propuestas independientes. La interfaz no convierte una de ellas en la fecha “verdadera”.

Las fuentes de un acontecimiento se conservan mediante `historical_event_sources`.
